-- =============================================
-- Author:		David Sanchez
-- Create date: 05-12-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeConfiguracionInterestRateFurmanIU]
	@pnAnioMes INT,
	@pnProcInteres NUMERIC(22,6),
	@pnClaUsuarioMod INT,
	@psNombrePcMod VARCHAR (100)
AS
BEGIN
	SET NOCOUNT ON
       
     --TODO
	 IF NOT EXISTS (SELECT 1 FROM [OpeSch].[OpeCfgFurmanVentasInterestRate] WITH (NOLOCK) WHERE AnioMes = @pnAnioMes)
	 BEGIN
		INSERT INTO [OpeSch].[OpeCfgFurmanVentasInterestRate]
		(
			AnioMes	
			,PorcInteres	
			,BajaLogica	
			,FechaBajaLogica	
			,FechaUltimaMod	
			,ClaUsuarioMod	
			,NombrePcMod
		)
		VALUES(
			
			@pnAnioMes
			,@pnProcInteres
			,0
			,NULL
			,GETDATE()
			,@pnClaUsuarioMod
			,@psNombrePcMod
		)	
	 END
	 ELSE
	 BEGIN
		UPDATE t1
			SET  
				t1.AnioMes = @pnAnioMes
				,t1.PorcInteres = @pnProcInteres
				,t1.[FechaUltimaMod] = GETDATE()
				,t1.[ClaUsuarioMod] = @pnClaUsuarioMod
				,t1.[NombrePcMod] = @psNombrePcMod
		FROM [OpeSch].[OpeCfgFurmanVentasInterestRate] t1
		WHERE AnioMes = @pnAnioMes
	 END
	 
   	SET NOCOUNT OFF
END