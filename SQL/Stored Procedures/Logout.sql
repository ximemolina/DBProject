ALTER PROCEDURE [dbo].[Logout](
	@inUsername VARCHAR(64)
	, @inIpAdress VARCHAR(64)
	, @outResultCode INT OUTPUT)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @IdTipoEvento INT=  2; ---Id tipo de evento de Logout
		DECLARE @IdPostByUser INT; ---Id Usuario que esta realizando el evento
		DECLARE @Descripcion VARCHAR( 1024 )= ''; ---Descripcion de Evento Ocurrido

		SET @IdPostByUser = ( SELECT U.id 
								FROM dbo.Usuario AS U 
								WHERE U.Nombre = @inUsername );
		SET @outResultCode = 0; ---Codigo error 0 indica que no hubo error

		INSERT dbo.EventLog( 	---Insercion de evento Login Exitoso a BitacoraEventos
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