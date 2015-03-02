insert into system.br(id, technical_type_code, feedback, technical_description) 
values('cancel-obscuration-request', 'sql', 'cancel-obscuration-request',
 '#{id}(service_id) is requested');



insert into system.br_definition(br_id, active_from, active_until, body) 
values('cancel-obscuration-request', now(), 'infinity', 
 'UPDATE party.party
 set classification_code = null,
     redact_code = null
WHERE obscure_service_id  = #{id}
;
select 0=0 as vl
');

INSERT INTO system.br_validation(br_id, target_code, target_service_moment, severity_code, order_of_execution)
VALUES ('cancel-obscuration-request', 'service', 'cancel', 'warning', 310);


insert into system.br(id, technical_type_code, feedback, technical_description) 
values('application-cancel-obscuration-request', 'sql', 'application-cancel-obscuration-request',
 '#{id}(service_id) is requested');


insert into system.br_definition(br_id, active_from, active_until, body) 
values('application-cancel-obscuration-request', now(), 'infinity', 
'UPDATE party.party
 set classification_code = null,
     redact_code = null
WHERE obscure_service_id in
(
SELECT        s.id
 FROM 
	      application.application aa, 
	      application.service s
WHERE 	      s.application_id::text = aa.id::text 
              and s.request_type_code::text = ''obscurationRequest''::text 
              and aa.id = #{id})
;

select 0=0 as vl
');
INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-cancel-obscuration-request', 'application', 'cancel', 'warning', 320);
INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-cancel-obscuration-request', 'application', 'withdraw', 'warning', 330);
INSERT INTO system.br_validation(br_id, target_code, target_application_moment, severity_code, order_of_execution)
VALUES ('application-cancel-obscuration-request', 'application', 'requisition', 'warning', 340);
