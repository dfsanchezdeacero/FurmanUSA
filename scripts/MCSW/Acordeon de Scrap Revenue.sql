DECLARE @pnAnioMesInicio INT = 202301, @pnAnioMesFin INT = 202312

--exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10911,@pnAnio=2023,@psIdioma='English'
--SELECT * FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10911 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @@pnAnioMesFin
--SELECT ScrapRevenueBulk = SUM(Cargos - Creditos) FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10911 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesFin

exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10912,@pnAnio=2023,@psIdioma='English'
--SELECT * FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10912 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @@pnAnioMesFin
SELECT ScrapRevenueCollated = SUM(Cargos - Creditos) FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10912 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesFin

exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10918,@pnAnio=2023,@psIdioma='English'
--SELECT * FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10918 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesFin
SELECT ScrapRevenuePaperTape = SUM(Cargos - Creditos) FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10918 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesFin

sp_helptext 'MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel'


		
	
	--WHERE	ClaArticulo = 600020
	--INSERT INTO #tmpFURCOM
--SELECT SubType = 202 ,SubSubType = 292 , * FROM #tmpFurmanCosts WHERE Type = 'Bulk'
--UNION
--SELECT SubType = 202 ,SubSubType = 293 , * FROM #tmpFurmanCosts WHERE Type = 'Bulk'
--UNION
--SELECT SubType = 202 ,SubSubType = 453 , * FROM #tmpFurmanCosts WHERE Type = 'Bulk'
--UNION
--SELECT SubType = 201 ,SubSubType = 289 , * FROM #tmpFurmanCosts WHERE Type = 'Wire Coil'
--UNION
--SELECT SubType = 201 ,SubSubType = 291 , * FROM #tmpFurmanCosts WHERE Type = 'Paper Tape'
--UNION
--SELECT SubType = 201 ,SubSubType = 290 , * FROM #tmpFurmanCosts WHERE Type = 'Plastic Strip'
--UNION
--SELECT SubType = 201 ,SubSubType = 454 , * FROM #tmpFurmanCosts WHERE Type = 'Wire Coil'


EXEC [MSWSch].[MSW_CU423_Pag8_Grid_GridGenerico_Sel]
	@pnAnioMesInicio		 = 202301
	,@pnAnioMesFin			= 202312


SELECT * FROm [DEAMIDCON02].[MCSW_Integra].[MSWSch].[MSWTraBSCLecturaFurmanCostByItemDet]