USE [DBProject]
GO
/****** Object:  StoredProcedure [dbo].[CargaSimulacion]    Script Date: 20/6/2025 22:35:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[CargaSimulacion](
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

		DECLARE @tempDeduccionesPendientes TABLE ( Sec INT IDENTITY(1,1)
										,idEmpleadoXTipoDeduccion INT
										,idEmpleado INT
										, idTipoDeduccion INT );

		DECLARE @tempAplicaDeducciones TABLE( Sec INT IDENTITY(1,1)
										,IdEmpleadoXSemanaPlanilla INT
										,MontoDeducciones  DECIMAL( 15,5 )
										,IdTipoMov INT
										,IdEmpleadoXTipoDeduccion INT
										,SumaDeducciones  DECIMAL( 15,5 )
										,IdEmpleadoMesPlanilla INT
										,MontoTotal  DECIMAL( 15,5 )
										,IdTipoDeduccion INT );

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

		DECLARE @tempEmpleadosIterar TABLE(Sec INT IDENTITY(1,1)
										,FechaProceso DATE
										,empleadosIterar XML
										, idEmpleado INT
										, tieneMarcaAsistencia BIT )

		---Declarar variables a utilizar

		---Variables para iterar
		DECLARE @hi INT				---Iteracion Tabla Fecha
		DECLARE @hi2 INT			---Iteracion Tabla InsercionEmpleados
		DECLARE @hi3 INT			---Iteracion Tabla EliminarEmpleados
		DECLARE @hi4 INT			---Iteracion Tabla AsociarDeduccion
		DECLARE @hi5 INT			---Iteracion Tabla DesasociarDeduccion
		DECLARE @hi6 INT			---Iteracion Tabla ActualizarJornada
		DECLARE @hi7 INT = 0		---Iteracion Tabla MarcasAsistencia
		DECLARE @hi8 INT = 0		---Iteracion Tabla DeduccionesPendientes
		DECLARE @hi9 INT = 0		---Iteracion Tabla MesPlanilla
		DECLARE @hi10 INT = 0		---Iteracion Tabla AsociacionesPendientes
		DECLARE @hi11 INT = 0		---Iteracion Tabla DesasociacionesPendientes
		DECLARE @hi12 INT = 0		---Iteracion Tabla AplicaDeducciones

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
		DECLARE @lo12 INT = 1

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
		DECLARE @IdEmpleadoXTipoJornadaXSemana INT
		DECLARE @MarcaInicio DATETIME
		DECLARE @MarcaFin DATETIME
		DECLARE @IdMarcaAsistencia INT
		DECLARE @FechaEntrada DATE
		DECLARE @FechaSalida DATE
		DECLARE @HoraEntrada TIME
		DECLARE @HoraSalida TIME
		DECLARE @HoraSalidaJornada DATETIME
		DECLARE @SalarioOrdinario MONEY
		DECLARE @SalarioExtraNormal MONEY = 0
		DECLARE @SalarioExtraDoble MONEY = 0
		DECLARE @SalarioPuesto MONEY = 0
		DECLARE @SalarioBrutoActualizado MONEY = 0
		DECLARE @SalarioBrutoAnterior MONEY = 0
		DECLARE @HorasTrabajadas INT = 0
		DECLARE @HorasExtras INT = 0
		DECLARE @HorasExtrasNormales INT = 0
		DECLARE @HorasExtrasDobles INT = 0
		DECLARE @tempHorasExtras INT = 0
		DECLARE @FinalDia DATETIME
		DECLARE @IdTipoMovExtraNormal INT = 2 --Id tipo mov para horas extras normales
		DECLARE @IdTipoMovExtraDoble INT = 3  --Id tipo mov para horas dobles
		DECLARE @FTieneMarca INT = 0		--false
		DECLARE @Descripcion VARCHAR( 1024 )
		DECLARE @IdTipoEvento INT
		DECLARE @IdPostByUser INT = 5 ---Usuario especificado para Script
		DECLARE @IpAdress VARCHAR( 64 ) = '108.181.197.183' ---IpAdress del servidor
		DECLARE @ValorDeduccion DECIMAL( 15,5 )
		DECLARE @IdMesPlanilla INT
		DECLARE @FechaFinSemana DATE
		DECLARE @IdSemanaPlanilla INT
		DECLARE @FechaFinMes DATE
		DECLARE @FechaInicio DATE
		DECLARE @IdEmpleadoXSemanaPlanilla INT
		DECLARE @IdTipoJornada INT
		DECLARE @MontoDeduccion MONEY
		DECLARE @SalarioBruto MONEY
		DECLARE @PorcentajeDeduccion DECIMAL ( 15,5 )
		DECLARE @IdTipoMov INT
		DECLARE @IdMovimientoPlanilla INT
		DECLARE @NumSemanas INT
		DECLARE @SumaDeducciones MONEY
		DECLARE @MontoTotal DECIMAL ( 15,5 )
		DECLARE @IdEmpleadoMesPlanilla INT
		DECLARE @FExtraNormal BIT = 0	--false
		DECLARE @FExtraDoble BIT = 0	--false *************************************
		DECLARE @FPendiente BIT = 0			--false
		DECLARE @FinMesFlag BIT = 0
		DECLARE @PrimerMesNoInicializadoFlag BIT = 0
		DECLARE @EsJuevesFlag BIT = 0
		DECLARE @tieneMarcaAsistenciaFlag BIT = 0
		DECLARE @IdSemanaPlanillaNueva INT
		DECLARE @IdMesPlanillaNuevo INT
		DECLARE @IdTipoEventoNuevaJornada INT = 15 ---Evento de ingreso de nuevas jornadas
		DECLARE @Descripcion2 VARCHAR ( 1024 )
		DECLARE @FechaDiaSig DATE
		DECLARE @IdTipoMovSalario INT

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

			IF DATENAME( weekday,@FechaActual ) = 'Thursday' ---Realizar Aperturas de Mes/Semana Y/O asociar/desasociar deducciones
			BEGIN
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

					SET @IdSemanaPlanillaNueva  = SCOPE_IDENTITY() --Obtener Id de semana nueva

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

					SET @IdMesPlanillaNuevo = SCOPE_IDENTITY()
					SET @FechaFinSemana = DATEADD( DAY, 7, @FechaActual )
							
					INSERT INTO DBO.SemanaPlanilla (  --Iniciar semana de planilla nueva
						idMesPlanilla
						,FechaInicio
						, FechaFin )
					VALUES (
						@IdMesPlanillaNuevo
						, @FechaInicio
						, @FechaFinSemana )

					SET @IdSemanaPlanillaNueva  = SCOPE_IDENTITY()
				END

				---Asociaciones se aplican solo en inicio de semana
				---Proceso se hace jueves en lugar de viernes para que, en caso de que viernes ya sea
				--- nuevo mes, no se tomen en cuenta deducciones que pasan a desasociarse ese día
				--- en tabla empleadoXMesPlanillaXTipoDeduccion
				SET @FechaDiaSig =  DATEADD( DAY, 1, @FechaActual )

				WHILE (@lo10<=@hi10)
				BEGIN

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
						,@FechaDiaSig )

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
					AND E.idMesPlanilla = @IdMesPlanillaNuevo

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
						,@FechaDiaSig
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

			---Insertar todos los empleados a los que se les va a iterar en la fecha actual
			INSERT INTO @tempEmpleadosIterar (---Insertar empleados con marcas de asistencia
				FechaProceso
				,empleadosIterar
				,idEmpleado
				,tieneMarcaAsistencia )
			SELECT
				MA.FechaProceso
				,MA.MarcasAsistencia
				, E.id
				,1---Si contiene marcaAsistencia
			FROM
				@tempMarcasAsistencia AS MA
				,DBO.Empleado AS E
			WHERE
				E.ValorDocumentoIdentidad = MA.MarcasAsistencia.value( '(/MarcaDeAsistencia/@ValorTipoDocumento)[1]', 'VARCHAR(64)' )
				AND MA.FechaProceso = @FechaActual

			SET @hi7 = @hi7 + @@ROWCOUNT

			INSERT @tempEmpleadosIterar ( ---Insertar empleados que no tienen marcas de asistencia
				FechaProceso
				,empleadosIterar
				,idEmpleado
				,tieneMarcaAsistencia )
			SELECT
				@FechaActual
				, ''	---No tiene XML pues no tiene marca de asistencia
				, E.id
				, 0	---No tiene marca de asistencia
			FROM DBO.Empleado AS E
			WHERE NOT EXISTS (
				SELECT 1
				FROM @tempEmpleadosIterar AS T
				WHERE T.idEmpleado = E.id )
			AND E.EsActivo = 1

			SET @hi7 = @hi7 + @@ROWCOUNT
	
			---Comienza a procesar cada uno de los empleados, uno por uno
			WHILE( @lo7<= @hi7 )
			BEGIN
				SET @SalarioOrdinario = 0
				SET @SalarioBrutoAnterior = 0
				SET @SalarioBrutoActualizado = 0
				SET @tieneMarcaAsistenciaFlag = 0

				---Revisar si hay empleados que procesar ese dia
				IF EXISTS ( SELECT 1 FROM @tempEmpleadosIterar AS MA 
							WHERE @lo7 = MA.Sec 
							AND @FechaActual = MA.FechaProceso)
				BEGIN
					--Obtener IdEmpleado
					SELECT 
						@IdEmpleado = E.idEmpleado
					FROM 
						@tempEmpleadosIterar AS E
					WHERE
						E.Sec = @lo7

					---Asignar id de Semana Planilla
					SELECT
						@IdSemanaPlanilla = S.id
					FROM
						DBO.SemanaPlanilla AS S
					WHERE
						@FechaActual BETWEEN S.FechaInicio AND S.FechaFin

					IF EXISTS ( SELECT 1 FROM @tempEmpleadosIterar AS MA ---Empleado si tiene marca de asistencia
								WHERE @lo7 = MA.Sec 
								AND @FechaActual = MA.FechaProceso
								AND MA.tieneMarcaAsistencia = 1 )
					BEGIN
						SET @tieneMarcaAsistenciaFlag = 1

						-----Prepocesamiento de datos para marcas de asistencia------
						SET @IdTipoEvento = 14	--Id Evento Ingreso Marcas asistencia
						SET @IdTipoMovSalario = 1 --Id Mov Credito horas ordinarias
							
						--Obtener IdEmpleadoTipoJornadaSemana
						--Obtener IdTipoJornada
						SELECT 
							@IdEmpleadoXTipoJornadaXSemana = ET.id
							,@IdTipoJornada = ET.idTipoJornada
						FROM
							DBO.EmpleadoXTipoJornadaXSemana AS ET
						WHERE 
							@IdEmpleado = ET.idEmpleado AND @IdSemanaPlanilla = ET.idSemanaPlanilla

						--Obtener HoraSalidaJornada
						SELECT 
							@HoraSalidaJornada = TJ.HoraFin
						FROM 
							DBO.TipoJornada AS TJ
						WHERE
							@IdTipoJornada = TJ.id

						--Obtener IdEmpleadoSemPlanilla
						SELECT 
							@IdEmpleadoXSemanaPlanilla = ES.id
						FROM	
							DBO.EmpleadoXSemanaPlanilla AS ES
						WHERE
							@IdEmpleado = ES.idEmpleado AND @IdSemanaPlanilla = ES.idSemanaPlanilla

						--Obtener MarcaInicio
						SELECT 
							@MarcaInicio = MA.empleadosIterar.value( '(/MarcaDeAsistencia/@HoraEntrada)[1]', 'DATETIME' )
						FROM
							@tempEmpleadosIterar AS MA
						WHERE
							@lo7 = MA.Sec

						--Obtener FechaEntrada
						SET @FechaEntrada = CONVERT( DATE, @MarcaInicio ) 

						--Obtener HoraEntrada
						SET @HoraEntrada = CONVERT( TIME, @MarcaInicio ) 

						--Obtener MarcaFin
						SELECT 
							@MarcaFin = MA.EmpleadosIterar.value( '(/MarcaDeAsistencia/@HoraSalida)[1]', 'DATETIME' )
						FROM
							@tempEmpleadosIterar AS MA
						WHERE
							@lo7 = MA.Sec

						--Obtener FechaSalida
						SET @FechaSalida = CONVERT( DATE, @MarcaFin )

						--Obtener HoraSalida
						SET @HoraSalida = CONVERT( TIME, @MarcaFin )

						--Formatear HoraSalidaJornada
						IF @IdTipoJornada = 3
						BEGIN
							SET @HoraSalidaJornada = CAST(@FechaSalida AS DATETIME) + CAST(@HoraSalidaJornada AS DATETIME)
						END
						ELSE
						BEGIN
							SET @HoraSalidaJornada = CAST(@FechaEntrada AS DATETIME) + CAST(@HoraSalidaJornada AS DATETIME)
						END

						--Obtener SalarioPuesto
						SELECT 
							@SalarioPuesto = P.SalarioXHora
						FROM	
							DBO.Puesto AS P
						INNER JOIN
							DBO.Empleado AS E
						ON 
							E.IdPuesto = P.id
						WHERE 
							@IdEmpleado = E.id

						--Obtener HorasTrabajadas solo ordinarias
						SET @HorasTrabajadas = DATEDIFF(MINUTE, @MarcaInicio, @HoraSalidaJornada) / 60.0

						--Obtener HorasExtras
						--Se tiene horas extra si la hora fin de la marca sobrepasa la hora fin del tipo de jornada
						IF @HoraSalidaJornada < @MarcaFin	 
						BEGIN
							SET @HorasExtras = DATEDIFF(MINUTE, @HoraSalidaJornada, @MarcaFin) / 60.0
						END
						ELSE
						BEGIN
							SET @HorasExtras = 0
						END

						--Obtener SalarioOrdinario
						--Primero se calcula monto por horas ordinarias HorasTrabajadas - HorasExtras
						IF EXISTS ( SELECT 1 FROM DBO.Feriado AS F WHERE @FechaEntrada = F.Fecha )
						BEGIN
							SET @SalarioOrdinario = ( @SalarioPuesto * 2.0 ) * @HorasTrabajadas
						END 
						ELSE
						BEGIN
							SET @SalarioOrdinario = @SalarioPuesto * @HorasTrabajadas
						END

						--Inicializar banderas y variables
						SET @FExtraNormal = 0
						SET @FExtraDoble = 0
						SET @SalarioExtraNormal = 0
						SET @SalarioExtraDoble = 0
						SET @HorasExtrasNormales = 0
						SET @HorasExtrasDobles = 0

						IF @HorasExtras > 0 --Si hay horas extras
						BEGIN
							--Obtener SalarioExtra 
							SET @FinalDia = CAST(@FechaSalida AS DATETIME) + CAST('00:00' AS DATETIME)
							--IF DATEDIFF(HOUR, @HoraSalidaJornada, @FinalDia) < @HorasExtras --Horas se dividen en 2 dias***
							IF @IdTipoJornada <> 3 AND @FechaEntrada <> @FechaSalida	--Horas se dividen en 2 dias
							BEGIN
								SET @tempHorasExtras = DATEDIFF(MINUTE, @HoraSalidaJornada, @FinalDia)/60.0 --Horas extra dentro del mismo dia entrada
								IF DATENAME( WEEKDAY, @FechaEntrada ) <> 'Sunday' AND  --No es feriado ni domingo
									NOT EXISTS ( SELECT 1 FROM DBO.Feriado AS F WHERE @FechaEntrada = F.Fecha )
								BEGIN
									SET @SalarioExtraNormal = (1.5 * @SalarioPuesto) * @tempHorasExtras
									SET @FExtraNormal = 1
									SET @HorasExtrasNormales = @tempHorasExtras
								END
								ELSE	--Es domingo o feriado
								BEGIN
									SET @SalarioExtraDoble = (2.0 * @SalarioPuesto) * @tempHorasExtras
									SET @FExtraDoble = 1;
									SET @HorasExtrasDobles = @tempHorasExtras
								END

								--Horas extras del dia siguiente
								IF DATENAME( WEEKDAY, @FechaSalida ) <> 'Sunday' AND  --No es feriado ni domingo
									NOT EXISTS ( SELECT 1 FROM DBO.Feriado AS F WHERE @FechaSalida = F.Fecha )
								BEGIN
									SET @SalarioExtraNormal = @SalarioExtraNormal + (
															(1.5 * @SalarioPuesto) * (@HorasExtras - @tempHorasExtras) 
															)
									SET @FExtraNormal = 1
									SET @HorasExtrasNormales = @HorasExtrasNormales + (@HorasExtras - @tempHorasExtras)
								END
								ELSE	--Es domingo o feriado
								BEGIN
									SET @SalarioExtraDoble = @SalarioExtraDoble + (
															(2.0 * @SalarioPuesto) * (@HorasExtras - @tempHorasExtras)
															)
									SET @FExtraDoble = 1;
									SET @HorasExtrasDobles = @HorasExtrasDobles + (@HorasExtras - @tempHorasExtras)
								END
							END
							ELSE	--Horas extras el mismo dia 
							BEGIN
								--No es feriado ni domingo
								IF DATENAME( WEEKDAY, @FechaSalida ) <> 'Sunday' AND 
									NOT EXISTS ( SELECT 1 FROM DBO.Feriado AS F WHERE @FechaSalida = F.Fecha )
								BEGIN
									SET @SalarioExtraNormal = (1.5 * @SalarioPuesto) * @HorasExtras
									SET @FExtraNormal = 1
									SET @HorasExtrasNormales = @HorasExtras
								END
								ELSE	--Es domingo o feriado
								BEGIN
									SET @SalarioExtraDoble = (2.0 * @SalarioPuesto) * @HorasExtras 
									SET @FExtraDoble = 1;
									SET @HorasExtrasDobles = @HorasExtras
								END
							END
						END

						--Obtener salario bruto actualizado
						IF @IdTipoJornada = 3 AND DATENAME(WEEKDAY, @FechaActual) = 'Thursday'
						BEGIN					
							SET @SalarioBrutoActualizado = @SalarioOrdinario + @SalarioExtraNormal + @SalarioExtraDoble
						END
						ELSE
						BEGIN
							--Obtener salario bruto anterior
							SELECT 
								@SalarioBrutoAnterior = ES.SalarioBruto
							FROM 
								DBO.EmpleadoXSemanaPlanilla AS ES
							WHERE
								@IdEmpleadoXSemanaPlanilla = ES.id

							SET @SalarioBrutoActualizado = @SalarioBrutoAnterior + @SalarioOrdinario 
															+ @SalarioExtraNormal + @SalarioExtraDoble
						END

						--Verificar si es jueves con jornada nocturna
						IF DATENAME( WEEKDAY, @FechaActual ) = 'Thursday' AND
							@IdTipoJornada = 3	--Jornada nocturna
						BEGIN
							SET @FPendiente = 1
						END
						ELSE
						BEGIN
							SET @FPendiente = 0
						END

						SET @Descripcion = ('ID Empleado: ' 
											+ CONVERT( VARCHAR( 1024 ), @IdEmpleado )
											+ '. Marca inicio: '
											+ CONVERT( VARCHAR( 1024 ), @MarcaInicio )
											+ '. Marca fin: '
											+ CONVERT( VARCHAR (1024), @MarcaFin) )
					END;

					---Preprocesamiento para eventos que solo ocurren si es jueves----------
					IF DATENAME( weekday,@FechaActual ) = 'Thursday' ---Solo ocurren jueves
					BEGIN

						IF NOT EXISTS ( SELECT 1
								FROM DBO.EmpleadoXMesPlanilla )
						BEGIN
							SET @PrimerMesNoInicializadoFlag = 1---revisar si está iniciando simulacion
						END

						---Preproceso para deducciones------
						IF @PrimerMesNoInicializadoFlag = 0 ---NO aplicar deducciones el primer dia
						BEGIN
							INSERT INTO @tempDeduccionesPendientes (---Obtener deducciones obligatorias
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
							INNER JOIN DBO.TipoDeduccion AS TD
							ON TD.id = ET.idTipoDeduccion
							WHERE
								E.id = @IdEmpleado
							AND TD.FlagObligatorio = 1

							SET @hi8 = @hi8 + @@ROWCOUNT

							INSERT INTO @tempDeduccionesPendientes (---Obtener deducciones no obligatorias
								idEmpleadoXTipoDeduccion
								,idEmpleado
								,idTipoDeduccion )
							SELECT
								ET.id
								, ET.idEmpleado
								, TD.id
							FROM
								DBO.EmpleadoXTipoDeduccion AS ET
							INNER JOIN DBO.EmpleadoXTipoDeduccionNoObligatoria AS O
							ON O.idEmpleadoXTipoDeduccion = ET.id
							INNER JOIN DBO.TipoDeduccion AS TD
							ON TD.id = ET.idTipoDeduccion
							WHERE
								O.FechaInicio<= @FechaActual	
							AND ET.idEmpleado = @IdEmpleado
							AND NOT EXISTS ( --- Deducción esté activa
									SELECT 1
									FROM DBO.EmpleadoXTipoDeduccionNoObligatoriaArchive AS A
									WHERE A.idEmpleadoXTipoDeduccionNoObligatoria =O.idEmpleadoXTipoDeduccion
								)
			
							SET @hi8 = @hi8 + @@ROWCOUNT

								SELECT
									@SumaDeducciones = S.SumaDeducciones
								FROM
									DBO.EmpleadoXSemanaPlanilla AS S
								WHERE
									S.idSemanaPlanilla = @IdSemanaPlanilla
								AND S.idEmpleado = @IdEmpleado

							WHILE ( @lo8 <= @hi8 ) ---Comienza a procesar deducciones del empleado
							BEGIN
						
								SELECT
									@IdEmpleadoXTipoDeduccion = D.idEmpleadoXTipoDeduccion
									,@IdEmpleado = D.idEmpleado
									,@IdTipoDeduccion  = D.idTipoDeduccion
								FROM
									@tempDeduccionesPendientes AS D
								WHERE
									D.Sec = @lo8

								SELECT
									@SalarioBruto = S.SalarioBruto
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
								ELSE IF EXISTS ( SELECT 1 ---Revisar si deducciones es No Obligatoria
											FROM DBO.TipoDeduccion AS TD
											WHERE
												TD.id = @IdTipoDeduccion
											and TD.FlagObligatorio = 0 )
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
										@tempDeduccionesPendientes AS D
									INNER JOIN DBO.TipoDeduccion AS TD
									ON TD.id = D.idTipoDeduccion
									INNER JOIN DBO.TipoDeduccionPorcentual AS TDP
									ON TD.id = TDP.idTipoDeduccion
									WHERE
										@lo8 = D.Sec

									--Calcular deduccion
									IF @FPendiente = 1 ---Es jornada nocturna un jueves
									BEGIN
										--No se incluye salario generado en esa marca asistencia de ese día pues este
										-- pertenece a semanaPlanilla siguiente, no actual
										SET @MontoDeduccion = @SalarioBruto * @PorcentajeDeduccion
									END
									ELSE 
									BEGIN
										SET @MontoDeduccion = ( @SalarioBruto		
																+@SalarioOrdinario
																+@SalarioExtraNormal
																+@SalarioExtraDoble ) * @PorcentajeDeduccion
									END

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

								SET @SumaDeducciones = @SumaDeducciones + @MontoDeduccion --Acumular deducciones

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
						
								---Inserta todos los datos preprocesados para realizar en la transacción los Inserts
								INSERT INTO @tempAplicaDeducciones( IdEmpleadoXSemanaPlanilla
												,MontoDeducciones 
												,IdTipoMov
												,IdEmpleadoXTipoDeduccion 
												,SumaDeducciones 
												,IdEmpleadoMesPlanilla 
												,MontoTotal
												,IdTipoDeduccion)
								VALUES ( @IdEmpleadoXSemanaPlanilla
										,@MontoDeduccion
										,@IdTipoMov
										,@IdEmpleadoXTipoDeduccion
										,@SumaDeducciones
										,@IdEmpleadoMesPlanilla
										,@MontoTotal
										,@IdTipoDeduccion )

								SET @hi12 = @hi12 + 1 ---Se procesa deduccion por deduccion

								SET @lo8 = @lo8 + 1
							END
						END
					
						---Preproceso para apertura de semana/mes---------
						SET @EsJuevesFlag = 1 ---Prender bandera de jueves

						IF EXISTS ( SELECT 1 ---	Si es último jueves del mes
										FROM DBO.MesPlanilla M 
										WHERE M.FechaFin = @FechaActual )
						BEGIN
							SET @FinMesFlag = 1 --Activar bandera indicando fin de mes
						END

						SELECT
							@idMesPlanilla = M.id ---Asignar id de MesPlanilla en la que está la semana
						FROM
							DBO.MesPlanilla AS M
						WHERE
							@FechaActual BETWEEN M.FechaInicio AND M.FechaFin

						---Preproceso para asociacion de jornada---------
						SELECT
							@IdTipoJornada = T.id ---Obtener ID del tipo de jornada
						FROM
							dbo.Empleado AS E
							,dbo.TipoJornada AS T
						INNER JOIN @tempActualizarJornadas AS A
						ON A.ActualizarJornadas.value('(/TipoJornadaProximaSemana/@IdTipoJornada)[1]', 'INT' ) = T.id
						WHERE
							A.ActualizarJornadas.value('(/TipoJornadaProximaSemana/@ValorTipoDocumento)[1]', 'VARCHAR(1024)' ) = E.ValorDocumentoIdentidad
						AND A.FechaProceso = @FechaActual
						AND E.id = @IdEmpleado

						SET @Descripcion2 = ( 'Id Empleado: ' 
							+ CONVERT( VARCHAR( 64 ) , @IdEmpleado ) 
							+ '. Id Tipo Jornada: ' 
							+ CONVERT( VARCHAR( 64 ) , @IdTipoJornada ) )		

					END
					---Comienza transacción de actualizar marcas de asistencia. Si es jueves, aplica deducciones, realiza apertura
					--- y aplica jornada de un solo empleado
					BEGIN TRANSACTION ProcesamientoEmpleado

						---Para primer jueves de toda la simulacion no se realiza nada y empleado debe tener marcas asistencia

						--Insertar marcas normalmente
						INSERT INTO DBO.MarcaAsistencia (
							idEmpleadoXTipoJornadaXSemana
							, HoraInicio
							, HoraFin )
						SELECT
							@IdEmpleadoXTipoJornadaXSemana
							, @HoraEntrada
							, @HoraSalida
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves
								
						SET @IdMarcaAsistencia = SCOPE_IDENTITY()

						--Credito horas ordinarias
						INSERT INTO DBO.MovimientoPlanilla (
							idEmpleadoXSemanaPlanilla
							, idTipoMovimiento
							, Fecha
							, Monto )
						SELECT
							@IdEmpleadoXSemanaPlanilla
							, @IdTipoMovSalario
							, @FechaActual
							, @SalarioOrdinario 
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves

						SET @IdMovimientoPlanilla = SCOPE_IDENTITY()
						
						INSERT INTO DBO.MovimientoAsistencia (
							idMovimientoPlanilla
							, idMarcaAsistencia
							, QHoras )
						SELECT
							@IdMovimientoPlanilla
							, @IdMarcaAsistencia
							, @HorasTrabajadas
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves

						--Credito por horas extra normal
						INSERT INTO DBO.MovimientoPlanilla (
							idEmpleadoXSemanaPlanilla
							, idTipoMovimiento
							, Fecha
							, Monto )
						SELECT
							@IdEmpleadoXSemanaPlanilla
							, @IdTipoMovExtraNormal
							, @FechaActual
							, @SalarioExtraNormal
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves
						AND @SalarioExtraNormal > 0

						SET @IdMovimientoPlanilla = SCOPE_IDENTITY()

						INSERT INTO DBO.MovimientoAsistencia (
							idMovimientoPlanilla
							, idMarcaAsistencia
							, QHoras )
						SELECT
							@IdMovimientoPlanilla
							, @IdMarcaAsistencia
							, @HorasExtrasNormales
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves
						AND @SalarioExtraNormal > 0

						--Credito por horas extra doble
						INSERT INTO DBO.MovimientoPlanilla (
							idEmpleadoXSemanaPlanilla
							, idTipoMovimiento
							, Fecha
							, Monto )
						SELECT
							@IdEmpleadoXSemanaPlanilla
							, @IdTipoMovExtraDoble
							, @FechaActual
							, @SalarioExtraDoble
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves
						AND @SalarioExtraDoble > 0

						SET @IdMovimientoPlanilla = SCOPE_IDENTITY()

						INSERT INTO DBO.MovimientoAsistencia (
							idMovimientoPlanilla
							, idMarcaAsistencia
							, QHoras )
						SELECT
							@IdMovimientoPlanilla
							, @IdMarcaAsistencia
							, @HorasExtrasDobles
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves
						AND @SalarioExtraDoble > 0

						--Actualizar Salario Bruto
						UPDATE ES		
						SET ES.SalarioBruto = @SalarioBrutoActualizado
						FROM 
							DBO.EmpleadoXSemanaPlanilla AS ES
						WHERE
							@IdEmpleadoXSemanaPlanilla = ES.id
						AND	@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves

						--Insertar a EventLog evento de Procesamiento Marcas Asistencia
						INSERT INTO DBO.EventLog  (
							IdTipoEvento
							,IdPostByUser
							,JSON
						) SELECT 
							@IdTipoEvento
							,@IdPostByUser
							,( SELECT 
									@IpAdress AS PostInIp,
									GETDATE() AS PostTime,
									@Descripcion AS Descripcion
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 0	--No es jornada nocturna un jueves
							
						----Comienzo de procesamiento de eventos que solo ocurren jueves----
						---Comenzar a AplicarDeducciones de empleado
						WHILE(@lo12<=@hi12)
						BEGIN
							SELECT
								@IdEmpleadoMesPlanilla = D.IdEmpleadoMesPlanilla
								,@IdEmpleadoXSemanaPlanilla = D.IdEmpleadoXSemanaPlanilla
								,@IdEmpleadoXTipoDeduccion = D.IdEmpleadoXTipoDeduccion
								,@IdTipoMov = D.IdTipoMov
								,@MontoDeduccion = D.MontoDeducciones
								,@MontoTotal = D.MontoTotal
								,@SumaDeducciones = D.SumaDeducciones
								,@IdTipoDeduccion = D.IdTipoDeduccion
							FROM
								@tempAplicaDeducciones AS D
							WHERE
								D.Sec = @lo12
							AND @EsJuevesFlag = 1---Acciones que solo se realizan jueves
							AND @PrimerMesNoInicializadoFlag = 0---Deducciones no se aplican si apenas está iniciando simulacion

							UPDATE E
								SET E.SumaDeducciones = @SumaDeducciones ---Actualizar suma deducciones
							FROM
								DBO.EmpleadoXSemanaPlanilla AS E
							WHERE
								E.id = @IdEmpleadoXSemanaPlanilla
							AND @EsJuevesFlag = 1---Acciones que solo se realizan jueves
							AND @PrimerMesNoInicializadoFlag = 0---Deducciones no se aplican si apenas está iniciando simulacion

							UPDATE M
								SET M.MontoTotal = @MontoTotal ---Acumular deducciones semanales en resumen mensual
							FROM
								DBO.EmpleadoXMesPlanillaXTipoDeduccion AS M
							WHERE
								M.idTipoDeduccion = @IdTipoDeduccion
							AND M.idEmpleadoXMesPlanilla = @IdEmpleadoMesPlanilla
							AND @EsJuevesFlag = 1---Acciones que solo se realizan jueves
							AND @PrimerMesNoInicializadoFlag = 0---Deducciones no se aplican si apenas está iniciando simulacion

							INSERT INTO DBO.MovimientoPlanilla(
								idEmpleadoXSemanaPlanilla
								,idTipoMovimiento
								, Fecha
								, Monto )
							SELECT
								@IdEmpleadoXSemanaPlanilla
								,@IdTipoMov
								, @FechaActual
								,@MontoDeduccion
							WHERE
								@EsJuevesFlag = 1---Acciones que solo se realizan jueves
							AND @PrimerMesNoInicializadoFlag = 0---Deducciones no se aplican si apenas está iniciando simulacion

							SET @IdMovimientoPlanilla = SCOPE_IDENTITY()

							INSERT INTO DBO.MovimientoDeduccion (
								idMovimientoPlanilla
								,idEmpleadoXTipoDeduccion )
							SELECT
								@IdMovimientoPlanilla
								,@IdEmpleadoXTipoDeduccion
							WHERE
								@EsJuevesFlag = 1---Acciones que solo se realizan jueves
							AND @PrimerMesNoInicializadoFlag = 0---Deducciones no se aplican si apenas está iniciando simulacion

							SET @lo12 = @lo12 + 1
						END

						---Comenzar Apertura de Semana para Empleado	

						--Asociar empleado con nuevo semana planilla
						INSERT INTO DBO.EmpleadoXSemanaPlanilla (
							idEmpleado
							,idSemanaPlanilla
							,SalarioBruto
							,SumaDeducciones )
						SELECT
							@IdEmpleado
							,@IdSemanaPlanillaNueva 
							,0 ---Inicializar contador de salarioBruto
							,0 ---Inicializar contador de sumaDeducciones
						WHERE
							@EsJuevesFlag = 1---Acciones que solo se realizan jueves
						AND ( @FinMesFlag = 1 OR @PrimerMesNoInicializadoFlag = 1 )---Si es fin de mes o apenas está iniciando simulacion
							
						SET @IdEmpleadoXSemanaPlanilla = SCOPE_IDENTITY()

						--Asociar empleados con nuevo mes planilla
						INSERT INTO DBO.EmpleadoXMesPlanilla ( 
							idEmpleado
							, idMesPlanilla )
						SELECT
							@IdEmpleado
							,@IdMesPlanillaNuevo
						WHERE
							@EsJuevesFlag = 1---Acciones que solo se realizan jueves
						AND	( @FinMesFlag = 1 OR @PrimerMesNoInicializadoFlag = 1 )---Si es fin de mes o apenas está iniciando simulacion

						---Insertar empleados x mes planilla x tipo deduccion
						INSERT INTO DBO.EmpleadoXMesPlanillaXTipoDeduccion ( 
							idEmpleadoXMesPlanilla
							,idTipoDeduccion
							, MontoTotal )
						SELECT
							E.id
							,TD.id
							,0 --Inicializar monto total
						FROM 
							DBO.EmpleadoXMesPlanilla AS E
						INNER JOIN DBO.EmpleadoXTipoDeduccion AS D
						ON D.idEmpleado = E.idEmpleado
						INNER JOIN DBO.TipoDeduccion AS TD 
						ON TD.id = D.idTipoDeduccion
						WHERE NOT EXISTS (
							SELECT 1 
							FROM DBO.EmpleadoXTipoDeduccionNoObligatoriaArchive AS N
							WHERE N.idEmpleadoXTipoDeduccionNoObligatoria = D.id )
						AND E.idMesPlanilla = @IdMesPlanillaNuevo
						AND E.idEmpleado = @IdEmpleado
						AND @EsJuevesFlag = 1---Acciones que solo se realizan jueves
						AND	( @FinMesFlag = 1 OR @PrimerMesNoInicializadoFlag = 1 )---Si es fin de mes o apenas está iniciando simulacion

						--Asociar empleados con nuevo semana planilla
						INSERT INTO DBO.EmpleadoXSemanaPlanilla (
							idEmpleado
							,idSemanaPlanilla
							,SalarioBruto
							,SumaDeducciones )
						SELECT
							@IdEmpleado
							,@IdSemanaPlanillaNueva 
							,0 ---Inicializar contador de salarioBruto
							,0 ---Inicializar contador de sumaDeducciones
						WHERE
							@EsJuevesFlag = 1---Acciones que solo se realizan jueves
						AND	@FinMesFlag = 0  ---Si no es fin de mes
						AND @PrimerMesNoInicializadoFlag = 0

						SET @IdEmpleadoXSemanaPlanilla = SCOPE_IDENTITY()

						
						---Se realiza asociacion de empleado con nueva jornada
						INSERT INTO DBO.EmpleadoXTipoJornadaXSemana (
							idTipoJornada
							, idEmpleado
							, idSemanaPlanilla )
						SELECT
							@IdTipoJornada
							, @IdEmpleado
							, @IdSemanaPlanillaNueva
						WHERE
							@EsJuevesFlag = 1---Acciones que solo se realizan jueves

						SET @IdEmpleadoXTipoJornadaXSemana = SCOPE_IDENTITY()

						--- Insert a EventLog
						INSERT dbo.EventLog( 	---Insercion de evento asociar jornadas
							IdTipoEvento
							,IdPostByUser
							,JSON
						) SELECT
							@IdTipoEventoNuevaJornada
							,@IdPostByUser
						,( SELECT 
							@IpAdress AS PostInIp,
							GETDATE() AS PostTime,
							@Descripcion2 AS Descripcion
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
						WHERE
							@EsJuevesFlag = 1---Acciones que solo se realizan jueves

						--Insertar marcas de jueves jornada nocturna
						INSERT INTO DBO.MarcaAsistencia (
							idEmpleadoXTipoJornadaXSemana
							, HoraInicio
							, HoraFin )
						SELECT
							@IdEmpleadoXTipoJornadaXSemana
							, @HoraEntrada
							, @HoraSalida
						WHERE
							@FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @PrimerMesNoInicializadoFlag = 0 

						SET @IdMarcaAsistencia = SCOPE_IDENTITY()

						--Credito horas ordinarias
						INSERT INTO DBO.MovimientoPlanilla (
							idEmpleadoXSemanaPlanilla
							, idTipoMovimiento
							, Fecha
							, Monto )
						SELECT
							@IdEmpleadoXSemanaPlanilla
							, @IdTipoMovSalario
							, @FechaDiaSig
							, @SalarioOrdinario
						WHERE
							@FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @PrimerMesNoInicializadoFlag = 0 

						SET @IdMovimientoPlanilla = SCOPE_IDENTITY()
						
						INSERT INTO DBO.MovimientoAsistencia (
							idMovimientoPlanilla
							, idMarcaAsistencia
							, QHoras )
						SELECT
							@IdMovimientoPlanilla
							, @IdMarcaAsistencia
							, COALESCE(@HorasTrabajadas, 0)
						WHERE
							@FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @PrimerMesNoInicializadoFlag = 0 

						--Credito por horas extra normal
						INSERT INTO DBO.MovimientoPlanilla (
							idEmpleadoXSemanaPlanilla
							, idTipoMovimiento
							, Fecha
							, Monto )
						SELECT
							@IdEmpleadoXSemanaPlanilla
							, @IdTipoMovExtraNormal
							, @FechaDiaSig
							, @SalarioExtraNormal
						WHERE
							@FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @SalarioExtraNormal > 0
						AND @PrimerMesNoInicializadoFlag = 0 

						SET @IdMovimientoPlanilla = SCOPE_IDENTITY()

						INSERT INTO DBO.MovimientoAsistencia (
							idMovimientoPlanilla
							, idMarcaAsistencia
							, QHoras )
						SELECT
							@IdMovimientoPlanilla
							, @IdMarcaAsistencia
							, @HorasExtrasNormales
						WHERE
							@FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @SalarioExtraNormal > 0
						AND @PrimerMesNoInicializadoFlag = 0 

						--Credito por horas extra doble
						INSERT INTO DBO.MovimientoPlanilla (
							idEmpleadoXSemanaPlanilla
							, idTipoMovimiento
							, Fecha
							, Monto )
						SELECT
							@IdEmpleadoXSemanaPlanilla
							, @IdTipoMovExtraDoble
							, @FechaDiaSig
							, @SalarioExtraDoble
						WHERE
							@FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @SalarioExtraDoble > 0
						AND @PrimerMesNoInicializadoFlag = 0 

						SET @IdMovimientoPlanilla = SCOPE_IDENTITY()

						INSERT INTO DBO.MovimientoAsistencia (
							idMovimientoPlanilla
							, idMarcaAsistencia
							, QHoras )
						SELECT
							@IdMovimientoPlanilla
							, @IdMarcaAsistencia
							, @HorasExtrasDobles
						WHERE
							@FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @SalarioExtraDoble > 0
						AND @PrimerMesNoInicializadoFlag = 0 

						--Actualizar Salario Bruto
						UPDATE ES		
						SET ES.SalarioBruto = @SalarioBrutoActualizado
						FROM 
							DBO.EmpleadoXSemanaPlanilla AS ES
						WHERE
							@IdEmpleadoXSemanaPlanilla = ES.id
						AND @FPendiente = 1  --Es jornada nocturna un jueves
						AND @tieneMarcaAsistenciaFlag = 1
						AND @PrimerMesNoInicializadoFlag = 0 

						--Insertar a EventLog
						INSERT INTO DBO.EventLog  (
							IdTipoEvento
							,IdPostByUser
							,JSON
						) SELECT
							@IdTipoEvento
							,@IdPostByUser
							,( SELECT 
									@IpAdress AS PostInIp,
									GETDATE() AS PostTime,
									@Descripcion AS Descripcion
								FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
						WHERE
							@PrimerMesNoInicializadoFlag = 0 
						AND @tieneMarcaAsistenciaFlag = 1
						AND @FPendiente = 1 --Es jornada nocturna un jueves
			
					COMMIT TRANSACTION ProcesamientoEmpleado
				END;

				SET @lo7 = @lo7+1
			END;

			--Eliminar tabla variable para 'reiniciar' empleados
			DELETE @tempEmpleadosIterar

			---Reiniciar banderas
			SET @FinMesFlag = 0
			SET @PrimerMesNoInicializadoFlag = 0
			SET @EsJuevesFlag = 0
			SET @tieneMarcaAsistenciaFlag = 0

			---Reiniciar variables limitantes
			SET  @lo2 = 1;
			SET  @lo3 = 1;
			SET  @lo4 = 1;
			SET  @lo5 = 1;
			SET  @lo6 = 1;

			SET @lo = @lo +1
		END


	END TRY
	BEGIN CATCH
	
		IF @@TRANCOUNT>0
		BEGIN
			ROLLBACK TRANSACTION ProcesamientoEmpleado;
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
