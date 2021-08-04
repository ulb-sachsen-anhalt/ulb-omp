#!/bin/bash

# most vars in .env
source .env

if  [ -z "$1" ] || ([ $1 != "dev" ] && [ $1 != "prod" ])
    then
        echo "Parameter 'dev' oder 'prod' fehlt"
        exit 0
elif [ $1 == "dev" ]
    then
        data_dir=${PROJECT_DATA_ROOT_DEV}
        echo "We are using omp  Version: ${OMP_VERSION_ULB_PROD}"
elif [ $1 == "prod" ]
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
cp -v ./omp.config.inc.php $data_dir/config/
cp -v ./resources/omp.config.inc.php $data_dir/config/
cp -v ./resources/omp$1.conf $data_dir/config/

# replace Host variable if in development build
if [ $1 == "dev" ]; then
    # cp -v ./resources/ompdev.conf $data_dir/config/
    echo "reconfigure compose file: docker-compose-ompdev-ulb.yml"
    sed -i "s/ompprod_db_ulb/ompdev_db_ulb/" $data_dir/config/omp.config.inc.php
    cp -v ./docker-compose-ompprod-ulb.yml ./docker-compose-ompdev-ulb.yml
    echo "sed data in docker-compose-ompdev-ulb.yml for develop server"
    sed -i "s/ompprod/ompdev/g" ./docker-compose-ompdev-ulb.yml
    sed -i "s/80:80/8080:80/" ./docker-compose-ompdev-ulb.yml
    sed -i "s/443:443/8443:443/" ./docker-compose-ompdev-ulb.yml
    sed -i "s/OMP_VERSION_ULB_PROD/OMP_VERSION_ULB_DEV/" ./docker-compose-ompdev-ulb.yml
fi

echo propagate new version of \"manager.po\"
cp -v ./locale/*.po $data_dir/config/locale/de_DE/

echo try starting docker-compose with docker-compose-omp$1-ulb.yml

./stop-omp $1
./start-omp $1


