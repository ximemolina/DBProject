USE [DBProject]
GO
/****** Object:  StoredProcedure [dbo].[RevisarUsuarioContrasena]    Script Date: 8/6/2025 19:35:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[RevisarUsuarioContrasena](
	@inUsername VARCHAR( 64 )
	, @inPassword VARCHAR( 64 )
	, @inIpAdress VARCHAR( 64 )
	, @outResultCode INT OUTPUT )
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		DECLARE @IdTipoEvento INT=  1; ---Id tipo de evento de Login Exitoso
		DECLARE @IdPostByUser INT; ---Id Usuario que est� realizando el evento
		DECLARE @Descripcion VARCHAR( 1024 )= ''; ---Descripci�n de Evento Ocurrido
		DECLARE @UsuarioNoExisteFlag BIT = 1

		SET @outResultCode=0; ---C�digo error 0 indica que no hubo error
		SET @IdTipoEvento = 1; ---Id tipo de evento de Login No Exitoso

		---Revisar que usuario si exista en tabla Usuario
		IF NOT EXISTS ( SELECT 1 FROM dbo.Usuario A WHERE A.Nombre = @inUsername )
		BEGIN

			SET @IdPostByUser = 5;---Asigna id por default de user "no conocido"
			SET @outResultCode = 50002; ---Contraseña no existe
			SET @Descripcion = 'Username: No Conocido, Resultado: No Exitoso'
			SET @UsuarioNoExisteFlag = 0 --desactivar bandera

		END;
		IF @UsuarioNoExisteFlag = 1
		BEGIN
			--Obtener id de usuario
			SELECT 
				@IdPostByUser = U.id
			FROM
				DBO.Usuario AS U
			WHERE
				@inUsername = U.Nombre

			---Revisar que usuario y contrasena coincidan
			IF NOT EXISTS ( SELECT 1 FROM dbo.Usuario A WHERE A.Nombre = @inUsername AND A.Contraseña = @inPassword )
			BEGIN

				SET @outResultCode = 50002; ---Contrasena no existe
				SET @Descripcion = ( 'Username: ' 
									+ CONVERT( VARCHAR( 64 ) , @inUsername ) 
									+ '. Resultado: No Exitoso' )			
			END;
			ELSE
			BEGIN
				---Caso de Login Exitoso
				SET @Descripcion = ( 'Username: ' 
									+ CONVERT( VARCHAR( 64 ) , @inUsername ) 
									+ '. Resultado: Exitoso' )
			END
		END;

		INSERT dbo.EventLog( 	---Inserci�n de evento Login Exitoso a BitacoraEventos
			IdTipoEvento
			,IdPostByUser
			,JSON
		) VALUES (
			@IdTipoEvento
			,@IdPostByUser
			,( SELECT 
					@inIpAdress AS PostInIp,
					GETDATE() AS PostTime,
					@Descripcion AS Descripcion
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER )
		);

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
