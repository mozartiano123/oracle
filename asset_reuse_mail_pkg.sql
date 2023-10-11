--SETUP EMAIL FOR USE IN PL/SQL

To configure, you create an access control list (ACL), 
which is stored in Oracle XML DB. You can create the access control list by using Oracle XML DB itself, 
or by using the DBMS_NETWORK_ACL_ADMIN and DBMS_NETWORK_ACL_UTILITY PL/SQL packages. 
This guide explains how to use these packages to create and manage the access control list. 

To create an access control list by using Oracle XML DB and for general conceptual information about access control lists, 
see Oracle XML DB Developer's Guide.

This feature enhances security for network connections because it restricts the external network hosts that a 
database user can connect to using the PL/SQL network utility packages such as UTL_TCP, UTL_SMTP, UTL_MAIL, UTL_HTTP,
 and UTL_INADDR. Otherwise, an intruder who gained access to the database could maliciously attack the network, 
 because, by default, the PL/SQL utility packages are created with the EXECUTE privilege granted to PUBLIC users.
 
 
 title PL/SQL package to send emails
 
 Location* 	brazil
Asset Type* 	code
Asset Sub Type* 	code
Category* 	dbms
Technology* 	oracle


 asset description
This asset provides a PL/SQL package to send emails from the database using the network utility packages UTL_SMTP and UTL_TCP for Oracle11g or 12c.
The mail package can be very useful if any database job is scheduled using the Oracle Scheduler from package DBMS_SCHEDULER feature. Mail package may be called from a PL/SQL code to send a job completition email, a data report, an error alert or any other email message you need.
Using the new Oracle feature of fine-grained access to external network services provided by the access control list (ACL), it is possible to configure which services in a specific server and port a database user acntcou may access. This enhances security because even if you grant EXECUTE privileges to UTL_SMTP or UTL_TCP to an database user, they wont be able to access any network service if the proper configuration is not done in ACL.
It is recommendable that, to use this mail package, you only provide EXECUTE on UTL_TCP and UTL_SMTP to the database user account that will run the jobs (usually an application user or a dba user). Also, only the SMTP server and port of your database server should be added in the ACL list to the specific database user account that will sending the emails.
This asset provides details of how to identify the stmp service address and port for your database server, setup ACL and deploy the mail package.



target
For DBAs that would like to use database email functionality and/or application support that have PL/SQL code running in a database (although the deployment can only be done by a dba).



pre-requisities
- Oracle 11g or 12c
- The database server must have a SMTP service


infra needs
A SMTP server providing email services to the database server


assumptions
The mail package provides an easy way to send emails from the database by using PL/SQL code.

You may improve monitoring of jobs in DBA_SCHEDULER_JOBS by send emails to you team, DL or pager. You may also include a call to mail package in application PL/SQL code to report errors or tasks completitions.



benefits
This package provides the ability to send emails from Oracle Database. This can potentially improve database jobs monitoring and application PL/SQL codes executions.

effort to reuse: 2 hours



how to reuse
1) All sprint database servers probably will have a SMTP service set up in database servers. To verify the SMTP address and port, run the below command from AIX shell prompt.

echo "Test body" | mailx -v -s "FooBar"  <firstname.lastname>@sprint.com

Check the output. Right after your command, you should get a line like below

firstname.lastname@sprint.com... Connecting to <smtpserver>.corp.sprint.com. via relay...

Note down the <smtpserver>.corp.sprint.com. The port number is usually defaulted to 25.


2) Connect to your database. Identify the oracle username account that will be able to send emails.

--setting the grants
grant execute on UTL_TCP to <username>;
grant execute on UTL_SMTP to <username>;


3) Create an ACL list. The principal is an username that will own the ACL list. Better to user an account that only dbas have access.

BEGIN
  DBMS_NETWORK_ACL_ADMIN.create_acl (
    acl          => 'acl_for_smtp.xml',
    description  => 'ACL functionality for poh application',
    principal    => '<DBAUSERNAME>',
    is_grant     => TRUE,
    privilege    => 'connect',
    start_date   => SYSTIMESTAMP,
    end_date     => NULL);
 

COMMIT;
END;
/


4) Provide access to the users. You may add more users if needed, but keep it a short list. We dont want everyone being able to send emails via PL/SQL code.

BEGIN
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl => 'acl_for_smtp.xml',
    principal => '<USERNAME>',
    is_grant => TRUE,
    privilege => 'connect');
END;
/


5) Set the service that users will be able to use in the network. Below we will setup the database SMTP service

BEGIN
  DBMS_NETWORK_ACL_ADMIN.assign_acl (
    acl => 'acl_for_smtp',
    host => '<servername>.corp.sprint.com',
    lower_port => 25,
    upper_port => NULL);
COMMIT;

--If you wish to unassign run
BEGIN
  DBMS_NETWORK_ACL_ADMIN.UNASSIGN_ACL(
    acl => '/sys/acls/acl_for_smtp.xml',
	host => 'plsasen2.corp.sprint.com',
	lower_port => 25,
    upper_port => NULL);
END;
/


6) Verify your ACL configuration by running the below.

--check the services configured (should show the acl_for_smtp service we have just setup)
select * from dba_network_acls;

--check the users that have privileges to access services
SELECT acl,
 principal,
 privilege,
 is_grant,
 TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
 TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date
fROM dba_network_acl_privileges;


7) Deploy the mail package from file mail_pkg.sql attached to this asset.

8) Grant execute for the users added in ACL list on mail_pkg.sql

grant execute on <username>.mail_pkg to <otherusername>;


9) Test the package connected in the database as the username configured in the ACL list.

DECLARE
	V_EMAIL_TO 			POSDAT.MAIL_PKG.ARRAY := POSDAT.MAIL_PKG.ARRAY('firstname.lastname@sprint.com','firstname2.lastname2@sprint.com'); -- WILL SEND EMAIL TO THIS LIST OF RECIPIENTS, YOU MAY ALSO INCLUDE PAGERS
	V_EMAIL_FROM		VARCHAR2(255) := 'firstname.lastname@sprint.com'; --EMAIL ADDRESS THAT WILL BE THE SENDER
	V_SUBJECT			VARCHAR2(120);
	V_EMAIL_BODY		VARCHAR2(10000);
	V_INSTANCE			VARCHAR2(30); -- INSTANCE NAME - USED TO IDENTIFY THE DB WHEN SENDING ERROR MESSAGES
	
BEGIN
	--GET THE INSTANCE NAME			
	SELECT GLOBAL_NAME INTO V_INSTANCE FROM GLOBAL_NAME;

	V_SUBJECT := 'Testing PL/SQL MAIL_PKG from instance: ' || V_INSTANCE;
		
	--SEND EMAIL 
	posdat.mail_pkg.send( 
		p_sender_email => V_EMAIL_FROM,
		p_from => V_EMAIL_FROM,
		p_to => V_EMAIL_TO,
		p_subject => V_SUBJECT,
		p_body => V_EMAIL_BODY);
	
END;
/


If you receive the email, then the configuration is completed and working. You may use the mail_pkg in any pl/sql code you think it will provide benefits.


post deployment checks

Check permissions on UTL_SMTP and UTL_TCP
Verify ACL service created and users added to it
Send a test email from a PL/SQL Code
All those checkings are detailed in Deployment.txt file.