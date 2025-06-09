CREATE PROCEDURE [dbo].[InsertarEmpleado] (
	@inNombre VARCHAR( 64 )
	, @inIdTipoDocId INT
    , @inDocId VARCHAR( 64 )
	, @inFechaNac DATE
	, @inNombrePuesto VARCHAR( 64 )
	, @inIdDepartamento INT
	, @inUsuario VARCHAR( 64 )
	, @inPassword VARCHAR( 64 )
	, @inUsername VARCHAR( 64 )
	, @inIpAdress VARCHAR( 64 )
	, @outResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @IdTipoEvento INT = 5; ---Insercion Empleado
		DECLARE @IdPostByUser INT; ---Id Usuario que está realizando el evento
		DECLARE @Descripcion VARCHAR( 1024 ); ---Descripción de Evento Ocurrido
		DECLARE @DescripcionError VARCHAR( 1024 );
		DECLARE @DescripcionResultado VARCHAR( 1024 );
		DECLARE @TipoDocId VARCHAR( 64 );
		DECLARE @idPuesto INT;
		DECLARE @Departamento VARCHAR( 64 );
		DECLARE @ultIdUsuario INT;
		DECLARE @FUsuarioValido INT = 1;			--True
		DECLARE @FNombreValido BIT = 1;			--True
		DECLARE @FNombreRepetido BIT = 0;		--False
		DECLARE @FDocumentoIdentidadValido BIT = 1;		--True
		DECLARE @FDocumentoIdentidadRepetido BIT = 0;	--False

		SET @IdPostByUser = ( SELECT 
									E.Id AS Id
								FROM
									dbo.Usuario AS E
								WHERE 
									E.Nombre = @inUsername );
		SET @TipoDocId = ( SELECT 
								TD.Nombre AS TipoDocId
							FROM
								dbo.TipoDocId AS TD
							WHERE
								TD.id = @inIdTipoDocId );
		SET @idPuesto = ( SELECT
								P.Id as Id
							FROM
								dbo.Puesto AS P
							WHERE
								LOWER( P.Nombre ) = LOWER( @inNombrePuesto ) );
		SET @Departamento = ( SELECT
									D.Nombre AS Departamento
								FROM
									dbo.Departamento AS D
								WHERE
									D.id = @inIdDepartamento );
		SET @Descripcion = ( ' Nombre: '
							+ CONVERT( VARCHAR(64) , @inNombre )
							+ '. '
							+ CONVERT( VARCHAR( 64 ), @TipoDocId)
							+ ': '
							+ CONVERT( VARCHAR(64) , @inDocId )
							+ '. Fecha de nacimiento: '
							+ CONVERT( VARCHAR(64) , @inFechaNac )
							+ '. Puesto: '
							+ CONVERT( VARCHAR(64) , @inNombrePuesto ) 
							+ '. Departamento: '
							+ CONVERT( VARCHAR(64) , @Departamento )
							+ '. Usuario: '
							+ CONVERT( VARCHAR(64), @inUsuario )
							+ '. Password: '
							+ CONVERT( VARCHAR(64), @inPassword ) );
		SET @ultIdUsuario = ( SELECT
									MAX(U.id)
								FROM	
									dbo.Usuario AS U ) + 1;
		SET @outResultCode = 0;
		
		--VALIDAR SI USUARIO YA EXISTE
		IF EXISTS ( SELECT 1
					FROM dbo.Usuario AS U
					WHERE U.Nombre = @inUsuario )
		BEGIN
			SET @FUsuarioValido = 0;		--Usuario ya existe
			SET @DescripcionResultado = ( 'Usuario '
										+ CONVERT( VARCHAR(64), @inUsuario )
										+ ' ya existe.');
		END;
		--VALIDAR SI FORMATO NOMBRE ES VALIDO
		IF PATINDEX( '%[^A-Za-z ]%', @inNombre ) > 0 OR @inNombre = ''
		BEGIN 
			SET @outResultCode = 50009;		--Nombre no alfabetico
			SET @FNombreValido = 0;
		END;

		--VALIDAR SI NOMBRE EXISTE
		IF @FNombreValido = 1 AND 
			EXISTS ( 
				SELECT 1 
				FROM dbo.Empleado AS E 
				WHERE LOWER( E.Nombre ) LIKE LOWER( @inNombre ) )
		BEGIN 
			SET @outResultCode = 50005		--Nombre ya existe
			SET @FNombreRepetido = 1;
		END;

		--VALIDAR SI FORMATO DOCUMENTO IDENTIDAD ES VALIDO
		IF @FNombreValido = 1 AND 
			@FNombreRepetido = 0 AND
			PATINDEX( '%[^0-9-]%', @inDocId ) > 0 OR 
					@inDocId = '' 
		BEGIN
			SET @outResultCode = 50010		--Documento de identidad invalido
			SET @FDocumentoIdentidadValido = 0;
		END;

		--VALIDAR SI DOCUMENTO IDENTIDAD EXISTE
		IF @FNombreValido = 1 AND 
			@FNombreRepetido = 0 AND
			@FDocumentoIdentidadValido = 1 AND
			EXISTS ( 
				SELECT 1 
				FROM dbo.Empleado AS E 
				WHERE E.ValorDocumentoIdentidad = @inDocId )
		BEGIN
			SET @outResultCode = 50004		--Documento identidad ya existe
			SET @FDocumentoIdentidadRepetido = 1;
		END;
		
		IF @outResultCode != 0
		BEGIN
			SET @DescripcionError = ( SELECT
											E.Descripcion AS DescripcionErr
										From
											dbo.Error AS E
										WHERE
											E.Codigo = @outResultCode );
			SET @DescripcionResultado = ( 'Error: '
										+ CONVERT( VARCHAR(64), @outResultCode )
										+ ' - '
										+ CONVERT ( VARCHAR(64), @DescripcionError )
										+ @DescripcionResultado )
		END;
		ELSE
		BEGIN
			SET @DescripcionResultado = ( 'Insercion exitosa' );
		END;

		--INSERCION AL EVENTLOG, USUARIO, EMPLEADO
		BEGIN TRANSACTION InsertarEmpleado
			---Inserta Evento en BitacoraEvento
			INSERT dbo.EventLog( 
				IdTipoEvento
				,IdPostByUser
				,JSON
			) VALUES (
				@IdTipoEvento
				,@IdPostByUser
				,( SELECT 
						@inIpAdress AS PostInIp,
						GETDATE() AS PostTime,
						@DescripcionResultado AS Resultado,
						@Descripcion AS Descripcion
				   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
			);

			IF @FNombreValido = 1 AND 
				@FNombreRepetido = 0 AND
				@FDocumentoIdentidadValido = 1 AND
				@FDocumentoIdentidadRepetido = 0 AND
				@FUsuarioValido = 1
			BEGIN

				--INSERTAR TABLA USUARIO
				INSERT INTO dbo.Usuario (
					id
					, Nombre
					, Contraseña
					, IdTipoUsuario
				)
				VALUES (
					@ultIdUsuario
					, @inUsuario
					, @inPassword
					, 2
				);
				--INSERTAR TABLA EMPLEADO
				INSERT INTO dbo.Empleado (
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
					@inNombre
					, @inIdTipoDocId
					, @inDocId
					, @inFechaNac
					, @idPuesto
					, @inIdDepartamento
					, @ultIdUsuario
					, 1
				);

			END;
		COMMIT TRANSACTION InsertarEmpleado
	END TRY

	BEGIN CATCH 
		IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION InsertarEmpleado;
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