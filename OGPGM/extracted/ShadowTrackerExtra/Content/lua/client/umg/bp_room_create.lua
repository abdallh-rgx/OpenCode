RoomCreateUI = RoomCreateUI or
{
	CustomRoomParaInfo = {};
	CustomTypeNameList = {};
	BattleCustomCfgInfo = {};
	RoomModeTableWithVersion = {};
	IsSameRoomTableItem = false;
	RoomModeTempInfo = {};
}

--注册Widget
function bp_room_create_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_room_create,
		  {{Path="/Game/UMG/UI_Logic/Room/Room_RoomCreate_BP.Room_RoomCreate_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROOM_WAITING_ZORDER+1}},
		  {"Lobby"},
		  false,
		  bp_room_create_OnModeSwitched ~= nil,
		  true
  );
end

function bp_room_create_OnModeSwitched(gamestatus)
	log("bp_room_create_OnModeSwitched gamestatus = " .. gamestatus);

	if string.lower(gamestatus) == "lobby" then
		RoomCreateUI.InitRoomModeTableWithVersion();
		-- RoomCreateUI.InitRoomCreateDropPara();
		-- RoomCreateUI.InitRoomCreateData();
	end
end


--创建房间掉落倍数参数类型信息(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_RoomCreateFirstTypeInfo =
{
	type_name = "",
};

--创建房间单条掉落倍数参数信息
BP_STRUCT_RoomCreateSecondTypeInfo =
{
	custom_num = 0,
	type_name = "",
	name = "",
	type_key = "",
	BP_ARRAY_RoomCreateMultipleList =
	{
		value = 0,
	},
	default_value = 0,
	adjust_enable = false,
	sort_num = 0,
	value = 0,
};

--创建房间掉落倍数参数类型列表(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_ARRAY_RoomCreateFirstTypeList =
{
	BP_STRUCT_RoomCreateFirstTypeInfo = _G.BP_STRUCT_RoomCreateFirstTypeInfo,
};

--创建房间单条掉落倍数参数列表
BP_ARRAY_RoomCreateSecondTypeList =
{
	BP_STRUCT_RoomSecondTypeInfo =
	{
		BP_ARRAY_RoomCreateSecondTypeDeatilList =
		{
			BP_STRUCT_RoomCreateSecondTypeInfo = _G.BP_STRUCT_RoomCreateSecondTypeInfo,
		},
	},
};

--创建房间缩圈速度参数列表
BP_ARRAY_RoomCreateShrinkSpeedList =
{
	BP_STRUCT_RoomCreateSecondTypeInfo = _G.BP_STRUCT_RoomCreateSecondTypeInfo,
};
--蓝圈伤害值
BP_ARRAY_RoomCreateBCircleDamageList =
{
	BP_STRUCT_RoomCreateSecondTypeInfo = _G.BP_STRUCT_RoomCreateSecondTypeInfo,
};
--白圈显示时间
BP_ARRAY_RoomCreateWCircleTimeShowList =
{
	BP_STRUCT_RoomCreateSecondTypeInfo = _G.BP_STRUCT_RoomCreateSecondTypeInfo,
};
--白圈开始时间
BP_ARRAY_RoomCreateWCircleTimeBeginList =
{
	BP_STRUCT_RoomCreateSecondTypeInfo = _G.BP_STRUCT_RoomCreateSecondTypeInfo,
};
--白圈直径
BP_ARRAY_RoomCreateWCircleDiameterList =
{
	BP_STRUCT_RoomCreateSecondTypeInfo = _G.BP_STRUCT_RoomCreateSecondTypeInfo,
};

BP_STRUCT_RoomCreateCommonSwitchParaInfo =
{
	is_open = false,
	default = false,
	adjustable = false,
};

--创建房间参数列表（old）
BP_CreateRoom_Mode = 1;
BP_CreateRoom_OpeMode = 0;  --操作模式，0为第三人称，1为第一人称
BP_CreateRoom_HostCanObserve = false; --房主是否可以死亡后观战
BP_ARRAY_OpeModeList ={0, 1};
BP_CreateRoom_IsJpKrVersion = false;
BP_CreateRoom_IsCompetitionRoom = false;--是否比赛房间，创建和房间内分别同步
BP_CreateRoom_IsUsePcPara =false

--地图id映射自定义掉落参数id（非模式id）
local _MapId2ModeID = {
	[1] = 1001,
	[3] = 1001,
	[7] = 1003,
	[10] = 1002,
	[11] = 1001,
	[14] = 1002,
	[15] = 1003,
	[16] = 1015,
	[17] = 1015,
}

---------------创建房间参数列表---------------
BP_CreateRoom_Name = "";			--房间名
BP_CreateRoom_Passwd = "";			--房间密码
BP_CreateRoom_AllowInvite = false;	--是否允许非房主邀请好友
BP_CreateRoom_RoomTableID = 0;		--房间模式表ID
BP_CreateRoom_RoomModeID = 0;		--房间模式ID
BP_CreateRoom_RoomModeName = "";	--房间模式名
BP_CreateRoom_RoomModeDesc = "";	--房间模式描述
BP_CreateRoom_RoomModeImage = "";	--房间模式图片地址
BP_CreateRoom_MapID = 0;			--地图ID
BP_CreateRoom_MapName = "";			--地图名
BP_CreateRoom_PlayMethod = "";		--玩法
BP_CreateRoom_Perspective = "";		--视角
BP_CreateRoom_IsFPP = false;		--视角是否第一人称
BP_CreateRoom_TeamModeID = 1;		--队伍模式ID
BP_CreateRoom_TeamModeName = "";	--队伍模式名
BP_CreateRoom_PlayerNumMax = 100;	--房间最大人数
BP_CreateRoom_PlayerNumMin = 32;	--房间最小人数
BP_CreateRoom_PlayerNum = 100;		--房间人数
BP_CreateRoom_WeatherModeID = 0;	--天气模式ID
BP_CreateRoom_WeatherModeName = "";	--天气模式名
BP_CreateRoom_WeatherModeEN = "";	--天气模式英文名
BP_CreateRoom_CurCustomNum = 1001;		--掉落倍数参数自定义编号
BP_STRUCT_RoomCreateSoundVisualInfo = _G.BP_STRUCT_RoomCreateCommonSwitchParaInfo;		--声音可视化
BP_STRUCT_RoomCreateAutoOpenDoorInfo = _G.BP_STRUCT_RoomCreateCommonSwitchParaInfo;		--自动开门
BP_STRUCT_RoomCreateAutoPickInfo = _G.BP_STRUCT_RoomCreateCommonSwitchParaInfo;			--自动拾取
BP_STRUCT_RoomCreateAimAssistInfo = _G.BP_STRUCT_RoomCreateCommonSwitchParaInfo;		--辅助瞄准
BP_STRUCT_RoomCreateBuckleBulletInfo = _G.BP_STRUCT_RoomCreateCommonSwitchParaInfo;		--枪械扣弹
BP_STRUCT_RoomCreateBombingAreaInfo = _G.BP_STRUCT_RoomCreateCommonSwitchParaInfo;		--轰炸区
BP_STRUCT_RoomCreateSignalGunInfo = _G.BP_STRUCT_RoomCreateCommonSwitchParaInfo;		--信号枪

---------------下拉列表信息---------------
--地图名列表
BP_ARRAY_RoomCreateMapNameList =
{
	text = "",
}
--玩法列表
BP_ARRAY_RoomCreatePlayMethodList =
{
	text = "",
}
--视角列表
BP_ARRAY_RoomCreatePerspectiveList =
{
	text = "",
}
--队伍模式名列表
BP_ARRAY_RoomCreateTeamModeNameList =
{
	text = "",
}
--天气模式列表
BP_ARRAY_RoomCreateWeatherModeCNList =
{
	text = "",
}

--天气模式ID列表
BP_ARRAY_RoomCreateWeatherModeIDList =
{
	id = 0,
}
--天气模式EN列表
BP_ARRAY_RoomCreateWeatherModeENList =
{
	text_en = "",
}
--掉落倍数参数列表
BP_ARRAY_RoomCreateCustomNumList =
{
	id = 0,
}

--自己的名字
BP_RoomCreate_SelfName = "";

--创建还是修改
BP_IsCreateRoom = false;

--是否房主
BP_CreateRoom_IsRoomMaster = false;

--是否有密码
BP_CreateRoom_IsLocked = false;

--高级参数是否有修改
BP_CreateRoom_IsAdvParaChanged = false;

--是否重新加载高级参数
BP_CreateRoom_NeedLoadAdvPara = false;

--选择的地图名
BP_CreateRoom_SelectedMapName = "";

--选择的玩法
BP_CreateRoom_SelectedPlayMethod = "";

--选择的天气名
BP_CreateRoom_SelectedWeatherName = "";

--房卡信息
BP_CreateRoom_RoomCardInfo = "";


function RoomCreateUI.Init()

	LuaClassObj.HandleDynamicCreation(bp_room_create);
	BP_CreateRoom_IsCompetitionRoom = BP_Room_IsCompetitionRoom;
	--log("[CLL] RoomCreateUI Init，BP_CreateRoom_IsCompetitionRoom = "..tostring(BP_CreateRoom_IsCompetitionRoom))

	BP_IsCreateRoom = true;
	BP_CreateRoom_IsRoomMaster = true;

	BP_RoomCreate_SelfName = DataMgr.roleData.nickName;

	RoomCreateUI.InitRoomCreateDropPara();
	RoomCreateUI.InitRoomCreateData();

	local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
    	BP_CreateRoom_IsJpKrVersion = true;
    else
    	BP_CreateRoom_IsJpKrVersion = false;
    end

    -- 如果房主观战功能关闭
    if LobbySystem.LobbyMenuOpenStatus[BP_ENUM_ANCHOR_OB].is_open == 0 then
   		BP_CreateRoom_IsJpKrVersion = false;
   	end

	---odd
	BP_CreateRoom_HostCanObserve = false;
	if BP_Room_IsHighLevelRoom then
		BP_CreateRoom_Adv_Hot_Point_IsShow = false
	else
		BP_CreateRoom_Hot_Point_IsShow = false;
	end
	RoomUI.UpdateRoomHotState()
	LuaClassObj.HandleUIMessage(bp_room_create, "ShowUI");
	
	UIManager.Show(eUIType.eRoomCreateUI)
end

function RoomCreateUI.Release()
	log("RoomCreateUI Release");
	RoomCreateUI.ReleaseDropParmInfo();
	RoomCreateUI.RoomModeTempInfo = {};
end

function RoomCreateUI.InitRoomCreateData()
	log("RoomCreateUIRoomCreateUI InitRoomCreateData");

	BP_CreateRoom_Name = "";
	BP_CreateRoom_Passwd = "";
	BP_CreateRoom_AllowInvite = false;

	BP_CreateRoom_RoomTableID = 0;
	BP_CreateRoom_RoomModeID = 0;
	BP_CreateRoom_RoomModeName = "";
	BP_CreateRoom_RoomModeDesc = "";
	BP_CreateRoom_RoomModeImage = "";
	--BP_CreateRoom_MapID = 0;
	BP_CreateRoom_MapName = "";
	BP_CreateRoom_PlayMethod = "";
	BP_CreateRoom_Perspective = "";
	BP_CreateRoom_IsFPP = false;
	BP_CreateRoom_TeamModeID = 1;
	BP_CreateRoom_TeamModeName = "";
	BP_CreateRoom_PlayerNumMax = 100;
	BP_CreateRoom_PlayerNumMin = 32;
	BP_CreateRoom_PlayerNum = 100;
	BP_CreateRoom_WeatherModeID = 0;
	BP_CreateRoom_WeatherModeName = "";
	BP_CreateRoom_WeatherModeEN = "";
	BP_ARRAY_RoomCreateShrinkSpeedList = {};
	--蓝圈伤害值
	BP_ARRAY_RoomCreateBCircleDamageList = {};
	--白圈显示时间
	BP_ARRAY_RoomCreateWCircleTimeShowList = {};
	--白圈开始时间
	BP_ARRAY_RoomCreateWCircleTimeBeginList = {};
	--白圈直径
	BP_ARRAY_RoomCreateWCircleDiameterList = {};

	RoomCreateUI.RoomModeTempInfo = {};

	local mode_list = RoomSystem.GetAllRoomCanCreateState();
	log("RoomCreateUIRoomCreateUI InitRoomCreateData1");
	-- log_tree("mode_list = ", mode_list);
	--[[local modeID = 0;
	for i=1,#mode_list do
		if mode_list[i] == RoomModeCreateState.CanCreate then
			modeID = i;
			break;
		end
	end
	local defauleID = 99999999;
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeID == modeID and v.ID < defauleID then
			defauleID = v.ID;
		end
	end
	log("RoomCreateUIRoomCreateUI InitRoomCreateData2 "..tostring(defauleID));
	--]]
	local defaultID = BP_CreateRoom_IsCompetitionRoom and 10002 or 1001;
	RoomCreateUI.SetAllParameterInitInfo(defaultID);

	BP_CreateRoom_NeedLoadAdvPara = true;
end

--打开UI、选择模式、选择地图、选择玩法等情况调用
function RoomCreateUI.SetAllParameterInitInfo(id)
	log("RoomCreateUI SetAllParameterInitInfo"..tostring(id));

	local ModeInfo = RoomCreateUI.RoomModeTableWithVersion[id];
	if BP_CreateRoom_RoomModeID == ModeInfo.ModeID and BP_CreateRoom_MapID == ModeInfo.MapID and BP_CreateRoom_PlayMethod == ModeInfo.PlayMethod then
		--选择了当前模式地图玩法，保存当前数据不变
		RoomCreateUI.IsSameRoomTableItem = true;
		log("RoomCreateUI.IsSameRoomTableItem = "..tostring(RoomCreateUI.IsSameRoomTableItem));
		return;
	else
		RoomCreateUI.IsSameRoomTableItem = false;
		log("RoomCreateUI.IsSameRoomTableItem = "..tostring(RoomCreateUI.IsSameRoomTableItem));
	end
	BP_CreateRoom_RoomTableID = ModeInfo.ID;
	BP_CreateRoom_RoomModeID = ModeInfo.ModeID;
	BP_CreateRoom_RoomModeName = ModeInfo.ModeName;
	BP_CreateRoom_RoomModeDesc = "";

	BP_CreateRoom_RoomModeImage = ModeInfo.ImagePath;
	--BP_CreateRoom_MapID = ModeInfo.MapID;
	BP_CreateRoom_MapName = ModeInfo.MapName;
	BP_CreateRoom_PlayMethod = ModeInfo.PlayMethod;
	BP_CreateRoom_Perspective = ModeInfo.DefaultPerspective;
	if BP_CreateRoom_Perspective == "第一人称" then
		BP_CreateRoom_IsFPP = true;
	else
		BP_CreateRoom_IsFPP = false;
	end
	if ModeInfo.QuaternaryModeID ~= 0 then
		BP_CreateRoom_TeamModeID = ModeInfo.QuaternaryModeID;
		BP_CreateRoom_TeamModeName = "四人";
	elseif ModeInfo.DoubleModeID ~= 0 then
		BP_CreateRoom_TeamModeID = ModeInfo.DoubleModeID;
		BP_CreateRoom_TeamModeName = "双人";
	elseif ModeInfo.SoloModeID ~= 0 then
		BP_CreateRoom_TeamModeID = ModeInfo.SoloModeID;
		BP_CreateRoom_TeamModeName = "单人";
	else
		BP_CreateRoom_TeamModeID = 0;
		BP_CreateRoom_TeamModeName = "";
	end
	BP_CreateRoom_PlayerNumMax = ModeInfo.MaxPlayerNum;
	BP_CreateRoom_PlayerNumMin = ModeInfo.MinPlayerNum;
	if BP_IsCreateRoom == true then
		BP_CreateRoom_PlayerNum = ModeInfo.DefaultPlayerNum;
	end
	BP_CreateRoom_WeatherModeName = ModeInfo.DefaultWeatherName;
	BP_ARRAY_RoomCreateMapNameList = {};
	BP_ARRAY_RoomCreatePlayMethodList = {};
	BP_ARRAY_RoomCreatePerspectiveList = {};
	BP_ARRAY_RoomCreateTeamModeNameList = {};
	BP_ARRAY_RoomCreateWeatherModeCNList = {};
	BP_ARRAY_RoomCreateWeatherModeIDList = {};
	BP_ARRAY_RoomCreateWeatherModeENList = {};
	BP_ARRAY_RoomCreateCustomNumList = {};

	--选出当前模式下所有地图名
	local AllCurModeInfoList = {};
	local MapKeyTable = {};	--去重
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeID == ModeInfo.ModeID and MapKeyTable[v.MapName] == nil then
			table.insert(AllCurModeInfoList, v);
			MapKeyTable[v.MapName] = true;
		end
	end
	table.sort(AllCurModeInfoList, function(a,b) return a.ID < b.ID end);
	for i=1,#AllCurModeInfoList do
		BP_ARRAY_RoomCreateMapNameList[i] = AllCurModeInfoList[i].MapName;
	end
	--选出当前模式和地图下所有玩法
	local AllCurModeMapInfoList = {};
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeID == ModeInfo.ModeID and v.MapID == ModeInfo.MapID then
			table.insert(AllCurModeMapInfoList, v);
		end
	end
	table.sort(AllCurModeMapInfoList, function(a,b) return a.ID < b.ID end);
	for i=1,#AllCurModeMapInfoList do
		BP_ARRAY_RoomCreatePlayMethodList[i] = AllCurModeMapInfoList[i].PlayMethod;
	end
	--视角列表
	BP_ARRAY_RoomCreatePerspectiveList = FuncUtil:StrSplit(ModeInfo.OptionalPerspective, ";");

	--队伍模式名列表
	local index = 1;
	if ModeInfo.SoloModeID ~= 0 then
		BP_ARRAY_RoomCreateTeamModeNameList[index] = "单人";
		index = index + 1;
	end
	if ModeInfo.DoubleModeID ~= 0 then
		BP_ARRAY_RoomCreateTeamModeNameList[index] = "双人";
		index = index + 1;
	end
	if ModeInfo.QuaternaryModeID ~= 0 then
		BP_ARRAY_RoomCreateTeamModeNameList[index] = "四人";
	end
	--天气列表
	BP_ARRAY_RoomCreateWeatherModeCNList = FuncUtil:StrSplit(ModeInfo.OptionalWeatherCN, ",");
	BP_ARRAY_RoomCreateWeatherModeIDList = FuncUtil:StrSplit(ModeInfo.OptionalWeatherID, ",");
	for i=1,#BP_ARRAY_RoomCreateWeatherModeIDList do
		BP_ARRAY_RoomCreateWeatherModeIDList[i] = tonumber(BP_ARRAY_RoomCreateWeatherModeIDList[i]);
	end
	BP_ARRAY_RoomCreateWeatherModeENList = FuncUtil:StrSplit(ModeInfo.OptionalWeatherEN, ",");
	BP_ARRAY_RoomCreateCustomNumList = FuncUtil:StrSplit(ModeInfo.DropCoefficientID, ",");
	for i=1,#BP_ARRAY_RoomCreateCustomNumList do
		BP_ARRAY_RoomCreateCustomNumList[i] = tonumber(BP_ARRAY_RoomCreateCustomNumList[i]);
	end
	for i=1,#BP_ARRAY_RoomCreateWeatherModeCNList do
		if BP_ARRAY_RoomCreateWeatherModeCNList[i] == BP_CreateRoom_WeatherModeName then
			BP_CreateRoom_WeatherModeID = BP_ARRAY_RoomCreateWeatherModeIDList[i];
			BP_CreateRoom_WeatherModeEN = BP_ARRAY_RoomCreateWeatherModeENList[i];
			BP_CreateRoom_CurCustomNum = BP_ARRAY_RoomCreateCustomNumList[i];
			break;
		end
	end
	--缩圈速度
	BP_ARRAY_RoomCreateShrinkSpeedList = {};
	BP_ARRAY_RoomCreateShrinkSpeedList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6308) and Client.GetTableData("LocalizeRes",6308).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultShrinkSpeed,
		adjust_enable = ModeInfo.ShrinkSpeedAdjustable == 1,
		sort_num = 0,
		value = ModeInfo.DefaultShrinkSpeed,
	};
	local str = string.sub(ModeInfo.OptionalShrinkSpeed, 2, -2);
	BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	--蓝圈伤害值
	BP_ARRAY_RoomCreateBCircleDamageList = {};
	BP_ARRAY_RoomCreateBCircleDamageList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6843) and Client.GetTableData("LocalizeRes",6843).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultBCircleDamage,
		adjust_enable = true,
		sort_num = 0,
		value = ModeInfo.DefaultBCircleDamage,
	};
	str = string.sub(ModeInfo.OptionalBCircleDamage, 2, -2);
	BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	--白圈显示时间
	BP_ARRAY_RoomCreateWCircleTimeShowList ={};
	BP_ARRAY_RoomCreateWCircleTimeShowList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6844) and Client.GetTableData("LocalizeRes",6844).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultWCircle1TimeShow,
		adjust_enable = true,
		sort_num = 0,
		value = ModeInfo.DefaultWCircle1TimeShow,
	};
	str = string.sub(ModeInfo.OptionalWCircle1TimeShow, 2, -2);
	BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	--白圈开始时间
	BP_ARRAY_RoomCreateWCircleTimeBeginList ={};
	BP_ARRAY_RoomCreateWCircleTimeBeginList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6845) and Client.GetTableData("LocalizeRes",6845).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultWCircle1TimeBegin,
		adjust_enable = true,
		sort_num = 0,
		value = ModeInfo.DefaultWCircle1TimeBegin,
	};
	str = string.sub(ModeInfo.OptionalWCircle1TimeBegin, 2, -2);
	BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	--白圈直径
	BP_ARRAY_RoomCreateWCircleDiameterList ={};
	BP_ARRAY_RoomCreateWCircleDiameterList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6846) and Client.GetTableData("LocalizeRes",6846).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultWCircle1Diameter,
		adjust_enable = true,
		sort_num = 0,
		value = ModeInfo.DefaultWCircle1Diameter,
	};
	str = string.sub(ModeInfo.OptionalWCircle1Diameter, 2, -2);
	BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	--声音可视化
	BP_STRUCT_RoomCreateSoundVisualInfo =
	{
		is_open = ModeInfo.DefaultSoundVisual == 1,
		default = ModeInfo.DefaultSoundVisual == 1,
		adjustable = ModeInfo.SoundVisualAdjustable == 1,
	};

	--自动开门
	BP_STRUCT_RoomCreateAutoOpenDoorInfo =
	{
		is_open = ModeInfo.DefaultAutoOpenDoor == 1,
		default = ModeInfo.DefaultAutoOpenDoor == 1,
		adjustable = ModeInfo.AutoOpenDoorAdjustable == 1,
	};

	--自动拾取
	BP_STRUCT_RoomCreateAutoPickInfo =
	{
		is_open = ModeInfo.DefaultAutoPick == 1,
		default = ModeInfo.DefaultAutoPick == 1,
		adjustable = ModeInfo.AutoPickAdjustable == 1,
	};

	--辅助瞄准
	BP_STRUCT_RoomCreateAimAssistInfo =
	{
		is_open = ModeInfo.DefaultAimAssist == 1,
		default = ModeInfo.DefaultAimAssist == 1,
		adjustable = ModeInfo.AimAssistAdjustable == 1,
	};

	--枪械扣弹
	BP_STRUCT_RoomCreateBuckleBulletInfo =
	{
		is_open = ModeInfo.DefaultBuckleBullet == 1,
		default = ModeInfo.DefaultBuckleBullet == 1,
		adjustable = ModeInfo.BuckleBulletAdjustable == 1,
	};

	--轰炸区
	BP_STRUCT_RoomCreateBombingAreaInfo =
	{
		is_open = ModeInfo.DefaultBombingArea == 1,
		default = ModeInfo.DefaultBombingArea == 1,
		adjustable = ModeInfo.BombingAreaAdjustable == 1,
	};

	--信号枪
	BP_STRUCT_RoomCreateSignalGunInfo =
	{
		is_open = ModeInfo.DefaultSignalGun == 1,
		default = ModeInfo.DefaultSignalGun == 1,
		adjustable = ModeInfo.SignalGunAdjustable == 1,
	};

	--掉落倍数参数
	RoomCreateUI.SetDropParaInfo();

	--更新房卡信息
	--RoomCreateUI.UpdateCurModeRoomCardInfo();

	BP_CreateRoom_NeedLoadAdvPara = true;

	-- RoomCreateUI.AllParaLog();
end

function RoomCreateUI.SetDropParaInfo()
	log("RoomCreateUI SetDropPara "..tostring(BP_CreateRoom_CurCustomNum));

	BP_ARRAY_RoomCreateFirstTypeList = {};
	BP_ARRAY_RoomCreateSecondTypeList = {};


	local SameCustomNumberParaInfo = FuncUtil:CopyTable(RoomCreateUI.CustomRoomParaInfo[BP_CreateRoom_CurCustomNum]);
	--log_tree("SetDropParaInfo :RoomCreateUI.CustomRoomParaInfo = ", RoomCreateUI.CustomRoomParaInfo);
	--log_tree("SetDropParaInfo :SameCustomNumberParaInfo = ", SameCustomNumberParaInfo);
	if SameCustomNumberParaInfo ~= nil then
		for k,v in pairs(RoomCreateUI.CustomTypeNameList) do
			--log("--SetDropParaInfo--"..tostring(v));
			if SameCustomNumberParaInfo[v] ~= nil then
				local list = {};
				local info = {};
				list = FuncUtil:CopyTable(SameCustomNumberParaInfo[v]);
				info.BP_ARRAY_RoomCreateSecondTypeDeatilList = list;
				table.insert(BP_ARRAY_RoomCreateFirstTypeList, {type_name = v});
				table.insert(BP_ARRAY_RoomCreateSecondTypeList, info);
			end
		end
	end

	BP_CreateRoom_IsAdvParaChanged = false;

	--log_tree("BP_ARRAY_RoomCreateFirstTypeList = ", BP_ARRAY_RoomCreateFirstTypeList);
	--log_tree("BP_ARRAY_RoomCreateSecondTypeList = ", BP_ARRAY_RoomCreateSecondTypeList);
end

function RoomCreateUI.InitRoomCreateDropPara()
	log("RoomCreateUI InitRoomCreateDropPara");
	local weaponType = Client.GetTableData("LocalizeRes",6296).TextValue;
	local additemType = Client.GetTableData("LocalizeRes",6297).TextValue;
	local consumeType = Client.GetTableData("LocalizeRes",6298).TextValue;
	local equipType = Client.GetTableData("LocalizeRes",6299).TextValue;
	local othersType = Client.GetTableData("LocalizeRes",4965).TextValue;
	RoomCreateUI.CustomTypeNameList =
	{
		weaponType,
		additemType,
		consumeType,
		equipType,
		othersType,
	};
	RoomCreateUI.CustomRoomParaInfo = {};
	local AllCustomRoomParaList = {};
	local CustomTable = Client.GetTable("CustomRoomParameter");
	for k,v in pairs(CustomTable) do
		local item = {};
		item.custom_num = v.CustomNumber;
		item.type_name = v.FirstTypeName;
		item.name = v.SecondTypeName;
		item.type_key = v.SecondTypeKey;
		item.default_value = v.DefaultMultiple;
		item.sort_num = v.SecondTypeSort;
		item.value = v.DefaultMultiple;
		if v.AdjustEnable == 1 then
			item.adjust_enable = true;
		else
			item.adjust_enable = false;
		end
		item.BP_ARRAY_RoomCreateMultipleList = {};
		local str = string.sub(v.Multiple, 2, -2);
		local array = string.split(str, ";");
		for i = 1, #array do
			table.insert(item.BP_ARRAY_RoomCreateMultipleList, tonumber(array[i]));
		end
		table.insert(AllCustomRoomParaList, item);

		RoomCreateUI.CustomRoomParaInfo[v.CustomNumber] = {};
	end

	for k,v in pairs(RoomCreateUI.CustomRoomParaInfo) do
		v[weaponType] = {};
		v[additemType] = {};
		v[consumeType] = {};
		v[equipType] = {};
		v[othersType] = {};
		for m,n in pairs(AllCustomRoomParaList) do
			if n.custom_num == k then
				if v[n.type_name] then
					table.insert(v[n.type_name], n);
				else
					log("typename error "..tostring(n.type_name));
				end
			end
		end
		local sort_func = function(a,b) return a.sort_num < b.sort_num end;
		table.sort(v[weaponType], sort_func);
		table.sort(v[additemType], sort_func);
		table.sort(v[consumeType], sort_func);
		table.sort(v[equipType], sort_func);
		table.sort(v[othersType], sort_func);
	end
	--log_tree("RoomCreateUI.CustomTypeNameList =", RoomCreateUI.CustomTypeNameList);
	--log_tree("AllCustomRoomParaList =", AllCustomRoomParaList);
	--log_tree("RoomCreateUI.CustomRoomParaInfo =", RoomCreateUI.CustomRoomParaInfo);
end

function RoomCreateUI.ReleaseDropParmInfo()
	log("RoomCreateUI ReleaseDropParmInfo");
	RoomCreateUI.CustomTypeNameList = {};
	RoomCreateUI.CustomRoomParaInfo = {};
end

function RoomCreateUI.InitRoomModeTableWithVersion()
	log("RoomCreateUI InitRoomModeTableWithVersion");
	RoomCreateUI.RoomModeTableWithVersion = {};
	local list = {};
	local RoomModeTable = Client.GetTable("RoomModeTable");
	for k,v in pairs(RoomModeTable) do
		local curVersion = Client.GetAppVersion();
		local minVersion = v.MinVersion;
		local iterator1 = string.gmatch(curVersion, "%d+");
		local iterator2 = string.gmatch(minVersion, "%d+");
		--log("curVersion = "..curVersion);
		--log("minVersion = "..minVersion);
		curVersion = "";
		minVersion = "";
		for value1 in iterator1 do
			curVersion = curVersion..value1;
		end
		for value2 in iterator2 do
			minVersion = minVersion..value2;
		end
		--log("curVersion = "..curVersion);
		--log("tonumber(curVersion) = "..tonumber(curVersion));
		--log("minVersion = "..minVersion);
		--log("tonumber(minVersion) = "..tonumber(minVersion));
		--策划配置表阻塞
		--if tonumber(curVersion) >= tonumber(minVersion) then
			table.insert(list, v);
		--end
		-- table.insert(list, v);
	end
	table.sort(list, function(a,b) return a.ID < b.ID end);
	for i=1,#list do
		RoomCreateUI.RoomModeTableWithVersion[list[i].ID] = list[i];
	end
	-- log_tree("list =", list);
	--log_tree("RoomCreateUI.RoomModeTableWithVersion =", RoomCreateUI.RoomModeTableWithVersion);
end

function RoomCreateUI.ShowUIInRoom()
	BP_CreateRoom_IsCompetitionRoom = RoomSystem.CurrentRoomInfo.room_type == "match"
	--RoomCreateUI.BattleCustomCfgInfo["BluecircleDamage"]~=nil;
	LuaClassObj.HandleDynamicCreation(bp_room_create);
	UIManager.Show(eUIType.eRoomCreateUI)
	RoomCreateUI.InitRoomCreateDropPara();

	RoomCreateUI.IsSameRoomTableItem = false;

	RoomCreateUI.BattleCustomCfgInfo = {};
	RoomCreateUI.BattleCustomCfgInfo = FuncUtil:CopyTable(RoomSystem.CurrentRoomInfo.battle_custom_cfg);

	BP_RoomCreate_SelfName = DataMgr.roleData.nickName;
	BP_CreateRoom_NeedLoadAdvPara = true;
	BP_IsCreateRoom = false;
	BP_CreateRoom_IsRoomMaster = RoomSystem.isRoomOwner();
	--BP_CreateRoom_Name = RoomSystem.CurrentRoomInfo.name;
	-- BP_CreateRoom_Passwd = "";
	BP_CreateRoom_IsLocked = RoomSystem.CurrentRoomInfo.lock_state;
	BP_CreateRoom_AllowInvite = RoomSystem.CurrentRoomInfo.allow_invite;
	local defaultModeId = BP_CreateRoom_IsCompetitionRoom and 10002 or 1001
	local ModeInfo = RoomCreateUI.RoomModeTableWithVersion[defaultModeId];
	BP_CreateRoom_IsUsePcPara =
	log_tree("modeinfo",ModeInfo)
	BP_CreateRoom_RoomTableID = ModeInfo.ID;
	BP_CreateRoom_RoomModeID = ModeInfo.ModeID;
	BP_CreateRoom_RoomModeName = ModeInfo.ModeName;
	BP_CreateRoom_RoomModeDesc = "";
	BP_CreateRoom_RoomModeImage = ModeInfo.ImagePath;
	--BP_CreateRoom_MapID = ModeInfo.MapID;
	BP_CreateRoom_MapName = ModeInfo.MapName;
	BP_CreateRoom_PlayMethod = ModeInfo.PlayMethod;
	if RoomSystem.CurrentRoomInfo.is_fpp then
		BP_CreateRoom_Perspective = "第一人称";
		BP_CreateRoom_IsFPP = true;
	else
		BP_CreateRoom_Perspective = "第三人称";
		BP_CreateRoom_IsFPP = false;
	end
	if RoomSystem.CurrentRoomInfo.group_type == 1 then
		BP_CreateRoom_TeamModeID = ModeInfo.SoloModeID;
		BP_CreateRoom_TeamModeName = "单人";
	elseif RoomSystem.CurrentRoomInfo.group_type == 2 then
		BP_CreateRoom_TeamModeID = ModeInfo.DoubleModeID;
		BP_CreateRoom_TeamModeName = "双人";
	elseif RoomSystem.CurrentRoomInfo.group_type == 4 then
		BP_CreateRoom_TeamModeID = ModeInfo.QuaternaryModeID;
		BP_CreateRoom_TeamModeName = "四人";
	end
	BP_CreateRoom_PlayerNumMax = ModeInfo.MaxPlayerNum;
	BP_CreateRoom_PlayerNumMin = ModeInfo.MinPlayerNum;
	BP_CreateRoom_PlayerNum = RoomSystem.CurrentRoomInfo.max_room_player;
	BP_CreateRoom_WeatherModeID = RoomSystem.CurrentRoomInfo.weather_id;
	BP_CreateRoom_WeatherModeEN = RoomSystem.CurrentRoomInfo.weather_name;
	BP_CreateRoom_IsAdvParaChanged = false;

	BP_ARRAY_RoomCreateMapNameList = {};
	BP_ARRAY_RoomCreatePlayMethodList = {};
	BP_ARRAY_RoomCreatePerspectiveList = {};
	BP_ARRAY_RoomCreateTeamModeNameList = {};
	BP_ARRAY_RoomCreateWeatherModeCNList = {};
	BP_ARRAY_RoomCreateWeatherModeIDList = {};
	BP_ARRAY_RoomCreateWeatherModeENList = {};
	BP_ARRAY_RoomCreateCustomNumList = {};

	--选出当前模式下所有地图名
	local AllCurModeInfoList = {};
	local MapKeyTable = {};	--去重
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeID == ModeInfo.ModeID and MapKeyTable[v.MapName] == nil then
			table.insert(AllCurModeInfoList, v);
			MapKeyTable[v.MapName] = true;
		end
	end
	table.sort(AllCurModeInfoList, function(a,b) return a.ID < b.ID end);
	for i=1,#AllCurModeInfoList do
		BP_ARRAY_RoomCreateMapNameList[i] = AllCurModeInfoList[i].MapName;
	end
	--选出当前模式和地图下所有玩法
	local AllCurModeMapInfoList = {};
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeID == ModeInfo.ModeID and v.MapID == ModeInfo.MapID then
			table.insert(AllCurModeMapInfoList, v);
		end
	end
	table.sort(AllCurModeMapInfoList, function(a,b) return a.ID < b.ID end);
	for i=1,#AllCurModeMapInfoList do
		BP_ARRAY_RoomCreatePlayMethodList[i] = AllCurModeMapInfoList[i].PlayMethod;
	end
	--视角列表
	BP_ARRAY_RoomCreatePerspectiveList = FuncUtil:StrSplit(ModeInfo.OptionalPerspective, ";");

	--队伍模式名列表
	local index = 1;
	if ModeInfo.SoloModeID ~= 0 then
		BP_ARRAY_RoomCreateTeamModeNameList[index] = Client.GetTableData("LocalizeRes", "993048").TextValue;
		index = index + 1;
	end
	if ModeInfo.DoubleModeID ~= 0 then
		BP_ARRAY_RoomCreateTeamModeNameList[index] = Client.GetTableData("LocalizeRes", "993049").TextValue;
		index = index + 1;
	end
	if ModeInfo.QuaternaryModeID ~= 0 then
		BP_ARRAY_RoomCreateTeamModeNameList[index] = Client.GetTableData("LocalizeRes", "993050").TextValue;
	end
	--缩圈速度
	BP_ARRAY_RoomCreateShrinkSpeedList = {};
	BP_ARRAY_RoomCreateShrinkSpeedList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6308) and Client.GetTableData("LocalizeRes",6308).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultShrinkSpeed,
		adjust_enable = ModeInfo.ShrinkSpeedAdjustable == 1,
		sort_num = 0,
		value = RoomCreateUI.BattleCustomCfgInfo["ShrinkSpeed"],
	};
	local str = string.sub(ModeInfo.OptionalShrinkSpeed, 2, -2);
	BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateShrinkSpeedList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	if BP_ARRAY_RoomCreateShrinkSpeedList[1].value ~= ModeInfo.DefaultShrinkSpeed then
		BP_CreateRoom_IsAdvParaChanged = true;
	end
	--蓝圈伤害值
	BP_ARRAY_RoomCreateBCircleDamageList = {};
	BP_ARRAY_RoomCreateBCircleDamageList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6843) and Client.GetTableData("LocalizeRes",6843).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultBCircleDamage,
		adjust_enable = true,
		sort_num = 0,
		value = RoomCreateUI.BattleCustomCfgInfo["BluecircleDamage"]~=nil and RoomCreateUI.BattleCustomCfgInfo["BluecircleDamage"]
				or ModeInfo.DefaultBCircleDamage,
	};
	str = string.sub(ModeInfo.OptionalBCircleDamage, 2, -2);
	BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateBCircleDamageList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	if BP_ARRAY_RoomCreateBCircleDamageList[1].value ~= ModeInfo.DefaultBCircleDamage then
		BP_CreateRoom_IsAdvParaChanged = true;
	end
	--白圈显示时间
	BP_ARRAY_RoomCreateWCircleTimeShowList ={};
	BP_ARRAY_RoomCreateWCircleTimeShowList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6844) and Client.GetTableData("LocalizeRes",6844).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultWCircle1TimeShow,
		adjust_enable = true,
		sort_num = 0,
		value = RoomCreateUI.BattleCustomCfgInfo["WhitecircleShowtime"] ~= nil and RoomCreateUI.BattleCustomCfgInfo["WhitecircleShowtime"]
				or ModeInfo.DefaultWCircle1TimeShow,
	};
	str = string.sub(ModeInfo.OptionalWCircle1TimeShow, 2, -2);
	BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateWCircleTimeShowList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	if BP_ARRAY_RoomCreateWCircleTimeShowList[1].value ~= ModeInfo.DefaultWCircle1TimeShow then
		BP_CreateRoom_IsAdvParaChanged = true;
	end
	--白圈开始时间
	BP_ARRAY_RoomCreateWCircleTimeBeginList ={};
	BP_ARRAY_RoomCreateWCircleTimeBeginList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6845) and Client.GetTableData("LocalizeRes",6845).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultWCircle1TimeBegin,
		adjust_enable = true,
		sort_num = 0,
		value = RoomCreateUI.BattleCustomCfgInfo["WhitecircleStarttime"]~=nil and RoomCreateUI.BattleCustomCfgInfo["WhitecircleStarttime"]
				or ModeInfo.DefaultWCircle1TimeBegin,
	};
	str = string.sub(ModeInfo.OptionalWCircle1TimeBegin, 2, -2);
	BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateWCircleTimeBeginList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	if BP_ARRAY_RoomCreateWCircleTimeBeginList[1].value ~= ModeInfo.DefaultWCircle1TimeBegin then
		BP_CreateRoom_IsAdvParaChanged = true;
	end
	--白圈直径
	BP_ARRAY_RoomCreateWCircleDiameterList ={};
	BP_ARRAY_RoomCreateWCircleDiameterList[1] =
	{
		custom_num = 0,
		type_name = "",
		name = Client.GetTableData("LocalizeRes",6846) and Client.GetTableData("LocalizeRes",6846).TextValue or "ShrinkSpeed",
		type_key = "",
		BP_ARRAY_RoomCreateMultipleList = {},
		default_value = ModeInfo.DefaultWCircle1Diameter,
		adjust_enable = true,
		sort_num = 0,
		value = RoomCreateUI.BattleCustomCfgInfo["WhitecircleDiameter"]~=nil and RoomCreateUI.BattleCustomCfgInfo["WhitecircleDiameter"]
				or ModeInfo.DefaultWCircle1Diameter,
	};
	str = string.sub(ModeInfo.OptionalWCircle1Diameter, 2, -2);
	BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList = FuncUtil:StrSplit(str, ";");
	for i=1,#BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList do
		BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList[i] = tonumber(BP_ARRAY_RoomCreateWCircleDiameterList[1].BP_ARRAY_RoomCreateMultipleList[i]);
	end
	if BP_ARRAY_RoomCreateWCircleDiameterList[1].value ~= ModeInfo.DefaultWCircle1Diameter then
		BP_CreateRoom_IsAdvParaChanged = true;
	end
	--声音可视化
	BP_STRUCT_RoomCreateSoundVisualInfo =
	{
		is_open = RoomCreateUI.BattleCustomCfgInfo["SoundVisual"],
		default = ModeInfo.DefaultSoundVisual == 1,
		adjustable = ModeInfo.SoundVisualAdjustable == 1,
	};
	if BP_STRUCT_RoomCreateSoundVisualInfo.is_open ~= (ModeInfo.DefaultSoundVisual == 1) then
		BP_CreateRoom_IsAdvParaChanged = true;
	end

	--自动开门
	BP_STRUCT_RoomCreateAutoOpenDoorInfo =
	{
		is_open = RoomCreateUI.BattleCustomCfgInfo["AutoOpenDoor"],
		default = ModeInfo.DefaultAutoOpenDoor == 1,
		adjustable = ModeInfo.AutoOpenDoorAdjustable == 1,
	};
	if BP_STRUCT_RoomCreateAutoOpenDoorInfo.is_open ~= (ModeInfo.DefaultAutoOpenDoor == 1) then
		BP_CreateRoom_IsAdvParaChanged = true;
	end

	--自动拾取
	BP_STRUCT_RoomCreateAutoPickInfo =
	{
		is_open = RoomCreateUI.BattleCustomCfgInfo["AutoPick"],
		default = ModeInfo.DefaultAutoPick == 1,
		adjustable = ModeInfo.AutoPickAdjustable == 1,
	};
	if BP_STRUCT_RoomCreateAutoPickInfo.is_open ~= (ModeInfo.DefaultAutoPick == 1) then
		BP_CreateRoom_IsAdvParaChanged = true;
	end

	--辅助瞄准
	BP_STRUCT_RoomCreateAimAssistInfo =
	{
		is_open = RoomCreateUI.BattleCustomCfgInfo["AimAssist"],
		default = ModeInfo.DefaultAimAssist == 1,
		adjustable = ModeInfo.AimAssistAdjustable == 1,
	};
	if BP_STRUCT_RoomCreateAimAssistInfo.is_open ~= (ModeInfo.DefaultAimAssist == 1) then
		BP_CreateRoom_IsAdvParaChanged = true;
	end

	--枪械扣弹
	BP_STRUCT_RoomCreateBuckleBulletInfo =
	{
		is_open = RoomCreateUI.BattleCustomCfgInfo["BuckleBullet"],
		default = ModeInfo.DefaultBuckleBullet == 1,
		adjustable = ModeInfo.BuckleBulletAdjustable == 1,
	};
	if BP_STRUCT_RoomCreateBuckleBulletInfo.is_open ~= (ModeInfo.DefaultBuckleBullet == 1) then
		BP_CreateRoom_IsAdvParaChanged = true;
	end

	--轰炸区
	BP_STRUCT_RoomCreateBombingAreaInfo =
	{
		is_open = RoomCreateUI.BattleCustomCfgInfo["Redzone"],
		default = ModeInfo.DefaultBombingArea == 1,
		adjustable = ModeInfo.BombingAreaAdjustable == 1,
	};
	if BP_STRUCT_RoomCreateBombingAreaInfo.is_open == nil then
		BP_STRUCT_RoomCreateBombingAreaInfo.is_open = ModeInfo.DefaultBombingArea == 1;
	end
	if BP_STRUCT_RoomCreateBombingAreaInfo.is_open ~= (ModeInfo.DefaultBombingArea == 1) then
		BP_CreateRoom_IsAdvParaChanged = true;
	end

	--信号枪
	BP_STRUCT_RoomCreateSignalGunInfo =
	{
		is_open = RoomCreateUI.BattleCustomCfgInfo["Firegun"],
		default = ModeInfo.DefaultSignalGun == 1,
		adjustable = ModeInfo.SignalGunAdjustable == 1,
	};
	if BP_STRUCT_RoomCreateSignalGunInfo.is_open == nil then
		BP_STRUCT_RoomCreateSignalGunInfo.is_open = ModeInfo.DefaultSignalGun == 1;
	end
	if BP_STRUCT_RoomCreateSignalGunInfo.is_open ~= (ModeInfo.DefaultSignalGun == 1) then
		BP_CreateRoom_IsAdvParaChanged = true;
	end
	--掉落倍数参数
	BP_ARRAY_RoomCreateFirstTypeList = {};
	BP_ARRAY_RoomCreateSecondTypeList = {};
	local SameCustomNumberParaInfo = FuncUtil:CopyTable(RoomCreateUI.CustomRoomParaInfo[BP_CreateRoom_CurCustomNum]);
	if SameCustomNumberParaInfo ~= nil then
		for k,v in pairs(RoomCreateUI.CustomTypeNameList) do
			if SameCustomNumberParaInfo[v] ~= nil then
				local list = {};
				local info = {};
				list = FuncUtil:CopyTable(SameCustomNumberParaInfo[v]);
				for i = 1, #list do
					for k2,v2 in pairs(RoomCreateUI.BattleCustomCfgInfo) do
						if list[i].type_key == k2 then
							--log("ccl inroom k= "..tostring(k2).."v = "..tostring(v2))
							if list[i].value ~= v2 then
								BP_CreateRoom_IsAdvParaChanged = true;
								list[i].value = v2;
							end
							break;
						end
					end
				end
				info.BP_ARRAY_RoomCreateSecondTypeDeatilList = list;
				table.insert(BP_ARRAY_RoomCreateFirstTypeList, {type_name = v});
				table.insert(BP_ARRAY_RoomCreateSecondTypeList, info);
			end
		end
	end
	--log_tree("BP_ARRAY_RoomCreateFirstTypeList = ", BP_ARRAY_RoomCreateFirstTypeList);
	--log_tree("BP_ARRAY_RoomCreateSecondTypeList = ", BP_ARRAY_RoomCreateSecondTypeList);

	-- RoomCreateUI.AllParaLog();

	LuaClassObj.HandleUIMessage(bp_room_create, "ShowUI");
end

function RoomCreateUI.SelectRoomMode(mode_id)
	log("RoomCreateUI SelectRoomMode");

	--缓存当前模式信息
	RoomCreateUI.SetRoomModeTempInfo();

	if RoomCreateUI.RoomModeTempInfo[mode_id] ~= nil and RoomCreateUI.RoomModeTempInfo[mode_id] ~= {} then
		--选择的模式有缓存
		RoomCreateUI.UseRoomModeTempInfo(mode_id);
	else
		--选择的模式没有缓存
		local id = 99999999;
		for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
			if v.ModeID == mode_id and v.ID < id then
				id = v.ID;
			end
		end
		RoomCreateUI.SetAllParameterInitInfo(id);
	end

	LuaClassObj.HandleUIMessage(bp_room_create, "SetModeRelativeParm");
end

function RoomCreateUI.UpdateCurModeRoomCardInfo()
	log("RoomCreateUI UpdateCurModeRoomCardInfo");
end

function RoomCreateUI.FormatRoomCardTime(left_ts)
	local format_ts = "";

	if left_ts == nil or type(left_ts) ~= "number" then
		return format_ts;
	end

	local days = math.floor(left_ts/86400);
	local hours = math.fmod(math.floor(left_ts/3600), 24);
	local mins = math.fmod(math.floor(left_ts/60), 60);
	local seconds = math.fmod(left_ts, 60);

	if days == 0 and hours == 0 and mins == 0 and seconds == 0 then
		format_ts = "";
	else
		local days_s = FuncUtil.LocalizeResFormat("301153", days);
		local hours_s = FuncUtil.LocalizeResFormat("301155", hours);
		local mins_s = FuncUtil.LocalizeResFormat("301156", mins);
		local seconds_s = FuncUtil.LocalizeResFormat("301157", seconds);
		if days > 0 then
			format_ts = days_s .. hours_s .. mins_s;
		else
			format_ts = hours_s .. mins_s .. seconds_s;
		end
	end

	return format_ts;
end

function RoomCreateUI.HideUI()
	log("RoomCreateUI HideUI");

	UIManager.Hide(eUIType.eRoomCreateUI)
	LuaClassObj.HandleUIMessage(bp_room_create, "HideUI");
end

function RoomCreateUI.GetRoomModeTableWithVersion()
	return RoomCreateUI.RoomModeTableWithVersion;
end

function RoomCreateUI.GetCurRoomModeID()
	return BP_CreateRoom_RoomModeID;
end

function RoomCreateUI.SetRoomModeTempInfo()
	log("RoomCreateUI SetRoomModeTempInfo");

	local id = BP_CreateRoom_RoomModeID;
	RoomCreateUI.RoomModeTempInfo[id] = {};
	RoomCreateUI.RoomModeTempInfo[id].RoomTableID = BP_CreateRoom_RoomTableID;
	RoomCreateUI.RoomModeTempInfo[id].RoomModeID = BP_CreateRoom_RoomModeID;
	RoomCreateUI.RoomModeTempInfo[id].RoomModeName = BP_CreateRoom_RoomModeName;
	RoomCreateUI.RoomModeTempInfo[id].RoomModeDesc = BP_CreateRoom_RoomModeDesc;
	RoomCreateUI.RoomModeTempInfo[id].RoomModeImage = BP_CreateRoom_RoomModeImage;
	RoomCreateUI.RoomModeTempInfo[id].RoomMapID = BP_CreateRoom_MapID;
	RoomCreateUI.RoomModeTempInfo[id].RoomMapName = BP_CreateRoom_MapName;
	RoomCreateUI.RoomModeTempInfo[id].PlayMethod = BP_CreateRoom_PlayMethod;
	RoomCreateUI.RoomModeTempInfo[id].Perspective = BP_CreateRoom_Perspective;
	RoomCreateUI.RoomModeTempInfo[id].IsFPP = BP_CreateRoom_IsFPP;
	RoomCreateUI.RoomModeTempInfo[id].TeamModeID = BP_CreateRoom_TeamModeID;
	RoomCreateUI.RoomModeTempInfo[id].TeamModeName = BP_CreateRoom_TeamModeName;
	RoomCreateUI.RoomModeTempInfo[id].PlayerNumMax = BP_CreateRoom_PlayerNumMax;
	RoomCreateUI.RoomModeTempInfo[id].PlayerNumMin = BP_CreateRoom_PlayerNumMin;
	RoomCreateUI.RoomModeTempInfo[id].PlayerNum = BP_CreateRoom_PlayerNum;
	RoomCreateUI.RoomModeTempInfo[id].WeatherModeName = BP_CreateRoom_WeatherModeName;
	RoomCreateUI.RoomModeTempInfo[id].WeatherModeID = BP_CreateRoom_WeatherModeID;
	RoomCreateUI.RoomModeTempInfo[id].WeatherModeEN = BP_CreateRoom_WeatherModeEN;
	RoomCreateUI.RoomModeTempInfo[id].CurCustomNum = BP_CreateRoom_CurCustomNum;

	RoomCreateUI.RoomModeTempInfo[id].RoomCreateMapNameList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateMapNameList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreatePlayMethodList = FuncUtil:CopyTable(BP_ARRAY_RoomCreatePlayMethodList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreatePerspectiveList = FuncUtil:CopyTable(BP_ARRAY_RoomCreatePerspectiveList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateTeamModeNameList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateTeamModeNameList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateWeatherModeCNList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateWeatherModeCNList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateWeatherModeIDList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateWeatherModeIDList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateWeatherModeENList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateWeatherModeENList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateCustomNumList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateCustomNumList);

	RoomCreateUI.RoomModeTempInfo[id].RoomCreateShrinkSpeedList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateShrinkSpeedList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateBCircleDamageList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateBCircleDamageList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateWCircleTimeShowList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateWCircleTimeShowList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateWCircleTimeBeginList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateWCircleTimeBeginList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateWCircleDiameterList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateWCircleDiameterList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateSoundVisualInfo = FuncUtil:CopyTable(BP_STRUCT_RoomCreateSoundVisualInfo);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateAutoOpenDoorInfo = FuncUtil:CopyTable(BP_STRUCT_RoomCreateAutoOpenDoorInfo);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateAutoPickInfo = FuncUtil:CopyTable(BP_STRUCT_RoomCreateAutoPickInfo);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateAimAssistInfo = FuncUtil:CopyTable(BP_STRUCT_RoomCreateAimAssistInfo);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateBuckleBulletInfo = FuncUtil:CopyTable(BP_STRUCT_RoomCreateBuckleBulletInfo);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateBombingAreaInfo = FuncUtil:CopyTable(BP_STRUCT_RoomCreateBombingAreaInfo);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateSignalGunInfo = FuncUtil:CopyTable(BP_STRUCT_RoomCreateSignalGunInfo);

	RoomCreateUI.RoomModeTempInfo[id].RoomCreateFirstTypeList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateFirstTypeList);
	RoomCreateUI.RoomModeTempInfo[id].RoomCreateSecondTypeList = FuncUtil:CopyTable(BP_ARRAY_RoomCreateSecondTypeList);
end

function RoomCreateUI.UseRoomModeTempInfo(mode_id)
	log("RoomCreateUI UseRoomModeTempInfo");

	BP_CreateRoom_RoomTableID = RoomCreateUI.RoomModeTempInfo[mode_id].RoomTableID;
	BP_CreateRoom_RoomModeID = RoomCreateUI.RoomModeTempInfo[mode_id].RoomModeID;
	BP_CreateRoom_RoomModeName = RoomCreateUI.RoomModeTempInfo[mode_id].RoomModeName;
	BP_CreateRoom_RoomModeDesc = RoomCreateUI.RoomModeTempInfo[mode_id].RoomModeDesc;
	BP_CreateRoom_RoomModeImage = RoomCreateUI.RoomModeTempInfo[mode_id].RoomModeImage;
	BP_CreateRoom_MapID = RoomCreateUI.RoomModeTempInfo[mode_id].RoomMapID;
	BP_CreateRoom_MapName = RoomCreateUI.RoomModeTempInfo[mode_id].RoomMapName;
	BP_CreateRoom_PlayMethod = RoomCreateUI.RoomModeTempInfo[mode_id].PlayMethod;
	BP_CreateRoom_Perspective = RoomCreateUI.RoomModeTempInfo[mode_id].Perspective;
	BP_CreateRoom_IsFPP = RoomCreateUI.RoomModeTempInfo[mode_id].IsFPP;
	BP_CreateRoom_TeamModeID = RoomCreateUI.RoomModeTempInfo[mode_id].TeamModeID;
	BP_CreateRoom_TeamModeName = RoomCreateUI.RoomModeTempInfo[mode_id].TeamModeName;
	BP_CreateRoom_PlayerNumMax = RoomCreateUI.RoomModeTempInfo[mode_id].PlayerNumMax;
	BP_CreateRoom_PlayerNumMin = RoomCreateUI.RoomModeTempInfo[mode_id].PlayerNumMin;
	BP_CreateRoom_PlayerNum = RoomCreateUI.RoomModeTempInfo[mode_id].PlayerNum;
	BP_CreateRoom_WeatherModeName = RoomCreateUI.RoomModeTempInfo[mode_id].WeatherModeName;
	BP_CreateRoom_WeatherModeID = RoomCreateUI.RoomModeTempInfo[mode_id].WeatherModeID;
	BP_CreateRoom_WeatherModeEN = RoomCreateUI.RoomModeTempInfo[mode_id].WeatherModeEN;
	BP_CreateRoom_CurCustomNum = RoomCreateUI.RoomModeTempInfo[mode_id].CurCustomNum;

	BP_ARRAY_RoomCreateMapNameList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateMapNameList);
	BP_ARRAY_RoomCreatePlayMethodList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreatePlayMethodList);
	BP_ARRAY_RoomCreatePerspectiveList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreatePerspectiveList);
	BP_ARRAY_RoomCreateTeamModeNameList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateTeamModeNameList);
	BP_ARRAY_RoomCreateWeatherModeCNList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateWeatherModeCNList);
	BP_ARRAY_RoomCreateWeatherModeIDList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateWeatherModeIDList);
	BP_ARRAY_RoomCreateWeatherModeENList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateWeatherModeENList);
	BP_ARRAY_RoomCreateCustomNumList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateCustomNumList);

	BP_ARRAY_RoomCreateShrinkSpeedList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateShrinkSpeedList);
	BP_ARRAY_RoomCreateBCircleDamageList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateBCircleDamageList);
	BP_ARRAY_RoomCreateWCircleTimeShowList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateWCircleTimeShowList);
	BP_ARRAY_RoomCreateWCircleTimeBeginList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateWCircleTimeBeginList);
	BP_ARRAY_RoomCreateWCircleDiameterList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateWCircleDiameterList);
	BP_STRUCT_RoomCreateSoundVisualInfo = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateSoundVisualInfo);
	BP_STRUCT_RoomCreateAutoOpenDoorInfo = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateAutoOpenDoorInfo);
	BP_STRUCT_RoomCreateAutoPickInfo = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateAutoPickInfo);
	BP_STRUCT_RoomCreateAimAssistInfo = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateAimAssistInfo);
	BP_STRUCT_RoomCreateBuckleBulletInfo = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateBuckleBulletInfo);
	BP_STRUCT_RoomCreateBombingAreaInfo = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateBombingAreaInfo );
	BP_STRUCT_RoomCreateSignalGunInfo = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateSignalGunInfo );

	BP_ARRAY_RoomCreateFirstTypeList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateFirstTypeList);
	BP_ARRAY_RoomCreateSecondTypeList = FuncUtil:CopyTable(RoomCreateUI.RoomModeTempInfo[mode_id].RoomCreateSecondTypeList);

	--更新房卡信息
	--RoomCreateUI.UpdateCurModeRoomCardInfo();

	BP_CreateRoom_NeedLoadAdvPara = true;

	-- RoomCreateUI.AllParaLog();
end

function RoomCreateUI.AllParaLog()
	log("BP_CreateRoom_Name = "..BP_CreateRoom_Name);
	log("BP_CreateRoom_Passwd = "..BP_CreateRoom_Passwd);
	log("BP_CreateRoom_AllowInvite = "..tostring(BP_CreateRoom_AllowInvite));

	log("BP_CreateRoom_RoomTableID = "..BP_CreateRoom_RoomTableID);
	log("BP_CreateRoom_RoomModeID = "..BP_CreateRoom_RoomModeID);
	log("BP_CreateRoom_RoomModeName = "..BP_CreateRoom_RoomModeName);
	log("BP_CreateRoom_RoomModeDesc = "..BP_CreateRoom_RoomModeDesc);
	log("BP_CreateRoom_RoomModeImage = "..BP_CreateRoom_RoomModeImage);
	log("BP_CreateRoom_MapID = "..BP_CreateRoom_MapID);
	log("BP_CreateRoom_MapName = "..BP_CreateRoom_MapName);
	log("BP_CreateRoom_PlayMethod = "..BP_CreateRoom_PlayMethod);
	log("BP_CreateRoom_Perspective = "..BP_CreateRoom_Perspective);
	log("BP_CreateRoom_IsFPP = "..tostring(BP_CreateRoom_IsFPP));
	log("BP_CreateRoom_TeamModeID = "..BP_CreateRoom_TeamModeID);
	log("BP_CreateRoom_TeamModeName = "..BP_CreateRoom_TeamModeName);
	log("BP_CreateRoom_PlayerNumMax = "..BP_CreateRoom_PlayerNumMax);
	log("BP_CreateRoom_PlayerNumMin = "..BP_CreateRoom_PlayerNumMin);
	log("BP_CreateRoom_PlayerNum = "..BP_CreateRoom_PlayerNum);
	log("BP_CreateRoom_WeatherModeID = "..BP_CreateRoom_WeatherModeID);
	log("BP_CreateRoom_WeatherModeName = "..BP_CreateRoom_WeatherModeName);
	log("BP_CreateRoom_WeatherModeEN = "..BP_CreateRoom_WeatherModeEN);

	log_tree("BP_ARRAY_RoomCreateMapNameList = ", BP_ARRAY_RoomCreateMapNameList);
	log_tree("BP_ARRAY_RoomCreatePlayMethodList = ", BP_ARRAY_RoomCreatePlayMethodList);
	log_tree("BP_ARRAY_RoomCreatePerspectiveList = ", BP_ARRAY_RoomCreatePerspectiveList);
	log_tree("BP_ARRAY_RoomCreateTeamModeNameList = ", BP_ARRAY_RoomCreateTeamModeNameList);
	log_tree("BP_ARRAY_RoomCreateWeatherModeCNList = ", BP_ARRAY_RoomCreateWeatherModeCNList);
	log_tree("BP_ARRAY_RoomCreateWeatherModeIDList = ", BP_ARRAY_RoomCreateWeatherModeIDList);
	log_tree("BP_ARRAY_RoomCreateWeatherModeENList = ", BP_ARRAY_RoomCreateWeatherModeENList);
	log_tree("BP_ARRAY_RoomCreateShrinkSpeedList = ", BP_ARRAY_RoomCreateShrinkSpeedList);
	log_tree("BP_ARRAY_RoomCreateCustomNumList = ", BP_ARRAY_RoomCreateCustomNumList);

	log_tree("BP_STRUCT_RoomCreateSoundVisualInfo = ", BP_STRUCT_RoomCreateSoundVisualInfo);
	log_tree("BP_STRUCT_RoomCreateAutoOpenDoorInfo = ", BP_STRUCT_RoomCreateAutoOpenDoorInfo);
	log_tree("BP_STRUCT_RoomCreateAutoPickInfo = ", BP_STRUCT_RoomCreateAutoPickInfo);
	log_tree("BP_STRUCT_RoomCreateAimAssistInfo = ", BP_STRUCT_RoomCreateAimAssistInfo);
	log_tree("BP_STRUCT_RoomCreateBuckleBulletInfo = ", BP_STRUCT_RoomCreateBuckleBulletInfo);
end



--不做任何事，蓝图里调这个函数将把lua变量的值同步给蓝图变量
function EventFetchInfo()
end

function EventRoomCreateRelease()
	RoomCreateUI.Release();
end

function EventCreateRoom()
	log("EventCreateRoom");

	--[[local betterCardSubType = RoomSystem.GetAdvisedCardInsID(BP_CreateRoom_RoomModeID)
	-- 如果有一张更合适的卡来用的话，那就提示一下玩家
	if betterCardSubType ~= 0 then
		local function useBetterCard()
			-- GlobalData.OpenUseItemsUI(betterCardID)
			-- EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, RoomCreateFinalCreateRoom)
			CommonItemListUI.ShowBySubTypeList(title, {betterCardSubType}, RoomCreateFinalCreateRoom)
		end

		local strTip = FuncUtil.GetLocalizeResStr("803003")
		local strCancel = FuncUtil.GetLocalizeResStr("803004")
		CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), strTip, useBetterCard, RoomCreateFinalCreateRoom, nil, strCancel)
		return;
	end--]]

	RoomCreateFinalCreateRoom()
end

function RoomCreateFinalCreateRoom()
	log("RoomCreateFinalCreateRoom")
	CommonItemListUI.Hide()
	-- EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_USED, RoomCreateFinalCreateRoom)
	local hasIllegalChar = false;
	local unitLen = 0;
	hasIllegalChar, unitLen = FuncUtil:CheckName(BP_CreateRoom_Name, true);

	if unitLen > 20 then
		DataMgr.ShowNoticeByID(110089);
		return;
	end

	local battle_cfg = {};
	battle_cfg["ShrinkSpeed"] = BP_ARRAY_RoomCreateShrinkSpeedList[1].value;
	battle_cfg["SoundVisual"] = BP_STRUCT_RoomCreateSoundVisualInfo.is_open;
	battle_cfg["AutoOpenDoor"] = BP_STRUCT_RoomCreateAutoOpenDoorInfo.is_open;
	battle_cfg["AutoPick"] = BP_STRUCT_RoomCreateAutoPickInfo.is_open;
	battle_cfg["AimAssist"] = BP_STRUCT_RoomCreateAimAssistInfo.is_open;
	battle_cfg["BuckleBullet"] = BP_STRUCT_RoomCreateBuckleBulletInfo.is_open;
	local roomModeId = BP_CreateRoom_IsCompetitionRoom and 10002 or 1001;
	if BP_CreateRoom_IsCompetitionRoom then
		battle_cfg["Redzone"] = BP_STRUCT_RoomCreateBombingAreaInfo.is_open;
		battle_cfg["Firegun"] = BP_STRUCT_RoomCreateSignalGunInfo.is_open;
		battle_cfg["BluecircleDamage"] = BP_ARRAY_RoomCreateBCircleDamageList[1].value;
		battle_cfg["WhitecircleShowtime"] = BP_ARRAY_RoomCreateWCircleTimeShowList[1].value;
		battle_cfg["WhitecircleStarttime"] = BP_ARRAY_RoomCreateWCircleTimeBeginList[1].value;
		battle_cfg["WhitecircleDiameter"] = BP_ARRAY_RoomCreateWCircleDiameterList[1].value;
	end
	for i = 1, #BP_ARRAY_RoomCreateSecondTypeList do
		local para_list = BP_ARRAY_RoomCreateSecondTypeList[i].BP_ARRAY_RoomCreateSecondTypeDeatilList;
		for j = 1, #para_list do
			--log("[ccll] key = "..tostring(para_list[j].type_key).."value = "..tostring(para_list[j].value))
			battle_cfg[para_list[j].type_key] = para_list[j].value;
		end
	end

	-- log("groupType = "..groupType);
	-- RoomCreateUI.AllParaLog();
	-- log_tree("battle_cfg = ", battle_cfg);
	log("BP_CreateRoom_MapID="..tostring(BP_CreateRoom_MapID));
	--log_tree("==BATTLE_CFG== ",battle_cfg)
	RoomSystem.req_create_room(BP_CreateRoom_Name,
			BP_CreateRoom_MapID,
			BP_CreateRoom_Passwd,
			BP_CreateRoom_Mode,
			BP_CreateRoom_HostCanObserve,
			battle_cfg,
			roomModeId,
			BP_CreateRoom_IsUsePcPara
	);
end

--提示房间名为空
function EventCreateRoomCheckNameEmpty()
	DataMgr.ShowNoticeByID(111020);
end

--function EventCreateRoomCheckPSWEmpty()
--	DataMgr.ShowNoticeByID(110080);
--end

--设置密码
function EventSetPSWOK()
	local psw = BP_CreateRoom_Passwd;
	local pswlen = string.len(BP_CreateRoom_Passwd);

	if type(psw) ~= "string" then
		BP_CreateRoom_Passwd = "";
		return;
	end

	if pswlen <= 0 then
		DataMgr.ShowNoticeByID(110080);
		BP_CreateRoom_Passwd = "";
		return;
	end
	if pswlen > 6 then
		DataMgr.ShowNoticeByID(110086);
		BP_CreateRoom_Passwd = "";
		return;
	else
		for i=1,pswlen do
			local curByte = string.byte(psw, i)
			if curByte < 48 or (curByte > 57 and curByte < 65) or (curByte > 90 and curByte < 97) or curByte > 122 then
				DataMgr.ShowNoticeByID(110086);
				BP_CreateRoom_Passwd = "";
				return;
			end
		end
	end
	--if psw ~= "" then
	--	DataMgr.ShowNoticeByID(110079);
	--end
	--LuaClassObj.HandleUIMessage(bp_room_create, "SetPSW");
end

--打开聊天框
function EventOpenRoomModeChatUI()
	LobbyChatEntranceUI.SetVisibility(true);
end

--关闭聊天框
function EventCloseRoomModeChatUI()
	LobbyChatEntranceUI.SetVisibility(false);
end

BP_CreateRoom_ClickMapID = 0;
BP_CreateRoom_HaveTheMap = false;

function EventIsMapReadyByMapID()
	BP_CreateRoom_HaveTheMap = TeamUpMatchInfoUI.IsMapReadyByMapID(BP_CreateRoom_ClickMapID);
	log("[HHF]EventIsMapReadyByMapID, BP_CreateRoom_HaveTheMap = " .. tostring(BP_CreateRoom_HaveTheMap).." ClickMapID = "..tostring(BP_CreateRoom_ClickMapID));
	if BP_CreateRoom_HaveTheMap ~= true then
		local tips = FuncUtil.GetLocalizeResStr(5010);
		PopUpNoticeUI.ShowNewNotice(tips);
	end

	BP_CreateRoom_CurCustomNum = _MapId2ModeID[BP_CreateRoom_ClickMapID]
	RoomCreateUI.SetDropParaInfo()
	LuaClassObj.HandleUIMessage(bp_room_create, "UpdateAdvancedParaItems");
end

--修改变量
function EventModifyVariable()
end

--房间内设置房间参数
function EventSaveParaInRoom()
	log("EventSaveParaInRoom");

	local battle_cfg = {};
	battle_cfg["ShrinkSpeed"] = BP_ARRAY_RoomCreateShrinkSpeedList[1].value;
	battle_cfg["SoundVisual"] = BP_STRUCT_RoomCreateSoundVisualInfo.is_open;
	battle_cfg["AutoOpenDoor"] = BP_STRUCT_RoomCreateAutoOpenDoorInfo.is_open;
	battle_cfg["AutoPick"] = BP_STRUCT_RoomCreateAutoPickInfo.is_open;
	battle_cfg["AimAssist"] = BP_STRUCT_RoomCreateAimAssistInfo.is_open;
	battle_cfg["BuckleBullet"] = BP_STRUCT_RoomCreateBuckleBulletInfo.is_open;
	if BP_CreateRoom_IsCompetitionRoom then
		battle_cfg["Redzone"] = BP_STRUCT_RoomCreateBombingAreaInfo.is_open;
		battle_cfg["Firegun"] = BP_STRUCT_RoomCreateSignalGunInfo.is_open;
		battle_cfg["BluecircleDamage"] = BP_ARRAY_RoomCreateBCircleDamageList[1].value;
		battle_cfg["WhitecircleShowtime"] = BP_ARRAY_RoomCreateWCircleTimeShowList[1].value;
		battle_cfg["WhitecircleStarttime"] = BP_ARRAY_RoomCreateWCircleTimeBeginList[1].value;
		battle_cfg["WhitecircleDiameter"] = BP_ARRAY_RoomCreateWCircleDiameterList[1].value;
	end
	for i = 1, #BP_ARRAY_RoomCreateSecondTypeList do
		local para_list = BP_ARRAY_RoomCreateSecondTypeList[i].BP_ARRAY_RoomCreateSecondTypeDeatilList;
		for j = 1, #para_list do
			battle_cfg[para_list[j].type_key] = para_list[j].value;
		end
	end

	local groupType = 0;
	if BP_CreateRoom_TeamModeName == "单人" then
		groupType = 1;
	elseif BP_CreateRoom_TeamModeName == "双人" then
		groupType = 2;
	elseif BP_CreateRoom_TeamModeName == "四人" then
		groupType = 4;
	end
	local roomModeId = BP_CreateRoom_IsCompetitionRoom and 10002 or 1001;
	if RoomWaitingUI.IsShow then
		RoomSystem.req_change_room(BP_STRUCT_RoomWaitingInfo.name,
				--BP_CreateRoom_Name,
				BP_CreateRoom_MapID,
				BP_Room_Passwd,
				groupType,
				BP_CreateRoom_AllowInvite,
				battle_cfg,
				roomModeId);
	end
end

--重置房间自定义高级参数
function EventResetRoomAdvancedCustomPara()
	log("EventResetRoomAdvancedCustomPara");

	BP_ARRAY_RoomCreateShrinkSpeedList[1].value = BP_ARRAY_RoomCreateShrinkSpeedList[1].default_value;
	BP_ARRAY_RoomCreateBCircleDamageList[1].value = BP_ARRAY_RoomCreateBCircleDamageList[1].default_value;
	BP_ARRAY_RoomCreateWCircleTimeShowList[1].value = BP_ARRAY_RoomCreateWCircleTimeShowList[1].default_value;
	BP_ARRAY_RoomCreateWCircleTimeBeginList[1].value = BP_ARRAY_RoomCreateWCircleTimeBeginList[1].default_value;
	BP_ARRAY_RoomCreateWCircleDiameterList[1].value = BP_ARRAY_RoomCreateWCircleDiameterList[1].default_value;

	BP_STRUCT_RoomCreateSoundVisualInfo.is_open = BP_STRUCT_RoomCreateSoundVisualInfo.default;
	BP_STRUCT_RoomCreateAutoOpenDoorInfo.is_open = BP_STRUCT_RoomCreateAutoOpenDoorInfo.default;
	BP_STRUCT_RoomCreateAutoPickInfo.is_open = BP_STRUCT_RoomCreateAutoPickInfo.default;
	BP_STRUCT_RoomCreateAimAssistInfo.is_open = BP_STRUCT_RoomCreateAimAssistInfo.default;
	BP_STRUCT_RoomCreateBuckleBulletInfo.is_open = BP_STRUCT_RoomCreateBuckleBulletInfo.default;
	BP_STRUCT_RoomCreateBombingAreaInfo.is_open = BP_STRUCT_RoomCreateBombingAreaInfo.default;
	BP_STRUCT_RoomCreateSignalGunInfo.is_open = BP_STRUCT_RoomCreateSignalGunInfo.default;

	for k,v in pairs(BP_ARRAY_RoomCreateSecondTypeList) do
		for k2,v2 in pairs(v.BP_ARRAY_RoomCreateSecondTypeDeatilList) do
			v2.value = v2.default_value;
		end
	end
	-- log_tree("BP_ARRAY_RoomCreateSecondTypeList = ", BP_ARRAY_RoomCreateSecondTypeList);

	LuaClassObj.HandleUIMessage(bp_room_create, "ResetAdvancedParaItems");
end

--设置重置按钮/保存设置按钮Enable
function EventSetResetAndSaveBtnEnable()
	LuaClassObj.HandleUIMessageNoFetch(bp_room_create, "SetResetAndSaveBtnEnable");
end

--提示当前模式不支持调整参数
function EventAdjustParaDisableOnThisMode()
	DataMgr.ShowNoticeByID(117089);
end

--提示非房主不能修改参数
function EventAdjustParaOnlyRoomMaster()
	DataMgr.ShowNoticeByID(110098);
end

--提示房间内不能修改参数
function EventAdjustParaDisableInRoom()
	DataMgr.ShowNoticeByID(117091);
end

--设置保存设置按钮Enable
function EventSetSaveBtnEnable()
	LuaClassObj.HandleUIMessageNoFetch(bp_room_create, "SetSaveBtnEnable");
end

--点击模式
function EventClickMode()
	if BP_IsCreateRoom == false then
		if BP_CreateRoom_IsRoomMaster == true then
			--提示房间内不能修改参数
			DataMgr.ShowNoticeByID(117091);
		else
			--提示非房主不能修改参数
			DataMgr.ShowNoticeByID(110098);
		end
		return;
	end
	--RoomModeSelectUI.ShowUI();
end

--选择地图
function EventSelectMap()
	log("BP_CreateRoom_SelectedMapName = "..BP_CreateRoom_SelectedMapName);
	local table_id = 0;
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeName == BP_CreateRoom_RoomModeName and v.MapName == BP_CreateRoom_SelectedMapName and v.PlayMethod == BP_CreateRoom_PlayMethod then
			table_id = v.ID;
		end
	end
	BP_CreateRoom_SelectedMapName = "";
	RoomCreateUI.SetAllParameterInitInfo(table_id);
	if RoomCreateUI.IsSameRoomTableItem == false then
		LuaClassObj.HandleUIMessage(bp_room_create, "SetModeRelativeParm");
	end
end

--选择玩法
function EventSelectPlayMethod()
	log("BP_CreateRoom_SelectedPlayMethod = "..BP_CreateRoom_SelectedPlayMethod);
	local table_id = 0;
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeName == BP_CreateRoom_RoomModeName and v.MapName == BP_CreateRoom_MapName and v.PlayMethod == BP_CreateRoom_SelectedPlayMethod then
			table_id = v.ID;
		end
	end
	BP_CreateRoom_SelectedPlayMethod = "";
	RoomCreateUI.SetAllParameterInitInfo(table_id);
	if RoomCreateUI.IsSameRoomTableItem == false then
		LuaClassObj.HandleUIMessage(bp_room_create, "SetModeRelativeParm");
	end
end

--选择视角
function EventSelectPerspective()
	log("BP_CreateRoom_Perspective = "..BP_CreateRoom_Perspective);
	if BP_CreateRoom_Perspective == Client.GetTableData("LocalizeRes", "100053").TextValue then
		BP_CreateRoom_IsFPP = true;
	else
		BP_CreateRoom_IsFPP = false;
	end
	log("BP_CreateRoom_IsFPP = "..tostring(BP_CreateRoom_IsFPP));
end

--选择队伍模式
function EventSelectTeamMode()
	log("BP_CreateRoom_TeamModeName = "..BP_CreateRoom_TeamModeName);
	for k,v in pairs(RoomCreateUI.RoomModeTableWithVersion) do
		if v.ModeName == BP_CreateRoom_RoomModeName and v.MapName == BP_CreateRoom_MapName and v.PlayMethod == BP_CreateRoom_PlayMethod then
			if BP_CreateRoom_TeamModeName == Client.GetTableData("LocalizeRes", "993048").TextValue then
				BP_CreateRoom_TeamModeID = v.SoloModeID;
			elseif BP_CreateRoom_TeamModeName == Client.GetTableData("LocalizeRes", "993049").TextValue then
				BP_CreateRoom_TeamModeID = v.DoubleModeID;
			elseif BP_CreateRoom_TeamModeName == Client.GetTableData("LocalizeRes", "993050").TextValue then
				BP_CreateRoom_TeamModeID = v.QuaternaryModeID;
			else
				BP_CreateRoom_TeamModeID = 0;
			end
			break;
		end
	end
	log("BP_CreateRoom_TeamModeID = "..BP_CreateRoom_TeamModeID);
end

--选择天气模式
function EventSelectWeatherMode()
	log("BP_CreateRoom_SelectedWeatherName = "..BP_CreateRoom_SelectedWeatherName);
	if BP_CreateRoom_SelectedWeatherName ~= BP_CreateRoom_WeatherModeName then
		-- log("1111111111111111111111111111111")
		BP_CreateRoom_WeatherModeName = BP_CreateRoom_SelectedWeatherName;
		for i=1,#BP_ARRAY_RoomCreateWeatherModeCNList do
			if BP_ARRAY_RoomCreateWeatherModeCNList[i] == BP_CreateRoom_SelectedWeatherName then
				BP_CreateRoom_WeatherModeID = BP_ARRAY_RoomCreateWeatherModeIDList[i];
				BP_CreateRoom_WeatherModeEN = BP_ARRAY_RoomCreateWeatherModeENList[i];
				BP_CreateRoom_CurCustomNum = BP_ARRAY_RoomCreateCustomNumList[i];
				RoomCreateUI.SetDropParaInfo();
				BP_CreateRoom_NeedLoadAdvPara = true;
				break;
			end
		end
	else
		-- log("2222222222222222222222222222222")
	end
	BP_CreateRoom_SelectedWeatherName = "";
	log("BP_CreateRoom_WeatherModeName = "..BP_CreateRoom_WeatherModeName);
	log("BP_CreateRoom_WeatherModeID = "..BP_CreateRoom_WeatherModeID);
	log("BP_CreateRoom_WeatherModeEN = "..BP_CreateRoom_WeatherModeEN);
	log("BP_CreateRoom_CurCustomNum = "..BP_CreateRoom_CurCustomNum);
	log("BP_CreateRoom_NeedLoadAdvPara = "..tostring(BP_CreateRoom_NeedLoadAdvPara));
end

--刷新当前模式房卡信息
function EventRefreshCurRoomCardInfo()
	--RoomCreateUI.UpdateCurModeRoomCardInfo();
	LuaClassObj.HandleUIMessage(bp_room_create, "RefreshCurRoomCardInfo");
end