-- =============================================
-- Author:		David Sanchez
-- Create date: 05-12-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeConfiguracionInterestRateFurmanSel]
	
AS
BEGIN
	SET NOCOUNT ON
       
     SELECT 
		YearMonth = AnioMes	
		,InterestExpRate = PorcInteres	
		,BajaLogica	
		,FechaBajaLogica	
		,FechaUltimaMod	
		,ClaUsuarioMod	
		,NombrePcMod
	FROM [OpeSch].[OpeCfgFurmanVentasInterestRate]
	ORDER BY AnioMes DESC

   	SET NOCOUNT OFF
END