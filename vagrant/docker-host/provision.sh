#!/usr/bin/env bash

# Fail-fast: Exit immediately on non-zero exit code
set -e

function log() {
    local msg=$1
    local opts=$2
    local time=`date +%H:%M:%S`
    echo $opts "$time $msg"
}

function setup_tweaks() {
    log "** setup_tweaks()"

    log "** Reducing TCP keepalive from 2 hours to 5 mins..."
    # http://docs.mongodb.org/manual/faq/diagnostics/#does-tcp-keepalive-time-affect-sharded-clusters-and-replica-sets
    echo 300 > /proc/sys/net/ipv4/tcp_keepalive_time
    echo "net.ipv4.tcp_keepalive_time = 300" >> /etc/sysctl.conf

    log "** Disabling Transparent Huge Pages (THP)..."
    # http://docs.mongodb.org/manual/administration/production-notes/#recommended-configuration
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local

    log "** Installing ntp"
    yum install -q -y ntp
    log "** Starting ntp"
    service ntpd start
    chkconfig ntpd on

    # Needed for rs.initiate() to work
    echo "127.0.0.1 docker-host" > /etc/hosts
}

function setup_disk() {
    log "** setup_disk()"
    local MOUNT_DIR=/data
    local DEV=/dev/sdb

    log "** Formatting $DEV as XFS..."
    mkfs.xfs -q -L MongoDBVol $DEV

    log "** Mounting $DEV to $MOUNT_DIR..."
    mkdir -p $MOUNT_DIR
    # http://xfs.org/index.php/XFS_FAQ#Q:_Is_using_noatime_or.2Fand_nodiratime_at_mount_time_giving_any_performance_benefits_in_xfs_.28or_not_using_them_performance_decrease.29.3F
    echo "$DEV $MOUNT_DIR xfs defaults 0 2" >> /etc/fstab
    mount $MOUNT_DIR

    log "** Reducing default readahead size from 256 to 32 blocks (16KB)..."
    # http://unix.stackexchange.com/questions/71364/persistent-blockdev-setra-read-ahead-setting
    cp /vagrant/conf/85-mongodb.rules /etc/udev/rules.d/
    # Simulate re-add of /dev/sdb so that our udev rules are applied immediately
    udevadm test --action=add /sys/block/sdb >/dev/null 2>&1

    mkdir -p /data/mongod/s1-{a,b,c}
    chown mongod: /data/mongod/*
}

# The standard CentOS 7 repo includes an older version of docker and there
# doesn't appear to be any official repos with the latest stable release, so we
# install the binary manually with the steps from https://docs.docker.com/installation/binaries/.
function install_docker() {
    log "** install_docker()"

    log "** Installing git (docker dependency)..."
    yum install -y -q git

    log "** Installing latest Docker binary..."
    wget -qO- https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz | tar xvz --strip-components=3 -C /usr/bin

    log "** Configuring Docker..."
    groupadd docker
    usermod vagrant -G docker
    local BASE_URL=https://raw.githubusercontent.com/docker/docker/master/contrib

    log "** Installing Docker systemd scripts..."
    wget -q $BASE_URL/init/systemd/docker.{service,socket} -P /usr/lib/systemd/system/
    log "** Installing Docker vim config..."
    wget -q $BASE_URL/syntax/vim/syntax/dockerfile.vim     -P /usr/share/vim/vimfiles/syntax
    wget -q $BASE_URL/syntax/vim/ftdetect/dockerfile.vim   -P /usr/share/vim/vimfiles/ftdetect

    log "** Starting Docker daemon..."
    service docker start

    # Workaround the fact that for some reason the socket file has group 'root'
    # instead of 'docker' as specified in docker.socket.
    chown root:docker /var/run/docker.sock

    log "** Running 'docker version'..."
    docker version
}

function install_tools() {
    yum install -y -q vim tmux
    cp /vagrant/conf/vimrc /home/vagrant/.vimrc
    chown vagrant: /home/vagrant/.vimrc

    cp /vagrant/docker/mongo-common/mongodb.repo /etc/yum.repos.d/
    yum install -y -q mongodb-org-shell mongodb-org-tools

    cp /vagrant/docker/mongo-shell/conf/mongo-hacker.js /home/vagrant/.mongorc.js
    chown vagrant:                                      /home/vagrant/.mongorc.js

    ln -s /vagrant/docker /home/vagrant/
}

# Create mongod user with specific UID and GID for host-container mounts.
function setup_users() {
    groupadd mongod -g 2000
    useradd  mongod -g 2000 -u 2000
}

function setup_logging() {
    mkdir -p      /var/log/mongodb
    chown mongod: /var/log/mongodb
    cp /vagrant/conf/logrotate /etc/logrotate.d/mongodb
}

setup_users
setup_tweaks
setup_disk
install_docker
install_tools
setup_logging
