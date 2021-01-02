#utilizando la base de datos para el enunciado 1
USE enunciado2Proyecto2;

/*Para la carga del csv se debe de mover dicho csv hacia la carpeta segura
la ruta en cual se debe de mover este archivo se visualiza con el comando 
SHOW VARIABLES LIKE "secure_file_priv";
*/

#Carga de datos del csv que carga regiones y sus padres
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dos.csv'
IGNORE INTO TABLE TemporalRegion
CHARACTER SET utf8
FIELDS OPTIONALLY ENCLOSED BY '\'' TERMINATED BY ','
LINES TERMINATED BY '\n' IGNORE 1 LINES
(nombre_region, region_padre);

#Carga de datos del csv que carga las encuestas
#El ignore antes del into table ignora los espacios vacios que se encuentren en el csv
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dos.csv'
IGNORE INTO TABLE TemporalEncuesta
CHARACTER SET utf8
FIELDS OPTIONALLY ENCLOSED BY '\'' TERMINATED BY ','
LINES TERMINATED BY '\n' IGNORE 1 LINES
(nombre_encuesta, pregunta, respuesta_posible, 
respuesta_correcta, pais, respuesta_pais);

#Carga de datos principales
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/uno.csv'
IGNORE INTO TABLE TemporalPrincipal
CHARACTER SET utf8
FIELDS OPTIONALLY ENCLOSED BY '\'' TERMINATED BY ','
LINES TERMINATED BY '\n' IGNORE 1 LINES
(invento, inventor, profesional_asignado, profesional_jefe,
fecha_contrato, salario, comision, area_investigacion,
ranking, @anio, pais_invento, pais_inventor, region_pais,
capital, poblacion, area, frontera, norte, sur, este, oeste)
SET anio = STR_TO_DATE(@anio, "%Y");

#usar el trim al momento de hacer la carga hacia las tablas buenas 
select char_length(trim(pais)), pais from TemporalEncuesta;