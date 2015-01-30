#!/usr/bin/env bash
#
# Reference implementation in Bash to interact with the MongoDB Management
# Service (MMS) REST API. Works for both host cloud version, On-Prem, and Ops
# Manager.
#
# Prerequisites:
#script to download the last snapshot (tarball) from MMS Backup, for
# the specified replica set.
#
# Dependencies:
#
#   - The goal here is to minimise dependencies as many production environments
#     are locked down. Thus we avoid the need to install any other software or
#     scripting languages or modules (e.g. Ruby, Python, Perl).
#
#   - The only dependency is on https://github.com/dominictarr/JSON.sh, a
#     fairly small Bash script to help parse the JSON returned from the MMS
#     REST API.
#
# See http://mms.mongodb.com/help-hosted/current/reference/api/ for details.
#
# Version: 1.0.0
# Author : James Tan <james.tan@mongodb.com>

set -e

# Default
MMS_API_VERSION=1.0
DOWNLOAD_DIR=backups

# ----------------------------------------------------------------------
JSON_tokenize () {
  local GREP
  local ESCAPE
  local CHAR

  if echo "test string" | egrep -ao --color=never "test" &>/dev/null; then
    GREP='egrep -ao --color=never'
  else
    GREP='egrep -ao'
  fi

  if echo "test string" | egrep -o "test" &>/dev/null; then
    ESCAPE='(\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\]'
  else
    GREP=awk_egrep
    ESCAPE='(\\\\[^u[:cntrl:]]|\\u[0-9a-fA-F]{4})'
    CHAR='[^[:cntrl:]"\\\\]'
  fi

  local STRING="\"$CHAR*($ESCAPE$CHAR*)*\""
  local NUMBER='-?(0|[1-9][0-9]*)([.][0-9]*)?([eE][+-]?[0-9]*)?'
  local KEYWORD='null|false|true'
  local SPACE='[[:space:]]+'

  $GREP "$STRING|$NUMBER|$KEYWORD|$SPACE|." | egrep -v "^$SPACE$"
}

JSON_parse () {
  read -r token
  JSON_parse_value
  read -r token
  case "$token" in
    '') ;;
    *) throw "EXPECTED EOF GOT $token" ;;
  esac
}

JSON_parse_value () {
  local jpath="${1:+$1,}$2" isleaf=0 isempty=0
  case "$token" in
    '{') JSON_parse_object "$jpath" ;;
    '[') JSON_parse_array  "$jpath" ;;
    # At this point, the only valid single-character tokens are digits.
    ''|[!0-9]) throw "EXPECTED value GOT ${token:-EOF}" ;;
    *) value=$token
       isleaf=1
       [ "$value" = '""' ] && isempty=1
       ;;
  esac
  [ "$value" = '' ] && return
  [ "$isleaf" -eq 1 ] && [ $isempty -eq 0 ] && printf "[%s]\t%s\n" "$jpath" "$value"
  :
}

JSON_parse_array () {
  local index=0 ary=''
  read -r token
  case "$token" in
    ']') ;;
    *)
      while :; do
        JSON_parse_value "$1" "$index"
        index=$((index+1))
        ary="$ary""$value"
        read -r token
        case "$token" in
          ']') break ;;
          ',') ary="$ary," ;;
          *) throw "EXPECTED , or ] GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
      ;;
  esac
}

JSON_parse_object () {
  local key
  local obj=''
  read -r token
  case "$token" in
    '}') ;;
    *)
      while :; do
        case "$token" in
          '"'*'"') key=$token ;;
          *) throw "EXPECTED string GOT ${token:-EOF}" ;;
        esac
        read -r token
        case "$token" in
          ':') ;;
          *) throw "EXPECTED : GOT ${token:-EOF}" ;;
        esac
        read -r token
        JSON_parse_value "$1" "$key"
        obj="$obj$key:$value"
        read -r token
        case "$token" in
          '}') break ;;
          ',') obj="$obj," ;;
          *) throw "EXPECTED , or } GOT ${token:-EOF}" ;;
        esac
        read -r token
      done
    ;;
  esac
}

# ----------------------------------------------------------------------

usage() {
    local self=`basename $0`
    echo "Usage: $self PARAMS [OPTIONS]"
    echo
    echo "Required parameters:"
    echo "  --user MMS_USER          MMS username, usually an email"
    echo "  --api-key API_KEY        MMS API key (eg. xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)"
    echo "  --server-url MMS_URL     MMS server URL (eg. http://mms-server:8080)"
    echo "  --group-id GROUP_ID      MMS group ID   (eg. 54c64146ae9fbe3d7f32c726)"
    echo "  --cluster-id CLUSTER_ID  MMS cluster ID (eg. 54c641560cf294969781b5c3)"
    echo
    echo "Options:"
    echo "  --download-dir DIR       Download directory. Default: '$DOWNLOAD_DIR'"
    echo
    echo "Miscellaneous:"
    echo "  --help                   Show this help message"
}

parse_options() {
    [ $# -eq 0 ] && usage && exit 1
    while [ $# -gt 0 ]; do
        case "$1" in
            --user        ) shift; MMS_USER=$1;;
            --api-key     ) shift; MMS_API_KEY=$1;;
            --server-url  ) shift; MMS_SERVER_URL=$1;;
            --group-id    ) shift; GROUP_ID=$1;;
            --cluster-id  ) shift; CLUSTER_ID=$1;;
            --download-dir) shift; DOWNLOAD_DIR=$1;;
            -h|--help     ) usage; exit 0;;
            *             ) echo "Unknown option(s): $*"; exit 1;;
        esac
        shift
    done
    [ "$MMS_USER"       = "" ] && echo "--user is not specified"       && exit 1;
    [ "$MMS_API_KEY"    = "" ] && echo "--api-key is not specified"    && exit 1;
    [ "$MMS_SERVER_URL" = "" ] && echo "--server-url is not specified" && exit 1;
    [ "$GROUP_ID"       = "" ] && echo "--group-id is not specified"   && exit 1;
    [ "$CLUSTER_ID"     = "" ] && echo "--cluster-id is not specified" && exit 1;
    true
}

api_get() {
    local url="groups/$GROUP_ID/clusters/$CLUSTER_ID/$1"
    curl --fail --silent --show-error --digest -u "$MMS_USER:$MMS_API_KEY" \
         "$MMS_SERVER_URL/api/public/v$MMS_API_VERSION/$url?pretty=true"
}

api_post() {
    local url="groups/$GROUP_ID/clusters/$CLUSTER_ID/$1"
    local data=$2
    curl --fail --silent --show-error --digest -u "$MMS_USER:$MMS_API_KEY" \
         -X POST -H "Content-Type: application/json" --data "$data" \
         "$MMS_SERVER_URL/api/public/v$MMS_API_VERSION/$url?pretty=true"
}

get_val() {
    local json=$1
    local grep_field=$2
    shift 2
    local cut_args=$*
    echo $json | JSON_tokenize | JSON_parse | grep "\[$grep_field\]" | cut $cut_args
}

get_latest_snapshot() {
    echo
    local res=$(api_get 'snapshots')

    SNAPSHOT_ID=$(           get_val "$res" '"results",0,"id"'                         -f6 -d'"')
    local created_date=$(    get_val "$res" '"results",0,"created","date"'             -f8 -d'"')
    local is_complete=$(     get_val "$res" '"results",0,"complete"'                   -f2)
    local type_name=$(       get_val "$res" '"results",0,"parts",0,"typeName"'         -f8 -d'"')
    local replica_set_name=$(get_val "$res" '"results",0,"parts",0,"replicaSetName"'   -f8 -d'"')
    local mongodb_version=$( get_val "$res" '"results",0,"parts",0,"mongodVersion"'    -f8 -d'"')
    local data_size=$(       get_val "$res" '"results",0,"parts",0,"dataSizeBytes"'    -f2)
    local storage_size=$(    get_val "$res" '"results",0,"parts",0,"storageSizeBytes"' -f2)
    local file_size=$(       get_val "$res" '"results",0,"parts",0,"fileSizeBytes"'    -f2)

    echo "Latest snapshot ID: $SNAPSHOT_ID"
    echo "Created on        : $created_date"
    echo "Complete?         : $is_complete"
    echo "Type name         : $type_name"
    echo "Replica set name  : $replica_set_name"
    echo "MongoDB version   : $mongodb_version"
    echo "Data size         : $data_size bytes"
    echo "Storage size      : $storage_size bytes"
    echo "File size         : $file_size bytes"
}

restore_snapshot() {
    echo
    local res=$(api_post 'restoreJobs' "{\"snapshotId\": \"$SNAPSHOT_ID\"}")
    RESTORE_ID=$(get_val "$res" '"results",0,"id"' -f6 -d'"')
    echo "Snapshot restore job ID: $RESTORE_ID"
}

wait_for_restore() {
    echo -n "Waiting for restore job..."

    # Possible values are: FINISHED IN_PROGRESS BROKEN KILLED
    local job_status="IN_PROGRESS"
    while [ "$job_status" = "IN_PROGRESS" ]; do
        sleep 1
        echo -n '.'
        local res=$(api_get "restoreJobs/$RESTORE_ID")
        job_status=$(get_val "$res" '"statusName"' -f4 -d'"')
    done
    echo
    echo "Job status: $job_status"

    DOWNLOAD_URL=$(get_val "$res" '"delivery","url"' -f6 -d'"')
}

download() {
    echo
    echo "Downloading restore tarball(s) to $DOWNLOAD_DIR/..."
    mkdir -p "$DOWNLOAD_DIR"
    wget -P "$DOWNLOAD_DIR" $DOWNLOAD_URL
}

parse_options $*
get_latest_snapshot
restore_snapshot
wait_for_restore
download