--SQL TUNING ADVISOR

-- create task
DECLARE
  l_sql_tune_task_id  VARCHAR2(100);
BEGIN
  l_sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
                          sql_id      => 'bz12yzypmh7zs',
                          scope       => DBMS_SQLTUNE.scope_comprehensive,
                          time_limit  => 500,
                          task_name   => 'bz12yzypmh7zs_Tune',
                          description => 'Tuning task1 for statement bz12yzypmh7zs');
  DBMS_OUTPUT.put_line('l_sql_tune_task_id: ' || l_sql_tune_task_id);
END;
/

-- query status of the task
COL TASK_ID FORMAT 999999
COL TASK_NAME FORMAT a25
COL STATUS_MESSAGE FORMAT a33

SELECT TASK_ID, TASK_NAME, STATUS, STATUS_MESSAGE
FROM   DBA_ADVISOR_LOG;


-- EXEC

BEGIN
  DBMS_SQLTUNE.EXECUTE_TUNING_TASK(task_name=>'bz12yzypmh7zs_Tune');
END;
/

-- query status

COL TASK_ID FORMAT 999999
COL TASK_NAME FORMAT a25
COL STATUS_MESSAGE FORMAT a33

SELECT TASK_ID, TASK_NAME, STATUS, STATUS_MESSAGE
FROM   DBA_ADVISOR_LOG;


-- Monitor status

SELECT STATUS 
FROM   USER_ADVISOR_TASKS
WHERE  TASK_NAME = 'bz12yzypmh7zs_Tune';


-- VIEW status

SET LONG 1000
SET LONGCHUNKSIZE 1000
SET LINESIZE 100
SELECT DBMS_SQLTUNE.REPORT_TUNING_TASK( 'bz12yzypmh7zs_Tune' )
FROM   DUAL;


-- drop task

execute dbms_sqltune.drop_tuning_task('bz12yzypmh7zs_Tune');
 
