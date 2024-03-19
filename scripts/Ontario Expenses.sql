DECLARE @pnAnioMesInicio INT = 202301, @pnAnioMesFin INT = 202312
	SELECT
		SUM(Cargos - Creditos)		
	FROM [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] FO
	INNER JOIN [MSWSch].[MswTraCuentaContable9] CC ON FO.IdCuentaContable = CC.IdCuentaContable
	LEFT JOIN [MSWSch].[MswTraSaldosEng9] S ON FO.IdCuentaContable = S.ClaCuenta
	WHERE (@pnAnioMesInicio IS NULL OR (@pnAnioMesInicio IS NOT NULL AND S.AnioMes >= @pnAnioMesInicio))
		AND	(@pnAnioMesFin IS NULL OR (@pnAnioMesFin IS NOT NULL AND S.AnioMes <= @pnAnioMesFin))	

SELECT * FROM [MSWSch].[MswTraSaldosEng9] WITH(NOLOCK) WHERe ClaCuenta = 1668 AND AnioMes >= 202301 AND AnioMes <= 202312


SELECT * FROM [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] 

SELECT * FROM MSWSch.MswTraCuentaContable9 WITH(NOLOCK) WHERE ClaNiv1 =6047  AND ClaNiv2 = 20 AND ClaNiv3 = 120

SELECT * FROM [MSWSch].[MswTraSaldosEng9Vw] WITH(NOLOCK) WHERe ClaCuenta = 775 ORDER BY AnioMes DESC


 SELECT * FROM [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario]

 SELECT * FROM [MSWSch].[MSWCatTipoConsultaGenerica] WHERE ClaTipoConsultaGenerica = 42
 SELECT * FROM [MSWSch].[MSWCatConsultaGenerica] WHERE NomConsultaGenerica LIKE '%FURMAN%'
 SELECT MAX(ClaConsultaGenerica) FROM [MSWSch].[MSWCatConsultaGenerica]

 --ClaUbicacion	ClaTipoConsultaGenerica	ClaConsultaGenerica	NomConsultaGenerica	Comentario	NomProceso	BajaLogica	FechaBajaLogica	ClaUsuarioMod	FechaUltimaMod	NombrePcMod
BEGIN TRAN DFSS
	INSERT INTO [MSWSch].[MSWCatConsultaGenerica]
	SELECT 68, 42, 4729,	'FURMAN Sales Ontario Expenses', 'FURMAN Sales - Ontario Expenses','MSW_CU99_Pag50_ObtenerGastosOntario_Sel'	,0,	NULL,	1,	GETDATE(), 'CargaFURMAN'

	SELECT * FROM [MSWSch].[MSWCatConsultaGenerica] WHERE NomConsultaGenerica LIKE '%FURMAN%'
ROLLBACK TRAN DFSS

 
 BEGIN TRAN DFSS

 INSERT INTO [MSWSch].[MSWTmpConsultaGenerica]
 SELECT 68, NEWID(),4729,	1,	'@pnAnio', 'Year', 'int', 4,2023,	'YYYY',	0,	NULL,	1,	GETDATE(), '100-DFSANCHEZ'
 SELECT * FROM [MSWSch].[MSWTmpConsultaGenerica] WHERE ClaConsultaGenerica = 4729

 --COMMIT TRAN DFSS
 ROLLBACK TRAN DFSS