#!/bin/sh
# vars ##############################
# FROM
# TO
# PWORDFROM
# PWORDTO
# DB
# CONTAINERFROM (mongodb by default)
# CONTAINERTO (mongodb by default)
# OP [GETDUMP,  TRANSFER(default)]
# USERFROM (root by default)
# USERTO (root by default)
# PATHFROM (/var/lib/mongodb by default)
# PATHTO (/var/lib/mongodb by default)
# script ############################

PWDTO=$PWORDFROM
PFROM=$PATHFROM
PTO=$PATHTO
CTNFROM=$CONTAINERFROM
CTNTO=$CONTAINERTO
UFROM=$USERFROM
UTO=$USERTO
OPERATION=$OP

if [ -z "$OP"]; then
OPERATION="TRANSFER"
echo "[No OP present. Assigning 'TRANSFER']"
fi

if [ -z "$PWORDTO"]; then
PWDTO=$PWORDFROM
echo "[No PWDTO present. Assigning '$PWDTO']"
fi

if [ -z "$PATHFROM"]; then
PFROM="/var/lib/mongodb"
echo "[No PATHFROM present. Assigning '/var/lib/mongodb']"
fi

if [ -z "$PATHTO"]; then
PTO="/var/lib/mongodb"
echo "[No PATHTO present. Assigning '/var/lib/mongodb']"
fi

if [ -z "$USERFROM"]; then
UFROM="root"
echo "[No USERFROM present. Assigning 'root']"
fi

if [ -z "$USERTO"]; then
UTO="root"
echo "[No USERTO present. Assigning 'root']"
fi

if [ -z "$CONTAINERFROM"]; then
CTNFROM="mongodb"
echo "[No CONTAINERFROM present. Assigning 'mongodb']"
fi

if [ -z "$CONTAINERTO"]; then
CTNTO="mongodb"
echo "[No CONTAINERTO present. Assigning 'mongodb']"
fi


echo "[Importing from $FROM to $TO with pwd_FROM: $PWORDFROM, pwd_TO: $PWORDTO, database: $DB, user_FROM: $UFROM, user_TO: $UTO,  path_FROM: $PFROM, path_TO: $PTO]"

echo "[Dumping data from $FROM  ............................]"
sshpass -p $PWORDFROM ssh -o StrictHostKeyChecking=no $UFROM@$FROM << EOF
docker exec -d $CTNFROM bash -c "rm -rf /data/db/$DB && mongodump -d $DB -o /data/db"
exit
EOF

echo "[Copying data from $FROM into temporal folder ............................]"
mkdir ~/tmpDump
sshpass -p $PWORDFROM scp $UFROM@$FROM:$PFROM/$DB/* ~/tmpDump

echo "[Removing old data from $TO ..........................]"
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no $UTO@$TO "rm -rf $PTO/$DB && mkdir $PTO/$DB"
echo "[Transferring data to $TO ............................]"
sshpass -p $PWDTO scp ~/tmpDump/* $UTO@$TO:$PTO/$DB

echo "[Is this dump? => $OPERATION]"

if [ "$OPERATION" == "TRANSFER" ]; then
echo "[Restoring data in $TO ...............................]"
sshpass -p $PWDTO ssh -o StrictHostKeyChecking=no $UTO@$TO << EOF
docker exec -d $CTNTO bash -c "mongorestore --db $DB /data/db/$DB"
exit
EOF
fi

echo "[Removing temporary data ...............................]"
rm -rf ~/tmpDump

echo "[Done!]" 