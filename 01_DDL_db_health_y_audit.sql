-- ============================================================================
-- 12. ANEXOS - CÓDIGO SQL DDL (DB-HEALTH)
-- i. Creación de tablas (db_health)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS db_health CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE db_health;

CREATE TABLE persona (
    identificacion VARCHAR(20) PRIMARY KEY,
    primer_nombre VARCHAR(50) NOT NULL,
    segundo_nombre VARCHAR(50),
    primer_apellido VARCHAR(50) NOT NULL,
    segundo_apellido VARCHAR(50),
    genero VARCHAR(20) NOT NULL,
    correo_electronico VARCHAR(100) NOT NULL UNIQUE,
    telefono_contacto VARCHAR(20) NOT NULL,
    fecha_nacimiento DATE NOT NULL
);

CREATE TABLE paciente (
    identificacion VARCHAR(20) PRIMARY KEY,
    tipo_sangre VARCHAR(5) NOT NULL,
    eps_afiliacion VARCHAR(50) NOT NULL,
    estado_civil VARCHAR(20) NOT NULL,
    CONSTRAINT fk_paciente_persona FOREIGN KEY (identificacion)
        REFERENCES persona(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE medico (
    identificacion VARCHAR(20) PRIMARY KEY,
    registro_medico VARCHAR(50) NOT NULL UNIQUE,
    horario_atencion VARCHAR(100) NOT NULL,
    CONSTRAINT fk_medico_persona FOREIGN KEY (identificacion)
        REFERENCES persona(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE enfermero (
    identificacion VARCHAR(20) PRIMARY KEY,
    turno_laboral VARCHAR(30) NOT NULL,
    area_asignada VARCHAR(50) NOT NULL,
    CONSTRAINT fk_enfermero_persona FOREIGN KEY (identificacion)
        REFERENCES persona(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE personal_administrativo (
    identificacion VARCHAR(20) PRIMARY KEY,
    cargo_administrativo VARCHAR(50) NOT NULL,
    extension_telefonica VARCHAR(10) NOT NULL,
    CONSTRAINT fk_admin_persona FOREIGN KEY (identificacion)
        REFERENCES persona(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE hospital (
    codigo_hospital VARCHAR(20) PRIMARY KEY,
    nombre_hospital VARCHAR(100) NOT NULL,
    telefono_principal VARCHAR(20) NOT NULL,
    nivel_complejidad VARCHAR(30) NOT NULL,
    direccion VARCHAR(150) NOT NULL
);

CREATE TABLE consultorio (
    numero_consultorio INT PRIMARY KEY,
    codigo_hospital VARCHAR(20) NOT NULL,
    piso INT NOT NULL,
    estado_disponibilidad VARCHAR(30) NOT NULL,
    CONSTRAINT fk_consultorio_hospital FOREIGN KEY (codigo_hospital)
        REFERENCES hospital(codigo_hospital) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE especialidad (
    codigo_especialidad VARCHAR(20) PRIMARY KEY,
    nombre_especialidad VARCHAR(50) NOT NULL,
    descripcion TEXT
);

CREATE TABLE medico_especialidad (
    identificacion_medico VARCHAR(20) NOT NULL,
    codigo_especialidad VARCHAR(20) NOT NULL,
    PRIMARY KEY (identificacion_medico, codigo_especialidad),
    CONSTRAINT fk_med_esp_medico FOREIGN KEY (identificacion_medico)
        REFERENCES medico(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_med_esp_especialidad FOREIGN KEY (codigo_especialidad)
        REFERENCES especialidad(codigo_especialidad) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE enfermero_hospital (
    identificacion_enfermero VARCHAR(20) NOT NULL,
    codigo_hospital VARCHAR(20) NOT NULL,
    PRIMARY KEY (identificacion_enfermero, codigo_hospital),
    CONSTRAINT fk_enf_hosp_enfermero FOREIGN KEY (identificacion_enfermero)
        REFERENCES enfermero(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_enf_hosp_hospital FOREIGN KEY (codigo_hospital)
        REFERENCES hospital(codigo_hospital) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE historia_clinica (
    consecutivo_historia INT AUTO_INCREMENT PRIMARY KEY,
    identificacion_paciente VARCHAR(20) NOT NULL UNIQUE,
    fecha_apertura DATE NOT NULL,
    diagnostico_principal VARCHAR(150) NOT NULL,
    observaciones TEXT,
    CONSTRAINT fk_historia_paciente FOREIGN KEY (identificacion_paciente)
        REFERENCES paciente(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE cita_medica (
    consecutivo_cita INT AUTO_INCREMENT PRIMARY KEY,
    identificacion_paciente VARCHAR(20) NOT NULL,
    identificacion_medico VARCHAR(20) NOT NULL,
    numero_consultorio INT NOT NULL,
    identificacion_administrativo VARCHAR(20) NOT NULL,
    fecha_hora_programada DATETIME NOT NULL,
    estado_cita VARCHAR(30) NOT NULL,
    motivo_consulta TEXT NOT NULL,
    CONSTRAINT fk_cita_paciente FOREIGN KEY (identificacion_paciente)
        REFERENCES paciente(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_medico FOREIGN KEY (identificacion_medico)
        REFERENCES medico(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_consultorio FOREIGN KEY (numero_consultorio)
        REFERENCES consultorio(numero_consultorio) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_cita_admin FOREIGN KEY (identificacion_administrativo)
        REFERENCES personal_administrativo(identificacion) ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE medicamento (
    codigo_medicamento VARCHAR(20) PRIMARY KEY,
    nombre_comercial VARCHAR(100) NOT NULL,
    concentracion VARCHAR(50) NOT NULL,
    stock_disponible INT NOT NULL DEFAULT 0,
    forma_farmaceutica VARCHAR(50) NOT NULL
);

CREATE TABLE prescripcion_cita_medicamento (
    consecutivo_cita INT NOT NULL,
    codigo_medicamento VARCHAR(20) NOT NULL,
    dosis VARCHAR(100) NOT NULL,
    frecuencia VARCHAR(100) NOT NULL,
    duracion VARCHAR(100) NOT NULL,
    PRIMARY KEY (consecutivo_cita, codigo_medicamento),
    CONSTRAINT fk_presc_cita FOREIGN KEY (consecutivo_cita)
        REFERENCES cita_medica(consecutivo_cita) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_presc_medicamento FOREIGN KEY (codigo_medicamento)
        REFERENCES medicamento(codigo_medicamento) ON UPDATE CASCADE ON DELETE RESTRICT
);

-- ============================================================================
-- ii. Creación del modelo auditoría (audit y disparadores)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS audit CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE audit;

CREATE TABLE aud_persona (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    identificacion_old VARCHAR(20), identificacion_new VARCHAR(20),
    primer_nombre_old VARCHAR(50), primer_nombre_new VARCHAR(50),
    segundo_nombre_old VARCHAR(50), segundo_nombre_new VARCHAR(50),
    primer_apellido_old VARCHAR(50), primer_apellido_new VARCHAR(50),
    segundo_apellido_old VARCHAR(50), segundo_apellido_new VARCHAR(50),
    genero_old VARCHAR(20), genero_new VARCHAR(20),
    correo_electronico_old VARCHAR(100), correo_electronico_new VARCHAR(100),
    telefono_contacto_old VARCHAR(20), telefono_contacto_new VARCHAR(20),
    fecha_nacimiento_old DATE, fecha_nacimiento_new DATE
);

CREATE TABLE aud_paciente (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    identificacion_old VARCHAR(20), identificacion_new VARCHAR(20),
    tipo_sangre_old VARCHAR(5), tipo_sangre_new VARCHAR(5),
    eps_afiliacion_old VARCHAR(50), eps_afiliacion_new VARCHAR(50),
    estado_civil_old VARCHAR(20), estado_civil_new VARCHAR(20)
);

CREATE TABLE aud_medico (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    identificacion_old VARCHAR(20), identificacion_new VARCHAR(20),
    registro_medico_old VARCHAR(50), registro_medico_new VARCHAR(50),
    horario_atencion_old VARCHAR(100), horario_atencion_new VARCHAR(100)
);

CREATE TABLE aud_enfermero (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    identificacion_old VARCHAR(20), identificacion_new VARCHAR(20),
    turno_laboral_old VARCHAR(30), turno_laboral_new VARCHAR(30),
    area_asignada_old VARCHAR(50), area_asignada_new VARCHAR(50)
);

CREATE TABLE aud_personal_administrativo (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    identificacion_old VARCHAR(20), identificacion_new VARCHAR(20),
    cargo_administrativo_old VARCHAR(50), cargo_administrativo_new VARCHAR(50),
    extension_telefonica_old VARCHAR(10), extension_telefonica_new VARCHAR(10)
);

CREATE TABLE aud_hospital (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    codigo_hospital_old VARCHAR(20), codigo_hospital_new VARCHAR(20),
    nombre_hospital_old VARCHAR(100), nombre_hospital_new VARCHAR(100),
    telefono_principal_old VARCHAR(20), telefono_principal_new VARCHAR(20),
    nivel_complejidad_old VARCHAR(30), nivel_complejidad_new VARCHAR(30),
    direccion_old VARCHAR(150), direccion_new VARCHAR(150)
);

CREATE TABLE aud_consultorio (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    numero_consultorio_old INT, numero_consultorio_new INT,
    codigo_hospital_old VARCHAR(20), codigo_hospital_new VARCHAR(20),
    piso_old INT, piso_new INT,
    estado_disponibilidad_old VARCHAR(30), estado_disponibilidad_new VARCHAR(30)
);

CREATE TABLE aud_especialidad (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    codigo_especialidad_old VARCHAR(20), codigo_especialidad_new VARCHAR(20),
    nombre_especialidad_old VARCHAR(50), nombre_especialidad_new VARCHAR(50),
    descripcion_old TEXT, descripcion_new TEXT
);

CREATE TABLE aud_medico_especialidad (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    identificacion_medico_old VARCHAR(20), identificacion_medico_new VARCHAR(20),
    codigo_especialidad_old VARCHAR(20), codigo_especialidad_new VARCHAR(20)
);

CREATE TABLE aud_enfermero_hospital (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    identificacion_enfermero_old VARCHAR(20), identificacion_enfermero_new VARCHAR(20),
    codigo_hospital_old VARCHAR(20), codigo_hospital_new VARCHAR(20)
);

CREATE TABLE aud_historia_clinica (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    consecutivo_historia_old INT, consecutivo_historia_new INT,
    identificacion_paciente_old VARCHAR(20), identificacion_paciente_new VARCHAR(20),
    fecha_apertura_old DATE, fecha_apertura_new DATE,
    diagnostico_principal_old VARCHAR(150), diagnostico_principal_new VARCHAR(150),
    observaciones_old TEXT, observaciones_new TEXT
);

CREATE TABLE aud_cita_medica (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    consecutivo_cita_old INT, consecutivo_cita_new INT,
    identificacion_paciente_old VARCHAR(20), identificacion_paciente_new VARCHAR(20),
    identificacion_medico_old VARCHAR(20), identificacion_medico_new VARCHAR(20),
    numero_consultorio_old INT, numero_consultorio_new INT,
    identificacion_administrativo_old VARCHAR(20), identificacion_administrativo_new VARCHAR(20),
    fecha_hora_programada_old DATETIME, fecha_hora_programada_new DATETIME,
    estado_cita_old VARCHAR(30), estado_cita_new VARCHAR(30),
    motivo_consulta_old TEXT, motivo_consulta_new TEXT
);

CREATE TABLE aud_medicamento (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    codigo_medicamento_old VARCHAR(20), codigo_medicamento_new VARCHAR(20),
    nombre_comercial_old VARCHAR(100), nombre_comercial_new VARCHAR(100),
    concentracion_old VARCHAR(50), concentracion_new VARCHAR(50),
    stock_disponible_old INT, stock_disponible_new INT,
    forma_farmaceutica_old VARCHAR(50), forma_farmaceutica_new VARCHAR(50)
);

CREATE TABLE aud_prescripcion_cita_medicamento (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    accion VARCHAR(10) NOT NULL,
    fecha_evento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario_bd VARCHAR(100) NOT NULL,
    consecutivo_cita_old INT, consecutivo_cita_new INT,
    codigo_medicamento_old VARCHAR(20), codigo_medicamento_new VARCHAR(20),
    dosis_old VARCHAR(100), dosis_new VARCHAR(100),
    frecuencia_old VARCHAR(100), frecuencia_new VARCHAR(100),
    duracion_old VARCHAR(100), duracion_new VARCHAR(100)
);

USE db_health;
DELIMITER //

CREATE TRIGGER trg_hospital_ai AFTER INSERT ON hospital FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_hospital (accion, fecha_evento, usuario_bd, codigo_hospital_new, nombre_hospital_new, telefono_principal_new, nivel_complejidad_new, direccion_new)
    VALUES ('INSERT', NOW(), CURRENT_USER(), NEW.codigo_hospital, NEW.nombre_hospital, NEW.telefono_principal, NEW.nivel_complejidad, NEW.direccion);
END//

CREATE TRIGGER trg_hospital_au AFTER UPDATE ON hospital FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_hospital (accion, fecha_evento, usuario_bd, codigo_hospital_old, codigo_hospital_new, nombre_hospital_old, nombre_hospital_new, telefono_principal_old, telefono_principal_new, nivel_complejidad_old, nivel_complejidad_new, direccion_old, direccion_new)
    VALUES ('UPDATE', NOW(), CURRENT_USER(), OLD.codigo_hospital, NEW.codigo_hospital, OLD.nombre_hospital, NEW.nombre_hospital, OLD.telefono_principal, NEW.telefono_principal, OLD.nivel_complejidad, NEW.nivel_complejidad, OLD.direccion, NEW.direccion);
END//

CREATE TRIGGER trg_hospital_ad AFTER DELETE ON hospital FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_hospital (accion, fecha_evento, usuario_bd, codigo_hospital_old, nombre_hospital_old, telefono_principal_old, nivel_complejidad_old, direccion_old)
    VALUES ('DELETE', NOW(), CURRENT_USER(), OLD.codigo_hospital, OLD.nombre_hospital, OLD.telefono_principal, OLD.nivel_complejidad, OLD.direccion);
END//

CREATE TRIGGER trg_paciente_ai AFTER INSERT ON paciente FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_paciente (accion, fecha_evento, usuario_bd, identificacion_new, tipo_sangre_new, eps_afiliacion_new, estado_civil_new)
    VALUES ('INSERT', NOW(), CURRENT_USER(), NEW.identificacion, NEW.tipo_sangre, NEW.eps_afiliacion, NEW.estado_civil);
END//

CREATE TRIGGER trg_paciente_au AFTER UPDATE ON paciente FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_paciente (accion, fecha_evento, usuario_bd, identificacion_old, identificacion_new, tipo_sangre_old, tipo_sangre_new, eps_afiliacion_old, eps_afiliacion_new, estado_civil_old, estado_civil_new)
    VALUES ('UPDATE', NOW(), CURRENT_USER(), OLD.identificacion, NEW.identificacion, OLD.tipo_sangre, NEW.tipo_sangre, OLD.eps_afiliacion, NEW.eps_afiliacion, OLD.estado_civil, NEW.estado_civil);
END//

CREATE TRIGGER trg_paciente_ad AFTER DELETE ON paciente FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_paciente (accion, fecha_evento, usuario_bd, identificacion_old, tipo_sangre_old, eps_afiliacion_old, estado_civil_old)
    VALUES ('DELETE', NOW(), CURRENT_USER(), OLD.identificacion, OLD.tipo_sangre, OLD.eps_afiliacion, OLD.estado_civil);
END//

CREATE TRIGGER trg_cita_ai AFTER INSERT ON cita_medica FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_cita_medica (accion, fecha_evento, usuario_bd, consecutivo_cita_new, identificacion_paciente_new, identificacion_medico_new, numero_consultorio_new, identificacion_administrativo_new, fecha_hora_programada_new, estado_cita_new, motivo_consulta_new)
    VALUES ('INSERT', NOW(), CURRENT_USER(), NEW.consecutivo_cita, NEW.identificacion_paciente, NEW.identificacion_medico, NEW.numero_consultorio, NEW.identificacion_administrativo, NEW.fecha_hora_programada, NEW.estado_cita, NEW.motivo_consulta);
END//

CREATE TRIGGER trg_cita_au AFTER UPDATE ON cita_medica FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_cita_medica (accion, fecha_evento, usuario_bd, consecutivo_cita_old, consecutivo_cita_new, identificacion_paciente_old, identificacion_paciente_new, identificacion_medico_old, identificacion_medico_new, numero_consultorio_old, numero_consultorio_new, identificacion_administrativo_old, identificacion_administrativo_new, fecha_hora_programada_old, fecha_hora_programada_new, estado_cita_old, estado_cita_new, motivo_consulta_old, motivo_consulta_new)
    VALUES ('UPDATE', NOW(), CURRENT_USER(), OLD.consecutivo_cita, NEW.consecutivo_cita, OLD.identificacion_paciente, NEW.identificacion_paciente, OLD.identificacion_medico, NEW.identificacion_medico, OLD.numero_consultorio, NEW.numero_consultorio, OLD.identificacion_administrativo, NEW.identificacion_administrativo, OLD.fecha_hora_programada, NEW.fecha_hora_programada, OLD.estado_cita, NEW.estado_cita, OLD.motivo_consulta, NEW.motivo_consulta);
END//

CREATE TRIGGER trg_cita_ad AFTER DELETE ON cita_medica FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_cita_medica (accion, fecha_evento, usuario_bd, consecutivo_cita_old, identificacion_paciente_old, identificacion_medico_old, numero_consultorio_old, identificacion_administrativo_old, fecha_hora_programada_old, estado_cita_old, motivo_consulta_old)
    VALUES ('DELETE', NOW(), CURRENT_USER(), OLD.consecutivo_cita, OLD.identificacion_paciente, OLD.identificacion_medico, OLD.numero_consultorio, OLD.identificacion_administrativo, OLD.fecha_hora_programada, OLD.estado_cita, OLD.motivo_consulta);
END//

CREATE TRIGGER trg_medicamento_ai AFTER INSERT ON medicamento FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_medicamento (accion, fecha_evento, usuario_bd, codigo_medicamento_new, nombre_comercial_new, concentracion_new, stock_disponible_new, forma_farmaceutica_new)
    VALUES ('INSERT', NOW(), CURRENT_USER(), NEW.codigo_medicamento, NEW.nombre_comercial, NEW.concentracion, NEW.stock_disponible, NEW.forma_farmaceutica);
END//

CREATE TRIGGER trg_medicamento_au AFTER UPDATE ON medicamento FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_medicamento (accion, fecha_evento, usuario_bd, codigo_medicamento_old, codigo_medicamento_new, nombre_comercial_old, nombre_comercial_new, concentracion_old, concentracion_new, stock_disponible_old, stock_disponible_new, forma_farmaceutica_old, forma_farmaceutica_new)
    VALUES ('UPDATE', NOW(), CURRENT_USER(), OLD.codigo_medicamento, NEW.codigo_medicamento, OLD.nombre_comercial, NEW.nombre_comercial, OLD.concentracion, NEW.concentracion, OLD.stock_disponible, NEW.stock_disponible, OLD.forma_farmaceutica, NEW.forma_farmaceutica);
END//

CREATE TRIGGER trg_medicamento_ad AFTER DELETE ON medicamento FOR EACH ROW
BEGIN
    INSERT INTO audit.aud_medicamento (accion, fecha_evento, usuario_bd, codigo_medicamento_old, nombre_comercial_old, concentracion_old, stock_disponible_old, forma_farmaceutica_old)
    VALUES ('DELETE', NOW(), CURRENT_USER(), OLD.codigo_medicamento, OLD.nombre_comercial, OLD.concentracion, OLD.stock_disponible, OLD.forma_farmaceutica);
END//

DELIMITER ;
