ALTER PROCEDURE [MSWSch].[MSWFreightFromHoustonToPasadenaSrv]
	@pnAnioMesInicio	INT, 
	@pnAnioMesFin		INT,
	@pnClaUbicacion		INT = 65
AS
BEGIN
	SET NOCOUNT ON 

	SELECT	   
		AnioMes,
		FechaTabular = CONVERT(date,  convert(datetime,  FechaTabular )),
		ClaSemana,
		NomSemana,
		ClaAgrupador1,
		NomAgrupador1,
		ClaAgrupador2,
		NomAgrupador2,
		ClaUbicacion,
		NomUbicacion,
		(Tons),
		(ImportePagarFinalUSD),
		NumViaje,
		TonsCubicadas,
		MillasViaje,
		ClaTransporte,
		NomTransporte,
		ClaTransportista,
		NomTransportista,
		ClaCiudadDestino,
		NomCiudadDestino,
		ClaEstadoDestino,
		NomEstadoDestino 
	FROM   USADATALake.MCSW_SST.MSWSch.MSWSSTFreightMXAndUSVw WITH(NOLOCK) 
	WHERE ANIOMES >= @pnAnioMesInicio 
	AND ANIOMES <= @pnAnioMesFin
	AND ClaUbicacion = @pnClaUbicacion
	ORDER BY AnioMes ASC, ClaAgrupador1 ASC, ClaAgrupador2 ASC

	SET NOCOUNT OFF
END

