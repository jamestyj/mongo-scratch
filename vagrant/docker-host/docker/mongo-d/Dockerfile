# mongod process on latest CentOS
# See https://docs.docker.com/articles/dockerfile_best-practices/

FROM       centos
MAINTAINER James Tan <james.tan@mongodb.com>

COPY       common/mongodb.repo /etc/yum.repos.d/
RUN        yum install -y mongodb-org-server

# UID and GID of mongod must match host for our logging setup
RUN        groupmod mongod -g 2000
RUN        usermod  mongod -u 2000

USER       mongod
ENTRYPOINT [ "mongod" ]
