select IdViaje, IdFactura,  *from  opesch.OPETraMovEntSal where idfabricacion =  24414597

--1 Si genera

--4 o 5 Customer Pickup


SELECT IdViaje, IdPlanCarga, * FROM [OPESch].[OpeTraViajevw] WHERE ClaTipoViaje = 5 AND ClaEstatus = 3
SELECT DISTINCT ClaTipoViaje FROM [OPESch].[OpeTraViajevw] WHERE ClaEstatus = 3  AND YEAR(FechaHrFactura) > 2022