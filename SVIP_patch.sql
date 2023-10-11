srvctl stop instance -d SVIP201 -i SVIP2013


cd /oracle/g01/software/rdbms
tar cvf - 11.2.0.4 | gzip > /oracle/g01/software/rdbms_11.2.0.4_080819.tar.gz

Ok, you are all set.  When you are ready to apply the patch (after the DB is brought down), simply do the following

export TMP=/oracle/g01/software/stage/OraInstall
export TMPDIR=$TMP
export TEMP=$TMP
/oracle/g01/software/rdbms/11.2.0.4/4q18_patch.ksh -invptr /oracle/g01/software/oraInventory11gRAC -silent -local -gh /oracle/g01/software/grid/11.2.0.4 -default

and it should install the patch
I have extracted the patch on all 3 nodes in the /oracle/g01/software/rdbms/11.2.0.4/Patches/LINUX/64 directory, 
and the patch source is in /oracle/g01/software/stage

srvctl start instance -d SVIP201 -i SVIP2013


30042880



PROD:plsli917:oracle:[/oracle/g01/software/rdbms]:SVIP2011:
$ opatch lsinventory | grep 30042880
Patch  30042880     : applied on Thu Aug 08 20:26:48 CDT 2019
     30042880

PROD:plsli918:oracle:[/oracle/g01/software/rdbms]:SVIP2012:
$ opatch lsinventory | grep 30042880
Patch  30042880     : applied on Thu Aug 08 20:39:18 CDT 2019



alter session set nls_date_format='dd-mon-yyyy hh24:mi:ss';
select startup_time, inst_id from gv$instance;


ALTER DATABASE RECOVER MANAGED STANDBY DATABASE  THROUGH ALL SWITCHOVER DISCONNECT  USING CURRENT LOGFILE;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE  CANCEL;



scn.sh
prg.sh
SQLNET  more session from client.

[‎7/‎9/‎2019 10:54 AM]  Campos, Rayder P [IBM Contractor for Sprint]:  
opatch lsinventory -detail 
SQL*Net more data from client  
 


# by SID  
SET LINES 150
set long 50000
col username for a15
col osuser for a15
col program for a25
col machine for a20
select s.PADDR,s.SID,s.SERIAL#,s.USERNAME,s.OSUSER,s.machine,
       s.PROGRAM, p.SPID, p.pga_used_mem,p.pga_alloc_mem,a.EXECUTIONS, a.sql_text
  from v$process p, v$sqlarea a, v$session s
  where p.addr = s.paddr
    and s.sql_address = a.address(+)
    and s.sql_hash_value = a.hash_value(+)
  and s.sid=&SID; 


  oradebug setospid 42029 (ospid)
  oradebug unlimit 
  oradebug event 10046 trace name context forever, level 12
  oradebug tracefile_name 
  oradebug event 10046 trace name context off 
 
 @/oracle/g01/bkup01/sqlt/sqlt/run/sqltxtrsby.sql 66f3a2m589q4m SQLTXPLAIN SVIP2012.VQS.NET

 10053 then 10046


/oracle/g01/admin/diag/rdbms/svip201/SVIP2012/trace/SVIP2012_ora_42029.trc