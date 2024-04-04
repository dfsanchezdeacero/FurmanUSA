USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeCalcularReporteFurmanPorPeriodo]    Script Date: 4/1/2024 3:35:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [OPESch].[OpeCalcularReporteFurmanPorPeriodo]
	 @pnAnioMesInicio		INT
	,@pnAnioMesFin			INT
	,@pnDpto                INT = NULL
	,@EsCalculaFURCOM       INT = 0
	,@pnClaUbicacion		INT = 65
	,@pnEsDebug             INT = 0	
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE 
		@sMensaje               VARCHAR(250)
		,@nFURGNA               NUMERIC(22,8)
		,@nFURINT               NUMERIC(22,8)
		,@nEsError              INT
		,@nFactorConv			NUMERIC(22,2) = 1000.00

	CREATE TABLE #tmpProdFurmanColumnas(
		Columna    VARCHAR(100)
	)

	--CREATE TABLE #tmpTonsTotAnioMesXCrc
	--(
	--	[ClaAnioMes]           INT
	--	,[ClaArticulo]	        INT
	--	,[NomArticulo]	        VARCHAR(200)
	--	,ClaElementoCosto       INT
	--	,[ProdTonsArticuloBase]	NUMERIC(22,8)
	--)

	CREATE TABLE #tmpTonsTotAnioMes
	(
		[ClaAnioMes]           INT
		,[ClaArticulo]	        INT
		--,[NomArticulo]	        VARCHAR(1000)
		,[ProdTonsArticuloBase]	NUMERIC(22,8)
	)

	
	CREATE TABLE #tmpTonsProdPOR
	(
		[ClaArticulo]	        INT
		--,[NomArticulo]	        VARCHAR(1000)
		,[ProdTonsArticuloBase]	NUMERIC(22,8)
	)


	--Filtramos la produccion del POR	 
	SELECT
		[IdFurmanProduccion]   
		,[ClaAnioMes]          
		,[ClaUbicacion]        
		,[ClaArticulo]	       
		--,[NomArticulo]	       
		,[ClaCrc]	           
		,[NomCrc]	           
		,[ClaElementoCosto]	   
		,[NomElementoCosto]    
		,[Importe]	           
		,[ProdTonsArticuloBase]
		,[CostoXTonelada]	   
		,[PorcComp]            
	INTO #tmpProdFurman
	FROM [OPESch].[OPETraFurmanProduccion] P WITH(NOLOCK)
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND P.ClaAnioMes >= @pnAnioMesInicio))
	AND  (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  P.ClaAnioMes <= @pnAnioMesFin))	
	AND P.ClaUbicacion = @pnClaUbicacion 
	AND  (@pnDpto IS NULL OR (@pnDpto IS NOT NULL AND P.ClaCrc = @pnDpto))	
	
	SELECT
		[IdFurmanProduccionFURPACK]   
		,[ClaAnioMes]          
		,[ClaUbicacion]        
		,[ClaArticulo]	       
		--,[NomArticulo]	       
		,[ClaCrc]	           
		,[NomCrc]	           
		,[ClaElementoCosto]	   
		,[NomElementoCosto]    
		,[Importe]	           
		,[ProdTonsArticuloBase]
		,[CostoXTonelada]	   
		,[PorcComp]            
	INTO #tmpProdFurmanPACK
	FROM [OPESch].[OPETraFurmanProduccionFURPACK] P WITH(NOLOCK)
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND P.ClaAnioMes >= @pnAnioMesInicio))
	AND  (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND  P.ClaAnioMes <= @pnAnioMesFin))	
	AND P.ClaUbicacion = @pnClaUbicacion 
	AND  (@pnDpto IS NULL OR (@pnDpto IS NOT NULL AND P.ClaCrc = @pnDpto))	

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpProdFurman',* FROM #tmpProdFurman WHERE ClaArticulo = 501815

		SELECT '#tmpProdFurmanPACK',* FROM #tmpProdFurmanPACK WHERE ClaArticulo = 501815
		--WHERE ClaArticulo = 522803 AND ClaElementoCosto = 1
	END

	-- Agrupamos la produccion para obtener el numero de toneladas trabajadas por AnioMes, por Articulo y por Elemento de Costo para Obtener.
	-- El objetivo es obtener de cada bloque de 
	--INSERT INTO #tmpTonsTotAnioMesXCrc
	--SELECT tmpP.ClaAnioMes, tmpP.ClaArticulo, tmpP.NomArticulo, tmpP.ClaElementoCosto, tmpP.ProdTonsArticuloBase
	--FROM #tmpProdFurman tmpP
	----WHERE tmpP.ClaElementoCosto = 1
	--GROUP BY tmpP.ClaAnioMes, tmpP.ClaArticulo, tmpP.NomArticulo, tmpP.ClaElementoCosto, tmpP.ProdTonsArticuloBase

	--IF @pnEsDebug = 1
	--BEGIN
	--	SELECT '#tmpTonsTotAnioMesXCrc',* FROM #tmpTonsTotAnioMesXCrc 
	--	--WHERE ClaArticulo = 522803
	--END


	--Agrupamos la produccion del articulo durante el POR
	INSERT INTO #tmpTonsTotAnioMes
	
	SELECT ClaAnioMes, ClaArticulo/*, NomArticulo*/,ProdTonsArticuloBase
	FROM #tmpProdFurman 
	GROUP BY ClaAnioMes, ClaArticulo/*, NomArticulo*/,ProdTonsArticuloBase

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpTonsTotAnioMes',* FROM #tmpTonsTotAnioMes WHERE ClaArticulo = 501815
		--WHERE ClaArticulo = 522803
	END

	INSERT INTO #tmpTonsProdPOR
	SELECT ClaArticulo, /*NomArticulo,*/ SUM(ProdTonsArticuloBase)
	FROM #tmpTonsTotAnioMes 
	--WHERE ClaArticulo = 522803
	GROUP BY ClaArticulo /*,NomArticulo,*/--, ProdTonsArticuloBase

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpTonsProdPOR',* FROM #tmpTonsProdPOR WHERE ClaArticulo = 501815
	END


	--CREATE TABLE #tmpFURMAT(
	--	ClaArticulo  INT
	--	--,NomArticulo VARCHAR(500)
	--	,AcumProdTonsArticuloBase NUMERIC(22,8)
	--	,AcumCostoXTonelada NUMERIC(22,8)
	--	,FURMAT NUMERIC(22,8)
	--)

	--CREATE TABLE #tmpFURLAB(
	--	ClaArticulo  INT
	--	--,NomArticulo VARCHAR(500)
	--	,AcumProdTonsArticuloBase NUMERIC(22,8)
	--	,AcumCostoXTonelada NUMERIC(22,8)
	--	,FURLAB NUMERIC(22,8)
	--)
	
	--CREATE TABLE #tmpFUROH(
	--	ClaArticulo  INT
	--	,NomArticulo VARCHAR(500)
	--	,AcumProdTonsArticuloBase NUMERIC(22,8)
	--	,AcumCostoXTonelada NUMERIC(22,8)
	--	,FUROH NUMERIC(22,8)
	--)	

	--CREATE TABLE #tmpFURPACK(
	--	ClaArticulo  INT
	--	,NomArticulo VARCHAR(500)
	--	,AcumProdTonsArticuloBase NUMERIC(22,8)
	--	,AcumCostoXTonelada NUMERIC(22,8)
	--	,FURPACK NUMERIC(22,8)
	--)
	
	SELECT
		tP.ClaArticulo	
		--,tP.NomArticulo
		,SUM(Ag.ProdTonsArticuloBase) AS AcumProdTonsArticuloBase
		,SUM(ISNULL(tP.CostoXTonelada,0)) AS AcumCostoXTonelada		
		,SUM(ISNULL(tP.CostoXTonelada,0))/@nFactorConv as 'FURMAT'
	INTO #tmpFURMAT
	FROM #tmpProdFurman tP
	INNER JOIN #tmpTonsProdPOR Ag ON tP.ClaArticulo = Ag.ClaArticulo
	WHERE tP.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] 
								 WHERE IdConceptoFurman = 1 --FURMAT
							     AND ( @pnDpto IS NULL OR (@pnDpto IS NOT NULL AND ClaCrc = @pnDpto))--Crc Seleccionado
								)
	GROUP BY
			tP.ClaArticulo	
			--,tP.NomArticulo
			--,Ag.ProdTonsArticuloBase

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpFURMAT',* FROM #tmpFURMAT WHERE ClaArticulo = 501815
	END
	
	SELECT
		tP.ClaArticulo	
		--,tP.NomArticulo
		,SUM(Ag.ProdTonsArticuloBase) AS AcumProdTonsArticuloBase
		,SUM(ISNULL(tP.CostoXTonelada,0)) AS AcumCostoXTonelada		
		,SUM(ISNULL(tP.CostoXTonelada,0))/@nFactorConv as 'FURLAB'
	INTO #tmpFURLAB
	FROM #tmpProdFurman tP
	INNER JOIN #tmpTonsProdPOR Ag ON tP.ClaArticulo = Ag.ClaArticulo
	WHERE tP.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] 
								 WHERE IdConceptoFurman = 2 --FURLAB
							     AND ( @pnDpto IS NULL OR (@pnDpto IS NOT NULL AND ClaCrc = @pnDpto))--Crc Seleccionado
								)
	GROUP BY
			tP.ClaArticulo	
			--,tP.NomArticulo
			--,Ag.ProdTonsArticuloBase

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpFURLAB',* FROM #tmpFURLAB WHERE ClaArticulo = 501815
	END
	
	SELECT
		tP.ClaArticulo	
		--,tP.NomArticulo
		,SUM(Ag.ProdTonsArticuloBase) AS AcumProdTonsArticuloBase
		,SUM(ISNULL(tP.CostoXTonelada,0)) AS AcumCostoXTonelada	
		,(SUM(ISNULL(tP.CostoXTonelada,0)) - Furpack.CostoXToneladaPK )/@nFactorConv as 'FUROH'
	INTO #tmpFUROH
	FROM #tmpProdFurman tP
	INNER JOIN #tmpTonsProdPOR Ag ON tP.ClaArticulo = Ag.ClaArticulo	
	
	OUTER APPLY(
		SELECT CostoXToneladaPK = SUM(ISNULL(PK.CostoXTonelada,0))
		FROM #tmpProdFurmanPACK PK 
		WHERE tP.ClaArticulo = PK.ClaArticulo
	)Furpack
	WHERE tP.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] 
								 WHERE IdConceptoFurman = 3 --FUROH
							     AND ( @pnDpto IS NULL OR (@pnDpto IS NOT NULL AND ClaCrc = @pnDpto))--Crc Seleccionado
								)
	GROUP BY
			tP.ClaArticulo	
			--,tP.NomArticulo
			--,Ag.ProdTonsArticuloBase
			,Furpack.CostoXToneladaPK


	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpFUROH',* FROM #tmpFUROH WHERE ClaArticulo = 501815
	END
	
	SELECT 
		PK.ClaArticulo	
		--,PK.NomArticulo
		,SUM(PK.ProdTonsArticuloBase) AS AcumProdTonsArticuloBase
		,SUM(ISNULL(PK.CostoXTonelada,0)) AS AcumCostoXTonelada		
		,SUM(ISNULL(PK.CostoXTonelada,0))/@nFactorConv as 'FURPACK'
	INTO #tmpFURPACK
	FROM #tmpProdFurmanPACK PK
	--INNER JOIN #tmpTonsProdPOR Ag ON PK.ClaArticulo = Ag.ClaArticulo
	WHERE PK.ClaElementoCosto IN (SELECT ClaElementoCosto --Elemento de Costo
								 FROM [OPESch].[OPERelConceptoFurmanCrc] 
								 WHERE IdConceptoFurman = 4 --FURPACK
							     AND ( @pnDpto IS NULL OR (@pnDpto IS NOT NULL AND ClaCrc = @pnDpto))--Crc Seleccionado
								)
	GROUP BY
			PK.ClaArticulo	
			--,PK.NomArticulo
			--,PK.ProdTonsArticuloBase
			--,PK.ProdTonsArticuloBase

	IF @pnEsDebug = 1
	BEGIN
		SELECT '#tmpFURPACK',* FROM #tmpFURPACK WHERE ClaArticulo = 501815
	END

	--FURNGA
	DECLARE @pnAnioCalculoGNA INT

	SELECT @pnAnioCalculoGNA=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) 
	WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA OR AnioGNAPeriodoFurman=@pnAnioCalculoGNA-1)
	BEGIN
		

		IF EXISTS(SELECT 1 FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA)
		BEGIN
			SELECT @nFURGNA = ISNULL((FactorGNAPeriodoFurman/100.0),0) FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) WHERE AnioGNAPeriodoFurman=@pnAnioCalculoGNA
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURGNA = ISNULL((FactorGNAPeriodoFurman/100.0),0) FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) ORDER BY AnioGNAPeriodoFurman DESC
		END
		--SET @nFURGNA=1
		PRINT @nFURGNA
	END
	ELSE
	BEGIN
		RAISERROR('GNA Missing configuration, please configure a GNA value for current P.O.R',16,1)
	END

	--SELECT  TOP 1  @nFURGNA = ISNULL((FactorGNAPeriodoFurman/100.0),0)
	--FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK) 
	--ORDER BY [AnioGNAPeriodoFurman] DESC

	--FURINT
	DECLARE @pnAnioCalculoINT INT

	SELECT @pnAnioCalculoINT=SUBSTRING(CONVERT(VARCHAR,@pnAnioMesFin),1,4)

	IF EXISTS (SELECT 1 FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) 
	WHERE AnioINTPeriodoFurman=@pnAnioCalculoINT OR AnioINTPeriodoFurman=@pnAnioCalculoINT-1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) WHERE AnioINTPeriodoFurman=@pnAnioCalculoINT)
		BEGIN
			SELECT @nFURINT = ISNULL((FactorINTPeriodoFurman/100.0),0) FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) WHERE AnioINTPeriodoFurman=@pnAnioCalculoINT
		END
		ELSE
		BEGIN
			SELECT TOP 1 @nFURINT = ISNULL((FactorINTPeriodoFurman/100.0),0) FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) ORDER BY AnioINTPeriodoFurman DESC
		END
		--SET @nFURINT=1
		PRINT @nFURINT
	END
	ELSE
	BEGIN
		RAISERROR('INT Missing configuration, please configure a INT value for current P.O.R',16,1)
	END

	IF @pnEsDebug = 1
	BEGIN
		SELECT @nFURINT,@nFURGNA
	END

	--SELECT  TOP 1  @nFURINT = ISNULL((FactorINTPeriodoFurman/100.0),0)
	--FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK) 
	--ORDER BY [AnioINTPeriodoFurman] DESC


	INSERT INTO #tmpProdFurmanColumnas (Columna)
	VALUES 
	('PROD')
	,('DESC')
	--,('DESC')
	,('KGs')
	--,('FURMAT Department')
	--,('SCRAP OFFSET')
	--,('FURMANYLD Department')
	,('FURMAT')
	,('FURLAB')	
	--,('FURVOH') 
	--,('FURFOH')
	,('FUROH')  --Valor Calulado
	,('FURPACK')
	,('FURCOM') --Valor Calulado
	,('FURGNA') --valor leido
	,('FURINT') --Valor leido
	,('TOTFMG') --Valor Calulado


	--SELECT * FROM #tmpProdFurmanColumnas

	--CREATE TABLE #tmpReporteFurmanProd(
	--	PRODCODU	        VARCHAR(20)
	--	,PRODCODU2	        INT
	--	,DESCRIP            VARCHAR(200)
	--	,CONNUMU            VARCHAR(200)
	--	,PRODQTY  	        NUMERIC(22,8)
	--	,FURMAT	  	        NUMERIC(22,8)
	--	,FURLAB	  	        NUMERIC(22,8)
	--	,FUROH	  	        NUMERIC(22,8)
	--	,FURPACK			NUMERIC(22,8)
	--	,FURCOM	  	        NUMERIC(22,8)
	--	,FURGNA	  	        NUMERIC(22,8)
	--	,FURINT	  	        NUMERIC(22,8)
	--	,TOTFGM             NUMERIC(22,8)
	--)

	--INSERT INTO #tmpReporteFurmanProd
	SELECT 
		Art.ClaveArticulo                                                        AS 'PRODCODU'
		,tP.ClaArticulo                                                        AS 'PRODCODU2'		
		,Art.NomArticulo                                                       AS 'DESCRIP'
		,CRC.ClaCrc 'AREAID'
		,CRC.NomCrc										AS 'AREA'
		,ISNULL(connumWire.ConnumConGuiones,'NOT DEFINED')					AS 'CONNUMU'
		--,CASE WHEN connumWire.PorcComposicion = 0 THEN ISNULL(tP.ProdTonsArticuloBase* 1000, 0)
		--	  WHEN connumWire.PorcComposicion <> 0 THEN ISNULL(tP.ProdTonsArticuloBase* 1000, 0) * ISNULL(connumWire.PorcComposicion,0)
		--	  ELSE 0
		--END  
		,ISNULL(tP.ProdTonsArticuloBase* 1000, 0) * ISNULL(connumWire.PorcComposicion, 1.0) AS 'PRODQTY'

		,ISNULL(fmat.FURMAT,0)                                                AS 'FURMAT'
		,ISNULL(flab.FURLAB,0)                                                AS 'FURLAB'
		,ISNULL(foh.FUROH, 0)                                                 AS 'FUROH'
		,ISNULL(fpk.FURPACK,0)												  AS 'FURPACK'
		,ISNULL(fmat.FURMAT,0) + ISNULL(flab.FURLAB,0) + ISNULL(foh.FUROH, 0) + ISNULL(fpk.FURPACK,0) AS 'FURCOM'
		,ISNULL(@nFURGNA, 0)                                                  AS 'FURGNA'
		,ISNULL(@nFURINT, 0)                                                  AS 'FURINT'
		,ISNULL(fmat.FURMAT,0) + ISNULL(flab.FURLAB,0) + ISNULL(foh.FUROH, 0) + ISNULL(@nFURGNA, 0) + ISNULL(@nFURINT, 0) + ISNULL(fpk.FURPACK,0) AS 'TOTFGM'
	INTO #tmpReporteFurmanProd
	FROM #tmpTonsProdPOR tP
		LEFT JOIN #tmpFURMAT fmat ON tP.ClaArticulo = fmat.ClaArticulo
		LEFT JOIN #tmpFURLAB flab ON tP.ClaArticulo = flab.ClaArticulo
		LEFT JOIN #tmpFUROH  foh  ON tP.ClaArticulo = foh.ClaArticulo
		LEFT JOIN #tmpFURPACK fpk ON tP.ClaArticulo = fpk.ClaArticulo
		LEFT JOIN [OPESch].[ArtCatArticuloVw] Art ON tp.ClaArticulo = Art.ClaArticulo 
													AND Art.ClaTipoInventario = 1
	
	OUTER APPLY(
		SELECT 
			Are.ConnumConGuiones AS ConnumConGuiones,
			SUM (Cmp.PorcComposicion/100.0) AS PorcComposicion
		FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
		INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Are.ClaArticulo = Cmp.ClaArticuloComp
		WHERE Cmp.ClaArticulo = tP.ClaArticulo
		GROUP BY Are.ConnumConGuiones		
	) as connumWire
	CROSS APPLY(
		SELECT 
			DISTINCT ClaArticulo, ClaCrc, NomCrc
		FROM #tmpProdFurman F
		WHERE F.ClaArticulo = tP.ClaArticulo
	) CRC
	
	ORDER BY tp.ClaArticulo

	IF @pnEsDebug = 1
		SELECT '#tmpTonsProdPOR', * FROM #tmpReporteFurmanProd --WHERE PRODCODU2 = 501815
	ELSE
	BEGIN
		IF @EsCalculaFURCOM <> 0
		BEGIN
			SELECT * FROM #tmpReporteFurmanProd	
		END
		ELSE
		BEGIN
			SET @nEsError = 0
			--SELECT @sMensaje as Mensaje, @nEsError as EsError
			SELECT * FROM #tmpReporteFurmanProd			
		END
	END
		
		DROP TABLE #tmpTonsProdPOR		
		DROP TABLE #tmpFUROH
		DROP TABLE #tmpTonsTotAnioMes
		DROP TABLE #tmpFURMAT
		DROP TABLE #tmpFURLAB
		DROP TABLE #tmpProdFurman
		DROP TABLE #tmpProdFurmanColumnas
		DROP TABLE #tmpReporteFurmanProd

	SET NOCOUNT OFF
END
