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

#Consulta 3
SELECT Persona.nombre AS Nombre_Proveedor,
Persona.ID_Persona AS ID_Proveedor,
SUM(DetalleTransaccion.cantidad * Producto.precio) AS Total
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
INNER JOIN TipoProducto ON TipoProducto.ID_TipoProducto = Producto.ID_TipoProducto
WHERE TipoPersona.tipoPersona = "P" AND TipoProducto.tipoProducto LIKE "Fresh Vegetables"
GROUP BY DetalleTransaccion.ID_Persona
ORDER BY Total DESC
LIMIT 5;

#Consulta 4
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

#Consulta 7
SELECT Ciudad.ciudad AS Ciudad,
SUM(DetalleTransaccion.cantidad) AS Total
FROM Persona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN Ciudad ON Ciudad.ID_Ciudad = Persona.ID_Ciudad
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
WHERE Producto.nombre LIKE "Tortillas" AND TipoPersona.tipoPersona = "C"
GROUP BY Persona.ID_Ciudad
ORDER BY Total DESC;

#Consulta 8
/* Left devuelve la cantidad de caracteres especificado en el segundo parametro de izquierda -> derecha,
siendo el primer parametro la palabra a dividir.
Upper pasa a mayuscula el texto que se pase por parametro */
SELECT UPPER(LEFT(Ciudad.ciudad, 1)) as Inicial,
COUNT(*) as Total_Ciudadanos
FROM Persona
INNER JOIN Ciudad ON Ciudad.ID_Ciudad = Persona.ID_Ciudad
GROUP BY Inicial
ORDER BY Inicial;

#Consulta 9
/* with "nombre" as permite crear una o varias subconsultas 
afuera de una para poder ser utilizada de una manera mas legible en otra que 
va abajo de esta */
WITH principal AS 
(SELECT numerador.ciudadNum AS Ciudad,
numerador.tipoNum AS Categoria,
(numerador.numNum / denominador.denDen) * 100 AS Porcentaje
FROM (SELECT SUM(DetalleTransaccion.cantidad) AS numNum, 
TipoProducto.tipoProducto AS tipoNum, Ciudad.ciudad AS ciudadNum
FROM Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
INNER JOIN TipoProducto ON TipoProducto.ID_TipoProducto = Producto.ID_TipoProducto
INNER JOIN Ciudad ON Ciudad.ID_Ciudad = Persona.ID_Ciudad
WHERE TipoPersona.tipoPersona LIKE "P"
GROUP BY TipoProducto.ID_TipoProducto, Ciudad.ID_Ciudad) AS numerador, 
(SELECT SUM(DetalleTransaccion.cantidad) AS denDen, Ciudad.ciudad AS ciudadDen
FROM Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN Producto ON Producto.ID_Producto = DetalleTransaccion.ID_Producto
INNER JOIN TipoProducto ON TipoProducto.ID_TipoProducto = Producto.ID_TipoProducto
INNER JOIN Ciudad ON Ciudad.ID_Ciudad = Persona.ID_Ciudad
WHERE TipoPersona.tipoPersona LIKE "P"
GROUP BY Ciudad.ID_Ciudad) AS denominador
WHERE numerador.ciudadNum = denominador.ciudadDen)
SELECT principal.Ciudad AS Ciudad, principal.Categoria AS Categoria, 
CONCAT_WS("%", principal.Porcentaje, "")  AS Porcentaje
FROM principal
ORDER BY principal.Ciudad, principal.Porcentaje DESC;
 
#Consulta 10
#AVG Saca un promedio del valor pasado por parametro 
WITH promedioCiudad AS
(SELECT AVG(DetalleTransaccion.cantidad) AS promedio
FROM Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
INNER JOIN Ciudad on Ciudad.ID_Ciudad = Persona.ID_Ciudad
WHERE Ciudad.ciudad LIKE "Frankfort" AND TipoPersona.tipoPersona LIKE "C"
GROUP BY Ciudad.ciudad),
promedioClientes AS 
(SELECT AVG(DetalleTransaccion.cantidad) AS promedio,
Persona.nombre AS Nombre
FROM Persona
INNER JOIN TipoPersona ON TipoPersona.ID_TipoPersona = Persona.ID_TipoPersona
INNER JOIN DetalleTransaccion ON DetalleTransaccion.ID_Persona = Persona.ID_Persona
WHERE TipoPersona.tipoPersona LIKE "C"
GROUP BY DetalleTransaccion.ID_Persona)
SELECT promedioClientes.Nombre AS Nombre_Cliente,
CONCAT_WS("%", promedioClientes.promedio, "") AS Promedio
FROM promedioCiudad, promedioClientes
WHERE promedioClientes.promedio > promedioCiudad.promedio
ORDER BY promedioClientes.promedio DESC;