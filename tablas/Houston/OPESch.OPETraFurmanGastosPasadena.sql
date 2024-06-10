USE [Operacion]
GO

/****** Object:  Table [OPESch].[OPETraFurmanProduccion]    Script Date: 4/29/2024 4:54:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [OPESch].[OPETraFurmanGastosPasadena](
	ClaAnio INT
	,Descripcion VARCHAR(500)
	,SaldoInicial NUMERIC(22,4)
	,Mes1  NUMERIC(22,4)
	,Mes2  NUMERIC(22,4)
	,Mes3  NUMERIC(22,4)
	,Mes4  NUMERIC(22,4)
	,Mes5  NUMERIC(22,4)
	,Mes6  NUMERIC(22,4)
	,Mes7  NUMERIC(22,4)
	,Mes8  NUMERIC(22,4)
	,Mes9  NUMERIC(22,4)
	,Mes10 NUMERIC(22,4)
	,Mes11 NUMERIC(22,4)
	,Mes12 NUMERIC(22,4)
	,SaldoFinal NUMERIC(22,4)
	,FechaUltimaMod datetime NOT NULL
	,NombrePcMod varchar(64) NOT NULL
	,ClaUsuarioMod int NOT NULL
 ,CONSTRAINT [PK_OPETraFurmanGastosPasadena] PRIMARY KEY CLUSTERED 
(
	[ClaAnio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [OPESch].[OPETraFurmanGastosPasadena] ADD  DEFAULT (getdate()) FOR [FechaUltimaMod]
GO

ALTER TABLE [OPESch].[OPETraFurmanGastosPasadena] ADD  DEFAULT (host_name()) FOR [NombrePcMod]
GO


