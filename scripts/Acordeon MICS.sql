SELECT ClaGrupoEstadistico1,ClaGrupoEstadistico2,ClaGrupoEstadistico3, * FROM MSWSch.MSWCatArticulo WHERE ClaArticulo = 615423
SELECT ClaGrupoEstadistico1,ClaGrupoEstadistico2,ClaGrupoEstadistico3,PesoTeoricoLbs, * FROM MSWSch.MSWCatArticulo WHERE ClaveArticulo = 'STW16-10040MCN'
SELECT ClaGrupoEstadistico1,ClaGrupoEstadistico2,ClaGrupoEstadistico3,PesoTeoricoLbs, * FROM MSWSch.MSWCatArticulo WHERE ClaveArticulo = 'WCP-90PNMCN' 

/*
M.IdFactura	
2402014	
2402160	
2401540	
2402218	
*/

SELECT * FROM MSWSch.MSWTraFurmanProduccion 
WHERE ClaArticuloClavo = 615423 AND YEAR(FechaProdClavo) = 2023 AND MONTH(FechaProdClavo) = 1

SELECT * FROM MSWSch.MSWTraOrdenCArgaEscaneo4 WHERE IdPedido = 2398178 AND ClaArticulo = 615423 ORDER BY IdProduccionArticulo DESC


SELECT * FROM MSWSch.MSWTraFurmanProduccion  WHERE IdProdClavo IN (
	2028782
	,2028783
	,2032038
	,2042648
	,2028785
	,2028789
	,2050356
	,2050209
)



SELECT * FROM MSWSch.MSWTraProduccionArticulo4  WHERE IdProduccionArticulo IN (
	2028782
	,2028783
	,2032038
	,2042648
	,2028785
	,2028789
	,2050356
	,2050209
)


SELECT * FROM MSWSch.MSWTraOrdenCArgaEscaneo4 WHERE IdPedido = 2398178 AND IdProduccionArticulo IN (
	2032038
	,2050209
	,2050356
)

EXEC [MSWSch].[MSW_CU99_Pag50_ObtenerProduccionFacturadaDEACEROFurman_Sel]
	@pnAnioMesInicio		= 202301
	,@pnAnioMesFin			= 202312
	,@nIdFactura			= 2401489
	,@pnClaProveedor		= 275
