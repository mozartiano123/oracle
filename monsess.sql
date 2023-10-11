--Monitor sessions
set serveroutput on
set echo off
set feedback off
set heading off

DECLARE

cursor c_rpt is
                select count(*) cnt, status, machine from gv$session group by status, machine order by machine;

v_proc  number(5,0);
v_sess  number(5,0);
v_count number(5,0);
v_name  varchar2(10);
v_rpt c_rpt%ROWTYPE;

BEGIN

        select value into v_proc from v$parameter where name='processes';
        select count(*) into v_sess from v$session;
        select name into v_name from v$database;

        v_count := round((v_sess/v_proc)*100);


        IF v_count > 70 and v_count < 90 THEN

                dbms_output.put_line (v_name || ' -  # of Sessions WARNING.');

                for v_rpt in c_rpt loop

                        dbms_output.put_line('Machine ' || v_rpt.machine || ' has ' || v_rpt.cnt || ' ' || v_rpt.status || ' session(s).');
                end loop;

                dbms_output.put_line ('TOTAL                     ' || v_sess || '  .');

        ELSIF v_count >= 90 then


                dbms_output.put_line (v_name || ' -  # of Sessions WARNING.');


                for v_rpt in c_rpt loop

                        dbms_output.put_line('Machine ' || v_rpt.machine || ' has ' || v_rpt.cnt || ' ' || v_rpt.status || ' session(s).');
             
                end loop;

                dbms_output.put_line ('TOTAL                     ' || v_sess || '  .');


                -- session below was commented out because it is only useful for tests.
        --ELSE

                --UTL_FILE.PUT_LINE(fileHandler,v_name || ' -  # of Sessions NORMAL.');
                --dbms_output.put_line (v_name || ' -  # of Sessions NORMAL.');

                --for v_rpt in c_rpt loop
                -- UTL_FILE.PUT_LINE(fileHandler,'Machine ' || v_rpt.machine || ' has ' || v_rpt.cnt || ' ' || v_rpt.status || ' session(s).');
                --UTL_FILE.PUT_LINE(fileHandler,'');
                -- dbms_output.put_line('Machine ' || v_rpt.machine || ' has ' || v_rpt.cnt || ' ' || v_rpt.status || ' session(s).');

                 -- end loop;


        end if;
END;
/
