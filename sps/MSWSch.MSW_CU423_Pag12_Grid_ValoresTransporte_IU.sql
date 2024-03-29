ALTER PROCEDURE [MSWSch].[MSW_CU423_Pag12_Grid_ValoresTransporte_IU]
		@pnAnio INT
		,@pnDINLFTWU_MXN NUMERIC(22,6)
		,@pnDWAREHU_MXN NUMERIC(22,6)
		,@pnDINLFTPU_MXN NUMERIC(22,6)
		,@pnDBROKU_MXN NUMERIC(22,6)
		,@pnUSBROKU NUMERIC(22,6)
		,@pnINLFPWU_L NUMERIC(22,6)
		,@pnUSWAREHU_L NUMERIC(22,6)
		, @psNombrePcMod				VARCHAR(64) = 'Commerce'
		, @pnClaUsuarioMod				INT = 1
		, @psIdioma						VARCHAR(30) = 'English'
AS   
BEGIN  

	DECLARE 			
		@MSG				VARCHAR(255)

	IF ISNULL(@pnAnio,0) = 0
	BEGIN		
		SELECT @MSG= CASE @psIdioma WHEN 'Spanish' THEN 'Debe ingresar el año.'
						ELSE 'You must enter the year.'
						END
		RAISERROR(@MSG , 16, 1 )
		RETURN
	END

	IF NOT EXISTS (SELECT 1 FROM MSWSch.MSWCfgFurmanInlandFreightRates WHERE Anio = @pnAnio)
		BEGIN /* ES ALTA DE AÑO */
			INSERT INTO MSWSch.MSWCfgFurmanInlandFreightRates
				(
					Anio
					,DINLFTWU_MXN
					,DWAREHU_MXN
					,DINLFTPU_MXN
					,DBROKU_MXN
					,USBROKU
					,INLFPWU_L
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
					,@pnDINLFTWU_MXN
					,@pnDWAREHU_MXN
					,@pnDINLFTPU_MXN
					,@pnDBROKU_MXN
					,@pnUSBROKU
					,@pnINLFPWU_L
					,@pnUSWAREHU_L
					,0
					,NULL
					,GETDATE()
					,@pnClaUsuarioMod
					,@psNombrePcMod
				)
		END
	ELSE
		BEGIN /*SE ACTUALIZA AÑO*/
			UPDATE MSWSch.MSWCfgFurmanInlandFreightRates
			SET 				  
				DINLFTWU_MXN = @pnDINLFTWU_MXN
				,DWAREHU_MXN  = @pnDWAREHU_MXN
				,DINLFTPU_MXN = @pnDINLFTPU_MXN
				,DBROKU_MXN   = @pnDBROKU_MXN
				,USBROKU      = @pnUSBROKU
				,INLFPWU_L    = @pnINLFPWU_L
				,USWAREHU_L   = @pnUSWAREHU_L
				,FechaUltimaMod = GETDATE()
				,ClaUsuarioMod = @pnClaUsuarioMod
				,NombrePcMod = @psNombrePcMod
			 WHERE Anio = @pnAnio
		END

	SELECT 
		Anio
		,DINLFTWU_MXN
		,DWAREHU_MXN
		,DINLFTPU_MXN
		,DBROKU_MXN
		,USBROKU
		,INLFPWU_L
		,USWAREHU_L		
	FROM MSWSch.MSWCfgFurmanInlandFreightRates WITH(NOLOCK)
	ORDER BY Anio DESC

END