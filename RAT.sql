RAT.sql

Real Application Testing


-- find unwanted statements
select * from (
SELECT parsing_schema_name,SQL_ID, ELAPSED_TIME, FETCHES, EXECUTIONS,(ELAPSED_TIME/EXECUTIONS)/1000000 , sql_text
FROM   TABLE(DBMS_SQLTUNE.SELECT_SQLSET('STS_CHANGE_STATS'))
where lower(sql_text) like '%merge%' 
) 


-- remove the statements from the STS
select 
'BEGIN   DBMS_SQLTUNE.DELETE_SQLSET (      sqlset_name  => '||''''||'STS_CHANGE_STATS'||''''||',     basic_filter => '||''''||'sql_id='||''''''||
sql_id||''''''''||');END;'||chr(10)||'/'  
from (
select * from   (
select * from (
SELECT SQL_ID, ELAPSED_TIME, FETCHES, EXECUTIONS,(ELAPSED_TIME/EXECUTIONS)/1000000 , sql_text
FROM   TABLE(DBMS_SQLTUNE.SELECT_SQLSET('STS_CHANGE_STATS'))
where lower(sql_text) like 'merge%'
) order by ELAPSED_TIME/EXECUTIONS desc
) 
); 




-- drop

exec DBMS_SQLPA.DROP_ANALYSIS_TASK( task_name = 'STS_CHANGE_STATS_TASK');


--

select * from (
	SELECT
  first_load_time          ,
  executions as execs              ,
  parsing_schema_name      ,
  elapsed_time  / 1000000 as elapsed_time_secs  ,
  cpu_time / 1000000 as cpu_time_secs           ,
  buffer_gets              ,
  disk_reads               ,
  direct_writes            ,
  rows_processed           ,
  fetches                  ,
  optimizer_cost           ,
  sql_plan                ,
  plan_hash_value          ,
  sql_id                   ,
  sql_text
   FROM TABLE(DBMS_SQLTUNE.SELECT_SQLSET(sqlset_name => 'STS_CHANGE_STATS')
             )
   where sql_id='as466qtkazck8');
