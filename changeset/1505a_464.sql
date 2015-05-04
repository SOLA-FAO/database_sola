INSERT INTO system.version SELECT '1505a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1504a');
INSERT INTO system.setting (name, vl, active, description) VALUES ('product-name', 'SOLA Registry', 't', 'SOLA product name');
INSERT INTO system.setting (name, vl, active, description) VALUES ('product-code', 'sr', 't', 'SOLA product code. sr - SOLA Registry, ssr - SOLA Systematic Registration, ssl - SOLA State Land, scs - SOLA Community Server');

