INSERT INTO system.version SELECT '1408a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1408a');

ALTER TABLE system.appuser ADD CONSTRAINT appuser_email_unique UNIQUE (email);
ALTER TABLE system.appuser ALTER COLUMN activation_code TYPE character varying(40);
ALTER TABLE system.appuser_historic ALTER COLUMN activation_code TYPE character varying(40);
UPDATE system.setting set vl = 'Dear #{userFullName},<br /><br />You have requested to restore the password. If you didn''t ask for this action, just ignore this message. Otherwise, follow <a href="#{passwordRestoreLink}">this link</a> to reset your password.<br /><br />Regards,<br />SOLA OpenTenure Team' WHERE name = 'email-msg-pswd-restore-body';

CREATE TABLE opentenure.land_use
(
  code character varying(20) NOT NULL, -- The code for the land use.
  display_value character varying(500) NOT NULL, -- Displayed value of the land use.
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- Status of the land use.
  description character varying(1000), -- Description of the land use.
  CONSTRAINT land_use_status_pkey PRIMARY KEY (code ),
  CONSTRAINT land_use_status_display_value_unique UNIQUE (display_value )
);

COMMENT ON COLUMN opentenure.land_use.code IS 'The code for the land use.';
COMMENT ON COLUMN opentenure.land_use.display_value IS 'Displayed value of the land use.';
COMMENT ON COLUMN opentenure.land_use.status IS 'Status of the land use.';
COMMENT ON COLUMN opentenure.land_use.description IS 'Description of the land use.';

ALTER TABLE opentenure.party ADD COLUMN is_person boolean DEFAULT true NOT NULL;
ALTER TABLE opentenure.party_historic ADD COLUMN is_person boolean;
COMMENT ON COLUMN opentenure.party.is_person IS 'Indicates if record is for individual or company (legal entity)';

ALTER TABLE opentenure.claim ADD COLUMN start_date date;
ALTER TABLE opentenure.claim ADD COLUMN land_use_code character varying(20);
ALTER TABLE opentenure.claim ADD CONSTRAINT fk_claim_land_use FOREIGN KEY (land_use_code) REFERENCES opentenure.land_use (code) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE opentenure.claim ADD COLUMN notes character varying(1000);
ALTER TABLE opentenure.claim ADD COLUMN north_adjacency character varying(500);
ALTER TABLE opentenure.claim ADD COLUMN south_adjacency character varying(500);
ALTER TABLE opentenure.claim ADD COLUMN east_adjacency character varying(500);
ALTER TABLE opentenure.claim ADD COLUMN west_adjacency character varying(500);
ALTER TABLE opentenure.claim ADD COLUMN assignee_name character varying(50);

COMMENT ON COLUMN opentenure.claim.start_date IS 'Start date of right (occupation)';
COMMENT ON COLUMN opentenure.claim.land_use_code IS 'Land use code';
COMMENT ON COLUMN opentenure.claim.notes IS 'Any note that could be usefully stored as part of the claim';
COMMENT ON COLUMN opentenure.claim.north_adjacency IS 'Optional information about adjacency on the north';
COMMENT ON COLUMN opentenure.claim.south_adjacency IS 'Optional information about adjacency on the south';
COMMENT ON COLUMN opentenure.claim.east_adjacency IS 'Optional information about adjacency on the east';
COMMENT ON COLUMN opentenure.claim.west_adjacency IS 'Optional information about adjacency on the west';
COMMENT ON COLUMN opentenure.claim.assignee_name IS 'User name who is assigned to work with claim';

ALTER TABLE opentenure.claim_historic ADD COLUMN notes character varying(1000);
ALTER TABLE opentenure.claim_historic ADD COLUMN start_date date;
ALTER TABLE opentenure.claim_historic ADD COLUMN north_adjacency character varying(500);
ALTER TABLE opentenure.claim_historic ADD COLUMN south_adjacency character varying(500);
ALTER TABLE opentenure.claim_historic ADD COLUMN east_adjacency character varying(500);
ALTER TABLE opentenure.claim_historic ADD COLUMN west_adjacency character varying(500);
ALTER TABLE opentenure.claim_historic ADD COLUMN assignee_name character varying(50);
ALTER TABLE opentenure.claim_historic ADD COLUMN land_use_code character varying(20);
ALTER TABLE opentenure.claim_historic ALTER COLUMN claimant_id DROP NOT NULL;
   
CREATE TABLE opentenure.claim_location
(
  id character varying(40) NOT NULL, -- Identifier for the claim location.
  claim_id character varying(40) NOT NULL, -- Identifier for the claim.
  mapped_location geometry NOT NULL, -- Additional claim location geometry
  gps_location geometry, -- Additional claim location geometry in Lat/Long format
  description character varying(500), -- Claim location description.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the claim_historic table.
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  CONSTRAINT claim_location_pkey PRIMARY KEY (id),
  CONSTRAINT claim_location_claim_id_fk8 FOREIGN KEY (claim_id)
      REFERENCES opentenure.claim (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT enforce_geotype_gps_location CHECK (geometrytype(gps_location) = 'POLYGON'::text OR geometrytype(gps_location) = 'POINT'::text OR gps_location IS NULL),
  CONSTRAINT enforce_geotype_mapped_location CHECK (geometrytype(mapped_location) = 'POLYGON'::text OR geometrytype(mapped_location) = 'POINT'::text),
  CONSTRAINT enforce_valid_gps_location CHECK (st_isvalid(gps_location)),
  CONSTRAINT enforce_valid_mapped_location CHECK (st_isvalid(mapped_location))
);

COMMENT ON COLUMN opentenure.claim_location.id IS 'Identifier for the claim location.';
COMMENT ON COLUMN opentenure.claim_location.claim_id IS 'Identifier for the claim.';
COMMENT ON COLUMN opentenure.claim_location.mapped_location IS 'Additional claim location geometry.';
COMMENT ON COLUMN opentenure.claim_location.gps_location IS 'Additional claim location geometry in Lat/Long format.';
COMMENT ON COLUMN opentenure.claim_location.description IS 'Claim location description.';
COMMENT ON COLUMN opentenure.claim_location.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';
COMMENT ON COLUMN opentenure.claim_location.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.claim_location.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.claim_location.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.claim_location.change_time IS 'The date and time the row was last modified.';


CREATE TABLE opentenure.claim_location_historic
(
  id character varying(40),
  claim_id character varying(40),
  mapped_location geometry,
  gps_location geometry,
  description character varying(500),
  rowidentifier character varying(40),
  rowversion integer NOT NULL,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.claim_location
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.claim_location
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

CREATE TABLE opentenure.claim_comment
(
  id character varying(40) NOT NULL, -- Identifier for the claim comment.
  claim_id character varying(40) NOT NULL, -- Identifier for the claim.
  comment character varying(500) NOT NULL, -- Comment text.
  comment_user character varying(50) NOT NULL, -- The user id who has created comment.
  creation_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time when comment was created.
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), -- Identifies the all change records for the row in the claim_historic table.
  rowversion integer NOT NULL DEFAULT 0, -- Sequential value indicating the number of times this row has been modified.
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, -- Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).
  change_user character varying(50), -- The user id of the last person to modify the row.
  change_time timestamp without time zone NOT NULL DEFAULT now(), -- The date and time the row was last modified.
  CONSTRAINT claim_comment_pkey PRIMARY KEY (id ),
  CONSTRAINT claim_comment_claim_id_fk8 FOREIGN KEY (claim_id)
      REFERENCES opentenure.claim (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON COLUMN opentenure.claim_comment.id IS 'Identifier for the claim comment.';
COMMENT ON COLUMN opentenure.claim_comment.claim_id IS 'Identifier for the claim.';
COMMENT ON COLUMN opentenure.claim_comment.comment IS 'Comment text.';
COMMENT ON COLUMN opentenure.claim_comment.comment_user IS 'The user id who has created comment.';
COMMENT ON COLUMN opentenure.claim_comment.creation_time IS 'The date and time when comment was created.';
COMMENT ON COLUMN opentenure.claim_comment.rowidentifier IS 'Identifies the all change records for the row in the claim_historic table.';
COMMENT ON COLUMN opentenure.claim_comment.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.claim_comment.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.claim_comment.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.claim_comment.change_time IS 'The date and time the row was last modified.';


CREATE TABLE opentenure.claim_comment_historic
(
  id character varying(40),
  claim_id character varying(40),
  comment character varying(500),
  comment_user character varying(50),
  creation_time timestamp without time zone,
  rowidentifier character varying(40),
  rowversion integer,
  change_action character(1),
  change_user character varying(50),
  change_time timestamp without time zone,
  change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.claim_comment
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.claim_comment
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('cropProduction', 'Crop Production', 'Crop Production', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('forestry', 'Forestry', 'Forestry', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('hunting', 'Hunting', 'Hunting', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('cropResidential', 'Crop Production and Residential', 'Crop Production and Residential', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('residential', 'Residential', 'Residential', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('construction', 'Construction', 'Construction', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('commerce', 'Commerce, finance and business', 'Commerce, finance and business', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('unused', 'Unused', 'Unused', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('mining', 'Mining and quarrying', 'Mining and quarrying', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('livestockProduction', 'Livestock Production', 'Livestock Production', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('commonage', 'Commonage', 'Commonage', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('tourism', 'Tourism', 'Tourism', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('leisure', 'Recreational, leisure and sport', 'Recreational, leisure and sport', 'c');

INSERT INTO opentenure.land_use(code, display_value, description, status)
VALUES ('industry', 'Industry and manufacturing', 'Industry and manufacturing', 'c');

INSERT INTO opentenure.claim_status(code, display_value, description, status)
VALUES ('withdrawn', 'Withdrawn', 'Status for withdrawn claims', 'c');

INSERT INTO opentenure.claim_status(code, display_value, description, status)
VALUES ('reviewed', 'Reviewed', 'Status for reviewed claims', 'c');

INSERT INTO opentenure.claim_status(code, display_value, description, status)
VALUES ('rejected', 'Rejected', 'Status for rejected claims', 'c');

INSERT INTO system.appgroup(id, name, description)
VALUES ('claim-reviewers', 'Claim reviewers', 'Claim reviewers');

INSERT INTO system.appuser(id, username, first_name, last_name, email, mobile_number, passwd, active, description)
VALUES ('claim-recorder', 'ClaimRecorder', 'Claim', 'Recorder', 'claim.recorder@mail.com', '111-222', 
'9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 't', 'Demo user for claim recorder role');

INSERT INTO system.appuser(id, username, first_name, last_name, email, mobile_number, passwd, active, description)
VALUES ('claim-reviewer', 'ClaimReviewer', 'Claim', 'Reviewer', 'claim.reviewer@mail.com', '111-333', 
'9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 't', 'Demo user for claim reviwer role');

INSERT INTO system.appuser(id, username, first_name, last_name, email, mobile_number, passwd, active, description)
VALUES ('claim-moderator', 'ClaimModerator', 'Claim', 'Moderator', 'claim.moderator@mail.com', '111-444', 
'9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', 't', 'Demo user for claim moderator role');

INSERT INTO system.approle(code, display_value, description, status)
VALUES ('ReviewClaim', 'Review claim', 'Review claim role', 'c');

INSERT INTO system.approle(code, display_value, description, status)
VALUES ('RecordClaim', 'Record claim', 'Community recorder role', 'c');

INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) VALUES ('test-id', 'claim-reviewers');
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) VALUES ('claim-recorder', 'CommunityRecorders');
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) VALUES ('test-id', 'CommunityRecorders');
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) VALUES ('claim-reviewer', 'claim-reviewers');
INSERT INTO system.appuser_appgroup (appuser_id, appgroup_id) VALUES ('claim-moderator', 'claim-moderators');

INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('RecordClaim', 'CommunityRecorders');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('RecordClaim', 'super-group-id');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('ReviewClaim', 'super-group-id');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('ReviewClaim', 'claim-reviewers');
INSERT INTO system.approle_appgroup (approle_code, appgroup_id) VALUES ('AccessCS', 'claim-reviewers');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-withdraw-body', 
'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has been withdrawn by community recorder.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim withdrawal notice body');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-withdraw-subject', 'SOLA OpenTenure - claim withdrawal', 't', 'Claim withdrawal notice subject');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-reject-body', 
'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has been rejected with the following reason:<br /><br />
<i>"#{claimRejectionReason}"</i><br /> <br /> 
The following comments were recorded on the claim:<br />#{claimComments}<br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim rejection notice body');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-reject-subject', 'SOLA OpenTenure - claim rejection', 't', 'Claim rejection notice subject');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-approve-review-body', 
'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has passed review stage with success.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim review approval notice body');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-approve-review-subject', 'SOLA OpenTenure - claim review approval', 't', 'Claim review approval notice subject');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-approve-moderation-body', 
'Dear #{userFirstName},<br /><br />
Claim <a href="#{claimLink}"><b>##{claimNumber}</b></a> has been approved.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim moderation approval notice body');

INSERT INTO system.setting (name, vl, active, description) VALUES ('email-msg-claim-approve-moderation-subject', 'SOLA OpenTenure - claim moderation approval', 't', 'Claim moderation approval notice subject');

UPDATE opentenure.claim SET status_code = 'unmoderated' WHERE status_code = 'challenged';
DELETE FROM opentenure.claim_status WHERE code = 'challenged';

update system.setting set 
vl = 'Dear #{userFullName},<br /><br />
New claim <b>##{claimNumber}</b> has been submitted. 
You can follow its status by <a href="#{claimLink}">this address</a>.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team'
where name = 'email-msg-claim-submit-body';

update system.setting set 
vl = 'Dear #{userFullName},<br /><br />Claim <b>##{claimNumber}</b> has been updated. Follow <a href="#{claimLink}">this link</a> to check claim status and updated information.<br /><br />Regards,<br />SOLA OpenTenure Team'
where name = 'email-msg-claim-updated-body';

update system.setting set 
vl = 'Dear #{userFullName},<br /><br />
New claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been submitted 
to challenge the claim <a href="#{claimLink}"><b>##{claimNumber}</b></a>.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team'
where name = 'email-msg-claim-challenge-submitted-body';

update system.setting set 
vl = 'Dear #{userFullName},<br /><br />
Claim challenge <b>##{challengeNumber}</b> has been updated. 
Follow <a href="#{challengeLink}">this link</a> to check updated information.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team'
where name = 'email-msg-claim-challenge-updated-body';

update system.setting set 
vl = 'SOLA OpenTenure - new claim challenge to the claim ##{claimNumber}'
where name = 'email-msg-claim-challenge-submitted-subject';

update system.setting set 
vl = 'SOLA OpenTenure - claim challenge ##{challengeNumber} update'
where name = 'email-msg-claim-challenge-updated-subject';

update system.setting set 
vl = 'SOLA OpenTenure - claim ##{claimNumber} update'
where name = 'email-msg-claim-updated-subject';

ALTER TABLE opentenure.attachment ADD CONSTRAINT fk_document_type_code FOREIGN KEY (type_code) REFERENCES source.administrative_source_type (code) ON UPDATE NO ACTION ON DELETE NO ACTION;

update system.config_map_layer set url='https://ot.flossola.org/geoserver/opentenure/wms', wms_layers='opentenure:claims' where name='claims-orthophoto';

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-approve-review-body', 
'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has passed review stage.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim challenge review approval notice body');

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-approve-review-subject', 
'SOLA OpenTenure - claim challenge review', 't', 'Claim challenge review approval notice subject');

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-approve-moderation-body', 
'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been moderated.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim challenge moderation approval notice body');

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-approve-moderation-subj',
'SOLA OpenTenure - claim challenge moderation', 't', 'Claim challenge moderation approval notice subject');

update system.setting set description = 'Claim rejection notice body' where name = 'email-msg-claim-reject-body';

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-reject-body',
'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been rejected with the following reason:<br /><br />
<i>"#{challengeRejectionReason}"</i><br /> <br />
Claim challenge comments:<br />#{challengeComments}<br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim challenge rejection notice body');

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-reject-subject', 
'SOLA OpenTenure - claim challenge rejection', 't', 'Claim challenge rejection notice subject');

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-withdraw-body', 
'Dear #{userFirstName},<br /><br />
Claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been withdrawn by community recorder.<br /><br />
<i>You are receiving this notification as the #{partyRole}</i><br /><br />
Regards,<br />SOLA OpenTenure Team', 't', 'Claim challenge withdrawal notice body');

insert into system.setting (name, vl, active, description) values ('email-msg-claim-challenge-withdraw-subject', 
'SOLA OpenTenure - claim challenge withdrawal', 't', 'Claim withdrawal notice subject');

insert into system.setting (name, vl, active, description) values (
'ot-community-area',
'POLYGON((175.068823 -36.785949,175.070902 -36.786461,175.079644 -36.787528,175.087001 -36.788041,175.090519 -36.787699,175.092118 -36.787101,175.093344 -36.785564,175.094677 -36.784967,175.096862 -36.785564,175.097875 -36.786290,175.102033 -36.784967,175.103366 -36.784796,175.106138 -36.782917,175.106991 -36.781636,175.117919 -36.784540,175.117274 -36.830375,175.113668 -36.831440,175.112302 -36.829328,175.109315 -36.828175,175.108238 -36.824562,175.107966 -36.821181,175.107092 -36.820481,175.104627 -36.821072,175.103862 -36.823171,175.101666 -36.827659,175.098931 -36.826071,175.097525 -36.828629,175.094896 -36.831006,175.094560 -36.832145,175.095884 -36.833196,175.093828 -36.836375,175.086922 -36.837365,175.085134 -36.834587,175.081358 -36.833326,175.078821 -36.834071,175.077160 -36.835777,175.075854 -36.836182,175.073712 -36.835163,175.071524 -36.836100,175.070229 -36.833666,175.068580 -36.834116,175.063665 -36.831845,175.064985 -36.830216,175.066285 -36.829052,175.066763 -36.826629,175.070516 -36.828458,175.072053 -36.826502,175.072377 -36.823365,175.071137 -36.820436,175.068876 -36.818138,175.068876 -36.807121,175.068876 -36.807121,175.068876 -36.807121,175.068876 -36.805628,175.068876 -36.805628,175.068823 -36.785949))',
't', 'Open Tenure community area where parcels can be claimed');

INSERT INTO source.administrative_source_type(code, display_value, status, description, is_for_registration)
    VALUES ('utilityBill', 'Utility bill', 'c', 'Utility bill', 'f');

INSERT INTO source.administrative_source_type(code, display_value, status, description, is_for_registration)
    VALUES ('taxPayment', 'Tax payment', 'c', 'Tax payment', 'f');

CREATE TABLE opentenure.rejection_reason
(
  code character varying(20) NOT NULL, -- The code for the rejection reason.
  display_value character varying(2000) NOT NULL, -- Displayed value of the rejection reason.
  status character(1) NOT NULL DEFAULT 't'::bpchar, -- Status of the rejection reason.
  description character varying(1000), -- Description of the rejection reason.
  CONSTRAINT rejection_reason_pkey PRIMARY KEY (code ),
  CONSTRAINT rejection_reason_display_value_unique UNIQUE (display_value )
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE opentenure.rejection_reason IS 'Rejection reason codes';
COMMENT ON COLUMN opentenure.rejection_reason.code IS 'The code for the rejection reason.';
COMMENT ON COLUMN opentenure.rejection_reason.display_value IS 'Displayed value of the rejection reason.';
COMMENT ON COLUMN opentenure.rejection_reason.status IS 'Status of the rejection reason.';
COMMENT ON COLUMN opentenure.rejection_reason.description IS 'Description of the rejection reason.';

INSERT INTO opentenure.rejection_reason(code, display_value, status, description)
    VALUES ('boundaryUnclear', 'The definition of the boundaries (of the claimed tenure rights) is missing from the claim, unclear, incorrectly defined or subject to an unresolved boundary dispute', 'c', 'Boundary unclear');
INSERT INTO opentenure.rejection_reason(code, display_value, status, description)
    VALUES ('missingEvidence', 'Documentary evidence in support of the claimed tenure rights is missing', 'c', 'Missing evidence');
INSERT INTO opentenure.rejection_reason(code, display_value, status, description)
    VALUES ('inconclusiveEvidence', 'Documentary evidence provided is insufficient to substantiate the claim to the tenure rights', 'c', 'Inconclusive evidence');
INSERT INTO opentenure.rejection_reason(code, display_value, status, description)
    VALUES ('validityOfEvidence', 'There are significant doubts concerning the validity of the documentary evidence provided in support of the claim to tenure rights', 'c', 'Invalid evidence');
INSERT INTO opentenure.rejection_reason(code, display_value, status, description)
    VALUES ('alternativeProcess', 'An alternative process must be completed before the claim to these tenure rights can be considered', 'c', 'Alternative process');
INSERT INTO opentenure.rejection_reason(code, display_value, status, description)
    VALUES ('others', 'Other reasons', 'c', 'Other reasons');

ALTER TABLE opentenure.claim ADD COLUMN rejection_reason_code character varying(20);
COMMENT ON COLUMN opentenure.claim.rejection_reason_code IS 'Rejection reason code.';
ALTER TABLE opentenure.claim ADD CONSTRAINT fk_claim_rejection_reason_code FOREIGN KEY (rejection_reason_code) 
  REFERENCES opentenure.rejection_reason (code) ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE opentenure.claim_historic ADD COLUMN rejection_reason_code character varying(20);
