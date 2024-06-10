BEGIN TRAN DFSS

	INSERT INTO [OPESch].[OpeCatFurmanConfiguracion]
	(ClaUbicacion, ClaConfiguracion, NombreConfiguracion, sValor1, sValor2, nValor1, nValor2, dValor1, dValor2, BajaLogica, FechaBajaLogica, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, ClaTipoInventario, ClaSistema)
	VALUES
	(65
	,5
	,'Porcentaje de Scrap Teorico de PUAS'
	,NULL
	,NULL	
	,4033
	,4.0
	,NULL	
	,NULL	
	,0	
	,NULL	
	,GETDATE() 
	,'DFSANCHEZ'
	,904542	
	,1	
	,1)

	SELECT * FROM [OPESch].[OpeCatFurmanConfiguracion]

ROLLBACK TRAN DFSS