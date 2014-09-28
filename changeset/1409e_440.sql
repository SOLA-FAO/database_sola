INSERT INTO system.version SELECT '1409e' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1409e');

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
  log_entry_moment = to_char(clock_timestamp(), 'yyyy-MM-dd HH24:MI:ss.ms | ');
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
