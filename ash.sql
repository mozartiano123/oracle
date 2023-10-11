 select * from dba_hist_wr_control;

 exec dbms_workload_repository.modify_snapshot_settings(interval => 15, retention => 44640);


col time for a20
col event for a40
set lines 170 pages 500
break on time 
select to_char(sample_time, 'dd-mon-yyyy hh24:mi') time, event, count(1) qty, count(1)*100/sum(count(1)) over() pctload
  from DBA_HIST_ACTIVE_SESS_HISTORY
  where sample_time between to_date('10-May-2018 12:00','dd-mon-yyyy hh24:mi:ss') and to_date('10-May-2018 12:30','dd-mon-yyyy hh24:mi:ss')
  --and event='enq: TX - row lock contention'
  group by to_char(sample_time, 'dd-mon-yyyy hh24:mi'), event
  order by 1,4 desc ;



-- SQL ID Wait events.

col time for a17
col time for a20
col event for a40
set lines 170 pages 500
break on time 
select /*+parallel(8)*/ --to_char(a.sample_time, 'dd-mon-yyyy hh24:mi') time,
 a.sql_id , u.username ,count(1) qty
  from dba_hist_active_sess_history a join dba_users u using(user_id)
 where a.sample_time between to_date('10-mar-2020 00:00:00','dd-mon-yyyy hh24:mi:ss') and to_date('10-mar-2020 01:40:00','dd-mon-yyyy hh24:mi:ss')
   and user_id!=30
   group by --to_char(a.sample_time, 'dd-mon-yyyy hh24:mi'), 
   a.sql_id, u.username
  order by 3 desc ; 


col time for a20
col event for a40
set lines 170 pages 500
break on time 


col sample_time for a30
select a.sample_id,a.sample_time,a.session_id, a.session_state,a.event,a.sql_id, a.blocking_session,a.blocking_session_status, a.MACHINE, b.username
from dba_hist_active_sess_history a join dba_users b on (a.USER_ID=b.USER_ID)
where sample_time between to_date('03-OCT-2019 10:00','dd-mon-yyyy hh24:mi:ss') and sysdate
and a.blocking_session is not null
and a.sql_id is not null
and a.event in ('enq: TX - index contention', 'log file sync','enq: TX - row lock contention','row cache lock');
/


col sample_time for a30
--select a.event, a.sql_id, count(*)
select a.sample_time, b.username, a.sql_id, a.event, MACHINE, count(*)
from dba_hist_active_sess_history a join dba_users b on (a.USER_ID=b.USER_ID)
where sample_time between to_date('27-Apr-2018 00:00','dd-mon-yyyy hh24:mi:ss') and to_date('28-Apr-2018 23:59','dd-mon-yyyy hh24:mi:ss')
and a.blocking_session is not null
and a.sql_id = '73rgzkqt3qaka'
--and a.event in ('enq: TX - index contention', 'log file sync','enq: TX - row lock contention','row cache lock')
group by a.sample_time, b.username, a.sql_id, a.event, a.MACHINE
--group by a.event, a.sql_id
having count(*) > 3
order by a.sample_time
/



col sample_time for a30
select --a.sample_id,
to_char(trunc(a.sample_time),'DD-MON-YY HH24'),a.session_id, count(*), a.sql_id, a.machine
from dba_hist_active_sess_history a join dba_users b on (a.USER_ID=b.USER_ID)
where sample_time between to_date('01-mar-2019 09:25:00','dd-mon-yyyy hh24:mi:ss') and to_date('01-mar-2019 09:35:00','dd-mon-yyyy hh24:mi:ss')
and a.blocking_session is not null
and a.event like '%TX%'
group by --a.sample_id,
to_char(trunc(a.sample_time),'DD-MON-YY HH24'),a.session_id, a.sql_id, a.machine
having count(*) > 1 
order by count(*);
/