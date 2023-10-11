column "MVIEW BEING REFRESHED" format a40
column INSERTS format 999999999
column UPDATES format 999999999
column DELETES format 999999999
select CURRMVOWNER_KNSTMVR || '.' || CURRMVNAME_KNSTMVR
"MVIEW BEING REFRESHED",
decode( REFTYPE_KNSTMVR, 1, 'FAST', 2, 'COMPLETE', 'UNKNOWN' ) REFTYPE,
decode(GROUPSTATE_KNSTMVR, 1, 'SETUP', 2, 'INSTANTIATE',
3, 'WRAPUP', 'UNKNOWN' ) STATE,
TOTAL_INSERTS_KNSTMVR INSERTS,
TOTAL_UPDATES_KNSTMVR UPDATES,
TOTAL_DELETES_KNSTMVR DELETES,
TOTAL_INSERTS_KNSTMVR+TOTAL_UPDATES_KNSTMVR+TOTAL_DELETES_KNSTMVR as TOTAL
from X$KNSTMVR X
WHERE type_knst=6 and
exists (select 1 from gv$session s
where s.sid=x.sid_knst and
s.serial#=x.serial_knst);




DBMS_MVIEW.REFRESH('MV_AC6_ELA','F',NULL,TRUE,FALSE,0,4,0,FALSE); 

SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
SET VERIFY OFF
 
COLUMN object FORMAT A32
COLUMN type FORMAT A15
COLUMN sid FORMAT 9999
COLUMN username FORMAT A20
COLUMN osuser FORMAT A10
COLUMN program FORMAT A40
 
SELECT a.object,
       a.type,
       a.sid,
       b.username,
       b.osuser,
       b.program
FROM   v$access a,
       v$session b
WHERE  a.sid   = b.sid
AND    a.sid = &enter_session_id
ORDER BY a.object
/



select MOWNER,MASTER,SNAPSHOT,SNAPID,SNAPTIME,SSCN,USER# 
from sys.slog$ where mowner='SPRINT_USAGE' and master='DS_AC6_ELA';



select MVIEW_NAME, LAST_REFRESH_TYPE, LAST_REFRESH_DATE, STALENESS, AFTER_FAST_REFRESH, STALE_SINCE from dba_mviews;


select  mowner, master, log, temp_log from sys.mlog$ where log in (
'MLOG$_DIM_ADJ_REASONS'
)


-- check refresh jobs

col BROKEN form a10
select JOB,LAST_DATE,LAST_SEC,THIS_DATE,THIS_SEC,NEXT_DATE,NEXT_SEC,TOTAL_TIME,BROKEN,FAILURES,WHAT from dba_jobs
/