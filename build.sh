#!/bin/bash

set -eu 

if [ $# -eq 0 ]
  then
    echo "Please pass: 
            - root password for mysqldump, (e.g. *omp*)
            - password SMTP (e.g. *arbitrary*)
            - docker-compose project-name  (*dev* or *prod*) "
fi

DB_PASS=$1
SMTP_PASS=$2
TARGET=$3

# most vars in .env
source .env

if  [ -z "$3" ] || ([ $3 != "dev" ] && [ $3 != "prod" ])
    then
        echo "Third parameter 'dev' or 'prod' missing!"
        exit 0
elif [ $3 == "dev" ]
    then
        data_dir=${PROJECT_DATA_ROOT_DEV}
        echo "We are using omp  Version: ${OMP_VERSION_ULB_PROD}"
elif [ $3 == "prod" ]
    then
        data_dir=${PROJECT_DATA_ROOT_PROD}
        echo "We are using omp  Version: ${OMP_VERSION_ULB_DEV}"
fi

# root data dir (mounted 500Gb volume /data)
echo "OMP data are in $data_dir/*"

[ -d $data_dir ] && echo "Data Directory $data_dir exists!"


# please create mapped folders initially! 
# see mapped volumes in docker-compose-omp-ulb.yml
# ------------------------------------------------

# place omp.config.inc.php file
echo propagate new version of \"omp.config.inc.php\"
cp -v ./resources/omp.config.inc.php $data_dir/config/

if [ $3 == "prod" ]; then
    sed -i "s/mail_password/$SMTP_PASS/" $data_dir/config/omp.config.inc.php
fi

# place Apache configuration file for VirtualHost 
cp -v ./resources/omp$3.conf $data_dir/config/


# replace Host variable if in development build
if [ $3 == "dev" ]; then
    cp -v ./resources/ompdev.conf $data_dir/config/
    echo "reconfigure config file with sed: omp.config.inc.php"
    sed -i "s/ompprod_db_ulb/ompdev_db_ulb/" $data_dir/config/omp.config.inc.php
    echo "copy and reconfigure compose file with sed: docker-compose-ompdev.yml"
    cp -v ./docker-compose-ompprod.yml ./docker-compose-ompdev.yml
    echo "sed data in docker-compose-ompdev.yml for develop server"
    sed -i "s/ompprod/ompdev/g" ./docker-compose-ompdev.yml
    
    # do not expose any port
    sed -i "/ports:/d" ./docker-compose-ompdev.yml
    sed -i "/80:80/d" ./docker-compose-ompdev.yml
    sed -i "/443:443/d" ./docker-compose-ompdev.yml
    # sed -i "s/80:80/8080:80/" ./docker-compose-ompdev.yml
    # sed -i "s/443:443/8443:443/" ./docker-compose-ompdev.yml
    
    sed -i "s/OMP_VERSION_ULB_PROD/OMP_VERSION_ULB_DEV/" ./docker-compose-ompdev.yml
fi

echo propagate new version of \"manager.po\"
cp -v ./locale/*.po $data_dir/config/locale/de_DE/

compose_network=omp

docker network inspect $compose_network >/dev/null 2>&1 || \
    docker network create $compose_network


echo try starting docker-compose with docker-compose-omp$3.yml

./stop-omp $3
./start-omp $3


