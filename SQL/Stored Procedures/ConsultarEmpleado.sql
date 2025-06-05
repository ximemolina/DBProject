CREATE PROCEDURE [dbo].[ConsultarEmpleado] (
	@inNombre VARCHAR( 64 )
	, @outResultCode INT OUTPUT
)
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT 
			E.Nombre AS Nombre,
			E.ValorDocumentoIdentidad AS DocId,
			E.FechaNacimiento AS FechaNacimiento,
			P.Nombre AS Puesto,
			TD.Nombre AS TipoDocId,
			D.Nombre AS Departamento
		FROM 
			dbo.Empleado AS E
		INNER JOIN 
			dbo.Puesto AS P
		ON 
			E.IdPuesto = P.Id
		INNER JOIN
			dbo.TipoDocId AS TD
		ON 
			E.IdTipoValorDocIdentidad = TD.id
		INNER JOIN
			dbo.Departamento AS D
		ON
			E.IdDepartamento = D.id
		WHERE 
			E.Nombre = @inNombre

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

		SET @outResultCode = 50008

	END CATCH

	SET NOCOUNT OFF;
END;
