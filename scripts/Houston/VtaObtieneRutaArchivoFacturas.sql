DECLARE
@ruta VARCHAR(500)
,@filename VARCHAR(100)
,@sTipoArchivo VARCHAR(10)
 
EXEC [DEAOFINET05].Ventas.VTASch.VtaObtieneRutaArchivoFacturas 
244060033
,1
,0
,@ruta OUT
,@filename OUT
,@sTipoArchivo OUT
 
SELECT @ruta
,@filename
,@sTipoArchivo