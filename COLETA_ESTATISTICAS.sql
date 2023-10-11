  CREATE OR REPLACE NONEDITIONABLE PROCEDURE "SYS"."STOCOLETAESTATISTICAS" is

v_part_pref number := 0;

cursor c1 is
select OWNER,TABLE_NAME,NUM_ROWS,PARTITIONED
  from dba_tables
where TEMPORARY = 'N' AND (IOT_TYPE != 'IOT_OVERFLOW' OR IOT_TYPE IS NULL)
   AND owner not in ('SYS','SYSTEM','DBSNMP','BACKUP')
   AND (OWNER,TABLE_NAME) not in (select OWNER,TABLE_NAME from dba_tab_statistics where stattype_locked is not null)
   AND (OWNER,TABLE_NAME) not in (select owner,table_name from DBA_EXTERNAL_TABLES)
order by NUM_ROWS;

procedure prc_ins_log(own_tab_rows varchar2,ctl number default 1) is
begin
if ctl=1 then
  insert into LogColetaEstatisticas values(sysdate, 'Coleta stats semanal -> '||own_tab_rows);
else
  insert into LogColetaEstatisticas values(sysdate, 'ERROR -> ' || own_tab_rows);
end if;
  commit;
end;

begin
  execute immediate 'truncate table LogColetaEstatisticas';

  begin
    for i in c1 loop
      begin
      prc_ins_log('INI -> ' || i.owner||' | '||i.table_name||' | '||i.num_rows);

     if (i.PARTITIONED = 'YES') then
         select count(*)
           into v_part_pref
           from dba_tab_stat_prefs
          where owner = i.owner
            and table_name = i.table_name;

      if v_part_pref = 0 then
         dbms_stats.set_table_prefs(i.owner,i.table_name,'incremental','true');
      end if;
      end if;

        dbms_stats.GATHER_TABLE_STATS(ownname => '"' || i.OWNER ||'"',
                                      tabname => '"' || i.TABLE_NAME ||'"',
                                      --estimate_percent => 100,
                                      estimate_percent => dbms_stats.auto_sample_size,
                                      degree => 8,
                                      cascade => true,
                                      method_opt => 'for all columns size auto'
                                      );

      prc_ins_log('FIM');

      exception when others then prc_ins_log(own_tab_rows => SQLCODE || ' - ' || SQLERRM, ctl => 0);
      end;
    end loop;

     prc_ins_log('INI -> DICTIONARY,FIXED,SYSTEM');

     DBMS_STATS.GATHER_DICTIONARY_STATS;
     DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
                DBMS_STATS.GATHER_SYSTEM_STATS(interval => 60);

     prc_ins_log('FIM');

  exception when others then prc_ins_log(own_tab_rows => SQLCODE || ' - ' || SQLERRM, ctl => 0);
  end;
end;
/