-- #396 Version Number table
CREATE TABLE system.version
(
  version_num character varying(50) NOT NULL, -- Identifier/name for the setting
  CONSTRAINT version_pkey PRIMARY KEY (version_num)
);

COMMENT ON TABLE system.version
  IS 'Identifies all changesets that have been applied to the SOLA database. The latest changeset applied to the database will indicate the current version of the SOLA database and code. Changesets are named using the year, month and a sequence character. E.g. The first changeset in Feb 2014 is 1402a, the second changeset in Feb 2014 is 1402b, etc. The sequence character must restart for each new month. E.g. in March 2014 the first changeset is 1403a. 
Tags: FLOSS SOLA Extension, System Configuration';
COMMENT ON COLUMN system.version.version_num IS 'The version number for the changeset.';

-- Add the previous changesets into the version table along with the version number for this current changeset (1402a). 
INSERT INTO system.version SELECT '1309a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1309a');
INSERT INTO system.version SELECT '1309b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1309b');
INSERT INTO system.version SELECT '1309c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1309c');
INSERT INTO system.version SELECT '1310a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1310a');
INSERT INTO system.version SELECT '1310b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1310b');
INSERT INTO system.version SELECT '1401a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1401a');
INSERT INTO system.version SELECT '1401b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1401b');
INSERT INTO system.version SELECT '1401c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1401c');
INSERT INTO system.version SELECT '1401d' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1401d');
INSERT INTO system.version SELECT '1402a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1402a');