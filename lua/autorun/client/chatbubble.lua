local cb = ClientsideModel("models/extras/info_speech.mdl", RENDERGROUP_OPAQUE)
cb:SetNoDraw(true)

hook.Add('PostPlayerDraw', 'ChatBubbles_PostPlayerDraw', function(ply)
	if ply:Alive() and ply:IsSpeaking() then
		local pos = ply:GetPos() + Vector(0, 0, 90)
		local ang = Angle(0, UnPredictedCurTime() * 100, 0)

		cb:SetPos(pos)
		cb:SetAngles(ang)

		cb:SetRenderOrigin(pos)
		cb:SetRenderAngles(ang)
		cb:SetupBones()
		cb:DrawModel()
		cb:SetRenderOrigin()
		cb:SetRenderAngles()
	end
end)
