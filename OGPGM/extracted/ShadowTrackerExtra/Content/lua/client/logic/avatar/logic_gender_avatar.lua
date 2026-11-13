--[[
	add by hy for lobby Gender avatar
]]
GenderAvatar = GenderAvatar or {}
GenderAvatar.SHOW_POSITION = {x = 70, y = 0, z = 90}
GenderAvatar.HIDE_POSITION = {x = 70, y = 0, z = 10000}

function GenderAvatar.Create(itemidList, showPosition, hidePosition, headid, fixSex)
	local mt = { __index = GenderAvatar }
	local result = {}
	setmetatable(result, mt)
	result:New(itemidList, showPosition, hidePosition, headid, fixSex)
	
	return result
end

function GenderAvatar.CreateMyself(showPosition, hidePosition)
	local equipments = {}
	for i, v in pairs(DataMgr.rolewear) do
		local cfg = DataMgr.GetHallDepotItemDataByInsID(v)
		local equipment = {itemID = cfg.resID, colorID = 0, patternID = 0}
		table.insert(equipments, equipment)
	end

	local weaponID = DataMgr.GetCurrentWeaponID()
	local equipment = {itemID = weaponID, colorID = 0, patternID = 0}
	table.insert(equipments, equipment)

	local fixSex = nil
	if DataMgr.avatarData.gamegender == 2 then
		fixSex = LobbyAvatar.SEX_FEMALE
	else
		fixSex = LobbyAvatar.SEX_MALE
	end

	return GenderAvatar.Create(equipments, showPosition, hidePosition, nil, fixSex)
end

function GenderAvatar:New(itemidList, showPosition, hidePosition, headid, fixSex)
	headid = headid or DataMgr.avatarData.headid
	itemidList = itemidList or {}
	self._showPosition = showPosition or GenderAvatar.SHOW_POSITION
	self._hidePosition = hidePosition or GenderAvatar.HIDE_POSITION

	self._fixGender = false
	if fixSex ~= nil then
		self._fixGender = true
	end

	self._storeEquipments = {}

	if self._fixGender == false or fixSex == LobbyAvatar.SEX_FEMALE then
		self._femaleAvatar = LobbyAvatar.Create(LobbyAvatar.SEX_FEMALE, headid)
	end

	if self._fixGender == false or fixSex == LobbyAvatar.SEX_MALE then
		self._maleAvatar = LobbyAvatar.Create(LobbyAvatar.SEX_MALE, headid)
	end

	if self._fixGender == true then
		self._showingAvatarSextype = fixSex
		if fixSex == LobbyAvatar.SEX_FEMALE then
			self._showingAvatar = self._femaleAvatar
		else
			self._showingAvatar = self._maleAvatar
		end
	else
		self:ShowMySex()
	end

    --Give a default hair by using player hair.
	self._showingAvatar:PutonEquipment(DataMgr.avatarData.hairid)

	for i,itemInfo in ipairs(itemidList) do
		self._showingAvatar:PutonEquipment(itemInfo.itemID, itemInfo.colorID, itemInfo.patternID)
	end

	self:ShowAvatar()
	-- self:StoreEquipments()
end

function GenderAvatar:Destroy()
	self._isShowing = false
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:Destroy()
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:Destroy()
	end

	self._showingAvatarSextype = nil
	self._showingAvatar = nil

	self._storeEquipments = {}
	self._femaleAvatar = nil
	self._maleAvatar = nil
end

function GenderAvatar:HasPetEquiped(petTypeID)
	if self._femaleAvatar ~= nil then
		return self._femaleAvatar:HasPetEquiped(petTypeID)
	end

	return self._maleAvatar:HasPetEquiped(petTypeID)
end

function GenderAvatar:CreatePet(petTypeID, level)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:CreatePet(petTypeID, level)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:CreatePet(petTypeID, level)
	end
end

function GenderAvatar:DestroyPet()
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:DestroyPet()
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:DestroyPet()
	end
end

function GenderAvatar:SetPetLevel(level)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:SetPetLevel(level)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:SetPetLevel(level)
	end
end

function GenderAvatar:SetPetName(name)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:SetPetName(name)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:SetPetName(name)
	end
end

function GenderAvatar:PlayPetAction(actionID)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:PlayPetAction(actionID)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:PlayPetAction(actionID)
	end
end

function GenderAvatar:StopPetAction()
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:StopPetAction()
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:StopPetAction()
	end
end

function GenderAvatar:GetShowingAvatar()
	return self._showingAvatar
end

function GenderAvatar:EnableRecyclable(value)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:EnableRecyclable(value)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:EnableRecyclable(value)
	end
end

function GenderAvatar:EnableLobbyPutonEvent(isEnable, callback)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:EnableLobbyPutonEvent(isEnable, callback)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:EnableLobbyPutonEvent(isEnable, callback)
	end
end

function GenderAvatar:EnableLobbyShowItem(isEnable)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:EnableLobbyShowItem(isEnable)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:EnableLobbyShowItem(isEnable)
	end
end

function GenderAvatar:EnableHatHelmetMutex(isEnable)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:EnableHatHelmetMutex(isEnable)
	end
	if self._maleAvatar ~= nil then
		self._maleAvatar:EnableHatHelmetMutex(isEnable)
	end
end

function GenderAvatar:FixGender()
	if self._fixGender == true then
		return
	end

	self._fixGender = true
	if self._showingAvatarSextype == LobbyAvatar.SEX_FEMALE then
		self._maleAvatar:Destroy()
		self._maleAvatar = nil
	else
		self._femaleAvatar:Destroy()
		self._femaleAvatar = nil
	end
end

function GenderAvatar:GetHalfheight()
	return self._showingAvatar:GetHalfheight()
end

function GenderAvatar:SetPosition(x, y, z)
	local position = {}
	position.x = x
	position.y = y
	position.z = z
	self._showPosition = position

	if self._isShowing == true then
		self:ShowAvatar()
	end
end

function GenderAvatar:SetFriendData(isSelfMale, isRight, isFriendMale)
	if self._femaleAvatar ~= nil then
		self._femaleAvatar:SetFriendData(isSelfMale, isRight, isFriendMale)
	end

	if self._femaleAvatar ~= nil then
		self._maleAvatar:SetFriendData(isSelfMale, isRight, isFriendMale)
	end
end

function GenderAvatar:ShowMySex()
	if self._fixGender == true then
		return
	end

	if DataMgr.avatarData.gamegender == 2 then
		self:ShowSex(LobbyAvatar.SEX_FEMALE)
	else
		self:ShowSex(LobbyAvatar.SEX_MALE)
	end
end

function GenderAvatar:SwitchSex()
	if self._fixGender == true then
		return
	end

	if self._showingAvatarSextype == LobbyAvatar.SEX_FEMALE then
		self:ShowSex(LobbyAvatar.SEX_MALE)
	else
		self:ShowSex(LobbyAvatar.SEX_FEMALE)
	end
end

function GenderAvatar:ShowSex(sexType)
	if self._fixGender == true then
		return
	end
	
	log("self:ShowSex sexType "..sexType)
	log("self:ShowSex  self._showingAvatarSextype "..tostring(self._showingAvatarSextype))
	if self._showingAvatarSextype == sexType then
		log("self:ShowSex sexType "..sexType.." is same")
		return
	end

	self:StopAction()
	self._showingAvatarSextype = sexType

	self._femaleAvatar:EnableClothAnimation(false)
	self._maleAvatar:EnableClothAnimation(false)

	if sexType == LobbyAvatar.SEX_FEMALE then
		self._femaleAvatar:PutonEquipment(self._maleAvatar:getHeadID())

		local rotation = self._maleAvatar:GetRotation()
		self._femaleAvatar:SetRotation(rotation.x, rotation.y, rotation.z)

		if self._isShowing == true then
			self._femaleAvatar:SetPosition(self._showPosition.x, self._showPosition.y, self._showPosition.z)
		else
			self._femaleAvatar:SetPosition(self._hidePosition.x, self._hidePosition.y, self._hidePosition.z)
		end
		self._maleAvatar:SetPosition(self._hidePosition.x, self._hidePosition.y, self._hidePosition.z)
		self._femaleAvatar:CopyEquipments(self._maleAvatar)

		self._showingAvatar = self._femaleAvatar
	else
		self._maleAvatar:PutonEquipment(self._femaleAvatar:getHeadID())

		local rotation = self._femaleAvatar:GetRotation()
		self._maleAvatar:SetRotation(rotation.x, rotation.y, rotation.z)
		
		if self._isShowing == true then
			self._maleAvatar:SetPosition(self._showPosition.x, self._showPosition.y, self._showPosition.z)
		else
			self._maleAvatar:SetPosition(self._hidePosition.x, self._hidePosition.y, self._hidePosition.z)
		end
		self._femaleAvatar:SetPosition(self._hidePosition.x, self._hidePosition.y, self._hidePosition.z)

		self._maleAvatar:CopyEquipments(self._femaleAvatar)
		self._showingAvatar = self._maleAvatar
	end

	self._femaleAvatar:EnableClothAnimation(true)
	self._maleAvatar:EnableClothAnimation(true)
end

function GenderAvatar:ShowAvatar()
	self._isShowing = true
	
	self._showingAvatar:SetPosition(self._showPosition.x, self._showPosition.y, self._showPosition.z)
	self._showingAvatar:EnableClothAnimation(true)
end

function GenderAvatar:HideAvatar()
	self._isShowing = false
	self._showingAvatar:EnableClothAnimation(false)
	self._showingAvatar:SetPosition(self._hidePosition.x, self._hidePosition.y, self._hidePosition.z)
end

function GenderAvatar:PutonEquipment(itemID, colorID, patternID)
	self._showingAvatar:PutonEquipment(itemID, colorID, patternID)
end

function GenderAvatar:PutoffEquipment(itemID)
	self._showingAvatar:PutoffEquipment(itemID)
end

function GenderAvatar:PutoffSubtype(subtype)
	self._showingAvatar:PutoffSubtype(subtype)
end

function GenderAvatar:ClearEquipments(unputoffList)
	self._showingAvatar:ClearEquipments(unputoffList)
end

function GenderAvatar:GetEquipments()
	return self._showingAvatar:GetEquipments()
end

function GenderAvatar:PutonOrPutoff(itemID, colorID, patternID, isForceEquip)
	isForceEquip = isForceEquip or false
	
	if self:HasEquiped(itemID, colorID, patternID) == true then
		if isForceEquip == false then
			self:PutoffEquipment(itemID)
		end
	else
		self:PutonEquipment(itemID, colorID, patternID)
	end
end

function GenderAvatar:HasEquiped(itemID, colorID, patternID)
	return self._showingAvatar:HasEquiped(itemID, colorID, patternID)
end

function GenderAvatar:SetStoreEquipments(equipments)
	self._storeEquipments = equipments
end

function GenderAvatar:StoreEquipments()
	self._storeEquipments = self._showingAvatar:GetEquipments()
end

function GenderAvatar:RestoreEquipments()
	self._showingAvatar:ClearEquipments()

	for subType,equipmentInfo in pairs(self._storeEquipments) do
		self._showingAvatar:PutonEquipment(equipmentInfo.itemID, equipmentInfo.colorID, equipmentInfo.patternID)
	end
end

function GenderAvatar:PlayAction(actionID)
	self:StopAction()
	self._showingAvatar:PlayAction(actionID)
end

function GenderAvatar:StopAction()
	if self._maleAvatar ~= nil then
		self._maleAvatar:StopAction()
	end

	if self._femaleAvatar ~= nil then
		self._femaleAvatar:StopAction()
	end
end