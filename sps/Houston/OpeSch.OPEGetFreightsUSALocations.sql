/*
	EXEC [OpeSch].[OPEGetFreightsUSALocations] @pnClaUbicacion = 65, @pnEsDebug = 1
	EXEC [OpeSch].[OPEGetFreightsUSALocations] @pnClaUbicacion = 449, @pnEsDebug = 1

	EXEC [OpeSch].[OPEGetFreightsUSALocations] @pnClaUbicacion = 65
	SELECT * FROM [OpeSch].[OpeFreightFromHoustonToLocation]

	EXEC [OpeSch].[OPEGetFreightsUSALocations] @pnClaUbicacion = 449
	SELECT * FROM [OpeSch].[OpeFreightFromPasadenaToLocation]

	
*/

ALTER PROC [OpeSch].[OPEGetFreightsUSALocations]
@pnClaUbicacion   INT 
,@pnClaUsuarioMod INT			= 1
,@psNombrePcMod	  VARCHAR(64) = 'FURMAN JOB'
,@pnEsDebug		   TINYINT		= 0
AS
BEGIN
	DECLARE @nAnioMesInicio INT, @nAnioMesFin INT, @nEsAbrirTransaccion INT = 0, @sMensaje VARCHAR(MAX), @nIdFreightHou INT, @nIdFreightPas INT

	CREATE TABLE #tmpUSAFreight(
		AnioMes		  INT
		,FechaTabular DATETIME
		,ClaSemana INT
		,NomSemana VARCHAR(300)
		,ClaAgrupador1 INT
		,NomAgrupador1 VARCHAR(300)
		,ClaAgrupador2 INT
		,NomAgrupador2 VARCHAR(300)
		,ClaUbicacion INT
		,NomUbicacion VARCHAR(300)
		,Tons NUMERIC(22,6)
		,ImportePagarFinalUSD NUMERIC(22,4)
		,NumViaje INT
		,TonsCubicadas NUMERIC(22,6)
		,MillasViaje NUMERIC(22,4)
		,ClaTransporte INT
		,NomTransporte VARCHAR(300)
		,ClaTransportista INT
		,NomTransportista VARCHAR(300)
		,ClaCiudadDestino INT
		,NomCiudadDestino VARCHAR(300)
		,ClaEstadoDestino INT 
		,NomEstadoDestino VARCHAR(300)	
	)
	


	IF @pnClaUbicacion = 65
		SELECT	@nAnioMesInicio = ISNULL(MAX(AnioMes), 202301)
		FROM	[OpeSch].[OpeFreightFromHoustonToLocation] WITH(NOLOCK)
	ELSE
		SELECT	@nAnioMesInicio = ISNULL(MAX(AnioMes), 202301)
		FROM	[OpeSch].[OpeFreightFromPasadenaToLocation] WITH(NOLOCK)
		

	 SELECT @nAnioMesFin = YEAR(GETDATE())*100 + MONTH(GETDATE()) 

	IF @pnEsDebug = 1	
		SELECT @nAnioMesInicio = 202301, @nAnioMesFin = 202301

	IF @pnEsDebug = 1
		SELECT @nAnioMesInicio AS '@nAnioMesInicio', @nAnioMesFin As '@nAnioMesFin', @pnClaUbicacion AS '@pnClaUbicacion'

	INSERT INTO #tmpUSAFreight
	EXEC DEAMIDCON.MCSW_ERP.[MSWSch].[MSWFreightFromHoustonToPasadenaSrv]
	@pnAnioMesInicio	= @nAnioMesInicio, 
	@pnAnioMesFin		= @nAnioMesFin,
	@pnClaUbicacion		= @pnClaUbicacion

	IF @pnEsDebug = 1 
		SELECT * FROM #tmpUSAFreight
	ELSE
	BEGIN
		BEGIN TRY 
		IF @@TRANCOUNT = 0
		BEGIN 
			SET @nEsAbrirTransaccion = 1
			BEGIN TRAN 
		END		

		IF @pnClaUbicacion = 65
		BEGIN

			DELETE FROM [OpeSch].[OpeFreightFromHoustonToLocation] WHERE AnioMes >= @nAnioMesInicio	

			SELECT	@nIdFreightHou = ISNULL(MAX(IdFreightHou),0)
			FROM	[OpeSch].[OpeFreightFromHoustonToLocation]

			INSERT INTO [OpeSch].[OpeFreightFromHoustonToLocation]
			(IdFreightHou
			,AnioMes
			,FechaTabular
			,ClaSemana
			,NomSemana
			,ClaAgrupador1
			,NomAgrupador1
			,ClaAgrupador2
			,NomAgrupador2
			,ClaUbicacion
			,NomUbicacion
			,Tons
			,ImportePagarFinalUSD
			,NumViaje
			,TonsCubicadas
			,MillasViaje
			,ClaTransporte
			,NomTransporte
			,ClaTransportista
			,NomTransportista
			,ClaCiudadDestino
			,NomCiudadDestino
			,ClaEstadoDestino
			,NomEstadoDestino
			,FechaUltimaMod
			,NombrePcMod
			,ClaUsuarioMod)
			SELECT
				IdFreightHou = ROW_NUMBER() OVER(ORDER BY AnioMes,ClaUbicacion,NumViaje,ClaTransportista, ClaCiudadDestino) + @nIdFreightHou
				,AnioMes
				,FechaTabular
				,ClaSemana
				,NomSemana
				,ClaAgrupador1
				,NomAgrupador1
				,ClaAgrupador2
				,NomAgrupador2
				,ClaUbicacion
				,NomUbicacion
				,Tons
				,ImportePagarFinalUSD
				,NumViaje
				,TonsCubicadas
				,MillasViaje
				,ClaTransporte
				,NomTransporte
				,ClaTransportista
				,NomTransportista
				,ClaCiudadDestino
				,NomCiudadDestino
				,ClaEstadoDestino
				,NomEstadoDestino
				,FechaUltimaMod = GETDATE()
				,NombrePcMod	= @psNombrePcMod
				,ClaUsuarioMod	= @pnClaUsuarioMod			
			FROM #tmpUSAFreight
		END
		ELSE
		BEGIN
			DELETE FROM [OpeSch].[OpeFreightFromPasadenaToLocation] WHERE AnioMes >= @nAnioMesInicio	


			SELECT	@nIdFreightPas = ISNULL(MAX(IdFreightPas),0)
			FROM	[OpeSch].[OpeFreightFromPasadenaToLocation]

			INSERT INTO [OpeSch].[OpeFreightFromPasadenaToLocation]
				(IdFreightPas
				,AnioMes
				,FechaTabular
				,ClaSemana
				,NomSemana
				,ClaAgrupador1
				,NomAgrupador1
				,ClaAgrupador2
				,NomAgrupador2
				,ClaUbicacion
				,NomUbicacion
				,Tons
				,ImportePagarFinalUSD
				,NumViaje
				,TonsCubicadas
				,MillasViaje
				,ClaTransporte
				,NomTransporte
				,ClaTransportista
				,NomTransportista
				,ClaCiudadDestino
				,NomCiudadDestino
				,ClaEstadoDestino
				,NomEstadoDestino
				,FechaUltimaMod
				,NombrePcMod
				,ClaUsuarioMod)

			SELECT
				IdFreightPas = ROW_NUMBER() OVER(ORDER BY AnioMes,ClaUbicacion,NumViaje,ClaTransportista, ClaCiudadDestino) + @nIdFreightPas
				,AnioMes
				,FechaTabular
				,ClaSemana
				,NomSemana
				,ClaAgrupador1
				,NomAgrupador1
				,ClaAgrupador2
				,NomAgrupador2
				,ClaUbicacion
				,NomUbicacion
				,Tons
				,ImportePagarFinalUSD
				,NumViaje
				,TonsCubicadas
				,MillasViaje
				,ClaTransporte
				,NomTransporte
				,ClaTransportista
				,NomTransportista
				,ClaCiudadDestino
				,NomCiudadDestino
				,ClaEstadoDestino
				,NomEstadoDestino
				,FechaUltimaMod = GETDATE()
				,NombrePcMod	= @psNombrePcMod
				,ClaUsuarioMod	= @pnClaUsuarioMod			
			FROM #tmpUSAFreight



			
		END


		IF @@TRANCOUNT = 1 AND @nEsAbrirTransaccion = 1
			BEGIN
				COMMIT TRAN 
			END	
		
		END TRY
		BEGIN CATCH
			SET @sMensaje = ERROR_MESSAGE()
	
			IF @@TRANCOUNT = 1 AND @nEsAbrirTransaccion = 1
			BEGIN
				ROLLBACK TRAN 			
			END	
		
			RAISERROR(@sMensaje,16,1)
			RETURN
		END CATCH										
	END

	DROP TABLE #tmpUSAFreight
END

