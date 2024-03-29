ALTER PROCEDURE [MSWSch].[MSW_CU423_Pag12_Grid_FactorInteres_IU]
		  @pnAnioMes					INT
		, @pnFactorInteresProc 			NUMERIC(22,6)
		, @psNombrePcMod				VARCHAR(64)
		, @pnClaUsuarioMod				INT		
AS   
BEGIN  

	DECLARE 			
		@MSG				VARCHAR(255)



	IF NOT EXISTS (SELECT 1 FROM MSWSch.MSWCfgFurmanVentaInterestRate WHERE AnioMes = @pnAnioMes)
		BEGIN /* ES ALTA DE AÑO */
			INSERT INTO MSWSch.MSWCfgFurmanVentaInterestRate
				(
					 AnioMes
					,PorcInteres
					,BajaLogica
					,FechaBajaLogica
					,FechaUltimaMod
					,ClaUsuarioMod
					,NombrePcMod
				)
			VALUES
				(
					 @pnAnioMes
					,@pnFactorInteresProc
					,0
					,NULL
					,GETDATE()
					,@pnClaUsuarioMod
					,@psNombrePcMod
				)
		END
	ELSE
		BEGIN /*SE ACTUALIZA AÑOMES*/
			UPDATE MSWSch.MSWCfgFurmanVentaInterestRate
			SET 
				   PorcInteres = @pnFactorInteresProc
				  ,FechaUltimaMod = GETDATE()
				  ,ClaUsuarioMod = @pnClaUsuarioMod
				  ,NombrePcMod = @psNombrePcMod
			 WHERE AnioMes = @pnAnioMes
		END
END
