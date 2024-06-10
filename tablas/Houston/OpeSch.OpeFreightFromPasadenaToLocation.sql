CREATE TABLE [OpeSch].[OpeFreightFromPasadenaToLocation](
	IdFreightPas INT
	,AnioMes		  INT
	,FechaTabular DATETIME
	,ClaSemana INT
	,NomSemana VARCHAR(300)
	,ClaAgrupador1 INT
	,NomAgrupador1 VARCHAR(300)
	,ClaAgrupador2 INT
	,NomAgrupador2 VARCHAR(300)
	,ClaUbicacion INT
	,NomUbicacion VARCHAR(300)
	,Tons NUMERIC(22,6)
	,ImportePagarFinalUSD NUMERIC(22,4)
	,NumViaje INT
	,TonsCubicadas NUMERIC(22,6)
	,MillasViaje NUMERIC(22,4)
	,ClaTransporte INT
	,NomTransporte VARCHAR(300)
	,ClaTransportista INT
	,NomTransportista VARCHAR(300)
	,ClaCiudadDestino INT
	,NomCiudadDestino VARCHAR(300)
	,ClaEstadoDestino INT 
	,NomEstadoDestino VARCHAR(300)
	,FechaUltimaMod datetime NOT NULL
	,NombrePcMod VARCHAR(64) NOT NULL
	,ClaUsuarioMod int NOT NULL
 CONSTRAINT [PK_OpeFreightFromPasadenaToLocation] PRIMARY KEY CLUSTERED 
(
	[IdFreightPas] ASC
	
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OpeSch].[OpeFreightFromPasadenaToLocation] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OpeSch].[OpeFreightFromPasadenaToLocation] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO