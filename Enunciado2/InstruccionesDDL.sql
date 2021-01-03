#Creando la base de datos para almacenar el modelo
CREATE DATABASE enunciado2Proyecto2;

#Utilizando la nueva base de datos creada
USE enunciado2Proyecto2;

#Creando las tablas que no tienen dependencia
CREATE TABLE Encuesta(
	ID_Encuesta INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL
);

CREATE TABLE Personal(
	ID_Personal INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    salario INT NOT NULL,
    bono INT,
    inicio DATE NOT NULL,
    principal BOOL DEFAULT False
);

CREATE TABLE Region(
	ID_Region INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    region VARCHAR(100) NOT NULL,
    padre INT,
    FOREIGN KEY (padre) REFERENCES Region(ID_Region)
);

#Creando tablas que tienen dependencias
CREATE TABLE Pregunta(
	ID_Pregunta INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    pregunta TEXT NOT NULL,
    ID_Encuesta INT NOT NULL,
    FOREIGN KEY (ID_Encuesta) REFERENCES Encuesta(ID_Encuesta)
);

CREATE TABLE Respuesta(
	ID_Respuesta INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    respuesta TEXT NOT NULL,
    estado BOOL DEFAULT False,
    ID_Pregunta INT NOT NULL,
    FOREIGN KEY (ID_Pregunta) REFERENCES Pregunta(ID_Pregunta)
);

CREATE TABLE Pais(
	ID_Pais INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    pais VARCHAR(100) NOT NULL,
    capital VARCHAR(100) NOT NULL,
    area INT NOT NULL,
    poblacion INT NOT NULL,
    ID_Region INT NOT NULL,
    FOREIGN KEY (ID_Region) REFERENCES Region(ID_Region)
);

CREATE TABLE Seleccion(
	ID_Respuesta INT NOT NULL,
    ID_Pais INT NOT NULL,
    PRIMARY KEY(ID_Respuesta, ID_Pais),
    FOREIGN KEY(ID_Respuesta) REFERENCES Respuesta(ID_Respuesta),
    FOREIGN KEY(ID_Pais) REFERENCES Pais(ID_Pais)
);

CREATE TABLE Frontera(
	ID_Frontera INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    norte BOOL DEFAULT False,
    sur BOOL DEFAULT False,
    este BOOL DEFAULT False,
    oeste BOOL DEFAULT False,
    frontera INT NOT NULL,
    ID_Pais INT NOT NULL,
    FOREIGN KEY (frontera) REFERENCES Pais(ID_Pais),
    FOREIGN KEY (ID_Pais) REFERENCES Pais(ID_Pais)
);

CREATE TABLE Inventor(
	ID_Inventor INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    inventor VARCHAR(100) NOT NULL,
    ID_Pais INT NOT NULL,
    FOREIGN KEY (ID_Pais) REFERENCES Pais(ID_Pais)
);

CREATE TABLE Invento(
	ID_Invento INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    invento VARCHAR(100) NOT NULL,
    anio DATE NOT NULL,
    patente TEXT,
    ID_Pais INT NOT NULL,
    FOREIGN KEY (ID_Pais) REFERENCES Pais(ID_Pais)
);

CREATE TABLE AsignacionInvencion(
	ID_Inventor INT NOT NULL,
    ID_Invento INT NOT NULL,
    PRIMARY KEY (ID_Inventor, ID_Invento),
    FOREIGN KEY (ID_Inventor) REFERENCES Inventor(ID_Inventor),
    FOREIGN KEY (ID_Invento) REFERENCES Invento(ID_Invento)
);

CREATE TABLE AsignacionDocumentacion(
	ID_Invento INT NOT NULL,
    ID_Personal INT NOT NULL,
    documento TEXT,
    PRIMARY KEY (ID_Invento, ID_Personal),
    FOREIGN KEY (ID_Invento) REFERENCES Invento(ID_Invento),
    FOREIGN KEY (ID_Personal) REFERENCES Personal(ID_Personal)
);

CREATE TABLE AreaInvestigacion(
	ID_AreaInvestigacion INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    areaInvestigacion VARCHAR(100) NOT NULL,
    descripcion TEXT DEFAULT "",
    ranking INT NOT NULL,
    ID_Personal INT NOT NULL,
    FOREIGN KEY (ID_Personal) REFERENCES Personal(ID_Personal)
);

CREATE TABLE AsignacionArea(
	ID_Personal INT NOT NULL,
    ID_AreaInvestigacion INT NOT NULL,
    PRIMARY KEY (ID_Personal, ID_AreaInvestigacion),
    FOREIGN KEY (ID_Personal) REFERENCES Personal(ID_Personal),
    FOREIGN KEY (ID_AreaInvestigacion) REFERENCES AreaInvestigacion(ID_AreaInvestigacion)
);

#Creando las tablas temporales para la carga masiva de datos
CREATE TABLE TemporalRegion(
	nombre_region VARCHAR(100),
    region_padre VARCHAR(100)
);

CREATE TABLE TemporalEncuesta(
	nombre_encuesta VARCHAR(100),
    pregunta TEXT,
    respuesta_posible TEXT,
    respuesta_correcta TEXT,
    pais VARCHAR(100),
    respuesta_pais TEXT
);

CREATE TABLE TemporalPrincipal(
	invento VARCHAR(100),
    inventor VARCHAR(100),
    profesional_asignado VARCHAR(100),
    profesional_jefe VARCHAR(100),
    fecha_contrato DATE,
    salario INT,
    comision INT,
    area_investigacion VARCHAR(100),
    ranking INT,
    anio DATE,
    pais_invento VARCHAR(100),
    pais_inventor VARCHAR(100),
    region_pais VARCHAR(100),
    capital VARCHAR(100),
    poblacion INT,
    area INT,
    frontera VARCHAR(100), 
    norte VARCHAR(100),
    sur VARCHAR(100),
    este VARCHAR(100),
    oeste VARCHAR(100)
);