ALTER VIEW OPESch.OpeTraMovSalidaTabularVw
AS
SELECT   
	mes.ClaUbicacion  
   ,mes.IdMovEntSal  
   ,mes.FechaEntSal  
   ,mes.IdEntSal  
   ,mes.IdViaje  
   ,mes.PesoEmbarcado  
   ,mes.IdFactura  
   ,mes.IdFacturaAlfanumerico     
   ,F.ClaCliente
   ,F.ClaConsignado
   ,Ct.ClaClienteUnico
   ,t.KgsPagar  
   ,t.ImportePagarFinal  
   ,FechaUltimaMod = mes.FechaUltimaMod
   ,ClaUsuarioMod = mes.ClaUsuarioMod
   ,NombrePcMod = mes.NombrePcMod
FROM  OPESch.OpeTraMovEntSal mes (NOLOCK)  
LEFT JOIN OPESch.OpeTraViaje  v (NOLOCK) ON mes.ClaUbicacion = v.ClaUbicacion  
             AND mes.IdViaje = v.IdViaje  
LEFT JOIN FleSch.FleTraTabular t (NOLOCK) ON v.IdNumTabular = t.IdTabular  
             AND v.ClaUbicacion = t.ClaUbicacion 
LEFT JOIN OpeSch.OpeTraFabricacionVw F ON F.IdFabricacion = mes.IdFabricacion --AND F.ClaUbicacion = mes.ClaUbicacion
LEFT JOIN [OpeSch].[OpeVtaCatClienteCuentaVw] Ct ON Ct.ClaClienteCuenta = F.ClaCliente 
WHERE mes.ClaUbicacion = 65-- (11,35,197)  
AND  mes.ClaMotivoEntrada = 1 
AND YEAR(mes.FechaEntSal) > 2020
AND Ct.ClaClienteUnico = 11912 --DEACERO 
--AND F.ClaCliente IN 
--(74844
--,111639
--,124865
--,124905
--,124973
--,804012
--,805115
--,1074844)
--AND mes.IdFacturaAlfanumerico = 'SL52967'  

--SELECT * FROm [OpeSch].[OpeVtaCatClienteCuentaVw] WHERE ClaClienteUnico = 11912