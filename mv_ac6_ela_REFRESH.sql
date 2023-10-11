set timing on
set time on
set serverout on
alter session force parallel query parallel 4;
alter session force parallel dml parallel 4;

declare
v_show_date varchar2(100);

BEGIN
BEGIN
	
 TEP_LOGS.logit('TEP_AC6_ELA','FROM UNIX',null,'Starting.. : MV_AC6_ELA');
 
 DBMS_MVIEW.REFRESH('MV_AC6_ELA','C',NULL,TRUE,FALSE,0,4,0,FALSE);
 
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



SELECT SR.PTN
FROM CUSTOMER C,
SUBSCRIBER_RSOURCE SR
WHERE C.SEC_NOTIF_VALUE = SR.SUBSCRIBER_NO
AND C.CUSTOMER_ID       = '151192196'
AND C.SEC_NOTIF_METHOD  = 'S'   
/

SELECT 1 
FROM PHYSICAL_DEVICE PD, 
  SERIAL_ITEM_INV SII, 
  ITEM_DEFINITION ID, 
  SUBSCRIBER_RSOURCE SR 
WHERE ID.ITEM_ID        = SII.ITEM_ID 
AND SII.SERIAL_NUMBER   = PD.UNIT_ESN 
AND PD.EFFECTIVE_DATE  <= SYSDATE 
AND (PD.EXPIRATION_DATE > SYSDATE 
OR PD.EXPIRATION_DATE  IS NULL) 
AND PD.SW_STATE_IND     = 'Y' 
AND PD.SERIAL_TYPE      = 'E' 
AND SR.BAN              = PD.CUSTOMER_ID 
AND SR.SUBSCRIBER_NO    = PD.SUBSCRIBER_NO 
AND SR.PTN              = '6172335561'
AND ID.ITEM_ID_TYPE    IN ('SMRTPH', 'FTRPH')
/