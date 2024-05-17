ALTER PROC [MSWSch].[MSW_CU423_Pag8_Grid_GridGenerico_Sel]
	@pnAnioMesInicio		INT = NULL
	,@pnAnioMesFin			INT = NULL
	,@pnVendor				INT = NULL
	,@pnDepto				INT = NULL
	,@pnEsDebug				TINYINT = 0  
	,@pnEsPorPantallaReact	INT = 0
AS
BEGIN
	
	DECLARE  
	@nFURINT               NUMERIC(22,9)
	,@nFURGNA              NUMERIC(22,9)
	,@nFURMAT				NUMERIC(22,9)

DECLARE @pnAnioCalculoINT INT

	SELECT @pnAnioCalculoINT=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [MSWSch].MSWCfgInteresPeriodoFurman (NOLOCK) 
	WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT OR AnioInteresPeriodoFurman=@pnAnioCalculoINT-1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT)
		BEGIN
			SELECT @nFURINT = ISNULL((FactorInteresPeriodoFurman),0) FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURINT = ISNULL((FactorInteresPeriodoFurman),0) FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) ORDER BY AnioInteresPeriodoFurman DESC
		END
		--SET @nFURINT=1
		PRINT @nFURINT
	END
	ELSE
	BEGIN
		RAISERROR('INT Missing configuration, please configure a INT value for current P.O.R',16,1)
	END

--FURNGA DIEGO LAUREANO
	DECLARE @pnAnioCalculoGNA INT

	SELECT @pnAnioCalculoGNA=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [MSWSch].MSWCfgGNAPeriodoFurman (NOLOCK) 
	WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA OR AnioGNAPeriodoFurman=@pnAnioCalculoGNA-1)
	BEGIN
		

		IF EXISTS(SELECT 1 FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA)
		BEGIN
			SELECT @nFURGNA = ISNULL((FactorGNAPeriodoFurman),0) FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURGNA = ISNULL((FactorGNAPeriodoFurman),0) FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) ORDER BY AnioGNAPeriodoFurman DESC
		END
		--SET @nFURGNA=1
		PRINT @nFURGNA
	END
	ELSE
	BEGIN
		RAISERROR('GNA Missing configuration, please configure a GNA value for current P.O.R',16,1)
	END

	SELECT		NumFacturaProv	= fftm.NumFacturaDEA
				,CantidadKgs	= fftm.CantidadKgs
				,ImporteFlete	= fftm.ImporteFlete
	INTO #tmpFlete
	FROM 		MSWSch.MSWTraFurmanFreightToMCSWAnioMes	fftm
	WHERE		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fftm.FechaFacturaDEA)*100+MONTH(fftm.FechaFacturaDEA) >= @pnAnioMesInicio))
		AND			(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fftm.FechaFacturaDEA)*100+MONTH(fftm.FechaFacturaDEA) <= @pnAnioMesFin))

	SELECT	@nFURMAT = SUM(ImporteFlete)/NULLIF(SUM(CantidadKgs),0)
	FROM	#tmpFlete

	SELECT
		ClaAnioMes = [YearMonth]
		,ClaveArticulo = [Item]
		,NomFamilia = [Family]
		,NomCategoria = [Category]
		,NomTipo = [Type]
		,CantCajas = [Boxes]
		,CantKilos = [Kg]
		,TotalDL = [TOTAL DL]
		,TotalVarExp = [TOTAL VAR EXP]
		,TotalIL	 = [TOTAL IL]
		,TotalFixed	 = [TOTAL FIXED EXP]
		,Collated	 = [Tot Collated]
		,NailCoating = [Tot Nail Coating]
		,Packing	 = [Tot Packaging]
		,Pallets	 = [Tot Pallets]
		,WireMarkup	 = [Tot Wire MarkUp]
	INTO #tmpResultSetCostos
	FROM [DEAMIDCON02].[MCSW_Integra].[MSWSch].[MSWTraBSCLecturaFurmanCostByItemDet] RD
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND RD.[YearMonth] >= @pnAnioMesInicio))
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND RD.[YearMonth] <= @pnAnioMesFin))

	SELECT
		NomTipo
		,CantCajas = CAST(SUM(CantCajas) AS NUMERIC(22,8)) 
		,A = CAST(SUM(CantKilos)   AS NUMERIC(22,8)) 
		,B = CAST(SUM(TotalDL)	   AS NUMERIC(22,8)) 
		,C = CAST(SUM(TotalVarExp) AS NUMERIC(22,8)) 
		,D = CAST(SUM(TotalIL)	   AS NUMERIC(22,8)) 
		,E = CAST(SUM(TotalFixed)  AS NUMERIC(22,8)) 
		,F = CAST(SUM(Collated)	   AS NUMERIC(22,8)) 
		,G = CAST(SUM(NailCoating) AS NUMERIC(22,8)) 
		,H = CAST(SUM(Packing)	   AS NUMERIC(22,8)) 
		,I = CAST(SUM(Pallets)	   AS NUMERIC(22,8)) 
		,J = CAST(SUM(WireMarkup)  AS NUMERIC(22,8)) 
	INTO #tmpVariablesFurman
	FROM #tmpResultSetCostos
	GROUP BY NomTipo

	SELECT 
		[TYPE] = NomTipo
		,FURMAT = @nFURMAT
		,FURMAT_COLLATED = (F + G)/A
		,FURMANYLD = J/A
		,SCRAPOFFSET  = CAST(0 AS NUMERIC(22,8)) 
		,FURLAB = B / A
		,FURFOH = (C + D + E) / A
		,FURCOM = CAST(0 AS NUMERIC(22,8)) 
		,FURGNA = CAST(0 AS NUMERIC(22,8)) 
		,FURINT = CAST(0 AS NUMERIC(22,8)) 
		,FURPACK = (H + I) / A
		,TOTFGM = CAST(0 AS NUMERIC(22,8)) 
	INTO #tmpFurmanCosts
	FROm #tmpVariablesFurman
	--GROUP BY NomTipo

	UPDATE #tmpFurmanCosts
		SET FURCOM = FURMAT + FURMAT_COLLATED + FURMANYLD + FURLAB + FURFOH

	UPDATE #tmpFurmanCosts
		SET FURGNA = FURCOM * @nFURGNA   
		,FURINT = FURCOM * @nFURINT

	UPDATE #tmpFurmanCosts
		SET TOTFGM = FURCOM + FURPACK + FURGNA + FURINT
	
	SELECT * FROM #tmpFurmanCosts


	DROP TABLE #tmpResultSetCostos
	DROP TABLE #tmpVariablesFurman
	DROP TABLE #tmpFurmanCosts
	DROP TABLE #tmpFlete
	
END
