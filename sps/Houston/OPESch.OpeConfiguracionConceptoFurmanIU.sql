-- =============================================
-- Author:		David Sanchez
-- Create date: 07-11-2022
-- Description: 
-- =============================================
ALTER PROCEDURE [OPESch].[OpeConfiguracionConceptoFurmanIU]
	@pnIdConceptoFurman   INT
	,@pnClaElementoCosto  INT
	,@pnClaUsuarioMod     INT
	,@psNombrePcMod		  VARCHAR(64)
	,@pnEsDebug			  INT = 0
	
AS
BEGIN
	SET NOCOUNT ON
        SELECT 1 FROM [OPESch].[OPERelConceptoFurmanCrc] WHERE IdConceptoFurman = 1 AND ClaElementoCosto = 3
		IF NOT EXISTS (SELECT 1 FROM [OPESch].[OPERelConceptoFurmanCrc] WHERE IdConceptoFurman = @pnIdConceptoFurman AND ClaElementoCosto = @pnClaElementoCosto)
		BEGIN
			DECLARE @pnClaCrcEnCurso INT

			SELECT DISTINCT
			P.ClaCrc,
			P.NomCrc
			INTO #tmpListaCRC
			FROM [OPESch].[OPETraFurmanProduccion] P

			SELECT 
			@pnClaCrcEnCurso = MIN(ClaCrc) 
			FROM #tmpListaCRC

			WHILE (@pnClaCrcEnCurso IS NOT NULL)
			BEGIN
				INSERT INTO [OPESch].[OPERelConceptoFurmanCrc]
				(IdConceptoFurman, ClaCrc, ClaElementoCosto, FechaUltimaMod, NombrePcMod, ClaUsuarioMod)
				VALUES
				(@pnIdConceptoFurman,@pnClaCrcEnCurso,@pnClaElementoCosto,GETDATE(),@psNombrePcMod,@pnClaUsuarioMod)

				IF @pnEsDebug = 1 SELECT @pnClaCrcEnCurso

				SELECT @pnClaCrcEnCurso = MIN(ClaCrc) 
				FROM #tmpListaCRC
				WHERE ClaCrc > @pnClaCrcEnCurso
			END

			
		END
		ELSE
		BEGIN
			DELETE FROM [OPESch].[OPERelConceptoFurmanCrc]
			WHERE IdConceptoFurman = @pnIdConceptoFurman 
			AND ClaElementoCosto = @pnClaElementoCosto
		END		

   	SET NOCOUNT OFF
END