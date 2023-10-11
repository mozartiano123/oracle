-- Create staging table.

exec DBMS_SQLTUNE.CREATE_STGTAB_SQLSET('STS_JFV_TAB','APPS');


-- create tuning set and get data from library cache for specific app MODULE only.

begin
DBMS_SQLTUNE.CREATE_SQLSET (sqlset_name => 'STS_JFV');
dbms_sqltune.capture_cursor_cache_sqlset(
sqlset_name => 'STS_JFV' , basic_filter=> q'# module like 'DWH_TEST%' and sql_text not like '%applicat%' and parsing_schema_name in ('APPS') #' ,
time_limit => 5*60,
repeat_interval => 5);
end ;
/
show errors


-- load tuning set to table.

exec DBMS_SQLTUNE.PACK_STGTAB_SQLSET('STS_JFV','SYS','STS_JFV_TAB','APPS');


-- import table on the destination database.

exec DBMS_SQLTUNE.UNPACK_STGTAB_SQLSET('STS_JFV','SYS',TRUE,'STS_JFV_TAB','APPS');


-- Exec SPA: (parameter change, optimizer features enabled)

declare 
sts_name VARCHAR2(30) := 'STS_JFV'; 
sts_owner VARCHAR2(30) := 'SYS'; 
task_name VARCHAR2(30) := 'SPA_JFV1'; 
task_desc VARCHAR2(256) := 'Execute SQLs'; 
execution_type VARCHAR2(30) := 'TEST EXECUTE'; 
persql_timelimit VARCHAR2(30):= NULL; 
compare_metric VARCHAR2(30) := 'ELAPSED_TIME'; 
param_name VARCHAR2(256) := 'optimizer_features_enable'; 
param_value1 VARCHAR2(32767) := '11.2.0.2'; 
param_value2 VARCHAR2(32767) := '12.1.0.1'; 
curval VARCHAR2(32767) := NULL; 
tname VARCHAR2(30) := task_name; 
ename1 VARCHAR2(30); 
ename2 VARCHAR2(30); 
ename3 VARCHAR2(30); 
edesc VARCHAR2(256); 
pvalue1 VARCHAR2(32767) := param_value1; 
pvalue2 VARCHAR2(32767) := param_value2; 
l_status VARCHAR2(30); 
begin 
	SELECT value INTO curval FROM v$parameter WHERE name = param_name; 
	pvalue1 := '''' || pvalue1 || ''''; pvalue2 := '''' || pvalue2 || ''''; 
	curval := '''' || curval || ''''; 
	dbms_sqlpa.set_analysis_task_parameter(tname, 'TIME_LIMIT', 'UNLIMITED'); 
	dbms_sqlpa.set_analysis_task_parameter(tname, 'LOCAL_TIME_LIMIT', persql_timelimit); 
	execute immediate 'alter session set ' || param_name || ' = ' || pvalue1; 
	edesc := 'parameter ' || param_name || ' set to ' || pvalue1; 
	ename1 := dbms_sqlpa.execute_analysis_task(task_name => tname, execution_type => execution_type, execution_name => 'INITIAL_SQL_TRIAL', 
		execution_desc => substr(edesc, 1, 256)); 
	select status into l_status from sys.dba_advisor_tasks where task_name = tname and owner = 'SYS'; 
	IF (l_status = 'COMPLETED') 
		THEN execute immediate 'alter session set ' || param_name || ' = ' || pvalue2; 
		edesc := 'parameter ' || param_name || ' set to ' || pvalue2; 
		ename1 := dbms_sqlpa.execute_analysis_task(task_name => tname, execution_type => execution_type, execution_name => 'SECOND_SQL_TRIAL', 
			execution_desc => substr(edesc, 1, 256)); 
	END IF; 
	select status into l_status from sys.dba_advisor_tasks where task_name = tname and owner = 'SYS'; 
	IF (l_status = 'COMPLETED') 
		THEN ename3 := dbms_sqlpa.execute_analysis_task(task_name => tname, execution_type => 'compare performance', 
			execution_params => dbms_advisor.argList( 'comparison_metric', compare_metric)); 
	END IF; 

	EXCEPTION 
		WHEN OTHERS THEN 
		IF (tname IS NOT NULL AND param_name IS NOT NULL AND curval IS NOT NULL) 
			THEN execute immediate 'alter session set ' || param_name || ' = ' || curval;
		END IF; 
	RAISE; 
end; 
