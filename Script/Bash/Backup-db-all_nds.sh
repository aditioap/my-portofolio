[root@NDSDBSLAVE144 scripts]# cat backup-db.sh
#!/bin/sh

### System Setup ###
#BACKUPDIR=/backup/MySqlDump
BACKUPDIR=/data/MySqlDump
LOG=/backup/MySqlDump/log

### Nama Database ###
#DATABASE="webbrinetssupport"

### MySQL Setup ###
MUSER="ops"
MHOST="localhost"

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"

### Today + hour in 24h format ###
NOW=$(date +"%Y%m")
NOWW=$(date +"%Y%m%d")

### File List Sql ###
FILEQUE=/root/scripts/list-db_by-size.sql
FILEDB=/root/scripts/list-db_by_size.txt

### List Database Sort by Size ###
DBLIST=`$MYSQL -u $MUSER -h $MHOST -P3306 -s < $FILEQUE |awk '{print$1}'`
#echo $DBLIST > $FILEDB

 ### Create dir for backup database ###
 [ -d $BACKUPDIR/NDS_$NOW ] || mkdir -p $BACKUPDIR/NDS_$NOW

for db in $DBLIST
do
       FILE=$BACKUPDIR/NDS_$NOW/${db}.sql.gz
       echo "### Processing Dump from database $db $(date +"%Y-%m-%d %H:%M") ###" >> $LOG/DumpDB_$db_$(date +"%Y-%m-%d").log
       $MYSQLDUMP -u $MUSER -h $MHOST -P3306 --set-gtid-purged=off --single-transaction --quick --skip-lock-tables --max_allowed_packet=1024M ${db} | $GZIP  > $BACKUPDIR/NDS_$NOW/${db}_$NOW.sql.gz
       echo "### Succes Dump database $db $(date +"%Y-%m-%d %H:%M") ###" >> $LOG/DumpDB_$db_$(date +"%Y-%m-%d").log

done


### Compress directory hasil dump ###
ACHIEVE=NDS_$NOW.tar.gz
#ACHIEVE=NDS_$NOWW.tar.gz
ACHIEVED=NDS_$NOW

cd $BACKUPDIR

$TAR -czvf $ACHIEVE $ACHIEVED

if [ -e $ACHIEVE ];then

        rm -rf $ACHIEVED
        echo "### Succes Compress database NDS $(date +"%Y-%m-%d %H:%M") ###" >> $LOG/DumpDB_$db_$(date +"%Y-%m-%d").log

fi


### HK Directory, Logs & File tar.gz ###
#find $BACKUPDIR -name "*.tar.gz" -type f -mtime +7 -exec rm -rf {} \;
#find $LOG -name "*.log"  -type f -mtime +7 -exec rm -rf {} \;
