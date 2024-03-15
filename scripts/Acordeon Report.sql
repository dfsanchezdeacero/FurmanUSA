SELECT * FROM MSWSch.MSWTraOrdenCArgaEscaneo4 
WHERE IdPedido = 2401489 
AND ClaArticulo = 616736 --615423 
AND IdOrdenCarga = 170133
ORDER BY IdProduccionArticulo DESC

SELECT IdOrdenCarga,IdPedido,ClaTipoPedido,ClaEstatusFactura,* FROM MSWSch.MSWTraFactura7Vw Where IdFactura = 2402160
SELECT * FROM MSWSch.MSWTraOrdenCArgaEscaneo4 WHERE IdPedido = 2402160 AND IdOrdenCarga = 170722
SELECT * FROM MSWSch.MSWTraFurmanProduccion  WHERE IdProdClavo IN (2052642)
SELECT * FROM MSWSch.MSWTraProduccionArticulo4  WHERE IdProduccionArticulo IN (2052642)
	
SELECT * FROM [MSWSch].[MswTraOrdenCarga4Vw] WHERE IdOrdenCarga IN (170540,170133)
SELECT * FROM [MSWSch].[MswTraOrdenCargaDet4] WHERE IdOrdenCarga IN (170540,170133) AND IdPedido = 2398178 
SELECT * FROM MSWsch.MSWTraPreOrdenVenta WHERE IdPreOrdenVenta = 2398178
SELECT * FROM MSWsch.MSWTraPreOrdenVentaDet WHERE IdPreOrdenVenta = 2398178

SELECT * FROM MSWSch.MSwTraFActuraDet7 WHERE IdFactura = 2395643
SELECT ClaEstatusFactura,IdOrdenCarga,ClaTipoPedido,* FROM MSWSch.MSwTraFActura7Vw WHERE IdFactura = 2395643
SELECT SubTotal,* FROM MSWSch.MSwTraFActuraDet7Vw WHERE IdFactura = 2395643
SELECT SubTotal = SUM(SubTotal) FROM MSWSch.MSwTraFActuraDet7Vw WHERE IdFactura = 2395643

SELECT * FROM  MSWSch.MswEstVentaArticuloGpoEst est WHERE IdFactura = 2395643
SELECT * FROM  MSWSch.MswEstVentaArticuloGpoEst est WHERE IdFactura = 2402196


	SELECT 
		det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario,
		SUM(det.CantidadEmbarcada) AS CantidadEmbarcada
	FROM MSWSch.MSwTraFActura7Vw					fac WITH(NOLOCK)
	INNER JOIN MSWSch.MSwTraFActuraDet7				det WITH(NOLOCK)	ON  det.IdFactura = fac.IdFactura 
													--AND det.ClaTipoCargo=1		
	AND fac.IdFactura = 2401510
	--AND fac.ClaTipoPedido IN(1,4,5)
	--AND fac.ClaEstatusFactura = 1 --Amarramos que la factura este autorizada/Emitida
	--AND ISNULL(fac.IdOrdenCarga,0) != 0
	--AND fac.FechaUltimoPago IS NOT NULL
	GROUP BY det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario	
	HAVING SUM(ISNULL(det.Subtotal,0)) > 0

EXEC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]
 @pnAnioMesInicio		 = 202301
,@pnAnioMesFin			 = 202301
,@pnVendor				 = 275
,@pnDepto				 = 0
,@pnEsDebug				= 1
,@pnSoloAlamabreMx = 0

SELECT DISTINCT
				det.IdFactura
				,det.ClaArticulo
				,det.NomUnidadPendiente
				,det.PrecioUnitario				
			FROM MSWSch.MSWTraFacturaDet7Vw				det WITH(NOLOCK)
			WHERE det.IdFactura = 2401510
			AND det.ClaArticulo IN (606483, 609269)
			AND det.PrecioUnitario	> 0

SELECT * FROM MSWSch.MswCatArticulo WHERE ClaArticulo = 609269
SELECT * FROM MSWSch.MswCatArticulo WHERE ClaArticulo = 606483

SELECT * 
FROM MSWSch.MSWTraFactura7Vw				fac WITH(NOLOCK)
INNER JOIN MSWSch.MSWCatAgente					age WITH(NOLOCK)	ON	age.ClaAgente = fac.ClaAgenteVta
INNER JOIN MSWSch.MSwCatClienteCuentaEmbarque	emb WITH(NOLOCK)	ON  emb.ClaveClienteCuentaEmbarque = fac.ClaveConsignado
INNER JOIN MSWSch.MswCatEstado					edo WITH(NOLOCK)	ON  edo.ClaEstadoUnico = fac.ClaEstadoConsignado
WHERE  fac.IdFactura = 2401415

SELECT 	
		est.AnioMes,
		est.ClaArticulo,
		est.IdFactura,			
		est.ClaveFactura,			
		SUM (est.Cantidad)		AS Cantidad,	
		SUM (est.Tons*0.90718474)	AS KilosTotales
FROM  MSWSch.MswEstVentaArticuloGpoEst est 
	LEFT JOIN MSWSch.MSWObtenerZonasOrgaSel(0,0) ZON ON (ZON.ClaOrganizacion = EST.ClaZona)				
	LEFT JOIN mswsch.MSWCatAgenteVw	GteVta			   ON GteVta.ClaAgenteVentas = est.ClaAgenteGerente
	LEFT JOIN mswsch.MSWCatClienteCuentaEmbarque cte   ON cte.ClaClienteCuentaEmbarque = est.ClaClienteCuentaEmbarque	 					
	INNER JOIN mswsch.MSWCatEstado			 	edo	   ON cte.ClaEstadoUnico  = edo.ClaEstadoUnico 
	INNER JOIN [MSWSch].[MSWCatRegionEstadistica] red  ON red.claRegionEstadistica = edo.ClaRegionEstadistica
WHERE  est.IdFactura = 2401415
GROUP BY 
		est.AnioMes,
		est.ClaArticulo,
		est.IdFactura,			
		est.ClaveFactura