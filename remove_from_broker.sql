#######################################
## Remove a Data Guard Configuration ##
#######################################

1. Put Primary Database in Maximum Performance Mode (Primary side)

DGMGRL> EDIT CONFIGURATION SET PROTECTION MODE AS MAXPERFORMANCE;

2. Remove Data Guard Broker Configuration (Primary side)

DGMGRL> REMOVE CONFIGURATION;

3. Unset Data Guard-specific Initialization Parameters (Primary side)

Unset/Remove following Initialization Parameters from the (S)PFILE of the Primary Database:

alter system reset LOG_ARCHIVE_CONFIG scope=spfile;
alter system reset DB_FILE_NAME_CONVERT scope=spfile;
alter system reset LOG_FILE_NAME_CONVERT scope=spfile;
alter system reset LOG_ARCHIVE_DEST_2 scope=spfile; -- confirmar que é este o parametro com a configuração do broker
alter system reset LOG_ARCHIVE_DEST_STATE_2 scope=spfile; -- confirmar que é este o parametro com a configuração do broker
alter system reset DG_BROKER_START scope=spfile;
alter system reset DG_BROKER_CONFIG_FILE1 scope=spfile;
alter system reset DG_BROKER_CONFIG_FILE2 scope=spfile;
alter system reset STANDBY_ARCHIVE_DEST scope=spfile;
alter system reset STANDBY_FILE_MANAGEMENT scope=spfile;
alter system reset FAL_SERVER scope=spfile;
alter system reset FAL_CLIENT scope=spfile;

4. Drop Standby Redologs from the Primary Database (Both Primary and Standby sides)

alter database recover managed standby database cancel;

alter system set dg_broker_start=false scope=both;



5. Drop Standby Redologs from the Primary Database (Both Primary and Standby sides)

SQL> SELECT 'ALTER DATABASE DROP STANDBY LOGFILE GROUP '||GROUP#||';' FROM V$STANDBY_LOG;

Execute the output

6. Drop the Data Guard Broker Configuration Files if used. (Both Primary and Standby sides)

SQL> show parameter DG_BROKER_CONFIG;

Remove the configuration files


#######################################
## Convert DB to Standalone Database ##
#######################################

1- Remover a BD do CRS.

SQL> show parameter db%name
SQL> create pfile='/home/oracle/initDEVMETA41.ora' from spfile;
SQL> show parameter spfile;
SQL> alter system set cluster_database=false scope=spfile;
SQL> exit

srvctl stop database -d DEVMETA4STB
srvctl remove database -d DEVMETA4STB
export ORACLE_SID=DEVMETA41

spfile='+DATAC2/DEVMETA4STB/PARAMETERFILE/spfile.461.1091441763'



2.  Once the standby is removed, it must be activated to be opened as a primary database:    
$  sqlplus / as sysdba

SQL>  STARTUP MOUNT;
SQL>  ALTER DATABASE ACTIVATE PHYSICAL STANDBY DATABASE;
SQL>  SHUTDOWN IMMEDIATE;
SQL>  STARTUP;


3. This database is open in read-write mode and can now be used as a standalone database. Save the DDL and Drop the DB links.

SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON


SELECT DBMS_METADATA.get_ddl ('DB_LINK', db_link, owner)
FROM   dba_db_links;


SET PAGESIZE 49999 LINESIZE 1000 FEEDBACK ON VERIFY ON


4.  Run NID

$ sqlplus / as sysdba
SQL> shutdown immediate
SQL> startup mount;
SQL> exit
$ nid target=/ 

$ sqlplus / as sysdba
SQL> startup nomount
SQL> alter system set db_name=DEVMETA4 scope=spfile;
SQL> alter system set db_unique_name=DEVMETA4 scope=spfile;
SQL> shutdown abort;
SQL> startup mount
SQL> alter database open resetlogs;
SQL> shutdown immediate
SQL> startup

5. Add back to  crs .


SQL> alter database add logfile thread 2 group 21 ('+DATAC2','+RECOC2') size 200M reuse;
SQL> alter database add logfile thread 2 group 22 ('+DATAC2','+RECOC2') size 200M reuse;
SQL> alter database add logfile thread 2 group 23 ('+DATAC2','+RECOC2') size 200M reuse;

SQL> ALTER DATABASE ENABLE PUBLIC THREAD 2; 

SQL> alter system set cluster_database=true scope=spfile;

SQL> shutdown immediate;

srvctl add database -db DEVMETA4 -oraclehome  /u01/app/oracle/product/12.2.0.1/devmeta4 -spfile '+DATAC2/DEVMETA4STB/PARAMETERFILE/spfile.461.1091441763' -dbtype RAC
srvctl add instance -db DEVMETA4 -instance DEVMETA41 -n lpexadev01-101
srvctl add instance -db DEVMETA4 -instance DEVMETA42 -n lpexadev02-101
srvctl status database -db DEVMETA4
srvctl start instance -db DEVMETA4 -instance DEVMETA41
srvctl start instance -db DEVMETA4 -instance DEVMETA42

6.  Create restore point

SQL> alter database flashback on;
SQL> create restore point MIG guarantee flashback database;








CBAMCDB

 	CREATE DATABASE LINK "SYS_HUB.OGMA.PT"
    USING 'CBAMCDB'

	CREATE PUBLIC DATABASE LINK "SIGMA360.OGMA.PT"
    CONNECT TO "IMPACTO" IDENTIFIED BY VALUES ':1'
    USING 'NOVADEV'


PONTEST

	CREATE DATABASE LINK "SYS_HUB"
    USING 'PONDEVCD'


DEVMETA4 

	CREATE DATABASE LINK "META4SGPA"
   	CONNECT TO "META4SIGMA" IDENTIFIED BY VALUES ':1'
   	USING 'NOVADEV'


    CREATE DATABASE LINK "META4SIGMA"
   	CONNECT TO "META4SIGMA" IDENTIFIED BY VALUES ':1'
   	USING 'NOVADEV'


    CREATE DATABASE LINK "QUAD_CONSULTA"
    CONNECT TO "MCONSULTA" IDENTIFIED BY VALUES ':1'
    USING '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS =
        (COMMUNITY = tcp.world)
        (PROTOCOL = TCP)
        (Host = ed101dbadm01)
        (Port = 1521)
      )
    )
    (CONNECT_DATA =
      (SID = QUADPROD1)
      )
    )
   '

  CREATE DATABASE LINK "META4SGPA"
   CONNECT TO "META4SIGMA" IDENTIFIED BY VALUES ':1'
   USING '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS =
        (COMMUNITY = tcp.world)
        (PROTOCOL = TCP)
        (Host = sdbdev2.ogma.pt)
        (Port = 1608)
      )
    )
    (CONNECT_DATA =
      (SID = NOVADEV1)
    )
  )
'


   CREATE DATABASE LINK "META4SIGMA"
   CONNECT TO "META4SIGMA" IDENTIFIED BY VALUES ':1'
   USING '(DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS =
        (COMMUNITY = tcp.world)
        (PROTOCOL = TCP)
        (Host = sbddev2.ogma.pt)
        (Port = 1608)
      )
    )
    (CONNECT_DATA =
      (SID = NOVADEV1)
    )
  )
'
