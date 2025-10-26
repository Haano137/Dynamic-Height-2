include("shared.lua")
include("server_classic.lua")
AddCSLuaFile("client.lua")

local cvarHeightEnabled = CreateConVar("dh2_sv_dynamicheight", "1", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, }, "Enables Dynamic Height 2 for the server.")
local cvarDynamicMode = CreateConVar("dh2_sv_dynamicmode", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, }, "Choose how your View Height is dynamically adjusted for each player in the server. (Enforced)")

--local cvarHeightMax = CreateConVar("sv_dynamicheight_max", "64", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})
--local cvarHeightMin = CreateConVar("sv_dynamicheight_min", "28", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE})

local function supportedPlayermodelOffset(ply)
	--local plymdl = DynamicHeightTwo:GetModelNamePath(ply)
	local bone = ply:GetBoneName(DynamicHeightTwo:GetBone(ply))
	--local mychoice = bone

	local offset = function (choice)
		local bone = {
			["Head"] = function()
				return 11
			end,
			default = function()
				return 0 
			end,
		}

		if bone[choice] then
			return bone[choice]()
		else
			return bone["default"]()
		end
	end
	return offset(bone)
end


--///////////////////// REALTIME MODE
--/////////////////////      |
--/////////////////////      V

local function ShouldUpdateViewOffset(ply, seq, height)
	local mode = ply:GetInfoNum("cl_dh2_dynamicmode", 1)
	if mode == 1 and height ~= ply.dh2_height then
		return true
	elseif mode == 2 and (not ply.dh2_height or height > ply.dh2_height) then
		return true
	end
	return seq ~= ply.dh2_seq
end

local function UpdateViewOffset(ply)
	--local mdl = ply
	--local plymdl = DynamicHeightTwo:GetModelNamePath(ply)
	local seq = ply:GetSequence()
	local bone = DynamicHeightTwo:GetBone(ply) or ply._dh2_headbone
	--ply:PrintMessage(3, "[Dynamic Height GetBone()] bone: " .. tostring(bone))
	local height = 64
	local pos = Vector(0, 0, 0)
	local offset = supportedPlayermodelOffset(ply)

	if bone then
		local plyPos = ply:GetPos()
		pos = ply:GetBonePosition(bone) or pos

		if pos == plyPos then
			pos = ply:GetBoneMatrix(bone):GetTranslation() or pos
		end

		pos = pos - plyPos
		height = math.Round(pos.z + offset, 2)
	end


	if ShouldUpdateViewOffset(ply, seq, height) then
		if ply.dh2_pastheight == nill then
			ply.dh2_pastheight = height
			--print('\nNot nill anymore')
		end

		local lerpHeight = Lerp(ply:GetInfoNum("dh2_cl_camerasmoothness", 0.10), ply.dh2_pastheight, height)
		--local lerpHeight = Lerp(0.1, height, eyePosZ)
		--local eyePosZ = math.Round(ply:EyePos().z, 2)

		ply:SetViewOffset(Vector(ply:GetViewOffset()[1], ply:GetViewOffset()[2], lerpHeight))
		ply:SetViewOffsetDucked(Vector(ply:GetViewOffsetDucked()[1], ply:GetViewOffsetDucked()[2], lerpHeight))
		ply:SetCurrentViewOffset(Vector(ply:GetCurrentViewOffset()[1], ply:GetCurrentViewOffset()[2], lerpHeight))

		ply.dh2_seq = seq
		ply.dh2_height = Height
		ply.dh2_pastheight = lerpHeight

		--[[
		ply:ChatPrint('ply:EyePos(): ' .. tostring(ply:EyePos()))
		ply:ChatPrint('ply:GetPos(): ' .. tostring(ply:GetPos()))
		ply:ChatPrint('ply:GetViewOffsetDucked(): ' .. tostring(ply:GetViewOffsetDucked()))
		ply:ChatPrint('ply:GetCurrentViewOffset(): ' .. tostring(ply:GetCurrentViewOffset()))
		]]
		
	end
end

--///////////////////// CLASSIC MODE
--/////////////////////      |
--/////////////////////      V


local function GetViewOffsetValue(ply, sequence, offset)
	local height
	-- Find the height by spawning a dummy entity
	local entity = ents.Create("base_anim")
	entity:SetModel(ply:GetModel())

	local bone = DynamicHeightTwo:GetBone(entity)

	entity:ResetSequence(sequence)
	entity:SetPoseParameter("move_x", ply:GetPoseParameter("move_x"))
	entity:SetPoseParameter("move_y", ply:GetPoseParameter("move_y"))

	if bone then
		height = entity:GetBonePosition(bone).z + (offset or 3)
	end

	-- Removes dummy entity
	-- ply:ChatPrint(tostring(entity:GetClass()))
	-- print("Entities: " + ents.GetCount( boolean IncludeKillMe = false ))
	-- print("Entities: " + tostring(ents.GetCount( boolean IncludeKillMe = false )))


	--- entity:Remove()
	if entity then
		entity:Remove()
	end

	return height
end

local function UpdateView(ply)
	local offset = supportedPlayermodelOffset(ply)

	local height = GetViewOffsetValue(ply, "idle_all_01", offset) or ply._height_original or 64
	local crouch = GetViewOffsetValue(ply, "cidle_pistol", offset) or ply._crouch_original or 28

	--local crouch2 = GetViewOffsetValue(ply, ply:GetSequenceInfo(ply:GetSequence()).label, offset) or ply._crouch_original or 28
	--ply:ChatPrint("[Dynamic Height 2] Current Sequence: " .. ply:GetSequenceInfo(ply:GetSequence()).label)

	-- Update player height
	--local max = cvarHeightMax:GetInt()
	--local min = cvarHeightMin:GetInt()
	local max = 64
	local min = 28

	ply:SetViewOffset(Vector(0, 0, height))
	ply:SetViewOffsetDucked(Vector(0, 0, crouch))
	--ply:SetCurrentViewOffset(Vector(0, 0, crouch2))
		-- Causes stair stuttering
	--ply.ec_ViewChanged = true
end

--///////////////////// SETTINGs APPLYER
--/////////////////////         |
--/////////////////////         V

local function SettingsApplyer(ply)
	local activeDH2 = {
		[true] = function(ply)
			DynamicHeightTwo:GetPlayerModel(ply)
			
			local mode = ply:GetInfoNum("dh2_cl_dynamicmode", 1)
		
			if cvarDynamicMode:GetInt() ~= 0 then
				mode = cvarDynamicMode:GetInt()
			end		

			local dynamicMode = {
				[0] = function(ply)
					if (not tobool(ply.dh2_dm0_loop)) then
						ply:SetViewOffset(ply._height_original or Vector(ply:GetViewOffset()[1], ply:GetViewOffset()[2], 64))
						ply:SetViewOffsetDucked(ply._crouch_original or Vector(ply:GetViewOffsetDucked()[1], ply:GetViewOffsetDucked()[2], 28))
						
						--ply:ChatPrint("[Dynamic Height 2] Dynamic Mode: True 0")
						ply.dh2_classic_loop = false
						ply.dh2_dm0_loop = true
					end
				end,
				[1] = function(ply)
					UpdateViewOffset(ply)
					ply.dh2_classic_loop = false
					ply.dh2_dm0_loop = false
					--ply:ChatPrint("[Dynamic Height 2] Dynamic Mode - ply:GetModel(): " .. ply:GetModel())
					--ply:ChatPrint("[Dynamic Height 2] Dynamic Mode: True 1")
				end,
				[2] = function(ply)
					--ply:ChatPrint("[Dynamic Height 2] Dynamic Mode: " .. tostring(ply.dh2_classic_loop))
					if not(ply.dh2_classic_loop) or (ply:GetInfoNum("dh2_cl_aggressiveclassic", 1) == 1) then
						DynamicHeightTwo:UpdateView(ply)
						ply.dh2_classic_loop = true
						ply.dh2_dm0_loop = false
						--ply:ChatPrint("[Dynamic Height 2] Dynamic Mode: True 2")
						ply:ChatPrint("[Dynamic Height 2] Dynamic Mode - ply:GetModel(): " .. ply:GetModel())
						--ply:ChatPrint("[Dynamic Height 2] Dynamic Mode - ply.dh2_oftr_model: " .. tostring(ply.dh2_oftr_model or "none"))
					end
				end,
			  }
			dynamicMode[mode](ply)
			
			ply._dh2_deactive = 1
		end,
		[false] = function(ply)
			if ply._dh2_deactive == 1 then
				ply:SetViewOffset(ply._height_original or Vector(0, 0, 64))
				ply:SetViewOffsetDucked(ply._crouch_original or Vector(0, 0, 28))

				ply._height_original = ply:GetViewOffset()
				ply._crouch_original = ply:GetViewOffsetDucked()

				ply.dh2_classic_loop = false
				ply._dh2_deactive = 0
				ply:ChatPrint("[Dynamic Height 2] Dynamic Mode: False 0")
			end
			--ply:ChatPrint("[Dynamic Height 2] Dynamic Mode: False 1")
		end,
	}
	activeDH2[cvarHeightEnabled:GetBool()](ply)
end

--///////////////////// HOOKS
--/////////////////////   |
--/////////////////////   V

hook.Add("PlayerTick", "DynamicHeightTwo:PlayerTick", function(ply)
	ply._dh2_headbone = ply._dh2_headbone or nil
	SettingsApplyer(ply)
	
	--PrintMessage(HUD_PRINTTALK, "Player: " .. tostring(ply))
end)

cvars.AddChangeCallback("dh2_sv_dynamicheight", ConVarChanged)
cvars.AddChangeCallback("dh2_sv_dynamicmode", ConVarChanged)
--cvars.AddChangeCallback("sv_dynamicheight_min", ConVarChanged)
--cvars.AddChangeCallback("sv_dynamicheight_max", ConVarChanged)