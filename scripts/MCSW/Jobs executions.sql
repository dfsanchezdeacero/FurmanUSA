BEGIN TRAN DFSS

	DELETE FROM [OpeSch].[OpeFreightFromPasadenaToLocation]
	DELETE FROM [OpeSch].[OpeFreightFromHoustonToLocation]

	EXEC [OpeSch].[OPEGetFreightsUSALocations] 
		@pnClaUbicacion	  = 65 
		,@pnClaUsuarioMod = 1
		,@psNombrePcMod	  = 'FURMAN JOB'

	EXEC [OpeSch].[OPEGetFreightsUSALocations] 
		@pnClaUbicacion = 449
		,@pnClaUsuarioMod = 1
		,@psNombrePcMod	  = 'FURMAN JOB'

	SELECT * FROM [OpeSch].[OpeFreightFromPasadenaToLocation] ORDER BY FechaUltimaMod, AnioMes DESC
	SELECT * FROM [OpeSch].[OpeFreightFromHoustonToLocation] ORDER BY FechaUltimaMod, AnioMes DESC

ROLLBACK TRAN DFSS

--SELECT * INTO [OpeSch].[OpeFreightFromPasadenaToLocation_BAK]
--FROM [OpeSch].[OpeFreightFromPasadenaToLocation]

--SELECT * INTO [OpeSch].[OpeFreightFromHoustonToLocation_BAK]
--FROM [OpeSch].[OpeFreightFromHoustonToLocation]

