#!/bin/bash

set -eu

IMAGE=testimage
DOCKER_CONF=Dockerfile

docker build --no-cache \
    --tag "${IMAGE}" \
    -f ${DOCKER_CONF} .


docker container stop containertest
docker run -dit --rm --name containertest -p 8080:80 ${IMAGE}
