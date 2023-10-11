col plan format a80
col object_owner format a10
col TO_CHAR(TIMESTAMP,'DD-MM-YYYYHH24:MI:SS') for a20
set lines 500 pages 1000

select to_char (timestamp, 'dd-mm-yyyy hh24:mi:ss'),
       plan_hash_value, 
       object_owner, object_name, substr( rpad(' ',2*depth) ||
            replace(operation || ' ' ||
            object_owner || ' ' ||
            object_name || ' ' ||
            options, '  ', ' '),
            1,100
      )     plan, cost, cardinality
from
      dba_hist_sql_plan
where
      sql_id = '175skv62rkgkv'
order by
      to_char (timestamp, 'dd-mm-yyyy hh24:mi:ss'),
      plan_hash_value,
      id
/


