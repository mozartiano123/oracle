select inst_id, status, event, count(*) as ACTIVE_SESSIONS from gv$session
        where username is not null and username != 'DATAPOINT'
        and status = 'ACTIVE'
        group by inst_id, status, event
        order by 1,2;
