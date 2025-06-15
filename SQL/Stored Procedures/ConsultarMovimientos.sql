CREATE PROCEDURE DBO.ConsultarMovimientos (
	@inUsername VARCHAR( 64 )
	,@outResultCode INT OUTPUT )
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @IdEmpleado INT

		SET @outResultCode = 0
		
		SELECT 
			@IdEmpleado = E.id
		FROM
			DBO.Usuario AS U
		INNER JOIN DBO.Empleado AS E
		ON U.id = E.IdUsuario
		WHERE
			U.Nombre = @inUsername
		
		SELECT
			P.Fecha AS Fecha
			,P.Monto AS Monto
			, P.id AS IdMovimiento
			,P.idTipoMovimiento AS IdTipoMovimiento
		FROM
			DBO.MovimientoPlanilla AS P
		INNER JOIN DBO.EmpleadoXSemanaPlanilla AS E
		ON P.idEmpleadoXSemanaPlanilla = E.id
		WHERE
			E.idEmpleado = @IdEmpleado
		ORDER BY
			P.Fecha DESC

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
END