SHOW DATABASES;
SHOW TABLES FROM mantenimiento_motos;
SELECT 'propietarios' AS tabla, COUNT(*) AS filas FROM propietarios
UNION ALL SELECT 'motocicletas', COUNT(*) FROM motocicletas
UNION ALL SELECT 'mecanicos', COUNT(*) FROM mecanicos
UNION ALL SELECT 'servicios', COUNT(*) FROM servicios
UNION ALL SELECT 'repuestos', COUNT(*) FROM repuestos
UNION ALL SELECT 'mantenimientos', COUNT(*) FROM mantenimientos
UNION ALL SELECT 'detalle_mantenimiento', COUNT(*) FROM detalle_mantenimiento
UNION ALL SELECT 'repuestos_utilizados', COUNT(*) FROM repuestos_utilizados;
SELECT id_mantenimiento, fecha, costo_total FROM mantenimientos;
SELECT nombre, stock FROM repuestos;

SELECT m.placa, mt.fecha, mt.kilometraje, mc.nombre AS mecanico, mt.costo_total
FROM mantenimientos mt
JOIN motocicletas m ON m.id_motocicleta = mt.id_motocicleta
JOIN mecanicos mc ON mc.id_mecanico = mt.id_mecanico
ORDER BY m.placa, mt.fecha;


SELECT mt.id_mantenimiento, m.placa, r.nombre AS repuesto, u.cantidad,
       u.precio_aplicado, (u.cantidad * u.precio_aplicado) AS subtotal
FROM repuestos_utilizados u
JOIN mantenimientos mt ON mt.id_mantenimiento = u.id_mantenimiento
JOIN motocicletas m ON m.id_motocicleta = mt.id_motocicleta
JOIN repuestos r ON r.id_repuesto = u.id_repuesto;


SELECT p.nombre, SUM(mt.costo_total) AS total_gastado
FROM propietarios p
JOIN motocicletas m ON m.id_propietario = p.id_propietario
JOIN mantenimientos mt ON mt.id_motocicleta = m.id_motocicleta
GROUP BY p.id_propietario, p.nombre;