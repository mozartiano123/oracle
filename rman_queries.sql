select RECID, STAMP ROW_LEVEL, ROW_TYPE, COMMAND_ID, OPERATION, MBYTES_PROCESSED, START_TIME, INPUT_BYTES, OUTPUT_BYTES, OBJECT_TYPE 
from v$rman_status 
where status='RUNNING'
/


select FILE#,CREATION_TIME, DATAFILE_BLOCKS, (BLOCKS*BLOCK_SIZE)/1048576 as zie, COMPLETION_TIME, BLOCKS_READ
from V$BACKUP_DATAFILE 
--where file#='8'
where COMPLETION_TIME >= to_date('15-dec-2021 00:00:00','dd-mon-yyyy hh24:mi:ss')
order by COMPLETION_TIME
/

-- longops
set lin 200 pages 999
col opname for a25
col serial# for a8
SELECT SID, SERIAL#, OPNAME, CONTEXT, SOFAR, TOTALWORK,
       ROUND(SOFAR/TOTALWORK*100,2) "%_COMPLETE"
FROM   V$SESSION_LONGOPS
WHERE  OPNAME LIKE 'RMAN%'
AND    OPNAME NOT LIKE '%aggregate%'
AND    TOTALWORK != 0
AND    SOFAR <> TOTALWORK;


select START_TIME, END_TIME, trunc(elapsed_seconds/60) as ELAPSED, INPUT_BYTES, OUTPUT_BYTES , STATUS 
from V$RMAN_BACKUP_JOB_DETAILS
where elapsed_seconds/60 > 60
order by start_time;

-- Backup time.
set numwidth 20
set lin 200 pages 999
col status for a10
select SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy hh24:mi') end_time,
trunc(elapsed_seconds/3600,2) hrs,
INPUT_BYTES/1048576 inMB, 
OUTPUT_BYTES/1048576 ouMB from V$RMAN_BACKUP_JOB_DETAILS
where INPUT_TYPE not in ('ARCHIVELOG')
order by session_key;


-- ARCHIVE Backup time.
set numwidth 20
set lin 200 pages 999
col status for a10
select SESSION_KEY, INPUT_TYPE, STATUS,
to_char(START_TIME,'mm/dd/yy hh24:mi') start_time,
to_char(END_TIME,'mm/dd/yy hh24:mi') end_time,
trunc(elapsed_seconds/3600,2) hrs,
INPUT_BYTES/1048576 inMB, 
OUTPUT_BYTES/1048576 ouMB from V$RMAN_BACKUP_JOB_DETAILS
where INPUT_TYPE in ('ARCHIVELOG')
order by session_key desc fetch first 10 rows only;

-- to adjust rman output run this on the UNIX

export NLS_DATE_FORMAT="dd-mm-yyyy hh24:mi:ss"
