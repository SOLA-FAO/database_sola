alter table cadastre.level 
  add column editable boolean not null default false;
COMMENT ON COLUMN cadastre.level.editable IS 'It shows if the spatial units of this level are editable from the spatial unit editor.';

alter table cadastre.level_historic 
  add column editable boolean not null default false;
COMMENT ON COLUMN cadastre.level_historic.editable IS 'It shows if the spatial units of this level are editable from the spatial unit editor.';


CREATE TABLE cadastre.level_config_map_layer
(
  level_id character varying(40) NOT NULL, -- Identifier for the level.
  config_map_layer_name character varying(40) NOT NULL, -- The identifier for the map layer.
  CONSTRAINT config_map_layer_pkey PRIMARY KEY (level_id, config_map_layer_name),
  CONSTRAINT level_config_map_layer_level_id_fk FOREIGN KEY (level_id)
      REFERENCES cadastre.level (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT level_config_map_layer_name_fk FOREIGN KEY (config_map_layer_name)
      REFERENCES system.config_map_layer (name) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE cadastre.level_config_map_layer
  IS 'It provides for each level which layers in the map are used for visualisation';

insert into system.query(name, sql)
values('SpatialResult.getRoadCenterlines', 'select id, label, st_asewkb(st_transform(geom, #{srid})) as the_geom from cadastre.spatial_unit where level_id = ''road-centerline'' and ST_Intersects(st_transform(geom, #{srid}), ST_SetSRID(ST_3DMakeBox(ST_Point(#{minx}, #{miny}),ST_Point(#{maxx}, #{maxy})), #{srid}))');

insert into cadastre.level(id, name, structure_code, type_code, editable)
values('road-centerline', 'Road centerline', 'unStructuredLine', 'geographicLocator', true);

delete from system.config_map_layer where name = 'road-centerlines';
insert into system.config_map_layer(name, title, type_code, active, visible_in_start, item_order, style, pojo_structure, pojo_query_name)
values('road-centerlines', 'Road centerlines', 'pojo', true, true, 35, 'road_centerline.xml', 'theGeom:LineString,label:""', 'SpatialResult.getRoadCenterlines');

insert into cadastre.level_config_map_layer(level_id, config_map_layer_name) 
values('road-centerline', 'road-centerlines');

insert into cadastre.level_config_map_layer(level_id, config_map_layer_name) 
values('c03162e0-99dd-11e3-a27b-2bfeef31a969', 'place-names');
update cadastre.level set editable=true where id='c03162e0-99dd-11e3-a27b-2bfeef31a969';

INSERT INTO system.version SELECT '1404b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1404b');
