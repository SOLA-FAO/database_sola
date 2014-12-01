INSERT INTO system.version SELECT '1411b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1411b');

drop function if exists system.consolidation_consolidate(character varying);
drop function if exists system.consolidation_extract(character varying, boolean);
drop function if exists system.get_text_from_schema(character varying);
drop function if exists system.script_to_schema(text);
DROP FUNCTION if exists system.consolidation_extract_make_consolidation_schema(character varying, boolean);
DROP FUNCTION if exists system.script_to_schema(extraction_script text);
DROP FUNCTION if exists system.process_log_get(process_id_v character varying);
DROP FUNCTION if exists system.process_log_start(process_id character varying);
DROP FUNCTION if exists system.process_log_update(process_id character varying, log_input character varying);
DROP FUNCTION if exists system.get_text_from_schema_only(schema_name character varying);
DROP FUNCTION if exists system.get_text_from_schema_table(schema_name character varying, table_name_v character varying, rows_at_once bigint, start_row_nr bigint);
DROP FUNCTION if exists system.run_script(script_body text);
delete from system.setting where name='zip-pass';

delete from system.br_validation where br_id in ('generate-process-progress-consolidate-max', 'generate-process-progress-extract-max', 
  'consolidation-db-structure-the-same', 'consolidation-not-again', 'consolidation-extraction-file-name', 
  'application-not-transferred', 'application-spatial-unit-not-transferred');
delete from system.br 
where id in ('generate-process-progress-consolidate-max', 'generate-process-progress-extract-max', 
  'consolidation-db-structure-the-same', 'consolidation-not-again', 'consolidation-extraction-file-name', 
  'application-not-transferred', 'application-spatial-unit-not-transferred');


INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('consolidation-db-structure-the-same', 'consolidation-db-structure-the-same', 'sql', 'The structure of the tables in the source and target database are the same.', NULL, 'It controls if every source table in consolidation schema is the same as the corresponding target table.');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('consolidation-db-structure-the-same', '2014-02-20', 'infinity', 'with def_of_tables as (
  select source_table_name, target_table_name, 
    (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.source_table_name) as ttt) as source_def,
    (select string_agg(col_definition, ''##'') from (select column_name || '' '' 
      || udt_name 
      || coalesce(''('' || character_maximum_length || '')'', '''') as col_definition
      from information_schema.columns cols
      where cols.table_schema || ''.'' || cols.table_name = config.target_table_name) as ttt) as target_def      
from consolidation.config config)
select count(*)=0 as vl from def_of_tables where source_def != target_def');

INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('consolidation-not-again', 'Records are unique', 'sql', 'Records being consolidated must not be present in the destination. 
result', '', '');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('consolidation-not-again', '2014-09-12', 'infinity', 'select not records_found as vl, result from system.get_already_consolidated_records() as vl');

INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-not-transferred', 'application-not-transferred', 'sql', 'An application should not be already transferred to another system.', NULL, 'The application should not have the status transferred.');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('application-not-transferred', '2014-09-12', 'infinity', 'select status_code != ''transferred'' as vl from application.application where id = #{id}');
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('application-spatial-unit-not-transferred', 'application-spatial-unit-not-transferred', 'sql', 'An application must not use a parcel already transferred.', NULL, 'It checks if the application has no spatial_unit that is already targeted by an application that has the status  transferred.');
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('application-spatial-unit-not-transferred', '2014-09-12', 'infinity', 'select count(1) = 0 as vl
from application.application_spatial_unit  
where application_id = #{id} and spatial_unit_id in (select spatial_unit_id from application.application_spatial_unit where application_id in (select id from application.application where status_code=''transferred''))');

INSERT INTO system.br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('consolidation-db-structure-the-same', 'consolidation-db-structure-the-same', 'consolidation', NULL, NULL, NULL, NULL, NULL, 'critical', 570);
INSERT INTO system.br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('consolidation-not-again', 'consolidation-not-again', 'consolidation', NULL, NULL, NULL, NULL, NULL, 'critical', 1);
INSERT INTO system.br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('bef9efc8-99dd-11e3-964f-6b27f41ee3f8', 'application-not-transferred', 'application', 'assign', NULL, NULL, NULL, NULL, 'critical', 1);
INSERT INTO system.br_validation (id, br_id, target_code, target_application_moment, target_service_moment, target_reg_moment, target_request_type_code, target_rrr_type_code, severity_code, order_of_execution) VALUES ('befa8c08-99dd-11e3-aee6-bf668a86c63d', 'application-spatial-unit-not-transferred', 'application', 'addSpatialUnit', NULL, NULL, NULL, NULL, 'critical', 300);

-- Insert a new setting called system-id. This must be a unique number that identifies the installed system.
insert into system.setting(name, vl, active, description) 
select 'system-id', '', true, 'A unique number that identifies the installed SOLA system. This unique number is used in the br that generate unique identifiers.'
where not exists (select name from system.setting where name='system-id');

-- Insert roles
insert into system.approle(code, display_value, status, description)
select 'ApplnTransfer', 'Appln Action - Transfer', 'c', 'The action that bring the application in the To be transferred state.'
where not exists (select * from system.approle where code='ApplnTransfer');
insert into system.approle_appgroup(approle_code, appgroup_id) 
select 'ApplnTransfer', 'super-group-id'
where not exists (select * from system.approle_appgroup where approle_code = 'ApplnTransfer' and appgroup_id='super-group-id');

insert into application.application_status_type(code, display_value, status, description)
select 'to-be-transferred', 'To be transferred', 'c', 'Application is marked for transfer.'
where not exists (select * from application.application_status_type where code='to-be-transferred');

insert into application.application_status_type(code, display_value, status, description)
select 'transferred', 'Transferred', 'c', 'Application is transferred.'
where not exists (select * from application.application_status_type where code='transferred');

insert into application.application_action_type(code, display_value, status_to_set, status, description)
select 'transfer', 'Transfer', 'to-be-transferred', 'c', 'Marks the application for transfer'
where not exists (select * from application.application_action_type where code='transfer');



--
-- Name: system.get_already_consolidated_records(); Type: FUNCTION; Schema: system; Owner: postgres
--

CREATE OR REPLACE  FUNCTION system.get_already_consolidated_records(OUT result character varying, OUT records_found boolean) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare
  table_rec record;
  sql_st varchar;
  total_result varchar default '';
  table_result varchar;
  new_line varchar default '
';
BEGIN
  for table_rec 
    in select * from consolidation.config 
       where not remove_before_insert and target_table_name not like '%_historic' loop
    sql_st = 'select string_agg(rowidentifier, '','') from ' || table_rec.source_table_name 
      || ' where rowidentifier in (select rowidentifier from ' || table_rec.target_table_name || ')';
    execute sql_st into table_result;
    if table_result != '' then
      total_result = total_result || new_line || '  - table: ' || table_rec.target_table_name 
        || ' row ids:' || table_result;
    end if;
  end loop;
  if total_result != '' then
    total_result = 'Records already present in destination:' || total_result;
  end if;
  result = total_result;
  records_found = (total_result != '');
END;
$$;

COMMENT ON FUNCTION system.get_already_consolidated_records(OUT result character varying, OUT records_found boolean) IS 'It retrieves the records that are already consolidated and being asked again for consolidation.';



CREATE OR REPLACE FUNCTION system.process_progress_start(process_id varchar, max_value integer)
  RETURNS void AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute system.process_progress_stop(process_id);
  execute 'CREATE SEQUENCE ' || sequence_prefix || process_id
   || ' INCREMENT 1 START 1 MINVALUE 1 MAXVALUE ' || max_value::varchar;   
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_progress_start(varchar, integer) is 'It starts a process progress counter.';

CREATE OR REPLACE FUNCTION system.process_progress_stop(process_id varchar)
  RETURNS void AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute 'DROP SEQUENCE IF EXISTS ' || sequence_prefix || process_id;   
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_progress_stop(varchar) is 'It stops a process progress counter.';

CREATE OR REPLACE FUNCTION system.process_progress_set(process_id varchar, progress_value integer)
  RETURNS void AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  max_progress_value integer;
BEGIN
  execute 'select max_value from ' || sequence_prefix || process_id into max_progress_value;
  if progress_value> max_progress_value then
    progress_value = max_progress_value;
  end if;
  perform setval(sequence_prefix || process_id, progress_value);
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_progress_set(varchar, integer) is 'It sets a new value for the process progress.';

CREATE OR REPLACE FUNCTION system.process_progress_get(process_id varchar)
  RETURNS integer AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision;
BEGIN
  execute 'select last_value from ' || sequence_prefix || process_id into vl;
  return vl;
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_progress_get(varchar) is 'Gets the absolute value of the process progress.';

CREATE OR REPLACE FUNCTION system.process_progress_get_in_percentage(process_id varchar)
  RETURNS integer AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision;
BEGIN
  execute 'select cast(100 * last_value::double precision/max_value::double precision as integer) from ' || sequence_prefix || process_id into vl;
  return vl;
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_progress_get_in_percentage(varchar) is 'Gets the value of the process progress in percentage.';


DROP TABLE if exists system.extracted_rows;

CREATE TABLE system.extracted_rows
(
  table_name character varying(200) NOT NULL, -- The table where the record has been found. It has to be absolute table name including the schema name.
  rowidentifier character varying(40) NOT NULL, -- The rowidentifier of the record. Carefull: It is the rowidentifier and not the id.
  CONSTRAINT extracted_rows_pkey PRIMARY KEY (table_name, rowidentifier)
);
COMMENT ON TABLE system.extracted_rows
  IS 'It logs every record that has been extracted from this database for consolidation purposes.';
COMMENT ON COLUMN system.extracted_rows.table_name IS 'The table where the record has been found. It has to be absolute table name including the schema name.';
COMMENT ON COLUMN system.extracted_rows.rowidentifier IS 'The rowidentifier of the record. Carefull: It is the rowidentifier and not the id.';

DROP TABLE system.consolidation_config;

CREATE TABLE system.consolidation_config
(
  id character varying(100) NOT NULL,
  schema_name character varying(100) NOT NULL,
  table_name character varying(100) NOT NULL,
  condition_description character varying(1000) NOT NULL,
  condition_sql character varying(1000),
  remove_before_insert boolean NOT NULL DEFAULT false,
  order_of_execution integer NOT NULL,
  log_in_extracted_rows boolean NOT NULL DEFAULT true, -- True - If the records has to be logged in the extracted rows table.
  CONSTRAINT consolidation_config_pkey PRIMARY KEY (id),
  CONSTRAINT consolidation_config_lkey UNIQUE (schema_name, table_name)
);
COMMENT ON TABLE system.consolidation_config
  IS 'This table contains the list of instructions to run the consolidation process.';
COMMENT ON COLUMN system.consolidation_config.schema_name IS 'Name of the source schema.';
COMMENT ON COLUMN system.consolidation_config.table_name IS 'Name of the source table.';
COMMENT ON COLUMN system.consolidation_config.condition_description IS 'Description of the condition has to be applied to rows of the source table for extraction.';
COMMENT ON COLUMN system.consolidation_config.condition_sql IS 'The SQL implementation of the condition.';
COMMENT ON COLUMN system.consolidation_config.remove_before_insert IS 'True - The records in the destination will be removed if they are found in the new extract. The check is done in rowidentifier.';
COMMENT ON COLUMN system.consolidation_config.order_of_execution IS 'Order of execution of the extract.';
COMMENT ON COLUMN system.consolidation_config.log_in_extracted_rows IS 'True - If the records has to be logged in the extracted rows table.';


CREATE OR REPLACE FUNCTION system.process_log_update(log_input character varying)
  RETURNS void AS
$BODY$
declare
  log_entry_moment varchar;  
BEGIN
  log_entry_moment = to_char(clock_timestamp(), 'yyyy-MM-dd HH24:MI:ss.ms | ');
  raise notice '%', log_entry_moment || log_input;
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.process_log_update(character varying) IS 'Updates the process log.';

CREATE OR REPLACE FUNCTION system.check_brs(br_target varchar, conditions varchar[][2])
  RETURNS varchar AS
$BODY$
declare
  log_entry_moment varchar;  
  rec record;
  br_rec record;
  condition varchar[];
  modified_body varchar;
  passed_criticals boolean default true;
  end_result varchar default '';
  new_line varchar default '
';
BEGIN
  
  for rec in select br_v.id as id, br_v.severity_code, br.display_name as name, br.feedback, br_d.body as body
      from system.br_validation br_v
        inner join system.br on br_v.br_id = br.id
        inner join system.br_definition br_d on br.id = br_d.br_id and now() between br_d.active_from and br_d.active_until
      where br_v.target_code = br_target
      order by br_v.order_of_execution
  loop
    modified_body = rec.body;
    -- Replace parameters in the body
    if conditions is not null then
      foreach condition slice 1 in array conditions loop
        modified_body = replace(modified_body, '#{' || condition[1] || '}', quote_nullable(condition[2]));
      end loop;
    end if;
    -- Call the br
    for br_rec in execute modified_body loop
      if not br_rec.vl and rec.severity_code='critical' then
        passed_criticals = false;
      end if;
      end_result = end_result 
       || '    BR:' || rec.feedback
       || '    Severity:' || rec.severity_code 
       || '    Passed:' || case when br_rec.vl then 'Yes' else 'No' end 
       || new_line;
    end loop;
  end loop;
  
  return passed_criticals || '####' || end_result;
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.check_brs(varchar, varchar[][2]) IS 'It checks the business rules. If one critical br is violated, it returns the result starting with false#### otherwise it starts with true####';

CREATE OR REPLACE FUNCTION system.consolidation_consolidate(admin_user character varying, process_name character varying)
  RETURNS void AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  cols varchar;
  exception_text_msg varchar;
  br_validation_result varchar;
  steps_max integer;
BEGIN

  steps_max = (select count(*) + 4 + 1 from system.consolidation_config);

  -- Create progress
  execute system.process_progress_start(process_name, steps_max);

    -- Checking business rules
  execute system.process_log_update('Validating consolidation schema against the other tables...');
  br_validation_result = system.check_brs('consolidation', null);  
  if br_validation_result like 'false####%' then
    execute system.process_log_update(substring(br_validation_result, 10));
    raise exception 'Validation failed!';
  else
    execute system.process_log_update(substring(br_validation_result, 9));
    execute system.process_log_update('Validation finished with success.');
  end if;
  execute system.process_log_update('Making the system not accessible for the users...');
  -- Make sola not accessible from all other users except the user running the consolidation.
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  -- Disable triggers.
  execute system.process_log_update('disabling all triggers...');
  perform fn_triggerall(false);
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  execute system.process_log_update('Move records from temporary consolidation schema to main tables.');
 
  -- For each table that is extracted and that has rows, insert the records into the main tables.
  for table_rec in select * from consolidation.config order by order_of_execution loop

    execute system.process_log_update('  - source table: "' || table_rec.source_table_name || '" destination table: "' || table_rec.target_table_name || '"... ');

    if table_rec.remove_before_insert then
      execute system.process_log_update('      deleting matching records in target table ...');
      execute 'delete from ' || table_rec.target_table_name ||
      ' where rowidentifier in (select rowidentifier from ' || table_rec.source_table_name || ')';
      execute system.process_log_update('      done');
    end if;
    cols = (select string_agg(column_name, ',')
      from information_schema.columns
      where table_schema || '.' || table_name = table_rec.target_table_name);
    execute system.process_log_update('      inserting records to target table ...');
    execute 'insert into ' || table_rec.target_table_name || '(' || cols || ') select ' || cols || ' from ' || table_rec.source_table_name;
    execute system.process_log_update('      done');
    execute system.process_log_update('  done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+2);
  
  end loop;
  
  -- Enable triggers.
  execute system.process_log_update('enabling all triggers...');
  perform fn_triggerall(true);
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  -- Make sola accessible for all users.
  execute system.process_log_update('Making the system accessible for the users...');
  update system.appuser set active = true where id != admin_user;
  execute system.process_log_update('done');
  execute system.process_log_update('Finished with success!');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.consolidation_consolidate(character varying, character varying) IS 'Moves records from the temporary consolidation schema into the main SOLA tables. Used by the bulk consolidation process.';

CREATE OR REPLACE FUNCTION system.consolidation_extract(admin_user character varying, everything boolean, process_name character varying)
  RETURNS boolean AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  sql_to_run varchar;
  order_of_exec int;
  steps_max integer;
BEGIN

  steps_max = (select (count(*) * 3) + 7 + 1 from system.consolidation_config);

  -- Create progress
  execute system.process_progress_start(process_name, steps_max);
  
  -- Prepare the process log
  execute system.process_log_update('Extraction process started.');
  if everything then
    execute system.process_log_update('Everything has to be extracted.');
  end if;
  execute system.process_log_update('');

  -- Make sola not accessible from all other users except the user running the consolidation.
  execute system.process_log_update('Making the system not accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  -- If everything is true it means all applications that do not have the status 'to-be-transferred' will get it.
  if everything then
    execute system.process_log_update('Marking the applications that are not yet marked for transfer...');
    update application.application set action_code = 'transfer', status_code='to-be-transferred' 
    where status_code not in ('to-be-transferred', 'transferred');
    execute system.process_log_update('done');    
  end if;
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  
  -- Drop schema consolidation if exists.
  execute system.process_log_update('Dropping schema consolidation...');
  execute 'DROP SCHEMA IF EXISTS ' || consolidation_schema || ' CASCADE;';    
  execute system.process_log_update('done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
      
  -- Make the schema.
  execute system.process_log_update('Creating schema consolidation...');
  execute 'CREATE SCHEMA ' || consolidation_schema || ';';
  execute system.process_log_update('done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  --Make table to define configuration for the the consolidation to the target database.
  execute system.process_log_update('Creating consolidation.config table...');
  execute 'create table ' || consolidation_schema || '.config (
    source_table_name varchar(100),
    target_table_name varchar(100),
    remove_before_insert boolean,
    order_of_execution int,
    status varchar(500)
  )';
  execute system.process_log_update('done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  execute system.process_log_update('Move records from main tables to consolidation schema.');
  order_of_exec = 1;
  for table_rec in select * from system.consolidation_config order by order_of_execution loop

    execute system.process_log_update('  - Table: ' || table_rec.schema_name || '.' || table_rec.table_name);
    -- Make the script to move the data to the consolidation schema.
    sql_to_run = 'create table ' || consolidation_schema || '.' || table_rec.table_name 
      || ' as select * from ' ||  table_rec.schema_name || '.' || table_rec.table_name
      || ' where rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=$1)';

    -- Add the condition to the end of the select statement if it is present
    if coalesce(table_rec.condition_sql, '') != '' then      
      sql_to_run = sql_to_run || ' and ' || table_rec.condition_sql;
    end if;

    -- Run the script
    execute system.process_log_update('      - move records...');
    execute sql_to_run using table_rec.schema_name || '.' || table_rec.table_name;
    execute system.process_log_update('      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    
    -- Log extracted records
    if table_rec.log_in_extracted_rows then
      execute system.process_log_update('      - log extracted records...');
      execute 'insert into system.extracted_rows(table_name, rowidentifier)
        select $1, rowidentifier from ' || consolidation_schema || '.' || table_rec.table_name
        using table_rec.schema_name || '.' || table_rec.table_name;
      execute system.process_log_update('      done');
    end if;  
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    

    -- Make a record in the config table
    sql_to_run = 'insert into ' || consolidation_schema 
      || '.config(source_table_name, target_table_name, remove_before_insert, order_of_execution) values($1,$2,$3, $4)'; 
    execute system.process_log_update('      - update config table...');
    execute sql_to_run 
      using  consolidation_schema || '.' || table_rec.table_name, 
             table_rec.schema_name || '.' || table_rec.table_name, 
             table_rec.remove_before_insert,
             order_of_exec;
    execute system.process_log_update('      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    order_of_exec = order_of_exec + 1;
  end loop;
  execute system.process_log_update('Done');


  -- Set the status of the applications that are in the consolidation schema to the previous status before they got the status
  -- to-be-transferred and unassign them.
  execute system.process_log_update('Set the status of the extracted applications to their previous status (before getting to be transferred status) and unassign them...');

  update consolidation.application set action_code = 'unAssign', assignee_id = null, assigned_datetime = null ,
    status_code = (select ah.status_code
      from application.application_historic ah
      where ah.id = application.id and ah.status_code not in ('to-be-transferred', 'transferred')
      order by ah.change_time desc limit 1);
  execute system.process_log_update('done');

  -- Set the status of the applications moved to consolidation schema to 'transferred' and unassign them.
  execute system.process_log_update('Unassign moved applications and set their status to ''transferred''...');
  update application.application set status_code='transferred', action_code = 'unAssign', assignee_id = null, assigned_datetime = null 
  where rowidentifier in (select rowidentifier from consolidation.application);
  execute system.process_log_update('done');

  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- Make sola accessible from all users.
  execute system.process_log_update('Making the system accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- return system.get_text_from_schema(consolidation_schema);
  return true;
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.consolidation_extract(character varying, boolean, character varying) IS 'Extracts the records from the database that are marked to be extracted.';

CREATE OR REPLACE FUNCTION system.process_progress_get(process_id character varying)
  RETURNS integer AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision;
BEGIN
  execute 'select last_value from ' || sequence_prefix || process_id into vl;
  return vl;
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.process_progress_get(character varying) IS 'Gets the absolute value of the process progress.';

CREATE OR REPLACE FUNCTION system.process_progress_get_in_percentage(process_id character varying)
  RETURNS integer AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  vl double precision;
BEGIN
  execute 'select cast(100 * last_value::double precision/max_value::double precision as integer) from ' || sequence_prefix || process_id into vl;
  return vl;
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.process_progress_get_in_percentage(character varying) IS 'Gets the value of the process progress in percentage.';

CREATE OR REPLACE FUNCTION system.process_progress_set(process_id character varying, progress_value integer)
  RETURNS void AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
  max_progress_value integer;
BEGIN
  execute 'select max_value from ' || sequence_prefix || process_id into max_progress_value;
  if progress_value> max_progress_value then
    progress_value = max_progress_value;
  end if;
  perform setval(sequence_prefix || process_id, progress_value);
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.process_progress_set(character varying, integer) IS 'It sets a new value for the process progress.';

CREATE OR REPLACE FUNCTION system.process_progress_start(process_id character varying, max_value integer)
  RETURNS void AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute system.process_progress_stop(process_id);
  execute 'CREATE SEQUENCE ' || sequence_prefix || process_id
   || ' INCREMENT 1 START 1 MINVALUE 1 MAXVALUE ' || max_value::varchar;   
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.process_progress_start(character varying, integer) IS 'It starts a process progress counter.';
CREATE OR REPLACE FUNCTION system.process_progress_stop(process_id character varying)
  RETURNS void AS
$BODY$
DECLARE
  sequence_prefix varchar default 'system.process_';
BEGIN
  execute 'DROP SEQUENCE IF EXISTS ' || sequence_prefix || process_id;   
END;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION system.process_progress_stop(character varying) IS 'It stops a process progress counter.';

INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application', 'application', 'application', 'Applications that have the status = “to-be-transferred”.', 'status_code = ''to-be-transferred'' and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application'')', false, 1, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.service', 'application', 'service', 'Every service that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.service'')', false, 2, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction', 'transaction', 'transaction', 'Every record that references a record in consolidation.service.', 'from_service_id in (select id from consolidation.service) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''transaction.transaction'')', false, 3, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction_source', 'transaction', 'transaction_source', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''transaction.transaction_source'')', false, 4, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_target', 'cadastre', 'cadastre_object_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object_target'')', false, 5, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_node_target', 'cadastre', 'cadastre_object_node_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object_node_target'')', false, 6, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_uses_source', 'application', 'application_uses_source', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_uses_source'')', false, 7, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_property', 'application', 'application_property', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_property'')', false, 8, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_spatial_unit', 'application', 'application_spatial_unit', 'Every record that belongs to the application being selected for transfer.', 'application_id in (select id from consolidation.application) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''application.application_spatial_unit'')', false, 9, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit', 'cadastre', 'spatial_unit', 'Every record that is referenced from application_spatial_unit or that is a targeted from a service already extracted or created from a service already extracted in consolidation schema.', '(id in (select spatial_unit_id from consolidation.application_spatial_unit) 
or id in (select id from cadastre.cadastre_object where transaction_id in (select id from consolidation.transaction))
or id in (select cadastre_object_id from consolidation.cadastre_object_target)
) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit'')', false, 10, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_in_group', 'cadastre', 'spatial_unit_in_group', 'Every record that references a record in consolidation.spatial_unit', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit_in_group'')', false, 11, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object', 'cadastre', 'cadastre_object', 'Every record that is also in consolidation.spatial_unit', 'id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.cadastre_object'')', false, 12, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_address', 'cadastre', 'spatial_unit_address', 'Every record that references a record in consolidation.spatial_unit.', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_unit_address'')', false, 13, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_value_area', 'cadastre', 'spatial_value_area', 'Every record that references a record in consolidation.spatial_unit.', 'spatial_unit_id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.spatial_value_area'')', false, 14, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.survey_point', 'cadastre', 'survey_point', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.survey_point'')', false, 15, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.legal_space_utility_network', 'cadastre', 'legal_space_utility_network', 'Every record that is also in consolidation.spatial_unit', 'id in (select id from consolidation.spatial_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''cadastre.legal_space_utility_network'')', false, 16, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_group', 'cadastre', 'spatial_unit_group', 'Every record', NULL, true, 17, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_contains_spatial_unit', 'administrative', 'ba_unit_contains_spatial_unit', 'Every record that references a record in consolidation.cadastre_object.', 'spatial_unit_id in (select id from consolidation.cadastre_object) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_contains_spatial_unit'')', false, 18, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.source_historic', 'source', 'source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source)', true, 43, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_target', 'administrative', 'ba_unit_target', 'Every record that references a record in consolidation.transaction.', 'transaction_id in (select id from consolidation.transaction) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_target'')', false, 19, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit', 'administrative', 'ba_unit', 'Every record that is referenced by consolidation.application_property or consolidation.ba_unit_contains_spatial_unit or consolidation.ba_unit_target.', '(id in (select ba_unit_id from consolidation.application_property) or id in (select ba_unit_id from consolidation.ba_unit_contains_spatial_unit) or id in (select ba_unit_id from consolidation.ba_unit_target)) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit'')', false, 20, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.required_relationship_baunit', 'administrative', 'required_relationship_baunit', 'Every record that references a record in consolidation.ba_unit.', 'from_ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.required_relationship_baunit'')', false, 21, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_area', 'administrative', 'ba_unit_area', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_area'')', false, 22, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_as_party', 'administrative', 'ba_unit_as_party', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.ba_unit_as_party'')', false, 23, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_ba_unit', 'administrative', 'source_describes_ba_unit', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.source_describes_ba_unit'')', false, 24, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr', 'administrative', 'rrr', 'Every record that references a record in consolidation.ba_unit.', 'ba_unit_id in (select id from consolidation.ba_unit) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.rrr'')', false, 25, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr_share', 'administrative', 'rrr_share', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.rrr_share'')', false, 26, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.party_for_rrr', 'administrative', 'party_for_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.party_for_rrr'')', false, 27, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.condition_for_rrr', 'administrative', 'condition_for_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.condition_for_rrr'')', false, 28, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.mortgage_isbased_in_rrr', 'administrative', 'mortgage_isbased_in_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.mortgage_isbased_in_rrr'')', false, 29, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_rrr', 'administrative', 'source_describes_rrr', 'Every record that references a record in consolidation.rrr.', 'rrr_id in (select id from consolidation.rrr) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.source_describes_rrr'')', false, 30, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.notation', 'administrative', 'notation', 'Every record that references a record in consolidation.ba_unit or consolidation.rrr or consolidation.transaction.', '(ba_unit_id in (select id from consolidation.ba_unit) or rrr_id in (select id from consolidation.rrr) or transaction_id in (select id from consolidation.transaction)) and rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=''administrative.notation'')', false, 31, true);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.source', 'source', 'source', 'Every source that is referenced from the consolidation.application_uses_source 
or consolidation.transaction_source
or source that references consolidation.transaction or source that is referenced from consolidation.source_describes_ba_unit or source that is referenced from consolidation.source_describes_rrr.', 'id in (select source_id from consolidation.application_uses_source)
or id in (select source_id from consolidation.transaction_source)
or transaction_id in (select id from consolidation.transaction)
or id in (select source_id from consolidation.source_describes_ba_unit)
or id in (select source_id from consolidation.source_describes_rrr) ', true, 32, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.power_of_attorney', 'source', 'power_of_attorney', 'Every record that is also in consolidation.source.', 'id in (select id from consolidation.source)', true, 33, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source', 'source', 'spatial_source', 'Every record that is also in consolidation.source.', 'id in (select id from consolidation.source)', true, 34, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source_measurement', 'source', 'spatial_source_measurement', 'Every record that references a record in consolidation.spatial_source.', 'spatial_source_id in (select id from consolidation.spatial_source)', true, 35, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.archive', 'source', 'archive', 'Every record that is referenced from a record in consolidation.source.', 'id in (select archive_id from consolidation.source) ', true, 36, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('document.document', 'document', 'document', 'Every record that is referenced by consolidation.source.', 'id in (select ext_archive_id from consolidation.source)', true, 37, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party', 'party', 'party', 'Every record that is referenced by consolidation.application or consolidation.ba_unit_as_party or consolidation.party_for_rrr.', 'id in (select agent_id from consolidation.application) or id in (select contact_person_id from consolidation.application) or id in (select agent_id from consolidation.application) or id in (select party_id from consolidation.party_for_rrr) or id in (select party_id from consolidation.ba_unit_as_party)', true, 38, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.group_party', 'party', 'group_party', 'Every record that is also in consolidation.party.', 'id in (select id from consolidation.party)', true, 39, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_member', 'party', 'party_member', 'Every record that references a record in consolidation.party.', 'party_id in (select id from consolidation.party)', true, 40, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_role', 'party', 'party_role', 'Every record that references a record in consolidation.party.', 'party_id in (select id from consolidation.party)', true, 41, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('address.address', 'address', 'address', 'Every record that is referenced by consolidation.party or consolidation.spatial_unit_address.', 'id in (select address_id from consolidation.party) or id in (select address_id from consolidation.spatial_unit_address)', true, 42, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.survey_point_historic', 'cadastre', 'survey_point_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.survey_point)', false, 44, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_value_area_historic', 'cadastre', 'spatial_value_area_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_value_area)', false, 45, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_address_historic', 'cadastre', 'spatial_unit_address_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_address)', false, 46, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source_measurement_historic', 'source', 'spatial_source_measurement_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_source_measurement)', false, 47, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.spatial_source_historic', 'source', 'spatial_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_source)', true, 48, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_rrr_historic', 'administrative', 'source_describes_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_rrr)', false, 49, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr_historic', 'administrative', 'rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.rrr)', false, 50, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.required_relationship_baunit_historic', 'administrative', 'required_relationship_baunit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.required_relationship_baunit)', false, 51, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.power_of_attorney_historic', 'source', 'power_of_attorney_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.power_of_attorney)', true, 52, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_role_historic', 'party', 'party_role_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_role)', true, 53, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_member_historic', 'party', 'party_member_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_member)', true, 54, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.party_for_rrr_historic', 'administrative', 'party_for_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party_for_rrr)', false, 55, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.legal_space_utility_network_historic', 'cadastre', 'legal_space_utility_network_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.legal_space_utility_network)', false, 56, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.group_party_historic', 'party', 'group_party_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.group_party)', true, 57, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.condition_for_rrr_historic', 'administrative', 'condition_for_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.condition_for_rrr)', false, 58, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_historic', 'cadastre', 'cadastre_object_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object)', false, 59, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_target_historic', 'administrative', 'ba_unit_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_target)', false, 60, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_contains_spatial_unit_historic', 'administrative', 'ba_unit_contains_spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_contains_spatial_unit)', false, 61, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_area_historic', 'administrative', 'ba_unit_area_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit_area)', false, 62, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('source.archive_historic', 'source', 'archive_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.archive)', true, 63, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_property_historic', 'application', 'application_property_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_property)', false, 64, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_historic', 'application', 'application_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application)', false, 65, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction_source_historic', 'transaction', 'transaction_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.transaction_source)', false, 66, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('transaction.transaction_historic', 'transaction', 'transaction_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.transaction)', false, 67, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_in_group_historic', 'cadastre', 'spatial_unit_in_group_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_in_group)', false, 68, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_group_historic', 'cadastre', 'spatial_unit_group_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit_group)', false, 69, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.spatial_unit_historic', 'cadastre', 'spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.spatial_unit)', false, 70, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.source_describes_ba_unit_historic', 'administrative', 'source_describes_ba_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.source_describes_ba_unit)', false, 71, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.service_historic', 'application', 'service_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.service)', false, 72, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.rrr_share_historic', 'administrative', 'rrr_share_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.rrr_share)', false, 73, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('party.party_historic', 'party', 'party_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.party)', true, 74, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.notation_historic', 'administrative', 'notation_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.notation)', false, 75, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.mortgage_isbased_in_rrr_historic', 'administrative', 'mortgage_isbased_in_rrr_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.mortgage_isbased_in_rrr)', false, 76, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('document.document_historic', 'document', 'document_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.document)', true, 77, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_target_historic', 'cadastre', 'cadastre_object_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object_target)', false, 78, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('cadastre.cadastre_object_node_target_historic', 'cadastre', 'cadastre_object_node_target_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.cadastre_object_node_target)', false, 79, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('administrative.ba_unit_historic', 'administrative', 'ba_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.ba_unit)', false, 80, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_uses_source_historic', 'application', 'application_uses_source_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_uses_source)', false, 81, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('application.application_spatial_unit_historic', 'application', 'application_spatial_unit_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.application_spatial_unit)', false, 82, false);
INSERT INTO system.consolidation_config (id, schema_name, table_name, condition_description, condition_sql, remove_before_insert, order_of_execution, log_in_extracted_rows) VALUES ('address.address_historic', 'address', 'address_historic', 'Every record that references a record in the main table in consolidation schema.', 'rowidentifier in (select rowidentifier from consolidation.address)', false, 83, false);
