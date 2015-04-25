#!/bin/bash
#
# Helper script to install common MongoDB POC tools in Amazon Linux (AWS EC2).
# Requires sudo rights.
#
# Run:
#
#   curl -sSL http://goo.gl/wN2XZ4 | bash | tee install.log
#

echo "** Installing MongoDB shell and tools..."
echo "[mongodb-org-3.0]
name=MongoDB Repository
baseurl=http://repo.mongodb.org/yum/amazon/2013.03/mongodb-org/3.0/x86_64/
gpgcheck=0
enabled=1" | sudo tee /etc/yum.repos.d/mongodb-org-3.0.repo > /dev/null
sudo yum install -y mongodb-org
sudo chkconfig mongod off
sudo mkdir -p /data/db
sudo chown $USER /data/db

echo
echo "** Installing utils..."
sudo yum install -y git htop tmux mosh sysstat

echo
echo "** Installing Mongo Hacker..."
cd ~
git clone https://github.com/TylerBrock/mongo-hacker.git
cd mongo-hacker
make install

echo
echo "** Installing Maven..."
echo "[epel-apache-maven]
name=Maven from Apache Foundation.
baseurl=https://repos.fedorapeople.org/repos/dchen/apache-maven/epel-6Server/\$basearch/
enabled=1
skip_if_unavailable=1
gpgcheck=0" | sudo tee /etc/yum.repos.d/epel-apache-maven.repo > /dev/null
sudo yum install -y apache-maven

echo
echo "** Installing POCDriver..."
cd ~
git clone https://github.com/johnlpage/POCDriver.git
cd POCDriver
mvn clean package

echo
echo "** Installing mtools..."
sudo yum install -y python-pip python-devel gcc
sudo pip install mtools pymongo==2.8
