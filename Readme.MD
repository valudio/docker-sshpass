# valudio/sshpass

These images are used for deployment and utility purposes by [Valudio](http://valudio.com).

*node-alpine*: It has latest nodejs, sshpass and openssh installed.
*alpine*: It has sshpass and openssh installed. No nodejs.
*alpine-mongo-import*: It has sshpass and openssh installed and it's used to import data between mongo databases using **mongodump** and **mongorestore**.

## alpine-mongo-import

In order to import data from one database to another you must execute this:
``` sh
docker run -it --rm \ -e FROM=hostname -e TO=hostname -e PWORDFROM="`your_password`" -e PWORDTO="`your_password`" -e DB=`database_name` valudio/docker-sshpass:mongo-import
#Note: PWORDTO is optional if both servers have the same password
``` 

If you want to simply export the dump to a specific path then use this:
``` sh
docker run -it --rm \ -e FROM=hostname -e TO=hostname -e PWORDFROM="`your_password`" -e PWORDTO="`your_password`" -e DB=`database_name` -e OP="GETDUMP" -e DUMPUSER="`your_user`" -e DUMPPATH="`path_to_deliver_the_dump`"  valudio/docker-sshpass:mongo-import
#Note: PWORDTO is optional if both servers have the same password.
#Note2: If you run this using docker for Windows you will have to escape your DUMPPATH variable using "\/" instead of "/".
``` 