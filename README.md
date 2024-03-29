# OMP Server ULB



## Enviroment setup for OMP Docker [ULB](https://omp.bibliothek.uni-halle.de/)

In order to streamline the development for our OJS and OMP applications and to ease the deployment of ready-to-go code from our test environment onto our productive environment, we have decided to use Docker.
What follows is an outline of the steps necessary to run an OMP installation in a Docker container.
As far as we know, there is no Docker setup from PKP yet so we build our own Dockerfile, inspired on our existing OJS dockerisation. -> https://github.com/pkp/docker-ojs


Our data for (dev)Server and Database containers is located here:

```/data/ompdev```

## Setup enviroment

First we need to create all directories, 
referenced as volume form _docker-compose-ompdev.yml_
```bash
/data/ompdev/config
/data/ompdev/db
/data/ompdev/files
/data/ompdev/logs
/data/ompdev/plugins
/data/ompdev/private
/data/ompdev/public

```
(same for _docker-compose-ompprod.yml_)


_uid_ and _gid_ of directories should correspond within the container ids


e.g.: container omp_app_ulb
```bash
 $ id apache   
 uid=100(apache) gid=101(apache) groups=101(apache),82(www-data),101(apache)
```
container omp_dbdev_ulb:
```bash
 $ id mysql  
 uid=999(mysql) gid=999(mysql) groups=999(mysql)
```

So set appropriate on host machine:
```bash
sudo chown 100:101  /data/ompdev/ -R
sudo chown 999:999  /data/ompdev/logs/db -R 
sudo chown 999:999  /data/ompdev/db -R 
```

From your clone directory start ```./build.sh```

This will setup all data for you to start the docker container in _developent, production_ or _local_ mode.
(There is probably some extra work if you start from scratch.)

To start container use start and stop scripts:
```bash
./start-omp local
./stop-omp local
```

Please check _.env_ for further settings!

## GitLab CI/CD

If you are working with gitlab you can use the .```gitlab-ci.yml``` to fire up your gitlab-runner. 



## License

GPL3



