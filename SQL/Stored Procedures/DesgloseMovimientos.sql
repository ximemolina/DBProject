CREATE PROCEDURE DBO.DesgloseMovimientos(
	@inIdTipoMovimiento INT
	,@inIdMovimiento INT
	, @outResultCode INT OUTPUT )
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		SET @outResultCode = 0;	

		IF @inIdTipoMovimiento = 1 OR @inIdTipoMovimiento = 2 OR @inIdTipoMovimiento = 3 ---Movimientos por horas de trabajo
		BEGIN
			SELECT
				M.Nombre AS Nombre
				,A.QHoras AS Horas
				, S.HoraInicio AS HoraInicio
				, S.HoraFin AS HoraFin
			FROM
				DBO.MovimientoAsistencia AS A
			INNER JOIN DBO.MovimientoPlanilla AS P
			ON P.id = A.idMovimientoPlanilla
			INNER JOIN DBO.MarcaAsistencia AS S
			ON S.id = A.idMarcaAsistencia
			INNER JOIN DBO.TipoMovimiento AS M
			ON P.idTipoMovimiento = M.id
			WHERE
				A.idMovimientoPlanilla = @inIdMovimiento
		END
		ELSE IF @inIdTipoMovimiento = 4 OR @inIdTipoMovimiento = 5 ---Movimientos por Deducciones
		BEGIN 
			SELECT
				T.Nombre AS Nombre
				,0 AS Horas ---Estos 0 se ponen solo para hacer que el formato de ambos select sea el mismo
				,0 AS HoraInicio
				,0 AS HoraFin 
			FROM
				DBO.MovimientoDeduccion AS A
			INNER JOIN DBO.MovimientoPlanilla AS P
			ON A.idMovimientoPlanilla = P.id
			INNER JOIN DBO.EmpleadoXTipoDeduccion AS E
			ON A.idEmpleadoXTipoDeduccion = E.id
			INNER JOIN DBO.TipoDeduccion AS T
			ON E.idTipoDeduccion = T.id
			WHERE
				A.idMovimientoPlanilla = @inIdMovimiento			

		END

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
		
		SET @outResultCode = 50008;		

	END CATCH

	SET NOCOUNT OFF;
END