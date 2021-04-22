#!/bin/bash

set -eu

source .env

echo We are using omp  Version ${OMP_VERSION} 
PHP_TAIL=/alpine/apache/php
OMP_GIT=https://github.com/pkp/omp.git

git clone ${OMP_GIT} || echo "'${OMP_GIT}' just here"
git --git-dir=omp/.git submodule update --init --recursive

# build image if not here
docker build -t omp-ulb .

# please create mapped folders initially! 
# see mapped volumes in docker-compose-omp-ulb.yml
# ------------------------------------------------
# --> /home/omp/volumes/config
cp ./omp.config.inc.php /home/omp/volumes/config/
# --> /home/omp/volumes/files
# --> /home/omp/volumes/private
# --> /home/omp/volumes/public

echo try start docker-compose with docker-compose-ulb.yml
#start omp

docker-compose --file ./docker-compose-omp-ulb.yml down

docker-compose --file ./docker-compose-omp-ulb.yml up -d

# copy uni favicon
docker cp favicon.ico omp_app_ulb:/var/www/html/favicon.ico

