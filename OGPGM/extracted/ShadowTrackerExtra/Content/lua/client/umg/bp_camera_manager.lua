--[[
	add by hy for lobby camera
]]
LobbyCameraManager = LobbyCameraManager or {}
LobbyCameraManager.AdaptLong = 0
LobbyCameraManager.AdaptWide = 1
LobbyCameraManager.AdaptNormal = 2

LobbyCameraManager.store_recommend = 10112;
LobbyCameraManager.store_clothes = 10112;
LobbyCameraManager.store_exchange = 10112;
LobbyCameraManager.store_weapon = 10114
LobbyCameraManager.store_vehicle = 10114;
LobbyCameraManager.store_supply = 10115;

BP_STRUCT_CameraManager_FullscreenCameraData = {
	x = 0,
	y = 0,
	z = 0,
	rootCameraID = 0,
	duration = 0,
}

BP_MallFullscreenRootCameraID = 0
BP_CurrentCameraAdapt = 2
BP_LobbyCameraManager_ExtraData = ""

function bp_camera_manager_RegisterUI()
	-- log("======================bp_camera_manager_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_camera_manager,
		{{Path="/Game/UMG/UI_Logic/LobbyCameraManager.LobbyCameraManager_C", Container="Default", ZOrder=BP_ENUM_UI_ACTIVITY_ZORDER}},
		{"Login","Lobby"},
		false,
		bp_camera_manager_OnModeSwitched ~= nil,
		true
	)
end

function bp_camera_manager_OnModeSwitched(gameStatus)
    log("bp_camera_manager_OnModeSwitched gameStatus = " .. tostring(gameStatus));
    
    if string.lower(gameStatus) == "lobby" then
    	LobbyCameraManager.Show()
    else
    	LobbyCameraManager.Hide()
    end
end

function LobbyCameraManager.Show()
	LuaClassObj.HandleDynamicCreation(bp_camera_manager)
	LuaClassObj.HandleUIMessageNoFetch(bp_camera_manager, "UIShow")

	--local bp = UIUtil.GetWidgetByLogicName("bp_camera_manager")
	--LobbyCameraManager.BP = bp
end

function LobbyCameraManager.Hide()
	LuaClassObj.HandleUIMessageNoFetch(bp_camera_manager, "UIHide")
end

function LobbyCameraManager.MallFullScreen(x, y, z, rootCameraID, duration)
	BP_STRUCT_CameraManager_FullscreenCameraData.x = x
	BP_STRUCT_CameraManager_FullscreenCameraData.y = y
	BP_STRUCT_CameraManager_FullscreenCameraData.z = z
	BP_STRUCT_CameraManager_FullscreenCameraData.rootCameraID = rootCameraID
	BP_STRUCT_CameraManager_FullscreenCameraData.duration = duration
	
	LuaClassObj.HandleUIMessageNoFetch(bp_camera_manager, "MallFullScreen")
end

function LobbyCameraManager.SwitchCamera(cameraID)
	local config = Client.GetTableData("LobbyCameraInfo", cameraID)
	if config == nil then
		PopUpNoticeUI.ShowNewNotice("没有找到相机配置，相机"..cameraID)
		return
	end
	BP_MallFullscreenRootCameraID = cameraID
	LuaClassObj.HandleUIMessageNoFetch(bp_camera_manager, "SwitchCamera")

	MallSystemWeaponModelHandler.SetCameraID(cameraID)
end

function LobbyCameraManager.FetchCameraAdapt()
	LuaClassObj.HandleUIMessageNoFetch(bp_camera_manager, "FetchCameraAdapt")
	return BP_CurrentCameraAdapt
end

function LobbyCameraManager.RefreshCamera()
	local camera = LobbyCameraManager.FetchCameraAdapt()
	LobbyCameraManager.SwitchCamera(camera)
end

function LobbyCameraManager.EnterCloseupView(closeupID, avatar)
	local pos = avatar:GetPosition()
	LobbyCameraManager.EnterCloseupViewPosition(tonumber(closeupID), pos.x, pos.y, pos.z)
end

function LobbyCameraManager.EnterCloseupViewPosition(closeupID, x, y, z)
	BP_STRUCT_CameraManager_FullscreenCameraData.x = x*1000
	BP_STRUCT_CameraManager_FullscreenCameraData.y = y*1000
	BP_STRUCT_CameraManager_FullscreenCameraData.z = z*1000
	BP_STRUCT_CameraManager_FullscreenCameraData.rootCameraID = tonumber(closeupID)

	LuaClassObj.HandleUIMessageNoFetch(bp_camera_manager, "EnterCloseupViewPositionLua")
end

function LobbyCameraManager.LeaveCloseupView()
	LuaClassObj.HandleUIMessageNoFetch(bp_camera_manager, "LeaveCloseupView")
end