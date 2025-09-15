-- Crear base de datos
CREATE DATABASE veterinarias_popayan;
\c veterinarias_popayan;

-- TABLAS
-- Tabla de veterinarias
CREATE TABLE veterinarias (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(20),
    horario_atencion VARCHAR(100)
);

-- Tabla de procedimientos
CREATE TABLE procedimientos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT
);

-- Relación muchos a muchos: veterinarias - procedimientos
CREATE TABLE veterinaria_procedimientos (
    id_veterinaria INT REFERENCES veterinarias(id),
    id_procedimiento INT REFERENCES procedimientos(id),
    PRIMARY KEY (id_veterinaria, id_procedimiento)
);

-- Tabla de pacientes (mascotas)
CREATE TABLE pacientes (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    especie VARCHAR(50),   -- perro, gato, conejo, etc.
    raza VARCHAR(100),
    edad INT,
    propietario VARCHAR(100)
);

-- Tabla de citas
CREATE TABLE citas (
    id SERIAL PRIMARY KEY,
    id_paciente INT REFERENCES pacientes(id),
    id_veterinaria INT REFERENCES veterinarias(id),
    id_procedimiento INT REFERENCES procedimientos(id),
    fecha DATE NOT NULL,
    observaciones TEXT
);

-- INSERTS
-- Veterinarias
INSERT INTO veterinarias (nombre, direccion, telefono, horario_atencion) VALUES
('VetCare Popayán', 'Cra 9 #12-34, Popayán', '3124567890', 'Lunes a Sábado 8:00am - 6:00pm'),
('Amigos Peludos', 'Calle 5 #8-22, Popayán', '3187654321', 'Lunes a Domingo 9:00am - 8:00pm'),
('Clínica AnimalVida', 'Av. Panamericana #45-10, Popayán', '3209988776', '24 horas');

-- Procedimientos
INSERT INTO procedimientos (nombre, descripcion) VALUES
('Consulta general', 'Revisión médica básica'),
('Vacunación', 'Aplicación de vacunas según especie y edad'),
('Corte de uñas', 'Corte y limpieza de uñas'),
('Esterilización', 'Cirugía de esterilización de perros y gatos'),
('Radiografía', 'Estudios radiográficos'),
('Ecografía', 'Estudios ecográficos'),
('Cirugía mayor', 'Operaciones complejas'),
('Parto asistido', 'Atención de parto para perros/gatos'),
('Venta de alimentos', 'Alimentos especializados para mascotas');

-- Relación veterinarias - procedimientos
INSERT INTO veterinaria_procedimientos VALUES
(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(1,7),(1,9),  -- VetCare Popayán
(2,1),(2,2),(2,3),(2,9),                          -- Amigos Peludos
(3,1),(3,2),(3,4),(3,5),(3,6),(3,7),(3,8);        -- Clínica AnimalVida

-- Pacientes
INSERT INTO pacientes (nombre, especie, raza, edad, propietario) VALUES
('Firulais', 'Perro', 'Criollo', 5, 'Juan Pérez'),
('Misu', 'Gato', 'Siames', 3, 'Ana Gómez'),
('Rocky', 'Perro', 'Pitbull', 2, 'Carlos Ruiz'),
('Luna', 'Perro', 'Golden Retriever', 1, 'Sofía Morales');

-- Citas
INSERT INTO citas (id_paciente, id_veterinaria, id_procedimiento, fecha, observaciones) VALUES
(1, 1, 2, '2025-08-20', 'Aplicación de vacuna antirrábica.'),
(2, 2, 3, '2025-08-22', 'Corte de uñas, paciente inquieto pero sin complicaciones.'),
(3, 3, 5, '2025-08-25', 'Radiografía por cojera, posible fractura.'),
(4, 3, 8, '2025-08-28', 'Parto asistido, nacieron 6 cachorros sanos.');



-- CONSULTAS
-- consulttar las veterinarias que hay
SELECT nombre, direccion, telefono, horario_atencion
FROM veterinarias;

-- procedimientos que ofrec cada vaterinaria
SELECT v.nombre AS veterinaria, p.nombre AS procedimiento
FROM veterinarias v
JOIN veterinaria_procedimientos vp ON v.id = vp.id_veterinaria
JOIN procedimientos p ON vp.id_procedimiento = p.id
ORDER BY v.nombre;

-- V que hacen parto asistido
SELECT v.nombre, v.telefono, v.horario_atencion
FROM veterinarias v
JOIN veterinaria_procedimientos vp ON v.id = vp.id_veterinaria
JOIN procedimientos p ON vp.id_procedimiento = p.id
WHERE p.nombre = 'Parto asistido';

-- v que atienden 24h
SELECT nombre, direccion, telefono
FROM veterinarias
WHERE horario_atencion ILIKE '%24 horas%';


-- TRIGGER
-- Tabla para historial de citas
CREATE TABLE historial_citas (
    id SERIAL PRIMARY KEY,
    id_cita INT,
    accion VARCHAR(50),
    fecha_registro TIMESTAMP DEFAULT NOW()
);

-- funcion trigger 
CREATE OR REPLACE FUNCTION log_cita()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO historial_citas (id_cita, accion)
    VALUES (NEW.id, 'Cita creada');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
CREATE TRIGGER trigger_log_cita
AFTER INSERT ON citas
FOR EACH ROW
EXECUTE FUNCTION log_cita();


-- PROCEDIMIENTOS
-- Procedimiento para registrar una nueva cita
CREATE OR REPLACE PROCEDURE registrar_cita(
    p_id_paciente INT,
    p_id_veterinaria INT,
    p_id_procedimiento INT,
    p_fecha DATE,
    p_observaciones TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO citas (id_paciente, id_veterinaria, id_procedimiento, fecha, observaciones)
    VALUES (p_id_paciente, p_id_veterinaria, p_id_procedimiento, p_fecha, p_observaciones);

    RAISE NOTICE 'Cita registrada correctamente para el paciente %', p_id_paciente;
END;
$$;
-- Ejemplo del uso
CALL registrar_cita(1, 2, 3, '2025-09-20', 'Corte de uñas programado.'); --se le registra citas al paciente 1 de corte de uñas


-- Procedimiento para actualizar edad de paciente
CREATE OR REPLACE PROCEDURE actualizar_edad_paciente(
    p_id_paciente INT,
    p_nueva_edad INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE pacientes
    SET edad = p_nueva_edad
    WHERE id = p_id_paciente;

    IF NOT FOUND THEN
        RAISE NOTICE 'No se encontró el paciente con id %', p_id_paciente;
    ELSE
        RAISE NOTICE 'Edad del paciente % actualizada a % años', p_id_paciente, p_nueva_edad;
    END IF;
END;
$$;
-- Eemplo del uso
CALL actualizar_edad_paciente(2, 4); --al paciente 2 cambia la edad a 4años
