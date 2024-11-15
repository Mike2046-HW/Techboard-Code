create database PRUEBAS_TECHBOARD
use PRUEBAS_TECHBOARD
use master
drop database PROYECTO_TECHBOARD

Select * From Vendedor
Select * From Vendedor_Producto
Select * From Producto


--- SECCIÓN DE LOS USUARIOS ---

-- Tabla de usuarios
create table USUARIO
(
	IdUsuario int primary key identity (1,1),
	Nombre varchar (100),
	Correo varchar(100),
	Clave varchar (100)
)

-- Procedimiento almacenado para el registro de ususarios
create proc sp_RegistrarUsuario
(
	@Correo varchar (100),
	@Clave varchar (500),
	@Nombre varchar (100),
	@Registrado bit output,
	@Mensaje varchar (100) output
)
as
begin
	
		if (not exists (select*from USUARIO where Correo = @Correo))
		begin
			insert into USUARIO (Correo, Clave, Nombre) values (@Correo,@Clave,@Nombre)
			set @Registrado = 1
			set @Mensaje = 'Usuario registrado'
		end
		else
		begin
			set @Registrado = 0
			set @Mensaje = 'Usuario registrado'
		end
end

-- Procedimiento almacenado para acceder al sistema
create proc sp_ValidarUsuario 
(
	@Correo varchar(100),
	@Clave varchar (500)
)
as
begin
		if(exists(select*from USUARIO where Correo = @Correo and Clave = @Clave))
			select IdUsuario from USUARIO where Correo = @Correo and Clave = @Clave
		else
			select '0'
end

--- SECCIÓN DEL COMPRADOR ---

-- Tabla Dirección del Comprador
CREATE TABLE Direccion_Comprador (
  Direccion_Comprador_Id INT IDENTITY PRIMARY KEY,
  Calle NVARCHAR(255) NOT NULL,
  Ciudad NVARCHAR(100) NOT NULL,
  Estado NVARCHAR(100) NOT NULL,
  Codigo_Postal NVARCHAR(20) NOT NULL
);


-- Tabla Comprador
CREATE TABLE Comprador (
  Comprador_Id INT IDENTITY PRIMARY KEY,
  Nombre_Empresa NVARCHAR(255) NOT NULL,
  RFC NVARCHAR(20) NOT NULL,
  Correo_Electronico NVARCHAR(255) NOT NULL,
  Telefono NVARCHAR(20) NOT NULL,
  Direccion_Comprador_Id INT FOREIGN KEY REFERENCES Direccion_Comprador(Direccion_Comprador_Id)
);

--- SECCIÓN DE PAQUETERIA ---

-- Tabla Paquetería
CREATE TABLE Paqueteria (
  Paqueteria_Id INT IDENTITY PRIMARY KEY,
  Nombre NVARCHAR(255) NOT NULL,
  Correo_Electronico NVARCHAR(255) NOT NULL,
  Telefono NVARCHAR(20) NOT NULL
);

-- INSERTAR PAQUETERIA
create procedure Registrar_Paqueteria
(
	@Nombre NVARCHAR(255),
	@Correo_Electronico NVARCHAR(255),
	@Telefono NVARCHAR(20)
) 
as begin
	insert into Paqueteria (Nombre, Correo_Electronico, Telefono) Values (@Nombre, @Correo_Electronico, @Telefono)
end

-- ELIMINAR PAQUETERIA
create procedure Eliminar_Paqueteria
(
	@Paqueteria_Id INT
)
as begin
	delete from Paqueteria where Paqueteria_Id = @Paqueteria_Id
end

-- ACTUALIZAR PAQUETERIA
create procedure Editar_Paqueteria
(
	@Paqueteria_Id INT,
	@Nombre NVARCHAR(255),
	@Correo_Electronico NVARCHAR(255),
	@Telefono NVARCHAR(20)
) 
as begin
	UPDATE Paqueteria SET Nombre = @Nombre, Correo_Electronico = @Correo_Electronico, Telefono = @Telefono where @Paqueteria_Id = Paqueteria_Id
end

--- SECCIÓN DE ESTADO DE ENVÍO ---

-- Tabla Estado de Envío
CREATE TABLE Estado_Envio (
  Estado_Envio_Id INT IDENTITY PRIMARY KEY,
  Estado NVARCHAR(255) NOT NULL,
  Fecha_Actualizacion DATETIME DEFAULT GETDATE(),
);

--- SECCIÓN DEL VENDEDOR ---

-- Tabla Dirección del Vendedor
CREATE TABLE Direccion_Vendedor (
  Direccion_Vendedor_Id INT IDENTITY PRIMARY KEY,
  Calle NVARCHAR(255) NOT NULL,
  Ciudad NVARCHAR(100) NOT NULL,
  Estado NVARCHAR(100) NOT NULL,
  Codigo_Postal NVARCHAR(20) NOT NULL
);

-- Tabla Vendedor
CREATE TABLE Vendedor (
  Vendedor_Id INT IDENTITY PRIMARY KEY,
  Nombre_Empresa NVARCHAR(255) NOT NULL,
  Correo_Electronico NVARCHAR(255) NOT NULL,
  Telefono NVARCHAR(20) NOT NULL,
  Direccion_Vendedor_Id INT FOREIGN KEY REFERENCES Direccion_Vendedor(Direccion_Vendedor_Id)
);

--- SECCIÓN DE PRODUCTOS ---

-- Tabla Tipo de Producto
CREATE TABLE Tipo_Producto (
  Tipo_Producto_Id INT IDENTITY PRIMARY KEY,
  Nombre_Tipo NVARCHAR(100) NOT NULL,
);

-- Tabla Producto
CREATE TABLE Producto (
  Producto_Id INT IDENTITY PRIMARY KEY,
  Tipo_Producto_Id INT FOREIGN KEY REFERENCES Tipo_Producto(Tipo_Producto_Id),
  Cantidad INT NOT NULL CHECK (Cantidad >= 0),
  Nombre_Producto nvarchar(100)
);

-- View de Productos para modelo de Visual Studio
create view v_Productos as Select
Producto_ID as 'ID',
Nombre_Producto as 'Nombre',
Nombre_Tipo as 'Categoria',
Cantidad as 'Stock'
from Producto
Join Tipo_Producto 
On Producto.Tipo_Producto_Id = Tipo_Producto.Tipo_Producto_Id

-- Procedimiento para agregar un producto nuevo
CREATE PROCEDURE sp_Insertar_Producto
(
    @Tipo NVARCHAR(100),
    @Nombre NVARCHAR(100),
    @Stock INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Id INT;

    -- Verifica si el tipo de producto ya existe
    SELECT @Id = Tipo_Producto_Id 
    FROM Tipo_Producto 
    WHERE Nombre_Tipo = @Tipo;

    -- Si no existe, inserta el nuevo tipo de producto y obtiene el ID
    IF @Id IS NULL
    BEGIN
        INSERT INTO Tipo_Producto (Nombre_Tipo)
        VALUES (@Tipo);

        SET @Id = SCOPE_IDENTITY();
    END

    -- Inserta en la tabla Producto utilizando el Tipo_Producto_Id
    INSERT INTO Producto (Tipo_Producto_Id, Cantidad, Nombre_Producto)
    VALUES (@Id, @Stock, @Nombre);
END;

-- Procedimiento para eliminar propducto 
CREATE PROCEDURE sp_Eliminar_Producto
(
	@Id_Producto int
)
AS BEGIN
	Delete From Producto where Producto_Id = @Id_Producto
End

-- Procedimiento para actualizar productos
CREATE PROCEDURE sp_Editar_Producto
(
	@Producto_Id int,
	@Nombre_Producto nvarchar(100),
	@Stock int
)
AS BEGIN
	UPDATE Producto SET Cantidad = @Stock, Nombre_Producto = @Nombre_Producto where @Producto_Id = Producto_Id
End

--- SECCIÓN DE PEDIDO ---

-- Tabla Pedido
CREATE TABLE Pedido (
  Pedido_Id INT IDENTITY PRIMARY KEY,
  Comprador_Id INT FOREIGN KEY REFERENCES Comprador(Comprador_Id),
  Fecha_Pedido DATETIME DEFAULT GETDATE(),
  Estado_Envio_Id INT FOREIGN KEY REFERENCES Estado_Envio ON DELETE CASCADE,
  Paqueteria_Id INT FOREIGN KEY REFERENCES Paqueteria ON DELETE CASCADE
);

-- Tabla Pedido_Producto (relación de muchos a muchos entre Pedido y Producto)
CREATE TABLE Pedido_Producto (
  Pedido_Producto_Id INT IDENTITY PRIMARY KEY,
  Pedido_Id INT FOREIGN KEY REFERENCES Pedido(Pedido_Id) ON DELETE CASCADE,
  Producto_Id INT FOREIGN KEY REFERENCES Producto(Producto_Id) ON DELETE CASCADE,
  Cantidad INT NOT NULL CHECK (Cantidad > 0)
);

-- Tabla Vendedor_Producto (Entidad de relación entre Vendedor y Producto)
CREATE TABLE Vendedor_Producto (
  Vendedor_Producto_Id INT IDENTITY PRIMARY KEY,
  Vendedor_Id INT FOREIGN KEY REFERENCES Vendedor(Vendedor_Id) ON DELETE CASCADE,
  Producto_Id INT FOREIGN KEY REFERENCES Producto(Producto_Id) ON DELETE CASCADE
);

-- View para ver los pedidos a detalle con el nombre de la paquetería
CREATE VIEW v_Detalles_Pedido AS
SELECT 
    p.Pedido_Id AS 'ID',
    p.Fecha_Pedido AS 'Fecha Pedido',
    c.Nombre_Empresa AS 'Comprador',
    es.Estado AS 'Estado',
    tp.Nombre_Tipo AS 'Tipo de producto',
    pr.Nombre_Producto AS 'Nombre Producto',
    pp.Cantidad AS 'Cantidad',
    v.Nombre_Empresa AS 'Vendedor',
    pa.Nombre AS 'Paquetería'  
FROM 
    Pedido p
JOIN 
    Comprador c ON p.Comprador_Id = c.Comprador_Id
JOIN 
    Estado_Envio es ON p.Estado_Envio_Id = es.Estado_Envio_Id
JOIN 
    Pedido_Producto pp ON p.Pedido_Id = pp.Pedido_Id
JOIN 
    Producto pr ON pp.Producto_Id = pr.Producto_Id
JOIN 
    Tipo_Producto tp ON pr.Tipo_Producto_Id = tp.Tipo_Producto_Id
JOIN 
    Vendedor_Producto vp ON pr.Producto_Id = vp.Producto_Id
JOIN 
    Vendedor v ON vp.Vendedor_Id = v.Vendedor_Id
JOIN 
    Paqueteria pa ON p.Paqueteria_Id = pa.Paqueteria_Id;  -- Unión con la tabla Paqueteria

--- SECCIÓN DE FACTURACIÓN ---

-- Tabla Factura (relacionada con Pedido)
CREATE TABLE Factura (
  Factura_Id INT IDENTITY PRIMARY KEY,
  Pedido_Id INT FOREIGN KEY REFERENCES Pedido(Pedido_Id) ON DELETE CASCADE,
  Numero_Factura NVARCHAR(50) NOT NULL UNIQUE,
  Fecha_Emision DATETIME2 DEFAULT SYSDATETIME(),
  Monto_Total DECIMAL(10, 2) NOT NULL,
  Impuesto DECIMAL(10, 2) DEFAULT 0
);

-- Inserción de pedido por medio de listas desplegables
CREATE OR ALTER PROCEDURE sp_Insertar_Pedido
(
    @Comprador_Id INT,
    @Producto_Id INT,
    @Cantidad INT,
    @Paqueteria_Id INT,
    @Estado_Envio_Id INT,
    @Vendedor_Id INT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Pedido_Id INT;

    -- Verificar si el Estado_Envio_Id proporcionado existe en la tabla Estado_Envio
    IF NOT EXISTS (SELECT 1 FROM Estado_Envio WHERE Estado_Envio_Id = @Estado_Envio_Id)
    BEGIN
        RAISERROR('El Estado_Envio_Id proporcionado no existe en la tabla Estado_Envio.', 16, 1);
        RETURN;
    END

    -- Verificar si el Paqueteria_Id proporcionado existe en la tabla Paqueteria
    IF NOT EXISTS (SELECT 1 FROM Paqueteria WHERE Paqueteria_Id = @Paqueteria_Id)
    BEGIN
        RAISERROR('El Paqueteria_Id proporcionado no existe en la tabla Paqueteria.', 16, 1);
        RETURN;
    END

    -- Inserta en la tabla Pedido con el Estado_Envio_Id y Paqueteria_Id proporcionados
    INSERT INTO Pedido (Comprador_Id, Estado_Envio_Id, Paqueteria_Id)
    VALUES (@Comprador_Id, @Estado_Envio_Id, @Paqueteria_Id);

    -- Obtén el Pedido_Id generado
    SET @Pedido_Id = SCOPE_IDENTITY();

    -- Inserta en la tabla Pedido_Producto
    INSERT INTO Pedido_Producto (Pedido_Id, Producto_Id, Cantidad)
    VALUES (@Pedido_Id, @Producto_Id, @Cantidad);

    -- Relaciona el producto con el vendedor en Vendedor_Producto si no existe la relación
    IF NOT EXISTS (SELECT 1 FROM Vendedor_Producto WHERE Vendedor_Id = @Vendedor_Id AND Producto_Id = @Producto_Id)
    BEGIN
        INSERT INTO Vendedor_Producto (Vendedor_Id, Producto_Id)
        VALUES (@Vendedor_Id, @Producto_Id);
    END
END;


INSERT INTO Tipo_Producto (Nombre_Tipo) VALUES ('Sopa Instantanea')
INSERT INTO Tipo_Producto (Nombre_Tipo) VALUES ('PCB Bi Capa')
INSERT INTO Tipo_Producto (Nombre_Tipo) VALUES ('PCB Tri Capa')

INSERT INTO Estado_Envio (Estado, Fecha_Actualizacion) VALUES ('En proceso',Getdate())
INSERT INTO Estado_Envio (Estado, Fecha_Actualizacion) VALUES ('Enviado',Getdate())
INSERT INTO Estado_Envio (Estado, Fecha_Actualizacion) VALUES ('Entregado',Getdate())



-- Insertar direcciones para los compradores
INSERT INTO Direccion_Comprador (Calle, Ciudad, Estado, Codigo_Postal)
VALUES 
('Av. Revolución 123', 'Ciudad de México', 'CDMX', '01234'),
('Calle del Sol 456', 'Guadalajara', 'Jalisco', '56789'),
('Boulevard de los Sueños 789', 'Monterrey', 'Nuevo León', '23456');

-- Insertar compradores utilizando las direcciones creadas
INSERT INTO Comprador (Nombre_Empresa, RFC, Correo_Electronico, Telefono, Direccion_Comprador_Id)
VALUES 
('Compras Rápidas SA', 'CRS123456789', 'contacto@comprasrapidas.com', '555-1234', 1),
('Electro Global SA', 'EGS987654321', 'ventas@electroglobal.com', '333-5678', 2),
('Papelería Central SA', 'PCS456123789', 'info@papeleriacentral.com', '818-9876', 3);



-- Insertar direcciones para los vendedores
INSERT INTO Direccion_Vendedor (Calle, Ciudad, Estado, Codigo_Postal)
VALUES 
('Calle Comercio 101', 'Puebla', 'Puebla', '12345'),
('Avenida Industrial 202', 'León', 'Guanajuato', '67890'),
('Ruta Comercial 303', 'Querétaro', 'Querétaro', '54321');

-- Insertar vendedores utilizando las direcciones creadas
INSERT INTO Vendedor (Nombre_Empresa, Correo_Electronico, Telefono, Direccion_Vendedor_Id)
VALUES 
('Distribuidora XYZ SA', 'contacto@distribuidoraxyz.com', '222-1010', 1),
('Industrial SA', 'ventas@industrial.com', '477-2020', 2),
('Comercial ABC SA', 'info@comercialabc.com', '442-3030', 3);

Select* From v_Detalles_Pedido