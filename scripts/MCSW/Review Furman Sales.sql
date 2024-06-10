
DECLARE @pnAnioMesInicio	INT	= 202301 ,@pnAnioMesFin	INT = 202301

SELECT
		 VtFcD.ClaArticulo 
		, Cat.NomArticulo		
		, VtFc.IdFactura 
		,Kilos = CAST(Edt.PesoEmbarcado AS numeric(22,2))		
		,VtFc.IdFabricacion  AS 'VtFc.IdFabricacion '
		,VtFc.ClaUbicacion  AS 'VtFc.ClaUbicacion '
		,Fab.ClaPlanta  AS 'Fab.ClaPlanta'
		,Fab.ClaTransportista AS 'Fab.ClaTransportista'
		,Fab.ClaTipoEmbarque	 AS 'Fab.ClaTipoEmbarque	'
		,Fab.ClaMedioEmbarque AS 'Fab.ClaMedioEmbarque'
		,MEm.NomMedioEmbarque		 AS 'MEm.NomMedioEmbarque'
		,Tab.IdTabular AS 'Tab.IdTabular'
		,Tab.ClaTipoTabular AS 'Tab.ClaTipoTabular'
		,Tab.ClaTransportista AS 'Tab.ClaTransportista'
		,Tab.ImportePagarFinal AS 'Tab.ImportePagarFinal'
	
	FROM OPERACION.OPESCH.OpeTraMovEntSal                E      WITH(NOLOCK)
	INNER JOIN OPERACION.OPESCH.[OPETraMovEntSalDet]     Edt    WITH(NOLOCK)  ON E.ClaUbicacion = Edt.ClaUbicacion 
																				AND E.IdMovEntSal = Edt.IdMovEntSal 
																				AND E.IdFabricacion = Edt.IdFabricacion	
																				--AND Edt.ClaUbicacion = 65
	INNER JOIN [OPESch].[OpeTraFacturaVw]                VtFc   WITH(NOLOCK)  ON VtFc.IdFactura = E.IdFactura AND VtFc.IdViaje = E.IdViaje
	INNER JOIN [OPESch].[OpeTraFacturaDetVw]             VtFcD  WITH(NOLOCK)  ON VtFcD.IdFactura = VtFc.IdFactura 
																				AND VtFcD.NumRenglonFab = Edt.IdFabricacionDet 
																				AND VtFcD.ClaArticulo = Edt.ClaArticulo 	
	INNER JOIN OpeSch.OpeTraFabricacionVw                Fab    WITH(NOLOCK)  ON VtFc.IdFabricacion = Fab.IdFabricacion
																				AND VtFc.ClaUbicacion = Fab.ClaPlanta
	INNER JOIN [FleSch].[FleVtaCatMedioEmbarque]		 MEm	WITH(NOLOCK)  ON  MEm.ClaMedioEmbarque = Fab.ClaMedioEmbarque
	LEFT JOIN  [OPESch].[OPECfgFurmanVariables]	         Val    WITH(NOLOCK)  ON Val.Anio = YEAR(VtFc.FechaFactura)
	INNER JOIN TiCatalogo.[dbo].[ArtCatArticulo]         Cat    WITH(NOLOCK)  ON Cat.ClaArticulo = Edt.ClaArticulo AND Cat.ClaTipoInventario = 1
	LEFT JOIN  OPESch.OPECarTraCargo                     Car    WITH(NOLOCK)  ON Car.IdCargo = VtFc.IdFactura
	LEFT JOIN  OPESch.OPECarHisCargo                     CarH   WITH(NOLOCK)  ON CarH.IdCargo = VtFc.IdFactura
	INNER JOIN OpeSch.OpeVtaCatClienteVw                 Cl     WITH(NOLOCK)  ON Cl.ClaCliente = VtFc.ClaClienteCuenta 
	INNER JOIN TiCatalogo.[dbo].[VtaCatCiudad]           Cd     WITH(NOLOCK)  ON Cl.ClaCiudad = Cd.ClaCiudad AND Cd.ClaPais = 2
	INNER JOIN [OPESch].[OpeTraViajevw]					 Via    WITH(NOLOCK)     ON E.ClaUbicacion = Via.ClaUbicacion
																				AND E.IdViaje = Via.IdViaje
	LEFT JOIN [OPESch].[OPEFleTraTabularVw]                Tab    WITH (NOLOCK) ON E.ClaUbicacion = Tab.ClaUbicacion
																				AND Via.IdNumTabular = Tab.IdTabular	
	INNER JOIN [FleSch].[FleVtaCfgArticuloFacturaVw]     CfgVta WITH(NOLOCK)  ON CfgVta.ClaArticulo = VtFcD.ClaArticulo AND CfgVta.ClaPais = 2
	INNER JOIN [FleSch].[FleVtaCatUnidadVentaVw]         CatUV  WITH(NOLOCK)  ON CfgVta.ClaUnidadVenta = CatUV.ClaUnidadVenta
	INNER JOIN TiCatalogo.[dbo].[VtaCatAgenteVw]         SRep   WITH(NOLOCK)  ON SRep.ClaAgente = VtFc.ClaAgente
	LEFT JOIN [OPESch].[OPECfgFurmanInlandFreightRates] InFht WITH(NOLOCK) ON InFht.Anio=YEAR(VtFc.FechaFactura)
	OUTER APPLY(
		SELECT 
			Are.ConnumConGuiones AS ConnumConGuiones,
			SUM (Cmp.PorcComposicion/100.0) AS PorcComposicion
		FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
		INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Cmp.ClaArticuloComp = Are.ClaArticulo
		WHERE Cmp.ClaArticulo = VtFcD.ClaArticulo
		GROUP BY Are.ConnumConGuiones	
	) as connumWire
	OUTER APPLY (
		SELECT 
			ParidadMonedaPeso
		FROm
		OpeSch.OpeAreCatParidadVw P
		WHERE CAST(P.FechaParidad AS DATE) = CAST(VtFc.FechaFactura AS DATE)
	) ExRt
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(VtFc.FechaFactura)*100+MONTH(VtFc.FechaFactura) >= @pnAnioMesInicio))
		AND (@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(VtFc.FechaFactura)*100+MONTH(VtFc.FechaFactura) <= @pnAnioMesFin))
		AND E.ClaUbicacion = 65 
		AND E.ClaMotivoEntrada = 1 
		AND Cat.ClaArticulo NOT IN(259087)
		AND Fab.ClaMedioEmbarque = 7

--ClaTipoViaje
--1 -- Si genera
--4 o 5 Customer Pickup 

SELECT tOP 100 * FROM [OPESch].[OpeTraViajevw]	WHERE ClaEstatus = 3 AND ClaTipoViaje IN (4,5)