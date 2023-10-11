col profile for a30
select username, account_status, PROFILE, CREATED, default_tablespace, temporary_tablespace from dba_users where lower(username)=lower('&nome');



  select GRANTEE, GRANTED_ROLE, ADMIN_OPTION as TABNAME from dba_role_privs where lower(grantee)=lower('&&nome')
  union all
  select GRANTEE, PRIVILEGE, ADMIN_OPTION from dba_sys_privs where lower(grantee)=lower('&nome')
  union all
  select GRANTEE, PRIVILEGE, OWNER||'.'||TABLE_NAME from dba_tab_privs where lower(grantee)=lower('&nome');




create user &nome identified by "&senha" default tablespace &tbs temporary tablespace &tmp profile SPRINT_USER_PROFILE;

create user &nome identified by "&senha" default tablespace &tbs temporary tablespace &tmp profile SPRINT_APP_PROFILE;



select distinct default_tablespace, temporary_tablespace from dba_users;




select name, password from user$ where name='&nome';

alter user '&nome' identified by values 'E3B18E566D8A0097';




select 'grant ' || privilege || ' on ' || owner || '.' || table_name || ' to usg505a;'
from dba_tab_privs where grantee='ECOMM_READ';


select username, account_status, PROFILE, CREATED from dba_users
where username in ('FM006188','GQ744400','JJZ2337','SRAMSE05');


select username, account_status, PROFILE, CREATED from dba_users where lower(username)=lower('&nome');



select distinct owner from dba_objects order by 1;


-- All user roles



SET LINE 200 pages 999
select
  lpad(' ', 2*level) || granted_role "User, his roles and privileges"
from
  (
  /* THE USERS */
    select
      null     grantee,
      username granted_role
    from
      dba_users
    where
      username like upper('%OGGADMIN%')
  /* THE ROLES TO ROLES RELATIONS */
  union
    select
      grantee,
      granted_role
    from
      dba_role_privs
  /* THE ROLES TO PRIVILEGE RELATIONS */
  union
    select
      grantee,
      privilege
    from
      dba_sys_privs
  )
start with grantee is null
connect by grantee = prior granted_role;


