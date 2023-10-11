col object_name for a30
select l.INST_ID,
l.SESSION_ID,
s.SERIAL#,
l.ORACLE_USERNAME,
l.PROCESS,
l.LOCKED_MODE,
o.OBJECT_NAME,
o.owner,
s.sql_id
from gv$locked_object l
join dba_objects o using (object_id)
join gv$session s on (l.session_id=s.sid)
--where l.oracle_username='NXTAPPONRT'
where -- o.object_name like '%ACCTIT%'
--and 
o.owner='SAPSR3'
--and o.object_name='%FE_TMR%'
--where l.session_id=189
order by o.object_name
/

select
--distinct
count(lc.session_id),
ob.OBJECT_NAME
from gv$locked_object lc,
dba_objects ob
where lc.object_id = ob.object_id
and ob.owner != 'SYSTEM'
group by ob.OBJECT_NAME

 --and OBJECT_NAME like '%TABLE_CASE%'
/


select distinct FINAL_BLOCKING_SESSION from v$session where  FINAL_BLOCKING_SESSION_STATUS='VALID';

-- locks
select  sid, serial#,
inst_id, blocking_session, blocking_session_status, sql_id, status, last_call_et, event
from gv$session
where blocking_session is not null order by 5;

-- TM CONTENTION

col tm for a30
SELECT distinct w.tm, w.p2 OBJECT_ID, l.inst_id, l.sid, l.lmode, l.request
 FROM
  ( SELECT p2, p3, 'TM-'||substr(p2raw,-8)||'-'||lpad(p3,8,'0') TM
      FROM v$session_wait
     WHERE event='enq: TX - row lock contention'
      -- and state='WAITING'
  ) W,
  gv$lock L
 WHERE l.type(+)='TM'
   and l.id1(+)=w.p2
   and l.id2(+)=w.p3
 ORDER BY tm, lmode desc, request desc
;



col machine for a30
select inst_id, sid, serial#,
process, username, machine, sql_id, last_call_et,
osuser,
status, last_call_et,EVENT, program, status
from gv$session
where sid=1815
--where username='TAXREP'
--and status = 'ACTIVE';


select sql_fulltext from gv$sql where sql_id='4z1vnc0995bm6';
select sql_fulltext from gv$sql where sql_id='79rc6fgr9ft0y';

select sql_id, sql_fulltext from gv$sql where lower(sql_text) like 'select count(*) from %v_bpmf_montr_h1%';

col SAMPLE_TIME for a30
col event for a30
select a.sample_id,a.sample_time,a.session_id,a.event,
a.session_state,a.event,a.sql_id,
a.blocking_session,a.blocking_session_status
from v$active_session_history a, dba_users u
where u.user_id = a.user_id
and a.event like '%row%'
and a.sample_time between to_date('31-MAY-21 09.00','DD-MON-YY hh24:mi') and to_date('31-MAY-21 09.15','DD-MON-YY hh24:mi')
--and u.username = 'TESTUSER'
order by sample_time
/

-- READ BY OTHER SESSION_ID
SELECT
   p1 "file#",
   p2 "block#",
   p3 "class#"
FROM
   v$session_wait
WHERE
   event = 'read by other session';

   alter system dump datafile 48 block 1512310;


select /*+ parallel (a,4)*/ to_char(sample_time, 'dd-mon-yyyy hh24:mi') time, sql_id, count(1) qty, count(1)*100/sum(count(*)) over() pctload
--  from gv$active_session_history a
  from DBA_HIST_ACTIVE_SESS_HISTORY a
--  where sample_time between to_date('16-JUL-2019 13:20:00','dd-mon-yyyy hh24:mi:ss') and to_date('16-JUL-2019 13:50:00','dd-mon-yyyy hh24:mi:ss')
  where sample_time > sysdate - 3/24
    and event='enq: TX - row lock contention'
   --and session_id = :B1
    --and sql_id='8qman17pk081n'
  having count(1)>20
  group by to_char(sample_time, 'dd-mon-yyyy hh24:mi'), sql_id
  order by 1,3 desc;



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