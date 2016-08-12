#!/bin/sh
# vars ##############################
# FROM
# TO
# PWORDFROM
# PWORDTO
# DB
# OP [GETDUMP, TRANSFER(default)]
# DUMPUSER=$6 (only needed if GETDUMP -> <USERNAME_TO_LOGIN>)
# DUMPPATH=$6 (only needed if GETDUMP -> <PATH_TO_STORE>)
# script ############################

PWDTO=$PWORDFROM

if [ -z "$PWORDTO"]; then
PWDTO=$PWORDFROM
echo "[No PWDTO present. Assigning '$PWDTO']"
fi

echo "[Importing from $FROM to $TO with pwd: $PWORD, database: $DB, dumpUser: $DUMPUSER, dumpPath: $DUMPPATH]"

echo "[Dumping data from $FROM  ............................]"
sshpass -p $PWORDFROM ssh -o StrictHostKeyChecking=no root@$FROM << EOF
docker exec -d mongodb bash -c "rm -rf /data/db/$DB && mongodump -d $DB -o /data/db"
exit
EOF

echo "[Copying data from $FROM into temporal folder ............................]"
mkdir ~/tmpDump
sshpass -p $PWORDFROM scp root@$FROM:/var/lib/mongodb/$DB/* ~/tmpDump

echo "[Is this dump? => $OP]"

if [ "$OP" == "GETDUMP" ]; then
echo "[Removing old data from $TO ..........................]"
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no $DUMPUSER@$TO "rm -rf $DUMPPATH && mkdir $DUMPPATH"
echo "[Transferring dump to $DUMPPATH ............................]"
sshpass -p $PWDTO scp ~/tmpDump/* $DUMPUSER@$TO:$DUMPPATH
else
echo "[Removing old data from $TO ..........................]"
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no root@$TO "rm -rf /var/lib/mongodb/$DB && mkdir /var/lib/mongodb/$DB"
echo "[Transferring data to $TO ............................]"
sshpass -p $PWDTO scp ~/tmpDump/* root@$TO:/var/lib/mongodb/$DB
echo "[Restoring data in $TO ...............................]"
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no root@$TO << EOF
docker exec -d mongodb bash -c "mongorestore --db $DB /data/db/$DB"
exit
EOF
fi

echo "[Removing temporary data ...............................]"
rm -rf ~/tmpDump

echo "[Done!]" 