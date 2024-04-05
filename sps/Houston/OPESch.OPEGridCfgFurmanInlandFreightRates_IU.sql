ALTER PROCEDURE [OPESch].[OPEGridCfgFurmanInlandFreightRates_IU]	
		@pnAnio INT
		,@pnDINLFTWU_MX NUMERIC(22,6)
		,@pnDWAREHU_MX NUMERIC(22,6)
		,@pnDINLFTPU_MXN NUMERIC(22,6)
		,@pnDBROKU_MX NUMERIC(22,6)
		,@pnUSBROKU NUMERIC(22,6)
		,@pnINLFPWCU_L NUMERIC(22,6)
		,@pnUSWAREHU_L NUMERIC(22,6)
		,@psNombrePcMod VARCHAR(64)
		,@pnClaUsuarioMod INT
AS   
BEGIN  

	
	IF NOT EXISTS (SELECT 1 FROM [OPESch].[OPECfgFurmanInlandFreightRates] WHERE Anio = @pnAnio)
	BEGIN /* ES ALTA DE AÑO */
		INSERT INTO [OPESch].[OPECfgFurmanInlandFreightRates]
			(
				Anio
				,DINLFTWU_MX
				,DWAREHU_MX
				,DINLFTPU_MXN
				,DBROKU_MX
				,USBROKU
				,INLFPWCU_L
				,USWAREHU_L
				,BajaLogica
				,FechaBajaLogica
				,FechaUltimaMod
				,ClaUsuarioMod
				,NombrePcMod
			)
		VALUES
			(
				@pnAnio
				,@pnDINLFTWU_MX
				,@pnDWAREHU_MX
				,@pnDINLFTPU_MXN
				,@pnDBROKU_MX
				,@pnUSBROKU
				,@pnINLFPWCU_L
				,@pnUSWAREHU_L
				,0
				,NULL
				,GETDATE()
				,@pnClaUsuarioMod
				,@psNombrePcMod
			)
	END	
	ELSE
	BEGIN
		IF EXISTS (SELECT 1 FROM [OPESch].[OPECfgFurmanInlandFreightRates] WHERE Anio = @pnAnio)
		BEGIN /*SE ACTUALIZA AÑO*/
			UPDATE t1
			SET 
				 t1.Anio = @pnAnio
				,t1.DINLFTWU_MX = @pnDINLFTWU_MX
				,t1.DWAREHU_MX = @pnDWAREHU_MX
				,t1.DINLFTPU_MXN = @pnDINLFTPU_MXN
				,t1.DBROKU_MX = @pnDBROKU_MX
				,t1.USBROKU = @pnUSBROKU
				,t1.INLFPWCU_L = @pnINLFPWCU_L
				,t1.USWAREHU_L = @pnUSWAREHU_L
				,t1.BajaLogica = 0
				,t1.FechaBajaLogica = NULL
				,t1.FechaUltimaMod = GETDATE()
				,t1.ClaUsuarioMod = @pnClaUsuarioMod
				,t1.NombrePcMod = @psNombrePcMod
			FROM [OPESch].[OPECfgFurmanInlandFreightRates] t1
			 WHERE Anio = @pnAnio		
		END
	END

END
