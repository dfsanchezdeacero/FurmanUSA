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

SELECT * FROM MSWSch.MswTraCuentaContable9 WITH(NOLOCK) WHERE ClaNiv1 =6015  AND ClaNiv2 = 20 AND ClaNiv3 = 0

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

 DECLARE
	@pnAnioMesInicio INT = 202301
	,@pnAnioMesFin INT = 202302
	,@nAnioInicio INT = 0
	,@nMesInicio INT = 0
	,@nDiaInicio INT = 0
	,@nAnioFin INT = 0
	,@nMesFin INT = 0
	,@nDiaFin INT = 0
	,@sFehaAnioMesInicio VARCHAR (100)
	,@sFehaAnioMesFin VARCHAR (100)
	,@nEsBisiestoAnioInicio BIT 
	,@nEsBisiestoAnioFin BIT 

	SELECT @sFehaAnioMesInicio = CAST((@pnAnioMesFin / 100) AS VARCHAR)+'-01-01'
	SELECT @sFehaAnioMesFin = CAST((@pnAnioMesFin / 100) AS VARCHAR)+'-01-01'

	SELECT @nEsBisiestoAnioInicio = MSWSch.MSWGetLeapYear(CAST(@sFehaAnioMesInicio AS datetime2))
	SELECT @nEsBisiestoAnioFin = MSWSch.MSWGetLeapYear(CAST(@sFehaAnioMesFin AS datetime2))

	SELECT @nAnioInicio = @pnAnioMesInicio / 100
		,@nAnioFin = @pnAnioMesFin / 100
		,@nMesInicio = @pnAnioMesInicio % 100
		,@nMesFin = @pnAnioMesFin % 100
		,@nDiaInicio = CASE WHEN @pnAnioMesInicio % 100 = 1 THEN 31
							WHEN @pnAnioMesInicio % 100 = 2 AND  @nEsBisiestoAnioInicio = 1 THEN 29
							WHEN @pnAnioMesInicio % 100 = 2 AND @nEsBisiestoAnioInicio = 0 THEN 28
							WHEN @pnAnioMesInicio % 100 = 3 THEN 31
							WHEN @pnAnioMesInicio % 100 = 4 THEN 30
							WHEN @pnAnioMesInicio % 100 = 5 THEN 31
							WHEN @pnAnioMesInicio % 100 = 6 THEN 30
							WHEN @pnAnioMesInicio % 100 = 7 THEN 31
							WHEN @pnAnioMesInicio % 100 = 8 THEN 31
							WHEN @pnAnioMesInicio % 100 = 9 THEN 30
							WHEN @pnAnioMesInicio % 100 = 10 THEN 31
							WHEN @pnAnioMesInicio % 100 = 11 THEN 30
							WHEN @pnAnioMesInicio % 100 = 12 THEN 31	
						END
		,@nDiaFin = CASE WHEN @pnAnioMesFin % 100 = 1 THEN 31
							WHEN @pnAnioMesFin % 100 = 2 AND @nEsBisiestoAnioFin = 1 THEN 29
							WHEN @pnAnioMesFin % 100 = 2 AND @nEsBisiestoAnioFin = 0 THEN 28
							WHEN @pnAnioMesFin % 100 = 3 THEN 31
							WHEN @pnAnioMesFin % 100 = 4 THEN 30
							WHEN @pnAnioMesFin % 100 = 5 THEN 31
							WHEN @pnAnioMesFin % 100 = 6 THEN 30
							WHEN @pnAnioMesFin % 100 = 7 THEN 31
							WHEN @pnAnioMesFin % 100 = 8 THEN 31
							WHEN @pnAnioMesFin % 100 = 9 THEN 30
							WHEN @pnAnioMesFin % 100 = 10 THEN 31
							WHEN @pnAnioMesFin % 100 = 11 THEN 30
							WHEN @pnAnioMesFin % 100 = 12 THEN 31
						END
	SELECT 
		CAST(CAST(@nAnioInicio AS VARCHAR)+'-'+CAST(@nMesInicio AS VARCHAR)+'-'+CAST(@nDiaInicio AS VARCHAR) AS DATE)
	SELECT 
		CAST(CAST(@nAnioFin AS VARCHAR)+'-'+CAST(@nMesFin AS VARCHAR)+'-'+CAST(@nDiaFin AS VARCHAR) AS DATE)



