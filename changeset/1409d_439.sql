INSERT INTO system.version SELECT '1409d' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1409d');

delete from system.br where id='consolidation-extraction-file-name';
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) 
VALUES ('consolidation-extraction-file-name', 'Consolidation extraction file name', 'sql', '', 'Generates the name of the extraction file for the consolidation. The extension is not part of this generation.', '');

INSERT INTO system.br_definition (br_id, active_from, active_until, body) 
VALUES ('consolidation-extraction-file-name', '2014-09-12', 'infinity', 
'select ''consolidation-'' || system.get_setting(''system-id'') || to_char(clock_timestamp(), ''-yyyy-MM-dd-HH24-MI'') as vl');
