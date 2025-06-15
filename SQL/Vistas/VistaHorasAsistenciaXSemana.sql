CREATE VIEW VistaHorasAsistenciaXSemana
AS			
	SELECT
		V.IdSemanaPlanilla AS IdSemanaPlanilla
		,V.IdEmpleado AS IdEmpleado
		,SUM(CASE WHEN V.IdMovimiento = 1 THEN Horas ELSE 0 END) AS HorasOrdinarias
		,SUM(CASE WHEN V.IdMovimiento = 2 THEN Horas ELSE 0 END) AS HorasExtraNormales
		,SUM(CASE WHEN V.IdMovimiento = 3 THEN Horas ELSE 0 END) AS HorasExtraDobles
	FROM 
		DBO.VistaDebitoSemanas AS V
	GROUP BY 
		V.IdSemanaPlanilla, V.IdEmpleado
GO