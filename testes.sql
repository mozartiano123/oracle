CREATE TABLE invoices
(invoice_no    NUMBER NOT NULL,
 invoice_date  DATE   NOT NULL,
 comments      VARCHAR2(500))
PARTITION BY RANGE (invoice_date)
(PARTITION invoices_q1 VALUES LESS THAN (TO_DATE('01/04/2001', 'DD/MM/YYYY')) TABLESPACE users,
 PARTITION invoices_q2 VALUES LESS THAN (TO_DATE('01/07/2001', 'DD/MM/YYYY')) TABLESPACE users,
 PARTITION invoices_q3 VALUES LESS THAN (TO_DATE('01/09/2001', 'DD/MM/YYYY')) TABLESPACE users,
 PARTITION invoices_q4 VALUES LESS THAN (TO_DATE('01/01/2002', 'DD/MM/YYYY')) TABLESPACE users);