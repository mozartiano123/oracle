
set serveroutput on 

declare
cnt_prod number;
cnt_stg number;
i number;
pt varchar2(30);
q_prod varchar2(4000);
q_stg varchar2(4000);
t_name varchar2(30) := 'OVM_REQ_RES_INFO';
t_owner varchar2(30) := 'OVMARCH';
pn varchar2(30) := 'OVM_REQ_RES_INFO_P';
t_name_change varchar2(30) := '_OLD';
pmax number := 39;

begin

dbms_output.put_line('PROD table name:' || t_owner || '.' || t_name);
dbms_output.put_line('STG table name:' || t_owner || '.' || t_name || t_name_change );

i := 0;

FOR i in 1..pmax
LOOP

	pt := pn || i;

	q_prod := 'select /*+parallel(8)*/ count(*) from ' || t_owner || '.' || t_name || ' partition (' || pt || ')';

	q_stg := 'select /*+parallel(8)*/ count(*) from ' || t_owner || '.' || t_name || t_name_change || ' partition (' || pt || ')';
	
	EXECUTE IMMEDIATE q_prod INTO cnt_prod;
	
	EXECUTE IMMEDIATE q_stg INTO cnt_stg;
	
	dbms_output.put_line('PROD table count for partition P' || i || ' = ' || cnt_prod || '              and STG table count = ' || cnt_stg );
	
	--i := i+1;

END LOOP;


end;
/
