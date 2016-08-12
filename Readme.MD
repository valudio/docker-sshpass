# valudio/sshpass

These images are used for deployment and utility purposes by [Valudio](http://valudio.com).

*node-alpine*: It has latest nodejs, sshpass and openssh installed.
*alpine*: It has sshpass and openssh installed. No nodejs.
*alpine-mongo-import*: It has sshpass and openssh installed and it's used to import data between mongo databases using **mongodump** and **mongorestore**.

## alpine-mongo-import

In order to import data from one database to another you must execute this:
``` sh
# if you run this using docker for Windows you will have to escape your PATHDATA variable.
docker run -it --rm -e FROM=hostname -e TO=hostname -e PWORD="`your_password`" -e PATHDATA="\/var\/lib\/mongodb" -e DB=`database_name` valudio/docker-sshpass:mongo-import
``` 