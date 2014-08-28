-- Ticket #412

-- Add system settings
INSERT INTO system.setting(name, vl, active, description) VALUES ('max-file-size', '10000', 't', 'Maximum file size in KB for uploading.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('max-uploading-daily-limit', '100000', 't', 'Maximum size of files uploaded daily.');
INSERT INTO system.setting(name, vl, active, description) VALUES ('moderation-days', '30', 't', 'Duration of moderation time in days');

-- Create OpenTenure schema
CREATE SCHEMA opentenure;
COMMENT ON SCHEMA opentenure
  IS 'This schema holds objects purely related to OpenTenure feature of SOLA';

-- Sequence: opentenure.opentenure_nr_seq

CREATE SEQUENCE opentenure.claim_nr_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9999
  START 1
  CACHE 1
  CYCLE;
ALTER TABLE opentenure.claim_nr_seq
  OWNER TO postgres;
COMMENT ON SEQUENCE opentenure.claim_nr_seq
  IS 'Sequence number used as the basis for the claim nr field. This sequence is used by the generate-claim-nr business rule.';

-- Insert BR rule to generate claim number
insert into system.br (id, display_name, technical_type_code, feedback, description, technical_description) values 
('generate-claim-nr', 'generate-claim-nr', 'sql', '', '', '');

insert into system.br_definition (br_id, active_from, active_until, body) values 
('generate-claim-nr', '2014-02-20', 'infinity', 
'SELECT coalesce(system.get_setting(''system-id''), '''') || to_char(now(), ''yymm'') || trim(to_char(nextval(''opentenure.claim_nr_seq''), ''0000'')) AS vl');

-- Create claim_status table 
CREATE TABLE opentenure.claim_status
(
  code character varying(20) NOT NULL, -- The code for the claim status.
  display_value character varying(500) NOT NULL, -- Displayed value of the claim status.
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- Status of the service status type
  description character varying(1000), -- Description of the claim status.
  CONSTRAINT claim_status_pkey PRIMARY KEY (code),
  CONSTRAINT claim_status_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.claim_status
  OWNER TO postgres;
COMMENT ON TABLE opentenure.claim_status
  IS 'Code list of claim status.';
COMMENT ON COLUMN opentenure.claim_status.code IS 'The code for the claim status.';
COMMENT ON COLUMN opentenure.claim_status.display_value IS 'Displayed value of the claim status.';
COMMENT ON COLUMN opentenure.claim_status.status IS 'Status of the service claim.';
COMMENT ON COLUMN opentenure.claim_status.description IS 'Description of the claim status.';

-- Insert claim status
insert into opentenure.claim_status (code, display_value, status, description) values 
('unmoderated', 'Un-moderated', 'i', '');

insert into opentenure.claim_status (code, display_value, status, description) values 
('challenged', 'Challenged', 'i', '');

insert into opentenure.claim_status (code, display_value, status, description) values 
('moderated', 'Moderated', 'i', '');

insert into opentenure.claim_status (code, display_value, status, description) values 
('created', 'Created', 'i', '');

-- Claimant
CREATE TABLE opentenure.claimant
(
  id character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  name character varying(255) NOT NULL,
  last_name character varying(50),
  id_type_code character varying(20),
  id_number character varying(20),
  birth_date date,
  gender_code character varying(20),
  mobile_phone character varying(15),
  phone character varying(15),
  email character varying(50),
  address character varying(255),
  user_name character varying(50) NOT NULL,
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT claimant_pkey PRIMARY KEY (id),
  CONSTRAINT claimant_gender_code_fk13 FOREIGN KEY (gender_code)
      REFERENCES party.gender_type (code) MATCH SIMPLE,
  CONSTRAINT claimant_id_type_code_fk12 FOREIGN KEY (id_type_code)
      REFERENCES party.id_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.claimant
  OWNER TO postgres;
COMMENT ON TABLE opentenure.claimant
  IS 'Extension to the LADM used by SOLA to store claimant information.';
COMMENT ON COLUMN opentenure.claimant.id IS 'Unique identifier for the claimant.';
COMMENT ON COLUMN opentenure.claimant.name IS 'First name of claimant.';
COMMENT ON COLUMN opentenure.claimant.last_name IS 'Last name of claimant.';
COMMENT ON COLUMN opentenure.claimant.id_type_code IS 'ID document type code';
COMMENT ON COLUMN opentenure.claimant.id_number IS 'ID document number.';
COMMENT ON COLUMN opentenure.claimant.birth_date IS 'Date of birth of the claimant.';
COMMENT ON COLUMN opentenure.claimant.gender_code IS 'Gender code of the claimant.';
COMMENT ON COLUMN opentenure.claimant.mobile_phone IS 'Mobile phone number of the claimant.';
COMMENT ON COLUMN opentenure.claimant.phone IS 'Landline phone number of the claimant.';
COMMENT ON COLUMN opentenure.claimant.email IS 'Email address of the claimant.';
COMMENT ON COLUMN opentenure.claimant.address IS 'Living address of the claimant.';
COMMENT ON COLUMN opentenure.claimant.user_name IS 'User name who has created the record.';
COMMENT ON COLUMN opentenure.claimant.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';
COMMENT ON COLUMN opentenure.claimant.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.claimant.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.claimant.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.claimant.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.claimant
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.claimant
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

-- Claimant historic
CREATE TABLE opentenure.claimant_historic
(
  id character varying(40),
  name character varying(255),
  last_name character varying(50),
  id_type_code character varying(20),
  id_number character varying(20),
  birth_date date,
  gender_code character varying(20),
  mobile_phone character varying(15),
  phone character varying(15),
  email character varying(50),
  address character varying(255),
  user_name character varying(50),
  rowidentifier character varying(40), 
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.claimant_historic
  OWNER TO postgres;
COMMENT ON TABLE opentenure.claimant_historic
  IS 'Historic table for opentenure.claimant. Keeps all changes done to the main table.';

-- Create claim table
CREATE TABLE opentenure.claim
(
  id character varying(40) NOT NULL, -- Identifier for the claim.
  nr character varying(15) NOT NULL, -- Auto generated claim number. Generated by the generate-claim-nr business rule when the claim record is initially saved.
  lodgement_date timestamp without time zone, -- The lodgement date and time of the claim. 
  challenge_expiry_date timestamp without time zone, -- Expiration date when challenge claim can be submitted. 
  decision_date timestamp without time zone, -- The decision date on the claim by the authority
  description character varying(250), -- Free description of the claim.
  challenged_claim_id character varying(40), -- The identifier of the challenged claim. If this value is provided, it means the record is a claim challenge type.
  claimant_id character varying(40) NOT NULL, -- The identifier of the claimant.
  mapped_geometry geometry, -- Claimed property geometry calculated using system SRID
  gps_geometry geometry, -- Claimed property geometry in Lat/Long format 
  status_code character varying(20) NOT NULL DEFAULT 'created'::character varying, -- The status of the claim.
  recorder_name character varying(50) NOT NULL, -- User's ID, who has created the claim.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the claim_historic table
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.

  CONSTRAINT claim_pkey PRIMARY KEY (id ),
  CONSTRAINT claim_claimant_id_fk8 FOREIGN KEY (claimant_id)
      REFERENCES opentenure.claimant (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT fk_challenged_claim FOREIGN KEY (challenged_claim_id) 
	  REFERENCES opentenure.claim (id) ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT claim_status_code_fk18 FOREIGN KEY (status_code)
      REFERENCES opentenure.claim_status (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT enforce_geotype_mapped_geometry CHECK (geometrytype(mapped_geometry) = 'POLYGON'::text OR geometrytype(mapped_geometry) = 'POINT'::text OR mapped_geometry IS NULL),
  CONSTRAINT enforce_geotype_gps_geometry CHECK (geometrytype(gps_geometry) = 'POLYGON'::text OR geometrytype(gps_geometry) = 'POINT'::text OR gps_geometry IS NULL),
  CONSTRAINT enforce_valid_mapped_geometry CHECK (st_isvalid(mapped_geometry)),
  CONSTRAINT enforce_valid_gps_geometry CHECK (st_isvalid(gps_geometry))
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.claim
  OWNER TO postgres;
COMMENT ON TABLE opentenure.claim
  IS 'Main table to store claim and claim challenge information submitted by the community recorders. SOLA Open Tenure extention.';
COMMENT ON COLUMN opentenure.claim.id IS 'Identifier for the claim.';
COMMENT ON COLUMN opentenure.claim.nr IS 'Auto generated claim number. Generated by the generate-claim-nr business rule when the claim record is initially saved.';
COMMENT ON COLUMN opentenure.claim.lodgement_date IS 'The lodgement date and time of the claim.';
COMMENT ON COLUMN opentenure.claim.challenge_expiry_date IS 'Expiration date when challenge claim can be submitted.';
COMMENT ON COLUMN opentenure.claim.decision_date IS 'The decision date on the claim by the authority.';
COMMENT ON COLUMN opentenure.claim.description IS 'Free description of the claim.';
COMMENT ON COLUMN opentenure.claim.challenged_claim_id IS 'The identifier of the challenged claim. If this value is provided, it means the record is a claim challenge type.';
COMMENT ON COLUMN opentenure.claim.claimant_id IS 'The identifier of the claimant.';
COMMENT ON COLUMN opentenure.claim.mapped_geometry IS 'Claimed property geometry calculated using system SRID';
COMMENT ON COLUMN opentenure.claim.gps_geometry IS 'Claimed property geometry in Lat/Long format';
COMMENT ON COLUMN opentenure.claim.status_code IS 'The status of the claim.';
COMMENT ON COLUMN opentenure.claim.recorder_name IS 'User''s ID, who has created the claim.';
COMMENT ON COLUMN opentenure.claim.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';
COMMENT ON COLUMN opentenure.claim.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.claim.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.claim.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.claim.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.claim
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.claim
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
    
-- Create historic claim table
CREATE TABLE opentenure.claim_historic
(
  id character varying(40),
  nr character varying(15),
  lodgement_date timestamp without time zone,
  challenge_expiry_date timestamp without time zone,
  decision_date timestamp without time zone,
  description character varying(250),
  challenged_claim_id character varying(40),
  claimant_id character varying(40) NOT NULL,
  mapped_geometry geometry,
  gps_geometry geometry,
  status_code character varying(20),
  recorder_name character varying(50), 
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);

ALTER TABLE opentenure.claim_historic
  OWNER TO postgres;
COMMENT ON TABLE opentenure.claim_historic
  IS 'Historic table for the main table with claims opentenure.claim. Keeps all changes done to the main table.';

-- Claim attachment
CREATE TABLE opentenure.attachment
(
  id character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  type_code character varying(20) NOT NULL,
  reference_nr character varying(255),
  document_date date,
  description character varying(255),
  body bytea NOT NULL,
  size bigint NOT NULL,
  mime_type character varying(255) NOT NULL,
  file_name character varying(255) NOT NULL,
  file_extension character varying(5) NOT NULL,
  user_name character varying(50) NOT NULL,
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT attachment_pkey PRIMARY KEY (id),
  CONSTRAINT source_type_code_fk3 FOREIGN KEY (type_code)
      REFERENCES source.administrative_source_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.attachment
  OWNER TO postgres;
COMMENT ON TABLE opentenure.attachment
  IS 'Extension to the LADM used by SOLA to store claim files attachments.';
COMMENT ON COLUMN opentenure.attachment.id IS 'Identifier for the attachment.';
COMMENT ON COLUMN opentenure.attachment.type_code IS 'Attached document type code.';
COMMENT ON COLUMN opentenure.attachment.reference_nr IS 'Document reference number.';
COMMENT ON COLUMN opentenure.attachment.document_date IS 'Document date.';
COMMENT ON COLUMN opentenure.attachment.file_extension IS 'File extension of the attachment. E.g. pdf, tiff, doc, etc';
COMMENT ON COLUMN opentenure.attachment.user_name IS 'User''s ID, who has created the attachment.';
COMMENT ON COLUMN opentenure.attachment.mime_type IS 'Mime type of the attachment.';
COMMENT ON COLUMN opentenure.attachment.file_name IS 'Actual file name of the attachment.';
COMMENT ON COLUMN opentenure.attachment.body IS 'Binary content of the attachment.';
COMMENT ON COLUMN opentenure.attachment.size IS 'File size.';
COMMENT ON COLUMN opentenure.attachment.description IS 'Short document description.';
COMMENT ON COLUMN opentenure.attachment.rowidentifier IS 'Identifies the all change records for the row in the document_historic table';
COMMENT ON COLUMN opentenure.attachment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.attachment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.attachment.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.attachment.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.attachment
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.attachment
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

-- Attachment historic
CREATE TABLE opentenure.attachment_historic
(
  id character varying(40),
  type_code character varying(20),
  reference_nr character varying(255),
  document_date date,
  description character varying(255),
  body bytea,
  size bigint,
  mime_type character varying(255),
  file_name character varying(255),
  file_extension character varying(5),
  user_name character varying(50),
  rowidentifier character varying(40), 
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.attachment_historic
  OWNER TO postgres;
COMMENT ON TABLE opentenure.attachment_historic
  IS 'Historic table for opentenure.attachment. Keeps all changes done to the main table.';
  
  
-- Claim attachments
CREATE TABLE opentenure.claim_uses_attachment
(
  claim_id character varying(40) NOT NULL, -- Identifier for the claim the record is associated to.
  attachment_id character varying(40) NOT NULL, -- Identifier of the source associated to the claim.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Unique row identifier.
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  CONSTRAINT claim_uses_attachment_pkey PRIMARY KEY (claim_id , attachment_id),
  CONSTRAINT claim_uses_attachment_claim_id_fk126 FOREIGN KEY (claim_id)
      REFERENCES opentenure.claim (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.claim_uses_attachment
  OWNER TO postgres;
COMMENT ON TABLE opentenure.claim_uses_attachment
  IS 'Links the claim to the attachment submitted with the claim. SOLA Open Tenure extension.';
COMMENT ON COLUMN opentenure.claim_uses_attachment.claim_id IS 'Identifier for the claim the record is associated to.';
COMMENT ON COLUMN opentenure.claim_uses_attachment.attachment_id IS 'Identifier of the attachment associated to the claim.';
COMMENT ON COLUMN opentenure.claim_uses_attachment.rowidentifier IS 'Unique row identifier.';
COMMENT ON COLUMN opentenure.claim_uses_attachment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.claim_uses_attachment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.claim_uses_attachment.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.claim_uses_attachment.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.claim_uses_attachment
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.claim_uses_attachment
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

-- Claim attachment historic table
CREATE TABLE opentenure.claim_uses_attachment_historic
(
  claim_id character varying(40),
  attachment_id character varying(40),
  rowidentifier character varying(40),
  rowversion integer NOT NULL,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.claim_uses_attachment_historic
  OWNER TO postgres;
COMMENT ON TABLE opentenure.claim_uses_attachment_historic
  IS 'Historic table for opentenure.claim_uses_attachment. Keeps all changes done to the main table.';

-- Chunks table
CREATE TABLE opentenure.attachment_chunk
(
  id character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Unique ID of the chunk
  attachment_id character varying(40) NOT NULL, -- Attachment ID, which will be used to create final document object. Used to group all chunks together.
  claim_id character varying(40), -- Claim ID. Used to clean the table when saving claim. It will guarantee that no orphan chunks left in the table.
  start_position bigint NOT NULL, -- Staring position of the byte in the source/destination document
  size bigint NOT NULL, -- Size of the chunk in bytes.
  body bytea NOT NULL, -- The content of the chunk.
  md5 character varying(50), -- Checksum of the chunk, calculated using MD5.
  creation_time timestamp without time zone NOT NULL DEFAULT now(), -- Date and time when chuck was created.
  user_name character varying(50) NOT NULL, -- User's id (name), who has loaded the chunk
  CONSTRAINT id_pkey_document_chunk PRIMARY KEY (id ),
  CONSTRAINT start_unique_document_chunk UNIQUE (attachment_id, start_position )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE opentenure.attachment_chunk
  OWNER TO postgres;
COMMENT ON TABLE opentenure.attachment_chunk
  IS 'Holds temporary pieces of attachment uploaded on the server. In case of large files, document can be split into smaller pieces (chunks) allowing reliable upload. After all pieces uploaded, client will instruct server to create a document and remove temporary files stored in this table.';
COMMENT ON COLUMN opentenure.attachment_chunk.id IS 'Unique ID of the chunk';
COMMENT ON COLUMN opentenure.attachment_chunk.attachment_id IS 'Attachment ID, which will be used to create final document object. Used to group all chunks together.';
COMMENT ON COLUMN opentenure.attachment_chunk.claim_id IS 'Claim ID. Used to clean the table when saving claim. It will guarantee that no orphan chunks left in the table.';
COMMENT ON COLUMN opentenure.attachment_chunk.start_position IS 'Staring position of the byte in the source/destination document';
COMMENT ON COLUMN opentenure.attachment_chunk.size IS 'Size of the chunk in bytes.';
COMMENT ON COLUMN opentenure.attachment_chunk.body IS 'The content of the chunk.';
COMMENT ON COLUMN opentenure.attachment_chunk.md5 IS 'Checksum of the chunk, calculated using MD5.';
COMMENT ON COLUMN opentenure.attachment_chunk.creation_time IS 'Date and time when chuck was created.';
COMMENT ON COLUMN opentenure.attachment_chunk.user_name IS 'User''s id (name), who has loaded the chunk';

-- Make changes to party table to add birthday column
ALTER TABLE party.party ADD COLUMN birth_date date;
--- ADD COMMENTS ----
COMMENT ON COLUMN party.party.birth_date IS 'SOLA Extension: Date of birth.';

--- HISTORIC TABLE -----
ALTER TABLE party.party_historic ADD COLUMN birth_date date;
   
-- ADD MIME TYPE FIELD TO DOCUMENT TABLE
ALTER TABLE document.document ADD COLUMN mime_type character varying(255);
COMMENT ON COLUMN document.document.mime_type IS 'File mime type.';

-- ADD MIME TYPE FIELD TO DOCUMENT_HISTORIC TABLE
ALTER TABLE document.document_historic ADD COLUMN mime_type character varying(255);
  
INSERT INTO system.version SELECT '1404a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1404a');
