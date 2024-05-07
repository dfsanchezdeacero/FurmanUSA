--Para Crear Objeto Procedimiento
--IF NOT EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('[OPESch].[OPEObtenerProduccionFurman]') AND OBJECTPROPERTY(id, 'IsProcedure') = 1)
--BEGIN
--	EXEC ('CREATE PROCEDURE [OPESch].[OPEObtenerProduccionFurman] as Select Getdate()')
--END
--GO
-- =============================================
-- Author:		 David Sanchez
-- Create date:  26-10-2022
-- Description:	 Todo
-- =============================================
ALTER PROCEDURE [OPESch].[OPEObtenerGastoPropioCRCFurman]
    @pnClaUsuarioMod	 INT		 = 1
    ,@psNombrePcMod		 VARCHAR(64) = 'JOB- FURMAN'
	,@pnClaUbicacion     INT         = 65
	,@psIdioma           VARCHAR(50) = 'ENGLISH'

AS
BEGIN
    SET NOCOUNT ON
        
		DECLARE @AnioMesMaxRegistrado INT
		,@dFechaActual DATETIME = GETDATE()
		,@nDiasExtendidosCierreMes INT = 6
		,@dFechaEjecucionDesde DATETIME
		,@dFechaEjecucionHasta DATETIME
		,@nContador             INT           = 1
		,@nNumEjecuciones       INT           = NULL		
        ,@nEsAbrirTransaccion   INT
        ,@sMensajeError 	    VARCHAR(2000) = NULL
		,@nIdFurmanProduccion   INT
		,@nIdFurmanGastos       INT
		

		CREATE TABLE #tmpFurmanCostos
		(
			[ClaAnioMes]            INT
			,[ClaUbicacion]         INT
			,[ClaCrc]	            INT
			,[ClaElementoCosto]	    INT
			,[ClaTipoGasto]	        INT	
			,ImpManufacturaDir		NUMERIC(22,8)
			,ImpManufacturaInd		NUMERIC(22,8)
			,ImpManufacturaNoDist   NUMERIC(22,8)
			,TonsProd				NUMERIC(22,8)

		)

		SELECT @dFechaEjecucionHasta = DATEADD(DAY, -@nDiasExtendidosCierreMes, @dFechaActual)
		
		SELECT 
			@AnioMesMaxRegistrado = ISNULL(MAX(ClaAnioMes),202301)
		FROM [OPESch].[OPETraFurmanGastos] WITH(NOLOCK)

		SELECT @dFechaEjecucionDesde = SUBSTRING(CAST(@AnioMesMaxRegistrado AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@AnioMesMaxRegistrado AS VARCHAR(10)), 5,6)+'-01'
	

		SELECT 
			dFechaEjecucionDesde = @dFechaEjecucionDesde
			,dFechaEjecucionHasta = @dFechaEjecucionHasta

		SELECT @nNumEjecuciones = DATEDIFF(Month,@dFechaEjecucionDesde, @dFechaEjecucionHasta) + 1

		SELECT nNumEjecuciones = @nNumEjecuciones
		
		DECLARE @nFechaEnProceso DATETIME = @dFechaEjecucionDesde
		,@nAnioMesEnProceso INT = YEAR(@dFechaEjecucionDesde)*100 + MONTH(@dFechaEjecucionDesde)

		WHILE (@nContador <= @nNumEjecuciones)
		BEGIN			

				SELECT @nAnioMesEnProceso = YEAR(@nFechaEnProceso)*100 + MONTH(@nFechaEnProceso)
			
				SELECT 
					Contador = @nContador
					,nAnioMesEnProceso = @nAnioMesEnProceso
				
				INSERT INTO #tmpFurmanCostos
				EXEC [DEAFYSA].[Costos].[CTSSch].[CTS_CU700_Pag1_InterfazProductoCosto_Prc]
					  @pnClaVersion = 9,
					  @pnClaAnioMes = @nAnioMesEnProceso,
					  @pnClaUbicacion = 65
			
				SELECT @nFechaEnProceso = DATEADD(Month, @nContador, @dFechaEjecucionDesde)
				SELECT @nContador = @nContador + 1

		END
	

    BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN 
            SET @nEsAbrirTransaccion = 1
            BEGIN TRAN INSERTAPRODFURMAN
        END        	

		DELETE FROM [OPESch].[OPETraFurmanGastos] WHERE ClaAnioMes = (YEAR(@dFechaEjecucionDesde) * 100) + MONTH(@dFechaEjecucionDesde)

		SELECT	@nIdFurmanGastos = ISNULL(MAX(IdFurmanGastos),0)
		FROM	[OPESch].[OPETraFurmanGastos]
		
		INSERT INTO [OPESch].[OPETraFurmanGastos](
			IdFurmanGastos
			,ClaAnioMes
			,ClaUbicacion
			,ClaCrc
			,ClaElementoCosto
			,ClaTipoGasto
			,ImpManufacturaDir
			,ImpManufacturaInd
			,ImpManufacturaNoDist
			,TonsProd
			,FechaUltimaMod
			,NombrePcMod
			,ClaUsuarioMod
		)

		SELECT
			IdFurmanGastos = ROW_NUMBER() OVER(ORDER BY ClaAnioMes,ClaUbicacion,ClaCrc,ClaElementoCosto,ClaTipoGasto) + @nIdFurmanGastos
			,ClaAnioMes
			,ClaUbicacion
			,ClaCrc    
			,ClaElementoCosto
			,ClaTipoGasto
			,ImpManufacturaDir
			,ImpManufacturaInd
			,ImpManufacturaNoDist
			,TonsProd
			,GETDATE()
			,@psNombrePcMod
			,HOST_ID()
		FROM #tmpFurmanCostos


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
		DROP TABLE #tmpFurmanCostos

    SET NOCOUNT OFF
END
