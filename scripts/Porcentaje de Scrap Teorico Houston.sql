BEGIN TRAN DFSS

	INSERT INTO [OPESch].[OpeCatFurmanConfiguracion]
	(ClaUbicacion, ClaConfiguracion, NombreConfiguracion, sValor1, sValor2, nValor1, nValor2, dValor1, dValor2, BajaLogica, FechaBajaLogica, FechaUltimaMod, NombrePcMod, ClaUsuarioMod, ClaTipoInventario, ClaSistema)
	VALUES
	(65,6,'Scrap Teorico de MINIMAT (MM/EVG)'		  ,NULL,NULL	,4133,2.5,NULL	,NULL	,0	,NULL	,GETDATE() ,'DFSANCHEZ',904542	,1	,1)
	,(65,7,'Scrap Teorico de MESH TRIPLE KNOT (SL) ',NULL,NULL	,4122,0.5,NULL	,NULL	,0	,NULL	,GETDATE() ,'DFSANCHEZ',904542	,1	,1)
	,(65,8,'Scrap Teorico de WIRE STRANDED'	      ,NULL,NULL	,4206,4,NULL	,NULL	,0	,NULL	,GETDATE() ,'DFSANCHEZ',904542	,1	,1)
	,(65,9,'Scrap Teorico de ROPE CLOSING'		  ,NULL,NULL	,4214,4,NULL	,NULL	,0	,NULL	,GETDATE() ,'DFSANCHEZ',904542	,1	,1)
	,(65,10,'Scrap Teorico de THIN WELDED MESH'	  ,NULL,NULL	,4012,2.5,NULL	,NULL	,0	,NULL	,GETDATE() ,'DFSANCHEZ',904542	,1	,1)
	,(65,11,'Scrap Teorico de PC STRAND'			  ,NULL,NULL	,4208,3,NULL	,NULL	,0	,NULL	,GETDATE() ,'DFSANCHEZ',904542	,1	,1)


	UPDATE [OPESch].[OpeCatFurmanConfiguracion] SET nValor2 = 1.5, NombreConfiguracion = 'Porcentaje de Scrap Teorico de SPIKE' WHERE ClaConfiguracion = 5


	SELECT * FROM [OPESch].[OpeCatFurmanConfiguracion]

ROLLBACK TRAN DFSS

	SELECT * FROM [OPESch].[OPECatConceptoFurman]
	SELECT * FROM [OPESch].[OPECatFurmanDepartments]
	SELECT * FROm [OPESch].[OPECatFurmanCrcVw] ORDER BY ClaFurmanDepartment
	SELECT * FROm  [OPESch].[OPECatFurmanCrcVw]

	