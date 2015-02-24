INSERT INTO system.version SELECT '1502a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1502a');

ALTER TABLE opentenure.claim_share
   ALTER COLUMN nominator DROP NOT NULL;
ALTER TABLE opentenure.claim_share
   ALTER COLUMN denominator DROP NOT NULL;
ALTER TABLE opentenure.claim_share ADD COLUMN percentage double precision;

COMMENT ON COLUMN opentenure.claim_share.percentage IS 'Percentage of the share. Another form of nominator/denominator presentation.';

ALTER TABLE opentenure.claim_share_historic ADD COLUMN percentage double precision;

ALTER TABLE system.config_map_layer_metadata ADD CONSTRAINT pk_config_map_layer_metadata PRIMARY KEY (name_layer, name);

ALTER TABLE system.approle ALTER COLUMN description TYPE character varying(5000);

INSERT INTO system.appgroup(id, name, description) VALUES ('CommunityMembers', 'Community members', 'Community memebers, who can view claims');
INSERT INTO system.approle_appgroup(approle_code, appgroup_id) VALUES ('AccessCS', 'CommunityMembers');