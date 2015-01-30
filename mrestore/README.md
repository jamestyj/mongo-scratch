# mrestore

Bash script that uses the MongoDB Management Service (MMS) REST API to trigger
a restore of the latest snapshot and downloads the resulting tarballs. Supports
MMS Cloud and On-Prem/OpsManager.

It is intended to have as few dependencies as possible and thus should work on
most Linux and Mac OS environments without the need to install any additional
software.

For details on the MMS API, see
http://mms.mongodb.com/help-hosted/current/reference/api/.

### Prerequisites

In the MMS web UI:

#. Enable Public API for the MMS group to restore from.
#. Generate an API key.
#. Whitelist the IP address from which `mrestore` is run.
#. Go to the URL of the replica set or cluster that you want to restore, which
   should be in the following form:
   `https://mms.mongodb.com/host/detail/XXXXXXX/YYYYYYY`.
   - The group ID is `XXXXXXX`.
   - The cluster ID is `YYYYYYY`.

### Usage

    $ ./mrestore.sh
    Usage: mrestore.sh PARAMS [OPTIONS]

    Required parameters:
      --server-url MMS_URL     MMS server URL (eg. https://mms.mongodb.com)
      --user MMS_USER          MMS username, usually an email
      --api-key API_KEY        MMS API key (eg. xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
      --group-id GROUP_ID      MMS group ID   (eg. 54c64146ae9fbe3d7f32c726)
      --cluster-id CLUSTER_ID  MMS cluster ID (eg. 54c641560cf294969781b5c3)

    Options:
      --download-dir DIR       Download directory. Default: '.'

    Miscellaneous:
      --help                   Show this help message

### Sample output

    $ ./mrestore.sh --server-url https://mms.mongodb.com \
                    --user admin@localhost.com \
                    --api-key 9d2fb094-108a-4c63-9ce6-5f79bbd8bd50 \
                    --group-id 54c64146ae9fbe3d7f32c726 \
                    --cluster-id 54c641560cf294969781b5c3

    Latest snapshot ID: 54cb3dd80cf27f7a35d2e5f6
    Created on        : 2015-01-30T04:20:22Z
    Complete?         : true
    Type name         : REPLICA_SET
    Replica set name  : demo1
    MongoDB version   : 2.6.5
    Data size         : 35.7 MB
    Storage size      : 4.45 GB
    File size         : 7.49 GB (uncompressed)

    Snapshot restore job ID: 54cb531a0cf2c15ade729798
    Waiting for restore job....
    Job status: FINISHED

    Downloading restore tarball(s) to ./...
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                    Dload  Upload   Total   Spent    Left  Speed
    100 21.2M    0 21.2M    0     0   620k      0 --:--:--  0:00:35 --:--:--  565k

    Wrote to './54c64146ae9fbe3d7f32c726-mms-app-1422591622.tar.gz' (21.2 MB)
