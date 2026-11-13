MallEditorUI = MallEditorUI or {}
MallEditorUI.isShowing = false
MallEditorUI.SAVE_FILE_PATCH = "d:\\logic_MallEditorSaveFileConfig.lua"
MallEditorUI.SAVE_FILE_CONTENT = ""

local MALL_CAMERA_FULL_SCREEN_CONFIG = "MALL_CAMERA_FULL_SCREEN_CONFIG"
local MALL_MODEL_ADAPT_CONFIG = "MALL_MODEL_ADAPT_CONFIG"
MallEditorUI.SAVE_DATA = {}

local exModel = nil

function bp_mall_editor_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_mall_editor,
	{
		{Path="/Game/UMG/UI_Logic/Lobby_Store/Store_2/LobbyMallEditor.LobbyMallEditor_C", Container="Default", ZOrder=0}
	},
	{"Lobby"},
	false,
	false,
	true
	);
	MallEditorUI._testSaveData()
end

function MallEditorUI._testSaveData()
end

function MallEditorUI.Show()
	MallEditorUI.isShowing = true
	LuaClassObj.HandleDynamicCreation(bp_mall_editor)
	LuaClassObj.HandleUIMessage(bp_mall_editor, "UIShow")

	LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
	local bp = UIUtil.GetWidgetByLogicName("bp_mall_editor")
	MallEditorUI.BP = bp
	bp.Button_Closeup_preview.OnClicked:Add(function()
		log("Button_Closeup_preview ........."..MallEditorUI.BP.EditableTextBox_Closeup_preview:GetText())
		LobbyCameraManager.EnterCloseupView(1,MultipleAvatar.ShowingAvatar)
	end)

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN)
	EventMallEditorLoadFile()
	LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_MALL_AVATAR)

	--LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_Background_Pat_int)

	ModelDisplayer.Init()


	-- =========================Slua=============================
	--local world = slua_GameFrontendHUD:GetWorld()
	--local tclass = slua.loadClass("/Game/AnimationTest/Cameara/CAMTEST.CAMTEST")
	--
	--local KismetMathLibrary = import("KismetMathLibrary")
	--local t = KismetMathLibrary:MakeTransform(FVector(0,0,0),FRotator(0,0,0),FVector(1,1,1))
	--local actor = world:SpawnActor(tclass, FVector(8,21,-14347),nil,nil)
	--actor:K2_SetActorRotation(FRotator(0,90,0),false)
	--
	--local playerController = slua_GameFrontendHUD:GetPlayerController()
	--playerController:SetViewTargetWithBlend(actor,0,0,0,false)
	--============================================================

	--LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.MALL_MESH_LobbyBgMesh, false)
	--LobbySceneManager.VisiableObjectsByTag(LobbySceneManager.MALL_MESH_Background_Weapon_02, true)
	--MultipleAvatar.MaleAvatar:Destroy()
	--MultipleAvatar.CreatePet(50001, 1)
	--MultipleAvatar.PlayPetAction(50001006)

	--local level = 1
	--Timer.InsertTimer(10,function()
	--	MultipleAvatar.PlayPetAction(50001006)
	--end,true)

	-- MultipleAvatar:ClearEquipments({LobbyAvatar.EQUIPMENT_SUBTYPE_HAIR})

	-- local a = LobbyPet.Create()
	-- a:SetPosition(100, 100, 100)
	-- local equipments = {}
	-- for i, v in pairs(DataMgr.rolewear) do
	-- 	local cfg = DataMgr.GetHallDepotItemDataByInsID(v)
	-- 	local equipment = {itemID = cfg.resID, colorID = 0, patternID = 0}
	-- 	table.insert(equipments, equipment)
	-- end

	-- local weaponID = DataMgr.GetCurrentWeaponID()
	-- local equipment = {itemID = weaponID, colorID = 0, patternID = 0}
	-- table.insert(equipments, equipment)

	-- for i,v in ipairs(equipments) do
	-- 	MultipleAvatar:PutonEquipment(v.itemID, v.colorID, v.patternID)
	-- end

	-- _avatar = GenderAvatar.CreateMyself({x = -55, y = -383, z = -14347}, {x = -5, y = -383, z = -24346})
	
	-- _avatar:PutonEquipment(401016)
	-- _avatar:PutonEquipment(40601001)
	
	-- MultipleAvatar:GetShowingAvatar():EnableHatHelmetMutex(false)

	-- ModelDisplayer.Display(BP_MALLEDITOR_operateItemID, 0, 0)
	-- ModelDisplayer.Display(BP_MALLEDITOR_operateItemID, 0, 0)
	-- ModelDisplayer.Display(BP_MALLEDITOR_operateItemID, 0, 0)
	-- ModelDisplayer.Display(BP_MALLEDITOR_operateItemID, 0, 0)
	-- ModelDisplayer.Display(BP_MALLEDITOR_operateItemID, 0, 0)
	-- log_tree("MallEditorSaveFile",MallEditorSaveFile)
	-- MallSystemWeaponModelHandler:SetForceResetRotation(true)

	--雪人盒子
	--exModel = SceneExtraModel.Create("/Game/Arts_Lobby/CookEntry/DeathBox/BluePrints/Ammo_DropBox_013/Ammo_DropBox_013.Ammo_DropBox_013_C")
	--exModel:SetPosition(-70, -434, -14438)

	--宠物鸟
	--exModel = LobbyPet.Create(50001, 1)
	--exModel:SetPosition(-70, -434, -14438)
	--exModel:SetRotation(0, 0, 90)
	--exModel:SetScale(5,5,5)
	--exModel:EnableRotation(true)

	--exModel = LobbyPet.Create()
	--exModel:AttachToAvatar(MultipleAvatar:ShowingAvatar)
	--exModel:SetPosition(-70, -434, -14438)
	--local index = 10001001
	--Timer.InsertTimer(3,function()
	--	log("=========================")
	--	index = index + 1
	--	MultipleAvatar:PlayPetAction(index)
	--	--exModel:PlayAction(10001001)
	--	--MultipleAvatar:DestroyPet()
	--end,true)

	--Timer.InsertTimer(5,function()
	--	log("=========================1")
	--	exModel:StopAction()
	--end)

	-- local ga2 = GenderAvatar.Create({},{x = -10, y = -383, z = -14347}, {x = -5, y = -383, z = -24346})
	-- ga2:PutonEquipment(1400106)

	-- ga2:SetRotation(0, 0, 90)

	-- log_tree("rotation", ga2:GetRotation())

	-- local ga = GenderAvatar.Create({},{x = -55, y = -383, z = -14347}, {x = -5, y = -383, z = -24346})
	-- ga:PutonEquipment(1400106)
	-- ga:StoreEquipments()
	-- ga:PutonEquipment(1400253)
	-- ga:PutonEquipment(106005)


	-- Timer.InsertTimer(5,function()
	-- 	log("=========================")
	-- 	MultipleAvatar:ClearEquipments()
	-- end)

	-- Timer.InsertTimer(10,function()
	-- 	ga:HideAvatar()
	-- 	ga:SwitchSex()
	-- end)

	-- Timer.InsertTimer(15,function()
	-- 	ga:ShowAvatar()
	-- end)

	-- Timer.InsertTimer(20,function()
	-- 	ga:RestoreEquipments()
	-- end)

	-- ModelDisplayer.Display(1400253)
	-- ModelDisplayer.Display(106005)
	
	-- Timer.InsertTimer(15,function()
	-- 	ModelDisplayer.Store()
	-- 	ModelDisplayer.Destroy()
	-- end)
	
	-- Timer.InsertTimer(20,function()
	-- 	ModelDisplayer.Init()
	-- 	ModelDisplayer.Restore()
	-- end)
end

function EventCloseMallEditor()
	LobbyCameraManager.LeaveCloseupView()
	if exModel ~= nil then
		exModel:Destroy()
	end

	ModelDisplayer.Destroy()
	MallSystemWeaponModelHandler:SetForceResetRotation(false)
	MallSystemWeaponModelHandler.ShowDebug(false)
	MallEditorUI.isShowing = false
	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE)
	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall")
	LobbySceneManager.ChangeLight(LobbySceneManager.LIGHT_LOBBY)

	--LobbySceneManager.ShowMesh(LobbySceneManager.MALL_MESH_LobbyBgMesh)
end
-- =========================Common==========================
function MallEditorUI._createSaveContent()
	MallEditorUI.SAVE_FILE_CONTENT = ""

	MallEditorUI._addSaveContent("-- ======Editor ant======")
	MallEditorUI._addSaveContent("-- ======It's auto created by editor,don't edit.")
	MallEditorUI._addSaveContent("MallEditorSaveFile = {}")
end

function MallEditorUI._addSaveContent(str)
	MallEditorUI.SAVE_FILE_CONTENT = MallEditorUI.SAVE_FILE_CONTENT .. str .. "\n"
end

function MallEditorUI._getSaveTable(key)
	log("_getSaveTable")
	MallEditorUI.SAVE_DATA[key] = MallEditorUI.SAVE_DATA[key] or {}

	return MallEditorUI.SAVE_DATA[key]
end

local function _GetSortedKeys(t)
	local keys = {}
	for k,v in pairs(t) do
		table.insert(keys, k)
		if k == 0 then
			log_tree("v",v)
		end
	end



	table.sort(keys, function (a, b)
		return a < b
	end)

	return keys
end

function MallEditorUI._saveData()
	MallEditorUI._createSaveContent()

	-- should order by key
	local tableKeys = _GetSortedKeys(MallEditorUI.SAVE_DATA)
	-- 

	for i,tableKey in ipairs(tableKeys) do
		MallEditorUI._addSaveContent("MallEditorSaveFile."..tableKey.." = {}")
		local table = MallEditorUI.SAVE_DATA[tableKey]

		local keys = _GetSortedKeys(table)
		for ii,key in ipairs(keys) do
			local value = table[key]
			if type(key) == "number" then
				MallEditorUI._addSaveContent("MallEditorSaveFile."..tableKey.."["..key.."] = {")
			elseif type(key) == "string" then
				MallEditorUI._addSaveContent("MallEditorSaveFile."..tableKey.."[\""..key.."\"] = {")
			end

			local pkeys = _GetSortedKeys(value)

			for iii,pk in ipairs(pkeys) do
				local pv = value[pk]
				if type(pv) == "number" then
					MallEditorUI._addSaveContent(pk.." = "..pv..";")
				elseif type(pv) == "string" then
					MallEditorUI._addSaveContent(pk.." = \""..pv.."\";")
				end				
			end

			MallEditorUI._addSaveContent("}")
		end
	end
end

local function _FileExists(path)
	local file = io.open(path, "rb")
	if file then file:close() end
	return file ~= nil
end

function EventMallEditorLoadFile()
	if _FileExists(MallEditorUI.SAVE_FILE_PATCH) == false then
		return
	end

	MallEditorSaveFile = {}
	dofile(MallEditorUI.SAVE_FILE_PATCH)

	for mkey, table in pairs(MallEditorSaveFile) do
		MallEditorUI.SAVE_DATA[mkey] = MallEditorSaveFile[mkey]
	end
end

function EventMallEditorSaveFile()
	MallEditorUI._saveData()
	local file = io.open(MallEditorUI.SAVE_FILE_PATCH,'w')
	file:write(MallEditorUI.SAVE_FILE_CONTENT)
	file:close()

	EditorRuntime.CheckDataType()
end


-- ==============================================================
BP_STRUCT_MallEditor_FullScreenData =
{
	itemID = 0,
	adapt = 0,
	x = 0,
	y = 0,
	z = 0,
	rootCameraID = 0,
}


------------------- About Camera--------------------------
function MallEditorUI._setMallFullscreenCamera(itemID, adapt, x, y, z, rootCameraID)
	local data = MallEditorUI._getSaveTable(MALL_CAMERA_FULL_SCREEN_CONFIG)
	local id = EditorRuntime.GetMallFullScreenID(itemID, adapt, rootCameraID)

	data[id] = data[id] or {}
	data[id].x = x
	data[id].y = y
	data[id].z = z
	data[id].rootCameraID = rootCameraID
end

function EventMallEditorGetFullScreenData()
	local itemID = BP_STRUCT_MallEditor_FullScreenData.itemID
	local adapt = BP_STRUCT_MallEditor_FullScreenData.adapt
	local CameraID = BP_STRUCT_MallEditor_FullScreenData.rootCameraID


	local data = EditorRuntime.GetMallFullScreenConfig(itemID, CameraID)

	--local id = EditorRuntime.GetMallFullScreenID(itemID, adapt, CameraID)

	--if MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG == nil
	--	--or MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG[id] == nil
	--	--then
	if data == nil then
		BP_STRUCT_MallEditor_FullScreenData.itemID = 0
		return
	end

	--local data = MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG[id]
	BP_STRUCT_MallEditor_FullScreenData.x = data.x
	BP_STRUCT_MallEditor_FullScreenData.y = data.y
	BP_STRUCT_MallEditor_FullScreenData.z = data.z
	BP_STRUCT_MallEditor_FullScreenData.rootCameraID = data.rootCameraID
end

function EventMallEditorFullScreenPreview()
	local itemID = BP_STRUCT_MallEditor_FullScreenData.itemID
	local CameraID = BP_STRUCT_MallEditor_FullScreenData.rootCameraID
	EditorRuntime.ShowMallFullScreen(itemID, CameraID)
end

-- Save data file and load again，for sure the data is same to savefile.
function EventMallEditorSaveFullScreenData()
	local data = BP_STRUCT_MallEditor_FullScreenData
	-- log_tree("data", data)
	MallEditorUI._setMallFullscreenCamera(data.itemID, data.adapt, data.x, data.y, data.z, data.rootCameraID)
	EventMallEditorSaveFile()
	EventMallEditorLoadFile()
end

function EventMallEditorOnCameraAdaptChange()
	log("==========EventMallEditorOnCameraAdaptChange============")
	-- LobbyCameraManager.SwitchCamera(10112)
	ModelDisplayer.OnAdaptChange()
end

-- ====================About Model======================
BP_MALLEDITOR_operateItemID = 0
BP_STRUCT_MallEditor_MallAdaptData = {
	itemID = 0,
	adapt = 0,
	rootCameraID = 0,

	parentx = 0,
	parenty = 0,
	parentz = 0,

	modelx = 0,
	modely = 0,
	modelz = 0,

	modelsx = 0,
	modelsy = 0,
	modelsz = 0,
}

function EventMallEditorEquipItem()
	ModelDisplayer.Display(BP_MALLEDITOR_operateItemID, 0, 0)
	local putoffEquipments = MultipleAvatar.ShowingAvatar:GetPutoffEquipments()
	local es = MultipleAvatar.ShowingAvatar:GetEquipments()
	MallSystemWeaponModelHandler.ShowDebug(true)
	MallSystemWeaponModelHandler:SetForceResetRotation(false)
	-- MallSystemWeaponModelHandler.SetAdaptPosition(101, 102, 103, 11, 12, 13)
end

function EventMallEditorSwitchSex()
	MultipleAvatar.SwitchSex()

	--if MultipleAvatar.HasPetEquiped() == false then
	--	MultipleAvatar.CreatePet()
	--else
	--	MultipleAvatar.DestroyPet()
	--end
end

function EventMallEditorShowAvatar()
	ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_AVATAR)
end

function EventMallEditorShowModel()
	ModelDisplayer.SetShowtype(ModelDisplayer.SHOWTYPE_WEAPON_MODEL)
end

function MallEditorUI._setMallAdaptData(adaptData)
	local data = MallEditorUI._getSaveTable(MALL_MODEL_ADAPT_CONFIG)
	local id = EditorRuntime.GetMallFullScreenID(adaptData.itemID, adaptData.adapt, adaptData.rootCameraID)

	data[id] = data[id] or {}
	for k,v in pairs(adaptData) do
		data[id][k] = v
	end
end

function EventMallEditorSaveMallAdaptData()
	log_tree("BP_STRUCT_MallEditor_MallAdaptData", BP_STRUCT_MallEditor_MallAdaptData)
	MallEditorUI._setMallAdaptData(BP_STRUCT_MallEditor_MallAdaptData)
	EventMallEditorSaveFile()
	EventMallEditorLoadFile()
end
-- =================================================

-- Extra Data
BP_MallEditorUI_ExtraData = ""

function MallEditorUI._SetExtraData(value)
	BP_MallEditorUI_ExtraData = value
end

function MallEditorUI._AppendExtraData(value)
	BP_MallEditorUI_ExtraData = "|" .. value 
end

function MallEditorUI._ApplyExtraData()
	LuaClassObj.HandleUIMessageNoFetch(bp_mall_editor, "ApplyExtraData")
end
-- ===================================================

function EventMallEditorOnCameraChange()
	log("EventMallEditorOnCameraChange " .. BP_MallEditorUI_ExtraData)
	LobbyCameraManager.SwitchCamera(tonumber(BP_MallEditorUI_ExtraData))
end