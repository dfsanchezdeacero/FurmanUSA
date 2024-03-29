ALTER PROC [MSWSch].[MSW_CU423_Pag12_Grid_ValoresTransporte_Sel]
	@psNombrePcMod				VARCHAR(64)
	,@pnClaUsuarioMod				INT
AS
BEGIN
	SELECT 
		Anio
		,DINLFTWU_MXN
		,DWAREHU_MXN
		,DINLFTPU_MXN
		,DBROKU_MXN
		,USBROKU
		,INLFPWU_L
		,USWAREHU_L
		,1 AS EditaTransporte
	FROM MSWSch.MSWCfgFurmanInlandFreightRates WITH(NOLOCK)
	ORDER BY Anio DESC
END