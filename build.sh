#!/bin/bash

set -e

if [ $# -eq 0 ]
  then
    echo "Please pass: 
            - password SMTP (e.g. *arbitrary*)"
fi

SMTP_PASS=$1

# most vars in .env
source .env


PRODUCTION=${PROJECT_DATA_ROOT_PROD}
DEVELOP=${PROJECT_DATA_ROOT_DEV}

echo "OMP data are in $PRODUCTION and $DEVELOP"

[ -d "$PRODUCTION" ] && echo "Data Directory $PRODUCTION exists!"
[ -d "$DEVELOP" ] && echo "Data Directory $DEVELOP exists!"

# please create mapped folders initially! 
# see mapped volumes in docker-compose-ompprod.yml
# ------------------------------------------------

# copy omp.config.inc.php file
echo propagate new version of \"omp.config.inc.php\"
cp -v ./resources/omp.config.inc.php $PRODUCTION/config/
cp -v ./resources/omp.config.inc.php $DEVELOP/config/

# copy our custom settings in php.custom.ini (increase memory_limit)
cp -v ./resources/php.ulb.ini $PRODUCTION/config/
cp -v ./resources/php.ulb.ini $DEVELOP/config/

# copy favicon
cp -v ./resources/favicon.ico $PRODUCTION/config/favicon.ico
cp -v ./resources/favicon.ico $DEVELOP/config/favicon.ico

# copy ULB specific plugins 
cp -r ./plugins/* $PRODUCTION/plugins/
cp -r ./plugins/* $DEVELOP/plugins/

sed -i "s/mail_password/$SMTP_PASS/" $PRODUCTION/config/omp.config.inc.php

# copy Apache configuration file for VirtualHost prod, dev, local
cp -v ./resources/omp*.conf "$DEVELOP"/config/

# replace Host variable if in development build

echo "reconfigure config file with sed: omp.config.inc.php"
sed -i "s/ompprod_db_ulb/ompdev_db_ulb/" "$DEVELOP"/config/omp.config.inc.php
sed -i "s/force_ssl/;force_ssl/" "$DEVELOP"/config/omp.config.inc.php
sed -i "s/force_login_ssl/;force_login_ssl/" "$DEVELOP"/config/omp.config.inc.php
echo "copy and reconfigure compose file with sed: docker-compose-ompdev.yml"

cp -v ./docker-compose-ompprod.yml ./docker-compose-ompdev.yml
echo "sed data in docker-compose-ompdev.yml for develop server"
sed -i "s/ompprod/ompdev/g" ./docker-compose-ompdev.yml
sed -i "s/OMP_VERSION_ULB_PROD/OMP_VERSION_ULB_DEV/" ./docker-compose-ompdev.yml

# do not expose any port in dev (but in devlocal keep Port:80)
cp -v ./docker-compose-ompdev.yml ./docker-compose-omplocal.yml
sed -i "/443:443/d" ./docker-compose-ompdev.yml
sed -i "/ports:/d" ./docker-compose-ompdev.yml
sed -i "/80:80/d" ./docker-compose-ompdev.yml

# for local development we don't need ssl  
echo "sed data in docker-compose-omplocal.yml for local development"
sed -i "/443:443/d" ./docker-compose-omplocal.yml
sed -i "/ssl/d" ./docker-compose-omplocal.yml
sed -i "s/ompdev\.conf/omplocal\.conf/" ./docker-compose-omplocal.yml
sed -i "s/ompdev_app_ulb/omplocal_app_ulb/" ./docker-compose-omplocal.yml

sleep 1

echo propagate new version of \"manager.po\"
cp -v ./locale/de_DE/*.po "$DEVELOP"/config/locale/de_DE/
cp -v ./locale/de_DE/*.po "$PRODUCTION"/config/locale/de_DE/


# backup database

backup=$PRODUCTION/sqldumps/$(date +"%Y-%m-%d")_${OMP_VERSION_ULB_PROD}_omp
echo dump OMP database "$backup.sql"
docker exec ompprod_db_ulb mysqldump -p${MYSQL_ROOT_PASSWORD} omp > $backup && \
    echo "backup successfull: $(du -h $backup)" && mv $backup $backup.sql || \
    if [ -f "$backup" ]; then 
        rm "$backup"
        echo "backup failed, delete empty dump"
    fi

echo you can now start omp with
echo "./start-omp {prod|dev|local}" 

