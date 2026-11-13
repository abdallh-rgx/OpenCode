--称号UI
RoleInfoAliasUI = RoleInfoAliasUI or
{
	CurrentChangeState = 1; --小红点隐藏状态，如果是0表示是预览称号，1表示默认状态和使用称号，1会刷新界面。
	isNeedGuide = false;
	alias_type_warzone_nation = 1; --战区称号子类型
	BP_ALIAS_OPEN_TYPE = 0; --0：大厅界面个人称号选择 1：角色信息界面个人称号选择
	isShow = false,
}

enum_Alias_State_Type =
{
	notHave = 0,
	have = 1,
	use = 2,
}

enum_Alias_Select_Type = {
	all = 0,
	rank = 1,
	achievement = 2,
	fightData = 3,
}

enum_Alias_Sort_Type = {
	default = 0,
	date = 1,
	rarity = 2,
	a_z = 3,
}

enum_Alias_Jump_Type = {
	default = 0,
	season = 1,
	achievement = 2,
	pay = 3,
	fightArea = 4,
	leagueGame = 5,
}


BP_STRUCT_AliasInfo = {
	id = 0,
	aliasState = 0,
	aliasTitle = "",
	aliasReceiveTime = "",
	aliasExpireTime = "",
	aliasDesc = "",
	aliasGetDesc = "",
	aliasType = 0, -- 称号类型
	aliasIconUrl = "", -- 称号iconURL
	aliasQuality = 0, -- 称号品质
	aliasSortWeight = 0, -- 排序权重
	aliasReceiveTimeCompare = 0, -- 用于比较的时间
	aliasIsHaveUse = 0,  -- 0没用过  1 用过
	aliasNation = "", --国家代码
	aliasIconUrlBig = "",
	aliasExpireTimeNum = 0;
}

BP_ARRAY_AliasList = {
	BP_STRUCT_AliasInfo = _G.BP_STRUCT_AliasInfo;
}

BP_ARRAY_TypeListName = {
	"";
}

BP_ARRAY_SortListName = {
	"";
}

BP_Current_CheckHad = 0;		--是否选择已获得
BP_Current_SelectType = 0;		--当前选中类型，0默认为全部
BP_Current_SortType = 0;		--当前排序方式，0为默认ID排序

BP_Current_SelectAliasId = 0;

arr_temp = {
	BP_STRUCT_AliasInfo = _G.BP_STRUCT_AliasInfo;
}



--注册Widget
function bp_roleinfo_alias_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_alias,
		{
		{Path="/Game/UMG/UI_Logic/RoleInfo/Title_managemen2_BP.Title_managemen2_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+20},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end


function RoleInfoAliasUI.Init()
	RoleInfoAliasUI.initTypeList();
	RoleInfoAliasUI.initSortList();
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_alias);
	RoleInfoAliasSystem.Enter();
	--判断是否需要新手引导
	RoleInfoAliasUI.refreshAliasList();
	if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1) and RoleInfoAliasUI.isNeedGuide then
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowNewbieTips2");		
	end	

	isShow = true
end

function RoleInfoAliasUI.Hide()
	isShow = false

	log("RoleInfoAliasUI Hide");
	RoleInfoAliasUI.Release();
	RoleInfoAliasUI.CurrentChangeState = 1;
	if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "HideUI");
	else
		UIManager.Hide(eUIType.eRoleInfoAliasUI)
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "HideUI2");
	end

	UIManager.Hide(eUIType.eRoleinfoAlias)
end

--当前使用称号，以及称号列表数据
function RoleInfoAliasUI.refreshAliasList()
	if isShow == false then return end
	
	initAliasInfo();
	if RoleInfoAliasUI.CurrentChangeState == 1 then
		if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
			LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowUI");
			LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "refreshList");
			LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "upDateAliasItemSelect");
			if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1) and RoleInfoAliasUI.isNeedGuide then
				LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowNewbieTips");
			end
		else
			LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowUI2");
			UIManager.Show(eUIType.eRoleInfoAliasUI)
			LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "refreshList2");
			LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "upDateAliasItemSelect2");
			if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1) and RoleInfoAliasUI.isNeedGuide then
				LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "ShowNewbieTips2");		
			end	
		end
	end
	UIManager.Show(eUIType.eRoleinfoAlias)

	DataMgr.roleData.alias.red_point = 0;
	LobbyUI:UpdateHeadportraitReddot();
	RoleInfoUI.UpdateHeadportraitReddot();
	RoleInfoUI.UpdateAliasInfo();
	LobbyUI:RefreshPlayerData();
end


function EventHideTitleNewbieTips()
	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_TITLE, 1)
end

function sortListFunction(a, b)
	if a.aliasState == b.aliasState then 
		return a.id < b.id;
	else
		return a.aliasState > b.aliasState;
	end 
end

function initAliasInfo()
	BP_ARRAY_AliasList = {};
	arr_temp = {};
	DataMgr.roleData.alias.id = 0;
	DataMgr.roleData.alias.title = "";
	DataMgr.roleData.alias.nation = "";
	RoleInfoAliasUI.isNeedGuide = false;
	BP_Current_SelectAliasId = 0;
	RoleInfoAliasUI.Empty();
	--称号信息
	for _k, _v in pairs(RoleInfoAliasSystem.alias_list_info) do
		local cfg = Client.GetTableData("AliasCfg", _k);
		if cfg ~= nil then
			local myItem = {};
			myItem.id = _k;
			myItem.aliasState = _v.state;
			myItem.aliasQuality = cfg.AliasQuality;
			myItem.aliasDesc = cfg.AliasDesc;
			myItem.aliasGetDesc = cfg.AliasGetDesc;
			myItem.aliasType = tonumber(cfg.AliasType);
			myItem.aliasIconUrl = cfg.AliasIconPath;
			myItem.aliasIconUrlBig = cfg.AliasIconPathBig;
			myItem.aliasSortWeight = cfg.AliasSortWeight;
			myItem.aliasReceiveTimeCompare = _v.receive_time;
			myItem.aliasIsHaveUse = _v.have_used;
			myItem.aliasExpireTimeNum = _v.expire_ts;
			if _v.state == enum_Alias_State_Type.have or _v.state == enum_Alias_State_Type.use then
				--myItem.aliasReceiveTime = FuncUtil.SecToDateString(_v.receive_time);
				myItem.aliasReceiveTime = FuncUtil.LocalizeResFormat( "6422", FuncUtil.SecToDateString(_v.receive_time));
				if _v.expire_ts == 0 then
					myItem.aliasExpireTime = Client.GetTableData("LocalizeRes",301300).TextValue;
				else
					myItem.aliasExpireTime = FuncUtil.SecToDateString(_v.expire_ts);
				end		
				myItem.aliasTitle = _v.title;
				myItem.aliasReceiveTimeCompare = _v.receive_time;
				myItem.aliasIsHaveUse = _v.have_used;	
				myItem.aliasNation = _v.nation;
			else
				myItem.aliasReceiveTime = 0;
				myItem.aliasExpireTime = 0;
				myItem.aliasTitle = cfg.AliasName;
				myItem.aliasReceiveTimeCompare = 0;
				myItem.aliasIsHaveUse = 0;
				myItem.aliasNation = "";
			end
			--发现有可以用的称号，改变状态
			if _v.state == enum_Alias_State_Type.have then
				RoleInfoAliasUI.isNeedGuide = true;
			end
	        if _v.state == enum_Alias_State_Type.use then
	        	BP_STRUCT_AliasInfo = myItem;
	        	
	        	if BP_Current_SelectAliasId == 0 then
	        		BP_Current_SelectAliasId = _k;
	        	end
	        	
	        	--更新个人信息的称号
	        	DataMgr.roleData.alias.id = myItem.id;
	        	DataMgr.roleData.alias.title = myItem.aliasTitle;
	        	DataMgr.roleData.alias.nation = myItem.aliasNation;
	        end
	        table.insert(BP_ARRAY_AliasList, myItem);
	        table.insert(arr_temp, myItem);
		end
	end

	table.sort( BP_ARRAY_AliasList, sortListFunction );
	
	if BP_Current_SelectAliasId == 0 and #BP_ARRAY_AliasList > 0 and RoleInfoAliasUI.isNeedGuide == true then
		BP_Current_SelectAliasId = BP_ARRAY_AliasList[1].id;
		BP_STRUCT_AliasInfo = BP_ARRAY_AliasList[1];
	end

	if #BP_ARRAY_AliasList == 0 then
		BP_STRUCT_AliasInfo = {};
		BP_Current_SelectAliasId = 0;
	end

	--log("BP_Current_SelectAliasId.." .. tostring(BP_Current_SelectAliasId));
	--log("BP_Current_SelectAliasId:" .. BP_Current_SelectAliasId);
	--log_tree("RoleInfoAliasSystem.alias_list_info:",RoleInfoAliasSystem.alias_list_info);
	--log_tree("BP_ARRAY_AliasList:",BP_ARRAY_AliasList);
end

function RoleInfoAliasUI.initTypeList()
	BP_ARRAY_TypeListName= {};
	local data = Client.GetTableData("LocalizeRes",4462);
	table.insert(BP_ARRAY_TypeListName, data.TextValue);
	for id=4675,4677 do
        local data = Client.GetTableData("LocalizeRes",id);
		table.insert(BP_ARRAY_TypeListName, data.TextValue);
 	end
end

function RoleInfoAliasUI.initSortList()
	BP_ARRAY_SortListName = {};
	for id=4670,4673 do
        local data = Client.GetTableData("LocalizeRes",id);
		table.insert(BP_ARRAY_SortListName, data.TextValue);
 	end
end

function RoleInfoAliasUI.Empty()
	BP_STRUCT_AliasInfo = {
	}
end


function RoleInfoAliasUI.Release()
	BP_ARRAY_AliasList = {};
	RoleInfoAliasUI.Empty();
	arr_temp = {};
	BP_ARRAY_TypeListName = {};
	BP_ARRAY_SortListName = {};
	BP_Current_SelectAliasId = 0;
	RoleInfoAliasUI.Empty();
	RoleInfoAliasUI.isNeedGuide = false;
	RoleInfoAliasUI.AliasReddot = 0;
end

function sortFunction(a, b)
	if a.aliasReceiveTimeCompare == b.aliasReceiveTimeCompare then 
		return a.aliasSortWeight > b.aliasSortWeight;
	else
		return a.aliasReceiveTimeCompare > b.aliasReceiveTimeCompare;
	end 
end

--选择显示
function EventSelectCombox()
	--log_tree("EventSelectCombox", arr_temp);
	BP_Current_SelectAliasId = 0;
	RoleInfoAliasUI.Empty();
	BP_ARRAY_AliasList = {};
	--根据类型筛选数据
	for k, v in pairs(arr_temp) do
		if BP_Current_SelectType > 0 then
			if BP_Current_CheckHad == 1 then
				if (v.aliasState == enum_Alias_State_Type.have or v.aliasState == enum_Alias_State_Type.use) and v.aliasType == BP_Current_SelectType then
        			table.insert(BP_ARRAY_AliasList, v);
        			if BP_Current_SelectAliasId == 0 then
        				BP_STRUCT_AliasInfo = v;
        				BP_Current_SelectAliasId = v.id;
        			end
				end
			else
				if v.aliasType == BP_Current_SelectType then
        			table.insert(BP_ARRAY_AliasList, v);
				end
			end
		else
			if BP_Current_CheckHad == 1 then
				if v.aliasState == enum_Alias_State_Type.have or v.aliasState == enum_Alias_State_Type.use then
        			table.insert(BP_ARRAY_AliasList, v);
        			if BP_Current_SelectAliasId == 0 then
        				BP_STRUCT_AliasInfo = v;
        				BP_Current_SelectAliasId = v.id;
        			end
				end
			else
    			table.insert(BP_ARRAY_AliasList, v);
			end
		end
	end
	--[[
	--排序
	if BP_Current_SortType > 0 then
		--获得时间排序--没有获得按权重排序
		if BP_Current_SortType == enum_Alias_Sort_Type.date then
			table.sort( BP_ARRAY_AliasList, sortFunction );
		--稀有度排序
		elseif BP_Current_SortType == enum_Alias_Sort_Type.rarity then
			table.sort( BP_ARRAY_AliasList, function(a,b) return a.aliasQuality > b.aliasQuality end );
		--字母排序
		elseif BP_Current_SortType == enum_Alias_Sort_Type.a_z then
			table.sort( BP_ARRAY_AliasList, function(a,b) return a.aliasTitle < b.aliasTitle end );
		end	
	else
		-- 默认按照ID排序
		table.sort( BP_ARRAY_AliasList, function(a,b) return a.id < b.id end );
	end
	]]
	--[[if BP_Current_SelectAliasId == 0 and #BP_ARRAY_AliasList > 0 then
		BP_Current_SelectAliasId = BP_ARRAY_AliasList[1].id;
	end]]
	table.sort( BP_ARRAY_AliasList, sortListFunction );

	if #BP_ARRAY_AliasList == 0 then
		BP_STRUCT_AliasInfo = {};
		BP_Current_SelectAliasId = 0;
	else
		BP_Current_SelectAliasId = BP_ARRAY_AliasList[1].id;
		BP_STRUCT_AliasInfo = BP_ARRAY_AliasList[1];	
	end

	if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "refreshList");
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "upDateAliasItemSelect");
	else		
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "refreshList2");
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "upDateAliasItemSelect2");
	end
end

function EventAliasUpDateSelect()
	local isNeedChange = false;
	for k, v in pairs(BP_ARRAY_AliasList) do
		if v.id == BP_Current_SelectAliasId then
			if v.aliasState == enum_Alias_State_Type.have and v.aliasIsHaveUse == 0 then
				v.aliasIsHaveUse = 1;
				isNeedChange = true;
			end
			BP_STRUCT_AliasInfo = v;
		end
	end
	if RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE == 0 then
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "updateCurrentAlias");
	else		
		LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "updateCurrentAlias2");
	end
	--LuaClassObj.HandleUIMessage(bp_roleinfo_alias, "upDateAliasItemSelect");
	RoleInfoAliasUI.CurrentChangeState = 0;
	if isNeedChange then
		--log("EventAliasUpDateSelectisNeedChange");
		RoleInfoAliasSystem.change_alias_req(BP_Current_SelectAliasId, RoleInfoAliasUI.CurrentChangeState);
	end
end

function EventUseAlias()
	RoleInfoAliasUI.CurrentChangeState = 1;
	RoleInfoAliasSystem.change_alias_req(BP_Current_SelectAliasId, RoleInfoAliasUI.CurrentChangeState);
end

function EventOnJump()
	local cfg = Client.GetTableData("AliasCfg", BP_Current_SelectAliasId);
	if cfg ~= nil then
		if cfg.AliasJumpUrl == enum_Alias_Jump_Type.season then
			RoleInfoAliasUI.Hide();
			RoleInfoUI.BtnCloseRoleInfo();
			SeasonUI.Show();
			local t = Timer.InsertTimer(1.0, SeasonUI.ShowSeasonAward, false, true);
		elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.achievement then
			RoleInfoAliasUI.Hide();
			--RoleInfoUI.BtnCloseRoleInfo();
			TaskUI.OpenTaskWithIndex(4);--成就移动到任务界面
			--PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 116009).TextValue);
		elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.pay then
			RoleInfoAliasUI.Hide();
			RoleInfoUI.BtnCloseRoleInfo();
			RechargeUI:Init();
		elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.fightArea then
			RoleInfoAliasUI.Hide();
			RoleInfoUI.BtnCloseRoleInfo();
			LobbyUI.EnterWarZone();
			--PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 116009).TextValue);
		elseif cfg.AliasJumpUrl == enum_Alias_Jump_Type.leagueGame then
			RoleInfoAliasUI.Hide();
			RoleInfoUI.BtnCloseRoleInfo();
			LeagueGameLobbyUI.Init();
		end
	end
	log("EventOnJump: RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE " .. RoleInfoAliasUI.BP_ALIAS_OPEN_TYPE);
	-- 在展示信息界面中，个人称号跳转时关闭展示信息界面
	if RoleInfoShowInfoUI.bShow then
		RoleInfoShowInfoUI.Hide();
	end
end

function EventAliasUIHide()
	RoleInfoAliasUI.Hide();
end

function EventRemoveAlias()
	RoleInfoAliasUI.CurrentChangeState = 1;
	RoleInfoAliasSystem.change_alias_req(0, 0);
end
