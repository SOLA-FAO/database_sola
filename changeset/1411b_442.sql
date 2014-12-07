INSERT INTO system.version SELECT '1411b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1411b');

INSERT INTO system.setting(name, vl, active, description) VALUES ('db-utilities-folder', '', 't', 'Full path to PostgreSQL utilities (bin) folder (e.g. C:\Program Files\PostgreSQL\9.1\bin). Used for backup/restore implementation of SOLA Web admin application');