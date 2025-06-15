USE [DBProject]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER VIEW [dbo].[VistaDeduccionesFijas]
AS
	SELECT
		E.idEmpleado AS IdEmpleado
		,D.id AS IdTipoDeduccion
		,D.Nombre AS Nombre
		,P.Valor AS Monto
	FROM
		DBO.TipoDeduccion AS D
	INNER JOIN DBO.EmpleadoXTipoDeduccion AS E
	ON E.idTipoDeduccion = D.id
	INNER JOIN DBO.EmpleadoXTipoDeduccionNoObligatoria AS N
	ON N.idEmpleadoXTipoDeduccion = E.id
	INNER JOIN DBO.EmpleadoXTipoDeduccionNoObligatoriaNoPorcentual AS P
	ON P.idEmpleadoXTipoDeduccionNoObligatoria = N.idEmpleadoXTipoDeduccion

GO


