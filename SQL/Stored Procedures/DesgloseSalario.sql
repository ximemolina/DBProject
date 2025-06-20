CREATE PROCEDURE [dbo].[DesgloseSalario](
	@inUsername VARCHAR( 64 ) 
	,@inIdSemana INT
	,@outResultCode INT OUTPUT )
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		DECLARE @IdEmpleado INT

		SET @outResultCode = 0

		SELECT
			@IdEmpleado = E.id
		FROM
			DBO.Usuario AS U
		INNER JOIN DBO.Empleado AS E
		ON U.id = E.IdUsuario
		WHERE
			U.Nombre = @inUsername

		SELECT
			A.HoraInicio AS HoraEntrada
			, A.HoraFin AS HoraSalida
			, CASE WHEN T.id = 1 THEN M.QHoras ELSE 0 END AS HoraOrdinaria
			, CASE WHEN T.id = 1 THEN P.Monto ELSE 0 END AS MontoHoraOrdinaria
			, CASE WHEN T.id = 2 THEN M.QHoras ELSE 0 END AS HoraExtraNormal
			, CASE WHEN T.id = 2 THEN P.Monto ELSE 0 END  AS MontoHoraExtraNormal
			, CASE WHEN T.id = 3 THEN M.QHoras ELSE 0 END AS HoraExtraDoble
			, CASE WHEN T.id = 3 THEN P.Monto ELSE 0 END AS MontoExtraDoble
		FROM
			DBO.EmpleadoXTipoJornadaXSemana AS E
		INNER JOIN DBO.MarcaAsistencia AS A
		ON A.idEmpleadoXTipoJornadaXSemana = E.id
		INNER JOIN DBO.MovimientoAsistencia AS M
		ON M.idMarcaAsistencia = A.id
		INNER JOIN DBO.MovimientoPlanilla AS P
		ON P.id = M.idMovimientoPlanilla
		INNER JOIN DBO.TipoMovimiento AS T
		ON T.id = P.idTipoMovimiento
		WHERE
			E.idEmpleado = @IdEmpleado
		AND @inIdSemana = E.idSemanaPlanilla ---solo mostrar dias de esa semana

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