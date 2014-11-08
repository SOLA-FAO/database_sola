INSERT INTO system.version SELECT '1411a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1411a');

CREATE OR REPLACE FUNCTION system.consolidation_extract_make_consolidation_schema(
  admin_user character varying -- the id of the administrator
  , everything boolean -- True if all not extracted applications has to be extracted
  )
  RETURNS boolean AS
$BODY$
DECLARE
  process_id varchar default 'extract_make_consolidation_schema';
  steps_max integer;
BEGIN
  steps_max = (select (count(*) * 3) + 7 from system.consolidation_config);
  -- Create a process
  execute system.process_log_start(process_id);
  -- Create progress
  execute system.process_progress_start(process_id, steps_max);
  -- Make consolidation schema
  return system.consolidation_extract(admin_user, everything, process_id);
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.consolidation_extract_make_consolidation_schema(character varying, boolean) IS 'Makes the consolidation schema with all the information that can be extracted.';

CREATE OR REPLACE FUNCTION system.get_text_from_schema_only(schema_name character varying)
  RETURNS text AS
$BODY$
DECLARE
  table_rec record;
  total_script varchar default '';
  sql_part varchar;
  new_line_values varchar default '
';
BEGIN
  
  -- Drop schema if exists.
  sql_part = 'DROP SCHEMA IF EXISTS ' || schema_name || ' CASCADE;';        
  total_script = sql_part || new_line_values;  
  
  -- Make the schema empty.
  sql_part = 'CREATE SCHEMA ' || schema_name || ';';
  total_script = total_script || sql_part || new_line_values;  
  
  -- Loop through all tables in the schema
  for table_rec in select table_name from information_schema.tables where table_schema = schema_name loop

    -- Make the create statement for the table
    sql_part = (select 'create table ' || schema_name || '.' || table_rec.table_name || '(' || new_line_values
      || string_agg('  ' || col_definition, ',' || new_line_values) || ');'
    from (select column_name || ' ' 
      || udt_name 
      || coalesce('(' || character_maximum_length || ')', '') 
        || case when udt_name = 'numeric' then coalesce('(' || numeric_precision || ',' || numeric_scale  || ')', '') else '' end as col_definition
      from information_schema.columns
      where table_schema = schema_name and table_name = table_rec.table_name
      order by ordinal_position) as cols);
    total_script = total_script || sql_part || new_line_values;
  end loop;

  return total_script;
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.get_text_from_schema_only(character varying) IS 'Gets the script that can regenerate the schema structure.';

update system.br_definition set
  body = 'with def_of_tables as (select source_table_name, target_table_name, (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') 
        || case when udt_name = ''numeric'' then ''('' || numeric_precision || '','' || numeric_scale  || '')'' else '''' end as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.source_table_name) as ttt) as source_def,
      (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') 
        || case when udt_name = ''numeric'' then ''('' || numeric_precision || '','' || numeric_scale  || '')'' else '''' end as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.target_table_name) as ttt) as target_def      
from consolidation.config config)
select count(*)=0 as vl from def_of_tables where source_def != target_def'
where br_id= 'consolidation-db-structure-the-same';
