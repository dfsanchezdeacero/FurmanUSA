CREATE TABLE [OPESch].[OPETraFurmanGastos](
	[IdFurmanGastos] [int] NOT NULL,
	[ClaAnioMes] [int] NOT NULL,
	[ClaUbicacion] [int] NOT NULL,
	[ClaCrc] [int] NOT NULL,	
	[ClaElementoCosto] [int] NOT NULL,
	[ClaTipoGasto] [int] NOT NULL,
	[ImpManufacturaDir]	NUMERIC(22,8),
	[ImpManufacturaInd]	NUMERIC(22,8),
	[TonsProd]			NUMERIC(22,8),
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
 CONSTRAINT [PK_OPETraFurmanGastos] PRIMARY KEY CLUSTERED 
(
	[IdFurmanGastos],[ClaAnioMes],[ClaUbicacion],[ClaCrc],[ClaElementoCosto],[ClaTipoGasto] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OPESch].[OPETraFurmanGastos] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OPESch].[OPETraFurmanGastos] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO


