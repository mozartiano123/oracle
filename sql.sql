-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/sql_area.sql
-- Author       : Tim Hall
-- Description  : Displays the SQL statements for currently running processes.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sql_area
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
--SET FEEDBACK OFF

SELECT s.sid,
       s.status "Status",
       p.spid "Process",
       s.schemaname "Schema Name",
       s.osuser "OS User",
       Substr(a.sql_text,1,120) "SQL Text",
       s.program "Program"
FROM   v$session s,
       v$sqlarea a,
       v$process p
WHERE  s.sql_hash_value = a.hash_value (+)
AND    s.sql_address    = a.address (+)
AND    s.paddr          = p.addr
AND    s.Status         = 'ACTIVE'
AND    s.sid  			=&1
/


------------ Heavy sqls

select V$SQL_PLAN_STATISTICS_ALL."COST" as custo,
       trunc(ROUND ( ( ((v$sqlarea.elapsed_time) / 1000000) / 60), 2)/decode(v$sqlarea.executions,0,1,v$sqlarea.executions),10) AS "Tempo medio de CPU",
       v$sqlarea.executions AS "Quant. exec.",
       v$sqlarea.rows_processed AS "Quant. linhas proc.",
       v$sqlarea.disk_reads AS "Leituras no disco",
       v$sqlarea.first_load_time AS "Primeira utilização",
       to_char(v$sqlarea.last_load_time,'dd/mm/yyyy') AS "Última utilização",
       v$sqlarea.parsing_schema_name AS "Usuário analisado",
       v$sqlarea.SQL_FULLTEXT,
       V$SQLAREA.MODULE
FROM v$sqlarea INNER JOIN V$SQL_PLAN_STATISTICS_ALL ON V$SQL_PLAN_STATISTICS_ALL.SQL_ID = v$sqlarea.SQL_ID
where v$sqlarea.parsing_schema_name NOT IN ('SYS', 'SYSTEM', 'SYSMAN', 'DBSNMP')
  and V$SQL_PLAN_STATISTICS_ALL."COST" >=20000
  AND TRUNC(v$sqlarea.last_load_time)>=TRUNC(SYSDATE)
  AND (UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%ALL_CONSTRAINTS%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%ALL_IND_COLUMNS%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%ALL_INDEXES%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%USER_TABLES%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%V$PARAMETER%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%USER_SEQUENCES%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%ALL_OBJECTS%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%GV$SESSION%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%V$PARAMETER%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%MDS_SESSION_INFO%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%/*+ INDEX%'
  AND UPPER(v$sqlarea.SQL_FULLTEXT) NOT LIKE '%ALL_TRIGGERS%')
  order by 1 desc

-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/sql_text.sql
-- Author       : Tim Hall
-- Description  : Displays the SQL statement held at the specified address.
-- Comments     : The address can be found using v$session or Top_SQL.sql.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sql_text (address)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET FEEDBACK OFF
SET VERIFY OFF

SELECT a.sql_text
FROM   v$sqltext_with_newlines a
WHERE  a.address = UPPER('&&1')
ORDER BY a.piece;


-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/top_sql.sql
-- Author       : Tim Hall
-- Description  : Displays a list of SQL statements that are using the most resources.
-- Comments     : The address column can be use as a parameter with SQL_Text.sql to display the full statement.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @top_sql (number)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT *
FROM   (SELECT Substr(a.sql_text,1,50) sql_text,
               Trunc(a.disk_reads/Decode(a.executions,0,1,a.executions)) reads_per_execution,
               a.sql_id,
               a.buffer_gets,
               a.disk_reads,
               a.executions,
               a.sorts,
               a.address
        FROM   v$sqlarea a
        ORDER BY 2 DESC)
WHERE  rownum <= &1
/

SET PAGESIZE 14


-- LONG RUNNING

col first_load_time for a20
col last_load_time for a20

select sql_id, first_load_time, last_load_time, elapsed_time, elapsed_time/executions/1000000 avg_elapsed, cpu_time/executions avg_cpu
from gv$sql where sql_id='9ffq3z15q8kzj';


-- get the DB TIME.
select
   maxval,
   minval,
   average,
   standard_deviation
from
   v$sysmetric_summary
where
   metric_name = 'Database Time Per Sec';



-- displays elapsed time for specific sql.

select sql_id, elapsed_time , EXECUTIONS from  v$sql where sql_id='f7mak70cmg0qf';

-- sql text

select sql_fulltext from gv$sql where sql_id='f7mak70cmg0qf';
select sql_text from dba_hist_sqltext where sql_id='f7mak70cmg0qf';

select sql_id, sql_text from gv$sql where upper(sql_text) like '%FROM%X07_BASE_DOCFIS%';


-- Check plans

SELECT * FROM TABLE(dbms_xplan.display_awr('a0r47t69cymbn'));
SELECT * FROM TABLE(dbms_xplan.display_awr('c6mbuvkb6hu2x'));


SELECT * FROM TABLE(dbms_xplan.display_awr('3bwag4vqygtpp','2402304860'));



select plan_table_output from table(dbms_xplan.display_cursor('8rcn1cfwvkfbx',null,'305413586'));
select plan_table_output from table(dbms_xplan.display_cursor('c6mbuvkb6hu2x'));

select * from table(dbms_xplan.display_cursor('6mbuvkb6hu2x',null,'ALLSTATS LAST +PEEKED_BINDS +PARTITION'));

select SQL_ID, CHILD_NUMBER, NAME, POSITION, DATATYPE, VALUE_ANYDATA from v$sql_bind_capture where sql_id='4kahmu9pf5g2g';

select  s.BEGIN_INTERVAL_TIME, ss.SQL_ID, ss.CPU_TIME_TOTAL
from dba_hist_sqlstat ss join dba_hist_snapshot s using(snap_id)
where ss.sql_id='8gfzwnh7km932'
/

-- plan stored in the shared pool
 select ADDRESS, HASH_VALUE from gV$SQLAREA where SQL_ID = 'c6mbuvkb6hu2x';


-- explain plan

explain plan set statement_id='sql1' for SELECT ...

SELECT PLAN_TABLE_OUTPUT FROM TABLE(DBMS_XPLAN.DISPLAY());

SELECT plan_table_output FROM TABLE(dbms_xplan.display('plan_table','sql1','serial'));

@?/rdbms/admin/utlxpls.sql



sqlplus -s /@mmpp101_su<<END

set timing on
set feedback on
set echo on
set serveroutput on

spool /replace_with_dirname/replace_with_filename/log.lst
exec p_insert_dim_subscriber;

spool off

exit;

-- SQL EXEC TIME

select inst_id,sql_id,plan_hash_value,CHILD_NUMBER,executions,round(elapsed_time/executions/1000000,3) time_per_exec,
round(buffer_gets/executions) buff_per_exec,
       round(disk_reads/executions) disk_r_per_exec
  from gv$sql where sql_id='&SQL'
  order by 1;


-- HIST shows historic information on a SQLID


    col elapsed_per_exec format 999999999.00
    col ELAPSED_PER_EXEC_MIN format 999.000000000
    col startup_time for a30
    col ELAPSED_TIME_TOTAL format 99999999999
    col snap_end_time for a27
    col snap_start_time for a27
    set pages 999 lines 200
    select --a.DBID,
           a.instance_number as inst_id, --c.STARTUP_TIME,
           c.BEGIN_INTERVAL_TIME as snap_start_time, c.END_INTERVAL_TIME as snap_end_time,
           a.sql_id, a.PLAN_HASH_VALUE,
           a.executions_total, (a.ELAPSED_TIME_TOTAL/1000000)/360 total_min --, b.executions_total, b.ELAPSED_TIME_TOTAL
           , (((a.ELAPSED_TIME_TOTAL - nvl (b.ELAPSED_TIME_TOTAL,0))/1000000)/(a.executions_total - nvl(b.executions_total, 0)))/360 elapsed_per_exec_min
    from dba_hist_sqlstat a,
         dba_hist_sqlstat b,
       DBA_HIST_SNAPSHOT C
        where a.sql_id = '077kztbgfa4f6'
        --where a.sql_id = '3bgwb8bnktvh'
    and a.DBID = b.dbid (+)
    and a.instance_number = b.instance_number (+)
    and a.snap_id = b.snap_id (+) - 1
    and a.sql_id = b.sql_id (+)
    and a.PLAN_HASH_VALUE = b.PLAN_HASH_VALUE (+)
    and a.executions_total - nvl (b.executions_total,0) > 0
    AND A.SNAP_ID = C.SNAP_ID (+) - 1
    AND a.DBID = c.dbid (+)
    AND a.instance_number = c.instance_number (+)
    order by snap_start_time;


-- HIST shows historic information on a SQLID


  col elapsed_per_exec format 999999999.00
  col ELAPSED_PER_EXEC_MIN format 999.000000000
  col startup_time for a30
  col ELAPSED_TIME_delta format 99999999999
  col snap_end_time for a27
  col snap_start_time for a27
  set pages 999 lines 200
  select --a.DBID,
        -- a.instance_number as inst_id, --c.STARTUP_TIME,
         c.BEGIN_INTERVAL_TIME as snap_start_time, c.END_INTERVAL_TIME as snap_end_time,
         a.sql_id, a.PLAN_HASH_VALUE,
         a.executions_delta--, (a.ELAPSED_TIME_delta/1000000)/360 delta_min , b.executions_delta, b.ELAPSED_TIME_delta
         , (((a.ELAPSED_TIME_delta - nvl (b.ELAPSED_TIME_delta,0))/1000000)/(a.executions_delta - nvl(b.executions_delta, 0)))/360 elapsed_per_exec_min
  from dba_hist_sqlstat a,
       dba_hist_sqlstat b,
     DBA_HIST_SNAPSHOT C
       where a.sql_id = '0vpcg177rbu1g'
  and a.DBID = b.dbid (+)
  and a.instance_number = b.instance_number (+)
  and a.snap_id = b.snap_id (+) - 1
  and a.sql_id = b.sql_id (+)
  and a.PLAN_HASH_VALUE = b.PLAN_HASH_VALUE (+)
  and a.executions_delta - nvl (b.executions_delta,0) > 0
  AND A.SNAP_ID = C.SNAP_ID (+) - 1
  AND a.DBID = c.dbid (+)
  AND a.instance_number = c.instance_number (+)
  order by snap_start_time;




----- ASH SQL events

  col time for a17
  col time for a20
  col event for a40
  set lines 170 pages 500
  break on time
  select to_char(sample_time, 'dd-mon-yyyy hh24:mi') time, event, count(1) qty, count(1)*100/sum(count(1)) over() pctload
    from gv$active_session_history
    --where sample_time > sysdate - 3/24
    --where sample_time between to_date('04-Dec-2017 07:00','dd-mon-yyyy hh24:mi:ss') and to_date('04-Dec-2017 22:20','dd-mon-yyyy hh24:mi:ss')
    --and session_id = :B1
    where sql_id='16wn7utcs0bjv'
    and sample_time between sysdate-1/24 and sysdate
     group by to_char(sample_time, 'dd-mon-yyyy hh24:mi'), event
    order by 1,3 desc ;



select sid,sql_id, status, SQL_EXEC_START, trunc(elapsed_time/1000000) as elapsed,
trunc(cpu_time/1000000) as cpu, QUEUING_TIME, BUFFER_GETS,
DISK_READS,
--PHYSICAL_READ_REQUESTS read_req,
--PHYSICAL_READ_BYTES reads,
--PHYSICAL_WRITE_REQUESTS write_req,
PHYSICAL_WRITE_BYTES writes,
--DIRECT_WRITES,
--trunc(CONCURRENCY_WAIT_TIME/1000000) as concur,
trunc(USER_IO_WAIT_TIME/1000000) as io_wait
from gv$sql_monitor where sql_id='95a0h2910ngdh'
order by SQL_EXEC_START;



select distinct s.username,s.last_call_et,sql_id,count(*), sql.sql_text
from gv$session s join gv$sql sql using (sql_id)
where  username is not null and status='ACTIVE'
group by s.username,s.last_call_et,sql_id , sql.sql_text
having s.last_call_et > 0
order by 2 desc;



==============================================
FORCE PLAN HASHVALUE
==============================================
========
Step1 (only sql_id)
========
col elapsed_per_exec format 999999999.00
col snap_end_time for a27
set pages 999 lines 194
select a.DBID, a.instance_number as inst_id, a.snap_id, c.END_INTERVAL_TIME as snap_end_time, a.sql_id, a.PLAN_HASH_VALUE,
       a.executions_total, a.ELAPSED_TIME_TOTAL/1000000 as elapsed_time_exec, b.executions_total, b.ELAPSED_TIME_TOTAL/1000000 as elapsed_time
       , (((a.ELAPSED_TIME_TOTAL - nvl (b.ELAPSED_TIME_TOTAL,0))/1000000)/(a.executions_total - nvl(b.executions_total, 0))) elapsed_per_exec
from dba_hist_sqlstat a,
     dba_hist_sqlstat b,
                DBA_HIST_SNAPSHOT C
where a.sql_id = '&1'
and a.DBID = b.dbid (+)
and a.instance_number = b.instance_number (+)
and a.snap_id = b.snap_id (+) - 1
and a.sql_id = b.sql_id (+)
and a.PLAN_HASH_VALUE = b.PLAN_HASH_VALUE (+)
and a.executions_total - nvl (b.executions_total,0) > 0
AND A.SNAP_ID = C.SNAP_ID (+) - 1
AND a.DBID = c.dbid (+)
AND a.instance_number = c.instance_number (+)
order by snap_id;


========
Step2 (only sql_id & plan_hash_value)
========
select extractvalue(value(d), '/hint') as outline_hints
from xmltable('/*/outline_data/hint'
passing (
   select xmltype(other_xml) as xmlval
   from DBA_HIST_SQL_PLAN
    where sql_id = '0vpcg177rbu1g' and plan_hash_value = '3427850421' and rownum=1 and other_xml is not null)) d;

========
Step3 (only sql_id & plan_hash_value)
========
-- create the profile with the plan details
declare
  ar_profile_hints sys.sqlprof_attr;
  cl_sql_text clob;
begin
 select extractvalue(value(d), '/hint') as outline_hints bulk collect into ar_profile_hints
   from
         xmltable('/*/outline_data/hint' passing ( select xmltype(other_xml) as xmlval
      from
       DBA_HIST_SQL_PLAN
      where
       sql_id = '0vpcg177rbu1g' and plan_hash_value = '3427850421' and rownum=1
      and    other_xml is not null)) d;

   select
   sql_text
-- sql_fulltext if using v$sql
   into
   cl_sql_text
   from
   -- replace with dba_hist_sqltext
   -- if required for AWR based
   -- execution
   -- v$sql
   sys.dba_hist_sqltext
   where
   sql_id = '0vpcg177rbu1g' and rownum=1;

   dbms_sqltune.import_sql_profile(
   sql_text    => cl_sql_text
   , profile     => ar_profile_hints
   , category    => 'DEFAULT'
   , name      => 'SQL_CR001000262_SVIP101'
   , force_match =>true
   );
end;
/
=========================
END OF STEP3
=========================


-- DROP PROFILE

BEGIN
  DBMS_SQLTUNE.DROP_SQL_PROFILE (
    name => 'SYS_SQLPROF_0179b5320b020000'
);
END;
/

--LIST PROFILES
COLUMN name FORMAT a30
COLUMN category FORMAT a10
COLUMN sql_text FORMAT a20

SELECT NAME, SQL_TEXT, CATEGORY, STATUS, CREATED
FROM   DBA_SQL_PROFILES order by created;

select distinct
p.name sql_profile_name,
s.sql_id
from
dba_sql_profiles p,
DBA_HIST_SQLSTAT s
where
p.name=s.sql_profile;


-- PLAN HASH value
select extractvalue(value(d), '/hint') as outline_hints
bulk collect
into
ar_profile_hints
from
xmltable('/*/outline_data/hint'
passing (
select
xmltype(other_xml) as xmlval
from
DBA_HIST_SQL_PLAN
where
sql_id = 'cssgphkkggbmn' and plan_hash_value = '3721027399'
and other_xml is not null)) d;




select sql_id, EXECUTIONS_TOTAL as execs, ELAPSED_TIME_TOTAL/1000000 as runseconds, ROWS_PROCESSED_TOTAL as rows_returned, FETCHES_TOTAL,
CPU_TIME_TOTAL, BUFFER_GETS_TOTAL as buffer_gets, PHYSICAL_READ_REQUESTS_TOTAL dread_reqs, DISK_READS_TOTAL dreads,
IOWAIT_TOTAL, SORTS_TOTAL, IO_INTERCONNECT_BYTES_TOTAL/1048576 inet_mb
from dba_hist_sqlstat
where sql_id in ('fy4ztbyshzhhb')
order by sql_id
/





##### Criar o sqlset

exec dbms_sqltune.create_sqlset(sqlset_name => '0vpcg177rbu1g_sqlset',description => 'sqlset descriptions');

##### fazer o load dele com os snaps id e sql id (não usar snaps muito antigos nem muito novos)
## from AWR:
declare
baseline_ref_cur DBMS_SQLTUNE.SQLSET_CURSOR;
begin
  open baseline_ref_cur for
    select VALUE(p) from table(DBMS_SQLTUNE.SELECT_WORKLOAD_REPOSITORY(&begin_snap_id, &end_snap_id,'sql_id='||CHR(39)||'&sql_id'||CHR(39)||' and plan_hash_value=2218079956',NULL,NULL,NULL,NULL,NULL,NULL,'ALL')) p;
    DBMS_SQLTUNE.LOAD_SQLSET('0vpcg177rbu1g_sqlset', baseline_ref_cur);
end;
/
## from cursor
declare
  baseline_ref_cur DBMS_SQLTUNE.SQLSET_CURSOR;
BEGIN
  OPEN l_cursor FOR
    SELECT VALUE(a) FROM TABLE(DBMS_SQLTUNE.select_cursor_cache(basic_filter=>'sql_id=&SQL_ID and plan_hash_value=&PHV',attribute_list => 'ALL')) a;
    DBMS_SQLTUNE.load_sqlset(sqlset_name=>'0vpcg177rbu1g_sqlset',populate_cursor=>l_cursor);
  end loop;
END;

##### checar se o sqlset foi de fato criado
SELECT NAME,OWNER,CREATED,STATEMENT_COUNT FROM DBA_SQLSET where name='0vpcg177rbu1g_sqlset';

##### veja se o hash plan desejado ja aparece
select * from table(dbms_xplan.display_sqlset('0vpcg177rbu1g_sqlset','0vpcg177rbu1g'));

##### faça o load do sqlset na baseline
set serveroutput on
declare
  my_int pls_integer;
begin
  my_int := dbms_spm.load_plans_from_sqlset (
  sqlset_name => '0vpcg177rbu1g_sqlset',
  basic_filter => 'sql_id=''0vpcg177rbu1g'' and plan_hash_value = 244338963',
  sqlset_owner => 'SYS',
  fixed => 'YES',
  enabled => 'YES');
  DBMS_OUTPUT.PUT_line(my_int);
end;
/

##### checar se a baseline está de acordo com o load
col last_executed for a30
col module for a40
SELECT SQL_HANDLE, PLAN_NAME, CREATED, ORIGIN, ENABLED, ACCEPTED, FIXED, LAST_EXECUTED, EXECUTIONS FROM DBA_SQL_PLAN_BASELINES
order by last_executed;

##### caso você queira dropar o sqlset
BEGIN
  DBMS_SQLTUNE.DROP_SQLSET( sqlset_name => '0vpcg177rbu1g_sqlset' );
END;
/

SQL_PLAN_b9cpcvky97mvhcfc13db1

-- SQL writing lots of rows
col sql_text for a50
select sql_id, executions, rows_processed, sql_text
  from v$sql
  where rows_processed > 10000
  and not regexp_like(upper(sql_text),'^.*SELECT.*')
  and parsing_user_id != 0               -- to ignore SYS
  and command_type != 47                 -- to ignore PL/SQL
  order by rows_processed;





  -- TUNING advisor
set serveroutput on

DECLARE
  l_sql_tune_task_id VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
  sql_id => 'a0r47t69cymbn',
  scope => DBMS_SQLTUNE.scope_comprehensive,
  time_limit => 3600,
  task_name => 'a0r47t69cymbn_tuning_task11',
  description => 'Tuning task1 for statement a0r47t69cymbn');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/


EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => 'a0r47t69cymbn_tuning_task11');

set long 99999
set longchunksize 65536
set linesize 100
select dbms_sqltune.report_tuning_task('a0r47t69cymbn_tuning_task11') from dual;

execute dbms_sqltune.accept_sql_profile(task_name =>'a0r47t69cymbn_tuning_task11', task_owner => 'SYS', replace =>TRUE);

 execute dbms_sqltune.accept_sql_profile(task_name =>'a0r47t69cymbn_tuning_task11', task_owner => 'SYS', replace =>TRUE);

execute dbms_sqltune.accept_sql_profile(task_name =>'0vpcg177rbu1g_tuning_task111', task_owner => 'SYS', replace =>TRUE);



execute dbms_sqltune.accept_sql_profile(task_name =>'0vpcg177rbu1g_tuning_task111', task_owner => 'SYS', replace =>TRUE);


SET LINES 1000
SET PAGES 1000
COLUMN I FORMAT A3
col object_name for a30
col operation for a50


--SQL PLAN HASH VALUE

  SELECT /*+ NO_MERGE */ 
         ROWNUM-1||
   DECODE(access_predicates,NULL,DECODE(filter_predicates,NULL,'','*'),'*') "I",
         SUBSTR(LPAD(' ',(DEPTH-1))||
   OPERATION,1,40)||
   DECODE(OPTIONS,NULL,'',' (' 
   || OPTIONS 
   || ')') "Operation",
         SUBSTR(OBJECT_NAME,1,30) "Object_Name",
         cardinality "# Rows",
         bytes,
         cost,
         time
    FROM (
         SELECT * 
           FROM gv$sql_plan 
          WHERE sql_id = ('gdt76qbt6kb57')
          and PLAN_HASH_VALUE = '2976397408'
         ) plan
ORDER BY id
/