-- ============================================================================
-- 12. ANEXOS - CÓDIGO SQL DML (DB-HEALTH)
-- i. Inserción de registros (5 a 10 registros por tabla)
-- ============================================================================

USE db_health;

INSERT INTO persona VALUES
('1001', 'Carlos', 'Andrés', 'Gómez', 'Ruiz', 'Masculino', 'carlos.gomez@mail.com', '3101110001', '1985-03-12'),
('1002', 'María', 'Fernanda', 'López', 'Díaz', 'Femenino', 'maria.lopez@mail.com', '3101110002', '1990-07-25'),
('1003', 'Juan', 'Pablo', 'Martínez', 'Sánchez', 'Masculino', 'juan.martinez@mail.com', '3101110003', '1978-11-04'),
('1004', 'Laura', 'Sofía', 'Rodríguez', 'Pérez', 'Femenino', 'laura.rodriguez@mail.com', '3101110004', '1995-01-19'),
('1005', 'Diego', 'Alejandro', 'Hernández', 'Castro', 'Masculino', 'diego.hernandez@mail.com', '3101110005', '1982-09-30'),
('2001', 'Andrés', 'Felipe', 'Vargas', 'Mora', 'Masculino', 'dr.vargas@dbhealth.com', '3202220001', '1975-05-14'),
('2002', 'Claudia', 'Patricia', 'Rojas', 'Silva', 'Femenino', 'dra.rojas@dbhealth.com', '3202220002', '1980-08-22'),
('2003', 'Ricardo', 'Antonio', 'Mendoza', 'Ortiz', 'Masculino', 'dr.mendoza@dbhealth.com', '3202220003', '1972-12-09'),
('2004', 'Natalia', 'Isabel', 'Cárdenas', 'Vega', 'Femenino', 'dra.cardenas@dbhealth.com', '3202220004', '1986-04-17'),
('2005', 'Sergio', 'Luis', 'Navarro', 'Pardo', 'Masculino', 'dr.navarro@dbhealth.com', '3202220005', '1979-10-28'),
('3001', 'Paola', 'Andrea', 'Suárez', 'Reyes', 'Femenino', 'paola.suarez@dbhealth.com', '3153330001', '1991-02-11'),
('3002', 'Jorge', 'Enrique', 'Ramírez', 'León', 'Masculino', 'jorge.ramirez@dbhealth.com', '3153330002', '1988-06-03'),
('3003', 'Diana', 'Carolina', 'Torres', 'Mejía', 'Femenino', 'diana.torres@dbhealth.com', '3153330003', '1993-09-15'),
('3004', 'Camila', 'Valentina', 'Acosta', 'Gil', 'Femenino', 'camila.acosta@dbhealth.com', '3153330004', '1994-11-27'),
('3005', 'Óscar', 'Javier', 'Peña', 'Salazar', 'Masculino', 'oscar.pena@dbhealth.com', '3153330005', '1987-01-08'),
('4001', 'Sandra', 'Milena', 'Quintero', 'Arias', 'Femenino', 'sandra.quintero@dbhealth.com', '3184440001', '1984-07-16'),
('4002', 'Héctor', 'Fabio', 'Giraldo', 'Osorio', 'Masculino', 'hector.giraldo@dbhealth.com', '3184440002', '1981-03-29'),
('4003', 'Juliana', 'Marcela', 'Pineda', 'Cruz', 'Femenino', 'juliana.pineda@dbhealth.com', '3184440003', '1992-10-05'),
('4004', 'Felipe', 'Esteban', 'Rincón', 'Duarte', 'Masculino', 'felipe.rincon@dbhealth.com', '3184440004', '1989-12-21'),
('4005', 'Tatiana', 'Lorena', 'Bautista', 'Rueda', 'Femenino', 'tatiana.bautista@dbhealth.com', '3184440005', '1996-05-02');

INSERT INTO paciente VALUES
('1001', 'O+', 'Sura EPS', 'Casado'),
('1002', 'A+', 'Sanitas', 'Soltera'),
('1003', 'B+', 'Nueva EPS', 'Casado'),
('1004', 'O-', 'Salud Total', 'Soltera'),
('1005', 'AB+', 'Compensar', 'Unión Libre');

INSERT INTO medico VALUES
('2001', 'RM-10451', 'Lunes a Viernes 07:00 - 13:00'),
('2002', 'RM-10452', 'Lunes a Viernes 13:00 - 19:00'),
('2003', 'RM-10453', 'Martes a Sábado 08:00 - 14:00'),
('2004', 'RM-10454', 'Lunes, Miércoles y Viernes 08:00 - 16:00'),
('2005', 'RM-10455', 'Martes y Jueves 09:00 - 17:00');

INSERT INTO enfermero VALUES
('3001', 'Mañana', 'Urgencias'),
('3002', 'Tarde', 'Consulta Externa'),
('3003', 'Noche', 'Hospitalización'),
('3004', 'Mañana', 'Pediatría'),
('3005', 'Tarde', 'Cirugía');

INSERT INTO personal_administrativo VALUES
('4001', 'Coordinador de Citas', '101'),
('4002', 'Auxiliar de Admisiones', '102'),
('4003', 'Recepcionista Consulta Externa', '103'),
('4004', 'Gestor de Autorizaciones', '104'),
('4005', 'Analista de Archivo Clínico', '105');

INSERT INTO hospital VALUES
('HOS-01', 'Hospital Central DB-Health', '6076301001', 'Alta Complejidad', 'Calle 45 # 27-10'),
('HOS-02', 'Clínica Norte Salud', '6076301002', 'Mediana Complejidad', 'Carrera 15 # 12-40'),
('HOS-03', 'Centro Médico Cabecera', '6076301003', 'Baja Complejidad', 'Calle 52 # 33-18'),
('HOS-04', 'Hospital del Sur', '6076301004', 'Alta Complejidad', 'Avenida Floridablanca # 80-22'),
('HOS-05', 'Unidad Materno Infantil', '6076301005', 'Mediana Complejidad', 'Carrera 27 # 36-50');

INSERT INTO consultorio VALUES
(101, 'HOS-01', 1, 'Disponible'),
(102, 'HOS-01', 1, 'Disponible'),
(201, 'HOS-02', 2, 'Ocupado'),
(301, 'HOS-03', 3, 'Disponible'),
(401, 'HOS-04', 4, 'Mantenimiento');

INSERT INTO especialidad VALUES
('ESP-01', 'Medicina General', 'Atención primaria y diagnóstico general'),
('ESP-02', 'Cardiología', 'Diagnóstico y tratamiento del sistema cardiovascular'),
('ESP-03', 'Pediatría', 'Atención médica integral de niños y adolescentes'),
('ESP-04', 'Medicina Interna', 'Manejo integral de patologías del adulto'),
('ESP-05', 'Dermatología', 'Tratamiento de afecciones de la piel');

INSERT INTO medico_especialidad VALUES
('2001', 'ESP-01'),
('2002', 'ESP-02'),
('2003', 'ESP-04'),
('2004', 'ESP-03'),
('2005', 'ESP-05');

INSERT INTO enfermero_hospital VALUES
('3001', 'HOS-01'),
('3002', 'HOS-01'),
('3003', 'HOS-02'),
('3004', 'HOS-05'),
('3005', 'HOS-04');

INSERT INTO historia_clinica (identificacion_paciente, fecha_apertura, diagnostico_principal, observaciones) VALUES
('1001', '2026-01-10', 'Hipertensión arterial controlada', 'Seguimiento trimestral con cardiología'),
('1002', '2026-02-14', 'Rinitis alérgica estacional', 'Sin antecedentes quirúrgicos relevantes'),
('1003', '2026-03-05', 'Gastritis crónica leve', 'Se recomienda dieta blanda y control'),
('1004', '2026-04-18', 'Migraña sin aura', 'Control con analgésicos según crisis'),
('1005', '2026-05-22', 'Dermatitis atópica', 'Tratamiento tópico dermatológico');

INSERT INTO cita_medica (identificacion_paciente, identificacion_medico, numero_consultorio, identificacion_administrativo, fecha_hora_programada, estado_cita, motivo_consulta) VALUES
('1001', '2002', 101, '4001', '2026-11-23 08:00:00', 'Programada', 'Control de presión arterial'),
('1002', '2001', 102, '4002', '2026-11-23 09:30:00', 'Atendida', 'Congestión nasal persistente'),
('1003', '2003', 201, '4003', '2026-11-24 10:00:00', 'Programada', 'Dolor epigástrico'),
('1004', '2001', 301, '4001', '2026-11-24 11:15:00', 'Atendida', 'Cefalea intensa'),
('1005', '2005', 101, '4004', '2026-11-25 14:00:00', 'Programada', 'Revisión de lesión cutánea');

INSERT INTO medicamento VALUES
('MED-01', 'Losartán', '50 mg', 250, 'Tableta'),
('MED-02', 'Loratadina', '10 mg', 180, 'Tableta'),
('MED-03', 'Omeprazol', '20 mg', 300, 'Cápsula'),
('MED-04', 'Acetaminofén', '500 mg', 500, 'Tableta'),
('MED-05', 'Hidrocortisona', '1%', 95, 'Crema tópica');

INSERT INTO prescripcion_cita_medicamento VALUES
(1, 'MED-01', '1 tableta', 'Cada 24 horas', '30 días'),
(2, 'MED-02', '1 tableta', 'Cada 24 horas', '10 días'),
(3, 'MED-03', '1 cápsula en ayunas', 'Cada 24 horas', '14 días'),
(4, 'MED-04', '1 tableta', 'Cada 8 horas si hay dolor', '5 días'),
(5, 'MED-05', 'Aplicar capa delgada', 'Cada 12 horas', '7 días');

-- ============================================================================
-- ii. Consultas
-- ============================================================================

SELECT 
    cm.consecutivo_cita,
    CONCAT(pp.primer_nombre, ' ', pp.primer_apellido) AS paciente,
    CONCAT(pm.primer_nombre, ' ', pm.primer_apellido) AS medico,
    h.nombre_hospital,
    c.numero_consultorio,
    cm.fecha_hora_programada,
    cm.estado_cita
FROM cita_medica cm
INNER JOIN paciente pa ON cm.identificacion_paciente = pa.identificacion
INNER JOIN persona pp ON pa.identificacion = pp.identificacion
INNER JOIN medico me ON cm.identificacion_medico = me.identificacion
INNER JOIN persona pm ON me.identificacion = pm.identificacion
INNER JOIN consultorio c ON cm.numero_consultorio = c.numero_consultorio
INNER JOIN hospital h ON c.codigo_hospital = h.codigo_hospital
ORDER BY cm.fecha_hora_programada;

SELECT 
    m.identificacion,
    m.registro_medico,
    CONCAT(p.primer_nombre, ' ', p.primer_apellido) AS nombre_medico,
    e.nombre_especialidad,
    m.horario_atencion
FROM medico m
INNER JOIN persona p ON m.identificacion = p.identificacion
INNER JOIN medico_especialidad me ON m.identificacion = me.identificacion_medico
INNER JOIN especialidad e ON me.codigo_especialidad = e.codigo_especialidad;

SELECT estado_cita, COUNT(*) AS total_citas
FROM cita_medica
GROUP BY estado_cita;

SELECT 
    cm.consecutivo_cita,
    CONCAT(p.primer_nombre, ' ', p.primer_apellido) AS paciente,
    m.nombre_comercial,
    m.concentracion,
    pcm.dosis,
    pcm.frecuencia,
    pcm.duracion
FROM prescripcion_cita_medicamento pcm
INNER JOIN cita_medica cm ON pcm.consecutivo_cita = cm.consecutivo_cita
INNER JOIN paciente pa ON cm.identificacion_paciente = pa.identificacion
INNER JOIN persona p ON pa.identificacion = p.identificacion
INNER JOIN medicamento m ON pcm.codigo_medicamento = m.codigo_medicamento;

SELECT 
    id_auditoria, accion, fecha_evento, usuario_bd,
    codigo_hospital_old, codigo_hospital_new,
    nombre_hospital_old, nombre_hospital_new
FROM audit.aud_hospital
ORDER BY fecha_evento DESC;

-- ============================================================================
-- iii. Creación de vistas
-- ============================================================================

CREATE OR REPLACE VIEW vw_agenda_citas AS
SELECT 
    cm.consecutivo_cita,
    cm.fecha_hora_programada,
    cm.estado_cita,
    pa.identificacion AS id_paciente,
    CONCAT(pp.primer_nombre, ' ', pp.primer_apellido) AS nombre_paciente,
    pa.eps_afiliacion,
    me.registro_medico,
    CONCAT(pm.primer_nombre, ' ', pm.primer_apellido) AS nombre_medico,
    h.nombre_hospital,
    c.numero_consultorio,
    cm.motivo_consulta
FROM cita_medica cm
INNER JOIN paciente pa ON cm.identificacion_paciente = pa.identificacion
INNER JOIN persona pp ON pa.identificacion = pp.identificacion
INNER JOIN medico me ON cm.identificacion_medico = me.identificacion
INNER JOIN persona pm ON me.identificacion = pm.identificacion
INNER JOIN consultorio c ON cm.numero_consultorio = c.numero_consultorio
INNER JOIN hospital h ON c.codigo_hospital = h.codigo_hospital;

CREATE OR REPLACE VIEW vw_resumen_pacientes AS
SELECT 
    p.identificacion,
    CONCAT(p.primer_nombre, ' ', p.primer_apellido) AS nombre_completo,
    p.genero,
    p.fecha_nacimiento,
    p.telefono_contacto,
    pa.tipo_sangre,
    pa.eps_afiliacion,
    hc.consecutivo_historia,
    hc.fecha_apertura,
    hc.diagnostico_principal
FROM persona p
INNER JOIN paciente pa ON p.identificacion = pa.identificacion
LEFT JOIN historia_clinica hc ON pa.identificacion = hc.identificacion_paciente;

CREATE OR REPLACE VIEW vw_formulas_medicas AS
SELECT 
    cm.consecutivo_cita,
    cm.fecha_hora_programada,
    CONCAT(p.primer_nombre, ' ', p.primer_apellido) AS paciente,
    m.codigo_medicamento,
    m.nombre_comercial,
    m.concentracion,
    m.forma_farmaceutica,
    pcm.dosis,
    pcm.frecuencia,
    pcm.duracion
FROM prescripcion_cita_medicamento pcm
INNER JOIN cita_medica cm ON pcm.consecutivo_cita = cm.consecutivo_cita
INNER JOIN persona p ON cm.identificacion_paciente = p.identificacion
INNER JOIN medicamento m ON pcm.codigo_medicamento = m.codigo_medicamento;
