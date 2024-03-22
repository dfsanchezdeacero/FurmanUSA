CREATE TABLE [MSWSch].[MSWEstFURCOMFurman](
	[Anio] [int] NOT NULL,
	[ClaArticulo] [int] NOT NULL,
	[FURCOM] [numeric](22, 8) NULL,
	[FURGNA] [numeric](22, 8) NULL,
	[FURINT] [numeric](22, 8) NULL,
	[FechaCalculo] [datetime] NOT NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
 CONSTRAINT [PK_MSWEstFURCOMFurman] PRIMARY KEY CLUSTERED 
(
	[Anio] ASC,
	[ClaArticulo] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [MSWSch].[MSWEstFURCOMFurman] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [MSWSch].[MSWEstFURCOMFurman] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO


