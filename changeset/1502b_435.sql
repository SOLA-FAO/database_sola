insert into system.setting (name, active, vl, description) values ('email-msg-notifiable-submit-body', 't', 'Dear #{notifiablePartyName},<p></p> this is to inform you that one <b>#{actionToNotify}</b> action has been requested 
				<br>by <b>#{targetPartyName}</b> 
				<br>on the following property: <b>#{baUnitName}</b>. <p></p><p></p>Regards,<br />#{sendingOffice}', 'Action on Interest body text');
insert into system.setting (name, active, vl, description) values ('email-msg-notifiable-subject', 't', 'SOLA REGISTRY - #{actionToNotify} action on property #{baUnitName}', 'Action on Interest subject text');




insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cancel-relation-notification', 'sql', 'Cancel notification for the services of the application',
 '#{id}(application_id) is requested');

insert into system.br_definition(br_id, active_from, active_until, body) 
values('cancel-relation-notification', now(), 'infinity', 
 'UPDATE administrative.notifiable_party_for_baunit 
 set status = ''x''
WHERE cancel_service_id in
(
SELECT        npbu.cancel_service_id
 FROM 
	      administrative.notifiable_party_for_baunit npbu,
	      application.application aa, 
	      application.service s,
	      party.group_party gp
WHERE 	      s.application_id::text = aa.id::text 
              and (npbu.party_id in (select pm.party_id from party.party_member pm where pm.group_id = gp.id))
              and (npbu.target_party_id in (select pm.party_id from party.party_member pm where pm.group_id = gp.id))
              and s.request_type_code::text = ''cancelRelationship''::text 
              and npbu.cancel_service_id = s.id
	      and aa.id = #{id})
;
select 0=0 as vl
');

INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('cancel-relation-notification', 'application', 'approve', 'warning', 300);



--- party.source_describes_party; tables

-- DROP TABLE party.source_describes_party;

CREATE TABLE  party.source_describes_party
(
  source_id character varying(40) NOT NULL,
  party_id character varying(40) NOT NULL,
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
  rowversion integer NOT NULL DEFAULT 0,
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
  change_user character varying(50),
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT source_describes_party_pkey PRIMARY KEY (source_id, party_id),
  CONSTRAINT source_describes_party_party_id_fk41 FOREIGN KEY (party_id)
      REFERENCES party.party (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT source_describes_party_source_id_fk42 FOREIGN KEY (source_id)
      REFERENCES source.source (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);
ALTER TABLE party.source_describes_party OWNER TO postgres;
COMMENT ON TABLE party.source_describes_party IS 'Implements the many-to-many relationship identifying administrative source instances with party instances
LADM Reference Object 
Relationship LA_AdministrativeSource - LA_PARTY
LADM Definition
Not Defined';

-- Index: party.source_describes_party_party_id_fk41_ind

--DROP INDEX party.source_describes_party_party_id_fk41_ind;

CREATE INDEX source_describes_party_party_id_fk41_ind
  ON party.source_describes_party
  USING btree
  (party_id);

-- Index: source_describes_party_index_on_rowidentifier

--DROP INDEX source_describes_party_index_on_rowidentifier;

CREATE INDEX source_describes_party_index_on_rowidentifier
  ON party.source_describes_party
  USING btree
  (rowidentifier);

-- Index: party.source_describes_party_source_id_fk42_ind

--DROP INDEX party.source_describes_party_source_id_fk42_ind;

CREATE INDEX source_describes_party_source_id_fk42_ind
  ON party.source_describes_party
  USING btree
  (source_id);


-- Trigger: __track_changes on aparty.source_describes_party

--DROP TRIGGER __track_changes ON party.source_describes_party;

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON party.source_describes_party
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

-- Trigger: __track_history on party.source_describes_party

--DROP TRIGGER __track_history ON party.source_describes_party;

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON party.source_describes_party
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
-- Table: party.source_describes_party_historic

-- DROP TABLE party.source_describes_party_historic;

CREATE TABLE party.source_describes_party_historic
(
  source_id character varying(40),
  party_id character varying(40),
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
ALTER TABLE party.source_describes_party_historic OWNER TO postgres;

-- Index: party.source_describes_party_historic_index_on_rowidentifier

--DROP INDEX party.source_describes_party_historic_index_on_rowidentifier;

CREATE INDEX source_describes_party_historic_index_on_rowidentifier
  ON party.source_describes_party_historic
  USING btree
  (rowidentifier);




INSERT INTO system.panel_launcher_group(
            code, display_value, description, status)
    VALUES ('recordRelationship','Record Relationship','Panels used for relationship services','c');
INSERT INTO system.config_panel_launcher(
            code, display_value, description, status, launch_group, panel_class, 
            message_code, card_name)
    VALUES ('recordRelationship','Record Relationship','','c','recordRelationship','org.sola.clients.swing.desktop.administrative.RecordPersonRelationshipPanel','cliprgs009','recordRelationship');


INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code,display_group_name, service_panel_code) 
VALUES ('recordRelationship', 'registrationServices', 'Record Person Relationship', '', 'c', 30, 0.00, 0.00, 0.00, 0, null, null, null,'Other Registration' ,'recordRelationship');






INSERT INTO system.panel_launcher_group(
            code, display_value, description, status)
    VALUES ('cancelRelationship','Cancel Relationship','Panels used for cancel relationship services','c');
INSERT INTO system.config_panel_launcher(
            code, display_value, description, status, launch_group, panel_class, 
            message_code, card_name)
    VALUES ('cancelRelationship','Cancel Relationship','','c','cancelRelationship','org.sola.clients.swing.desktop.administrative.CancelPersonRelationshipPanel','cliprgs009','cancelRelationship');


INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code,display_group_name, service_panel_code) 
VALUES ('cancelRelationship', 'registrationServices', 'Cancel Person Relationship', '', 'c', 30, 0.00, 0.00, 0.00, 0, null, null, null,'Other Registration' ,'cancelRelationship');






INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('recordRelationship', 'Service - Record of Interest', 'c', 'Registration Service. Allows to record interests within a relationship.');
INSERT INTO system.approle_appgroup(approle_code, appgroup_id)
VALUES ('recordRelationship', 'super-group-id');




INSERT INTO system.approle (code, display_value, status, description) 
VALUES ('cancelRelationship', 'Service - Cancel of Interest', 'c', 'Registration Service. Allows to cancel interests within a relationship.');
INSERT INTO system.approle_appgroup(approle_code, appgroup_id)
VALUES ('cancelRelationship', 'super-group-id');



insert into party.party_role_type(code, display_value, status) values('notifiablePerson', 'Notifiable Person', 'c');
insert into party.group_party_type(code, display_value, status) values('spouse', 'Spouse', 'c');
insert into party.group_party_type(code, display_value, status) values('inheritor', 'Inheritor', 'c');
--INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
--VALUES ('marriage', 'Marriage Certificate', 'c', '', 'f');
--INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
--VALUES ('birth', 'Birth Certificate', 'c', '', 'f');
--INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
--VALUES ('adoption', 'Adoption Certificate', 'c', '', 'f');
--INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
--VALUES ('divorce', 'Divorce Certificate', 'c', '', 'f');
--INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
--VALUES ('death', 'Death Certificate', 'c', '', 'f');
INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) 
VALUES ('relationshipTitle', 'Vital Certificate', 'c', '', 'f');
---General Register Certificate???


 -- Data for the table application.request_type_requires_source_type -- 
--insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('marriage', 'recordRelationship');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('relationshipTitle', 'recordRelationship');
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('relationshipTitle', 'cancelRelationship');



    
--Table administrative.notifiable_party_for_baunit ----
DROP TABLE IF EXISTS administrative.notifiable_party_for_baunit CASCADE;
CREATE TABLE administrative.notifiable_party_for_baunit(
    party_id varchar(40) NOT NULL,
    target_party_id varchar(40) NOT NULL,
    baunit_name varchar(40) NOT NULL,
    application_id varchar(40) NOT NULL,
    service_id varchar(40) NOT NULL,
    cancel_service_id varchar(40),
    status  varchar(40) NOT NULL DEFAULT ('c'),
    rowidentifier varchar(40) NOT NULL DEFAULT (uuid_generate_v1()),
    rowversion integer NOT NULL DEFAULT (0),
    change_action char(1) NOT NULL DEFAULT ('i'),
    change_user varchar(50),
    change_time timestamp NOT NULL DEFAULT (now()),

    -- Internal constraints
    
    CONSTRAINT notifiable_party_for_baunit_pkey PRIMARY KEY (party_id, target_party_id, baunit_name)
);



-- Index notifiable_party_for_baunit_index_on_rowidentifier  --
CREATE INDEX notifiable_party_for_baunit_index_on_rowidentifier ON administrative.notifiable_party_for_baunit (rowidentifier);
    

comment on table administrative.notifiable_party_for_baunit is 'Parties to be informed about transaction on baunit.';
    
DROP TRIGGER IF EXISTS __track_changes ON administrative.notifiable_party_for_baunit CASCADE;
CREATE TRIGGER __track_changes BEFORE UPDATE OR INSERT
   ON administrative.notifiable_party_for_baunit FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_changes();
    

----Table administrative.notifiable_party_for_rrr_historic used for the history of data of table administrative.notifiable_party_for_rrr ---
DROP TABLE IF EXISTS administrative.notifiable_party_for_baunit_historic CASCADE;
CREATE TABLE administrative.notifiable_party_for_baunit_historic
(
    party_id varchar(40),
    target_party_id varchar(40),
    baunit_name varchar(40),
    application_id varchar(40),
    service_id varchar(40),
    cancel_service_id varchar(40),
    status varchar(40),
    rowidentifier varchar(40),
    rowversion integer,
    change_action char(1),
    change_user varchar(50),
    change_time timestamp,
    change_time_valid_until TIMESTAMP NOT NULL default NOW()
);


-- Index notifiable_party_for_rrr_historic_index_on_rowidentifier  --
CREATE INDEX notifiable_party_for_baunit_historic_index_on_rowidentifier ON administrative.notifiable_party_for_baunit_historic (rowidentifier);
    

DROP TRIGGER IF EXISTS __track_history ON administrative.notifiable_party_for_baunit CASCADE;
CREATE TRIGGER __track_history AFTER UPDATE OR DELETE
   ON administrative.notifiable_party_for_baunit FOR EACH ROW
   EXECUTE PROCEDURE f_for_trg_track_history();


CREATE OR REPLACE VIEW application.cancel_notification AS 


 SELECT       pp.name partyName,    
              pp.last_name partyLastName,
              tpp.name targetpartyName,    
              tpp.last_name targetpartyLastName,    
              npbu.party_id,    
              npbu.target_party_id,
              npbu.baunit_name,
              npbu.service_id,
              npbu.cancel_service_id,
              gpp.id groupPartyId,    
              gpp.name groupPartyName,    
              gpp.last_name groupPartyLastName
 FROM 
	      party.party pp,
	      party.party tpp,
	      party.party gpp,       
	      administrative.notifiable_party_for_baunit npbu,
	      application.application aa, 
	      application.service s,
	      party.group_party gp
WHERE 	      s.application_id::text = aa.id::text 
              and s.id = npbu.cancel_service_id
	      and  (pp.id=npbu.party_id    
              and tpp.id=npbu.target_party_id)
              and  (gpp.id=gp.id)
              and (pp.id in (select pm.party_id from party.party_member pm where pm.group_id = gp.id))
              and (tpp.id in (select pm.party_id from party.party_member pm where pm.group_id = gp.id))
              and s.request_type_code::text = 'cancelRelationship'::text ;


	      
		

