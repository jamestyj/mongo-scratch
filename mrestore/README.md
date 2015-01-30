# mms_backup

Reference implementation in Bash to interact with the MongoDB Management
Service (MMS) REST API. Works for both host cloud version, On-Prem, and Ops
Manager.

Prerequisites:
cript to download the last snapshot (tarball) from MMS Backup, for
the specified replica set.

Dependencies:

  - The goal here is to minimise dependencies as many production environments
    are locked down. Thus we avoid the need to install any other software or
    scripting languages or modules (e.g. Ruby, Python, Perl).

  - The only dependency is on https://github.com/dominictarr/JSON.sh, a
    fairly small Bash script to help parse the JSON returned from the MMS
    REST API.

See http://mms.mongodb.com/help-hosted/current/reference/api/ for details.

Version: 1.0.0
Author : James Tan <james.tan@mongodb.com>

    $ ./mms_backup.sh
    Usage: mms_backup.sh PARAMS [OPTIONS]

    Required parameters:
    --user MMS_USER          MMS username, usually an email
    --api-key API_KEY        MMS API key (eg. xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
    --server-url MMS_URL     MMS server URL (eg. http://mms-server:8080)
    --group-id GROUP_ID      MMS group ID   (eg. 54c64146ae9fbe3d7f32c726)
    --cluster-id CLUSTER_ID  MMS cluster ID (eg. 54c641560cf294969781b5c3)

    Options:
    --download-dir DIR       Download directory. Default: 'backups'
    --json-sh JSON_SH        Full path to json.sh (https://github.com/dominictarr/JSON.sh)
                            Default: './json.sh'

    Miscellaneous:
    --help                   Show this help message

