#Creando la base de datos para almacenar el modelo
CREATE DATABASE enunciado1Proyecto2;

#utilizando la base de datos creada
USE enunciado1Proyecto2;

#Creando las tablas que no tengan dependencia de otras
CREATE TABLE Region(
	ID_Region INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    region VARCHAR(100) NOT NULL
);

CREATE TABLE TipoPersona(
	ID_TipoPersona INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    tipoPersona CHAR(1)
);

CREATE TABLE CodigoPostal(
	ID_CodigoPostal INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    codigoPostal VARCHAR(100) NOT NULL
);

CREATE TABLE Compania(
	ID_Compania INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
    contacto VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    telefono VARCHAR(50) NOT NULL
);

CREATE TABLE TipoProducto(
	ID_TipoProducto INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    tipoProducto VARCHAR(75) NOT NULL
);

#creando las tablas que tienen dependencias
CREATE TABLE Ciudad(
	ID_Ciudad INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    ciudad VARCHAR(100) NOT NULL,
    ID_Region INT NOT NULL,
    FOREIGN KEY (ID_Region) REFERENCES Region(ID_Region)
);

CREATE TABLE Persona(
	ID_Persona INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
	nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    telefono VARCHAR(50) NOT NULL,
    fechaRegistro DATE NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    ID_CodigoPostal INT NOT NULL,
    ID_Ciudad INT NOT NULL,
    ID_TipoPersona INT NOT NULL,
    FOREIGN KEY (ID_CodigoPostal) REFERENCES CodigoPostal(ID_CodigoPostal),
    FOREIGN KEY (ID_Ciudad) REFERENCES Ciudad(ID_Ciudad),
    FOREIGN KEY (ID_TipoPersona) REFERENCES TipoPersona(ID_TipoPersona)
);

CREATE TABLE Producto(
	ID_Producto INT AUTO_INCREMENT NOT NULL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    precio DECIMAL(6, 2) NOT NULL,
    ID_TipoProducto INT NOT NULL,
    FOREIGN KEY (ID_TipoProducto) REFERENCES TipoProducto(ID_TipoProducto)
);

CREATE TABLE Transaccion(
	ID_Persona INT NOT NULL,
    ID_Compania INT NOT NULL,
    PRIMARY KEY(ID_Persona, ID_Compania),
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    FOREIGN KEY (ID_Compania) REFERENCES Compania(ID_Compania)
);

CREATE TABLE DetalleTransaccion(
	ID_DetalleTransaccion INT AUTO_INCREMENT PRIMARY KEY,
    cantidad INT NOT NULL,
    ID_Producto INT NOT NULL,
    ID_Persona INT NOT NULL,
    ID_Compania INT NOT NULL,
    FOREIGN KEY (ID_Producto) REFERENCES Producto(ID_Producto),
    FOREIGN KEY (ID_Persona) REFERENCES Persona(ID_Persona),
    FOREIGN KEY (ID_Compania) REFERENCES Compania(ID_Compania)
);

#tabla temporal que sirve para cargar el csv y llenar el modelo
CREATE TABLE Temporal(
	nombre_compania VARCHAR(100) NOT NULL,
    contacto_compania VARCHAR(100) NOT NULL,
    correo_compania VARCHAR(100) NOT NULL,
    telefono_compania VARCHAR(50) NOT NULL,
    tipo CHAR(1) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    telefono VARCHAR(100) NOT NULL,
    fecha_registro DATE NOT NULL,
    direccion VARCHAR(100) NOT NULL,
    ciudad VARCHAR(100) NOT NULL,
    codigo_postal INT NOT NULL,
    region VARCHAR(100) NOT NULL,
    producto VARCHAR(100) NOT NULL,
    categoria_producto VARCHAR(100) NOT NULL,
    cantidad INT NOT NULL,
	precio_unitario DECIMAL(6, 2) NOT NULL
);