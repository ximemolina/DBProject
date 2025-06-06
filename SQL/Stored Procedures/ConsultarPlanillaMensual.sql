USE [DBProject]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[ConsultarPlanillaMensual] (
	@inUsername VARCHAR( 64 )
	,@inIpAdress VARCHAR( 64 )
	,@outResultCode INT OUTPUT )
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @IdEmpleado INT
		DECLARE @IdPostByUser INT
		DECLARE @Descripcion VARCHAR( 1024 )
		DECLARE @IdTipoEvento INT = 11 --Evento Consulta Planilla Mensual
		DECLARE @FechaInicio DATE
		DECLARE @FechaFin DATE
		DECLARE @IdPrimerMes INT

		SET @outResultCode = 0

		SELECT
			@IdEmpleado = E.id
			,@IdPostByUser = U.id
		FROM
			DBO.Empleado AS E
		INNER JOIN DBO.Usuario AS U
		ON E.IdUsuario = U.id
		WHERE
			U.Nombre = @inUsername

		SELECT TOP( 1 ) ---Fin fecha de mes más actual
			@FechaFin = M.FechaFin
		FROM 
			[dbo].[VistaEmpleadoXSemana] AS V
		INNER JOIN DBO.MesPlanilla AS M
		ON M.id = V.IdMes
		WHERE
			V.IdEmpleado = @idEmpleado
		ORDER BY
			V.IdMes DESC --meses mas actuales

		SELECT
			@IdPrimerMes = MIN(M.IdMes) --Obtener ID de mes más viejo con una subconsulta
		FROM (
			SELECT TOP (12)
				V.IdMes,
				SUM(V.SalarioBruto) AS SalarioBruto,
				SUM(V.TotalDeducciones) AS TotalDeducciones,
				SUM(V.SalarioNeto) AS SalarioNeto
			FROM 
				[dbo].[VistaEmpleadoXSemana] AS V
			WHERE
				V.IdEmpleado = @idEmpleado
			GROUP BY
				V.IdMes
			ORDER BY
				V.IdMes DESC
		) AS M;

		SELECT
			@FechaInicio = M.FechaInicio --Obtener fecha de inicio de mes más viejo
		FROM
			DBO.MesPlanilla AS M
		WHERE
			M.id = @IdPrimerMes

		SELECT TOP( 12 ) ---Obtener 12 meses
			V.IdMes AS IdMes
			, SUM(V.SalarioBruto) AS SalarioBruto ---Acumular todo el salario bruto de ese mes
			, SUM(V.TotalDeducciones) AS TotalDeducciones ---Acumular todas las deducciones de ese mes
			, SUM(V.SalarioNeto) AS SalarioNeto ---Acumular todo el salarioNeto
		FROM 
			[dbo].[VistaEmpleadoXSemana] AS V
		WHERE
			V.IdEmpleado = @idEmpleado
		GROUP BY
			V.IdMes 
		ORDER BY
			V.IdMes DESC --meses mas actuales
		

		SET @Descripcion = ( 'Id Empleado: ' 
							+ CONVERT( VARCHAR( 64 ) , @IdEmpleado ) 
							+ '. Fecha Inicio Planilla: ' 
							+ CONVERT( VARCHAR( 64 ) , @FechaInicio ) 
							+ '. Fecha Fin Planilla: ' 
							+ CONVERT( VARCHAR( 64 ) , @FechaFin ) )

		INSERT INTO dbo.EventLog( 	---Insercion de evento ConsultaMes
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
END