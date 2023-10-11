ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;



-- Check status, if MRP is running than it is applying.


select process, thread#, sequence#, status from v$managed_standby where process like 'MRP%';


-- find lag

SELECT name, value, datum_time, time_computed
FROM v$dataguard_stats
WHERE name like '%lag%';



-- check applied logs

SELECT SEQUENCE#, APPLIED FROM V$ARCHIVED_LOG;

SELECT
    THREAD#,
     SEQUENCE#,
     APPLIED,
     REGISTRAR,
     DELETED,
     BACKUP_COUNT
  From
     V$ARCHIVED_LOG
-- where applied='YES'
where THREAD#='1'
 order by 2;

-- applied vs current

select s.applied, p.curr, th 
from (select max(sequence#) applied, thread# th 
      from v$archived_log 
      where applied <> 'NO' 
      group by thread#) s
join (select max(sequence#) curr, thread# th
      from v$archivelog
      group by thread#) p
using (th);


SELECT
     THREAD#,
     max(SEQUENCE#)
From
     V$ARCHIVED_LOG
     where applied='YES'
 group by thread#;

SELECT
     THREAD#,
     max(SEQUENCE#)
From
     V$ARCHIVED_LOG
group by thread#;


-- Get last sequence generated

SELECT THREAD# , SEQUENCE#
FROM V$ARCHIVED_LOG
WHERE (THREAD#,FIRST_TIME ) IN (SELECT THREAD#,MAX(FIRST_TIME) FROM V$ARCHIVED_LOG GROUP BY THREAD#)
ORDER BY 1;

SELECT THREAD#, MAX(SEQUENCE#)
FROM V$LOG_HISTORY
WHERE RESETLOGS_CHANGE# =
(SELECT RESETLOGS_CHANGE#
FROM V$DATABASE_INCARNATION
WHERE STATUS = 'CURRENT')
GROUP BY THREAD#;


-- Get last sequence applied and shipped.
set lin 200 pages 99
select al.thrd "Thread", almax "Last Seq Received", lhmax "Last Seq Applied"
from (select thread# thrd, max(sequence#) almax
      from v$archived_log
      where resetlogs_change#=(select resetlogs_change# from v$database)
      group by thread#) al,
     (select thread# thrd, max(sequence#) lhmax
      from v$log_history
      where first_time=(select max(first_time) from v$log_history)
      group by thread#) lh
where al.thrd = lh.thrd;


--------------------------------------------------------------------------|
-- RECOVER FROM MISSING file (STANDBY_FILE_MANAGEMENT was set to manual)--|
--------------------------------------------------------------------------|


1- Check for file error on STBY:

    SQL> col name for a80
    SQL> select * from v$recover_file where error like '%FILE%';

         FILE# ONLINE  ONLINE_ ERROR                                                                CHANGE# TIME
---------- ------- ------- ----------------------------------------------------------------- ---------- ---------
       318 ONLINE  ONLINE  FILE MISSING                                                               0



2- Check if file exists on PRIMARY:

    SQL> col name for a80
    SQL> select file#,name from v$datafile where file#=7;

         FILE# NAME
---------- --------------------------------------------------------------------------------
       318 +DATA_01/wdmp101/datafile/oemadm_data.628.1027244275


3- Check if file exists on STBY:

    SQL> col name for a80
    SQL> select file#,name from v$datafile where file#=7;

         FILE# NAME
---------- --------------------------------------------------------------------------------
       318 /oracle/g01/software/rdbms/11.2.0.4/dbs/UNNAMED00318


4- Create the file in the STBY:

  SQL> alter database create datafile '/oracle/SJP/122/dbs/UNNAMED00007' as new;

  Database altered.

#no worries, this file will be created in the DATA_01 because of OMF.

5- Enable STANDBY_FILE_MANAGEMENT as AUTO on STBY:

  SQL> alter system set standby_file_management=AUTO scope=both sid='*';

  System altered.


6- Restart the redo apply on STBY:

SQL> alter database recover managed standby database disconnect from session;

Database altered.


7- Check if MRP has started and if redo is applying on STBY:


  SQL> col name for a30
  SQL> col value for a30
  SQL> select process, thread#, sequence#, status from v$managed_standby where process='MRP0';

  PROCESS      THREAD#  SEQUENCE# STATUS
  --------- ---------- ---------- ------------
  MRP0               3      11254 APPLYING_LOG

  SQL> select * from v$dataguard_stats;

NAME                           VALUE                          UNIT                           TIME_COMPUTED                  DATUM_TIME
------------------------------ ------------------------------ ------------------------------ ------------------------------ ------------------------------
transport lag                  +00 00:00:00                   day(2) to second(0) interval   12/19/2019 20:39:46            12/19/2019 20:39:45
apply lag                      +02 10:51:00                   day(2) to second(0) interval   12/19/2019 20:39:46            12/19/2019 20:39:45
apply finish time              +00 14:15:41.052               day(2) to second(3) interval   12/19/2019 20:39:46
estimated startup time         20                             second                         12/19/2019 20:39:46


8- Check  archivelog for messages of log applying.




ALTER DATABASE DROP STANDBY LOGFILE GROUP 21;
ALTER DATABASE DROP STANDBY LOGFILE GROUP 22;


alter database add standby logfile THREAD 1 group 31 ('/flash/archive/CONCDF_STBY/onlinelog/stby_redo31.log') SIZE 512M;
alter database add standby logfile THREAD 1 group 32 ('/flash/archive/CONCDF_STBY/onlinelog/stby_redo32.log') SIZE 512M;


