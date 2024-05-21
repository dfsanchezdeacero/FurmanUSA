DECLARE @pnAnioMesInicio INT = 202301, @pnAnioMesFin INT = 202312
exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10911,@pnAnio=2023,@psIdioma='English'
SELECT * FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10911 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesInicio
SELECT SUM(Cargos - Creditos) FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10911 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesInicio

exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10912,@pnAnio=2023,@psIdioma='English'
SELECT * FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10912 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesInicio
SELECT SUM(Cargos - Creditos) FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10912 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesInicio

exec MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel @pnClaCuenta=10918,@pnAnio=2023,@psIdioma='English'
SELECT * FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10918 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesInicio
SELECT SUM(Cargos - Creditos) FROM MSWSch.MswTraSaldosEng9 WHERE ClaCuenta = 10918 AND AnioMes >= @pnAnioMesInicio AND AnioMes <= @pnAnioMesInicio

sp_helptext 'MSWSch.MSW_CU910_Pag5_Grid_BalanceCuenta_Sel'