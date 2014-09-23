INSERT INTO system.version SELECT '1409c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1409c');

-- Remove functions that cannot be replaced.

drop function if exists system.consolidation_consolidate(character varying);
drop function if exists system.consolidation_extract(character varying, boolean);
drop function if exists system.get_text_from_schema(character varying);
drop function if exists system.script_to_schema(text);

insert into system.approle(code, display_value, status, description)
values('ApplnTransfer', 'Appln Action - Transfer', 'c', 'The action that bring the application in the To be transferred state.');
insert into system.approle_appgroup(approle_code, appgroup_id) values('ApplnTransfer', 'super-group-id');

insert into application.application_status_type(code, display_value, status, description)
values('to-be-transferred', 'To be transferred', 'c', 'Application is marked for transfer.');

insert into application.application_status_type(code, display_value, status, description)
values('transferred', 'Transferred', 'c', 'Application is transferred.');

insert into application.application_action_type(code, display_value, status_to_set, status, description)
values('transfer', 'Transfer', 'to-be-transferred', 'c', 'Marks the application for transfer');

alter table system.consolidation_config add nr_rows_at_once integer not null default 10000;

comment on column system.consolidation_config.nr_rows_at_once is 'The number of rows to be extracted at once.';

alter table system.consolidation_config add log_in_extracted_rows boolean not null default true;

comment on column system.consolidation_config.log_in_extracted_rows is 'True - If the records has to be logged in the extracted rows table.';

create table system.extracted_rows(
  table_name varchar(200) not null,
  rowidentifier varchar(40) not null,
  primary key(table_name, rowidentifier)
);

comment on table system.extracted_rows is 'It logs every record that has been extracted from this database for consolidation purposes.';
comment on column system.extracted_rows.table_name is 'The table where the record has been found. It has to be absolute table name including the schema name.';
comment on column system.extracted_rows.rowidentifier is 'The rowidentifier of the record. Carefull: It is the rowidentifier and not the id.';

update system.br set technical_description='The application should not have the status transferred.'
where id='application-not-transferred';
delete from system.br_definition where br_id='application-not-transferred';
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('application-not-transferred', '2014-09-12', 'infinity', 
'select status_code != ''transferred'' as vl from application.application where id = #{id}');

update system.br set technical_description='It checks if the application has no spatial_unit that is already targeted by an application that has the status  transferred.'
where id='application-spatial-unit-not-transferred';
delete from system.br_definition where br_id='application-spatial-unit-not-transferred';
INSERT INTO system.br_definition (br_id, active_from, active_until, body) VALUES ('application-spatial-unit-not-transferred', '2014-09-12', 'infinity', 
'select count(1) = 0 as vl
from application.application_spatial_unit  
where application_id = #{id} and spatial_unit_id in (select spatial_unit_id from application.application_spatial_unit where application_id in (select id from application.application where status_code=''transferred''))');

delete from system.br_validation where id='consolidation-not-again';
delete from system.br where id='consolidation-not-again';
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('consolidation-not-again', 'Records are unique', 'sql', 'Records being consolidated must not be present in the destination. 
result', '', '');

INSERT INTO system.br_definition (br_id, active_from, active_until, body) 
VALUES ('consolidation-not-again', '2014-09-12', 'infinity', 
'select not records_found as vl, result from system.get_already_consolidated_records() as vl');

insert into system.br_validation(id, br_id, target_code, severity_code, order_of_execution)
values('consolidation-not-again', 'consolidation-not-again', 'consolidation', 'critical', 1);


CREATE OR REPLACE FUNCTION system.get_already_consolidated_records(out result varchar, out records_found boolean)
  RETURNS record AS
$BODY$
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
$BODY$
  LANGUAGE plpgsql;

comment on function system.get_already_consolidated_records() is 'It retrieves the records that are already consolidated and being asked again for consolidation.';

delete from system.br where id='generate-process-progress-consolidate-max';
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-process-progress-consolidate-max', 'generate-process-progress-consolidate-max', 'sql', '...::::::::...', '-- Calculate the max the process progress can be. 
  Increments:
  - 10 the upload
  - 2 script to schema only
  - 2 script to table data only for each table
  - 2 for each br validation
  - 1 for writting the validation result to log
  In consolidaton method
  - 4 once
  - 2 for each table
 ', '');

INSERT INTO system.br_definition (br_id, active_from, active_until, body) 
VALUES ('generate-process-progress-consolidate-max', '2014-09-12', 'infinity', 
'select 10 
  + 2 + (select count(*)*2 from system.consolidation_config) 
  + 1 + (select count(*)*2 from system.br_validation where target_code=''consolidate'')
  + 4 + (select count(*)*2 from system.consolidation_config) as vl');


CREATE OR REPLACE FUNCTION system.consolidation_consolidate(admin_user varchar, process_name varchar)
  RETURNS void AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  cols varchar;
  exception_text_msg varchar;
  
BEGIN
  BEGIN -- TRANSACTION TO CATCH EXCEPTION
    execute system.process_log_update(process_name, 'Making the system not accessible for the users...');
    -- Make sola not accessible from all other users except the user running the consolidation.
    update system.appuser set active = false where id != admin_user;
    execute system.process_log_update(process_name, 'done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    -- Disable triggers.
    execute system.process_log_update(process_name, 'disabling all triggers...');
    perform fn_triggerall(false);
    execute system.process_log_update(process_name, 'done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    execute system.process_log_update(process_name, 'Move records from temporary consolidation schema to main tables.');
    -- For each table that is extracted and that has rows, insert the records into the main tables.
    for table_rec in select * from consolidation.config order by order_of_execution loop

      execute system.process_log_update(process_name, '  - source table: "' || table_rec.source_table_name || '" destination table: "' || table_rec.target_table_name || '"... ');

      if table_rec.remove_before_insert then
        execute system.process_log_update(process_name, '      deleting matching records in target table ...');
        execute 'delete from ' || table_rec.target_table_name ||
        ' where rowidentifier in (select rowidentifier from ' || table_rec.source_table_name || ')';
        execute system.process_log_update(process_name, '      done');
      end if;
      cols = (select string_agg(column_name, ',')
        from information_schema.columns
        where table_schema || '.' || table_name = table_rec.target_table_name);

      execute system.process_log_update(process_name, '      inserting records to target table ...');
      execute 'insert into ' || table_rec.target_table_name || '(' || cols || ') select ' || cols || ' from ' || table_rec.source_table_name;
      execute system.process_log_update(process_name, '      done');
      execute system.process_log_update(process_name, '  done');
      execute system.process_progress_set(process_name, system.process_progress_get(process_name)+2);
    
    end loop;
  
    -- Enable triggers.
    execute system.process_log_update(process_name, 'enabling all triggers...');
    perform fn_triggerall(true);
    execute system.process_log_update(process_name, 'done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

    -- Make sola accessible for all users.
    execute system.process_log_update(process_name, 'Making the system accessible for the users...');
    update system.appuser set active = true where id != admin_user;
    execute system.process_log_update(process_name, 'done');
    execute system.process_log_update(process_name, 'Finished with success!');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS exception_text_msg = MESSAGE_TEXT;  
    execute system.process_log_update(process_name, 'Consolidation failed. Reason: ' || exception_text_msg);
    RAISE;
  END;
END;
$BODY$
  LANGUAGE plpgsql;

COMMENT ON FUNCTION system.consolidation_consolidate(varchar, varchar) IS 'Moves records from the temporary consolidation schema into the main SOLA tables. Used by the bulk consolidation process.';

delete from system.br where id='generate-process-progress-extract-max';
INSERT INTO system.br (id, display_name, technical_type_code, feedback, description, technical_description) VALUES ('generate-process-progress-extract-max', 'generate-process-progress-extract-max', 'sql', '...::::::::...', '-- Calculate the max the process progress can be.
Increments of the progress in the extraction method
 - 7 times once
 - 3 times for each table
Increments of the progress in the method to convert schema to text
 - 2 for the schema generation only and save as file
 - 5 increments for each table to convert to text and save as file
 - 10 increments for the compression of files', '');

INSERT INTO system.br_definition (br_id, active_from, active_until, body) 
VALUES ('generate-process-progress-extract-max', '2014-09-12', 'infinity', 
'select 7 + (count(*)*(3+5)) + 2 + 10 as vl from system.consolidation_config');

CREATE OR REPLACE FUNCTION system.consolidation_extract(admin_user varchar, everything boolean, process_name varchar)
  RETURNS bool AS
$BODY$
DECLARE
  table_rec record;
  consolidation_schema varchar default 'consolidation';
  sql_to_run varchar;
  order_of_exec int;
  --process_progress int;
BEGIN
  
  -- Prepare the process log
  execute system.process_log_update(process_name, 'Extraction process started.');
  if everything then
    execute system.process_log_update(process_name, 'Everything has to be extracted.');
  end if;
  execute system.process_log_update(process_name, '');

  -- Make sola not accessible from all other users except the user running the consolidation.
  execute system.process_log_update(process_name, 'Making the system not accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update(process_name, 'done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  -- If everything is true it means all applications that have not a service 'recordTransfer' will get one.
  if everything then
    execute system.process_log_update(process_name, 'Marking the applications that are not yet marked for transfer...');
    update application.application set action_code = 'transfer', status_code='to-be-transferred' 
    where status_code not in ('to-be-transferred', 'transferred');
    execute system.process_log_update(process_name, 'done');    
  end if;
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  
  -- Drop schema consolidation if exists.
  execute system.process_log_update(process_name, 'Dropping schema consolidation...');
  execute 'DROP SCHEMA IF EXISTS ' || consolidation_schema || ' CASCADE;';    
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
      
  -- Make the schema.
  execute system.process_log_update(process_name, 'Creating schema consolidation...');
  execute 'CREATE SCHEMA ' || consolidation_schema || ';';
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  --Make table to define configuration for the the consolidation to the target database.
  execute system.process_log_update(process_name, 'Creating consolidation.config table...');
  execute 'create table ' || consolidation_schema || '.config (
    source_table_name varchar(100),
    target_table_name varchar(100),
    remove_before_insert boolean,
    order_of_execution int,
    status varchar(500)
  )';
  execute system.process_log_update(process_name, 'done');    
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);

  execute system.process_log_update(process_name, 'Move records from main tables to consolidation schema.');
  order_of_exec = 1;
  for table_rec in select * from system.consolidation_config order by order_of_execution loop

    execute system.process_log_update(process_name, '  - Table: ' || table_rec.schema_name || '.' || table_rec.table_name);
    -- Make the script to move the data to the consolidation schema.
    sql_to_run = 'create table ' || consolidation_schema || '.' || table_rec.table_name 
      || ' as select * from ' ||  table_rec.schema_name || '.' || table_rec.table_name
      || ' where rowidentifier not in (select rowidentifier from system.extracted_rows where table_name=$1)';

    -- Add the condition to the end of the select statement if it is present
    if coalesce(table_rec.condition_sql, '') != '' then      
      sql_to_run = sql_to_run || ' and ' || table_rec.condition_sql;
    end if;

    -- Run the script
    execute system.process_log_update(process_name, '      - move records...');
    execute sql_to_run using table_rec.schema_name || '.' || table_rec.table_name;
    execute system.process_log_update(process_name, '      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    
    -- Log extracted records
    if table_rec.log_in_extracted_rows then
      execute system.process_log_update(process_name, '      - log extracted records...');
      execute 'insert into system.extracted_rows(table_name, rowidentifier)
        select $1, rowidentifier from ' || consolidation_schema || '.' || table_rec.table_name
        using table_rec.schema_name || '.' || table_rec.table_name;
      execute system.process_log_update(process_name, '      done');
    end if;  
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    

    -- Make a record in the config table
    sql_to_run = 'insert into ' || consolidation_schema 
      || '.config(source_table_name, target_table_name, remove_before_insert, order_of_execution) values($1,$2,$3, $4)'; 
    execute system.process_log_update(process_name, '      - update config table...');
    execute sql_to_run 
      using  consolidation_schema || '.' || table_rec.table_name, 
             table_rec.schema_name || '.' || table_rec.table_name, 
             table_rec.remove_before_insert,
             order_of_exec;
    execute system.process_log_update(process_name, '      done');
    execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
    order_of_exec = order_of_exec + 1;
  end loop;
  execute system.process_log_update(process_name, 'Done');

  -- Set the status of the applications moved to consolidation schema to 'transferred' and unassign them.
  execute system.process_log_update(process_name, 'Unassign moved applications and set their status to ''transferred''...');
  update application.application set status_code='transferred', action_code = 'unAssign', assignee_id = null, assigned_datetime = null 
  where rowidentifier in (select rowidentifier from consolidation.application);
  execute system.process_log_update(process_name, 'done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- Make sola accessible from all users.
  execute system.process_log_update(process_name, 'Making the system accessible for the users...');
  update system.appuser set active = false where id != admin_user;
  execute system.process_log_update(process_name, 'done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- return system.get_text_from_schema(consolidation_schema);
  return true;
END;
$BODY$
  LANGUAGE plpgsql;

comment on function system.consolidation_extract(varchar, boolean, varchar) is 'Extracts the records from the database that are marked to be extracted.';

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

CREATE OR REPLACE FUNCTION system.process_log_start(process_id varchar)
  RETURNS void AS
$BODY$
declare
  path_to_logs varchar;
  dynamic_sql varchar;
BEGIN
  path_to_logs = (SELECT setting FROM pg_settings where name = 'data_directory') || '/' || (SELECT setting FROM pg_settings where name = 'log_directory') || '/';
  create temporary table temp_process_log(
    log text
  );
  insert into temp_process_log(log) values('');
  dynamic_sql = 'COPY temp_process_log TO ' || quote_literal(path_to_logs || process_id || '_log.log');
  execute dynamic_sql;
  drop table if exists temp_process_log;
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_log_start(varchar) is 'Starts a process log.';


CREATE OR REPLACE FUNCTION system.process_log_update(process_id varchar, log_input varchar)
  RETURNS void AS
$BODY$
declare
  path_to_logs varchar;
  dynamic_sql varchar;
  new_line varchar default '
';
  log_entry_moment varchar;
  
BEGIN
  path_to_logs = (SELECT setting FROM pg_settings where name = 'data_directory') || '/' || (SELECT setting FROM pg_settings where name = 'log_directory') || '/';
  create temporary table temp_process_log(
    log text
  );
  log_entry_moment = to_char(clock_timestamp(), 'yyyy-MM-dd HH24:MI:ss.mi | ');
  dynamic_sql = 'COPY temp_process_log FROM ' || quote_literal(path_to_logs || process_id || '_log.log');
  execute dynamic_sql;
  update temp_process_log set log = log ||  new_line || log_entry_moment || log_input;
  dynamic_sql = 'COPY temp_process_log TO ' || quote_literal(path_to_logs || process_id || '_log.log');
  execute dynamic_sql;
  drop table if exists temp_process_log;
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_log_update(varchar, varchar) is 'Updates the process log.';

CREATE OR REPLACE FUNCTION system.process_log_get(process_id_v varchar)
  RETURNS text AS
$BODY$
DECLARE
  path_to_logs varchar;
  dynamic_sql varchar;
  log_body varchar;
BEGIN
  path_to_logs = (SELECT setting FROM pg_settings where name = 'data_directory') || '/' || (SELECT setting FROM pg_settings where name = 'log_directory') || '/';

  create temporary table temp_process_log(
    log text
  );
  
  dynamic_sql = 'COPY temp_process_log FROM ' || quote_literal(path_to_logs || process_id_v || '_log.log');
  execute dynamic_sql;
  log_body = (select log from temp_process_log);
  drop table if exists temp_process_log;
  return coalesce(log_body, '');  
END;
$BODY$
  LANGUAGE plpgsql;

comment on FUNCTION system.process_log_get(varchar) is 'Gets process log.';

CREATE OR REPLACE FUNCTION system.run_script(script_body text)
  RETURNS void AS
$BODY$
BEGIN
  execute script_body;
END;
$BODY$
  LANGUAGE plpgsql;

comment on function system.run_script(text) is 'It runs any script passed as parameter.';

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
        || case when udt_name = 'numeric' then '(' || numeric_precision || ',' || numeric_scale  || ')' else '' end as col_definition
      from information_schema.columns
      where table_schema = schema_name and table_name = table_rec.table_name
      order by ordinal_position) as cols);
    total_script = total_script || sql_part || new_line_values;
  end loop;

  return total_script;
END;
$BODY$
  LANGUAGE plpgsql;

comment on function system.get_text_from_schema_only(character varying) is 'Gets the script that can regenerate the schema structure.';

CREATE OR REPLACE FUNCTION system.get_text_from_schema_table(schema_name varchar, table_name_v varchar, rows_at_once bigint, start_row_nr bigint)
  RETURNS text AS
$BODY$
DECLARE
  sql_to_run varchar;
  sql_part varchar;
  new_line_values varchar default '
';
BEGIN

    -- Get the select columns from the source.
    sql_to_run = (
      select string_agg(col_definition, ' || '','' || ')
      from (select 
        case 
          when udt_name in ('bpchar', 'varchar') then 'quote_nullable(' || column_name || ')'
          when udt_name in ('date', 'bool', 'timestamp', 'geometry', 'bytea') then 'quote_nullable(' || column_name || '::text)'
          else column_name 
        end as col_definition
     from information_schema.columns
     where table_schema = schema_name and table_name = table_name_v
     order by ordinal_position) as cols);

  -- Add the function to concatenate all rows with the delimiter
  sql_to_run = 'string_agg(''insert into ' || schema_name || '.' || table_name_v 
      ||  ' values('' || ' || sql_to_run || ' || '');'', ''' || new_line_values || ''')';

  sql_to_run = 'select ' || sql_to_run || ' from (select * from ' ||  schema_name || '.' || table_name_v || ' limit ' || rows_at_once::varchar || ' offset ' || (start_row_nr - 1)::varchar || ') tmp';

  -- Get the rows 
  execute sql_to_run into sql_part;
  if sql_part is null then
    sql_part = '';
  end if;

  return sql_part;
END;
$BODY$
  LANGUAGE plpgsql;

comment on function system.get_text_from_schema_table(varchar, varchar, bigint, bigint) is 'Gets the script with insert statements from the rows of the given table and start and amount of rows.';

