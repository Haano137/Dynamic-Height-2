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

function DynamicHeightTwo:UpdateView(ply)
	local offset = DynamicHeightTwo:supportedPlayermodelOffset(ply)

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