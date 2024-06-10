SELECT * FROm [OPESch].[OPETraFurmanGastos] ORDER BY FechaUltimaMod, ClaAnioMes DESC
SELECT * FROM [OPESch].[OPETraFurmanProduccion] ORDER BY FechaUltimaMod, ClaAnioMes DESC
SELECT * FROM [OPESch].[OPETraFurmanProduccionFURPACK] ORDER BY FechaUltimaMod, ClaAnioMes DESC
SELECT * FROM [OPESch].[OPETraFurmanCostoEmbalaje] ORDER BY FechaUltimaMod, ClaAnioMes DESC

DELETE FROM [OPESch].[OPETraFurmanGastos]
DELETE FROM [OPESch].[OPETraFurmanProduccion]
DELETE FROM [OPESch].[OPETraFurmanProduccionFURPACK]
DELETE FROM [OPESch].[OPETraFurmanCostoEmbalaje]

--SELECT * INTO [OPESch].[OPETraFurmanGastos_BAK2]
--FROM [OPESch].[OPETraFurmanGastos]

--SELECT * INTO [OPESch].[OPETraFurmanProduccion_BAK]
--FROM [OPESch].[OPETraFurmanProduccion]

--SELECT * INTO [OPESch].[OPETraFurmanProduccionFURPACK_BAK]
--FROM [OPESch].[OPETraFurmanProduccionFURPACK]

--SELECT * INTO [OPESch].[OPETraFurmanCostoEmbalaje_BAK]
--FROM [OPESch].[OPETraFurmanCostoEmbalaje]


		
BEGIN TRAN DFSS

	EXEC [OPESch].[OPEObtenerGastoPropioCRCFurman]
		@pnClaUsuarioMod	 = 1
		,@psNombrePcMod		 = 'JOB- FURMAN'
		,@pnClaUbicacion     = 65
		,@psIdioma           = 'ENGLISH'

	SELECT * FROm [OPESch].[OPETraFurmanGastos] ORDER BY FechaUltimaMod, ClaAnioMes DESC

ROLLBACK TRAN DFSS

BEGIN TRAN DFSS
	
EXEC [OPESch].[OPEObtenerProduccionFurman] 	
	@pnClaUsuarioMod	 = 1
	,@psNombrePcMod		 = 'JOB- FURMAN'
	,@pnClaUbicacion     = 65
	,@psIdioma           = 'ENGLISH'

	SELECT * FROM [OPESch].[OPETraFurmanProduccion] ORDER BY FechaUltimaMod, ClaAnioMes DESC

ROLLBACK TRAN DFSS


BEGIN TRAN DFSS

	--EXEC [OPESch].[OPEObtenerProduccionFURPACKFurman]
	--	@pnClaUsuarioMod	 = 1
	--	,@psNombrePcMod		 = 'JOB- FURMAN'
	--	,@pnClaUbicacion     = 65
	--	,@psIdioma           = 'ENGLISH'

	EXEC [OPESch].[OPEObtenerProduccionFURPACKFurman]
		@pnClaUsuarioMod	 = 1
		,@psNombrePcMod		 = 'JOB- FURMAN'
		,@pnClaUbicacion     = 65
		,@psIdioma           = 'ENGLISH'

	SELECT * FROM [OPESch].[OPETraFurmanProduccionFURPACK] ORDER BY FechaUltimaMod, ClaAnioMes DESC

ROLLBACK TRAN DFSS

BEGIN TRAN DFSS

	EXEC [OPESch].[OPEObtenerCostoEmbalajeFurman]
		@pnClaUsuarioMod	 = 1
		,@psNombrePcMod		 = 'JOB- FURMAN'
		,@pnClaUbicacion     = 65
		,@psIdioma           = 'ENGLISH'

	SELECT * FROM [OPESch].[OPETraFurmanCostoEmbalaje] ORDER BY FechaUltimaMod, ClaAnioMes DESC


ROLLBACK TRAN DFSS

