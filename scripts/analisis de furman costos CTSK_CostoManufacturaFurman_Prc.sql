DECLARE
        @nEsAbrirTransaccion   INT        
		,@nContador             INT           = 1
		,@nNumEjecuciones       INT           = NULL
		,@nClaAnioMes           INT		
		,@sSql					VARCHAR(MAX)
		,@sServer               VARCHAR(50)
		,@dFechaDePartida DATETIME
		,@pnFechaActual DATETIME = '2024-05-01'
		,@sIdioma VARCHAR(100) = 'English'
		,@nClaUbicacion INT = 65
		,@sListaGastos VARCHAR(100) --= '1,716,741,743,751,762,776,804,157,170,171,172,190,609,86,158,255,257,271,458,604,610,611,614'
		--'21,22,25,26,27,28,65,66,67,68,463,642'

		




SET @dFechaDePartida = '2024-01-01'


SET @nNumEjecuciones = DATEDIFF(MONTH, @dFechaDePartida, @pnFechaActual) + 1
SELECT 'Meses a Extraer Datos: ',@nNumEjecuciones


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

CREATE TABLE #tmpFurmanProdElementos
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


WHILE(@nNumEjecuciones >= @nContador)
BEGIN
					
	SET @nClaAnioMes = YEAR(@dFechaDePartida)*100 + MONTH(@dFechaDePartida)
					
	SELECT '@nClaAnioMes', @nClaAnioMes

	INSERT INTO #tmpFurmanProd
	EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] 
		@pnClaAnioMes = @nClaAnioMes
		,@pnClaUbicacion = @nClaUbicacion
		,@pnIdioma = @sIdioma
		--, @psClaTipoGastos = @sListaGastos

	INSERT INTO #tmpFurmanProdElementos
	EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc] 
		@pnClaAnioMes = @nClaAnioMes
		,@pnClaUbicacion = @nClaUbicacion
		,@pnIdioma = @sIdioma
		, @psClaTipoGastos = @sListaGastos

				
	SET @nContador = @nContador + 1
	SET @dFechaDePartida = DATEADD(Month,1,@dFechaDePartida)
END

SELECT * FROM #tmpFurmanProd
--WHERE ClaCrc = 4133 AND ClaElementoCosto = 4
--AND ClaElementoCosto IN (5,8,3,97,9,7)
--AND ClaAnioMes >= 202304
--AND ClaAnioMes <= 202304

SELECT Importe = SUM(Importe), Prod = SUM(ProdTonsArticuloBase) FROM #tmpFurmanProd 
--WHERE ClaCrc = 4133 AND ClaElementoCosto = 4
--AND ClaElementoCosto IN (5,8,3,97,9,7)
--AND ClaAnioMes >= 202301
--AND ClaAnioMes <= 202301



--SELECT * FROM #tmpFurmanProdElementos WHERE ClaCrc = 4133 
--AND ClaElementoCosto IN (5,8,3,97,9,7)
--AND ClaAnioMes >= 202301
--AND ClaAnioMes <= 202312

--SELECT Importe = SUM(Importe) FROM #tmpFurmanProdElementos WHERE ClaCrc = 4133 
--AND ClaElementoCosto IN (5,8,3,97,9,7)
--AND ClaAnioMes >= 202301
--AND ClaAnioMes <= 202312

DROP TABLE #tmpFurmanProd
DROP TABLE #tmpFurmanProdElementos
