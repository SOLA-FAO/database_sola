INSERT INTO system.version SELECT '1503f' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1503f');

ALTER TABLE system.language ADD COLUMN ltr boolean NOT NULL DEFAULT 't';
COMMENT ON COLUMN system.language.ltr IS 'Indicates text direction. If true, then left to right should applied, otherwise right to left.';
UPDATE system.language SET ltr = 'f' WHERE code = 'ar-JO';

insert into source.administrative_source_type (code, display_value, description, status, is_for_registration) values ('personPhoto', 'Person photo', 'Photo of the person', 'c', 'f');