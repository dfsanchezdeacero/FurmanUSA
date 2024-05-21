--Tomamos como referencia que el articulo ya tiene una orden de trabajo relacionada con su produccion  
--en la tabla MSWTraProduccionArticulo4

--Este Proceso se toma de base en el SP MSWSch.MSWGenerarOrdenTrabajoManoObraProc

SELECT 
pa.IdCelda
,pa.ClaArticulo
,pa.ClaAreaProduccion
,pa.CantidadOriginal --Cajas Producidas / tiempo de uso de maquina
,ep.PrecioHora -- Precio por Hora del proceso de produccion por el que paso
,ca.PorcCostoManoObra -- % de Mano de Costo de Obra del producto final
,CostoMarcado = ROUND(ISNULL(CAST(pa.CantidadOriginal AS NUMERIC(22,4))/100,0) * ISNULL(ep.PrecioHora,0),2) * ISNULL(ca.PorcCostoManoObra/100,0)
	
FROM MSWSch.MSWTraProduccionArticulo4		pa 
INNER JOIN	MSWSch.MSWCatArticulo4Vw			a			ON	pa.ClaArticulo				= a.ClaArticulo
INNER JOIN	MSWSch.MSWTraComposicionArticulo4Vw	ca			ON	a.ClaArticulo				= ca.ClaArticulo
INNER JOIN	MSWSch.MSWRelCategoriaPaso4Vw	rcp			ON	pa.ClaLocalidad				= rcp.ClaLocalidad
														AND	pa.ClaAreaProduccion		= rcp.ClaAreaProduccion
														AND	a.ClaCategoria				= rcp.ClaCategoria
INNER JOIN	MSWSch.MSWRelEmpleadoProduccionCelda4Vw	rep	ON	pa.IdCelda					= rep.IdCelda
														AND	rcp.ClaPaso					= rep.ClaPaso
INNER JOIN	MSWSch.MSWCatEmpleadoProduccion4Vw	ep		ON	rep.ClaEmpleadoProduccion	= ep.ClaEmpleadoProduccion
WHERE pa.ClaArticulo = 600020-- AND pa.FechaProduccion =  '2023-01-10'

SELECT * FROM MSWSch.MSWRelEmpleadoProduccionCelda4Vw WHERE IdCelda = 10
SELECT * FROM MSWSch.MSWCatEmpleadoProduccion4Vw WHERE ClaEmpleadoProduccion IN (33,34)




SELECT 0.4421 * 69600.0000 * (1/100.0)
--CostoMarcado	= PrecioPromedio * otc.Cantidad * ISNULL( PorcCostoMaterial, 0)/100,

--= '2023-01-10'
SELECT * FROM 	MSWSch.MSWTraOrdenTrabajo4				(NOLOCK)	ot WHERE ClaArticulo = 617622 AND FechaTransaccion = '2023-01-10'
SELECT PorcCostoManoObra,* FROM MSWSch.MSWTraComposicionArticulo4Vw WHERE ClaArticulo = 616742


SELECT top 2 'bulk',* FROM 	MSWSch.MSWTraOrdenTrabajo4				(NOLOCK)	ot WHERE ClaArticulo = 600004 ORDER BY FechaTransaccion DESC 
SELECT * FROM 	MSWSch.MSWTraOrdenTrabajoConsumo4				(NOLOCK)	ot WHERE IdOrdenTrabajo = 1022942

SELECT 0.5900 * 104.0000 * (0/100.0)