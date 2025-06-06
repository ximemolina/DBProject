CREATE PROCEDURE [dbo].[ModificarEmpleado] (
	@inNombre VARCHAR( 64 )
	, @inNuevoNombre VARCHAR( 64 )
	, @inNuevoTipoDocId VARCHAR( 64 )
	, @inNuevoDocId VARCHAR( 64 )
	, @inNuevaFechaNac VARCHAR( 64 )
	, @inNuevoPuesto VARCHAR( 64 )
	, @inNuevoDepartamento VARCHAR( 64 )
	, @inUsername VARCHAR( 64 )
	, @inIpAdress VARCHAR( 64 )
	, @outResultCode INT OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @IdTipoEvento INT = 7;		--Modificacion exitosa****************
		DECLARE @IdPostByUser INT;
		DECLARE @DescripcionAnterior VARCHAR( 1024 ) = '';
		DECLARE @DescripcionModificada VARCHAR( 1024 ) = '';
		DECLARE @DescripcionError VARCHAR( 1024 );
		DECLARE @FechaNacimiento DATE;
		DECLARE @IdTipoDocId INT;
		DECLARE @IdNuevoTipoDocId INT;
		DECLARE @ValorDocId VARCHAR( 64 );
		DECLARE @IdPuesto INT;
		DECLARE @IdNuevoPuesto INT;
		DECLARE @IdDepartamento INT;
		DECLARE @IdNuevoDepartamento INT;
		DECLARE @FNombreValido BIT = 1;			--True
		DECLARE @FNombreRepetido BIT = 0;		--False
		DECLARE @FDocumentoIdentidadValido BIT = 1;		--True
		DECLARE @FDocumentoIdentidadRepetido BIT = 0;	--False

		SET @inNuevoNombre = LTRIM( RTRIM( @inNuevoNombre ) );
		SET @inNuevoDocId = LTRIM( RTRIM( @inNuevoDocId ) );
		SET @inNuevaFechaNac = CONVERT ( DATE, @inNuevaFechaNac);
		SET @IdPostByUser = ( SELECT 
									U.Id AS Id
							  FROM
									dbo.Usuario AS U
							  WHERE
									U.Nombre = @inUsername );
		SET @FechaNacimiento = ( SELECT 
										E.FechaNacimiento AS FechaNacimiento
									FROM
										dbo.Empleado AS E
									WHERE
										E.Nombre = @inNombre );
		SET @IdTipoDocId = ( SELECT 
									E.IdTipoValorDocIdentidad AS IdTipoDocId
								FROM
									dbo.Empleado AS E
								WHERE 
									E.Nombre = @inNombre );
		SET @IdNuevoTipoDocId = ( SELECT 
									TD.id AS IdNuevoTipoDocId
								FROM 
									dbo.TipoDocId AS TD
								WHERE
									TD.Nombre = @inNuevoTipoDocId );
		SET @ValorDocId = ( SELECT 
									E.ValorDocumentoIdentidad AS ValorDocId
								FROM
									dbo.Empleado AS E
								WHERE 
									E.Nombre = @inNombre );
		SET @IdPuesto = ( SELECT 
							E.IdPuesto AS IdPuesto
						FROM 
							dbo.Empleado AS E 
						WHERE
							E.Nombre = @inNombre );
		SET @idNuevoPuesto = ( SELECT
									P.Id AS IdNuevoPuesto
								FROM 
									dbo.Puesto AS P
								WHERE
									P.Nombre = @inNuevoPuesto );
		SET @IdDepartamento = ( SELECT 
									E.IdDepartamento AS IdDepartamento
								FROM 
									dbo.Empleado AS E 
								WHERE
									E.Nombre = @inNombre );
		SET @IdNuevoDepartamento = ( SELECT 
											D.id AS IdNuevoDepartamento
										FROM 
											dbo.Departamento AS D
										WHERE
											D.Nombre = @inNuevoDepartamento );
		SET @DescripcionError = ( 'Resultado exitoso' );
		SET @DescripcionAnterior = ( ' Nombre: '
									+ CONVERT( VARCHAR( 64 ) , @inNombre )
									+ ' Tipo ID DocId: '
									+ CONVERT( VARCHAR( 64 ) , @IdTipoDocId )
									+ ' DocId: '
									+ CONVERT( VARCHAR( 64 ) , @ValorDocId )
									+ ' Fecha nacimiento: '
									+ CONVERT( VARCHAR( 64 ) , @FechaNacimiento )
									+ ' ID Puesto: '
									+ CONVERT( VARCHAR( 64 ) , @IdPuesto ) 
									+ ' ID Departamento: '
									+ CONVERT( VARCHAR( 64 ) , @IdDepartamento ) );
		SET @DescripcionModificada = ( ' Nombre: '
									+ CONVERT( VARCHAR( 64 ) , @inNuevoNombre )
									+ ' Tipo ID DocId: '
									+ CONVERT( VARCHAR( 64 ) , @IdNuevoTipoDocId )
									+ ' DocId: '
									+ CONVERT( VARCHAR( 64 ) , @inNuevoDocId )
									+ ' Fecha nacimiento: '
									+ CONVERT( VARCHAR( 64 ) , @inNuevaFechaNac )
									+ ' ID Puesto: '
									+ CONVERT( VARCHAR( 64 ) , @IdNuevoPuesto ) 
									+ ' ID Departamento: '
									+ CONVERT( VARCHAR( 64 ) , @IdNuevoDepartamento ) );
		
		--VALIDAR SI FORMATO NOMBRE ES VALIDO
		IF PATINDEX( '%[^A-Za-z ]%', @inNuevoNombre ) > 0 OR @inNuevoNombre = ''
		BEGIN 
			SET @outResultCode = 50009;		--Nombre no alfabetico
			SET @FNombreValido = 0;
		END;

		--VALIDAR SI NOMBRE EXISTE
		IF @FNombreValido = 1 AND 
			EXISTS ( 
				SELECT 1 
				FROM dbo.Empleado AS E 
				WHERE LOWER( E.Nombre ) LIKE LOWER( @inNuevoNombre ) AND
				E.ValorDocumentoIdentidad != @ValorDocId)
		BEGIN 
			SET @outResultCode = 50007		--Nombre ya existe
			SET @FNombreRepetido = 1;
		END;

		--VALIDAR SI FORMATO DOCUMENTO IDENTIDAD ES VALIDO
		IF @FNombreValido = 1 AND 
			@FNombreRepetido = 0 AND
			PATINDEX( '%[^0-9-]%', @inNuevoDocId ) > 0 OR @inNuevoDocId = ''
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
				WHERE E.ValorDocumentoIdentidad = @inNuevoDocId AND
				LOWER( E.Nombre ) NOT LIKE LOWER( @inNombre ) AND
				E.IdTipoValorDocIdentidad = @IdNuevoTipoDocId)
		BEGIN
			SET @outResultCode = 50006		--Documento identidad ya existe
			SET @FDocumentoIdentidadRepetido = 1;
		END;

		SET @DescripcionError = ( SELECT
											'Error ' + CONVERT( VARCHAR( 64 ), @outResultCode) 
											+ ' - ' + E.Descripcion 
										From
											dbo.Error AS E
										WHERE
											E.Codigo = @outResultCode );
		
		--INICIO DE TRASACCION
		BEGIN TRANSACTION ActualizarDatos
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
						@DescripcionError AS Resultado,
						@DescripcionAnterior AS Original,
						@DescripcionModificada AS Actualizada
				   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
			);

			--Actualiza los datos
			IF @FNombreValido = 1 AND 
				@FNombreRepetido = 0 AND
				@FDocumentoIdentidadValido = 1 AND
				@FDocumentoIdentidadRepetido = 0
			BEGIN 
				UPDATE 
					E
				SET
					E.Nombre = @inNuevoNombre,
					E.IdTipoValorDocIdentidad = @IdNuevoTipoDocId,
					E.ValorDocumentoIdentidad = @inNuevoDocId,
					E.FechaNacimiento = @inNuevaFechaNac,
					E.IdPuesto = @idNuevoPuesto,
					E.IdDepartamento = @IdNuevoDepartamento
				FROM 
					dbo.Empleado AS E
				WHERE
					E.Nombre = @inNombre

				SET @outResultCode = 0;
			
			END;
		COMMIT TRANSACTION  ActualizarDatos
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
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