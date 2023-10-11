col hash_value for a40
col tablespace for a15
col username for a15
set linesize 200 pagesize 1000
 
SELECT s.inst_id,s.sid, s.username, s.sql_id, u.tablespace, s.sql_hash_value||'/'||u.sqlhash hash_value, u.segtype, u.contents, 
       u.blocks,u.blocks*(select value from v$parameter where name='db_block_size')/1024/1024 MB
  FROM gv$session s, gv$tempseg_usage u
  WHERE s.inst_id=u.inst_id
    and s.saddr=u.session_addr
  order by u.blocks;
  
select sql_id, sorts, rows_processed/greatest(nvl(executions,1),1) 
 from gv$sql
 where sql_id='&sqlid'
 and sorts > 0
 order by 3;
 
 
BREAK ON tablespace_name ON report
COLUMN tablespace_name           FORMAT a14               HEAD 'Tablespace|Name'          JUST right
COLUMN temp_segment_name         FORMAT a8                HEAD 'Segment|Name'             JUST right
COLUMN current_users             FORMAT 9,999             HEAD 'Current|Users'            JUST right
COLUMN total_temp_segment_size   FORMAT 999,999,999,999   HEAD 'Total Temp|Segment Size'  JUST right
COLUMN currently_used_bytes      FORMAT 999,999,999,999   HEAD 'Currently|Used Bytes'     JUST right
COLUMN pct_used                  FORMAT 999               HEAD 'Pct.|Used'                JUST right
COLUMN extent_hits               FORMAT 999,999,999           HEAD 'Extent|Hits'              JUST right
COLUMN max_size                  FORMAT 999,999,999,999,999   HEAD 'Max|Size'                 JUST right
COLUMN max_used_size             FORMAT 999,999,999,999,999   HEAD 'Max Used|Size'            JUST right
COLUMN max_sort_size             FORMAT 999,999,999,999   HEAD 'Max Sort|Size'            JUST right
COLUMN free_requests             FORMAT 999999               HEAD 'Free|Requests'            JUST right
COMPUTE SUM OF current_users            ON report
COMPUTE SUM OF total_temp_segment_size  ON report
COMPUTE SUM OF currently_used_bytes     ON report
COMPUTE SUM OF currently_free_bytes     ON report
COMPUTE SUM OF extent_hits              ON report
COMPUTE SUM OF max_size                 ON report
COMPUTE SUM OF max_used_size            ON report
COMPUTE SUM OF max_sort_size            ON report
COMPUTE SUM OF free_requests            ON report
SELECT 
    a.tablespace_name             tablespace_name
  , 'SYS.'          || 
    a.segment_file  ||
    '.'             || 
    a.segment_block               temp_segment_name
  , a.current_users               current_users
  , (a.total_blocks*b.value)      total_temp_segment_size
  , (a.used_blocks*b.value)       currently_used_bytes
  , TRUNC(ROUND((a.used_blocks/a.total_blocks)*100))    pct_used
  , a.extent_hits                 extent_hits
  , (a.max_blocks*b.value)        max_size
  , (a.max_used_blocks*b.value)   max_used_size
  , (a.max_sort_blocks *b.value)  max_sort_size
  , a.free_requests               free_requests
FROM
    v$sort_segment                  a
  , (select value from v$parameter
     where name = 'db_block_size')  b
/
 

-- MOST USED TEMP

SELECT A.tablespace_name tablespace, D.mb_total,
SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_used,
D.mb_total - SUM (A.used_blocks * D.block_size) / 1024 / 1024 mb_free
FROM v$sort_segment A,
(
SELECT B.name, C.block_size, SUM (C.bytes) / 1024 / 1024 mb_total
FROM v$tablespace B, v$tempfile C
WHERE B.ts#= C.ts#
GROUP BY B.name, C.block_size
) D
WHERE A.tablespace_name = D.name
GROUP by A.tablespace_name, D.mb_total
/ 

 -- TEMP NDW - per session

set lines 180 pages 999
col mb_used for 999,999,999.999
break on tablespace skip 1 on report
compute sum of mb_used on tablespace skip 2
compute sum of mb_used on report
select t.inst_id, s.sid, s.serial#, t.username, s.sql_id, (t.blocks*tbs.block_size/1024/1024) MB_used
from gv$sort_usage t, dba_tablespaces tbs, gv$session s
where t.tablespace = tbs.tablespace_name
  and t.session_addr = s.saddr
  --and t.username = 'STORMADM'
  and tbs.tablespace_name='TEMPEBS'
  order by MB_USED
/ 


select s.inst_id, s.sid, s.serial#, p.qcsid, s.username, s.osuser, s.sql_id, s.status
from gv$px_session p join gv$session s on(p.SID=s.sid and p.SERIAL#=s.SERIAL# and p.inst_id=s.inst_id)
where s.username='APP_DPN'
order by s.status;


--
-- Temporary Tablespace Usage per tablespace.
--
 
SET PAUSE ON
SET PAGESIZE 60
SET LINESIZE 300
 
COL TABLESPACE_SIZE FOR 99,999,999,999,999
COL ALLOCATED_SPACE FOR 99,999,999,999,999
COL FREE_SPACE FOR 99,999,999,999,999
 
SELECT *
FROM   dba_temp_free_space
/



-- TEMP fragmentation.

select
total.tablespace_name tsname,
count(free.bytes) nfrags,
nvl(max(free.bytes)/1024,0) mxfrag,
total.bytes/1024 totsiz,
nvl(sum(free.bytes)/1024,0) avasiz,
(1-nvl(sum(free.bytes),0)/total.bytes)*100 pctusd
from
dba_data_files total,
dba_free_space free
where
total.tablespace_name = free.tablespace_name(+)
and total.file_id=free.file_id(+)
group by
total.tablespace_name,
total.bytes;

-- all segments using temp.


SELECT   b.TABLESPACE
       , b.segfile#
       , b.segblk#
       , ROUND (  (  ( b.blocks * p.VALUE ) / 1024 / 1024 ), 2 ) size_mb
       , a.SID
       , a.serial#
       , a.username
       , a.osuser
       , a.program
       , a.status
    FROM v$session a
       , v$sort_usage b
       , v$process c
       , v$parameter p
   WHERE p.NAME = 'db_block_size'
     AND a.saddr = b.session_addr
     AND a.paddr = c.addr
ORDER BY size_mb,
        b.TABLESPACE
       , b.segfile#
       , b.segblk#
       , b.blocks;




       --HISTORY


       select t.sample_time, t.sql_id, t.temp_mb, t.temp_diff
       ,s.sql_text
  from (
        select --session_id,session_serial#,
               --'alter system kill session ''' || session_id || ',' || session_serial# || ''' immediate;' kill_session_cmd,
               trunc(sample_time) sample_time,sql_id, sum(temp_mb) temp_mb, sum(temp_diff) temp_diff
               , row_number() over (partition by trunc(sample_time) order by sum(temp_mb) desc nulls last) as rn
          from (
                select sample_time,session_id,session_serial#,sql_id,temp_space_allocated/1024/1024 temp_mb, 
                       temp_space_allocated/1024/1024-lag(temp_space_allocated/1024/1024,1,0) over (order by sample_time) as temp_diff
                 from dba_hist_active_sess_history 
                 --from v$active_session_history
                where 1 = 1 
               )
         group by --session_id,session_serial#,
                  trunc(sample_time),
                  sql_id
       ) t
  left join v$sqlarea s
    on s.sql_id = t.sql_id
 where 1 = 1
   and rn <=5
   and sample_time >= trunc(sysdate) - 7                 
 order by sample_time desc, temp_mb desc
 /