CREATE PROCEDURE [dbo].[ListarPuestos] ( 
	@outResultCode INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SELECT 
			P.Nombre AS Puesto
		FROM 
			dbo.Puesto AS P

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
