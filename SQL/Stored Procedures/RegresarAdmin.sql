CREATE PROCEDURE DBO.RegresarAdmin (
	  @inUsername VARCHAR(64)
	, @inIpAdress VARCHAR(64)
	, @outResultCode INT OUTPUT )
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @IdPostByUser INT
		DECLARE @IdTipoEvento INT = 13 --Id Evento Regresar a Interfaz Admin
		
		SET @outResultCode = 0

		SELECT
			@IdPostByUser = U.id ---Obtener id de usuario
		FROM
			DBO.Usuario AS U
		WHERE
			U.Nombre = @inUsername

		INSERT dbo.EventLog( 	---Inserci�n de evento Login Exitoso a BitacoraEventos
			IdTipoEvento
			,IdPostByUser
			,JSON
		) VALUES (
			@IdTipoEvento
			,@IdPostByUser
			,( SELECT 
					@inIpAdress AS PostInIp,
					GETDATE() AS PostTime
			   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
		);
	END TRY
	BEGIN CATCH
		
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

	SET NOCOUNT OFF;
	
END;