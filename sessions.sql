-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/session_events.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session events.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_events
-- Last Modified: 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 999
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event FORMAT A40

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       se.event,
       se.total_waits,
       se.total_timeouts,
       se.time_waited,
       se.average_wait,
       se.max_wait,
       se.time_waited_micro
FROM   v$session_event se,
       v$session s
WHERE  s.sid = se.sid
--AND    s.sid = &1
AND    s.status = 'ACTIVE'
and    s.type <> 'BACKGROUND'
ORDER BY se.time_waited DESC;





-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/session_events_by_spid.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session events for the specified spid.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_events_by_spid (spid)
-- Last Modified: 06-APR-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 999
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event FORMAT A40

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       se.event,
       se.total_waits,
       se.total_timeouts,
       se.time_waited,
       se.average_wait,
       se.max_wait,
       se.time_waited_micro
FROM   v$session_event se,
       v$session s,
       v$process p
WHERE  s.sid = se.sid
AND    s.paddr = p.addr
AND    p.spid = &1
ORDER BY se.time_waited DESC;






-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/session_io.sql
-- Author       : Tim Hall
-- Description  : Displays I/O information on all database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_io
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 999

COLUMN username FORMAT A15

SELECT NVL(s.username, '(oracle)') AS username,
       s.osuser,
       s.sid,
       s.serial#,
       si.block_gets,
       si.consistent_gets,
       si.physical_reads,
       si.block_changes,
       si.consistent_changes
FROM   v$session s,
       v$sess_io si
WHERE  s.sid = si.sid
ORDER BY s.username, s.osuser;




-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/session_rollback.sql
-- Author       : Tim Hall
-- Description  : Displays rollback information on relevant database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_rollback
-- Last Modified: 29/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN username FORMAT A15

SELECT s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       t.used_urec,
       rs.segment_name,
       r.rssize,
       r.status
FROM   v$transaction t,
       v$session s,
       v$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    t.xidusn = r.usn
AND   rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC;




-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/session_stats.sql
-- Author       : Tim Hall
-- Description  : Displays session-specific statistics.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_stats (statistic-name or all)
-- Last Modified: 03/11/2004
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

SELECT sn.name, ss.value
FROM   v$sesstat ss,
       v$statname sn,
       v$session s
WHERE  ss.statistic# = sn.statistic#
AND    s.sid = ss.sid
AND    s.audsid = SYS_CONTEXT('USERENV','SESSIONID')
AND    sn.name LIKE '%' || DECODE(LOWER('&1'), 'all', '', LOWER('&1')) || '%';




-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/session_waits.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session waits.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_waits
-- Last Modified: 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 999

COLUMN username FORMAT A20
COLUMN event FORMAT A30

SELECT NVL(s.username, '(oracle)') AS username,
       s.sid,
       s.serial#,
       sw.event,
       sw.wait_time,
       sw.seconds_in_wait,
       sw.state
FROM   v$session_wait sw,
       v$session s
WHERE  s.sid = sw.sid
and s.sid='1678'
order by s.sid
ORDER BY sw.seconds_in_wait DESC;




-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/sessions.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sessions
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 999

COLUMN username FORMAT A15
COLUMN osuser FORMAT A15
COLUMN spid FORMAT A10
COLUMN service_name FORMAT A15
COLUMN module FORMAT A35
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

  SELECT NVL(s.username, '(oracle)') AS username,
         s.osuser,
         s.sid,
         s.serial#,
         p.spid,
         s.lockwait,
         s.status,
         s.service_name,
         s.module,
         s.machine,
         s.program,
         s.sql_id,
         TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time,
         s.last_call_et AS last_call_et_secs
  FROM   gv$session s,
         gv$process p
  WHERE  s.paddr = p.addr
         -- and s.status='ACTIVE'
         and p.spid = 21414
         --and s.username='SYS'
  ORDER BY p.spid, logon_time, s.username, s.osuser;





-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/sessions_by_machine.sql
-- Author       : Tim Hall
-- Description  : Displays the number of sessions for each client machine.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sessions_by_machine
-- Last Modified: 20-JUL-2014
-- -----------------------------------------------------------------------------------
SET PAGESIZE 999
set lines 200

SELECT machine,
       NVL(active_count, 0) AS active,
       NVL(inactive_count, 0) AS inactive,
       NVL(killed_count, 0) AS killed
FROM   (SELECT machine, status, count(*) AS quantity
        FROM   gv$session
        where type <> 'BACKGROUND'
        GROUP BY machine, status)
PIVOT  (SUM(quantity) AS count FOR (status) IN ('ACTIVE' AS active, 'INACTIVE' AS inactive, 'KILLED' AS killed))
ORDER BY machine;




-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/top_sessions.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database sessions ordered by executions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @top_sessions.sql (reads, execs or cpu)
-- Last Modified: 21/02/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 999
SET VERIFY OFF

COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

SELECT NVL(a.username, '(oracle)') AS username,
       a.osuser,
       a.sid,
       a.serial#,
       c.value AS &&1,
       a.lockwait,
       a.status,
       a.module,
       a.machine,
       a.program,
       TO_CHAR(a.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   gv$session a,
       gv$sesstat c,
       gv$statname d
WHERE  a.sid        = c.sid
AND    c.statistic# = d.statistic#
AND    d.name       = DECODE(UPPER('&1'), 'READS', 'session logical reads',
                                          'EXECS', 'execute count',
                                          'CPU',   'CPU used by this session',
                                                   'CPU used by this session')
and    a.status='ACTIVE'
AND    a.type <> 'BACKGROUND'
ORDER BY c.value DESC;

SET PAGESIZE 14


select INST_ID,machine, count(*) from gv$session
group by INST_ID,machine;

-- parallel sessions


select distinct s.inst_id,s.username,s.osuser,s.status,s.sql_id,p.qcsid,p.DEGREE,p.REQ_DEGREE from gv$px_session p,gv$session s
where s.inst_id=p.inst_id and s.sid=p.sid and s.status='ACTIVE'
and s.inst_id=1
order by p.REQ_DEGREE ;



---- LOCKS


SELECT vs.username,
 vs.osuser,
 vh.sid locking_sid,
 vs.status status,
 vs.module module,
 vs.program program_holding,
 jrh.job_name,
 vsw.username,
 vsw.osuser,
 vw.sid waiter_sid,
 vsw.program program_waiting,
 jrw.job_name--,
-- 'alter system kill session ' || ''''|| vh.sid || ',' || vs.serial# || ''';'  "Kill_Command"
FROM v$lock vh,
 v$lock vw,
 v$session vs,
 v$session vsw,
 dba_scheduler_running_jobs jrh,
 dba_scheduler_running_jobs jrw
WHERE     (vh.id1, vh.id2) IN (SELECT id1, id2
 FROM v$lock
 WHERE request = 0
 INTERSECT
 SELECT id1, id2
 FROM v$lock
 WHERE lmode = 0)
 AND vh.id1 = vw.id1
 AND vh.id2 = vw.id2
 AND vh.request = 0
 AND vw.lmode = 0
 AND vh.sid = vs.sid
 AND vw.sid = vsw.sid
 AND vh.sid = jrh.session_id(+)
 AND vw.sid = jrw.session_id(+);


select count(*), status, machine from v$session where type <> 'BACKGROUND'
group by status, machine ;


--

-- Monitor SGA size

col description for a70
col parameter for a30
set numwidth 20
SELECT i.instance_name instance,
 -- b.ksppstvl "Session_Value",
 c.ksppstvl value,c.ksppstvl/1024/1024 meg,c.ksppstvl/1024/1024/1024 gig,
 -- above is instance_value
 a.ksppinm "PARAMETER",KSPPDESC "DESCRIPTION"
 FROM
 x$ksppi a,
 x$ksppcv b,
 x$ksppsv c,
 v$instance i
 WHERE
 a.indx = b.indx
 AND
 a.indx = c.indx
 AND
 (a.ksppinm LIKE '/_/_%' escape '/' or a.ksppinm LIKE 'db_keep_cache_size' or a.ksppinm LIKE 'db_recycle_cache_size')
 and a.ksppinm not in ('__oracle_base')
 and c.ksppstvl not in ('TRUE','FALSE')
 order by 3
 /




-- MONITOR DATAPUMP SESSIONS

 SELECT V.STATUS, V.SID,V.SERIAL#,IO.BLOCK_CHANGES,EVENT, MODULE
 FROM V$SESS_IO IO,V$SESSION V WHERE IO.SID=V.SID AND V.SADDR IN
 (SELECT SADDR FROM DBA_DATAPUMP_SESSIONS) ORDER BY SID;


   --- longops
  col username for a20
  col units for a10
  set lines 200
  col username for a12
  col machine for a30
  col osuser for a10
  col target for a20
  col opname for a30
  col done for a5
  col inst for 99
  col sid for 99999
  col ser# for 99999
  compute sum of sofar on report
  compute sum of totalwork on report
  break on report
  select a.inst_id inst,a.sid, a.serial# ser#, a.username
  , b.machine, b.osuser
  ,  a.SOFAR, a.TOTALWORK, units,
  round(( a.sofar/a.totalwork )*100)||'%' Done, a.TARGET, time_remaining/60 minut, a.OPNAME, b.sql_id
  from gv$session_longops a, gv$session b
  where a.sofar <> a.totalwork
  and a.sid=b.sid
  and a.serial#=b.serial#
  and a.inst_id=b.inst_id
  and a.totalwork<>0
  --and b.sql_id in ('fxxgfq8r0nd2j')
 -- and a.username='MSAF'
  /

--  sessions
select event,count(1) qty from gv$session
where status='ACTIVE' and username is not null group by event order by 2 desc



    set lin 200 pages 999
    col tim for a15
    col process for a7
    col event for a40
    col machine for a15
    col program for a30
    col username for a20
    select
    inst_id,
    SID,
    serial#,
    username,
    --osuser,
    machine,
    program,
    process,
    --blocking_session as bl,
    to_char(LOGON_TIME, 'DDMM - HH24:MI') as tim,
    LAST_CALL_ET/60 et_min,
    --BLOCKING_SESSION,
    P1,
    EVENT,
    WAIT_TIME,
    SECONDS_IN_WAIT,
    status,
    sql_id,
    prev_sql_id
    from gv$session
    where
    type <> 'BACKGROUND'
    --and program like '%dante%'
    --and event like '%resmgr:cpu quantum%'
    --and upper(program) like '%SQL DEVELOPER%'
  and status='ACTIVE'
 -- and program in ('intprd-000012')
   -- and machine in ('sahara')
    --and username = 'CH134255'
   -- and sql_id in ('5zsn5vc8bgz0y')
    --and sid in ('863')
    --and inst_id = 1
   --and lower(machine) like lower('%MAIGLOG054%')
    --and type <> 'BACKGROUND'
   -- and sql_id='880s8wa5dkvmp'
  and username = 'SYS'
 --and lower(username) like 'dcsdba'
-- and sid in ('65','690', '1399')
    --and osuser='ndwadm'
    --and process = '11744'
  --  and status = 'INACTIVE'
    --and logon_time < sysdate - 1/24
    --and event not in ('resmgr:cpu quantum')
    order by LOGON_TIME
    /




-- sessions using CPU.
select
   ss.username,
   se.SID,
   VALUE/100 cpu_usage_seconds
from
   v$session ss,
   v$sesstat se,
   v$statname sn
where
   se.STATISTIC# = sn.STATISTIC#
and
   NAME like '%CPU used by this session%'
and
   se.SID = ss.SID
and
   ss.status='ACTIVE'
and
   ss.username is not null
order by VALUE desc;

-- Sessão fazendo rollback

select t.INST_ID
       , s.sid
       , s.serial#
       , s.program
       , t.status as transaction_status
       , s.status as session_status
       , s.lockwait
       , s.pq_status
       , t.used_ublk as undo_blocks_used
       , decode(bitand(t.flag, 128), 0, 'NO', 'YES') rolling_back
from
    gv$session s
    , gv$transaction t
where s.taddr = t.addr
and s.inst_id = t.inst_id
--and s.STATUS = 'KILLED'
order by s.inst_id;
/



-- Open transaction

select s.inst_id
      ,s.sid
      ,s.serial#
      ,s.username
      ,s.machine
      ,s.status
      ,s.lockwait
      ,t.used_ublk
      ,t.used_urec
      ,t.start_time
from gv$transaction t
inner join gv$session s on t.addr = s.taddr
order by t.start_time;

-- Process

SELECT s.username, s.osuser, s.machine, s.sid, s.serial#, p.spid, s.program
FROM gv$session s, gv$process p
WHERE s.inst_id = p.inst_id
AND s.paddr = p.addr
AND s.username IS NOT NULL
--and p.spid = 61365
and s.sid = 472
--AND s.STATUS = 'KILLED'
/

SELECT sw.INST_ID, SW.SID, SW.SEQ#, SW.EVENT, SW.STATE, sw.WAIT_TIME
FROM gv$session_wait sw
WHERE sw.sid IN (SELECT sid FROM gv$session s WHERE s.status = 'KILLED' AND s.inst_id = sw.INST_ID)
ORDER BY sw.inst_id
/

SELECT p.INST_ID, p.pid, p.serial#, p.spid, p.program
FROM gv$process p
WHERE p.spid is not null
AND NOT EXISTS (SELECT 1 FROM gv$session s WHERE s.inst_id = p.inst_id and s.paddr = p.addr)
AND p.pname is null
ORDER BY p.inst_id
/

-- ospid

select vs.sid,vs.serial#,vs.username,vs.inst_id,vp.spid
from gv$session vs,gv$process vp
where vs.paddr=vp.addr --and sid=176
--and vs.inst_id=3;
and spid = 7734;


-- ACTIVE TRACES
SELECT * FROM dba_enabled_traces;


SET LINESIZE 100
COLUMN trace_file FORMAT A90
SELECT s.sid,
       s.serial#,
       s.status,
       pa.value || '/' || LOWER(SYS_CONTEXT('userenv','instance_name')) ||    
       '_ora_' || p.spid || '.trc' AS trace_file
FROM   v$session s,
       v$process p,
       v$parameter pa
WHERE  pa.name = 'user_dump_dest'
AND    s.paddr = p.addr
AND    s.audsid = SYS_CONTEXT('USERENV', 'SESSIONID');


-- old sessions
  col machine for a30
  col program for a40
  col logon for a12
  col username for a15
  col osuser for a10
  select inst_id, sid, serial#, machine, program, username, osuser, status, to_char(logon_time,'DD-MON-YY hh24:mi') logon, last_call_et
  from gv$session where logon_time <= sysdate-8/24 and username is not null --and status='ACTIVE'
  and username is not null
  order by logon, last_call_et
  /


  -- machine

  break on username on sql_id
select b.username,sql_id,a.event,count(1) qty, count(1)*100/sum(count(1)) over() pctload
  from DBA_HIST_ACTIVE_SESS_HISTORY a, dba_users b
  --where sample_time >  sysdate - 8/(24*60)
  where a.user_id=b.user_id
    and a.machine like '&machine'
  group by b.username,sql_id,a.event
  order by 1,2;

--ASH show last statements run by a session.

col sample_time for a30
select session_id,
session_serial#,
sample_time,
sql_id,
nvl(wait_class,session_state)
from DBA_HIST_ACTIVE_SESS_HISTORY
where session_id=360 and nvl(wait_class,session_state) <> 'Application'
order by sample_time;

-- ASH queries executed in a session.

col SQL_OPNAME for a20
select --INST_ID, 
SESSION_ID, session_serial#,
SQL_ID, SQL_OPNAME, min(SQL_EXEC_START), max(TIME_WAITED), EVENT
from gv$active_session_history
where SESSION_ID = &sid
--and INST_ID=&inst_id
group by --INST_ID, 
SESSION_ID, session_serial#, SQL_ID, SQL_OPNAME, EVENT
order by min(SQL_EXEC_START), max(TIME_WAITED) desc;


-- Datapump

select
   sid, serial#, username, machine, program, sql_id
from
   v$session s,
   dba_datapump_sessions d
where
   s.saddr = d.saddr;



select
s.username,
s.sid,
s.status,
s.sql_id,
event,
--BLOCKING_SESSION,
substr(sq.sql_fulltext,1,50) as sql_text
from gv$session s,gv$sql sq where sq.sql_id=s.sql_id and s.inst_id=sq.inst_id and s.status='ACTIVE' and s.TYPE <> 'BACKGROUND'
/


-- number of sessions

select count(*),
status,
machine
from gv$session
group by
status,
machine
order by
machine
/


col sid format 999999
col username format a20
col osuser format a15
select a.inst_id, a.sid, a.serial#,a.username, a.osuser,a.status, b.spid
from gv$session a, gv$process b
where a.paddr= b.addr
and a.sid='&sid'
--and b.spid='&pid'
order by a.sid;

--and a.sid='&sid'

set pagesize 900
set linesize 1000
column status format 99999999
column sid format 9999 
column proc_ora format 999999
column USUARIO_SO format a30 
column USUARIO_BD format a30
column SERVIDOR format a30
column PID_SO format a10
column USERNAME format a20
column Data for a20
select to_char(logon_time,'dd/mm/yy hh24:mi') as Data, s.username, substr (OSUSER,1,14) usuario_SO, SUBSTR(s.USERNAME,1,10) usuario_BD, s.SID SID,
s.SERIAL# proc_ora ,status, SUBSTR (SPID,1,8) pid_SO, substr (machine,1,21) servidor
from v$session s, v$process p
where s.PADDR = p.ADDR
and s.sid=9857
--and type != 'BACKGROUND'
--and s.username ='SYS'
order by 1;



exec dbms_system.set_sql_trace_in_session(1528,65457,true);

-- Waits

select event, state, count(*)
from v$session_wait
group by event, state order by 3 desc
/

select sql_id, nvl(a.event, 'on cpu') as event, count(1) qty, count(1)*100/sum(count(*)) over() pctload
  from gv$active_session_history a
 -- where sample_time > sysdate - 1/24
    --and event='latch free'
   --and session_id = :B1
 where sample_time between to_date('13-Nov-2017 02:15:00','dd-mon-yyyy hh24:mi:ss') and to_date('13-Nov-2017 22:45:00','dd-mon-yyyy hh24:mi:ss')
    and sql_id='d6hrtxucyqwxx'
  group by sql_id, nvl(a.event, 'on cpu')
  order by 3 desc;


-- CPU USAGE

SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300

COLUMN username FORMAT A30
--COLUMN sid FORMAT 999,999,999
--COLUMN serial# FORMAT 999,999,999
COLUMN "cpu usage (seconds)"  FORMAT 999,999,999.0000

SELECT
   s.username,
   t.sid,
   s.serial#,
   SUM(VALUE/100) as "cpu usage (seconds)"
FROM
   v$session s,
   v$sesstat t,
   v$statname n
WHERE
   t.STATISTIC# = n.STATISTIC#
AND
   NAME like '%CPU used by this session%'
AND
   t.SID = s.SID
AND
   s.status='ACTIVE'
AND
   s.username is not null
GROUP BY username,t.sid,s.serial#
/

-- Sessions waiting on cursor x

select EVENT, WAIT_TIME_MILLI as "WAIT(MS)", WAIT_COUNT,
round((WAIT_TIME_MILLI*100)/(select sum(WAIT_TIME_MILLI) from
v$event_histogram),3) as "TOTAL DB WAIT(%)"
from  v$event_histogram
where WAIT_TIME_MILLI > 512
and event like '%cursor%'
group by EVENT, WAIT_TIME_MILLI, WAIT_COUNT
order by WAIT_TIME_MILLI desc
/

-- sqlids waiting on cursor x
select count(*), sql_id,sql_child_number,session_state,blocking_session_status,event,wait_class
  from DBA_HIST_ACTIVE_SESS_HISTORY
  where snap_id between 18085 and 18086
  and event like '%cursor: pin S%'
  group by sql_id,sql_child_number,session_state,blocking_session_status,event,wait_class
/

select sql_id,optimizer_cost o_cost,optimizer_mode o_mode ,SHARABLE_MEM mem ,
        version_count ver_c,fetches_total fetc_t ,END_OF_FETCH_COUNT_TOTAL cnt_total,
        EXECUTIONS_TOTAL exe ,PARSE_CALLS_TOTAL pars,DISK_READS_TOTAL disk_t,
        BUFFER_GETS_TOTAL buffer_t ,ROWS_PROCESSED_TOTAL rows_t ,cpu_time_total cpu_t,
        round(elapsed_time_total/1000000) elapsed_s ,iowait_total
from dba_hist_sqlstat
where snap_id between 18085 and 18086
and sql_id in ('<NUMERO_DO_SQLID_1>','<NUMERO_DO_SQLID_2>')
/

-- cursores abertos no banco

select      user_process username,
       "Recursive Calls",
       "Opened Cursors",
       "Current Cursors"
    from  (
       select  nvl(ss.USERNAME,'ORACLE PROC')||'('||se.sid||') ' user_process,
                       sum(decode(NAME,'recursive calls',value)) "Recursive Calls",
                       sum(decode(NAME,'opened cursors cumulative',value)) "Opened Cursors",
                       sum(decode(NAME,'opened cursors current',value)) "Current Cursors"
      from    v$session ss,
                v$sesstat se,
                 v$statname sn
      where   se.STATISTIC# = sn.STATISTIC#
      and     (NAME  like '%opened cursors current%'
      or       NAME  like '%recursive calls%'
      or       NAME  like '%opened cursors cumulative%')
      and     se.SID = ss.SID
      and     ss.USERNAME is not null
      group   by nvl(ss.USERNAME,'ORACLE PROC')||'('||se.SID||') '
   )
   orasnap_user_cursors
   order      by USER_PROCESS,"Recursive Calls"
/


SFWDBS-DS-NOR-NOL-PROD-DBA <SFWDBS-DS-NOR-NOL-PROD-DBA@sprint.com>


-- library cache pin

column h_wait format A20

select 'alter system disconnect session ''' || sid || ',' || serial# || ''' immediate;' from gv$session
where sid in
(SELECT s.sid
FROM
    v$sql sql,
    v$session s,
    x$kglpn p,
    v$session_wait waiter,
    v$session_wait holder
WHERE
    s.sql_hash_value = sql.hash_value and
    p.kglpnhdl=waiter.p1raw and
    s.saddr=p.kglpnuse and
    waiter.event like 'library cache pin' and
    holder.sid=s.sid
GROUP BY
    s.sid,
    waiter.p1raw ,
    holder.event ,
    holder.p1raw ,
    holder.p2raw ,
    holder.p3raw ,
    sql.hash_value
    )
;

    waiter.p1raw w_p1r,
    holder.event h_wait,
    holder.p1raw h_p1r,
    holder.p2raw h_p2r,
    holder.p3raw h_p2r,
    count(s.sid) users_blocked,
    sql.hash_value
FROM
    v$sql sql,
    v$session s,
    x$kglpn p,
    v$session_wait waiter,
    v$session_wait holder
WHERE
    s.sql_hash_value = sql.hash_value and
    p.kglpnhdl=waiter.p1raw and
    s.saddr=p.kglpnuse and
    waiter.event like 'library cache pin' and
    holder.sid=s.sid
GROUP BY
    s.sid,
    waiter.p1raw ,
    holder.event ,
    holder.p1raw ,
    holder.p2raw ,
    holder.p3raw ,
    sql.hash_value



    select to_char(sample_time, 'dd-mon-yyyy hh24:mi') time,b.username,machine,a.event,count(1) qty, count(1)*100/sum(count(1)) over() pctload
  from DBA_HIST_ACTIVE_SESS_HISTORY a, dba_users b
--  from gv$active_session_history a, dba_users b
  where a.user_id=b.user_id
--    and sample_time between to_date('16-JUL-2019 13:20:00','dd-mon-yyyy hh24:mi:ss') and to_date('16-JUL-2019 13:50:00','dd-mon-yyyy hh24:mi:ss')
    and sample_time > sysdate - 3/24
    and event='enq: TX - row lock contention'
    and sql_id='&SQL_ID'
  group by to_char(sample_time, 'dd-mon-yyyy hh24:mi'),b.username,a.event,machine
  order by 1,2;

select NAME,RTIME,TABLESPACE_SIZE*8192/power(1024,4),TABLESPACE_USEDSIZE*8192//power(1024,4)
from dba_hist_tbspc_space_usage,v$tablespace
where TABLESPACE_ID=TS# and NAME='TEMP_FLASH_01' and RTIME like '11/17/2019%' order by 1,2;




-- get SGA in use


-- get memory in use size of procs

set lin 200 pages 999
compute sum of MAX on report
compute sum of ALLOC on report
compute sum of USED on report
compute sum of FREE on report
break on report

SELECT spid, program,
            pga_max_mem/1024      max,
            pga_alloc_mem/1024    alloc,
            pga_used_mem/1024     used,
            pga_freeable_mem/1024 free
FROM V$PROCESS;



-- CPU in use per username for active.

SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300

COLUMN username FORMAT A30
COLUMN sid FORMAT 999,999,999
COLUMN serial# FORMAT 999,999,999
COLUMN "cpu usage (seconds)"  FORMAT 999,999,999.0000

SELECT
   s.username,
   t.sid,
   s.serial#,
   SUM(VALUE/100) as "cpu usage (seconds)"
FROM
   v$session s,
   v$sesstat t,
   v$statname n
WHERE
   t.STATISTIC# = n.STATISTIC#
AND
   NAME like '%CPU used by this session%'
AND
   t.SID = s.SID
AND
   s.status='ACTIVE'
AND
   s.username is not null
GROUP BY username,t.sid,s.serial#
/



-- CPU WAIT ON THE DATABASE
set lin 200 pages 999
col BEGIN_TIME for a15
col END_TIME for a15

with AASSTAT as (
           select
                 decode(n.wait_class,'User I/O','User I/O',
                                     'Commit','Commit',
                                     'Wait')                               CLASS,
                 sum(round(m.time_waited/m.INTSIZE_CSEC,3))                AAS,
                 BEGIN_TIME ,
                 END_TIME
           from  v$waitclassmetric  m,
                 v$system_wait_class n
           where m.wait_class_id=n.wait_class_id
             and n.wait_class != 'Idle'
           group by  decode(n.wait_class,'User I/O','User I/O', 'Commit','Commit', 'Wait'), BEGIN_TIME, END_TIME
          union
             select 'CPU_ORA_CONSUMED'                                     CLASS,
                    round(value/100,3)                                     AAS,
                 BEGIN_TIME ,
                 END_TIME
             from v$sysmetric
             where metric_name='CPU Usage Per Sec'
               and group_id=2
          union
            select 'CPU_OS'                                                CLASS ,
                    round((prcnt.busy*parameter.cpu_count)/100,3)          AAS,
                 BEGIN_TIME ,
                 END_TIME
            from
              ( select value busy, BEGIN_TIME,END_TIME from v$sysmetric where metric_name='Host CPU Utilization (%)' and group_id=2 ) prcnt,
              ( select value cpu_count from v$parameter where name='cpu_count' )  parameter
          union
             select
               'CPU_ORA_DEMAND'                                            CLASS,
               nvl(round( sum(decode(session_state,'ON CPU',1,0))/60,2),0) AAS,
               cast(min(SAMPLE_TIME) as date) BEGIN_TIME ,
               cast(max(SAMPLE_TIME) as date) END_TIME
             from v$active_session_history ash
              where SAMPLE_TIME >= (select BEGIN_TIME from v$sysmetric where metric_name='CPU Usage Per Sec' and group_id=2 )
               and SAMPLE_TIME < (select END_TIME from v$sysmetric where metric_name='CPU Usage Per Sec' and group_id=2 )
)
select
       to_char(BEGIN_TIME,'HH:MI:SS') BEGIN_TIME,
       to_char(END_TIME,'HH:MI:SS') END_TIME,
       CPU_OS CPU_TOTAL,
       decode(sign(CPU_OS-CPU_ORA_CONSUMED), -1, 0, (CPU_OS - CPU_ORA_CONSUMED )) CPU_OS,
       CPU_ORA_CONSUMED CPU_ORA,
       decode(sign(CPU_ORA_DEMAND-CPU_ORA_CONSUMED), -1, 0, (CPU_ORA_DEMAND - CPU_ORA_CONSUMED )) CPU_ORA_WAIT,
       COMMIT,
       READIO,
       WAIT
       -- ,(  decode(sign(CPU_OS - CPU_ORA_CONSUMED), -1, 0,
       --                (CPU_OS - CPU_ORA_CONSUMED))
       --    + CPU_ORA_CONSUMED +
       --  decode(sign(CPU_ORA_DEMAND - CPU_ORA_CONSUMED), -1, 0,
       --             (CPU_ORA_DEMAND - CPU_ORA_CONSUMED ))) STACKED_CPU_TOTAL
from (
        select
                min(BEGIN_TIME) BEGIN_TIME,
                max(END_TIME) END_TIME,
                sum(decode(CLASS,'CPU_ORA_CONSUMED',AAS,0)) CPU_ORA_CONSUMED,
                sum(decode(CLASS,'CPU_ORA_DEMAND' ,AAS,0)) CPU_ORA_DEMAND,
                sum(decode(CLASS,'CPU_OS' ,AAS,0)) CPU_OS,
                sum(decode(CLASS,'Commit' ,AAS,0)) COMMIT,
                sum(decode(CLASS,'User I/O' ,AAS,0)) READIO,
                sum(decode(CLASS,'Wait' ,AAS,0)) WAIT
         from AASSTAT)
/


-- Sessions doing most physical reads io

set lines 120
col osuser   format a10
col username format a10

select
   osuser,
   username,
   process pid,
   ses.sid sid,
   serial#,
   physical_reads,
   block_changes,
   sql_id
from
   v$session ses,
   v$sess_io sio
where
   ses.sid = sio.sid
order
   by physical_reads ;

 

 -- SQL PLAN


SET LINES 1000
SET PAGES 1000
COLUMN I FORMAT A3


  SELECT /*+ NO_MERGE */ 
         ROWNUM-1||
   DECODE(access_predicates,NULL,DECODE(filter_predicates,NULL,'','*'),'*') "I",
         SUBSTR(LPAD(' ',(DEPTH-1))||
   OPERATION,1,40)||
   DECODE(OPTIONS,NULL,'',' (' 
   || OPTIONS 
   || ')') "Operation",
         SUBSTR(OBJECT_NAME,1,30) "Object Name",
         cardinality "# Rows",
         bytes,
         cost,
         time
    FROM (
         SELECT * 
           FROM gv$sql_plan 
          WHERE sql_id = 'c4tknm4pyujt3'
          and plan_hash_value='3114505402'
         ) plan
ORDER BY id
/
