UNDO.sql

-- query using most undo

select s.sql_text from v$sql s, v$undostat u
where u.maxqueryid=s.sql_id;

-- session undo for a currently executing transaction.

select s.sid, s.status, s.LAST_CALL_ET,s.username,t.used_urec,t.used_ublk
from gv$session s, gv$transaction t
where s.saddr = t.ses_addr
order by t.used_ublk desc;

-- To find out which session is currently using the most UNDO,

select s.sid, t.name, s.value
from gv$sesstat s, gv$statname t
where s.statistic#=t.statistic#
and t.name='undo change vector size'
order by s.value ;

-- user and query using more undo

select sql.sql_text, t.used_urec records, t.used_ublk blocks,
(t.used_ublk*8192/1024) kb from v$transaction t,
v$session s, v$sql sql
where t.addr=s.taddr
and s.sql_id = sql.sql_id
and s.username ='&USERNAME';

-- undo use in the database 
col BEGIN_TIME for a30
col END_TIME for a30
SELECT TO_CHAR(BEGIN_TIME, 'MM/DD/YYYY HH24:MI:SS') BEGIN_TIME,
TO_CHAR(END_TIME, 'MM/DD/YYYY HH24:MI:SS') END_TIME,
UNDOTSN, UNDOBLKS, TXNCOUNT, MAXCONCURRENCY AS "MAXCON", 
MAXQUERYLEN as "QUERYLEN", MAXQUERYID as "QUERYID", UNEXPIREDBLKS "NOTTOUSE", EXPIREDBLKS as "TOUSE"
FROM gv$UNDOSTAT WHERE rownum <= 144 order by 2;

--


SELECT a.name,b.status 
FROM   v$rollname a,v$rollstat b
WHERE  a.usn = b.usn
AND    a.name IN ( 
		  SELECT segment_name
		  FROM dba_segments 
		  WHERE tablespace_name = 'UNDO_02'
		 );


select s.sid, s.username, sum(ss.value) / 1024 / 1024 as undo_size_mb
from v$sesstat ss join v$session s on s.sid=ss.sid join v$statname stat on stat.statistic#=ss.statistic#
where stat.name = 'undo change vector size'
and s.type <> 'BACKGROUND'
and s.username IS NOT NULL
group by s.sid, s.username;


--- rollback info

-- Show rollback information.
--
 
SET PAUSE ON
SET PAUSE 'Press Return to Continue'
SET PAGESIZE 60
SET LINESIZE 300
 
COLUMN username FORMAT A20
COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 99999
 
SELECT s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       t.used_urec,
       rs.segment_name,
       r.rssize,
       r.status
FROM   v$transaction t,
       v$session s,
       v$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    t.xidusn = r.usn
AND   rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC
/