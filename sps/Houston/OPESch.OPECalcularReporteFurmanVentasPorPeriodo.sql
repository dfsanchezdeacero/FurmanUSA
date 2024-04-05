ALTER PROC [OPESch].[OPECalcularReporteFurmanVentasPorPeriodo]
 @pnAnioMesInicio		INT = NULL
,@pnAnioMesFin			INT = NULL
,@pnEsDebug				TINYINT = 0  
AS
BEGIN

	DECLARE 
		@nEsError       INT,
		@sMensaje       VARCHAR(MAX),
		@AnioInicial    INT,
		@AnioFinal      INT,
		@nREPACKU		NUMERIC(22,8),
		@pnDpto         INT = NULL,
		@AnioSinConfig	VARCHAR(MAX),
		@FechaCompletaIni	DATE,
		@FechaCompletaFin	DATE,
		@sFamiliasAlambre VARCHAR(8000)

    SELECT @sFamiliasAlambre = sValor1 
	FROM [OPESch].[OpeCatFurmanConfiguracion] WHERE ClaConfiguracion = 2


	SELECT * 
	INTO #FamiliasAlambre
	FROM [OPESch].[OpeSplitString](@sFamiliasAlambre,',',0)


	CREATE TABLE #tmpTonsProdPOR
	(
		PRODCODU VARCHAR(100)
		,PRODCODU2 INT
		,DESCRIP  VARCHAR(500)
		,AREAID INT
		,AREA VARCHAR(500)
		,CONNUMU VARCHAR(200)
		,PRODQTY NUMERIC(22,8)
		,FURMAT  NUMERIC(22,8)
		,FURLAB  NUMERIC(22,8)
		,FUROH   NUMERIC(22,8)
		,FURPACK NUMERIC(22,8)
		,FURCOM  NUMERIC(22,8)
		,FURGNA  NUMERIC(22,8)
		,FURINT  NUMERIC(22,8)
		,TOTFGM  NUMERIC(22,8)
	)

	CREATE TABLE #tmpAnios(
		Anio		INT
	)

	CREATE TABLE #PackingCost(
		ClaArticulo INT 
		,ClaAnioMes INT
		,ProdTonsSUM NUMERIC (22,8)
		,ProdKGsSUM NUMERIC (22,8)
		,CostoPacking NUMERIC (22,8)
	)

	INSERT INTO #PackingCost
	SELECT
		--SUM(ProdTonsArticuloBase*1000) AS 'ProdKGsSUM', SUM(Importe) AS 'CostoPacking',SUM(Importe)/SUM(ProdTonsArticuloBase*1000) AS REPACK  
		ClaArticulo, ClaAnioMes, ProdTonsArticuloBase as 'ProdTonsSUM', ProdTonsArticuloBase*1000 as 'ProdKGsSUM', SUM(Importe) as 'CostoPacking'
	FROM [OPESch].[OPETraFurmanCostoEmbalaje]
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND ClaAnioMes >= @pnAnioMesInicio))
	AND (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND ClaAnioMes <= @pnAnioMesFin))
	AND ClaArticulo NOT IN(259087)
	GROUP BY ClaArticulo, ClaAnioMes, ProdTonsArticuloBase

	SELECT @nREPACKU = SUM(CostoPacking)/SUM(ProdKGsSUM)
	FROM #PackingCost

	SELECT
		@AnioInicial = LEFT(@pnAnioMesInicio,4),
		@AnioFinal	 = LEFT(@pnAnioMesFin,4)

	WHILE	@AnioInicial <= @AnioFinal
	BEGIN
		INSERT INTO #tmpAnios (Anio) VALUES (@AnioInicial)
		SET @AnioInicial = @AnioInicial + 1
	END

	SELECT  
		@AnioSinConfig = CAST(STUFF((SELECT ', ' + CONVERT(VARCHAR(4),tmp.Anio)
	FROM #tmpAnios tmp
	WHERE tmp.Anio NOT IN (
		SELECT 
			Anio
		FROM [OPESch].[OPECfgFurmanVariables] con WITH(NOLOCK)
	)FOR XML PATH('')) ,1,1,'') AS VARCHAR(MAX))

	IF @AnioSinConfig IS NOT NULL
		BEGIN		
		--SELECT @sMensaje =  'Missing settings for following years: ' + @AnioSinConfig
					
		--RAISERROR(@sMensaje , 16, 1 )
		--RETURN

		SET @sMensaje = 'Missing settings for following years: ' + @AnioSinConfig
		SET @nEsError = 1
		--RAISERROR(@sMensaje , 16, 1 )
	END

	SET @FechaCompletaIni = CAST(@pnAnioMesInicio/100 AS VARCHAR) + '-' + CAST(@pnAnioMesInicio%100 AS VARCHAR) + '-1'

	SET @FechaCompletaFin = CAST(@pnAnioMesFin/100 AS VARCHAR) + '-' + CAST(@pnAnioMesFin%100 AS VARCHAR) + '-1'
	SET	@FechaCompletaFin = DATEADD(dd,-1,DATEADD(mm,1,@FechaCompletaFin))

	
	INSERT INTO #tmpTonsProdPOR (PRODCODU, PRODCODU2, DESCRIP, AREAID, AREA, CONNUMU, PRODQTY,FURMAT,FURLAB,FUROH,FURPACK,FURCOM,FURGNA,FURINT,TOTFGM)
	--(PRODCODU,DESCRIP,CONNUMU,PRODQTY,FURMAT,FURLAB,FUROH,FURPACK,FURCOM,FURGNA,FURINT,TOTFGM)				
	EXEC [OpeSch].[OpeCalcularReporteFurmanPorPeriodo] @pnAnioMesInicio = @pnAnioMesInicio
													  ,@pnAnioMesFin = @pnAnioMesFin													  
		
	SELECT 
		PRODCODU = PRODCODU2
		,TOTFGM  = TOTFGM 
	INTO #tmpFURMAN
	FROM #tmpTonsProdPOR
	
	IF @pnEsDebug = 1
	BEGIN
		SELECT PRODCODU,TOTFGM FROM #tmpFURMAN
	END

	SELECT
		PRODCODU = VtFcD.ClaArticulo 
		,PRODDESCU = Cat.NomArticulo 
		,WireRodCONNUMU = NULL 
		,WireRodClaArticulo = NULL 
		,WireCONNUMU = ISNULL(connumWire.ConnumConGuiones, NULL) 
		,WireClaArticulo = ISNULL(connumWire.ClaArticuloComp, NULL) 
		,CUSCODU = Cl.ClaCliente 
		,CUSTNAMEU = Cl.NombreCliente 
		,SALINDTU = VtFc.FechaFactura 
		,INVOICEU = VtFc.IdFactura 
		,ImporteFactura = VtFc.ImpFactura 
		,ImporteSubTotal = Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) 
		,TipoCambio = VtFc.TipoCambio 
		,SHIPDATU = E.FechaEntSal 
		,PAYDATEU = ISNULL(Car.FechaUltimoPago, CarH.FechaUltimoPago) 
		,QTYU = Edt.PesoEmbarcado 
		,QTY_AS_SOLDU = Edt.CantEmbarcada 
		,QTYUNIT_AS_SOLDU = ISNULL(CatUV.NombreUnidadEdi, CatUV.NombreUnidadVenta) 
		,GRSUPRU = (ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) *Edt.CantEmbarcada) / Edt.PesoEmbarcado  
		,GRSUPR_AS_SOLDU = ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) 
		,BILLADJU = 0 
		,EARLPYU = 0 
		,OTHDISU = 0 
		,REBATEU = 0 		
		,DINLFTWU_MX = InFht.DINLFTWU_MX
		,DINLFTWU_USD = InFht.DINLFTWU_MX / NULLIF(ExRt.ParidadMonedaPeso,0)
		,DWAREHU_MX = InFht.DWAREHU_MX
		,DWAREHU_USD = InFht.DWAREHU_MX / NULLIF(ExRt.ParidadMonedaPeso,0)
		,DINLFTPU_MXN = InFht.DINLFTPU_MXN
		,DINLFTPU_USD = InFht.DINLFTPU_MXN / NULLIF(ExRt.ParidadMonedaPeso,0)
		,DBROKU_MX = InFht.DBROKU_MX
		,DBROKU_USD = InFht.DBROKU_MX / NULLIF(ExRt.ParidadMonedaPeso,0)
		,USBROKU = InFht.USBROKU
		,INLFPWCU_L = InFht.INLFPWCU_L
		,USWAREHU_L = InFht.USWAREHU_L
		,INLFCU = ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Tab.ImportePagarFinal,0))/Edt.PesoEmbarcado,0)
		,INLFPW_P = 0
		,USWAREHU_P = 0
		,DESTU = Cl.ZonaPostal
		,STATEU = LTRIM(REPLACE(Cd.NombreEstado,',',''))
		,COMM1U = ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionAgenteVenta,0))/Edt.PesoEmbarcado,0)
		,COMM2U = ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionManagerVenta ,0))/Edt.PesoEmbarcado,0)
		,COMM3U = ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionVPVenta ,0))/Edt.PesoEmbarcado,0)
		,COMM4U = ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionAgIndVenta ,0))/Edt.PesoEmbarcado,0)
		,SELAGENU = SRep.NombreAgente
		,CREDITU = 0
		,REPACKU = @nREPACKU
		,INDIRECTS = ((ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) *Edt.CantEmbarcada) / Edt.PesoEmbarcado) * (CONVERT(numeric,Val.PorcGastoVentaIndirecta)/100)
		,FURMANU = ISNULL(FUR.TOTFGM,0)
		,USP = 0
		,PorcInteres = Val.PorcInteres
	INTO #tmpInfoVtas
	FROM OPERACION.OPESCH.OpeTraMovEntSal                E      WITH(NOLOCK)
	INNER JOIN OPERACION.OPESCH.[OPETraMovEntSalDet]     Edt    WITH(NOLOCK)  ON E.ClaUbicacion = Edt.ClaUbicacion AND E.IdMovEntSal = Edt.IdMovEntSal AND E.IdFabricacion = Edt.IdFabricacion	
	LEFT JOIN  #tmpFURMAN                                FUR    WITH(NOLOCK)  ON Edt.ClaArticulo = FUR.PRODCODU
	INNER JOIN [OPESch].[OpeTraFacturaVw]                VtFc   WITH(NOLOCK)  ON VtFc.IdFactura = E.IdFactura AND VtFc.IdViaje = E.IdViaje
	INNER JOIN [OPESch].[OpeTraFacturaDetVw]             VtFcD  WITH(NOLOCK)  ON VtFcD.IdFactura = VtFc.IdFactura AND VtFcD.NumRenglonFab = Edt.IdFabricacionDet AND VtFcD.ClaArticulo = Edt.ClaArticulo 	
	LEFT JOIN  [OPESch].[OPECfgFurmanVariables]	         Val    WITH(NOLOCK)  ON Val.Anio = YEAR(VtFc.FechaFactura)
	INNER JOIN TiCatalogo.[dbo].[ArtCatArticulo]         Cat    WITH(NOLOCK)  ON Cat.ClaArticulo = Edt.ClaArticulo AND Cat.ClaTipoInventario = 1
	LEFT JOIN  OPESch.OPECarTraCargo                     Car    WITH(NOLOCK)  ON Car.IdCargo = VtFc.IdFactura
	LEFT JOIN  OPESch.OPECarHisCargo                     CarH   WITH(NOLOCK)  ON CarH.IdCargo = VtFc.IdFactura
	INNER JOIN OpeSch.OpeVtaCatClienteVw                 Cl     WITH(NOLOCK)  ON Cl.ClaCliente = VtFc.ClaClienteCuenta 
	INNER JOIN TiCatalogo.[dbo].[VtaCatCiudad]           Cd     WITH(NOLOCK)  ON Cl.ClaCiudad = Cd.ClaCiudad AND Cd.ClaPais = 2
	INNER JOIN [OpcSch].[OpcOpeTraViajeVw]               Via    WITH(NOLOCK)  ON E.IdViaje = Via.IdViaje
	INNER JOIN [FleSch].[FleTraTabularVw]                Tab    WITH (NOLOCK) ON Via.IdNumTabular = Tab.IdTabular
	INNER JOIN [FleSch].[FleVtaCfgArticuloFacturaVw]     CfgVta WITH(NOLOCK)  ON CfgVta.ClaArticulo = VtFcD.ClaArticulo AND CfgVta.ClaPais = 2
	INNER JOIN [FleSch].[FleVtaCatUnidadVentaVw]         CatUV  WITH(NOLOCK)  ON CfgVta.ClaUnidadVenta = CatUV.ClaUnidadVenta
	INNER JOIN TiCatalogo.[dbo].[VtaCatAgenteVw]         SRep   WITH(NOLOCK)  ON SRep.ClaAgente = VtFc.ClaAgente
	--LEFT JOIN OpeSch.OPECfgFurmanInlandFreightValoresUsar InFht WITH(NOLOCK) ON InFht.Anio=YEAR(VtFc.FechaFactura)
	LEFT JOIN [OPESch].[OPECfgFurmanInlandFreightRates] InFht WITH(NOLOCK) ON InFht.Anio=YEAR(VtFc.FechaFactura)
	OUTER APPLY(
		SELECT 
			TOP 1 Are.ConnumConGuiones, Cmp.ClaArticuloComp
		FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
		INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Are.ClaArticulo = Cmp.ClaArticuloComp
		WHERE Cmp.ClaArticulo = Edt.ClaArticulo
		ORDER BY Cmp.PorcComposicion DESC
	) as connumWire
	OUTER APPLY (
		SELECT 
			ParidadMonedaPeso
		FROm
		OpeSch.OpeAreCatParidadVw P
		WHERE CAST(P.FechaParidad AS DATE) = CAST(VtFc.FechaFactura AS DATE)
	) ExRt
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(VtFc.FechaFactura)*100+MONTH(VtFc.FechaFactura) >= @pnAnioMesInicio))
		AND (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(VtFc.FechaFactura)*100+MONTH(VtFc.FechaFactura) <= @pnAnioMesFin))
		AND E.ClaMotivoEntrada = 1 AND Cat.ClaArticulo NOT IN(259087)
	--AND VtFc.IdFactura = 168007221
	--AND VtFcD.ClaArticulo = 522801
	--ORDER BY VtFcD.ClaArticulo, VtFc.FechaFactura
	

	/*  
		Vamos por todos los creditos que se le han emitido a la factura. [OPECarHisCredito] es una replica (Sincroniza) de CARTERA.
		
		"ClaMovCredito"

		Ajuste en precio: (Bonificacion):
			65 - AJUSTE EN PRECIO

		Descuentos por pronto pago:    
			61 - PP AUTOMATICO
			62 - PP MANUAL
			67 - COD AUTORIZADO
			101-COD IMPROCEDENTE

		Rebates:
			118-REBATE

		Otro Descuentos
			Descuentos confidenciales:        63 - DESCTOS. CONF. AUTOMATICOS
			64- DESCTOS. CONF. MANUALES
			163-DESCTOS. CONF. AUTOMATICOS.
			263-DICE DEBE DECIR.
			Descuentos por ajuste*:             66-AJUSTE EN DESCUENTO
			102-DESCUENTOS EXCEDIDOS
			110-DESCTO COEXPORTACION			 
	*/ 
	--SELECT NULL/1
	--SELECT NULL * 1
	--SELECT 1/NULL
	--UPDATE 
	--	t1
	--SET		
	--	t1.INLFWCU = ISNULL(((t1.ImporteSubTotal /t1.ImporteFactura)*t1.Impor) / t1.QTYU,0)
	--FROM #tmpInfoVtas t1	
	
	--INLFWCU

	UPDATE 
		t1
	SET		
		t1.BILLADJU = ISNULL(((t1.ImporteSubTotal /t1.ImporteFactura)*t2.SumImpCreditoMonCargo) / t1.QTYU,0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito = 65 AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2		

	UPDATE t1
	SET
		t1.EARLPYU = ISNULL(((t1.ImporteSubTotal /t1.ImporteFactura)*t2.SumImpCreditoMonCargo) / t1.QTYU,0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito IN (61,62,67, 101) AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2

	UPDATE t1
	SET
		t1.OTHDISU = ISNULL(((t1.ImporteSubTotal /t1.ImporteFactura)*t2.SumImpCreditoMonCargo) / t1.QTYU,0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito IN (64,66,102,110,163,263) AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2	

	UPDATE t1
	SET
		t1.REBATEU = ISNULL(((t1.ImporteSubTotal /t1.ImporteFactura)*t2.SumImpCreditoMonCargo) / t1.QTYU,0)
	FROM #tmpInfoVtas t1	
	OUTER APPLY (
		SELECT SUM(Cred.ImpCreditoMonCargo) as SumImpCreditoMonCargo
		FROM [OPESch].[OPECarHisCredito] Cred
		WHERE Cred.ClaMovCredito IN (118) AND IdCargo = t1.INVOICEU
		GROUP BY Cred.IdCargo
	) t2

	--CALCULOS COMPLEMENTARIOS
	UPDATE #tmpInfoVtas
	SET 
		CREDITU = ((CONVERT(NUMERIC,DATEDIFF(day, ISNULL(SHIPDATU,0), ISNULL(PAYDATEU,0)))/365) * (GRSUPRU + BILLADJU - EARLPYU - OTHDISU - REBATEU)) * (Convert(NUMERIC,PorcInteres)/100.00)

	UPDATE t1	
		SET t1.USP = ISNULL(t1.GRSUPRU,0) + ISNULL(t1.BILLADJU,0) - ISNULL(t1.EARLPYU,0) - ISNULL(t1.OTHDISU,0) - ISNULL(t1.REBATEU,0) - ((ISNULL(t1.DINLFTWU_USD,0) + ISNULL(t1.DWAREHU_USD,0) + ISNULL(t1.DINLFTPU_USD,0) + ISNULL(t1.DBROKU_USD,0)) * TipoCambio) - ISNULL(t1.USBROKU,0) - ISNULL(t1.INLFPWCU_L,0) - ISNULL(t1.USWAREHU_L,0) - ISNULL(t1.INLFCU,0) - ISNULL(t1.COMM1U,0) - ISNULL(t1.COMM2U,0) - ISNULL(t1.COMM3U,0) - ISNULL(t1.COMM4U,0) - ISNULL(t1.CREDITU,0) - ISNULL(t1.REPACKU,0) - ISNULL(t1.INDIRECTS,0) - ISNULL(t1.FURMANU,0)
	FROM #tmpInfoVtas t1


	IF @pnEsDebug = 1
	BEGIN
		SELECT * FROM #tmpInfoVtas
	END


		SELECT 
			PRODCODU
			,PRODDESCU
			,WireRodCONNUMU
			,WireCONNUMU
			,CUSCODU
			,CUSTNAMEU
			,SALINDTU
			,INVOICEU
			,SHIPDATU
			,PAYDATEU
			,QTYU
			,QTY_AS_SOLDU
			,QTYUNIT_AS_SOLDU
			,GRSUPRU
			,GRSUPR_AS_SOLDU
			,BILLADJU
			,EARLPYU
			,OTHDISU
			,REBATEU
			,DINLFTWU_MX
			,DINLFTWU_USD
			,DWAREHU_MX
			,DWAREHU_USD
			,DINLFTPU_MXN
			,DINLFTPU_USD
			,DBROKU_MX
			,DBROKU_USD
			,USBROKU
			,INLFPWCU_L
			,USWAREHU_L
			,INLFCU
			,INLFPW_P
			,USWAREHU_P
			,DESTU
			,STATEU
			,COMM1U
			,COMM2U
			,COMM3U
			,COMM4U
			,SELAGENU
			,CREDITU
			,REPACKU
			,INDIRECTS
			,FURMANU
			,USP
		FROM #tmpInfoVtas vtas
	
		DROP TABLE #tmpInfoVtas
		DROP TABLE #tmpTonsProdPOR
		DROP TABLE #tmpFURMAN
		DROP TABLE #FamiliasAlambre
		DROP TABLE #PackingCost
END