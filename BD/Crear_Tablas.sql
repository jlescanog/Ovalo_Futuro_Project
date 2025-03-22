-- 1. Creación de la tabla usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombres VARCHAR(150) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    tipo_documento VARCHAR(20) NOT NULL,
    numero_doc VARCHAR(20) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    telefono VARCHAR(15),
    password_hash TEXT NOT NULL,
    rol VARCHAR(50) NOT NULL,
    fecha_creacion TIMESTAMP DEFAULT now(),
    fecha_actualizacion TIMESTAMP
);

-- Índices adicionales para mejorar rendimiento
CREATE INDEX idx_usuarios_email ON usuarios(email);
CREATE INDEX idx_usuarios_numero_doc ON usuarios(numero_doc);

-- 2. Creación de la tabla alumnos
CREATE TABLE alumnos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    codigo_alumno VARCHAR(20) NOT NULL UNIQUE,
    fecha_ingreso DATE NOT NULL
);

-- 3. Creación de la tabla apoderados
CREATE TABLE apoderados (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    relacion VARCHAR(50) NOT NULL
);

-- 4. Creación de la tabla profesores
CREATE TABLE profesores (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    especialidad VARCHAR(100) NOT NULL
);

-- 5. Creación de la tabla administrativos
CREATE TABLE administrativos (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
    cargo VARCHAR(100) NOT NULL
);

-- 6. Creación de la tabla cursos
CREATE TABLE cursos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    nivel VARCHAR(50) NOT NULL
);

-- 7. Creación de la tabla horarios
CREATE TABLE horarios (
    id SERIAL PRIMARY KEY,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    profesor_id INT NOT NULL REFERENCES profesores(id) ON DELETE CASCADE,
    dia VARCHAR(20) NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL
);

-- 8. Creación de la tabla matriculas
CREATE TABLE matriculas (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    fecha_matricula TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_matriculas_fecha ON matriculas(fecha_matricula);

-- 9. Creación de la tabla notas
CREATE TABLE notas (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    profesor_id INT NOT NULL REFERENCES profesores(id) ON DELETE CASCADE,
    nota DECIMAL(5,2) NOT NULL,
    fecha_registro TIMESTAMP DEFAULT now(),
    fecha_actualizacion TIMESTAMP
);

-- 10. Creación de la tabla asistencias
CREATE TABLE asistencias (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    curso_id INT NOT NULL REFERENCES cursos(id) ON DELETE CASCADE,
    fecha DATE NOT NULL,
    estado VARCHAR(20) NOT NULL
);

-- 11. Creación de la tabla pagos
CREATE TABLE pagos (
    id SERIAL PRIMARY KEY,
    alumno_id INT NOT NULL REFERENCES alumnos(id) ON DELETE CASCADE,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago TIMESTAMP DEFAULT now(),
    fecha_registro TIMESTAMP DEFAULT now()
);

-- 12. Creación de la tabla reportes
CREATE TABLE reportes (
    id SERIAL PRIMARY KEY,
    administrativo_id INT NOT NULL REFERENCES administrativos(id) ON DELETE CASCADE,
    tipo_reporte VARCHAR(50) NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT now()
);
