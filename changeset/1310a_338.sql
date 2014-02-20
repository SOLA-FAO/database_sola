-- #338 - New Service for Mapping existing Parcel (existing Title)
--  added to the reference data new service and its required document 
DELETE from application.request_type where code = 'mapExistingParcel';
INSERT INTO application.request_type(
            code, request_category_code, display_value, description, status, 
            nr_days_to_complete, base_fee, area_base_fee, value_base_fee, 
            nr_properties_required, notation_template)
    VALUES ('mapExistingParcel','registrationServices', 'Map Existing Parcel', '', 'c', 30, 
            0.00, 0.00, 0.00, 0, 
            'Allows to make changes to the cadastre');
DELETE FROM application.request_type_requires_source_type WHERE request_type_code = 'mapExistingParcel';
insert into application.request_type_requires_source_type(source_type_code, request_type_code) values('cadastralSurvey', 'mapExistingParcel');
DELETE FROM application.request_type_requires_source_type WHERE request_type_code = 'newDigitalTitle';
INSERT INTO application.request_type_requires_source_type (request_type_code, source_type_code) VALUES('newDigitalTitle', 'title');