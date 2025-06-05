CREATE PROCEDURE [dbo].[ListarDepartamentos] ( 
	@outResultCode INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SELECT 
			D.Nombre AS Departamento
		FROM 
			dbo.Departamento AS D

		SET @outResultCode = 0;
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

		SET @outResultCode = 50008;

	END CATCH

    SET NOCOUNT OFF;
END;