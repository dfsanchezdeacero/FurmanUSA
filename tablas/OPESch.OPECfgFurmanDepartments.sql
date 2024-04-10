CREATE TABLE [OPESch].[OPECatFurmanDepartments](
	[ClaFurmanDepartment] [int] NOT NULL,
	[NomFurmanDepartment] VARCHAR(150) NOT NULL,
	[BajaLogica] [tinyint] NULL,
	[FechaBajaLogica] [datetime] NULL,
	[FechaUltimaMod] [datetime] NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ClaFurmanDepartment] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO