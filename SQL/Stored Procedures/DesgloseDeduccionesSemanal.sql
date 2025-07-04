USE [DBProject]
GO
/****** Object:  StoredProcedure [dbo].[DesgloseDeduccionesSemanal]    Script Date: 13/6/2025 22:40:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[DesgloseDeduccionesSemanal](
	@inUsername VARCHAR( 64 )
	,@inIdSemana INT
	,@outResultCode INT OUTPUT )
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @IdEmpleado INT
		DECLARE @NumSemanas INT

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
			, V.ValorPorcentual * M.SalarioBruto AS MontoDeduccion
		FROM
			DBO.EmpleadoXSemanaPlanilla AS M
		INNER JOIN DBO.Empleado AS E
		ON E.id = M.idEmpleado
		INNER JOIN DBO.EmpleadoXTipoDeduccion AS D
		ON D.idEmpleado = E.id
		INNER JOIN DBO.VistaDeduccionesPorcentuales AS V
		ON V.IdTipoDeduccion = D.idTipoDeduccion
		WHERE
			M.idEmpleado = @IdEmpleado
		AND M.idSemanaPlanilla = @inIdSemana
		AND NOT EXISTS(SELECT 1--Hay que revisar que no haya desasociaciones para evitar repetidos
						FROM 
							DBO.EmpleadoXTipoDeduccionNoObligatoriaArchive E
						WHERE 
							E.idEmpleadoXTipoDeduccionNoObligatoria = D.id )

		SELECT
			@NumSemanas = DATEDIFF(WEEK, M.FechaInicio , M.FechaFin)---Obtener cantidad de semanas de mes planilla
		FROM
			DBO.SemanaPlanilla AS P
		INNER JOIN DBO.MesPlanilla AS M
		ON P.idMesPlanilla = M.id
		WHERE
			P.id = @inIdSemana
							
		----Desplegar toda la información de deducciones fijas
		SELECT 
			V.Nombre AS Nombre
			,0 AS PorcentajeAplicado
			, V.Monto/@NumSemanas AS MontoDeduccion
		FROM
			DBO.EmpleadoXSemanaPlanilla AS M
		INNER JOIN DBO.Empleado AS E
		ON E.id = M.idEmpleado
		INNER JOIN DBO.EmpleadoXTipoDeduccion AS D
		ON D.idEmpleado = E.id
		INNER JOIN DBO.VistaDeduccionesFijas AS V
		ON V.IdTipoDeduccion = D.idTipoDeduccion
		AND V.IdEmpleado = M.idEmpleado
		WHERE
			M.idEmpleado = @IdEmpleado
			AND M.idSemanaPlanilla = @inIdSemana
		AND NOT EXISTS(SELECT 1 --Hay que revisar que no haya desasociaciones para evitar repetidos
						FROM 
							DBO.EmpleadoXTipoDeduccionNoObligatoriaArchive E
						WHERE 
							E.idEmpleadoXTipoDeduccionNoObligatoria = D.id )
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
