#utilizando la base de datos para el enunciado 1
USE enunciado2Proyecto2;

/* Para la carga del csv se debe de mover dicho csv hacia la carpeta segura
la ruta en cual se debe de mover este archivo se visualiza con el comando 
SHOW VARIABLES LIKE "secure_file_priv";
Se usa el ignore en la carga masiva de los csv para ignorar los espacios vacios, que 
se originan por un archivo sucio de entrada
*/
#Carga de datos del csv que carga regiones y sus padres
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/tres.csv'
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

#Carga de datos a las tablas sin dependencias

#Carga de los datos de regiones, primero solo los nombres, luego los padres
INSERT INTO Region (region)
SELECT TRIM(nombre_region) FROM TemporalRegion;

/* Con el ignore se ignora el campo obligatorio de cada tupla que es "region"
que es el nombre de la region, al utilizar left join obtenemos todas las claves foranes 
que pertenecen a las regiones padre, con el inner join se obtienen las claves primarias de cada tupla,
al utilizar el on duplicate key update en vez de hacer nuevas inserciones se actualizan los registros 
que ya contengan esas claves */
INSERT IGNORE Region (ID_Region, padre)
SELECT recursiva.hijo, recursiva.padre FROM 
	(SELECT unionPadre.ID_Region AS padre, unionHija.ID_Region AS hijo 
		FROM TemporalRegion AS temp
		LEFT JOIN Region AS unionPadre ON temp.region_padre = unionPadre.region
		INNER JOIN Region AS unionHija ON temp.nombre_region = unionHija.region) AS recursiva
ON DUPLICATE KEY UPDATE padre = recursiva.padre;

INSERT INTO Encuesta (titulo)
SELECT DISTINCT TRIM(nombre_encuesta) FROM TemporalEncuesta;

INSERT INTO Personal (nombre, salario, bono, inicio)
SELECT DISTINCT TRIM(profesional_asignado), salario, comision, fecha_contrato
FROM TemporalPrincipal WHERE profesional_asignado <> "";

#Insercion del atributo identificador del jefe de todas las areas
INSERT IGNORE Personal (ID_Personal, principal)
SELECT ID_Personal, True FROM Personal WHERE Personal.nombre = 
	(SELECT (profesional_asignado) FROM TemporalPrincipal
		WHERE profesional_jefe LIKE "TODAS" LIMIT 1)
ON DUPLICATE KEY UPDATE principal = True;

#Creando las tablas que tienen dependencias
INSERT INTO Pregunta (pregunta, ID_Encuesta)
SELECT DISTINCT TRIM(TemporalEncuesta.pregunta), Encuesta.ID_Encuesta FROM Encuesta
INNER JOIN TemporalEncuesta ON TRIM(TemporalEncuesta.nombre_encuesta) = Encuesta.titulo;

INSERT INTO Respuesta (respuesta, ID_Pregunta)
SELECT sub.respuesta, sub.ID_Pregunta FROM
	(SELECT DISTINCT TRIM(TemporalEncuesta.respuesta_posible) AS respuesta, 
		Pregunta.ID_Pregunta AS ID_Pregunta, Pregunta.pregunta FROM Pregunta
		INNER JOIN TemporalEncuesta ON TRIM(TemporalEncuesta.pregunta) LIKE Pregunta.pregunta
		INNER JOIN Encuesta ON TRIM(TemporalEncuesta.nombre_encuesta) LIKE Encuesta.titulo) AS sub;

/* Modificando cual es la respuesta correcta para cada pregunta */
INSERT IGNORE Respuesta (ID_Respuesta, estado)
SELECT sub.ID_Respuesta, True FROM
	(SELECT ID_Respuesta AS ID_Respuesta, respuesta AS posible,
		ID_Pregunta AS ID_Pregunta FROM Respuesta) AS sub,
	(SELECT DISTINCT Pregunta.ID_Pregunta AS ID_Pregunta, 
		Respuesta.ID_Respuesta AS ID_Respuesta, 
		TRIM(TemporalEncuesta.respuesta_correcta) as correcta 
		FROM Pregunta
		INNER JOIN TemporalEncuesta ON TRIM(TemporalEncuesta.pregunta) LIKE Pregunta.pregunta
		INNER JOIN Encuesta ON TRIM(TemporalEncuesta.nombre_encuesta) LIKE Encuesta.titulo
		INNER JOIN Respuesta ON Respuesta.ID_Pregunta = Pregunta.ID_Pregunta) AS sub1
WHERE sub1.ID_Pregunta = sub.ID_Pregunta AND sub1.correcta = sub.posible 
ON DUPLICATE KEY UPDATE estado = True;

INSERT INTO Pais (pais, capital, area, poblacion, ID_Region)
SELECT TRIM(sub.pais_inventor), TRIM(sub.capital), sub.area, sub.poblacion, sub.ID_Region FROM 
	(SELECT DISTINCT pais_inventor, capital, area, poblacion, 
		(SELECT ID_Region FROM Region WHERE region LIKE TRIM(region_pais)) AS ID_Region
		FROM TemporalPrincipal) as sub;
        
INSERT INTO Seleccion (ID_Pais, ID_Respuesta)
SELECT DISTINCT sub.ID_Pais, sub.ID_Respuesta FROM
(SELECT Pais.ID_Pais, Respuesta.ID_Respuesta
	FROM TemporalEncuesta
	INNER JOIN Pais ON Pais.pais LIKE TRIM(TemporalEncuesta.pais)
    INNER JOIN Pregunta ON Pregunta.pregunta LIKE TRIM(TemporalEncuesta.pregunta)
    INNER JOIN Respuesta ON Respuesta.ID_Pregunta = Pregunta.ID_Pregunta
	WHERE LEFT(Respuesta.respuesta, 1) LIKE TRIM(TemporalEncuesta.respuesta_pais) AND
    Pregunta.pregunta LIKE TRIM(TemporalEncuesta.pregunta)
) as sub;

INSERT INTO Frontera (norte, sur, este, oeste, frontera, ID_Pais)
SELECT DISTINCT * FROM
(SELECT IF(TRIM(norte) like "x", True, False) AS norte, 
	IF(TRIM(sur) like "x", True, False) AS sur,
    IF(TRIM(este) like "x", True, False) AS este, 
    IF(TRIM(oeste) like "x", True, False) AS oeste, 
    (SELECT ID_Pais FROM Pais WHERE Pais.pais LIKE TemporalPrincipal.frontera) AS ID_Frontera,
	(SELECT ID_Pais FROM Pais WHERE Pais.pais LIKE TemporalPrincipal.pais_inventor) AS ID_Pais
	FROM TemporalPrincipal WHERE TemporalPrincipal.frontera <> ""
) AS sub;

INSERT INTO Inventor (inventor, ID_Pais)
SELECT DISTINCT TRIM(inventor), 
(SELECT ID_Pais FROM Pais 
	WHERE Pais.pais LIKE TRIM(TemporalPrincipal.pais_inventor)) 
FROM TemporalPrincipal
WHERE TemporalPrincipal.inventor <> "";

INSERT INTO Invento (invento, anio, ID_Pais)
SELECT DISTINCT TRIM(invento), anio, 
(SELECT ID_Pais FROM Pais 
	WHERE Pais.pais LIKE TRIM(TemporalPrincipal.pais_invento))
FROM TemporalPrincipal
WHERE TemporalPrincipal.invento <> "";

INSERT INTO AsignacionInvencion (ID_Invento, ID_Inventor)
SELECT DISTINCT sub.ID_Invento, sub.ID_Inventor FROM
(SELECT ID_Invento, ID_Inventor FROM TemporalPrincipal
	INNER JOIN Invento ON Invento.invento LIKE TRIM(TemporalPrincipal.invento)
    INNER JOIN Inventor ON Inventor.inventor LIKE TRIM(TemporalPrincipal.inventor)) AS sub;

INSERT INTO AsignacionDocumentacion (ID_Personal, ID_Invento)
SELECT DISTINCT sub.ID_Personal, sub.ID_Invento FROM
(SELECT ID_Personal, ID_Invento FROM TemporalPrincipal
	INNER JOIN Invento ON Invento.invento LIKE TRIM(TemporalPrincipal.invento)
    INNER JOIN Personal ON Personal.nombre LIKE TRIM(TemporalPrincipal.profesional_asignado)) AS sub;

#Insercion de las areas que si tienen un jefe inmediato en el csv
INSERT INTO AreaInvestigacion (areaInvestigacion, ranking, ID_Personal)
SELECT sub.area_investigacion, sub.ranking, (SELECT ID_Personal FROM Personal WHERE nombre LIKE jefe.profesional_asignado) FROM
(SELECT DISTINCT TRIM(TemporalPrincipal.area_investigacion) AS area_investigacion, ranking
	FROM TemporalPrincipal WHERE TemporalPrincipal.area_investigacion <> "") as sub,
(SELECT DISTINCT TRIM(profesional_asignado) AS profesional_asignado , TRIM(profesional_jefe) as  profesional_jefe 
	FROM TemporalPrincipal 
	WHERE TemporalPrincipal.profesional_jefe <> "" AND TemporalPrincipal.profesional_jefe <> "TODAS") AS jefe
WHERE sub.area_investigacion LIKE jefe.profesional_jefe;
    
#Insercion de las areas que no tienen jefe inmediato, dejando de jefe al jefe de todas las areas
INSERT INTO AreaInvestigacion (areaInvestigacion, ranking, ID_Personal)
SELECT Distinct area_investigacion, ranking, (SELECT ID_Personal FROM Personal WHERE principal = True) 
	FROM TemporalPrincipal WHERE
	TRIM(TemporalPrincipal.area_investigacion) NOT IN (SELECT areaInvestigacion FROM AreaInvestigacion) 
    AND TemporalPrincipal.area_investigacion <> "";

INSERT INTO AsignacionArea (ID_AreaInvestigacion, ID_Personal)
SELECT DISTINCT AreaInvestigacion.ID_AreaInvestigacion, Personal.ID_Personal 
	FROM TemporalPrincipal
	INNER JOIN Personal ON Personal.nombre LIKE TRIM(TemporalPrincipal.profesional_asignado)
    INNER JOIN AreaInvestigacion ON AreaInvestigacion.areaInvestigacion LIKE TRIM(TemporalPrincipal.area_investigacion);