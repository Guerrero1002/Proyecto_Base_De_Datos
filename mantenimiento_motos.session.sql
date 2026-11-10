-- =====================================================
-- Sistema de Gestión de Mantenimiento de Motocicletas
-- Base de datos: mantenimiento_motos  |  Gestor: MySQL 8
-- =====================================================


DROP DATABASE IF EXISTS mantenimiento_motos;
CREATE DATABASE mantenimiento_motos
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE mantenimiento_motos;

-- -----------------------------------------------------
-- 1. TABLAS
-- -----------------------------------------------------

CREATE TABLE propietarios (
    id_propietario INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(100) NOT NULL,
    cedula         VARCHAR(20)  NOT NULL UNIQUE,
    telefono       VARCHAR(15),
    direccion      VARCHAR(100),
    correo         VARCHAR(100)
);

CREATE TABLE motocicletas (
    id_motocicleta INT AUTO_INCREMENT PRIMARY KEY,
    id_propietario INT NOT NULL,
    placa          VARCHAR(10) NOT NULL UNIQUE,
    marca          VARCHAR(50) NOT NULL,
    modelo         VARCHAR(50) NOT NULL,
    anio           INT,
    color          VARCHAR(30),
    CONSTRAINT fk_moto_propietario FOREIGN KEY (id_propietario)
        REFERENCES propietarios (id_propietario)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE mecanicos (
    id_mecanico  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    cedula       VARCHAR(20)  NOT NULL UNIQUE,
    telefono     VARCHAR(15),
    especialidad VARCHAR(50)
);

CREATE TABLE servicios (
    id_servicio INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio      DECIMAL(10,2) NOT NULL CHECK (precio >= 0)
);

CREATE TABLE repuestos (
    id_repuesto INT AUTO_INCREMENT PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    descripcion TEXT,
    stock       INT NOT NULL DEFAULT 0 CHECK (stock >= 0),
    precio      DECIMAL(10,2) NOT NULL CHECK (precio >= 0)
);

CREATE TABLE mantenimientos (
    id_mantenimiento INT AUTO_INCREMENT PRIMARY KEY,
    id_motocicleta   INT NOT NULL,
    id_mecanico      INT NOT NULL,
    fecha            DATE NOT NULL,
    kilometraje      INT,
    observaciones    TEXT,
    costo_total      DECIMAL(10,2) NOT NULL DEFAULT 0,
    CONSTRAINT fk_mant_moto FOREIGN KEY (id_motocicleta)
        REFERENCES motocicletas (id_motocicleta)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_mant_mecanico FOREIGN KEY (id_mecanico)
        REFERENCES mecanicos (id_mecanico)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE detalle_mantenimiento (
    id_detalle       INT AUTO_INCREMENT PRIMARY KEY,
    id_mantenimiento INT NOT NULL,
    id_servicio      INT NOT NULL,
    precio_aplicado  DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_det_mant FOREIGN KEY (id_mantenimiento)
        REFERENCES mantenimientos (id_mantenimiento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_det_serv FOREIGN KEY (id_servicio)
        REFERENCES servicios (id_servicio)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE repuestos_utilizados (
    id_uso           INT AUTO_INCREMENT PRIMARY KEY,
    id_mantenimiento INT NOT NULL,
    id_repuesto      INT NOT NULL,
    cantidad         INT NOT NULL CHECK (cantidad > 0),
    precio_aplicado  DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_uso_mant FOREIGN KEY (id_mantenimiento)
        REFERENCES mantenimientos (id_mantenimiento)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_uso_rep FOREIGN KEY (id_repuesto)
        REFERENCES repuestos (id_repuesto)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- -----------------------------------------------------
-- 2. DATOS DE EJEMPLO
-- -----------------------------------------------------

INSERT INTO propietarios (nombre, cedula, telefono, direccion, correo) VALUES
('Juan Pérez',   '1100000001', '0991111111', 'Loja, Av. Universitaria', 'juan.perez@correo.com'),
('María López',  '1100000002', '0992222222', 'Loja, Calle Bolívar',     'maria.lopez@correo.com'),
('Pedro Ramírez','1100000003', '0993333333', 'Loja, Barrio San Sebastián', 'pedro.ramirez@correo.com');

INSERT INTO motocicletas (id_propietario, placa, marca, modelo, anio, color) VALUES
(1, 'ABC-123', 'KTM',    'RC 200',  2022, 'Naranja'),
(1, 'DEF-456', 'Honda',  'CB 125',  2020, 'Rojo'),
(2, 'GHI-789', 'Yamaha', 'FZ 150',  2021, 'Negro'),
(3, 'JKL-012', 'Suzuki', 'Gixxer',  2023, 'Azul');

INSERT INTO mecanicos (nombre, cedula, telefono, especialidad) VALUES
('Carlos Gómez',  '1100000101', '0984444444', 'Motor'),
('Luis Torres',   '1100000102', '0985555555', 'Sistema eléctrico'),
('Ana Vega',      '1100000103', '0986666666', 'Frenos y suspensión');

INSERT INTO servicios (nombre, descripcion, precio) VALUES
('Cambio de aceite',      'Cambio de aceite de motor y revisión de nivel',    10.00),
('Ajuste de frenos',      'Revisión y ajuste del sistema de frenos',          12.00),
('Cambio de cadena',      'Reemplazo y lubricación de cadena de transmisión', 15.00),
('Revisión eléctrica',    'Diagnóstico de batería, luces y encendido',        18.00);

INSERT INTO repuestos (nombre, descripcion, stock, precio) VALUES
('Aceite de motor',   'Aceite 20W-50 1 litro',      40, 15.00),
('Pastillas de freno','Juego de pastillas delanteras', 25, 20.00),
('Cadena de transmisión','Cadena 428H',              10, 35.00),
('Bujía',             'Bujía estándar',              30,  6.00);

-- Mantenimiento 1: ejemplo del informe (cambio de aceite + aceite de motor)
INSERT INTO mantenimientos (id_motocicleta, id_mecanico, fecha, kilometraje, observaciones, costo_total) VALUES
(1, 1, '2026-10-05', 12500, 'Cambio de aceite de rutina', 0),
(3, 3, '2026-10-12',  8300, 'Frenos con desgaste',        0),
(4, 2, '2026-10-20',  3100, 'Falla en el encendido',      0);

INSERT INTO detalle_mantenimiento (id_mantenimiento, id_servicio, precio_aplicado) VALUES
(1, 1, 10.00),
(2, 2, 12.00),
(3, 4, 18.00);

INSERT INTO repuestos_utilizados (id_mantenimiento, id_repuesto, cantidad, precio_aplicado) VALUES
(1, 1, 1, 15.00),
(2, 2, 1, 20.00),
(3, 4, 1,  6.00);

-- Calcula el costo total de cada mantenimiento (servicios + repuestos)
UPDATE mantenimientos m
SET costo_total =
    COALESCE((SELECT SUM(d.precio_aplicado) FROM detalle_mantenimiento d
              WHERE d.id_mantenimiento = m.id_mantenimiento), 0)
  + COALESCE((SELECT SUM(u.cantidad * u.precio_aplicado) FROM repuestos_utilizados u
              WHERE u.id_mantenimiento = m.id_mantenimiento), 0);

-- Descuenta del stock los repuestos utilizados
UPDATE repuestos r
JOIN (SELECT id_repuesto, SUM(cantidad) AS usado
      FROM repuestos_utilizados GROUP BY id_repuesto) x
  ON x.id_repuesto = r.id_repuesto
SET r.stock = r.stock - x.usado;

-- -----------------------------------------------------
-- 3. CONSULTAS
-- -----------------------------------------------------

-- 3.1 Motocicletas con su propietario
SELECT m.placa, m.marca, m.modelo, p.nombre AS propietario
FROM motocicletas m
JOIN propietarios p ON p.id_propietario = m.id_propietario;

-- 3.2 Historial de mantenimiento por motocicleta
SELECT m.placa, mt.fecha, mt.kilometraje, mc.nombre AS mecanico, mt.costo_total
FROM mantenimientos mt
JOIN motocicletas m ON m.id_motocicleta = mt.id_motocicleta
JOIN mecanicos mc   ON mc.id_mecanico   = mt.id_mecanico
ORDER BY m.placa, mt.fecha;

-- 3.3 Servicios realizados en cada mantenimiento
SELECT mt.id_mantenimiento, m.placa, s.nombre AS servicio, d.precio_aplicado
FROM detalle_mantenimiento d
JOIN mantenimientos mt ON mt.id_mantenimiento = d.id_mantenimiento
JOIN motocicletas m    ON m.id_motocicleta    = mt.id_motocicleta
JOIN servicios s       ON s.id_servicio       = d.id_servicio;

-- 3.4 Repuestos utilizados en cada mantenimiento
SELECT mt.id_mantenimiento, m.placa, r.nombre AS repuesto, u.cantidad,
       u.precio_aplicado, (u.cantidad * u.precio_aplicado) AS subtotal
FROM repuestos_utilizados u
JOIN mantenimientos mt ON mt.id_mantenimiento = u.id_mantenimiento
JOIN motocicletas m    ON m.id_motocicleta    = mt.id_motocicleta
JOIN repuestos r       ON r.id_repuesto       = u.id_repuesto;

-- 3.5 Repuestos con stock bajo (menos de 15 unidades)
SELECT nombre, stock FROM repuestos WHERE stock < 15 ORDER BY stock;

-- 3.6 Cantidad de mantenimientos por mecánico
SELECT mc.nombre, COUNT(mt.id_mantenimiento) AS total_mantenimientos
FROM mecanicos mc
LEFT JOIN mantenimientos mt ON mt.id_mecanico = mc.id_mecanico
GROUP BY mc.id_mecanico, mc.nombre;

-- 3.6 Total gastado por propietario
SELECT p.nombre, SUM(mt.costo_total) AS total_gastado
FROM propietarios p
JOIN motocicletas m   ON m.id_propietario = p.id_propietario
JOIN mantenimientos mt ON mt.id_motocicleta = m.id_motocicleta
GROUP BY p.id_propietario, p.nombre;