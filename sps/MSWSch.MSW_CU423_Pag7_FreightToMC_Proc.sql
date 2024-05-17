--UPDATE TO [MSWSch].[MSW_CU423_Pag7_FreightToMC_Proc]	
DECLARE 
	@nClaClienteUnicoMid		INT = 11912
	,@sServerVentas				VARCHAR(50)
	,@sSql						VARCHAR(MAX)
	,@nAnioMes INT = 202301
	,@nCategoriaAlambron		INT
	,@nCategoriaAlambre			INT
	,@AnioMesMaxRegistrado INT
	,@dFechaActual DATETIME = GETDATE()
	,@nDiasExtendidosCierreMes INT = 6
	,@dFechaEjecucionDesde DATETIME
	,@dFechaEjecucionHasta DATETIME
	,@nContador             INT           = 1
	,@nNumEjecuciones       INT           = NULL		
    ,@nEsAbrirTransaccion   INT
	,@nFechaEnProceso DATETIME
	,@nAnioMesEnProceso INT
	,@sMensajeError 	    VARCHAR(2000) = NULL

	CREATE TABLE #tmpFacturaProvDet
	(
	 IdFactura				INT
	,FechaFactura			DATETIME
	,IdFacturaAlfanumerico	VARCHAR(100)
	,ImpFactura				FLOAT	
	,PlacasCamion			VARCHAR(10) 
	,ClaPedidoCliente		VARCHAR(16)
	,FechaVenceNormal		DATETIME
	,DiasVencidoFact		INT	
	,ClaUbicacion			INT
	,IdViaje				INT
	,IdFabricacion			INT	
	,KilosSurtidos			FLOAT			 
	,LibrasSurtidas			FLOAT
	,ClaArticulo			INT
	,CantidadSurtida		FLOAT
	,NomUnidadVenta			VARCHAR(10)
	,KilosSurtidosDet		FLOAT
	,ClaClienteCuentaDEA	INT
	,ClaArticuloMSW			INT
	,ClaCategoriaMSW		INT
	)


--* Configuraciones
	SELECT	@sServerVentas = sValor3
	FROM	MSWSch.MSWCatConfiguracion (NOLOCK)
	WHERE	ClaConfiguracion = 52
		
	SELECT	@nCategoriaAlambron = nValor1
	FROM	MSWSch.MSWCatConfiguracion (NOLOCK)
	WHERE	ClaConfiguracion = 100	
	
	SELECT	@nCategoriaAlambre = nValor1
	FROM	MSWSch.MSWCatConfiguracion (NOLOCK)
	WHERE	ClaConfiguracion = 104	

	SELECT @dFechaEjecucionHasta = DATEADD(DAY, -@nDiasExtendidosCierreMes, @dFechaActual)

	SELECT 
			@AnioMesMaxRegistrado = ISNULL(MAX(ClaAnioMes),202301)
	FROM [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes] WITH(NOLOCK)

	--SELECT * FROM  [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes]

	SELECT @dFechaEjecucionDesde = SUBSTRING(CAST(@AnioMesMaxRegistrado AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@AnioMesMaxRegistrado AS VARCHAR(10)), 5,6)+'-01'

	SELECT 
			dFechaEjecucionDesde = @dFechaEjecucionDesde
			,dFechaEjecucionHasta = @dFechaEjecucionHasta

	SELECT @nNumEjecuciones = DATEDIFF(Month,@dFechaEjecucionDesde, @dFechaEjecucionHasta) + 1

	SELECT nNumEjecuciones = @nNumEjecuciones
		
	SELECT 
		@nFechaEnProceso = @dFechaEjecucionDesde
		,@nAnioMesEnProceso = YEAR(@dFechaEjecucionDesde) * 100 + MONTH(@dFechaEjecucionDesde)


	WHILE (@nContador <= @nNumEjecuciones)
	BEGIN		
		SELECT @nAnioMesEnProceso = YEAR(@nFechaEnProceso)*100 + MONTH(@nFechaEnProceso)
			
		SELECT 
			Contador = @nContador
			,nAnioMesEnProceso = @nAnioMesEnProceso

			--* Obtener facturas deacero a cliente mid continent	  	  
		SELECT  @sSql = 'SELECT * FROM OPENQUERY(' + @sServerVentas + /*DEAOFINET05*/', 
						''SELECT		 f.IdFactura 
											,f.FechaFactura
											,f.IdFacturaAlfanumerico
											,f.ImpFactura															 
											, f.PlacasCamion   
											, f.ClaPedidoCliente
											, f.FechaVenceNormal
											, DiasVencidoFact = DATEDIFF(dd,f.FechaVenceNormal, GETDATE())
											, f.ClaUbicacion
											, f.IdViaje
											, f.IdFabricacion
											, f.KilosSurtidos 				 
											, LibrasSurtidas = f.kilosSurtidos * 2.2046
											, fd.ClaArticulo
											, fd.CantidadSurtida
											, NomUnidadVenta = LTRIM(RTRIM(fd.NomUnidadVenta))
											, KilosSurtidosDet = fd.KilosSurtidos
											, ClaClienteCuentaDEA = f.ClaClienteCuenta
											, ClaArticuloMSW = NULL
											, ClaCategoriaMSW = NULL
							FROM			Ventas.VtaSch.VtaTraFacturaVw f			
							INNER JOIN		Ventas.VtaSch.VtaTraFacturaDetVw fd		ON fd.IdFactura  = f.IdFactura
							INNER JOIN		Ventas.VtaSch.VtaCatClienteCuentaVw	cuc ON cuc.ClaClienteCuenta = f.ClaClienteCuenta 
							WHERE	f.ClaUbicacion IN(35, 11, 197, 345, 65)
							AND YEAR(f.FechaFactura)*100 + MONTH(f.FechaFactura) = ('+ CAST(@nAnioMesEnProceso AS VARCHAR(20)) +')
							AND cuc.ClaClienteUnico in (' +  CAST(@nClaClienteUnicoMid AS VARCHAR(20)) + ') 												
							AND f.IdViaje IS NOT NULL
							''
					)'
		INSERT INTO #tmpFacturaProvDet
		EXEC (@sSql)

		SELECT @nFechaEnProceso = DATEADD(Month, @nContador, @dFechaEjecucionDesde)
		SELECT @nContador = @nContador + 1
	END





	--Obtener articulo y categoria en mid
	UPDATE #tmpFacturaProvDet SET	 ClaArticuloMSW = art.ClaArticulo
									,ClaCategoriaMSW = art.ClaCategoria
	FROM		#tmpFacturaProvDet		fdea
	INNER JOIN	MSWSch.MSWCatArticulo	art		(NOLOCK)	ON fdea.ClaArticulo = art.ClaArticuloDea
		

	UPDATE #tmpFacturaProvDet SET	 ClaArticuloMSW = art.ClaArticulo
									,ClaCategoriaMSW = art.ClaCategoria
	FROM		#tmpFacturaProvDet		fdea
	INNER JOIN	MSWSch.MSWCatArticulo	art		(NOLOCK)	ON fdea.ClaArticulo = art.ClaArticulo
	WHERE		fdea.ClaArticuloMSW IS NULL

	SELECT DISTINCT
			 IdFactura
			,FechaFactura
			,IdFacturaAlfanumerico
			,ImpFactura
			,PlacasCamion
			,ClaPedidoCliente
			,FechaVenceNormal
			,DiasVencidoFact	
			,ClaUbicacion
			,IdViaje
			,IdFabricacion
			,KilosSurtidos
			,LibrasSurtidas
			,ClaClienteCuentaDEA
			,ClaCategoriaMSW
	INTO #tmpFacturaProv
	FROM	#tmpFacturaProvDet
	WHERE	ClaCategoriaMSW IN (@nCategoriaAlambron,@nCategoriaAlambre)

	SELECT '#Facturas de Alambre y Alambron',* FROM #tmpFacturaProv ORDER BY FechaFactura

	--* Obtener importe flete de la replica de bodega laredo
	SELECT		 IdFacturaDEA		= fac.IdFactura
				,NumFacturaDEA		= fac.IdFacturaAlfanumerico
				,FechaFacturaDEA	= fac.FechaFactura
				,CantidadKgs		= fle.KgsPagar
				,ImporteFlete		= fle.ImportePagarFinal
				,ClaCategoria		= fac.ClaCategoriaMSW
				,CantidadKgsPorCat	= fle.KgsPagar
				,ImporteFletePorCat	= fle.ImportePagarFinal
				,ClaUbicacion		= fle.ClaUbicacion
				,IdViaje			= fle.IdViaje
				,FechaEntSal		= fle.FechaEntSal
	INTO #tmpFleteLdoMC
	FROM		#tmpFacturaProv					fac
	CROSS APPLY	(
					SELECT	TOP 1	 KgsPagar
									,ImportePagarFinal	
									,ClaUbicacion
									,IdViaje
									,FechaEntSal
					FROM	MSWSch.MSWOpeTraMovSalidaTabular (NOLOCK)
					WHERE	IdFactura = fac.IdFactura
					ORDER BY IdMovEntSal DESC
				)	fle
	

	--* Distribuir Cantidad e Importe si es necesario 
	UPDATE		flmc SET CantidadKgsPorCat = ROUND(flmc.CantidadKgs*ISNULL(fd.KilosSurtidosDet/NULLIF(ftot.KilosSurtidosTotal,0),0),2)
						,ImporteFletePorCat= ROUND(flmc.ImporteFlete*ISNULL(fd.KilosSurtidosDet/NULLIF(ftot.KilosSurtidosTotal,0),0),2)
	FROM		#tmpFleteLdoMC		flmc
	INNER JOIN	#tmpFacturaProvDet	fd		ON	flmc.IdFacturaDEA = fd.IdFactura
											AND	flmc.ClaCategoria = fd.ClaCategoriaMSW
	INNER JOIN  (
				SELECT	IdFacturaDEA
				FROM	#tmpFleteLdoMC
				GROUP BY IdFacturaDEA
				HAVING COUNT(ClaCategoria) > 1			
				) cat ON flmc.IdFacturaDEA = cat.IdFacturaDEA
	CROSS APPLY (
				SELECT	KilosSurtidosTotal = SUM(KilosSurtidosDet)
				FROM	#tmpFacturaProvDet 
				WHERE	IdFactura = fd.IdFactura
				) ftot

	SELECT ClaUbicacion
		,IdViaje
	INTO #tmpViajeRepetido
	FROM #tmpFleteLdoMC
	WHERE IdViaje IS NOT NULL
	GROUP BY ClaUbicacion
		,IdViaje
	HAVING COUNT(1) > 1

	UPDATE f SET CantidadKgs		= CASE WHEN f.IdFacturaDEA = fac.IdFacturaDEA THEN CantidadKgs ELSE 0 END
				,ImporteFlete		= CASE WHEN f.IdFacturaDEA = fac.IdFacturaDEA THEN ImporteFlete ELSE 0 END
				,CantidadKgsPorCat	= CASE WHEN f.IdFacturaDEA = fac.IdFacturaDEA THEN CantidadKgsPorCat ELSE 0 END
				,ImporteFletePorCat	= CASE WHEN f.IdFacturaDEA = fac.IdFacturaDEA THEN ImporteFletePorCat ELSE 0 END
	FROM #tmpFleteLdoMC f
	INNER JOIN #tmpViajeRepetido v ON f.ClaUbicacion = v.ClaUbicacion
									AND f.IdViaje = v.IdViaje
	OUTER APPLY (
				SELECT TOP 1 IdFacturaDEA
				FROM #tmpFleteLdoMC
				WHERE ClaUbicacion = f.ClaUbicacion
				AND IdViaje = f.IdViaje
				ORDER BY NumFacturaDEA
				)	fac

	
	SELECT '#Tabular/Embarque de Facturas Alambre y Alambron',* FROM #tmpFleteLdoMC ORDER BY FechaFacturaDEA

	BEGIN TRY
        IF @@TRANCOUNT = 0
        BEGIN 
            SET @nEsAbrirTransaccion = 1
            BEGIN TRAN INSERTAPRODFURMAN
        END        	

		DELETE FROM [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes] 
		WHERE ClaAnioMes = (YEAR(@dFechaEjecucionDesde) * 100) + MONTH(@dFechaEjecucionDesde)
		
		INSERT INTO [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes](
			ClaAnioMes
			,ClaUbicacion
			,IdFacturaDEA
			,NumFacturaDEA
			,FechaFacturaDEA
			,IdViaje
			,FechaEmbarque
			,ClaCategoria
			,CantidadKgs
			,ImporteFlete
			,FechaUltimaMod
			,NombrePcMod
			,ClaUsuarioMod
		)

		SELECT			
			(YEAR(FechaFacturaDEA) * 100) + MONTH(FechaFacturaDEA)		
			,ClaUbicacion
			,IdFacturaDEA
			,NumFacturaDEA
			,FechaFacturaDEA
			,IdViaje
			,FechaEntSal
			,ClaCategoria
			,CantidadKgs
			,ImporteFlete
			,GETDATE()
			,HOST_NAME()
			,1		
		FROM #tmpFleteLdoMC


        IF @@TRANCOUNT > 0 AND @nEsAbrirTransaccion = 1
        BEGIN
            COMMIT TRAN INSERTAPRODFURMAN
        END	
    END TRY
    BEGIN CATCH
        SET @sMensajeError = ERROR_MESSAGE()
		
        IF @@TRANCOUNT > 0 AND @nEsAbrirTransaccion = 1
        BEGIN
            ROLLBACK TRAN INSERTAPRODFURMAN
        END	
            
        RAISERROR(@sMensajeError,16,1)
    END CATCH

			

DROP TABLE #tmpFacturaProvDet
DROP TABLE #tmpFacturaProv
DROP TABLE #tmpFleteLdoMC
DROP TABLE #tmpViajeRepetido
--DELETE FROM [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes]

