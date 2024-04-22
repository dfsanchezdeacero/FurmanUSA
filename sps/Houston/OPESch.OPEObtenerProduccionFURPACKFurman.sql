USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OPEObtenerProduccionFURPACKFurman]    Script Date: 4/3/2024 5:51:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [OPESch].[OPEObtenerProduccionFURPACKFurman]
    @pnClaUsuarioMod	 INT			= 1
    ,@psNombrePcMod		 VARCHAR(64) = NULL
	,@pnClaUbicacion     INT         = 65
	,@pnFechaActual      DATETIME
	,@psIdioma           VARCHAR(50) = 'ENGLISH'

AS
BEGIN
    SET NOCOUNT ON
    
    DECLARE
        @nEsAbrirTransaccion   INT
        ,@sMensajeError 	    VARCHAR(2000) = NULL
		,@dFechaDePartida       DATETIME      = NULL
		,@nUltimoAnioMesEjec    INT           = NULL
		,@nContador             INT           = 1
		,@nNumEjecuciones       INT           = NULL
		,@nClaAnioMes           INT
		,@nIdFurmanProduccion   INT
		,@sSql					VARCHAR(MAX)
		,@sTiposGastoFurpack	VARCHAR(MAX) = ''
		,@sServer               VARCHAR(50)

		CREATE TABLE #tmpFurmanProd
		(
			[ClaAnioMes]           INT
			,[ClaUbicacion]         INT
			,[ClaArticulo]	        INT
			,[NomArticulo]	        VARCHAR(200)
			,[ClaCrc]	            INT
			,[NomCrc]	            VARCHAR(100)
			,[ClaElementoCosto]	    INT
			,[NomElementoCosto]     VARCHAR(200)	
			,[Importe]	            NUMERIC(22,8)
			,[ProdTonsArticuloBase]	NUMERIC(22,8)
			,[CostoXTonelada]	    NUMERIC(22,8)
			,[PorcComp]             NUMERIC(22,8)
		)

		SELECT 
		@sTiposGastoFurpack = sValor1 
		FROM [OPESch].[OpeCatFurmanConfiguracion] WHERE ClaConfiguracion = 4

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN 
            SET @nEsAbrirTransaccion = 1
            BEGIN TRAN INSERTAPRODFURMAN
        END
        
        --PROCESAMIENTO
		SET @sServer = 'DEAFYSA'

        IF NOT EXISTS(SELECT 1 FROM [OPESch].[OPETraFurmanProduccionFURPACK] WITH (NOLOCK))
		BEGIN
			PRINT('Escenario 1')
			--Solo hay info a partir del 2020
			SET @dFechaDePartida = '2017-01-01'


			SET @nNumEjecuciones = DATEDIFF(MONTH, @dFechaDePartida, @pnFechaActual) + 1
			PRINT('Diferencia de Fechas: ')
			PRINT(@nNumEjecuciones)

			WHILE(@nNumEjecuciones >= @nContador)
			BEGIN
				
				PRINT('Contador: ')
				PRINT(@nContador)

				SET @nClaAnioMes = YEAR(@dFechaDePartida)*100 + MONTH(@dFechaDePartida)
				
				PRINT('@nClaAnioMes: ')
				PRINT(@nClaAnioMes)

				--SELECT  @sSql = 'SELECT * FROM OPENQUERY(' + @sServer + /*DEAFYSA*/', 
				--					''
				--					EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] '+CAST(@nClaAnioMes AS VARCHAR(20))+','+CAST(@pnClaUbicacion AS VARCHAR(20))+'
				--					''
				--				)'
										
				--INSERT INTO #tmpFurmanProd
				--EXEC (@sSql)

				INSERT INTO #tmpFurmanProd
				EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc]
				@pnClaAnioMes = @nClaAnioMes,@pnClaUbicacion = 65,@pnIdioma = 'ENGLISH',@psClaTipoGastos = @sTiposGastoFurpack--'410, 411, 705,872'
				--EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] @nClaAnioMes, @pnClaUbicacion, @psIdioma
				
				SET @nContador = @nContador + 1
				SET @dFechaDePartida = DATEADD(Month,1,@dFechaDePartida)
			END
		END
		ELSE
		BEGIN
			PRINT('Escenario 2')
			DECLARE @pnAnioMesEjecucion INT = YEAR(@pnFechaActual)*100 + MONTH(@pnFechaActual)

			--SET @nFechaActual = YEAR(GETDATE())*100 + MONTH(GETDATE())

			SELECT	@nUltimoAnioMesEjec = MAX(ClaAnioMes)
			FROM	[OPESch].[OPETraFurmanProduccionFURPACK] WITH(NOLOCK)

			IF @nUltimoAnioMesEjec = @pnAnioMesEjecucion
			BEGIN 
				PRINT('Seguimos en el mismo mes, borramos y actualizamos info del Mes')
				PRINT(@nUltimoAnioMesEjec)

				SET @dFechaDePartida = SUBSTRING(CAST(@nUltimoAnioMesEjec AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@nUltimoAnioMesEjec AS VARCHAR(10)), 5,6)+'-01'
				SET @dFechaDePartida = DATEADD(mm,-1,@dFechaDePartida)
				SET @nClaAnioMes = YEAR(@dFechaDePartida)*100 + MONTH(@dFechaDePartida)
				
				PRINT('Borramos datos con AnioMes Mayor a ')
				PRINT(@nClaAnioMes)

				DELETE FROM [OPESch].[OPETraFurmanProduccionFURPACK] WHERE ClaAnioMes > @nClaAnioMes

				--SELECT  @sSql = 'SELECT * FROM OPENQUERY(' + @sServer + /*DEAFYSA*/', 
				--					''
				--					EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] '+CAST(@nClaAnioMes AS VARCHAR(20))+','+CAST(@pnClaUbicacion AS VARCHAR(20))+'
				--					''
				--				)'										
				--INSERT INTO #tmpFurmanProd
				--EXEC (@sSql)

				INSERT INTO #tmpFurmanProd
				EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc]
				@pnClaAnioMes = @pnAnioMesEjecucion,@pnClaUbicacion = 65,@pnIdioma = 'ENGLISH',@psClaTipoGastos = @sTiposGastoFurpack--'410, 411, 705,872'
				--EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] @pnAnioMesEjecucion, @pnClaUbicacion, @psIdioma
			END
			IF @nUltimoAnioMesEjec < @pnAnioMesEjecucion
			BEGIN
				PRINT('Ya es cambio de Mes, no borramos solo descargamos nuevo mes')
				PRINT(@nUltimoAnioMesEjec)

				SET @dFechaDePartida = SUBSTRING(CAST(@nUltimoAnioMesEjec AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@nUltimoAnioMesEjec AS VARCHAR(10)), 5,6)+'-01'
				--SET @dFechaDePartida = DATEADD(mm,-1,@dFechaDePartida)
				SET @nClaAnioMes = YEAR(@dFechaDePartida)*100 + MONTH(@dFechaDePartida)

				INSERT INTO #tmpFurmanProd
				EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc]
				@pnClaAnioMes = @pnAnioMesEjecucion,@pnClaUbicacion = 65,@pnIdioma = 'ENGLISH',@psClaTipoGastos = @sTiposGastoFurpack--'410, 411, 705,872'
				--EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] @pnAnioMesEjecucion, @pnClaUbicacion

			END
			

		END

		SELECT	@nIdFurmanProduccion = ISNULL(MAX(IdFurmanProduccionFURPACK),0)
		FROM	[OPESch].[OPETraFurmanProduccionFURPACK]	

		INSERT INTO [OPESch].[OPETraFurmanProduccionFURPACK](
			[IdFurmanProduccionFURPACK]
			,[ClaAnioMes]
			,[ClaUbicacion]
			,[ClaArticulo]
			,[NomArticulo]
			,[ClaCrc]
			,[NomCrc]
			,[ClaElementoCosto]
			,[NomElementoCosto]
			,[Importe]
			,[ProdTonsArticuloBase]
			,[CostoXTonelada]
			,[PorcComp]
			,[FechaUltimaMod]
			,[NombrePcMod]
			,[ClaUsuarioMod]
		)
		SELECT 
			[IdFurmanProduccionFURPACK] = ROW_NUMBER() OVER(ORDER BY [ClaAnioMes],[ClaUbicacion],[ClaArticulo]) + @nIdFurmanProduccion
			,[ClaAnioMes]
			,[ClaUbicacion]
			,[ClaArticulo]
			,[NomArticulo]
			,[ClaCrc]
			,[NomCrc]
			,[ClaElementoCosto]
			,[NomElementoCosto]
			,[Importe]
			,[ProdTonsArticuloBase]
			,[CostoXTonelada]
			,[PorcComp]
			,GETDATE()
			,HOST_NAME()
			,HOST_ID()
		FROM #tmpFurmanProd


        IF @@TRANCOUNT > 0 AND @nEsAbrirTransaccion = 1
        BEGIN
            COMMIT TRAN INSERTAPRODFURMAN
        END	
    END TRY
    BEGIN CATCH
        SET @sMensajeError = ERROR_MESSAGE()
		
        IF @@TRANCOUNT > 0 AND @nEsAbrirTransaccion = 1
        BEGIN
            ROLLBACK TRAN INSERTAPRODFURMAN
        END	
            
        RAISERROR(@sMensajeError,16,1)
    END CATCH

    FIN:
		DROP TABLE #tmpFurmanProd

    SET NOCOUNT OFF
END
