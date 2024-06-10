CREATE TABLE #tmpResultsMICS(
	IdFactura INT
	,ClaveFactura VARCHAR(250)
	,ClaArticulo INT
	,ClaveArticulo VARCHAR(20)
	,NomArticulo VARCHAR(250)
	,Connumu VARCHAR(250)
	,PesoLbs NUMERIC(22,4)
	,PesoKgs  NUMERIC(22,4)
	,CajasSold  NUMERIC(22,4)
	,KgsSold  NUMERIC(22,4)
	,CajasFURMAN  NUMERIC(22,4)
	,KgsFURMAN  NUMERIC(22,4)
)

INSERT INTO #tmpResultsMICS
EXEC [MSWSch].[MSW_CU99_Pag50_ObtenerProduccionFacturadaDEACEROFurman_Sel]
	@pnAnioMesInicio		= 202301
	,@pnAnioMesFin			= 202301
	,@nIdFactura			= 0
	,@pnClaProveedor		= 275

SELECT 
	IdFactura
	,Kilos = SUM(KgsSold)
	,Cajas = SUM(CajasSold)--ClaArticulo--Cant = COUNT(IdFactura)
INTO #tmpResultsMICSDistinct
FROM #tmpResultsMICS
--WHERE CajasFURMAN > 0 AND KgsFURMAN > 0 
GROUP BY IdFactura
ORDER BY IdFactura 

SELECT '#tmpResultsMICSDistinct',* FROM #tmpResultsMICSDistinct

CREATE TABLE #tmpResultsReport(
	ClaArticulo	INT,ClaveArticulo VARCHAR(20)
	,NomArticulo VARCHAR(250)
	,TipoClavo VARCHAR(250)
	,ConnumuAlambre VARCHAR(250)	
	,ConnumuAlambron VARCHAR(250)
	,WireSource VARCHAR(20)
	,ClaveConsignado VARCHAR(20)
	,NomConsignado VARCHAR(250)
	,FechaFactura DATETIME 		
	,IdFactura INT	
	,ClaveFactura VARCHAR(20)		
	,FechaEmbarcado	DATETIME
	,FechaUltimoPago DATETIME	
	,CantidadKilos NUMERIC(22,4)
	,CantTotalEmbarcada NUMERIC(22,4)
	,UOM VARCHAR(20)
	,PrecioUnitarioBruto NUMERIC(22,4)
	,PrecioUnitario	NUMERIC(22,4)	
)

INSERT INTO #tmpResultsReport
EXEC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]
 @pnAnioMesInicio		 = 202301
,@pnAnioMesFin			 = 202301
,@pnVendor				 = 275
,@pnDepto				 = 0
,@pnEsDebug				= 2
,@pnSoloAlamabreMx		= 0

SELECT 
IdFactura
,Kilos = SUM(CantidadKilos)
,Cajas = SUM(CantTotalEmbarcada)--ClaArticulo--Cant = COUNT(IdFactura)
INTO #tmpResultsReportDictinct
FROM #tmpResultsReport 
GROUP BY IdFactura
ORDER BY IdFactura

SELECT '#tmpResultsReportDictinct',* FROM #tmpResultsReportDictinct

SELECT DISTINCT
--	,M.ClaArticulo AS 'M.ClaArticulo'
	M.IdFactura AS 'MIdFactura'
	,R.IdFactura AS 'RIdFactura'
	,M.Kilos AS 'MKilos'
	,R.Kilos AS 'RKilos'
	,DiffKilos = M.Kilos - R.Kilos
	,M.Cajas AS 'MCajas'
	,R.Cajas AS 'RCajas'
	,DiffCajas = M.Cajas - R.Cajas
--	,R.ClaArticulo AS 'R.ClaArticulo' 
INTO #Totaldiff
FROM #tmpResultsMICSDistinct M 
INNEr JOIN #tmpResultsReportDictinct R  ON M.IdFactura = R.IdFactura									  
ORDER BY M.IdFactura

SELECT * FROM #Totaldiff WHERE DiffCajas <> 0 AND DiffKilos <> 0
SELECT SUM(DiffKilos), SUM(DiffCajas) FROM #Totaldiff

DROP TABLE #tmpResultsMICS
DROP TABLE #tmpResultsMICSDistinct
DROP TABLE #tmpResultsReport
DROP TABLE #tmpResultsReportDictinct
DROP TABLE #Totaldiff