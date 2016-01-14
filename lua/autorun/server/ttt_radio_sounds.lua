---------------------------------------------------------
-- Plays a random sound for most of the radio commands --
---------------------------------------------------------

-- Goes into lua/autorun/server/
if SERVER then
	local radio_sounds = {
		quick_yes = {
			"vo/npc/vortigaunt/yes.wav",
			"vo/npc/male01/yeah02.wav",
			"vo/npc/barney/ba_ohyeah.wav",
			"vo/npc/barney/ba_yell.wav",
			"radio/ct_affirm.wav",
		},
		quick_no = {
			"vo/npc/male01/no01.wav",
			"vo/npc/male01/ohno.wav",
			"radio/negative.wav",
		},
		quick_help = {
			"vo/npc/male01/help01.wav",
			"vo/ravenholm/monk_helpme02.wav",
			"vo/npc/male01/runforyourlife01.wav",
			"vo/npc/male01/runforyourlife02.wav",
			"vo/npc/male01/runforyourlife03.wav",
			"radio/ct_backup.wav",
		},
		quick_imwith = {
			"vo/npc/male01/hi01.wav",
			"vo/npc/male01/hi02.wav",
		},
		quick_see = {
			"vo/npc/male01/overthere01.wav",
			"vo/npc/male01/overthere02.wav",
		},
		quick_suspect = {
			"vo/npc/male01/watchout.wav",
			"vo/ravenholm/firetrap_lookout.wav",
		},
		quick_traitor = {
			"radio/ct_enemys.wav",
			"vo/npc/male01/wetrustedyou01.wav",
			"vo/npc/male01/wetrustedyou02.wav",
			"vo/npc/male01/heretohelp01.wav",
			"vo/npc/male01/heretohelp02.wav",
		},
		quick_inno = {
			"vo/npc/Barney/ba_imwithyou.wav",
		},
		quick_check = {
			"vo/ravenholm/monk_mourn02.wav",
			"vo/ravenholm/monk_mourn03.wav",
		},
	}

	hook.Add("TTTPlayerRadioCommand", "EXakpoint - TTT Radio Sounds", function( ply, msg_name, msg_target )
		if ( ply.m_fNextTTTRadio and ply.m_fNextTTTRadio > CurTime() ) then
			return true
		end

		ply.m_fNextTTTRadio = CurTime() + 1.625

		local sounds = radio_sounds[ msg_name ]
		if sounds then
			ply:EmitSound( table.Random( sounds ), 75, 100 )
		end
	end)
end

