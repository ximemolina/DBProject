ALTER PROCEDURE [dbo].[EliminarEmpleado](
				@inDocId VARCHAR( 64 )
				,@inUsername VARCHAR( 64 )
				,@inIpAdress VARCHAR( 64 )
				,@outResultCode INT OUTPUT )
AS
BEGIN
	
	SET NOCOUNT OFF;
	
	BEGIN TRY

		DECLARE @IdTipoEvento INT = 6; ---Id TipoEvento Borrado Exitoso
		DECLARE @Nombre VARCHAR( 64 );
		DECLARE @TipoDocId VARCHAR( 64 );
		DECLARE @FechaNac DATE;
		DECLARE @Puesto VARCHAR( 64 );
		DECLARE @Departamento VARCHAR( 64 );
		DECLARE @Descripcion VARCHAR( 1024 );
		DECLARE @IdPostByUser INT;

		---Obtener nombre
		SET @Nombre = ( SELECT 
							E.Nombre AS Nombre
						FROM	
							dbo.Empleado AS E
						WHERE 
							E.ValorDocumentoIdentidad = @inDocId )
		---Obtener tipo de documento de identidad
		SET @TipoDocId = ( SELECT 
								TD.Nombre AS TipoDocId
							FROM
								dbo.TipoDocId AS TD
							INNER JOIN
								dbo.Empleado AS E
							ON 
								TD.id = E.IdTipoValorDocIdentidad
							WHERE
								E.ValorDocumentoIdentidad = @inDocId )
		---Obtener fehca de nacimiento
		SET @FechaNac = ( SELECT
								E.FechaNacimiento AS FechaNac
							FROM
								dbo.Empleado AS E
							WHERE 
								E.ValorDocumentoIdentidad = @inDocId )
		---Obtener nombre del puesto 
		SET @Puesto = ( SELECT
									P.Nombre AS Nombre
								FROM
									Puesto AS P
								INNER JOIN	
									dbo.Empleado AS E
								ON
									P.id = E.IdPuesto
								WHERE
									E.ValorDocumentoIdentidad = @inDocId )
		---Obtener departamento
		SET @Departamento = ( SELECT 
									D.Nombre AS Departamento
								FROM
									dbo.Departamento AS D
								INNER JOIN 
									dbo.Empleado AS E
								ON
									D.id = E.IdDepartamento
								WHERE
									E.ValorDocumentoIdentidad = @inDocId )
		SET @Descripcion = ( 'Nombre del Empleado: ' 
							+ CONVERT( VARCHAR(64) , @Nombre )
							+ '. Tipo documento identidad: '
							+ CONVERT( VARCHAR , @TipoDocId)
							+ '. Valor Documento de Identidad: ' 
							+ CONVERT( VARCHAR , @inDocId ) 
							+ '. Fecha de nacimiento: '
							+ CONVERT( VARCHAR, @FechaNac)
							+ '. Puesto: ' 
							+ CONVERT( VARCHAR(64) , @Puesto )
							+ '. Departamento: '
							+ CONVERT( VARCHAR , @Departamento) );
		---Obtener ID del user que está realizando la accion
		SET @IdPostByUser = ( SELECT 
									U.Id AS Id
								FROM 
									dbo.Usuario U
								WHERE
									U.Nombre = @inUsername )

		BEGIN TRANSACTION EliminarEmpleado

		---'Elimina' al empleado poniendo el activo en 0
		UPDATE E
		SET 
			E.EsActivo = 0
		FROM
			DBO.Empleado AS E
		WHERE 
			E.ValorDocumentoIdentidad = @inDocId;
	
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
						@Descripcion AS Descripcion
				   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
			);

		COMMIT TRANSACTION EliminarEmpleado

		SET @outResultCode = 0; ---Código de éxito

	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT>0
		BEGIN
			ROLLBACK TRANSACTION EliminarEmpleado;
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

		Set @outResultCode = 50008; --Error en base de datos

	END CATCH

	SET NOCOUNT ON;

END;
