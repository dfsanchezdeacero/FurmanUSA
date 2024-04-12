select IdViaje, IdFactura,  *from  opesch.OPETraMovEntSal where idfabricacion =  24414597select IdViaje, IdPlanCarga, *from  [OPESch].[OpeTraViajevw]	where idviaje =  60810select top 1 * from opesch.opetraordenenvio where  idviaje =  60810--[OPESch].[OpeTraViajevw].[ClaTipoViaje]

--1 Si genera

--4 o 5 Customer Pickup


SELECT IdViaje, IdPlanCarga, * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 5 AND ClaEstatus = 3SELECT TOP 100 IdViaje, IdPlanCarga, * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 1 															AND ClaEstatus = 3 															AND IdNumTabular IS NOT NULL --OR IdNumTabular = 0)															AND IdPlanCarga IS NOT NULL															ORDER BY FechaHrFactura DESCSELECT * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 1 AND ClaEstatus = 3  AND YEAR(FechaHrFactura) > 2022SELECT * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 2 AND  ClaEstatus = 3  AND YEAR(FechaHrFactura) > 2022SELECT * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 3 AND  ClaEstatus = 3  AND YEAR(FechaHrFactura) > 2022SELECT * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 4 AND  ClaEstatus = 3  AND YEAR(FechaHrFactura) > 2022SELECT * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 5 AND  ClaEstatus = 3  AND YEAR(FechaHrFactura) > 2022SELECT * FROM [OPESch].[OpeCatTipoViajeVw] 
SELECT DISTINCT ClaTipoViaje FROM [OPESch].[OpeTraViajevw] WHERE ClaEstatus = 3  AND YEAR(FechaHrFactura) > 2022--[OPESch].[OPEFleTraTabularVw]