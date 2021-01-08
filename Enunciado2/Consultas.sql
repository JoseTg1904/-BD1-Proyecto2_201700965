#Consulta 1
SELECT a.areaInvestigacion AS Area_Investigacion,
(SELECT nombre FROM Personal WHERE Personal.ID_Personal = b.ID_Personal) AS Jefe,
(SELECT nombre FROM Personal WHERE Personal.ID_Personal = c.ID_Personal) AS Subalterno
FROM AsignacionArea
	INNER JOIN Personal AS b ON b.ID_Personal = AsignacionArea.ID_Personal
    INNER JOIN AreaInvestigacion as a ON a.ID_Personal = b.ID_Personal
	INNER JOIN AreaInvestigacion as c ON AsignacionArea.ID_AreaInvestigacion = c.ID_AreaInvestigacion;
    
#Consulta 2
WITH promedio AS
(SELECT AVG(Personal.salario) AS promedio, 
	AreaInvestigacion.areaInvestigacion FROM AsignacionArea
	INNER JOIN Personal ON Personal.ID_Personal = AsignacionArea.ID_Personal
    INNER JOIN AreaInvestigacion ON AreaInvestigacion.ID_AreaInvestigacion = AsignacionArea.ID_AreaInvestigacion
    GROUP BY AsignacionArea.ID_AreaInvestigacion),
individual AS
(SELECT Personal.nombre, Personal.salario, 
	AreaInvestigacion.areaInvestigacion FROM AsignacionArea
	INNER JOIN Personal ON Personal.ID_Personal = AsignacionArea.ID_Personal
    INNER JOIN AreaInvestigacion ON AreaInvestigacion.ID_AreaInvestigacion = AsignacionArea.ID_AreaInvestigacion)
SELECT individual.nombre, individual.salario,
	individual.areaInvestigacion
	FROM individual, promedio WHERE individual.salario > promedio.promedio
    AND promedio.areaInvestigacion LIKE individual.areaInvestigacion;
    
#Consulta 3
SELECT UPPER(LEFT(Pais.pais, 1)) AS Inicial, SUM(Pais.area) AS Suma 
	FROM Pais GROUP BY Inicial ORDER BY Inicial;


#Consulta 4
SELECT Inventor.inventor, Invento.anio FROM Inventor
	INNER JOIN AsignacionInvencion ON AsignacionInvencion.ID_Inventor = Inventor.ID_Inventor
    INNER JOIN Invento ON Invento.ID_Invento = AsignacionInvencion.ID_Invento
	WHERE (Inventor.inventor LIKE "B%r") OR 
    (Inventor.inventor LIKE "%n" AND YEAR(Invento.anio) BETWEEN 1801 AND 1900);
    
#Consulta 5
SELECT sub.pais, sub.area FROM 
(SELECT COUNT(*) AS NoFronteras, Pais.pais, Pais.area FROM Pais 
	INNER JOIN Frontera ON Frontera.ID_Pais = Pais.ID_Pais
    GROUP BY Pais.ID_Pais) AS sub
WHERE sub.NoFronteras > 7;

#Consulta 6
SELECT sub.nombre, sub.salario, sub.bono, sub.Suma AS Total FROM 
(SELECT Personal.nombre, Personal.salario,
	Personal.bono, (Personal.salario + Personal.bono) AS Suma,
    (Personal.salario * 0.25) AS Porcentaje FROM Personal) AS sub
WHERE sub.bono > sub.Porcentaje;

#Consulta 7
WITH sumatoria AS
(SELECT SUM(Pais.poblacion) AS Total FROM Pais
	WHERE Pais.ID_Region = 
    (SELECT ID_Region FROM Region WHERE region LIKE "Centro America")),
individual AS
(SELECT Pais.pais, Pais.poblacion FROM Pais)
SELECT individual.pais, individual.poblacion FROM individual, sumatoria
WHERE individual.poblacion > sumatoria.Total;

#Consulta 8
SELECT invento FROM Invento WHERE 
	YEAR(anio) = (SELECT YEAR(anio) FROM Invento WHERE 
		ID_Invento = (SELECT ID_Invento FROM AsignacionInvencion WHERE 
			ID_Inventor = (SELECT ID_Inventor FROM Inventor WHERE 
					Inventor.inventor LIKE "BENZ")));
                    
#Consulta 9
WITH japon AS
(SELECT area FROM Pais WHERE pais LIKE "Japon"),
individual AS 
(SELECT pais, area, poblacion FROM Pais
	WHERE ID_Pais NOT IN (SELECT ID_Pais FROM Frontera))
SELECT individual.pais, individual.poblacion FROM individual, japon
WHERE individual.area >= japon.area; 

#Consulta 10
SELECT sub.nombre, sub.salario, sub.bono FROM 
(SELECT Personal.nombre, Personal.salario,
	Personal.bono, (Personal.bono * 2) AS Doble FROM Personal) AS sub
WHERE sub.salario > sub.Doble;