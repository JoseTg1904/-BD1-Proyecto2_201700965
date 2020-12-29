#utilizando la base de datos para el enunciado 1
USE enunciado1Proyecto2;

/*Para la carga del csv se debe de mover dicho csv hacia la carpeta segura
la ruta en cual se debe de mover este archivo se visualiza con el comando 
SHOW VARIABLES LIKE "secure_file_priv";
*/
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Enunciado1.csv'
INTO TABLE Temporal
COLUMNS TERMINATED BY ';' LINES TERMINATED BY '\n' IGNORE 1 LINES 
(nombre_compania, contacto_compania, correo_compania, telefono_compania,
tipo, nombre, correo, telefono, @fecha_registro, direccion, ciudad, codigo_postal, 
region, producto, categoria_producto, cantidad, precio_unitario)
SET fecha_registro = STR_TO_DATE(@fecha_registro, "%d/%m/%Y");

#carga de datos a tablas sin dependencias
INSERT INTO TipoPersona (tipoPersona) 
SELECT DISTINCT tipo FROM Temporal;

INSERT INTO Region (region)
SELECT DISTINCT region FROM Temporal;

INSERT INTO CodigoPostal (codigoPostal)
SELECT DISTINCT codigo_postal FROM Temporal;

INSERT INTO TipoProducto (tipoProducto)
SELECT DISTINCT categoria_producto FROM Temporal;

INSERT INTO Compania (nombre, contacto, correo, telefono)
SELECT DISTINCT nombre_compania, contacto_compania, correo_compania, telefono_compania
FROM Temporal;

#carga de datos a tablas con dependencia
INSERT INTO Ciudad (ciudad, ID_Region)
SELECT DISTINCT ciudad, 
(SELECT ID_Region FROM Region WHERE Region.region = Temporal.region)
FROM Temporal;

INSERT INTO Persona (nombre, correo, telefono, fechaRegistro, direccion, 
ID_CodigoPostal, ID_Ciudad, ID_TipoPersona)
SELECT DISTINCT nombre, correo, telefono, fecha_registro, direccion,
(SELECT ID_CodigoPostal FROM CodigoPostal WHERE codigoPostal = codigo_postal),
(SELECT ID_Ciudad FROM Ciudad WHERE Ciudad.ciudad = Temporal.ciudad),
(SELECT ID_TipoPersona FROM TipoPersona WHERE tipoPersona = tipo)
FROM Temporal;

INSERT INTO Producto (nombre, precio, ID_TipoProducto)
SELECT DISTINCT producto, precio_unitario,
(SELECT ID_TipoProducto FROM TipoProducto WHERE tipoProducto = categoria_producto)
FROM Temporal;

INSERT INTO Transaccion (ID_Compania, ID_Persona)
SELECT DISTINCT 
(SELECT ID_Compania FROM Compania WHERE Compania.nombre = Temporal.nombre_compania),
(SELECT ID_Persona FROM Persona WHERE Persona.nombre = Temporal.nombre)
FROM Temporal;

INSERT INTO DetalleTransaccion (cantidad, ID_Compania, ID_Persona, ID_Producto)
SELECT cantidad,
(SELECT ID_Compania FROM Compania WHERE Compania.nombre = Temporal.nombre_compania),
(SELECT ID_Persona FROM Persona WHERE Persona.nombre = Temporal.nombre),
(SELECT ID_Producto FROM Producto WHERE Producto.nombre = Temporal.producto)
FROM Temporal;