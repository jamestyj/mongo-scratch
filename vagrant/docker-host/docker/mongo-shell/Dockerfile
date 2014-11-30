# mongo-shell process on latest CentOS
# See https://docs.docker.com/articles/dockerfile_best-practices/

FROM       centos
MAINTAINER James Tan <james.tan@mongodb.com>

COPY       common/mongodb.repo /etc/yum.repos.d/
RUN        yum install -y mongodb-org-shell
RUN        useradd mongo

COPY       conf/mongo-hacker.js /home/mongo/.mongorc.js
RUN        chown mongo:         /home/mongo/.mongorc.js

USER       mongo
ENTRYPOINT /usr/bin/mongo --host $MONGOD_PORT_27017_TCP_ADDR
