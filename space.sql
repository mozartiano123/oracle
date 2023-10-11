clear columns
column tablespace format a30
column total_mb format 999,999,999.99
column used_mb format 999,999,999,999.99
column free_mb format 999,999,999.99
column pct_used format 999.99
column graph format a25 heading "GRAPH (X=5%)"
column status format a10
compute sum of total_mb on report
compute sum of used_mb on report
compute sum of free_mb on report
break on report
set lines 200 pages 100
select  /* +parallel(4) */ total.ts tablespace,
        DECODE(total.mb,null,'OFFLINE',dbat.status) status,
	total.mb total_mb,
	NVL(total.mb - free.mb,total.mb) used_mb,
	NVL(free.mb,0) free_mb,
        DECODE(total.mb,NULL,0,NVL(ROUND((total.mb - free.mb)/(total.mb)*100,2),100)) pct_used,
	CASE WHEN (total.mb IS NULL) THEN '['||RPAD(LPAD('OFFLINE',13,'-'),20,'-')||']'
	ELSE '['|| DECODE(free.mb,
                             null,'XXXXXXXXXXXXXXXXXXXX',
                             NVL(RPAD(LPAD('X',trunc((100-ROUND( (free.mb)/(total.mb) * 100, 2))/5),'X'),20,'-'),
		'--------------------'))||']'
         END as GRAPH
from
	(select tablespace_name ts, sum(bytes)/1048576 mb from dba_data_files group by tablespace_name) total,
	(select tablespace_name ts, sum(bytes)/1048576 mb from dba_free_space group by tablespace_name) free,
        dba_tablespaces dbat
where total.ts=free.ts(+) and
      total.ts=dbat.tablespace_name
UNION ALL
select  sh.tablespace_name,
        'TEMP',
	SUM(sh.bytes_used+sh.bytes_free)/1048576 total_mb,
	SUM(sh.bytes_used)/1048576 used_mb,
	SUM(sh.bytes_free)/1048576 free_mb,
        ROUND(SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free)*100,2) pct_used,
        '['||DECODE(SUM(sh.bytes_free),0,'XXXXXXXXXXXXXXXXXXXX',
              NVL(RPAD(LPAD('X',(TRUNC(ROUND((SUM(sh.bytes_used)/SUM(sh.bytes_used+sh.bytes_free))*100,2)/5)),'X'),20,'-'),
                '--------------------'))||']'
FROM v$temp_space_header sh
GROUP BY tablespace_name
order by 6
/
ttitle off
rem clear columns



alter tablespace DATA_FLASH_01_03 add datafile '+DATA_NDW_FLASH_01' size 32767m;

-- per datafile

set lin 200 pages 999
col file_name for a60
col tablespace_name for a20
set numwidth 15
select FILE_NAME, FILE_ID, TABLESPACE_NAME, AUTOEXTENSIBLE,
BYTES/1048576 as MB, MAXBYTES/1048576 as MAX_MB
from dba_data_files where tablespace_name='&tbs'
/


select * from V$SYSAUX_OCCUPANTS order by SPACE_USAGE_KBYTES ;


--Alter database datafile 1382 resize 10240m ;
Alter database datafile 1792 resize 32767m ;

-- Object size.
select segment_name, sum(bytes)/1024/1024 as mb
from dba_segments
where upper(owner) =upper('&owner')
and upper(segment_name) = upper('&object')
group by segment_name;

-- ASM SPACE

set lines 200 pages 999
column name for a20
column tablespace format a30
column total_mb format 999,999,999.99
column used_mb format 999,999,999,999.99
column free_mb format 999,999,999.99
column pct_used format 999.99
select /*+parallel(4) */ name,total_mb,total_mb-free_mb used_mb,free_mb,(total_mb-free_mb)/total_mb*100 pct_used,
dg.USABLE_FILE_MB usable, d.qty disks, d.resize_gb
  from v$asm_diskgroup dg, (select GROUP_NUMBER, count(1) qty,avg(os_mb/1024) resize_GB from v$asm_disk group by group_number) d
  where d.GROUP_NUMBER=dg.GROUP_NUMBER
  order by 1
  /

-- redo logs

col member for a50
select lf.member, sum(l.bytes)/1048576 as total_mb
from v$log l join v$logfile lf using (group#)
group by lf.member;

-- asm space
SELECT * FROM V$FLASH_RECOVERY_AREA_USAGE;

-- high water mark


col file_name for a80
select /*+parallel(6) no_merge */file_name, smallest, currsize, savings
from(
  select file_name, tablespace_name,
       ceil( (nvl(hwm,1)*&&blksize)/1048576 ) smallest,
       ceil( blocks*&&blksize/1048576) currsize,
       ceil( blocks*&&blksize/1048576) - ceil( (nvl(hwm,1)*&&blksize)/1048576 ) savings
  from dba_data_files a,
     ( select file_id, max(block_id+blocks-1) hwm
       from dba_extents
      group by file_id ) b
  where a.file_id = b.file_id(+)
) c
where savings >= 100
and tablespace_name in ('APPS_TS_TX_DATA')
order by savings desc
/


-- FIND FILE NAME GIVEN BLCOK#

SET PAUSE ON
SET PAGESIZE 60
SET LINESIZE 300

COLUMN segment_name FORMAT A24
COLUMN segment_type FORMAT A24

SELECT segment_name, segment_type, block_id, blocks
   FROM   dba_extents
   WHERE
          file_id = &file_no
   AND
          ( &block_value BETWEEN block_id AND ( block_id + blocks ) )
/


-- per session

set lines 200 pages 999
SELECT s.sid, s.serial#, s.username, s.program,
i.block_changes
FROM v$session s, v$sess_io i
WHERE s.sid = i.sid
ORDER BY 5 desc, 1, 2, 3, 4
/



--growth per day

SELECT /*+Parallel(8)*/b.tsname tablespace_name
, MAX(b.used_size_mb) cur_used_size_mb
, round(AVG(inc_used_size_mb),2)avg_increas_mb
FROM (
  SELECT a.days, a.tsname, used_size_mb
  , used_size_mb - LAG (used_size_mb,1)  OVER ( PARTITION BY a.tsname ORDER BY a.tsname,a.days) inc_used_size_mb
  FROM (
      SELECT TO_CHAR(sp.begin_interval_time,'MM-DD-YYYY') days
       ,ts.tsname
       ,MAX(round((tsu.tablespace_usedsize* dt.block_size )/(1024*1024),2)) used_size_mb
      FROM DBA_HIST_TBSPC_SPACE_USAGE tsu, DBA_HIST_TABLESPACE_STAT ts
       ,DBA_HIST_SNAPSHOT sp, DBA_TABLESPACES dt
      WHERE tsu.tablespace_id= ts.ts# AND tsu.snap_id = sp.snap_id
       AND ts.tsname = dt.tablespace_name
       AND sp.begin_interval_time > sysdate-10
      GROUP BY TO_CHAR(sp.begin_interval_time,'MM-DD-YYYY'), ts.tsname
      ORDER BY ts.tsname, days
  ) A
) b GROUP BY b.tsname ORDER BY b.tsname
/



OVM_ORDER_INFO – will go to archive order info and pick up the req id’s, if in
OVM_REQ_HISTORY










-- most used datafiles

REM FUNCTION:   Reports on the file io status of all of the datafiles
REM             in the database
REM TESTED ON:  10.2.0.3 and 11.1.0.6 (9i should be supported too)
REM PLATFORM:   non-specific
REM REQUIRES:   v$filestat, v$dbfile
REM
REM  This is a part of the Knowledge Xpert for Oracle Administration library.
REM  Copyright (C) 2008 Quest Software
REM  All rights reserved.
REM
REM******************** Knowledge Xpert for Oracle Administration ********************

COLUMN Percent   format 999.99    heading 'Percent|Of IO'
COLUMN ratio     format 999.999   heading 'Block|Read|Ratio'
COLUMN phyrds                     heading 'Physical | Reads'
COLUMN phywrts                    heading 'Physical | Writes'
COLUMN phyblkrd                   heading 'Physical|Block|Reads'
COLUMN name      format a50       heading 'File|Name'
SET feedback off verify off lines 132 pages 200
TTITLE left _date center 'File IO Statistics Report' skip 2

WITH total_io AS
     (SELECT SUM (phyrds + phywrts) sum_io
        FROM v$filestat)
SELECT   NAME, phyrds, phywrts, ((phyrds + phywrts) / c.sum_io) * 100 PERCENT,
         phyblkrd, (phyblkrd / GREATEST (phyrds, 1)) ratio
    FROM SYS.v_$filestat a, SYS.v_$dbfile b, total_io c
   WHERE a.file# = b.file#
order by 3
--ORDER BY a.file#
/
SET feedback on verify on lines 80 pages 22
CLEAR columns
TTITLE off


















-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/high_water_mark.sql
-- Author       : Tim Hall
-- Description  : Displays the High Water Mark for the specified table, or all tables.
-- Requirements : Access to the Dbms_Space.
-- Call Syntax  : @high_water_mark (table_name or all) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET VERIFY OFF

DECLARE
  CURSOR cu_tables IS
    SELECT a.owner,
           a.table_name
    FROM   all_tables a
    WHERE  a.table_name = Decode(Upper('&&1'),'ALL',a.table_name,Upper('&&1'))
    AND    a.owner      = Upper('&&2');

  op1  NUMBER;
  op2  NUMBER;
  op3  NUMBER;
  op4  NUMBER;
  op5  NUMBER;
  op6  NUMBER;
  op7  NUMBER;
BEGIN

  Dbms_Output.Disable;
  Dbms_Output.Enable(1000000);
  Dbms_Output.Put_Line('TABLE                             UNUSED BLOCKS     TOTAL BLOCKS  HIGH WATER MARK');
  Dbms_Output.Put_Line('------------------------------  ---------------  ---------------  ---------------');
  FOR cur_rec IN cu_tables LOOP
    Dbms_Space.Unused_Space(cur_rec.owner,cur_rec.table_name,'TABLE',op1,op2,op3,op4,op5,op6,op7);
    Dbms_Output.Put_Line(RPad(cur_rec.table_name,30,' ') ||
                         LPad(op3,15,' ')                ||
                         LPad(op1,15,' ')                ||
                         LPad(Trunc(op1-op3-1),15,' '));
  END LOOP;

END;
/



-- fragmented tables

select
   table_name,round((blocks*8),2) "tam (kb)" ,
   round((num_rows*avg_row_len/1024),2) "total (kb)",
   (round((blocks*8),2) - round((num_rows*avg_row_len/1024),2)) "vazio (kb)"
from
   dba_tables
where
   (round((blocks*8),2) > round((num_rows*avg_row_len/1024),2))
order by 4 desc;


-- per datafile
col file_name for a60
col tablespace_name for a20
set numwidth 15
select FILE_NAME, FILE_ID, TABLESPACE_NAME,
BYTES/1048576 as MB, MAXBYTES/1048576 as MB
from dba_temp_files where tablespace_name='&tbs'
/






CLL.CLL_F189PERATIONS
AR.RA_CUSTOMER_TRX_ALL
ECOMEX.EXP_FATURA_ITEM_DETALHES
XXXPB.SGF_ADE_PROD_REALIZADA_EVT
ONT.OE_ORDER_HEADERS_ALL
CLL.CLL_F189_INVOICES_INTERFACE