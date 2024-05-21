
SELECT * FROM  [MSWSch].[MSWCatConfiguracion] WHERE ClaConfiguracion >= 604

BEGIN TRAN DFSS

	DECLARE @nClaConfiguracion  INT
	SELECT @nClaConfiguracion = MAX(ClaConfiguracion) + 1 FROM [MSWSch].[MSWCatConfiguracion]
	SELECT @nClaConfiguracion

	INSERT INTO [MSWSch].[MSWCatConfiguracion]
	(ClaTipoInventario,ClaUbicacion,ClaSistema,ClaConfiguracion,NombreConfiguracion,sValor1,sValor2,nValor1,nValor2,dValor1,dValor2,BajaLogica,FechaBajaLogica,FechaUltimaMod,NombrePcMod,ClaUsuarioMod,sValor3)
	VALUES(1,6,272,@nClaConfiguracion,'FURMAN Identificar Clavos (GpoEst) nValor1 = Bulk, sValor2 = Headed Nails','292,293,453',NULL,202,NULL,NULL,NULL,0,NULL,GETDATE(),'CARGA INICIAL',1,NULL)

	INSERT INTO [MSWSch].[MSWCatConfiguracion]
	(ClaTipoInventario,ClaUbicacion,ClaSistema,ClaConfiguracion,NombreConfiguracion,sValor1,sValor2,nValor1,nValor2,dValor1,dValor2,BajaLogica,FechaBajaLogica,FechaUltimaMod,NombrePcMod,ClaUsuarioMod,sValor3)
	VALUES(1,6,272,@nClaConfiguracion + 1,'FURMAN Identificar Clavos GpoEst) nValor1 = Collated, sValor2 = Wire Coil ','289,454',NULL,201,NULL,NULL,NULL,0,NULL,GETDATE(),'CARGA INICIAL',1,NULL)

	INSERT INTO [MSWSch].[MSWCatConfiguracion]
	(ClaTipoInventario,ClaUbicacion,ClaSistema,ClaConfiguracion,NombreConfiguracion,sValor1,sValor2,nValor1,nValor2,dValor1,dValor2,BajaLogica,FechaBajaLogica,FechaUltimaMod,NombrePcMod,ClaUsuarioMod,sValor3)
	VALUES(1,6,272,@nClaConfiguracion + 2,'FURMAN Identificar Clavos (GpoEst) nValor1 = Collated, sValor2 = Paper Tape','291,',NULL,201,NULL,NULL,NULL,0,NULL,GETDATE(),'CARGA INICIAL',1,NULL)

	INSERT INTO [MSWSch].[MSWCatConfiguracion]
	(ClaTipoInventario,ClaUbicacion,ClaSistema,ClaConfiguracion,NombreConfiguracion,sValor1,sValor2,nValor1,nValor2,dValor1,dValor2,BajaLogica,FechaBajaLogica,FechaUltimaMod,NombrePcMod,ClaUsuarioMod,sValor3)
	VALUES(1,6,272,@nClaConfiguracion + 3,'FURMAN Identificar Clavos (GpoEst) nValor1 = Collated, sValor2 = Plastic Strip','290,',NULL,201,NULL,NULL,NULL,0,NULL,GETDATE(),'CARGA INICIAL',1,NULL)
	
	SELECT * FROM [MSWSch].[MSWCatConfiguracion] WHERE NombreConfiguracion LIKE '%furman%'
--COMMIT TRAN DFSS
ROLLBACK TRAN DFSS