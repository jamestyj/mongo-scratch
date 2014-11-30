vagrant up
vagrant ssh

docker ps
docker ps -a
docker images

docker rm CONTAINER
docker rmi IMAGE

clean-containers
clean-images

cd docker
# First builds are slow as it has to download and install the dependencies
# (e.g. base CentOS 7 image, mongod, mongo-shell).
# Subsequent are fast since these are automatically cached by Docker.
./build mongo-d

docker run -it --rm mongo-shell

docker exec -it mongod-s1-a bash

- To detach yourself from the container, use the escape sequence CTRL+P followed by CTRL+Q.

TODO
- NUMA
- ulimits
- Auto-retry process
- Sharding
  - config server
  - mongos
- Resource limits
  - Memory limits
  - --cpuset (pin to core)
    https://goldmann.pl/blog/2014/09/11/resource-management-in-docker/
