CreateConVar("dh2_cl_dynamicmode", 1, {FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_USERINFO}, "Choose how your View Height is dynamically adjusted to match your playermodel.")
CreateConVar("dh2_cl_camerasmoothness", 0.10, {FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_USERINFO}, "Adjust how smooth or snappy the camera is during Realtime Mode.")
CreateConVar("dh2_cl_aggressiveclassic", 0, {FCVAR_CLIENTCMD_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_USERINFO}, "Makes Classic Mode run on PlayerTick rather than on Playermodel/Outfitter Change. (Not recommended) (Similar experience to Dynamic Height 1)")

include("shared.lua")

function DynamicHeightTwo:Refresh()
	self.model = nil
	self.sequence = nil
	self.pose = nil
end

concommand.Add("dh2_cl_refresh", function()
	DynamicHeightTwo:Refresh()
end)

-- Options Menu
hook.Add("PopulateToolMenu", "DynamicHeightTwo:PopulateToolMenu", function()

	spawnmenu.AddToolMenuOption("Options", "Dynamic Height 2", "DynamicHeight2Client", "Client", "", "", function(panel)
	  	local dyna = panel:ComboBox("Dynamic view height mode", "dh2_cl_dynamicmode")
		dyna:SetSortItems(false)
	  	dyna:AddChoice("Disabled", 0)
	  	dyna:AddChoice("\"Realtime\" mode", 1)
	  	dyna:AddChoice("\"Classic\" mode", 2)
	  	panel:ControlHelp("Choose how your View Height is dynamically adjusted to match your playermodel.")

		panel:AddControl("CheckBox", {
			Label = "Enable Aggressive Classic Mode",
			Command = "dh2_cl_aggressiveclassic",
		})
		panel:ControlHelp("Makes Classic Mode run on PlayerTick rather than on Playermodel/Outfitter Change. (Not recommended) (Similar experience to Dynamic Height 1)")

		local slider = panel:NumSlider( "Smoothness Slider (Realtime Mode)", "dh2_cl_camerasmoothness", 0.01, 1.00, 2 )
		panel:ControlHelp("Adjust how smooth or snappy the camera is during Realtime Mode.")

	  	--panel:Button("Reload model", "dh2_cl_refresh")
		--panel:ControlHelp("Forces a model reload. May be useful if the first-person model doesn't update after changing your playermodel for some reason.")
	end)

	spawnmenu.AddToolMenuOption("Options", "Dynamic Height 2", "DynamicHeight2Server", "Server", "", "", function(panel)
		panel:AddControl("CheckBox", {
			Label = "Enable Dynamic Height 2",
			Command = "dh2_sv_dynamicheight",
		})
		panel:ControlHelp("Enables Dynamic Height 2 for the server. Not enforceable.")

		
		local dyna = panel:ComboBox("Server Dynamic view height mode", "dh2_sv_dynamicmode")
		dyna:SetSortItems(false)
		dyna:AddChoice("Disabled", 0)
		dyna:AddChoice("\"Realtime\" mode", 1)
		dyna:AddChoice("\"Classic\" mode", 2)
		panel:ControlHelp("Choose how to Dynamically adjust view height for all player in the server.")
	end)

end)