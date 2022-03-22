# OMP Server ULB

[![pipeline status](https://git.itz.uni-halle.de/ulb/ulb-ojs/badges/master/pipeline.svg)](https://git.itz.uni-halle.de/ulb/ulb-ojs/badges/master/pipeline.svg)



## Enviroment setup for OMP Docker [ULB](https://omp.bibliothek.uni-halle.de/)

There is no docker setup from PKP yet.
So we build our own Dockerfile, inspired be OJS-Docker. -> https://github.com/pkp/docker-ojs


Our data for (dev)Server and Database containers is located here:

```/data/ompdev```

## Setup enviroment

First we need to create all directories, 
referenced as volume form _docker-compose-ompdev.yml_
```
/data/ompdev/config
/data/ompdev/db
/data/ompdev/files
/data/ompdev/logs
/data/ompdev/plugins
/data/ompdev/private
/data/ompdev/public

```
(same for _docker-compose-ompprod.yml_)


_uid_ and _gid_ of directories should correspondent within the container ids


e.g.: container omp_app_ulb
<pre>
 >id apache   
 >uid=100(apache) gid=101(apache) groups=101(apache),82(www-data),101(apache)
</pre>
container omp_dbdev_ulb:
<pre>
 >id mysql  
 >uid=999(mysql) gid=999(mysql) groups=999(mysql)
</pre>

So set appropriate on host machine:
<pre>
sudo chown 100:100  /data/ompdev/ -R
sudo chown 999:999  /data/ompdev/logs/db -R 
sudo chown 999:999  /data/ompdev/db -R 
</pre>

From your clone directory start ```./build.sh```

This will setup all data for you to start docker container in _developent, production_ or _local_ mode.
(There ist some work if you start form scratch for sure.)

To start container use start and stop scripts:
```
./start-omp local
./stop-omp local
```

Please check _.env_ for further settings!




