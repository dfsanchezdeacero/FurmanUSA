ALTER PROC [MSWSch].[MSW_CU423_Pag12_ObtenerGastosOntario_Sel]
	@pnAnio		INT = 2023
AS
BEGIN
	SELECT
		FO.IdCuentaContable
		, CC.ClaNiv1
		, CC.ClaNiv2
		, CC.ClaNiv3
		, FO.Descripcion
		, CC.NomCuentaIdioma1
		,CC.NomCuentaIdioma2
		,Year = @pnAnio
		,January = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 1 THEN (Cargos- Creditos) ELSE 0 END ) ,0)
		,February = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 2 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,March = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 3 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,April = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 4 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,May = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 5 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,June = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 6 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,July = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 7 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,August = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 8 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,September = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 9 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,October = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 10 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,November = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 11 THEN (Cargos- Creditos) ELSE 0 END ),0)
		,December = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio  and AnioMes % 100 = 12 THEN (Cargos- Creditos) ELSE 0 END ),0)
	INTO #tmpAnioMesGastosOntario
	FROM [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] FO
	INNER JOIN [MSWSch].[MswTraCuentaContable9] CC ON FO.IdCuentaContable = CC.IdCuentaContable
	LEFT JOIN [MSWSch].[MswTraSaldosEng9Vw] S ON FO.IdCuentaContable = S.ClaCuenta
	WHERE (S.AnioMes / 100) = @pnAnio
	GROUP BY 
		FO.IdCuentaContable
		, CC.ClaNiv1
		, CC.ClaNiv2
		, CC.ClaNiv3
		, FO.Descripcion
		, CC.NomCuentaIdioma1
		,CC.NomCuentaIdioma2
	ORDER BY CC.ClaNiv1

	SELECT Descripcion, NomCuentaIdioma1,January,February,March,April,May,June,July,August,September,October,November,December FROM #tmpAnioMesGastosOntario

	DROP TABLE #tmpAnioMesGastosOntario
END

--EXEC [MSWSch].[MSW_CU423_Pag12_ObtenerGastosOntario_Sel] @pnAnio = 2023