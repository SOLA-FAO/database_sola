INSERT INTO system.version SELECT '1503d' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1503d');

delete from system.setting where name in ('command-extract', 'command-consolidate','path-to-backup','path-to-process-log');

insert into system.setting(name, vl, description) 
values('command-extract', 'D:\dev\sola\scr\extract-from-admin.bat', 'The command for running the extraction.');

insert into system.setting(name, vl, description) 
values('command-consolidate', 'D:\dev\sola\scr\consolidate-from-admin.bat', 'The command for running the consolidation.');

insert into system.setting(name, vl, description) 
values('path-to-backup', 'D:\dev\sola\scr\data', 'The path of the extracted files.');

insert into system.setting(name, vl, description) 
values('path-to-process-log', 'D:\dev\sola\scr\log', 'The path of the process log files.');

