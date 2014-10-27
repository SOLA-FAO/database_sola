INSERT INTO system.version SELECT '1410c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1410c');

CREATE OR REPLACE FUNCTION bulk_operation.move_other_objects(transaction_id_v character varying, change_user_v character varying)
  RETURNS void AS
$BODY$
declare
  other_object_type varchar;
  level_id_v varchar;
  geometry_type varchar;
  geometry_type_for_structure varchar;
  query_name_v varchar;
  query_sql_template varchar;
begin
  query_sql_template = 'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.spatial_unit 
where level_id = ''level_id_v'' and ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))';
  other_object_type = (select type_code 
    from bulk_operation.spatial_unit_temporary 
    where transaction_id = transaction_id_v limit 1);
  geometry_type = (select st_geometrytype(geom) 
    from bulk_operation.spatial_unit_temporary 
    where transaction_id = transaction_id_v limit 1);
  geometry_type = lower(substring(geometry_type from 4));
  if (select count(*) from cadastre.structure_type where code = geometry_type) = 0 then
    insert into cadastre.structure_type(code, display_value, status)
    values(geometry_type, geometry_type, 'c');
  end if;
  level_id_v = (select id from cadastre.level where name = other_object_type or id = lower(other_object_type));
  if level_id_v is null then
    level_id_v = lower(other_object_type);
    insert into cadastre.level(id, type_code, name, structure_code, editable) 
    values(level_id_v, 'geographicLocator', other_object_type, geometry_type, true);
    if (select count(*) from system.config_map_layer where name = level_id_v) = 0 then
      -- A map layer is added here. For the symbology an sld file already predefined in gis component must be used.
      -- The sld file must be named after the geometry type + the word generic. 
      query_name_v = 'SpatialResult.get' || level_id_v;
      if (select count(*) from system.query where name = query_name_v) = 0 then
        -- A query is added here
        insert into system.query(name, sql) values(query_name_v, replace(query_sql_template, 'level_id_v', level_id_v));
      end if;
      if geometry_type like '%point' then
        geometry_type_for_structure = replace(geometry_type, 'point', 'Point');
      elseif geometry_type like '%linestring' then
        geometry_type_for_structure = replace(geometry_type, 'linestring', 'LineString');
      elseif geometry_type like '%polygon' then
        geometry_type_for_structure = replace(geometry_type, 'polygon', 'Polygon');
      else
        geometry_type_for_structure = 'Geometry';
      end if;
      geometry_type_for_structure  = replace(geometry_type_for_structure, 'multi', 'Multi');
      
      insert into system.config_map_layer(name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name, added_from_bulk_operation) 
      values(level_id_v, other_object_type, 'pojo', true, true, 1, 'generic-' || geometry_type || '.xml', 'theGeom:' || geometry_type_for_structure || ',label:""', query_name_v, true);
    end if;
  end if;
  insert into cadastre.spatial_unit(id, label, level_id, geom, transaction_id, change_user)
  select id, label, level_id_v, geom, transaction_id, change_user_v
  from bulk_operation.spatial_unit_temporary where transaction_id = transaction_id_v;
  update transaction.transaction set status_code = 'approved', change_user = change_user_v where id = transaction_id_v;
  delete from bulk_operation.spatial_unit_temporary where transaction_id = transaction_id_v;
end;
$BODY$
  LANGUAGE plpgsql;
COMMENT ON FUNCTION bulk_operation.move_other_objects(character varying, character varying) IS 'Moves general spatial objects other than cadastre objects from the Bulk Operation schema to the Cadastre schema. If an appropriate level and/or structure type do not exist in the Cadastre schema, this function will add them.';
