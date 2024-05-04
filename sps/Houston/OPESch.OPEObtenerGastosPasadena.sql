--EXEC OPESch.OPEObtenerGastosPasadena
--SELECT * FROM [OPESch].[OPETraFurmanGastosPasadena]

ALTER PROCEDURE OPESch.OPEObtenerGastosPasadena
	@pnClaUsuarioMod	 INT			= 1
	,@psNombrePcMod		 VARCHAR(64) = 'FURMAN - JOB'
	,@psIdioma           VARCHAR(50) = 'English'
	,@pnEsDebug INT = 0
	

AS
BEGIN
	SET NOCOUNT ON

	DECLARE
		@nAnioDePartida INT
		,@nNumEjecuciones INT = 0
		,@nEjecucionEnProc INT = 0
		,@nAnioEnCurso INT = YEAR(GETDATE())
		,@nEsAbrirTransaccion INT = 0		
		,@sMensaje VARCHAR(1000)
	

		CREATE TABLE #ExtraccionExpsPasadena(
			LinkNumCuenta VARCHAR(MAX)
			,Descripcion VARCHAR(500)
			,Nivel1ClaCuentaContable INT
			,Nivel2ClaCuentaContable INT
			,Nivel3ClaCuentaContable INT
			,Nivel4ClaCuentaContable INT
			,ClaTipoDatoNivelOrden1 INT
			,ClaTipoDatoNivelOrden2 INT
			,ClaTipoDatoNivelOrden3 INT
			,Nivel INT
			,SaldoInicial NUMERIC(22,4)
			,Mes1  NUMERIC(22,4)
			,Mes2  NUMERIC(22,4)
			,Mes3  NUMERIC(22,4)
			,Mes4  NUMERIC(22,4)
			,Mes5  NUMERIC(22,4)
			,Mes6  NUMERIC(22,4)
			,Mes7  NUMERIC(22,4)
			,Mes8  NUMERIC(22,4)
			,Mes9  NUMERIC(22,4)
			,Mes10 NUMERIC(22,4)
			,Mes11 NUMERIC(22,4)
			,Mes12 NUMERIC(22,4)
			,SaldoFinal NUMERIC(22,4)
		)

		CREATE TABLE #ExpsPasadena(
			Anio INT 
			,Descripcion VARCHAR(500)
			,SaldoInicial NUMERIC(22,4)
			,Mes1  NUMERIC(22,4)
			,Mes2  NUMERIC(22,4)
			,Mes3  NUMERIC(22,4)
			,Mes4  NUMERIC(22,4)
			,Mes5  NUMERIC(22,4)
			,Mes6  NUMERIC(22,4)
			,Mes7  NUMERIC(22,4)
			,Mes8  NUMERIC(22,4)
			,Mes9  NUMERIC(22,4)
			,Mes10 NUMERIC(22,4)
			,Mes11 NUMERIC(22,4)
			,Mes12 NUMERIC(22,4)
			,SaldoFinal NUMERIC(22,4)
		)
			DECLARE @AnioMaxRegistrado INT --= 2020--2024--2024

			--FECHA INICIAL POR DEFAULT 2020
			SELECT 
			@AnioMaxRegistrado = ISNULL(MAX(ClaAnio),2020)
			FROM [OPESch].[OPETraFurmanGastosPasadena]

			SELECT @nAnioDePartida = @AnioMaxRegistrado

			SELECT @nNumEjecuciones = @nAnioEnCurso - @nAnioDePartida
			SELECT @nEjecucionEnProc = @nNumEjecuciones

			WHILE (@nEjecucionEnProc >= 0)
			BEGIN
	
				SELECT AnioEnEjecucion = @nAnioEnCurso - @nEjecucionEnProc

				INSERT INTO #ExtraccionExpsPasadena
				EXEC [LNK_CTS_DEAOFINET03].Finanzas.CNTSch.CNT_CU66_Pag1_Grid_gridReporte66_Sel @pnClaEmpresa66=22
				,@pnClaMoneda66=2 --Dolares
				,@pnClaAnio66= @nEjecucionEnProc --AnioActual - @pnClaAnio66
				,@pnClaMes66=12 -- Datos Hasta Diciembre
				,@pnClaDireccion66=14 --Compañia 22-DEAUSA
				,@pnClaCuentaMayor66=NULL 
				,@pnClaNivel366=1451  
				,@pnClaNivel466=NULL
				,@pnNivel=2 
				,@pnNivel1k=14
				,@pnNivel2k=75
				,@pnNivel3k=1451
				,@pnNivel4k=-1
				,@pnClaTipoDatoNivelOrden1=1
				,@pnClaTipoDatoNivelOrden2=2
				,@pnClaTipoDatoNivelOrden3=4
				,@pnClaTipoDatoNivelOrden4=default
				,@pnDelEjercicio=0
				,@pnAcumulada=1
				,@pnmovimientoMes=1
				,@pnsaldosAcumulados=0
				,@pncomparativa=0
				,@pnvervariacion=0
				,@pnChckMiles66=0
				,@pnChckCentavos66=1
				,@pnChckGpoAsig66=0
				,@pnIdSesion66=14742261
				,@pnClaUsuarioMod=100022063
				,@psIdioma=@psIdioma
	
				INSERT INTO #ExpsPasadena
				SELECT
					Anio = @nAnioEnCurso - @nEjecucionEnProc
					,Descripcion
					,SaldoInicial
					,Mes1 
					,Mes2 
					,Mes3 
					,Mes4 
					,Mes5 
					,Mes6 
					,Mes7 
					,Mes8 
					,Mes9 
					,Mes10
					,Mes11
					,Mes12
					,SaldoFinal
				FROM #ExtraccionExpsPasadena				

				--Limpiamos EXtraccion Anterior
				DELETE FROM #ExtraccionExpsPasadena

				SELECT @nEjecucionEnProc = @nEjecucionEnProc - 1

			END

			IF @pnEsDebug = 1 
				SELECT '#ExpsPasadena',* FROM #ExpsPasadena
			ELSE
			BEGIN
				BEGIN TRY 
					IF @@TRANCOUNT = 0
					BEGIN 
						SET @nEsAbrirTransaccion = 1
						BEGIN TRAN 
					END

					DELETE FROM [OPESch].[OPETraFurmanGastosPasadena] WHERE ClaAnio >= @nAnioDePartida

					INSERT INTO [OPESch].[OPETraFurmanGastosPasadena]
					(
						ClaAnio
						,Descripcion
						,SaldoInicial
						,Mes1 
						,Mes2 
						,Mes3 
						,Mes4 
						,Mes5 
						,Mes6 
						,Mes7 
						,Mes8 
						,Mes9 
						,Mes10
						,Mes11
						,Mes12
						,SaldoFinal
						,FechaUltimaMod
						,NombrePcMod
						,ClaUsuarioMod
					)
					SELECT 
						Anio
						,Descripcion
						,SaldoInicial
						,Mes1 
						,Mes2 
						,Mes3 
						,Mes4 
						,Mes5 
						,Mes6 
						,Mes7 
						,Mes8 
						,Mes9 
						,Mes10
						,Mes11
						,Mes12
						,SaldoFinal
						,GETDATE()
						,@psNombrePcMod
						,@pnClaUsuarioMod
					FROM #ExpsPasadena

				
					IF @@TRANCOUNT = 1 AND @nEsAbrirTransaccion = 1
					BEGIN
						COMMIT TRAN 
					END	
		
				END TRY
				BEGIN CATCH
					SET @sMensaje = ERROR_MESSAGE()
	
					IF @@TRANCOUNT = 1 AND @nEsAbrirTransaccion = 1
					BEGIN
						ROLLBACK TRAN 			
					END	
		
					RAISERROR(@sMensaje,16,1)
					RETURN
				END CATCH				
			END

		DROP TABLE #ExpsPasadena
		DROP TABLE #ExtraccionExpsPasadena
	   	SET NOCOUNT OFF
--	END
END
