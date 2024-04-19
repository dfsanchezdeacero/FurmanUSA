USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeFactorGNAFurmanPorPeriodo]    Script Date: 4/18/2024 2:39:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 01-11-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeFactorGNAFurmanPorPeriodoIU]
	@pnAnioGNAPeriodoFurman		INT            
	,@pnFactorGNAPeriodoFurman	NUMERIC (22,8) 
	,@psNombrePcMod	    VARCHAR(50)
    ,@pnClaUsuarioMod		    INT           
AS
BEGIN
	SET NOCOUNT ON
         DECLARE 
			@nLastId INT = 0

		SELECT 
			@nLastId = ISNULL(MAX(ClaGNAPeriodoFurman),1) + 1
		FROM [OPESch].[OPECfgGNAPeriodoFurman] (NOLOCK)

		 IF NOT EXISTS (SELECT 1 FROM [OPESch].[OPECfgGNAPeriodoFurman] WITH (NOLOCK) WHERE AnioGNAPeriodoFurman = @pnAnioGNAPeriodoFurman)
        BEGIN
            INSERT INTO [OPESch].[OPECfgGNAPeriodoFurman]
            (ClaGNAPeriodoFurman	
            ,ClaveGNAPeriodoFurman
            ,AnioGNAPeriodoFurman
            ,FactorGNAPeriodoFurman
            ,FechaUltimaMod
            ,NombrePcMod
            ,ClaUsuarioMod)
            VALUES (
                @nLastId
                ,@nLastId
                ,@pnAnioGNAPeriodoFurman
                ,@pnFactorGNAPeriodoFurman
                ,GETDATE()
                ,@psNombrePcMod
                ,@pnClaUsuarioMod
            )
        END
        ELSE
        BEGIN
			UPDATE 
				[OPESch].[OPECfgGNAPeriodoFurman]
            SET FactorGNAPeriodoFurman = @pnFactorGNAPeriodoFurman
			,FechaUltimaMod = GETDATE()
			,NombrePcMod = @psNombrePcMod
            ,ClaUsuarioMod = @pnClaUsuarioMod
            WHERE AnioGNAPeriodoFurman = @pnAnioGNAPeriodoFurman            
        END

		

   	SET NOCOUNT OFF
END