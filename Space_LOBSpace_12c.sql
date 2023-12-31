select
  NULL NAME,
  NULL VALUE
from dual where 1=0 union all ( select
  NULL NAME,
  NULL VALUE
from dual where 1=0) union all ( select * from (
WITH
    FUNCTION LOB_INFO(OWNER VARCHAR2,NAME VARCHAR2, OPT NUMBER) RETURN NUMBER IS
        LOBBLOCK NUMBER;
        LOBBYTE NUMBER;
        LOBUSEBLK NUMBER;
        LOBUSEBYTE NUMBER;
        LOBEXPBLK NUMBER;
        LOBEXPBYTE NUMBER;
        LOBUNEXPBLK NUMBER;
        LOBUNEXPBYTE NUMBER;
    BEGIN
        DBMS_SPACE.SPACE_USAGE
            (    OWNER,
                NAME,
                'LOB',
                LOBBLOCK,
                LOBBYTE,
                LOBUSEBLK,
                LOBUSEBYTE,
                LOBEXPBLK,
                LOBEXPBYTE,
                LOBUNEXPBLK,
                LOBUNEXPBYTE);
        CASE OPT
            WHEN 1 THEN RETURN LOBBLOCK;
            WHEN 2 THEN    RETURN LOBBYTE;
            WHEN 3 THEN RETURN LOBUSEBLK;
            WHEN 4 THEN    RETURN LOBUSEBYTE;
            WHEN 5 THEN RETURN LOBEXPBLK;
            WHEN 6 THEN    RETURN LOBEXPBYTE;
            WHEN 7 THEN RETURN LOBUNEXPBLK;
            WHEN 8 THEN    RETURN LOBUNEXPBYTE;
        END CASE;
    END;
    FUNCTION LOB_FREEINFO(OWNER VARCHAR2,NAME VARCHAR2, OPT NUMBER) RETURN NUMBER IS
        TTBLK NUMBER;
        TTBYTE NUMBER;
        UNUSEBLK NUMBER;
        UNUSEBYTE NUMBER;
        LSTEXTFILEID NUMBER;
        LSTEXTBLKID NUMBER;
        LSTBLK NUMBER;
    BEGIN
        DBMS_SPACE.UNUSED_SPACE
            (    OWNER,
                NAME,
                'LOB',
                TTBLK,
                TTBYTE,
                UNUSEBLK,
                UNUSEBYTE,
                LSTEXTFILEID,
                LSTEXTBLKID,
                LSTBLK);
        CASE OPT
            WHEN 1 THEN RETURN TTBLK;
            WHEN 2 THEN    RETURN TTBYTE;
            WHEN 3 THEN RETURN UNUSEBLK;
            WHEN 4 THEN    RETURN UNUSEBYTE;
            WHEN 5 THEN RETURN LSTEXTFILEID;
            WHEN 6 THEN    RETURN LSTEXTBLKID;
            WHEN 7 THEN RETURN LSTBLK;
        END CASE;
    END;
BASIS_INFO AS
(
SELECT
    'SAPSR3'    OWNER,
    'SOFFCONT1'    TABLE_NAME,
    'CLUSTD'        COLUMN_NAME
FROM
DUAL
)
SELECT
    'Owner' NAME,
    OWNER VALUE
FROM
    BASIS_INFO
UNION ALL
SELECT
    'Table Name' NAME,
    TABLE_NAME VALUE
FROM
    BASIS_INFO
UNION ALL
SELECT
    'Column Name' NAME,
    COLUMN_NAME VALUE
FROM
    BASIS_INFO
UNION ALL
SELECT
    'Lob Segment Name' NAME,
    DL.SEGMENT_NAME VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'PCT Version' NAME,
    DECODE(DL.PCTVERSION,null,'N/A',to_char(DL.PCTVERSION)) VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Retention' NAME,
    DECODE(DL.RETENTION,null,'N/A',to_char(DL.RETENTION)) VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Cache' NAME,
    DL.CACHE VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Compression' NAME,
    DL.COMPRESSION VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Deduplication' NAME,
    DL.DEDUPLICATION VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'In Row' NAME,
    DL.IN_ROW VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Securefile' NAME,
    DL.SECUREFILE VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Total Blocks' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,1),'999999999999') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Total Size in MB' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,2)/1024/1024,'999999999990.99') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Used Blocks' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,3),'999999999999') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Used Size in MB' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,4)/1024/1024,'999999999990.99') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Expired Blocks' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,5),'999999999999') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Expired Size in MB' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,6)/1024/1024,'999999999990.99') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Unexpired Blocks' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,7),'999999999999') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Unexpired Size in MB' NAME,
    TO_CHAR(LOB_INFO(BI.OWNER,DL.SEGMENT_NAME,8)/1024/1024,'999999999990.99') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Unused Blocks' NAME,
    TO_CHAR(LOB_FREEINFO(BI.OWNER,DL.SEGMENT_NAME,3),'999999999999') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
UNION ALL
SELECT
    'Unused Size in MB' NAME,
    TO_CHAR(LOB_FREEINFO(BI.OWNER,DL.SEGMENT_NAME,4)/1024/1024,'999999999990.99') VALUE
FROM
    DBA_LOBS DL,
    BASIS_INFO BI
WHERE
    DL.OWNER LIKE BI.OWNER AND
    DL.TABLE_NAME = BI.TABLE_NAME AND
    DL.COLUMN_NAME = BI.COLUMN_NAME
));
