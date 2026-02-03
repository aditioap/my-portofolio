#!/bin/sh

### System Setup ###
#BACKUPDIR=/backup/MySqlDump
BACKUPDIR=/mnt/data/manager01
SOURCEDIR=/data
LOG=/data/script/logs

### Binaries ###
TAR="$(which tar)"
GZIP="$(which gzip)"
SCP="$(which scp)"


### Today + hour in 24h format ###
#NOW=$(date +"%Y%m")
NOW=$(date +"%Y%m%d")


 ### Create dir for backup database ###
## [ -d $BACKUPDIR/Manager01_$NOW ] || mkdir -p $BACKUPDIR/Manager01_$NOW

### Compress directory hasil dump ###
ACHIEVE=$BACKUPDIR/Manager01_$NOW.tar.gz
#ACHIEVE=NDS_$NOWW.tar.gz
ACHIEVED=$SOURCEDIR

#cd $SOURCEDIR

$TAR -czvf $ACHIEVE $ACHIEVED

if [ -e $ACHIEVE ];then

        ##rm -rf $ACHIEVED
        echo "### Succes Backup Manager01 directory at $(date +"%Y-%m-%d %H:%M") ###" > $LOG/Backup-Manager01_$(date +"%Y-%m-%d").log

fi


### HK Directory, Logs & File tar.gz ###
find $BACKUPDIR -name "*.tar.gz" -type f -mtime +7 -exec rm -rf {} \;
find $LOG -name "*.log"  -type f -mtime +7 -exec rm -rf {} \;
