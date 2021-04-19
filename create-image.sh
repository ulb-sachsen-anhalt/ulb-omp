#!/bin/bash

set -eu

docker build -t omp-ulb .

source .env

echo We are using omp  Version =>${OMP_VERSION} 
PHP_TAIL=/alpine/apache/php
OMP_GIT=https://github.com/pkp/omp.git


git clone ${OMP_GIT} || echo "'${OMP_GIT}' just here"


mkdir -pv /home/omp/volumes/config
# && chmod 777 /home/omp/volumes/config
cp ./omp.config.inc.php /home/omp/volumes/config/
mkdir -pv /home/omp/volumes/files
# && chmod 777 /home/omp/volumes/files
mkdir -pv /home/omp/volumes/private
mkdir -pv /home/omp/volumes/public
# && chmod 777 /home/omp/volumes/public

echo try start docker-compose with docker-compose-ulb.yml
#start omp

docker-compose --file ./docker-compose-omp-ulb.yml down

docker-compose --file ./docker-compose-omp-ulb.yml up -d
