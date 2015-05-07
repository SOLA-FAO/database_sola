INSERT INTO system.version SELECT '1505c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1505c');

CREATE OR REPLACE FUNCTION public.get_translation(mixed_value character varying, language_code character varying)
  RETURNS character varying AS
$BODY$
DECLARE
  delimiter_word varchar;
  language_index integer;
  result varchar;
BEGIN
  if mixed_value is null then
    return mixed_value;
  end if;
  delimiter_word = '::::';
  language_index = (select lng.row_number from (select row_number() over(order by item_order asc) as row_number, code from system.language) lng where lower(lng.code)=lower(language_code));
  result = split_part(mixed_value, delimiter_word, language_index);
  if result is null or result = '' then
    language_index = (select lng.row_number from (select row_number() over(order by item_order asc) as row_number, code, is_default from system.language) lng where lng.is_default limit 1);
    result = split_part(mixed_value, delimiter_word, language_index);
    if result is null or result = '' then
      result = mixed_value;
    end if;
  end if;
  return result;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.get_translation(character varying, character varying)
  OWNER TO postgres;
COMMENT ON FUNCTION public.get_translation(character varying, character varying) IS 'This function is used to translate the values that are supposed to be multilingual like the reference data values (display_value)';
