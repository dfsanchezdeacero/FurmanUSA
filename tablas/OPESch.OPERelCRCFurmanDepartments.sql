CREATE TABLE [OPESch].[OPERelCRCFurmanDepartments](
	[ClaFurmanDepartment] [int] NOT NULL,
	[ClaCrc] [int] NOT NULL,
	[FechaUltimaMod] [datetime] NULL,
	[ClaUsuarioMod] [int] NOT NULL,
	[NombrePcMod] [varchar](64) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ClaFurmanDepartment],[ClaCrc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

BEGIN TRAN DFSS

INSERT INTO [OPESch].[OPERelCRCFurmanDepartments]
(ClaFurmanDepartment, ClaCrc, FechaUltimaMod, ClaUsuarioMod, NombrePcMod)
VALUES
(7, 4230, GETDATE(), 1, 'FURMAN')
,(2, 4012, GETDATE(), 1, 'FURMAN')
,(5, 4206, GETDATE(), 1, 'FURMAN')
,(3, 4252, GETDATE(), 1, 'FURMAN')
,(1, 4122, GETDATE(), 1, 'FURMAN')
,(5, 4214, GETDATE(), 1, 'FURMAN')
,(6, 4033, GETDATE(), 1, 'FURMAN')
,(1, 4037, GETDATE(), 1, 'FURMAN')
,(6, 4133, GETDATE(), 1, 'FURMAN')
,(4, 4208, GETDATE(), 1, 'FURMAN')

SELECT * FROM [OPESch].[OPERelCRCFurmanDepartments]

ROLLBACK TRAN DFSS