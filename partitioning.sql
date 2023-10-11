partitioning.sql

-- set table to interval
alter table NGS.MANAGE_CART set interval(numtoYMinterval(1,'MONTH'));

-- create new partition in a range partitioning

alter table OVMARCH.OVM_REQ_RES_INFO ADD PARTITION OVM_REQ_RES_INFO_P40 
VALUES LESS THAN (TO_DATE(' 2017-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) tablespace NGS_DATA;




-- get high value.
	col TABLE_OWNER for a12
	select TABLE_OWNER, TABLE_NAME, PARTITION_NAME, HIGH_VALUE from dba_tab_partitions where table_name='SVR_ERROR_LOGS' and table_owner='OVMARCH'
	order by PARTITION_POSITION desc;


