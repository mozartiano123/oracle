-- select only those indexes with an estimated space saving percent greater than 25%
VAR savings_percent NUMBER;
EXEC :savings_percent := 25;
-- select only indexes with current size (as per cbo stats) greater then 1MB
VAR minimum_size_mb NUMBER;
EXEC :minimum_size_mb := 1;
SET SERVEROUT ON ECHO OFF FEED OFF VER OFF TAB OFF LINES 300;
COL report_date NEW_V report_date;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD"T"HH24:MI:SS') report_date FROM DUAL;
SPO /tmp/indexes_2b_shrunk_&&report_date..txt;
DECLARE
l_used_bytes NUMBER;
l_alloc_bytes NUMBER;
l_percent NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('PDB: '||SYS_CONTEXT('USERENV', 'CON_NAME'));
DBMS_OUTPUT.PUT_LINE('---');
DBMS_OUTPUT.PUT_LINE(
RPAD('INDEX_NAME', 35)||' '||
RPAD('TABLE_NAME', 35)||' '||
LPAD('SAVING %', 10)||' '||
LPAD('CURRENT SIZE', 20)||' '||
LPAD('ESTIMATED SIZE', 20));
DBMS_OUTPUT.PUT_LINE(
RPAD('-', 35, '-')||' '||
LPAD('-', 10, '-')||' '||
LPAD('-', 20, '-')||' '||
LPAD('-', 20, '-'));
FOR i IN (SELECT x.owner,x.table_name, x.index_name, SUM(s.leaf_blocks) * TO_NUMBER(p.value) index_size,
REPLACE(DBMS_METADATA.GET_DDL('INDEX',x.index_name,x.owner),CHR(10),CHR(32)) ddl
FROM dba_ind_statistics s, dba_indexes x, dba_users u, v$parameter p
WHERE u.oracle_maintained = 'N'
AND x.owner = u.username
AND x.tablespace_name NOT IN ('SYSTEM','SYSAUX')
AND x.index_type LIKE '%NORMAL%'
AND x.table_type = 'TABLE'
AND x.status = 'VALID'
AND x.temporary = 'N'
AND x.dropped = 'NO'
AND x.visibility = 'VISIBLE'
AND x.segment_created = 'YES'
AND x.orphaned_entries = 'NO'
AND p.name = 'db_block_size'
AND s.owner = x.owner
AND s.index_name = x.index_name
-- change the owner here >>>> 
AND x.owner = 'MSAF'
GROUP BY
x.owner, x.table_name,x.index_name, p.value
HAVING
SUM(s.leaf_blocks) * TO_NUMBER(p.value) > :minimum_size_mb * POWER(2,20)
ORDER BY
index_size DESC)
LOOP
DBMS_SPACE.CREATE_INDEX_COST(i.ddl,l_used_bytes,l_alloc_bytes);
IF i.index_size * (100 - :savings_percent) / 100 > l_alloc_bytes THEN
l_percent := 100 * (i.index_size - l_alloc_bytes) / i.index_size;
DBMS_OUTPUT.PUT_LINE(
RPAD(i.owner||'.'||i.index_name, 35)||' '||
RPAD(i.table_name, 35)||' '||
LPAD(TO_CHAR(ROUND(l_percent, 1), '990.0')||' % ', 10)||' '||
LPAD(TO_CHAR(ROUND(i.index_size / POWER(2,20), 1), '999,999,990.0')||' MB', 20)||' '||
LPAD(TO_CHAR(ROUND(l_alloc_bytes / POWER(2,20), 1), '999,999,990.0')||' MB', 20));
END IF;
END LOOP;
END;
/


-- Fragmentação.

1) Tabela para guardar a informação da fragmentação, alimentada pela procedure do passo 2

 

CREATE TABLE TB_SPACE_USAGE
   (
    TOWNER VARCHAR2(200 BYTE),
    TNAME VARCHAR2(200 BYTE),
    TTYPE VARCHAR2(200 BYTE),
    PNAME VARCHAR2(200 BYTE),
    TSNAME VARCHAR2(200 BYTE),
    UNFORMATTED_BLOCKS VARCHAR2(200 BYTE),
    UNFORMATTED_BYTES VARCHAR2(200 BYTE),
    FS1_BLOCKS NUMBER,
    FS1_BYTES NUMBER,
    FS2_BLOCKS NUMBER,
    FS2_BYTES NUMBER,
    FS3_BLOCKS NUMBER,
    FS3_BYTES NUMBER,
    FS4_BLOCKS NUMBER,
    FS4_BYTES NUMBER,
    FULL_BLOCKS NUMBER,
    FULL_BYTES NUMBER,
    FREE_BYTES NUMBER,
    SEGMENT_SPACE NUMBER
   );

 

2) Procedure para encontrar fragmentação:

 

create or replace procedure PRC_find_fragmentation as

 

cursor c1 is
select owner,segment_name,bytes,segment_type,partition_name,tablespace_name
  from dba_segments
 where
   segment_type in ('TABLE','INDEX')
   and owner not in ('SYS','SYSTEM','PERFSTAT')
   and bytes/1024/1024 > 100
   and
   (
   segment_name in (select table_name from dba_tables where iot_type is null)
   or segment_name in (select index_name from dba_indexes where index_type in ('NORMAL','FUNCTION-BASED NORMAL'))
   )
 order by 3 desc;

 

unformatted_blocks number;
unformatted_bytes number;
sowner varchar2(100);
sname varchar2(100);
tname varchar2(100);
tsname varchar2(200);
pname varchar2(200);
fs1_blocks number;
fs1_bytes number;
fs2_blocks number;
fs2_bytes number;
fs3_blocks number;
fs3_bytes number;
fs4_blocks number;
fs4_bytes number;
full_blocks number;
full_bytes number;
free_bytes number;
vspace number;
seg_type varchar2(200);

 

BEGIN
execute immediate 'truncate table TB_SPACE_USAGE';
open c1;
loop
     fetch c1 into sowner,tname,vspace,seg_type,pname,tsname;
      exit when c1%notfound;
dbms_output.put_line(seg_type||':'||tname);
if seg_type='TABLE' then
dbms_output.put_line(' TABLE .....'||sname||'   '||tname||'   '||seg_type);
execute immediate 'begin dbms_space.SPACE_USAGE(segment_owner=> :1,segment_name=>:2,segment_type =>:3,unformatted_blocks =>:4,unformatted_bytes =>:5,fs1_blocks =>:6,fs1_bytes =>:7,fs2_blocks =>:8,fs2_bytes =>:9,fs3_blocks =>:10, fs3_bytes =>:11,fs4_blocks => :12,fs4_bytes => :13,full_blocks =>:14,full_bytes => :15); end;' using in sowner,in tname,in seg_type, out unformatted_blocks,out unformatted_bytes, out fs1_blocks, out fs1_bytes, out fs2_blocks, out fs2_bytes, out fs3_blocks, out fs3_bytes, out fs4_blocks, out fs4_bytes, out full_blocks, out full_bytes;
elsif seg_type='INDEX' then
dbms_output.put_line(' INDEX .....');
execute immediate 'begin dbms_space.SPACE_USAGE(segment_owner=> :1,segment_name=>:2,segment_type =>:3,unformatted_blocks =>:4,unformatted_bytes =>:5,fs1_blocks =>:6,fs1_bytes =>:7,fs2_blocks =>:8,fs2_bytes =>:9,fs3_blocks =>:10, fs3_bytes =>:11,fs4_blocks => :12,fs4_bytes => :13,full_blocks =>:14,full_bytes => :15); end;' using in sowner,in tname,in seg_type, out unformatted_blocks,out unformatted_bytes, out fs1_blocks, out fs1_bytes, out fs2_blocks, out fs2_bytes, out fs3_blocks, out fs3_bytes, out fs4_blocks, out fs4_bytes, out full_blocks, out full_bytes;
end if;

free_bytes := fs1_bytes+fs2_bytes+fs3_bytes+fs4_bytes;

insert into TB_SPACE_USAGE
(
Towner,tname,ttype,pname,tsname,unformatted_blocks,unformatted_bytes,fs1_blocks,fs1_bytes,fs2_blocks ,fs2_bytes,fs3_blocks ,fs3_bytes ,fs4_blocks ,
fs4_bytes,full_blocks ,full_bytes ,free_bytes,segment_space
)
values
(
sowner,tname,seg_type,pname,tsname,unformatted_blocks,unformatted_bytes,fs1_blocks,fs1_bytes,fs2_blocks ,fs2_bytes,fs3_blocks ,fs3_bytes ,
fs4_blocks ,fs4_bytes,full_blocks ,full_bytes ,free_bytes,vspace
);
commit;

end loop;
close c1;
END;
/

 exec PRC_find_fragmentation;

-- Fragmentação por tipo de segmento:
   select ttype tipo_segmento,round(sum(free_bytes)/1024/1024/1024,2) total_fragmentado_gb
     from TB_SPACE_USAGE
    group by ttype;