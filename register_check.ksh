#!/bin/ksh

## now loop through the above array
for i in "FE_TMR_INPUT_BLOCK" "FE_TMR_LOG" "ORDER_COMMENTS" "ORDER_LINE_SOC_FEATURES" "ORDER_STATUS_CHANGE_REASON" "TM_BOGX_SESSION_DATA"
do
   echo "-- $i" 
   echo " "
   s="_STG"
   orig_table=$i
   int_table=$i$s

## open sqlplus to run the code

sqlplus -s / as sysdba << EOF!
set serveroutput on
set feedback off


DECLARE

cursor ccons is
select b.owner owner, a.table_name orig_table, b.table_name int_table, a.constraint_name orig_cons, b.constraint_name int_cons, a.column_name col, a.position pos from 
(select cc.*, c.constraint_type 
from dba_cons_columns cc join dba_constraints c on (c.owner=cc.owner and c.constraint_name=cc.constraint_name)
where cc.table_name='$orig_table' and cc.owner='OEMADM' 
and c.constraint_type='C') a
join (
select cc.*, c.constraint_type 
from dba_cons_columns cc join dba_constraints c on (c.owner=cc.owner and c.constraint_name=cc.constraint_name)
where cc.table_name='$int_table' and cc.owner='OEMADM' 
and c.constraint_type='C') b
on (a.column_name=b.column_name)
order by a.constraint_name, a.position;

vcons ccons%rowtype;

BEGIN

for vcons in ccons loop
  dbms_output.put_line('BEGIN ');
  dbms_output.put_line('DBMS_REDEFINITION.REGISTER_DEPENDENT_OBJECT( ');
  dbms_output.put_line('uname => ''' || vcons.owner || ''', ');
  dbms_output.put_line('orig_table => ''' || vcons.orig_table || ''', ');
  dbms_output.put_line('int_table => ''' || vcons.int_table || ''', ');
  dbms_output.put_line('dep_type      => DBMS_REDEFINITION.CONS_CONSTRAINT, ');
  dbms_output.put_line('dep_owner      => ''' || vcons.owner || ''', ');
  dbms_output.put_line('dep_orig_name      => ''' || vcons.orig_cons || ''', ');
  dbms_output.put_line('dep_int_name      => ''' || vcons.int_cons || ''');');
  dbms_output.put_line('END;');
  dbms_output.put_line('/');
  dbms_output.put_line(chr(10));

end loop;

END;
/


EOF!

done

exit