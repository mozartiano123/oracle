CREATE TABLE DBTUNE.TEMP_SEG_USAGE(
  DATE_TIME  DATE,
  USERNAME VARCHAR2(30),
  SID                  VARCHAR2(6),
  SERIAL#        VARCHAR2(6),
  OS_USER     VARCHAR2(30),
  SPACE_USED NUMBER,
  SQL_TEXT    VARCHAR2(1000));



  CREATE OR REPLACE PROCEDURE DBTUNE.TEMP_SEG_USAGE_INSERT IS BEGIN
  insert into DBTUNE.TEMP_SEG_USAGE
  SELECT sysdate,a.username, a.sid, a.serial#, a.osuser, b.blocks*8192, c.sql_text
  FROM v$session a, v$sort_usage b, v$sqlarea c
  WHERE b.tablespace = 'SSD_TEMP_01'
  and a.saddr = b.session_addr
  AND c.address= a.sql_address
  AND c.hash_value = a.sql_hash_value
  ORDER BY b.tablespace, b.blocks;
  commit;
END;
/

BEGIN
  DBMS_JOB.ISUBMIT(
    JOB => 5555,
    WHAT => 'DBTUNE.TEMP_SEG_USAGE_INSERT;',
    NEXT_DATE => SYSDATE,
    INTERVAL => 'SYSDATE + (1/1440)');
COMMIT;
END;
/ 


GRANT SELECT ON v_$session TO DBTUNE;
GRANT SELECT ON v_$sort_usage TO DBTUNE;
GRANT SELECT ON v_$sqlarea TO DBTUNE;


-- query to monitor

SELECT TRUNC(DATE_TIME,'MI'), 
SUM(SPACE_USED)/1048576,
COUNT(DISTINCT SID)
FROM DBTUNE.TEMP_SEG_USAGE 
WHERE TRUNC(DATE_TIME,'MI') > sysdate - (1/24)
GROUP BY TRUNC(DATE_TIME,'MI') 
ORDER BY 1;
