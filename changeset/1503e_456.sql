INSERT INTO system.version SELECT '1503e' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1503e');

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'MapFeatureEditor', 'Map - Feature Editor','c', 'Allows the user to edit map features (e.g. roads and place names).'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'MapFeatureEditor');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'MapFeatureEditor', ag.id FROM system.appgroup ag WHERE ag."name" = 'Super group'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'MapFeatureEditor'
					 AND    appgroup_id = ag.id));

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'MapZoneEditor', 'Map - Zone Editor','c', 'Allows the user to edit map zones and configure zone hierarchies.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'MapZoneEditor');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'MapZoneEditor', ag.id FROM system.appgroup ag WHERE ag."name" = 'Super group'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'MapZoneEditor'
					 AND    appgroup_id = ag.id));

INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ReportGender', 'Reports - Gender','c', 'Allows the user to generate the Gender Report.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ReportGender');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT 'ReportGender', ag.id FROM system.appgroup ag WHERE ag."name" = 'Super group'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = 'ReportGender'
					 AND    appgroup_id = ag.id));
