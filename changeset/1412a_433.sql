INSERT INTO system.version SELECT '1412a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1412a');

update system.br_validation set severity_code='medium' where br_id='spatial-unit-group-inside-other-spatial-unit-group';
