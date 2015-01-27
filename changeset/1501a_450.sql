INSERT INTO system.version SELECT '1501a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1501a');

ALTER TABLE opentenure.claim ADD COLUMN claim_area bigint DEFAULT 0;
COMMENT ON COLUMN opentenure.claim.claim_area IS 'Claim area in square meters.';
ALTER TABLE opentenure.claim_historic ADD COLUMN claim_area bigint;