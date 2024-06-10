DECLARE 
	@pnAnioMesInicio INT = 202301
	,@pnAnioMesFin INT = 202312
	,@nScrapRevenueBulk				NUMERIC(22,9)
	,@nScrapRevenueCollated			NUMERIC(22,9)
	,@nScrapRevenuePaperTape		NUMERIC(22,9)
	,@nScrapProduccionBulk			NUMERIC(22,9)
	,@nScrapProduccionWireCoil		NUMERIC(22,9)
	,@nScrapProduccionPaperTape		NUMERIC(22,9)
	,@nScrapProduccionPlasticStrip	NUMERIC(22,9)
	,@nScrapOffSetBulk				NUMERIC(22,9)
	,@nScrapOffSetWireCoil			NUMERIC(22,9)
	,@nScrapOffSetPaperTape			NUMERIC(22,9)
	,@nScrapOffSetPlasticStrip		NUMERIC(22,9)
	,@nClaUnidadKgs INT
	,@nClaUnidadLbs INT
	,@nClaUnidadCajas INT
	,@nTipoClavosBulk INT
	,@sSubTipoClavosBulk VARCHAR(100)
	,@nTipoClavosWireCoil INT
	,@sSubTipoClavosWireCoil VARCHAR(100)
	,@nTipoClavosPaperTape INT
	,@sSubTipoClavosPaperTape VARCHAR(100)
	,@nTipoClavosPlasticStrip INT
	,@sSubTipoClavosPlasticStrip VARCHAR(100)
	,@nEsDebug INT = 0


	SELECT 
		@nScrapRevenueBulk = SUM(Cargos - Creditos) 
	FROM MSWSch.MswTraSaldosEng9 
	WHERE ClaCuenta = 10911 
	AND AnioMes >= @pnAnioMesInicio 
	AND AnioMes <= @pnAnioMesFin

	SELECT 
		@nScrapRevenueCollated = SUM(Cargos - Creditos) 
	FROM MSWSch.MswTraSaldosEng9 
	WHERE ClaCuenta = 10912 
	AND AnioMes >= @pnAnioMesInicio 
	AND AnioMes <= @pnAnioMesFin

	SELECT 
		@nScrapRevenuePaperTape = SUM(Cargos - Creditos) 
	FROM MSWSch.MswTraSaldosEng9 
	WHERE ClaCuenta = 10918 
	AND AnioMes >= @pnAnioMesInicio 
	AND AnioMes <= @pnAnioMesFin


SELECT @nClaUnidadKgs = ClaUnidad FROM MSWSch.MSWCatUnidad WHERE ClaUnidad = 1
SELECT @nClaUnidadLbs = ClaUnidad FROM MSWSch.MSWCatUnidad WHERE ClaUnidad = 15
SELECT @nClaUnidadCajas = ClaUnidad FROM MSWSch.MSWCatUnidad WHERE ClaUnidad = 11

SELECT 
	@nTipoClavosBulk = nValor1
	,@sSubTipoClavosBulk = sValor1
FROM [MSWSch].[MSWCatConfiguracion] 
WHERE ClaConfiguracion = 604

SELECT 
	@nTipoClavosWireCoil = nValor1
	,@sSubTipoClavosWireCoil = sValor1
FROM [MSWSch].[MSWCatConfiguracion] 
WHERE ClaConfiguracion = 605

SELECT 
	@nTipoClavosPaperTape = nValor1
	,@sSubTipoClavosPaperTape = sValor1
FROM [MSWSch].[MSWCatConfiguracion] 
WHERE ClaConfiguracion = 606

SELECT 
	@nTipoClavosPlasticStrip = nValor1
	,@sSubTipoClavosPlasticStrip = sValor1
FROM [MSWSch].[MSWCatConfiguracion] 
WHERE ClaConfiguracion = 607

	SELECT * 
	INTO  #tmpSubTipoClavosBulk
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosBulk, ',',0)

	SELECT * 
	INTO  #tmpSubTipoClavosWireCoil
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosWireCoil, ',',0)

	SELECT * 
	INTO  #tmpSubTipoClavosPaperTape
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosPaperTape, ',',0)

	SELECT * 
	INTO  #tmpSubTipoClavosPlasticStrip
	FROM [MSWSch].[MSWSplitString](@sSubTipoClavosPlasticStrip, ',',0)

	SELECT 		
		OT.ClaArticulo
		,UnidadOTs = OT.ClaUnidad
		,BxsOTs = OT.Cantidad
		,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
		,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
		,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)
	INTO #tmpKgsScrapBulk
	FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
	INNER JOIN MSWSch.MswCatArticulo C WITH(NOLOCK) ON OT.ClaArticulo = C.ClaArticulo
										AND C.ClaTipoInventario = 1
	INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm WITH(NOLOCK) ON C.ClaArticulo = Cm.ClaArticulo
	WHERE C.ClaGrupoEstadistico2 = @nTipoClavosBulk
	AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosBulk)
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
	AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))



	SELECT 		
		OT.ClaArticulo
		,UnidadOTs = OT.ClaUnidad
		,BxsOTs = OT.Cantidad
		,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
		,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
		,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)
	INTO #tmpKgsScrapWireCoil
	FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
	INNER JOIN MSWSch.MswCatArticulo C ON OT.ClaArticulo = C.ClaArticulo
										AND C.ClaTipoInventario = 1
	INNER JOIN MSWSCh.MSWTraArticuloInfo I ON Ot.ClaArticulo = I.ClaArticulo
	INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm ON C.ClaArticulo = Cm.ClaArticulo
	WHERE C.ClaGrupoEstadistico2 = @nTipoClavosWireCoil
	AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosWireCoil)
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
	AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))

SELECT 	
	OT.ClaArticulo
	,UnidadOTs = OT.ClaUnidad
	,BxsOTs = OT.Cantidad
	,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
	,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
	,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)	
INTO #tmpKgsScrapPaperTape
FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
INNER JOIN MSWSch.MswCatArticulo C ON OT.ClaArticulo = C.ClaArticulo
									AND C.ClaTipoInventario = 1
INNER JOIN MSWSCh.MSWTraArticuloInfo I ON Ot.ClaArticulo = I.ClaArticulo
INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm ON C.ClaArticulo = Cm.ClaArticulo
WHERE C.ClaGrupoEstadistico2 = @nTipoClavosPaperTape
AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosPaperTape)
AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))


--SELECT [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](618035,128, 11, 15)
--SELECT [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](618035,128, 15, 15)
--SELECT [MSWSch].[MSW_CU423_Pag3_ConversionEntreUnidades_Fn](128, 11, 15)


SELECT 		
	OT.ClaArticulo
	,UnidadOTs = OT.ClaUnidad
	,BxsOTs = OT.Cantidad
	,LbsOTs = [MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs)
	,KgsOTs = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs)
	,KgsScrap = [MSWSch].MSW_CU423_Pag3_ConversionEntreUnidades_Fn([MSWSch].[msw_CU910_pag2_ObtenConversionEntreUnidades](OT.ClaArticulo,OT.Cantidad,OT.ClaUnidad, @nClaUnidadLbs), @nClaUnidadLbs, @nClaUnidadKgs) * ISNULL(Cm.PorcCostoMaterial/100.00,0)
INTO #tmpKgsScrapPlasticStrip
FROM MSWSch.MSWTraOrdenTrabajo4 OT WITH(NOLOCK)
INNER JOIN MSWSch.MswCatArticulo C ON OT.ClaArticulo = C.ClaArticulo
									AND C.ClaTipoInventario = 1
INNER JOIN MSWSCh.MSWTraArticuloInfo I ON Ot.ClaArticulo = I.ClaArticulo
INNER JOIN MSWSch.MSWTraComposicionArticulo4Vw Cm ON C.ClaArticulo = Cm.ClaArticulo
WHERE C.ClaGrupoEstadistico2 = @nTipoClavosPlasticStrip
AND C.ClaGrupoEstadistico3 IN (SELECT Item FROM #tmpSubTipoClavosPlasticStrip)
AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) <= @pnAnioMesFin))
AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(OT.FechaTransaccion)*100+MONTH(OT.FechaTransaccion) >= @pnAnioMesInicio))

IF @nEsDebug = 1
SELECT '#tmpKgsScrapBulk',
	KgsOTs = SUM(KgsOTs),
	KgsScrap = SUM(KgsScrap),
	ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)	
FROM #tmpKgsScrapBulk

SELECT @nScrapProduccionBulk = SUM(KgsScrap) FROM #tmpKgsScrapBulk

IF @nEsDebug = 1
SELECT '#tmpKgsScrapWireCoil', 
	KgsOTs = SUM(KgsOTs),
	KgsScrap = SUM(KgsScrap),
	ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)
FROM #tmpKgsScrapWireCoil

SELECT @nScrapProduccionWireCoil = SUM(KgsScrap) FROM #tmpKgsScrapWireCoil

IF @nEsDebug = 1
SELECT '#tmpKgsScrapPaperTape', 
	KgsOTs = SUM(KgsOTs),
	KgsScrap = SUM(KgsScrap),
	ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)
FROM #tmpKgsScrapPaperTape

SELECT @nScrapProduccionPaperTape = SUM(KgsScrap) FROM #tmpKgsScrapPaperTape

IF @nEsDebug = 1
SELECT '#tmpKgsScrapPlasticStrip', 
	KgsOTs = SUM(KgsOTs),
	KgsScrap = SUM(KgsScrap),
	ProcScrap = SUM(KgsScrap)/SUM(KgsOTs)	
FROM #tmpKgsScrapPlasticStrip

SELECT @nScrapProduccionPlasticStrip = SUM(KgsScrap) FROM #tmpKgsScrapPlasticStrip

SELECT @nScrapOffSetBulk = @nScrapRevenueBulk / @nScrapProduccionBulk
SELECT nScrapOffSetBulk = @nScrapOffSetBulk

SELECT @nScrapOffSetPaperTape = @nScrapRevenuePaperTape / @nScrapProduccionPaperTape
SELECT nScrapOffSetPaperTape = @nScrapOffSetPaperTape

/*
SELECT WireCoilRevenueProc = (@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip) 
SELECT WireCoilRevenue = (((@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated) 
SELECT WreCoilScrapoffset = (((@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated)  / @nScrapProduccionWireCoil
*/

SELECT @nScrapOffSetWireCoil = (((@nScrapProduccionWireCoil) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated)  / @nScrapProduccionWireCoil
SELECT nScrapOffSetWireCoil = @nScrapOffSetWireCoil

SELECT @nScrapOffSetPlasticStrip = (((@nScrapProduccionPlasticStrip) / (@nScrapProduccionWireCoil + @nScrapProduccionPlasticStrip)) * @nScrapRevenueCollated)  / @nScrapProduccionPlasticStrip
SELECT nScrapOffSetWireCoil = @nScrapOffSetPlasticStrip



DROP TABLE #tmpSubTipoClavosBulk
DROP TABLE #tmpSubTipoClavosWireCoil
DROP TABLE #tmpSubTipoClavosPaperTape
DROP TABLE #tmpSubTipoClavosPlasticStrip
DROP TABLE #tmpKgsScrapBulk
DROP TABLE #tmpKgsScrapWireCoil
DROP TABLE #tmpKgsScrapPaperTape
DROP TABLE #tmpKgsScrapPlasticStrip

