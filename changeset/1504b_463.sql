INSERT INTO system.version SELECT '1504b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1504b');
delete from system.setting where name like 'email-msg-claim%';
delete from system.setting where name like 'email-msg-reg%';
delete from system.setting where name like 'email-msg-user%';
delete from system.config_map_layer_metadata where name_layer = 'claims-orthophoto';
delete from system.config_map_layer where name = 'claims-orthophoto';
drop schema opentenure cascade;