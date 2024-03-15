USE [MCSW_ERP]
GO

/****** Object:  Table [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario]    Script Date: 3/14/2024 3:54:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario](	
	[IdCuentaContable] [int] NOT NULL,
	[Descripcion] [varchar](100) NULL,
	[BajaLogica] [tinyint] NOT NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
	[ClaUsuarioMod] [int] NOT NULL,
 CONSTRAINT [PK_MSWCfgFurmanCuentaContableGastosOntario] PRIMARY KEY CLUSTERED 
(	
	[IdCuentaContable] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] ADD  DEFAULT ((0)) FOR [BajaLogica]
GO

ALTER TABLE [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO


