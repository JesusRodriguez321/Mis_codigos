--- SCRUM - 24 Ejecución de Consultas DDL Básicas---

CREATE TABLE auditoria_inventario (
    id_auditoria SERIAL PRIMARY KEY,
    fecha_modificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    detalle_modificacion TEXT NOT NULL
);
ALTER TABLE auditoria_inventario ADD COLUMN usuario_responsable VARCHAR(100);
ALTER TABLE auditoria_inventario DROP COLUMN usuario_responsable;
DROP TABLE auditoria_inventario;

--- SCRUM - 25 Operaciones DML y Mantenimiento de Datos---

BEGIN; --En caso de fallas (solo lo probe en cmd)

--Apartado 'a.1'

--Comando Insercion de un nuevo proveedor,
INSERT INTO Clientes (rut, nombre, direccion, telefono)
VALUES (
    '76.111.161-1',
    'Cliente Prueba SpA',
    'Av. Prueba 100, Santiago',
    '912345721'
);

--Comando De verificacion
SELECT *
FROM Clientes
WHERE rut = '76.111.161-1';

--Aprtado 'a.2'

--Comando de Insercion de Producto
INSERT INTO Productos (nombre, descripcion, precio, id_categoria)
VALUES (
    'Webcam Full HD',
    'Cámara web Full HD para videollamadas',
    29990,
    2
);

--Comando de verificacion
SELECT *
FROM Productos
WHERE nombre = 'Webcam Full HD'; 

--Aprtado 'b'

--Comando para actualizar stock
UPDATE Inventario
SET cantidad = cantidad + 10
WHERE id_producto = 1
  AND id_ubicacion = 1;

--Comando de verificacion
SELECT 
    i.id_inventario,
    p.nombre AS producto,
    i.id_ubicacion,
    i.cantidad AS stock
FROM Inventario i
JOIN Productos p 
    ON i.id_producto = p.id_producto
WHERE i.id_producto = 1
  AND i.id_ubicacion = 1;

--Aprtado 'c'

--Comando para actualizar contacto
UPDATE Proveedores
SET contacto = 'nuevo.contacto@tecnochile.cl'
WHERE id_proveedor = 1;

--Comando de verificacion
SELECT 
    id_proveedor,
    nombre_empresa,
    contacto
FROM Proveedores
WHERE id_proveedor = 1;

--Aprtado 'd'

--Comando para borrar un dato
DELETE FROM Clientes
WHERE rut = '76.111.161-1';

--Comando de verificacion
SELECT *
FROM Clientes
WHERE rut = '76.111.161-1';

--Aprtado 'e' (ya realizado en cada apartado pero lo dejo como un solo ejecutable por separado)
/*
--cliente
SELECT *
FROM Clientes
WHERE rut = '76.111.161-1';


--producto
SELECT *
FROM Productos
WHERE nombre = 'Webcam Full HD';


--stock
SELECT 
    i.id_inventario,
    p.nombre AS producto,
    i.id_ubicacion,
    i.cantidad AS stock
FROM Inventario i
JOIN Productos p 
    ON i.id_producto = p.id_producto
WHERE i.id_producto = 1
  AND i.id_ubicacion = 1;


--contacto
SELECT 
    id_proveedor,
    nombre_empresa,
    contacto
FROM Proveedores
WHERE id_proveedor = 1;*/

--En caso de fallas quiten los guiones del rollback
--ROLLBACK; 

--- SCRUM - 26 Construcción de Consultas Relacionales y Agrupaciones---

1._Consulta de la lista de las órdenes junto al nombre del cliente
SELECT 
    o.id_orden, 
    o.fecha_orden, 
    o.estado,
    c.nombre AS nombre_cliente
FROM Orden o
JOIN Clientes c ON o.id_cliente = c.id_cliente; 

2._Consulta de detalle de la orden con producto, categoría, cantidad solicitada y valor asociado:
SELECT 
    d.id_orden, 
    p.nombre AS producto, 
    cat.nombre_categoria AS categoria, 
    d.cantidad AS cantidad_solicitada, 
    (d.cantidad * p.precio) AS valor_asociado
FROM DetalleOrden d
JOIN Productos p ON d.id_producto = p.id_producto
JOIN Categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY d.id_orden; 

3._Consulta de la lista de envíos (número de orden, cliente, transportista y empleado)
SELECT 
    e.id_envio, 
    o.id_orden, 
    c.nombre AS cliente, 
    t.nombre_empresa AS transportista, 
    em.nombre_completo AS empleado
FROM Envios e
JOIN Orden o ON e.id_orden = o.id_orden
JOIN Clientes c ON o.id_cliente = c.id_cliente
JOIN Transportistas t ON e.id_transportista = t.id_transportista
JOIN Empleados em ON e.id_empleado = em.id_empleado;
 
4._Consulta del inventario disponible por bodega, ubicación y producto
SELECT 
    b.nombre_bodega AS bodega, 
    u.pasillo, 
    u.estante, 
    p.nombre AS producto, 
    i.cantidad AS stock_disponible
FROM Inventario i
JOIN Ubicaciones u ON i.id_ubicacion = u.id_ubicacion
JOIN Bodegas b ON u.id_bodega = b.id_bodega
JOIN Productos p ON i.id_producto = p.id_producto; 

5._Consulta de identificar productos con stock bajo (Filtro límite: 50 unidades o menos):
SELECT 
    p.nombre AS producto, 
    SUM(i.cantidad) AS stock_total
FROM Inventario i
JOIN Productos p ON i.id_producto = p.id_producto
GROUP BY p.nombre
HAVING SUM(i.cantidad) <= 50
ORDER BY stock_total ASC;

6._Consulta de cantidad total de productos almacenados por bodega:
SELECT 
    b.nombre_bodega AS bodega, 
    SUM(i.cantidad) AS total_productos_almacenados
FROM Inventario i
JOIN Ubicaciones u ON i.id_ubicacion = u.id_ubicacion
JOIN Bodegas b ON u.id_bodega = b.id_bodega
GROUP BY b.nombre_bodega
ORDER BY total_productos_almacenados DESC;

7._Múltiples proveedores asociados a cada producto:
SELECT 
    p.nombre AS producto, 
    pr.nombre_empresa AS proveedor
FROM Productos p
JOIN Producto_Proveedor pp ON p.id_producto = pp.id_producto
JOIN Proveedores pr ON pp.id_proveedor = pr.id_proveedor
ORDER BY p.nombre, pr.nombre_empresa;

--- SCRUM 27 Gestión de Respaldos (Backup/Restore)---

--1._Respaldo base de datos (backup):
-- ejecutar el comando en la terminal de linux (servidor)
pg_dump -h "127.0.0.1" -U "ua_eq02" -d "ua_eq02" -F c -f respaldo_eq02.backup

--2._Crear nueva base de datos respaldada:
-- ejecutar el comando dentro de la terminal psql
CREATE DATABASE eq02_respaldado;

--3._Restaurar respaldo:
-- ejecutar el comando en la terminal de linux (servidor)
pg_restore -h "127.0.0.1" -U "ua_eq02" -d "eq02_respaldado" -1 respaldo_eq02.backup

--4._Verificación final:
--ingresar a la nueva base de datos creada
psql -h "127.0.0.1" -U "ua_eq02" -d "eq02_respaldado"

--5._Prueba en psql:
-- verificar tablas de la base de datos y hacer una consulta
\dt
SELECT * FROM Inventario LIMIT 5;
 
--Consultas TCL 

--TRANSACCION 1 BEGIN + COMMIT

BEGIN;

WITH nueva_orden AS (
    INSERT INTO Orden (
        id_cliente,
        fecha_orden,
        estado
    )
    VALUES (
        1,
        CURRENT_DATE,
        'Pendiente'
    )
    RETURNING id_orden
),
nuevo_detalle AS (

    INSERT INTO DetalleOrden (
        id_orden,
        id_producto,
        cantidad
    )
    SELECT
        id_orden,
        1,
        2
    FROM nueva_orden
)
INSERT INTO Envios (
    id_orden,
    id_transportista,
    id_empleado,
    fecha_despacho,
    estado_envio
)
SELECT
    id_orden,
    1,
    1,
    CURRENT_DATE,
    'Pendiente'
FROM nueva_orden;
COMMIT;
--VERIFICACION TRANSACCION 1
SELECT *
FROM Orden
ORDER BY id_orden DESC
LIMIT 1;

SELECT *
FROM DetalleOrden
ORDER BY id_detalle_orden DESC
LIMIT 1;

SELECT *
FROM Envios
ORDER BY id_envio DESC
LIMIT 1;

        --TRANSACCION 2 BEGIN + ROLLBACK
BEGIN;
INSERT INTO Clientes (
    rut,
    nombre,
    direccion,
    telefono
)
VALUES (
    '11.839.292-2',
    'ATTLA',
    'Alamos 972',
    '940988972'
);
--Verifica que el cliente existe dentro de la transaccion 
SELECT *
FROM Clientes
WHERE rut = '11.839.292-2';

--Cancela todos los cambios realizados
ROLLBACK;

--Verifica que el cliente ya no existe
SELECT *
FROM Clientes
WHERE rut = '11.839.292-2';

         --TRANSACCION 3 BEGIN + SAVEPOINT + ROLLBACK TO SAVEPOINT + COMMIT
BEGIN;


--Muestra la cantidad inicial
SELECT *
FROM Inventario
WHERE id_inventario = 1;


--Primer cambio (se conserva)
UPDATE Inventario
SET cantidad = cantidad - 2
WHERE id_inventario = 1;


--punto de guardado
SAVEPOINT punto_inventario;


--Segundo cambio (sera eliminado)
UPDATE Inventario
SET cantidad = cantidad - 5
WHERE id_inventario = 1;

--Resultado
SELECT *
FROM Inventario
WHERE id_inventario = 1;


--vuelve al punto de guardado
ROLLBACK TO SAVEPOINT punto_inventario;


--Verifica que se deshizo el segundo cambio 
SELECT *
FROM Inventario
WHERE id_inventario = 1;

--Guarda definitivamente el primer cambio
COMMIT;


--VERIFICACION FINAL
SELECT *
FROM Inventario
WHERE id_inventario = 1;
