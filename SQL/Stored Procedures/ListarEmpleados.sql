CREATE PROCEDURE [dbo].[ListarEmpleados] (
    @outResultCode INT OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
	BEGIN TRY
		SELECT
			E.Nombre AS Nombre
			, P.Nombre AS Puesto
		FROM 
			dbo.Empleado AS E
		INNER JOIN 
			dbo.Puesto AS P
		ON
			E.IdPuesto = P.id
		WHERE 
			E.EsActivo = 1		--Filtrar empleados activos
		ORDER BY
			E.Nombre;
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