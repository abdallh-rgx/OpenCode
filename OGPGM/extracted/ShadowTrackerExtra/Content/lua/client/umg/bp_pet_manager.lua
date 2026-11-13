--[[
	add by hy for LobbyPet
]]
LobbyPet = {}
local _pets = {}
LobbyPet.OPCODE_ATTACH_TO_CHARACTOR = "OPCODE_ATTACH_TO_CHARACTOR"
LobbyPet.OPCODE_ENABLE_ROTAITION = "OPCODE_ENABLE_ROTAITION"
LobbyPet.OPCODE_SET_NAME = "OPCODE_SET_NAME"

function LobbyPet:New(petTypeID, level)
	self._petTypeID = petTypeID or 0
	self._level = level or 1

	self._id = PetManager.CreateAvatar(self._petTypeID, self._level)
	self._position = {x = 0, y = 0, z = 0}

	_pets[self._id] = self
	self._callbacks = {}

	self._master = nil
	self:SetName("")
end

function LobbyPet:GetId()
	return self._id
end

function LobbyPet:SetLevel(level)
	if self._level == level then
		return
	end

	self._level = level

	--recreate model and attach to master
	PetManager.DestroyAvatar(self._id)
	_pets[self._id] = nil

	self._id = PetManager.CreateAvatar(self._petTypeID, self._level)
	_pets[self._id] = self

	if self._master ~= nil then
		local tmpMaster = self._master
		self._master = nil
		self:AttachToAvatar(tmpMaster)
	end
end

function LobbyPet:_AppendExtraData(appendData)
	-- log("LobbyPet:_AppendExtraData appendData ".. tostring(appendData))
	if appendData == true then
		appendData = 1
	elseif appendData == false then
		appendData = 0
	end

	self._extraData = self._extraData .. "|" .. appendData
end

function LobbyPet:_ApplyExtraData()
	log("LobbyPet:_ApplyExtraData appendData ".. self._extraData)
	PetManager.SetExtraData(self._id, self._extraData)
end

function LobbyPet:EnableRotation(isEnable)
	self._extraData = LobbyPet.OPCODE_ENABLE_ROTAITION
	self:_AppendExtraData(isEnable)

	self:_ApplyExtraData()
end

function LobbyPet:SetName(name)
	self._extraData = LobbyPet.OPCODE_SET_NAME
	self:_AppendExtraData(name)

	self:_ApplyExtraData()
end

function LobbyPet:GetPetTypeID()
	return self._petTypeID
end

function LobbyPet:GetLevel()
	return self._level
end


function LobbyPet:SetPosition(x, y, z)
	local position = self._position
	position.x = x
	position.y = y
	position.z = z

	PetManager.SetAvatarPosition(self._id, x, y, z)
end

function LobbyPet:SetRotation(x, y, z)
	PetManager.SetAvatarRotation(self._id, x, y, z)
end

function LobbyPet:SetScale(x, y, z)
	PetManager.SetAvatarScale(self._id, x, y, z)
end

function LobbyPet:GetRotation()
	return PetManager.GetAvatarRotation(self._id)
end

function LobbyPet:AttachToAvatar(avatar)
	if self._master ~= nil then
		return
	end

	self._master = avatar
	avatar:SetPet(self)

	self._extraData = LobbyPet.OPCODE_ATTACH_TO_CHARACTOR
	self:_AppendExtraData(avatar:GetId())

	self:_ApplyExtraData()
end

 function LobbyPet:PlayAction(actionID)
 	PetManager.PlayAction(self._id, actionID)
 end

 function LobbyPet:StopAction()
 	PetManager.StopAction(self._id)
 end

function LobbyPet.Create(petTypeID, level)
	local mt = { __index = LobbyPet }
	local result = {}
	setmetatable(result, mt)
	result:New(petTypeID, level)

	return result
end

function LobbyPet:Destroy(recyclable)
	PetManager.DestroyAvatar(self._id)
	_pets[self._id] = nil

	if self._master ~= nil then
		self._master:SetPet(nil)
		self._master = nil
	end
end

-- ======================== Avatar Manager
PetManager = PetManager or {}

BP_PetManagerCreateAvatarID = 0
BP_PetManagerOperateAvatarID = 0
BP_PetManagerOperateTypeID = ""
BP_PetManagerLevel = 0

BP_STRUCT_PetManager_ActionId = 0
BP_PetManager_ExtraData = ""

BP_STRUCT_PetManager_PositionData =
{
	x_f = 0,
	y_f = 0,
	z_f = 0,
}



function bp_pet_manager_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_pet_manager,
		{{Path="/Game/UMG/UI_Logic/LobbyPetManager.LobbyPetManager_C", Container="Default", ZOrder=BP_ENUM_UI_ACTIVITY_ZORDER}},
		{"Login","Lobby"},
		false,
		bp_pet_manager_OnModeSwitched ~= nil,
		true
	)
end

function PetManager.Show()
	log("PetManager.Show")
	-- log(debug.traceback())

	LuaClassObj.HandleDynamicCreation(bp_pet_manager)
	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "UIShow")

	-- _maleAvatarStack = {}
	-- _femaleAvatarStack = {}

	_pets = {}
	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "DestroyAllAvatar")
end

-- destory all avatar
function PetManager.Hide()
	log("PetManager.Hide")
	-- log(debug.traceback())

	-- PetManager._hasInit = false
	-- _maleAvatarStack = {}
	-- _femaleAvatarStack = {}

	_pets = {}
	
	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "DestroyAllAvatar")
	-- LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "UIHide")
end

function PetManager.CreateAvatar(petTypeID, level)

	BP_PetManagerOperateTypeID = tostring(petTypeID)
	BP_PetManagerLevel = level

	log("petmanager BP_PetManagerLevel ".. BP_PetManagerLevel)

	BP_PetManagerCreateAvatarID = BP_PetManagerCreateAvatarID + 1
	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "CreateAvatar")
	
	return BP_PetManagerCreateAvatarID
end

function PetManager.DestroyAvatar(avatarID)
	log("PetManager.DestroyAvatar")
	-- log(debug.traceback())

	BP_PetManagerOperateAvatarID = avatarID
	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "DestroyAvatar")
end

function PetManager.SetAvatarScale(avatarID, x, y, z)
	BP_PetManagerOperateAvatarID = avatarID

	BP_STRUCT_PetManager_PositionData.x_f = x
	BP_STRUCT_PetManager_PositionData.y_f = y
	BP_STRUCT_PetManager_PositionData.z_f = z

	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "UpdateScale")
end

function PetManager.SetAvatarPosition(avatarID, x, y, z)
	BP_PetManagerOperateAvatarID = avatarID

	BP_STRUCT_PetManager_PositionData.x_f = x
	BP_STRUCT_PetManager_PositionData.y_f = y
	BP_STRUCT_PetManager_PositionData.z_f = z

	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "UpdatePosition")
end

function PetManager.SetAvatarRotation(avatarID, x, y, z)
	BP_PetManagerOperateAvatarID = avatarID

	BP_STRUCT_PetManager_PositionData.x_f = x
	BP_STRUCT_PetManager_PositionData.y_f = y
	BP_STRUCT_PetManager_PositionData.z_f = z

	-- log_tree("SetAvatarRotation", BP_STRUCT_PetManager_PositionData)
	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "UpdateRotation")
end

function PetManager.GetAvatarRotation(avatarID)
	BP_PetManagerOperateAvatarID = avatarID

	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "GetRotation")

	local result = {}
	result.x = BP_STRUCT_PetManager_PositionData.x_f
	result.y = BP_STRUCT_PetManager_PositionData.y_f
	result.z = BP_STRUCT_PetManager_PositionData.z_f
	return result
end

 function PetManager.PlayAction(avatarID, actionID)
 	BP_PetManagerOperateAvatarID = avatarID
 	BP_STRUCT_PetManager_ActionId = actionID

 	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "PlayAction")
 end

 function PetManager.StopAction(avatarID)
 	BP_PetManagerOperateAvatarID = avatarID

 	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "StopAction")
 end

function PetManager.SetExtraData(avatarID, extraData)
	BP_PetManagerOperateAvatarID = avatarID
	BP_PetManager_ExtraData = extraData
	LuaClassObj.HandleUIMessageNoFetch(bp_pet_manager, "SetExtraData")
end

-- function EventPetManagerProcessExtraData()
-- 	log("EventPetManagerProcessExtraData")
-- 	log(BP_PetManager_ExtraData)

-- 	local extraDatas = string.split(BP_PetManager_ExtraData, "|")
-- 	local opcode = extraDatas[1]

-- 	if opcode == LobbyPet.EXTRADATA_LOBBY_PUTON_EVENT then
-- 		-- log_tree("extraDatas", extraDatas)
-- 		local avatarID = tonumber(extraDatas[2])
-- 		local slottype = tonumber(extraDatas[3])
-- 		local newItemID = tonumber(extraDatas[4])

-- 		local avatar = _pets[avatarID]
-- 		if avatar == nil then
-- 			return
-- 		end
		
-- 		avatar:CallEvent(LobbyPet.EXTRADATA_LOBBY_PUTON_EVENT, slottype, newItemID)
-- 		return
-- 	end
-- end