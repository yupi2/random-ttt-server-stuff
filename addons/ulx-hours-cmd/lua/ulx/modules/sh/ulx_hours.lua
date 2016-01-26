-- Generate a key at https://steamcommunity.com/dev/apikey
local steamWebApiKey = "INSERT_API_KEY_HERE"

function ulx.hours(calling_ply, target_ply)
	-- NOTE: Printing "(SILENT)" in logged string so admins won't be
	--  confused to whether the target player saw the hours thing or not.
	-- NOTE (AGAIN): Yes there's long lines. I don't want to fuck around with
	--  anything to shorten the lines because it might make it harder to
	--  read or something. It could also make it looks ugly

	local sID64 = target_ply:SteamID64()

	-- Compile list of admins that the hour-count should be sent to.
	-- TODO: See if this is done automatically with any functions.
	local admins = {}
	for _, plr in ipairs(player.GetAll()) do
		if ULib.ucl.query(plr, "ulx seeasay") or plr == calling_ply then
			table.insert(admins, plr)
		end
	end

	local onSuccess = function(body, length, headers, code)
		local pageJSON = util.JSONToTable(body)
		if not pageJSON then
			ulx.fancyLog(admins, "(SILENT) Couldn't get #T's GMOD hours; Steam is fucked.", target_ply)
			return
		end

		local gameCount = pageJSON["response"]["game_count"]

		-- game_count will not be listed in the JSON if the profile is private.
		if gameCount == nil then
			ulx.fancyLog(admins, "(SILENT) Couldn't get #T's GMOD hours; profile is private.", target_ply)
			return
		end

		-- game_count will be 0 if the owned games is filtered for a single
		--  game and the player doesn't have the game.
		if gameCount == 0 then
			ulx.fancyLog(admins, "(SILENT) Couldn't get #T's GMOD hours; player doesn't have GMOD?", target_ply)
			return
		end

		-- The playtime_forever value is in minutes so we make it hours!
		-- And we use string.format() to cut off the decimal places past one.
		-- AKA 123.4 instead of 123.45678.
		local totalPlaytime = string.format("%.1f", tonumber(pageJSON["response"]["games"][1]["playtime_forever"]) / 60)
		ulx.fancyLog(admins, "(SILENT) #T has #s hours recorded on GMOD.", target_ply, totalPlaytime)
	end

	local onError = function(errorStr)
		ulx.fancyLog(admins, "(SILENT) Couldn't get #T's GMOD hours; an error occurred with Steam.", target_ply)
		calling_ply:PrintMessage(HUD_PRINTCONSOLE, "Hour count Steam HTTP error from PLAYER " .. sID64 .. ": " .. errorStr)
		return
	end

	-- Use the Steam Web API to get the JSON and filter it to only include GMOD.
	http.Fetch(
		"http://api.steampowered.com/IPlayerService/GetOwnedGames/v0001/?format=json&appids_filter[0]=4000&key="
			.. steamWebApiKey .. "&steamid=" .. sID64,
		onSuccess, onError
	)
end
local hours = ulx.command( "Custom", "ulx hours", ulx.hours, "!hours" )
hours:addParam{ type=ULib.cmds.PlayerArg }
hours:defaultAccess( ULib.ACCESS_ADMIN )
hours:help( "Prints out how many hours a player has on GMOD to the admins." )
