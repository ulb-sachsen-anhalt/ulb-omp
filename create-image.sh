#!/bin/bash

set -eu

#DB_NAME=$1
#DB_USER=$2
#DB_PASS=$3

#echo start with DB: $DB_NAME, $DB_USER, DB_PASS

docker build -t omp-ulb .



source .env

echo We are using omp  Version =>${OMP_VERSION} 
PHP_TAIL=/alpine/apache/php
OMP_GIT=https://github.com/pkp/docker-omp.git


git clone ${OMP_GIT} || echo "'${OMP_GIT}' just here"


mkdir -pv /home/omp/volumes/config && cp ./omp.config.inc.php /home/omp/volumes/config/
mkdir -pv /home/omp/volumes/files && chmod 777 /home/omp/volumes/files
mkdir -pv /home/omp/volumes/private
mkdir -pv /home/omp/volumes/public && chmod 777 /home/omp/volumes/public

#OMP_HOME=$(find ./docker-omp -type d -name ${OMP_VERSION})
#OMP_HOME=$OMP_HOME$PHP_TAIL
#if [ -z "$OMP_HOME$" ] ; then echo "**OMP Version $VERSION not found!**";
#    else echo "Version '$OMP_VERSION' found --> $OMP_HOME"; fi

#echo copy $OMP_HOME/Dockerfile .
#cp $OMP_HOME/Dockerfile .

#echo copy $omp_HOME/exclude.list .
#cp $OMP_HOME/exclude.list .


echo try start docker-compose with docker-compose-ulb.yml
#start omp

docker-compose --file ./docker-compose-omp-ulb.yml down

docker-compose --file ./docker-compose-omp-ulb.yml up -d
