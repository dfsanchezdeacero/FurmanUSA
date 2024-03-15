DECLARE 	@pnAnioMesInicio INT = 202301, @pnAnioMesFin INT = 202301
	SELECT 	
			est.ClaLocalidad,
			est.AnioMes,
			est.ClaArticulo,
			est.IdFactura,			
			est.ClaveFactura,			
			SUM (est.Cantidad)		AS Cantidad,	
			SUM (est.Tons * 0.90718474)	* 1000 AS KilosTotales
	INTO #EstVta				
	FROM  MSWSch.MswEstVentaArticuloGpoEst est 
		LEFT JOIN MSWSch.MSWObtenerZonasOrgaSel(0,0) ZON ON (ZON.ClaOrganizacion = EST.ClaZona)				
		LEFT JOIN mswsch.MSWCatAgenteVw	GteVta			   ON GteVta.ClaAgenteVentas = est.ClaAgenteGerente
		LEFT JOIN mswsch.MSWCatClienteCuentaEmbarque cte   ON cte.ClaClienteCuentaEmbarque = est.ClaClienteCuentaEmbarque	 					
		INNER JOIN mswsch.MSWCatEstado			 	edo	   ON cte.ClaEstadoUnico  = edo.ClaEstadoUnico 
		INNER JOIN [MSWSch].[MSWCatRegionEstadistica] red  ON red.claRegionEstadistica = edo.ClaRegionEstadistica
	WHERE 
		(@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND Est.AnioMes >= @pnAnioMesInicio))
		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND Est.AnioMes <= @pnAnioMesFin))	
		AND ISNULL(est.ClaGrupoEstadistico2,206) not in ( 206 ,-999 )  and est.AnioMes  /100 >= 2019
		AND	 ( 0=0 Or  ISNULL(est.ClaGrupoEstadistico1,101 ) = 0)		
		AND	 ( 272=0 Or  ISNULL(est.ClaSistemaOrigen,272 ) = 272)
		AND est.CLaLocalidad = 20
		--AND (@nIdFactura = 0 OR (@nIdFactura IS NOT NULL AND est.IdFactura = @nIdFactura))
	GROUP BY 
			est.ClaLocalidad
			,est.AnioMes
			,est.ClaArticulo
			,est.IdFactura
			,est.ClaveFactura			
	HAVING MAX(abs(ISNULL(Cantidad,0))) != 0
		
	SELECT * FROM #EstVta WHERE IdFactura = 2397782

	SELECT @nKilosFacturadosOntario = SUM(KilosTotales) 
	FROM #EstVta 
	WHERE CLaLocalidad = 20

	DROP TABLE #EstVta