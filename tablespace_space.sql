set lines 200
col file_name for a70
select file_id,file_name,bytes/1024/1024 mb,
AUTOEXTENSIBLE,INCREMENT_BY*(select value from v$parameter where name='db_block_size')/1024/1024 inc_mb,maxbytes/1024/1024 max_mb
  from dba_data_files 
  where tablespace_name like '&TABLESPACE' order by 2
  /
