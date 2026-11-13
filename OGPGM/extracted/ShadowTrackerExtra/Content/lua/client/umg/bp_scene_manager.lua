--[[
	add by hy for lobby scene manager
]]
LobbySceneManager = LobbySceneManager or {}
BP_LobbySceneManager_MallSceneMaterialID = 0
BP_LobbySceneManager_MallSceneTextureURL = ""

LobbySceneManager.LIGHT_LOBBY = 0
LobbySceneManager.LIGHT_MALL_MODEL = 1
LobbySceneManager.LIGHT_MALL_AVATAR = 2

LobbySceneManager.MALL_MESH_LobbyBgMesh = "LobbyBgMesh"
LobbySceneManager.MALL_MESH_Background_Weapon_02 = "Background_Weapon_02"
LobbySceneManager.MALL_MESH_Background_Pat_int = "ScenePet"

LobbySceneManager.HIDE_FX = "HIDE_FX"

local _meshTags = {
	LobbySceneManager.MALL_MESH_LobbyBgMesh,
	LobbySceneManager.MALL_MESH_Background_Weapon_02,
	LobbySceneManager.MALL_MESH_Background_Pat_int
}

BP_LobbySceneManager_LightType = 0
BP_LobbySceneManager_ExtraData = ""

LobbySceneManager.OPCODE_OBJECT_VISIABLE = "OPCODE_OBJECT_VISIABLE"

--sami 大厅载具创建资源id
BP_LobbySceneManager_Vehicle_Id = 0

BP_STRUCT_Comm_Vec3 =
{
	x_f = 0,
	y_f = 0,
	z_f = 0,
}
--创建载具参数信息，0-位置，1-旋转，2-缩放
BP_ARRAY_LobbySceneManager_Vehicle_Param =
{
	BP_STRUCT_Comm_Vec3 = _G.BP_STRUCT_Comm_Vec3;
}


function bp_scene_manager_RegisterUI()
	-- log("======================bp_scene_manager_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_scene_manager,
		{{Path="/Game/UMG/UI_Logic/LobbySceneManager.LobbySceneManager_C", Container="Default", ZOrder=BP_ENUM_UI_ACTIVITY_ZORDER}},
		{"Login","Lobby"},
		false,
		bp_scene_manager_OnModeSwitched ~= nil,
		true
	)
end

function bp_scene_manager_OnModeSwitched(gameStatus)
    log("bp_scene_manager_OnModeSwitched gameStatus = " .. tostring(gameStatus));
    
    if string.lower(gameStatus) == "lobby" then
    	MallSystemWeaponModelHandler:DestroyWeaponShowActor()
    	LobbySceneManager.Show()
    else
    	LobbySceneManager.Hide()
    	MallSystemWeaponModelHandler:DestroyWeaponShowActor()
    end
end

function LobbySceneManager.Show()
	LuaClassObj.HandleDynamicCreation(bp_scene_manager)
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "UIShow")

	LobbySceneManager.SetMallWeaponParticalVisiable(false)
	LobbySceneManager.SetSnowmanVisiable(false)
end

function LobbySceneManager.Hide()
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "UIHide")
end

function LobbySceneManager.ShowMesh(tag)
	for i,v in ipairs(_meshTags) do
		LobbySceneManager.VisiableObjectsByTag(v, tag == v)
	end
end

function LobbySceneManager.VisiableObjectsByTag(tag, visiable)
	BP_LobbySceneManager_ExtraData = LobbySceneManager.OPCODE_OBJECT_VISIABLE

	LobbySceneManager._AppendExtraData(tag)
	LobbySceneManager._AppendExtraData(visiable)

	LobbySceneManager._ApplyExtraData()
end

function LobbySceneManager.ChangeMallSceneMaterial(materialID)
	BP_LobbySceneManager_MallSceneMaterialID = materialID
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "ChangeMallSceneMaterial")
end

function LobbySceneManager.ChangeMallSceneTexture(url)
	BP_LobbySceneManager_MallSceneTextureURL = url
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "ChangeMallSceneTexture")
end

function LobbySceneManager.ChangeLight(lightType)
	BP_LobbySceneManager_LightType = lightType
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "ChangeLight")
end

function LobbySceneManager.SetMallWeaponParticalVisiable(isVisiable)
	if isVisiable == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "ShowMallWeaponPartical")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "HideMallWeaponPartical")
	end
end

function LobbySceneManager.EnableVolumeLight(isEnable)
	if isEnable == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "EnableVolumeLight")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "DisableVolumeLight")
	end
end

function LobbySceneManager.SetSnowmanVisiable(isVisiable)
	if isVisiable == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "ShowSnowman")
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "HideSnowman")
	end
end

function LobbySceneManager._AppendExtraData(appendData)
	-- log("LobbyAvatar:_AppendExtraData appendData ".. tostring(appendData))
	if appendData == true then
		appendData = 1
	elseif appendData == false then
		appendData = 0
	end

	BP_LobbySceneManager_ExtraData = BP_LobbySceneManager_ExtraData .. "|" .. appendData
end

function LobbySceneManager._ApplyExtraData()
	log("LobbySceneManager._ApplyExtraData = "..BP_LobbySceneManager_ExtraData)
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "ApplyExtraData")
end

SceneExtraModel = SceneExtraModel or {}
local _extraModelID = 0
BP_LobbySceneManager_OperateExtraModelPath = ""
BP_LobbySceneManager_OperateExtraModelID = 0
BP_Array_LobbySceneManager_OperateExtraModelTransform = {
	0
}

function SceneExtraModel:New(path)
	self._id = _extraModelID + 1

	BP_LobbySceneManager_OperateExtraModelPath = path
	BP_LobbySceneManager_OperateExtraModelID = self._id
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "CreateExtraModel")
end

function SceneExtraModel.Create(...)
	local mt = { __index = SceneExtraModel }
	local result = {}
	setmetatable(result, mt)
	result:New(...)

	return result
end

function SceneExtraModel:Destroy()
	BP_LobbySceneManager_OperateExtraModelID = self._id
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "DestroyExtraModel")
end

local function insertTransform(value)
	table.insert(BP_Array_LobbySceneManager_OperateExtraModelTransform, value)
end

function SceneExtraModel:SetPosition(x, y, z)
	BP_LobbySceneManager_OperateExtraModelID = self._id
	
	BP_Array_LobbySceneManager_OperateExtraModelTransform = {}
	insertTransform(x)
	insertTransform(y)
	insertTransform(z)

	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "SetExtraModelPosition")
end

function SceneExtraModel:SetRotation(x, y, z)
	BP_LobbySceneManager_OperateExtraModelID = self._id

	BP_Array_LobbySceneManager_OperateExtraModelTransform = {}
	insertTransform(x)
	insertTransform(y)
	insertTransform(z)

	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "SetExtraModelRotation")
end

--解析三维向量
function LobbySceneManager.ParseVec3(str)
	local vec = {x_f = 1, y_f = 1, z_f = 1}
	if str and str ~= "" then
		local arr = string.split(str, ";")
		if arr and #arr == 3 then
			vec =
			{
				x_f = tonumber(arr[1]),
				y_f = tonumber(arr[2]),
				z_f = tonumber(arr[3]),
			}	
		end
	end
	return vec
end

function LobbySceneManager.CreateHallVehicle(homeThemeItemId, itemId)
    log("LobbySceneManager.CreateHallVehicle homeThemeItemId = "..homeThemeItemId..", itemId = "..itemId)
	BP_LobbySceneManager_Vehicle_Id = itemId
	local cfg = Client.GetTableData("HallThemeItem", homeThemeItemId)
	if cfg then
		local pos = LobbySceneManager.ParseVec3(cfg.vehiclePosition)
		local rotation = LobbySceneManager.ParseVec3(cfg.vehicleRotation)
		local scale = LobbySceneManager.ParseVec3(cfg.vehicleScale)
		BP_ARRAY_LobbySceneManager_Vehicle_Param = {}
		table.insert(BP_ARRAY_LobbySceneManager_Vehicle_Param, pos)
		table.insert(BP_ARRAY_LobbySceneManager_Vehicle_Param, rotation)
		table.insert(BP_ARRAY_LobbySceneManager_Vehicle_Param, scale)
	end	
	LuaClassObj.HandleUIMessageNoFetch(bp_scene_manager, "CreateHallVehicle")
end

