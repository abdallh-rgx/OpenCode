--[[
	add by hy for lobby multiple avatar
]]
MultipleAvatar = MultipleAvatar or {}

MultipleAvatar.FemaleAvatar = nil
MultipleAvatar.MaleAvatar = nil

-- MultipleAvatar._showPosition = {x = 25, y = -383, z = -14347}
-- MultipleAvatar._hidePosition = {x = -5, y = -383, z = -24346}
MultipleAvatar.SHOW_POSITION = {x = 70, y = 0, z = 90}
MultipleAvatar.HIDE_POSITION = {x = 70, y = 0, z = 10000}

MultipleAvatar._showPosition = {x = 70, y = 0, z = 90}
MultipleAvatar._hidePosition = {x = 70, y = 0, z = 10000}

MultipleAvatar.ShowingAvatarSextype = nil
MultipleAvatar.ShowingAvatar = nil

MultipleAvatar._storeEquipments = {}

local _isShowing = false
-- itemidList = {itemID=0, colorID=0, patternID=0}
-- showPosition/hidePosition = {x = 70, y = 0, z = 90}
function MultipleAvatar.Init(itemidList, showPosition, hidePosition)
	log("MultipleAvatar.Init")
	--

	itemidList = itemidList or {}
	MultipleAvatar._showPosition = showPosition or MultipleAvatar.SHOW_POSITION
	MultipleAvatar._hidePosition = hidePosition or MultipleAvatar.HIDE_POSITION

	log_tree("MultipleAvatar._showPosition",MultipleAvatar._showPosition)
	MultipleAvatar._storeEquipments = {}

	MultipleAvatar.Destroy()
	MultipleAvatar.FemaleAvatar = LobbyAvatar.Create(LobbyAvatar.SEX_FEMALE, DataMgr.avatarData.headid)
	MultipleAvatar.MaleAvatar = LobbyAvatar.Create(LobbyAvatar.SEX_MALE, DataMgr.avatarData.headid)

	MultipleAvatar.ShowMySex(true)
	MultipleAvatar.ShowingAvatar:PutonEquipment(DataMgr.avatarData.hairid)
	MultipleAvatar.ShowingAvatar:PutonEquipment(DataMgr.avatarData.beardid, DataMgr.avatarData.beardcolorid)
	for i,itemInfo in ipairs(itemidList) do
		MultipleAvatar.ShowingAvatar:PutonEquipment(itemInfo.itemID, itemInfo.colorID, itemInfo.patternID)
	end

	MultipleAvatar.ShowAvatar()
	MultipleAvatar.StoreEquipments()
end

function MultipleAvatar.Destroy()
	log("MultipleAvatar.Destroy")
	--

	_isShowing = false
	if MultipleAvatar.FemaleAvatar ~= nil then
		MultipleAvatar.FemaleAvatar:Destroy()
	end
	if MultipleAvatar.MaleAvatar ~= nil then
		MultipleAvatar.MaleAvatar:Destroy()
	end

	MultipleAvatar.ShowingAvatarSextype = nil
	MultipleAvatar.ShowingAvatar = nil

	MultipleAvatar._storeEquipments = {}
	MultipleAvatar.FemaleAvatar = nil
	MultipleAvatar.MaleAvatar = nil
end

function MultipleAvatar.CreatePet(petTypeID, level)
	petTypeID = petTypeID or 0
	level = level or 0
	MultipleAvatar.FemaleAvatar:CreatePet(petTypeID, level)
	MultipleAvatar.MaleAvatar:CreatePet(petTypeID, level)
end

function MultipleAvatar.DestroyPet()
	MultipleAvatar.FemaleAvatar:DestroyPet()
	MultipleAvatar.MaleAvatar:DestroyPet()
end

function MultipleAvatar.SetPetLevel(level)
	MultipleAvatar.FemaleAvatar:SetPetLevel(level)
	MultipleAvatar.MaleAvatar:SetPetLevel(level)
end

function MultipleAvatar.HasPetEquiped(petTypeID)
	if MultipleAvatar.FemaleAvatar ~= nil then
		return MultipleAvatar.FemaleAvatar:HasPetEquiped(petTypeID)
	end

	return MultipleAvatar.MaleAvatar:HasPetEquiped(petTypeID)
end

function MultipleAvatar.PlayPetAction(actionID)
	MultipleAvatar.FemaleAvatar:PlayPetAction(actionID)
	MultipleAvatar.MaleAvatar:PlayPetAction(actionID)
end

function MultipleAvatar.StopPetAction()
	MultipleAvatar.FemaleAvatar:StopPetAction()
	MultipleAvatar.MaleAvatar:StopPetAction()
end

function MultipleAvatar.EnableLobbyPutonEvent(isEnable, callback)
	if MultipleAvatar.FemaleAvatar then
		MultipleAvatar.FemaleAvatar:EnableLobbyPutonEvent(isEnable, callback)
	end
	if MultipleAvatar.MaleAvatar then
		MultipleAvatar.MaleAvatar:EnableLobbyPutonEvent(isEnable, callback)
	end
end

function MultipleAvatar.SetShowPosition(x, y, z)
	if MultipleAvatar.ShowingAvatar == nil then

		return false
	end

	local position = {}
	position.x = x
	position.y = y
	position.z = z
	MultipleAvatar._showPosition = position

	if _isShowing == true then
		MultipleAvatar.ShowAvatar()
	end
end

-- function MultipleAvatar:SetRotation(x, y, z)
-- 	MultipleAvatar.ShowingAvatar:SetRotation(x, y, z)
-- end

function MultipleAvatar.ShowMySex(isInit)
	isInit = isInit or false

	if isInit == false and MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	if DataMgr.avatarData.gamegender == 2 then
		MultipleAvatar.ShowSex(LobbyAvatar.SEX_FEMALE, isInit)
	else
		MultipleAvatar.ShowSex(LobbyAvatar.SEX_MALE, isInit)
	end
end

function MultipleAvatar.SwitchSex()
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	if MultipleAvatar.ShowingAvatarSextype == LobbyAvatar.SEX_FEMALE then
		MultipleAvatar.ShowSex(LobbyAvatar.SEX_MALE)
	else
		MultipleAvatar.ShowSex(LobbyAvatar.SEX_FEMALE)
	end
end

function MultipleAvatar.ShowSex(sexType, isInit)
	isInit = isInit or false

	if isInit == false and MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	log("MultipleAvatar.ShowSex sexType "..sexType)
	log("MultipleAvatar.ShowSex  MultipleAvatar.ShowingAvatarSextype "..tostring(MultipleAvatar.ShowingAvatarSextype))
	if MultipleAvatar.ShowingAvatarSextype == sexType then
		log("MultipleAvatar.ShowSex sexType "..sexType.." is same")
		return
	end

	MultipleAvatar.StopAction()
	MultipleAvatar.ShowingAvatarSextype = sexType




	if sexType == LobbyAvatar.SEX_FEMALE then

		local rotation = MultipleAvatar.MaleAvatar:GetRotation()
		MultipleAvatar.FemaleAvatar:SetRotation(rotation.x, rotation.y, rotation.z)

		if _isShowing == true then
			MultipleAvatar.FemaleAvatar:SetPosition(MultipleAvatar._showPosition.x, MultipleAvatar._showPosition.y, MultipleAvatar._showPosition.z)
		else
			MultipleAvatar.FemaleAvatar:SetPosition(MultipleAvatar._hidePosition.x, MultipleAvatar._hidePosition.y, MultipleAvatar._hidePosition.z)
		end
		MultipleAvatar.MaleAvatar:SetPosition(MultipleAvatar._hidePosition.x, MultipleAvatar._hidePosition.y, MultipleAvatar._hidePosition.z)

		MultipleAvatar.FemaleAvatar:CopyEquipments(MultipleAvatar.MaleAvatar)
		MultipleAvatar.MaleAvatar:EnableClothAnimation(false)

		MultipleAvatar.ShowingAvatar = MultipleAvatar.FemaleAvatar
		MultipleAvatar.FemaleAvatar:EnableClothAnimation(true)
	else

		local rotation = MultipleAvatar.FemaleAvatar:GetRotation()
		MultipleAvatar.MaleAvatar:SetRotation(rotation.x, rotation.y, rotation.z)
		
		if _isShowing == true then
			MultipleAvatar.MaleAvatar:SetPosition(MultipleAvatar._showPosition.x, MultipleAvatar._showPosition.y, MultipleAvatar._showPosition.z)
		else
			MultipleAvatar.MaleAvatar:SetPosition(MultipleAvatar._hidePosition.x, MultipleAvatar._hidePosition.y, MultipleAvatar._hidePosition.z)
		end
		MultipleAvatar.FemaleAvatar:SetPosition(MultipleAvatar._hidePosition.x, MultipleAvatar._hidePosition.y, MultipleAvatar._hidePosition.z)

		MultipleAvatar.MaleAvatar:CopyEquipments(MultipleAvatar.FemaleAvatar)
		MultipleAvatar.FemaleAvatar:EnableClothAnimation(false)
		MultipleAvatar.ShowingAvatar = MultipleAvatar.MaleAvatar
		MultipleAvatar.MaleAvatar:EnableClothAnimation(true)
	end
end

function MultipleAvatar.CopyMyEquipments()
	local mainAvatar = TeamAvatarManager.GetMainAvatar()
	MultipleAvatar.ShowingAvatar:CopyEquipments(mainAvatar)
end

function MultipleAvatar.ShowAvatar()
	log("MultipleAvatar.ShowAvatar")
	--

	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	_isShowing = true
	MultipleAvatar.ShowingAvatar:SetPosition(MultipleAvatar._showPosition.x, MultipleAvatar._showPosition.y, MultipleAvatar._showPosition.z)
	MultipleAvatar.ShowingAvatar:EnableClothAnimation(true)
end

function MultipleAvatar.HideAvatar()
	log("MultipleAvatar.HideAvatar")
	--
	
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar.ShowingAvatar:EnableClothAnimation(false)

	_isShowing = false
	MultipleAvatar.ShowingAvatar:SetPosition(MultipleAvatar._hidePosition.x, MultipleAvatar._hidePosition.y, MultipleAvatar._hidePosition.z)
end

function MultipleAvatar.PutonEquipment(itemID, colorID, patternID)
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar.ShowingAvatar:PutonEquipment(itemID, colorID, patternID)
end

function MultipleAvatar.PutoffEquipment(itemID)
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar.ShowingAvatar:PutoffEquipment(itemID)
end

function MultipleAvatar.HasEquiped(itemID, colorID, patternID)
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	return MultipleAvatar.ShowingAvatar:HasEquiped(itemID, colorID, patternID)
end

function MultipleAvatar.SetStoreEquipments(equipments)
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar._storeEquipments = equipments
end

function MultipleAvatar.StoreEquipments()
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar._storeEquipments = MultipleAvatar.ShowingAvatar:GetEquipments()
end

function MultipleAvatar.RestoreEquipments()
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar.ShowingAvatar:ClearEquipments()

	for subType,equipmentInfo in pairs(MultipleAvatar._storeEquipments) do
		MultipleAvatar.ShowingAvatar:PutonEquipment(equipmentInfo.itemID, equipmentInfo.colorID, equipmentInfo.patternID)
	end
end

function MultipleAvatar.ClearEquipments(unputoffList)
	if MultipleAvatar.ShowingAvatar == nil then
		return false
	end
	MultipleAvatar.ShowingAvatar:ClearEquipments(unputoffList)
end


function MultipleAvatar.PlayAction(actionID)
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar.StopAction()
	MultipleAvatar.ShowingAvatar:PlayAction(actionID)
end

function MultipleAvatar.StopAction()
	if MultipleAvatar.ShowingAvatar == nil then


		return false
	end

	MultipleAvatar.MaleAvatar:StopAction()
	MultipleAvatar.FemaleAvatar:StopAction()
end