CREATE OR REPLACE PROCEDURE  sys.alter_triggers_fks (p_owner IN varchar2, p_table IN varchar2, p_operation IN char) as

  type type_constraints is REF CURSOR;
  type type_triggers is REF CURSOR;
  t_constraints type_constraints;
    r_constraint dba_constraints%ROWTYPE;
  t_triggers type_triggers;
    r_trigger dba_triggers%ROWTYPE;
  v_owner  VARCHAR2(100) := p_owner;
  v_table VARCHAR2(100) := p_table;
  v_operation VARCHAR2(100) := p_operation;
  v_owner_table VARCHAR2(4000);
  v_command VARCHAR2(4000);
  v_command2 VARCHAR2(4000);
  i NUMBER;

BEGIN
  
  --v_owner := 'CLW_P01_EPM';
  --v_table := 'IMP_ENTITY_PARAM';
  v_owner_table := v_owner || '.' || v_table;

  IF v_operation = 'D' THEN

      dbms_output.put_line(CHR(10));
      dbms_output.put_line('CONSTRAINTS'); 
      dbms_output.put_line(CHR(10));
  
-- CONSTRAINTS
    
      OPEN t_constraints FOR
      select * 
      from dba_constraints 
      where constraint_type='R' 
      and owner=v_owner
      and table_name=v_table
      and STATUS='ENABLED';
    
    LOOP
    FETCH t_constraints INTO r_constraint;
  
    EXIT WHEN t_constraints%NOTFOUND;
  
      v_command :='alter table '  || v_owner_table || ' disable novalidate constraint ' || r_constraint.CONSTRAINT_NAME || ';';
  
      dbms_output.put_line(v_command);
      execute immediate v_command;
  
    END LOOP;
    CLOSE  t_constraints;

  dbms_output.put_line(CHR(10));
  dbms_output.put_line('TRIGGERS'); 
  dbms_output.put_line(CHR(10));

--TRIGGERS
    OPEN t_triggers FOR
      select * 
      from dba_triggers 
      where table_owner=v_owner
      and table_name=v_table
      and status='ENABLED';
    
    LOOP
    FETCH t_triggers INTO r_trigger;
  
    EXIT WHEN t_triggers%NOTFOUND;
  
      v_command2 :='alter trigger '  || v_owner || '.' || r_trigger.TRIGGER_NAME || ' disable;';
  
      dbms_output.put_line(v_command2);
      execute immediate v_command2;
  
    END LOOP;
    CLOSE  t_triggers;

  ELSIF v_operation = 'E' THEN


      dbms_output.put_line(CHR(10));
      dbms_output.put_line('CONSTRAINTS'); 
      dbms_output.put_line(CHR(10));
  
-- CONSTRAINTS
    
      OPEN t_constraints FOR
      select * 
      from dba_constraints 
      where constraint_type='R' 
      and owner=v_owner
      and table_name=v_table;
    
    LOOP
    FETCH t_constraints INTO r_constraint;
  
    EXIT WHEN t_constraints%NOTFOUND;
  
      v_command :='alter table '  || v_owner_table || ' enable novalidate constraint ' || r_constraint.CONSTRAINT_NAME || ';';
  
      dbms_output.put_line(v_command);
      execute immediate v_command;
  
    END LOOP;
    CLOSE  t_constraints;

  dbms_output.put_line(CHR(10));
  dbms_output.put_line('TRIGGERS'); 
  dbms_output.put_line(CHR(10));

--TRIGGERS
    OPEN t_triggers FOR
      select * 
      from dba_triggers 
      where table_owner=v_owner
      and table_name=v_table;
    
    LOOP
    FETCH t_triggers INTO r_trigger;
  
    EXIT WHEN t_triggers%NOTFOUND;
  
      v_command2 :='alter trigger '  || v_owner || '.' || r_trigger.TRIGGER_NAME || ' enable;';
  
      dbms_output.put_line(v_command2);
      execute immediate v_command2;
  
    END LOOP;
    CLOSE  t_triggers;

  ELSE

   dbms_output.put_line('This procedure should be called using 3 parameters');
   dbms_output.put_line('Parameter 1 is owner, Parameter 2 is table name and Parameter 3 can be E for ENABLE or D for Disable');
   dbms_output.put_line('exec sys.alter_triggers_fks(Parameter1,Parameter2,Parameter3);');

  END IF;

END;
/
