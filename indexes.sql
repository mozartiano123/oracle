indexes.sql

select INDEX_OWNER, INDEX_NAME, TABLE_NAME, COLUMN_NAME, COLUMN_POSITION, DESCEND from dba_ind_columns where table_name='&tbl';

select segment_name, sum(bytes)/1048576 from dba_segments where segment_name='&idx'
group by segment_name;
