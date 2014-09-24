INSERT INTO system.version SELECT '1409a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1409a');

DROP TABLE IF EXISTS opentenure.field_constraint;
DROP TABLE IF EXISTS opentenure.field_constraint_OPTION;
DROP TABLE IF EXISTS opentenure.field_constraint_type;
DROP TABLE IF EXISTS opentenure.field_payload;
DROP TABLE IF EXISTS opentenure.field_template;
DROP TABLE IF EXISTS opentenure.field_type;
DROP TABLE IF EXISTS opentenure.field_value_type;
DROP TABLE IF EXISTS opentenure.form_payload;
DROP TABLE IF EXISTS opentenure.form_template;
DROP TABLE IF EXISTS opentenure.section_element_payload;
DROP TABLE IF EXISTS opentenure.section_payload;
DROP TABLE IF EXISTS opentenure.section_template;

CREATE TABLE opentenure.field_constraint_type
(
code VARCHAR(255) NOT NULL,
display_value character varying(500) NOT NULL, 
status character(1) NOT NULL DEFAULT 'c'::bpchar,
description character varying(1000), 
CONSTRAINT field_constraint_type_pkey PRIMARY KEY (code),
CONSTRAINT field_constraint_type_display_value_unique UNIQUE (display_value)
);
COMMENT ON TABLE opentenure.field_constraint_type IS 'Reference table for the field constraint types, used in dynamic forms.';
COMMENT ON COLUMN opentenure.field_constraint_type.code IS 'The code for the constraint type.';
COMMENT ON COLUMN opentenure.field_constraint_type.display_value IS 'Displayed value of the constraint type.';
COMMENT ON COLUMN opentenure.field_constraint_type.status IS 'Status of the constraint type.';
COMMENT ON COLUMN opentenure.field_constraint_type.description IS 'Description of the constraint type.';

CREATE TABLE opentenure.field_value_type
(
code VARCHAR(255) NOT NULL,
display_value character varying(500) NOT NULL, 
status character(1) NOT NULL DEFAULT 'c'::bpchar,
description character varying(1000), 
CONSTRAINT field_value_type_pkey PRIMARY KEY (code),
CONSTRAINT field_value_type_display_value_unique UNIQUE (display_value)
);
COMMENT ON TABLE opentenure.field_value_type IS 'Reference table for the field value types, used in dynamic forms.';
COMMENT ON COLUMN opentenure.field_value_type.code IS 'The code for the field value type.';
COMMENT ON COLUMN opentenure.field_value_type.display_value IS 'Displayed value of the field value type.';
COMMENT ON COLUMN opentenure.field_value_type.status IS 'Status of the field value type.';
COMMENT ON COLUMN opentenure.field_value_type.description IS 'Description of the field value type.';

CREATE TABLE opentenure.field_type
(
code VARCHAR(255) NOT NULL,
display_value character varying(500) NOT NULL, 
status character(1) NOT NULL DEFAULT 'c'::bpchar,
description character varying(1000), 
CONSTRAINT field_type_pkey PRIMARY KEY (code),
CONSTRAINT field_type_display_value_unique UNIQUE (display_value)
);
COMMENT ON TABLE opentenure.field_type IS 'Reference table for the field types, used in dynamic forms.';
COMMENT ON COLUMN opentenure.field_type.code IS 'The code for the field type.';
COMMENT ON COLUMN opentenure.field_type.display_value IS 'Displayed value of the field type.';
COMMENT ON COLUMN opentenure.field_type.status IS 'Status of the field type.';
COMMENT ON COLUMN opentenure.field_type.description IS 'Description of the field type.';

CREATE TABLE opentenure.form_template
(
name VARCHAR(255) NOT NULL,
display_name VARCHAR(255) NOT NULL,
is_default boolean NOT NULL DEFAULT false,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT form_template_pkey PRIMARY KEY (name)
);

COMMENT ON TABLE opentenure.form_template IS 'Dynamic form template.';
COMMENT ON COLUMN opentenure.form_template.display_name IS 'Form name, which can be used for displaying on the UI.';
COMMENT ON COLUMN opentenure.form_template.is_default IS 'Indicates whether form is default for all new claims.';
COMMENT ON COLUMN opentenure.form_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.form_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.form_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.form_template.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.form_template.change_time IS 'The date and time the row was last modified.';

CREATE TABLE opentenure.form_template_historic
(
name VARCHAR(255),
display_name VARCHAR(255),
is_default boolean,
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.form_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.form_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
 
CREATE OR REPLACE FUNCTION opentenure.f_for_trg_set_default()
  RETURNS trigger AS
$BODY$
BEGIN  
  IF (TG_WHEN = 'AFTER') THEN
    IF (TG_OP = 'UPDATE' OR TG_OP = 'INSERT') THEN
        IF (NEW.is_default) THEN
            UPDATE opentenure.form_template SET is_default = 'f' WHERE is_default = 't' AND name != NEW.name;
        ELSE
	    IF (TG_OP = 'UPDATE' AND (SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't' AND name != OLD.name) < 1) THEN
	         UPDATE opentenure.form_template SET is_default = 't' WHERE name = OLD.name;
	    END IF;
        END IF;
    ELSIF (TG_OP = 'DELETE') THEN
        IF ((SELECT COUNT(1) FROM opentenure.form_template WHERE is_default = 't' AND name != OLD.name) < 1) THEN
	     UPDATE opentenure.form_template SET is_default = 't' WHERE name IN (SELECT name FROM opentenure.form_template WHERE name != OLD.name LIMIT 1);
        END IF;
    END IF;
    RETURN NULL;
  END IF;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION opentenure.f_for_trg_set_default()
  OWNER TO postgres;
COMMENT ON FUNCTION opentenure.f_for_trg_set_default() IS 'This function is to set default flag and have at least 1 form as default.';


CREATE TRIGGER set_default
  AFTER INSERT OR UPDATE OR DELETE
  ON opentenure.form_template
  FOR EACH ROW
  EXECUTE PROCEDURE opentenure.f_for_trg_set_default();
  
CREATE TABLE opentenure.section_template
(
id VARCHAR(40) NOT NULL,
name VARCHAR(255) NOT NULL,
display_name VARCHAR(255) NOT NULL,
error_msg VARCHAR(255) NOT NULL,
min_occurrences INTEGER NOT NULL,
max_occurrences INTEGER NOT NULL,
form_template_name VARCHAR(255) NOT NULL,
element_name VARCHAR(255) NOT NULL,
element_display_name VARCHAR(255) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT section_template_pkey PRIMARY KEY (id),
FOREIGN KEY (form_template_name) REFERENCES opentenure.form_template(name) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.section_template IS 'Sections of dynamic form template.';
COMMENT ON COLUMN opentenure.section_template.name IS 'Section name to be used as UI component name.';
COMMENT ON COLUMN opentenure.section_template.display_name IS 'Value to be used as a visible text (header) of UI component.';
COMMENT ON COLUMN opentenure.section_template.error_msg IS 'Error message to show when min/max conditions are not met.';
COMMENT ON COLUMN opentenure.section_template.min_occurrences IS 'Minimum occurane of the section elements on the form.';
COMMENT ON COLUMN opentenure.section_template.max_occurrences IS 'Maximum occurane of the section elements on the form. If max > 1, UI will be shown as a table.';
COMMENT ON COLUMN opentenure.section_template.form_template_name IS 'Foreign key reference to form template.';
COMMENT ON COLUMN opentenure.section_template.element_name IS 'Section element name to be used as UI component name.';
COMMENT ON COLUMN opentenure.section_template.element_display_name IS 'Text value to be used as a visible label of the section element UI component.';
COMMENT ON COLUMN opentenure.section_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.section_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.section_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.section_template.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.section_template.change_time IS 'The date and time the row was last modified.';

CREATE UNIQUE INDEX unique_section_template_name_idx ON opentenure.section_template(name,form_template_name);

CREATE TABLE opentenure.section_template_historic
(
id VARCHAR(40),
name VARCHAR(255),
display_name VARCHAR(255),
error_msg VARCHAR(255),
min_occurrences INTEGER,
max_occurrences INTEGER,
form_template_name VARCHAR(255),
element_name VARCHAR(255),
element_display_name VARCHAR(255),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.section_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.section_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE opentenure.form_payload
(
id VARCHAR(40) NOT NULL,
claim_id VARCHAR(40) NOT NULL,
form_template_name VARCHAR(255) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT form_payload_pkey PRIMARY KEY (id),
FOREIGN KEY (form_template_name) REFERENCES opentenure.form_template(name) ON DELETE CASCADE,
FOREIGN KEY (claim_id) REFERENCES opentenure.claim(id) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.form_payload IS 'Dynamic form payload.';
COMMENT ON COLUMN opentenure.form_payload.id IS 'Primary key.';
COMMENT ON COLUMN opentenure.form_payload.claim_id IS 'Foreign key to the parent claim object.';
COMMENT ON COLUMN opentenure.form_payload.form_template_name IS 'Foreign key to relevant dynamic form template.';
COMMENT ON COLUMN opentenure.form_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.form_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.form_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.form_payload.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.form_payload.change_time IS 'The date and time the row was last modified.';

CREATE TABLE opentenure.form_payload_historic
(
id VARCHAR(40),
claim_id VARCHAR(40),
form_template_name VARCHAR(255),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.form_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.form_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE opentenure.section_payload
(
id VARCHAR(40) NOT NULL,
name VARCHAR(255) NOT NULL,
display_name VARCHAR(255) NOT NULL,
element_name VARCHAR(255) NOT NULL,
element_display_name VARCHAR(255) NOT NULL,
min_occurrences INTEGER NOT NULL,
max_occurrences INTEGER NOT NULL,
form_payload_id VARCHAR(40) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT section_payload_pkey PRIMARY KEY (id),
FOREIGN KEY (form_payload_id) REFERENCES opentenure.form_payload(id) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.section_payload IS 'Dynamic form section payload.';
COMMENT ON COLUMN opentenure.section_payload.id IS 'Primary key.';
COMMENT ON COLUMN opentenure.section_payload.name IS 'Section name to be used as UI component name.';
COMMENT ON COLUMN opentenure.section_payload.display_name IS 'Value to be used as a visible text (header) of UI component.';
COMMENT ON COLUMN opentenure.section_payload.min_occurrences IS 'Minimum occurane of the section elements on the form.';
COMMENT ON COLUMN opentenure.section_payload.max_occurrences IS 'Maximum occurane of the section elements on the form. If max > 1, UI will be shown as a table.';
COMMENT ON COLUMN opentenure.section_payload.form_payload_id IS 'Foreign key reference to form payload.';
COMMENT ON COLUMN opentenure.section_payload.element_name IS 'Section element name to be used as UI component name.';
COMMENT ON COLUMN opentenure.section_payload.element_display_name IS 'Text value to be used as a visible label of the section element UI component.';
COMMENT ON COLUMN opentenure.section_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.section_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.section_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.section_payload.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.section_payload.change_time IS 'The date and time the row was last modified.';

CREATE UNIQUE INDEX unique_section_payload_name_idx ON opentenure.section_payload(name,form_payload_id);

CREATE TABLE opentenure.section_payload_historic
(
id VARCHAR(40),
name VARCHAR(255),
display_name VARCHAR(255),
element_name VARCHAR(255),
element_display_name VARCHAR(255),
min_occurrences INTEGER,
max_occurrences INTEGER,
form_payload_id VARCHAR(40),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.section_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.section_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE opentenure.field_template
(
id VARCHAR(40) NOT NULL,
name VARCHAR(255) NOT NULL,
display_name VARCHAR(255) NOT NULL,
hint VARCHAR(255),
field_type VARCHAR(255) NOT NULL,
section_template_id VARCHAR(40) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT field_template_pkey PRIMARY KEY (id),
FOREIGN KEY (section_template_id) REFERENCES opentenure.section_template(id) ON DELETE CASCADE,
FOREIGN KEY (field_type) REFERENCES opentenure.field_type(code) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.field_template IS 'Dynamic form field template.';
COMMENT ON COLUMN opentenure.field_template.id IS 'Primary key.';
COMMENT ON COLUMN opentenure.field_template.name IS 'Field name to be used as UI component name.';
COMMENT ON COLUMN opentenure.field_template.hint IS 'Field hint to be used for UI component.';
COMMENT ON COLUMN opentenure.field_template.field_type IS 'Field type code.';
COMMENT ON COLUMN opentenure.field_template.display_name IS 'Value to be used as a visible text (header) of UI component.';
COMMENT ON COLUMN opentenure.field_template.section_template_id IS 'Section template ID.';
COMMENT ON COLUMN opentenure.field_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.field_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.field_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.field_template.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.field_template.change_time IS 'The date and time the row was last modified.';

CREATE UNIQUE INDEX unique_field_template_name_idx ON opentenure.field_template(name,section_template_id);

CREATE TABLE opentenure.field_template_historic
(
id VARCHAR(40),
name VARCHAR(255),
display_name VARCHAR(255),
hint VARCHAR(255),
field_type VARCHAR(255),
section_template_id VARCHAR(40),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.field_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.field_template
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE opentenure.field_constraint
(
id VARCHAR(40) NOT NULL,
name VARCHAR(255) NOT NULL,
display_name VARCHAR(255) NOT NULL,
error_msg VARCHAR(255) NOT NULL,
format VARCHAR(255),
min_value DECIMAL(20,10),
max_value DECIMAL(20,10),
field_constraint_type VARCHAR(255) NOT NULL,
field_template_id VARCHAR(40) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT field_constraint_pkey PRIMARY KEY (id),
FOREIGN KEY (field_constraint_type) REFERENCES opentenure.field_constraint_type(code) ON DELETE CASCADE,
FOREIGN KEY (field_template_id) REFERENCES opentenure.field_template(id) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.field_constraint IS 'Dynamic form field constraint.';
COMMENT ON COLUMN opentenure.field_constraint.id IS 'Primary key.';
COMMENT ON COLUMN opentenure.field_constraint.name IS 'Field name to be used as UI component name.';
COMMENT ON COLUMN opentenure.field_constraint.display_name IS 'Value to be used as a visible text (header) of UI component.';
COMMENT ON COLUMN opentenure.field_constraint.error_msg IS 'Error message to display in case of constraint violation.';
COMMENT ON COLUMN opentenure.field_constraint.format IS 'Regular expression, used to check field value';
COMMENT ON COLUMN opentenure.field_constraint.min_value IS 'Minimum field value, used in range constraint.';
COMMENT ON COLUMN opentenure.field_constraint.max_value IS 'Maximum field value, used in range constraint.';
COMMENT ON COLUMN opentenure.field_constraint.field_constraint_type IS 'Type of constraint.';
COMMENT ON COLUMN opentenure.field_constraint.field_template_id IS 'Field template id, which constraint relates to.';
COMMENT ON COLUMN opentenure.field_template.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.field_template.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.field_template.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.field_template.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.field_template.change_time IS 'The date and time the row was last modified.';

CREATE UNIQUE INDEX unique_field_constraint_name_idx ON opentenure.field_constraint(name,field_template_id);

CREATE TABLE opentenure.field_constraint_historic
(
id VARCHAR(40),
name VARCHAR(255),
display_name VARCHAR(255),
error_msg VARCHAR(255),
format VARCHAR(255),
min_value DECIMAL(20,10),
max_value DECIMAL(20,10),
field_constraint_type VARCHAR(255),
field_template_id VARCHAR(40),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.field_constraint
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.field_constraint
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE opentenure.field_constraint_option
(
id VARCHAR(40) NOT NULL,
name VARCHAR(255) NOT NULL,
display_name VARCHAR(255) NOT NULL,
field_constraint_id VARCHAR(40) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT field_constraint_option_pkey PRIMARY KEY (id),
FOREIGN KEY (field_constraint_id) REFERENCES opentenure.field_constraint(id) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.field_constraint_option IS 'Dynamic form field constraint option, used to limit field values.';
COMMENT ON COLUMN opentenure.field_constraint_option.id IS 'Primary key.';
COMMENT ON COLUMN opentenure.field_constraint_option.name IS 'Field name to be used as UI component name.';
COMMENT ON COLUMN opentenure.field_constraint_option.display_name IS 'Value to be used as a visible text of UI component.';
COMMENT ON COLUMN opentenure.field_constraint_option.field_constraint_id IS 'Field constraint ID.';
COMMENT ON COLUMN opentenure.field_constraint_option.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.field_constraint_option.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.field_constraint_option.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.field_constraint_option.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.field_constraint_option.change_time IS 'The date and time the row was last modified.';

CREATE UNIQUE INDEX unique_field_constraint_option_name_idx ON opentenure.field_constraint_option(name,field_constraint_id);

CREATE TABLE opentenure.field_constraint_option_historic
(
id VARCHAR(40),
name VARCHAR(255),
display_name VARCHAR(255),
field_constraint_id VARCHAR(40),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.field_constraint_option
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.field_constraint_option
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE opentenure.section_element_payload
(
id VARCHAR(40) NOT NULL,
section_payload_id VARCHAR(40) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT section_element_payload_pkey PRIMARY KEY (id),
FOREIGN KEY (section_payload_id) REFERENCES opentenure.section_payload(id) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.section_element_payload IS 'Dynamic form section element payload.';
COMMENT ON COLUMN opentenure.section_element_payload.section_payload_id IS 'Section payload ID.';
COMMENT ON COLUMN opentenure.section_element_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.section_element_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.section_element_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.section_element_payload.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.section_element_payload.change_time IS 'The date and time the row was last modified.';

CREATE TABLE opentenure.section_element_payload_historic
(
id VARCHAR(40),
section_payload_id VARCHAR(40),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.section_element_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.section_element_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
CREATE TABLE opentenure.field_payload
(
id VARCHAR(40) NOT NULL,
name VARCHAR(255) NOT NULL,
display_name VARCHAR(255) NOT NULL,
field_type VARCHAR(255) NOT NULL,
section_element_payload_id VARCHAR(40) NOT NULL,
string_payload VARCHAR(2048),
big_decimal_payload DECIMAL(20,10),
boolean_payload BOOLEAN,
field_value_type VARCHAR(255) NOT NULL,
rowidentifier character varying(40) NOT NULL DEFAULT uuid_generate_v1(),
rowversion integer NOT NULL DEFAULT 0,
change_action character(1) NOT NULL DEFAULT 'i'::bpchar,
change_user character varying(50), 
change_time timestamp without time zone NOT NULL DEFAULT now(),
CONSTRAINT field_payload_pkey PRIMARY KEY (id),
FOREIGN KEY (field_value_type) REFERENCES opentenure.field_value_type(code) ON DELETE CASCADE,
FOREIGN KEY (section_element_payload_id) REFERENCES opentenure.section_element_payload(id) ON DELETE CASCADE,
FOREIGN KEY (field_type) REFERENCES opentenure.field_type(code) ON DELETE CASCADE
);

COMMENT ON TABLE opentenure.field_payload IS 'Dynamic form field payload.';
COMMENT ON COLUMN opentenure.field_payload.id IS 'Primary key.';
COMMENT ON COLUMN opentenure.field_payload.name IS 'Field name to be used as UI component name.';
COMMENT ON COLUMN opentenure.field_payload.display_name IS 'Value to be used as a visible text of UI component.';
COMMENT ON COLUMN opentenure.field_payload.field_type IS 'Field type code.';
COMMENT ON COLUMN opentenure.field_payload.section_element_payload_id IS 'Section element id.';
COMMENT ON COLUMN opentenure.field_payload.string_payload IS 'String field value.';
COMMENT ON COLUMN opentenure.field_payload.big_decimal_payload IS 'Decimal or integer field value.';
COMMENT ON COLUMN opentenure.field_payload.boolean_payload IS 'Boolean field value.';
COMMENT ON COLUMN opentenure.field_payload.rowidentifier IS 'Identifies the all change records for the row in the form historic table.';
COMMENT ON COLUMN opentenure.field_payload.rowversion IS 'Sequential value indicating the number of times this row has been modified.';
COMMENT ON COLUMN opentenure.field_payload.change_action IS 'Indicates if the last data modification action that occurred to the row was insert (i), update (u) or delete (d).';
COMMENT ON COLUMN opentenure.field_payload.change_user IS 'The user id of the last person to modify the row.';
COMMENT ON COLUMN opentenure.field_payload.change_time IS 'The date and time the row was last modified.';

CREATE UNIQUE INDEX unique_field_payload_name_idx ON opentenure.field_payload(name,section_element_payload_id);

CREATE TABLE opentenure.field_payload_historic
(
id VARCHAR(40),
name VARCHAR(255),
display_name VARCHAR(255),
field_type VARCHAR(255),
section_element_payload_id VARCHAR(40),
string_payload VARCHAR(2048),
big_decimal_payload DECIMAL(20,10),
boolean_payload BOOLEAN,
field_value_type VARCHAR(255),
rowidentifier character varying(40),
rowversion integer,
change_action character(1),
change_user character varying(50), 
change_time timestamp without time zone,
change_time_valid_until timestamp without time zone NOT NULL DEFAULT now()
);

CREATE TRIGGER __track_changes
  BEFORE INSERT OR UPDATE
  ON opentenure.field_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_changes();

CREATE TRIGGER __track_history
  AFTER UPDATE OR DELETE
  ON opentenure.field_payload
  FOR EACH ROW
  EXECUTE PROCEDURE f_for_trg_track_history();
  
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('DATETIME', 'DATETIME');
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('INTEGER', 'INTEGER');
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('NOT_NULL', 'NOT_NULL');
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('INTEGER_RANGE', 'INTEGER_RANGE');
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('DOUBLE_RANGE', 'DOUBLE_RANGE');
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('REGEXP', 'REGEXP');
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('LENGTH', 'LENGTH');
INSERT INTO opentenure.field_constraint_type (code, display_value) VALUES ('OPTION', 'OPTION');

INSERT INTO opentenure.field_type (code, display_value) VALUES ('BOOL', 'BOOL');
INSERT INTO opentenure.field_type (code, display_value) VALUES ('TEXT', 'TEXT');
INSERT INTO opentenure.field_type (code, display_value) VALUES ('INTEGER', 'INTEGER');
INSERT INTO opentenure.field_type (code, display_value) VALUES ('DECIMAL', 'DECIMAL');
INSERT INTO opentenure.field_type (code, display_value) VALUES ('DATE', 'DATE');

INSERT INTO opentenure.field_value_type (code, display_value) VALUES ('TEXT', 'TEXT');
INSERT INTO opentenure.field_value_type (code, display_value) VALUES ('NUMBER', 'NUMBER');
INSERT INTO opentenure.field_value_type (code, display_value) VALUES ('BOOL', 'BOOL');