set serveroutput on

DECLARE

type curtype is ref cursor;
c2 curtype;
c3 curtype;
cursor c1 is select owner , table_name , constraint_name  , r_constraint_name , r_owner
from dba_constraints 
where r_constraint_name in 
(select constraint_name from dba_constraints 
where table_name in ('DOCUMENT','BILL','DOCUMENTMETADATA','DOCUMENTDATASTOREITEM','DOCUMENT_FACT','HISTORICUSAGE','HISTORICCHARGES') 
--where table_name = 'ORDER_VALIDATOR'
and constraint_type in ('P','U')
--and owner = 'BRITEBILL')
--and owner in ('BRITEBILL')) 
--and table_name in ('DOCUMENT','BILL','DOCUMENTMETADATA','DOCUMENTDATASTOREITEM','DOCUMENT_FACT','HISTORICUSAGE','HISTORICCHARGES')
;

v1 c1%rowtype;
v2 dba_cons_columns%rowtype;
v3 dba_cons_columns%rowtype;
a varchar2(4000);
b varchar2(4000);
c varchar2(4000);
d varchar2(4000);
do varchar2(4000);
dn varchar2(4000);
e varchar2(4000);
f varchar2(4000);
tsql varchar2(4000);
rsql varchar2(4000);

BEGIN

  dbms_output.put_line(chr(10));
  dbms_output.put_line('-- COMMANDS TO DROP FK CONSTRAINTS FROM THE TABLES;');
  dbms_output.put_line(chr(10));

   for v1 in c1 
  LOOP
    
    a := 'alter table ' || v1.owner || '.' || v1.table_name || ' drop constraint ' || v1.constraint_name  || ' ;';

    dbms_output.put_line(a);
    dbms_output.put_line(chr(10));

  END LOOP;


  dbms_output.put_line(chr(10));
  dbms_output.put_line('-- COMMANDS TO ADD FK CONSTRAINTS TO THE TABLES;');
  dbms_output.put_line(chr(10));

  for v1 in c1 
  LOOP
    
    a := 'alter table ' || v1.owner || '.' || v1.table_name || ' add constraint ' || v1.constraint_name  || ' foreign key (';

    tsql := 'select * from dba_cons_columns where constraint_name=''' || v1.constraint_name || ''' and owner='''|| v1.owner || ''' order by position';
    
      b := '';
      e := '';

      OPEN c2 for tsql; 
      LOOP
        FETCH c2 into v2;
              
    --      dbms_output.put_line(v2.constraint_name || ' ' || v2.column_name);
          EXIT WHEN c2%NOTFOUND;
          b := b || v2.column_name ;
          
          
          
          b := b || ', ' ;
         
      END LOOP;  
      CLOSE c2;

    c := substr(b,1,instr(b,',',-1,1)-1);
 --   dbms_output.put_line(c);
    
    select owner, table_name
    into do, dn
    from dba_constraints
    where constraint_name = v1.r_constraint_name
    and owner = v1.r_owner ;

    rsql := 'select * from dba_cons_columns where constraint_name=''' || v1.r_constraint_name || ''' and owner='''|| v1.r_owner || ''' order by position';

      OPEN c3 for tsql; 
      LOOP
        FETCH c3 into v3;
              
    --      dbms_output.put_line(v3.constraint_name || ' ' || v3.column_name);

          EXIT WHEN c3%NOTFOUND;
          e := e || v3.column_name ;
          
          
          
          e := e || ', ' ;
         
      END LOOP;  
      CLOSE c3;

    f := substr(e,1,instr(e,',',-1,1)-1);


    a := a || c ||  ') references ' || do || '.' || dn || '(' || f || ') enable novalidate;';

    dbms_output.put_line(a);
    dbms_output.put_line(chr(10));

  END LOOP;

END;
/

