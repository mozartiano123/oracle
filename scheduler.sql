COL log_id              FORMAT 9999   HEADING 'Log#'
COL log_date            FORMAT A32    HEADING 'Log Date'
COL owner               FORMAT A06    HEADING 'Owner'
COL job_name            FORMAT A30    HEADING 'Job'
COL status              FORMAT A10    HEADING 'Status'
COL actual_start_date   FORMAT A40    HEADING 'Actual|Start|Date'
COL error#              FORMAT 999999 HEADING 'Error|Nbr'
col REQ_START_DATE FORMAT A40    HEADING 'REQ|Start|Date'
col REQ_START_DATE FORMAT A40    HEADING 'Additional|Info'

TTITLE 'Scheduled Tasks:'

select
    owner,
   log_date,
   job_name,
   status,
   --req_start_date,
   actual_start_date,
   run_duration,
   ADDITIONAL_INFO
from
   dba_scheduler_job_run_details
where
 owner='BPM01_SOAINFRA'
 and job_name = 'DELETE_INSTANCES_AUTO_JOB1'
   --job_name like '%MSAF_EXPURGO%'
  -- job_action like '%UPDATE_PORT_STATUS_TO_RPTG_DAY%'
 -- and status <> 'SUCCEEDED'
  -- actual_start_date > sysdate -2/24
  --and actual_start_date between to_date('01-feb-2022 00:00','dd-mon-yyyy hh24:mi') and  to_date('01-feb-2022 10:00','dd-mon-yyyy hh24:mi')
order by
actual_start_date
--run_duration
/

select OWNER, job_name, job_action, start_date, repeat_interval, enabled, state from dba_scheduler_jobs 
where job_action like '%JOB_APRI_SUMARIO_OV_PB_VM%';


select OWNER, job_name, job_action, start_date, repeat_interval, enabled, state from dba_scheduler_jobs 
where job_name = 'DELETE_INSTANCES_AUTO_JOB1';

col owner for a15
col job_name for a30
col job_action for a30
select OWNER, job_name, job_action, last_start_date, NEXT_RUN_DATE , last_run_duration, repeat_interval, enabled, state from dba_scheduler_jobs 
--where upper(job_name) like '%COLETA_ESTATISTICA_PARCIAL%';


col ACTUAL_START_DATE for a30
col ADDITIONAL_INFO for a100
SELECT ACTUAL_START_DATE, RUN_DURATION, JOB_NAME, STATUS, ERROR#, ADDITIONAL_INFO, SESSION_ID, CPU_USED
FROM DBA_SCHEDULER_JOB_RUN_DETAILS
WHERE JOB_NAME =  upper('%COLETA%') -- and owner='SYS'
order by 1;


-- RUNNING JOBS
    col owner for a20
    col elapsed_time for a20
    col cpu_used for a20
    col job_name for a50
    SELECT owner, job_name, session_id, running_instance, elapsed_time, cpu_used
    FROM dba_scheduler_running_jobs;




BEGIN
DBMS_SCHEDULER.RUN_JOB(
JOB_NAME            => 'SYS.COLETA_ESTATISTICAS',
USE_CURRENT_SESSION => FALSE);
END;
/

BEGIN
dbms_scheduler.STOP_JOB(job_name=>'SYS.COLETA_ESTATISTICAS' ,force=>true);
END;
/

col value for a50
col attribute_name for a30
select * from DBA_SCHEDULER_GLOBAL_ATTRIBUTE;

exec dbms_scheduler.set_scheduler_attribute('SCHEDULER_DISABLED','TRUE');

exec dbms_scheduler.set_scheduler_attribute('SCHEDULER_DISABLED','FALSE');

--Disable job.

exec dbms_scheduler.disable('SYS.COLETA_ESTATISTICAS');

exec dbms_scheduler.enable('SYS.COLETA_ESTATISTICA_PARCIAL');


-- jobs
 select OWNER, JOB_NAME, JOB_TYPE, JOB_ACTION, REPEAT_INTERVAL, LAST_START_DATE, ENABLED, state
 from dba_scheduler_jobs where -- owner not in ('SYS','SYSTEM')
 --and
  job_name like 'ORA%'
 --and LAST_START_DATE > sysdate -1
 --and repeat_interval like '%WEEKLY%';
 --and lower(job_action) like '%pkg_rep_exec%';
 /



exec DBMS_MVIEW.REFRESH('MV_ACT_REC_FILTER', method => 'C');



 select OWNER, JOB_NAME, JOB_TYPE, JOB_ACTION REPEAT_INTERVAL, LAST_START_DATE, ENABLED, state
 from dba_scheduler_jobs where job_name='JOB_MV_DEVICE_CONTEXT';


 alter system set optimizer_adaptive_plans=FALSE sid='*';

BEGIN
DBMS_SCHEDULER.DROP_JOB(
JOB_NAME            => 'SYS.COLETA_ESTATISTICAS');
END;
/


-- Maintenance windows
col  window_name for a30
col resource_plan for a30
col duration for a15
col repeat_interval for a40
col last_start_date for a40
col next_start_date for a40
col enabled for a5

select window_name, resource_plan, enabled, duration, repeat_interval, last_start_date, next_start_date 
from DBA_SCHEDULER_WINDOWS;

-- changing window
BEGIN
dbms_scheduler.set_attribute(
    name      => 'COLETA_STATS_PARCIAL',
    attribute => 'DURATION',
    value     => numtodsinterval(12, 'hour'));
end;
/

BEGIN
dbms_scheduler.set_attribute(
    name      => 'SYS.COLETA_ESTATISTICA_PARCIAL',
    attribute => 'repeat_interval',
    value => 'freq=daily;byday=mon,tue,wed,thu,fri;byhour=22;byminute=0;bysecond=0;');
end;
/


BEGIN
dbms_scheduler.set_attribute(
    name      => 'SYS.COLETA_STATS_PARCIAL',
    attribute => 'repeat_interval',
    value        =>  'freq=daily;byday=mon,tue,wed,thu,fri;byhour=22;byminute=30;bysecond=0;');
end;
/

BEGIN
  DBMS_SCHEDULER.SET_ATTRIBUTE (
   name         =>  'SYS.COLETA_ESTATISTICAS',
   attribute    =>  'repeat_interval',
   value        =>  'freq=daily;byday=fri;byhour=20;byminute=0;');
END;
/

-- create window
BEGIN
  dbms_scheduler.create_window(
    window_name => 'COLETA_STATS_PARCIAL',
    duration => numtodsinterval(4, 'hour'),
    resource_plan => 'DEFAULT_MAINTENANCE_PLAN',
    repeat_interval => 'freq=daily;byday=mon,tue,wed,thu,fri;byhour=1;byminute=0;bysecond=0;'
  );

  dbms_scheduler.add_window_group_member(
    group_name => 'MAINTENANCE_WINDOW_GROUP',
    window_list => 'COLETA_STATS_PARCIAL'
  );
END;
/

-- create job using window
begin
  dbms_scheduler.create_job (
    job_name => 'COLETA_ESTATISTICA_PARCIAL',
    job_type => 'STORED_PROCEDURE',
    job_action => 'coleta_stats_stale',
    schedule_name => 'COLETA_STATS_PARCIAL',
    enabled => TRUE
    );

  DBMS_SCHEDULER.SET_ATTRIBUTE(
    NAME => 'COLETA_ESTATISTICA_PARCIAL',
    ATTRIBUTE => 'STOP_ON_WINDOW_CLOSE',
    VALUE => TRUE
  );
END;
/


begin

    DBMS_SCHEDULER.CREATE_JOB (
         job_name           => 'Statspack_Hourly',
         job_type           => 'STORED_PROCEDURE',
         job_action         => 'STATSPACK.SNAP',
         start_date         => current_timestamp,
         repeat_interval    => 'FREQ=hourly;',
         enabled            => true);

end;
/