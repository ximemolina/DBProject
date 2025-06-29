USE [DBProject]
GO
/****** Object:  StoredProcedure [dbo].[ConsultarPlanillaSemanal]    Script Date: 14/6/2025 13:36:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   PROCEDURE [dbo].[ConsultarPlanillaSemanal](
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
		DECLARE @IdTipoEvento INT = 10 --Evento Consulta Planilla Semanal
		DECLARE @FechaInicio DATE
		DECLARE @FechaFin DATE
		DECLARE @IdPrimeraSemana INT

		SET @outResultCode = 0

		SELECT
			@IdEmpleado = E.id ---Obtener id del empleado que tiene ese usuario
			,@IdPostByUser = U.id
		FROM
			DBO.Usuario AS U
		INNER JOIN DBO.Empleado AS E
		ON U.id = E.IdUsuario
		WHERE
			U.Nombre = @inUsername

		SELECT TOP( 1 ) ---Fin fecha de mes más actual
			@FechaFin = M.FechaFin
		FROM 
			[dbo].[VistaEmpleadoXSemana] AS V
		INNER JOIN DBO.SemanaPlanilla AS M
		ON M.id = V.IdSemana
		WHERE
			V.IdEmpleado = @idEmpleado
		ORDER BY
			V.IdSemana DESC --semanas mas actuales

		SELECT
			@IdPrimeraSemana = MIN(M.IdSemana) --Obtener ID de mes más viejo con una subconsulta
		FROM (
			SELECT TOP (15)
				V.IdSemana AS IdSemana
				,V.SalarioBruto AS SalarioBruto
				,V.TotalDeducciones AS TotalDeducciones
				,V.SalarioNeto AS SalarioNeto
				,H.HorasOrdinarias AS HorasOrdinarias
				,H.HorasExtraNormales AS HorasExtraNormales
				,H.HorasExtraDobles AS HorasExtraDobles
			FROM 
				DBO.VistaEmpleadoXSemana AS V
			INNER JOIN dbo.VistaHorasAsistenciaXSemana AS H
				ON H.IdSemanaPlanilla = V.IdSemana
				AND H.IdEmpleado = V.IdEmpleado
			WHERE
				V.IdEmpleado = @IdEmpleado 
			ORDER BY 
				V.IdSemana DESC
		) AS M;

		SELECT
			@FechaInicio = M.FechaInicio --Obtener fecha de inicio de semana más viejo
		FROM
			DBO.SemanaPlanilla AS M
		WHERE
			M.id = @idPrimeraSemana


		SELECT TOP (15)
			V.IdSemana AS IdSemana
			,V.SalarioBruto AS SalarioBruto
			,V.TotalDeducciones AS TotalDeducciones
			,V.SalarioNeto AS SalarioNeto
			,H.HorasOrdinarias AS HorasOrdinarias
			,H.HorasExtraNormales AS HorasExtraNormales
			,H.HorasExtraDobles AS HorasExtraDobles
		FROM 
			DBO.VistaEmpleadoXSemana AS V
		INNER JOIN dbo.VistaHorasAsistenciaXSemana AS H
			ON H.IdSemanaPlanilla = V.IdSemana
			AND H.IdEmpleado = V.IdEmpleado
		WHERE
			V.IdEmpleado = @IdEmpleado 
		ORDER BY 
			V.IdSemana DESC

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
		SET @outResultCode = 50008

	END CATCH
	SET NOCOUNT OFF;
END