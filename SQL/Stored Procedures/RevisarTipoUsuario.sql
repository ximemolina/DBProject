USE [DBProject]
GO

/****** Object:  StoredProcedure [dbo].[RevisarTipoUsuario]    Script Date: 25/5/2025 15:24:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[RevisarTipoUsuario](
	@inUsername VARCHAR( 64 )
	,@outResultCode INT OUTPUT )
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRY
		
		SET @outResultCode = 0

		SELECT 
			TU.Nombre ---Obtener Tipo Usuario
		FROM DBO.Usuario AS U
		INNER JOIN DBO.TipoUsuario AS TU
		ON TU.ID = U.IdTipoUsuario
		WHERE
			U.Nombre = @inUsername ---Revisar que nombres de usuario coincidan

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

		Set @outResultCode = 50008; --Error en base de datos
	END CATCH
	SET NOCOUNT OFF;

END;
GO


