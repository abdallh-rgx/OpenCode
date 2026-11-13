--[[
	add by hy for LobyyAvatar
]]
-- Avatar
LobbyAvatar = {}
LobbyAvatar.SEX_FEMALE = 2
LobbyAvatar.SEX_MALE = 1

LobbyAvatar.EXTRADATA_FRIEND = "0"
LobbyAvatar.EXTRADATA_HALFHEIGHT = "1"
LobbyAvatar.EXTRADATA_LOBBY_PUTON_EVENT = "2"
LobbyAvatar.EXTRADATA_CHANGE_HEAD = "3"
LobbyAvatar.EXTRADATA_ENABLE_CLOTH_ANIMATION = "4"

LobbyAvatar.EQUIPMENT_SUBTYPE_WEAPON = 1
LobbyAvatar.EQUIPMENT_SUBTYPE_HAIR = 406

local _avatars = {}

function LobbyAvatar:New(sex, headId)
	self._recyclable = false
	
	self._sex = sex or 1
	self._headId = headId or 401999
	self._position = {x = 0, y = 0, z = 0}

	self._extraData = ""

	self._enableLobbyShowItem = true
	self._enbaleHatHelmetMutex = true

	self._equipments = {}
	self._storeEquipments = {}

	self._putoffEquipments = {}
	self._id = AvatarManager.CreateAvatar(self._sex, self._headId)

	_avatars[self._id] = self

    self._enablePutonEvent = false
	self._callbacks = {}
	self._pet = nil
end

function LobbyAvatar:CreatePet(petTypeID, level)
	if self._pet ~= nil then
		return
	end

	local pet = LobbyPet.Create(petTypeID, level)
	pet:AttachToAvatar(self)
end

function LobbyAvatar:DestroyPet()
	if self._pet == nil then
		return
	end

	self._pet:Destroy()
	self._pet = nil
end

function LobbyAvatar:SetPetLevel(level)
	if self._pet == nil then
		return
	end

	self._pet:SetLevel(level)
end

function LobbyAvatar:SetPetName(name)
	if self._pet == nil then
		return
	end

	self._pet:SetName(name)
end

function LobbyAvatar:HasPetEquiped(petTypeID,level)
	if petTypeID == nil then
		return self._pet ~= nil
	end

	if self._pet == nil then
		return false
	end

	if level == nil then
		level = self._pet:GetLevel()
	end

	return tonumber(self._pet:GetPetTypeID()) == tonumber(petTypeID) and (level == self._pet:GetLevel())
end

function LobbyAvatar:PlayPetAction(actionID)
	if self._pet == nil then
		return
	end

	self._pet:PlayAction(actionID)
end

function LobbyAvatar:StopPetAction()
	if self._pet == nil then
		return
	end

	self._pet:StopAction()
end

--just use for LobbyPet:AttachToAvatar(avatar)
function LobbyAvatar:SetPet(value)
	self._pet = value
end

function LobbyAvatar:GetPet()
	return self._pet
end

function LobbyAvatar:GetId()
	return self._id
end

function LobbyAvatar:getSex()
	return self._sex
end

function LobbyAvatar:getHeadID()
	return self._headId
end

function LobbyAvatar:GetHalfheight()
	self._extraData = LobbyAvatar.EXTRADATA_HALFHEIGHT
	self:_ApplyExtraData()

	return tonumber(BP_AvatarManager_ExtraData)
end

function LobbyAvatar:EnableClothAnimation(isEnable)
	self._extraData = LobbyAvatar.EXTRADATA_ENABLE_CLOTH_ANIMATION
	self:_AppendExtraData(isEnable)
	self:_ApplyExtraData()
end

function LobbyAvatar:_AppendExtraData(appendData)
	-- log("LobbyAvatar:_AppendExtraData appendData ".. tostring(appendData))
	if appendData == true then
		appendData = 1
	elseif appendData == false then
		appendData = 0
	end

	self._extraData = self._extraData .. "|" .. appendData
end

function LobbyAvatar:_ApplyExtraData()
	log("LobbyAvatar:_ApplyExtraData appendData ".. self._extraData)
	AvatarManager.SetExtraData(self._id, self._extraData)
end

function LobbyAvatar:SetFriendData(isSelfMale, isRight, isFriendMale)
	self._extraData = LobbyAvatar.EXTRADATA_FRIEND
	self:_AppendExtraData(isSelfMale)
	self:_AppendExtraData(isRight)
	self:_AppendExtraData(isFriendMale)

	self:_ApplyExtraData()
end

function LobbyAvatar:ClearFriendData()
	AvatarManager.ClearFriendData(self._id)
end

function LobbyAvatar:EnableLobbyPutonEvent(isEnable, callback)
	self._extraData = LobbyAvatar.EXTRADATA_LOBBY_PUTON_EVENT
	self:_AppendExtraData(isEnable)

	self:_ApplyExtraData()
    self._enablePutonEvent = isEnable
	if isEnable == true then
		self._callbacks[LobbyAvatar.EXTRADATA_LOBBY_PUTON_EVENT] = callback
	end
end

function LobbyAvatar:CallEvent(event, ...)
	local callback = self._callbacks[event]
	if callback ~= nil then
		callback(...)
	end
end

function LobbyAvatar:EnableLobbyShowItem(isEnable)
	self._enableLobbyShowItem = isEnable
end

function LobbyAvatar:EnableHatHelmetMutex(isEnable)
	self._enbaleHatHelmetMutex = isEnable
end

function LobbyAvatar:GetEquipments()
	local result = {}
	for subType,equipmentInfo in pairs(self._equipments) do
		result[subType] = self:_copyEquipmentData(equipmentInfo)
	end

	return result
end

function LobbyAvatar:GetPutoffEquipments()
	local result = {}
	for subType,equipmentInfo in pairs(self._putoffEquipments) do
		result[subType] = self:_copyEquipmentData(equipmentInfo)
	end

	return result
end

function LobbyAvatar:CopyEquipments(targetAvatar)
	self:ClearEquipments()
	local targetEquipments = targetAvatar:GetEquipments()

	for subType,equipmentInfo in pairs(targetEquipments) do
		self:PutonEquipment(equipmentInfo.itemID, equipmentInfo.colorID, equipmentInfo.patternID)
	end
end

function LobbyAvatar:StoreEquipments()
	self._storeEquipments = {}

	for subType,equipmentInfo in pairs(self._equipments) do
		self._storeEquipments[subType] = equipmentInfo
	end
end

function LobbyAvatar:RestoreEquipments()
	self:ClearEquipments()

	for subType,equipmentInfo in pairs(self._storeEquipments) do
		self:PutonEquipment(equipmentInfo.itemID, equipmentInfo.colorID, equipmentInfo.patternID)
	end

	self._storeEquipments = {}
end

function LobbyAvatar:HasEquiped(itemID, colorID, patternID)
	colorID = colorID or 0
	patternID = patternID or 0

	-- log("[LobbyAvatar] HasEquiped "..itemID.." "..colorID.." "..patternID)
	-- log_tree("self._equipments", self._equipments)
	
	local config = Client.GetTableData("Item", itemID)
	if config == nil then
		return false
	end

	local subType = self:_getDisplaySubtype(config)

	local currentEquipment = self._equipments[subType]
	if currentEquipment == nil then 
		return false
	end

	if currentEquipment.itemID == itemID
	and currentEquipment.colorID == colorID
	and currentEquipment.patternID == patternID
	then
		return true
	end

	return false
end

function LobbyAvatar:_GetDisplayItemID(itemID, subType)
	local displayItemID = itemID
	if self._enableLobbyShowItem == false then
		return displayItemID
	end

	-- Use Level 3 itemID
	if subType == 502 
	or subType == 504 
	or subType == 505 
	then
		local itemMappingCfg = Client.GetTableData("BackpackMapping", itemID)
		if itemMappingCfg ~= nil then
			displayItemID = itemMappingCfg.LobbyShowItemID			
		end
	end

	return displayItemID
end

function LobbyAvatar:PutonEquipment(itemID, colorID, patternID)
	if itemID == nil then
		log("[AvatarManager] Error: PutonEquipment itemID is nil ,skip...")
		log(debug.traceback())
		return
	end

	log("[AvatarManager] PutonEquipment "..itemID)
	for k,v in pairs(self._equipments) do
		log("[AvatarManager] currentEquipments ".. v.itemID.." id is "..self._id)
	end

	-- log(debug.traceback())
	self._putoffEquipments = {}

	colorID = colorID or 0
	patternID = patternID or 0

	local config = Client.GetTableData("Item", itemID)
	if config == nil then
		log("[LobbyAvatar] Error: config is nil "..itemID)
		--log(debug.traceback())
		return
	end
	local subType = self:_getDisplaySubtype(config)

	if self:HasEquiped(itemID, colorID, patternID) == true then
		log("[LobbyAvatar] avatar has equiped "..itemID)
		return
	end

	log("subType "..subType)
	-- For fix the Bug, recreate model when change face.!!!!!!
	if subType == 400 then
		if self._headId ~= itemID then
			self._headId = itemID
			log("Recreate Model")

			self:_recreateModel()
		end
		return
	end

	log("Normal Equipment")
	local currentEquipment = self._equipments[subType]
	if currentEquipment ~= nil and subType ~= 1 then
		self:PutoffEquipment(currentEquipment.itemID)
	end
	
	-- For fix the Bug, recreate model when puton special equipment.!!!!!!
	if itemID == 1405063 or itemID == 1405065 then
		self:_recreateModel()
	end

	local equipInfo = {}
	equipInfo.itemID = itemID
	equipInfo.colorID = colorID
	equipInfo.patternID = patternID
	equipInfo.subType = subType

	self._equipments[subType] = equipInfo

	local displayItemID = self:_GetDisplayItemID(itemID, subType)
	AvatarManager.PutOnItem(self._id, displayItemID, colorID, patternID)
end

function LobbyAvatar:PutoffEquipment(itemID)
	log("[AvatarManager] PutoffEquipment "..itemID)
	for k,v in pairs(self._equipments) do
		log("[AvatarManager] currentEquipments ".. v.itemID.." id is "..self._id)
	end

	local config = Client.GetTableData("Item", itemID)
	local subType = self:_getDisplaySubtype(config)

	local currentEquipment = self._equipments[subType]
	if currentEquipment == nil then
		return
	end

	if itemID ~= currentEquipment.itemID then
		log("ERROR : hy avatar PutoffEquipment false my id is " .. currentEquipment.itemID .. ", itemID  is " .. itemID)
		return
	end

	log("hy avatar PutoffEquipment "..itemID)
	self._equipments[subType] = nil
	table.insert(self._putoffEquipments, currentEquipment)
	local displayItemID = self:_GetDisplayItemID(itemID, subType)
	AvatarManager.PutOffItem(self._id, displayItemID)
end

function LobbyAvatar:PutoffSubtype(subtype)
	local currentEquipment = self._equipments[subtype]
	if currentEquipment == nil then
		return
	end

	self:PutoffEquipment(currentEquipment.itemID)
end

function LobbyAvatar:PutonEquipmentPreview(itemID, colorID, patternID)
	self:PutonEquipment(itemID, colorID, patternID)

	for i,equipment in ipairs(self._putoffEquipments) do
		local config = Client.GetTableData("Item", itemID)
		local subType = self:_getDisplaySubtype(config)

		if self._storeEquipments[subType] == nil then
			self._storeEquipments[subType] = equipment
		end
	end
end

function LobbyAvatar:ClearEquipments(unputoffList)
	log("ClearEquipments")

	unputoffList = unputoffList or {}
	local unputoffMap = {}

	for i,v in ipairs(unputoffList) do
		unputoffMap[v] = 1
	end

	log_tree("ClearEquipments",self._equipments)

	for subType,equipmentInfo in pairs(self._equipments) do
		if unputoffMap[subType] == nil then
			log("ClearEquipments "..subType)
			self:PutoffEquipment(equipmentInfo.itemID)
		end
	end
end

function LobbyAvatar:GetPosition()
	return self._position
end

function LobbyAvatar:SetPosition(x, y, z)
	local position = self._position
	position.x = x
	position.y = y
	position.z = z

	AvatarManager.SetAvatarPosition(self._id, x, y, z)
end

function LobbyAvatar:SetRotation(x, y, z)
	AvatarManager.SetAvatarRotation(self._id, x, y, z)
end

function LobbyAvatar:GetRotation()
	return AvatarManager.GetAvatarRotation(self._id)
end

function LobbyAvatar:PlayAction(actionID)
	AvatarManager.PlayAction(self._id, actionID)
end

function LobbyAvatar:StopAction()
	AvatarManager.StopAction(self._id)
end

function LobbyAvatar:_getDisplaySubtype(config)
	local subType = config.ItemSubType
	if config.ItemType == 1 then
		subType = 1
	end

	if self._enbaleHatHelmetMutex == true then
		if subType == 401 then
			subType = 502
		end
	end

	return subType
end

function LobbyAvatar:_copyEquipmentData(equipment)
	local result = {}
	result.itemID = equipment.itemID
	result.colorID = equipment.colorID
	result.patternID = equipment.patternID

	return result
end

function LobbyAvatar:_recreateModel()
	local tmpRotation = self:GetRotation()

	AvatarManager.DestroyAvatar(self._id)
	_avatars[self._id] = nil

	self._id = AvatarManager.CreateAvatar(self._sex, self._headId)
	_avatars[self._id] = self

	if self._enablePutonEvent == true then
		self:EnableLobbyPutonEvent(true)
	end

	local tmpEquipments = self:GetEquipments()
	self._equipments = {}

	log_tree("tmpEquipments",tmpEquipments)
	for subType,equipmentInfo in pairs(tmpEquipments) do
		self:PutonEquipment(equipmentInfo.itemID, equipmentInfo.colorID, equipmentInfo.patternID)
	end

	self:SetPosition(self._position.x, self._position.y, self._position.z)
	self:SetRotation(tmpRotation.x, tmpRotation.y, tmpRotation.z)

	-- process pet
	if self._pet ~= nil then
		local petTypeID = self._pet:GetPetTypeID()
		local petLevel = self._pet:GetLevel()

		self:DestroyPet()
		self:CreatePet(petTypeID, petLevel)
	end
end

function LobbyAvatar.Create(sex, headId)
	local avatar = nil
	if sex == LobbyAvatar.SEX_FEMALE then
		avatar = AvatarManager.PopFemaleAvatar()

	elseif sex == LobbyAvatar.SEX_MALE then
		avatar = AvatarManager.PopMaleAvatar()
	end

	if avatar ~= nil then
		avatar:PutonEquipment(headId)
		avatar:SetRotation(0, 0, 0)
		return avatar
	end

	local mt = { __index = LobbyAvatar }
	local result = {}
	setmetatable(result, mt)
	result:New(sex, headId)

	return result
end

function LobbyAvatar:EnableRecyclable(value)
	-- self._recyclable = value
end

function LobbyAvatar:Destroy(recyclable)
	log("==================recyclable ".. tostring(self._recyclable))
	-- log(debug.traceback())
	if self._recyclable == true then
		local isSuccess = false
		if self._sex == LobbyAvatar.SEX_FEMALE then
			isSuccess = AvatarManager.PushFemaleAvatar(self)

		elseif self._sex == LobbyAvatar.SEX_MALE then
			isSuccess = AvatarManager.PushMaleAvatar(self)
		end
		
		if isSuccess == true then
			self:SetPosition(999999, 999999, 999999)
			self:SetRotation(0, 0, 0)
			self:ClearEquipments()
			return
		end
	end

	if self._pet ~= nil then
		self._pet:Destroy()
		self._pet = nil
	end

	AvatarManager.DestroyAvatar(self._id)
	_avatars[self._id] = nil
end

function LobbyAvatar:AttachToPawnContainer(lobbyPawnContainer)
	AvatarManager.AttachAvatarToPawnContainer(self._id, lobbyPawnContainer:GetId())
end

function LobbyAvatar:DetachFromPawnContainer()
	AvatarManager.DetachAvatarFromPawnContainer(self._id)
end

function LobbyAvatar:GetRadius()
	AvatarManager.GetRadius(self._id)
	return tonumber(BP_AvatarManager_ExtraData)
end

function LobbyAvatar:SetCanRotate(isCan)
	AvatarManager.SetCanRotate(self._id, isCan)
end


--=================================================
LobbyPawnContainer = {}

local _pawnContainers = {}

function LobbyPawnContainer:New()
	self._id = AvatarManager.CreatePawnContainer()
	_pawnContainers[self._id] = self
end

function LobbyPawnContainer:GetId()
	return self._id
end

function LobbyPawnContainer:GetRotation()
	return AvatarManager.GetPawnContainerRotation(self._id)
end

function LobbyPawnContainer:SetRotation(x, y, z)
	AvatarManager.SetPawnContainerRotation(self._id, x, y, z)
end

function LobbyPawnContainer:GetPosition()
	local PositionData = AvatarManager.GetPawnContainerPosition(self._id)
	return {x = PositionData.x_f, y = PositionData.y_f, z = PositionData.z_f}
end

function LobbyPawnContainer:SetPosition(x, y, z)

	AvatarManager.SetPawnContainerPosition(self._id, x, y, z)
end

function LobbyPawnContainer:SetRadius(radius)
	AvatarManager.SetPawnContainerRadius(self._id, radius)
end

function LobbyPawnContainer:SetHalfHeight(height)
	AvatarManager.SetPawnContainerHalfHeight(self._id, height)
end

function LobbyPawnContainer:SetCanRotate(isCan)
	AvatarManager.SetPawnContainerCanRotate(self._id, isCan)
end

function LobbyPawnContainer.Create()
	local mt = { __index = LobbyPawnContainer }
	local result = {}
	setmetatable(result, mt)
	result:New()
	return result
end

function LobbyPawnContainer:Destroy()
	log("==================Destroy ".. tostring(self._id))
	AvatarManager.DestroyPawnContainer(self._id)
	_pawnContainers[self._id] = nil
end

-- ======================== Avatar Manager
AvatarManager = AvatarManager or {
	CreatePawnContainerID = 0,
}

BP_AvatarManagerCreateAvatarID = 0
BP_AvatarManagerOperateAvatarID = 0

BP_STRUCT_AvatarManager_CreateData =
{
	avatarID = 0,
	sex = 1,
	headId = 401999,
}

BP_STRUCT_AvatarManager_OperateItemData =
{
	isPutOn = true,
	itemID = 0,
	colorID = 0,
	patternID = 0,
}

BP_STRUCT_AvatarManager_PositionData =
{
	x_f = 0,
	y_f = 0,
	z_f = 0,
}

--父节点ID
BP_AvatarManager_PawnContainerID = 0

BP_STRUCT_AvatarManager_ActionId = 0

BP_AvatarManager_ExtraData = ""
local MAX_AVATAR_STACK_SIZE = 10
local _femaleAvatarStack = {}
local _maleAvatarStack = {}

function _GetAvatarStackSize()
	return #_femaleAvatarStack + #_maleAvatarStack
end

function _IsAvatarStackFull()
	return _GetAvatarStackSize() >= MAX_AVATAR_STACK_SIZE
end

function AvatarManager.PushFemaleAvatar(avatar)
	if _IsAvatarStackFull() == true then
		return false
	end

	table.insert(_femaleAvatarStack, avatar)
	return true
end

function AvatarManager.PopFemaleAvatar()
	local top = #_femaleAvatarStack

	if top == 0 then
		return nil
	end

	local result = _femaleAvatarStack[top]
	_femaleAvatarStack[top] = nil
	return result
end

function AvatarManager.PushMaleAvatar(avatar)
	if _IsAvatarStackFull() == true then
		return false
	end
	
	table.insert(_maleAvatarStack, avatar)
	return true
end

function AvatarManager.PopMaleAvatar()
	local top = #_maleAvatarStack
	
	if top == 0 then
		return nil
	end

	local result = _maleAvatarStack[top]
	_maleAvatarStack[top] = nil
	return result
end

-- AvatarManager._hasInit = false

function bp_avatar_mamger_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_avatar_mamger,
		{{Path="/Game/UMG/UI_Logic/LobbyAvatarManager.LobbyAvatarManager_C", Container="Default", ZOrder=BP_ENUM_UI_ACTIVITY_ZORDER}},
		{"Login","Lobby"},
		false,
		bp_avatar_mamger_OnModeSwitched ~= nil,
		true
	)
end

function AvatarManager.Show()
	log("AvatarManager.Show")
	-- log(debug.traceback())

	LuaClassObj.HandleDynamicCreation(bp_avatar_mamger)
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "UIShow")

	_maleAvatarStack = {}
	_femaleAvatarStack = {}

	_avatars = {}
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "DestroyAllAvatar")
end

-- destory all avatar
function AvatarManager.Hide()
	log("AvatarManager.Hide")
	-- log(debug.traceback())

	-- AvatarManager._hasInit = false
	_maleAvatarStack = {}
	_femaleAvatarStack = {}

	_avatars = {}
	
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "DestroyAllAvatar")
	-- LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "UIHide")
end

function AvatarManager.CreateAvatar(sex, headId)
	sex = sex or LobbyAvatar.SEX_MALE
	headId = headId or 401999

	BP_AvatarManagerCreateAvatarID = BP_AvatarManagerCreateAvatarID + 1

	BP_STRUCT_AvatarManager_CreateData.avatarID = BP_AvatarManagerCreateAvatarID
	BP_STRUCT_AvatarManager_CreateData.sex = sex
	BP_STRUCT_AvatarManager_CreateData.headId = headId

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "CreateAvatar")
	
	return BP_AvatarManagerCreateAvatarID
end

function AvatarManager.DestroyAvatar(avatarID)
	log("AvatarManager.DestroyAvatar")
	-- log(debug.traceback())

	BP_AvatarManagerOperateAvatarID = avatarID
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "DestroyAvatar")
end

function AvatarManager.PutOnItem(avatarID, itemID, colorID, patternID)
	BP_AvatarManagerOperateAvatarID = avatarID
	colorID = colorID or 0
	patternID = patternID or 0

	BP_STRUCT_AvatarManager_OperateItemData.isPutOn = true
	BP_STRUCT_AvatarManager_OperateItemData.itemID = itemID
	BP_STRUCT_AvatarManager_OperateItemData.colorID = colorID
	BP_STRUCT_AvatarManager_OperateItemData.patternID = patternID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "ChangeItem")
end

function AvatarManager.PutOffItem(avatarID, itemID)
	BP_AvatarManagerOperateAvatarID = avatarID

	BP_STRUCT_AvatarManager_OperateItemData.isPutOn = false
	BP_STRUCT_AvatarManager_OperateItemData.itemID = itemID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "ChangeItem")
end

function AvatarManager.SetAvatarPosition(avatarID, x, y, z)
	BP_AvatarManagerOperateAvatarID = avatarID

	BP_STRUCT_AvatarManager_PositionData.x_f = x
	BP_STRUCT_AvatarManager_PositionData.y_f = y
	BP_STRUCT_AvatarManager_PositionData.z_f = z

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "UpdatePosition")
end

function AvatarManager.SetAvatarRotation(avatarID, x, y, z)
	BP_AvatarManagerOperateAvatarID = avatarID

	BP_STRUCT_AvatarManager_PositionData.x_f = x
	BP_STRUCT_AvatarManager_PositionData.y_f = y
	BP_STRUCT_AvatarManager_PositionData.z_f = z

	-- log_tree("SetAvatarRotation", BP_STRUCT_AvatarManager_PositionData)
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "UpdateRotation")
end

function AvatarManager.GetAvatarRotation(avatarID)
	BP_AvatarManagerOperateAvatarID = avatarID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "GetRotation")

	local result = {}
	result.x = BP_STRUCT_AvatarManager_PositionData.x_f
	result.y = BP_STRUCT_AvatarManager_PositionData.y_f
	result.z = BP_STRUCT_AvatarManager_PositionData.z_f
	return result
end

function AvatarManager.PlayAction(avatarID, actionID)
	BP_AvatarManagerOperateAvatarID = avatarID
	BP_STRUCT_AvatarManager_ActionId = actionID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "PlayAction")
end

function AvatarManager.StopAction(avatarID)
	BP_AvatarManagerOperateAvatarID = avatarID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "StopAction")
end

function AvatarManager.ClearFriendData(avatarID)
	BP_AvatarManagerOperateAvatarID = avatarID
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "ClearFriendData")
end

function AvatarManager.GetRadius(avatarID)
	BP_AvatarManagerOperateAvatarID = avatarID
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "GetRadius")
end

function AvatarManager.SetExtraData(avatarID, extraData)
	BP_AvatarManagerOperateAvatarID = avatarID
	BP_AvatarManager_ExtraData = extraData
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "SetExtraData")
end

function AvatarManager.SetCanRotate(avatarID, isCan)
	BP_AvatarManagerOperateAvatarID = avatarID
	BP_AvatarManager_ExtraData = isCan and "1" or "0"
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "SetCanRotate")
end


function EventAvatarManagerProcessExtraData()
	log("EventAvatarManagerProcessExtraData")
	log(BP_AvatarManager_ExtraData)

	local extraDatas = string.split(BP_AvatarManager_ExtraData, "|")
	local opcode = extraDatas[1]

	if opcode == LobbyAvatar.EXTRADATA_LOBBY_PUTON_EVENT then
		-- log_tree("extraDatas", extraDatas)
		local avatarID = tonumber(extraDatas[2])
		local slottype = tonumber(extraDatas[3])
		local newItemID = tonumber(extraDatas[4])

		local avatar = _avatars[avatarID]
		if avatar == nil then
			return
		end
		
		avatar:CallEvent(LobbyAvatar.EXTRADATA_LOBBY_PUTON_EVENT, slottype, newItemID)
		return
	end
end

function AvatarManager.CreatePawnContainer()
	AvatarManager.CreatePawnContainerID = AvatarManager.CreatePawnContainerID + 1
	BP_AvatarManager_PawnContainerID = AvatarManager.CreatePawnContainerID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "CreatePawnContainer")
	return BP_AvatarManager_PawnContainerID
end

function AvatarManager.DestroyPawnContainer(pawnContainerID)
	BP_AvatarManager_PawnContainerID = pawnContainerID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "DestroyPawnContainer")
	return BP_AvatarManager_PawnContainerID
end

function AvatarManager.AttachAvatarToPawnContainer(avatarID, pawnContainerID)
	BP_AvatarManagerOperateAvatarID = avatarID
	BP_AvatarManager_PawnContainerID = pawnContainerID
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "AttachAvatarToPawnContainer")
end

function AvatarManager.DetachAvatarFromPawnContainer(avatarID)
	BP_AvatarManagerOperateAvatarID = avatarID
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "DetachAvatarFromPawnContainer")
end


function AvatarManager.SetPawnContainerRotation(pawnContainerID, x, y, z)
	BP_AvatarManager_PawnContainerID = pawnContainerID

	BP_STRUCT_AvatarManager_PositionData.x_f = x
	BP_STRUCT_AvatarManager_PositionData.y_f = y
	BP_STRUCT_AvatarManager_PositionData.z_f = z

	-- log_tree("SetAvatarRotation", BP_STRUCT_AvatarManager_PositionData)
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "SetPawnContainerRotation")
end

function AvatarManager.GetPawnContainerRotation(pawnContainerID)
	BP_AvatarManager_PawnContainerID = pawnContainerID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "GetPawnContainerRotation")

	local result = {}
	result.x = BP_STRUCT_AvatarManager_PositionData.x_f
	result.y = BP_STRUCT_AvatarManager_PositionData.y_f
	result.z = BP_STRUCT_AvatarManager_PositionData.z_f
	return result
end


function AvatarManager.SetPawnContainerPosition(pawnContainerID, x, y, z)
	BP_AvatarManager_PawnContainerID = pawnContainerID

	BP_STRUCT_AvatarManager_PositionData.x_f = x
	BP_STRUCT_AvatarManager_PositionData.y_f = y
	BP_STRUCT_AvatarManager_PositionData.z_f = z

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "SetPawnContainerPosition")
end

function AvatarManager.GetPawnContainerPosition(pawnContainerID)
	BP_AvatarManager_PawnContainerID = pawnContainerID

	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "GetPawnContainerPosition")

	local result = {}
	result.x = BP_STRUCT_AvatarManager_PositionData.x_f
	result.y = BP_STRUCT_AvatarManager_PositionData.y_f
	result.z = BP_STRUCT_AvatarManager_PositionData.z_f
	return result
end

function AvatarManager.SetPawnContainerRadius(pawnContainerID, radius)
	BP_AvatarManager_PawnContainerID = pawnContainerID
	BP_AvatarManager_ExtraData = tostring(radius) 
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "SetPawnContainerRadius")
end

function AvatarManager.SetPawnContainerHalfHeight(pawnContainerID, height)
	BP_AvatarManager_PawnContainerID = pawnContainerID
	BP_AvatarManager_ExtraData = tostring(height)
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "SetPawnContainerHalfHeight")
end

function AvatarManager.SetPawnContainerCanRotate(avatarID, isCan)
	BP_AvatarManager_PawnContainerID = avatarID
	BP_AvatarManager_ExtraData = isCan and "1" or "0"
	LuaClassObj.HandleUIMessageNoFetch(bp_avatar_mamger, "SetPawnContainerCanRotate")
end
