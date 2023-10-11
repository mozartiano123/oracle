tDatapoint


UPDATE dmd.DB_ATTR_VAL 
 SET ATTR_STATE='NORMAL', updt_freq_in_mins_qty = '10080'
 WHERE dbms_name = 'ORACLE'
 and pltfm_name = 'AIX'
 and srvr_name = 'PLSAA971' 
 and instc_name = 'ICEP1011' 
 and db_name = 'ICEP1011' 
 and attr_name = 'BACKUP_JOB'
/ 

-- accounts

select * from DATAPOINT_AUDIT.sprint_user_last_logon where lower(username) = lower('&nome');







select /*+Parallel(4) Index(a INVOICE_ITEM_1IX) Index(b ACCOUNT_DIM_IDX1)*/ 
 a.INV_CREATION_DATE,
  a.BAN,
  a.SUBSCRIBER_NO,
  a.LEASE_SEQ_NO,
  a.FEATURE_CODE,
  a.INV_STATUS,
  b.AR_WO_IND,
  a.INV_TYPE,
  SUM(a.CHARGES_AMT),
  SUM(a.BILL_CREDIT_AMT),
  SUM(a.BILL_DISCOUNT_AMT),
  SUM(a.TOT_PYM_CRD_AMT),
  SUM(a.TOT_GEN_CRD_AMT),
  SUM(a.ADJUSTED_AMT),
  SUM(a.INV_ADJUSTED_AMT),
  SUM(a.TAX_CITY_AMT),
  SUM(a.TAX_COUNTY_AMT),
  SUM(a.TAX_STATE_AMT),
  SUM(a.TAX_FEDERAL_AMT),
  SUM(a.TAX_MIS1_AMT),
  SUM(a.TAX_MIS2_AMT),
  SUM(a.TAX_ROAMING_AMT)
from NORSNAPADM.INVOICE_ITEM a
left outer join STORMADM.ACCOUNT_DIM b
on a.BAN              = b.BAN
where a.FEATURE_CODE like 'LSE%'
group by a.INV_CREATION_DATE,
  a.FEATURE_CODE,
  a.BAN,
  a.INV_STATUS,
  a.SUBSCRIBER_NO,
  b.AR_WO_IND,
  a.LEASE_SEQ_NO,
  a.INV_TYPE;

a INVOICE_ITEM_1IX b ACCOUNT_DIM_IDX1


