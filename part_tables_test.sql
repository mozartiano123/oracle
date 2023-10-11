CREATE TABLE invoices
(invoice_no    NUMBER NOT NULL,
 invoice_date  DATE   NOT NULL,
 comments      VARCHAR2(500))
PARTITION BY RANGE (invoice_date)
(PARTITION invoices_q1 VALUES LESS THAN (TO_DATE('01/04/2001', 'DD/MM/YYYY')) TABLESPACE users,
 PARTITION invoices_q2 VALUES LESS THAN (TO_DATE('01/07/2001', 'DD/MM/YYYY')) TABLESPACE users,
 PARTITION invoices_q3 VALUES LESS THAN (TO_DATE('01/09/2001', 'DD/MM/YYYY')) TABLESPACE users,
 PARTITION invoices_q4 VALUES LESS THAN (TO_DATE('01/01/2002', 'DD/MM/YYYY')) TABLESPACE users)
/


CREATE INDEX invoices_idx2 ON invoices (invoice_date)
GLOBAL --PARTITION BY RANGE (invoice_date)
TABLESPACE users 
  /

CREATE INDEX invoices_idx20 ON invoices (invoice_date, invoice_no)
LOCAL --PARTITION BY RANGE (invoice_date)
TABLESPACE users 
  /


CREATE INDEX invoices_idx40 ON invoices (invoice_no)
GLOBAL -- PARTITION BY RANGE (invoice_date)
TABLESPACE users 
/

CREATE INDEX invoices_idx3 ON invoices (invoice_date) LOCAL tablespace users
/begin

for i in 1.. 10000
loop
insert into invoices (invoice_no,invoice_date,comments)
values (i,to_date('01/01/2002','DD/MM/YYYY')-i,'TESTANDO ESSA BUDEGA');
end loop;
end;
/

CREATE INDEX invoices_idx4 ON invoices (invoice_no) LOCAL TABLESPACE users
/



delete From DS_AMS_M2M_USAGE where FILEID = :1

	select distinct FILEID from sprint_usage.DS_AMS_M2M_USAGE;


	Execution Plan
----------------------------------------------------------
Plan hash value: 3528115336

---------------------------------------------------------------------------------------------------------------------------------------------------
| Id  | Operation                 | Name                     | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |    TQ  |IN-OUT| PQ Distrib |
---------------------------------------------------------------------------------------------------------------------------------------------------
|   0 | DELETE STATEMENT          |                          | 45012 |   263K|    42   (0)| 00:00:01 |       |       |        |      |            |
|   1 |  DELETE                   | DS_AMS_M2M_USAGE         |       |       |            |          |       |       |        |      |            |
|   2 |   PX COORDINATOR          |                          |       |       |            |          |       |       |        |      |            |
|   3 |    PX SEND QC (RANDOM)    | :TQ10000                 | 45012 |   263K|    42   (0)| 00:00:01 |       |       |  Q1,00 | P->S | QC (RAND)  |
|   4 |     PX PARTITION RANGE ALL|                          | 45012 |   263K|    42   (0)| 00:00:01 |     1 |    95 |  Q1,00 | PCWC |            |
|*  5 |      INDEX RANGE SCAN     | IDX_AMS_M2M_USAGE_FILEID | 45012 |   263K|    42   (0)| 00:00:01 |     1 |    95 |  Q1,00 | PCWP |            |
---------------------------------------------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   5 - access("FILEID"=5050739)



Execution Plan
----------------------------------------------------------
Plan hash value: 2033571934

-----------------------------------------------------------------------------------------------------------------
| Id  | Operation            | Name                     | Rows  | Bytes | Cost (%CPU)| Time     | Pstart| Pstop |
-----------------------------------------------------------------------------------------------------------------
|   0 | DELETE STATEMENT     |                          | 85833 |   502K|   400   (1)| 00:00:05 |       |       |
|   1 |  DELETE              | DS_AMS_M2M_USAGE         |       |       |            |          |       |       |
|   2 |   PARTITION RANGE ALL|                          | 85833 |   502K|   400   (1)| 00:00:05 |     1 |    95 |
|*  3 |    INDEX RANGE SCAN  | IDX_AMS_M2M_USAGE_FILEID | 85833 |   502K|   400   (1)| 00:00:05 |     1 |    95 |
-----------------------------------------------------------------------------------------------------------------

Predicate Information (identified by operation id):
---------------------------------------------------

   3 - access("FILEID"=4906444)


 CREATE MATERIALIZED VIEW LOG ON "SPRINT_USAGE"."DS_AC6_ELA";


 DROP MATERIALIZED VIEW LOG on  "SPRINT_USAGE"."DS_AC6_ELA"

 DATABASE SOFTWARE


ALTER MATERIALIZED VIEW LOG ON "SPRINT_USAGE"."DS_AC6_ELA"
  PCTFREE 25
  PCTUSED 40;


INSERT INTO tmp_ac6_summ_tc (report_date, s_type, ams_trans_count, ams_records, ams_duration, act_trans_count,act_records, act_minutes, ac6_trans_count, 
	md_in, md_in_vol , md_ems_errors,md_ems_errors_vol, md_gen, md_gen_vol, md_drops, md_drops_vol, md_out, md_out_vol,md_dups, md_dups_vol, non_match_drops, 
	non_match_drops_vol, billable_recs, file2e_input, file2e_success, file2e_rejects,file2e_dups, audit_0, audit_0_vol, audit_1, audit_1_vol, audit_2, 
	audit_2_vol, audit_3, audit_3_vol, audit_4, audit_4_vol,md_sent_to_tc, md_none_errors)
SELECT report_date,
       switch_type,
       SUM(ams_trans_count),
       SUM(ams_records),
       SUM(ams_duration),
       SUM(act_trans_count) act_trans_count,
       SUM(act_records),
       SUM(act_minutes),
       SUM(ac6_trans_count) ac6_trans_count,
       SUM(md_in),
       SUM(md_in_vol),
       SUM(md_ems_errors),
       SUM(md_ems_errors_vol),
       SUM(md_gen),
       SUM(md_gen_vol),
       SUM(md_drops),
       SUM(md_drops_vol),
       SUM(md_out),
       SUM(md_out_vol),
       SUM(md_dups),
       SUM(md_dups_vol),
       SUM(md_none_drops),
       SUM(non_match_drops_vol),
       SUM(billable_records),
       SUM(file2e_input) file2e_input,
       SUM(file2e_success) file2e_success,
       SUM(file2e_rejects),
       sum(file2e_dups) file2e_dups,
       SUM(audit_0),
       SUM(audit_0_vol),
       SUM(audit_1),
       SUM(audit_1_vol),
       SUM(audit_2),
       SUM(audit_2_vol),
       SUM(audit_3),
       SUM(audit_3_vol),
       SUM(audit_4),
       SUM(audit_4_vol) ,
       sum(md_sent_to_tc) md_sent_to_tc,
       SUM(md_none_errors) md_none_errors
FROM
  (SELECT NVL(ams_process_date, TRUNC(sent_to_itds_date)) report_date,
          CASE
              WHEN s.switch_type = 'eHRPD' THEN 'LTE'
              ELSE s.switch_type
          END switch_type ,
          SUM(DECODE(ams_fileid,NULL,0,1)) ams_trans_count,
          SUM(ams_records) ams_records,
          SUM(ams_duration) ams_duration,
          SUM(DECODE(actlog_id,NULL,0,1)) act_trans_count,
          SUM(act_records) act_records,
          SUM(act_minutes) act_min utes,
                                   SUM(CASE
                                           WHEN a.fid<=9900
                                                AND ac6bal_id IS NOT NULL THEN 1
                                           ELSE 0
                                       END) ac6 _trans_count ,
                                                SUM(md_in) md_in,
                                                SUM(md_in) cons_md_in,
                                                SUM(md_in_vol) md_in_vol ,
                                                SUM(md_ems_errors) md_ems_errors,
                                                SUM(md_ems_errors_vo l) md_ems_errors_vol,
                                                SUM(md_gen) md_gen,
                                                SUM(md_gen_vol) md_gen_vol,
                                                SUM(md_dro ps) md_drops,
                                                SUM(md_drops_vol) md_drops_vol,
                                                SUM(md_out) md_out,
                                                SUM(md_out_vol) md_out_vol ,
                                                SUM(md_dups) md_dups,
                                                SUM(md_dups_vol) md_dups_vol,
                                                SU M(md_none_drops) md_none_drops,
                                                   SUM(non_match_drops_vol) non_match_drops_vol,
                                                   SU M(billable_records) billable_records ,
                                                      SUM(file2e_rejects) file2e_rejects ,
                                                      SUM(file2e_input) file2e_input,
                                                      SUM(file2e_success) fi le2e_success,
                                                                             sum(file2e_dups) file2e_dups ,
                                                                             SUM(audit_0) audit_0,
                                                                             SUM(audit_0_vol) audit_0_vol,
                                                                             SU M(audit_1) audit_1 ,
                                                                                SUM(audit_1_vol) audit_1_vol,
                                                                                SUM(audit_2) audit_2,
                                                                                SU M(audit_2_vol) audit_2_vol,
                                                                                   SUM(audit_3) audit_3,
                                                                                   SUM(audit_3_vol) audit_3_vol,
                                                                                   SUM(audit_4) audit_4,
                                                                                   SUM(audit_4_vol) audit_4_vol --,SUM(case when a.fid >=9901 then 1 else 0 end) cons_t
rans_count --,SUM(CASE WHEN a.fid>=9901 AND ac6bal_id IS NOT NULL
THEN 1 ELSE 0 END) cons_ac6_trans_count ,
     SUM(md_sent_to_tc) md_sent_to_tc,
     SUM(md_none_errors) md_none_errors
FROM ds_ams_compare_tc_3g_ws a,
     lu_switch_name s
WHERE a.fid_id = s.fid_id
  AND reseller_id IS NULL
  AND NVL(ams_process_date, sent_to_itds_date) IN
    (SELECT *
     FROM TABLE(:nt))
GROUP BY NVL(ams_process_date, TRUNC(sent_to_itds_date)),
         s.swi tch_type /*UNION ALL
                   SELECT 'EMS' switch_type, 0 ams_trans_count, 0 ams_records, 0
 ams_duration, 0 act_trans_count
                         ,SUM(gecompress) act_records, 0, 0 ac6_trans_count
                         ,SUM(md_in) md_in, 0 cons_md_in, SUM(md_in_vol) md_in_v
ol, SUM(md_ems_errors) md_ems_errors, SUM(md_ems_errors_vol) md_ems_errors_vol,
SUM(md_gen) md_gen, SUM(md_gen_vol) md_gen_vol, SUM(md_drops) md_drops, SUM(md_d
rops_vol) md_drops_vol, SUM(md_out) md_out, SUM(md_out_vol) md_out_vol
                         ,SUM(md_dups) md_dups, SUM(md_dups_vol) md_dups_vol, 0,
 0, SUM(billable_records) billable_records, SUM(rater_rejected_records) file2e_r
ejects, 0, 0, 0
                         ,0,0, SUM(audit_1) audit_1, SUM(audit_1_vol) audit_1_vo
l, SUM(audit_2) audit_2, SUM(audit_2_vol) audit_2_vol, SUM(audit_3) audit_3, SUM
(audit_3_vol) audit_3_vol, SUM(audit_4) audit_4, SUM(audit_4_vol) audit_4_vol
                         --,0 cons_trans_count, 0  cons_ac6_trans_count
                         , 0 md_sent_to_tc
                     FROM ems_compare_tc_3g
                    WHERE process_date BETWEEN :start_date AND :end_date */ )
GROUP BY report_date,
         switch_type








INSERT INTO sprint_usage.DS_AC6_ELA (FILEID, REPORT_DATE, SOURCE_ID, TOKEN_ID, NETWORK_ELEMENT, FID, FID_ID, CYCLE_CODE, CYCLE_MONTH, CYCLE_YEAR, SERVICE, EVENT_TYPE)
VALUES (546508,
        '05-APR-17',
        4,
        3416364459361304580,
        'QUEIJOUAI',
        9887,
        23263,
        31,
        4,
        2017,
        78,
        'CLASSIC_UPDATE')

SELECT FILEID || ',' || REPORT_DATE || ',' || SOURCE_ID || ',' || TOKEN_ID || ',' || NETWORK_ELEMENT || ',' || FID || ',' || FID_ID || ',' || 
CYCLE_CODE || ',' || CYCLE_MONTH || ',' ||  CYCLE_YEAR || ',' || SERVICE || ',' || EVENT_TYPE
FROM sprint_usage.DS_AC6_ELA
WHERE fileid = 546508 and rownum <2;



delete from sprint_usage.DS_AC6_ELA where NETWORK_ELEMENT='QUEIJOUAI';