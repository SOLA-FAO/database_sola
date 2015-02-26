 
-- Add security classification roles 
INSERT INTO system.approle (code, display_value, status, description)
SELECT 'ChangeSecClass', 'Security - Change Security Classification','c', 'Allows the user to set or change the security classification for a record.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = 'ChangeSecClass');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT ar.code, ag.id 
	 FROM system.appgroup ag, system.approle ar 
	 WHERE ag."name" = 'Super group'
	 AND   ar.code = 'ChangeSecClass'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = ar.code
					 AND    appgroup_id = ag.id));


INSERT INTO system.approle (code, display_value, status, description)
SELECT '01SEC_Unrestricted', 'Security - Unrestricted','c', 'Grants user clearance to view and/or access all unrestricted records.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = '01SEC_Unrestricted');

INSERT INTO system.approle (code, display_value, status, description)
SELECT '02SEC_Restricted', 'Security - Restricted','c', 'Grants user clearance to view and/or access all unrestricted and restricted records.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = '02SEC_Restricted');

INSERT INTO system.approle (code, display_value, status, description)
SELECT '03SEC_Confidential', 'Security - Confidential','c', 'Grants user clearance to view and/or access all unrestricted, restricted and confidential records.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = '03SEC_Confidential');

INSERT INTO system.approle (code, display_value, status, description)
SELECT '04SEC_Secret', 'Security - Secret','c', 'Grants user clearance to view and/or access all unrestricted, restricted, confidential and secret records.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = '04SEC_Secret');

INSERT INTO system.approle (code, display_value, status, description)
SELECT '05SEC_TopSecret', 'Security - Top Secret','c', 'Grants user clearance to view and/or access all records.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = '05SEC_TopSecret');

INSERT INTO system.approle (code, display_value, status, description)
SELECT '10SEC_SuppressOrd', 'Security - Suppression Order','c', 'Grants user clearance to view and/or access all records marked with the Supression Order security classification.'
WHERE NOT EXISTS (SELECT code FROM system.approle WHERE code = '10SEC_SuppressOrd');


INSERT INTO system.approle_appgroup (approle_code, appgroup_id) 
    (SELECT ar.code, ag.id 
	 FROM system.appgroup ag, system.approle ar 
	 WHERE ag."name" = 'Super group'
	 AND   ar.code LIKE '%SEC_%'
	 AND NOT EXISTS (SELECT approle_code FROM system.approle_appgroup 
	                 WHERE  approle_code = ar.code
					 AND    appgroup_id = ag.id));				  

-- Ba Unit
ALTER TABLE administrative.ba_unit
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE administrative.ba_unit
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

COMMENT ON COLUMN administrative.ba_unit.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Ba Unit. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';

COMMENT ON COLUMN administrative.ba_unit.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Ba Unit. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';

ALTER TABLE administrative.ba_unit_historic
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE administrative.ba_unit_historic
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 					 

-- RRR	
ALTER TABLE administrative.rrr
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE administrative.rrr
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

COMMENT ON COLUMN administrative.rrr.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this RRR. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';

COMMENT ON COLUMN administrative.rrr.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this RRR. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';

ALTER TABLE administrative.rrr_historic
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE administrative.rrr_historic
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 
	
-- Notation	
ALTER TABLE administrative.notation
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE administrative.notation
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

COMMENT ON COLUMN administrative.notation.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Notation. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';

COMMENT ON COLUMN administrative.notation.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Notation. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';

ALTER TABLE administrative.notation_historic
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE administrative.notation_historic
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 


-- Party	
ALTER TABLE party.party
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE party.party
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

COMMENT ON COLUMN party.party.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Party. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';

COMMENT ON COLUMN party.party.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Party. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';

ALTER TABLE party.party_historic
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE party.party_historic
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 
	
-- Application	
ALTER TABLE application.application
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE application.application
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

COMMENT ON COLUMN application.application.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Application/Job. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';

COMMENT ON COLUMN application.application.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Application/Job. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';

ALTER TABLE application.application_historic
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE application.application_historic
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

-- Source	
ALTER TABLE source.source
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE source.source
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

COMMENT ON COLUMN source.source.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Source. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';

COMMENT ON COLUMN source.source.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Source. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';

ALTER TABLE source.source_historic
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE source.source_historic
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20);
   
-- Cadastre Object	 (a.k.a. Parcel)
ALTER TABLE cadastre.cadastre_object
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE cadastre.cadastre_object
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20); 

COMMENT ON COLUMN cadastre.cadastre_object.classification_code IS 'FROM  SOLA State Land Extension: The security classification for this Parcel. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';

COMMENT ON COLUMN cadastre.cadastre_object.redact_code IS 'FROM  SOLA State Land Extension: The redact classification for this Parcel. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';

ALTER TABLE cadastre.cadastre_object_historic
  DROP COLUMN IF EXISTS classification_code,
  DROP COLUMN IF EXISTS redact_code;
  
ALTER TABLE cadastre.cadastre_object_historic
    ADD COLUMN classification_code VARCHAR(20),
	ADD COLUMN redact_code VARCHAR(20);  
   