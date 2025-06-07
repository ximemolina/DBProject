USE [DBProject]
GO

/****** Object:  View [dbo].[VistaDeduccionesFijas]    Script Date: 7/6/2025 13:27:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[VistaDeduccionesFijas]
AS
	SELECT
		D.id AS IdTipoDeduccion
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


