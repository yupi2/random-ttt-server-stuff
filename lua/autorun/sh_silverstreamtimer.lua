-- Lua file used by the projectsuburb map to show the nuke timer.

local on = false
local countdown = 0

if game.GetMap() == "ttt_projectsuburb_final" then
	if SERVER then
		AddCSLuaFile()
		util.AddNetworkString("SilverstreamsTimer")

		SilverstreamsTimer_Start = function()
			net.Start("SilverstreamsTimer")
				net.WriteBool(true)
				net.WriteFloat(CurTime() + 20)
			net.Broadcast()
		end

		SilverstreamsTimer_Stop = function()
			net.Start("SilverstreamsTimer")
				net.WriteBool(false)
			net.Broadcast()
		end
	else
		surface.CreateFont("SilverstreamsTimerFont", {
			font = "coolvetica",
			size = 70,
			weight = 400,
			antialias = true,
		})

		net.Receive("SilverstreamsTimer", function()
			on = net.ReadBool()
			if on then
				countdown = net.ReadFloat()
			end
		end)

		hook.Add("HUDPaint", "SilverstreamsTimerHUD", function()
			local curtime = CurTime()
			if on and countdown > curtime then
				local timeLeft = string.ToMinutesSeconds(countdown - curtime)
				-- color black & white are globals defined by GMOD
				draw.SimpleText(timeLeft, "SilverstreamsTimerFont", ScrW() / 2 + 1, 55, color_black, 1, 1)
				draw.SimpleText(timeLeft, "SilverstreamsTimerFont", ScrW() / 2, 50, color_white, 1, 1)
			end
		end)
	end
end
