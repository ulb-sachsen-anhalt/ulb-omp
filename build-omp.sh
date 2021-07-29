#!/bin/bash

set -eu

# most vars in .env
source .env

# root data dir (mounted 500Gb volume /data)
data_dir=${PROJECT_DATA_ROOT}

echo "We are using omp  Version: ${OMP_VERSION_ULB} "

echo "OMP data are in $data_dir/*"

[ -d $data_dir ] && echo "Data Directory $data_dir exists!"


# please create mapped folders initially! 
# see mapped volumes in docker-compose-omp-ulb.yml
# ------------------------------------------------



echo propagate new version of \"omp.config.inc.php\"
cp -v ./omp.config.inc.php $data_dir/config/

echo propagate new version of \"manager.po\"
cp -v ./locale/*.po $data_dir/config/locale/de_DE/


echo try starting docker-compose with docker-compose-ulb.yml


docker-compose --file ./docker-compose-omp-ulb.yml --project-name prod down

docker-compose --file ./docker-compose-omp-ulb.yml --project-name prod up -d


