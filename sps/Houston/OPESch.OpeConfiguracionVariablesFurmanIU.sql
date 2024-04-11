-- =============================================
-- Author:		David Sanchez
-- Create date: 05-12-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeConfiguracionVariablesFurmanIU]
	@pnAnio					   INT,
	@pnProcInteres			   NUMERIC(22,6),
	@pnPorcGastoVentaIndirecta NUMERIC(22,6),
	@pnComisionAgenteVenta	   NUMERIC(22,6),
	@pnComisionManagerVenta    NUMERIC(22,6),
	@pnComisionVPVenta         NUMERIC(22,6),
	@pnComisionAgIndVenta      NUMERIC(22,6),
	@pnClaUsuarioMod		   INT,
	@psNombrePcMod			   VARCHAR (100)
	
AS
BEGIN
	SET NOCOUNT ON       
     
	 IF NOT EXISTS (SELECT 1 FROM [OPESch].[OPECfgFurmanVariables] WITH (NOLOCK) WHERE Anio = @pnAnio)
	 BEGIN
		INSERT INTO [OPESch].[OPECfgFurmanVariables]
			(
				[Anio]
				,[PorcGastoVentaIndirecta]
				,[ComisionAgenteVenta]
				,[ComisionManagerVenta]
				,[ComisionVPVenta]
				,[ComisionAgIndVenta]
				,[BajaLogica]
				,[FechaBajaLogica]
				,[FechaUltimaMod]
				,[ClaUsuarioMod]
				,[NombrePcMod]
			)
			VALUES 
			(
				@pnAnio
				,@pnPorcGastoVentaIndirecta
				,@pnComisionAgenteVenta
				,@pnComisionAgenteVenta
				,@pnComisionVPVenta
				,@pnComisionVPVenta
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
					t1.[PorcGastoVentaIndirecta] = @pnPorcGastoVentaIndirecta
					,t1.[ComisionAgenteVenta] = @pnComisionAgenteVenta
					,t1.[ComisionManagerVenta] = @pnComisionManagerVenta
					,t1.[ComisionVPVenta] = @pnComisionVPVenta
					,t1.[ComisionAgIndVenta] = @pnComisionAgIndVenta					
					,t1.[FechaUltimaMod] = GETDATE()
					,t1.[ClaUsuarioMod] = @pnClaUsuarioMod
					,t1.[NombrePcMod] = @psNombrePcMod
			FROM [OPESch].[OPECfgFurmanVariables] t1
			WHERE Anio = @pnAnio
	 ENd

   	SET NOCOUNT OFF
END