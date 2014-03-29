--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = system, pg_catalog;

--
-- Data for Name: appgroup; Type: TABLE DATA; Schema: system; Owner: postgres
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE appgroup DISABLE TRIGGER ALL;

INSERT INTO appgroup (id, name, description) VALUES ('super-group-id', 'Super group', 'This is a group of users that has right in anything. It is used in developement. In production must be removed.');


ALTER TABLE appgroup ENABLE TRIGGER ALL;

--
-- Data for Name: approle_appgroup; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE approle_appgroup DISABLE TRIGGER ALL;

INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnEdit', 'super-group-id', 'be35b284-99dd-11e3-8e17-1b1ace45a197', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('SourceSave', 'super-group-id', 'be37ae5e-99dd-11e3-ab3e-0fdfb55fc8f9', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('RHSave', 'super-group-id', 'be37fc7e-99dd-11e3-9f1f-3b8feb1de6e3', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('BaunitSave', 'super-group-id', 'be384a9e-99dd-11e3-ab5c-5bc965cc7e7a', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('newDigitalTitle', 'super-group-id', 'be3871ae-99dd-11e3-81f3-03c2ac371b43', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnView', 'super-group-id', 'be38bfce-99dd-11e3-83a5-cf3409079481', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnUnassignOthers', 'super-group-id', 'be38e6de-99dd-11e3-95bd-9770ac5860df', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnDispatch', 'super-group-id', 'be390dee-99dd-11e3-8363-2be6343e5ee2', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('SourceSearch', 'super-group-id', 'be3934fe-99dd-11e3-81e6-ff925fc58f63', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ParcelSave', 'super-group-id', 'be395c0e-99dd-11e3-95ce-0f471bdd1a3c', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('PartySave', 'super-group-id', 'be398328-99dd-11e3-ba89-739b74f32793', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('cadastrePrint', 'super-group-id', 'be39aa38-99dd-11e3-9048-371578945fa5', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('newOwnership', 'super-group-id', 'be39d148-99dd-11e3-97f9-d7ceb07710ef', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('documentCopy', 'super-group-id', 'be39d148-99dd-11e3-8579-e3b27f46e726', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('varyLease', 'super-group-id', 'be39f858-99dd-11e3-a111-ef4dca888f7e', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('RightsExport', 'super-group-id', 'be3a1f68-99dd-11e3-96c8-6bb4cf2d8e4c', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnUnassignSelf', 'super-group-id', 'be3a4678-99dd-11e3-abb5-d7c1555810bb', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('SourcePrint', 'super-group-id', 'be3a6d88-99dd-11e3-a714-9348875b49ba', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ExportMap', 'super-group-id', 'be3a9498-99dd-11e3-be27-277f11e0107e', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('BaunitSearch', 'super-group-id', 'be3abba8-99dd-11e3-9497-3b28e1959885', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('newFreehold', 'super-group-id', 'be3ae2b8-99dd-11e3-97e6-8f45a4d555f9', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageBR', 'super-group-id', 'be3b09c8-99dd-11e3-beaf-0f51942e145e', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ViewMap', 'super-group-id', 'be3b30d8-99dd-11e3-b151-43f166b2f9ca', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('lodgeObjection', 'super-group-id', 'be3b30d8-99dd-11e3-9a92-934c3732f30b', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('servitude', 'super-group-id', 'be3b57e8-99dd-11e3-8561-43f3abce7cf9', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('PartySearch', 'super-group-id', 'be3b7ef8-99dd-11e3-ad3d-efd661357772', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('historicOrder', 'super-group-id', 'be3ba608-99dd-11e3-9afc-5329cffa47ae', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('systematicRegn', 'super-group-id', 'be3bcd18-99dd-11e3-9b02-bf0ac4a794c8', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('removeRestriction', 'super-group-id', 'be3bf428-99dd-11e3-819e-37f517b49261', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnResubmit', 'super-group-id', 'be3c1b38-99dd-11e3-805e-0b401e2c096e', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnCreate', 'super-group-id', 'be3c1b38-99dd-11e3-a16d-ab5abc6b4a8d', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('mortgage', 'super-group-id', 'be3c4252-99dd-11e3-a5ff-3be2b662f009', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('registerLease', 'super-group-id', 'be3c6962-99dd-11e3-962f-8b5c1490d936', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('caveat', 'super-group-id', 'be3c9072-99dd-11e3-88f9-f7819f3e21c9', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('removeCaveat', 'super-group-id', 'be3cb782-99dd-11e3-acea-eb6c66630d07', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('surveyPlanCopy', 'super-group-id', 'be3cde92-99dd-11e3-ac4a-4327f6ee3548', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('varyMortgage', 'super-group-id', 'be3d05a2-99dd-11e3-8f6c-abe0810450dc', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('varyCaveat', 'super-group-id', 'be3d2cb2-99dd-11e3-b77f-1366b7b48653', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('CompleteService', 'super-group-id', 'be3d53c2-99dd-11e3-ada1-effcd3498be7', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('CancelService', 'super-group-id', 'be3d53c2-99dd-11e3-a168-3fa78ed19d05', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnValidate', 'super-group-id', 'be3d7ad2-99dd-11e3-8338-2ff182201c03', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('redefineCadastre', 'super-group-id', 'be3da1e2-99dd-11e3-9160-d786dc2dff87', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('serviceEnquiry', 'super-group-id', 'be3dc8f2-99dd-11e3-8615-7f3225f9eb04', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('RevertService', 'super-group-id', 'be3df002-99dd-11e3-86a8-230b6eaa7982', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('NoPasswordExpiry', 'super-group-id', 'be3e1712-99dd-11e3-9b9a-cbc46ce463f0', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnAssignOthers', 'super-group-id', 'be3e3e22-99dd-11e3-8989-b767ea63704b', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnWithdraw', 'super-group-id', 'be3e6532-99dd-11e3-b643-c361a16efeb4', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('titleSearch', 'super-group-id', 'be3e8c42-99dd-11e3-bba8-8f1f78a9e134', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnReject', 'super-group-id', 'be3eb352-99dd-11e3-926a-6f8ea6c64eef', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('DashbrdViewUnassign', 'super-group-id', 'be3eda6c-99dd-11e3-95ec-efecd21e6657', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('PrintMap', 'super-group-id', 'be3f017c-99dd-11e3-97c5-2343e89a91c3', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('BaunitCertificate', 'super-group-id', 'be3f017c-99dd-11e3-ae1e-6ff2de66ec9d', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ReportGenerate', 'super-group-id', 'be3f288c-99dd-11e3-afbf-bb2050e5ef22', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('regnOnTitle', 'super-group-id', 'be3f4f9c-99dd-11e3-903d-0bc1819ef2ed', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('varyRight', 'super-group-id', 'be3f76ac-99dd-11e3-96e1-9772426317d5', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('cnclStandardDocument', 'super-group-id', 'be3f9dbc-99dd-11e3-89bc-bb43e7d2b169', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageSettings', 'super-group-id', 'be3fc4cc-99dd-11e3-86a1-27716dc68756', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageSecurity', 'super-group-id', 'be3febdc-99dd-11e3-8812-fb80415cc5a5', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnAssignSelf', 'super-group-id', 'be4012ec-99dd-11e3-9f72-a32cce304e5b', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnStatus', 'super-group-id', 'be4039fc-99dd-11e3-92ff-17ecc5e3855e', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnRequisition', 'super-group-id', 'be40610c-99dd-11e3-8e4e-b3c0181d3a97', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('BulkApplication', 'super-group-id', 'be40881c-99dd-11e3-a60a-7b88b2957043', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('TransactionCommit', 'super-group-id', 'be40af2c-99dd-11e3-9f22-8b245d4b3256', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('cnclPowerOfAttorney', 'super-group-id', 'be40af2c-99dd-11e3-8c37-4f56ce8d45a1', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('cadastreChange', 'super-group-id', 'be40d63c-99dd-11e3-8e45-23e1aa859527', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('newApartment', 'super-group-id', 'be40fd4c-99dd-11e3-ae3c-c3b670bfbb5a', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('regnStandardDocument', 'super-group-id', 'be41245c-99dd-11e3-951c-b709155504de', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnArchive', 'super-group-id', 'be414b6c-99dd-11e3-a7fb-c75a5ebcd52e', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('removeRight', 'super-group-id', 'be41727c-99dd-11e3-9e32-7f2f12b3024f', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ChangePassword', 'super-group-id', 'be419996-99dd-11e3-8b35-77b8c207d13b', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ManageRefdata', 'super-group-id', 'be419996-99dd-11e3-8513-a728bd470770', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('StartService', 'super-group-id', 'be41c0a6-99dd-11e3-91e8-8b58f4dc2c3b', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('mapExistingParcel', 'super-group-id', 'be41e7b6-99dd-11e3-9434-17054171bef3', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('DashbrdViewAssign', 'super-group-id', 'be420ec6-99dd-11e3-b09c-5fdcbfb92dfd', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('cancelProperty', 'super-group-id', 'be4235d6-99dd-11e3-ae6d-6f328598a436', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('buildingRestriction', 'super-group-id', 'be425ce6-99dd-11e3-b3af-bf0ad2e1eafe', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('limtedRoadAccess', 'super-group-id', 'be4283f6-99dd-11e3-9a44-931a6bb6ee32', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('regnPowerOfAttorney', 'super-group-id', 'be42ab06-99dd-11e3-b30b-1f8b47e0d5ff', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('ApplnApprove', 'super-group-id', 'be42d216-99dd-11e3-919f-57cc413df0e7', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('consolidationExt', 'super-group-id', 'be42f926-99dd-11e3-9c66-1bba97c850af', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');
INSERT INTO approle_appgroup (approle_code, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('consolidationCons', 'super-group-id', 'be432036-99dd-11e3-a806-e3af0fb1848a', 1, 'i', 'db:postgres', '2014-02-20 16:19:00.912');


ALTER TABLE approle_appgroup ENABLE TRIGGER ALL;

--
-- Data for Name: appuser; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE appuser DISABLE TRIGGER ALL;

INSERT INTO appuser (id, username, first_name, last_name, passwd, active, email, description, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('test-id', 'test', 'Test', 'The BOSS', '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08', true, 'test@simple.com', NULL, 'be17a2c6-99dd-11e3-ba2b-af4cac70daca', 1, 'i', 'test', '2014-02-20 16:19:00.722');

ALTER TABLE appuser ENABLE TRIGGER ALL;

--
-- Data for Name: appuser_appgroup; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE appuser_appgroup DISABLE TRIGGER ALL;

INSERT INTO appuser_appgroup (appuser_id, appgroup_id, rowidentifier, rowversion, change_action, change_user, change_time) VALUES ('test-id', 'super-group-id', 'be56cf8c-99dd-11e3-ac27-0343410f6672', 1, 'i', 'db:postgres', '2014-02-20 16:19:01.139');


ALTER TABLE appuser_appgroup ENABLE TRIGGER ALL;

--
-- Data for Name: appuser_setting; Type: TABLE DATA; Schema: system; Owner: postgres
--

ALTER TABLE appuser_setting DISABLE TRIGGER ALL;



ALTER TABLE appuser_setting ENABLE TRIGGER ALL;

--
-- PostgreSQL database dump complete
--

