AddCSLuaFile()

local bloom_netstr = "postround_bloom"
local bloom_time_length = 5 -- seconds

if SERVER then
	util.AddNetworkString(bloom_netstr)

	hook.Add("PlayerDeath", "ttlor_PostRound_slow", function()
		-- Wait a moment, so the player entity is actually dead.
		timer.Simple(0.005, function()
			if GetRoundState() == ROUND_ACTIVE then
				local win = hook.Call("TTTCheckForWin", GAMEMODE)
				if win == WIN_TRAITOR or win == WIN_INNOCENT then
					net.Start(bloom_netstr)
						net.WriteBool(win == WIN_TRAITOR)
					net.Broadcast()
				end
			end
		end)
	end)
else -- CLIENT
	local ttt_enable_endround_bloom = CreateClientConVar("ttt_enable_endround_bloom", "1", true, true)

	local mt = 0
	local draw_bloom_bool = false

	local ColorConstTable

	local ColorConstTableTraitor = {
		0.14,
		0,
		0,
		0.026,
		0.88,
		0.2,
		0.5,
		0,
		2
	}

	local ColorConstTableInnocent = {
		0,
		0.14,  -- 0,
		0,     -- 0.1,
		0.026, -- 0.05,
		0.88,  -- 0.88,
		0.2,   -- 0.65,
		0,
		0.5,   -- 0,
		2      -- 0
	}

	local BloomTable = {
		0.76,
		3.74,
		45.1,
		26.03,
		2,
		2.58,
		1,
		1,
		1
	}
	
	hook.Add("TTTSettingsTabs", "Round End Bloom", function(dtabs)
		local dsettings = dtabs.Items[2].Panel

		local dgui = vgui.Create("DForm", dsettings)
		dgui:SetName("Draw the bloom effect at the end of the round.")
		dgui:TTTCustomUI_FormatForm()
		dgui:CheckBox("Enable", "ttt_enable_endround_bloom")
		dsettings:AddItem(dgui)
		for k, v in pairs(dgui.Items) do
			for i, j in pairs(v:GetChildren()) do
				j.Label:TTTCustomUI_FormatLabel()
			end
		end
		--dsettings:AddItem(dgui)
	end)

	local function EndBloomDraw()
		draw_bloom_bool = false
	end

	net.Receive(bloom_netstr, function()
		if not ttt_enable_endround_bloom:GetBool() then return end
		local traitorwon = net.ReadBool()

		ColorConstTable = traitorwon and ColorConstTableTraitor or ColorConstTableInnocent
		draw_bloom_bool = true

		timer.Simple(bloom_time_length, EndBloomDraw)

		for i = 1, 20 do
			timer.Simple(0.0625 * i, function()
				mt = (i ^ 2) / 400 -- Fade In.
			end)

			timer.Simple((1.375 + (0.125 * i)), function()
				mt = 1 - ((i ^ 2) / 400) --Fade out.
			end)
		end
	end)

	hook.Add("RenderScreenspaceEffects", "TTT EndRound Bloom", function()
		if draw_bloom_bool then
			local ColorModifyTable = {
				["$pp_colour_addr"]       =   ColorConstTable[1] * mt,
				["$pp_colour_addg"]       =   ColorConstTable[2] * mt,
				["$pp_colour_addb"]       =   ColorConstTable[3] * mt,
				["$pp_colour_brightness"] =   ColorConstTable[4] * mt,
				["$pp_colour_contrast"]   = ((ColorConstTable[5] - 1) * mt) + 1, -- ISSUE!
				["$pp_colour_colour"]     = ((ColorConstTable[6] - 1) * mt) + 1,
				["$pp_colour_mulr"]       =   ColorConstTable[7] * mt,
				["$pp_colour_mulg"]       =   ColorConstTable[8] * mt,
				["$pp_colour_mulb"]       =   ColorConstTable[9] * mt
			}

			DrawToyTown(4, mt * (ScrH() * 0.33))

			DrawBloom(
				mt * BloomTable[1],
				mt * BloomTable[2],
				mt * BloomTable[3],
				mt * BloomTable[4],
				math.Round(mt * BloomTable[5]),
				mt * BloomTable[6],
				mt * BloomTable[7],
				mt * BloomTable[8],
				mt * BloomTable[9]
			)

			DrawColorModify(ColorModifyTable)
		end
	end)
end