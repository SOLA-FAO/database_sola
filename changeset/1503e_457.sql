INSERT INTO system.version SELECT '1503e' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1503e');

ALTER TABLE system.language ADD COLUMN ltr boolean NOT NULL DEFAULT 't';
COMMENT ON COLUMN system.language.ltr IS 'Indicates text direction. If true, then left to right should applied, otherwise right to left.';
UPDATE system.language SET ltr = 'f' WHERE code = 'ar-JO';