-- 1. Crear tipos ENUM
CREATE TYPE estado_asistencia AS ENUM ('presente', 'ausente', 'tardanza');
CREATE TYPE estado_pago AS ENUM ('pendiente', 'completado', 'cancelado');
CREATE TYPE roles_usuario AS ENUM ('alumno', 'profesor', 'apoderado', 'administrativo');

-- 2. Tabla usuarios (base para todos los roles)
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(150) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL CHECK (fecha_nacimiento < CURRENT_DATE),
    tipo_documento VARCHAR(20) NOT NULL,
    numero_doc VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    telefono VARCHAR(15),
    password_hash TEXT NOT NULL,
    rol roles_usuario NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP
);

-- 3. Tabla alumnos (hereda de usuarios)
CREATE TABLE alumnos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    codigo_alumno VARCHAR(20) NOT NULL UNIQUE,
    fecha_ingreso DATE NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 4. Tabla apoderados
CREATE TABLE apoderados (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 5. Relación alumno-apoderado (un alumno puede tener varios apoderados)
CREATE TABLE alumno_apoderado (
    alumno_id INT REFERENCES alumnos(id) ON DELETE CASCADE,
    apoderado_id INT REFERENCES apoderados(id) ON DELETE CASCADE,
    relacion VARCHAR(50) NOT NULL,
    PRIMARY KEY (alumno_id, apoderado_id)
);

-- 6. Tabla profesores
CREATE TABLE profesores (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    especialidad VARCHAR(100) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 7. Tabla administrativos
CREATE TABLE administrativos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    cargo VARCHAR(100) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 8. Tabla cursos
CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    nivel VARCHAR(50) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

-- 9. Tabla horarios (relación curso-profesor)
CREATE TABLE horarios (
    id SERIAL PRIMARY KEY,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    profesor_id INT NOT NULL REFERENCES profesores(id) ON DELETE CASCADE,
    dia VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    UNIQUE (curso_id, dia, hora_inicio) -- Evita horarios solapados
);

-- 10. Tabla matriculas (con restricción única)
CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    fecha_matricula TIMESTAMP DEFAULT NOW(),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE (alumno_id, curso_id) -- Evita matrículas duplicadas
);

-- 11. Tabla notas
CREATE TABLE notas (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    profesor_id INT NOT NULL REFERENCES profesores(id) ON DELETE CASCADE,
    nota DECIMAL(5,2) NOT NULL CHECK (nota BETWEEN 0 AND 20),
    fecha_registro TIMESTAMP DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP
);

-- 12. Tabla asistencias (con ENUM)
CREATE TABLE asistencias (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    fecha DATE NOT NULL,
    estado estado_asistencia NOT NULL,
    UNIQUE (alumno_id, curso_id, fecha) -- Una asistencia por día
);

-- 13. Tabla pagos (ampliada)
CREATE TABLE pagos (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    monto DECIMAL(10,2) NOT NULL CHECK (monto > 0),
    concepto VARCHAR(100) NOT NULL,
    metodo_pago VARCHAR(50),
    estado estado_pago NOT NULL DEFAULT 'pendiente',
    fecha_pago TIMESTAMP,
    fecha_registro TIMESTAMP DEFAULT NOW()
);

-- 14. Tabla reportes (con almacenamiento flexible)
CREATE TABLE reportes (
    id SERIAL PRIMARY KEY,
    administrativo_id INT NOT NULL REFERENCES administrativos(id) ON DELETE CASCADE,
    tipo_reporte VARCHAR(50) NOT NULL,
    contenido JSONB,
    archivo_ruta VARCHAR(255),
    fecha_generacion TIMESTAMP DEFAULT NOW()
);

-- 15. Índices para optimización
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_alumnos_codigo ON alumnos(codigo_alumno);
CREATE INDEX idx_asistencias_fecha ON asistencias(fecha);
CREATE INDEX idx_pagos_estado ON pagos(estado);

-- 16. Trigger para actualizar fechas automáticamente
CREATE OR REPLACE FUNCTION actualizar_fecha()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Aplicar trigger a todas las tablas con fecha_actualizacion
DO $$
DECLARE
    tabla RECORD;
BEGIN
    FOR tabla IN (
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'fecha_actualizacion'
    ) LOOP
        EXECUTE format('
            CREATE TRIGGER %s_actualizacion
            BEFORE UPDATE ON %s
            FOR EACH ROW EXECUTE FUNCTION actualizar_fecha()',
            tabla.table_name, tabla.table_name);
    END LOOP;
END $$;