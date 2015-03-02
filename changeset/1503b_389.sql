INSERT INTO system.version SELECT '1503b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1503b');


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

  -- If everything is true it means all applications that have not a service 'recordTransfer' will get one.
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
  update system.appuser set active = true where id != admin_user;
  execute system.process_log_update('done');
  execute system.process_progress_set(process_name, system.process_progress_get(process_name)+1);
  
  -- return system.get_text_from_schema(consolidation_schema);
  return true;
END;
$BODY$
  LANGUAGE plpgsql;
