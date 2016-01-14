--[[
	You can still do a single airduck (which will still bob the player)
	but it isn't spammable now.
]]--

-- Clears the IN_DUCK bit for CMoveData.
local function removeduck(mvd)
	mvd:SetButtons(bit.band(mvd:GetButtons(), bit.bnot(IN_DUCK)))
end

hook.Add("SetupMove", "Airduck-fix: SetupMove", function(ply, mvd, cmd)
	if ply.airducked == nil then
		if ply:Alive() and not ply:OnGround() then
			if mvd:KeyDown(IN_DUCK) then
				ply.airducked = 1
			end
		end
	else
		if ply:OnGround() or not ply:Alive() then
			ply.airducked = nil
			return
		end

		if mvd:KeyReleased(IN_DUCK) then
			ply.airducked = 2
			return
		end

		if ply.airducked ~= 1 and mvd:KeyDown(IN_DUCK) then
			removeduck(mvd)
		end
	end
end)

