Unix

uuencode mailtest.txt mailtest.txt| mailx -s "Test EBS" alexander.bufalo@byseven.com.br

uuencode reorg_ECP.html reorg_ECP.html| mailx -s "ECP" alexdb@br.ibm.com

uuencode clcsadm.sql clcsadm.sql| mail -s "WDM CLCS MERGE " alexander.bufalol@sprint.com

uuencode awrrpt_2_106310_106315.zip awrrpt_2_106310_106315.zip | mailx -s "SVIP - AWR2" alexander.bufalol@sprint.com

uuencode mmpp101.zip mmpp101.zip| mail -s "MMPP sql" alexander.bufalol@sprint.com

#debug oraenv

sh -x /usr/local/bin/oraenv


#Statspack Report
@?/rdbms/admin/spreport

# single
@$ORACLE_HOME/rdbms/admin/awrrpt.sql
@?/rdbms/admin/awrrpti.sql

#rac
@?/rdbms/admin/awrgrpt.sql
@?/rdbms/admin/awrgrpti.sql
23128
23120

#compare
@$ORACLE_HOME/rdbms/admin/awrddrpt.sql
@$ORACLE_HOME/rdbms/admin/awrgdrpt.sql


#ADDM.
@$ORACLE_HOME/rdbms/admin/addmrpt.sql
@$ORACLE_HOME/rdbms/admin/addmrpti.sql

#ASH
@$ORACLE_HOME/rdbms/admin/ashrpt.sql
@$ORACLE_HOME/rdbms/admin/ashrpti.sql


find . -name "*.par" -exec grep exclude {} \;

find /oracle/g01/bkup01/WDMP101/backup/archive/* -mtme +3 -exec rm -f  "{}" \;

ls -l {} \;

rm -f {} \;


#find the largest files in the dir.

du -ah . 2>/dev/null | sort -n -r | head -n 20


find /oracle/g01/admin/diag/rdbms/wdmp101/WDMP1011/trace/*.trc -type f -mtime +2 -exec ls -ltrh "{}" \;

find /ggsCUST/repl3 -type f \( ! -name "*.*" \) -mtime +3 -exec mv "{}"  /oracle/g01/stage02/repl3_trails \;


find /ggsCUST/repl3 -type f -mtime +1 -exec mv "{}" /oracle/g01/bkup01/trail_bkp \;

find /ggsCUST/Trail7 -type f \( ! -name "*.*" \) -mtime +5 -exec ls -l "{}" \;

find /ggsCUST/Trail7 -type f \( ! -name "*.*" \) -mtime +5 -exec rm -f "{}" \;

find /oracle/g01/bkup01/trail_bkp -type f -mtime +7 -exec  ls -ltr "{}" \;

find /oracle/g01/bkup01/AUD_BACKUP/ -type f -exec  rm -rf "{}" \;

find /oracle/g01/admin/SVIP1011/adump/ -type f  \( ! -name "alert.*" \) -mtime +7 -exec  mv "{}" /oracle/g01/bkup01/AUD_BKP \;

find /oracle/g01/admin/diag/asm/+asm/+ASM3/trace -type f  \( ! -name "alert.*" \) -mtime +7 -exec  rm -f "{}"  \;

find /u01/app/grid/diag/crs/prdway4rac1c/crs/trace -type f  \( ! -name "alert.*" \) -mtime +90 -exec  rm -rf "{}"  \;

find /oracle/g01/bkup01/AUD_BACKUP/*.aud -type f  -exec  rm  -f "{}"  \;


find /oracle/g01/bkup01/trail_bkp -type f -mtime +60 -exec rm -f  "{}" \;

find /oracle/g01/admin/diag/rdbms/cxpp101/CXPP1011/trace/* -type f -size +1000K -exec gzip "{}"  \;



find /goldengate/ggsoracle/*/ora112/dirdef/NXTCU01_dbschema_GBL_1730.def -type f  -exec ls -l "{}" \;

# find table in goldengate def

find /goldengate/ggsoracle/*/ora112/dirdef/*.def -type f -exec grep -l "PI_DATA"  "{}" \;

# find goldengate prm per table

find /goldengate/ggsoracle/*/ora112/dirprm/*.prm -type f -exec egrep -l 'MAP NXTAPPONRT.MAC_SCHEDULE' "{}" \;

find /goldengate/ggsoracle/*/ora112/dirprm/*.prm -type f -exec grep  -l 'NXTAPPONRT.MAC_SCHEDULE' "{}" \;

find /code/prod/dba/* -type f -exec grep -l "6qsvad" "{}" \;

find /goldengate/ggsoracle/*/ora112/dirprm/rtmp0*c3.prm -type f -exec sed -i 's/tmpr6qs/rtmp/g' {} +

#

find /u01/app/orabcx/diag/rdbms/orabcx01/ORABCX01/trace/ORABCX01_ora_16*.trc -type f -mtime +90 -exec ls -l  "{}" \;

find /oracle/g01/admin/NIVP1013/diag/rdbms/nivp101/NIVP1013/trace/*.trm -mtime +3 -exec rm -f {} \;

# process using port

ps -ef| awk '{print $2}'| xargs -I '{}' sh -c 'echo examining process {}; pfiles {}| grep 1830'


find /oracle/g01/admin/NIVP1013/diag/rdbms/nivp101/NIVP1013/trace/*.trc -mtime +3 | wc -l

-- linux performance

ps aux | sort -nrk 3,3 | head -n 28

iostat -xz 1 100

vmstat -w 1 100


-- CPU SUNOS

sar -u 5 60

psrinfo -pv

-- SUNOS memory

prtconf | grep Memory


-- AIX CPU

prtconf -s
pmcycles -m
lsdev -Cc processor
# bindprocessor -q

-- AIX memory

lparstat -i | grep Memory

ipcs -am

lsdev -C | grep mem

lsattr -El mem0

svmon -G -O unit=MB
svmon -G -i 1 2

#shows patchset
oslevel -s

ps gv | head -n 1; ps gv | egrep -v "RSS" | sort +6b -7 -n -r

ps gv | head -n 1;


export EDITOR=vi


#check zip
ek923426@plsab677:/oracle/g01/bkup01/C265370[EAIP1031] > unzip -l rms_files.zip
Archive:  rms_files.zip
  Length     Date   Time    Name
 --------    ----   ----    ----
       80  07-17-20 05:52   LFO_tablespace.txt
      202  07-17-20 05:45   RHS_tablespace.txt
       66  07-17-20 06:31   VWI_tablespace.txt
     3451  07-17-20 08:09   files_list.txt
      124  07-17-20 05:48   scn_LFO.txt
      124  07-17-20 05:45   scn_RHS.txt
      124  07-17-20 06:31   scn_VWI.txt
     1300  07-17-20 05:48   LFO.log
     1545  07-17-20 05:46   RHS.log
     1425  07-17-20 06:37   VWI.log
 --------                   -------
     8441                   10 files

# add to zip
zip -uj file.zip *.log

# remove from zip
zip -d /tmp/ECP2_tns.zip orainfra/app/product/18.0.0/grid/network/admin/listener.ora


for i in `ps -ef | grep PARAMFILE | awk '{print $2}'`; do kill  $i; done;

#linux TOP a PID

top -p pid

# change shm size.

/etc/fstab
none                    /dev/shm                tmpfs   defaults,size=6G 0 0
mount -o remount /dev/shm

# copy file to a new file and modify based on search criteria using sed.

cat /etc/security/limits.d/oracle-database-preinstall-19c.conf | sed 's/oracle/grid /g' > /etc/security/limits.d/oracle-grid-user-preinstall-19c.conf
