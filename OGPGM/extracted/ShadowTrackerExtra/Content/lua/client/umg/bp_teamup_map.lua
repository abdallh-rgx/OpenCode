--组队模式选 or
TeamUpMaplUI = TeamUpMaplUI or
{	
	curModelId = 0,
	curModelMapInfo = {},
}

-- 地图数据
BP_STRUCT_TeamUpMapInfo =
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
};

-- 当前显示的地图列表
BP_ARRAY_TeamUpMapInfoList = 
{
	BP_STRUCT_TeamUpMapInfo = _G.BP_STRUCT_TeamUpMapInfo,
};

-- 面板标题
BP_TeamUpMap_Title = "经典模式-四人";	
-- 面板模式
BP_TeamUpMap_Model = "选择地图";	
-- 是否可以选择地图
BP_TeamUpMap_CanSelectMap = true;
-- 是否锁定地图，禁止选择
BP_TeamUpMap_LockSelectMap = false;
-- 当前点击的地图id
BP_TeamUpMap_CurClickMapId = 0;
-- 当前点击的地图的选中状态
BP_TeamUpMap_CurClickMapSelected = true;
-- 当前地图说明
BP_TeamUpMap_CurMapSelectedHelpInfo = "";
-- 当前地图视角类型 0-第一人称 1-第三人称
BP_TeamUpMap_CurModelPerspective = 1;

-- 注册面板
function bp_teamup_map_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_teamup_map,
        {
			{Path="/Game/UMG/UI_Logic/Lobby/Lobby_SelectMap_BP.Lobby_SelectMap_BP_C", Container="Default", ZOrder=BP_ENUM_UI_SELECTMAP_ZORDER},
		},
		{"Lobby"},
		false,
		bp_teamup_map_OnModeSwitched ~= nil
	);		
	
	BP_STRUCT_TeamUpMapInfo = {};
end



function TeamUpMaplUI.ShowPanel(curModelID)
	log("TeamUpMaplUI:ShowPanel "..curModelID);
	
	TeamUpMaplUI.curModelId = curModelID;

	-- 获取当前模式对应的地图数据
	local curModelMapInfo = nil;
	local canSelect = true;
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
		BP_ARRAY_TeamUpMapInfoList = {};
		BP_TeamUpMap_LockSelectMap = not curModelMapInfo.is_optional;
		BP_TeamUpMap_Title = TeamUpModelUI.GetCurModelName();
		
		local modelConfig = Client.GetTableData("MatchModeTable", curModelID);
		if modelConfig and modelConfig.PersonPerspective == 100053 then
			BP_TeamUpMap_CurModelPerspective = 0;
		else
			BP_TeamUpMap_CurModelPerspective = 1;
		end
		
		-- 设置面板相关文字显示
		if TeamUpModelUI.GetCurModelType() == 1 or TeamUpModelUI.GetCurModelType() == 3 then
			BP_TeamUpMap_Model = Client.GetTableData("LocalizeRes", "500036").TextValue;
			BP_TeamUpMap_CurMapSelectedHelpInfo = DataMgr.GetMsgByID(500050);
		else
			BP_TeamUpMap_Model = Client.GetTableData("LocalizeRes", "500037").TextValue;
			BP_TeamUpMap_CurMapSelectedHelpInfo = DataMgr.GetMsgByID(500051);
		end
		
		TeamUpMaplUI.curModelMapInfo = curModelMapInfo;
		log("BP_TeamUpMap_Title "..BP_TeamUpMap_Title);
		log("BP_TeamUpMap_LockSelectMap "..tostring(BP_TeamUpMap_LockSelectMap));
		
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
					subMapName = DataMgr.GetMsgByID(tonumber(infoConfig.Subtitle));
					-- if subMapName ~= "" then
					-- 	mapName = mapName.."—"..subMapName;		
					-- end
					tips = DataMgr.GetMsgByID(tonumber(infoConfig.mapTips));
					forbidTips = DataMgr.GetMsgByID(tonumber(infoConfig.ForbidTips));
					subInfo = DataMgr.GetMsgByID(tonumber(infoConfig.Introduce));
					modelSubName = DataMgr.GetMsgByID(infoConfig.LabelWords);
					isSelect = v.is_default == 1;
										
					if v.need_level > DataMgr.roleData.level then
						--levelLimit = tostring(v.need_level).."级开放";
						levelLimit = FuncUtil.LocalizeResFormat("500040", v.need_level);
					else
						levelLimit = "";
					end				
					
					if not isOpen and hasPreview then
						timeLimitStr = previewStr;
					else
						timeLimitStr = "";
					end
										
					table.insert(BP_ARRAY_TeamUpMapInfoList, 
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
						
						seq = infoConfig.Sort;
					});
				end
			end			
		end

		-- 排序
		table.sort(BP_ARRAY_TeamUpMapInfoList,
			function (a, b)
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
		
		--log_tree("BP_ARRAY_TeamUpMapInfoList", BP_ARRAY_TeamUpMapInfoList);
		
		LuaClassObj.HandleUIMessage(bp_teamup_map, "UIShow");
	--else
		-- 当前模式地图数据异常
		--DataMgr.ShowMessageBoxByID(500041)
	end
end

function TeamUpMaplUI.HidePanel()
	log("TeamUpMaplUI:HidePanel");
	if TeamUpSystem.IsTeamLeader() then
		log("TeamUpMaplUI:HidePanel UpdateModelData")
		-- 更新当前模式数据
		TeamUpModelUI.UpdateCurMapName();
		-- 刷新万圣节tip
		TeamUpModelUI.UpdateTip()
		-- 广播当前模式数据
		TeamUpSystem.team_change_type_request(TeamUpMaplUI.curModelId);
	end

	LuaClassObj.HandleUIMessage(bp_teamup_map, "UIHide");
end

function EventFetchInfo()
	
end

-- 点击关闭按钮
function EventClickClose_Push()
	-- 检查当前模式至少一个选中
	local selectedCount = 0;
	for i,v in ipairs(BP_ARRAY_TeamUpMapInfoList) do
		if v.is_selected then
			selectedCount = selectedCount + 1;
		end
	end

	log("EventClickClose_Push selectedCount:"..selectedCount);
	if selectedCount > 0 then		
		-- 更新当前地图选择状态
		for i,v in ipairs(BP_ARRAY_TeamUpMapInfoList) do
			TeamUpMaplUI.curModelMapInfo = TeamUpSystem.UpdateModelMapInfo(TeamUpMaplUI.curModelId, v.map_id, v.is_selected);
		end
		
		TeamUpMaplUI.HidePanel();
	else
		if TeamUpModelUI.GetCurModelType() == 1 then
			-- 经典模式
			-- 至少需要选择一张地图
			local content = Client.GetTableData("LocalizeRes", "500044").TextValue;
			PopUpNoticeUI.ShowNewNotice(content);
		else
			-- 娱乐模式或其他
			-- 至少需要选择一种玩法
			local content = Client.GetTableData("LocalizeRes", "500043").TextValue;
			PopUpNoticeUI.ShowNewNotice(content);
		end		
	end	
end

-- 点击地图item
function EventClickMapItem_Push()
	log("EventClickMapItem_Push");	

	if not TeamUpSystem.IsTeamLeader() then
		DataMgr.ShowNoticeByID(500045); --队员无法进行选择
		return;
	end

	if TeamUp_Is_Matching then
		DataMgr.ShowNoticeByID(110014); --匹配中无法设置
		return;
	end

	if BP_TeamUpMap_LockSelectMap then
		log("EventClickMapItem_Push is Lock return");
		DataMgr.ShowNoticeByID(500042); --当前模式不可选择玩法
		return;
	end
	
	if BP_TeamUpMap_CurClickMapSelected then
		BP_TeamUpMap_CurClickMapSelected = false;		
	else
		BP_TeamUpMap_CurClickMapSelected = true;
	end

	-- 更新当前地图数据
	for i,v in ipairs(BP_ARRAY_TeamUpMapInfoList) do
		if v.map_id == BP_TeamUpMap_CurClickMapId then
			v.is_selected = BP_TeamUpMap_CurClickMapSelected;
			break;
		end
	end

	--TeamUpMaplUI.curModelMapInfo = TeamUpSystem.UpdateModelMapInfo(TeamUpMaplUI.curModelId, BP_TeamUpMap_CurClickMapId, BP_TeamUpMap_CurClickMapSelected);
	--log_tree("TeamUpMaplUI.curModelMapInfo", TeamUpMaplUI.curModelMapInfo);
	LuaClassObj.HandleUIMessage(bp_teamup_map, "UpdateMapItemSelectStatus");
end
