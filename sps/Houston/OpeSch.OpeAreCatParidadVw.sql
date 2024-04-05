CREATE VIEW OpeSch.OpeAreCatParidadVw AS  
  
 SELECT  
 FechaParidad   
 ,ClaMoneda   
 ,ParidadMonedaPeso   
 ,ParidadMonedaDolar   
 ,BajaLogica   
 ,FechaBajaLogica   
 ,FechaUltimaMod   
 ,FechaIns   
 ,ParidadDolarMon  
 FROm TiCatalogo.[dbo].[ConCatParidadVw] WHERE ClaMoneda = 2