USE [DBProject]
GO

/****** Object:  View [dbo].[VistaDebitoSemanas]    Script Date: 8/6/2025 13:56:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[VistaDebitoSemanas]
AS
	SELECT
		E.idEmpleado AS IdEmpleado
		, E.idSemanaPlanilla AS IdSemanaPlanilla
		, T.id AS IdMovimiento
		, SUM(A.QHoras) AS Horas ---se obtiene cantidad total de horas de los movs
	FROM
		DBO.EmpleadoXSemanaPlanilla AS E
	INNER JOIN DBO.MovimientoPlanilla AS M
	ON M.idEmpleadoXSemanaPlanilla = E.id
	INNER JOIN DBO.TipoMovimiento AS T
	ON T.id = M.idTipoMovimiento
	INNER JOIN DBO.MovimientoAsistencia AS A
	ON M.id = A.idMovimientoPlanilla
	GROUP BY
		E.idEmpleado, E.idSemanaPlanilla, T.id ---Se agrupan columnas que sean de la misma semana,pertenezcan 
													---al mismo empleado y sean del mismo tipo de movimiento
GO


