USE [Operacion]
GO

/****** Object:  View [OPESch].[OPECatFurmanCrcVw]    Script Date: 4/9/2024 4:45:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--*----
--*Objeto:		Vista: [OPECatElementoCrcVw]
--*Autor:		DFSANCHEZ
--*Fecha:		Nov 7 2022  09:57AM
--*Objetivo:	Generar la vista para tabla Elementos de Centros de Costo

--*----	

ALTER VIEW [OPESch].[OPECatFurmanCrcVw]
AS
SELECT DISTINCT
	P.ClaCrc,
	P.NomCrc,
	F.ClaFurmanDepartment,
	F.NomFurmanDepartment
FROM [OPESch].[OPETraFurmanProduccion]	P WITH (NOLOCK)
INNER JOIN [OPESch].[OPERelCRCFurmanDepartments] Rel WITH (NOLOCK) ON P.ClaCrc = Rel.ClaCrc
INNER JOIN [OPESch].[OPECatFurmanDepartments] F WITH (NOLOCK) ON Rel.ClaFurmanDepartment = F.ClaFurmanDepartment


GO
