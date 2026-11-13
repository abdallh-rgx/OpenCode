--[[
	组队招募 2017-12-12
--]]

RecruitUI = RecruitUI or {

}

--UI是否打开
BP_IsUIShow = false;

--世界招募
BP_WorldRecruit = true;

--好友招募
BP_FrientRecruit = true;

--频道招募
BP_ChannelRecruit = true;

--语种频道招募
BP_LocalLanguageRecruit = true;


--模式字符串
BP_ModelStr = "";

--队伍人数字符串1/2
BP_ModelPLayCountStr = "";

--文字信息
BP_SendMessage = "";

BP_ChatannelRoomID = 0;
BP_ChannelName = "";


BP_ARRAY_PerspectiveList = {
	"";
}

BP_ARRAY_TypeModelList = {
	"";
}

BP_ARRAY_MapJdList = { -- 经典模式地图
	"";
}

BP_ARRAY_MapYlList = {	-- 娱乐模式地图
	"";
}

BP_ARRAY_MapHdList = {	-- 活动模式地图
	"";
};

MapJdDict = {};
MapYlDict = {};
MapHdDict = {};

-- 115 版本数据
ARRAY_MapJdList = {};
ARRAY_MapYlList = {};
ARRAY_MapHdList = {};


BP_ARRAY_VoiceTypeList = {
	"";
}

BP_ARRAY_PosList = { -- 招募位置
	0,
}

BP_PerspectiveIndex = 1;
BP_TypeModeIndex = 0;
BP_MapName = "";
BP_VoiceIndex = 1;

--自己的UID
MySelfUID = "";

--是否满员
IsFull = false;

local ENUM_MAP_TYPE = {
	MAP_JD = 0,
	MAP_YL = 1,
	MAP_HD = 2,
}

function bp_recruit_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_recruit,
			{
				{Path="/Game/UMG/UI_Logic/Recruit/RecruitLogic_BP.RecruitLogic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RECRUIT_ZORDER},
			},
			{"Lobby"},
			false,
			bp_recruit_OnModeSwitched ~= nil,
			true

	);
end

function RecruitUI.InitPerspectiveList()
	BP_ARRAY_PerspectiveList = {};
	for id=100053,100054 do
		local data = Client.GetTableData("LocalizeRes",id);
		table.insert(BP_ARRAY_PerspectiveList, data.TextValue);
	end
end

function RecruitUI.TypeModelList()
	BP_ARRAY_TypeModelList = {};
	for id=100048,100049 do
		local data = Client.GetTableData("LocalizeRes",id);
		table.insert(BP_ARRAY_TypeModelList, data.TextValue);
	end
	data = Client.GetTableData("LocalizeRes",6885);
	table.insert(BP_ARRAY_TypeModelList, data.TextValue);
end

function RecruitUI.MapIdList()
	BP_ARRAY_MapJdList = {};
	BP_ARRAY_MapYlList = {};
	BP_ARRAY_MapHdList = {};
	
	for k,modes in pairs(TeamUpSystem.ModeInfoList) do
		local matchMode = Client.GetTableData("MatchModeTable", k);
		if nil ~= matchMode and  matchMode.MaxTeamPlayerNum == 4 then
			if modes.model_type == 1 then		-- 经典
				for id,mode in pairs(modes.mode_group) do
					local infoConfig = Client.GetTableData("ModeTeamTable", id);
					local mapName = DataMgr.GetMsgByID(tonumber(infoConfig.mapName));
					local map = {["name"] = mapName, ["pve_level"] = mode.need_pve_level, ["level"] = mode.need_level};
					MapJdDict[id] = map;
					if mode.is_default == 1 then
						table.insert(BP_ARRAY_MapJdList, mapName);
					end
				end
			end
			if modes.model_type == 2 then		-- 娱乐
				for id,mode in pairs(modes.mode_group) do
					local infoConfig = Client.GetTableData("ModeTeamTable", id);
					local mapName = DataMgr.GetMsgByID(tonumber(infoConfig.mapName));
					local map = {["name"] = mapName, ["pve_level"] = mode.need_pve_level, ["level"] = mode.need_level};
					MapYlDict[id] = map;
					if mode.is_default == 1 then
						table.insert(BP_ARRAY_MapYlList, mapName);
					end
				end
			end
			if modes.model_type == 4 then		-- 活动
				for id,mode in pairs(modes.mode_group) do
					local infoConfig = Client.GetTableData("ModeTeamTable", id);
					local mapName = DataMgr.GetMsgByID(tonumber(infoConfig.mapName));
					local map = {["name"] = mapName, ["pve_level"] = mode.need_pve_level, ["level"] = mode.need_level};
					MapHdDict[id] = map;
					if mode.is_default == 1 then
						table.insert(BP_ARRAY_MapHdList, mapName);
					end
				end
			end			
		end	
	end
	
	RecruitUI.CreateOldData();
end

-- 兼容115的数据
function RecruitUI.CreateOldData()
	-- 115 版本数据
	ARRAY_MapJdList = {};
	ARRAY_MapYlList = {};
	ARRAY_MapHdList = {};

	for id=500001,500002 do
		local data = Client.GetTableData("LocalizeRes",id);
		table.insert(ARRAY_MapJdList, data.TextValue);
	end
	local data1 = Client.GetTableData("LocalizeRes",500065);
	table.insert(ARRAY_MapJdList, data1.TextValue);
	data1 = Client.GetTableData("LocalizeRes",500069);
	table.insert(ARRAY_MapJdList, data1.TextValue);

	--刺激对决
	local data = Client.GetTableData("LocalizeRes",500057);
	if TeamUpSystem.ModeInfoList[203] ~= nil  and TeamUpSystem.ModeInfoList[203]["mode_group"] ~= nil and TeamUpSystem.ModeInfoList[203]["mode_group"][57] ~= nil then
		table.insert(ARRAY_MapYlList, data.TextValue);
	end

	--极速战场
	data = Client.GetTableData("LocalizeRes",500021);
	if TeamUpSystem.ModeInfoList[203] ~= nil  and TeamUpSystem.ModeInfoList[203]["mode_group"] ~= nil and TeamUpSystem.ModeInfoList[203]["mode_group"][36] ~= nil then
		table.insert(ARRAY_MapYlList, data.TextValue);
	end

	--狙击特训
	data = Client.GetTableData("LocalizeRes",500022);
	if TeamUpSystem.ModeInfoList[203] ~= nil  and TeamUpSystem.ModeInfoList[203]["mode_group"] ~= nil and TeamUpSystem.ModeInfoList[203]["mode_group"][39] ~= nil then
		table.insert(ARRAY_MapYlList, data.TextValue);
	end
	--战争模式	
	data = Client.GetTableData("LocalizeRes",500054);
	if TeamUpSystem.ModeInfoList[203] ~= nil  and TeamUpSystem.ModeInfoList[203]["mode_group"] ~= nil and TeamUpSystem.ModeInfoList[203]["mode_group"][54] ~= nil then
		table.insert(ARRAY_MapYlList, data.TextValue);
	end

	--生化危机sunset
	data = Client.GetTableData("LocalizeRes",500072);
	if TeamUpSystem.ModeInfoList[12003] ~= nil  and TeamUpSystem.ModeInfoList[12003]["mode_group"] ~= nil and TeamUpSystem.ModeInfoList[12003]["mode_group"][12003] ~= nil then
		table.insert(ARRAY_MapHdList, data.TextValue);
	end

	--破晓生还
	data = Client.GetTableData("LocalizeRes",500076);
	if TeamUpSystem.ModeInfoList[12003] ~= nil  and TeamUpSystem.ModeInfoList[12003]["mode_group"] ~= nil and TeamUpSystem.ModeInfoList[12003]["mode_group"][12011] ~= nil then
		table.insert(ARRAY_MapHdList, data.TextValue);
	end

	--多队生存
	data = Client.GetTableData("LocalizeRes",500077);
	if TeamUpSystem.ModeInfoList[12003] ~= nil  and TeamUpSystem.ModeInfoList[12003]["mode_group"] ~= nil and TeamUpSystem.ModeInfoList[12003]["mode_group"][12012] ~= nil then
		table.insert(ARRAY_MapHdList, data.TextValue);
	end
end

function RecruitUI.AdjustMapNameList(dict, mapList)
	for k,v in pairs(dict)do
		table.insert(mapList,k)
	end
end

function RecruitUI.VoiceTypeList()
	BP_ARRAY_VoiceTypeList = {};
	for id=4717,4719 do
		local data = Client.GetTableData("LocalizeRes",id);
		table.insert(BP_ARRAY_VoiceTypeList, data.TextValue);
	end
end

function RecruitUI.InitSelectData()
	RecruitUI.InitPerspectiveList();
	RecruitUI.TypeModelList();
	RecruitUI.MapIdList();
	RecruitUI.VoiceTypeList();
end

--初始化
function RecruitUI.InitData()
	RecruitUI.InitSelectData();
	--取队伍信息，初始化 TeamUpSystem.TeamInfo
	local curSelectMode =  TeamUpModelUI.GetCurSelectModel();
	local modleId = 101;
	if curSelectMode ~=nil then
		modleId = curSelectMode.model_id;
	end

	local modelConfig = Client.GetTableData("MatchModeTable", modleId);
	local playerNum = 1;
	if modelConfig ~= nil then
		playerNum = modelConfig.MaxTeamPlayerNum;
	end

	local curPlayer = TeamUpSystem.TeamInfo.player_count;
	IsFull = false;


	--增加第一人称模式
	local curModel = TeamUpModelUI.GetCurSelectModel();
	--[[
		100054 第三人称
		100053 第一人称
		BP_STRUCT_CurSelectedModelInfo
		├─ model_name_hide: "经典模式"
		├─ model_id: 103
		├─ is_selected: true
		├─ model_name: "经典模式"
		├─ perspective_type: 100054
		├─ is_open: true
		├─ model_type: 1
		├─ is_lock: false
		├─ player_num: 4
		├─ seq: 3
		├─ perspective_name: "第三人称"
		├─ model_sub_name_type: 0
		├─ model_sub_name: "第三人称"
		└─ player_num_name: "四人"
	]]
	local firstMod = DataMgr.GetMsgByID(117087); --经典
	local firstPersonNum = DataMgr.GetMsgByID(117086); --四人

	local switch =
	{
		[1] = function()
			--BP_ModelStr = "四人模式";
			BP_ModelStr = Client.GetTableData("LocalizeRes", "110051").TextValue;
			BP_ModelPLayCountStr = tostring(curPlayer).."/4";
			IsFull = (curPlayer >= 4) or false;
			--[[	
			if curModel.perspective_type == 100053 then
				BP_ModelStr =  firstMod.."("..tostring(curModel.perspective_name)..")-"..firstPersonNum;
			end
			]]
		end,
		[2] = function()
			--BP_ModelStr = "四人模式";
			BP_ModelStr = Client.GetTableData("LocalizeRes", "110051").TextValue;
			BP_ModelPLayCountStr = tostring(curPlayer).."/4";
			IsFull = (curPlayer >= 4) or false;
			--[[
			if curModel.perspective_type == 100053 then
				BP_ModelStr =  firstMod.."("..tostring(curModel.perspective_name)..")-"..firstPersonNum;
			end
			]]
		end,
		[4] = function()
			--BP_ModelStr = "四人模式";
			BP_ModelStr = Client.GetTableData("LocalizeRes", "110051").TextValue;
			BP_ModelPLayCountStr = tostring(curPlayer).."/4";
			IsFull = (curPlayer >= 4) or false;
			--[[
			if curModel.perspective_type == 100053 then
				BP_ModelStr =  firstMod.."("..tostring(curModel.perspective_name)..")-"..firstPersonNum;
			end
			]]
		end,
		[1000] = function()
			--Default	
			BP_ModelStr = "";
			BP_ModelPLayCountStr = "";
		end,
	}
	local exculSwitch = switch[playerNum];
	if exculSwitch then
		exculSwitch();
	else
		switch[100]();
	end
	MySelfUID = TeamUp_My_User_ID;

	BP_ChatannelRoomID = BP_ChatRoom_MyRoomID;
	if tonumber(BP_ChatannelRoomID) > 0 then
		BP_ChannelName = tostring(BP_ChatRoom_MyRoomName);
	else
		BP_ChannelRecruit = false;
		BP_ChannelName = DataMgr.GetMsgByID(110018); -- "暂未进入聊天室";		
	end
end

--显示UI
function RecruitUI.ShowUI()
	LuaClassObj.HandleDynamicCreation(bp_recruit);

	--同步下组队限时开放
	TeamUpSystem.on_mode_shield_req();

	local isroom = RoomWaitingUI.IsInRoom();
	if isroom == true then
		--DataMgr.ShowNoticeByString("房间中不能招募队员");
		DataMgr.ShowNoticeByString(Client.GetTableData("LocalizeRes", "301294").TextValue);
		return;
	end

	--TODO,组合数据
	RecruitUI.InitData();
	if TeamUp_Team_Type == TEAMUP_TEAM_TYPE_SOLO then
		--DataMgr.ShowNoticeByString("单人模式下不能招募队员");
		--DataMgr.ShowNoticeByID(110041);
		--return;
	end

	if IsFull == true then
		--DataMgr.ShowNoticeByString("您的队伍已满");
		DataMgr.ShowNoticeByID(110019);
		return;
	end

	BP_SendMessage = DataMgr.GetMsgByID(110040);--"车队发车，速来加入!";

	--蓝图层显示UI
	BP_IsUIShow = true;
	LuaClassObj.HandleUIMessage(bp_recruit, "UIShow");
	UIManager.Show(eUIType.eChatRecruit);
end

function RecruitUI.refreshUI( )
	if BP_IsUIShow  then -- 当地图数据刷新时，娱乐模式下刷新界面
		LuaClassObj.HandleUIMessage(bp_recruit, "UpdateMapList");
	end
end

function EventRecruit_Push()
	--蓝图变量同步给lua
end

function EventFetchInfo()
	--lua变量同步蓝图
end

--关闭UI
function EventHideUI()
	BP_IsUIShow = false;
	UIManager.Hide(eUIType.eChatRecruit);
end

--发送
function EventSendMessage()
	log("BP_MapName.." .. BP_MapName);

	if BP_MapName == "" then
		DataMgr.ShowNoticeByID(4723);
		return;
	end
	--地图
	BP_MapName = string.gsub(BP_MapName, ",", "", 1);
	arrMapName = string.split(BP_MapName, ",");
	
	local mapArr = {};	
	if BP_TypeModeIndex == 0 then
		mapArr = RecruitUI.PutMaps(BP_ARRAY_MapJdList, arrMapName, MapJdDict)
	elseif BP_TypeModeIndex == 1 then
		mapArr = RecruitUI.PutMaps(BP_ARRAY_MapYlList, arrMapName, MapYlDict)
	elseif BP_TypeModeIndex == 2 then
		mapArr = RecruitUI.PutMaps(BP_ARRAY_MapHdList, arrMapName, MapHdDict)
	end

	for i = #arrMapName + 1, 4 do
		arrMapName[i] = 0;
	end
	local content = FuncUtil.InCodeTeamRecruitMsg(BP_TypeModeIndex, BP_PerspectiveIndex, BP_VoiceIndex, TeamUpSystem.TeamInfo.player_count, arrMapName, BP_ARRAY_PosList);
	
	TeamUpSystem.team_recruit(content,false,false,false,false,false,true,BP_VoiceIndex, mapArr);
	LuaClassObj.HandleUIMessage(bp_recruit, "UIHide");
	UIManager.Hide(eUIType.eChatRecruit);
end

function RecruitUI.PutMaps(mapNameShowList, mapIndex, mapDict)
	local mapArr = {};
	for i=1, 4 do
		local hasInsert = false;
		if #mapIndex >= i then
			local mapName = mapNameShowList[mapIndex[i]+1];
			for k,v in pairs(mapDict) do
				if v.name == mapName then
					table.insert(mapArr, k);
					hasInsert = true;
					break;
				end
			end			
		end
		if hasInsert == false then
			table.insert(mapArr ,0)
		end
	end
	return mapArr;
end

function EventPosSelectOver( )
	DataMgr.ShowNoticeByID(4976);
end
