USE [DBProject]
GO

/****** Object:  View [dbo].[VistaEmpleadoXSemana]    Script Date: 6/6/2025 20:00:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VistaEmpleadoXSemana]
AS

	SELECT
		M.id AS IdMes
		,E.id AS IdEmpleado
		,ESP.SalarioBruto AS SalarioBruto
		,ESP.SumaDeducciones AS TotalDeducciones
		,ESP.SalarioBruto - ESP.SumaDeducciones AS SalarioNeto
	FROM
		DBO.EmpleadoXSemanaPlanilla AS ESP
	INNER JOIN DBO.SemanaPlanilla AS S
	ON ESP.idSemanaPlanilla = S.id
	INNER JOIN DBO.Empleado AS E
	ON ESP.idEmpleado = E.id
	INNER JOIN DBO.MesPlanilla AS M
	ON S.idMesPlanilla = M.id

GO


