set lines 300
select local_tran_id,OS_USER,DB_USER, state, fail_time, db_user from dba_2pc_pending;

Select 'exec DBMS_TRANSACTION.rollback_force('''|| LOCAL_TRAN_ID || ''');' || 'commit;' from dba_2pc_pending;

Select 'execute dbms_transaction.purge_lost_db_entry('''|| LOCAL_TRAN_ID || ''');' || 'commit;' from dba_2pc_pending;

--purge
exec DBMS_TRANSACTION.rollback_force('9.20.4459658');
exec dbms_transaction.purge_lost_db_entry('9.20.4459658');

commit; 