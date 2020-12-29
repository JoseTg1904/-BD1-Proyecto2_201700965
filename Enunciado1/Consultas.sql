#Consulta 1
/* Substring_index es similar a un split, 
donde el primer parametro indica el texto a dividir,
el segundo el delimitador y el tercero desde donde empieza y
la cantidad de veces que se acepta la aparicion del delimitador
donde un numero positivo es izquierda->derecha y 
negativo derecha->izquierda */
SELECT 	Persona.ID_Persona AS ID_Cliente,
SUBSTRING_INDEX(Persona.nombre, " ", 1) AS Nombre_Cliente,
SUBSTRING_INDEX(Persona.nombre, " ", -1) AS Apellido_Cliente,
SUM(DetalleTransaccion.cantidad) AS Total_Productos
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
WHERE TipoPersona.tipoPersona = "C"
GROUP BY DetalleTransaccion.ID_Persona
ORDER BY Total_Productos DESC
LIMIT 1;

#Consulta 2
#month obtiene solo el mes de una fecha que tiene por parametro
(SELECT MONTH(Persona.fechaRegistro) AS Mes_Registro,
SUBSTRING_INDEX(Persona.nombre, " ", 1) AS Nombre_Cliente,
SUBSTRING_INDEX(Persona.nombre, " ", -1) AS Apellido_Cliente,
SUM(DetalleTransaccion.cantidad * Producto.precio) AS Total
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
WHERE TipoPersona.tipoPersona = "C"
GROUP BY DetalleTransaccion.ID_Persona
ORDER BY Total DESC
LIMIT 3)
UNION ALL
(SELECT MONTH(Persona.fechaRegistro) AS Mes_Registro,
SUBSTRING_INDEX(Persona.nombre, " ", 1) AS Nombre_Cliente,
SUBSTRING_INDEX(Persona.nombre, " ", -1) AS Apellido_Cliente,
SUM(DetalleTransaccion.cantidad * Producto.precio) AS Total
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
WHERE TipoPersona.tipoPersona = "C"
GROUP BY DetalleTransaccion.ID_Persona
ORDER BY Total ASC
LIMIT 3);

#consulta 3
SELECT Persona.nombre AS Nombre_Proveedor,
Persona.ID_Persona AS ID_Proveedor,
sum(DetalleTransaccion.cantidad * Producto.precio) AS Total
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
INNER JOIN TipoProducto ON TipoProducto.ID_TipoProducto = Producto.ID_TipoProducto
WHERE TipoPersona.tipoPersona = "P" AND TipoProducto.tipoProducto LIKE "Fresh Vegetables"
GROUP BY DetalleTransaccion.ID_Persona
ORDER BY Total DESC
LIMIT 5;

#consulta 4
/* concat_ws sirve para concatenar campos,
el primer parametro es el texto que se utilizara para unir los campos
y puede tener n campos a concatenar */
SELECT Persona.nombre AS Nombre_Proveedor,
Persona.telefono AS Telefono_Proveedor,
CONCAT_WS("", DetalleTransaccion.ID_Compania, DetalleTransaccion.ID_Persona) AS No_Orden,
SUM(DetalleTransaccion.cantidad) AS Total
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
WHERE TipoPersona.tipoPersona = "P"
GROUP BY DetalleTransaccion.ID_Persona
ORDER BY Total;

#Consulta 5
SELECT Persona.ID_Persona AS ID_Cliente,
Persona.nombre AS Nombre_Cliente,
SUM(DetalleTransaccion.cantidad) AS Total_Productos
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
INNER JOIN TipoProducto ON TipoProducto.ID_TipoProducto = Producto.ID_TipoProducto
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
WHERE TipoPersona.tipoPersona = "C" AND TipoProducto.tipoProducto LIKE "Seafood"
GROUP BY DetalleTransaccion.ID_Persona
ORDER BY Total_Productos DESC
LIMIT 10;

#Consulta 6
SELECT Region.region AS Region,
CONCAT_WS("%", ((COUNT(*) / (SELECT COUNT(*) FROM Persona)) * 100), "") 
AS Porcentaje
FROM Persona 
INNER JOIN Ciudad ON Ciudad.ID_Ciudad = Persona.ID_Ciudad
INNER JOIN Region ON Region.ID_Region = Ciudad.ID_Region
GROUP BY Ciudad.ID_Region;