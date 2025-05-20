CREATE PROCEDURE [dbo].[MostrarError](
	@inCodeError INT
	,@outResultCode INT OUTPUT )
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		SELECT
			E.Descripcion AS Descripcion --Obtener descripcion de error con base a su codigo
		FROM
			dbo.Error AS E
		WHERE
			E.Codigo = @inCodeError --Verificar que ambos codigos sean iguales

		SET @outResultCode = 0; --Codigo error 0 indica que no hubo errores

		RETURN @outResultCode;

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
GO