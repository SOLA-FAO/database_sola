COMMENT ON COLUMN opentenure.claimant.id IS 'Unique identifier for the party.';
COMMENT ON COLUMN opentenure.claimant.name IS 'First name of party.';
COMMENT ON COLUMN opentenure.claimant.birth_date IS 'Date of birth of the party.';
COMMENT ON COLUMN opentenure.claimant.gender_code IS 'Gender code of the party.';
COMMENT ON COLUMN opentenure.claimant.mobile_phone IS 'Mobile phone number of the party.';
COMMENT ON COLUMN opentenure.claimant.phone IS 'Landline phone number of the party.';
COMMENT ON COLUMN opentenure.claimant.email IS 'Email address of the party.';
COMMENT ON COLUMN opentenure.claimant.address IS 'Living address of the party.';
ALTER TABLE opentenure.claimant RENAME TO party;
COMMENT ON TABLE opentenure.party
  IS 'Extension to the LADM used by SOLA to store party information (cliamant or owner).';

ALTER TABLE opentenure.claimant_historic RENAME TO party_historic;
COMMENT ON TABLE opentenure.party_historic
  IS 'Historic table for opentenure.party. Keeps all changes done to the main table.';


CREATE TABLE opentenure.claim_share
(
  id character varying(40) NOT NULL, 
  claim_id character varying(40) NOT NULL, 
  nominator smallint NOT NULL, 
  denominator smallint NOT NULL, 
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  rowversion integer NOT NULL DEFAULT 0, 
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, 
  change_user character varying(50), 
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT claim_share_pkey PRIMARY KEY (id),
  CONSTRAINT claim_share_claim_id_fk12 FOREIGN KEY (claim_id)
      REFERENCES opentenure.claim (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE opentenure.claim_share
  IS 'Identifies the share a party has in a claim.';
COMMENT ON COLUMN opentenure.claim_share.id IS 'Identifier for the claim share.';
COMMENT ON COLUMN opentenure.claim_share.claim_id IS 'Identifier of the claim the share is assocaited with.';
COMMENT ON COLUMN opentenure.claim_share.nominator IS 'Nominiator part of the share (i.e. top number of fraction)';
COMMENT ON COLUMN opentenure.claim_share.denominator IS 'Denominator part of the share (i.e. bottom number of fraction)';
COMMENT ON COLUMN opentenure.claim_share.rowidentifier IS 'Identifies the all change records for the row in the claim_share_historic table';
COMMENT ON COLUMN opentenure.claim_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.claim_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.claim_share.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.claim_share.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.claim_share
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.claim_share
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

CREATE TABLE opentenure.claim_share_historic
(
  id character varying(40),
  claim_id character varying(40),
  nominator smallint,
  denominator smallint,
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


CREATE TABLE opentenure.party_for_claim_share
(
  party_id character varying(40) NOT NULL, 
  claim_share_id character varying(40) NOT NULL,
  rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(), 
  rowversion integer NOT NULL DEFAULT 0, 
  change_action character(1) NOT NULL DEFAULT 'i'::bpchar, 
  change_user character varying(50), 
  change_time timestamp without time zone NOT NULL DEFAULT now(),
  CONSTRAINT party_for_claim_share_pkey PRIMARY KEY (party_id, claim_share_id),
  CONSTRAINT party_for_claim_share_claim_id_fk43 FOREIGN KEY (claim_share_id)
      REFERENCES opentenure.claim_share (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT party_for_claim_share_party_id_fk23 FOREIGN KEY (party_id)
      REFERENCES opentenure.party (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

COMMENT ON TABLE opentenure.party_for_claim_share
  IS 'Identifies parties involved in the claim share.';
COMMENT ON COLUMN opentenure.party_for_claim_share.party_id IS 'Identifier for the party.';
COMMENT ON COLUMN opentenure.party_for_claim_share.claim_share_id IS 'Identifier of the claim share.';
COMMENT ON COLUMN opentenure.party_for_claim_share.rowidentifier IS 'Identifies the all change records for the row in the party_for_claim_share_historic table';
COMMENT ON COLUMN opentenure.party_for_claim_share.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.party_for_claim_share.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.party_for_claim_share.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.party_for_claim_share.change_time IS 'The date and time the row was last modified.';

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.party_for_claim_share
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.party_for_claim_share
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();

CREATE TABLE opentenure.party_for_claim_share_historic
(
  party_id character varying(40),
  claim_share_id character varying(40),
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

insert into system.approle (code,display_value,status,description) values ('ModerateClaim', 'Moderate claim', 'c', 'Allows to moderate claims submitted by other community recorders.');
insert into system.appgroup (id,name,description) values ('claim-moderators', 'Claim moderators', 'Group for users who can moderate claims, submitted by community recorders');
insert into system.appuser_appgroup (appuser_id, appgroup_id) values ('test-id', 'claim-moderators');
insert into system.approle_appgroup (approle_code, appgroup_id) values ('ModerateClaim', 'claim-moderators');
insert into system.approle_appgroup (approle_code, appgroup_id) values ('AccessCS', 'claim-moderators');

INSERT INTO system.version SELECT '1406a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1406a');