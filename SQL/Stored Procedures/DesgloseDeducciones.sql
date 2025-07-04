USE [DBProject]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER   PROCEDURE [dbo].[DesgloseDeducciones](
	@inUsername VARCHAR( 64 )
	,@inIdMes INT
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

		----Desplegar toda la información de deducciones porcentuales
		SELECT 
			V.Nombre AS Nombre
			,V.ValorPorcentual AS PorcentajeAplicado
			, T.MontoTotal AS MontoDeduccion
		FROM
			DBO.EmpleadoXMesPlanilla AS M
		INNER JOIN DBO.EmpleadoXMesPlanillaXTipoDeduccion AS T
		ON T.idEmpleadoXMesPlanilla = M.id
		INNER JOIN DBO.VistaDeduccionesPorcentuales AS V
		ON V.IdTipoDeduccion = T.idTipoDeduccion
		WHERE
			M.idEmpleado = @IdEmpleado
			AND M.idMesPlanilla = @inIdMes

		----Desplegar toda la información de deducciones fijas
		SELECT 
			V.Nombre AS Nombre
			,0 AS PorcentajeAplicado
			, T.MontoTotal AS MontoDeduccion
		FROM
			DBO.EmpleadoXMesPlanilla AS M
		INNER JOIN DBO.EmpleadoXMesPlanillaXTipoDeduccion AS T
		ON T.idEmpleadoXMesPlanilla = M.id
		INNER JOIN DBO.VistaDeduccionesFijas AS V
		ON V.IdTipoDeduccion = T.idTipoDeduccion
		AND V.IdEmpleado = M.idEmpleado
		WHERE
			M.idEmpleado = @IdEmpleado
			AND M.idMesPlanilla = @inIdMes

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
