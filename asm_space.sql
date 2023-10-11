-- per tablespace
set lines 200 pages 999
column name for a13
column tablespace format a30
column total_mb format 999,999,999.99
column used_mb format 999,999,999,999.99
column free_mb format 999,999,999.99
column pct_used format 999.99
select name,total_mb,total_mb-free_mb used_mb,free_mb,(total_mb-free_mb)/total_mb*100 pct_used, d.qty disks, d.resize_gb
  from v$asm_diskgroup dg, (select GROUP_NUMBER, count(1) qty,avg(os_mb/1024) resize_GB from v$asm_disk group by group_number) d
  where d.GROUP_NUMBER=dg.GROUP_NUMBER
  order by 1
  /


-- per session

set lines 200 pages 999
SELECT s.sid, s.serial#, s.username, s.program,
i.block_changes
FROM v$session s, v$sess_io i
WHERE s.sid = i.sid
ORDER BY 5 desc, 1, 2, 3, 4
/

