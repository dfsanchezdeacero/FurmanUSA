ALTER PROC [MSWSch].[MSW_CU99_Pag50_ObtenerGastosOntario_Sel]
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
		,Total = ISNULL(SUM( CASE WHEN AnioMes /100 = @pnAnio THEN (Cargos- Creditos) ELSE 0 END ),0)
	INTO #tmpAnioMesGastosOntario
	FROM [MSWSch].[MSWCfgFurmanCuentaContableGastosOntario] FO
	INNER JOIN [MSWSch].[MswTraCuentaContable9] CC ON FO.IdCuentaContable = CC.IdCuentaContable
	LEFT JOIN [MSWSch].[MswTraSaldosEng9] S ON FO.IdCuentaContable = S.ClaCuenta
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

	SELECT 
		Descripcion AS [Account;w=100;a=Left;c=G/L Account]
		,NomCuentaIdioma1 AS [Name;w=300;a=Left;c=G/L Account Name]
		,January AS [January;w=80;a=Right;t=decimal;d=2;c=January;s=Sum]
		,February AS [February;w=80;a=Right;t=decimal;d=2;c=February;s=Sum]
		,March AS [March;w=80;a=Right;t=decimal;d=2;c=March;s=Sum]
		,April AS [April;w=80;a=Right;t=decimal;d=2;c=April;s=Sum]
		,May AS [May;w=80;a=Right;t=decimal;d=2;c=May;s=Sum]
		,June AS [June;w=80;a=Right;t=decimal;d=2;c=June;s=Sum]
		,July AS [July;w=80;a=Right;t=decimal;d=2;c=July;s=Sum]
		,August AS [August;w=80;a=Right;t=decimal;d=2;c=August;s=Sum]
		,September AS [September;w=80;a=Right;t=decimal;d=2;c=September;s=Sum]
		,October AS [October;w=80;a=Right;t=decimal;d=2;c=October;s=Sum]
		,November AS [November;w=80;a=Right;t=decimal;d=2;c=November;s=Sum]
		,December AS [December;w=80;a=Right;t=decimal;d=2;c=December;s=Sum]
		,TOTAL AS [Total;w=80;a=Right;t=decimal;d=2;c=Total;s=Sum]
	FROM #tmpAnioMesGastosOntario
	ORDER BY ClaNiv1

	DROP TABLE #tmpAnioMesGastosOntario
END