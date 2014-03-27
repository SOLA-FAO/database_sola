-- Ticket #407
ALTER TABLE system.appuser DISABLE TRIGGER USER;

ALTER TABLE system.appuser ADD COLUMN email character varying(40), ADD COLUMN activation_code character varying(20), 
ADD COLUMN passwd1 character varying(100) NOT NULL DEFAULT uuid_generate_v1(),
ADD COLUMN active1 boolean NOT NULL DEFAULT true,
ADD COLUMN description1 character varying(255),
ADD COLUMN rowidentifier1 character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
ADD COLUMN rowversion1 integer NOT NULL DEFAULT 0,
ADD COLUMN change_action1 character(1) NOT NULL DEFAULT 'i'::bpchar,
ADD COLUMN change_user1 character varying(50),
ADD COLUMN change_time1 timestamp without time zone NOT NULL DEFAULT now();

DROP INDEX system.appuser_index_on_rowidentifier;

UPDATE system.appuser SET passwd1 = passwd, active1 = active, description1 = description, rowidentifier1 = rowidentifier, 
rowversion1 = rowversion, change_action1 = change_action, change_user1 = change_user, change_time1 = change_time;

ALTER TABLE system.appuser DROP COLUMN passwd CASCADE, DROP COLUMN active CASCADE, DROP COLUMN description CASCADE, DROP COLUMN rowidentifier CASCADE,
DROP COLUMN rowversion CASCADE, DROP COLUMN change_action CASCADE, DROP COLUMN change_user CASCADE, DROP COLUMN change_time CASCADE; 

ALTER TABLE system.appuser RENAME COLUMN passwd1 TO passwd;
ALTER TABLE system.appuser RENAME COLUMN active1 TO active;
ALTER TABLE system.appuser RENAME COLUMN description1 TO description;
ALTER TABLE system.appuser RENAME COLUMN rowidentifier1 TO rowidentifier;
ALTER TABLE system.appuser RENAME COLUMN rowversion1 TO rowversion;
ALTER TABLE system.appuser RENAME COLUMN change_action1 TO change_action;
ALTER TABLE system.appuser RENAME COLUMN change_user1 TO change_user;
ALTER TABLE system.appuser RENAME COLUMN change_time1 TO change_time;

CREATE INDEX appuser__index_on_rowidentifier
  ON system.appuser
  USING btree
  (rowidentifier COLLATE pg_catalog."default" );

--- HISTORIC TABLE -----
ALTER TABLE system.appuser_historic ADD COLUMN email character varying(40), ADD COLUMN activation_code character varying(20), 
ADD COLUMN passwd1 character varying(100) NOT NULL DEFAULT uuid_generate_v1(),
ADD COLUMN active1 boolean NOT NULL DEFAULT true,
ADD COLUMN description1 character varying(255),
ADD COLUMN rowidentifier1 character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
ADD COLUMN rowversion1 integer NOT NULL DEFAULT 0,
ADD COLUMN change_action1 character(1) NOT NULL DEFAULT 'i'::bpchar,
ADD COLUMN change_user1 character varying(50),
ADD COLUMN change_time1 timestamp without time zone NOT NULL DEFAULT now(),
ADD COLUMN change_time_valid_until1 timestamp without time zone NOT NULL DEFAULT now();

DROP INDEX system.appuser_historic_index_on_rowidentifier;
  
UPDATE system.appuser_historic SET passwd1 = passwd, active1 = active, description1 = description, rowidentifier1 = rowidentifier, 
rowversion1 = rowversion, change_action1 = change_action, change_user1 = change_user, change_time1 = change_time, change_time_valid_until1 = change_time_valid_until;

ALTER TABLE system.appuser_historic DROP COLUMN passwd CASCADE, DROP COLUMN active CASCADE, DROP COLUMN description CASCADE, DROP COLUMN rowidentifier CASCADE,
DROP COLUMN rowversion CASCADE, DROP COLUMN change_action CASCADE, DROP COLUMN change_user CASCADE, DROP COLUMN change_time CASCADE, DROP COLUMN change_time_valid_until CASCADE; 

ALTER TABLE system.appuser_historic RENAME COLUMN passwd1 TO passwd;
ALTER TABLE system.appuser_historic RENAME COLUMN active1 TO active;
ALTER TABLE system.appuser_historic RENAME COLUMN description1 TO description;
ALTER TABLE system.appuser_historic RENAME COLUMN rowidentifier1 TO rowidentifier;
ALTER TABLE system.appuser_historic RENAME COLUMN rowversion1 TO rowversion;
ALTER TABLE system.appuser_historic RENAME COLUMN change_action1 TO change_action;
ALTER TABLE system.appuser_historic RENAME COLUMN change_user1 TO change_user;
ALTER TABLE system.appuser_historic RENAME COLUMN change_time1 TO change_time;
ALTER TABLE system.appuser_historic RENAME COLUMN change_time_valid_until1 TO change_time_valid_until;

CREATE INDEX appuser_historic_index_on_rowidentifier
  ON system.appuser_historic
  USING btree
  (rowidentifier COLLATE pg_catalog."default" );

---- ENABLE TRIGGERS -----
ALTER TABLE system.appuser ENABLE TRIGGER USER;

