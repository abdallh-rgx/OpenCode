TeamUpMatchInfoUI = TeamUpMatchInfoUI or
{
	thirdPersonPerspective = 100054,
	firstPersonPerspective = 100053,
	isShowing = false,
	mapLimitLeftTimeRefreshTimer = nil,

	-- 保存地图的选中状态
	selectedMapList = {},

	bHaveRetriedInit = false,       -- 是否已尝试过重新初始化
	bInitDownloadResult = false,
	initErrorCode = 0,
	downloadState_notStart = 0,
	downloadState_downloading = 1,
	downloadState_pause = 2,
	downloadState_have = 3,			-- 需后台同步修改
	downloadState_error = 4,
	needDownloadMapList = {
		PUBG_Desert = {event = 10, filepre = "map_desert_", corrupted = false},
		PUBG_Savage_Main = {event = 20, filepre = "map_savagemain_", corrupted = false},
		DihorOtok_Main = {event = 30, filepre = "map_dihorotok_", corrupted = false},
	},
	mapList = {},                   -- 避免针对同一个文件重复调用Client.IsFileReady（底层函数CPufferMgrImpInter::GetFileId）
	mapInfoList = {},
	modeInfoList = {},              -- modeID对应的地图，可能会有多个
	tryInitializeInfo = {},         -- 初始化失败后，点击下载会再次尝试初始化，并记下启动下载的文件

	interval = 3,
	mapEvent_progress = 0,
    mapEvent_start = 1,
    mapEvent_time = 2,
    mapEvent_done = 3,
    mapEvent_error = 4,
    mapEvent_pause = 5,
    mapEvent_continue = 6,
    mapEvent_autoPause = 7,
}

-- 选服设置，等同于BP_STRUCT_ChooseZoneInfo
BP_STRUCT_MatchInfo_ChooseZoneInfo =
{
	zone_id = 0,
	tpingsvr_ip = "",
	tpingsvr_port = "",
};
BP_ARRAY_MatchInfo_ChooseZoneList =
{
	BP_STRUCT_MatchInfo_ChooseZoneInfo = _G.BP_STRUCT_MatchInfo_ChooseZoneInfo,
};

-- 当前显示的地图列表，与地图列表中保持一致
BP_STRUCT_TeamUpMatchMapInfo =
{
	map_id = 0,
	map_name = "",
	is_selected = true,	-- 当前是否是选中状态
	icon_path = "",
	tips = "",
	size_type = 0,
	forbid_tips = "",
	level_limit = "5级开放",
	sub_info = "",
	can_select = true,	-- 当前是否可以被选择
	model_sub_name = "第一人称",  -- 模式子说明  第一人称/第三人称
	model_sub_name_type = 0,  -- 模式子说明样式
	time_limit_str = "",	-- 限时开启提示
	download_state = 0,     -- 地图下载状态
	download_percent = 0,   -- 地图下载百分比
	map_file_name = "",     -- 地图文件名称
	map_file_size = 0,      -- 地图文件大小
	corrupted = false,      -- 地图文件是否已损坏
	has_skill = false;		-- 显示副本buff技能
	show_skill_effect = false;
}

BP_ARRAY_TeamUpMatchMapInfoList = 
{
	BP_STRUCT_TeamUpMatchMapInfo = _G.BP_STRUCT_TeamUpMatchMapInfo,
};

-- 当前选择的zone_id
BP_TeamUpMatchInfo_ChooseZoneId = 0;

-- 当前点击的地图id
BP_TeamUpMatchInfo_CurClickMapId = 0;

-- 当前点击的地图的选中状态
BP_TeamUpMatchInfo_CurClickMapSelected = true;

-- 是否选择第三人称
-- 100053：经典四人第一人称，100054：经典四人第三人称
BP_TeamUpMatchInfo_IsThirdPerson = true;

BP_TeamUpMatchInfo_MapModeType = 1;		-- 地图模式类型

TeamUpMatchInfo_ClassicMapMode = 1;		-- 经典模式		
TeamUpMatchInfo_ArcadeMapMode = 2;		-- 娱乐模式
TeamUpMatchInfo_FPPMapMode = 3;			-- 第一人称模式
TeamUpMatchInfo_ActivityMapMode = 4;	-- 活动模式

-- 选择的玩家人数
BP_TeamUpMatchInfo_SelectPlayerNum = 1;

-- 当前玩家人数
BP_TeamUpMatchInfo_CurrentPlayerNum = 1;

-- 是否自动匹配
BP_TeamUpMatchInfo_AutoMatch = true;

BP_TeamUpMatchInfo_CurDownloadMapFileName = "";
BP_TeamUpMatchInfo_CurDownloadMapPosterPath = "";

-- 万圣节活动开关
BP_TeamUpHalloweenSwitch = false

-- 万圣节皮肤
BP_TeamUp_Cur_Lobby_Skin_Id = 0;

-- 万圣节活动海岛图，这里是模式匹配表中子模式的id，也就是map_id
BP_ARRAY_TeamUPHalloweenMapIdList = {
	1, 2, 3, 46, 47, 48
}

--是否开启同语言匹配
BP_TeamUpMatchInfo_SameLanguage = false;

-- 存档决定是否勾选checkbox可以打开语言选择面板
BP_NoPrompt_LanguageState = false;

MAP_DOWNLOAD_INCREMENTAL_VERSION = true;

-- 通过服务器开关控制是否显示相同语言匹配
BP_TeamUpMatchInfo_SameLanguage_Open = false;

BP_TeamUpMatchInfo_HasActivityMode = false;

BP_TeamUpMatchInfo_Show_Skill_Effect = false;

-- 当前点击地图提示的地图id
BP_TeamUpMatchInfo_Current_ClickTips_MapId = 0;

-- 注册面板
function bp_teamup_match_info_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_teamup_match_info,
        {
			{Path="/Game/UMG/UI_Logic/Lobby/Lobby_SelectMatchInfo_Logic_BP.Lobby_SelectMatchInfo_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_SELECTMATCHINFO_ZORDER},
		},
		{"Lobby"},
		false,
		bp_teamup_match_info_OnModeSwitched ~= nil
	);
	EventSystem:registEvent(EVENTTYPE_LOBBY_SKIN, EVENTID_LOBBY_SKIN_CHANGE_SEC, TeamUpMatchInfoUI.OnSetLobbySkinId);
end


function TeamUpMatchInfoUI.Show()
	TeamUpMatchInfoUI.isShowing = true;
	TeamUpMatchInfoUI.StartTimer();
	TeamUpMatchInfoUI.UpdateHalloweenSwitch();
	if #BP_ARRAY_LanguageNameList <= 1 then			-- 如果没有拉到语言信息，拉取第一第二语言
		LobbyChatSystem.topic_fetch_lang_list_req();	
	end	

	--同语言设置
	if nil ~= DataMgr.MatchLanguage then
		BP_TeamUpMatchInfo_SameLanguage = DataMgr.MatchLanguage.only_match;
	end

	if LobbyUI:CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MATCHINFO_SAME_LANGUAGE, false) then
        BP_TeamUpMatchInfo_SameLanguage_Open = true;
	else
		BP_TeamUpMatchInfo_SameLanguage_Open = false;
	end

	BP_TeamUpMatchInfo_HasActivityMode = TeamUpMatchInfoUI.HasActivityModeInfo();
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UIShow");
	TeamUpMatchInfoUI.SetDefaultInfo();
	TeamUpMatchInfoUI.UpdateSelectedZoneId();
	UIManager.Show(eUIType.eTemaupMatchInfo);
	
	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		BP_Back_ChooseZoneId = 1
		BP_TeamUpMatchInfo_ChooseZoneId = 1
		TeamUpSystem.on_select_zone_req(1);
	end
	TeamUpMatchInfoUI.UpdateNewMapSkillInActivity()
end

function TeamUpMatchInfoUI.OnSetLobbySkinId(eventType, eventID, skinId)
	local bUIAutoTest = Client.IsUIAutoTest();
	if bUIAutoTest then
		skinId = 10004
	end
	
	BP_TeamUp_Cur_Lobby_Skin_Id = skinId;
    LuaClassObj.HandleUIMessageNoFetch(bp_teamup_match_info, "UpdateLobbySkin");
end

function TeamUpMatchInfoUI.Hide()
	TeamUpMatchInfoUI.isShowing = false;
	TeamUpMatchInfoUI.StopTimer();
	TeamUpMapTipsUI.ClosePanel();
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UIHide");
end

function TeamUpMatchInfoUI.StartTimer()
	TeamUpMatchInfoUI.StopTimer();

	TeamUpMatchInfoUI.mapLimitLeftTimeRefreshTimer = Timer.InsertTimer(60, TeamUpMatchInfoUI.UpdateMapLimitInfo, true);
end

function TeamUpMatchInfoUI.StopTimer()
	if TeamUpMatchInfoUI.mapLimitLeftTimeRefreshTimer then
		Timer.RemoveTimer(TeamUpMatchInfoUI.mapLimitLeftTimeRefreshTimer);
		TeamUpMatchInfoUI.mapLimitLeftTimeRefreshTimer = nil;
	end
end

function TeamUpMatchInfoUI.UpdateMapLimitInfo()
	TeamUpMatchInfoUI.ResetMapList();
	
	-- reset map 会把地图的tip给关闭，所以在这里重现打开
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "ShowMapTip");
end

function TeamUpMatchInfoUI.UpdateCurTeamPlayerNum(curPlayerNum)
	BP_TeamUpMatchInfo_CurrentPlayerNum = curPlayerNum;
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateCurrentPlayerNum");
end

-- 根据条件判断是否显示新手引导
local function ShowNewbieGuide()
	local newbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_LANG, 1);
  	if newbie then
    	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "ShowNewbieGuide");
  	end
end

-- 根据条件判断是否隐藏新手引导
--@sync 是否向服务器同步
local function HideNewbieGuide(sync)
	local newbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_LANG, 1);
	if newbie then
		if sync then
			DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_MATCH_LANG, 1);
		end
    	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "HideNewbieGuide");
  	end
end

-- 蓝图调用,显示新手引导
function  EventTeamUpMatchInfoShowNewbieGuide()
	ShowNewbieGuide();
end

function TeamUpMatchInfoUI.SetDefaultInfo()
	log_tree("BP_TeamUpModel_Perspective", BP_TeamUpModel_Perspective);
	if BP_TeamUpModel_Perspective == TeamUpMatchInfoUI.firstPersonPerspective then
		BP_TeamUpMatchInfo_IsThirdPerson = false;
	else
		BP_TeamUpMatchInfo_IsThirdPerson = true;
	end
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateIsThirdPerson");
	
	BP_TeamUpMatchInfo_MapModeType = BP_TeamUpModel_SelectModelType;
	
	LuaClassObj.HandleUIMessageNoFetch(bp_teamup_match_info, "UpdateModel");

	BP_TeamUpMatchInfo_AutoMatch = BP_TeamUpModel_AutoMatch == 1;
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateAutoMatch");

	BP_TeamUpMatchInfo_SelectPlayerNum = BP_TeamUpModel_PlayerNum;
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdatePlayerNum");

	-- 刷新当前模式
	--TeamUpModelUI.SetCurSelectedModel(TeamUpSystem.TeamInfo.team_type);
	TeamUpMatchInfoUI.UpdateMapList(BP_STRUCT_CurSelectedModelInfo.model_id);
	TeamUpMatchInfoUI.RefreshSelectedMapIndexList();
end

function TeamUpMatchInfoUI.UpdateMapList(curModelID, needResetSelectedMap, bUpdate)
	log("[HHF]TeamUpMatchInfoUI.UpdateMapList, curModelID = " .. tostring(curModelID) .. ", needResetSelectedMap = " .. tostring(needResetSelectedMap) .. ", bUpdate = " .. tostring(bUpdate));
	-- 获取当前模式对应的地图数据
	local curModelMapInfo = nil;
	local canSelect = true;
	-- local curModelID = BP_STRUCT_CurSelectedModelInfo.model_id;

	if TeamUpSystem.IsTeamLeader() then
		for k,v in pairs(TeamUpSystem.ModeInfoList) do
			if k == curModelID then
				curModelMapInfo = v;
				break;
			end
		end
	else
		curModelMapInfo = TeamUpSystem.TeammateModeInfo;
		canSelect = false;
	end

	if curModelMapInfo then
		BP_ARRAY_TeamUpMatchMapInfoList = {};

		local infoConfig = {};
		local mapName = "";
		local subMapName = "";
		local tips = "";
		local forbidTips = "";
		local levelLimit = "";
		local subInfo = "";
		local modelSubName = "";
		local timeLimitStr = "";
		local isSelect = false;
		
		local isOpen = false;
		local hasPreview = false;
		local previewStr = "";
		
		log_tree("curModelMapInfo.mode_group ",curModelMapInfo.mode_group);
		local infolen = 0;
		local myRating = TeamUpSystem.GetRatingByModelId(curModelID);
		if not TeamUpSystem.IsTeamLeader() then
			-- 队友rating分不做限制
			myRating = 9999999;
		end
		
		-- 根据地图数量设置面板中item的size
		for k,v in pairs(curModelMapInfo.mode_group) do
			isOpen, hasPreview, previewStr = TeamUpSystem.IsOnTime(v);
			log("curModelMapInfo.mode_group group_id:"..v.group_id..", isOpen:"..tostring(isOpen)..", hasPreview:"..tostring(hasPreview)..", previewStr:"..previewStr);
			if isOpen or (not isOpen and hasPreview) then
				if myRating >= v.rating_limit then
					infolen = infolen + 1;
				end
			end
		end
		log("infolen "..infolen);
		local sizeType = 0;
		if infolen > 2 then
			sizeType = 1;
		end

		for k,v in pairs(curModelMapInfo.mode_group) do 
			isOpen, hasPreview, previewStr = TeamUpSystem.IsOnTime(v);
			if myRating >= v.rating_limit and (isOpen or (not isOpen and hasPreview)) then
				infoConfig = Client.GetTableData("ModeTeamTable", k);
				if infoConfig then
					mapName = DataMgr.GetMsgByID(tonumber(infoConfig.mapName));
					if infoConfig.Subtitle ~= "" then
						subMapName = DataMgr.GetMsgByID(tonumber(infoConfig.Subtitle));
					end
					-- if subMapName ~= "" then
					-- 	mapName = mapName.."—"..subMapName;		
					-- end
					if infoConfig.mapTips ~= "" then
						tips = DataMgr.GetMsgByID(tonumber(infoConfig.mapTips));
					end
					if infoConfig.ForbidTips ~= "" then
						forbidTips = DataMgr.GetMsgByID(tonumber(infoConfig.ForbidTips));
					end
					if infoConfig.Introduce ~= "" then
						subInfo = DataMgr.GetMsgByID(tonumber(infoConfig.Introduce));
					end
					if infoConfig.LabelWords ~= 0 then
						modelSubName = DataMgr.GetMsgByID(infoConfig.LabelWords);
					end
					isSelect = v.is_default == 1;
								
					local pvpLimit = false;
					if v.need_level > DataMgr.roleData.level then
						--levelLimit = tostring(v.need_level).."级开放";
						levelLimit = FuncUtil.LocalizeResFormat("500040", v.need_level);
						pvpLimit = true;
					else
						levelLimit = "";
					end

					if v.need_pve_level and v.need_pve_level > 1 and v.need_pve_level > DataMgr.roleData.pve_level then			
						--- 冒险等级{0}级开发
						local pve_limit = FuncUtil.LocalizeResFormat("6829", v.need_pve_level);
						if pvpLimit then
							levelLimit = levelLimit.."\n"..pve_limit;
						else
							levelLimit = pve_limit;
						end
					end

					if not isOpen and hasPreview then
						timeLimitStr = previewStr;
					else
						timeLimitStr = "";
					end

					local showNewEffect = false;
					local hasSkill = false;
					if v.skills and #v.skills > 0 then
						hasSkill = true;
						local mapSkillInfo = TeamUpSystem.GetMapSkillInfo(tostring(k));
						if mapSkillInfo and (mapSkillInfo["count"] or 0) ==  #v.skills then
							local sameSkill = true;
							for index,skillId in pairs(v.skills) do
								if mapSkillInfo[tostring(skillId)] == nil then
									sameSkill = false;
								end
							end
							if false == sameSkill then
								showNewEffect = true;
							end
						else
							showNewEffect = true;
						end
					end
					
					local result = TeamUpMatchInfoUI.GetMapStateByModeID(k);
					isSelect = isSelect and result.downloadstate == TeamUpMatchInfoUI.downloadState_have;
					log("[HHF]TeamUpMatchInfoUI.UpdateMapList, modeid = " .. k .. ", mapfilename = " .. result.mapfilename .. ", size = " .. tostring(result.mapfilesize/1048576) .. " MB, downloadstate = " .. result.downloadstate .. ", percent = " .. result.downloadpercent);
									
					table.insert(BP_ARRAY_TeamUpMatchMapInfoList, 
					{
						map_id = k,
						map_name = mapName,
						is_selected = isSelect,
						icon_path = infoConfig.mapPath,
						tips = tips,
						size_type = sizeType,
						forbid_tips = forbidTips,
						level_limit = levelLimit,
						sub_info = subInfo,
						can_select = canSelect,
						model_sub_name = modelSubName,
						model_sub_name_type = infoConfig.LabelStyle,
						time_limit_str = timeLimitStr,
						download_state = result.downloadstate,
						download_percent = result.downloadpercent,
						map_file_name = result.mapfilename,
						map_file_size = result.mapfilesize,
						corrupted = result.corrupted,
						
						seq = infoConfig.Sort;
						has_skill = hasSkill;
						show_skill_effect = showNewEffect;
					});
				end
			end			
		end

		-- 排序
		table.sort(BP_ARRAY_TeamUpMatchMapInfoList, function (a, b)
			if a.time_limit_str == "" and b.time_limit_str ~= "" then
				return true;
			elseif a.time_limit_str ~= "" and b.time_limit_str == "" then
				return false;
			else
				if a.seq ~= b.seq then
					return a.seq < b.seq;
				else
					return false;
				end
			end
		end);

		if needResetSelectedMap then
			for i,v in ipairs(BP_ARRAY_TeamUpMatchMapInfoList) do
				v.is_selected = TeamUpMatchInfoUI.selectedMapList[i] == true;
				v.is_selected = v.is_selected and v.download_state == TeamUpMatchInfoUI.downloadState_have;
			end
		end
		--log_tree("[HHFTEST]TeamUpMatchInfoUI.UpdateMapList, BP_ARRAY_TeamUpMatchMapInfoList = ", BP_ARRAY_TeamUpMatchMapInfoList, "[HHFTEST]");
		if bUpdate then
			LuaClassObj.HandleUIMessage(bp_teamup_match_info, "OnUpdateDownloadProgress");
		else
			LuaClassObj.HandleUIMessage(bp_teamup_match_info, "CreateMapItems");
		end

		LuaClassObj.HandleUIMessageNoFetch(bp_teamup_match_info, "UpdateActivityTipsVisible");
	end
end

-- 点击地图item
function EventTeamUpMatchInfoClickMapItem_Push()
	if BP_TeamUpMatchInfo_CurClickMapSelected then
		BP_TeamUpMatchInfo_CurClickMapSelected = false;		
	else
		BP_TeamUpMatchInfo_CurClickMapSelected = true;
	end

	-- 更新当前地图数据
	for i,v in ipairs(BP_ARRAY_TeamUpMatchMapInfoList) do
		if v.map_id == BP_TeamUpMatchInfo_CurClickMapId then
			v.is_selected = BP_TeamUpMatchInfo_CurClickMapSelected;
			break;
		end
	end

	TeamUpMatchInfoUI.RefreshSelectedMapIndexList();

	--TeamUpMaplUI.curModelMapInfo = TeamUpSystem.UpdateModelMapInfo(TeamUpMaplUI.curModelId, BP_TeamUpMatchInfo_CurClickMapId, BP_TeamUpMatchInfo_CurClickMapSelected);
	--log_tree("TeamUpMaplUI.curModelMapInfo", TeamUpMaplUI.curModelMapInfo);
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateMapItemSelectStatus");
end

function TeamUpMatchInfoUI.ResetMapList(needResetSelectedMap, bUpdate)
	local modelInfo = TeamUpMatchInfoUI.GetCurrentModelInfo();
	if modelInfo then
		TeamUpMatchInfoUI.UpdateMapList(modelInfo.model_id, needResetSelectedMap, bUpdate);
	end
end

function TeamUpMatchInfoUI.SetCurrentModel(modelInfo)
	modelInfo.is_selected = true;

	BP_STRUCT_CurSelectedModelInfo = modelInfo;
	BP_TeamUpModel_SelectModelType = modelInfo.model_type;
	BP_TeamUpModel_PlayerNum = modelInfo.player_num;
	BP_TeamUpModel_Perspective = modelInfo.perspective_type;
	
	-- 更新当前选中的模式数据
	TeamUpModelUI.curSelectedModelType = BP_TeamUpModel_SelectModelType;
	TeamUpModelUI.curSelectedPlayerNum = BP_TeamUpModel_PlayerNum;
	TeamUpModelUI.curSelectedPerspective = BP_TeamUpModel_Perspective;
	
	log_tree("BP_STRUCT_CurSelectedModelInfo", BP_STRUCT_CurSelectedModelInfo);
	
	-- 保存地图模式
	for i,info in ipairs(BP_ARRAY_TeamUpMatchMapInfoList) do
		TeamUpSystem.UpdateModelMapInfo(modelInfo.model_id, info.map_id, info.is_selected);
	end

	-- 更新当前模式数据
	TeamUpModelUI.UpdateCurMapName();
	-- 刷新万圣节tip
	TeamUpModelUI.UpdateTip()
	-- 广播当前模式数据
	TeamUpSystem.team_change_type_request(modelInfo.model_id);
end

function TeamUpMatchInfoUI.GetCurrentModelInfo()
	local playerName = BP_TeamUpMatchInfo_SelectPlayerNum;
	local perspective = TeamUpMatchInfoUI.thirdPersonPerspective;
	
	if BP_TeamUpMatchInfo_IsThirdPerson then
		perspective = TeamUpMatchInfoUI.thirdPersonPerspective;
	else
		perspective = TeamUpMatchInfoUI.firstPersonPerspective;
	end
	
	for k,v in pairs(TeamUpModelUI.listAllModelInfo) do
		if v.model_type == BP_TeamUpMatchInfo_MapModeType and v.player_num == playerName and v.perspective_type == perspective then
			return v;
		end
	end

	return nil;
end

-- 判断是否有活动模式，如果没有活动模式,活动模式的按钮都不显示
function TeamUpMatchInfoUI.HasActivityModeInfo()
	for k,v in pairs(TeamUpModelUI.listAllModelInfo) do
		if v.model_type == TeamUpMatchInfo_ActivityMapMode then
			return true;
		end
	end
	return false;
end

function TeamUpMatchInfoUI.SaveInfo()
	-- 自动匹配
	if BP_TeamUpMatchInfo_AutoMatch then
		BP_TeamUpModel_AutoMatch = 1;
	else
		BP_TeamUpModel_AutoMatch = 0;
	end
	
	--更新自动匹配选项
	TeamUpSystem.team_change_fill_request(BP_TeamUpModel_AutoMatch);

	local modelInfo = TeamUpMatchInfoUI.GetCurrentModelInfo();
	if modelInfo then
		for k,v in pairs(TeamUpModelUI.listAllModelInfo) do
			v.is_selected = false;
		end
		TeamUpMatchInfoUI.SetCurrentModel(modelInfo);
	end
end

function TeamUpMatchInfoUI.UpdateSelectedZoneId()
	BP_TeamUpMatchInfo_ChooseZoneId = TeamUpSystem.ChooseZoneId;
	
	if TeamUpMatchInfoUI.isShowing then
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "RefreshSelectedZoneName");
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateSelectedZoneItem");
	end
end

function TeamUpMatchInfoUI.SelectPlayerNum(playerNum)
	if playerNum < BP_TeamUpMatchInfo_CurrentPlayerNum then
		DataMgr.ShowNoticeByID(110000);
	else
		BP_TeamUpMatchInfo_SelectPlayerNum = playerNum;
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdatePlayerNum");
		TeamUpMatchInfoUI.ResetMapList(true, true);
	end
end

function TeamUpMatchInfoUI.RefreshSelectedMapIndexList()
	TeamUpMatchInfoUI.selectedMapList = {};
	for i,info in ipairs(BP_ARRAY_TeamUpMatchMapInfoList) do
		if info.is_selected then
			TeamUpMatchInfoUI.selectedMapList[i] = true;
		end
	end
	log_tree("TeamUpMatchInfoUI.selectedMapList", TeamUpMatchInfoUI.selectedMapList);
end

-- bp click event
function EventTeamupMatchInfoClickOk_Push()
	-- 检查当前模式至少一个选中
	local selectedCount = 0;
	for i,v in ipairs(BP_ARRAY_TeamUpMatchMapInfoList) do
		if v.is_selected then
			selectedCount = selectedCount + 1;
		end
	end

	log("EventTeamUpMatchInfoClickMapItem_Push selectedCount:"..selectedCount);
	if selectedCount < 1 then
		local content = DataMgr.GetMsgByID(500044);
		PopUpNoticeUI.ShowNewNotice(content);
		return;
	end
	
	-- log_tree("BP_TeamUpMatchInfo_IsThirdPerson", BP_TeamUpMatchInfo_IsThirdPerson);
	-- log_tree("BP_TeamUpMatchInfo_SelectPlayerNum", BP_TeamUpMatchInfo_SelectPlayerNum);
	-- log_tree("BP_TeamUpMatchInfo_AutoMatch", BP_TeamUpMatchInfo_AutoMatch);
	
	TeamUpMatchInfoUI.SaveInfo();
	TeamUpMatchInfoUI.Hide();
end

-- 按钮关闭
function EventTeamupMatchInfoClickClose()
	TeamUpMatchInfoUI.Hide();
end

function EventTeamupMatchInfoClickRoom_Push()
	local isLock = TeamUpModelUI.CheckRoomLock();
	if isLock then
		return;
	end

	log("EventClickRoom_Push status:"..BP_TeamUpModel_AutoMatch);
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end
	
	if TeamUpSystem.TeamInfo and TeamUpSystem.TeamInfo.player_count and TeamUpSystem.TeamInfo.player_count > 1 then
		DataMgr.ShowNoticeByID(110002); --请先退出组队
		return;
	end
	
	RoomUI:Init();
	RoomSystem.Enter();
	ClientSendBAReport(BP_BA_SHARE_ROOMREFASH, 0);
	ClientSendBAReport(BP_BA_LOBBY_ROOM_PANEL, 0);
	
	TeamUpMatchInfoUI.Hide();
end

function EventTeamupMatchInfoClickTraining_Push()
	--log_tree("TeamUpSystem.TeamInfo", TeamUpSystem.TeamInfo);

	local isLock = TeamUpModelUI.CheckRoomLock();
	if isLock then
		return;
	end
	
	log("EventTeamupMatchInfoClickTraining_Push status:"..BP_TeamUpModel_AutoMatch..", playerNum:"..TeamUpSystem.TeamInfo.player_count);
	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end	
	
	if TeamUpSystem.TeamInfo.player_count > 1 then
		local content = Client.GetTableData("LocalizeRes", "4145").TextValue;
		PopUpNoticeUI.ShowNewNotice(content);
		return;
	end
		
	NetUtil.SendPkg("on_match_req", 301, 0, nil);
	TeamUpSystem.matchIsTrainingMode = true;
	--ConnectionWaitingUI:Show();
end

function EventTeamupMatchInfoClickTutorial_Push()
	log("EventTeamupMatchInfoClickTutorial_Push");

	NewteachingUI.Show()
	ClientSendBAReport(BP_BA_LOBBY_NEWERGUIDE_PANEL, 0);
end

-- zone选择
function EventTeamupMatchInfoClickZoneItem_Push()
	if not BP_Room_IsInRoom then
		TeamUpSystem.on_select_zone_req(BP_TeamUpMatchInfo_ChooseZoneId);
	end
end

-- 视角选择
function EventTeamupMatchInfoClickThirdPerson_Push()
	if not BP_TeamUpMatchInfo_IsThirdPerson then
		BP_TeamUpMatchInfo_IsThirdPerson = true;
		BP_TeamUpMatchInfo_MapModeType = TeamUpMatchInfo_ClassicMapMode;
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateIsThirdPerson");
		TeamUpMatchInfoUI.ResetMapList(false, true);
		TeamUpMapTipsUI.ClosePanel();
	end
end

function EventTeamupMatchInfoClickFirstPerson_Push()
	if BP_TeamUpMatchInfo_IsThirdPerson then
		EventTeamupMatchInfoClickClassic_Push();

		BP_TeamUpMatchInfo_IsThirdPerson = false;
		BP_TeamUpMatchInfo_MapModeType = TeamUpMatchInfo_FPPMapMode;
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateIsThirdPerson");
		TeamUpMatchInfoUI.ResetMapList(false, true);
		TeamUpMapTipsUI.ClosePanel();
	end
end

local function TameupMatchInfoIsMapModel(mapModle)
	return BP_TeamUpMatchInfo_MapModeType == mapModle;
end

-- 设置模式，刷新信息
local function TeamupMatchInfoSetMapModel(mapModle)
	BP_TeamUpMatchInfo_MapModeType = mapModle;
	LuaClassObj.HandleUIMessage(bp_teamup_match_info, "UpdateModel");
	TeamUpMatchInfoUI.ResetMapList();
	TeamUpMatchInfoUI.RefreshSelectedMapIndexList();
	TeamUpMapTipsUI.ClosePanel();
end

-- 经典模式选择
function EventTeamupMatchInfoClickClassic_Push()
	if not TameupMatchInfoIsMapModel(TeamUpMatchInfo_ClassicMapMode) then
		TeamupMatchInfoSetMapModel(TeamUpMatchInfo_ClassicMapMode);		
	end
end

-- 娱乐模式选择
function EventTeamupMatchInfoClickArcade_Push()
	if not TameupMatchInfoIsMapModel(TeamUpMatchInfo_ArcadeMapMode) then
		TeamupMatchInfoSetMapModel(TeamUpMatchInfo_ArcadeMapMode);
	end
end

-- 活动模式选择
function EventTeamupMatchInfoClickActivity_Push()
	if not TameupMatchInfoIsMapModel(TeamUpMatchInfo_ActivityMapMode) then
		TeamupMatchInfoSetMapModel(TeamUpMatchInfo_ActivityMapMode);
	end
end

-- 队伍人数选择
function EventTeamupMatchInfoClickTeam1_Push()
	log("EventTeamupMatchInfoClickTeam1_Push");
	HideNewbieGuide(false);
	TeamUpMatchInfoUI.SelectPlayerNum(1);
end

function EventTeamupMatchInfoClickTeam2_Push()
	log("EventTeamupMatchInfoClickTeam2_Push");
	ShowNewbieGuide();
	TeamUpMatchInfoUI.SelectPlayerNum(2);
end

function EventTeamupMatchInfoClickTeam4_Push()
	log("EventTeamupMatchInfoClickTeam4_Push");
	ShowNewbieGuide();
	TeamUpMatchInfoUI.SelectPlayerNum(4);
end

-- 自动匹配选择，如果是活动模式，默认是选择状态
function EventTeamupMatchInfoClickAutoMatch_Push()
end

--[[
=======================地图下载相关========================
LogNula: LuaLog: [HHFTEST]TeamUpMatchInfoUI.RealInitMapInfo, TeamUpMatchInfoUI.mapInfoList = 
LogNula: LuaLog: [HHFTEST]├─ 1
LogNula: LuaLog: [HHFTEST]│  ├─ state: 3
LogNula: LuaLog: [HHFTEST]│  ├─ mapName: "PUBG_Forest"
LogNula: LuaLog: [HHFTEST]│  ├─ mapFileName: ""
LogNula: LuaLog: [HHFTEST]│  ├─ eventIncrement: 0
LogNula: LuaLog: [HHFTEST]│  ├─ showName: "绝地海岛"
LogNula: LuaLog: [HHFTEST]│  ├─ mapFileSize: 0
LogNula: LuaLog: [HHFTEST]│  ├─ percent: 1000
LogNula: LuaLog: [HHFTEST]│  ├─ mapID: 1
LogNula: LuaLog: [HHFTEST]│  └─ taskID: 0
LogNula: LuaLog: [HHFTEST]│  └─ startDownloadTime: 0
LogNula: LuaLog: [HHFTEST]│  └─ preProgressTime: 0
LogNula: LuaLog: [HHFTEST]│  └─ downloadTime: 0

LogNula: LuaLog: [HHFTEST]TeamUpmatchInfoUI.InitMapInfo, TeamUpMatchInfoUI.needDownloadMapList = 
LogNula: LuaLog: [HHFTEST]├─ PUBG_Desert
LogNula: LuaLog: [HHFTEST]│  ├─ event: 10
LogNula: LuaLog: [HHFTEST]│  └─ filepre: "map_desert_"
LogNula: LuaLog: [HHFTEST]└─ PUBG_Savage_Main
LogNula: LuaLog: [HHFTEST]   ├─ event: 20
LogNula: LuaLog: [HHFTEST]   └─ filepre: "map_savagemain_"
--]]

function TeamUpMatchInfoUI.OnInitDownload(bResult, code)
	log("[HHF]TeamUpMatchInfoUI.OnInitDownload, bResult = " .. tostring(bResult) .. ", code = " .. tostring(code));
	TeamUpMatchInfoUI.bInitDownloadResult = bResult;
	TeamUpMatchInfoUI.initErrorCode = code;

	if TeamUpMatchInfoUI.bInitDownloadResult ~= true then
		if TeamUpMatchInfoUI.bHaveRetriedInit == true then
			local notice = string.format(FuncUtil.GetLocalizeResStr(5047), tostring(TeamUpMatchInfoUI.initErrorCode));
			PopUpNoticeUI.ShowNewNotice(notice);
		else
			log("[HHF]TeamUpMatchInfoUI.OnInitDownload, try to reintialize.");
			Client.ReInitializePuffer(GameFrontendHUD, false, 3, 5, 20*1024*1024);
			TeamUpMatchInfoUI.bHaveRetriedInit = true;
			return;
		end
	end
	TeamUpMatchInfoUI.InitMapInfo();

	if TeamUpMatchInfoUI.tryInitializeInfo.beInitializing == true then
		log("[HHF]TeamUpMatchInfoUI.OnInitDownload, change to real downloading state or reset.");
		TeamUpMatchInfoUI.tryInitializeInfo.beInitializing = false;
		if TeamUpMatchInfoUI.tryInitializeInfo.waitingMap ~= nil then
			if TeamUpMatchInfoUI.bInitDownloadResult == true then
				for k, v in pairs(TeamUpMatchInfoUI.tryInitializeInfo.waitingMap) do
					TeamUpMatchInfoUI.StartToDownloadMap(v, false);
				end
			else
				for k, v in pairs(TeamUpMatchInfoUI.tryInitializeInfo.waitingMap) do
					TeamUpMatchInfoUI.ChangeMapToSpecifiedState(v, TeamUpMatchInfoUI.downloadState_notStart);
				end
				TeamUpMatchInfoUI.ResetMapList(true, true);
				LobbyUI.UpdateDownloadingMapInfo();
			end
			TeamUpMatchInfoUI.tryInitializeInfo.waitingMap = {};
		end
	end
end

function TeamUpMatchInfoUI.InitMapInfo()
	if TeamUpMatchInfoUI.bInitDownloadResult ~= true then
		TeamUpMatchInfoUI.bInitDownloadResult = Client.GetPufferInitResult(GameFrontendHUD);
		TeamUpMatchInfoUI.initErrorCode = Client.GetPufferInitErrCode(GameFrontendHUD);
		log("[HHF]TeamUpMatchInfoUI.InitMapInfo, bInitDownloadResult = " .. tostring(TeamUpMatchInfoUI.bInitDownloadResult) .. ", initErrorCode = " .. tostring(TeamUpMatchInfoUI.initErrorCode));
	end

	local bSplitMapVersion = Client.IsSplitMapPakVersion();
	log("[HHF]TeamUpMatchInfoUI.InitMapInfo, bSplitMapVersion = " .. tostring(bSplitMapVersion));
	
	if FuncUtil:CountTable(TeamUpModelUI.listAllModelInfo) > 0 and FuncUtil:CountTable(TeamUpSystem.ModeInfoList) > 0 then
		TeamUpMatchInfoUI.FilterNeedDownloadMapList();
		if bSplitMapVersion == true then
			TeamUpMatchInfoUI.CheckIfMapFileCorrupted();
		end
		
		local bFirstInitMapInfo = true;
		if FuncUtil:CountTable(TeamUpMatchInfoUI.mapInfoList) > 0 then
			bFirstInitMapInfo = false;
		end

		for k, v in pairs(TeamUpModelUI.listAllModelInfo) do
			for k1, v1 in pairs(TeamUpSystem.ModeInfoList) do
				if k1 == v.model_id then
					for k2, v2 in pairs(v1.mode_group) do 
						TeamUpMatchInfoUI.InitMapInfoByModeID(bSplitMapVersion, k2);
					end
					break;
				end
			end
		end
		TeamUpMatchInfoUI.InitLeftMapInfo(bSplitMapVersion);
		
		--log_tree("[HHFTEST]TeamUpMatchInfoUI.InitMapInfo, TeamUpMatchInfoUI.mapInfoList = ", TeamUpMatchInfoUI.mapInfoList, "[HHFTEST]");
		--log_tree("[HHFTEST]TeamUpMatchInfoUI.InitMapInfo, TeamUpMatchInfoUI.modeInfoList = ", TeamUpMatchInfoUI.modeInfoList, "[HHFTEST]");
		
		local param = {};
		for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
			param[k] = v.state;
		end
		if FuncUtil:CountTable(param) > 0 then
			TeamUpSystem.SendMyMapInfo(param);
		end

		if bFirstInitMapInfo == true then
			TeamUpSystem.ResetModeToAvailableMap();
		end

		EventShowDownloadInfoInLobbyWhenNeed();
	else
		log("[HHF]TeamUpMatchInfoUI.InitMapInfo, ModeInfoList isn't ready.");
	end
end

function TeamUpMatchInfoUI.FilterNeedDownloadMapList()
	local config = Client.GetSplitMapConfigInfo();
	local haveSplitedMap = string.split(config, "+");
	--log_tree("[HHFTEST]TeamUpMatchInfoUI.FilterNeedDownloadMapList, haveSplitedMap = ", haveSplitedMap, "[HHFTEST]");
	for k, v in pairs(TeamUpMatchInfoUI.needDownloadMapList) do
		local found = false;
		for _, v1 in pairs(haveSplitedMap) do
			if string.find(v1, v.filepre) ~= nil then
				found = true;
			end
		end

		if found == false then
			TeamUpMatchInfoUI.needDownloadMapList[k] = nil;
		end
	end
	--log_tree("[HHFTEST]TeamUpMatchInfoUI.FilterNeedDownloadMapList, after needDownloadMapList = ", TeamUpMatchInfoUI.needDownloadMapList, "[HHFTEST]");
end

function TeamUpMatchInfoUI.CheckIfMapFileCorrupted()
	for k, v in pairs(TeamUpMatchInfoUI.needDownloadMapList) do
		local fileName = v.filepre .. Client.GetApplicationVersion() .. ".corrupted";
		v.corrupted = PufferDownloader.IsFileExistByExtension(GameFrontendHUD, fileName, "corrupted");
		log("[HHF]TeamUpMatchInfoUI.CheckIfMapFileCorrupted, fileName = " .. tostring(fileName) .. ", corrupted = " .. tostring(v.corrupted));
	end
end

function TeamUpMatchInfoUI.CheckPopCorruptedMapFiles()
	local haveCorrupted = false;
	local mapShowNames = {};
	for k, v in pairs(TeamUpMatchInfoUI.needDownloadMapList) do
		if v.corrupted == true then
			local haveAddMapNameToShow = false;
			for k1, v1 in pairs(TeamUpMatchInfoUI.mapInfoList) do
				if v1.mapName == k then
					if v1.state == TeamUpMatchInfoUI.downloadState_have then
						local fileName = v.filepre .. Client.GetApplicationVersion() .. ".corrupted";
						PufferDownloader.DeleteFile(fileName);
						v.corrupted = false;
						break;
					else
						v1.corrupted = true;

						if haveAddMapNameToShow == false then
							haveAddMapNameToShow = true;
							table.insert(mapShowNames, v1.showName);

							haveCorrupted = true;
						end
					end
				end
			end
		end
	end

	log("[HHF]TeamUpMatchInfoUI.CheckPopCorruptedMapFiles, haveCorrupted = " .. tostring(haveCorrupted));
	--log_tree("[HHFTEST]TeamUpMatchInfoUI.CheckPopCorruptedMapFiles, corruptedMapNames = ", mapShowNames, "[HHFTEST]");

	local loginTimesToday = IMSDKNoticeUI.GetLoginTimesToday();
	if loginTimesToday > 1 then
		log("[HHF]TeamUpMatchInfoUI.CheckPopCorruptedMapFiles, loginTimesToday = " .. tostring(loginTimesToday) .. " and immediately return.");
		LobbySystem.PopNextUI();
		return;
	end

	if haveCorrupted == true and #mapShowNames > 0 then
		local mapsName = "";
		for k, v in pairs(mapShowNames) do
			if mapsName == "" then
				mapsName = mapsName .. v;
			else
				mapsName = mapsName .. ", " .. v;
			end
		end
		local title = FuncUtil.GetLocalizeResStr(110115);
		local okLabel = FuncUtil.GetLocalizeResStr(5078);
		local cancelLabel = FuncUtil.GetLocalizeResStr(6416);
		local msgConfig = FuncUtil.GetLocalizeResStr(6415);
		local tips = string.format(msgConfig, mapsName);

		CommonMessageBoxUI:ShowPanel(2, title, tips,
			EventTeamupClickMatchInfo_Push,
			LobbySystem.PopNextUI,
			okLabel,
			cancelLabel);
	else
		LobbySystem.PopNextUI();
	end
end

function TeamUpMatchInfoUI.InitMapInfoByModeID(bSplitMapVersion, modeID)
	log("[HHF]TeamUpMatchInfoUI.InitMapInfoByModeID, modeID = " .. modeID);
	local modeInfo = Client.GetTableData("ModeTeamTable", modeID);
	if modeInfo ~= nil then
		local subModeIDTable = TeamUpMatchInfoUI.GetSubModeIDByString(modeInfo.SubModeIDs);
		for k, v in pairs(subModeIDTable) do
			local subModeInfo = Client.GetTableData("BTMode", v);
			if subModeInfo ~= nil then		
				local mapTableInfo = Client.GetTableData("Map", subModeInfo.MapID);
				if mapTableInfo ~= nil then
					local info = TeamUpMatchInfoUI.modeInfoList[modeID];
					if info == nil then
						info = {};
						table.insert(info, mapTableInfo.ResId);
						TeamUpMatchInfoUI.modeInfoList[modeID] = info;
					else
						local have = false;
						for k1, v1 in pairs(info) do
							if v1 == mapTableInfo.ResId then
								have = true;
								break;
							end
						end
						if have == false then
							table.insert(info, mapTableInfo.ResId);
						end
					end

					TeamUpMatchInfoUI.AddOneMapInfo(bSplitMapVersion, mapTableInfo, true);
				end
			end
		end
	end
end

function TeamUpMatchInfoUI.InitLeftMapInfo(bSplitMapVersion)
	log("[HHF]TeamUpMatchInfoUI.InitLeftMapInfo");
	local mapTableInfo = Client.GetTable("Map");
	for k, v in pairs(mapTableInfo) do
		TeamUpMatchInfoUI.AddOneMapInfo(bSplitMapVersion, v, false);
	end
end

function TeamUpMatchInfoUI.AddOneMapInfo(bSplitMapVersion, mapInfo, showInLobby)
	if mapInfo == nil then
		log("[HHF]TeamUpMatchInfoUI.AddOneMapInfo, mapInfo = nil");
	else
		--log("[HHF]TeamUpMatchInfoUI.AddOneMapInfo, mapInfo.ResId = " .. tostring(mapInfo.ResId));
		local oneMap = TeamUpMatchInfoUI.mapInfoList[mapInfo.ResId];
		if oneMap == nil then
			oneMap = {};
			oneMap.mapID = mapInfo.ResId;
			oneMap.mapName = TeamUpMatchInfoUI.SubStringFromEnd(mapInfo.MapPath, "/");
			oneMap.showName = mapInfo.WatchingName;
			oneMap.canPause = true;
			oneMap.showInLobby = showInLobby;
			if bSplitMapVersion == true then
				if TeamUpMatchInfoUI.needDownloadMapList[oneMap.mapName] == nil then
					oneMap.eventIncrement = 0;
					oneMap.mapFileName = "";
					oneMap.mapFileSize = 0;
					oneMap.taskID = 0;
					oneMap.state = TeamUpMatchInfoUI.downloadState_have;
					oneMap.percent = 1000;
				else
					oneMap.eventIncrement = TeamUpMatchInfoUI.needDownloadMapList[oneMap.mapName].event;
					oneMap.mapFileName = TeamUpMatchInfoUI.needDownloadMapList[oneMap.mapName].filepre .. Client.GetApplicationVersion() .. ".pak";
					if TeamUpMatchInfoUI.bInitDownloadResult == true then
						local bReady = TeamUpMatchInfoUI.IsMapFileReady(oneMap.mapFileName);--Client.IsFileReady(GameFrontendHUD, oneMap.mapFileName);
						if bReady == true then
							oneMap.mapFileSize = 0;
							oneMap.taskID = 0;
							oneMap.state = TeamUpMatchInfoUI.downloadState_have;
							oneMap.percent = 1000;
						else
							local bExist = PufferDownloader.IsFileExist(GameFrontendHUD, oneMap.mapFileName);
							if bExist == true then
								oneMap.mapFileSize = 0;
								oneMap.taskID = 0;
								oneMap.state = TeamUpMatchInfoUI.downloadState_have;
								oneMap.percent = 1000;
							else
								if MAP_DOWNLOAD_INCREMENTAL_VERSION then
									oneMap.mapFileSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, oneMap.mapFileName);
								else
									oneMap.mapFileSize = Client.GetFileSizeCompressed(GameFrontendHUD, oneMap.mapFileName);
								end
								oneMap.taskID = 0;
								oneMap.state = TeamUpMatchInfoUI.downloadState_notStart;
								oneMap.percent = 0;
							end
						end
					else
						local bExist = PufferDownloader.IsFileExist(GameFrontendHUD, oneMap.mapFileName);
						if bExist == true then
							oneMap.mapFileSize = 0;
							oneMap.taskID = 0;
							oneMap.state = TeamUpMatchInfoUI.downloadState_have;
							oneMap.percent = 1000;
						else
							oneMap.mapFileSize = 0;
							oneMap.taskID = 0;
							oneMap.state = TeamUpMatchInfoUI.downloadState_notStart;
							oneMap.percent = 0;
						end
					end
				end
			else
				oneMap.eventIncrement = 0;
				oneMap.mapFileName = "";
				oneMap.mapFileSize = 0;
				oneMap.taskID = 0;
				oneMap.state = TeamUpMatchInfoUI.downloadState_have;
				oneMap.percent = 1000;
			end

			TeamUpMatchInfoUI.mapInfoList[mapInfo.ResId] = oneMap;
		else
			if bSplitMapVersion == true then
				if TeamUpMatchInfoUI.needDownloadMapList[oneMap.mapName] ~= nil then
					if TeamUpMatchInfoUI.bInitDownloadResult == true then
						if oneMap.state ~= TeamUpMatchInfoUI.downloadState_have then
							if oneMap.mapFileSize == 0 then
								if MAP_DOWNLOAD_INCREMENTAL_VERSION then
									oneMap.mapFileSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, oneMap.mapFileName);
								else
									oneMap.mapFileSize = Client.GetFileSizeCompressed(GameFrontendHUD, oneMap.mapFileName);
								end
							end
						end
					end
				end
			end
		end
	end
end

function TeamUpMatchInfoUI.IsMapFileReady(filename)
	if TeamUpMatchInfoUI.mapList[filename] ~= nil then
		return TeamUpMatchInfoUI.mapList[filename];
	end

	local bReady = Client.IsFileReady(GameFrontendHUD, filename);
	if bReady == true then
		TeamUpMatchInfoUI.mapList[filename] = true;
	end

	return bReady;
end

function TeamUpMatchInfoUI.GetSubModeIDByString(input)
	local subMode = {};
	for w in string.gmatch(input, "%d+") do
		table.insert(subMode, w);
	end
	return subMode;
end

function TeamUpMatchInfoUI.SubStringFromEnd(str, k)
	local pos = 1;
	local rts = string.reverse(str);
	local _, i = string.find(rts, k);
	if i ~= nil then
		pos = string.len(str) - i + 2;
	end
	return string.sub(str, pos);
end

function TeamUpMatchInfoUI.GetMapStateByModeID(modeID)
	log("[HHF]TeamUpMatchInfoUI.GetMapStateByModeID, modeID = " .. tostring(modeID));
	local result = {};
	result.mapfilename = "";
	result.mapfilesize = 0;
	result.downloadpercent = 0;
	result.downloadstate = TeamUpMatchInfoUI.downloadState_notStart;
	result.corrupted = false;
	local first = true;

	local modeInfo = TeamUpMatchInfoUI.modeInfoList[modeID];
	if modeInfo ~= nil then
		for k, v in pairs(modeInfo) do
			local mapInfo = TeamUpMatchInfoUI.mapInfoList[v];
			if mapInfo ~= nil then
				--mapInfo.showInLobby = true;
				if first then
					result.mapfilename = mapInfo.mapFileName;
					result.mapfilesize = mapInfo.mapFileSize;
					result.downloadpercent = mapInfo.percent;
					result.downloadstate = mapInfo.state;
					result.corrupted = mapInfo.corrupted or false;
					first = false;

					if result.downloadstate == TeamUpMatchInfoUI.downloadState_have then
						break;
					end
				end
				
				if mapInfo.state == TeamUpMatchInfoUI.downloadState_have then
					result.mapfilename = mapInfo.mapFileName;
					result.mapfilesize = mapInfo.mapFileSize;
					result.downloadpercent = mapInfo.percent;
					result.downloadstate = mapInfo.state;
					result.corrupted = mapInfo.corrupted or false;
					break;
				end
			else
				log("[HHF]TeamUpMatchInfoUI.GetMapStateByModeID, TeamUpMatchInfoUI.mapInfoList[" .. v .. "] = nil, Can't believe it!");
			end
		end
	else
		log("[HHF]TeamUpMatchInfoUI.GetMapStateByModeID, TeamUpMatchInfoUI.modeInfoList[" .. modeID .. "] = nil, Can't believe it!");
	end

	return result;
end

function TeamUpMatchInfoUI.ReportEventsCount(filename, id, value)
	local bReported = false;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapFileName == filename then
			if id == TeamUpMatchInfoUI.mapEvent_progress then
				local pause = value - v.preProgressTime;
				if pause < TeamUpMatchInfoUI.interval then
					v.preProgressTime = value;
				else
					v.preProgressTime = value;
					v.startDownloadTime = v.startDownloadTime + pause;
				end
			elseif id == TeamUpMatchInfoUI.mapEvent_start then
				v.startDownloadTime = value;
				v.preProgressTime = value;
				if bReported == false then
					VersionUpdater.ReportEventsCount(id + v.eventIncrement);
					bReported = true;
				end
			elseif id == TeamUpMatchInfoUI.mapEvent_time then
				v.downloadTime = value - v.startDownloadTime;
				if bReported == false then
					VersionUpdater.ReportEventsCount(id + v.eventIncrement, v.downloadTime);
					bReported = true;
				end
			elseif id == TeamUpMatchInfoUI.mapEvent_error then
				if bReported == false then
					VersionUpdater.ReportEventsCount(id + v.eventIncrement, value);
					bReported = true;
				end
			elseif id == TeamUpMatchInfoUI.mapEvent_done or
				   id == TeamUpMatchInfoUI.mapEvent_pause or
				   id == TeamUpMatchInfoUI.mapEvent_continue or
				   id == TeamUpMatchInfoUI.mapEvent_autoPause then
				if bReported == false then
					VersionUpdater.ReportEventsCount(id + v.eventIncrement);
					bReported = true;
				end
			end
		end
	end
end

function EventStartToDownloadMap()
	if TeamUpMatchInfoUI.bInitDownloadResult == true then
		log("[HHF]EventStartToDownloadMap, filename = " .. tostring(BP_TeamUpMatchInfo_CurDownloadMapFileName));
		if not Client.HasActiveWifi() then
			log("[HHF]EventStartToDownloadMap, without WiFi.");
			local title = FuncUtil.GetLocalizeResStr(201001);
			local okLabel = FuncUtil.GetLocalizeResStr(110036);
			local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
			local msgConfig = FuncUtil.GetLocalizeResStr(201004);
			local size = TeamUpMatchInfoUI.GetFileSizeByFileName(BP_TeamUpMatchInfo_CurDownloadMapFileName);
			local tips = string.format(msgConfig, size / 1048576);

			CommonMessageBoxUI:ShowPanel(2, title, tips,
				function()
					TeamUpMatchInfoUI.StartToDownloadMap(BP_TeamUpMatchInfo_CurDownloadMapFileName, false);
				end,
				nil,
				okLabel,
				cancelLabel);
		else
			log("[HHF]EventStartToDownloadMap, with WiFi.");
			TeamUpMatchInfoUI.StartToDownloadMap(BP_TeamUpMatchInfo_CurDownloadMapFileName, false);
		end
	else
		--log("[HHF]EventStartToDownloadMap, InitDownloader failed.");
		--local notice = string.format(FuncUtil.GetLocalizeResStr(5047), tostring(TeamUpMatchInfoUI.initErrorCode));
		--PopUpNoticeUI.ShowNewNotice(notice);
		TeamUpMatchInfoUI.TryInitializeAgain(BP_TeamUpMatchInfo_CurDownloadMapFileName);
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "OnStartDownloadSuccess");
	end
end

function TeamUpMatchInfoUI.TryInitializeAgain(filename)
	if TeamUpMatchInfoUI.tryInitializeInfo.beInitializing ~= true then
		log("[HHF]TeamUpMatchInfoUI.TryInitializeAgain, filename = " .. tostring(filename));
		TeamUpMatchInfoUI.tryInitializeInfo.beInitializing = true;
		TeamUpMatchInfoUI.tryInitializeInfo.waitingMap = {};
		table.insert(TeamUpMatchInfoUI.tryInitializeInfo.waitingMap, filename);
		Client.ReInitializePuffer(GameFrontendHUD, false, 3, 5, 20*1024*1024);
	else
		log("[HHF]TeamUpMatchInfoUI.TryInitializeAgain, only keep the filename = " .. tostring(filename));
		table.insert(TeamUpMatchInfoUI.tryInitializeInfo.waitingMap, filename);
	end

	TeamUpMatchInfoUI.ChangeMapToSpecifiedState(filename, TeamUpMatchInfoUI.downloadState_downloading);
	TeamUpMatchInfoUI.ResetMapList(true, true);
	LobbyUI.UpdateDownloadingMapInfo();
end

function TeamUpMatchInfoUI.ChangeMapToSpecifiedState(filename, state)
	log("[HHF]TeamUpMatchInfoUI.ChangeMapToSpecifiedState, filename = " .. tostring(filename) .. ", state = " .. tostring(state));
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapFileName == filename then
			v.state = state;
		end
	end
end

function TeamUpMatchInfoUI.GetFileSizeByFileName(filename)
	local size = 0;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapFileName == filename then
			size = v.mapFileSize;
			break;
		end
	end

	log("[HHF]TeamUpMatchInfoUI.GetFileSizeByFileName, filename = " .. tostring(filename) .. ", filesize = " .. size);
	return size;
end

function TeamUpMatchInfoUI.ShowNoEnoughSpaceTips(filename)
	local space = Client.GetDeviceFreeSpace();
	local size = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, filename, true) / 1048576;
	if size < space or string.lower(Client.GetDevicePlatformName()) == "windows" then
	else
		local notice = FuncUtil.GetLocalizeResStr(4179);
		PopUpNoticeUI.ShowNewNotice(notice);
	end
	log("[HHF]TeamUpMatchInfoUI.ShowNoEnoughSpaceTips, size = " .. tostring(size) .. ", space = " .. tostring(space));
end

function EventGetMapPosterByFileName()
	local name = BP_TeamUpMatchInfo_CurDownloadMapFileName;
	local path = "/Game/UMG/Texture/Lobby_NoAtlas/DL_bigmap_bg.DL_bigmap_bg";
	if string.find(name, "map_savagemain_") ~= nil then
		path = "/Game/UMG/Texture/Lobby_NoAtlas/DL_bigmap_bg.DL_bigmap_bg";
	elseif string.find(name, "map_desert_") ~= nil then
		path = "/Game/UMG/Texture/Lobby_NoAtlas/DL_bigmap02_bg.DL_bigmap02_bg";
	elseif string.find(name, "map_dihorotok_") ~= nil then
		path = "/Game/UMG/Texture/Lobby_NoAtlas/DL_bigmap03_bg.DL_bigmap03_bg";
	end

	log("[HHF]EventGetMapPosterByFileName, name = " .. tostring(name) .. ", path = " .. tostring(path));
	BP_TeamUpMatchInfo_CurDownloadMapPosterPath = path;
end

function TeamUpMatchInfoUI.StartToDownloadMap(filename, force)
	if TeamUpMatchInfoUI.bInitDownloadResult ~= true then
		log("[HHF]TeamUpMatchInfoUI.StartToDownloadMap, why you try when initialization is failed.");
		return;
	end

	TeamUpMatchInfoUI.ShowNoEnoughSpaceTips(filename);

	local taskID = 0;
	if MAP_DOWNLOAD_INCREMENTAL_VERSION then
		taskID = PufferDownloader.RequestFile(GameFrontendHUD, filename, force);
	else
		taskID = Client.RequestFile(GameFrontendHUD, filename, force);
	end

	if taskID > 0 then
		log("[HHF]TeamUpMatchInfoUI.StartToDownloadMap, RequestFile Success, taskID = " .. tostring(taskID));
		local current = 0;
		for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
			if v.mapFileName == filename then
				v.taskID = taskID;
				v.state = TeamUpMatchInfoUI.downloadState_downloading;
				if MAP_DOWNLOAD_INCREMENTAL_VERSION then
					v.mapFileSize = PufferDownloader.GetFileSizeCompressed(GameFrontendHUD, v.mapFileName);
				else
					v.mapFileSize = Client.GetFileSizeCompressed(GameFrontendHUD, v.mapFileName);
				end
				current = v.percent;
				--break;
			end
		end
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "OnStartDownloadSuccess");
		TeamUpMatchInfoUI.ResetMapList(true, true);
		LobbyUI.UpdateDownloadingMapInfo();
		if current == 0 then
			TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_start, FuncUtil.GetServerTimeInSec());
		else
			TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_continue);
		end
	else
		log("[HHF]TeamUpMatchInfoUI.StartToDownloadMap, RequestFile failed, errorCode = " .. tostring(taskID));
		local notice = string.format(FuncUtil.GetLocalizeResStr(5048), tostring(taskID));
		PopUpNoticeUI.ShowNewNotice(notice);
		LuaClassObj.HandleUIMessage(bp_teamup_match_info, "OnStartDownloadFailed");
		TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_error, taskID);
	end
end

function TeamUpMatchInfoUI.CanPauseByStage(stage)
	if stage >= PufferDownloader.STAGE_FILE_MERGING then
		log("[HHF]TeamUpMatchInfoUI.CanPauseByStage, stage = " .. tostring(stage) .. ", return false");
		return false;
	else
		log("[HHF]TeamUpMatchInfoUI.CanPauseByStage, stage = " .. tostring(stage) .. ", return true");
		return true;
	end
end

TeamUpMatchInfoUI.StageTimeProportion = {
	-- {本Stage所占比例，本Stage从多少比例开始}
	{0.0, 0.0}, -- [PufferDownloader.STAGE_INITIALIZING]
	{0.05, 0.0}, -- [PufferDownloader.STAGE_FETCH_FILE_LIST]
	{0.70, 0.05}, -- [PufferDownloader.STAGE_FILE_DOWNLOADING]
	{0.15, 0.75}, -- [PufferDownloader.STAGE_FILE_MERGING]
	{0.10, 0.90}, -- [PufferDownloader.STAGE_FILE_CHECKING]
	{0.0, 0.0}, -- [PufferDownloader.STAGE_RETRY]
	{0.0, 1.0}, -- [PufferDownloader.STAGE_FINISH]
	{0.05, 0.95} -- [PufferDownloader.STAGE_PRECHECK]
}
function TeamUpMatchInfoUI.OnUpdateDownloadProgress(taskID, cur, total, curStage)
	log("[HHF]TeamUpMatchInfoUI.OnUpdateDownloadProgress, taskID = " .. tostring(taskID) .. ", cur = " .. tostring(cur) .. ", total = " .. tostring(total) .. ", curStage = " .. tostring(curStage));
	local filename = "";
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.taskID == taskID then
			v.canPause = TeamUpMatchInfoUI.CanPauseByStage(curStage);

			if MAP_DOWNLOAD_INCREMENTAL_VERSION then
				local proportion = TeamUpMatchInfoUI.StageTimeProportion[curStage];
				v.percent = cur / total * 1000 * proportion[1] + proportion[2]*1000;
			else
				v.percent = cur / total * 1000;
			end

			if v.percent >= 1000 then
				v.percent = 999;
			end
			--break;
			if filename == "" then
				filename = v.mapFileName;
			end
		end
	end

	TeamUpMatchInfoUI.ResetMapList(true, true);
	LobbyUI.UpdateDownloadingMapInfo();
	TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_progress, FuncUtil.GetServerTimeInSec());
end

function TeamUpMatchInfoUI.OnDownloadMapCompleted(taskID, isSuccess, errorCode)
	log("[HHF]TeamUpMatchInfoUI.OnDownloadMapCompleted, taskID = " .. tostring(taskID) .. ", isSuccess = " .. tostring(isSuccess) .. ", errorCode = " .. tostring(errorCode));
	local param = {};
	local filename = "";
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.taskID == taskID then
			if isSuccess then
				v.state = TeamUpMatchInfoUI.downloadState_have;
				param[k] = TeamUpMatchInfoUI.downloadState_have;
			else
				v.state = TeamUpMatchInfoUI.downloadState_error;
			end
			--break;
			if filename == "" then
				filename = v.mapFileName;
			end
		end
	end

	if isSuccess then
		TeamUpSystem.UpdateMyMapInfo(param);
	end

	TeamUpMatchInfoUI.ResetMapList(true, true);
	LobbyUI.UpdateDownloadingMapInfo();

	if errorCode == 0 then
		TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_done);
		TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_time, FuncUtil.GetServerTimeInSec());
	else
		if isSuccess ~= true then
			TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_error, errorCode);
		end
	end
	
	if isSuccess ~= true then
		if errorCode == 271581189 or errorCode == 269811740 then
			local title = FuncUtil.GetLocalizeResStr(201001);
			local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
			local notice = string.format(FuncUtil.GetLocalizeResStr(201032), tostring(errorCode));
			local warning = FuncUtil.GetLocalizeResStr(201022);

			CommonMessageBoxUI:ShowPanel(1, title, notice .. warning,
				function()
					LuaClassObj.HandleUIMessage(bp_global, "quitGame");
				end,
				nil,
				cancelLabel,
				nil);
		else
			local notice = string.format(FuncUtil.GetLocalizeResStr(5048), tostring(errorCode));
			PopUpNoticeUI.ShowNewNotice(notice);
		end
	end
end

function TeamUpMatchInfoUI.IsDownloadingCanPauseByFileName(filename)
	local canPause = true;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapFileName == filename then
			canPause = v.canPause;
			break;
		end
	end

	log("[HHF]TeamUpMatchInfoUI.IsDownloadingCanPauseByFileName, filename = " .. tostring(filename) .. ", canPause = " .. tostring(canPause));
	return canPause;
end

function EventPauseDownloadMap()
	if TeamUpMatchInfoUI.bInitDownloadResult == true then
		if TeamUpMatchInfoUI.IsDownloadingCanPauseByFileName(BP_TeamUpMatchInfo_CurDownloadMapFileName) == true then
			log("[HHF]EventPauseDownloadMap, filename = " .. BP_TeamUpMatchInfo_CurDownloadMapFileName);
			TeamUpMatchInfoUI.PauseDownloadByFileName(BP_TeamUpMatchInfo_CurDownloadMapFileName);
		else
			local notice = FuncUtil.GetLocalizeResStr(201025);
			PopUpNoticeUI.ShowNewNotice(notice);
		end
	else
		--log("[HHF]EventPauseDownloadMap, InitDownloader failed.");
		--local notice = string.format(FuncUtil.GetLocalizeResStr(5047), tostring(TeamUpMatchInfoUI.initErrorCode));
		--PopUpNoticeUI.ShowNewNotice(notice);
		TeamUpMatchInfoUI.StopTaskBeforeInitReturn(BP_TeamUpMatchInfo_CurDownloadMapFileName);
	end
end

function TeamUpMatchInfoUI.PauseDownloadByFileName(filename)
	log("[HHF]TeamUpMatchInfoUI.PauseDownloadByFileName, filename = " .. filename);
	local taskID = 0;
	local result = false;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapFileName == filename then
			taskID = v.taskID;
			if MAP_DOWNLOAD_INCREMENTAL_VERSION then
				result = PufferDownloader.StopTask(GameFrontendHUD, v.taskID);
			else
				result = Client.StopTask(GameFrontendHUD, v.taskID);
			end
			break;
		end
	end

	if taskID ~= 0 then
		if result == true then
			for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
				if v.taskID == taskID then
					v.state = TeamUpMatchInfoUI.downloadState_pause;
					--break;
				end
			end

			TeamUpMatchInfoUI.ResetMapList(true, true);
			LobbyUI.UpdateDownloadingMapInfo();
			TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_pause);
		else
			log("[HHF]TeamUpMatchInfoUI.PauseDownloadByFileName, StopTask failed");
			TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_error);
		end
	else
		log("[HHF]TeamUpMatchInfoUI.PauseDownloadByFileName, Can't believe it! taskID = 0");
	end
end

function TeamUpMatchInfoUI.StopTaskBeforeInitReturn(filename)
	log("[HHF]TeamUpMatchInfoUI.StopTaskBeforeInitReturn, filename = " .. filename);
	--log_tree("[HHFTEST]TeamUpMatchInfoUI.StopTaskBeforeInitReturn, before waitingMap = ", TeamUpMatchInfoUI.tryInitializeInfo.waitingMap, "[HHFTEST]");
	for k, v in pairs(TeamUpMatchInfoUI.tryInitializeInfo.waitingMap) do
		if v == filename then
			table.remove(TeamUpMatchInfoUI.tryInitializeInfo.waitingMap, k);
			break;
		end
	end
	--log_tree("[HHFTEST]TeamUpMatchInfoUI.StopTaskBeforeInitReturn, after waitingMap = ", TeamUpMatchInfoUI.tryInitializeInfo.waitingMap, "[HHFTEST]");
	TeamUpMatchInfoUI.ChangeMapToSpecifiedState(filename, TeamUpMatchInfoUI.downloadState_notStart);
	TeamUpMatchInfoUI.ResetMapList(true, true);
	LobbyUI.UpdateDownloadingMapInfo();
end

function TeamUpMatchInfoUI.PauseAllDownloading()
	log("[HHF]TeamUpMatchInfoUI.PauseAllDownloading");
	for k, v in pairs(TeamUpMatchInfoUI.needDownloadMapList) do
		local result = false;
		local filename = "";
		for k1, v1 in pairs(TeamUpMatchInfoUI.mapInfoList) do
			if v1.mapName == k and v1.state == TeamUpMatchInfoUI.downloadState_downloading then
				filename = v1.mapFileName;
				if MAP_DOWNLOAD_INCREMENTAL_VERSION then
					result = PufferDownloader.StopTask(GameFrontendHUD, v1.taskID);
				else
					result = Client.StopTask(GameFrontendHUD, v1.taskID);
				end
				break;
			end
		end

		if filename ~= "" then
			if result == true then
				log("[HHF]TeamUpMatchInfoUI.PauseAllDownloading, " .. filename .. " downloading is stoped.");
				for k2, v2 in pairs(TeamUpMatchInfoUI.mapInfoList) do
					if v2.mapFileName == filename then
						v2.state = TeamUpMatchInfoUI.downloadState_pause;
						--break;
					end
				end
				LobbyUI.UpdateDownloadingMapInfo();
				TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_autoPause);
			else
				log("[HHF]TeamUpMatchInfoUI.PauseAllDownloading, stop " .. filename .. " downloading failed.");
				TeamUpMatchInfoUI.ReportEventsCount(filename, TeamUpMatchInfoUI.mapEvent_error);
			end
		else
			log("[HHF]TeamUpMatchInfoUI.PauseAllDownloading, " .. k .. " isn't downloading.");
		end
	end
end

function EventContinueDownloadMap()
	if TeamUpMatchInfoUI.bInitDownloadResult == true then
		log("[HHF]EventContinueDownloadMap, filename = " .. BP_TeamUpMatchInfo_CurDownloadMapFileName);
		TeamUpMatchInfoUI.StartToDownloadMap(BP_TeamUpMatchInfo_CurDownloadMapFileName, false);
	else
		log("[HHF]EventContinueDownloadMap, InitDownloader failed.");
		local notice = string.format(FuncUtil.GetLocalizeResStr(5047), tostring(TeamUpMatchInfoUI.initErrorCode));
		PopUpNoticeUI.ShowNewNotice(notice);
	end
end

function EventOnErrorRepeatDownload()
	if TeamUpMatchInfoUI.bInitDownloadResult == true then
		log("[HHF]EventOnErrorRepeatDownload, filename = " .. BP_TeamUpMatchInfo_CurDownloadMapFileName);
		local bReady = Client.IsFileReady(GameFrontendHUD, BP_TeamUpMatchInfo_CurDownloadMapFileName);
		if bReady == true then
			local result = Client.RemountPakFiles(GameFrontendHUD);
			if result == true then
				log("[HHF]EventOnErrorRepeatDownload, file is ready, remount success.");
				local taskID = TeamUpMatchInfoUI.GetTaskIDByFileName(BP_TeamUpMatchInfo_CurDownloadMapFileName);
				TeamUpMatchInfoUI.OnDownloadMapCompleted(taskID, true, -1);
			else
				log("[HHF]EventOnErrorRepeatDownload, file is ready, remount failed.");				
				local notice = FuncUtil.GetLocalizeResStr(201008);
				PopUpNoticeUI.ShowNewNotice(notice);
			end
		else
			local taskID = TeamUpMatchInfoUI.GetTaskIDByFileName(BP_TeamUpMatchInfo_CurDownloadMapFileName);
			local result = false;
			if MAP_DOWNLOAD_INCREMENTAL_VERSION then
				result = PufferDownloader.StopTask(GameFrontendHUD, taskID);
			else
				result = Client.StopTask(GameFrontendHUD, taskID);
			end
			log("[HHF]EventOnErrorRepeatDownload, StopTask() = " .. tostring(result));
			TeamUpMatchInfoUI.StartToDownloadMap(BP_TeamUpMatchInfo_CurDownloadMapFileName, true);
		end
	else
		log("[HHF]EventOnErrorRepeatDownload, InitDownloader failed.");
		local notice = string.format(FuncUtil.GetLocalizeResStr(5047), tostring(TeamUpMatchInfoUI.initErrorCode));
		PopUpNoticeUI.ShowNewNotice(notice);
	end
end

function TeamUpMatchInfoUI.GetTaskIDByFileName(filename)
	local taskID = 0;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapFileName == filename then
			taskID = v.taskID;
			break;
		end
	end
	log("[HHF]TeamUpMatchInfoUI.GetTaskIDByFileName, filename = " .. filename .. ", taskID = " .. taskID);
	return taskID;
end

function TeamUpMatchInfoUI.StartLobbyDownload(filename)
	log("[HHF]TeamUpMatchInfoUI.StartLobbyDownload, filename = " .. filename);
	local state = TeamUpMatchInfoUI.GetDownloadStateByFileName(filename);
	if state == TeamUpMatchInfoUI.downloadState_error then
		BP_TeamUpMatchInfo_CurDownloadMapFileName = filename;
		EventOnErrorRepeatDownload();
	else
		TeamUpMatchInfoUI.StartToDownloadMap(filename, false);
	end
end

function TeamUpMatchInfoUI.GetDownloadStateByFileName(filename)
	local state = TeamUpMatchInfoUI.downloadState_notStart;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapFileName == filename then
			state = v.state;
			break;
		end
	end
	log("[HHF]TeamUpMatchInfoUI.GetDownloadStateByFileName, filename = " .. filename .. ", state = " .. state);
	return state;
end

function TeamUpMatchInfoUI.ResetMapDownloaderInfo()
	log("[HHF]TeamUpMatchInfoUI.ResetMapDownloaderInfo");
	TeamUpMatchInfoUI.PauseAllDownloading();
	TeamUpMatchInfoUI.mapList = {};
	TeamUpMatchInfoUI.mapInfoList = {};
	TeamUpMatchInfoUI.modeInfoList = {};
	TeamUpMatchInfoUI.tryInitializeInfo = {};
	TeamUpMatchInfoUI.bHaveRetriedInit = false;
end

function TeamUpMatchInfoUI.IsMapReadyByMapID(mapID)
	local have = false;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
		if v.mapID == mapID then
			if v.state == TeamUpMatchInfoUI.downloadState_have then
				have = true;
			else
				have = false;
			end
			break;
		end
	end

	log("[HHF]TeamUpMatchInfoUI.IsMapReadyByMapID, mapID = " .. tostring(mapID) .. ", ready = " .. tostring(have));
	return have;
end

function TeamUpMatchInfoUI.UpdateHalloweenSwitch()
	local halloweenID = 1
	BP_TeamUpHalloweenSwitch = LoginSystem.commonSwitch.FestivalId == halloweenID
end

function EventShowDownloadInfoInLobbyWhenNeed()
	local need = false;
	for k, v in pairs(TeamUpMatchInfoUI.mapInfoList) do
        if v.state ~= TeamUpMatchInfoUI.downloadState_have then
			need = true;
			break;
		end
	end

	log("[HHF]EventShowDownloadInfoInLobbyWhenNeed, need = " .. tostring(need));
	if need then
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "ShowMapDownloadingPanel");
		LobbyUI.UpdateDownloadingMapInfo();
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_lobby, "HideMapDownloadingPanel");
	end
end

function EventTeamUpMatchInfoSameLanguageClickTrue()
	MatchPopupUI.SetLanguageSet()
	BP_TeamUpMatchInfo_SameLanguage = true;
	--设置勾选
	local id1, id2;
    for i,v in ipairs(BP_ChatLanguageDataList) do
        if v.langName == BP_MatchPopup_LanguageSelect1 then
            id1 = v.id;
        end
        if v.langName == BP_MatchPopup_LanguageSelect2 then
            id2 = v.id;
        end
    end
    MatchPopupUI.SetSameLanguage(true);
    LanguageSelectSystem.MatchLanguageSelectReq(id1, id2, BP_TeamUpMatchInfo_SameLanguage);
end

function EventTeamUpMatchInfoSameLanguageClickFalse()
	MatchPopupUI.SetLanguageSet()
	BP_TeamUpMatchInfo_SameLanguage = false;
	--设置不勾选
	local id1, id2;
    for i,v in ipairs(BP_ChatLanguageDataList) do
        if v.langName == BP_MatchPopup_LanguageSelect1 then
            id1 = v.id;
        end
        if v.langName == BP_MatchPopup_LanguageSelect2 then
            id2 = v.id;
        end
    end
    MatchPopupUI.SetSameLanguage(false);
    LanguageSelectSystem.MatchLanguageSelectReq(id1, id2, BP_TeamUpMatchInfo_SameLanguage);
end

function EventOpenLanguageSelectPanel()
	HideNewbieGuide(true);
	MatchLanguageSelect.SetAsMatchInfoType(true);
	--TeamUpMapTipsUI.ClosePanel();
	MatchLanguageSelect.Show();
end

function EventFetchInfo()
	-- body
end

-- 点击了tips，刷新副本词缀
function EventTeamUpMatchInfoOnMapItemTipsClick()
	log("------EventTeamUpMatchInfoOnMapItemTipsClick")
	BP_TeamUpMatchInfo_Show_Skill_Effect = false;

	log_tree(tostring(BP_TeamUpMatchInfo_Current_ClickTips_MapId),BP_ARRAY_TeamUpMatchMapInfoList)
	for k,mapInfo in pairs(BP_ARRAY_TeamUpMatchMapInfoList) do
		if mapInfo.map_id == BP_TeamUpMatchInfo_Current_ClickTips_MapId then
			mapInfo.show_skill_effect = false;
		else
			if mapInfo.show_skill_effect == true then
				BP_TeamUpMatchInfo_Show_Skill_Effect = true;
			end
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_teamup_match_info, "UpdateActivityTipsVisible");
end

function TeamUpMatchInfoUI.UpdateNewMapSkillInActivity()
	if false == TeamUpMatchInfoUI.isShowing then
		return;
	end
	BP_TeamUpMatchInfo_Show_Skill_Effect = false;
	local activityMaps = nil;

	for k,v in pairs(TeamUpSystem.ModeInfoList) do
		if v.model_type == TeamUpMatchInfo_ActivityMapMode then
			activityMaps = v;
			break;
		end
	end
	if activityMaps ~= nil and activityMaps.mode_group then
		for k,v in pairs(activityMaps.mode_group) do
			isOpen, hasPreview, previewStr = TeamUpSystem.IsOnTime(v);
			if isOpen or (not isOpen and hasPreview) then
				infoConfig = Client.GetTableData("ModeTeamTable", k);
				if infoConfig then
					if v.skills and #v.skills > 0 then
						local mapSkillInfo = TeamUpSystem.GetMapSkillInfo(tostring(k));
						local sameSkill = true;
						if mapSkillInfo and (mapSkillInfo["count"] or 0) ==  #v.skills then
							for index,skillId in pairs(v.skills) do
								if mapSkillInfo[tostring(skillId)] == nil then
									sameSkill = false;
								end
							end
						else
							sameSkill = false;
						end
						if false == sameSkill then
							BP_TeamUpMatchInfo_Show_Skill_Effect = true;
							break;
						end
					end
				end
			end
		end
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_teamup_match_info, "UpdateActivityTipsVisible");
end