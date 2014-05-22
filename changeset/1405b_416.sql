ALTER TABLE system.config_map_layer ADD COLUMN use_for_ot boolean NOT NULL DEFAULT false;
ALTER TABLE system.config_map_layer DROP CONSTRAINT config_map_layer_pojo_query_name_fk105;
ALTER TABLE system.config_map_layer DROP CONSTRAINT config_map_layer_pojo_query_name_for_select_fk106;
ALTER TABLE system.config_map_layer DROP CONSTRAINT config_map_layer_type_code_fk104;
ALTER TABLE system.config_map_layer ADD CONSTRAINT config_map_layer_pojo_query_name_fk105 FOREIGN KEY (pojo_query_name)
      REFERENCES system.query (name) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE system.config_map_layer ADD CONSTRAINT config_map_layer_pojo_query_name_for_select_fk106 FOREIGN KEY (pojo_query_name_for_select)
      REFERENCES system.query (name) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE system.config_map_layer ADD CONSTRAINT config_map_layer_type_code_fk104 FOREIGN KEY (type_code)
      REFERENCES system.config_map_layer_type (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
COMMENT ON TABLE system.config_map_layer
  IS 'Identifies the layers available for display in the SOLA Map Viewer.
Tags: FLOSS SOLA Extension, Reference Table, Map Configuration';
COMMENT ON COLUMN system.config_map_layer.use_for_ot IS 'Flag to indicate if the layer must be visible on open tenure map.';

insert into system.config_map_layer (name, title, type_code, active, visible_in_start, item_order, url, wms_layers, wms_version, wms_format, added_from_bulk_operation, use_in_public_display, use_for_ot) 
values ('claims-orthophoto', 'Claims', 'wms', 't', 'f', 12, 'http://demo.flossola.org/geoserver/sola/wms', 'sola:nz_orthophoto, sola:claim', '1.1.1', 'image/png', 'f', 'f', 't');

INSERT INTO system.version SELECT '1405b' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1405b');