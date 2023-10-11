--invalid objects


col object_name for a30
select owner, object_name, object_type, status, created, last_ddl_time
from dba_objects
where owner not like 'SYS%'
and status='INVALID'
--and object_name like '%CIQ%' or object_name like '%ACD%'
order by 5;


-- Partitioned tables
select table_owner, table_name, partition_name, high_value, tablespace_name
from dba_tab_partitions
where table_owner='CLW_P01_EPM' and table_name='AUDIT_LOG'
order by partition_position;

-- PARTITIONED INDEXES
select owner, index_name, table_name, locality, partition_count
from dba_part_indexes
where table_name='MANAGE_CART';

select * from DBA_PART_KEY_COLUMNS;
-- alter partitioned lob

alter table OVMARCH.OVM_REQ_RES_INFO move partition OVM_REQ_RES_INFO_P40
lob (REQ_RES_XML) store as securefile (TABLESPACE OVM_DATA CACHE LOGGING NOCOMPRESS);


-- add partition

alter table OVMARCH.OVM_REQ_RES_INFO ADD PARTITION OVM_REQ_RES_INFO_P51
VALUES LESS THAN (TO_DATE(' 2019-10-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) tablespace OVM_DATA
lob (REQ_RES_XML) store as securefile (TABLESPACE OVM_DATA CACHE LOGGING NOCOMPRESS);




-- INDEXCOLUMNS
col index_owner for a15
col column_name for a30
col table_name for a30
col table_owner for a15
col index_name for a30
select INDEX_OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, COLUMN_NAME, COLUMN_POSITION
from dba_ind_columns
where table_owner='SAPSR3'
and table_name='ANLA'
order by table_name, index_name, COLUMN_POSITION;


col column_name for a30
col table_name for a30
col index_name for a30
select INDEX_OWNER, INDEX_NAME, TABLE_OWNER, TABLE_NAME, COLUMN_NAME
from dba_ind_columns
where index_name='IX1_ORDER_GIVEBACK_DEVICE_INFO'
and index_owner='OEMADM'
order by index_name, column_position;

-- INDEX
select index_name, status, partitioned, visibility, UNIQUENESS
from dba_indexes
where index_name in ('CP_R034ADM','CHARGE_4IX','CHARGE_PK')
and owner = 'VETORH';


-- Index usage stats
SELECT Blevel, LEAF_BLOCKS, DISTINCT_KEYS, CLUSTERING_FACTOR
FROM DBA_INDEXES
WHERE index_name = 'PK_ANCESTOR';

-- Indexes of a table
col column_name for a30
select i.owner, index_name, c.column_name, i.table_name, i.uniqueness, i.status, i.last_analyzed, i.visibility
from dba_indexes i join dba_ind_columns c using(index_name)
where i.table_name='INVENTORY_TRANSACTION' and owner='DCSDBA'
order by index_name;


-- size index of a table
col segment_name for a50
select sum(bytes)/1048576 , segment_name, tablespace_name
from dba_segments where segment_name in
	(
    select  index_name
    from dba_indexes
	where table_name='XITOR'
	 --and owner='OEMADM'
	)
group by segment_name, tablespace_name
order by 1;


-- Segment size.
col segment_name for a30
select owner, segment_name, segment_type, sum(bytes)/1048576 as total_mb, count(*)
from dba_segments
where tablespace_name like '%ENC%'
--where segment_name in ('CHARGE_3IX','CHARGE_4IX','CHARGE_PK')
--and owner = 'NXTAPPONRT'
group by owner, segment_name, segment_type
order by total_mb;

-- constraints
col column_name for a30
col owner for a30
col table_name for a30
col constraint_name for a30
select * from dba_cons_columns where constraint_name='BILL';


col column_name for a20
col owner for a30
col table_name for a20
col constraint_name for a30
col constraint_type for a30
select cc.*, c.constraint_type, c.status, c.validated from dba_cons_columns cc join dba_constraints c 
on (c.owner=cc.owner and c.constraint_name=cc.constraint_name)
where cc.table_name='E000CIX' and cc.owner='SAPIENSPRD' order by cc.constraint_name, cc.position;

select constraint_name, constraint_type, index_name, DELETE_RULE,status, validated from dba_constraints where table_name='VAL_ADDRESS_INFO'
and owner='OEMADM' order by constraint_type, constraint_name;

select owner, table_name, constraint_name from dba_constraints where constraint_type='R' and r_constraint_name='FK_VAI_VAL_ADDR_INFO_ID';

select constraint_name, constraint_type, r_constraint_name from dba_constraints where constraint_type='R' and
table_name='S009' and owner='SAPSR3';


select constraint_name, constraint_type, r_constraint_name from dba_constraints where
constraint_name='FK_VAI_VAL_ADDR_INFO_ID' and owner='OEMADM';





-- use dbms metadata
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
   SELECT DBMS_METADATA.get_ddl ('CONSTRAINT', 'OVM_SERVICE_REQUEST_INFO_PK', 'OVMADM') from dual;
END;
/

SELECT DBMS_METADATA.get_ddl ('CONSTRAINT', 'OVM_SERVICE_REQUEST_INFO_PK', 'OVMADM') from dual;
FROM   all_constraints
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'))
AND    constraint_type IN ('U', 'P');

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON




-- BLOCKS


select
   segment_name,   segment_type from
   dba_extents
where   file_id = 16 and 716174 between block_id and (block_id + blocks - 1);


-- dba_segments


select distinct owner from (

select owner || ',' as owner , segment_name || ',' as name, segment_type || ',' as type, tablespace_name || ',' as tbs, sum(bytes)/1048576 as total_mb
from dba_segments
where owner not in ('DATAPOINT','SYS','SYSTEM','XDB','DBA_MAINTENANCE','DBTUNE','SYMANTEC_I3_ORCL','SYSREAD','OPS$ORACLE','PERFSTAT',
'HEALTHCHECK_DBA','DATAPOINT_AUDIT','DATAPOINT_EM','DBSNMP','NXTAPPO','NXTREFWAITSNPEDM','OPT_STATS','ORABACK','ORAMAINT','OUTLN')
group by owner, segment_name, segment_type, tablespace_name
order by owner, segment_type;

);

