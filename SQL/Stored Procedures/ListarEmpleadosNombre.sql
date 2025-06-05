CREATE PROCEDURE [dbo].[ListarEmpleadosNombre] ( 
	@inNombre VARCHAR( 64 )
	, @inUsername VARCHAR( 64 )
	, @inIpAdress VARCHAR( 64 )
	, @outResultCode INT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		DECLARE @IdTipoEvento INT = 4;		--Consulta por filtro
		DECLARE @IdPostByUser INT;
		DECLARE @Descripcion VARCHAR( 1024 );

		SET @inNombre = LTRIM(RTRIM(@inNombre));
		SET @IdPostByUser = ( SELECT 
									U.Id AS Id
							  FROM
									dbo.Usuario AS U
							  WHERE
									U.Nombre = @inUsername );
		SET @Descripcion = ( 'Valor del filtro por nombre: ' 
							+ CONVERT( VARCHAR(64) , @inNombre ));

		IF PATINDEX( '%[^A-Za-z ]%', @inNombre ) > 0 OR LTRIM(RTRIM(@inNombre)) = ''
		BEGIN 
			SET @outResultCode = 50009;		--Nombre no alfabetico
		END;
		
		ELSE
		BEGIN 
			SELECT 
				E.Nombre AS Nombre
				, P.Nombre AS Puesto
			FROM
				dbo.Empleado AS E
			INNER JOIN
				dbo.Puesto AS P
			ON
				E.IdPuesto = P.id
			WHERE
				LOWER(E.Nombre) LIKE LOWER('%' + @inNombre + '%') AND E.EsActivo = 1
			ORDER BY
				E.Nombre

			---Inserta Evento en BitacoraEvento
			INSERT dbo.EventLog( 	
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

			SET @outResultCode = 0;			--Hay registros
		END;

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
END;