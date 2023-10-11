#!/bin/ksh

export ORACLE_SID=WDMP2011
export ORACLE_HOME=`cat /etc/oratab | grep -i \^$ORACLE_SID: | cut -f2 -d':'`
export PATH=${ORACLE_HOME}/bin:$PATH
export NLS_DATE_FORMAT="DD-MON-YYYY HH24:MI:SS"

YYYYMMDD=`date +%Y'%m'%d`
LOGTIME=$(TZ=CST6CDT;date +%Y-%m-%d-%H-%M-%S)
LOGFILE=/oracle/g01/bkup01/STANDBY_CREATION/restore_${ORACLE_SID}_$LOGTIME.log

echo "START RESTORE TIME: `date`" > $LOGFILE

rman target / nocatalog <<EOF >> $LOGFILE

run {
ALLOCATE CHANNEL dd1 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';
ALLOCATE CHANNEL dd2 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';
ALLOCATE CHANNEL dd3 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';
ALLOCATE CHANNEL dd4 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';
ALLOCATE CHANNEL dd5 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';
ALLOCATE CHANNEL dd6 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';
ALLOCATE CHANNEL dd7 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';
ALLOCATE CHANNEL dd8 TYPE 'SBT_TAPE' PARMS 'BLKSIZE=1048576,SBT_LIBRARY=/oracle/g01/software/datadomain/lib/libddobk.so,ENV=(STORAGE_UNIT=oracle1164_nob_rep, BACKUP_HOST=NBED0101.corp.sprint.
com, RMAN_AGENT_HOME=/oracle/g01/software/datadomain)';

set newname for database to '+DATA_01';
set until scn 15854699346000;

restore database;
switch datafile all;
switch tempfile all;

recover database;

release channel dd1;
release channel dd2;
release channel dd3;
release channel dd4;
release channel dd5;
release channel dd6;
release channel dd7;
release channel dd8;
}
EOF

echo "FINISHED RESTORE TIME: `date`" >> $LOGFILE

