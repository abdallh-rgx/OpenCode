--[[
	add by hy for editor rumtime
]]
EditorRuntime = EditorRuntime or {}
EditorRuntime.SHOW_MALL_FULLSCREEN_SPEED = 500

EditorRuntime.DATE_TYPE_LUA = "DATE_TYPE_LUA"
EditorRuntime.DATE_TYPE_EXCEL = "DATE_TYPE_EXCEL"

local _dataType = nil

local function _FileExists(path)
	local file = io.open(path, "rb")
	if file then file:close() end
	return file ~= nil
end

local function _GetDataType()
	if _dataType == nil then
		EditorRuntime.CheckDataType()
		if _dataType == EditorRuntime.DATE_TYPE_LUA then
			dofile(MallEditorUI.SAVE_FILE_PATCH)
		end
	end

	return _dataType
end

function EditorRuntime.CheckDataType()
	if _FileExists(MallEditorUI.SAVE_FILE_PATCH) == true then
		_dataType = EditorRuntime.DATE_TYPE_LUA
	else
		_dataType = EditorRuntime.DATE_TYPE_EXCEL
	end

	log("EditorRuntime.CheckDataType ".. _dataType)
end

function EditorRuntime.GetMallFullScreenID(itemID, adapt, cameraID)
	local cfg
	cfg = Client.GetTableData("WeaponSkinMapping", itemID)
	
	if cfg ~= nil then
		return cfg.WeaponID .. "_" .. adapt .. "_" .. cameraID
	else
		cfg = Client.GetTableData("VehiclePlaneSkinMapping", itemID)
	end

	if cfg == nil then
		log("========================[EditorRuntime] error===========================")
		-- log("为了让问题暴露，现在先把这个return注释到，正式版本会加上。请遇到报错的人尽快解决。")
		
		log("cfg is nil, id is = " .. itemID)
		log(debug.traceback())

		-- 为了让问题暴露，现在先把这个return注释到，正式版本会加上。请遇到报错的人尽快解决。
		PopUpNoticeUI.ShowNewNotice("没有找到皮肤映射配置"..itemID)
		return itemID .. "_" .. adapt .. "_" .. cameraID
	end

	return cfg.OrginalID .. "_" .. adapt .. "_" .. cameraID
end

function EditorRuntime.ShowMallFullScreen(itemID, cameraID, speed)
	speed = speed or EditorRuntime.SHOW_MALL_FULLSCREEN_SPEED
	log("EditorRuntime.ShowMallFullScreen "..itemID.." cameraID "..cameraID)
	local adapt = LobbyCameraManager.FetchCameraAdapt()
	local id = EditorRuntime.GetMallFullScreenID(itemID, adapt, cameraID)

	local data = nil
	if _GetDataType() == EditorRuntime.DATE_TYPE_LUA then
		if MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG == nil then
			log("MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG is nil")
			return
		end

		data = MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG[id]
	else
		data = Client.GetTableData("MALL_CAMERA_FULL_SCREEN_CONFIG", id)
	end

	if data == nil then
		log("MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG "..id.." is nil")
		return
	end

	LobbyCameraManager.MallFullScreen(data.x, data.y, data.z, cameraID, speed)
end

function EditorRuntime.GetMallFullScreenConfig(itemID, cameraID)
	--speed = speed or EditorRuntime.SHOW_MALL_FULLSCREEN_SPEED
	log("EditorRuntime.ShowMallFullScreen "..itemID.." cameraID "..cameraID)
	local adapt = LobbyCameraManager.FetchCameraAdapt()
	local id = EditorRuntime.GetMallFullScreenID(itemID, adapt, cameraID)

	local data = nil
	if _GetDataType() == EditorRuntime.DATE_TYPE_LUA then
		if MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG == nil then
			log("MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG is nil")
			return
		end

		data = MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG[id]
	else
		data = Client.GetTableData("MALL_CAMERA_FULL_SCREEN_CONFIG", id)
	end

	if data == nil then
		log("MallEditorSaveFile.MALL_CAMERA_FULL_SCREEN_CONFIG "..id.." is nil")
		return nil
	end

	return data
	--LobbyCameraManager.MallFullScreen(data.x, data.y, data.z, cameraID, speed)
end

function EditorRuntime.ChangeMallSceneMaterial(materialID)
	LobbySceneManager.ChangeMallSceneMaterial(materialID)
end

function EditorRuntime.ChangeMallSceneTexture(url)
	LobbySceneManager.ChangeMallSceneTexture(url)
end

function EditorRuntime.ShowMallModelAdapt(itemID, cameraID)
	local adapt = LobbyCameraManager.FetchCameraAdapt()
	local id = EditorRuntime.GetMallFullScreenID(itemID, adapt, cameraID)

	local data = nil
	if _GetDataType() == EditorRuntime.DATE_TYPE_LUA then
		if MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG == nil then
			log("MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG is nil")
			return
		end

		data = MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG[id]
	else
		data = Client.GetTableData("MALL_MODEL_ADAPT_CONFIG", id)
	end

	if data == nil then
		log("MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG "..id.." is nil")
		return
	end

	MallSystemWeaponModelHandler.SetAdaptPosition(
		data.parentx, 
		data.parenty, 
		data.parentz, 

		data.modelx, 
		data.modely, 
		data.modelz,

		data.modelsx,
		data.modelsy,
		data.modelsz
	)
end

function EditorRuntime.GetAdaptConfig(itemID, cameraID)
	local adapt = LobbyCameraManager.FetchCameraAdapt()
	local id = EditorRuntime.GetMallFullScreenID(itemID, adapt, cameraID)

	local data = nil
	if _GetDataType() == EditorRuntime.DATE_TYPE_LUA then
		if MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG == nil then
			log("MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG is nil")
			return nil
		end

		data = MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG[id]
	else
		data = Client.GetTableData("MALL_MODEL_ADAPT_CONFIG", id)
	end
	
	if data == nil then
		log("MallEditorSaveFile.MALL_MODEL_ADAPT_CONFIG "..id.." is nil")
		return nil
	end

	return data
end