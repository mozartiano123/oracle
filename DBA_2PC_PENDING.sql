-- DBA_2PC_PENDING

--query
col host for a30
col os_user for a15
col os_terminal for a15
set lines 160
select DB_USER,HOST,OS_USER,OS_TERMINAL,STATE,LOCAL_TRAN_ID from DBA_2PC_PENDING;

--procedure
ROLLBACK FORCE '4.23.3528649';

execute dbms_transaction.purge_lost_db_entry('4.23.3528649');
COMMIT;

-- BA_2PC_PENDING - outher

Select local_tran_id,global_tran_id,state,fail_time,force_time
from dba_2pc_pending;

select local_tran_id,in_out,database,dbuser_owner from dba_2pc_neighbors;

select 'exec dbms_transaction.purge_lost_db_entry('''||local_tran_id||''' )' , 'commit;' from dba_2pc_pending ;


============================