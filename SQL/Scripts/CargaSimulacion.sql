USE [DBProject]
GO
/****** Object:  StoredProcedure [dbo].[CargaSimulacion]    Script Date: 27/5/2025 14:15:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[CargaSimulacion](
	@inArchivoXML NVARCHAR( MAX ) 
	,@outResultCode INT OUTPUT )
AS
BEGIN

	SET NOCOUNT ON;
	
	BEGIN TRY

		SET @outResultCode = 0; --Codigo éxito

		--Convertir el XML de tipo VARCHAR a tipo XML
		DECLARE @xml XML
		SET @xml = CAST( @inArchivoXML AS XML )
		
		--Declarar tablas variables para cada tipo de nodo de accion
		DECLARE @tempFecha TABLE ( Sec INT IDENTITY(1,1)
										,FechaProceso DATE );

		DECLARE @tempInsercionEmpleados TABLE ( Sec INT IDENTITY(1,1)
										,FechaProceso DATE
										,InsercionEmpleado XML );

		DECLARE @tempEliminarEmpleados TABLE ( Sec INT IDENTITY(1,1)
										,FechaProceso DATE
										,EliminarEmpleados XML );

		DECLARE @tempAsociarDeduccion TABLE ( Sec INT IDENTITY(1,1)
										,FechaProceso DATE
										,AsociarDeduccion XML );

		DECLARE @tempDesasociarDeduccion TABLE ( Sec INT IDENTITY(1,1)
										,FechaProceso DATE
										,DesasociarDeduccion XML );

		DECLARE @tempActualizarJornadas TABLE ( Sec INT IDENTITY(1,1)
										,FechaProceso DATE
										,ActualizarJornadas XML );

		DECLARE @tempMarcasAsistencia TABLE ( Sec INT IDENTITY(1,1)
										,FechaProceso DATE
										,MarcasAsistencia XML );

		---Declarar variables a utilizar

		---Variables para iterar
		DECLARE @hi INT				---Iteracion Tabla Fecha
		DECLARE @hi2 INT			---Iteracion Tabla InsercionEmpleados
		DECLARE @hi3 INT			---Iteracion Tabla EliminarEmpleados
		DECLARE @hi4 INT			---Iteracion Tabla AsociarDeduccion
		DECLARE @hi5 INT			---Iteracion Tabla DesasociarDeduccion
		DECLARE @hi6 INT			---Iteracion Tabla ActualizarJornada
		DECLARE @hi7 INT			---Iteracion Tabla MarcasAsistencia

		--Variables para limitar iteracion
		DECLARE @lo INT = 1
		DECLARE @lo2 INT = 1
		DECLARE @lo3 INT = 1
		DECLARE @lo4 INT = 1
		DECLARE @lo5 INT = 1
		DECLARE @lo6 INT = 1
		DECLARE @lo7 INT = 1

		--Otras variables
		DECLARE @FechaActual DATE
		DECLARE @IdEmpleadoXTipoDeduccion INT
		DECLARE @IdTipoDeduccion INT
		DECLARE @IdEmpleado INT

		--Iniciar a cargar nodos desde el xml a sus respectivas tablas

		----Cargar fechas de los procesos
		INSERT INTO @tempFecha ( FechaProceso )
		SELECT 
			fecha.value('@Fecha', 'DATE')
		FROM 
			@xml.nodes( 'Operacion/FechaOperacion' ) AS X( fecha );

		----Cargar asociaciones de empleados con deducciones
		INSERT INTO @tempAsociarDeduccion ( AsociarDeduccion,FechaProceso )
		SELECT 
			A.query('.'),                                        
			F.value( '@Fecha', 'DATE' )     
		FROM 
			@xml.nodes('Operacion/FechaOperacion') AS X( F )
		CROSS APPLY 
			F.nodes('AsociacionEmpleadoDeducciones/AsociacionEmpleadoConDeduccion') AS Asociaciones( A );

		----Cargar desasociaciones de empleados con deducciones
		INSERT INTO @tempDesasociarDeduccion ( DesasociarDeduccion,FechaProceso )
		SELECT 
			D.query('.'),                                        
			F.value( '@Fecha', 'DATE' )    
		FROM 
			@xml.nodes( 'Operacion/FechaOperacion' ) AS X( F )
		CROSS APPLY 
			F.nodes( 'DesasociacionEmpleadoDeducciones/DesasociacionEmpleadoConDeduccion' ) AS Desociaciones( D );

		----Cargar jornadas a aplicar
		INSERT INTO @tempActualizarJornadas ( ActualizarJornadas,FechaProceso )
		SELECT 
			J.query('.'),                                        
			F.value( '@Fecha', 'DATE' )    
		FROM 
			@xml.nodes( 'Operacion/FechaOperacion' ) AS X( F )
		CROSS APPLY 
			F.nodes( 'JornadasProximaSemana/TipoJornadaProximaSemana' ) AS Jornadas( J );

		----Cargar marcas de asistencia
		INSERT INTO @tempMarcasAsistencia ( MarcasAsistencia,FechaProceso )
		SELECT 
			M.query('.'),                                        
			F.value( '@Fecha', 'DATE' )    
		FROM 
			@xml.nodes( 'Operacion/FechaOperacion' ) AS X( F )
		CROSS APPLY 
			F.nodes( 'MarcasAsistencia/MarcaDeAsistencia' ) AS Marcas( M );


		----****************Falta cargar tablas de insercion y eliminacion empleados********************************************

		---Asignar variables limitantes para iteracion

		SELECT 
			@hi= max(F.Sec) ---Obtener cant. filas a iterar
		FROM 
			@tempFecha AS F;

		SELECT 
			@hi2= max(I.Sec) ---Obtener cant. filas a iterar
		FROM 
			@tempInsercionEmpleados AS I;

		SELECT 
			@hi3= max(E.Sec) ---Obtener cant. filas a iterar
		FROM 
			@tempEliminarEmpleados AS E;

		SELECT 
			@hi4= max(A.Sec) ---Obtener cant. filas a iterar
		FROM 
			@tempAsociarDeduccion AS A;

		SELECT 
			@hi5= max(D.Sec) ---Obtener cant. filas a iterar
		FROM 
			@tempDesasociarDeduccion AS D;

		SELECT 
			@hi6= max(A.Sec) ---Obtener cant. filas a iterar
		FROM 
			@tempActualizarJornadas AS A;

		SELECT 
			@hi7= max(M.Sec) ---Obtener cant. filas a iterar
		FROM 
			@tempMarcasAsistencia AS M;


		---Inicio de cargar a tablas de base de datos
		BEGIN TRANSACTION ActualizarDatos
			
			WHILE( @lo<=@hi ) ---Comienza iteración por cada fecha de proceso
			BEGIN
				
				---Reiniciar variables limitantes
				SET  @lo2 = 0;
				SET  @lo3 = 0;
				SET  @lo4 = 0;
				SET  @lo5 = 0;
				SET  @lo6 = 0;
				SET  @lo7 = 0;

				SELECT @FechaActual = T.FechaProceso ---Obtener fecha en la que se está iterando
				FROM @tempFecha AS T
				WHERE T.Sec = @lo

				WHILE( @lo2<= @hi2 ) ---Insertar Empleados de esta fecha
				BEGIN
					SET @lo2 = @lo2+1
				END;

				WHILE( @lo3<= @hi3 ) ---Eliminar Empleados de esta fecha
				BEGIN
					SET @lo3 = @lo3+1
				END;

				WHILE( @lo4<= @hi4 ) ---Asociar deducciones en esta fecha
				BEGIN

					---Revisar si hay deducciones que hacer esa fecha
					IF EXISTS (
						SELECT 1 
						FROM @tempAsociarDeduccion A 
						WHERE @lo4 = A.Sec 
						AND  A.FechaProceso = @FechaActual )
					BEGIN
						
						SELECT
							@IdTipoDeduccion = TD.id --Obtener tipo de deduccion que se está procesando
						FROM
							@tempAsociarDeduccion AS A
						INNER JOIN DBO.TipoDeduccion AS TD
						ON TD.id = A.AsociarDeduccion.value('(/AsociacionEmpleadoConDeduccion/@IdTipoDeduccion)[1]', 'INT' )
						WHERE 
							@lo4 = A.Sec

						--Conectar empleado con tipo de deduccion por medio de tabla empleadoxtipodeduccion
						INSERT INTO DBO.EmpleadoXTipoDeduccion (
							idEmpleado
							,idTipoDeduccion )
						SELECT
							E.id
							, @IdTipoDeduccion
						FROM 
							dbo.Empleado AS E
							, @tempAsociarDeduccion AS A
						WHERE
							A.AsociarDeduccion.value('(/AsociacionEmpleadoConDeduccion/@ValorTipoDocumento)[1]', 'VARCHAR(64)' ) = E.ValorDocumentoIdentidad
							AND A.Sec = @lo4

						SET @IdEmpleadoXTipoDeduccion = SCOPE_IDENTITY(); --Obtener id de empleado x tipoDeduccion

						---Actualizar tabla empleadoxtipodeduccionnoobligatoria
						INSERT INTO DBO.EmpleadoXTipoDeduccionNoObligatoria (
							idEmpleadoXTipoDeduccion
							,FechaInicio )
						VALUES (
							@IdEmpleadoXTipoDeduccion --Id se hereda
							,@FechaActual )

						---Revisar si deduccion es fija
						IF NOT EXISTS (SELECT 1 FROM DBO.TipoDeduccionPorcentual D WHERE D.idTipoDeduccion = @IdTipoDeduccion)
						BEGIN
							INSERT INTO DBO.EmpleadoXTipoDeduccionNoObligatoriaNoPorcentual (
								idEmpleadoXTipoDeduccionNoObligatoria
								,Valor)
							SELECT
								@IdEmpleadoXTipoDeduccion --Id se hereda
								, A.AsociarDeduccion.value('(/AsociacionEmpleadoConDeduccion/@Monto)[1]', 'INT' )
							FROM
								@tempAsociarDeduccion AS A
							WHERE
								A.Sec = @lo4
						END

					END;
					SET @lo4 = @lo4+1
				END;

				WHILE( @lo5<= @hi5 ) ---Desasociar deducciones en esta fecha
				BEGIN

					---Revisar si hay deducciones que desasociar esa fecha
					IF EXISTS (
						SELECT 1 
						FROM @tempDesasociarDeduccion A 
						WHERE @lo5 = A.Sec 
						AND  A.FechaProceso = @FechaActual )
					BEGIN

						SELECT
							@IdTipoDeduccion = TD.id --Obtener tipo de deduccion que se está procesando
						FROM
							@tempDesasociarDeduccion AS A
						INNER JOIN DBO.TipoDeduccion AS TD
						ON TD.id = A.DesasociarDeduccion.value('(/DesasociacionEmpleadoConDeduccion/@IdTipoDeduccion)[1]', 'INT' )
						WHERE 
							@lo4 = A.Sec	
							
						SELECT 
							@IdEmpleadoXTipoDeduccion = EXTD.id ---Obtener id para el archive
						FROM
							@tempDesasociarDeduccion AS A
							,DBO.Empleado AS E
						INNER JOIN DBO.EmpleadoXTipoDeduccion AS EXTD
						ON E.Id = EXTD.idEmpleado
						WHERE
							A.DesasociarDeduccion.value('(/DesasociacionEmpleadoConDeduccion/@ValorTipoDocumento)[1]', 'VARCHAR(64)' ) = E.ValorDocumentoIdentidad
							AND EXTD.idTipoDeduccion = @IdTipoDeduccion
							AND @lo4 = A.Sec
						
						---Actualizar archive de deducciones no obligatorias
						INSERT INTO DBO.EmpleadoXTipoDeduccionNoObligatoriaArchive (
							idEmpleadoXTipoDeduccionNoObligatoria
							, FechaInicio
							,FechaFin )
						SELECT 
							E.idEmpleadoXTipoDeduccion
							, E.FechaInicio
							,@FechaActual
						FROM
							DBO.EmpleadoXTipoDeduccionNoObligatoria AS E
						WHERE
							E.idEmpleadoXTipoDeduccion = @IdEmpleadoXTipoDeduccion
					END;

					SET @lo5 = @lo5+1
				END;

				IF DATENAME( weekday,@FechaActual ) = 'Thursday' ---Actualizar jornadas Y cierre si es jueves
				BEGIN
					WHILE( @lo6<= @hi6 )
					BEGIN
						SET @lo6 = @lo6+1
					END;
				END

				WHILE( @lo7<= @hi7 ) ---Procesar marcas de asistencia de esa fecha
				BEGIN
					SET @lo7 = @lo7+1
				END;

				SET @lo = @lo +1
			END

		COMMIT TRANSACTION ActualizarDatos

	END TRY
	BEGIN CATCH
	
		IF @@TRANCOUNT>0
		BEGIN
			ROLLBACK TRANSACTION ActualizarDatos;
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
		
		SET @outResultCode = 50008;
	END CATCH

	SET NOCOUNT OFF;

END;
