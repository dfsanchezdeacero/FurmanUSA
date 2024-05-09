SELECT 
	E.IdFacturaAlfanumerico
	, E.IdFactura
	, Tab.ImportePagarFinal
	, Edt.ClaArticulo
	, Edt.CantEmbarcada
	, Edt.PesoEmbarcado
	, ViajesFact.TotalPesoEmbarcado
	, Porc = Edt.PesoEmbarcado/ViajesFact.TotalPesoEmbarcado
	, ImportePagarFinalProc = Tab.ImportePagarFinal * (Edt.PesoEmbarcado/ViajesFact.TotalPesoEmbarcado)
	, INLFCU = (Tab.ImportePagarFinal * (Edt.PesoEmbarcado/ViajesFact.TotalPesoEmbarcado)) / Invs.TotalQtyKilos--Sub.TotalPesoEmbarcado--Edt.PesoEmbarcado
	--, INLFCU = Tab.ImportePagarFinal / Edt.PesoEmbarcado --Invs.TotalQtyKilos--Sub.TotalPesoEmbarcado--Edt.PesoEmbarcado
FROM OpeSch.OpeTraMovEntSal                E      WITH(NOLOCK)
INNER JOIN OpeSch.[OPETraMovEntSalDet]     Edt    WITH(NOLOCK)  ON E.ClaUbicacion = Edt.ClaUbicacion
																AND E.IdMovEntSal = Edt.IdMovEntSal 
																AND E.IdFabricacion = Edt.IdFabricacion	
																AND Edt.ClaUbicacion = 65
INNER JOIN OpeSch.OpeTraViajevw		  	   Via    WITH(NOLOCK)  ON E.ClaUbicacion = Via.ClaUbicacion
																AND E.IdViaje = Via.IdViaje
																AND Via.IdNumTabular IS NOT NULL
																AND Via.ClaEstatus = 3
LEFT JOIN OPESch.OPEFleTraTabularVw        Tab    WITH (NOLOCK) ON Via.ClaUbicacion = Tab.ClaUbicacion
																AND Via.IdNumTabular = Tab.IdTabular
																AND Tab.ClaTipoTabular IN (1,3)
OUTER APPLY(
	SELECT 
		TotalPesoEmbarcado = SUM(Edts.PesoEmbarcado)--, Edt.* 
	FROM OpeSch.OpeTraMovEntSal                Es      WITH(NOLOCK)
	INNER JOIN OpeSch.[OPETraMovEntSalDet]     Edts    WITH(NOLOCK)  ON Es.ClaUbicacion = Edts.ClaUbicacion
																	AND Es.IdMovEntSal = Edts.IdMovEntSal 
																	AND Es.IdFabricacion = Edts.IdFabricacion	
																	AND Edts.ClaUbicacion = 65	
	WHERE Es.ClaUbicacion = 65 
	AND Es.IdViaje = E.IdViaje
) ViajesFact
OUTER APPLY(

		SELECT 
			TotalQtyKilos = SUM(Ed.PesoEmbarcado)	
		FROM OPERACION.OPESCH.OpeTraMovEntSal                En      WITH(NOLOCK)
		INNER JOIN OPERACION.OPESCH.[OPETraMovEntSalDet]     Ed    WITH(NOLOCK)  ON En.ClaUbicacion = Ed.ClaUbicacion 
																					AND En.IdMovEntSal = Ed.IdMovEntSal 
																					AND En.IdFabricacion = Ed.IdFabricacion	
																					AND En.ClaUbicacion = 65	
		INNER JOIN [OPESch].[OpeTraFacturaVw]                Inv   WITH(NOLOCK)  ON Inv.IdFactura = En.IdFactura AND Inv.IdViaje = En.IdViaje
		WHERE Inv.IdFactura = E.IdFactura 
		AND Inv.IdViaje = E.IdViaje		
	) Invs
WHERE E.ClaUbicacion = 65 
AND E.IdFactura = 244059813 --62761--60799