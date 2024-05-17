CREATE TABLE [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes](
	[ClaAnioMes] [int] NOT NULL,
	[ClaUbicacion] [int] NOT NULL,
	[IdFacturaDEA] [int] NOT NULL,
	[NumFacturaDEA] [varchar](100) NULL,
	[FechaFacturaDEA] [datetime] NULL,
	[IdViaje] [int] NOT NULL,
	[FechaEmbarque] [datetime] NULL,
	[ClaCategoria] [int] NULL,
	[CantidadKgs] [numeric](22, 4) NULL,
	[ImporteFlete] [numeric](22, 4) NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,			
 CONSTRAINT [PK_MSWTraFurmanFreightToMCSWAnioMes] PRIMARY KEY CLUSTERED 
(
	[ClaAnioMes],[IdFacturaDEA],[ClaUbicacion],[IdViaje] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO


