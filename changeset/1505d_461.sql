INSERT INTO system.version SELECT '1505d' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1505d');



-- TABLES  -------------------------------------------------------------------------------------

-- Table: application.notify_relationship_type

-- DROP TABLE application.notify_relationship_type;

CREATE TABLE application.notify_relationship_type
(
  code character varying(20) NOT NULL, -- The code for the relationship type.
  display_value character varying(250) NOT NULL, -- Displayed value of the relationship type.
  description text, -- Description of the relationship type.
  status character(1) NOT NULL, -- Status of the relationship type (c - current, x - no longer valid).
  CONSTRAINT notify_relationship_type_pkey PRIMARY KEY (code),
  CONSTRAINT notify_relationship_type_display_value_unique UNIQUE (display_value)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE application.notify_relationship_type
  OWNER TO postgres;
COMMENT ON TABLE application.notify_relationship_type
  IS 'Code list identifying the type of relationship a party has with land affected by a job. Used for bulk notification purposes. 
Tags: SOLA State Land Extension, Reference Table';
COMMENT ON COLUMN application.notify_relationship_type.code IS 'The code for the relationship type.';
COMMENT ON COLUMN application.notify_relationship_type.display_value IS 'Displayed value of the relationship type.';
COMMENT ON COLUMN application.notify_relationship_type.description IS 'Description of the relationship type.';
COMMENT ON COLUMN application.notify_relationship_type.status IS 'Status of the relationship type (c - current, x - no longer valid).';






-- Table: application.notify

-- DROP TABLE application.notify;

CREATE TABLE application.notify
(
  id character varying(40) NOT NULL, -- Identifier for the notification.
  service_id character varying(40) NOT NULL, -- Identifier for the service.
  party_id character varying(40) NOT NULL, -- Identifier for the party.
  relationship_type_code character varying(20) NOT NULL DEFAULT 'owner'::character varying, -- The type of relationship between the party and the land affected by the job. One of Owner, Adjoining Owner, Occupier, Adjoining Occupier, Rightholder, Other, etc.
  description text, -- The description of the party to notify.
  classification_code character varying(20), -- SOLA State Land Extension: The security classification for this Notification Party. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.
  redact_code character varying(20), -- SOLA State Land Extension: The redact classification for this Notification Party. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the notify_historic table
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  cancel_service_id character varying(40),  -- Identifier for the cancelaation service if requested.
  status character varying(40) NOT NULL DEFAULT 'c'::character varying, -- status of the notification if still enabled (c) or waiting for cancellation (x).
  CONSTRAINT notify_pkey PRIMARY KEY (id),
  CONSTRAINT notify_party_id_fk FOREIGN KEY (party_id)
      REFERENCES party.party (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT notify_service_id_fk FOREIGN KEY (service_id)
      REFERENCES application.service (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT notify_type_code_fk FOREIGN KEY (relationship_type_code)
      REFERENCES application.notify_relationship_type (code) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)

WITH (
  OIDS=FALSE
);
ALTER TABLE application.notify
  OWNER TO postgres;
COMMENT ON TABLE application.notify
  IS 'Identifies parties to be notified in bulk as well as the relationship the party has with the land affected by the job.
Tags: SOLA State Land Extension, Change History';
COMMENT ON COLUMN application.notify.id IS 'Identifier for the notification.';
COMMENT ON COLUMN application.notify.service_id IS 'Identifier for the service.';
COMMENT ON COLUMN application.notify.party_id IS 'Identifier for the party.';
COMMENT ON COLUMN application.notify.relationship_type_code IS 'The type of relationship between the party and the land affected by the job. One of Owner, Adjoining Owner, Occupier, Adjoining Occupier, Rightholder, Other, etc.';
COMMENT ON COLUMN application.notify.description IS 'The description of the party to notify.';
COMMENT ON COLUMN application.notify.classification_code IS 'SOLA State Land Extension: The security classification for this Notification Party. Only users with the security classification (or a higher classification) will be able to view the record. If null, the record is considered unrestricted.';
COMMENT ON COLUMN application.notify.redact_code IS 'SOLA State Land Extension: The redact classification for this Notification Party. Only users with the redact classification (or a higher classification) will be able to view the record with un-redacted fields. If null, the record is considered unrestricted and no redaction to the record will occur unless bulk redaction classifications have been set for fields of the record.';
COMMENT ON COLUMN application.notify.rowidentifier IS 'Identifies the all change records for the row in the notify_historic table';
COMMENT ON COLUMN application.notify.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN application.notify.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN application.notify.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN application.notify.change_time IS 'The date and time the row was last modified.';


-- Index: application.notify_index_on_party_id

-- DROP INDEX application.notify_index_on_party_id;

CREATE INDEX notify_index_on_party_id
  ON application.notify
  USING btree
  (party_id COLLATE pg_catalog."default");

-- Index: application.notify_index_on_rowidentifier

-- DROP INDEX application.notify_index_on_rowidentifier;

CREATE INDEX notify_index_on_rowidentifier
  ON application.notify
  USING btree
  (rowidentifier COLLATE pg_catalog."default");

-- Index: application.notify_index_on_service_id

-- DROP INDEX application.notify_index_on_service_id;

CREATE INDEX notify_index_on_service_id
  ON application.notify
  USING btree
  (service_id COLLATE pg_catalog."default");


-- Trigger: __track_changes on application.notify

-- DROP TRIGGER __track_changes ON application.notify;

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON application.notify
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

-- Trigger: __track_history on application.notify

-- DROP TRIGGER __track_history ON application.notify;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON application.notify
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();




-- Table: application.notify_property

-- DROP TABLE application.notify_property;

CREATE TABLE application.notify_property
(
  notify_id character varying(40) NOT NULL, -- Identifier for the notification party the record is associated to.
  ba_unit_id character varying(40) NOT NULL, -- Identifier of the property associated to the objection.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the notify_property_historic table
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  cancel_service_id character varying(40),  -- Identifier for the cancelaation service if requested.
  status character varying(40) NOT NULL DEFAULT 'c'::character varying, -- status of the notification if still enabled (c) or waiting for cancellation (x).
  CONSTRAINT notifiy_property_pkey PRIMARY KEY (notify_id, ba_unit_id),
  CONSTRAINT notify_property_ba_unit_id_fk FOREIGN KEY (ba_unit_id)
      REFERENCES administrative.ba_unit (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT notify_property_notify_id_fk FOREIGN KEY (notify_id)
      REFERENCES application.notify (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE application.notify_property
  OWNER TO postgres;
COMMENT ON TABLE application.notify_property
  IS 'Identifies the properties (a.k.a. Ba Units) this notification party is related to. 
Tags: FLOSS SOLA Extension, Change History';
COMMENT ON COLUMN application.notify_property.notify_id IS 'Identifier for the notification party the record is associated to.';
COMMENT ON COLUMN application.notify_property.ba_unit_id IS 'Identifier of the property associated to the objection.';
COMMENT ON COLUMN application.notify_property.rowidentifier IS 'Identifies the all change records for the row in the notify_property_historic table';
COMMENT ON COLUMN application.notify_property.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN application.notify_property.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN application.notify_property.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN application.notify_property.change_time IS 'The date and time the row was last modified.';


-- Index: application.notify_property_ba_unit_id_fk_ind

-- DROP INDEX application.notify_property_ba_unit_id_fk_ind;

CREATE INDEX notify_property_ba_unit_id_fk_ind
  ON application.notify_property
  USING btree
  (ba_unit_id COLLATE pg_catalog."default");

-- Index: application.notify_property_index_on_rowidentifier

-- DROP INDEX application.notify_property_index_on_rowidentifier;

CREATE INDEX notify_property_index_on_rowidentifier
  ON application.notify_property
  USING btree
  (rowidentifier COLLATE pg_catalog."default");

-- Index: application.notify_property_notify_id_fk_ind

-- DROP INDEX application.notify_property_notify_id_fk_ind;

CREATE INDEX notify_property_notify_id_fk_ind
  ON application.notify_property
  USING btree
  (notify_id COLLATE pg_catalog."default");


-- Trigger: __track_changes on application.notify_property

-- DROP TRIGGER __track_changes ON application.notify_property;

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON application.notify_property
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

-- Trigger: __track_history on application.notify_property

-- DROP TRIGGER __track_history ON application.notify_property;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON application.notify_property
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

-- Table: application.notify_property_historic

-- DROP TABLE application.notify_property_historic;

CREATE TABLE application.notify_property_historic
(
  notify_id character varying(40),
  ba_unit_id character varying(40),
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now(),
  cancel_service_id character varying(40),  -- Identifier for the cancelaation service if requested.
  status character varying(40) NOT NULL DEFAULT 'c'::character varying -- status of the notification if still enabled (c) or waiting for cancellation (x)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE application.notify_property_historic
  OWNER TO postgres;

-- Index: application.notify_property_historic_index_on_rowidentifier

-- DROP INDEX application.notify_property_historic_index_on_rowidentifier;

CREATE INDEX notify_property_historic_index_on_rowidentifier
  ON application.notify_property_historic
  USING btree
  (rowidentifier COLLATE pg_catalog."default");

  
-- Table: application.notify_uses_source

-- DROP TABLE application.notify_uses_source;

CREATE TABLE application.notify_uses_source
(
  notify_id character varying(40) NOT NULL, -- Identifier for the notification party the record is associated to.
  source_id character varying(40) NOT NULL, -- Identifier of the source associated to the application.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the objection_uses_source_historic table
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  CONSTRAINT notify_uses_source_pkey PRIMARY KEY (notify_id, source_id),
  CONSTRAINT notify_uses_source_notify_id_fk FOREIGN KEY (notify_id)
      REFERENCES application.notify (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT notify_uses_source_source_id_fk FOREIGN KEY (source_id)
      REFERENCES source.source (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE application.notify_uses_source
  OWNER TO postgres;
COMMENT ON TABLE application.notify_uses_source
  IS 'Links the notification parties to the sources (a.k.a. documents) genreated for the bulk notification. 
Tags: FLOSS SOLA Extension, Change History';
COMMENT ON COLUMN application.notify_uses_source.notify_id IS 'Identifier for the notification party the record is associated to.';
COMMENT ON COLUMN application.notify_uses_source.source_id IS 'Identifier of the source associated to the application.';
COMMENT ON COLUMN application.notify_uses_source.rowidentifier IS 'Identifies the all change records for the row in the objection_uses_source_historic table';
COMMENT ON COLUMN application.notify_uses_source.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN application.notify_uses_source.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN application.notify_uses_source.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN application.notify_uses_source.change_time IS 'The date and time the row was last modified.';


-- Index: application.notify_uses_source_index_on_rowidentifier

-- DROP INDEX application.notify_uses_source_index_on_rowidentifier;

CREATE INDEX notify_uses_source_index_on_rowidentifier
  ON application.notify_uses_source
  USING btree
  (rowidentifier COLLATE pg_catalog."default");

-- Index: application.notify_uses_source_notify_id_fk_ind

-- DROP INDEX application.notify_uses_source_notify_id_fk_ind;

CREATE INDEX notify_uses_source_notify_id_fk_ind
  ON application.notify_uses_source
  USING btree
  (notify_id COLLATE pg_catalog."default");

-- Index: application.notify_uses_source_source_id_fk_ind

-- DROP INDEX application.notify_uses_source_source_id_fk_ind;

CREATE INDEX notify_uses_source_source_id_fk_ind
  ON application.notify_uses_source
  USING btree
  (source_id COLLATE pg_catalog."default");


-- Trigger: __track_changes on application.notify_uses_source

-- DROP TRIGGER __track_changes ON application.notify_uses_source;

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON application.notify_uses_source
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

-- Trigger: __track_history on application.notify_uses_source

-- DROP TRIGGER __track_history ON application.notify_uses_source;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON application.notify_uses_source
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();


---- HISTORIC -----

-- Table: application.notify_historic

-- DROP TABLE application.notify_historic;

CREATE TABLE application.notify_historic
(
  id character varying(40),
  service_id character varying(40),
  party_id character varying(40),
  relationship_type_code character varying(20),
  description text,
  classification_code character varying(20),
  redact_code character varying(20),
  cancel_service_id character varying(40),
  status character varying(40) NOT NULL DEFAULT 'c'::character varying,
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
ALTER TABLE application.notify_historic
  OWNER TO postgres;
COMMENT ON TABLE application.notify_historic
  IS 'History table for the application.notify table';

-- Index: application.notify_historic_index_on_rowidentifier

-- DROP INDEX application.notify_historic_index_on_rowidentifier;

CREATE INDEX notify_historic_index_on_rowidentifier
  ON application.notify_historic
  USING btree
  (rowidentifier COLLATE pg_catalog."default");

-- Table: application.notify_uses_source_historic

-- DROP TABLE application.notify_uses_source_historic;

CREATE TABLE application.notify_uses_source_historic
(
  notify_id character varying(40),
  source_id character varying(40),
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
ALTER TABLE application.notify_uses_source_historic
  OWNER TO postgres;

-- Index: application.notify_uses_source_historic_index_on_rowidentifier

-- DROP INDEX application.notify_uses_source_historic_index_on_rowidentifier;

CREATE INDEX notify_uses_source_historic_index_on_rowidentifier
  ON application.notify_uses_source_historic
  USING btree
  (rowidentifier COLLATE pg_catalog."default");


---  INSERTS -----------------------------------------------------------------------

INSERT INTO application.notify_relationship_type (code, display_value, description, status) VALUES ('owner', 'owner', 'owner', 'c');
INSERT INTO application.notify_relationship_type (code, display_value, description, status) VALUES ('safeguard', 'safeguard', 'safeguard', 'c');



---  VIEWS  --------------------------------------------------------------------------

DROP VIEW application.cancel_notification;
DROP TABLE administrative.notifiable_party_for_baunit;

-- View: application.notifiable_party_for_baunit

-- DROP VIEW application.notifiable_party_for_baunit;

 
CREATE OR REPLACE VIEW application.notifiable_party_for_baunit AS 
SELECT n.party_id, 
    nt.party_id AS target_party_id, 
    n.service_id, 
    s.application_id, 
    np.cancel_service_id, 
    n.status, 
    (bu.name_firstpart::text || '/'::text) || bu.name_lastpart::text AS baunit_name, 
    n.rowidentifier, n.rowversion, n.change_action, n.change_user, 
    n.change_time, n.id AS notifyid, nt.id AS notifytargetid
  FROM application.service s, 
    administrative.ba_unit bu, 
    application.notify n, 
    application.notify nt, 
    application.notify_property np,
    administrative.party_for_rrr  pr,
    administrative.rrr rrr
  WHERE n.service_id::text = s.id::text AND bu.id::text = np.ba_unit_id::text AND np.notify_id::text = n.id::text AND n.relationship_type_code::text = 'safeguard'::text 
    AND nt.service_id::text = s.id::text AND nt.relationship_type_code::text = 'owner'::text 
    AND nt.party_id=pr.party_id  
    AND pr.rrr_id=rrr.id 
    AND rrr.ba_unit_id= bu.id ;

-- View: application.cancel_notification

-- DROP VIEW application.cancel_notification;

CREATE OR REPLACE VIEW application.cancel_notification AS 
 SELECT pp.name AS partyname,
  pp.last_name AS partylastname, 
    tpp.name AS targetpartyname, 
    tpp.last_name AS targetpartylastname, 
    npbu.party_id, 
    npbu.target_party_id, 
    npbu.baunit_name,
    npbu.service_id, 
    npbu.cancel_service_id 
   FROM party.party pp, party.party tpp, 
    application.notifiable_party_for_baunit npbu, 
    application.application aa, application.service s
  WHERE s.application_id::text = aa.id::text 
  AND s.id::text = npbu.cancel_service_id::text 
  AND pp.id::text = npbu.party_id::text AND tpp.id::text = npbu.target_party_id::text 
 AND s.request_type_code::text = 'cancelRelationship'::text;


          
-- BRs -----------------------------------------------------------------------------------------------

delete from system.br_validation where br_id = 'cancel-relation-notification';
delete from system.br_definition where br_id = 'cancel-relation-notification';
delete from system.br where id = 'cancel-relation-notification';


insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cancel-relation-notification', 'sql', 'Cancel notification for the services of the application',
 '#{id}(application_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('cancel-relation-notification', now(), 'infinity', 
 'UPDATE application.notify_property
 set status = ''x''
WHERE cancel_service_id in
(
SELECT        npbu.cancel_service_id
 FROM 
	      application.notifiable_party_for_baunit npbu,
	      application.application aa, 
	      application.service s
WHERE 	      s.application_id::text = aa.id::text 
              and s.request_type_code::text = ''cancelRelationship''::text 
              and npbu.cancel_service_id = s.id
	      and aa.id = #{id})
;
UPDATE application.notify
 set status = ''x''
WHERE cancel_service_id in
(
SELECT        npbu.cancel_service_id
 FROM 
	      application.notifiable_party_for_baunit npbu,
	      application.application aa, 
	      application.service s
WHERE 	      s.application_id::text = aa.id::text 
              and s.request_type_code::text = ''cancelRelationship''::text 
              and npbu.cancel_service_id = s.id
	      and aa.id = #{id})
;
select 0=0 as vl
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('cancel-relation-notification', 'application', 'approve', 'warning', 300);








delete from system.br_validation where br_id = 'delete-relation-notification';
delete from system.br_definition where br_id = 'delete-relation-notification';
delete from system.br where id = 'delete-relation-notification';


insert into system.br(id, technical_type_code, feedback, technical_description) 
values('delete-relation-notification', 'sql', 'Delete notification for the services of the application',
 '#{id}(application_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('delete-relation-notification', now(), 'infinity', 
 'DELETE from application.notify
WHERE 
service_id in (
SELECT        npbu.service_id
 FROM  application.notifiable_party_for_baunit npbu
where status = ''x''
and cancel_service_id in
( SELECT        npbu.cancel_service_id
 FROM 
	      application.notifiable_party_for_baunit npbu,
	      application.application aa, 
	      application.service s
WHERE 	      s.application_id::text = aa.id::text 
              and s.request_type_code::text = ''cancelRelationship''::text 
              and npbu.cancel_service_id = s.id
	      and aa.id = #{id})
)	      
	      
;
select 0=0 as vl
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('delete-relation-notification', 'application', 'archive', 'warning', 300);  

