-- Table: "system".config_map_layer_metadata
 --DROP TABLE "system".config_map_layer_metadata;

CREATE TABLE "system".config_map_layer_metadata
(
  name_layer character varying(50) NOT NULL,
  "name" character varying(50),
  "value" character varying(100),
  CONSTRAINT config_map_layer_metadata_name_fk FOREIGN KEY (name_layer)
      REFERENCES "system".config_map_layer ("name") MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE RESTRICT
)
WITH (
  OIDS=FALSE
);
ALTER TABLE "system".config_map_layer_metadata OWNER TO postgres;

-- Index: "system".config_map_layer_metadata_name_fk_ind

-- DROP INDEX "system".config_map_layer_metadata_name_fk_ind;

CREATE INDEX config_map_layer_metadata_name_fk_ind
  ON "system".config_map_layer_metadata
  USING btree
  (name);

INSERT INTO "system".config_map_layer_metadata(
            name_layer)
    select "name" from "system".config_map_layer;



-- set imagery date
UPDATE system.config_map_layer_metadata
SET value = 'Should be the date of the orthophoto',
    "name" = 'date'
WHERE name_layer = 'orthophoto';