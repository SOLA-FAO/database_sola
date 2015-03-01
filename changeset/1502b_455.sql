INSERT INTO system.panel_launcher_group(
            code, display_value, description, status)
	VALUES ('obscurationRequest','Obscuration Request','Panels used for obscuration services','c');
INSERT INTO system.config_panel_launcher(
            code, display_value, description, status, launch_group, panel_class, 
            message_code, card_name)
	VALUES ('obscurationRequest','Obscuration Request','','c','obscurationRequest','org.sola.clients.swing.desktop.party.ObscurationPanel','cliprgs009','obscurationRequest');


INSERT INTO application.request_type (code, request_category_code, display_value, description, status, nr_days_to_complete, base_fee, area_base_fee, value_base_fee, nr_properties_required, notation_template, rrr_type_code, type_action_code,display_group_name, service_panel_code) 
	VALUES ('obscurationRequest', 'registrationServices', 'Obscuration Request', '', 'c', 30, 0.00, 0.00, 0.00, 0, null, null, null,'Other Registration' ,'obscurationRequest');

INSERT INTO system.approle (code, display_value, status, description) VALUES ('obscurationRequest', 'Service - Obscuration request', 'c', 'Obscuration Service. Allows to record a restriction order and obscure data.');
INSERT INTO system.approle_appgroup(approle_code, appgroup_id) VALUES ('obscurationRequest', 'super-group-id');

INSERT INTO source.administrative_source_type (code, display_value, status, description, is_for_registration) VALUES ('restrictionOrder', 'Restriction Order', 'c', '', 'f');

INSERT INTO application.request_type_requires_source_type(source_type_code, request_type_code) values('restrictionOrder', 'obscurationRequest');


ALTER TABLE party.party
  ADD COLUMN obscure_service_id character varying(40);

ALTER TABLE party.party_historic
  ADD COLUMN obscure_service_id character varying(40);




