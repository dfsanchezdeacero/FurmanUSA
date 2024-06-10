SELECT DISTINCT (ClaUbicacion) FROM	MSWSch.OpeTraMovSalidaTabular (NOLOCK)

SELECT * FROM [Sincroniza].[dbo].[transfer_tablas] WHERE tabla LIKE '%Tabular%'
SELECT * FROM [Sincroniza].[dbo].[transfer_grupos] WHERE grupo = 'TF_MSW' AND sub_grupo IN ('OPE','MHUBLDO','HOU')

SELECT TOP 5 * FROM [MSWSch].[OpeTraMovSalidaTabular]
SELECT TOP 5 * FROM [MSWSch].[MSWOpeTraMovSalidaTabular]

SELECT* FROm [Sincroniza].[dbo].[transfer_campos] WHERE tabla = 'TF_OpeTraMovSalidaTabularVw' ORDER BY Orden

SELECT* FROm [Sincroniza].[dbo].[transfer_campos] WHERE tabla = 'TF_OpeTraMovSalidaTabularDetVw' ORDER BY campo_origen

SELECT DISTINCT (ClaUbicacion) FROM MSWSch.OpeTraMovSalidaTabular
SELECT TOP 10 * FROM MSWSch.OpeTraMovSalidaTabular
SELECT TOP 10 * FROM MSWSch.OpeTraMovSalidaTabularDet ORDER BY FechaUltimaMod  DESC

SELECT  * FROM  MSWSch.OpeTraMovSalidaTabular
WHERE CLAUBICACION = 345 AND FECHAULTIMAMOD>='20240101'
AND IDVIAJE  = 1494

SELECT * FROM	MSWSch.MSWTraFurmanFreightToMCSW	fftm	(NOLOCK) WHERE IdFacturaDEA IN (1052001918,1052001919,1052001920)

SELECT TOP 5 * FROM [MSWSch].[OpeTraMovSalidaTabularDet]


SELECT * FROM Sincroniza.[dbo].[transfer_estatus] WHERE tabla = 'TF_OpeTraMovSalidaTabularVw'
SELECT * FROM Sincroniza.[dbo].[transfer_bitacora] WHERE tabla = 'TF_OpeTraMovSalidaTabularVw'

SELECT * FROM Sincroniza.[dbo].[transfer_estatus] WHERE tabla = 'TF_OpeTraMovSalidaTabularDetVw'
SELECT * FROM Sincroniza.[dbo].[transfer_bitacora] WHERE tabla = 'TF_OpeTraMovSalidaTabularDetVw'

EXEC SINCRONIZA.dbo.sp_transferir @grupo= 'TF_MSW' ,@sub_grupo='OPE',@tabla='TF_OpeTraMovSalidaTabularVw', @fecha_ini = '19000101', @show=1
EXEC SINCRONIZA.dbo.sp_transferir @grupo= 'TF_MSW' ,@sub_grupo='OPE',@tabla='TF_OpeTraMovSalidaTabularDetVw', @fecha_ini = '19000101', @show=1
EXEC SINCRONIZA.dbo.sp_transferir @grupo= 'TF_MSW' ,@sub_grupo='MHUBLDO',@tabla='TF_OpeTraMovSalidaTabularVw', @fecha_ini = '19000101', @show=1
EXEC SINCRONIZA.dbo.sp_transferir @grupo= 'TF_MSW' ,@sub_grupo='MHUBLDO',@tabla='TF_OpeTraMovSalidaTabularDetVw', @fecha_ini = '19000101', @show=1
EXEC SINCRONIZA.dbo.sp_transferir @grupo= 'TF_MSW' ,@sub_grupo='HOU',@tabla='TF_OpeTraMovSalidaTabularVw', @fecha_ini = '19000101', @show=1
EXEC SINCRONIZA.dbo.sp_transferir @grupo= 'TF_MSW' ,@sub_grupo='HOU',@tabla='TF_OpeTraMovSalidaTabularDetVw', @fecha_ini = '19000101', @show=1


BEGIN TRAN DFSS
	/*
	INSERT INTO [Sincroniza].[dbo].[transfer_campos] 
	(tabla,campo_origen,campo_destino,tabla_abcde,tipo,tipou,es_null,es_key,orden,val_default,transferir,fuc,objeto)
	VALUES
	('TF_OpeTraMovSalidaTabularVw', 'NombrePcMod','NombrePcMod', 'a','varchar(64)','varchar(64)',0,0,120,NULL,1,GETDATE(),NULL)
	,('TF_OpeTraMovSalidaTabularVw', 'ClaUsuarioMod','ClaUsuarioMod', 'a','int','int',0,0,130,NULL,1,GETDATE(),NULL)
	*/

	SELECT * FROM [Sincroniza].[dbo].[transfer_campos] 
	WHERE tabla = 'TF_OpeTraMovSalidaTabularVw' ORDER BY Orden

	SELECT * FROM [Sincroniza].[dbo].[transfer_campos] 
	WHERE tabla = 'TF_OpeTraMovSalidaTabularDetVw' ORDER BY Orden

	/*
	UPDATE [Sincroniza].[dbo].[transfer_tablas] 
	SET tabla_destino = 'MSWOpeTraMovSalidaTabular'
	,fuc = GETDATE()
	WHERE grupo	= 'TF_MSW'
	AND sub_grupo IN ('MHUBLDO','HOU','OPE')
	AND tabla = 'TF_OpeTraMovSalidaTabularVw'

	UPDATE [Sincroniza].[dbo].[transfer_tablas] 
	SET tabla_destino = 'MSWOpeTraMovSalidaTabularDet'
	,fuc = GETDATE()
	WHERE grupo	= 'TF_MSW'
	AND sub_grupo IN ('MHUBLDO','HOU','OPE')
	AND tabla = 'TF_OpeTraMovSalidaTabularDetVw'
	*/

	SELECT * FROM [Sincroniza].[dbo].[transfer_tablas] 
	WHERE tabla = ('TF_OpeTraMovSalidaTabularVw')
	AND grupo	= 'TF_MSW'
	SELECT * FROM [Sincroniza].[dbo].[transfer_tablas] 
	WHERE tabla = ('TF_OpeTraMovSalidaTabularDetVw')
	AND grupo	= 'TF_MSW'	

	SELECT * FROM MSWSch.MSWOpeTraMovSalidaTabular

	SELECT DISTINCT (CLaUbicacion) FROM MSWSch.MSWOpeTraMovSalidaTabular
	SELECT * FROM MSWSch.MSWOpeTraMovSalidaTabularDet 

ROLLBACK TRAN DFSS



EXEC [MSWSch].[MSW_CU423_Pag8_Grid_GridGenerico_Sel]
	@pnAnioMesInicio		= 202301
	,@pnAnioMesFin			= 202312

SELECT 
	CantidadKilos = SUM(CantidadKgs)
	,ImporteFlete = SUM(ImporteFlete)
	,PerUnitFreightCost = SUM(ImporteFlete)/SUM(CantidadKgs) FROM [MSWSch].[MSWTraFurmanFreightToMCSWAnioMes]
WHERE ClaAnioMes >= 202301 AND ClaAnioMes <= 202312