--[[
	add by hy for display avatar and model.
]]
ModelDisplayer = ModelDisplayer or {}

ModelDisplayer.SHOWTYPE_AVATAR = 0
ModelDisplayer.SHOWTYPE_MODEL = 1
ModelDisplayer.SHOWTYPE_WEAPON_MODEL = 2
ModelDisplayer.SHOWTYPE_NONE = 3

local _showtype = -1
local _showModelId = 0

--local _storeModelId = 0
--local _storeShowtype = 0
--local _storeEquipments = {}
--local _storeSexType = 0

local _storeData = {}
ModelDisplayer.STORE_KEY_DEFAULT = "STORE_KEY_DEFAULT"
ModelDisplayer.KEY_STORE_MAIN_UI = "KEY_STORE_MAIN_UI"
ModelDisplayer.KEY_SUPPLY_MAIN_UI = "KEY_SUPPLY_MAIN_UI"
ModelDisplayer.KEY_STORE_PREVIEW_UI = "KEY_STORE_PREVIEW_UI"

function ModelDisplayer.Init(itemList, needAvatar)
	if needAvatar == nil then needAvatar = true end

	log("ModelDisplayer.Init")
	--log(debug.traceback())

	ModelDisplayer.Destroy()
	if needAvatar == true then
		MultipleAvatar.Init(itemList, {x = -55, y = -383, z = -14347}, {x = -5, y = -383, z = -24346})
	end

	ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
	MallSystemWeaponModelHandler:SetForceResetRotation(true)
	-- ModelDisplayer.Display(1400106)
end

function ModelDisplayer.Destroy()
	log("ModelDisplayer.Destroy")
	--log(debug.traceback())

	MultipleAvatar.Destroy()
	MallSystemWeaponModelHandler:SetForceResetRotation(false)
	MallSystemWeaponModelHandler:DestroyWeaponShowActor()
	_showtype = -1
	_showModelId = 0
end

local _beforeHideShowtype = -1
function ModelDisplayer.Hide()
	log("ModelDisplayer.Hide")
	--log(debug.traceback())

	_beforeHideShowtype = _showtype
	ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_NONE)
end

function ModelDisplayer.Show()
	log("ModelDisplayer.Show")
	--log(debug.traceback())

	ModelDisplayer.SetShowtype(_beforeHideShowtype)
	_beforeHideShowtype = -1
end

function ModelDisplayer.Store(storeKey)
	storeKey = storeKey or ModelDisplayer.STORE_KEY_DEFAULT

	local data = {}
	data._storeModelId = _showModelId
	data._storeShowtype = _showtype
	data._storeEquipments = MultipleAvatar.ShowingAvatar:GetEquipments()
	data._storeSexType = MultipleAvatar.ShowingAvatarSextype

	local pet = MultipleAvatar.ShowingAvatar:GetPet()
	if pet ~= nil then
		data._petType = pet:GetPetTypeID()
		data._petLevel = pet:GetLevel()
	else
		data._petType = 0
		data._petLevel = 0
	end

	_storeData[storeKey] = data
end

function ModelDisplayer.Restore(storeKey)
	storeKey = storeKey or ModelDisplayer.STORE_KEY_DEFAULT
	local data = _storeData[storeKey]
	if data == nil then
		log("ModelDisplayer.Restore storeKey data is nil.")
		return
	end

	ModelDisplayer.Display(data._storeModelId)
	MultipleAvatar.ShowSex(data._storeSexType)
	MultipleAvatar.SetStoreEquipments(data._storeEquipments)
	MultipleAvatar.RestoreEquipments()
	ModelDisplayer.SetShowtype(data._storeShowtype)

	if data._petType ~= 0 then
		MultipleAvatar.CreatePet(data._petType, data._petLevel)
	end
end

function ModelDisplayer.GetShowtype()
	return _showtype
end

function ModelDisplayer.SetShowtype(showtype)
	log("ModelDisplayer.SetShowtype")
	--log(debug.traceback())

	if _showtype == showtype then
		return
	end
	_showtype = showtype

	if showtype == ModelDisplayer.SHOWTYPE_AVATAR then
		MultipleAvatar.ShowAvatar()
		MallSystemWeaponModelHandler:HideWeapon()
		-- LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR)
		return
	end

	if showtype == ModelDisplayer.SHOWTYPE_MODEL 
	or showtype == ModelDisplayer.SHOWTYPE_WEAPON_MODEL
	then
		MultipleAvatar.HideAvatar()
		if MallSystemWeaponModelHandler.GetShowingId() == _showModelId then
			MallSystemWeaponModelHandler:ShowWeapon()
		else
			ModelDisplayer._Show3DModel(_showModelId)
		end
		-- ModelDisplayer._Show3DModel(_showModelId)
		-- LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_MODEL)
		return
	end

	if showtype == ModelDisplayer.SHOWTYPE_NONE then
		MultipleAvatar.HideAvatar()
		MallSystemWeaponModelHandler:HideWeapon()
		return
	end

end

function ModelDisplayer.OnAdaptChange()
	-- ModelDisplayer.Display(_storeModelId)
end

function ModelDisplayer.Display(itemID, colorID, patternID, isForceEquip)
	log("ModelDisplayer.Display")
	log(itemID)
	log(isForceEquip)

	--_showModelId = itemID
	local itemCfg = Client.GetTableData("Item", itemID)
	if itemCfg == nil then
		return
	end

	local sex = itemCfg.ShowSexInMall
	if sex == 2 then
		MultipleAvatar.ShowSex(LobbyAvatar.SEX_FEMALE)
	elseif sex == 1 then
		MultipleAvatar.ShowSex(LobbyAvatar.SEX_MALE)
	end
	MallSystemWeaponModelHandler:SetForceResetRotation(true)

	local itemType = itemCfg.ItemType
	local subType = itemCfg.ItemSubType
	if ModelDisplayer._Is3DModel(itemType) == true then
		_showModelId = itemID
		MallSystemWeaponModelHandler:SetForceResetRotation(false)
		
		if _showtype == ModelDisplayer.SHOWTYPE_MODEL then
			ModelDisplayer._Show3DModel(itemID)
		else
			ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_MODEL)
		end
		return
	end

	if ModelDisplayer._Is2DModel(itemType, subType) == true then
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_NONE)
		return
	end

	if ModelDisplayer._IsWeapon(itemType) == true then
		_showModelId = itemID
		if _showtype == ModelDisplayer.SHOWTYPE_WEAPON_MODEL then
			ModelDisplayer._Show3DModel(itemID)
			ModelDisplayer._PutonOrPutoff(itemID, colorID, patternID, isForceEquip)
		else
			ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
			ModelDisplayer._PutonOrPutoff(itemID, colorID, patternID, isForceEquip)
		end
		return
	end

	if ModelDisplayer._IsEmotion(itemType) == true then
		MultipleAvatar.PlayAction(itemID)
		return
	end

	if ModelDisplayer._IsPet(itemType) == true then
		ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
		if MultipleAvatar.HasPetEquiped(itemID) == false then
			MultipleAvatar.CreatePet(itemID,1)
		else
			if isForceEquip == false then
				MultipleAvatar.DestroyPet()
			end
		end
		return
	end

	ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
	ModelDisplayer._PutonOrPutoff(itemID, colorID, patternID, isForceEquip)
end

function ModelDisplayer._Show3DModel(itemID)
	MallSystemWeaponModelHandler:Init()
	MallSystemWeaponModelHandler:ShowWeaponByResId(itemID, true, true, true, false, false)
end

function ModelDisplayer._PutonOrPutoff(itemID, colorID, patternID, isForceEquip)
	isForceEquip = isForceEquip or false
	
	if MultipleAvatar.HasEquiped(itemID, colorID, patternID) == true then
		log("HasEquiped")
		if isForceEquip == false then
			MultipleAvatar.PutoffEquipment(itemID)
		end
	else
		log("Not HasEquiped")
		MultipleAvatar.PutonEquipment(itemID, colorID, patternID)
	end
end

function ModelDisplayer._Is3DModel(itemType)
	return itemType == 8 or itemType == 9
end

function ModelDisplayer._Is2DModel(itemType, subType)
	return (itemType == 4 and subType == 701) or
		itemType == 6 or
		itemType == 15 or
		itemType == 16 or 
		itemType == 19 or 
		itemType == 20 or 
		itemType == 21 or 
		itemType == 26 or
		itemType == 100 or 
		itemType == 200
end

function ModelDisplayer._IsWeapon(itemType)
	return itemType == 1
end

function ModelDisplayer._IsEmotion(itemType)
	return itemType == 22
end

function ModelDisplayer._IsPet(itemType)
	return itemType == 500
end