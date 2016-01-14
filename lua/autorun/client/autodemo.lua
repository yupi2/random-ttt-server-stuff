local autorecorddemo = CreateConVar("autorecorddemo", "0", FCVAR_ARCHIVE)

local function my_autorecorddemo()
	if engine.IsRecordingDemo() then
		RunConsoleCommand("stop")
	end

	local timestamp = os.date("demos/%Y_%m_%d.%H-%M-%S.", os.time())
	local dynamic_name = timestamp .. game.GetMap()

	RunConsoleCommand("record", dynamic_name .. ".dem")
	RunConsoleCommand("record_screenshot", dynamic_name .. ".jpg")
end

hook.Add("TTTSettingsTabs", "autorecorddemo", function(dtabs)
	local dsettings = dtabs.Items[2].Panel

	local dgui = vgui.Create("DForm", dsettings)
	dgui:SetName("Automatically Record demos")

	if tttCustomSettings then
		dgui:TTTCustomUI_FormatForm()
	end

	dgui:CheckBox("Enable", "autorecorddemo")
	dsettings:AddItem(dgui)

	if tttCustomSettings then
		for k, v in pairs(dgui.Items) do
			for i, j in pairs(v:GetChildren()) do
				j.Label:TTTCustomUI_FormatLabel()
			end
		end
	end
end)

hook.Add("Initialize", "autorecorddemo", function()
	if autorecorddemo:GetBool() then
		my_autorecorddemo()
	end
end)

