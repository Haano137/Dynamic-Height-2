function DynamicHeightTwo:GetPlayerModel(ply)
	local entity = ply

	hook.Add("RPUChanged","DynamicHeightTwo:RPUChanged",function(ply)
		entity:SetModel(ply:GetModel())
		--entity:PrintMessage(3, "[Dynamic Height 2] " .. entity:GetModel())
	end)

	util.AddNetworkString("DynamicHeightTwo:OutfitterModel")
	net.Receive("DynamicHeightTwo:OutfitterModel", function()
		local OutfitterModel = net.ReadString()
		if OutfitterModel == "" then
			OutfitterModel = entity:GetModel()
		end
		entity:SetModel(OutfitterModel)
		entity.dh2_classic_loop = false
		ply = entity
	end)
	
	--ply:PrintMessage(3, "[Dynamic Height 2] " .. ply:GetModel())
	--ply:PrintMessage(4, "") -- Words cannot begin to explain how it makes me feel about how removing this line breaks shit
	--ply:GetModel()
end



	-- Black Autumn Playermodel Selector v1.95
	util.AddNetworkString("BlackAutumnApplyPM")
	net.Receive("BlackAutumnApplyPM", function(len, ply)
		ply = ply or entity
		local newpmdata = net.ReadTable()
		local model = player_manager.TranslatePlayerModel(newpmdata.Name)

		entity:PrintMessage(3, "[Dynamic Height 2] " .. tostring(entity))

		entity.dh2_baps = true
		entity.dh2_baps_playermodel = model
		entity:PrintMessage(3, "[Dynamic Height 2] " .. tostring(entity.dh2_baps_playermodel))
	end)
	if entity.dh2_baps then
		--entity:SetModel(entity.dh2_baps_playermodel or ply:GetModel())
		entity.dh2_baps = false
		entity.dh2_baps_playermodel = nil
		ply = entity
		entity.dh2_classic_loop = false
	end

	
	-- Outfitter: Choose your player model: UnApply
	hook.Add("EnforceModel","DynamicHeightTwo:EnforceModel",function(pl,mdl,nocheck)
		dbg("EnforceModel",pl,mdl or "UNENFORCE")
	
		if not mdl then
			if pl.original_model then
				pl:SetModel(pl.original_model)
				pl.original_model = nil
			end
		end
		pl = pl or entity
		entity.dh2_classic_loop = false
		entity:PrintMessage(3, "[Dynamic Height 2] " .. entity:GetModel())
	end)

	

	-- Default Player Spawn
	hook.Add("PlayerSpawn","DynamicHeightTwo:PlayerSpawn",function(ply)
		local function CreateSomeTimers( )
			timer.Create( "UniqueName1", 1, 1, function() print( "inside" ) end )
		end
		hook.Add( "Initialize", "Timer Example", CreateSomeTimers )

		--ply:SetModel(entity:GetModel())
		--ply = entity
		timer.Simple( 5, function() print( "Hello World" ) end )
		entity.dh2_classic_loop = false
		ply:PrintMessage(3, "[Dynamic Height 2] Player Spawn: " .. ply:GetModel())
		--entity:PrintMessage(3, "[Dynamic Height 2] Default Player Spawn: " .. ply.dh2_enforce_model)
	end)
	
	-- Enhanced PlayerModel Selector
	util.AddNetworkString("lf_playermodel_update")
	net.Receive("lf_playermodel_update", function(len, ply)
		--local model = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"))

		--entity:SetModel(model)
		--ply = entity
		entity.dh2_classic_loop = false
		ply:PrintMessage(3, "[Dynamic Height 2] Enhanced PlayerModel Selector: " .. entity:GetModel())
	end)


	
	-- Playermodel Selector Support 2.0
	if not(entity.dh2_test_model1) or (entity.dh2_test_model1 ~= entity:GetModel())  then
		entity.dh2_test_model1 = entity:GetModel()
		entity.dh2_classic_loop = false
		entity:PrintMessage(3, "[Dynamic Height 2] Model Saved: " .. entity.dh2_test_model1)
	end
	
	-- Playermodel Selector Support 2.0
	if not(entity.dh2_test_model1) or (entity.dh2_test_model1 ~= entity:GetModel())  then
		
		entity.dh2_test_model1 = entity:GetModel()
		entity.dh2_classic_loop = false
		entity:PrintMessage(3, "[Dynamic Height 2] entity.dh2_test_model1: " .. entity.dh2_test_model1)
		entity:PrintMessage(3, "[Dynamic Height 2] entity.dh2_true_model: " .. (entity.dh2_true_model or "None"))
	end


	

	-- Outfitter: Choose your player model: Apply
	util.AddNetworkString("DynamicHeightTwo:OutfitterModel")
	net.Receive("DynamicHeightTwo:OutfitterModel", function()
		local OutfitterModels = net.ReadTable()
		if OutfitterModels[1] == "" then
			OutfitterModels[1] = entity:GetModel()
		end
		if OutfitterModels[2] == "" then
			OutfitterModels[1] = entity.dh2_true_model or ""
		end

		entity.dh2_oftr_model = OutfitterModels[1]
		entity.dh2_true_model = OutfitterModels[2]

		entity:SetModel(entity.dh2_oftr_model)
		entity.dh2_classic_loop = false
		--entity:PrintMessage(3, "[Dynamic Height 2] Outfitter - entity.dh2_true_model: " .. entity.dh2_true_model)
		--entity:PrintMessage(3, "[Dynamic Height 2] Outfitter - entity.dh2_oftr_model: " .. entity.dh2_oftr_model)
	end)
	

	-- Default Player Spawn
	--[[
	hook.Add("PlayerSpawn","DynamicHeightTwo:PlayerSpawn",function()
		entity.dh2_classic_loop = false
		entity:PrintMessage(3, "[Dynamic Height 2] PlayerSpawn: " .. entity:GetModel())
		entity:PrintMessage(3, "[Dynamic Height 2] PlayerSpawn: " .. tostring(entity.dh2_true_model or "None"))
	end)
	]]

	--[[
	-- Realtime Player Updater
	hook.Add("RPUChanged","DynamicHeightTwo:RPUChanged",function(ply)
		--self.ply = ply or entity
		entity.dh2_classic_loop = false
		entity:PrintMessage(3, "[Dynamic Height 2] Realtime Player Updater: " .. entity:GetModel())
	end)
	]]

	

	-- Vanilla + Various Playermodel Selector Support 2.0
	if entity.dh2_test_model1 ~= entity:GetModel() then
		entity.dh2_test_model1 = entity:GetModel()
		--entity:PrintMessage(3, "[Dynamic Height 2] Model Saved: " .. tostring(entity.dh2_test_model1))
		--entity:PrintMessage(3, "[Dynamic Height 2] truemodel: " .. tostring(entity.dh2_true_model))
		if not(entity.dh2_true_model == "" or entity.dh2_true_model == nil) then
			--entity:PrintMessage(3, "[Dynamic Height 2] VALID TRUE MODEL")
			hook.Add("PlayerSetModel","DynamicHeightTwo:PlayerSetModel",function()
				return false
			end)
		else
			hook.Add("PlayerSetModel","DynamicHeightTwo:PlayerSetModel",function()
				entity.dh2_classic_loop = false
				entity:PrintMessage(3, "[Dynamic Height 2] 2 " .. tostring(entity.dh2_classic_loop))
				return
			end)
		end
		--entity.dh2_classic_loop = false
		--entity:PrintMessage(3, "[Dynamic Height 2] 3 " .. tostring(entity.dh2_classic_loop))
	end

	-- Vanilla + Various Playermodel Selector Support 2.0 Optimized
	local modelChange = tobool(entity.dh2_test_model1 ~= entity:GetModel())
	local modelChangeFinder = {
		[true] = function(entity)
			entity.dh2_test_model1 = entity:GetModel()
			entity.dh2_classic_loop = false
			local modelChangeFinder = {
				[true] = function(entity)
					entity:PrintMessage(3, "[Dynamic Height 2] VALID TRUE MODEL")
					hook.Add("PlayerSetModel","DynamicHeightTwo:PlayerSetModel",function()
						return false
					end)
				end,
				[false] = function(entity)
					entity:PrintMessage(3, "[Dynamic Height 2] PLAYERMODEL CHANGED")
					hook.Add("PlayerSetModel","DynamicHeightTwo:PlayerSetModel",function()
						return
					end)
				end
			}
			modelChangeFinder[not(entity.dh2_true_model == "" or entity.dh2_true_model == nil)](entity)
		end,
		[false] = function(entity)
		end
	}
	modelChangeFinder[modelChange](entity)