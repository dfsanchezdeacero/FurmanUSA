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

SELECT * FROM MSWSch.MSwTraFActuraDet7 WHERE IdFactura = 2401489
SELECT ClaEstatusFactura,IdOrdenCarga,ClaTipoPedido,* FROM MSWSch.MSwTraFActura7Vw WHERE IdFactura = 2401489
SELECT * FROM MSWSch.MSwTraFActuraDet7Vw WHERE IdFactura = 2401489
SELECT SubTotal = SUM(SubTotal) FROM MSWSch.MSwTraFActuraDet7Vw WHERE IdFactura = 2401489

SELECT * FROM  MSWSch.MswEstVentaArticuloGpoEst est WHERE IdFactura = 2401945

EXEC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]
 @pnAnioMesInicio		 = 202301
,@pnAnioMesFin			 = 202301
,@pnVendor				 = 275
,@pnDepto				 = 0
,@pnEsDebug				= 1