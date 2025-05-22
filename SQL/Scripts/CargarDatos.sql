USE [DBProject]
GO

/****** Object:  StoredProcedure [dbo].[CargarDatos]    Script Date: 19/5/2025 18:21:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CargarDatos](
	@inArchivoXML NVARCHAR(MAX)
	,@outResultCode INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

		BEGIN TRY
		
			SET @outResultCode = 0; --C�digo exito

			--Convertir variable nvarchar a variable xml
			DECLARE @xml XML
			SET @xml = CAST( @inArchivoXML AS XML )

			--Declarar las tablas variables para cada tipo de nodo
			DECLARE @tempError table ( Sec INT IDENTITY(1,1)
										,Error XML );
			DECLARE @tempPuesto table ( Sec INT IDENTITY(1,1)
										,Puesto XML );
			DECLARE @tempTipoEvento table ( Sec INT IDENTITY(1,1)
											,TipoEvento XML );
			DECLARE @tempTipoMovimiento table ( Sec INT IDENTITY(1,1)
												,TipoMovimiento XML );
			DECLARE @tempUsuario table ( Sec INT IDENTITY(1,1)
											,Usuario XML );
			DECLARE @tempFeriado table( Sec INT IDENTITY(1,1)
										,Feriado XML );
			DECLARE @tempDepartamento table( Sec INT IDENTITY(1,1)
										,Departamento XML );			
			DECLARE @tempTipoDeduccion table( Sec INT IDENTITY(1,1)
										,TipoDeduccion XML );	
			DECLARE @tempTipoDocId table( Sec INT IDENTITY(1,1)
										,TipoDocId XML );
			DECLARE @tempTipoJornada table( Sec INT IDENTITY(1,1)
										,TipoJornada XML );	
			DECLARE @tempEmpleado table ( Sec INT IDENTITY(1,1)
											,Empleado XML );

			---Declarar variables a utilizar
			---Variables para iterar
			DECLARE @hi INT				---Iteracion Tabla Feriados
			DECLARE @hi1 INT			---Iteracion Tabla Error
			DECLARE @hi2 INT			---Iteracion Tabla TipoDeduccion
			DECLARE @hi3 INT			---Iteracion Tabla TipoEvento
			DECLARE @hi4 INT			---Iteracion Tabla Puestos
			DECLARE @hi5 INT			---Iteracion Tabla TipoJornada
			DECLARE @hi6 INT			---Iteracion Tabla TipoMovimiento
			DECLARE @hi7 INT			---Iteracion Tabla Departamento
			DECLARE @hi8 INT			---Iteracion Tabla TipoDocId
			DECLARE @hi9 INT			---Iteracion Tabla Usuarios
			DECLARE @hi10 INT			---Iteracion Tabla Empleado

			--Variables para limitar iteracion
			DECLARE @lo INT = 1
			DECLARE @lo1 INT = 1
			DECLARE @lo2 INT = 1
			DECLARE @lo3 INT = 1
			DECLARE @lo4 INT = 1
			DECLARE @lo5 INT = 1
			DECLARE @lo6 INT = 1
			DECLARE @lo7 INT = 1
			DECLARE @lo8 INT = 1
			DECLARE @lo9 INT = 1
			DECLARE @lo10 INT = 1

			--Otras variables
			DECLARE @ObligatorioFlag BIT
			DECLARE @PorcentualFlag BIT
			DECLARE @IdTipoDeduccion INT


			--Iniciar a cargar nodos desde el xml a sus respectivas tablas

			----Cargar nodos de tipo de documento identidad del xml a su tabla
			INSERT INTO @tempTipoDocId ( TipoDocId )
			SELECT 
				tipoID.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/TiposdeDocumentodeIdentidad/TipoDocuIdentidad' ) AS X( tipoID );

			----Cargar nodos de tipo de jornada del xml a su tabla
			INSERT INTO @tempTipoJornada ( TipoJornada )
			SELECT 
				tipoJornada.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/TiposDeJornada/TipoDeJornada' ) AS X( tipoJornada );

			----Cargar nodos de tipo de puesto del xml a su tabla
			INSERT INTO @tempPuesto ( Puesto )
			SELECT 
				puesto.query( '.' ) 
			FROM 
				@xml.nodes( 'Catalogo/Puestos/Puesto' ) AS X( puesto );

			----Cargar nodos de departamento del xml a su tabla
			INSERT INTO @tempFeriado ( Feriado )
			SELECT 
				feriado.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/Feriados/Feriado' ) AS X( feriado );

			---Cargar nodos de tipos de movimiento del xml a su tabla
			INSERT INTO @tempTipoMovimiento ( TipoMovimiento )
			SELECT 
				tipoMov.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/TiposDeMovimiento/TipoDeMovimiento' ) AS X( tipoMov );

			---Cargar nodos de tipos de deducciones del xml a su tabla
			INSERT INTO @tempTipoDeduccion ( TipoDeduccion )
			SELECT 
				tipoDeduccion.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/TiposDeDeduccion/TipoDeDeduccion' ) AS X( tipoDeduccion );

			---Cargar nodos de tipos de evento del xml a su tabla
			INSERT INTO @tempTipoEvento ( TipoEvento )
			SELECT 
				tipoEvento.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/TiposdeEvento/TipoEvento' ) AS X( tipoEvento );

			---Cargar nodos de departamento del xml a su tabla
			INSERT INTO @tempDepartamento ( Departamento )
			SELECT 
				Departamento.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/Departamentos/Departamento' ) AS X( Departamento );

			---Cargar nodos de usuario del xml a su tabla
			INSERT INTO @tempUsuario ( Usuario )
			SELECT 
				Usuario.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/Usuarios/Usuario' ) AS X( Usuario );

			---Cargar nodos de empleado del xml a su tabla
			INSERT INTO @tempEmpleado ( Empleado )
			SELECT 
				Empleado.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/Empleados/Empleado' ) AS X( Empleado );

			---Cargar nodos de error del xml a su tabla
			INSERT INTO @tempError ( Error )
			SELECT 
				Error.query( '.' )
			FROM 
				@xml.nodes( 'Catalogo/Errores/Error' ) AS X( Error );

			---Asignar variables limitantes para iteracion

			SELECT 
				@hi= max(F.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempFeriado AS F;

			SELECT 
				@hi1= max(E.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempError AS E;

			SELECT 
				@hi2= max(TD.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempTipoDeduccion AS TD;

			SELECT 
				@hi3= max(TE.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempTipoEvento AS TE;

			SELECT 
				@hi4= max(P.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempPuesto AS P;

			SELECT 
				@hi5= max(TJ.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempTipoJornada AS TJ;

			SELECT 
				@hi6= max(TM.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempTipoMovimiento AS TM;

			SELECT 
				@hi7= max(D.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempDepartamento AS D;

			SELECT 
				@hi8= max(TDI.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempTipoDocId AS TDI;

			SELECT 
				@hi9= max(U.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempUsuario AS U;

			SELECT 
				@hi10= max(E.Sec) ---Obtener cant. filas a iterar
			FROM 
				@tempEmpleado AS E;

			---Comienza inserci�n de datos desde tablas variables a tablas del proyecto
			BEGIN TRANSACTION InsertarDatos

			--Inserta fecha y nombre de feriados
			WHILE ( @lo<=@hi )
			BEGIN
				INSERT INTO dbo.Feriado ( id
					, Nombre
					, Fecha )
				SELECT 
					T.Feriado.value( '(/Feriado/@Id)[1]', 'INT' ),
					T.Feriado.value( '(/Feriado/@Nombre)[1]', 'VARCHAR(64)' ),
					T.Feriado.value( '(/Feriado/@Fecha)[1]', 'DATE' )
				FROM 
					@tempFeriado AS T
				WHERE
					T.Sec = @lo

				SET @lo = @lo + 1
			END;

			--Insertar errores
			WHILE ( @lo1<=@hi1 )
			BEGIN
				INSERT INTO dbo.Error ( Codigo
					,Descripcion )
				SELECT 
					E.Error.value( '(/Error/@Codigo)[1]', 'INT' ),
					E.Error.value( '(/Error/@Descripcion)[1]', 'VARCHAR(1024)' )
				FROM 
					@tempError AS E
				WHERE
					E.Sec = @lo1

				SET @lo1 = @lo1 + 1
			END;

			--Insertar tipo de deduccion
			WHILE ( @lo2<=@hi2 )
			BEGIN
				---Revisar si el tipo de deducci�n es obligatoria
				IF ( SELECT 
						TD.TipoDeduccion.value( '(/TipoDeDeduccion/@Obligatorio)[1]', 'VARCHAR(64)' )
					FROM 
						@tempTipoDeduccion AS TD 
					WHERE 
						TD.Sec = @lo2 ) = 'Si'
				BEGIN
					SET @ObligatorioFlag = 1; ---Es deducci�n obligatoria
				END;
				ELSE
				BEGIN
					SET @ObligatorioFlag = 0; ---No es deducci�n obligatoria
				END;

				---Revisar si el tipo de deduccion es porcentual
				IF ( SELECT TD.TipoDeduccion.value( '(/TipoDeDeduccion/@Porcentual)[1]', 'VARCHAR(64)' )
					FROM @tempTipoDeduccion AS TD 
					WHERE TD.Sec = @lo2 ) = 'Si'
				BEGIN
					SET @PorcentualFlag = 1; ---Es deduccion porcentual
				END;
				ELSE
				BEGIN
					SET @PorcentualFlag = 0; ---No es deducci�n porcentual
				END;

				--Obtener ID del tipo de deduccion a insertar
				SELECT 
					@IdTipoDeduccion = TD.TipoDeduccion.value( '(/TipoDeDeduccion/@Id)[1]', 'INT' )
				FROM 
					@tempTipoDeduccion AS TD
				WHERE
					TD.Sec = @lo2

				--Insertar valores a tabla de tipo de deduccion
				INSERT INTO dbo.tipoDeduccion( id
					,Nombre 
					,FlagObligatorio
					,FlagPorcentual )
				SELECT 
					@IdTipoDeduccion,
					TD.TipoDeduccion.value( '(/TipoDeDeduccion/@Nombre)[1]', 'VARCHAR(64)' ),
					@ObligatorioFlag
					,@PorcentualFlag
				FROM 
					@tempTipoDeduccion AS TD
				WHERE
					TD.Sec = @lo2
				
				

				--Si es deduccion procentual, se actualiza tabla heredada TDPorcentual
				IF @PorcentualFlag = 1
				BEGIN
					INSERT INTO dbo.TipoDeduccionPorcentual( idTipoDeduccion
						,valor )
					SELECT
						@IdTipoDeduccion
						,TD.TipoDeduccion.value( '(/TipoDeDeduccion/@Valor)[1]', 'DECIMAL(18,5)' )
					FROM
						@tempTipoDeduccion AS TD
					WHERE
						TD.Sec = @lo2
				END;

				SET @lo2 = @lo2 + 1
			END;

			--Insertar id y nombre de tabla variable a tabla evento
			WHILE ( @lo3<=@hi3 )
			BEGIN
				INSERT INTO dbo.TipoEvento ( Id
					, Nombre )
				SELECT 
					T.TipoEvento.value( '(/TipoEvento/@Id)[1]', 'INT' ),
					T.TipoEvento.value( '(/TipoEvento/@Nombre)[1]', 'VARCHAR(64)' )
				FROM 
					@tempTipoEvento AS T
				WHERE
					T.Sec = @lo3

				SET @lo3 = @lo3 +1
			END;

			--Insertar valores de tabla variable a tabla puesto
			WHILE ( @lo4 <= @hi4 )
			BEGIN

				INSERT INTO dbo.Puesto ( Id
					, Nombre
					, SalarioXHora )
				SELECT
					P.Puesto.value( '(/Puesto/@Id)[1]', 'INT' ),
					P.Puesto.value( '(/Puesto/@Nombre)[1]', 'VARCHAR(64)' ),
					P.Puesto.value( '(/Puesto/@SalarioXHora)[1]', 'MONEY' )
				FROM 
					@tempPuesto AS P
				WHERE
					P.Sec = @lo4

				SET @lo4 = @lo4 + 1
			END;

			--Insertar valores de tabla variable a tabla tipo de jornada
			WHILE ( @lo5 <= @hi5 )
			BEGIN

				INSERT INTO dbo.TipoJornada( id
					, Nombre
					, HoraInicio
					, HoraFin )
				SELECT 
					TJ.TipoJornada.value( '(/TipoDeJornada/@Id)[1]', 'INT' ),
					TJ.TipoJornada.value( '(/TipoDeJornada/@Nombre)[1]', 'VARCHAR(64)' ),
					TJ.TipoJornada.value( '(/TipoDeJornada/@HoraInicio)[1]', 'TIME' ),
					TJ.TipoJornada.value( '(/TipoDeJornada/@HoraFin)[1]', 'TIME' )
				FROM 
					@tempTipoJornada AS TJ
				WHERE
					TJ.Sec = @lo5

				SET @lo5 = @lo5 + 1
			END;

			---Inserta valor de tabla variable a tabla de tipo de movimiento
			WHILE ( @lo6 <= @hi6 )
			BEGIN
				INSERT INTO dbo.TipoMovimiento ( Id
					, Nombre )
				SELECT 
					T.TipoMovimiento.value( '(/TipoDeMovimiento/@Id)[1]', 'INT' ),
					T.TipoMovimiento.value( '(/TipoDeMovimiento/@Nombre)[1]', 'VARCHAR(64)' )
				FROM 
					@tempTipoMovimiento AS T
				WHERE
					T.Sec = @lo6

				SET @lo6 = @lo6 +1 
			END;

			---Inserta valor de tabla variable a tabla departamento
			WHILE ( @lo7 <= @hi7 )
			BEGIN
				INSERT INTO dbo.Departamento( Id
					, Nombre )
				SELECT 
					D.Departamento.value( '(/Departamento/@Id)[1]', 'INT' ),
					D.Departamento.value( '(/Departamento/@Nombre)[1]', 'VARCHAR(64)' )
				FROM 
					@tempDepartamento AS D
				WHERE
					D.Sec = @lo7

				SET @lo7 = @lo7 +1 
			END;

			---Inserta valor de tabla variable a tabla doc identidad
			WHILE ( @lo8 <= @hi8 )
			BEGIN
				INSERT INTO dbo.TipoDocId( Id
					, Nombre )
				SELECT 
					TDI.TipoDocId.value( '(/TipoDocuIdentidad/@Id)[1]', 'INT' ),
					TDI.TipoDocId.value( '(/TipoDocuIdentidad/@Nombre)[1]', 'VARCHAR(64)' )
				FROM 
					@tempTipoDocId AS TDI
				WHERE
					TDI.Sec = @lo8

				SET @lo8 = @lo8 +1 
			END;

			--Insertar usuarios
			WHILE ( @lo9<=@hi9 )
			BEGIN
				INSERT INTO dbo.Usuario( Id
					,Nombre
					,Contraseña
					,IdTipoUsuario )
				SELECT 
					U.Usuario.value( '(/Usuario/@Id)[1]', 'INT' ),
					U.Usuario.value( '(/Usuario/@Username)[1]', 'VARCHAR(64)' ),
					U.Usuario.value( '(/Usuario/@Password)[1]', 'VARCHAR(64)' ),
					TU.id
				FROM 
					@tempUsuario AS U
				INNER JOIN dbo.TipoUsuario AS TU
				ON U.Usuario.value( '(/Usuario/@Tipo)[1]', 'VARCHAR(64)' ) = TU.id
				WHERE
					U.Sec = @lo9

				SET @lo9 = @lo9 + 1
			END;

			---Insertar Empleados
			WHILE ( @lo10<=@hi10 )
			BEGIN
				INSERT INTO dbo.Empleado( Nombre
					,IdTipoValorDocIdentidad
					,ValorDocumentoIdentidad
					,FechaNacimiento
					,IdDepartamento
					,IdPuesto
					,IdUsuario
					,EsActivo)
				SELECT 
					E.Empleado.value( '(/Empleado/@Nombre)[1]', 'VARCHAR(64)' ),
					TDI.id,
					E.Empleado.value( '(/Empleado/@ValorDocumento)[1]', 'VARCHAR(64)' ),
					E.Empleado.value( '(/Empleado/@FechaNacimiento)[1]', 'DATE' ),
					D.id,
					P.id,
					U.id,
					E.Empleado.value( '(/Empleado/@Activo)[1]', 'INT' )
				FROM 
					@tempEmpleado AS E
				INNER JOIN dbo.TipoDocId AS TDI
				ON E.Empleado.value( '(/Empleado/@IdTipoDocumento)[1]', 'INT' ) = TDI.id
				INNER JOIN dbo.Departamento AS D
				ON E.Empleado.value( '(/Empleado/@IdDepartamento)[1]', 'INT' ) = D.id
				INNER JOIN dbo.Puesto AS P
				ON E.Empleado.value( '(/Empleado/@IdPuesto)[1]', 'INT' ) = P.id
				INNER JOIN dbo.Usuario AS U
				ON E.Empleado.value( '(/Empleado/@IdUsuario)[1]', 'INT' ) = U.id
				WHERE
					E.Sec = @lo10

				SET @lo10 = @lo10 + 1
			END;

			COMMIT TRANSACTION InsertarDatos

		END TRY
		BEGIN CATCH

			IF @@TRANCOUNT>0
			BEGIN
				ROLLBACK TRANSACTION InsertarDatos;
			END;

			INSERT INTO dbo.DBError VALUES
			(
				SUSER_NAME(),
				ERROR_NUMBER(),
				ERROR_STATE(),
				ERROR_SEVERITY(),
				ERROR_LINE(),
				ERROR_PROCEDURE(),
				ERROR_MESSAGE(),
				GETDATE()
			);

		SET @outResultCode = 50008;---C�digo error en base de datos

		END CATCH

	SET NOCOUNT OFF;

END;
GO


