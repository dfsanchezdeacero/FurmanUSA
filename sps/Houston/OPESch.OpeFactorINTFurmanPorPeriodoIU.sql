USE [Operacion]
GO
/****** Object:  StoredProcedure [OPESch].[OpeFactorINTFurmanPorPeriodo]    Script Date: 4/18/2024 2:39:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		David Sanchez
-- Create date: 01-11-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeFactorINTFurmanPorPeriodoIU]
	  @pnAnioINTPeriodoFurman	INT
	,@pnFactorINTPeriodoFurman	NUMERIC (22,8)
	,@psNombrePcMod	    VARCHAR(50)
    ,@pnClaUsuarioMod		    INT
AS
BEGIN
	SET NOCOUNT ON

	 DECLARE 
		@nLastId INT = 0

	SELECT @nLastId = ISNULL(MAX(ClaINTPeriodoFurman),1) + 1 
	FROM [OPESch].[OPECfgINTPeriodoFurman] (NOLOCK)

	IF NOT EXISTS (SELECT 1 FROM [OPESch].[OPECfgINTPeriodoFurman] WITH (NOLOCK) WHERE AnioINTPeriodoFurman=@pnAnioINTPeriodoFurman)
        BEGIN
            INSERT INTO [OPESch].[OPECfgINTPeriodoFurman]
            (ClaINTPeriodoFurman	
            ,ClaveINTPeriodoFurman
            ,AnioINTPeriodoFurman
            ,FactorINTPeriodoFurman
            ,FechaUltimaMod
            ,NombrePcMod
            ,ClaUsuarioMod)
            VALUES (
                @nLastId
                ,@nLastId
                ,@pnAnioINTPeriodoFurman
                ,@pnFactorINTPeriodoFurman
                ,GETDATE()
                ,HOST_NAME()
                ,1
            )
        END
        ELSE
        BEGIN
			UPDATE [OPESch].[OPECfgINTPeriodoFurman]
            SET FactorINTPeriodoFurman = @pnFactorINTPeriodoFurman
			,FechaUltimaMod = GETDATE()
			,NombrePcMod = @psNombrePcMod
            ,ClaUsuarioMod = @pnClaUsuarioMod
            WHERE AnioINTPeriodoFurman=@pnAnioINTPeriodoFurman            
        END
    

   	SET NOCOUNT OFF
END
