ALTER  VIEW [OPESch].[OPECatArticuloFurmanDepartmentVw]
AS
SELECT DISTINCT	 
	P.ClaArticulo,
	P.ClaCrc,
	P.NomCrc,
	F.ClaFurmanDepartment,
	F.NomFurmanDepartment
FROM [OPESch].[OPETraFurmanProduccion]	P WITH (NOLOCK)
INNER JOIN [OPESch].[OPERelCRCFurmanDepartments] Rel WITH (NOLOCK) ON P.ClaCrc = Rel.ClaCrc
INNER JOIN [OPESch].[OPECatFurmanDepartments] F WITH (NOLOCK) ON Rel.ClaFurmanDepartment = F.ClaFurmanDepartment

GO
