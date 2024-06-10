CREATE TABLE [MSWSch].[MSWCfgFurmanInlandFreightRates](
	[Anio] [int] NOT NULL,
	[DINLFTWU_MXN] [numeric](22, 6) NULL,
	[DWAREHU_MXN] [numeric](22, 6) NULL,
	[DINLFTPU_MXN] [numeric](22, 6) NULL,
	[DBROKU_MXN] [numeric](22, 6) NULL, 
	[USBROKU] [numeric](22, 6) NULL,
	[INLFPWU_L] [numeric](22, 6) NULL,
	[USWAREHU_L] [numeric](22, 6) NULL, 
	[BajaLogica] [tinyint] NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Anio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



