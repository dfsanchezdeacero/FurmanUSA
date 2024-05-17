CREATE TABLE [MSWSch].[MSWOpeTraMovSalidaTabularDet](
	[ClaUbicacion] [int] NOT NULL,
	[IdMovEntSal] [int] NOT NULL,
	[ClaArticulo] [int] NOT NULL,
	[IdEntSalDet] [int] NOT NULL,
	[IdFabricacion] [int] NULL,
	[IdFabricacionDet] [int] NULL,
	[PesoEmbarcado] [numeric](22, 4) NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
 CONSTRAINT [PK_MSWOpeTraMovSalidaTabularDet] PRIMARY KEY CLUSTERED 
(
	[ClaUbicacion] ASC,
	[IdMovEntSal] ASC,
	[ClaArticulo] ASC,
	[IdEntSalDet] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


