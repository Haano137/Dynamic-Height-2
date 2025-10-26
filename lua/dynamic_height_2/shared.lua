-- Note to self: "LocalPlayer().enforce_model" = Outfitter playermodel
-- Note to self: LocalPlayer() is client-side only retrievable
-- Note to self: Enhanced Playermodel doesn't trigger PlayerTick for some reason

AddCSLuaFile()

DynamicHeightTwo = DynamicHeightTwo or {}

local bone_list = {
	"Head","ValveBiped.Bip01_Head1", "ValveBiped.Bip01_Neck1",
}

function DynamicHeightTwo:GetPlayerModel(ply)
	local entity = ply

	-- Vanilla + Various Playermodel Selector Support 2.0 Optimized
	local modelChange = tobool(entity.dh2_test_model1 ~= entity:GetModel())
	local modelChangeFinder = {
		[true] = function(entity)
			entity.dh2_test_model1 = entity:GetModel()
			entity.dh2_classic_loop = false
			local modelChangeFinder = {
				[true] = function(entity)
					--entity:PrintMessage(3, "[Dynamic Height 2] VALID TRUE MODEL")
					hook.Add("PlayerSetModel","DynamicHeightTwo:PlayerSetModel",function()
						return false
					end)
				end,
				[false] = function(entity)
					--entity:PrintMessage(3, "[Dynamic Height 2] PLAYERMODEL CHANGED")
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
	
end

function DynamicHeightTwo:GetBone(ply)
	local bone = 0
	for _, v in ipairs(bone_list) do
		bone = ply:LookupBone(v) or 0
		if bone > 0 then
			ply._dh2_headbone = bone
			return bone
		end
	end
	return bone
end

hook.Add("OutfitApply","DynamicHeightTwo:OutfitApply",function(ply)
	local dh2Enabled = tobool(ply:GetInfoNum("dh2_sv_dynamicheight", 0))
	--ply:PrintMessage(3, tostring(dh2Enabled))
	if ply==LocalPlayer() and dh2Enabled then
		local OutfitterModels = {LocalPlayer().enforce_model or "", LocalPlayer().original_model or ""}
		net.Start("DynamicHeightTwo:OutfitterModel")
			net.WriteTable(OutfitterModels)
		net.SendToServer()
		--ply:PrintMessage(3, "Outfit sent!")
	end
end)