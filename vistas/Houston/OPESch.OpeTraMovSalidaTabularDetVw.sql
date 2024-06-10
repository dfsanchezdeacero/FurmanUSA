ALTER VIEW OPESch.OpeTraMovSalidaTabularDetVw
AS
	SELECT		 det.ClaUbicacion
				,det.IdMovEntSal
				,det.ClaArticulo
				,det.IdEntSalDet
				,det.IdFabricacion
				,det.IdFabricacionDet
				,det.PesoEmbarcado
				,det.FechaUltimaMod
				,det.NombrePcMod
				,det.ClaUsuarioMod
	FROM		OPESch.OpeTraMovSalidaTabularVw	enc
	INNER JOIN	OPESch.OPETraMovEntSalDet		det	ON	enc.ClaUbicacion = det.ClaUbicacion
													AND	enc.IdMovEntSal = det.IdMovEntSal
