CREATE TABLE [OPESch].[OPECfgFurmanInlandFreightRates](
	[Anio] [int] NOT NULL,	
	
	[DINLFTWU_MX] [numeric](22, 6) NULL,
	[DWAREHU_MX] [numeric](22, 6) NULL,
	[DINLFTPU_MXN] [numeric](22, 6) NULL,
	[DBROKU_MX] [numeric](22, 6) NULL,
	[USBROKU] [numeric](22, 6) NULL,
	[INLFPWCU_L] [numeric](22, 6) NULL,
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


