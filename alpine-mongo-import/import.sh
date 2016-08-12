#!/bin/sh
# vars ##############################
# FROM=$1
# TO=$2
# PWD=$3
# DATA=$4
# DB=$5
# script ############################
echo "Import data from $FROM to $TO"
echo "Dumping data from $FROM"
sshpass -p $PWD ssh -o StrictHostKeyChecking=no root@$FROM << EOF
docker exec -d mongodb bash -c "rm -rf /data/db/$DB && mongodump -d $DB -o /data/db"
exit
EOF
echo "Copying data from $FROM into local"
mkdir ~/tmpDump
sshpass -p $PWD scp root@$FROM:$DATA/$DB/* ~/tmpDump
echo "Transferring data to $TO"
# removing old data
sshpass -p $PWD ssh -o StrictHostKeyChecking=no root@$TO "rm -rf $DATA/$DB && mkdir $DATA/$DB"
sshpass -p $PWD scp ~/tmpDump/* root@$TO:$DATA/$DB
echo "Removing temporary data from local"
rm -rf ~/tmpDump
echo "Restoring data in $TO"
sshpass -p $PWD ssh -o StrictHostKeyChecking=no root@$TO << EOF
docker exec -d mongodb bash -c "mongorestore --db $DB $DATA/$DB"
exit
EOF
echo "Done!"