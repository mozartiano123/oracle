set pagesize 50000
col mb for 999,999,999.99
set markup html on

spool /home/oracle/scripts/PDS_object_growth_report.html

clear columns

SELECT 'REPORT: GROWTH OF DATABASE' || ' DATE: ' || TO_CHAR(SYSDATE, 'DD/MON/RRRR') AS "GROWTH REPORT" FROM DUAL;

SELECT INSTANCE_NAME AS "INSTANCE NAME"  FROM V$INSTANCE;

SELECT 'MONITORED SCHEMAS: '|| SCHEMA_NAME AS "MONITORED SCHEMAS" FROM DBA_MAINTENANCE.MONITORED_SCHEMAS;

SELECT 'MONITORED_OBJECTS_WITH_HIGHEST_GROWTH_ON_PAST_30_DAYS' FROM DUAL;

compute sum of GROWTH_PAST_30_DAYS(MB) on report
break on report
select owner, object_name, object_type, MB as "GROWTH_PAST_30_DAYS(MB)" from
(SELECT CD.OWNER, CD.OBJECT_NAME, CD.OBJECT_TYPE, (CD.BYTES-SD.BYTES)/1024/1024 AS MB
FROM (select * from DBA_MAINTENANCE.DATABASE_OBJECTS_GROWTH WHERE SNAP_TIME > TRUNC(SYSDATE-1)) CD,
(SELECT * FROM DBA_MAINTENANCE.DATABASE_OBJECTS_GROWTH WHERE SNAP_TIME BETWEEN TRUNC(SYSDATE-30) AND trunc(SYSDATE-29)) SD
WHERE CD.OWNER = SD.OWNER
AND CD.OBJECT_NAME = SD.OBJECT_NAME
AND CD.OBJECT_TYPE = SD.OBJECT_TYPE
group by cd.owner, cd.object_name, cd.object_type, cd.bytes, sd.bytes
having (cd.bytes-sd.bytes) > 0
order by 4 DESC)
--Where rownum <= 10
/

SELECT 'MONITORED_SCHEMAS_GROWTH_ON_PAST_7_DAYS' FROM DUAL;

SELECT CD.OWNER, (CD.BYTES-SD.BYTES)/1024/1024 AS "GROWTH_PAST_7_DAYS(MB)"
FROM (select owner, sum(bytes) as bytes from DBA_MAINTENANCE.DATABASE_OBJECTS_GROWTH WHERE SNAP_TIME > TRUNC(SYSDATE) group by owner) CD,
(SELECT owner, sum(bytes) as bytes from DBA_MAINTENANCE.DATABASE_OBJECTS_GROWTH WHERE SNAP_TIME BETWEEN TRUNC(SYSDATE-7) AND trunc(SYSDATE-6) group by owner) SD
WHERE CD.OWNER = SD.OWNER
order by 2,1
/

SPOOL OFF

exit