-- Ticket #407
--- DROP DEPENDENT OBJECTS -----
DROP VIEW system.active_users;
DROP VIEW system.user_pword_expiry;
DROP VIEW system.user_roles;

ALTER TABLE system.appuser DISABLE TRIGGER USER;

ALTER TABLE system.appuser ADD COLUMN email character varying(40), ADD COLUMN mobile_number character varying(20), 
ADD COLUMN activation_code character varying(20), 
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

ALTER TABLE system.appuser DROP COLUMN passwd, DROP COLUMN active, DROP COLUMN description, DROP COLUMN rowidentifier,
DROP COLUMN rowversion, DROP COLUMN change_action, DROP COLUMN change_user, DROP COLUMN change_time; 

ALTER TABLE system.appuser RENAME COLUMN passwd1 TO passwd;
ALTER TABLE system.appuser RENAME COLUMN active1 TO active;
ALTER TABLE system.appuser RENAME COLUMN description1 TO description;
ALTER TABLE system.appuser RENAME COLUMN rowidentifier1 TO rowidentifier;
ALTER TABLE system.appuser RENAME COLUMN rowversion1 TO rowversion;
ALTER TABLE system.appuser RENAME COLUMN change_action1 TO change_action;
ALTER TABLE system.appuser RENAME COLUMN change_user1 TO change_user;
ALTER TABLE system.appuser RENAME COLUMN change_time1 TO change_time;

CREATE INDEX appuser_index_on_rowidentifier
  ON system.appuser
  USING btree
  (rowidentifier COLLATE pg_catalog."default" );

--- HISTORIC TABLE -----
ALTER TABLE system.appuser_historic ADD COLUMN email character varying(40), ADD COLUMN mobile_number character varying(20), 
ADD COLUMN activation_code character varying(20), 
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

ALTER TABLE system.appuser_historic DROP COLUMN passwd, DROP COLUMN active, DROP COLUMN description, DROP COLUMN rowidentifier,
DROP COLUMN rowversion, DROP COLUMN change_action, DROP COLUMN change_user, DROP COLUMN change_time, DROP COLUMN change_time_valid_until; 

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

--- ADD COMMENTS ----
COMMENT ON COLUMN system.appuser.email IS 'User''s email address';
COMMENT ON COLUMN system.appuser.mobile_number IS 'User''s mobile phone number';
COMMENT ON COLUMN system.appuser.activation_code IS 'Activation code used to confirm user''s registration';
COMMENT ON COLUMN system.appuser.passwd IS 'User''s password';
COMMENT ON COLUMN system.appuser.active IS 'Indicates if user''s account is active (enabled) or not';
COMMENT ON COLUMN system.appuser.description IS 'Free text description of user''s additional details';

---- ENABLE TRIGGERS -----
ALTER TABLE system.appuser ENABLE TRIGGER USER;

--- CREATE DROPPED DEPENDENCY OBJECTS ----

CREATE OR REPLACE VIEW system.user_roles AS 
 SELECT u.username, rg.approle_code AS rolename
   FROM system.appuser u
   JOIN system.appuser_appgroup ug ON u.id::text = ug.appuser_id::text AND u.active
   JOIN system.approle_appgroup rg ON ug.appgroup_id::text = rg.appgroup_id::text;

ALTER TABLE system.user_roles
  OWNER TO postgres;
COMMENT ON VIEW system.user_roles
  IS 'Determines the application security roles assigned to each user. Referenced by the SolaRealm security configuration in Glassfish.';

CREATE OR REPLACE VIEW system.user_pword_expiry AS 
 WITH pw_change_all AS (
                 SELECT u.username, u.change_time, u.change_user, u.rowversion
                   FROM system.appuser u
                  WHERE NOT (EXISTS ( SELECT uh2.id
                           FROM system.appuser_historic uh2
                          WHERE uh2.username::text = u.username::text AND uh2.rowversion = (u.rowversion - 1) AND uh2.passwd::text = u.passwd::text))
        UNION 
                 SELECT uh.username, uh.change_time, uh.change_user, uh.rowversion
                   FROM system.appuser_historic uh
                  WHERE NOT (EXISTS ( SELECT uh2.id
                           FROM system.appuser_historic uh2
                          WHERE uh2.username::text = uh.username::text AND uh2.rowversion = (uh.rowversion - 1) AND uh2.passwd::text = uh.passwd::text))
        ), pw_change AS (
         SELECT pall.username AS uname, pall.change_time AS last_pword_change, pall.change_user AS pword_change_user
           FROM pw_change_all pall
          WHERE pall.rowversion = (( SELECT max(p2.rowversion) AS max
                   FROM pw_change_all p2
                  WHERE p2.username::text = pall.username::text))
        )
 SELECT p.uname, p.last_pword_change, p.pword_change_user, 
        CASE
            WHEN (EXISTS ( SELECT r.username
               FROM system.user_roles r
              WHERE r.username::text = p.uname::text AND (r.rolename::text = ANY (ARRAY['ManageSecurity'::character varying::text, 'NoPasswordExpiry'::character varying::text])))) THEN true
            ELSE false
        END AS no_pword_expiry, 
        CASE
            WHEN s.vl IS NULL THEN NULL::integer
            ELSE p.last_pword_change::date - now()::date + s.vl::integer
        END AS pword_expiry_days
   FROM pw_change p
   LEFT JOIN system.setting s ON s.name::text = 'pword-expiry-days'::text AND s.active;

ALTER TABLE system.user_pword_expiry
  OWNER TO postgres;
COMMENT ON VIEW system.user_pword_expiry
  IS 'Determines the number of days until the users password expires. Once the number of days reaches 0, users will not be able to log into SOLA unless they have the ManageSecurity role (i.e. role to change manage user accounts) or the NoPasswordExpiry role. To configure the number of days before a password expires, set the pword-expiry-days setting in system.setting table. If this setting is not in place, then a password expiry does not apply.';


CREATE OR REPLACE VIEW system.active_users AS 
 SELECT u.username, u.passwd
   FROM system.appuser u, system.user_pword_expiry ex
  WHERE u.active = true AND ex.uname::text = u.username::text AND (COALESCE(ex.pword_expiry_days, 1) > 0 OR ex.no_pword_expiry = true);

ALTER TABLE system.active_users
  OWNER TO postgres;
COMMENT ON VIEW system.active_users
  IS 'Identifies the users currently active in the system. If the users password has expired, then they are treated as inactive users, unless they are System Administrators. This view is intended to replace the system.appuser table in the SolaRealm configuration in Glassfish.';

INSERT INTO system.version SELECT '1403b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1403b');