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
PATH_TO_STORE=$DUMPPATH

if [ -z "$PWORDTO"]; then
PWDTO=$PWORDFROM
echo "[No PWDTO present. Assigning '$PWDTO']"
fi

if [ -z "$DUMPPATH"]; then
PATH_TO_STORE="/var/lib/mongodb"
echo "[No DUMPPATH present. Assigning '/var/lib/mongodb']"
fi


echo "[Importing from $FROM to $TO with pwd_FROM: $PWORDFROM, pwd_TO: $PWORDTO, database: $DB, dumpUser: $DUMPUSER, dumpPath: $DUMPPATH]"

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
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no $DUMPUSER@$TO "rm -rf $PATH_TO_STORE/$DB && mkdir $PATH_TO_STORE/$DB"
echo "[Transferring dump to $PATH_TO_STORE ............................]"
sshpass -p $PWDTO scp ~/tmpDump/* $DUMPUSER@$TO:$PATH_TO_STORE/$DB
else
echo "[Removing old data from $TO ..........................]"
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no root@$TO "rm -rf $PATH_TO_STORE/$DB && mkdir $PATH_TO_STORE/$DB"
echo "[Transferring data to $TO ............................]"
sshpass -p $PWDTO scp ~/tmpDump/* root@$TO:$PATH_TO_STORE/$DB
echo "[Restoring data in $TO ...............................]"
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no root@$TO << EOF
docker exec -d mongodb bash -c "mongorestore --db $DB /data/db/$DB"
exit
EOF
fi

echo "[Removing temporary data ...............................]"
rm -rf ~/tmpDump

echo "[Done!]" 