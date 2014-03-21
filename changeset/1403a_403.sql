-- Ticket #403
DROP TRIGGER if exists trg_remove ON cadastre.cadastre_object;

CREATE TRIGGER trg_remove
  AFTER DELETE
  ON cadastre.cadastre_object
  FOR EACH ROW
  EXECUTE PROCEDURE cadastre.f_for_tbl_cadastre_object_trg_remove();

INSERT INTO system.version SELECT '1403a' WHERE NOT EXISTS (SELECT version_num FROM system.version WHERE version_num = '1403a');
