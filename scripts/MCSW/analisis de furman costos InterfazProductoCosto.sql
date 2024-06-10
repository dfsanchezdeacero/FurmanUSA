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

INSERT INTO #tmpFurmanCostos
EXEC [DEAFYSA].[Costos].[CTSSch].[CTS_CU700_Pag1_InterfazProductoCosto_Prc]
      @pnClaVersion = 9,
      @pnClaAnioMes = 202301,
      @pnClaUbicacion = 65

SELECT * FROM #tmpFurmanCostos WHERE ClaCrc = 4133 AND ClaElementoCosto = 4

SELECT ClaCrc,ClaElementoCosto, GastoPropio = SUM(ImpManufacturaDir), GastoAsginado = SUM(ImpManufacturaInd) , TonsProd
FROM #tmpFurmanCostos 
WHERE ClaCrc = 4133 AND ClaElementoCosto = 4
GROUP BY ClaCrc, ClaElementoCosto, TonsProd

	

--DROP TABLE #tmpFurmanCostos