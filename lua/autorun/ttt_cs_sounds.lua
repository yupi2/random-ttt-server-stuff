if SERVER then
	AddCSLuaFile()
	util.AddNetworkString("TTTEndroundStupidShit")
	hook.Add("TTTEndRound", "Stupid shit fuck shit fuck shit", function(result)
		net.Start("TTTEndroundStupidShit")
			net.WriteInt(result, 32)
		net.Broadcast()
	end)
	return -- Exit because there's nothing else we need to do on the server.
end

local ttt_round_endstart_sounds = CreateClientConVar("ttt_round_endstart_sounds", "1", true, true)

-- WIN_NONE = 1, WIN_TRAITOR = 2, WIN_INNOCENT =3, WIN_TIMELIMIT = 4
local endroundSounds = {
	"fuck me",
	Sound("radio/ctwin.wav"),
	Sound("radio/terwin.wav"),
	Sound("radio/rounddraw.wav")
}

hook.Add("TTTBeginRound", "Begin round sound", function()
	if ttt_round_endstart_sounds:GetBool() then
		surface.PlaySound("radio/letsgo.wav")
	end
end)

net.Receive("TTTEndroundStupidShit", function()
	local result = net.ReadInt(32)
	if ttt_round_endstart_sounds:GetBool() then
		surface.PlaySound(endroundSounds[result])
	end
end)

hook.Add("TTTSettingsTabs", "Round End/Start Sound", function(dtabs)
	local dsettings = dtabs.Items[2].Panel

	local dgui = vgui.Create("DForm", dsettings)
	dgui:SetName("Play some Counter-Strike sounds at the beginning and end of rounds.")

	if tttCustomSettings then
		dgui:TTTCustomUI_FormatForm()
	end

	dgui:CheckBox("Enable", "ttt_round_endstart_sounds")
	dsettings:AddItem(dgui)

	if tttCustomSettings then
		for k, v in pairs(dgui.Items) do
			for i, j in pairs(v:GetChildren()) do
				j.Label:TTTCustomUI_FormatLabel()
			end
		end
	end
end)
