local function GetPreviousAlivePlayer(ply)
	local alive = util.GetAlivePlayers()

	if #alive < 1 then return nil end

	local prev = nil
	local choice = nil

	if IsValid(ply) then
		for k, p in ipairs(alive) do
			if p == ply then
				choice = prev
			end
			prev = p
		end
	end

	if not IsValid(choice) then
		choice = alive[#alive]
	end

	return choice
end

local function TTTKeyPress(self, ply, key)
	if not IsValid(ply) then return end

	-- Spectator keys
	if ply:IsSpec() and not ply:GetRagdollSpec() then
		if ply.propspec then
			return PROPSPEC.Key(ply, key)
		end

		ply:ResetViewRoll()

		if key == IN_ATTACK then
			-- spectate either the previous guy or a random guy in chase
			local target = GetPreviousAlivePlayer(ply:GetObserverTarget())

			if IsValid(target) then
				ply:Spectate(ply.spec_mode or OBS_MODE_CHASE)
				ply:SpectateEntity(target)
			end
		elseif key == IN_ATTACK2 then
			-- spectate either the next guy or a random guy in chase
			local target = util.GetNextAlivePlayer(ply:GetObserverTarget())

			if IsValid(target) then
				ply:Spectate(ply.spec_mode or OBS_MODE_CHASE)
				ply:SpectateEntity(target)
			end
		elseif key == IN_DUCK or key == IN_JUMP then
			if key == IN_JUMP and ply:GetObserverMode() == OBS_MODE_ROAMING then
				return
			end

			local pos = ply:GetPos()
			local ang = ply:EyeAngles()

			local target = ply:GetObserverTarget()
			if IsValid(target) and target:IsPlayer() then
				pos = target:EyePos()
				ang = target:EyeAngles()
			end

			-- reset
			ply:Spectate(OBS_MODE_ROAMING)
			ply:SpectateEntity(nil)

			ply:SetPos(pos)
			ply:SetEyeAngles(ang)
			return true
		-- elseif key == IN_JUMP then
			---- unfuck if you're on a ladder etc
			-- if not (ply:GetMoveType() == MOVETYPE_NOCLIP) then
				-- ply:SetMoveType(MOVETYPE_NOCLIP)
			-- end
		elseif key == IN_RELOAD then
			local tgt = ply:GetObserverTarget()
			if not IsValid(tgt) or not tgt:IsPlayer() then return end

			if not ply.spec_mode or ply.spec_mode == OBS_MODE_CHASE then
				ply.spec_mode = OBS_MODE_IN_EYE
			elseif ply.spec_mode == OBS_MODE_IN_EYE then
				ply.spec_mode = OBS_MODE_CHASE
			end
			-- roam stays roam

			ply:Spectate(ply.spec_mode)
		end
	end
end

if GAMEMODE and GAMEMODE.KeyPress then GAMEMODE.KeyPress = TTTKeyPress end

hook.Add("OnGamemodeLoaded", "Replace TTT KeyPress func", function()
	GAMEMODE.KeyPress = TTTKeyPress
end)
