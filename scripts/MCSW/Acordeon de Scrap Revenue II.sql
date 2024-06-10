DECLARE @pnAnioMesInicio INT = 202301, @pnAnioMesFin INT = 202301
--,@pdFechaBalance DATETIME
,@pdFechaBalanceInicio DATETIME
,@pdFechaBalanceFin DATETIME

/*
CREATE TABLE #tmpBalanceCuenta(
	Id			    INT
	,IdMes		    INT
	,EsAbrirLink    INT
	,Periodo	    VARCHAR(100)
	,AnioMes	    INT
	,Neto		    NUMERIC(22,4)
	,Balance	    NUMERIC(22,4)
	,EsAplicaEstilo INT
)

Apoyo para validar resultado con lo que se ve en pantalla
INSERT INTO #tmpBalanceCuenta
exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10911,@pnAnio=2023,@psIdioma='English'

INSERT INTO #tmpBalanceCuenta
exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10911,@pnAnio=2024,@psIdioma='English'
DELETE FROM #tmpBalanceCuenta WHERE IdMes IN (0,13,14)
*/

	SELECT FURMANAnioMesInicio = @pnAnioMesInicio, FURMANAnioMesFin = @pnAnioMesFin

	SELECT @pdFechaBalanceInicio = SUBSTRING(CAST(@pnAnioMesInicio AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@pnAnioMesInicio AS VARCHAR(10)), 5,6)+'-01'		
	SELECT @pdFechaBalanceFin = SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)), 1,4)+'-'+SUBSTRING(CAST(@pnAnioMesFin AS VARCHAR(10)), 5,6)+'-01'		
	
	SELECT @pdFechaBalanceInicio = DATEADD(MONTH, 1 ,@pdFechaBalanceInicio)	
	SELECT @pdFechaBalanceFin = DATEADD(MONTH, 1 ,@pdFechaBalanceFin)	
	
	SELECT dFechaBalanceInicio = (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio)
	, dFechaBalanceFin = (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)

/*
	SELECT 
		Periodo
		,AnioMes
		,Neto
		,Balance
	FROM #tmpBalanceCuenta 
	WHERE AnioMes >= (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio)
	AND AnioMes <= (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)

	SELECT 
		Neto = SUM(Neto)
	FROM #tmpBalanceCuenta 
	WHERE AnioMes >= (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio)
	AND AnioMes <= (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)
*/
	SELECT 
		CargoMenosCredito = SUM(Cargos - Creditos) 
	FROM MSWSch.MswTraSaldosEng9 WITH(NOLOCK)
	WHERE ClaCuenta = 10911 
	AND AnioMes >= (YEAR(@pdFechaBalanceInicio) *100) + MONTH(@pdFechaBalanceInicio) 
	AND AnioMes <= (YEAR(@pdFechaBalanceFin) *100) + MONTH(@pdFechaBalanceFin)

/*
DROP TABLE #tmpBalanceCuenta
*/