INSERT INTO system.version SELECT '1503c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1503c');

CREATE OR REPLACE FUNCTION system.process_progress_get(process_id character varying)
  RETURNS integer AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision default 0;
BEGIN
  if (select count(1) from information_schema.sequences where sequence_schema || '.' || sequence_name = sequence_prefix || process_id)>0 then
    execute 'select last_value from ' || sequence_prefix || process_id into vl;
  end if;
  return vl;
END;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION system.process_progress_get_in_percentage(process_id character varying)
  RETURNS integer AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision default 1;
BEGIN
  if (select count(1) from information_schema.sequences where sequence_schema || '.' || sequence_name = sequence_prefix || process_id)>0 then
    execute 'select cast(100 * last_value::double precision/max_value::double precision as integer) from ' || sequence_prefix || process_id into vl;
  end if;
  return vl;
END;
$BODY$
  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION system.process_progress_set(process_id character varying, progress_value integer)
  RETURNS void AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  max_progress_value integer;
BEGIN
  if (select count(1) from information_schema.sequences where sequence_schema || '.' || sequence_name = sequence_prefix || process_id)=0 then
    return;
  end if;
  execute 'select max_value from ' || sequence_prefix || process_id into max_progress_value;
  if progress_value> max_progress_value then
    progress_value = max_progress_value;
  end if;
  perform setval(sequence_prefix || process_id, progress_value);
END;
$BODY$
  LANGUAGE plpgsql;
 