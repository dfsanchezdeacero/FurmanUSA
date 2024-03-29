USE [MCSW_ERP]
GO
/****** Object:  StoredProcedure [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]    Script Date: 2/22/2024 8:34:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 --NUEVO FURMAN
ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]
--ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel_DFSS]

 @pnAnioMesInicio		INT = 202301
,@pnAnioMesFin			INT = 202312
,@pnVendor				INT = 275
,@pnDepto				INT = 0
,@psIdioma				VARCHAR(15)='Spanish'
,@pnEsDebug				TINYINT = 0
,@pnEsPorPantallaReact  INT = 0
AS
BEGIN

	DECLARE @nFactorLbsToKgs DECIMAL(10,6) = 0.453592

	CREATE TABLE #tmpProduccion	(
		 PRODCODU			VARCHAR(20)
		,FURCOM				NUMERIC(22,8)
		,FURGNA             NUMERIC(22,8)
		,FURINT             NUMERIC(22,8)
	)

	SELECT 
		det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario,
		SUM(det.CantidadEmbarcada) AS CantidadEmbarcada
	INTO #Factura7Vw
	FROM MSWSch.MSwTraFActura7						fac WITH(NOLOCK)
	INNER JOIN MSWSch.MSwTraFActuraDet7				det WITH(NOLOCK)	ON  det.IdFactura = fac.IdFactura AND det.ClaTipoCargo=1
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(fac.FechaFactura)*100+MONTH(fac.FechaFactura) >= @pnAnioMesInicio))
	AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(fac.FechaFactura)*100+MONTH(fac.FechaFactura) <= @pnAnioMesFin))
	--AND fac.IdFactura = 2413477
	GROUP BY det.ClaArticulo,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.IdPedido,
		IdOrdenCarga,
		det.PrecioUnitario	
	HAVING SUM(ISNULL(det.Subtotal,0)) > 0

	SELECT 
		fac.ClaArticulo,
		ConnumuAlambre = ISNULL(con.ConnumuAlambre,''),
		ConnumuAlambron = ISNULL(con.ConnumuAlambron,''),
		con.ConnumuResuelto,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.PrecioUnitario,
		CantTotalFactura = fac.CantidadEmbarcada,
		CantTotalEmbarcada = SUM(ISNULL(oce.Cantidad,0)),
		CantidadKilos = 0 
	INTO #Furman
	FROM #Factura7Vw							fac WITH(NOLOCK)	
	INNER JOIN MSWSch.MSWTraOrdenCArgaEscaneo4	oce WITH(NOLOCK)	ON  oce.IdOrdenCarga = fac.IdOrdenCarga 
																		AND oce.ClaArticulo = fac.ClaArticulo
																		AND fac.IdPedido = oce.IdPedido
	CROSS APPLY	(
		SELECT
			TOP 1 ConnumuAlambre= ISNULL(ConnumuAlambre,'') 
			, ConnumuAlambron = ISNULL(ConnumuAlambron,'')
			,ConnumuResuelto
		FROM MSWSch.MSWTraFurmanProduccion	pro WITH(NOLOCK)	
		WHERE   pro.IdProdClavo = oce.IdProduccionArticulo 
			AND pro.ClaArticuloClavo = fac.ClaArticulo
			AND pro.ClaProveedorResuelto = @pnVendor
			AND	ConnumuResuelto IS NOT NULL
	) AS con	
	GROUP BY fac.ClaArticulo,
		con.ConnumuAlambre,
		con.ConnumuAlambron,
		con.ConnumuResuelto,
		fac.FechaFactura,
		fac.IdFactura,
		fac.ClaveFactura,
		fac.PrecioUnitario,
		fac.CantidadEmbarcada

	UPDATE F
		SET F.CantidadKilos = CantTotalEmbarcada * (art.PesoTeoricoLbs * @nFactorLbsToKgs) 
	FROM #Furman F
	INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON  art.ClaArticulo		  = F.ClaArticulo 
																		AND art.ClaTipoInventario = 1	
	
		SELECT
			 V.ClaArticulo
			,art.NomArticulo
			,V.IdFactura
			,V.ClaveFactura
			,V.ConnumuAlambre
			,V.ConnumuAlambron
			--,V.ConnumuResuelto
			,fac.ClaveConsignado
			,fac.NomConsignado
			,V.FechaFactura
			,fac.FechaEmbarcado
			,fac.FechaUltimoPago
			,V.CantTotalEmbarcada
			,V.CantidadKilos
			,UOM = facD.NomUnidadPendiente
			,PrecioUnitarioBruto = facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)
			,facD.PrecioUnitario
			/*,BILLADJU = (ISNULL(fac.ImporteTotalAjustado,0)/ NULLIF(ISNULL(CantidadKilos,0),0)) / (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))*/
			/*UPDATE -> 2024 */,QtyXGRSUPRU = V.CantidadKilos * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			/*UPDATE -> 2024 */,BILLADJU = ISNULL(fac.ImporteTotalAjustado,0)
			--,EARLPYU = CAST(0 AS numeric)
			--,OTHDIS1U = ISNULL(fac.ImporteTotalDescuento,0) / (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			/*UPDATE -> 2024 */ ,OTHDIS1U = ISNULL(fac.ImporteTotalDescuento,0) / V.CantidadKilos
			--,REBATEU = ISNULL(afConcilia.afcRebates,0) / (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			/*UPDATE -> 2024 */ ,REBATEU = ISNULL(afConcilia.afcRebates,0) / V.CantidadKilos
			,DINLFTWU = InFhtV.DINLFTWU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,DWAREHU = InFhtV.DWAREHU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,DINLFTPU_MXN = InFhtV.DINLFTPU_MXN * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,DINLFTPU_USD = InFhtV.DINLFTPU_USD * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,DBROKU = InFhtV.DBROKU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,USBROKU = InFhtV.USBROKU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,INLFPWCU = InFhtV.INLFPWCU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))			
			,USWAREHU = InFhtV.USWAREHU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			--,ImporteFlete = ISNULL(fac.ImpFleteSCargoCliente,0)/ NULLIF(ISNULL(fac.ImporteFactura,0),0) 
			/*UPDATE -> 2024 */,ImporteFlete = ISNULL(fac.ImpFleteSCargoCliente,0)/V.CantidadKilos
			--,ImporteFleteAhorrado = ISNULL(fac.ImpFleteCCargoCliente,0)/ NULLIF(ISNULL(fac.ImporteFactura,0),0)
			/*UPDATE -> 2024 */,ImporteFleteAhorrado = ISNULL(fac.ImpFleteCCargoCliente,0)/V.CantidadKilos
			,emb.CodigoPostal
			,AcronimoEdo = LTRIM(REPLACE(edo.AcronimoEdo,',',''))
			--,Commision = ((ISNULL(CommSAg.ComisionPorCaja,0) * ISNULL(V.CantTotalEmbarcada,0))/ NULLIF(V.CantidadKilos, 0)) * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			/*UPDATE -> 2024 */,Commision = (ISNULL(CommSAg.ComisionPorCaja,0) * V.CantTotalEmbarcada) / NULLIF(V.CantidadKilos,0)
			,AgenteVta = ISNULL(age.ClaveAgente,0) + ' - ' + ISNULL(age.NomAgente,'') + ' ' + ISNULL(age.ApellidoPaterno,'')
			,CREDITU = ISNULL((CONVERT(NUMERIC,DATEDIFF(day, fac.FechaEmbarcado, fac.FechaUltimoPago))/365) * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)) * (Convert(NUMERIC,ISNULL(Config.PorcInteres,0))/100),0)
			,REPACKU = RPCK.CostoPackingPorKilo / (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,INDIRECTS = (Config.PorcGastoVentaIndirecta/100) * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			,FURMANU = ISNULL(Fur.FURCOM+Fur.FURGNA+Fur.FURINT,0)
			,USP = 0			
		INTO #ResultSet																			                                                
		FROM #Furman V
		INNER JOIN MSWSch.MSwTraFActura7				fac WITH(NOLOCK)    ON V.IdFactura = fac.IdFactura
		INNER JOIN MSWSch.MswCatArticulo				art WITH(NOLOCK)	ON art.ClaArticulo		  = V.ClaArticulo 
																			AND art.ClaTipoInventario = 1
		INNER JOIN MSWSch.MSWCatAgente					age WITH(NOLOCK)	ON	age.ClaAgente = fac.ClaAgenteVta
		INNER JOIN MSWSch.MSwCatClienteCuentaEmbarque	emb WITH(NOLOCK)	ON  emb.ClaveClienteCuentaEmbarque = fac.ClaveConsignado
		INNER JOIN MSWSch.MswCatEstado					edo WITH(NOLOCK)	ON  edo.ClaEstadoUnico = fac.ClaEstadoConsignado
		CROSS APPLY(
			SELECT DISTINCT
				det.IdFactura
				,det.ClaArticulo
				,det.NomUnidadPendiente
				,det.PrecioUnitario				
			FROM MSWSch.MSwTraFActuraDet7				det WITH(NOLOCK)
			WHERE det.IdFactura = V.IdFactura
			AND det.ClaArticulo = V.ClaArticulo
		) facD
		CROSS APPLY(
			SELECT 
				Est.ClaArticulo	 
				,Est.IdFactura		 
				,Est.ConnumuArticulo
			FROM [MSWSch].[MSWEstVentasFurman]		Est WITH(NOLOCK)	WHERE  V.ClaArticulo	  = Est.ClaArticulo
																			AND	V.IdFactura		  = Est.IdFactura
																			AND V.ConnumuResuelto = Est.ConnumuArticulo
																		
		) EstV
		CROSS APPLY(
			SELECT 
				DINLFTWU = InFht.DINLFTWU/100
				,DWAREHU = InFht.DWAREHU/100
				,DINLFTPU_MXN = InFht.DINLFTPU_MXN/100
				,DINLFTPU_USD = InFht.DINLFTPU_USD/100
				,DBROKU = InFht.DBROKU/100
				,USBROKU = InFht.USBROKU/100
				,INLFPWCU = InFht.INLFPWCU/100
				,USWAREHU = InFht.USWAREHU/100
			FROM MSWSch.MSWCfgFurmanInlandFreightValoresUsar InFht WITH(NOLOCK)
		) InFhtV	
		OUTER APPLY (
			SELECT Comm.ComisionPorCaja
			FROM MSWCfgFurmanComisionesPorCaja	Comm WITH(NOLOCK)	
			WHERE age.ClaUsuario = Comm.ClaUsuario 
				AND Comm.Anio= YEAR(fac.FechaFactura)
		) CommSAg

		OUTER APPLY (
			SELECT 
				val.PorcInteres
				,val.PorcGastoVentaIndirecta
				,val.ComisionAgenteVenta
				,val.ComisionManagerVenta
				,val.ComisionVPVenta
				,val.ComisionAgIndVenta
			FROM MSWSch.MSWCfgFurmanVentaValoresUsar	val	WITH(NOLOCK)
			WHERE val.Anio = YEAR(fac.FechaFactura)
		)Config	
		OUTER APPLY(
			SELECT 
				est.ClaArticuloClavo		
				,CostoPackingPorKilo = SUM(est.CostoPackingPorKilo)
			FROM [MSWSch].[MSWCfgFurmanRepackingCost] est 
			WHERE
				est.ClaArticuloClavo = V.ClaArticulo
				AND (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) >= @pnAnioMesInicio))
				AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND YEAR(est.FechaVenta)*100+MONTH(est.FechaVenta) <= @pnAnioMesFin))	
			GROUP BY ClaArticuloClavo					
		)RPCK

		OUTER APPLY (
			SELECT TOP 1
				ClaArticulo,FURCOM,FURGNA,FURINT
			FROM [MSWSch].[MSWEstFURCOMFurman]
			WHERE ClaArticulo = V.ClaArticulo
			AND AnioMes >= @pnAnioMesInicio
			AND AnioMes <= @pnAnioMesFin
			ORDER BY AnioMes DESC
		) as Fur

		OUTER APPLY (
			--REBATE
			SELECT 
			--'afc', afc.
				SUM(afc.ImporteAnticipoAplicar) AS afcRebates
				FROM MSWSch.MswRelAnticipoFacturaConcilia7 afc WITH(NOLOCK)
				INNER JOIN MSWSch.MSwTraFActura7 FNg  WITH(NOLOCK) ON afc.IdFacturaAnticipo = FNg.IdFactura
				INNER JOIN MSWSch.MSWTraPreOrdenVenta pov WITH(NOLOCK) ON pov.IdPreORdenVenta = FNg.IdPedido
				WHERE afc.IdFactura = V.IdFactura
				AND pov.ClaTipoPreOrdenVenta = 5 --Rebate / Other
		) AS afConcilia	
		
		UPDATE R
			SET R.QtyXGRSUPRU = (R.CantidadKilos * R.PrecioUnitarioBruto)/(SumQtyXGRSUPRU.SumQtyGRSUPRUValue)
		FROM #ResultSet R 
		CROSS APPLY(
			SELECT 
				SumQtyGRSUPRUValue = SUM(F.CantidadKilos * F.PrecioUnitarioBruto)
			FROM #ResultSet F
			WHERE F.IdFactura = R.IdFactura
			
		) SumQtyXGRSUPRU
				

		UPDATE R
			SET R.BILLADJU = (R.BILLADJU  *  R.QtyXGRSUPRU) /R.CantidadKilos 
		FROM #ResultSet R 

		UPDATE R
			SET USP = PrecioUnitarioBruto + (BILLADJU - OTHDIS1U - REBATEU) - (DINLFTWU + DWAREHU + DINLFTPU_MXN + DBROKU) - USBROKU - INLFPWCU - USWAREHU - ImporteFlete + ImporteFleteAhorrado - COMM
		FROM #ResultSet R 

		/*
			/*Gross Unit Price*/	(facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))																					                      
					+ (																															                      
			/*BILLADJU*/- ((ISNULL(fac.ImporteTotalAjustado,0)/ NULLIF(ISNULL(CantidadKilos,0),0)) / (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
			/*EARLPYU	- CAST(0 AS numeric)*/
			/*EARLPYU & OTHDIS1U*/- ((ISNULL(fac.ImporteTotalDescuento,0)/ NULLIF(ISNULL(CantidadKilos,0),0)) / (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
			/*REBATEU*/	- ((ISNULL(afConcilia.afcRebates,0) / NULLIF(ISNULL(CantidadKilos,0),0)) / (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
					)																			                                                                      
					-(																			                                                                      
			/*DINLFTWU*/(InFhtV.DINLFTWU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
			/*DWAREHU*/	+ (InFhtV.DWAREHU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
	   /*DINLFTPU_MXN*/	+ (InFhtV.DINLFTPU_MXN * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
			/*DBROKU*/	+ (InFhtV.DBROKU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
					)																			                                                                      
			/*USBROKU*/	- (InFhtV.USBROKU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
			/*INLFPWCU*/- (InFhtV.INLFPWCU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
			/*USWAREHU*/- (InFhtV.USWAREHU * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))                                                                                   
			/*INLFWCU*/	- (ISNULL(fac.ImpFleteSCargoCliente,0)/ NULLIF(ISNULL(fac.ImporteFactura,0),0))
			/*FGHTREV*/ + (ISNULL(fac.ImpFleteCCargoCliente,0)/ NULLIF(ISNULL(fac.ImporteFactura,0),0))
			/*COMM*/	- ((ISNULL(CommSAg.ComisionPorCaja,0) * ISNULL(V.CantTotalEmbarcada,0))/ NULLIF(V.CantidadKilos, 0)) * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs))
			/*CREDITU*/ - (ISNULL((CONVERT(NUMERIC,DATEDIFF(day, fac.FechaEmbarcado, fac.FechaUltimoPago))/365) * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)) * (Convert(NUMERIC,ISNULL(Config.PorcInteres,0))/100),0))
		 	/*REPACK*/	- (ISNULL(RPCK.CostoPackingPorKilo,0) * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
		  /*INDIRECTS*/ - ((Config.PorcGastoVentaIndirecta/100) * (facD.PrecioUnitario / (art.PesoTeoricoLbs*@nFactorLbsToKgs)))
		   /*FURMANU*/	- ISNULL(Fur.FURCOM+Fur.FURGNA+Fur.FURINT,0)
		*/

		SELECT
			 V.ClaArticulo			AS [PRODCODU;w=100;a=Center;t=clave;c=PRODCODU]
			,Cat.ClaveArticulo		AS [PRODCODU2;w=120;a=Center;t=clave;c=PRODCODU2]
			,V.NomArticulo			AS [PRODDESCU;w=350;a=Left;c=PRODDESCU]
			,ISNULL(GpoEst.NomGpoEst, 'ND') AS [NAILTYPE;w=150;a=Center;t=clave;c=NAILTYPE]
			,V.ConnumuAlambre 		AS [CONNUMU;w=150;a=Left;t=clave;c=Wire CONNUMU]
			,V.ConnumuAlambron	 	AS [CONNUMU2;w=150;a=Left;t=clave;c=Wire Rod CONNUMU]
			--,V.ConnumuResuelto		AS [CONNUMU;w=150;a=Center;t=clave;c=Wire CONNUMU]
			,V.ClaveConsignado		AS [CUSCODU;w=100;a=Center;t=clave;c=CUSCODU]
			,V.NomConsignado		AS [CUSTNAMEU;w=350;a=Left;c=CUSTNAMEU]
			,V.FechaFactura			AS [SALINDTU;w=100;a=Center;t=clave;c=SALINDTU]
			,V.IdFactura			AS [INVOICEID;w=100;a=Center;t=clave;c=INVOICEID]
			,V.ClaveFactura			AS [INVOICEU;w=100;a=Center;t=clave;c=INVOICEU]			
			,V.FechaEmbarcado		AS [SHIPDATU;w=100;a=Center;t=clave;c=SHIPDATU]
			,V.FechaUltimoPago		AS [PAYDATEU;w=100;a=Center;t=clave;c=PAYDATEU]			
			,V.CantidadKilos		AS [QTYU;w=100;a=Right;t=decimal;d=4;c=QTYU;s=Sum]
			,V.CantTotalEmbarcada	AS [QTY_AS_SOLDU;w=120;a=Right;t=decimal;d=4;c=QTY_AS_SOLDU;s=Sum]
			,V.UOM					AS [QTYUNIT_AS_SOLDU;w=120;a=Center;t=clave;c=QTYUNIT_AS_SOLDU]
			,V.PrecioUnitarioBruto	AS [GRSUPRU;w=100;a=Right;t=decimal;d=4;c=GRSUPRU]
			,V.PrecioUnitario		AS [GRSUPR_AS_SOLDU;w=120;a=Right;t=decimal;d=4;c=GRSUPR_AS_SOLDU]			
			,V.BILLADJU				AS [BILLADJU;w=100;a=Right;t=decimal;d=4;c=BILLADJU]			
			,V.OTHDIS1U				AS [OTHDIS1U;w=100;a=Right;t=decimal;d=4;c=OTHDIS1U & EARLPYU]
			,V.REBATEU				AS [REBATEU;w=100;a=Right;t=decimal;d=4;c=REBATEU]
			,V.DINLFTWU				AS [DINLFTWU;w=80;a=Right;t=decimal;d=4;c=DINLFTWU]
			,V.DWAREHU				AS [DWAREHU;w=80;a=Right;t=decimal;d=4;c=DWAREHU]
			,V.DINLFTPU_MXN			AS [DINLFTPU_MXN;w=100;a=Right;t=decimal;d=4;c=DINLFTPU_MXN]
			,V.DINLFTPU_USD			AS [DINLFTPU_USD;w=100;a=Right;t=decimal;d=4;c=DINLFTPU_USD]
			,V.DBROKU				AS [DBROKU;w=80;a=Right;t=decimal;d=4;c=DBROKU]
			,V.USBROKU				AS [USBROKU;w=80;a=Right;t=decimal;d=4;c=USBROKU]
			,V.INLFPWCU				AS [INLFPWCU;w=80;a=Right;t=decimal;d=4;c=INLFPWCU]
			,V.USWAREHU				AS [USWAREHU;w=80;a=Right;t=decimal;d=4;c=USWAREHU]
			,V.ImporteFlete			AS [INLFCU;w=80;a=Right;t=decimal;d=4;c=INLFCU]
			,V.ImporteFleteAhorrado	AS [FGHTREV;w=80;a=Right;t=decimal;d=4;c=FGHTREV]
			,V.CodigoPostal			AS [DESTU;w=80;a=Center;t=clave;c=DESTU]
			,V.AcronimoEdo			AS [STATEU;w=60;a=Center;t=clave;c=STATEU]
			,V.Commision			AS [COMM;w=80;a=Right;t=decimal;d=4;c=COMM]
			,V.AgenteVta			AS [SELAGENU;w=300;a=Left;c=SELAGENU]
			,V.CREDITU				AS [CREDITU;w=80;a=Right;t=decimal;d=4;c=CREDITU]
			,V.REPACKU				AS [REPACKU;w=100;a=Right;t=decimal;d=4;c=REPACKU]
			,V.INDIRECTS			AS [INDIRECTS;w=100;a=Right;t=decimal;d=4;c=INDIRECTS]
			,V.FURMANU				AS [FURMANU;w=100;a=Right;t=decimal;d=4;c=FURMANU]
			,V.USP					AS [USP;w=100;a=Right;t=decimal;d=4;c=USP]
		FROM #ResultSet V
		INNER JOIN MSWSch.MSWCatArticulo Cat WITH(NOLOCK) ON V.ClaArticulo = Cat.ClaArticulo
		--INNER JOIN [MSWSch].[MswCatGrupoEstadistico] GpoEst WITH(NOLOCK) ON Cat.ClaGrupoEstadistico2 = GpoEst.ClaGrupoEstadistico

		OUTER APPLY(
			SELECT TOP 1
				ClaGpoEst = GpoEstCat.ClaGrupoEstadistico,
				NomGpoEst = GpoEstCat.NombreGrupoEstadisticoIngles
			FROM [MSWSch].[MswCatGrupoEstadistico] GpoEstCat WITH(NOLOCK) 
			WHERE GpoEstCat.ClaGrupoEstadistico = Cat.ClaGrupoEstadistico2
			ORDER BY NivelActual ASC
		) AS GpoEst
		--WHERE V.IdFactura = 2405728	

		ORDER BY V.FechaFactura ASC

		--SELECT		--	PRODCODU,PRODCODU2,PRODDESCU,NAILTYPE,CONNUMU,CONNUMU2,CUSCODU,CUSTNAMEU,SALINDTU,INVOICEID,INVOICEU,QTYU,QTY_AS_SOLDU,QTYUNIT_AS_SOLDU,GRSUPRU,GRSUPR_AS_SOLDU,BILLADJU, OTHDIS1U, REBATEU 		--FROM #ResultSet WHERE INVOICEID = 2405728		
		

	DROP TABLE #Factura7Vw
	DROP TABLE #Furman


END
