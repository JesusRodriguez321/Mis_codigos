--Tablas normales

CREATE TABLE Clientes (
    id_cliente SERIAL PRIMARY KEY,
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200),
    telefono VARCHAR(15)
);

CREATE TABLE Categorias(
    id_categoria SERIAL PRIMARY KEY,
    nombre_categoria VARCHAR(50) NOT NULL
);

CREATE TABLE Bodegas(
    id_bodega SERIAL PRIMARY KEY,
    nombre_bodega VARCHAR(100) NOT NULL,
    direccion VARCHAR(200)
);

CREATE TABLE Transportistas(
    id_transportista SERIAL PRIMARY KEY,
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre_empresa VARCHAR(100) NOT NULL
);

CREATE TABLE Empleados(
    id_empleado SERIAL PRIMARY KEY,
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre_completo VARCHAR(100) NOT NULL,
    cargo VARCHAR(50)
);

CREATE TABLE Proveedores (
    id_proveedor SERIAL PRIMARY KEY,
    rut VARCHAR(12) NOT NULL UNIQUE,
    nombre_empresa VARCHAR(100) NOT NULL
);

-- Tablas con relaciones (john FKs)

CREATE TABLE Productos(
    id_producto SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio INT,
    id_categoria INT,
    CONSTRAINT fk_productos_categoria FOREIGN KEY (id_categoria) REFERENCES Categorias(id_categoria)
);

CREATE TABLE Producto_Proveedor(
    id_producto INT,
    id_proveedor INT,
    PRIMARY KEY (id_producto, id_proveedor),
    CONSTRAINT fk_pp_producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    CONSTRAINT fk_pp_proveedor FOREIGN KEY (id_proveedor) REFERENCES Proveedores(id_proveedor)
);

CREATE TABLE Orden(
    id_orden SERIAL PRIMARY KEY,
    id_cliente INT,
    fecha_orden DATE,
    estado VARCHAR(50),
    CONSTRAINT fk_orden_cliente FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente)
);

CREATE TABLE Ubicaciones(
    id_ubicacion SERIAL PRIMARY KEY,
    id_bodega INT,
    pasillo VARCHAR(10),
    estante VARCHAR(10),
    CONSTRAINT fk_ubicaciones_bodega FOREIGN KEY (id_bodega) REFERENCES Bodegas(id_bodega)
);

CREATE TABLE DetalleOrden(
    id_detalle_orden SERIAL PRIMARY KEY,
    id_orden INT,
    id_producto INT,
    cantidad INT NOT NULL, 
    CONSTRAINT fk_detalleorden_orden FOREIGN KEY (id_orden) REFERENCES Orden(id_orden),
    CONSTRAINT fk_detalleorden_producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto)
);

CREATE TABLE Inventario(
    id_inventario SERIAL PRIMARY KEY,
    id_producto INT,
    id_ubicacion INT,
    cantidad INT NOT NULL CHECK (cantidad >= 0),
    CONSTRAINT fk_inventario_producto FOREIGN KEY (id_producto) REFERENCES Productos(id_producto),
    CONSTRAINT fk_inventario_ubicacion FOREIGN KEY (id_ubicacion) REFERENCES Ubicaciones(id_ubicacion)
);

CREATE TABLE Envios(
    id_envio SERIAL PRIMARY KEY,
    id_orden INT,
    id_transportista INT,
    id_empleado INT,
    fecha_despacho DATE,
    estado_envio VARCHAR(50),
    CONSTRAINT fk_envios_orden FOREIGN KEY (id_orden) REFERENCES Orden(id_orden),
    CONSTRAINT fk_envios_transportista FOREIGN KEY (id_transportista) REFERENCES Transportistas(id_transportista),
    CONSTRAINT fk_envios_empleado FOREIGN KEY (id_empleado) REFERENCES Empleados(id_empleado)
