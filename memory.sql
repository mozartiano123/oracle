memory.sql

-- changes in the pools sizes

set pages 999 
set lines 130 
col component for a25 head "Component" 
col status format a10 head "Status" 
col initial_size for 999,999,999,999 head "Initial" 
col parameter for a25 heading "Parameter" 
col final_size for 999,999,999,999 head "Final" 
col changed head "Changed At" 

select component, parameter, initial_size, final_size, status, 
to_char(end_time ,'mm/dd/yyyy hh24:mi:ss') changed 
from v$memory_resize_ops 
order by 6 
/


-- Get shared pool utilization

--This script estimates Shared Pool utilization.

REM If running Shared Server uncomment the mts calculation and output commands.
SET serveroutput on;

DECLARE
   object_mem       NUMBER;
   shared_sql       NUMBER;
   cursor_mem       NUMBER;
   mts_mem          NUMBER;
   used_pool_size   NUMBER;
   free_mem         NUMBER;
   pool_size        VARCHAR2 (512);                     -- Now from V$SGASTAT
BEGIN
   -- Stored objects (packages, views)
   SELECT SUM (sharable_mem)
     INTO object_mem
     FROM v$db_object_cache;

   -- Shared SQL -- need to have additional memory if dynamic SQL used
   SELECT SUM (sharable_mem)
     INTO shared_sql
     FROM v$sqlarea;

   -- User Cursor Usage -- run this during peak usage.
   --  assumes 250 bytes per open cursor, for each concurrent user.
   SELECT SUM (250 * users_opening)
     INTO cursor_mem
     FROM v$sqlarea;

   -- For a test system -- get usage for one user, multiply by # users
   -- select (250 * value) bytes_per_user
   -- from v$sesstat s, v$statname n
   -- where s.statistic# = n.statistic#
   -- and n.name = 'opened cursors current'
   -- and s.sid = 25;  -- where 25 is the sid of the process
   -- MTS memory needed to hold session information for shared server users
   -- This query computes a total for all currently logged on users (run
   --  multiply by # users.
   SELECT SUM (VALUE)
     INTO mts_mem
     FROM v$sesstat s, v$statname n
    WHERE s.statistic# = n.statistic# AND n.NAME = 'session uga memory max';

   -- Free (unused) memory in the SGA: gives an indication of how much memory
   -- is being wasted out of the total allocated.
   SELECT BYTES
     INTO free_mem
     FROM v$sgastat
    WHERE NAME = 'free memory' AND pool = 'shared pool';

   -- For non-MTS add up object, shared sql, cursors and 20% overhead.
   used_pool_size := ROUND (1.2 * (object_mem + shared_sql + cursor_mem));

   -- For MTS mts contribution needs to be included (comment out previous line)
   -- used_pool_size := round(1.2*(object_mem+shared_sql+cursor_mem+mts_mem));
   SELECT SUM (BYTES)
     INTO pool_size
     FROM v$sgastat
    WHERE pool = 'shared pool';

   -- Display results
   DBMS_OUTPUT.put_line ('Shared Pool Memory Utilization Report');
   DBMS_OUTPUT.put_line ('Obj mem:  ' || TO_CHAR (object_mem) || ' bytes');
   DBMS_OUTPUT.put_line ('Shared sql:  ' || TO_CHAR (shared_sql) || ' bytes');
   DBMS_OUTPUT.put_line ('Cursors:  ' || TO_CHAR (cursor_mem) || ' bytes');
   -- dbms_output.put_line ('MTS session: '||to_char (mts_mem) || ' bytes');
   DBMS_OUTPUT.put_line (   'Free memory: '
                         || TO_CHAR (free_mem)
                         || ' bytes '
                         || '('
                         || TO_CHAR (ROUND (free_mem / 1024 / 1024, 2))
                         || 'MB)'
                        );
   DBMS_OUTPUT.put_line (   'Shared pool utilization (total):  '
                         || TO_CHAR (used_pool_size)
                         || ' bytes '
                         || '('
                         || TO_CHAR (ROUND (used_pool_size / 1024 / 1024, 2))
                         || 'MB)'
                        );
   DBMS_OUTPUT.put_line (   'Shared pool allocation (actual):  '
                         || pool_size
                         || ' bytes '
                         || '('
                         || TO_CHAR (ROUND (pool_size / 1024 / 1024, 2))
                         || 'MB)'
                        );
   DBMS_OUTPUT.put_line (   'Percentage Utilized:  '
                         || TO_CHAR (ROUND (used_pool_size / pool_size * 100))
                        );
END;
/