USE [MCSW_ERP]
GO
/****** Object:  StoredProcedure [MSWSch].[MSW_CU99_Pag50_ObtenerProduccionFacturadaDEACEROFurman_Sel]    Script Date: 3/4/2024 12:16:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [MSWSch].[MSW_CU99_Pag50_ObtenerProduccionFacturadaDEACEROFurman_Sel]
	@pnAnioMesInicio		INT = 202301
	,@pnAnioMesFin			INT = 202301
	,@nIdFactura			INT = 2394108
	,@pnClaProveedor		INT = 275	
AS
BEGIn
	DECLARE @nFactorLbsToKgs DECIMAL(10,6) = 0.453592, @pnEsDebug  INT = 0
	SELECT 	
			est.ClaLocalidad,
			est.AnioMes,
			est.ClaArticulo,
			est.IdFactura,			
			est.ClaveFactura,			
			SUM (est.Cantidad)		AS Cantidad,	
			SUM (est.Tons*0.90718474)	AS KilosTotales
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
		AND (@nIdFactura = 0 OR (@nIdFactura IS NOT NULL AND est.IdFactura = @nIdFactura))
		
	GROUP BY 
			est.ClaLocalidad
			,est.AnioMes
			,est.ClaArticulo
			,est.IdFactura
			,est.ClaveFactura			
	HAVING MAX(abs(ISNULL(Cantidad,0))) != 0

	IF @pnEsDebug = 1 SELECT '#EstVta', * FROM #EstVta

	SELECT 
		det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		fac.IdOrdenCarga,
		det.PrecioUnitario,
		SUM(det.CantidadEmbarcada) AS CantidadEmbarcada
	INTO #Factura7Vw
	FROM MSWSch.MSwTraFActura7Vw						fac WITH(NOLOCK)
	INNER JOIN MSWSch.MSwTraFActuraDet7VW				det WITH(NOLOCK)	ON  det.IdFactura = fac.IdFactura 
																		AND det.ClaTipoCargo=1
	LEFT JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON art.ClaArticulo		  = det.ClaArticulo 
																		AND art.ClaTipoInventario = 1
																		AND art.ClaGrupoEstadistico2 IN (202,201)
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fac.FechaFactura)*100+MONTH(fac.FechaFactura) >= @pnAnioMesInicio))
		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fac.FechaFactura)*100+MONTH(fac.FechaFactura) <= @pnAnioMesFin))
		AND (@nIdFactura = 0 OR (@nIdFactura IS NOT NULL AND fac.IdFactura = @nIdFactura))
		AND fac.ClaTipoPedido = 1 
		AND ISNULL(fac.IdOrdenCarga,0) != 0
		AND fac.ClaEstatusFactura = 1 --Amarramos que la factura este autorizada/Emitida
	GROUP BY det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario	
	HAVING SUM(ISNULL(det.Subtotal,0)) > 0

	IF @pnEsDebug = 1 SELECT '#Factura7Vw', * FROM #Factura7Vw

	SELECT 
		fac.ClaArticulo,
		oce.IdProduccionArticulo,
		con.ConnumuResuelto,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.PrecioUnitario,
		fac.CantidadEmbarcada AS CantTotalFactura,
		CAST(ISNULL(oce.Cantidad,0) AS numeric(22,4))	AS CantTotalEmbarcada
	INTO #Furman
	FROM #Factura7Vw								fac WITH(NOLOCK)	
		LEFT JOIN MSWSch.MSWTraOrdenCArgaEscaneo4	oce WITH(NOLOCK)	ON  fac.IdOrdenCarga = oce.IdOrdenCarga
																		AND fac.ClaArticulo = oce.ClaArticulo
																		AND fac.IdPedido = oce.IdPedido		
		LEFT JOIN MSWSch.MSWTraFurmanProduccion	pro WITH(NOLOCK)	ON pro.IdProdClavo = oce.IdProduccionArticulo
																		AND pro.ClaProveedorResuelto IS NOT NULL
																		AND pro.ClaProveedorResuelto = @pnClaProveedor
																		AND pro.ClaProveedorResuelto = pro.ClaProvResueltoAlambre

	OUTER APPLY	(
		SELECT
			TOP 1 
			ConnumuAlambre = ISNULL(prox.ConnumuAlambre,'') 
			, ConnumuAlambron = ISNULL(prox.ConnumuAlambron,'')
			, WireSource = CASE WHEN prox.ClaProveedorResuelto = @pnClaProveedor AND prox.ClaProvResueltoAlambre = @pnClaProveedor AND prox.IdProdAlambre IS NOT NULL 
								THEN 'MX' 
								ELSE 'US' 
						   END
			,ConnumuResuelto = prox.ConnumuResuelto
		FROM MSWSch.MSWTraFurmanProduccion	prox WITH(NOLOCK)	
		WHERE prox.IdProdClavo = oce.IdProduccionArticulo
		--AND prox.ClaArticuloClavo = oce.ClaArticulo
		--AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(prox.FechaProdClavo)*100+MONTH(prox.FechaProdClavo) >= @pnAnioMesInicio))
		--AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(prox.FechaProdClavo)*100+MONTH(prox.FechaProdClavo) <= @pnAnioMesFin))		
		AND	prox.ClaProveedorResuelto IS NOT NULL
		AND prox.ClaProveedorResuelto = @pnClaProveedor
		AND	prox.ClaProvResueltoAlambre = @pnClaProveedor		
		--AND prov.ClaProvResueltoAlambron = @pnVendor			
	) AS con
	WHERE oce.Cantidad > 0
	GROUP BY fac.ClaArticulo,
		oce.IdProduccionArticulo,
		con.ConnumuResuelto,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.PrecioUnitario,
		fac.CantidadEmbarcada,
		oce.Cantidad

	IF @pnEsDebug = 1 
		SELECT '#Furman', oce.* FROM #Furman oce
		--INNER JOIN MSWSch.MSWTraFurmanProduccion	pro WITH(NOLOCK)	ON pro.IdProdClavo = oce.IdProduccionArticulo
		--																AND pro.ClaArticuloClavo = oce.ClaArticulo
	
	--RETURN

	SELECT	
			est.AnioMes
			,IdFactura = est.IdFactura
			,ClaveFactura = est.ClaveFactura
			,ClaArticulo = est.ClaArticulo			
			,Connumu = f.ConnumuResuelto
			,EstQtyTotal = ISNULL(est.Cantidad,0)
			,EstKgsTotal = ISNULL(est.KilosTotales,0)*1000
			,FurmanQtyTotal = SUM(ISNULL(f.CantTotalEmbarcada,0))
			,FurmanKgsTotal = CAST(0 AS NUMERIC(22,4))
			,PrecioUnitario = f.PrecioUnitario
			,Indice = ROW_NUMBER() OVER(ORDER BY est.IdFactura,est.ClaArticulo) 
	INTO #tmpResult
	FROM  #EstVta  est
	
	LEFT JOIN #Furman f ON est.IdFactura = f.IdFactura 
					AND est.ClaArticulo = f.ClaArticulo
					AND est.AnioMes = (YEAR(f.FechaFactura)*100+MONTH(f.FechaFactura))
	GROUP BY est.AnioMes
		,est.IdFactura
		,est.ClaveFactura
		,est.ClaArticulo
		,f.ConnumuResuelto
		,est.Cantidad
		,est.KilosTotales
		,f.PrecioUnitario
	
	IF @pnEsDebug = 1 SELECT '#tmpResult', * FROM #tmpResult



	UPDATE F
		SET F.FurmanKgsTotal = F.FurmanQtyTotal * (art.PesoTeoricoLbs * @nFactorLbsToKgs)  
	FROM #tmpResult F
	INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON  art.ClaArticulo		  = F.ClaArticulo 
																		AND art.ClaTipoInventario = 1


	SELECT 
		AnioMes
		,IdFactura
		,ClaArticulo
	INTO #tmpResultRepetido
	FROM #tmpResult
	GROUP BY 
		AnioMes
		,IdFactura
		,ClaArticulo
	HAVING COUNT(1) > 1


	UPDATE f SET EstQtyTotal		= CASE WHEN f.Indice = fac.Indice THEN EstQtyTotal ELSE 0 END
				,EstKgsTotal		= CASE WHEN f.Indice = fac.Indice THEN EstKgsTotal ELSE 0 END
	FROM #tmpResult f
	INNER JOIN #tmpResultRepetido v ON f.IdFactura = v.IdFactura
									AND f.ClaArticulo = v.ClaArticulo
	OUTER APPLY (
				SELECT 
					TOP 1 Indice
				FROM #tmpResult
				WHERE IdFactura = f.IdFactura
					AND ClaArticulo = f.ClaArticulo
				ORDER BY IdFactura,ClaArticulo
				)	fac	

	IF @pnEsDebug = 2
	BEGIN
			SELECT
			IdFactura = R.IdFactura
			,ClaveFactura = CAST(R.ClaveFactura AS VARCHAR)
			,ClaArticulo = CAST(R.ClaArticulo AS VARCHAR)
			,ClaveArticulo = Cat.ClaveArticulo
			,NomArticulo = Cat.NomArticulo
			,Connumu = R.Connumu
			,PesoLbs = ISNULL(Cat.PesoTeoricoLbs,0)
			,PesoKgs = ISNULL(Cat.PesoTeoricoLbs,0) * 0.453592
			,CajasSold= ISNULL(R.EstQtyTotal,0)
			,KgsSold= ISNULL(R.EstKgsTotal,0)
			,CajasFURMAN= ISNULL(R.FurmanQtyTotal,0)
			,KgsFURMAN = ISNULL(R.FurmanKgsTotal,0)
		FROM #tmpResult R
		LEFT JOIN MSWSch.MswCatArticulo Cat ON R.ClaArticulo = Cat.ClaArticulo 
											AND Cat.ClaTipoInventario = 1
	END
	ELSE
	BEGIN

		SELECT
			[Invoice Id;w=80;a=center;t=clave]			              = CAST(R.IdFactura AS VARCHAR)
			,[Invoice;w=80;a=center;t=clave]			              = CAST(R.ClaveFactura AS VARCHAR)
			,[SHIPDATU;w=100;a=Center;t=clave;c=SHIPDATU] = Fact.FechaEmbarcado 
			,[PAYDATEU;w=100;a=Center;t=clave;c=PAYDATEU]= Fact.FechaUltimoPago
			,[GRSUPRU;w=80;a=Right;t=decimal;d=4;c=GRSUPRU] = (R.PrecioUnitario / NULLIF((Cat.PesoTeoricoLbs*@nFactorLbsToKgs),0))
			,[Interest Rate %;w=80;a=right;t=decimal;d=4] = ISNULL(ConfigIntRate.PorcInteres,0)
			,[Nail Id;w=80;a=center;t=clave]			              = CAST(R.ClaArticulo AS VARCHAR)
			,[Nail Code;w=140;a=left;t=clave]			              = Cat.ClaveArticulo
			,[Nail Name;w=300;a=left;t=clave]			              = Cat.NomArticulo
			,[Nail Connumu;w=200;a=left;t=clave]			          = R.Connumu
			--,[Unit Price;w=80;a=right;t=decimal;d=4]				  = ISNULL(R.PrecioUnitario,0)
			,[Weight Lbs;w=80;a=right;t=decimal;d=4]				  = ISNULL(Cat.PesoTeoricoLbs,0)
			,[Weight Kgs;w=80;a=right;t=decimal;d=4]				  = ISNULL(Cat.PesoTeoricoLbs,0) * 0.453592
			,[Boxes Sold;w=100;a=right;t=decimal;d=2;s=Sum]			  = ISNULL(R.EstQtyTotal,0)
			,[Kgs Sold ;w=100;a=right;t=decimal;d=2;s=Sum]			  = ISNULL(R.EstKgsTotal,0)
			,[FURMAN Boxes Sold;w=100;a=right;t=decimal;d=2;s=Sum]	  = ISNULL(R.FurmanQtyTotal,0)
			,[FURMAN Kgs Sold;w=100;a=right;t=decimal;d=2;s=Sum]	  = ISNULL(R.FurmanKgsTotal,0)
		FROM #tmpResult R
		LEFT JOIN MSWSch.MswCatArticulo Cat ON R.ClaArticulo = Cat.ClaArticulo 
												AND Cat.ClaTipoInventario = 1

		OUTER APPLY (
			SELECT 
				FechaEmbarcado = fac.FechaEmbarcado
				,FechaUltimoPago = fac.FechaUltimoPago
				--,PrecioUnitario = facD.PrecioUnitario
			FROM MSWSch.MSWTraFactura7Vw fac 
			--LEFT JOIN MSWSch.MSWTraFacturaDet7Vw facD ON fac.IdFactura = facD.IdFactura 
			--										AND R.ClaArticulo = facD.ClaArticulo
			WHERE R.IdFactura = fac.IdFactura --AND facD.ClaTipoCargo=1
		) Fact
		OUTER APPLY (
			SELECT 
				PorcInteres = AVG(FInt.PorcInteres)
			FROM [MSWSch].[MSWCfgFurmanVentaInterestRate] FInt WITH(NOLOCK) 
			WHERE FInt.AnioMes >= @pnAnioMesInicio
			AND FInt.AnioMes <= @pnAnioMesFin
		)ConfigIntRate
											
		ORDER BY R.IdFactura
	END
	
	DROP TABLE #EstVta
	DROP TABLE #Factura7Vw
	DROP TABLE #Furman
	DROP TABLE #tmpResult
	DROP TABLE #tmpResultRepetido

END
