CREATE VIEW MSWSch.MSWAreCatParidadVw AS

	SELECT
	FechaParidad	
	,ClaMoneda	
	,ParidadMonedaPeso	
	,ParidadMonedaDolar	
	,BajaLogica	
	,FechaBajaLogica	
	,FechaUltimaMod	
	,FechaIns	
	,ParidadDolarMon
	FROm [TiCatalogo].dbo.[ConCatParidad] WHERE ClaMoneda = 2