ALTER TABLE administrative.ba_unit_as_party 
  ADD COLUMN rowidentifier character varying(40) not null default uuid_generate_v1();

COMMENT ON COLUMN administrative.ba_unit_as_party.rowidentifier 
  IS 'SOLA Extension: Identifies the all change records for the row in the ba_unit_as_party table';
