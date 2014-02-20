-- #383 - Change label for public-display-parcels-next layer
UPDATE "system".config_map_layer
   SET title='Other Systematic Registration Parcels'
 WHERE "name"= 'public-display-parcels-next';
 
---#383 Public Display and Related Issues (issues on certificates) 
---------- VIEW application.systematic_registration_certificates -----------
CREATE OR REPLACE VIEW application.systematic_registration_certificates AS 
 SELECT aa.nr, co.name_firstpart, co.name_lastpart, su.ba_unit_id
   FROM application.application_status_type ast, 
   cadastre.cadastre_object co, administrative.ba_unit bu, cadastre.spatial_value_area sa, administrative.ba_unit_contains_spatial_unit su, 
   application.application aa, application.service s,
   transaction.transaction t
  WHERE sa.spatial_unit_id::text = co.id::text AND sa.type_code::text = 'officialArea'::text 
  AND su.spatial_unit_id::text = sa.spatial_unit_id::text 
  AND su.ba_unit_id = bu.id
  AND bu.transaction_id = t.id
  AND t.from_service_id = s.id
  AND s.application_id::text = aa.id::text 
  AND s.request_type_code::text = 'systematicRegn'::text 
  AND aa.status_code::text = ast.code::text AND aa.status_code::text = 'approved'::text 
  ;


ALTER TABLE application.systematic_registration_certificates OWNER TO postgres;