INSERT INTO system.version SELECT '1410a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1410a');

update opentenure.claim set land_use_code = null;
ALTER TABLE opentenure.claim DROP CONSTRAINT fk_claim_land_use;
ALTER TABLE opentenure.claim ADD CONSTRAINT fk_claim_land_use_type FOREIGN KEY (land_use_code)
      REFERENCES cadastre.land_use_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
DROP TABLE opentenure.land_use;