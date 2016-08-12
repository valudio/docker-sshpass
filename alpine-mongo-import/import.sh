#!/bin/sh
# vars ##############################
# FROM=$1
# TO=$2
# PWORD=$3
# PATHDATA=$4
# DB=$5
# script ############################
echo "Importing from $FROM to $TO with pwd: $PWORD to path $PATHDATA and database $DB"
echo "Import data from $FROM to $TO"
echo "Dumping data from $FROM"
sshpass -p $PWORD ssh -o StrictHostKeyChecking=no root@$FROM << EOF
docker exec -d mongodb bash -c "rm -rf /data/db/$DB && mongodump -d $DB -o /data/db"
exit
EOF
echo "Copying data from $FROM into local"
mkdir ~/tmpDump
sshpass -p $PWORD scp root@$FROM:$PATHDATA/$DB/* ~/tmpDump
echo "Transferring data to $TO"
# removing old data
sshpass -p $PWORD ssh -o StrictHostKeyChecking=no root@$TO "rm -rf $PATHDATA/$DB && mkdir $PATHDATA/$DB"
sshpass -p $PWORD scp ~/tmpDump/* root@$TO:$PATHDATA/$DB
echo "Removing temporary data from local"
rm -rf ~/tmpDump
echo "Restoring data in $TO"
sshpass -p $PWORD ssh -o StrictHostKeyChecking=no root@$TO << EOF
docker exec -d mongodb bash -c "mongorestore --db $DB /data/db/$DB"
exit
EOF
echo "Done!"