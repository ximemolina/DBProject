USE [DBProject]
GO

/****** Object:  StoredProcedure [dbo].[CargarDatos]    Script Date: 22/5/2025 13:29:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[CargaSimulacion](
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

		DECLARE @tempDeducciones TABLE ( Sec INT IDENTITY(1,1)
										,idEmpleadoXTipoDeduccion INT
										,idEmpleado INT
										, idTipoDeduccion INT );

		DECLARE @tempAsociacionesPendientes TABLE( Sec INT IDENTITY(1,1)
										,idTipoEvento INT
										,idTipoDeduccion INT
										, idEmpleado INT
										, valorDeduccion DECIMAL ( 10,5 )
										,descripcion VARCHAR( 1024 ) 
										,monto INT )

		DECLARE @tempDesasociacionesPendientes TABLE( Sec INT IDENTITY(1,1)
										,idTipoEvento INT
										,idTipoDeduccion INT
										, idEmpleado INT
										, idEmpleadoXTipoDeduccion INT
										, descripcion VARCHAR ( 1024 ) )

		---Declarar variables a utilizar

		---Variables para iterar
		DECLARE @hi INT				---Iteracion Tabla Fecha
		DECLARE @hi2 INT			---Iteracion Tabla InsercionEmpleados
		DECLARE @hi3 INT			---Iteracion Tabla EliminarEmpleados
		DECLARE @hi4 INT			---Iteracion Tabla AsociarDeduccion
		DECLARE @hi5 INT			---Iteracion Tabla DesasociarDeduccion
		DECLARE @hi6 INT			---Iteracion Tabla ActualizarJornada
		DECLARE @hi7 INT			---Iteracion Tabla MarcasAsistencia
		DECLARE @hi8 INT = 0		---Iteracion Tabla Deducciones
		DECLARE @hi9 INT = 0		---Iteracion Tabla MesPlanilla
		DECLARE @hi10 INT = 0		---Iteracion Tabla AsociacionesPendientes
		DECLARE @hi11 INT = 0		---Iteracion Tabla DesasociacionesPendientes

		--Variables para limitar iteracion
		DECLARE @lo INT = 1
		DECLARE @lo2 INT = 1
		DECLARE @lo3 INT = 1
		DECLARE @lo4 INT = 1
		DECLARE @lo5 INT = 1
		DECLARE @lo6 INT = 1
		DECLARE @lo7 INT = 1
		DECLARE @lo8 INT = 1
		DECLARE @lo9 INT = 1
		DECLARE @lo10 INT = 1
		DECLARE @lo11 INT = 1

		--Otras variables
		DECLARE @FechaActual DATE
		DECLARE @IdEmpleadoXTipoDeduccion INT
		DECLARE @IdTipoDeduccion INT
		DECLARE @IdEmpleado INT
		DECLARE @NombreEmpleado VARCHAR( 64 )
		DECLARE @IdTipoDocId INT
		DECLARE @TipoDocId VARCHAR( 64 )
		DECLARE @DocId VARCHAR( 64 )
		DECLARE @FechaNac DATE
		DECLARE @IdPuesto INT
		DECLARE @Puesto VARCHAR( 64 )
		DECLARE @IdDepartamento INT
		DECLARE @Departamento VARCHAR( 64 )
		DECLARE @UsuarioEmpleado VARCHAR( 64 )
		DECLARE @Password VARCHAR( 64 )
		DECLARE @ultIdUsuario INT
		DECLARE @Descripcion VARCHAR( 1024 )
		DECLARE @IdTipoEvento INT
		DECLARE @IdPostByUser INT = 5 ---Usuario especificado para Script
		DECLARE @IpAdress VARCHAR( 64 ) = '108.181.197.183' ---IpAdress del servidor
		DECLARE @ValorDeduccion DECIMAL( 10,5 ) 
		DECLARE @IdMesPlanilla INT
		DECLARE @FechaFinSemana DATE
		DECLARE @IdSemanaPlanilla INT
		DECLARE @FechaFinMes DATE
		DECLARE @FechaInicio DATE
		DECLARE @IdEmpleadoXSemanaPlanilla INT
		DECLARE @IdTipoJornada INT
		DECLARE @MontoDeduccion MONEY
		DECLARE @SalarioBruto MONEY
		DECLARE @PorcentajeDeduccion DECIMAL ( 10,5 )
		DECLARE @IdTipoMov INT
		DECLARE @IdMovimientoPlanilla INT
		DECLARE @NumSemanas INT
		DECLARE @SumaDeducciones MONEY
		DECLARE @MontoTotal DECIMAL ( 10,5 )
		DECLARE @IdEmpleadoMesPlanilla INT

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

		----Cargar empleados a insertar
		INSERT INTO @tempInsercionEmpleados (InsercionEmpleado, FechaProceso)
		SELECT 
			I.query('.'),
			F.value( '@Fecha', 'DATE')
		FROM
			@xml.nodes( 'Operacion/FechaOperacion' ) AS X ( F )
		CROSS APPLY
			F.nodes( 'NuevosEmpleados/NuevoEmpleado' ) AS Inserciones( I );

		----Cargar empleados a eliminar
		INSERT INTO @tempEliminarEmpleados (EliminarEmpleados, FechaProceso)
		SELECT 
			E.query('.'),
			F.value( '@Fecha', 'DATE')
		FROM
			@xml.nodes( 'Operacion/FechaOperacion' ) AS X ( F )
		CROSS APPLY
			F.nodes( 'EliminarEmpleados/EliminarEmpleado' ) AS Eliminaciones( E );

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
				
				SELECT @FechaActual = T.FechaProceso ---Obtener fecha en la que se está iterando
				FROM @tempFecha AS T
				WHERE T.Sec = @lo

				WHILE( @lo2<= @hi2 ) ---Insertar Empleados de esta fecha
				BEGIN
					---Revisar si hay insersion de empleados
					IF EXISTS (
						SELECT 1
						FROM	@tempInsercionEmpleados I
						WHERE @lo2 = I.Sec
						AND I.FechaProceso = @FechaActual )
					BEGIN
						---Obtener datos para el EventLog
						SET @IdTipoEvento = 5;	---Id insercion de empleado

						SET @ultIdUsuario = ( SELECT MAX(U.id)
												FROM dbo.Usuario AS U ) + 1

						SELECT	--Obtener nombre del empleado
							@NombreEmpleado = I.InsercionEmpleado.value( '(/NuevoEmpleado/@Nombre)[1]' , 'VARCHAR(64)' )
						FROM
							@tempInsercionEmpleados AS I
						WHERE
							@lo2 = I.Sec

						SELECT	--Obtener IdTipoDocId
							@IdTipoDocId = TD.id
						FROM	
							@tempInsercionEmpleados AS I
						INNER JOIN
							DBO.TipoDocId AS TD
						ON
							TD.id = I.InsercionEmpleado.value( '(/NuevoEmpleado/@IdTipoDocumento)[1]' , 'INT' )
						WHERE
							@lo2 = I.Sec
							
						SELECT	--Obtener TipoDocId
							@TipoDocId = TD.Nombre
						FROM
							DBO.TipoDocId AS TD
						WHERE
							TD.id = @IdTipoDocId

						SELECT	--Obtener DocId
							@DocId = I.InsercionEmpleado.value( '(/NuevoEmpleado/@ValorTipoDocumento)[1]' , 'VARCHAR(64)' ) 
						FROM
							@tempInsercionEmpleados AS I
						WHERE
							@lo2 = I.Sec

						SELECT	--Obtener FechaNac
							@FechaNac = I.InsercionEmpleado.value( '(/NuevoEmpleado/@FechaNacimiento)[1]' , 'DATE' )
						FROM
							@tempInsercionEmpleados AS I
						WHERE
							@lo2 = I.Sec

						SELECT	--Obtener Puesto
							@Puesto = P.Nombre
						FROM
							@tempInsercionEmpleados AS I
						INNER JOIN
							DBO.Puesto AS P
						ON
							P.Nombre = I.InsercionEmpleado.value( '(/NuevoEmpleado/@NombrePuesto)[1]' , 'VARCHAR(64)' )
						WHERE
							@lo2 = I.Sec

						SELECT	--Obtener IdPuesto
							@IdPuesto = P.id
						FROM
							DBO.Puesto AS P
						WHERE
							P.Nombre = @Puesto

						SELECT	--Obtener IdDepartamento
							@IdDepartamento = D.id
						FROM
							@tempInsercionEmpleados AS I
						INNER JOIN
							DBO.Departamento AS D
						ON
							D.id = I.InsercionEmpleado.value( '(/NuevoEmpleado/@IdDepartamento)[1]' , 'INT' )
						WHERE
							@lo2 = I.Sec

						SELECT	--Obtener Departamento
							@Departamento = D.Nombre
						FROM
							DBO.Departamento AS D
						WHERE
							D.id = @IdDepartamento

						SELECT	--Obtener UsuarioEmpleado
							@UsuarioEmpleado = I.InsercionEmpleado.value( '(/NuevoEmpleado/@Usuario)[1]' , 'VARCHAR(64)' )
						FROM
							@tempInsercionEmpleados AS I
						WHERE
							@lo2 = I.Sec

						SELECT	--Obtener Password
							@Password = I.InsercionEmpleado.value( '(/NuevoEmpleado/@Password)[1]' , 'VARCHAR(64)' )
						FROM
							@tempInsercionEmpleados AS I
						WHERE
							@lo2 = I.Sec

						SET @Descripcion = ( ' Nombre: '
											+ CONVERT( VARCHAR(64) , @NombreEmpleado )
											+ '. '
											+ CONVERT( VARCHAR( 64 ), @TipoDocId)
											+ ': '
											+ CONVERT( VARCHAR(64) , @DocId )
											+ '. Fecha de nacimiento: '
											+ CONVERT( VARCHAR(64) , @FechaNac )
											+ '. Puesto: '
											+ CONVERT( VARCHAR(64) , @Puesto ) 
											+ '. Departamento: '
											+ CONVERT( VARCHAR(64) , @Departamento )
											+ '. Usuario: '
											+ CONVERT( VARCHAR(64), @UsuarioEmpleado )
											+ '. Password: '
											+ CONVERT( VARCHAR(64), @Password ) );

						INSERT dbo.EventLog(	---Inserta Evento Insercion empleado
							IdTipoEvento
							,IdPostByUser
							,JSON
						) VALUES (
							@IdTipoEvento
							,@IdPostByUser
							,( SELECT 
									@IpAdress AS PostInIp,
									GETDATE() AS PostTime,
									'Insersion existosa' AS Resultado,
									@Descripcion AS Descripcion
							   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
						);

						INSERT INTO dbo.Usuario (	--INSERTAR TABLA USUARIO
							id
							, Nombre
							, Contraseña
							, IdTipoUsuario
						)
						VALUES (
							@ultIdUsuario
							, @UsuarioEmpleado
							, @Password
							, 2
						);
						
						INSERT INTO dbo.Empleado (	--INSERTAR TABLA EMPLEADO
							Nombre
							, IdTipoValorDocIdentidad
							, ValorDocumentoIdentidad
							, FechaNacimiento
							, IdPuesto
							, IdDepartamento
							, IdUsuario
							, EsActivo
						)
						VALUES (
							@NombreEmpleado
							, @IdTipoDocId
							, @DocId
							, @FechaNac
							, @IdPuesto
							, @IdDepartamento
							, @ultIdUsuario
							, 1
						);

					END;
					SET @lo2 = @lo2+1
				END;

				WHILE( @lo3<= @hi3 ) ---Eliminar Empleados de esta fecha
				BEGIN
					---Revisar si hay insersion de empleados
					IF EXISTS (
						SELECT 1
						FROM	@tempEliminarEmpleados AS E
						WHERE @lo3 = E.Sec
						AND E.FechaProceso = @FechaActual )
					BEGIN
						---Obtener datos para el EventLog
						SET @IdTipoEvento = 6;	---Id eliminacion de empleado

						SELECT	--Obtener DocId
							@DocId = E.ValorDocumentoIdentidad
						FROM
							@tempEliminarEmpleados AS EE
						INNER JOIN
							DBO.Empleado AS E
						ON
							E.ValorDocumentoIdentidad = EE.EliminarEmpleados.value( '(/EliminarEmpleado/@ValorTipoDocumento)[1]' , 'VARCHAR(64)' ) 
						WHERE
							@lo3 = EE.Sec

						SELECT	--Obtener NombreEmpleado
							@NombreEmpleado = E.Nombre
						FROM
							DBO.Empleado AS E
						WHERE
							E.ValorDocumentoIdentidad = @DocId

						SELECT	--Obtener TipoDocID
							@TipoDocId = TD.Nombre
						FROM
							DBO.Empleado AS E
						INNER JOIN
							DBO.TipoDocId AS TD
						ON
							E.IdTipoValorDocIdentidad = TD.id
						WHERE
							E.ValorDocumentoIdentidad = @DocId


						SELECT	--Obtener FechaNac
							@FechaNac = E.FechaNacimiento
						FROM
							DBO.Empleado AS E
						WHERE
							E.ValorDocumentoIdentidad = @DocId

						SELECT	--Obtener Puesto
							@Puesto = P.Nombre
						FROM
							DBO.Empleado AS E
						INNER JOIN
							DBO.Puesto AS P
						ON
							E.IdPuesto = P.id
						WHERE
							E.ValorDocumentoIdentidad = @DocId

						SELECT	--Obtener Departamento
							@Departamento = D.Nombre
						FROM
							DBO.Empleado AS E
						INNER JOIN
							DBO.Departamento AS D
						ON
							E.IdDepartamento = D.id
						WHERE
							E.ValorDocumentoIdentidad = @DocId

						SET @Descripcion = ( 'Nombre del Empleado: ' 
							+ CONVERT( VARCHAR(64) , @NombreEmpleado )
							+ '. Tipo documento identidad: '
							+ CONVERT( VARCHAR , @TipoDocId)
							+ '. Valor Documento de Identidad: ' 
							+ CONVERT( VARCHAR , @DocId ) 
							+ '. Fecha de nacimiento: '
							+ CONVERT( VARCHAR, @FechaNac)
							+ '. Puesto: ' 
							+ CONVERT( VARCHAR(64) , @Puesto )
							+ '. Departamento: '
							+ CONVERT( VARCHAR , @Departamento) );

						UPDATE E	--Eliminacion logica
						SET 
							E.EsActivo = 0
						FROM
							DBO.Empleado AS E
						WHERE 
							E.ValorDocumentoIdentidad = @DocId;
	
							INSERT dbo.EventLog(	---Inserta Evento Eliminacion empleado	
								IdTipoEvento
								,IdPostByUser
								,JSON
							) VALUES (
								@IdTipoEvento
								,@IdPostByUser
								,( SELECT 
										@IpAdress AS PostInIp,
										GETDATE() AS PostTime,
										@Descripcion AS Descripcion
								   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
							);
					END;
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
						
						---Obtener datos necesarios para Insert de EventLog

						SET @IdTipoEvento = 8 --Id Evento Asociacion Deducciones

						SELECT
							@IdTipoDeduccion = TD.id --Obtener tipo de deduccion que se está procesando
						FROM
							@tempAsociarDeduccion AS A
						INNER JOIN DBO.TipoDeduccion AS TD
						ON TD.id = A.AsociarDeduccion.value('(/AsociacionEmpleadoConDeduccion/@IdTipoDeduccion)[1]', 'INT' )
						WHERE
							@lo4 = A.Sec

						SELECT
							@IdEmpleado = E.id ---Obtener IdEmpleado que se está procesando
						FROM
							dbo.Empleado AS E
							, @tempAsociarDeduccion AS A
						WHERE
							A.AsociarDeduccion.value('(/AsociacionEmpleadoConDeduccion/@ValorTipoDocumento)[1]', 'VARCHAR(1024)' ) = E.ValorDocumentoIdentidad
							AND @lo4 = A.Sec

						IF (SELECT T.FlagPorcentual 
							FROM DBO.TipoDeduccion T 
							WHERE @IdTipoDeduccion = T.id) = 1 ---Si Deduccion es Porcentual
						BEGIN
							SELECT @ValorDeduccion = TD.valor --Obtener Valor Porcentual
							FROM DBO.TipoDeduccion T 
							INNER JOIN DBO.TipoDeduccionPorcentual TD
							ON T.id = TD.idTipoDeduccion ---Id Heredado
							WHERE @IdTipoDeduccion = T.id
						END
						ELSE ---Si deducción es fija
						BEGIN 
							SELECT @ValorDeduccion = A.AsociarDeduccion.value('(/AsociacionEmpleadoConDeduccion/@Monto)[1]', 'INT' )
							FROM
								@tempAsociarDeduccion AS A
							WHERE
								A.Sec = @lo4

						END

						SET @Descripcion = ( 'Id Empleado: ' 
								+ CONVERT( VARCHAR( 64 ) , @IdEmpleado ) 
								+ '. Id Deduccion: ' 
								+ CONVERT( VARCHAR( 64 ) , @IdTipoDeduccion ) 
								+ '. Valor Deduccion: ' 
								+ CONVERT( VARCHAR( 64 ) , @ValorDeduccion ) )

						INSERT INTO @tempAsociacionesPendientes (
							idTipoEvento
							,idTipoDeduccion
							,idEmpleado
							,valorDeduccion
							,descripcion 
							,monto )
						SELECT 
							@IdTipoEvento
							,@IdTipoDeduccion
							,@IdEmpleado
							,@ValorDeduccion
							,@Descripcion 
							,A.AsociarDeduccion.value('(/AsociacionEmpleadoConDeduccion/@Monto)[1]', 'INT' )
						FROM
							@tempAsociarDeduccion AS A
						WHERE
							A.Sec = @lo4
						
						SET @hi10 = @hi10 + 1 ---Solo se agrega una asociacion a la vez
					END;
					SET @lo4 = @lo4+1
				END;

				WHILE( @lo5<= @hi5 ) ---Desasociar deducciones en esta fecha
				BEGIN

					---Revisar si hay deducciones que desasociar esa fecha
					---Además validar que no se esté desasociando deduccion obligatoria
					IF EXISTS (
						SELECT 1 
						FROM @tempDesasociarDeduccion A 
						WHERE @lo5 = A.Sec 
						AND  A.FechaProceso = @FechaActual 
						AND A.DesasociarDeduccion.value('(/DesasociacionEmpleadoConDeduccion/@IdTipoDeduccion)[1]', 'INT' ) <> 1 )
					BEGIN

						SET @IdTipoEvento = 9 --Id Evento DesAsociacion Deducciones

						SELECT
							@IdTipoDeduccion = TD.id --Obtener tipo de deduccion que se está procesando
						FROM
							@tempDesasociarDeduccion AS A
						INNER JOIN DBO.TipoDeduccion AS TD
						ON TD.id = A.DesasociarDeduccion.value('(/DesasociacionEmpleadoConDeduccion/@IdTipoDeduccion)[1]', 'INT' )
						WHERE 
							@lo5 = A.Sec	

						SELECT
							@IdEmpleado = E.id ---Obtener IdEmpleado que se está procesando
						FROM
							dbo.Empleado AS E
							, @tempDesasociarDeduccion AS A
						WHERE
							A.DesasociarDeduccion.value('(/DesasociacionEmpleadoConDeduccion/@ValorTipoDocumento)[1]', 'VARCHAR(1024)' ) = E.ValorDocumentoIdentidad
							AND @lo5 = A.Sec	

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
							AND @lo5 = A.Sec

						SET @Descripcion = ( 'Id Empleado: ' 
								+ CONVERT( VARCHAR( 64 ) , @IdEmpleado ) 
								+ '. Id Deduccion: ' 
								+ CONVERT( VARCHAR( 64 ) , @IdTipoDeduccion ) )		
							
						---IDTIPOEVENTO, ID TIPO DEDUCCION, ID EMPLEADO, IDEMPLEADOXTIPODEDUCCION, DESCRIPCION
						INSERT INTO @tempDesasociacionesPendientes (
							idTipoEvento
							,idTipoDeduccion
							,idEmpleado
							,idEmpleadoXTipoDeduccion
							,descripcion )
						VALUES (
							@IdTipoEvento
							,@IdTipoDeduccion
							,@IdEmpleado
							,@IdEmpleadoXTipoDeduccion
							,@Descripcion )

						SET @hi11 = @hi11 + 1 ---se procesa una desasociacion a la vez
					END;

					SET @lo5 = @lo5+1
				END;

				WHILE( @lo7<= @hi7 ) ---Procesar marcas de asistencia de esa fecha
				BEGIN
					---------------------------------------------------------------------
					--- Si es jueves revisar que no se incluyan marcas de asistencia de jornadas nocturas (osea las
					--- que terminan al día siguiente). Estas marcas aplicarían para semana planilla proxima, no la actual
					--- Lo que se podría hacer para manejar estas marcas, sería guardarlas en una tabla variable
					--- Esta se iteraría al día siguiente (osea viernes y este día es al q pertenecen estas jornadas)
					--- Esta tabla variable siempre incluiría solo jornadas nocturas de jueves
					---------------------------------------------------------------------

					--- Inserta a tabla MarcaAsistencia

					--- Obtener la jornada de cada empleado de dbo.EmpleadoXTipoJornada

					--- hay que calcular horas trabajas y lo de salarios. Salario resultante será lo que se inserta
					--- en atributo monto de Mov.Planilla. Guardar las horas trabajadas en un variable, esta se utilizará
					--- para actualizar luego tabla Mov.Asistencia. Guardar salario resultante en variable para actualizar
					--- salario bruto de EmpleadoXSemanaPlanilla

					--- Si CantidadHoras son 8 o menos:
					---	Insertar Mov.Planilla para cantidad de horas trabajadas ordinarias
					---	Insertar Mov.Asistencia para cantidad de horas trabajadas ordinarias

					--- Si son más de 8 horas, se hace lo anterior pero tmb se generarían otros movs (Cant. horas trabajadas
					--- extras normales o cantidad de horas extras dobles trabajadas)
					--- En el peor caso, se harían 3 Inserts a Mov.Planilla y Mov.Asistencia
					
					--- Actualizar SalarioBruto de EmpleadoXSemanaPlanilla (sumarle a lo q tenga ya salario bruto)
					--- Insert a EventLog

					SET @lo7 = @lo7+1
				END;

				IF DATENAME( weekday,@FechaActual ) = 'Thursday' ---Actualizar jornadas Y cierre si es jueves
				BEGIN

					SELECT
						@IdSemanaPlanilla = S.id ---Asignar id de Semana Planilla
					FROM
						DBO.SemanaPlanilla AS S
					WHERE
						@FechaActual BETWEEN S.FechaInicio AND S.FechaFin

					INSERT INTO @tempDeducciones (
						idEmpleadoXTipoDeduccion
						,idEmpleado
						,idTipoDeduccion )
					SELECT
						ET.id
						, E.id
						, TD.id
					FROM
						DBO.EmpleadoXTipoDeduccion AS ET
					INNER JOIN DBO.Empleado AS E
					ON E.id = ET.idEmpleado
					INNER JOIN DBO.EmpleadoXTipoDeduccionNoObligatoria AS O
					ON O.idEmpleadoXTipoDeduccion = ET.id
					INNER JOIN DBO.TipoDeduccion AS TD
					ON TD.id = ET.idTipoDeduccion
					WHERE
						E.EsActivo = 1 --Empleado activo
					AND NOT EXISTS ( --- Deducción esté activa
							SELECT 1
							FROM DBO.EmpleadoXTipoDeduccionNoObligatoriaArchive AS A
							WHERE A.idEmpleadoXTipoDeduccionNoObligatoria =O.idEmpleadoXTipoDeduccion
						)
			
					SET @hi8 = @hi8 + @@ROWCOUNT --se maneja así pq tabla variable es IDENTITY
												-- entonces contador IDENTITY no se reinicia

					WHILE ( @lo8 <= @hi8 )
					BEGIN
						
						SELECT
							@IdEmpleadoXTipoDeduccion = D.idEmpleadoXTipoDeduccion
							,@IdEmpleado = D.idEmpleado
							,@IdTipoDeduccion  = D.idTipoDeduccion
						FROM
							@tempDeducciones AS D
						WHERE
							D.Sec = @lo8

						SELECT
							@SalarioBruto = S.SalarioBruto
							,@SumaDeducciones = S.SumaDeducciones
							,@IdEmpleadoXSemanaPlanilla = S.id
						FROM
							DBO.EmpleadoXSemanaPlanilla AS S
						WHERE
							S.idSemanaPlanilla = @IdSemanaPlanilla
						AND S.idEmpleado = @IdEmpleado


						IF EXISTS ( SELECT 1 ---Revisar si deducciones es obligatorio
									FROM DBO.TipoDeduccion AS TD
									WHERE
										TD.id = @IdTipoDeduccion
									and TD.FlagObligatorio = 1 )
						BEGIN
							SET @IdTipoMov = 4 --Id Movimiento Deducciones obligatorias
						END
						ELSE
						BEGIN
							SET @IdTipoMov = 5 --Id Movimiento Deducciones no obligatorias
						END

						--Obtener montos de deduccion (depende del tipo de valor de deduccion)
						IF EXISTS ( SELECT 1 --Revisar si deduccion a aplicarse es porcentual
									FROM DBO.TipoDeduccion TD 
									WHERE
										TD.id = @IdTipoDeduccion
									AND	TD.FlagPorcentual = 1 ) 
						BEGIN

							SELECT
								@PorcentajeDeduccion = TDP.valor
							FROM
								@tempDeducciones AS D
							INNER JOIN DBO.TipoDeduccion AS TD
							ON TD.id = D.idTipoDeduccion
							INNER JOIN DBO.TipoDeduccionPorcentual AS TDP
							ON TD.id = TDP.idTipoDeduccion
							WHERE
								@lo8 = D.Sec

							SET @MontoDeduccion = @SalarioBruto * @PorcentajeDeduccion --Calcular deduccion

						END
						ELSE ---Si es deduccion fija (ya se asumiría que no es obligatoria)
						BEGIN

							SELECT
								@ValorDeduccion = EP.Valor
							FROM
								DBO.EmpleadoXTipoDeduccionNoObligatoria AS ET
							INNER JOIN DBO.EmpleadoXTipoDeduccionNoObligatoriaNoPorcentual AS EP
							ON EP.idEmpleadoXTipoDeduccionNoObligatoria = ET.idEmpleadoXTipoDeduccion
							WHERE
								ET.idEmpleadoXTipoDeduccion = @IdEmpleadoXTipoDeduccion

							SELECT
								@NumSemanas = DATEDIFF(WEEK, M.FechaInicio , M.FechaFin)---Obtener cantidad de semanas de mes planilla
							FROM
								DBO.MesPlanilla AS M
							WHERE
								@FechaActual BETWEEN M.FechaInicio AND M.FechaFin
				
							SET @MontoDeduccion =  @ValorDeduccion / @NumSemanas --Calcular deduccion
						
						END

						INSERT INTO DBO.MovimientoPlanilla(
							idEmpleadoXSemanaPlanilla
							,idTipoMovimiento
							, Fecha
							, Monto )
						VALUES (
							@IdEmpleadoXSemanaPlanilla
							,@IdTipoMov
							, @FechaActual
							,@MontoDeduccion )

						SET @IdMovimientoPlanilla = SCOPE_IDENTITY()

						INSERT INTO DBO.MovimientoDeduccion (
							idMovimientoPlanilla
							,idEmpleadoXTipoDeduccion )
						VALUES (
							@IdMovimientoPlanilla
							,@IdEmpleadoXTipoDeduccion )	
						
						SET @SumaDeducciones = @SumaDeducciones + @MontoDeduccion --Acumular deducciones

						UPDATE E
							SET E.SumaDeducciones = @SumaDeducciones ---Actualizar suma deducciones
						FROM
							DBO.EmpleadoXSemanaPlanilla AS E
						WHERE
							E.id = @IdEmpleadoXSemanaPlanilla

						SELECT
							@IdEmpleadoMesPlanilla = M.id ---Obtener ID de mes actual
						FROM
							DBO.EmpleadoXMesPlanilla AS M
						INNER JOIN DBO.MesPlanilla AS MP
						ON MP.id = M.idMesPlanilla
						WHERE
							@FechaActual BETWEEN MP.FechaInicio AND MP.FechaFin
						AND M.idEmpleado = @IdEmpleado

						SELECT
							@MontoTotal = M.MontoTotal --Obtener monto de deducciones totales del mes
						FROM
							DBO.EmpleadoXMesPlanillaXTipoDeduccion AS M
						WHERE
							M.idEmpleadoXMesPlanilla = @IdEmpleadoMesPlanilla
						AND M.idTipoDeduccion = @IdTipoDeduccion

						SET @MontoTotal = @MontoTotal + @MontoDeduccion

						UPDATE M
							SET M.MontoTotal = @MontoTotal ---Acumular deducciones semanales en resumen mensual
						FROM
							DBO.EmpleadoXMesPlanillaXTipoDeduccion AS M
						WHERE
							M.idTipoDeduccion = @IdTipoDeduccion
						AND M.idEmpleadoXMesPlanilla = @IdEmpleadoMesPlanilla
						
						SET @lo8 = @lo8 + 1
					END;
					

					---	Si NO es último jueves del mes
					--- Ademas, revisar que no este la tabla MesPlanilla vacia
					IF NOT EXISTS ( SELECT 1 
									FROM DBO.MesPlanilla M 
									WHERE M.FechaFin = @FechaActual )
					AND EXISTS ( SELECT 1
								FROM DBO.MesPlanilla )
					BEGIN

						SET @FechaFinSemana = DATEADD(day, 7, @FechaActual) ---Semana planilla terminará prox jueves
						SET @FechaInicio = DATEADD(day, 1, @FechaActual)--Semana inicia al siguiente dia (viernes)

						SELECT
							@idMesPlanilla = M.id ---Asignar id de MesPlanilla en la que está la semana
						FROM
							DBO.MesPlanilla AS M
						WHERE
							@FechaActual BETWEEN M.FechaInicio AND M.FechaFin

						INSERT INTO DBO.SemanaPlanilla ( --Iniciar semana de planilla nueva
							idMesPlanilla
							,FechaInicio
							,FechaFin )
						VALUES (
							@IdMesPlanilla
							,@FechaInicio
							,@FechaFinSemana )

						SET @IdSemanaPlanilla = SCOPE_IDENTITY() --Obtener Id de semana nueva

						--Asociar empleados con nuevo semana planilla
						INSERT INTO DBO.EmpleadoXSemanaPlanilla (
							idEmpleado
							,idSemanaPlanilla
							,SalarioBruto
							,SumaDeducciones )
						SELECT
							E.id
							,@IdSemanaPlanilla
							,0 ---Inicializar contador de salarioBruto
							,0 ---Inicializar contador de sumaDeducciones
						FROM
							DBO.Empleado AS E
						WHERE 
							E.EsActivo = 1 ---Solo tomar en cuenta empleados activos
					END
					ELSE
					BEGIN

						SET @FechaInicio = DATEADD( DAY, 1, @FechaActual )--Mes inicia al siguiente dia (viernes)
						SET @FechaFinMes =  DATEADD( WEEK, 4, @FechaActual ) 

						---Si sumandole una semana más, es menor/igual a fecha final de mes, setear esa fecha como fecha fin
						IF DATEADD( WEEK, 1, @FechaFinMes ) <= EOMONTH( DATEADD ( WEEK, 1, @FechaActual ) )
						BEGIN
							SET @FechaFinMes = DATEADD( WEEK, 1, @FechaFinMes )
						END

						INSERT INTO DBO.MesPlanilla (  --Iniciar mes de planilla nuevo
							FechaInicio
							, FechaFin )
						VALUES (
							@FechaInicio
							, @FechaFinMes )

						SET @IdMesPlanilla = SCOPE_IDENTITY()
						SET @FechaFinSemana = DATEADD( DAY, 7, @FechaActual )
							
						INSERT INTO DBO.SemanaPlanilla (  --Iniciar semana de planilla nueva
							idMesPlanilla
							,FechaInicio
							, FechaFin )
						VALUES (
							@IdMesPlanilla
							, @FechaInicio
							, @FechaFinSemana )

						SET @IdSemanaPlanilla = SCOPE_IDENTITY()

						--Asociar empleados con nuevo semana planilla
						INSERT INTO DBO.EmpleadoXSemanaPlanilla (
							idEmpleado
							,idSemanaPlanilla
							,SalarioBruto
							,SumaDeducciones )
						SELECT
							E.id
							,@IdSemanaPlanilla
							,0 ---Inicializar contador de salarioBruto
							,0 ---Inicializar contador de sumaDeducciones
						FROM
							DBO.Empleado AS E
						WHERE 
							E.EsActivo = 1 ---Solo tomar en cuenta empleados activos

						SET @IdEmpleadoXSemanaPlanilla = SCOPE_IDENTITY()

						--Asociar empleados con nuevo mes planilla
						INSERT INTO DBO.EmpleadoXMesPlanilla ( 
							idEmpleado
							, idMesPlanilla )
						SELECT
							E.id
							,@IdMesPlanilla
						FROM
							DBO.Empleado AS E

						---Insertar empleados x mes planilla x tipo deduccion
						---Tomar en cuenta que los empleadosXTipoDeduccion cuyo id
						--- esté en el Archive, no serán incluidos porque significa
						--- que ya están desasociados con la deduccion
						INSERT INTO DBO.EmpleadoXMesPlanillaXTipoDeduccion (
							idEmpleadoXMesPlanilla
							,idTipoDeduccion
							, MontoTotal )
						SELECT
							E.id
							,TD.id
							,0 --Inicializar monto total
						FROM 
							DBO.EmpleadoXTipoDeduccion AS D
						INNER JOIN DBO.TipoDeduccion AS TD 
						ON TD.id = D.idTipoDeduccion
						INNER JOIN DBO.EmpleadoXMesPlanilla AS E 
						ON E.idEmpleado = D.idEmpleado
						WHERE NOT EXISTS (
							SELECT 1 
							FROM DBO.EmpleadoXTipoDeduccionNoObligatoriaArchive AS N
							WHERE N.idEmpleadoXTipoDeduccionNoObligatoria = D.id )
						AND E.idMesPlanilla = @IdMesPlanilla

					END

					---Comenzar a procesar jornadas para proxima semana planilla
					WHILE( @lo6<= @hi6 )
					BEGIN
						---Verificar que jornadas sean de ese jueves
						IF EXISTS ( SELECT 1
									FROM @tempActualizarJornadas AS A
									WHERE A.FechaProceso = @FechaActual 
										  AND A.Sec = @lo6 )
						BEGIN
	
							---Obtener datos para facilitar inserts de tablas

							SET @IdTipoEvento = 15 ---Evento de ingreso de nuevas jornadas

							SELECT
								@IdSemanaPlanilla = S.id ---Asignar id de Semana Planilla
							FROM
								DBO.SemanaPlanilla AS S
							WHERE
								 DATEADD( WEEK, 1, @FechaActual ) BETWEEN S.FechaInicio AND S.FechaFin
							---  ^^^^^^^ se añade día extra porque jornada empezarían a partir del viernes

							SELECT
								@IdEmpleado = E.id ---Obtener IdEmpleado que se está procesando
							FROM
								dbo.Empleado AS E
								, @tempActualizarJornadas AS A
							WHERE
								A.ActualizarJornadas.value('(/TipoJornadaProximaSemana/@ValorTipoDocumento)[1]', 'VARCHAR(1024)' ) = E.ValorDocumentoIdentidad
								AND @lo6 = A.Sec

							SELECT
								@IdTipoJornada = T.id ---Obtener ID del tipo de jornada
							FROM
								dbo.TipoJornada AS T
							INNER JOIN @tempActualizarJornadas AS A
							ON A.ActualizarJornadas.value('(/TipoJornadaProximaSemana/@IdTipoJornada)[1]', 'INT' ) = T.id
							WHERE
								A.Sec = @lo6

							SET @Descripcion = ( 'Id Empleado: ' 
								+ CONVERT( VARCHAR( 64 ) , @IdEmpleado ) 
								+ '. Id Tipo Jornada: ' 
								+ CONVERT( VARCHAR( 64 ) , @IdTipoJornada ) )		

							--- Insert EmpleadoXTipoJornadaXSemana
							INSERT INTO DBO.EmpleadoXTipoJornadaXSemana (
								idTipoJornada
								, idEmpleado
								, idSemanaPlanilla )
							VALUES (
								@IdTipoJornada
								, @IdEmpleado
								, @IdSemanaPlanilla )

							--- Insert a EventLog
							INSERT dbo.EventLog( 	---Inserci�n de evento asociar jornadas
								IdTipoEvento
								,IdPostByUser
								,JSON
							) VALUES (
								@IdTipoEvento
								,@IdPostByUser
							,( SELECT 
								@IpAdress AS PostInIp,
								GETDATE() AS PostTime,
								@Descripcion AS Descripcion
							FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
							);

						END;

						SET @lo6 = @lo6+1

					END;
				END
				IF DATENAME( weekday,@FechaActual ) = 'Friday' --Asociar/Desasociar Empleados a Deducciones
				BEGIN

					---Asociaciones se aplican solo en inicio de semana
					WHILE (@lo10<=@hi10)
					BEGIN

						SELECT
							@idMesPlanilla = M.id ---Asignar id de MesPlanilla en la que está la semana
						FROM
							DBO.MesPlanilla AS M
						WHERE
							@FechaActual BETWEEN M.FechaInicio AND M.FechaFin

						SELECT ---Asignar a variables todos los valores de tabla variable
							@IdEmpleado = A.idEmpleado
							,@IdTipoDeduccion= A.idTipoDeduccion
							,@IdTipoEvento = A.idTipoEvento
							,@MontoDeduccion = A.monto
							,@ValorDeduccion = A.valorDeduccion
							,@Descripcion = A.descripcion
						FROM
							@tempAsociacionesPendientes AS A
						WHERE
							A.Sec = @lo10

						INSERT INTO DBO.EmpleadoXTipoDeduccion (
							idEmpleado
							,idTipoDeduccion )
						VALUES (
							@IdEmpleado
							, @IdTipoDeduccion )

						SET @IdEmpleadoXTipoDeduccion = SCOPE_IDENTITY(); --Obtener id de empleado x tipoDeduccion

						---Actualizar tabla empleadoxtipodeduccionnoobligatoria
						INSERT INTO DBO.EmpleadoXTipoDeduccionNoObligatoria (
							idEmpleadoXTipoDeduccion
							,FechaInicio )
						VALUES (
							@IdEmpleadoXTipoDeduccion --Id se hereda
							,@FechaActual )

						---Revisar si deduccion es fija
						IF NOT EXISTS ( SELECT 1 
										FROM DBO.TipoDeduccionPorcentual D 
										WHERE D.idTipoDeduccion = @IdTipoDeduccion )
						BEGIN
							INSERT INTO DBO.EmpleadoXTipoDeduccionNoObligatoriaNoPorcentual (
								idEmpleadoXTipoDeduccionNoObligatoria
								,Valor)
							VALUES( 
								@IdEmpleadoXTipoDeduccion --Id se hereda
								, @MontoDeduccion )
						END

						---Actualizar EmpleadoXMesPLanillaXTipoDeduccion
						INSERT DBO.EmpleadoXMesPlanillaXTipoDeduccion(
							idEmpleadoXMesPlanilla
							,idTipoDeduccion
							,MontoTotal )
						SELECT
							E.id
							,@IdTipoDeduccion
							,0 ---inicializa contador de monto
						FROM
							DBO.EmpleadoXMesPlanilla AS E
						WHERE
							E.idEmpleado = @IdEmpleado
						AND E.idMesPlanilla = @IdMesPlanilla


						INSERT dbo.EventLog( 	---Inserci�n de evento asociar deduccion
							IdTipoEvento
							,IdPostByUser
							,JSON
						) VALUES (
							@IdTipoEvento
							,@IdPostByUser
						,( SELECT 
							@IpAdress AS PostInIp,
							GETDATE() AS PostTime,
							@Descripcion AS Descripcion
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
						);

						SET @lo10 = @lo10 + 1

					END
					WHILE (@lo11 <= @hi11 )
					BEGIN
						---Desasociar empleados de sus deducciones no obligatorias
						SELECT  ---Asignar a variables todos los valores de tabla variable
							@IdEmpleado = A.idEmpleado
							,@IdTipoDeduccion= A.idTipoDeduccion
							,@IdTipoEvento = A.idTipoEvento
							,@Descripcion = A.descripcion
							,@IdEmpleadoXTipoDeduccion = A.idEmpleadoXTipoDeduccion
						FROM
							@tempDesasociacionesPendientes AS A
						WHERE
							A.Sec = @lo11

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

						INSERT dbo.EventLog( 	---Inserci�n de evento Desasociar deduccion
							IdTipoEvento
							,IdPostByUser
							,JSON
						) VALUES (
							@IdTipoEvento
							,@IdPostByUser
						,( SELECT 
							@IpAdress AS PostInIp,
							GETDATE() AS PostTime,
							@Descripcion AS Descripcion
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
						);

						SET @lo11 = @lo11 + 1
					END
				END
				---Reiniciar variables limitantes
				SET  @lo2 = 1;
				SET  @lo3 = 1;
				SET  @lo4 = 1;
				SET  @lo5 = 1;
				SET  @lo6 = 1;
				SET  @lo7 = 1;

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


