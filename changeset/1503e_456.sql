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


-- Disable the systematic registration services
UPDATE application.request_type 
SET status = 'x'
WHERE code IN ('lodgeObjection', 'mapExistingParcel', 
                'systematicRegn', 'recordTransfer');


-- Rename and update Gender Safeguard services  and document types
UPDATE application.request_type 
SET display_group_name = 'Gender Safeguards'
WHERE code IN  ('recordRelationship', 'cancelRelationship'); 

UPDATE system.approle
SET display_value = 'Service - Privacy Request'
WHERE code = 'obscurationRequest';

UPDATE source.administrative_source_type
SET    display_value = 'Suppression Order'
WHERE  code = 'restrictionOrder';

UPDATE source.administrative_source_type
SET    display_value = 'Vital Record'
WHERE  code = 'relationshipTitle';

UPDATE source.administrative_source_type
SET    display_value = 'Proof of Identity'
WHERE  code = 'idVerification';

UPDATE source.administrative_source_type
SET    display_value = 'Waiver'
WHERE  code = 'waiver';

UPDATE source.administrative_source_type
SET status = 'x'
WHERE code IN ('objection', 'publicNotification', 'systematicRegn' );

INSERT INTO source.administrative_source_type
(code, display_value, status, description)
VALUES ('officeNote', 'Office Note', 'c', 'Document created by a staff member to note information or points of interest related to a given application'); 

INSERT INTO source.administrative_source_type
(code, display_value, status, description)
VALUES ('other', 'Other', 'c', 'Document that does not fit one of the other named categories.');

INSERT INTO source.administrative_source_type
(code, display_value, status, description)
VALUES ('requisition', 'Requisition Notice', 'c', 'Notice sent by the land registation agency to inform the agent of items that must be addressed with their application before the application can be processed and approved.');

INSERT INTO source.administrative_source_type
(code, display_value, status, description)
VALUES ('surveyDataFile', 'Survey Data File', 'c', 'A CSV data file containing survey coordinate points that can be imported when processing the Change to Cadastre Service.');

-- Hide the Claims Map Layer
UPDATE system.config_map_layer
SET active = FALSE
WHERE name = 'claims-orthophoto';

-- Modify the Privacy Request to open the Party Search screen
INSERT INTO system.config_panel_launcher(
            code, display_value, description, status, launch_group, panel_class, 
            message_code, card_name)
    VALUES ('partySearch', 'Party Search Panel', null, 'c', 'nullConstructor',  
	        'org.sola.clients.swing.desktop.party.PartySearchPanelForm', 'cliprgs008', 'searchPersons');
			
DELETE FROM system.config_panel_launcher WHERE code = 'obscurationRequest';
DELETE FROM system.panel_launcher_group WHERE code = 'obscurationRequest';

UPDATE application.request_type 
SET display_value = 'Privacy Request',
    display_group_name = 'Gender Safeguards',
    service_panel_code = 'partySearch'
WHERE code = 'obscurationRequest'; 

ALTER TABLE party.party DROP COLUMN IF EXISTS obscure_service_id ; 
ALTER TABLE party.party_historic DROP COLUMN IF EXISTS obscure_service_id ; 

-- app-allowable-primary-right-for-new-title has flawed logic and is no longer required
-- as the IS Primary checkbox has been removed from the RRR forms.  
DELETE FROM system.br_validation WHERE br_id = 'app-allowable-primary-right-for-new-title'; 