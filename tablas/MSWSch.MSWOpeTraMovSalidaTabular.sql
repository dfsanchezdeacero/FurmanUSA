CREATE TABLE [MSWSch].[MSWOpeTraMovSalidaTabular](
	[ClaUbicacion] [int] NOT NULL,
	[IdMovEntSal] [int] NOT NULL,
	[FechaEntSal] [datetime] NULL,
	[IdEntSal] [int] NULL,
	[IdViaje] [int] NULL,
	[PesoEmbarcado] [numeric](22, 4) NULL,
	[IdFactura] [int] NULL,
	[IdFacturaAlfanumerico] [varchar](20) NULL,
	[KgsPagar] [numeric](22, 4) NULL,
	[ImportePagarFinal] [numeric](22, 4) NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
 CONSTRAINT [PK_MSWOpeTraMovSalidaTabular] PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[IdMovEntSal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


