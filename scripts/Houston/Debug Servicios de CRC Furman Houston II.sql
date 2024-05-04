/*

	TRUNCATE TABLE [OPESch].[OPETraFurmanProduccion]
	TRUNCATE TABLE [OPESch].[OPETraFurmanProduccionFURPACK]
	TRUNCATE TABLE [OPESch].[OPETraFurmanGastos]
	TRUNCATE TABLE [OPESch].[OPETraFurmanCostoEmbalaje]

	DELETE FROM [OPESch].[OPETraFurmanProduccion]
	GO
	DELETE FROM [OPESch].[OPETraFurmanProduccionFURPACK]
	GO
	DELETE FROM [OPESch].[OPETraFurmanGastos]
	GO
	DELETE FROM [OPESch].[OPETraFurmanCostoEmbalaje]


	EXEC [OPESch].[OPEObtenerProduccionFurman]
	EXEC [OPESch].[OPEObtenerGastoPropioCRCFurman]
	EXEC [OPESch].[OPEObtenerProduccionFURPACKFurman]
	EXEC [OPESch].[OPEObtenerCostoEmbalajeFurman]

*/



SELECT ClaAnioMes,ClaCrc, ClaElementoCosto, Gasto = SUM(Importe), TonsProd = SUM(ProdTonsArticuloBase)
FROM [OPESch].[OPETraFurmanProduccion] WITH(NOLOCK)
WHERE ClaCrc = 4133 AND ClaElementoCosto = 4 --AND ClaAnioMes > 202401
GROUP BY ClaAnioMes,ClaCrc, ClaElementoCosto
ORDER BY ClaAnioMes

SELECT ClaAnioMes,ClaCrc, ClaElementoCosto, Gasto = SUM(Importe), TonsProd = SUM(ProdTonsArticuloBase)
FROM [OPESch].[OPETraFurmanProduccionFURPACK] WITH(NOLOCK)
WHERE ClaCrc = 4133 --AND ClaElementoCosto = 4 --AND ClaAnioMes > 202401
GROUP BY ClaAnioMes,ClaCrc, ClaElementoCosto
ORDER BY ClaAnioMes

	
SELECT ClaAnioMes,ClaCrc,ClaElementoCosto, GastoPropio = SUM(ImpManufacturaDir), GastoAsginado = SUM(ImpManufacturaInd), TonsProd
FROM [OPESch].[OPETraFurmanGastos] WITH(NOLOCK)
WHERE ClaCrc = 4133 AND ClaElementoCosto = 4 --AND ClaAnioMes = 202312
GROUP BY ClaAnioMes,ClaCrc, ClaElementoCosto, TonsProd
ORDER BY ClaAnioMes


SELECT *
FROM [OPESch].[OPERelConceptoFurmanCrc] Rel
WHERE IdConceptoFurman = 1