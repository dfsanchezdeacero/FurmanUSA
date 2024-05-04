		CREATE TABLE #tmpFurmanCostos
	(
		[ClaAnioMes]            INT
		,[ClaUbicacion]         INT
		,[ClaCrc]	            INT
		,[ClaElementoCosto]	    INT
		,[ClaTipoGasto]	        INT	
		,ImpManufacturaDir		NUMERIC(22,8)
		,ImpManufacturaInd		NUMERIC(22,8)
		,TonsProd				NUMERIC(22,8)

	)

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

	DECLARE @AnioMesMaxRegistrado INT --= 2020--2024--2024
	,@dFechaActual DATETIME = '2023-12-31' --GETDATE() 
	,@nDiasExtendidosCierreMes INT = 6
	,@dFechaEjecucionDesde DATETIME
	,@dFechaEjecucionHasta DATETIME
	,@nContador             INT           = 1
	,@nNumEjecuciones       INT           = NULL
	,@sListaGastos VARCHAR(250) = '21,22,23,24,25,26,27,28,29,30,31,32,35,36,37,38,39,40,42,61,62,63,64,65,66,67,68,69,81,82,84,463,618,642,643,651,652,765'

	SELECT @dFechaEjecucionHasta = DATEADD(DAY, -@nDiasExtendidosCierreMes, @dFechaActual)

	--FECHA INICIAL POR DEFAULT 2020
	SELECT 
		@AnioMesMaxRegistrado = 202301--ISNULL(MAX(ClaAnioMes),202301)
	FROM [OPESch].[OPETraFurmanProduccion] WITH(NOLOCK)

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


			INSERT INTO #tmpFurmanProd
			EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] 
				@nAnioMesEnProceso
				,65
				,'Spanish'
				--, @psClaTipoGastos = @sListaGastos

			INSERT INTO #tmpFurmanCostos
			EXEC [DEAFYSA].[Costos].[CTSSch].[CTS_CU700_Pag1_InterfazProductoCosto_Prc]
				  @pnClaVersion = 9,
				  @pnClaAnioMes = @nAnioMesEnProceso,
				  @pnClaUbicacion = 65
			
			SELECT @nFechaEnProceso = DATEADD(Month, @nContador, @dFechaEjecucionDesde)
			SELECT @nContador = @nContador + 1

	END

	SELECT ClaAnioMes,ClaCrc, ClaElementoCosto, Gasto = SUM(Importe), TonsProd = SUM(ProdTonsArticuloBase)
	FROM #tmpFurmanProd 
	WHERE ClaCrc = 4133 AND ClaElementoCosto = 4 --AND ClaAnioMes = 202312
	GROUP BY ClaAnioMes,ClaCrc, ClaElementoCosto
	ORDER BY ClaAnioMes
	
	SELECT ClaAnioMes,ClaCrc,ClaElementoCosto, GastoPropio = SUM(ImpManufacturaDir), GastoAsginado = SUM(ImpManufacturaInd), TonsProd
	FROM #tmpFurmanCostos 
	WHERE ClaCrc = 4133 AND ClaElementoCosto = 4 --AND ClaAnioMes = 202312
	GROUP BY ClaAnioMes,ClaCrc, ClaElementoCosto, TonsProd
	ORDER BY ClaAnioMes
	

	--DROP TABLE #tmpFurmanProd
	--DROP TABLE #tmpFurmanCostos