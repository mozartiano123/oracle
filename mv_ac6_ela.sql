set timing on
set time on
set serverout on
declare
v_show_date varchar2(100);
BEGIN
BEGIN
--DBMS_MVIEW.REFRESH('MV_AC6_ELA','C',NULL,TRUE,FALSE,0,0,0,FALSE);


 TEP_LOGS.logit('TEP_AC6_ELA','FROM UNIX',null,'Starting.. : MV_AC6_ELA');
 DBMS_MVIEW.REFRESH('MV_AC6_ELA','C',NULL,TRUE,FALSE,0,0,0,FALSE);
 dbms_output.put_line('Done Working on : MV_AC6_ELA');
 TEP_LOGS.logit('TEP_AC6_ELA','FROM UNIX',null,'End.. : MV_AC6_ELA');

 TEP_LOGS.logit('TEP_AC6_ELA','FROM UNIX',null,'Starting.. : Load Web');
         web_ela.run_report;
 TEP_LOGS.logit('TEP_AC6_ELA','FROM UNIX',null,'End.. : Load Web');

dbms_output.put_line('Ela success ');
tep_mail_utils.send_notify_html('Ela Mtl View complete refresh done ', 'Ela Mtl View complete refresh done');
end;

select to_char(sysdate,'dd-mon-yyyy hh24:mi:ss') into v_show_date from dual;
dbms_output.put_line(' When exited '|| v_show_date);
END;
/
