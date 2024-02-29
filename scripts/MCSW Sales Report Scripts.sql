/*
SELECT ClaGrupoEstadistico1, ClaGrupoEstadistico2,ClaGrupoEstadistico3,* FROM MSWSch.MSWCatArticulo WITH(NOLOCK) WHERE ClaArticulo 
IN (721230, 711551)
IN (610016
,610033
,614631
,615744
,600020
,600036
,614711
,610343)
--= 600015

SELECT * FROM [MSWSch].[MswCatGrupoEstadistico] WHERE ClaGrupoEstadistico IN (202, 201)

SELECT * FROM [MSWSch].[MswRelGrupoEstadistico] WHERE Cla_GpoEstadistico IN (202, 292)

SELECT * FROM MSWSCh.MSWCatCategoriaVw WHERE ClaCategoria = 42
SELECT * FROM MSWSCh.MSWCatFamiliaVw WHERE ClaFamilia = 347
SELECT * FROM MSWSCh.MSWCatSubFamiliaVw WHERE  ClaFamilia = 347 AND ClaSubFamilia = 1


CREATE PROC MSWSCh.MSW_FGV_TEST_PROCASBEGIN SELECT 1,2,3END*/CREATE TABLE #tmpProc (

    PRODCODU  INT
    ,PRODCODU2  VARCHAR(100)
    ,PRODDESCU  VARCHAR(100)
    ,NAILTYPE  VARCHAR(100)
    ,CONNUMU  VARCHAR(100)
    ,CONNUMU2  VARCHAR(100)
    ,CUSCODU  VARCHAR(100)
    ,CUSTNAMEU  VARCHAR(100)
    ,SALINDTU  DATETIME
    ,INVOICEID  VARCHAR(100)
    ,INVOICEU  VARCHAR(100)
    ,SHIPDATU  DATETIME
    ,PAYDATEU  DATETIME
    ,QTYU  DECIMAL(22,4)
    ,QTY_AS_SOLDU  DECIMAL(22,4)
    ,QTYUNIT_AS_SOLDU   VARCHAR(100)
    ,GRSUPRU  DECIMAL(22,4)
    ,GRSUPR_AS_SOLDU DECIMAL(22,4)
    ,BILLADJU  DECIMAL(22,4)
    ,OTHDIS1U  DECIMAL(22,4)
    ,REBATEU  DECIMAL(22,4)
    ,DINLFTWU  DECIMAL(22,4)
    ,DWAREHU  DECIMAL(22,4)
    ,DINLFTPU_MXN  DECIMAL(22,4)
    ,DINLFTPU_USD  DECIMAL(22,4)
    ,DBROKU  DECIMAL(22,4)
    ,USBROKU  DECIMAL(22,4)
    ,INLFPWCU  DECIMAL(22,4)
    ,USWAREHU  DECIMAL(22,4)
    ,INLFWCU  DECIMAL(22,4)
    ,FGHTREV  DECIMAL(22,4)
    ,DESTU VARCHAR(100)
    ,STATEU  VARCHAR(100)
    ,COMM  DECIMAL(22,4)
    ,SELAGENU  VARCHAR(100)
    ,CREDITU  DECIMAL(22,4)
    ,REPACKU  DECIMAL(22,4)
    ,INDIRECTS  DECIMAL(22,4)
    ,FURMANU  DECIMAL(22,4)
    ,USP  DECIMAL(22,4)
)INSERT INTO #tmpProc
EXEC [MSWSch].[MSW_CU423_Pag12_Grid_GridGenerico_Sel]
 @pnAnioMesInicio		= 202308
,@pnAnioMesFin			= 202308
,@pnVendor				= 275SELECT PRODCODU	
,PRODCODU2	
,PRODDESCU	
,NAILTYPE	
,CONNUMU	
,CONNUMU2	
--,CUSCODU	
--,CUSTNAMEU	
--,SALINDTU	
,INVOICEID	
--,INVOICEU	
--,SHIPDATU	
--,PAYDATEU	
,QTYU	
,QTY_AS_SOLDU	
,QTYUNIT_AS_SOLDU	
,GRSUPRU	
,GRSUPR_AS_SOLDU	
--,BILLADJU	
--,OTHDIS1U	
--,REBATEU	
--,DINLFTWU	
--,DWAREHU	
--,DINLFTPU_MXN	
--,DINLFTPU_USD	
--,DBROKU	
--,USBROKU	
--,INLFPWCU	
--,USWAREHU	
,INLFWCU	
,FGHTREV	
--,DESTU	
--,STATEU	
,COMM	
--,SELAGENU	
--,CREDITU	
--,REPACKU	
--,INDIRECTS	
--,FURMANU	
--,USP
FROM #tmpProc--WHERE COMM > 0WHERE INVOICEID IN (2409516)																																								DROP TABLE #tmpProc--SELECT TOp 100 ImporteFlete,ImpFleteCCargoCliente,ImpFleteSCargoCliente,* FROM MSWSch.MSwTraFActura7 WHERE IdFactura IN (2417603) --2409516,2413309--SELECT * FROM MSWSch.MSwTraFActura7 WHERE IdFactura IN (2409516,2413309)--FletePropCobrado--Dependiendo el campo neto --Si el FleteCargoCliente es negativo, sumar --Los fletes tiene utilidad, por eso salen negativos--estoy cobrandole de mas al transportista de lo que nos costo --sp_helptext 'MSWSch.AreRelConnumArticuloVw'--SELECT * FROM MSWSch.AreRelConnumArticuloVw-- SELECT * FROM TiCatalogo.dbo.AreRelConnumArticulo (NOLOCK)  