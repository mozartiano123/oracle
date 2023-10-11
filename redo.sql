set lines 132
column  day format a16    heading 'Day'
column  d_0 format a3   heading '00'
column  d_1 format a3   heading '01'
column  d_2 format a3   heading '02'
column  d_3 format a3   heading '03'
column  d_4 format a3   heading '04'
column  d_5 format a3   heading '05'
column  d_6 format a3   heading '06'
column  d_7 format a3   heading '07'
column  d_8 format a3   heading '08'
column  d_9 format a3   heading '09'
column  d_10  format a3   heading '10'
column  d_11  format a3   heading '11'
column  d_12  format a3   heading '12'
column  d_13  format a3   heading '13'
column  d_14  format a3   heading '14'
column  d_15  format a3   heading '15'
column  d_16  format a3   heading '16'
column  d_17  format a3   heading '17'
column  d_18  format a3   heading '18'
column  d_19  format a3   heading '19'
column  d_20  format a3   heading '20'
column  d_21  format a3   heading '21'
column  d_22  format a3   heading '22'
column  d_23  format a3   heading '23'
column  Total   format 99999
column status  format a8
column member  format a40
column archived heading "Archived" format a8
column bytes heading "Bytes|(MB)" format 9999
Ttitle  "Log Info"  skip 2
select l.group#,f.member,l.archived,l.bytes/1078576 bytes,l.status,f.type
  from v$log l, v$logfile f
 where l.group# = f.group#
/
Ttitle off
prompt =========================================================================================================================
Ttitle  "Log Switch on hourly basis"  skip 2

select to_char(FIRST_TIME,'DY, DD-MON-YYYY') day,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'00',1,0))) d_0,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'01',1,0))) d_1,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'02',1,0))) d_2,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'03',1,0))) d_3,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'04',1,0))) d_4,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'05',1,0))) d_5,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'06',1,0))) d_6,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'07',1,0))) d_7,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'08',1,0))) d_8,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'09',1,0))) d_9,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'10',1,0))) d_10,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'11',1,0))) d_11,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'12',1,0))) d_12,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'13',1,0))) d_13,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'14',1,0))) d_14,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'15',1,0))) d_15,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'16',1,0))) d_16,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'17',1,0))) d_17,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'18',1,0))) d_18,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'19',1,0))) d_19,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'20',1,0))) d_20,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'21',1,0))) d_21,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'22',1,0))) d_22,
       decode(sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0)),0,'-',sum(decode(substr(to_char(FIRST_TIME,'HH24'),1,2),'23',1,0))) d_23,
       count(trunc(FIRST_TIME)) "Total"
  from v$log_history
 group by to_char(FIRST_TIME,'DY, DD-MON-YYYY')
 order by to_date(substr(to_char(FIRST_TIME,'DY, DD-MON-YYYY'),5,15) )
/
Ttitle off
prompt =========================================================================================================================           




-- sessions more redo
SELECT s.sid, s.serial#, s.username, s.program,
t.used_ublk, t.used_urec
FROM gv$session s, gv$transaction t
WHERE s.taddr = t.addr
ORDER BY 5,6 desc;

select sid, name,
round(value/1024/1024) redo_mb
from v$statname n, v$sesstat s
where n.name like 'redo size'
and s.statistic# = n.statistic#
order by 3
/

col machine for a30
select b.inst_id, b.SID, b.serial# sid_serial, b.username, machine, b.osuser, b.status, a.redo_mb MB
from (select n.inst_id, sid, round(value/1024/1024) redo_mb from gv$statname n, gv$sesstat s
where n.inst_id=s.inst_id and n.statistic#=134 and s.statistic# = n.statistic# order by value desc) a, gv$session b
where b.inst_id=a.inst_id
  and a.sid = b.sid
and   rownum <= 10;



set lines 200 pages 999
col START_TIME for a20
col START_DATE for a20

SELECT  Start_Date,   Start_Time,   Num_Logs, Round(Num_Logs * (Vl.Bytes / (1024 * 1024)),2) AS Mbytes, Vdb.NAME AS Dbname
FROM 
	(SELECT To_Char(Vlh.First_Time, 'YYYY-MM-DD') AS Start_Date, To_Char(Vlh.First_Time, 'HH24') || ':00' AS Start_Time, COUNT(Vlh.Thread#) Num_Logs
	FROM V$log_History Vlh 
	GROUP BY To_Char(Vlh.First_Time,  'YYYY-MM-DD'),To_Char(Vlh.First_Time, 'HH24') || ':00') 
Log_Hist,V$log Vl ,  V$database Vdb
WHERE Vl.Group# = 1
ORDER BY Log_Hist.Start_Date, Log_Hist.Start_Time;


-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/redo_by_day.sql
-- Author       : Tim Hall
-- Description  : Lists the volume of archived redo by day for the specified number of days.
-- Call Syntax  : @redo_by_day (days)
-- Requirements : Access to the v$views.
-- Last Modified: 11/10/2013
-- -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT TRUNC(first_time) AS day,
       ROUND(SUM(blocks * block_size)/1024/1024/1024,2) size_gb
FROM   v$archived_log
WHERE  TRUNC(first_time) >= TRUNC(SYSDATE) - &1
GROUP BY TRUNC(first_time)
ORDER BY TRUNC(first_time);

SET VERIFY ON


-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/redo_by_hour.sql
-- Author       : Tim Hall
-- Description  : Lists the volume of archived redo by hour for the specified day.
-- Call Syntax  : @redo_by_hour (day 0=Today, 1=Yesterday etc.)
-- Requirements : Access to the v$views.
-- Last Modified: 11/10/2013
-- -----------------------------------------------------------------------------------

SET VERIFY OFF PAGESIZE 30

WITH hours AS (
  SELECT TRUNC(SYSDATE) - &1 + ((level-1)/24) AS hours
  FROM   dual
  CONNECT BY level < = 24
)
SELECT h.hours AS date_hour,
       ROUND(SUM(blocks * block_size)/1024/1024/1024,2) size_gb
FROM   hours h
       LEFT OUTER JOIN v$archived_log al ON h.hours = TRUNC(al.first_time, 'HH24')
GROUP BY h.hours
ORDER BY h.hours;

SET VERIFY ON PAGESIZE 14




-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/redo_by_min.sql
-- Author       : Tim Hall
-- Description  : Lists the volume of archived redo by min for the specified number of hours.
-- Call Syntax  : @redo_by_min (N number of minutes from now)
-- Requirements : Access to the v$views.
-- Last Modified: 11/10/2013
-- -----------------------------------------------------------------------------------

SET VERIFY OFF PAGESIZE 100

WITH mins AS (
  SELECT TRUNC(SYSDATE, 'MI') - (&1/(24*60)) + ((level-1)/(24*60)) AS mins
  FROM   dual
  CONNECT BY level <= &1
)
SELECT m.mins AS date_min,
       ROUND(SUM(blocks * block_size)/1024/1024,2) size_mb
FROM   mins m
       LEFT OUTER JOIN v$archived_log al ON m.mins = TRUNC(al.first_time, 'MI')
GROUP BY m.mins
ORDER BY m.mins;


SET VERIFY ON PAGESIZE 14



-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/monitoring/redo_by_min.sql
-- Author       : Tim Hall
-- Description  : Lists the volume of archived redo by min for the specified number of hours.
-- Call Syntax  : @redo_by_min (N number of minutes from now)
-- Requirements : Access to the v$views.
-- Last Modified: 11/10/2013
-- -----------------------------------------------------------------------------------

SET VERIFY OFF PAGESIZE 100

WITH mins AS (
  SELECT TRUNC(SYSDATE, 'MI') - (&1/(24*60)) + ((level-1)/(24*60)) AS mins
  FROM   dual
  CONNECT BY level <= &1
)
SELECT m.mins AS date_min,
       ROUND(SUM(blocks * block_size)/1024/1024,2) size_mb
FROM   mins m
       LEFT OUTER JOIN v$archived_log al ON m.mins = TRUNC(al.first_time, 'MI')
GROUP BY m.mins
ORDER BY m.mins;

SET VERIFY ON PAGESIZE 14