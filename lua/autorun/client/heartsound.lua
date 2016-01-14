local LocalPlayer = LocalPlayer

local ttt_low_health_sound = CreateClientConVar("ttt_low_health_sound", "1", true, true)

local nextboop = 0
local function LowHealthSound()
	if not ttt_low_health_sound:GetBool() then return end

	local plr = LocalPlayer()
	if not IsValid(plr) then return end

	local health = plr:Health()

	if plr:Team() == TEAM_TERROR and plr:Alive() and health < 27 and nextboop <= CurTime() then
		surface.PlaySound("zelda/TP_LowHealth.mp3")

		local t
		if health >= 21 then
			t = 2
		elseif health >= 16 then
			t = 1.67
		elseif health >= 11 then
			t = 1.33
		elseif health >= 6 then
			t = 1
		else
			t = 0.5
		end

		nextboop = CurTime() + t
	end
end

-- Uncomment to have the option in the F1 menu.
--[[ hook.Add("TTTSettingsTabs", "Heart sound thing", function(dtabs)
	local dsettings = dtabs.Items[2].Panel

	local dgui = vgui.Create("DForm", dsettings)
	dgui:SetName("Play low health sound.")
	dgui:TTTCustomUI_FormatForm()
	dgui:CheckBox("Enable annoying as fuck health sound", "ttt_low_health_sound")
	dsettings:AddItem(dgui)

	if tttCustomSettings then
		for k, v in pairs(dgui.Items) do
			for i, j in pairs(v:GetChildren()) do
				j.Label:TTTCustomUI_FormatLabel()
			end
		end
	end
end) ]]

hook.Add("OnGamemodeLoaded", "LowHealthSoundSetup", function()
	hook.Add("Think", "LowHealthSound", LowHealthSound)
end)
