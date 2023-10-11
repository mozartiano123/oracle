How to rebuild syxaux


-- get details on sysaux occupancy

set lines 112
set pages 10000

col TSname heading 'TSpace|Name|||'
col TSname format a25
col TSstatus heading 'TSpace|Status|||'
col TSstatus format a9
col TSSizeMb heading 'TSpace|Size|Mb||'
col TSSizeMb format 999999
col TSUsedMb heading 'TSpace|Used|Space|Mb|'
col TSUsedMb format 999999
col TSFreeMb heading 'TSpace|Free|Space|Mb|'
col TSFreeMb format 999999
col TSUsedPrct heading 'TSpace|Used|Space|%|'
col TSUsedPrct format 999999
col TSFreePrct heading 'TSpace|Free|Space|%|'
col TSFreePrct format 999999
col TSSegUsedMb heading 'TSpace|Segmt|Space|Mb|'
col TSSegUsedMb format 999999
col TSExtUsedMb heading 'TSpace|Extent|Space|Mb|'
col TSExtUsedMb format 999999
col AutoExtFile heading 'Auto|Extend|File|?|'
col AutoExtFile format a6
col TSMaxSizeMb heading 'TSpace|MaxSize|Mb||'
col TSMaxSizeMb format a6
col TSMaxUsedPrct heading 'TSpace|Maxed|Used|Space|%'
col TSMaxUsedPrct format a6
col TSMaxFreePrct heading 'TSpace|Maxed|Free|Space|%'
col TSMaxFreePrct format a6

WITH
  ts_total_space AS (SELECT
                       TableSpace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks,
                       SUM(maxbytes) as maxbytes
                     FROM dba_data_files
                     GROUP BY TableSpace_name),
  ts_free_space AS (SELECT
                      ddf.TableSpace_name,
                      NVL(SUM(dfs.bytes),0) as bytes,
                      NVL(SUM(dfs.blocks),0) as blocks
                    FROM
                      dba_data_files ddf,
                      dba_free_space dfs
                    WHERE ddf.file_id = dfs.file_id(+)
                    GROUP BY ddf.TableSpace_name),
  ts_total_segments AS (SELECT
                          TableSpace_name,
                          SUM(bytes) as bytes,
                          SUM(blocks) as blocks
                        FROM dba_segments
                        GROUP BY TableSpace_name),
ts_total_extents AS (SELECT
                       TableSpace_name,
                       SUM(bytes) as bytes,
                       SUM(blocks) as blocks
                     FROM dba_extents
                     GROUP BY TableSpace_name)
SELECT
  dt.TableSpace_name as "TSname",
  dt.status as "TSstatus",
  ROUND(ttsp.bytes/1024/1024,0) as "TSSizeMb",
  ROUND((ttsp.bytes-tfs.bytes)/1024/1024,0) as "TSUsedMb",
  ROUND(tfs.bytes/1024/1024,0) as "TSFreeMb",
  ROUND((ttsp.bytes-tfs.bytes)/ttsp.bytes*100,0) as "TSUsedPrct",
  ROUND(tfs.bytes/ttsp.bytes*100,0) as "TSFreePrct",
  ROUND(ttse.bytes/1024/1024,0) as "TSSegUsedMb",
  ROUND(tte.bytes/1024/1024,0) as "TSExtUsedMb",
  CASE
    WHEN ttsp.maxbytes = 0 THEN 'No' ELSE 'Yes'
  END as "AutoExtFile",
  CASE
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND(ttsp.maxbytes/1024/1024,0))
  END as "TSMaxSizeMb",
  CASE
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.bytes-tfs.bytes)/ttsp.maxbytes*100,0))
  END as "TSMaxUsedPrct",
  CASE
    WHEN ttsp.maxbytes = 0 THEN '-' ELSE TO_CHAR(ROUND((ttsp.maxbytes-(ttsp.bytes-tfs.bytes))/ttsp.maxbytes*100,0))
  END as "TSMaxFreePrct"
FROM
  dba_TableSpaces dt,
  ts_total_space ttsp,
  ts_free_space tfs,
  ts_total_segments ttse,
  ts_total_extents tte
WHERE dt.TableSpace_name = ttsp.TableSpace_name(+)
AND dt.TableSpace_name = tfs.TableSpace_name(+)
AND dt.TableSpace_name = ttse.TableSpace_name(+)
AND dt.TableSpace_name = tte.TableSpace_name(+)
AND dt.TableSpace_name = 'SYSAUX'
;


-- get details on big tables and indexes

set lines 130
set pages 10000

col SgmntSize heading 'Sgmnt|Size|Mb'
col SgmntSize format 99999
col TSname heading 'TSpace|Name|'
col TSname format a25
col SgmntOwner heading 'Sgmnt|Owner|'
col SgmntOwner format a15
col SgmntName heading 'Sgmnt|Name|'
col SgmntName format a35
col SgmntType heading 'Sgmnt|Type|'
col SgmntType format a5

SELECT
  ROUND(SUM(ds.bytes)/1024/1024,0) as "SgmntSize",
  ds.TableSpace_name as "TSname",
  ds.owner as "SgmntOwner",
  ds.segment_name as "SgmntName",
  ds.segment_type as "SgmntType"
FROM dba_segments ds
WHERE ds.segment_type IN ('TABLE','INDEX')
AND TableSpace_name = 'SYSAUX'
GROUP BY
  ds.TableSpace_name,
  ds.owner,
  ds.segment_name,
  ds.segment_type
ORDER BY "SgmntSize" ;





WRH$_RSRC_CONSUMER_GROUP_PK         INDEX
WRM$_SNAPSHOT_DETAILS_INDEX         INDEX
WRH$_SQL_BIND_METADATA_PK           INDEX
WRH$_MUTEX_SLEEP_PK                 INDEX
WRH$_ENQUEUE_STAT_PK                INDEX
WRH$_SYSMETRIC_SUMMARY_INDEX        INDEX
WRH$_SQL_PLAN_PK                    INDEX
WRH$_BG_EVENT_SUMMARY_PK            INDEX
 



set lin 200 pages 999
set echo on tim on feedback on timing on feedback on
alter session set ddl_lock_timeout=10;
spool move_sysaux.log

alter table SYS.WRH$_SQL_PLAN move tablespace SYSAUX_TEMP parallel 8;
alter table SYS.WRH$_SQL_PLAN move tablespace SYSAUX parallel 8;

alter index WRH$_SQL_PLAN_PK rebuild parallel 8;
alter index WRH$_SQL_PLAN_PK noparallel;

ALTER TABLE SYS.WRH$_SQL_PLAN MOVE LOB(OTHER_XML) STORE AS (TABLESPACE SYSAUX_TEMP);
ALTER TABLE SYS.WRH$_SQL_PLAN MOVE LOB(OTHER_XML) STORE AS (TABLESPACE SYSAUX);

alter table SYS.WRH$_SQL_BIND_METADATA   move tablespace SYSAUX_TEMP parallel 8;
alter table SYS.WRH$_SQL_BIND_METADATA   move tablespace SYSAUX parallel 8;

alter index WRH$_SQL_BIND_METADATA_PK rebuild parallel 8;
alter index WRH$_SQL_BIND_METADATA_PK noparallel;


alter table SYS.WRM$_SNAPSHOT_DETAILS    move tablespace SYSAUX_TEMP parallel 8;
alter table SYS.WRM$_SNAPSHOT_DETAILS    move tablespace SYSAUX parallel 8;

alter index WRM$_SNAPSHOT_DETAILS_INDEX rebuild parallel 8;
alter index WRM$_SNAPSHOT_DETAILS_INDEX noparallel;

spool off

exit;


select segment_name, sum(bytes)/1048576 from dba_segments
where segment_name in (
'SYS.WRH$_SQL_PLAN',
'WRH$_SQL_PLAN_PK',
'WRH$_SQL_BIND_METADATA',
'WRM$_SNAPSHOT_DETAILS',
'WRH$_SQL_BIND_METADATA_PK',
'WRM$_SNAPSHOT_DETAILS_INDEX') 
group by segment_name
/




select table_name, index_name from dba_indexes where table_name in 
(
'WRH$_SQL_PLAN',
'WRH$_SQL_BIND_METADATA',  
'WRH$_ENQUEUE_STAT',
'WRM$_SNAPSHOT_DETAILS',
'WRH$_BG_EVENT_SUMMARY',
'WRH$_MUTEX_SLEEP',
'WRH$_SYSMETRIC_SUMMARY')
order by table_name;

TABLE_NAME                     INDEX_NAME
------------------------------ ------------------------------
WRH$_BG_EVENT_SUMMARY          WRH$_BG_EVENT_SUMMARY_PK
WRH$_ENQUEUE_STAT              WRH$_ENQUEUE_STAT_PK
WRH$_MUTEX_SLEEP               WRH$_MUTEX_SLEEP_PK
WRH$_SQL_BIND_METADATA         WRH$_SQL_BIND_METADATA_PK
WRH$_SQL_PLAN                  SYS_IL0000008938C00038$$
WRH$_SQL_PLAN                  WRH$_SQL_PLAN_PK
WRH$_SYSMETRIC_SUMMARY         WRH$_SYSMETRIC_SUMMARY_INDEX
WRM$_SNAPSHOT_DETAILS          WRM$_SNAPSHOT_DETAILS_INDEX

