https://github.com/pkp/docker-ojs

Diese Rechte entsprechen den uid/gid im entspr. container.
Da diese Ordner von den Containern eingebunden werden, sollten diese Rechte gesetzt werden.

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


sudo chown 100:100  /data/omp/ -R
sudo chown 999:999  /data/omp/logs/db -R 
sudo chown 999:999  /data/db -R 