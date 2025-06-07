CREATE VIEW DBO.VistaDeduccionesPorcentuales
AS

	SELECT
		D.Nombre AS Nombre
		,TD.valor AS ValorPorcentual
	FROM
		DBO.TipoDeduccion AS D
	INNER JOIN DBO.TipoDeduccionPorcentual AS TD
	ON D.id = TD.idTipoDeduccion

GO

CREATE VIEW DBO.VistaDeduccionesFijas
AS
	SELECT
		D.Nombre AS Nombre
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