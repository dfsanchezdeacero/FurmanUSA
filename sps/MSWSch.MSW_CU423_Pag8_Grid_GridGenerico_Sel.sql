ALTER PROC [MSWSch].[MSW_CU423_Pag8_Grid_GridGenerico_Sel]
 @pnAnioMesInicio		INT = NULL
,@pnAnioMesFin			INT = NULL
,@pnVendor				INT = NULL
,@pnDepto				INT = NULL
,@pnEsDebug				TINYINT = 0  
,@pnEsPorPantallaReact	INT = 0
AS
BEGIN
	declare @gpoEst INT = NULL

		if (@pnDepto =1 )
			set @gpoEst = 202 --BULK
		ELSE IF (@pnDepto = 2 )
			set @gpoEst = 201 --COLLATED
	
	DECLARE	@sNomProveedor			VARCHAR(50)
			,@nImpAlambronUsado		NUMERIC(22,4)
			,@nCantAlambronUsadoKgs	NUMERIC(22,4)
			,@nCantAlambreProdKgs	NUMERIC(22,4)
			,@nCategoriaAlambron	INT
			,@nScrapRevenueTotal	NUMERIC(22,4)
			,@nNumMes				INT
			,@nDiffNumMes			INT
			,@dFechaInicial			DATE
			,@dFechaFinal			DATE
			,@nFactorLbsKgs			NUMERIC(22,7)  =0.4535923
			,@nFURMAT_DRAW			NUMERIC(22,9)
			,@nFURMANYLD_DRAW		NUMERIC(22,9)
			,@nScrapOffset			NUMERIC(22,9)
			,@nFURMANYLD_BULK		NUMERIC(22,9)
			,@nFURLAB_DRAW			NUMERIC(22,9)
			,@nFURVOH_DRAW			NUMERIC(22,9)
			,@nFURFOH_DRAW			NUMERIC(22,9)
			,@nINTYear              INT
			,@nFURINT               NUMERIC(22,9)
			,@nFURGNA               NUMERIC(22,9)
			,@sMensaje VARCHAR(250)
	
	CREATE TABLE #tmpFlete	(
								 NumFacturaProv	VARCHAR(100)
								,CantidadKgs	NUMERIC(22,4)
								,ImporteFlete	NUMERIC(22,4)
							)


	CREATE TABLE #tmpFURVOH_DRAW  (
									 TotalVariableOHCostsDrawing	NUMERIC(22,9)
									,AllocatedVariableOHCosts		NUMERIC(22,9)
									,FURVOH_DRAW					NUMERIC(22,9)
									,PorcProvRunHours				NUMERIC(22,9)	
									)

	CREATE TABLE #tmpFURFOH_DRAW  (
									 TotalFixedOHCostsDrawing		NUMERIC(22,9)
									,AllocatedFixedOHCosts			NUMERIC(22,9)
									,FURFOH_DRAW					NUMERIC(22,9)
									,PorcProvRunHours				NUMERIC(22,9)	
									)	

	SELECT	@nCategoriaAlambron = nValor1
	FROM	MSWSch.MSWCatConfiguracion (NOLOCK)
	WHERE	ClaConfiguracion = 100	
	
	SELECT	@sNomProveedor = NomProveedor
	FROM	MSWSCh.MSWCatProveedor5 (NOLOCK)
	WHERE	ClaProveedor = @pnVendor	

	SELECT	 fp.IdFurmanProduccion
			,fp.IdProdClavo	
			,fp.ClaArticuloClavo	
			,fp.FechaProdClavo	
			,fp.ClaAreaProdClavo	
			,fp.IdCeldaClavo	
			,fp.CantClavo	
			,fp.NomUnidadClavo	
			,fp.CantClavoLbs	
			,fp.CantClavoKgs	
			,fp.ClaArticuloDeaClavo	
			,fp.ConnumuClavo

			,fp.IdProdDetClavo	
			,fp.IdProdAlambre	
			,fp.IdCeldaAlambre	
			,fp.ClaArticuloAlambre	
			,fp.CantAlambreUsado	
			,fp.ClaUnidadAlambreUsado	
			,fp.CantAlambreUsadoKgs	
			,fp.CantTotalAlambre	
			,fp.CantTotalAlambreKgs	
			,fp.NomProveedorAlambre	
			,fp.EsAlambrePlanta	
			,fp.ClaArticuloDeaAlambre	
			,fp.ConnumuAlambre

			,fp.IdProdDetAlambre	
			,fp.ClaArticuloAlambron	
			,fp.CantAlambronUsado	
			,fp.ClaUnidadAlambronUsado	
			,fp.CantAlambronUsadoKgs	
			,fp.CantTotalAlambron	
			,fp.CantTotalAlambronKgs	
			,fp.NomProveedorAlambron	
			,fp.ClaProveedorAlambron	
			,fp.ClaArticuloDeaAlambron	
			,CASE WHEN fp.ClaProveedorAlambron = 275 THEN fp.ConnumuAlambron ELSE '' END AS ConnumuAlambron
			,fp.ClaProveedorResuelto
			,fp.EsTieneAlambre
			,fp.EsTieneAlambron
			,fp.ConnumuResuelto				 
	INTO #tmpFurmanProd
	FROM	MSWSch.MSWTraFurmanProduccion	fp	(NOLOCK)	
	INNER JOIN MSWSch.MSWCatArticulo Cat (NOLOCK)               ON fp.ClaArticuloClavo = Cat.ClaArticulo
																AND	Cat.ClaTipoInventario = 1
	WHERE	
	fp.ClaAreaProdClavo IN (1,2)		
	AND (@gpoEst IS NULL OR (@gpoEst IS NOT NULL AND Cat.ClaGrupoEstadistico2 = @gpoEst))
	AND	(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fp.FechaProdClavo)*100+MONTH(fp.FechaProdClavo) >= @pnAnioMesInicio))
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fp.FechaProdClavo)*100+MONTH(fp.FechaProdClavo) <= @pnAnioMesFin))
	AND	fp.ClaProveedorResuelto = @pnVendor	
	AND	fp.ConnumuResuelto IS NOT NULL
	/*AND		(
				(fp.ClaProveedorAlambron = @pnVendor OR (@sNomProveedor IS NOT NULL AND @sNomProveedor LIKE fp.NomProveedorAlambron + '%'))
				OR (@sNomProveedor IS NOT NULL AND @sNomProveedor LIKE fp.NomProveedorAlambre + '%')
			)*/

	SELECT		 DISTINCT	 IdProdArticulo		= fp.IdProdClavo			
							,ClaArticulo		= fp.ClaArticuloClavo
							,FechaProdArticulo	= fp.FechaProdClavo
							,ConnumuArticulo	= fp.ConnumuResuelto--connum.ConnumuAlambron
							,ConnumuAlambre      = fp.ConnumuAlambre
							,ConnumuAlambron    = fp.ConnumuAlambron
							,CantArticuloKgs	= fp.CantClavoKgs
							,ClaAreaProduccion	= fp.ClaAreaProdClavo
							,CantPorSkid		= ISNULL(art.CantidadPorSkid,0)
	INTO #tmpProdArt
	FROM		#tmpFurmanProd				fp
	LEFT JOIN	MSWSch.MSWTraArticuloInfo	art	(NOLOCK)	ON	fp.ClaArticuloClavo = art.ClaArticulo
															AND	art.ClaTipoInventario = 1
	/*OUTER APPLY	(
				SELECT		TOP 1 ConnumuAlambron
				FROM		#tmpFurmanProd
				WHERE		ClaArticuloClavo = fp.ClaArticuloClavo
				AND			ConnumuAlambron	IS NOT NULL
				ORDER BY	FechaProdClavo
				) connum*/
				
	SELECT		 tmp.ClaArticulo
				,tmp.ConnumuArticulo
				,tmp.ConnumuAlambre
				,tmp.ConnumuAlambron
				,tmp.ClaAreaProduccion
				,CantArticuloKgs = SUM(tmp.CantArticuloKgs)
				,tmp.CantPorSkid
				,FURMAT_BULK = CAST(NULL AS NUMERIC(22,9))
				,FURLAB_BULK = CAST(NULL AS NUMERIC(22,9))
				,FURLAB_COLLATED = CAST(NULL AS NUMERIC(22,9))
				,FURVOH_BULK = CAST(NULL AS NUMERIC(22,9))
				,FURVOH_COLLATED = CAST(NULL AS NUMERIC(22,9))
				,FURFOH_BULK = CAST(NULL AS NUMERIC(22,9))
				,FURFOH_COLLATED = CAST(NULL AS NUMERIC(22,9))
				,FURMANYLD_BULK = CAST(NULL AS NUMERIC(22,9))
				,FURLAB_DRAW = CAST(NULL AS NUMERIC(22,9))
				,FURHT       = CAST(NULL AS NUMERIC(22,9))
				,WasteVariance = CAST(NULL AS NUMERIC(22,9))
	INTO #tmpProdArtAgrupado
	FROM		#tmpProdArt	tmp		
	GROUP BY	 tmp.ClaArticulo
				,tmp.ConnumuArticulo
				,tmp.ConnumuAlambre
				,tmp.ConnumuAlambron
				,tmp.ClaAreaProduccion
				,tmp.CantPorSkid


	-- Hacemos la proporcion de la produccion tomando en cuenta la tabla estadistica
	UPDATE Ag
		SET CantArticuloKgs = EstProcC.ProduccionEstKgs
	FROM #tmpProdArtAgrupado Ag 
	CROSS APPLY(
		SELECT
			--ClaveArticulo
			--,ClaArticulo
			--,ConnumuArticulo
			--ProduccionClavosTotKgs = SUM(ProduccionClavosKgs)
			ProduccionEstKgs = CAST(SUM(EstProc.ProduccionClavosKgs*EstProc.PorcProdClavoRastreado)as numeric(22,4))
		FROM [MSWSch].[MSWEstProduccionFurman] EstProc
		WHERE Ag.ClaArticulo = EstProc.ClaArticulo
			AND EstProc.ConnumuArticulo = ISNULL(Ag.ConnumuArticulo, '')
			AND	(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(EstProc.FechaProduccionDate)*100+MONTH(EstProc.FechaProduccionDate) >= @pnAnioMesInicio))
			AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(EstProc.FechaProduccionDate)*100+MONTH(EstProc.FechaProduccionDate) <= @pnAnioMesFin))
			--AND FechaProduccion >= 20230901 
			--AND FechaProduccion <= 20230930
		GROUP BY 			
			EstProc.ClaArticulo
			,EstProc.ConnumuArticulo
	)EstProcC
		
	
	
--* FURMAT_DRAW
	IF @pnVendor IN (275) --DEACERO RM
	BEGIN
		INSERT INTO #tmpFlete				
		SELECT		NumFacturaProv	= fftm.NumFacturaDEA
					,CantidadKgs	= fftm.CantidadKgs
					,ImporteFlete	= fftm.ImporteFlete
		FROM 		MSWSch.MSWTraFurmanFreightToMCSW	fftm
		WHERE		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fftm.FechaFacturaDEA)*100+MONTH(fftm.FechaFacturaDEA) >= @pnAnioMesInicio))
		AND			(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fftm.FechaFacturaDEA)*100+MONTH(fftm.FechaFacturaDEA) <= @pnAnioMesFin))		
		/*CROSS APPLY	(
						SELECT	TOP 1 ent.IdEntrada
						FROM	MSWSch.MSWTraEntrada5	ent	(NOLOCK)
						INNER JOIN MSWSch.MSWTraOrdenCompra5 oc (NOLOCK) ON ent.IdOrdenCompra = oc.IdOrdenCompra
						WHERE	oc.ClaProveedor = @pnVendor
						AND		LTRIM(RTRIM(ent.Factura)) =	fftm.NumFacturaDEA
						AND		ISNULL(ent.EsCancelada,0) = 0
						AND		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(ent.FechaEntrada)*100+MONTH(ent.FechaEntrada) >= @pnAnioMesInicio))
						AND		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(ent.FechaEntrada)*100+MONTH(ent.FechaEntrada) <= @pnAnioMesFin))
					) e*/
		/*CROSS APPLY	(
						SELECT	TOP 1 ele.IdElemento
						FROM	MSWSch.MSWTraElemento8	ele	(NOLOCK)
						WHERE	LTRIM(RTRIM(ele.ReferenciaStr1)) =	fftm.NumFacturaDEA
						AND		ISNULL(ele.ClaEstatusElemento,0) <> 3
						AND		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(ele.Fecha)*100+MONTH(ele.Fecha) >= @pnAnioMesInicio))
						AND		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(ele.Fecha)*100+MONTH(ele.Fecha) <= @pnAnioMesFin))
					) e*/					
	END
	
	SELECT	@nFURMAT_DRAW = SUM(ImporteFlete)/NULLIF(SUM(CantidadKgs),0)
	FROM	#tmpFlete


--* FURMANYLD_DRAW
	SELECT	 @nImpAlambronUsado		= SUM(ImpAlambronUsado)
			,@nCantAlambronUsadoKgs	= SUM(CantAlambronUsadoKgs)
			,@nCantAlambreProdKgs	= SUM(CantAlambreProdKgs)
	FROM 	MSWSch.MSWTraFurmanDrawingWaste
	WHERE	ClaProveedor = @pnVendor
	AND		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND AnioMes >= @pnAnioMesInicio))
	AND		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND AnioMes <= @pnAnioMesFin))
	
	SET @nImpAlambronUsado = ISNULL(@nImpAlambronUsado,0)
	SET @nCantAlambronUsadoKgs = ISNULL(@nCantAlambronUsadoKgs,0)
	SET @nCantAlambreProdKgs = ISNULL(@nCantAlambreProdKgs,0)
	SET @nFURMANYLD_DRAW = ((((@nCantAlambronUsadoKgs - @nCantAlambreProdKgs)/NULLIF(@nCantAlambronUsadoKgs,0))) * @nImpAlambronUsado)/NULLIF(@nCantAlambreProdKgs,0)
	/*
		SELECT * FROM MSWSch.MSWTraFurmanDrawingWaste WHERE ClaProveedor = 275
								A					B						C
		ClaProveedor	AnioMes	ImpAlambronUsado	CantAlambronUsadoKgs	CantAlambreProdKgs
		275				201912	58629.5016			66014.7710				64720.3637

		Yield Loss % 		D = ((B - C) / B) * 100	
					
		Cost of Waste		(D * A) / C	

		SELECT	YieldLossPorc = ((CantAlambronUsadoKgs - CantAlambreProdKgs)/CantAlambronUsadoKgs)/**100*/
				,CostOfWaste = ((((CantAlambronUsadoKgs - CantAlambreProdKgs)/CantAlambronUsadoKgs)/**100*/) * ImpAlambronUsado)/CantAlambreProdKgs
		FROM	MSWSch.MSWTraFurmanDrawingWaste 
		WHERE	ClaProveedor = 275
	
	*/

--* SCRAP_OFFSET
	--* Obtener alambre hecho con alambron del proveedor 'MSWSch.MSWTraFurmanProduccionAlambre'
	SELECT	DISTINCT fp.IdProdAlambre
					,fp.ClaArticuloAlambre
					,fp.CantAlambreKgs
	INTO #tmpProdAlambre
	FROM	MSWSch.MSWTraFurmanProduccionAlambre	fp (NOLOCK)
	WHERE	fp.ClaProveedorResuelto = @pnVendor
	AND		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fp.FechaProdAlambre)*100+MONTH(fp.FechaProdAlambre) >= @pnAnioMesInicio))
	AND		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fp.FechaProdAlambre)*100+MONTH(fp.FechaProdAlambre) <= @pnAnioMesFin))	
	AND		ISNULL(fp.IdCeldaAlambre,0) > 0
	--AND		fp.IdOrdenTrabajoAlambre IS NOT NULL
	
	SELECT	@nCantAlambreProdKgs = SUM(CantAlambreKgs)
	FROM	#tmpProdAlambre

	SELECT	@nScrapRevenueTotal = SUM(ScrapRevenueTotal)
	FROM	MSWSch.MSWTraFurmanScrapOffset
	WHERE	ClaProveedor = @pnVendor
	AND		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND AnioMes >= @pnAnioMesInicio))
	AND		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND AnioMes <= @pnAnioMesFin))
	AND		ClaCategoria = @nCategoriaAlambron

	SET @nScrapOffset = (@nScrapRevenueTotal/NULLIF(@nCantAlambreProdKgs,0))*-1

--* FURMAT_BULK
	/*
	Unit cost of carton ('B-Box') used in production of finished good	0.4765	C
	Reported FURMAT BULK												0.0210	D = C / (50 x 0.4536)
	*/

	SET @dFechaInicial = CAST(@pnAnioMesInicio AS VARCHAR) + '01'
	SET @dFechaFinal = CAST(@pnAnioMesFin AS VARCHAR) + '01'
	SET @nNumMes = DATEDIFF(mm, @dFechaInicial, @dFechaFinal) + 1

	SELECT	 ClaAreaProduccion
			,PromCostOfCartons = CAST(ISNULL((ISNULL(SUM(ImpConsumo),0) + ISNULL(SUM(ImpAjusteInv),0)) / NULLIF((ISNULL(SUM(CantConsumo),0) + ISNULL(SUM(CantAjusteInv),0)),0),0) AS NUMERIC(22,9)) 
			--SUM(CostoUnitario)/NULLIF(@nNumMes,0)
	INTO #tmpCostOfCartons
	FROM	MSWSch.MSWTraFurmanCostOfCartons	(NOLOCK)
	WHERE	ClaProveedor = @pnVendor
	AND		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND AnioMes >= @pnAnioMesInicio))
	AND		(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND AnioMes <= @pnAnioMesFin))
	GROUP BY ClaAreaProduccion

	UPDATE	pa	SET FURMAT_BULK = coc.PromCostOfCartons / NULLIF((pa.CantPorSkid* @nFactorLbsKgs),0)
	FROM		#tmpProdArtAgrupado	pa
	INNER JOIN	#tmpCostOfCartons	coc	ON	pa.ClaAreaProduccion = coc.ClaAreaProduccion

--* FURMANYLD_BULK

	DECLARE 
		@nConteoOTs             INT
		,@nSumaCostoUnitario    NUMERIC(22,4)
		,@nTotalProduccionKgs	NUMERIC(22,4)

	SELECT 
		 @nConteoOTs          = ConteoOTs          
		,@nSumaCostoUnitario  = SumaCostoUnitario 
		,@nTotalProduccionKgs =TotalProduccionKgs
	FROM [MSWSch].[MSW_CU423_Pag7_PreCalculo_FURMANYLD_BULK_fn](@pnAnioMesInicio, @pnAnioMesFin)

		
	UPDATE	pa	SET FURMANYLD_BULK = fb.FURMANYLD_BULK, WasteVariance = fb.VariacionWaste
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (	
		SELECT FURMANYLD_BULK,VariacionWaste FROM MSWSch.MSW_CU423_Pag7_FURMANYLD_BULK_fn (
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			,@nConteoOTs
																			,@nSumaCostoUnitario
																			,@nTotalProduccionKgs
																			)
	)fb

--* FURLAB_DRAW
	DECLARE
		@nStandardDrawingLaborRate NUMERIC(22,9)
		,@nPorcProvRunHours		 NUMERIC(22,9)
		,@nTotalProdProvKgs		 NUMERIC(22,4)
	
	SELECT 
		@nStandardDrawingLaborRate = StandardDrawingLaborRate
		,@nPorcProvRunHours = PorcProvRunHours
		,@nTotalProdProvKgs = TotalProdProvKgs
	FROM [MSWSch].[MSW_CU423_Pag7_Precalculo_FURLAB_DRAW_fn](@pnVendor,@pnAnioMesInicio,@pnAnioMesFin)


	UPDATE	pa	SET FURLAB_DRAW = fb.FURLAB_DRAW
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (
				SELECT FURLAB_DRAW FROM MSWSch.MSW_CU423_Pag7_FURLAB_DRAW_fn(
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			,@nStandardDrawingLaborRate
																			,@nPorcProvRunHours
																			,@nTotalProdProvKgs
																			)
				) fb


--* FURLAB_BULK
	UPDATE	pa	SET FURLAB_BULK = fb.FURLAB_BULK
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (
				SELECT FURLAB_BULK FROM MSWSch.MSW_CU423_Pag7_FURLAB_BULK_fn(
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			)
				) fb
				
				
--* FURLAB_COLLATED
	UPDATE	pa	SET FURLAB_COLLATED = fb.FURLAB_BULK
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (
				SELECT FURLAB_BULK FROM MSWSch.MSW_CU423_Pag7_FURLAB_COLLATED_fn(
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			)
				) fb				

--* FURVOH_DRAW
	INSERT INTO #tmpFURVOH_DRAW
	SELECT	 TotalVariableOHCostsDrawing
			,AllocatedVariableOHCosts
			,FURVOH_DRAW
			,PorcProvRunHours
	FROM	MSWSch.MSW_CU423_Pag7_FURVOH_DRAW_fn(
												@pnVendor--@pnClaProveedor	INT
												,NULL--@pnClaArticulo		INT
												,@pnAnioMesInicio--@pnAnioMesInicial	INT
												,@pnAnioMesFin--@pnAnioMesFinal	INT
												)

	SELECT	@nFURVOH_DRAW = FURVOH_DRAW
	FROM	#tmpFURVOH_DRAW

--* FURVOH_BULK
	UPDATE	pa	SET FURVOH_BULK = fb.FURVOH_BULK
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (
				SELECT FURVOH_BULK FROM MSWSch.MSW_CU423_Pag7_FURVOH_BULK_fn(
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			)
				) fb
				
--* FURVOH_COLLATED
	UPDATE	pa	SET FURVOH_COLLATED = fb.FURVOH_BULK
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (
				SELECT FURVOH_BULK FROM MSWSch.MSW_CU423_Pag7_FURVOH_COLLATED_fn(
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			)
				) fb				

--* FURFOH_DRAW
	INSERT INTO #tmpFURFOH_DRAW
	SELECT	 TotalFixedOHCostsDrawing
			,AllocatedFixedOHCosts
			,FURFOH_DRAW
			,PorcProvRunHours
	FROM	MSWSch.MSW_CU423_Pag7_FURFOH_DRAW_fn(
												@pnVendor--@pnClaProveedor	INT
												,NULL--@pnClaArticulo		INT
												,@pnAnioMesInicio--@pnAnioMesInicial	INT
												,@pnAnioMesFin--@pnAnioMesFinal	INT
												)

	SELECT	@nFURFOH_DRAW = FURFOH_DRAW
	FROM	#tmpFURFOH_DRAW

--* FURFOH_BULK
	UPDATE	pa	SET FURFOH_BULK = fb.FURFOH_BULK
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (
				SELECT FURFOH_BULK FROM MSWSch.MSW_CU423_Pag7_FURFOH_BULK_fn(
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			)
				) fb
				
--* FURFOH_COLLATED
	UPDATE	pa	SET FURFOH_COLLATED = fb.FURFOH_BULK
	FROM		#tmpProdArtAgrupado	pa
	CROSS APPLY (
				SELECT FURFOH_BULK FROM MSWSch.MSW_CU423_Pag7_FURFOH_COLLATED_fn(
																			 @pnVendor--@pnClaProveedor	INT
																			,pa.ClaArticulo--@pnClaArticulo		INT
																			,@pnAnioMesInicio--@pnAnioMesInicial	INT
																			,@pnAnioMesFin--@pnAnioMesFinal	INT
																			)
				) fb				

--*FURTH 
	UPDATE pa SET FURHT = fb.ImporteHeatTreatmentKgs
	FROM #tmpProdArtAgrupado	pa
	CROSS APPLY (
			SELECT ImporteHeatTreatmentKgs FROM [MSWSch].[MSWCfgFurmanHeatTreatment] H (NOLOCK)
				INNER JOIN [MSWSch].[MSWRelFurmanHeatTreatmentArticulo] DtA (NOLOCK) ON H.ClaFurmanHeatTreatment = DtA.ClaFurmanHeatTreatment
			WHERE H.AnioMesInicial = @pnAnioMesInicio 
			AND H.AnioMesFinal = @pnAnioMesFin 
			AND H.BajaLogica != 1 
			AND DtA.ClaArticulo = pa.ClaArticulo
	) fb

	IF @pnEsDebug = 1
	BEGIN
		--SELECT '#tmpFurmanProd',* FROM #tmpFurmanProd
		--SELECT '#tmpProdArt',* FROM #tmpProdArt
		SELECT '#tmpProdArtAgrupado',* FROM #tmpProdArtAgrupado
		--SELECT '#tmpFlete',* FROM #tmpFlete
		SELECT @nNumMes '@nNumMes'
	END

--FURINT DIEGO LAUREANO
	DECLARE @pnAnioCalculoINT INT

	SELECT @pnAnioCalculoINT=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [MSWSch].MSWCfgInteresPeriodoFurman (NOLOCK) 
	WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT OR AnioInteresPeriodoFurman=@pnAnioCalculoINT-1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT)
		BEGIN
			SELECT @nFURINT = ISNULL((FactorInteresPeriodoFurman/100.0),0) FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) WHERE AnioInteresPeriodoFurman=@pnAnioCalculoINT
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURINT = ISNULL((FactorInteresPeriodoFurman/100.0),0) FROM MswSch.MSWCfgInteresPeriodoFurman (NOLOCK) ORDER BY AnioInteresPeriodoFurman DESC
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
			SELECT @nFURGNA = ISNULL((FactorGNAPeriodoFurman/100.0),0) FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURGNA = ISNULL((FactorGNAPeriodoFurman/100.0),0) FROM MswSch.MSWCfgGNAPeriodoFurman (NOLOCK) ORDER BY AnioGNAPeriodoFurman DESC
		END
		--SET @nFURGNA=1
		PRINT @nFURGNA
	END
	ELSE
	BEGIN
		RAISERROR('GNA Missing configuration, please configure a GNA value for current P.O.R',16,1)
	END

	
	IF(@pnEsPorPantallaReact=0)
	BEGIN
		SELECT 
		 prod.ClaArticulo			        AS [PRODCODU;w=100;a=Center;t=clave;c=PRODCODU]
		,CONVERT(VARCHAR,ISNULL(Art.ClaveArticulo,''))+' - '+ISNULL(Art.NomArticuloIngles,'')  AS [PRODNAME;w=400;a=left;t=clave;c=PRODNAME] 
		--,Depto.NomGrupoEstadistico2Ingles AS [DEPARMENT;w=150;a=Center;t=clave;c=DEPARMENT;v=true]
		--,CONVERT(VARCHAR,ISNULL(Art.ClaveArticulo,''))+' - '+ISNULL(Art.NomArticuloIngles,'') AS [DEPARMENT;w=150;a=Center;t=clave;c=DEPARMENT;v=true]
		,ISNULL(GpoEst2.NomGpoEst+' - '+ GpoEst3.NomGpoEst, 'ND') AS [NAILTYPE;w=280;a=left;t=text;c=NAILTYPE]
		--,NomFamiliaIngles AS [Family;w=150;a=Center;t=clave;c=Family;v=true]
		,prod.ConnumuArticulo		                AS [CONNUMU;w=150;a=Center;t=clave;c=CONNUMU;v=false]	
		,ISNULL(prod.ConnumuAlambre,'')             AS [WCONNUMU;w=150;a=left;t=clave;c=Wire CONNUMU]	
		,ISNULL(prod.ConnumuAlambron,'')            AS [WRCONNUMU;w=150;a=left;t=clave;c=Wire Rod CONNUMU]	
		,prod.CantArticuloKgs		                AS [PRODQTY;w=100;a=Right;t=decimal;d=4;c=PRODQTY;s=sum]
		,ISNULL(@nFURMAT_DRAW,0)	                AS [FURMAT_DRAW;w=100;a=Right;t=decimal;d=9;c=FURMAT_DRAW;]	
		,ISNULL(@nFURMANYLD_DRAW,0)                 AS [FURMANYLD_DRAW;w=125;a=Right;t=decimal;d=9;c=FURMANYLD_DRAW;]
		,ISNULL(@nScrapOffset,0)	                AS [SCRAP_OFFSET;w=100;a=Right;t=decimal;d=9;c=SCRAP_OFFSET]
		,ISNULL(FURMAT_BULK,0)		                AS [FURMAT_BULK;w=100;a=Right;t=decimal;d=9;c=FURMAT_BULK]
		--,ISNULL(@nFURMANYLD_BULK,0) AS [FURMANYLD_BULK;w=100;a=Right;t=decimal;d=9;c=FURMANYLD_BULK]
		,ISNULL(FURMANYLD_BULK,0)  AS [FURMANYLD_BULK;w=155;a=Right;t=decimal;d=9;c=FURMANYLD_BULK]
		--,ISNULL(@nFURMAT_DRAW,0) + ISNULL(@nFURMANYLD_DRAW,0) + ISNULL(@nScrapOffset,0) + ISNULL(FURMAT_BULK,0) + ISNULL(@nFURMANYLD_BULK,0) AS [FURMAT;w=100;a=Right;t=decimal;d=9;c=FURMAT]
		,ISNULL(@nFURMAT_DRAW,0) 
		+ ISNULL(@nFURMANYLD_DRAW,0) 
		+ ISNULL(@nScrapOffset,0) 
		+ ISNULL(FURMAT_BULK,0) 
		+ /*ISNULL(WasteVariance,0)*/ ISNULL(FURMANYLD_BULK,0) AS [FURMAT;w=100;a=Right;t=decimal;d=9;c=FURMAT]
		--,ISNULL(@nFURLAB_DRAW,0) AS [FURLAB_DRAW;w=100;a=Right;t=decimal;d=9;c=FURLAB_DRAW]
		,ISNULL(FURLAB_DRAW,0)     AS [FURLAB_DRAW;w=100;a=Right;t=decimal;d=9;c=FURLAB_DRAW]
		,ISNULL(FURLAB_BULK,0)     AS [FURLAB_BULK;w=100;a=Right;t=decimal;d=9;c=FURLAB_BULK]
		,ISNULL(FURLAB_COLLATED,0)     AS [FURLAB_COLLATED;w=100;a=Right;t=decimal;d=9;c=FURLAB_COLLATED]
		,ISNULL(FURLAB_DRAW,0) 
		+ ISNULL(FURLAB_BULK,0)
		+ ISNULL(FURLAB_COLLATED,0)     AS [FURLAB;w=100;a=Right;t=decimal;d=9;c=FURLAB]
		,ISNULL(@nFURVOH_DRAW,0)   AS [FURVOH_DRAW;w=100;a=Right;t=decimal;d=9;c=FURVOH_DRAW]
		,ISNULL(FURVOH_BULK,0)     AS [FURVOH_BULK;w=100;a=Right;t=decimal;d=9;c=FURVOH_BULK]
		,ISNULL(FURVOH_COLLATED,0)     AS [FURVOH_COLLATED;w=100;a=Right;t=decimal;d=9;c=FURVOH_COLLATED]
		,ISNULL(@nFURVOH_DRAW,0) 
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0)    AS [FURVOH;w=100;a=Right;t=decimal;d=9;c=FURVOH]
		,ISNULL(@nFURFOH_DRAW,0)   AS [FURFOH_DRAW;w=100;a=Right;t=decimal;d=9;c=FURFOH_DRAW]
		,ISNULL(FURFOH_BULK,0)     AS [FURFOH_BULK;w=100;a=Right;t=decimal;d=9;c=FURFOH_BULK]
		,ISNULL(FURFOH_COLLATED,0)     AS [FURFOH_COLLATED;w=100;a=Right;t=decimal;d=9;c=FURFOH_COLLATED]
		,ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)    
		+ ISNULL(FURFOH_COLLATED,0) AS [FURFOH;w=100;a=Right;t=decimal;d=9;c=FURFOH]
		,ISNULL(@nFURVOH_DRAW,0) 
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0) 
		+ ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)   
		+ ISNULL(FURFOH_COLLATED,0) AS [FUROH;w=100;a=Right;t=decimal;d=9;c=FUROH]
		,ISNULL(prod.FURHT,0)      AS [FURHT;w=100;a=Right;t=decimal;d=9;c=FURHT]
		--,ISNULL(@nFURMAT_DRAW,0) + ISNULL(@nFURMANYLD_DRAW,0) + ISNULL(@nScrapOffset,0) + ISNULL(FURMAT_BULK,0) + ISNULL(FURMANYLD_BULK,0)
		--	+ ISNULL(FURLAB_DRAW,0) + ISNULL(FURLAB_BULK,0)
		--	+ ISNULL(@nFURVOH_DRAW,0) + ISNULL(FURVOH_BULK,0) + ISNULL(@nFURFOH_DRAW,0) + ISNULL(FURFOH_BULK,0)	
		--	AS [FURCOM;w=100;a=Right;t=decimal;d=9;c=FURCOM]
		,ISNULL(@nFURMAT_DRAW,0) 
		+ ISNULL(@nFURMANYLD_DRAW,0) 
		+ ISNULL(@nScrapOffset,0) 
		+ ISNULL(FURMAT_BULK,0) 
		+ ISNULL(FURMANYLD_BULK,0)
		+ ISNULL(FURLAB_DRAW,0) 
		+ ISNULL(FURLAB_BULK,0)                               
		+ ISNULL(FURLAB_COLLATED,0)  
		+ ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)
		+ ISNULL(FURFOH_COLLATED,0)
		+ ISNULL(@nFURVOH_DRAW,0)
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0)                               
		+ ISNULL(prod.FURHT,0)     --Nota: RE: FURMAN - Detalles Resueltos. Respecto a tu primer duda sobre el FURHT, sí hay que sumarla par obtener el FURCOM, favor de realizar esa adecuación. (LuisEugenio)
		AS [FURCOM;w=100;a=Right;t=decimal;d=9;c=FURCOM]
		,(
			ISNULL(@nFURMAT_DRAW,0) 
			+ ISNULL(@nFURMANYLD_DRAW,0)
			+ ISNULL(@nScrapOffset,0) 
			+ ISNULL(FURMAT_BULK,0) 
			+ ISNULL(FURMANYLD_BULK,0)
			+ ISNULL(FURLAB_DRAW,0) 
			+ ISNULL(FURLAB_BULK,0)  
			+ ISNULL(FURLAB_COLLATED,0)   
			+ ISNULL(@nFURFOH_DRAW,0) 
			+ ISNULL(FURFOH_BULK,0)
			+ ISNULL(FURFOH_COLLATED,0)
			+ ISNULL(@nFURVOH_DRAW,0)
			+ ISNULL(FURVOH_BULK,0)  
			+ ISNULL(FURVOH_COLLATED,0)   
			+ ISNULL(prod.FURHT,0)
		) * ISNULL(@nFURGNA,0) AS [FURGNA;w=100;a=Right;t=decimal;d=9;c= FURGNA]
		,(
			ISNULL(@nFURMAT_DRAW,0) 
			+ ISNULL(@nFURMANYLD_DRAW,0)
			+ ISNULL(@nScrapOffset,0) 
			+ ISNULL(FURMAT_BULK,0) 
			+ ISNULL(FURMANYLD_BULK,0)
			+ ISNULL(FURLAB_DRAW,0) 
			+ ISNULL(FURLAB_BULK,0)   
			+ ISNULL(FURLAB_COLLATED,0)  
			+ ISNULL(@nFURFOH_DRAW,0) 
			+ ISNULL(FURFOH_BULK,0)
			+ ISNULL(FURFOH_COLLATED,0)
			+ ISNULL(@nFURVOH_DRAW,0)
			+ ISNULL(FURVOH_BULK,0)  
			+ ISNULL(FURVOH_COLLATED,0)   
			+ ISNULL(prod.FURHT,0)
		) * ISNULL(@nFURINT,0)  AS [FURINT;w=100;a=Right;t=decimal;d=9;c=FURINT]
		,ISNULL(@nFURMAT_DRAW,0) 
		+ ISNULL(@nFURMANYLD_DRAW,0) 
		+ ISNULL(@nScrapOffset,0) 
		+ ISNULL(FURMAT_BULK,0) 
		+ ISNULL(FURMANYLD_BULK,0)
		+ ISNULL(FURLAB_DRAW,0) 
		+ ISNULL(FURLAB_BULK,0)
		+ ISNULL(FURLAB_COLLATED,0) 
		+ ISNULL(@nFURVOH_DRAW,0) 
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0) 
		+ ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)
		+ ISNULL(FURFOH_COLLATED,0)
		+ ISNULL(prod.FURHT,0) 
		+ (
			(
			ISNULL(@nFURMAT_DRAW,0) 
			+ ISNULL(@nFURMANYLD_DRAW,0)
			+ ISNULL(@nScrapOffset,0) 
			+ ISNULL(FURMAT_BULK,0) 
			+ ISNULL(FURMANYLD_BULK,0)
			+ ISNULL(FURLAB_DRAW,0) 
			+ ISNULL(FURLAB_BULK,0)  
			+ ISNULL(FURLAB_COLLATED,0)   
			+ ISNULL(@nFURFOH_DRAW,0) 
			+ ISNULL(FURFOH_BULK,0)
			+ ISNULL(FURFOH_COLLATED,0)
			+ ISNULL(@nFURVOH_DRAW,0)
			+ ISNULL(FURVOH_BULK,0) 
			+ ISNULL(FURVOH_COLLATED,0)    
			+ ISNULL(prod.FURHT,0)
			) * ISNULL(@nFURGNA,0) /*FURGNA */ 
		) 
		+ (
			(
				ISNULL(@nFURMAT_DRAW,0) 
				+ ISNULL(@nFURMANYLD_DRAW,0)
				+ ISNULL(@nScrapOffset,0) 
				+ ISNULL(FURMAT_BULK,0) 
				+ ISNULL(FURMANYLD_BULK,0)
				+ ISNULL(FURLAB_DRAW,0) 
				+ ISNULL(FURLAB_BULK,0)  
				+ ISNULL(FURLAB_COLLATED,0)   
				+ ISNULL(@nFURFOH_DRAW,0) 
				+ ISNULL(FURFOH_BULK,0)
				+ ISNULL(FURFOH_COLLATED,0)
				+ ISNULL(@nFURVOH_DRAW,0)
				+ ISNULL(FURVOH_BULK,0)   
				+ ISNULL(FURVOH_COLLATED,0)  
				+ ISNULL(prod.FURHT,0)
			) * ISNULL(@nFURINT,0)
		)                       AS [TOTFMG;w=100;a=Right;t=decimal;d=9;c=TOTFMG] 
	
		FROM	#tmpProdArtAgrupado	prod		
		--INNER JOIN MSWSch.MSWCatArticulo Art WITH(NOLOCK) ON prod.ClaArticulo=Art.ClaArticulo AND Art.ClaTipoInventario = 1 AND Art.ClaGrupoEstadistico2 IS NOT NULL
		INNER JOIN MSWSch.MSWCatArticulo Art WITH(NOLOCK) ON prod.ClaArticulo=Art.ClaArticulo 
														AND Art.ClaTipoInventario = 1 
														AND Art.ClaGrupoEstadistico2 IS NOT NULL
		--INNER JOIN MSWSch.MSWCatFamilia Fam WITH(NOLOCK) ON Fam.ClaFamilia = Art.ClaFamilia
		--LEFT JOIN MSWSch.MSWCatGrupoEstadistico2_Orig Depto WITH(NOLOCK) ON Art.ClaGrupoEstadistico2=Depto.ClaGrupoEstadistico2
		--WHERE Art.ClaGrupoEstadistico2  = @gpoEst

		OUTER APPLY(
			SELECT TOP 1
				ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
				NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
			FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
			WHERE GpoEstCat.ClaGrupoEstadistico = Art.ClaGrupoEstadistico2
			ORDER BY GpoEstCat.NivelActual ASC
		) AS GpoEst2
		OUTER APPLY(
			SELECT TOP 1
				ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
				NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
			FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
			WHERE GpoEstCat.ClaGrupoEstadistico = Art.ClaGrupoEstadistico3
			ORDER BY GpoEstCat.NivelActual ASC
		) AS GpoEst3



		ORDER BY prod.ClaArticulo
	END
	ELSE
	BEGIN
		SELECT 
		 prod.ClaArticulo			        AS PRODCODU
		 ,CONVERT(VARCHAR,ISNULL(Art.ClaveArticulo,''))+' - '+ISNULL(Art.NomArticuloIngles,'') AS PRODNAME
		 --Depto.NomGrupoEstadistico2Ingles AS DEPARMENT
		,ISNULL(GpoEst2.NomGpoEst +' - '+ GpoEst3.NomGpoEst, 'ND') AS DEPARMENT
		,prod.ConnumuArticulo		                AS CONNUMU	
		,ISNULL(prod.ConnumuAlambre,'')             AS WCONNUMU
		,ISNULL(prod.ConnumuAlambron,'')            AS WRCONNUMU	
		,prod.CantArticuloKgs		                AS PRODQTY
		,ISNULL(@nFURMAT_DRAW,0)	                AS FURMAT_DRAW	
		,ISNULL(@nFURMANYLD_DRAW,0)                 AS FURMANYLD_DRAW
		,ISNULL(@nScrapOffset,0)	                AS SCRAP_OFFSET
		,ISNULL(FURMAT_BULK,0)		                AS FURMAT_BULK
		--,ISNULL(@nFURMANYLD_BULK,0) AS [FURMANYLD_BULK;w=100;a=Right;t=decimal;d=9;c=FURMANYLD_BULK]
		,ISNULL(FURMANYLD_BULK,0)  AS FURMANYLD_BULK
		--,ISNULL(@nFURMAT_DRAW,0) + ISNULL(@nFURMANYLD_DRAW,0) + ISNULL(@nScrapOffset,0) + ISNULL(FURMAT_BULK,0) + ISNULL(@nFURMANYLD_BULK,0) AS [FURMAT;w=100;a=Right;t=decimal;d=9;c=FURMAT]
		,ISNULL(@nFURMAT_DRAW,0) 
		+ ISNULL(@nFURMANYLD_DRAW,0) 
		+ ISNULL(@nScrapOffset,0) 
		+ ISNULL(FURMAT_BULK,0) 
		+ /*ISNULL(WasteVariance,0)*/ ISNULL(FURMANYLD_BULK,0) AS FURMAT
		--,ISNULL(@nFURLAB_DRAW,0) AS [FURLAB_DRAW;w=100;a=Right;t=decimal;d=9;c=FURLAB_DRAW]
		,ISNULL(FURLAB_DRAW,0)     AS FURLAB_DRAW
		,ISNULL(FURLAB_BULK,0)     AS FURLAB_BULK
		,ISNULL(FURLAB_COLLATED,0)     AS FURLAB_COLLATED
		,ISNULL(FURLAB_DRAW,0) 
		+ ISNULL(FURLAB_BULK,0)
		+ ISNULL(FURLAB_COLLATED,0)     AS FURLAB
		,ISNULL(@nFURVOH_DRAW,0)   AS FURVOH_DRAW
		,ISNULL(FURVOH_BULK,0)     AS FURVOH_BULK
		,ISNULL(FURVOH_COLLATED,0)     AS FURVOH_COLLATED
		,ISNULL(@nFURVOH_DRAW,0) 
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0)    AS FURVOH
		,ISNULL(@nFURFOH_DRAW,0)   AS FURFOH_DRAW
		,ISNULL(FURFOH_BULK,0)     AS FURFOH_BULK
		,ISNULL(FURFOH_COLLATED,0)     AS FURFOH_COLLATED
		,ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)    
		+ ISNULL(FURFOH_COLLATED,0) AS FURFOH
		,ISNULL(@nFURVOH_DRAW,0) 
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0) 
		+ ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)   
		+ ISNULL(FURFOH_COLLATED,0) AS FUROH
		,ISNULL(prod.FURHT,0)      AS FURHT
		--,ISNULL(@nFURMAT_DRAW,0) + ISNULL(@nFURMANYLD_DRAW,0) + ISNULL(@nScrapOffset,0) + ISNULL(FURMAT_BULK,0) + ISNULL(FURMANYLD_BULK,0)
		--	+ ISNULL(FURLAB_DRAW,0) + ISNULL(FURLAB_BULK,0)
		--	+ ISNULL(@nFURVOH_DRAW,0) + ISNULL(FURVOH_BULK,0) + ISNULL(@nFURFOH_DRAW,0) + ISNULL(FURFOH_BULK,0)	
		--	AS [FURCOM;w=100;a=Right;t=decimal;d=9;c=FURCOM]
		,ISNULL(@nFURMAT_DRAW,0) 
		+ ISNULL(@nFURMANYLD_DRAW,0) 
		+ ISNULL(@nScrapOffset,0) 
		+ ISNULL(FURMAT_BULK,0) 
		+ ISNULL(FURMANYLD_BULK,0)
		+ ISNULL(FURLAB_DRAW,0) 
		+ ISNULL(FURLAB_BULK,0)                               
		+ ISNULL(FURLAB_COLLATED,0)  
		+ ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)
		+ ISNULL(FURFOH_COLLATED,0)
		+ ISNULL(@nFURVOH_DRAW,0)
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0)                               
		+ ISNULL(prod.FURHT,0)     --Nota: RE: FURMAN - Detalles Resueltos. Respecto a tu primer duda sobre el FURHT, sí hay que sumarla par obtener el FURCOM, favor de realizar esa adecuación. (LuisEugenio)
		AS FURCOM
		,(
			ISNULL(@nFURMAT_DRAW,0) 
			+ ISNULL(@nFURMANYLD_DRAW,0)
			+ ISNULL(@nScrapOffset,0) 
			+ ISNULL(FURMAT_BULK,0) 
			+ ISNULL(FURMANYLD_BULK,0)
			+ ISNULL(FURLAB_DRAW,0) 
			+ ISNULL(FURLAB_BULK,0)  
			+ ISNULL(FURLAB_COLLATED,0)   
			+ ISNULL(@nFURFOH_DRAW,0) 
			+ ISNULL(FURFOH_BULK,0)
			+ ISNULL(FURFOH_COLLATED,0)
			+ ISNULL(@nFURVOH_DRAW,0)
			+ ISNULL(FURVOH_BULK,0)  
			+ ISNULL(FURVOH_COLLATED,0)   
			+ ISNULL(prod.FURHT,0)
		) * ISNULL(@nFURGNA,0) AS FURGNA
		,(
			ISNULL(@nFURMAT_DRAW,0) 
			+ ISNULL(@nFURMANYLD_DRAW,0)
			+ ISNULL(@nScrapOffset,0) 
			+ ISNULL(FURMAT_BULK,0) 
			+ ISNULL(FURMANYLD_BULK,0)
			+ ISNULL(FURLAB_DRAW,0) 
			+ ISNULL(FURLAB_BULK,0)   
			+ ISNULL(FURLAB_COLLATED,0)  
			+ ISNULL(@nFURFOH_DRAW,0) 
			+ ISNULL(FURFOH_BULK,0)
			+ ISNULL(FURFOH_COLLATED,0)
			+ ISNULL(@nFURVOH_DRAW,0)
			+ ISNULL(FURVOH_BULK,0)  
			+ ISNULL(FURVOH_COLLATED,0)   
			+ ISNULL(prod.FURHT,0)
		) * ISNULL(@nFURINT,0)  AS FURINT
		,ISNULL(@nFURMAT_DRAW,0) 
		+ ISNULL(@nFURMANYLD_DRAW,0) 
		+ ISNULL(@nScrapOffset,0) 
		+ ISNULL(FURMAT_BULK,0) 
		+ ISNULL(FURMANYLD_BULK,0)
		+ ISNULL(FURLAB_DRAW,0) 
		+ ISNULL(FURLAB_BULK,0)
		+ ISNULL(FURLAB_COLLATED,0) 
		+ ISNULL(@nFURVOH_DRAW,0) 
		+ ISNULL(FURVOH_BULK,0) 
		+ ISNULL(FURVOH_COLLATED,0) 
		+ ISNULL(@nFURFOH_DRAW,0) 
		+ ISNULL(FURFOH_BULK,0)
		+ ISNULL(FURFOH_COLLATED,0)
		+ ISNULL(prod.FURHT,0) 
		+ (
			(
			ISNULL(@nFURMAT_DRAW,0) 
			+ ISNULL(@nFURMANYLD_DRAW,0)
			+ ISNULL(@nScrapOffset,0) 
			+ ISNULL(FURMAT_BULK,0) 
			+ ISNULL(FURMANYLD_BULK,0)
			+ ISNULL(FURLAB_DRAW,0) 
			+ ISNULL(FURLAB_BULK,0)  
			+ ISNULL(FURLAB_COLLATED,0)   
			+ ISNULL(@nFURFOH_DRAW,0) 
			+ ISNULL(FURFOH_BULK,0)
			+ ISNULL(FURFOH_COLLATED,0)
			+ ISNULL(@nFURVOH_DRAW,0)
			+ ISNULL(FURVOH_BULK,0) 
			+ ISNULL(FURVOH_COLLATED,0)    
			+ ISNULL(prod.FURHT,0)
			) * ISNULL(@nFURGNA,0) /*FURGNA */ 
		) 
		+ (
			(
				ISNULL(@nFURMAT_DRAW,0) 
				+ ISNULL(@nFURMANYLD_DRAW,0)
				+ ISNULL(@nScrapOffset,0) 
				+ ISNULL(FURMAT_BULK,0) 
				+ ISNULL(FURMANYLD_BULK,0)
				+ ISNULL(FURLAB_DRAW,0) 
				+ ISNULL(FURLAB_BULK,0)  
				+ ISNULL(FURLAB_COLLATED,0)   
				+ ISNULL(@nFURFOH_DRAW,0) 
				+ ISNULL(FURFOH_BULK,0)
				+ ISNULL(FURFOH_COLLATED,0)
				+ ISNULL(@nFURVOH_DRAW,0)
				+ ISNULL(FURVOH_BULK,0)   
				+ ISNULL(FURVOH_COLLATED,0)  
				+ ISNULL(prod.FURHT,0)
			) * ISNULL(@nFURINT,0)
		)                       AS TOTFMG 
	
		FROM	#tmpProdArtAgrupado	prod
		INNER JOIN MSWSch.MSWCatArticulo Art WITH(NOLOCK) ON prod.ClaArticulo=Art.ClaArticulo 
														AND Art.ClaTipoInventario = 1 
														AND Art.ClaGrupoEstadistico2 IS NOT NULL
		--INNER JOIN MSWSch.MSWCatArticulo Cat WITH(NOLOCK) ON V.ClaArticulo = Cat.ClaArticulo
		OUTER APPLY(
			SELECT TOP 1
				ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
				NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
			FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
			WHERE GpoEstCat.ClaGrupoEstadistico = Art.ClaGrupoEstadistico2
			ORDER BY GpoEstCat.NivelActual ASC
		) AS GpoEst2
		OUTER APPLY(
			SELECT TOP 1
				ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
				NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
			FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
			WHERE GpoEstCat.ClaGrupoEstadistico = Art.ClaGrupoEstadistico3
			ORDER BY GpoEstCat.NivelActual ASC
		) AS GpoEst3

		ORDER BY prod.ClaArticulo
	END

	
FINSP:
DROP TABLE #tmpFurmanProd
DROP TABLE #tmpProdArt
DROP TABLE #tmpProdArtAgrupado
DROP TABLE #tmpFlete
DROP TABLE #tmpProdAlambre
DROP TABLE #tmpCostOfCartons
--DROP TABLE #tmpFURMANYLD_BULK
--DROP TABLE #tmpFURLAB_DRAW
DROP TABLE #tmpFURVOH_DRAW
DROP TABLE #tmpFURFOH_DRAW

END
