CREATE TABLE [MSWSch].[MSWCfgFurmanREPACKURatio](
	[Anio] [int] NOT NULL,
	[ClaGpoEst2] [int] NOT NULL,
	[ClaGpoEst3] [int] NOT NULL,
	[REPACKURatio] [numeric](22, 6) NULL,
	[BajaLogica] [tinyint] NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
 CONSTRAINT [PK_MSWCfgFurmanREPACKURatio] PRIMARY KEY CLUSTERED 
(
	[Anio],[ClaGpoEst2], [ClaGpoEst3] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [MSWSch].[MSWCfgFurmanREPACKURatio] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [MSWSch].[MSWCfgFurmanREPACKURatio] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO

