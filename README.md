# OMP Server ULB

[![pipeline status](https://git.itz.uni-halle.de/ulb/ulb-omp/badges/master/pipeline.svg)](https://git.itz.uni-halle.de/ulb/ulb-omp/badges/master/pipeline.svg)

https://github.com/pkp/docker-ojs

OMP Daten in

/data/omp

Die Besitzer hier entsprechen den uid/gid im entspr. Container.
Da diese Ordner/Unterordner von den Containern eingebunden werden, sollten diese Rechte analog gesetzt werden:

Im container omp_app_ulb
<pre>
 >id apache   
 >uid=100(apache) gid=101(apache) groups=101(apache),82(www-data),101(apache)
</pre>
Im container omp_db_ulb
<pre>
 >id mysql  
 >uid=999(mysql) gid=999(mysql) groups=999(mysql)
</pre>


<pre>
sudo chown 100:100  /data/omp/ -R
sudo chown 999:999  /data/omp/logs/db -R 
sudo chown 999:999  /data/omp/db -R 
</pre>
