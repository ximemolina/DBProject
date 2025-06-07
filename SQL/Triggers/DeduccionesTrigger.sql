CREATE TRIGGER DeduccionesTrigger
ON DBO.Empleado
FOR INSERT ---Indicar acción que dispara trigger
AS
BEGIN
	
	BEGIN TRY
		DECLARE @IdEmpleado INT = ( SELECT ---Obtener Id Empleado que acaba de ser insertado
										I.id
									FROM INSERTED AS I )
	
		INSERT INTO DBO.EmpleadoXTipoDeduccion (
			idEmpleado
			,idTipoDeduccion )
		VALUES (
			@IdEmpleado
			, 1 ) ---Conecta Empleado con las deducciones obligatorias

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
		
	END CATCH
END;
