USE [DBProject]
GO

/****** Object:  View [dbo].[VistaDeduccionesPorcentuales]    Script Date: 7/6/2025 13:27:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[VistaDeduccionesPorcentuales]
AS

	SELECT
		D.id AS IdTipoDeduccion
		,D.Nombre AS Nombre
		,TD.valor AS ValorPorcentual
	FROM
		DBO.TipoDeduccion AS D
	INNER JOIN DBO.TipoDeduccionPorcentual AS TD
	ON D.id = TD.idTipoDeduccion

GO


