--[[
	add by hy for team avatar manager
]]
TeamAvatarManager = TeamAvatarManager or {}
TeamAvatarManager.MUTEX_TEMP = "MUTEX_TEMP"
TeamAvatarManager.MUTEX_OPEN_BOX = "OpenBoxUI"
TeamAvatarManager.MUTEX_ROLEINFO = "RoleInfo"

local _isShowing = true

local POSITION_KEY_OCCUPIED = 4
local _teamPosition = {
	{-5, 0, 89.5, false},
	{115, -30, 89.5, false},
	{50, -90, 89.5, false},
	{200, -70, 89.5, false}
}

local _mutex = nil

local _avatars = {}
-- local _myAvatar = nil
local function _logError(callback)
	log("===================================================[TeamAvatarManager] Error======================================================")
	--log(debug.traceback())
	callback()
end

local function _logErrorAvatarNotExisted(avatarUID)
	_logError(function()
		log(avatarUID .. " not existed")
	end)
end

local function _GetEmptyPosition()
	-- log_tree("[TeamAvatarManager] _teamPosition ", _teamPosition)
	for i,v in ipairs(_teamPosition) do
		-- log("v[POSITION_KEY_OCCUPIED]"..v[POSITION_KEY_OCCUPIED])
		if v[POSITION_KEY_OCCUPIED] == false then
			local result = {}

			result.x = v[1]
			result.y = v[2]
			result.z = v[3]
			result.index = i

			return result
		end
	end

	return nil
end

local function _OccupyPosition(index, value)
	_teamPosition[index][POSITION_KEY_OCCUPIED] = value
end

local function _IsVaildItemID(itemID)
	if itemID == 0 then
		log("itemID not valid:" .. tostring(itemID))
		return false
	end

	if itemID == nil then
		_logError(function()
			log("itemID not valid:" .. tostring(itemID))
		end)
		return false
	end

	if type(itemID) ~= "number" then
		_logError(function()
			log("itemID not valid:" .. tostring(itemID))
		end)
		return false
	end

	return true
end

function TeamAvatarManager.GetMutex(mutex)
	if _mutex ~= nil then
		log("[TeamAvatarManager] GetMutex " .. tostring(mutex) .. " failure , current mutex is" .. tostring(_mutex))
		return
	end

	_mutex = mutex
end

function TeamAvatarManager.ReleaseMutex(mutex)
	if _mutex ~= mutex then
		log("[TeamAvatarManager] ReleaseMutex " .. tostring(mutex) .. " failure , current mutex is" .. tostring(_mutex))
		return
	end

	_mutex = nil
end

function TeamAvatarManager.Init()
	TeamAvatarManager.Destroy()

	EventSystem:registEvent(EVENTTYPE_PET,EVENTID_PET_PlayAction, TeamAvatarManager.OnTeamPetAction)
	EventSystem:registEvent(EVENTTYPE_PET,EVENTID_PET_LevelUp, TeamAvatarManager.OnTeamPetLevelup)
	EventSystem:registEvent(EVENTTYPE_PET,EVENTID_PET_EquipPet_Change, TeamAvatarManager.OnChangeTeamPet)
	EventSystem:registEvent(EVENTTYPE_PET,EVENTID_PET_Rename, TeamAvatarManager.OnChangeTeamPetName)

end

function TeamAvatarManager.Destroy()
	EventSystem:unregistEvent(EVENTTYPE_PET,EVENTID_PET_PlayAction, TeamAvatarManager.OnTeamPetAction)
	EventSystem:unregistEvent(EVENTTYPE_PET,EVENTID_PET_LevelUp, TeamAvatarManager.OnTeamPetLevelup)
	EventSystem:registEvent(EVENTTYPE_PET,EVENTID_PET_EquipPet_Change, TeamAvatarManager.OnChangeTeamPet)
	EventSystem:registEvent(EVENTTYPE_PET,EVENTID_PET_Rename, TeamAvatarManager.OnChangeTeamPetName)

	TeamAvatarManager.PetData = {}
	_mutex = nil

	for k,avatar in pairs(_avatars) do
		avatar:Destroy()
	end
	_avatars = {}

	for i,v in ipairs(_teamPosition) do
		_OccupyPosition(i, false)
	end
end

    -- BP_STRUCT_SpawnPlayerData =
    -- {
    --     gid = tostring(playerData.gid),
    --     sex = playerData.avatar.gamegender,
    --     headId = playerData.avatar.headid,
    --     index = BP_LobbyPlayerNum,
    --     BP_ARRAY_AvatarList = playerData.BP_ARRAY_AvatarList or {},
    --     weaponResId = playerData.weaponId or 0,
    --     weaponSkinId = playerData.weaponSkinId or 0,
    --     bagSkinInsId = playerData.bagSkinInsId or 0,
    --     headShow = playerData.headShow or 0,
    -- }

function TeamAvatarManager.CreateAvatar(playerData)

	log("[TeamAvatarManager] CreateAvatar")
	-- log(debug.traceback())
	-- log_tree("playerData ",playerData)

	local showPosition = _GetEmptyPosition()
	if showPosition == nil then
		log("[TeamAvatarManager] _teamPosition is full... not create")
		return
	end

	_OccupyPosition(showPosition.index, true)

	local fixSex = nil
	if playerData.sex == 1 then
		fixSex = LobbyAvatar.SEX_FEMALE
	else
		fixSex = LobbyAvatar.SEX_MALE
	end
	local avatar = GenderAvatar.Create({}, showPosition, nil, playerData.headId , fixSex)
	local uid = tostring(playerData.gid)
	_avatars[uid] = avatar

	--if playerData.sex == 1 then
	--	avatar:ShowSex(LobbyAvatar.SEX_FEMALE)
	--else
	--	avatar:ShowSex(LobbyAvatar.SEX_MALE)
	--end
	--avatar:FixGender()
	avatar:EnableHatHelmetMutex(false)
	avatar:EnableLobbyShowItem(false)


	--local PetSystem = require("client.slua.logic.pet.logic_pet")
	--log("[TeamAvatarManager] GetEquipedPet uid " .. uid)
	--log("[TeamAvatarManager] GetEquipedPet DataMgr.roleData.uid " .. DataMgr.roleData.uid)
	--if tostring(uid) == tostring(DataMgr.roleData.uid) then
	--	log("[TeamAvatarManager] GetEquipedPet DataMgr.roleData.uid " .. DataMgr.roleData.uid)
		--local petID = PetSystem.GetEquipedPet()

		--TeamAvatarManager.PutonEquipment(uid, DataMgr.avatarData.beardid, DataMgr.avatarData.beardcolorid)
		--log("[TeamAvatarManager] GetEquipedPet " .. petID)
		--if petID ~= 0 then
		--	avatar:GetShowingAvatar():CreatePet(petID)
		--else
		--	avatar:GetShowingAvatar():DestroyPet()
		--end
	--end

	--TeamAvatarManager.PutonEquipment(uid, playerData.headId)
	TeamAvatarManager.PutonEquipment(uid, playerData.headShow)

	TeamAvatarManager.PutonEquipment(uid, playerData.weaponResId)
	TeamAvatarManager.PutonEquipment(uid, playerData.weaponSkinId)

	TeamAvatarManager.PutonEquipment(uid, playerData.bagSkinInsId)

	for i,v in ipairs(playerData.BP_ARRAY_AvatarList) do
		TeamAvatarManager.PutonEquipment(uid, v.resID, v.colorID, v.patternID)
	end
	avatar.positionIndex = showPosition.index

	if _isShowing == false then
		avatar:HideAvatar()
	end

	--create pet
	local petInfo = TeamAvatarManager.PetData[tostring(uid)]
	if petInfo ~= nil then
		TeamAvatarManager.OnChangeTeamPet(uid, petInfo.petTypeID, petInfo.petLevel)
	end

	return avatar
end

function TeamAvatarManager.DestroyAvatar(playerData)
	log("[TeamAvatarManager] DestroyAvatar")
	-- log_tree("[TeamAvatarManager] DestroyAvatar playerData", playerData)
	-- log_tree("[TeamAvatarManager] DestroyAvatar _avatars ", _avatars)
	local gid = tostring(playerData.gid)

	local avatar = _avatars[gid]
	if avatar == nil then
		_logErrorAvatarNotExisted(gid)
		return
	end
	_OccupyPosition(avatar.positionIndex, false)

	avatar:Destroy()
	_avatars[gid] = nil
end

function TeamAvatarManager.GetMainAvatar()
	return _avatars[tostring(DataMgr.roleData.uid)]
end

function TeamAvatarManager.GetAvatarCount()
	local result = 0

	for gid, avatar in pairs(_avatars) do
		result = result + 1
	end

	return result
end

function TeamAvatarManager.EnablePutonEvent(AvatarUID, isEnable)
	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:EnableLobbyPutonEvent(isEnable, nil)
end

function TeamAvatarManager.PutoffInvalidEquipments()
	log("[TeamAvatarManager] PutoffInvalidEquipment")

	for gid, avatar in pairs(_avatars) do
		local equipments = avatar:GetEquipments()
		
		for subtype, equipment in pairs(equipments) do
			if WardrobeSystem.IsItemIsolated(equipment.itemID) then
				avatar:PutoffEquipment(equipment.itemID)

				log("[TeamAvatarManager] PutoffInvalidEquipment " .. gid .. " itemID " .. equipment.itemID)
			end
		end
	end
end

function TeamAvatarManager.PutonEquipment(AvatarUID, itemID, colorID, patternID)
	if _IsVaildItemID(itemID) == false then
		return
	end

	--log(debug.traceback())
	log("[TeamAvatarManager] PutonEquipment AvatarUID "..AvatarUID.." itemID "..itemID)
	-- log("[TeamAvatarManager] PutonEquipment colorID "..colorID)
	-- log("[TeamAvatarManager] PutonEquipment patternID "..patternID)
	-- log_tree("[TeamAvatarManager] PutonEquipment _avatars ", _avatars)

	if WardrobeSystem.IsItemIsolated(itemID) == true then
		log("[TeamAvatarManager] PutonEquipment IsItemIsolated "..itemID)
		return
	end

	log("[TeamAvatarManager] PutonEquipment not IsItemIsolated "..itemID)

	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:PutonEquipment(itemID, colorID, patternID)
end

function TeamAvatarManager.PutoffEquipment(AvatarUID, itemID)
	if _IsVaildItemID(itemID) == false then
		return
	end

	log("[TeamAvatarManager] PutoffEquipment AvatarUID "..AvatarUID.." itemID "..itemID)
	-- log("[TeamAvatarManager] PutoffEquipment AvatarUID "..AvatarUID)
	-- log("[TeamAvatarManager] PutoffEquipment itemID "..itemID)
	-- log_tree("[TeamAvatarManager] PutoffEquipment _avatars ", _avatars)

	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:PutoffEquipment(itemID)
end

function TeamAvatarManager.PlayAction(AvatarUID, actionID)
	log("[TeamAvatarManager] PlayAction AvatarUID "..AvatarUID)
	log("[TeamAvatarManager] PlayAction actionID "..actionID)
	
	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:PlayAction(actionID)
end

function TeamAvatarManager.PutoffSubtype(AvatarUID, subtype)
	log("[TeamAvatarManager] PutoffSubtype AvatarUID "..AvatarUID)
	log("[TeamAvatarManager] PutoffSubtype subtype "..subtype)
	-- log_tree("[TeamAvatarManager] PutoffEquipment _avatars ", _avatars)
	
	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:PutoffSubtype(subtype)
end

function TeamAvatarManager.IsShowing()
	return _isShowing
end

function TeamAvatarManager.ShowAllAvatar(mutex)
	log("[TeamAvatarManager] ShowAllAvatar")

	if _mutex ~= nil and _mutex ~= mutex then
		log("[TeamAvatarManager] ShowAllAvatar failure, mutex is " .. tostring(mutex) .. ", current mutex is" .. tostring(_mutex))
		return
	end

	_isShowing = true

	for k,v in pairs(_avatars) do
		v:ShowAvatar()
	end
end

function TeamAvatarManager.HideAllAvatar(mutex)
	log("[TeamAvatarManager] HideAllAvatar")

	if _mutex ~= nil and _mutex ~= mutex then
		log("[TeamAvatarManager] HideAllAvatar failure, mutex is " .. tostring(mutex) .. ", current mutex is" .. tostring(_mutex))
		return
	end
	_isShowing = false

	for k,v in pairs(_avatars) do
		v:HideAvatar()
	end
end


--About Pet
function TeamAvatarManager.test()
	for k,v in pairs(_avatars) do
		log("[TeamAvatarManager] test")
		v:PlayPetAction(50001006)
	end
end

function TeamAvatarManager.OnTeamPetAction(eventType, eventID, petData)
	local AvatarUID = petData.UID
	local petActionID = petData.PetActionID

	log("[TeamAvatarManager] OnTeamPetAction uid "..AvatarUID.." petActionID "..petActionID)

	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:PlayPetAction(petActionID)
end

function TeamAvatarManager.OnTeamPetLevelup(eventType, eventID, petData)
	local AvatarUID = petData.UID
	local petLevel = petData.PetLevel
	log("[TeamAvatarManager] OnTeamPetLevelup uid "..AvatarUID.." level "..petLevel)

	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:SetPetLevel(petLevel)
end

function TeamAvatarManager.OnChangeTeamPet(eventType, eventID, petData)
	local uid = petData.UID
	local petTypeID = petData.PetID
	local petLevel = petData.PetLevel

	log("[TeamAvatarManager] OnChangeTeamPet uid "..uid.." petid "..petTypeID.." level "..petLevel)
	if petTypeID ~= 0 then
		TeamAvatarManager.CreatePet(uid, petTypeID, petLevel)
	else
		TeamAvatarManager.DestroyPet(uid)
	end
end

function TeamAvatarManager.TestData()
	local data = {}
	data.UID = DataMgr.roleData.uid
	data.PetID = 1
	data.PetName = "测试名字"
	TeamAvatarManager.OnChangeTeamPetName(1, 1, data)
end

function TeamAvatarManager.OnChangeTeamPetName(eventType, eventID, petData)
	local uid = petData.UID
	local petTypeID = petData.PetID
	local petName = petData.PetName

	log("[TeamAvatarManager] OnChangeTeamPetName uid "..uid.." petid "..petTypeID.." petName "..petName)
	TeamAvatarManager.SetPetName(uid, petName)
end

function TeamAvatarManager.CreatePet(AvatarUID, petTypeID, petLevel)
	petTypeID = petTypeID or 0
	log("[TeamAvatarManager] CreatePet AvatarUID "..AvatarUID.."petTypeID "..petTypeID)

	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	if (avatar:HasPetEquiped(petTypeID,petLevel) == true) then
		return
	end

	TeamAvatarManager.DestroyPet(AvatarUID)
	avatar:CreatePet(petTypeID, petLevel)
end

function TeamAvatarManager.DestroyPet(AvatarUID)
	log("[TeamAvatarManager] DestroyPet AvatarUID "..AvatarUID)

	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	log("[TeamAvatarManager] DestroyPet")
	avatar:DestroyPet()
end

function TeamAvatarManager.SetPetName(AvatarUID, petName)
	log("[TeamAvatarManager] CreatePet AvatarUID "..AvatarUID.."petName "..petName)

	if true then
		-- 策划需求，先屏蔽组队名字
		return
	end

	local avatar = _avatars[tostring(AvatarUID)]
	if avatar == nil then
		_logErrorAvatarNotExisted(AvatarUID)
		return
	end

	avatar:SetPetName(petName)
end

--Pet logic data
TeamAvatarManager.PetData = {}

function TeamAvatarManager.SetPetData(uid, petTypeID, petLevel)
	local petInfo = {}
	petInfo.petTypeID = petTypeID or 0
	petInfo.petLevel = petLevel or 1

	TeamAvatarManager.PetData[tostring(uid)] = petInfo
	TeamAvatarManager.OnChangeTeamPet(uid, petTypeID, petLevel)
end

