	SELECT PrecioPromedio, * FROm MSWSch.MSWTraExistenciaLocalidad WHERE CLaArticulo = 600020 AND ClaLocalidad = 8
	
	--PrecioPromedio * otc.Cantidad * ISNULL( PorcCostoMaterial, 0)/100,

	SELECT	'Bulk',
			CatArt.ClaArticulo,
			CatArt.ClaveArticulo,	
			CatArt.NomArticulo,			
			Comp.PorcCostoManoObra  AS  CostoManoDeObra ,
			Comp.PorcCostoMaterial AS CostoMaterial,
			Comp.LineaProduccion AS LineaProduccion,			
			Comp.ClaTipoComposicionArticulo   As  ClaTipoComposicion,
			TipComp.NomTipoComposicionArticuloIng
	FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
																			AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
											AND CatArt.ClaTipoInventario = 1
											AND CatArt.ClaGrupoEstadistico2 = 202
											AND CatArt.ClaGrupoEstadistico3 IN (292,293,453)
											AND CatArt.BajaLogica = 0
	
	SELECT
		'Bulk',
		AVG(Comp.PorcCostoManoObra)  AS  CostoManoDeObra,
		AVG(Comp.PorcCostoMaterial) AS CostoMaterial
	FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
																			AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
											AND CatArt.ClaTipoInventario = 1
											AND CatArt.ClaGrupoEstadistico2 = 202
											AND CatArt.ClaGrupoEstadistico3 IN (292,293,453)
											AND CatArt.BajaLogica = 0	

	SELECT	
		'Wire Coil',
		CatArt.ClaArticulo,
		CatArt.ClaveArticulo,	
		CatArt.NomArticulo,			
		Comp.PorcCostoManoObra  AS  CostoManoDeObra ,
		Comp.PorcCostoMaterial AS CostoMaterial,
		Comp.LineaProduccion AS LineaProduccion,			
		Comp.ClaTipoComposicionArticulo   As  ClaTipoComposicion,
		TipComp.NomTipoComposicionArticuloIng
	FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
																			AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
											AND CatArt.ClaTipoInventario = 1
											AND CatArt.ClaGrupoEstadistico2 = 201
											AND CatArt.ClaGrupoEstadistico3 IN (289,454)
											AND CatArt.BajaLogica = 0

	SELECT
		'Wire Coil',
		AVG(Comp.PorcCostoManoObra)  AS  CostoManoDeObra,
		AVG(Comp.PorcCostoMaterial) AS CostoMaterial
	FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
																			AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
											AND CatArt.ClaTipoInventario = 1
											AND CatArt.ClaGrupoEstadistico2 = 201
											AND CatArt.ClaGrupoEstadistico3 IN (289,454)
											AND CatArt.BajaLogica = 0	

	--SELECT	
	--	'Paper Tape',
	--	CatArt.ClaArticulo,
	--	CatArt.ClaveArticulo,	
	--	CatArt.NomArticulo,			
	--	Comp.PorcCostoManoObra  AS  CostoManoDeObra ,
	--	Comp.PorcCostoMaterial AS CostoMaterial,
	--	Comp.LineaProduccion AS LineaProduccion,			
	--	Comp.ClaTipoComposicionArticulo   As  ClaTipoComposicion,
	--	TipComp.NomTipoComposicionArticuloIng
	--FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	--INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
	--																		AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	--INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
	--										AND CatArt.ClaTipoInventario = 1
	--										AND CatArt.ClaGrupoEstadistico2 = 201
	--										AND CatArt.ClaGrupoEstadistico3 IN (291)
	--										AND CatArt.BajaLogica = 0

	SELECT
		'Paper Tape',
		AVG(Comp.PorcCostoManoObra)  AS  CostoManoDeObra,
		AVG(Comp.PorcCostoMaterial) AS CostoMaterial
	FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
																			AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
											AND CatArt.ClaTipoInventario = 1
											AND CatArt.ClaGrupoEstadistico2 = 201
											AND CatArt.ClaGrupoEstadistico3 IN (291)
											AND CatArt.BajaLogica = 0	

	--SELECT	
	--	'Plastic Strip',
	--	CatArt.ClaArticulo,
	--	CatArt.ClaveArticulo,	
	--	CatArt.NomArticulo,			
	--	Comp.PorcCostoManoObra  AS  CostoManoDeObra ,
	--	Comp.PorcCostoMaterial AS CostoMaterial,
	--	Comp.LineaProduccion AS LineaProduccion,			
	--	Comp.ClaTipoComposicionArticulo   As  ClaTipoComposicion,
	--	TipComp.NomTipoComposicionArticuloIng
	--FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	--INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
	--																		AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	--INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
	--										AND CatArt.ClaTipoInventario = 1
	--										AND CatArt.ClaGrupoEstadistico2 = 201
	--										AND CatArt.ClaGrupoEstadistico3 IN (290)
	--										AND CatArt.BajaLogica = 0


	SELECT				
		'Plastic Strip',
		AVG(Comp.PorcCostoManoObra)  AS  CostoManoDeObra,
		AVG(Comp.PorcCostoMaterial) AS CostoMaterial
	FROM	MSWSch.MSWTraComposicionArticulo4Vw Comp  WITH(NOLOCK) 
	INNER JOIN MSWSch.MSWCatTipoComposicionArticulo4Vw TipComp   WITH(NOLOCK) ON Comp.ClaTipoComposicionArticulo = TipComp.ClaTipoComposicionArticulo  
																			AND ISNULL(TipComp.BajaLogica , 0 ) =0 
	INNER JOIN MSWSch.MswCatArticulo CatArt ON Comp.ClaArticulo = CatArt.ClaArticulo 
											AND CatArt.ClaTipoInventario = 1
											AND CatArt.ClaGrupoEstadistico2 = 201
											AND CatArt.ClaGrupoEstadistico3 IN (290)
											AND CatArt.BajaLogica = 0	

SELECT
'Tipo'
,NombreGrupoEstadistico
,ClaGrupoEstadistico
FROM MSWSch.MswCatGrupoEstadistico WHERE ClaGrupoEstadistico IN (201, 202) AND NivelActual = 2

SELECT
	'SubTipo'
	,NombreGrupoEstadistico
	,ClaGrupoEstadistico
FROM MSWSch.MswCatGrupoEstadistico Est
WHERE ClaGrupoEstadistico IN (292, 293, 453, 289, 291, 290, 454) AND NivelActual = 3 

SELECT ClaCategoria,ClaFamilia,ClaGrupoEstadistico2, ClaGrupoEstadistico3,* FROm MSWSch.MswCatArticulo WHERE ClaArticulo = 606635
SELECT * FROM MSWSch.MSWCatCategoria WHERE ClaCategoria = 43
SELECT * FROM MSWSch.MSWCatFamilia WHERE ClaFamilia =  341