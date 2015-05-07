-- Ticket #465 - Add request_display_group table
INSERT INTO system.version SELECT '1505b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1505b');

-- *** Add request_display_group table and display order to
  --     request_types  
 ALTER TABLE application.request_type 
  DROP COLUMN IF EXISTS  display_group_name,
  DROP COLUMN IF EXISTS  display_group_code,
  DROP COLUMN IF EXISTS  display_order,
  DROP CONSTRAINT IF EXISTS  request_type_display_group_code_fk;
  
DROP TABLE IF EXISTS application.request_display_group; 
  
CREATE TABLE application.request_display_group
(
  code character varying(20) NOT NULL, 
  display_value character varying(250) NOT NULL, 
  description text, 
  status character(1) NOT NULL, 
  CONSTRAINT request_display_group_pkey PRIMARY KEY (code),
  CONSTRAINT request_display_group_display_value_unique UNIQUE (display_value)
);

COMMENT ON TABLE application.request_display_group
  IS 'Code list identifying the display groups that can be used for request types
Tags: SOLA State Land Extension, Reference Table';
COMMENT ON COLUMN application.request_display_group.code IS 'The code for the request display group.';
COMMENT ON COLUMN application.request_display_group.display_value IS 'Displayed value of the request display group.';
COMMENT ON COLUMN application.request_display_group.description IS 'Description of the request display group.';
COMMENT ON COLUMN application.request_display_group.status IS 'Status of the negotiation type (c - current, x - no longer valid).';

INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('caveat', 'Caveat::::::::مذكرة قانونية::::::::::::::::::::::::附加说明', 'Caveat display group.', 'c'); 
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('document', 'Documents::::::::الوثائق::::::::::::::::::::::::文件', 'Documents display group.', 'c'); 
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('gender', 'Gender Safeguards::::::::تسجيل آخر::::::::::::::::::::::::', 'Gender Safeguards display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('generalReg', 'General Registration::::::::التسجيل العام::::::::::::::::::::::::普通登记', 'General Registration display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('lease', 'Lease::::::::إيجار::::::::::::::::::::::::租赁', 'Lease display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('mortgage', 'Mortgage::::::::رهن::::::::::::::::::::::::抵押', 'Mortgage display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('otherReg', 'Other Registration::::::::تسجيل آخر::::::::::::::::::::::::其他登记', 'Other Registration display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('ownership', 'Ownership::::::::ملكية::::::::::::::::::::::::所有权', 'Ownership display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('supporting', 'Supporting::::::::دعم::::::::::::::::::::::::支持', 'Supporting display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('survey', 'Survey::::::::المسح::::::::::::::::::::::::调查', 'Survey display group.', 'c');
INSERT INTO application.request_display_group (code, display_value, description, status)
VALUES ('systematicReg', 'Systematic Registration::::::::التسجيل المنتظم::::::::::::::::::::::::系统登记', 'Systematic Registration display group.', 'x');

ALTER TABLE application.request_type 
  ADD COLUMN display_group_code character varying(20),
  ADD COLUMN display_order int,
  ADD CONSTRAINT request_type_display_group_code_fk FOREIGN KEY (display_group_code)
      REFERENCES application.request_display_group (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE; 

COMMENT ON COLUMN application.request_type.display_group_code IS 'SOLA Extension. Used to group request types that have a similar purpose (e.g. Mortgage types or Systematic Registration types). Used by the Add Service dialog to group the request types for display.';
COMMENT ON COLUMN application.request_type.display_order IS 'SOLA Extension. Used to order the request types for display in the Add Service dialog.';
	  
-- Caveat				
UPDATE application.request_type SET display_order = 10, display_group_code = 'caveat' WHERE code IN ('caveat');
UPDATE application.request_type SET display_order = 20, display_group_code = 'caveat' WHERE code IN ('varyCaveat');
UPDATE application.request_type SET display_order = 30, display_group_code = 'caveat' WHERE code IN ('removeCaveat');
-- Documents
UPDATE application.request_type SET display_order = 40, display_group_code = 'document' WHERE code IN ('regnPowerOfAttorney');
UPDATE application.request_type SET display_order = 50, display_group_code = 'document' WHERE code IN ('regnStandardDocument');
UPDATE application.request_type SET display_order = 60, display_group_code = 'document' WHERE code IN ('cnclPowerOfAttorney');
UPDATE application.request_type SET display_order = 70, display_group_code = 'document' WHERE code IN ('cnclStandardDocument');
UPDATE application.request_type SET display_order = 80, display_group_code = 'document' WHERE code IN ('documentCopy');
-- Gender Safeguards				
UPDATE application.request_type SET display_order = 90, display_group_code = 'gender' WHERE code IN ('recordRelationship');
UPDATE application.request_type SET display_order = 100, display_group_code = 'gender' WHERE code IN ('cancelRelationship');
UPDATE application.request_type SET display_order = 110, display_group_code = 'gender' WHERE code IN ('obscurationRequest');
-- General Registration				
UPDATE application.request_type SET display_order = 120, display_group_code = 'generalReg' WHERE code IN ('newFreehold');
UPDATE application.request_type SET display_order = 130, display_group_code = 'generalReg' WHERE code IN ('newApartment');
UPDATE application.request_type SET display_order = 140, display_group_code = 'generalReg' WHERE code IN ('regnOnTitle');
UPDATE application.request_type SET display_order = 150, display_group_code = 'generalReg' WHERE code IN ('newDigitalTitle');
UPDATE application.request_type SET display_order = 160, display_group_code = 'generalReg' WHERE code IN ('cancelProperty');
UPDATE application.request_type SET display_order = 170, display_group_code = 'generalReg' WHERE code IN ('varyRight');
UPDATE application.request_type SET display_order = 180, display_group_code = 'generalReg' WHERE code IN ('removeRight');
UPDATE application.request_type SET display_order = 190, display_group_code = 'generalReg' WHERE code IN ('removeRestriction');
UPDATE application.request_type SET display_order = 200, display_group_code = 'generalReg' WHERE code IN ('regnDeeds');
UPDATE application.request_type SET display_order = 210, display_group_code = 'generalReg' WHERE code IN ('newDigitalProperty');
UPDATE application.request_type SET display_order = 220, display_group_code = 'generalReg' WHERE code IN ('newState');
-- Lease				
UPDATE application.request_type SET display_order = 230, display_group_code = 'lease' WHERE code IN ('registerLease');
UPDATE application.request_type SET display_order = 240, display_group_code = 'lease' WHERE code IN ('varyLease');
-- Mortgage				
UPDATE application.request_type SET display_order = 250, display_group_code = 'mortgage' WHERE code IN ('mortgage');
UPDATE application.request_type SET display_order = 260, display_group_code = 'mortgage' WHERE code IN ('varyMortgage');
-- Other Registration				
UPDATE application.request_type SET display_order = 270, display_group_code = 'otherReg' WHERE code IN ('buildingRestriction');
UPDATE application.request_type SET display_order = 280, display_group_code = 'otherReg' WHERE code IN ('historicOrder');
UPDATE application.request_type SET display_order = 290, display_group_code = 'otherReg' WHERE code IN ('limitedRoadAccess');
UPDATE application.request_type SET display_order = 300, display_group_code = 'otherReg' WHERE code IN ('servitude');
UPDATE application.request_type SET display_order = 310, display_group_code = 'otherReg' WHERE code IN ('lifeEstate');
UPDATE application.request_type SET display_order = 320, display_group_code = 'otherReg' WHERE code IN ('usufruct');
UPDATE application.request_type SET display_order = 330, display_group_code = 'otherReg' WHERE code IN ('waterRights');
-- Ownership				
UPDATE application.request_type SET display_order = 340, display_group_code = 'ownership' WHERE code IN ('newOwnership');
UPDATE application.request_type SET display_order = 350, display_group_code = 'ownership' WHERE code IN ('noteOccupation');
UPDATE application.request_type SET display_order = 360, display_group_code = 'ownership' WHERE code IN ('recordTransfer');
-- Supporting				
UPDATE application.request_type SET display_order = 370, display_group_code = 'supporting' WHERE code IN ('titleSearch');
UPDATE application.request_type SET display_order = 380, display_group_code = 'supporting' WHERE code IN ('serviceEnquiry');
UPDATE application.request_type SET display_order = 390, display_group_code = 'supporting' WHERE code IN ('cadastrePrint');
UPDATE application.request_type SET display_order = 400, display_group_code = 'supporting' WHERE code IN ('cadastreBulk');
UPDATE application.request_type SET display_order = 410, display_group_code = 'supporting' WHERE code IN ('cadastreExport');
-- Survey				
UPDATE application.request_type SET display_order = 420, display_group_code = 'survey' WHERE code IN ('cadastreChange');
UPDATE application.request_type SET display_order = 430, display_group_code = 'survey' WHERE code IN ('redefineCadastre');
UPDATE application.request_type SET display_order = 440, display_group_code = 'survey' WHERE code IN ('surveyPlanCopy');
-- Systematic Registration				
UPDATE application.request_type SET display_order = 450, display_group_code = 'systematicReg' WHERE code IN ('lodgeObjection');
UPDATE application.request_type SET display_order = 460, display_group_code = 'systematicReg' WHERE code IN ('mapExistingParcel');
UPDATE application.request_type SET display_order = 470, display_group_code = 'systematicReg' WHERE code IN ('systematicRegn');