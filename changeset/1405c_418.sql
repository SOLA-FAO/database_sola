insert into system.setting (name, vl, active, description) values ('email-enable-email-service', '0', 't', 'Enables or disables email service. 1 - enable, 0 - disable');
insert into system.setting (name, vl, active, description) values ('email-admin-address', '', 't', 'Email address of server administrator. If empty, no notifications will be sent');
insert into system.setting (name, vl, active, description) values ('email-admin-name', '', 't', 'Name of server administrator');

insert into system.setting (name, active, vl, description) values ('email-body-format', 't', 'html', 'Message body format. text - for simple text format, html - for html format');

insert into system.setting (name, active, vl, description) values ('email-service-interval', 't', '10', 'Time interval in seconds for email service to check and process scheduled messages.');
insert into system.setting (name, active, vl, description) values ('email-send-interval1', 't', '1', 'Time interval in minutes for the first attempt to send email message.');
insert into system.setting (name, active, vl, description) values ('email-send-attempts1', 't', '2', 'Number of attempts to send email with first interval');
insert into system.setting (name, active, vl, description) values ('email-send-interval2', 't', '120', 'Time interval in minutes for the second attempt to send email message.');
insert into system.setting (name, active, vl, description) values ('email-send-attempts2', 't', '2', 'Number of attempts to send email with second interval');
insert into system.setting (name, active, vl, description) values ('email-send-interval3', 't', '1440', 'Time interval in minutes for the third attempt to send email message.');
insert into system.setting (name, active, vl, description) values ('email-send-attempts3', 't', '1', 'Number of attempts to send email with third interval');

insert into system.setting (name, active, vl, description) values ('email-msg-user-registration-subject', 't', 'SOLA OpenTenure - New user registration', 'Subject text for new user registration on OpenTenure Web-site. Sent to administrator.');
insert into system.setting (name, active, vl, description) values ('email-msg-user-registration-body', 't', 'New user with name "<b>#{userName}</b>" has been registered on SOLA OpenTenure Web-site.', 'Message text for new user registration on OpenTenure Web-site');

insert into system.setting (name, active, vl, description) values ('email-msg-reg-subject', 't', 'SOLA OpenTenure - Registration', 'Subject text for new user registration on OpenTenure Web-site. Sent to user.');
insert into system.setting (name, active, vl, description) values ('email-msg-reg-body', 't', 'Dear #{userFullName},<p></p>You have registered on SOLA OpenTenure Web-site. In order to start using it, you need to activate your account. You can do it by clicking <a href ="#{activationLink}">this link</a>, or open the following address in your browser <b>#{activationLink}</b> and provide your user name and activation code <p></p>Your user name is:<br /><b>#{userName}</b><br />Activation code:<br /> <b>#{activationCode}</b><p></p><p><br /></p>Regards,<br />SOLA OpenTenure Team', 'Message text for new user registration on OpenTenure Web-site. Sent to user.');

insert into system.setting (name, active, vl, description) values ('email-msg-failed-send-subject', 't', 'Delivery failure', 'Subject text for delivery failure of message');
insert into system.setting (name, active, vl, description) values ('email-msg-failed-send-body', 't', 'Message send to the user #{userName} has been failed to deliver after number of attempts with the following error: <br/>#{error}', 'Message text for delivery failure');

insert into system.setting (name, active, vl, description) values ('email-msg-pswd-restore-subject', 't', 'SOLA OpenTenure - password restore', 'Password restore subject');
insert into system.setting (name, active, vl, description) values ('email-msg-pswd-restore-body', 't', 'Dear #{userFullName},<p></p>You have requested to restore the password. If you didn''t ask for this action, just ignore this message. Otherwise, follow <a href="#{passwordRestoreLink}">this link</a> to reset your password.<p></p><p></p>Regards,<br />SOLA OpenTenure Team', 'Message text for password restore');

insert into system.setting (name, active, vl, description) values ('email-msg-claim-submit-subject', 't', 'SOLA OpenTenure - new claim submitted', 'New claim subject text');
insert into system.setting (name, active, vl, description) values ('email-msg-claim-submit-body', 't', 'Dear #{userFullName},<p></p>You have submitted new claim <b>##{claimNumber}</b>. You can follow its status by <a href="#{claimLink}">this address</a>.<p></p><p></p>Regards,<br />SOLA OpenTenure Team', 'New claim body text');

insert into system.setting (name, active, vl, description) values ('email-msg-claim-updated-subject', 't', 'SOLA OpenTenure - claim #%s update', 'Claim update subject text');
insert into system.setting (name, active, vl, description) values ('email-msg-claim-updated-body', 't', 'Dear #{userFullName},<p></p>Claim <b>##{claimNumber}</b> has been updated. Follow <a href="#{claimLink}">this link</a> to check claim status and updated information.<p></p><p></p>Regards,<br />SOLA OpenTenure Team', 'Claim update body text');

insert into system.setting (name, active, vl, description) values ('email-msg-claim-challenge-updated-subject', 't', 'SOLA OpenTenure - claim challenge #%s update', 'Claim challenge update subject text');
insert into system.setting (name, active, vl, description) values ('email-msg-claim-challenge-updated-body', 't', 'Dear #{userFullName},<p></p>Claim challenge <b>##{challengeNumber}</b> has been updated. Follow <a href="#{challengeLink}">this link</a> to check updated information.<p></p><p></p>Regards,<br />SOLA OpenTenure Team', 'Claim challenge update body text');

insert into system.setting (name, active, vl, description) values ('email-msg-claim-challenge-submitted-subject', 't', 'SOLA OpenTenure - new claim challenge to #%s', 'New claim challenge subject text');
insert into system.setting (name, active, vl, description) values ('email-msg-claim-challenge-submitted-body', 't', 'Dear #{userFullName},<p></p>New claim challenge <a href="#{challengeLink}"><b>##{challengeNumber}</b></a> has been submitted to challenge the claim <a href="#{claimLink}"><b>##{claimNumber}</b></a>.<p></p><p></p>Regards,<br />SOLA OpenTenure Team', 'New claim challenge body text');

insert into system.setting (name, active, vl, description) values ('account-activation-timeout', 't', '70', 'Account activation timeout in hours. After this time, activation should expire.');

ALTER TABLE system.appuser ADD COLUMN activation_expiration timestamp without time zone;
ALTER TABLE system.appuser_historic ADD COLUMN activation_expiration timestamp without time zone;
COMMENT ON COLUMN system.appuser.activation_expiration IS 'Account activation timeout. It can be used to delete account if it was not activated in time.';

CREATE TABLE system.email
(
  id character varying(40) NOT NULL, -- Unique identifier of the record.
  recipient character varying(255) NOT NULL, -- Email address of recipient.
  recipient_name character varying(255), -- Name of recipient.
  cc character varying(5000), -- List of names and email address to send a copy of the message
  bcc character varying(5000), -- List of names and email address to send a blind copy of the message
  subject character varying(250) NOT NULL, -- Subject of the message
  body character varying(8000) NOT NULL, -- Message body
  attachment bytea, -- Attachment file to send
  attachment_mime_type character varying(250), -- Attachment mime type
  attachment_name character varying(250), -- Attachment file name
  time_to_send timestamp without time zone NOT NULL DEFAULT now(), -- Date and time when to send the message.
  attempt integer NOT NULL DEFAULT 1, -- Number of attempt of sending message.
  error character varying(5000), -- Error message received when sending the message.
  CONSTRAINT email_pk_id PRIMARY KEY (id )
)
WITH (
  OIDS=FALSE
);
ALTER TABLE system.email
  OWNER TO postgres;
COMMENT ON TABLE system.email
  IS 'Table for email messages to be sent.';
COMMENT ON COLUMN system.email.id IS 'Unique identifier of the record.';
COMMENT ON COLUMN system.email.recipient IS 'Email address of recipient.';
COMMENT ON COLUMN system.email.recipient_name IS 'Name of recipient.';
COMMENT ON COLUMN system.email.cc IS 'List of names and email address to send a copy of the message';
COMMENT ON COLUMN system.email.bcc IS 'List of names and email address to send a blind copy of the message';
COMMENT ON COLUMN system.email.subject IS 'Subject of the message';
COMMENT ON COLUMN system.email.body IS 'Message body';
COMMENT ON COLUMN system.email.attachment IS 'Attachment file to send';
COMMENT ON COLUMN system.email.attachment_name IS 'Attachment file name';
COMMENT ON COLUMN system.email.attachment_mime_type IS 'attachment_mime_type';
COMMENT ON COLUMN system.email.time_to_send IS 'Date and time when to send the message.';
COMMENT ON COLUMN system.email.attempt IS 'Number of attempt of sending message.';
COMMENT ON COLUMN system.email.error IS 'Error message received when sending the message.';

ALTER TABLE opentenure.claim ADD COLUMN type_code character varying(20);
ALTER TABLE opentenure.claim DROP CONSTRAINT claim_claimant_id_fk8;
ALTER TABLE opentenure.claim DROP CONSTRAINT claim_status_code_fk18;
ALTER TABLE opentenure.claim DROP CONSTRAINT fk_challenged_claim;
ALTER TABLE opentenure.claim ADD CONSTRAINT claim_claimant_id_fk8 FOREIGN KEY (claimant_id)
      REFERENCES opentenure.claimant (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE opentenure.claim ADD CONSTRAINT claim_status_code_fk18 FOREIGN KEY (status_code)
      REFERENCES opentenure.claim_status (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE opentenure.claim ADD CONSTRAINT fk_challenged_claim FOREIGN KEY (challenged_claim_id)
      REFERENCES opentenure.claim (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT;
ALTER TABLE opentenure.claim ADD CONSTRAINT claim_fk_type_code FOREIGN KEY (type_code) REFERENCES administrative.rrr_type (code) ON UPDATE NO ACTION ON DELETE NO ACTION;

COMMENT ON COLUMN opentenure.claim.type_code IS 'Type of claim (e.g. ownership, usufruct, occupation).';

ALTER TABLE opentenure.claim_historic ADD COLUMN type_code character varying(20);

INSERT INTO system.version SELECT '1405c' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1405c');