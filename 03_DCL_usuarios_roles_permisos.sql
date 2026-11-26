-- ============================================================================
-- 12. ANEXOS - CÓDIGO SQL DCL (DB-HEALTH)
-- i. Gestión de usuarios, roles y permisos
-- ============================================================================

CREATE ROLE IF NOT EXISTS 'rol_app_db_health';
CREATE ROLE IF NOT EXISTS 'rol_dev_db_health';
CREATE ROLE IF NOT EXISTS 'rol_auditor_db_health';

GRANT SELECT, INSERT, UPDATE, DELETE ON db_health.* TO 'rol_app_db_health';
GRANT ALL PRIVILEGES ON db_health.* TO 'rol_dev_db_health';
GRANT SELECT ON audit.* TO 'rol_dev_db_health';
GRANT SELECT ON audit.* TO 'rol_auditor_db_health';

CREATE USER IF NOT EXISTS 'app_db_health'@'localhost' IDENTIFIED BY 'AppHealth2026*';
CREATE USER IF NOT EXISTS 'dev_db_health'@'localhost' IDENTIFIED BY 'DevHealth2026*';
CREATE USER IF NOT EXISTS 'auditor_db_health'@'localhost' IDENTIFIED BY 'AudHealth2026*';

GRANT 'rol_app_db_health' TO 'app_db_health'@'localhost';
GRANT 'rol_dev_db_health' TO 'dev_db_health'@'localhost';
GRANT 'rol_auditor_db_health' TO 'auditor_db_health'@'localhost';

SET DEFAULT ROLE 'rol_app_db_health' FOR 'app_db_health'@'localhost';
SET DEFAULT ROLE 'rol_dev_db_health' FOR 'dev_db_health'@'localhost';
SET DEFAULT ROLE 'rol_auditor_db_health' FOR 'auditor_db_health'@'localhost';

FLUSH PRIVILEGES;

SHOW GRANTS FOR 'app_db_health'@'localhost';
SHOW GRANTS FOR 'dev_db_health'@'localhost';
SHOW GRANTS FOR 'auditor_db_health'@'localhost';
