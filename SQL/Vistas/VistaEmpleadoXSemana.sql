USE [DBProject]
GO

/****** Object:  View [dbo].[VistaEmpleadoXSemana]    Script Date: 8/6/2025 12:40:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER   VIEW [dbo].[VistaEmpleadoXSemana]
AS

	SELECT
		M.id AS IdMes
		,S.id AS IdSemana
		,ESP.idEmpleado AS IdEmpleado
		,ESP.SalarioBruto AS SalarioBruto
		,ESP.SumaDeducciones AS TotalDeducciones
		,ESP.SalarioBruto - ESP.SumaDeducciones AS SalarioNeto
	FROM
		DBO.EmpleadoXSemanaPlanilla AS ESP
	INNER JOIN DBO.SemanaPlanilla AS S
	ON ESP.idSemanaPlanilla = S.id
	INNER JOIN DBO.MesPlanilla AS M
	ON S.idMesPlanilla = M.id

GO


