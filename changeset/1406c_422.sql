INSERT INTO system.version SELECT '1406c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1406c');

ALTER TABLE application.request_type DROP COLUMN IF EXISTS service_panel_code;
ALTER TABLE administrative.rrr_type DROP COLUMN IF EXISTS rrr_panel_code;
DROP TABLE IF EXISTS system.config_panel_launcher;

-- panel_launcher_group table
DROP TABLE IF EXISTS system.panel_launcher_group;
CREATE TABLE system.panel_launcher_group
(
  code character varying(20) NOT NULL, 
  display_value character varying(500) NOT NULL,
  description character varying(1000), 
  status character(1) NOT NULL DEFAULT 't'::bpchar, 
  CONSTRAINT panel_launcher_group_pkey PRIMARY KEY (code),
  CONSTRAINT panel_launcher_group_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.panel_launcher_group
  OWNER TO postgres;
COMMENT ON TABLE system.panel_launcher_group
  IS 'Used to group the panel launcher configuration values to make the PanelLancher logic flexible. 
Tags: FLOSS SOLA Extension, Reference Table';
COMMENT ON COLUMN system.panel_launcher_group.code IS 'The code for the panel launcher group';
COMMENT ON COLUMN system.panel_launcher_group.display_value IS 'The user friendly name for the panel launcher group';
COMMENT ON COLUMN system.panel_launcher_group.description IS 'Description for the panel launcher group';
COMMENT ON COLUMN system.panel_launcher_group.status IS 'Status of this panel launcher group';

INSERT INTO system.panel_launcher_group(code, display_value, description, status)
SELECT 'nullConstructor', 'Nullary Constructor', 'Panels that do not take any constructor arguments', 'c'
WHERE NOT EXISTS (SELECT code FROM system.panel_launcher_group WHERE code = 'nullConstructor');

INSERT INTO system.panel_launcher_group(code, display_value, description, status)
SELECT 'documentServices', 'Document Services', 'Panels used for document services', 'c'
WHERE NOT EXISTS (SELECT code FROM system.panel_launcher_group WHERE code = 'documentServices');

INSERT INTO system.panel_launcher_group(code, display_value, description, status)
SELECT 'cadastreServices', 'Cadastre Services', 'Panels used for cadastre services', 'c'
WHERE NOT EXISTS (SELECT code FROM system.panel_launcher_group WHERE code = 'cadastreServices');

INSERT INTO system.panel_launcher_group(code, display_value, description, status)
SELECT 'propertyServices', 'Property Services', 'Panels used for property services', 'c'
WHERE NOT EXISTS (SELECT code FROM system.panel_launcher_group WHERE code = 'propertyServices');

INSERT INTO system.panel_launcher_group(code, display_value, description, status)
SELECT 'newPropServices', 'New Property Services', 'Panels used for new property services', 'c'
WHERE NOT EXISTS (SELECT code FROM system.panel_launcher_group WHERE code = 'newPropServices');

INSERT INTO system.panel_launcher_group(code, display_value, description, status)
SELECT 'generalRRR', 'General RRR', 'Panels used for general RRRs', 'c'
WHERE NOT EXISTS (SELECT code FROM system.panel_launcher_group WHERE code = 'generalRRR');

INSERT INTO system.panel_launcher_group(code, display_value, description, status)
SELECT 'leaseRRR', 'Lease RRR', 'Panels used for Lease RRR', 'c'
WHERE NOT EXISTS (SELECT code FROM system.panel_launcher_group WHERE code = 'leaseRRR');

-- config_panel_launcher table
--DROP TABLE IF EXISTS system.config_panel_launcher;
CREATE TABLE system.config_panel_launcher
(
  code character varying(20) NOT NULL, -- The code for the panel to launch
  display_value character varying(500) NOT NULL, -- The user friendly name for the panel to launch
  description character varying(1000), -- Description for the panel to launch
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- Status of this configuration record.
  launch_group character varying(20) NOT NULL, 
  panel_class character varying(100), -- The full package and class name for the panel to launch. e.g. org.sola.clients.swing.desktop.administrative.PropertyPanel
  message_code character varying(50), -- The code of the message to display when opening the panel. See the ClientMessage class for a list of codes.
  card_name character varying(50), -- The MainContentPanel card name for the panel to launch
  CONSTRAINT config_panel_launcher_pkey PRIMARY KEY (code),
  CONSTRAINT config_panel_launcher_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.config_panel_launcher
  OWNER TO postgres;
  
ALTER TABLE system.config_panel_launcher ADD CONSTRAINT config_panel_launcher_launch_group_fkey FOREIGN KEY (launch_group)
      REFERENCES system.panel_launcher_group (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
CREATE INDEX config_panel_launcher_launch_group_fkey_ind
  ON system.config_panel_launcher
  USING btree (launch_group COLLATE pg_catalog."default");
  
COMMENT ON TABLE system.config_panel_launcher
  IS 'Configuration data used by the PanelLauncher to determine the appropriate panel or form to display to the user when starting a Service or opening an RRR. 
Tags: FLOSS SOLA Extension, Reference Table';
COMMENT ON COLUMN system.config_panel_launcher.code IS 'The code for the panel to launch';
COMMENT ON COLUMN system.config_panel_launcher.display_value IS 'The user friendly name for the panel to launch';
COMMENT ON COLUMN system.config_panel_launcher.description IS 'Description for the panel to launch';
COMMENT ON COLUMN system.config_panel_launcher.status IS 'Status of this configuration record.';
COMMENT ON COLUMN system.config_panel_launcher.launch_group IS 'The launch group for the panel.';
COMMENT ON COLUMN system.config_panel_launcher.panel_class IS 'The full package and class name for the panel to launch. e.g. org.sola.clients.swing.desktop.administrative.PropertyPanel';
COMMENT ON COLUMN system.config_panel_launcher.message_code IS 'The code of the message to display when opening the panel. See the ClientMessage class for a list of codes. ';
COMMENT ON COLUMN system.config_panel_launcher.card_name IS 'The MainContentPanel card name for the panel to launch';

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'documentTrans', 'Document Transaction Panel', null, 'c', 'documentServices', 'org.sola.clients.swing.desktop.source.TransactionedDocumentsPanel', 'cliprgs016', 'transactionedDocumentPanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'documentTrans');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'documentSearch', 'Document Search Panel', null, 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.source.DocumentSearchForm', 'cliprgs007', 'documentsearch'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'documentSearch');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'map', 'Map Panel', null, 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.cadastre.MapPanelForm', 'cliprgs004', 'map'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'map');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'applicationSearch', 'Application Search Panel', null, 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.application.ApplicationSearchPanel', 'cliprgs003', 'appsearch'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'applicationSearch');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'cadastreTransMap', 'Cadastre Transaction Map Panel', null, 'c', 'cadastreServices', 'org.sola.clients.swing.desktop.cadastre.CadastreTransactionMapPanel', 'cliprgs017', 'cadastreChange'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'cadastreTransMap');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'property', 'Property Panel', null, 'c', 'propertyServices', 'org.sola.clients.swing.desktop.administrative.PropertyPanel', 'cliprgs009', 'propertyPanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'property');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'newProperty', 'New Property Panel', null, 'c', 'newPropServices', 'org.sola.clients.swing.desktop.administrative.PropertyPanel', 'cliprgs009', 'propertyPanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'newProperty');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'propertySearch', 'Property Search Panel', null, 'c', 'nullConstructor', 'org.sola.clients.swing.desktop.administrative.BaUnitSearchPanel', 'cliprgs006', 'baunitsearch'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'propertySearch');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'simpleRight', 'Simple Right Panel', null, 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.SimpleRightPanel', null, 'simpleRightPanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'simpleRight');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'simpleRightholder', 'Simple Rightholder Panel', null, 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.SimpleRightholderPanel', null, 'simpleOwnershipPanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'simpleRightholder');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'mortgage', 'Mortgage Panel', null, 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.MortgagePanel', null, 'mortgagePanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'mortgage');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'lease', 'Lease Panel', null, 'c', 'leaseRRR', 'org.sola.clients.swing.desktop.administrative.LeasePanel', null, 'leasePanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'lease');

INSERT INTO system.config_panel_launcher(code, display_value, description, status, launch_group, panel_class, message_code, card_name)
SELECT 'ownership', 'Ownership Share Panel', null, 'c', 'generalRRR', 'org.sola.clients.swing.desktop.administrative.OwnershipPanel', null, 'ownershipPanel'
WHERE NOT EXISTS (SELECT code FROM system.config_panel_launcher WHERE code = 'ownership');

-- Modify the application.request_type table to reference the appropriate panel code
--ALTER TABLE application.request_type DROP COLUMN IF EXISTS service_panel_code ;
ALTER TABLE application.request_type ADD COLUMN service_panel_code character varying(20); 
COMMENT ON COLUMN application.request_type.service_panel_code IS 'SOLA Extension. Used to identify the SOLA panel class to display to the user when they start the service'; 
ALTER TABLE application.request_type ADD CONSTRAINT request_type_config_panel_launcher_fkey FOREIGN KEY (service_panel_code)
      REFERENCES system.config_panel_launcher (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
CREATE INDEX request_type_config_panel_launcher_fkey_ind
  ON application.request_type
  USING btree (service_panel_code COLLATE pg_catalog."default");
  
UPDATE application.request_type
SET service_panel_code = 'documentTrans'
WHERE code IN ('regnPowerOfAttorney', 'cnclPowerOfAttorney', 'regnStandardDocument', 'cnclStandardDocument');

UPDATE application.request_type
SET service_panel_code = 'documentSearch'
WHERE code IN ('documentCopy', 'surveyPlanCopy');

UPDATE application.request_type
SET service_panel_code = 'map'
WHERE code IN ('cadastrePrint');

UPDATE application.request_type
SET service_panel_code = 'applicationSearch'
WHERE code IN ('serviceEnquiry');

UPDATE application.request_type
SET service_panel_code = 'cadastreTransMap'
WHERE code IN ('cadastreChange', 'redefineCadastre', 'mapExistingParcel');

UPDATE application.request_type
SET service_panel_code = 'propertySearch'
WHERE code IN ('titleSearch');

UPDATE application.request_type
SET service_panel_code = 'newProperty'
WHERE code IN ('newApartment', 'newFreehold', 'newState', 'systematicRegn', 'lodgeObjection');

UPDATE application.request_type
SET service_panel_code = 'property'
WHERE service_panel_code IS NULL
AND code NOT IN ('cadastreBulk', 'cadastreExport');


-- Modify the administrative.rrr_type table to reference the appropriate panel code
--ALTER TABLE administrative.rrr_type DROP COLUMN IF EXISTS rrr_panel_code ;
ALTER TABLE administrative.rrr_type ADD COLUMN rrr_panel_code character varying(20); 
COMMENT ON COLUMN administrative.rrr_type.rrr_panel_code IS 'SOLA Extension. Used to identify the SOLA panel class to display to the user when they view or edit the RRR.'; 
ALTER TABLE administrative.rrr_type ADD CONSTRAINT rrr_type_config_panel_launcher_fkey FOREIGN KEY (rrr_panel_code)
      REFERENCES system.config_panel_launcher (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
CREATE INDEX rrr_type_config_panel_launcher_fkey_ind
  ON administrative.rrr_type
  USING btree (rrr_panel_code COLLATE pg_catalog."default");
  
UPDATE administrative.rrr_type
SET rrr_panel_code = 'mortgage'
WHERE code IN ('mortgage');

UPDATE administrative.rrr_type
SET rrr_panel_code = 'lease'
WHERE code IN ('lease');

UPDATE administrative.rrr_type
SET rrr_panel_code = 'ownership'
WHERE code IN ('ownership', 'apartment', 'stateOwnership');

UPDATE administrative.rrr_type
SET rrr_panel_code = 'simpleRightholder'
WHERE code IN ('agriActivity', 'commonOwnership', 'customaryType', 'firewood', 'fishing', 'grazing',
   'occupation', 'ownershipAssumed', 'superficies', 'tenancy', 'usufruct', 'waterrights', 'adminPublicServitude',
    'monument', 'lifeEstate', 'caveat');
	
UPDATE administrative.rrr_type
SET rrr_panel_code = 'simpleRight'
WHERE rrr_panel_code IS NULL; 

