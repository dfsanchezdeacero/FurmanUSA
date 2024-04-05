SELECT 
	*
	--(Cmp.PorcComposicion/100.0) AS PorcComposicion,
	--Are.ConnumConGuiones AS ConnumConGuiones
FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Are.ClaArticulo = Cmp.ClaArticuloComp
WHERE Cmp.ClaArticulo = 522790

SELECT * FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
WHERE Cmp.ClaArticulo = 522790

SELECT * FROM OPESch.AreRelConnumArticulo WHERE ClaArticulo = 282340
SELECT * FROM OPESch.AreRelConnumArticulo WHERE ClaArticulo = 539933
SELECT * FROM OPESch.AreRelConnumArticulo WHERE ClaArticulo = 539934
SELECT * FROM OPESch.AreRelConnumArticulo WHERE ClaArticulo = 539935

 SELECT 
	--Cmp.ClaArticuloComp AS ConnumConGuiones
	--TOP 1 
	SUM (Cmp.PorcComposicion/100.0) AS PorcComposicion,
	Are.ConnumConGuiones AS ConnumConGuiones
FROM [PALSch].[PALManRelArticuloComposicionInfoVw] Cmp WITH(NOLOCK)
INNER JOIN OPESch.AreRelConnumArticulo Are WITH(NOLOCK) ON Are.ClaArticulo = Cmp.ClaArticuloComp
WHERE Cmp.ClaArticulo = 501815
GROUP BY Are.ConnumConGuiones


EXEC [OPESch].[OpeCalcularReporteFurmanPorPeriodo]
	 @pnAnioMesInicio		= 202301
	,@pnAnioMesFin			= 202312
	,@pnDpto                = NULL
	--,@EsCalculaFURCOM       INT = 0
	--,@pnClaUbicacion		INT = 65
	,@pnEsDebug             = 0

SELECT * FROM [OPESch].[OPETraFurmanProduccionFURPACK] P WITH(NOLOCK) WHERE ClaArticulo = 501815 ORDER BY ClaAnioMes

dbo.sp_buscatexto '%OPETraFurmanCostoEmbalaje%'

SELECT * FROM [OPESch].[OpeCatFurmanConfiguracion] WHERE ClaConfiguracion = 3

EXEC [DEAFYSA].[Costos].[CTSSch].[CTSK_CostoManufacturaFurman_Prc]
@pnClaAnioMes = 202301,@pnClaUbicacion = 65,@pnIdioma = 'ENGLISH',@psClaTipoGastos = '410, 411, 705,872'