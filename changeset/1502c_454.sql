INSERT INTO system.version SELECT '1502c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1502c');
update system.setting set vl = 'Dear #{userFullName},<p></p>You have registered on SOLA OpenTenure Web-site. Before you can use your account, it will be reviewed and approved by Community Technologist. 
Upon account approval, you will receive notification message.<p></p>Your user name is<br />#{userName}<p></p><p></p>Regards,<br />SOLA OpenTenure Team'
where name = 'email-msg-reg-body';

insert into system.setting (name, vl, active, description) values (
'email-msg-user-activation-body', 'Dear #{userFullName},<p></p>Your account has been activated. 
<p></p>Please use <b>#{userName}</b> to login.<p></p><p></p>Regards,<br />SOLA OpenTenure Team','t',
'Message text to notify Community member account activation on the Community Server Web-site'
);

insert into system.setting (name, vl, active, description) values (
'email-msg-user-activation-subject', 'SOLA OpenTenure account activation','t',
'Subject text to notify Community member account activation on the Community Server Web-site'
);