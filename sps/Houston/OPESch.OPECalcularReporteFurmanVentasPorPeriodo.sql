USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OPECalcularReporteFurmanVentasPorPeriodo]    Script Date: 4/3/2024 5:54:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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
		@pnDpto         INT = NULL,
		@AnioSinConfig	VARCHAR(MAX),
		@nDINLFTWU		NUMERIC(22,8),
		@nDWAREHU       NUMERIC(22,8),
		@nDINLFTPU_MXN	NUMERIC(22,8),
		@nDINLFTPU_USD	NUMERIC(22,8),
		@nDBROKU        NUMERIC(22,8),
		@nINLFPWCU		NUMERIC(22,8),
		@nREPACKU		NUMERIC(22,8),
		@nUSBROKU		NUMERIC(22,8),
		@nUSWAREHU		NUMERIC(22,8),
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

	CREATE TABLE #tmpFURMAN	(
		PRODCODU    INT
		,TOTFGM		NUMERIC(22,8)
	)

	CREATE TABLE #tmpInfoVtas(
		 PRODCODU           INT
		,PRODDESCU          VARCHAR(2000)
		,WireRodCONNUMU     VARCHAR(200)
		,WireRodClaArticulo INT
		,WireCONNUMU        VARCHAR(200)
		,WireClaArticulo    INT
		,CUSCODU            INT
		,CUSTNAMEU          VARCHAR(2000)    
		,SALINDTU           DATETIME
		,INVOICEU           INT
		,ImporteFactura     FLOAT
		,ImporteSubTotal    FLOAT
		,TipoCambio			NUMERIC(22,4)
		,SHIPDATU           DATETIME
		,PAYDATEU           DATETIME
		,QTYU               NUMERIC(22,8)
		,QTY_AS_SOLDU       NUMERIC(22,8)
		,QTYUNIT_AS_SOLDU   VARCHAR(100)
		,GRSUPRU            FLOAT
		,GRSUPR_AS_SOLDU    FLOAT
		,BILLADJU			NUMERIC(22,8)
		,EARLPYU			NUMERIC(22,8)
		,OTHDISU			NUMERIC(22,8)
		,REBATEU			NUMERIC(22,8)
		,DINLFTWU			NUMERIC(22,8)
		,DWAREHU			NUMERIC(22,8) -- ?
		,DINLFTPU_MXN		NUMERIC(22,8)
		,DINLFTPU_USD		NUMERIC(22,8)
		,DBROKU				NUMERIC(22,8) -- ?
		,USBROKU			NUMERIC(22,8)
		,INLFPWCU			NUMERIC(22,8)
		,USWAREHU           NUMERIC(22,8)
		,INLFWCU            NUMERIC(22,8)
		,DESTU              VARCHAR(50)
		,STATEU             VARCHAR(200)
		,COMM1U				NUMERIC(22,8)
		,COMM2U				NUMERIC(22,8)
		,COMM3U				NUMERIC(22,8)
		,COMM4U				NUMERIC(22,8)
		,SELAGENU           VARCHAR(300)
		,CREDITU		    NUMERIC(22,8)
		,REPACKU		    NUMERIC(22,8)
		,INDIRECTS			NUMERIC(22,8)		
		,FURMANU            NUMERIC(22,8)
		,USP                NUMERIC(22,8)
		,PorcInteres        NUMERIC(22,8)
	)


	CREATE TABLE #tmpCostosFletes(
			IdEstudio				INT
			,IdBdVenta				INT
			,ClaCliente				INT
			,ClaUbicacionUSA        INT
			,NombreUbicacion        VARCHAR(300)
			,ClaClienteUnico		INT
			,IdFacturaOriginal		INT
			,NumFacturaOriginal		VARCHAR(30)
			,ClaArticulo			INT
			,ClaveArticulo			VARCHAR(20)
			,DINLFTWU				NUMERIC(22,8)
			,DWAREHU				NUMERIC(22,8)
			,DINLFTPU_MXN			NUMERIC(22,8)
			,DINLFTPU_USD			NUMERIC(22,8)
			,INLFPWCU				NUMERIC(22,8)
			,DBROKU                 NUMERIC(22,8)
			,USBROKU				NUMERIC(22,8)
			,USWAREHU				NUMERIC(22,8)
			,TheoricalNetQuantityKg	NUMERIC(22,8)	
	)

	CREATE TABLE #tmpCostosFletesProc(
		 IdEstudio				INT
		,IdBdVenta				INT
		,ClaCliente				INT
		,ClaClienteUnico		INT
		,IdFacturaOriginal		INT
		,NumFacturaOriginal		VARCHAR(30)
		,ClaArticulo			INT
		,ClaveArticulo			VARCHAR(20)
		,DINLFTWU				NUMERIC(22,8)
		,DWAREHU				NUMERIC(22,8)
		,DINLFTPU_MXN			NUMERIC(22,8)
		,DINLFTPU_USD			NUMERIC(22,8)
		,INLFPWCU				NUMERIC(22,8)
		,DBROKU                 NUMERIC(22,8)
		,USBROKU				NUMERIC(22,8)
		,USWAREHU				NUMERIC(22,8)
		,ClaArticuloMid			INT
		,ClaCategoria			INT
		,TheoricalNetQuantityKg	NUMERIC(22,8)
	)

	CREATE TABLE #tmpCostosFletesSUM(
		 ClaArticulo			INT
		,ClaArticuloMid			INT
		,ClaCategoria			INT
		,IdFacturaOriginal		INT
		,NumFacturaOriginal		VARCHAR(30)
		,DINLFTWU				NUMERIC(22,8)
		,DWAREHU				NUMERIC(22,8)
		,DINLFTPU_MXN			NUMERIC(22,8)
		,DINLFTPU_USD			NUMERIC(22,8)
		,INLFPWCU				NUMERIC(22,8)
		,DBROKU                 NUMERIC(22,8)
		,USBROKU				NUMERIC(22,8)
		,USWAREHU				NUMERIC(22,8)
		,TheoricalNetQuantityKg	NUMERIC(22,8)
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
		GOTO FIN
	END

	SET @FechaCompletaIni = CAST(@pnAnioMesInicio/100 AS VARCHAR) + '-' + CAST(@pnAnioMesInicio%100 AS VARCHAR) + '-1'

	SET @FechaCompletaFin = CAST(@pnAnioMesFin/100 AS VARCHAR) + '-' + CAST(@pnAnioMesFin%100 AS VARCHAR) + '-1'
	SET	@FechaCompletaFin = DATEADD(dd,-1,DATEADD(mm,1,@FechaCompletaFin))

	/*
	SERVICO SIN VALORES, CALCULANDO VALORES POR CONFIG PROXY ENTREGADO POR NEGO ISABEL PARAZ de COMMERCIO EXTERIOR
	
	INSERT INTO #tmpCostosFletes (IdEstudio,IdBdVenta,ClaCliente, ClaUbicacionUSA, NombreUbicacion, ClaClienteUnico,IdFacturaOriginal,NumFacturaOriginal,ClaArticulo,ClaveArticulo,DINLFTWU,DWAREHU,DINLFTPU_MXN,DINLFTPU_USD,INLFPWCU,DBROKU,USBROKU,USWAREHU,TheoricalNetQuantityKg)
	EXEC LNK_ARE.Operacion.ARESch.AreCostosFletesForFurman_Srv 
		 @pdFechaInicial = @FechaCompletaIni
		,@pdFechaFinal = @FechaCompletaFin
		,@pnClaClienteUnico = 12579
	
	IF @pnEsDebug = 1
	BEGIN 
		SELECT '#tmpCostosFletes',* FROM #tmpCostosFletes
	END

	INSERT INTO #tmpCostosFletesProc (IdEstudio,IdBdVenta,ClaCliente,ClaClienteUnico,IdFacturaOriginal,NumFacturaOriginal,ClaArticulo,ClaveArticulo,DINLFTWU,DWAREHU,DINLFTPU_MXN,DINLFTPU_USD,INLFPWCU,DBROKU,USBROKU,USWAREHU,ClaArticuloMid,ClaCategoria,TheoricalNetQuantityKg)
	SELECT 
		DISTINCT
			tmp.IdEstudio,
			tmp.IdBdVenta,
			tmp.ClaCliente,
			tmp.ClaClienteUnico,
			tmp.IdFacturaOriginal,
			tmp.NumFacturaOriginal,
			tmp.ClaArticulo,
			tmp.ClaveArticulo,
			tmp.DINLFTWU,
			tmp.DWAREHU,
			tmp.DINLFTPU_MXN,
			tmp.DINLFTPU_USD,
			tmp.INLFPWCU,
			tmp.DBROKU,
			tmp.USBROKU,
			tmp.USWAREHU,
			art.ClaArticulo,
			art.ClaFamilia,
			tmp.TheoricalNetQuantityKg
	FROM #tmpCostosFletes tmp
	INNER JOIN TiCatalogo.[dbo].[ArtCatArticulo] art	 WITH(NOLOCK)	ON  art.ClaArticulo = tmp.ClaArticulo
	INNER JOIN TiCatalogo.[dbo].[ArtCatFamilia] artF WITH(NOLOCK) ON art.ClaFamilia = artF.ClaFamilia
	WHERE art.ClaFamilia in (SELECT f.Item FROM #FamiliasAlambre AS f) AND artF.ClaTipoInventario = 1

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpCostosFletesProc',* FROM #tmpCostosFletesProc
	END

	INSERT INTO #tmpCostosFletesSUM (ClaArticulo,ClaArticuloMid,ClaCategoria,IdFacturaOriginal,NumFacturaOriginal,DINLFTWU,DWAREHU,DINLFTPU_MXN,DINLFTPU_USD,INLFPWCU,DBROKU,USBROKU,USWAREHU,TheoricalNetQuantityKg)
	SELECT 
		tmp.ClaArticulo,
		tmp.ClaArticuloMid,
		tmp.ClaCategoria,
		tmp.IdFacturaOriginal,
		tmp.NumFacturaOriginal,
		ISNULL(tmp.DINLFTWU,0)     * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS DINLFTWU,
		ISNULL(tmp.DWAREHU,0)     * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS DWAREHU,
		ISNULL(tmp.DINLFTPU_MXN,0) * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS DINLFTPU_MXN,
		ISNULL(tmp.DINLFTPU_USD,0) * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS DINLFTPU_USD,
		ISNULL(tmp.INLFPWCU,0)	   * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS INLFPWCU,
		ISNULL(tmp.DBROKU,0)	   * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS DBROKU,
		ISNULL(tmp.USBROKU,0)	   * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS USBROKU,
		ISNULL(tmp.USWAREHU,0)	   * ISNULL(tmp.TheoricalNetQuantityKg,0)	AS USWAREHU,
		tmp.TheoricalNetQuantityKg
	FROM #tmpCostosFletesProc tmp

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpCostosFletesSUM',* FROM #tmpCostosFletesSUM
	END

	SELECT
		@nDINLFTWU = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) > 0 
						THEN 
							SUM(ISNULL(fle.DINLFTWU,0))/SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) 
						ELSE 
							0	
					  END,
		@nDWAREHU = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0))  > 0 THEN SUM(ISNULL(fle.DWAREHU,0))		/ SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) ELSE 0	END,		
		@nDINLFTPU_MXN = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0))  > 0 THEN SUM(ISNULL(fle.DINLFTPU_MXN,0))	/ SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) ELSE 0	END,
		@nDINLFTPU_USD = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0))  > 0 THEN SUM(ISNULL(fle.DINLFTPU_USD,0))	/ SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) ELSE 0	END,
		@nINLFPWCU = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0))  > 0 THEN SUM(ISNULL(fle.INLFPWCU,0))		/ SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) ELSE 0	END,
		@nDBROKU = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0))  > 0 THEN SUM(ISNULL(fle.DBROKU,0))		/ SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) ELSE 0	END,
		@nUSBROKU = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0))  > 0 THEN SUM(ISNULL(fle.USBROKU,0))		/ SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) ELSE 0	END,
		@nUSWAREHU = CASE WHEN SUM(ISNULL(fle.TheoricalNetQuantityKg,0))  > 0 THEN SUM(ISNULL(fle.USWAREHU,0))		/ SUM(ISNULL(fle.TheoricalNetQuantityKg,0)) ELSE 0	END
	FROM #tmpCostosFletesSUM fle


	IF @pnEsDebug = 1
	BEGIN
		SELECT @nDINLFTWU as '@nDINLFTWU', @nDWAREHU as '@nDWAREHU',@nDINLFTPU_MXN as '@nDINLFTPU_MXN', @nDINLFTPU_USD as '@nDINLFTPU_USD', @nINLFPWCU as '@nINLFPWCU', @nDBROKU AS '@nDBROKU',@nUSBROKU as '@nUSBROKU', @nUSWAREHU as '@nUSWAREHU'
	END
	*/
	IF(@pnEsDebug=1)
	BEGIN
		PRINT 'ERROR #tmpTonsProdPOR'
	END
	INSERT INTO #tmpTonsProdPOR (PRODCODU, PRODCODU2, DESCRIP, AREAID, AREA, CONNUMU, PRODQTY,FURMAT,FURLAB,FUROH,FURPACK,FURCOM,FURGNA,FURINT,TOTFGM)
	--(PRODCODU,DESCRIP,CONNUMU,PRODQTY,FURMAT,FURLAB,FUROH,FURPACK,FURCOM,FURGNA,FURINT,TOTFGM)		
	EXEC [OpeSch].[OpeCalcularReporteFurmanPorPeriodo] @pnAnioMesInicio, @pnAnioMesFin, NULL, 1

	IF(@pnEsDebug=1)
	BEGIN
		PRINT 'ERROR DESP #tmpTonsProdPOR'
	END

	INSERT INTO #tmpFURMAN
	SELECT PRODCODU2,TOTFGM FROM #tmpTonsProdPOR
	
	IF @pnEsDebug = 1
	BEGIN
		SELECT PRODCODU,TOTFGM FROM #tmpFURMAN
	END

	CREATE TABLE #tmpProdFurmanColumnas(
		Columna    VARCHAR(100)
	)

	IF(@pnEsDebug=1)
	BEGIN
		PRINT 'ERROR ##tmpProdFurmanColumnas'
	END
	INSERT INTO #tmpProdFurmanColumnas (Columna)
	VALUES('PRODCODU')
		,('PRODDESCU')
		,('WireRodCONNUMU')
		,('WireCONNUMU')
		,('CUSCODU')
		,('CUSTNAMEU')
		,('SALINDTU')
		,('INVOICEU')
		,('SHIPDATU')
		,('PAYDATEU')
		,('QTYU')
		,('QTY_AS_SOLDU')
		,('QTYUNIT_AS_SOLDU')
		,('GRSUPRU')
		,('GRSUPR_AS_SOLDU')
		,('BILLADJU')
		,('EARLPYU')
		,('OTHDISU')
		,('REBATEU')
		,('DINLFTWU')
		,('DWAREHU')
		,('DINLFTPU_MXN')
		,('DINLFTPU_USD')
		,('DBROKU')
		,('USBROKU')
		,('INLFPWCU')
		,('USWAREHU')
		,('INLFWCU')
		,('DESTU')
		,('STATEU')
		,('COMM1U')
		,('COMM2U')
		,('COMM3U')
		,('COMM4U')
		,('SELAGENU')
		,('CREDITU')
		,('REPACKU')
		,('INDIRECTS')
		,('FURMANU')
		,('USP')
		--,('PorcInteres')
	
	IF(@pnEsDebug=1)
	BEGIN
		PRINT 'ERROR #tmpInfoVtas'
	END
		
	INSERT INTO #tmpInfoVtas
	SELECT
		VtFcD.ClaArticulo AS 'PRODCODU'
		,Cat.NomArticulo AS 'PRODDESCU'
		,NULL AS 'WireRodCONNUMU'
		,NULL AS 'WireRodClaArticulo'
		,ISNULL(connumWire.ConnumConGuiones, NULL) AS 'WireCONNUMU'
		,ISNULL(connumWire.ClaArticuloComp, NULL) AS 'WireClaArticulo'
		,Cl.ClaCliente AS 'CUSCODU'
		,Cl.NombreCliente AS 'CUSTNAMEU'
		,VtFc.FechaFactura AS 'SALINDTU'
		,VtFc.IdFactura AS 'INVOICEU'
		,VtFc.ImpFactura AS 'ImporteFactura'
		,Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) as 'ImporteSubTotal'
		,VtFc.TipoCambio AS 'TipoCambio'
		,E.FechaEntSal AS 'SHIPDATU'
		,ISNULL(Car.FechaUltimoPago, CarH.FechaUltimoPago) AS 'PAYDATEU'
		,Edt.PesoEmbarcado AS 'QTYU'
		,Edt.CantEmbarcada AS 'QTY_AS_SOLDU'
		,ISNULL(CatUV.NombreUnidadEdi, CatUV.NombreUnidadVenta) AS 'QTYUNIT_AS_SOLDU'
		--,ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) AS 'GRSUPRU'	
		,(ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) *Edt.CantEmbarcada) / Edt.PesoEmbarcado  AS 'GRSUPRU'
		,ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) AS 'GRSUPR_AS_SOLDU'
		,0 AS 'BILLADJU'
		,0 AS 'EARLPYU'
		,0 AS 'OTHDISU'
		,0 AS 'REBATEU'
		,InFht.DINLFTWU/100 AS 'DINLFTWU'
		,InFht.DWAREHU/100 AS 'DWAREHU	'
		,InFht.DINLFTPU_MXN/100 AS 'DINLFTPU_MXN'
		,InFht.DINLFTPU_USD/100 AS 'DINLFTPU_USD'
		,InFht.DBROKU/100 AS 'DBROKU'
		,InFht.USBROKU/100 AS 'USBROKU'
		,InFht.INLFPWCU/100 AS 'INLFPWCU'
		,InFht.USWAREHU/10 AS 'USWAREHU'
		,ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Tab.ImportePagarFinal,0))/Edt.PesoEmbarcado,0) AS 'INLFWCU'
		,Cl.ZonaPostal AS 'DESTU'
		,LTRIM(REPLACE(Cd.NombreEstado,',','')) AS 'STATEU' 		
		,ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionAgenteVenta,0))/Edt.PesoEmbarcado,0)  AS 'COMM1U'
		,ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionManagerVenta ,0))/Edt.PesoEmbarcado,0) AS 'COMM2U'
		,ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionVPVenta ,0))/Edt.PesoEmbarcado,0) AS 'COMM3U'
		,ISNULL(((Edt.CantEmbarcada * ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase)/VtFc.ImpFactura) * ISNULL(Val.ComisionAgIndVenta ,0))/Edt.PesoEmbarcado,0) AS 'COMM4U'
		,SRep.NombreAgente AS 'SELAGENU'
		,0 AS 'CREDITU' 		
		,@nREPACKU AS 'REPACKU'
		,((ISNULL(VtFcD.PrecioUnitarioFactura, VtFcD.PrecioVentaBase) *Edt.CantEmbarcada) / Edt.PesoEmbarcado) * (CONVERT(numeric,Val.PorcGastoVentaIndirecta)/100) as 'INDIRECTS'	
		,ISNULL(FUR.TOTFGM,0) AS 'FURMAN'
		,0 AS 'USP'
		,Val.PorcInteres as 'PorcInteres'
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
	LEFT JOIN OpeSch.OPECfgFurmanInlandFreightValoresUsar InFht WITH(NOLOCK) ON InFht.Anio=YEAR(VtFc.FechaFactura)
	OUTER APPLY(
		SELECT 
			TOP 1 Are.ConnumConGuiones, Cmp.ClaArticuloComp
		FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
		INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Are.ClaArticulo = Cmp.ClaArticuloComp
		WHERE Cmp.ClaArticulo = Edt.ClaArticulo
		ORDER BY Cmp.PorcComposicion DESC
	) as connumWire
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
		SET t1.USP = ISNULL(t1.GRSUPRU,0) + ISNULL(t1.BILLADJU,0) - ISNULL(t1.EARLPYU,0) - ISNULL(t1.OTHDISU,0) - ISNULL(t1.REBATEU,0) - ((ISNULL(t1.DINLFTWU,0) + ISNULL(t1.DWAREHU,0) + ISNULL(t1.DINLFTPU_MXN,0) + ISNULL(t1.DBROKU,0)) * TipoCambio) - ISNULL(t1.USBROKU,0) - ISNULL(t1.INLFPWCU,0) - ISNULL(t1.USWAREHU,0) - ISNULL(t1.INLFWCU,0) - ISNULL(t1.COMM1U,0) - ISNULL(t1.COMM2U,0) - ISNULL(t1.COMM3U,0) - ISNULL(t1.COMM4U,0) - ISNULL(t1.CREDITU,0) - ISNULL(t1.REPACKU,0) - ISNULL(t1.INDIRECTS,0) - ISNULL(t1.FURMANU,0)
	FROM #tmpInfoVtas t1


	IF @pnEsDebug = 1
	BEGIN
		SELECT * FROM #tmpInfoVtas
	END
	SET @nEsError = 0

	FIN:		
		SELECT @sMensaje as Mensaje, @nEsError as EsError
		--SELECT * FROM #tmpProdFurmanColumnas
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
			,DINLFTWU
			,DWAREHU
			,DINLFTPU_MXN
			,DINLFTPU_USD
			,DBROKU
			,USBROKU
			,INLFPWCU
			,USWAREHU
			,INLFWCU
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
		DROP TABLE #tmpCostosFletes
		DROP TABLE #tmpCostosFletesProc
		DROP TABLE #tmpCostosFletesSUM
		DROP TABLE #tmpTonsProdPOR
		DROP TABLE #tmpFURMAN
		DROP TABLE #FamiliasAlambre
		DROP TABLE #PackingCost
END