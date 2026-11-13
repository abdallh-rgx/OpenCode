UnknowPassAwardUI = UnknowPassAwardUI or
{
	isShowing = false,

	-- 是否为第一次收到通行证数据
	-- 是则初始化通行证界面的奖励列表，这是为了优化通行证界面的打开速度
	isFirstGetInfo = true,

	isNeedInitAwards = true;	-- 是否为第一次打开奖励面板，第一次打开则刷新一次当前的等级位置
	
	-- 通行证当日是否显示过，赛季过期提示消息的key
	seasonExpireConfigKey = "UnknowPassAwardUI.seasonExpireConfigKey";
	
	--是否可以点击积分加号
	bCanClickAddOrSubScore = true,
	nTimerIdClick = 0,
	bShowPassDetail = false,	-- upass通行证升级显示页面
	bFreshed = false,
	bShowBuyScore = false,
}

BP_STRUCT_UnknowPass_Award_Jump_Info = {
	Idx = 0,
	IsElite = false,
	EliteIdx = 0,
}

BP_STRUCT_UnknowPassAward_Item =
{
	resId = 0,
	number = 0,
    gender = 0,
	status = 0,		-- 领取状态,分组用
	groupId = 0, 	-- 分组id
};

-- 奖励状态枚举
BP_ENUM_UNKNOWPASS_NoAward = 0; -- 不存在任何奖励
BP_ENUM_UNKNOWPASS_CanGet = 1;  -- 可以领取奖励
BP_ENUM_UNKNOWPASS_Lock = 2;    -- 奖励未解锁
BP_ENUM_UNKNOWPASS_HasGet = 3;  -- 奖励已领取
BP_ENUM_UNKNOWPASS_NeedBuy = 4;  -- 奖励需要购买

-- 单个等级奖励信息

BP_STRUCT_UnknowPass_Award_Level_Info = 
{
	-- 通行证等级
	level = 1,

	-- 是否解锁
	isUnlock = false,

	-- 是否预览
	isPreview = false,
	
	-- 是否分组显示
	isSplitGroup = false;

	-- 普通奖励
	BP_Array_OrdinaryAward = {
		BP_STRUCT_UnknowPassAward_Item = _G.BP_STRUCT_UnknowPassAward_Item,
	},
	ordinaryAwardState = BP_ENUM_UNKNOWPASS_NoAward,
	
	-- 精英奖励
	BP_Array_EliteAward = {
		BP_STRUCT_UnknowPassAward_Item = _G.BP_STRUCT_UnknowPassAward_Item,
	},
	eliteAwardState = BP_ENUM_UNKNOWPASS_NoAward,
};

BP_UnknowPass_Award_Gender = 1;

BP_UnknowPass_Ticket = 0; --UC点券

-- 当前等级
BP_UnknowPass_Level = 0;

-- 当前分数
BP_UnknowPass_Score = 0;

-- 当前赛季
BP_UnknowPass_Award_Season_Index = 0;

BP_UnknowPass_Award_SeasonName = "";
BP_UnknowPass_Award_SeasonTime = "";

-- 通行证是否已经购买
BP_UnknowPass_HasBuy = false;

-- 通行证最大的奖励条，这个会决定界面最大初始化的奖励个数
BP_UnknowPass_MaxAwardCount = 100;

-- 单个奖励最大的物品种类
BP_UnknowPass_MaxGroupAwardCount = 3;

-- 当前选择的普通奖励等级
BP_UnknowPass_CurrentOrdinaryGetLevel = 0;

-- 当前选择的精英奖励等级
BP_UnknowPass_CurrentEliteGetLevel = 0;

-- 当前选中的物品id
BP_UnknowPass_CurrentSelectItemID = 0;

-- 当前选中的购买积分物品id
BP_UnknowPass_Award_CurrentSelectBuyItemID = 0;

-- 选择购买的积分等级
BP_UnknowPass_BuyLevel = 0;

-- 是否是最大等级
BP_UnknowPass_Award_IsMaxLevel = false;

-- 奖励界面，展示时停留的等级
BP_UnknowPass_Award_StayLevel = 1;

-- 是否有可以领取的奖励
BP_UnknowPass_Award_HasCanGetAward = false;

--订阅状态
BP_UnknowPass_Prime_Status = 0;

--订阅加成
BP_UnknowPass_Prime_Add = "";

BP_UnknowPass_Award_BuyPass_Tips_Num = 0;
BP_UnknowPass_Award_Tips = "";

-- 分组奖励点击的物品GroupId
BP_UnknowPass_CurrentEliteGetGroupID = 0;

-- 当前预览等级
BP_UnknowPass_Current_Preview_Level = 0;

-- 当前观看的物品分组显示价格
BP_UnknowPass_Current_Preview_Price = 0;

-- 当前观看的物品分组显示打折价格
BP_UnknowPass_Current_Preview_DiscountPrice = 0;

-- 当前观看的物品分组显示价格类型
BP_UnknowPass_Current_Preview_PriceType = 0;

-- 奖励列表
BP_ARRAY_UnknowPass_Award_Level_List = 
{
	BP_STRUCT_UnknowPass_Award_Level_Info = _G.BP_STRUCT_UnknowPass_Award_Level_Info, --定义结构体数组，这种写法要作为规范规定下来
};

-- 高亮可预览奖励列表
BP_ARRAY_UnknowPass_Award_Level_Preview_List =
{
	BP_STRUCT_UnknowPass_Award_Level_Info = _G.BP_STRUCT_UnknowPass_Award_Level_Info, --定义结构体数组，这种写法要作为规范规定下来
};

-- 当前预览可以解锁等级
BP_ARRAY_UnknowPass_Award_Preview_Unlock_Level = 0;

-- 注册widget
function bp_unknow_pass_award_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_unknow_pass_award,
	{
		{Path="/Game/UMG/UI_Logic/Lobby/UnknowPass_Award_Logic_BP.UnknowPass_Award_Logic_BP_C", Container="Default", ZOrder=0},
	},
	{"UnknowPass","Lobby"},
	false,
	true
	);
	
	EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, UnknowPassAwardUI.OnInfoUpdate);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_LEVEL_AWARD, UnknowPassAwardUI.OnGetLevelAward);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_SCORE, UnknowPassAwardUI.OnBuyScore);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BATCH_GET_LEVEL_AWARD, UnknowPassAwardUI.OnGetTotalLevelAward);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_GET_UNCLAIMED_SEASON_AWARD, UnknowPassAwardUI.OnGetUnclaimedReward);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, UnknowPassAwardUI.UpdateUC);
end

function bp_unknow_pass_award_OnModeSwitched(gamestatus)
	print("UnknowPassAwardUI bp_unknow_pass_award_OnModeSwitched", gamestatus)
	local status = string.lower(gamestatus)
	if status == "unknowpass" or status == "lobby" then
		UnknowPassAwardUI.RegistControlEvent()
	else
		UnknowPassAwardUI.UnregistControlEvent()
	end
end

function UnknowPassAwardUI.UpdateUC()
	if DataMgr and DataMgr.ticket then
		BP_UnknowPass_Ticket = DataMgr.ticket
		LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "UpdateUC");
	end
end

function UnknowPassAwardUI.Init()
	log("UnknowPassAwardUI ShowUI");
	-- modify by stephezhang 初始化时候不用刷新，收到数据刷新就可以了。这里初始化会卡顿
	UnknowPassAwardUI.isNeedInitAwards = true;
	UnknowPassAwardUI.bShowPassDetail = false;
end

function UnknowPassAwardUI.RegistControlEvent()
	print("UnknowPassAwardUI.RegistControlEvent")
	local AwardUI = UIUtil.GetWidgetByName("bp_unknow_pass_award", "UnknowPass_Award_Logic_BP")
	UnknowPassAwardUI.onClickItemDelegates = {}
	UnknowPassAwardUI.onCreateItemDelegate = AwardUI.uiroot.ReuseList.OnCreateItem:Add(function (widget)
		local clickDelegate
		print("UnknowPassAwardUI add click", widget)
		clickDelegate = widget.ordinaryAward.item1.ItemClickDispatcher:Add(UnknowPassAwardUI.OnClickItem)
		table.insert(UnknowPassAwardUI.onClickItemDelegates, {
			eventDelegate = widget.ordinaryAward.item1.ItemClickDispatcher,
			funcDelegate = clickDelegate,
		})

		clickDelegate = widget.eliteAward.item1.ItemClickDispatcher:Add(UnknowPassAwardUI.OnClickItem)
		table.insert(UnknowPassAwardUI.onClickItemDelegates, {
			eventDelegate = widget.eliteAward.item1.ItemClickDispatcher,
			funcDelegate = clickDelegate,
		})
		clickDelegate = widget.eliteAward.item2.ItemClickDispatcher:Add(UnknowPassAwardUI.OnClickItem)
		table.insert(UnknowPassAwardUI.onClickItemDelegates, {
			eventDelegate = widget.eliteAward.item2.ItemClickDispatcher,
			funcDelegate = clickDelegate,
		})

		clickDelegate = widget.UnknowPass_Award_100.Item1ClickDispatcher:Add(UnknowPassAwardUI.OnClickItem)
		table.insert(UnknowPassAwardUI.onClickItemDelegates, {
			eventDelegate = widget.UnknowPass_Award_100.Item1ClickDispatcher,
			funcDelegate = clickDelegate,
		})
		clickDelegate = widget.UnknowPass_Award_100.Item2ClickDispatcher:Add(UnknowPassAwardUI.OnClickItem)
		table.insert(UnknowPassAwardUI.onClickItemDelegates, {
			eventDelegate = widget.UnknowPass_Award_100.Item2ClickDispatcher,
			funcDelegate = clickDelegate,
		})
	end)
	print("UnknowPassAwardUI UnknowPassAwardUI.onCreateItemDelegate", UnknowPassAwardUI.onCreateItemDelegate)
end

function UnknowPassAwardUI.UnregistControlEvent()
	print("UnknowPassAwardUI.UnregistControlEvent")
	local AwardUI = UIUtil.GetWidgetByName("bp_unknow_pass_award", "UnknowPass_Award_Logic_BP")
	local KismetSystemLibrary = import("KismetSystemLibrary")
	if not KismetSystemLibrary.IsValid(AwardUI) then
		print("UnknowPassAwardUI.UnregistControlEvent AwardUI is not valid!")
		UnknowPassAwardUI.onCreateItemDelegate = nil
		UnknowPassAwardUI.onClickItemDelegates = nil
		return
	end
	if UnknowPassAwardUI.onCreateItemDelegate then
		AwardUI.uiroot.ReuseList.OnCreateItem:Remove(UnknowPassAwardUI.onCreateItemDelegate)
		UnknowPassAwardUI.onCreateItemDelegate = nil
	end

	if UnknowPassAwardUI.onClickItemDelegates then
		for _, v in pairs(UnknowPassAwardUI.onClickItemDelegates) do
			v.eventDelegate:Remove(v.funcDelegate)
		end
		UnknowPassAwardUI.onClickItemDelegates = nil
	end
end

function UnknowPassAwardUI.OnClickItem(itemID, widget)
	print("UnknowPassAwardUI.OnClickItem:", itemID, widget)
	local itemData = Client.GetTableData("Item", itemID)
	local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")

	if itemData and itemData.ItemType == 18 then -- 单条快捷语音
		local AwardUI = UIUtil.GetWidgetByName("bp_unknow_pass_award", "UnknowPass_Award_Logic_BP")
		local key = itemData.ItemSubType
		ActorVoiceSystem.PlaySound(key, AwardUI)
	else
		ActorVoiceSystem.StopSound()
	end
end
function UnknowPassAwardUI.Show()
	UnknowPassAwardUI.isShowing = true;
	UnknowPassAwardUI.bFreshed = false;
	
	if DataMgr and DataMgr.ticket then
		BP_UnknowPass_Ticket = DataMgr.ticket
	end



	BP_UnknowPass_Award_BuyPass_Tips_Num = UnknowPassSystem.Data.get_reward_num_if_buy or 0
	LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "UIShow");
	UIManager.Show(eUIType.eUnknowPassAwardUI);

	-- 如果上赛季的奖励没有领取，则请求领取奖励
	local bSeasonReward = UnknowPassUI.CheckAndShowSeasonReward()
	if not bSeasonReward then
		local bNewSeason = UnknowPassUI.CheckAndShowNewSeason()
		if not bNewSeason then
			UnknowPassUI.CheckAndShowNewbie()
		end
	end

	if not UnknowPassAwardUI.TrySetIsTodayShow() then
		if UnknowPassAwardUI.IsSeasonNearExpire() then
			if UnknowPassAwardUI.HasCanGetReward() then
				local expireTips = UnknowPassSystem.SeasonInfo.cfg.expire_tips;
				if expireTips then
					CommonMessageBoxUI:ShowPanel(1, FuncUtil.GetLocalizeResStr(101001), string.gsub(expireTips, "\\\n", "\n"));
				end
				-- log_tree("UnknowPassSystem.SeasonInfo", UnknowPassSystem.SeasonInfo);
			end
		end
	end

	if UnknowPassAwardUI.isNeedInitAwards then
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "ResetFirstShow");
	end
	
	UnknowPassAwardUI.UpdateAwardList();
	UnknowPassAwardUI.HideSelectItem()
end

function UnknowPassAwardUI.Hide()
	UnknowPassAwardUI.isShowing = false;
	UIManager.Hide(eUIType.eUnknowPassAwardUI);
	UnknowPassAwardUI.HideSelectItem()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "UIHide");
	UnknowPassSystem.StopAction()
	UnknowPassAwardUI.HideUpgradeUI()
end

-- 隐藏选中框
function UnknowPassAwardUI.HideSelectItem()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "HideSelectItem");
end

function UnknowPassAwardUI.Release()
	UnknowPassAwardUI.Hide();
end

-- 显示通行证等级奖励
-- @reward_list 物品列表
function UnknowPassAwardUI.ShowAwardList(reward_list)
	if UnknowPassSystem.IsBuyElite then 	-- 精英走原来的逻辑
		UnknowPassShowAward.ShowUI(UnknowPassSystem:GetAwardList(reward_list));
	else -- 普通账号领取普通奖励走另外的逻辑
		UnknowPassShowOrdinaryAward.ShowUI(UnknowPassSystem:GetAwardList(reward_list))
	end
end

-- 刷新整体数据
function UnknowPassAwardUI.ParseAwardList(upass_data, bUpdateUI)
	upass_data = upass_data or {};

	-- 解析奖励列表
	BP_ARRAY_UnknowPass_Award_Level_List = {};
	BP_ARRAY_UnknowPass_Award_Level_Preview_List = {};
	for i=1,BP_UnknowPass_MaxAwardCount do

		local info = {
			level = i,
			isUnlock = i <= BP_UnknowPass_Level,
			isPreview = false,
			isSplitGroup = false;
			BP_Array_OrdinaryAward = {},
			BP_Array_EliteAward = {},
			ordinaryAwardState = BP_ENUM_UNKNOWPASS_NoAward,
			eliteAwardState = BP_ENUM_UNKNOWPASS_NoAward,
		};

		-- 普通奖励
		if upass_data.ordinary_reward_cfg and upass_data.ordinary_reward_cfg[i] then
			info.BP_Array_OrdinaryAward = UnknowPassAwardUI.GetAwardList(upass_data.ordinary_reward_cfg[i],i);
			
			if upass_data.reward_status.ordinary[i] then
				info.ordinaryAwardState = BP_ENUM_UNKNOWPASS_HasGet;
			elseif i <= BP_UnknowPass_Level then
				info.ordinaryAwardState = BP_ENUM_UNKNOWPASS_CanGet;
			else
				info.ordinaryAwardState = BP_ENUM_UNKNOWPASS_Lock;
			end
		end

		-- 精英奖励
		if upass_data.elite_reward_cfg and upass_data.elite_reward_cfg[i] then
			if not BP_UnknowPass_HasBuy then
				info.eliteAwardState = BP_ENUM_UNKNOWPASS_Lock;
			else
				if upass_data.reward_status.elite[i] then
					info.eliteAwardState = BP_ENUM_UNKNOWPASS_HasGet;
				elseif i <= BP_UnknowPass_Level then
					info.eliteAwardState = BP_ENUM_UNKNOWPASS_CanGet;
				else
					info.eliteAwardState = BP_ENUM_UNKNOWPASS_Lock;
				end				
			end

			info.BP_Array_EliteAward, isSplitGroup = UnknowPassAwardUI.GetAwardList(upass_data.elite_reward_cfg[i], i,info.eliteAwardState);

			info.isPreview = upass_data.elite_reward_cfg[i].spec_show == 1;
			info.isSplitGroup = isSplitGroup;
		end

		table.insert(BP_ARRAY_UnknowPass_Award_Level_List, info);
		if info.isPreview then
			table.insert(BP_ARRAY_UnknowPass_Award_Level_Preview_List, info);
		end
	end

	if bUpdateUI then
		BP_UnknowPass_Award_HasCanGetAward = UnknowPassAwardUI.HasCanGetReward();
		UnknowPassUI.showAwardReddot = BP_UnknowPass_Award_HasCanGetAward;

		UnknowPassUI.UpdateReddot();

		if UnknowPassAwardUI.isFirstGetInfo then
			UnknowPassAwardUI.isFirstGetInfo = false;
			LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "RefreshAwardList");
		end
	end
end

-- event
function UnknowPassAwardUI.OnInfoUpdate(evenType, eventID)
	if nil == UIManager.GetUI(eUIType.eUnknowPassUI) then
		UnknowPassAwardUI.ParseAwardList(UnknowPassSystem.Data, false)
		return;
	end
	
	--是否需要刷新
	local needRefresh = not(UnknowPassAwardUI.bFreshed);
	needRefresh = needRefresh or BP_UnknowPass_Level ~= UnknowPassSystem.Level or BP_UnknowPass_Score ~= UnknowPassSystem.Score;
	needRefresh = needRefresh or BP_UnknowPass_Award_Season_Index ~= UnknowPassSystem.Season;
	needRefresh = needRefresh or BP_UnknowPass_HasBuy ~= UnknowPassSystem.IsBuyElite;
	needRefresh = needRefresh or BP_UnknowPass_MaxAwardCount ~= UnknowPassSystem.MaxLevel

	BP_UnknowPass_Level = UnknowPassSystem.Level;
	BP_UnknowPass_Score = UnknowPassSystem.Score;
	BP_UnknowPass_Award_Season_Index = UnknowPassSystem.Season;
	BP_UnknowPass_HasBuy = UnknowPassSystem.IsBuyElite;
	BP_UnknowPass_MaxAwardCount = UnknowPassSystem.MaxLevel;

	UnknowPassAwardUI.ParseAwardList(UnknowPassSystem.Data, true)
	UnknowPassAwardUI.RefreshUI(needRefresh);
end

function UnknowPassAwardUI.RefreshUI(needRefresh)
	BP_UnknowPass_Award_Gender = DataMgr.avatarData.gamegender
	BP_UnknowPass_Level = UnknowPassSystem.Level;
	BP_UnknowPass_Score = UnknowPassSystem.Score;
	BP_UnknowPass_Award_Season_Index = UnknowPassSystem.Season;
	BP_UnknowPass_HasBuy = UnknowPassSystem.IsBuyElite;
	BP_UnknowPass_MaxAwardCount = UnknowPassSystem.MaxLevel;
	
	if  true == needRefresh then
		UnknowPassAwardUI.UpdateScore();
		UnknowPassAwardUI.UpdatePassIcon();
		UnknowPassAwardUI.UpdateAwardList();
		UnknowPassAwardUI.UpdatePreviewInfo();
	end
	UnknowPassAwardUI.FreshBuyPassTip()

	UnknowPassAwardUI.bFreshed = true;
end

function UnknowPassAwardUI.FreshBuyPassTip()
	--log("UnknowPassAwardUI.FreshBuyPassTip "..UnknowPassSystem.Data.get_reward_num_if_buy)
	BP_UnknowPass_Award_BuyPass_Tips_Num = UnknowPassSystem.Data.get_reward_num_if_buy or 0
	local t1 = FuncUtil.GetLocalizeResStr(4635)
	local t2 = FuncUtil.GetLocalizeResStr(4636)
	local t3 = FuncUtil.GetLocalizeResStr(4637)
	local t4 = FuncUtil.GetLocalizeResStr(4641)
	t3 = string.gsub(t3, "\\n", "")
	BP_UnknowPass_Award_Tips = t1.."\n"..t2.."\n"..t3.."\n"..t4
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "FreshBuyPassTip");
end

function UnknowPassAwardUI.OnGetLevelAward(evenType, eventID, data)
	log_tree("OnGetLevelAward",data)
	for i,info in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if info.level == data.level then
			if data.is_elite_task then
				info.eliteAwardState = BP_ENUM_UNKNOWPASS_HasGet;
				if info.isSplitGroup and info.BP_Array_EliteAward then -- 刷新分组显示逻辑
					for ii,eliteAward in pairs(info.BP_Array_EliteAward) do
						if UnknowPassSystem.Data.reward_status.elite[info.level] then
							eliteAward.status = BP_ENUM_UNKNOWPASS_HasGet;
						else
							if data.group_id == eliteAward.groupId then
								eliteAward.status = BP_ENUM_UNKNOWPASS_HasGet;
							else
								eliteAward.status = BP_ENUM_UNKNOWPASS_NeedBuy;
							end
							
						end
					end
				end 
				UnknowPassSystem.Data.reward_status.elite[info.level] = 1;
			else
				info.ordinaryAwardState = BP_ENUM_UNKNOWPASS_HasGet;
			end
			break;
		end
	end

	BP_UnknowPass_Award_HasCanGetAward = UnknowPassAwardUI.HasCanGetReward();
	UnknowPassUI.showAwardReddot = BP_UnknowPass_Award_HasCanGetAward;
	UnknowPassUI.UpdateReddot();
	UnknowPassAwardUI.UpdateAwardList();

	UnknowPassAwardUI.ShowAwardList(data.reward_list);

	UnknowPassUI.UpdateSexButton();
end

function UnknowPassAwardUI.OnBuyScore()
    if UnknowPassSystem.Level > UnknowPassSystem.BuyBeforeLevel then
		UnknowPassLevelUp.ShowLevelUp();
	end

	BP_UnknowPass_Level = UnknowPassSystem.Level;
	BP_UnknowPass_Score = UnknowPassSystem.Score;

	for i,info in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if info.level <= BP_UnknowPass_Level then
			info.isUnlock = true;

			if info.ordinaryAwardState == BP_ENUM_UNKNOWPASS_Lock then
				info.ordinaryAwardState = BP_ENUM_UNKNOWPASS_CanGet;
			end

			-- 精英奖励
			if info.eliteAwardState == BP_ENUM_UNKNOWPASS_Lock and BP_UnknowPass_HasBuy then
				info.eliteAwardState = BP_ENUM_UNKNOWPASS_CanGet;
				
				if UnknowPassSystem.Data.elite_reward_cfg and UnknowPassSystem.Data.elite_reward_cfg[i] then
					info.BP_Array_EliteAward, isSplitGroup = UnknowPassAwardUI.GetAwardList(UnknowPassSystem.Data.elite_reward_cfg[i], i,info.eliteAwardState);
				end
			end
			
		end
	end

	BP_UnknowPass_Award_HasCanGetAward = UnknowPassAwardUI.HasCanGetReward();
	UnknowPassUI.showAwardReddot = BP_UnknowPass_Award_HasCanGetAward;

	UnknowPassAwardUI.UpdateAwardList();
	UnknowPassAwardUI.UpdateScore();
	UnknowPassAwardUI.UpdatePreviewInfo();
	UnknowPassUI.UpdateReddot();

	--更新购买积分
	if UnknowPassAwardUI.bShowBuyScore == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "OnBuyScoreClick")
	end
end

function UnknowPassAwardUI.OnGetTotalLevelAward(evenType, eventID, reward_list)	
	for i,info in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if info.ordinaryAwardState == BP_ENUM_UNKNOWPASS_CanGet then
			info.ordinaryAwardState = BP_ENUM_UNKNOWPASS_HasGet;
		end

		if info.eliteAwardState == BP_ENUM_UNKNOWPASS_CanGet then
			if info.isSplitGroup and UnknowPassSystem.Data.reward_status.need_by_awards then
				for ii,need_buy_award in pairs(UnknowPassSystem.Data.reward_status.need_by_awards) do
					if need_buy_award.level == info.level then
						for idx, award in ipairs(info.BP_Array_EliteAward) do
							if award.groupId == need_buy_award.group_id then
								award.status = BP_ENUM_UNKNOWPASS_NeedBuy;
							else
								award.status = BP_ENUM_UNKNOWPASS_HasGet;
							end
						end
						break;
					end
				end
			end
			info.eliteAwardState = BP_ENUM_UNKNOWPASS_HasGet;
		end
	end

	UnknowPassAwardUI.isNeedInitAwards = true;
	BP_UnknowPass_Award_HasCanGetAward = UnknowPassAwardUI.HasCanGetReward();
	UnknowPassUI.showAwardReddot = BP_UnknowPass_Award_HasCanGetAward;
	UnknowPassAwardUI.UpdateAwardList();
	UnknowPassUI.UpdateReddot();

	UnknowPassAwardUI.ShowAwardList(reward_list);
end

function UnknowPassAwardUI.OnRelogin()
	log("[yyc] UnknowPassAwardUI.OnRelogin")
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "OnRelogin");
end

function UnknowPassAwardUI.OnGetUnclaimedReward(evenType, eventID, reward_list)
	--log_tree("UnknowPassAwardUI.OnGetUnclaimedReward", reward_list)

	--判断新赛季的动画 
	UnknowPassShowAward.HideCallBack = function()
		local bNewSeason = UnknowPassUI.CheckAndShowNewSeason()
		if not bNewSeason then
			UnknowPassUI.CheckAndShowNewbie()
		end
	end
	UnknowPassShowAward.ShowUI(UnknowPassSystem:GetAwardList(reward_list));
end

-- 切换到奖励界面
function UnknowPassAwardUI.SwitchToAwardPanel()
	UnknowPassAwardUI.bShowBuyScore = false
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "SwitchToAwardPanel");
	UnknowPassSystem.ShowLeftDetailDefault()
end

-- 切换到购买积分界面(购买等级)
function UnknowPassAwardUI.SwitchToBuyScorePanel()	
	UnknowPassAwardUI.bShowBuyScore = true
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "SwitchToBuyScorePanel");
	UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailDefaultAvatar)
end

-- 赛季结束三天，提示用户领取奖励
function UnknowPassAwardUI.IsSeasonNearExpire()
	local seasonEndTime = UnknowPassSystem.SeasonInfo.cfg.end_timestamp;
	--log_tree("seasonEndTime - FuncUtil.GetServerTimeInSec()", seasonEndTime - FuncUtil.GetServerTimeInSec());
	--log_tree("seasonEndTime", seasonEndTime);
	local diffTime = seasonEndTime - FuncUtil.GetServerTimeInSec();
    return 0 < diffTime and diffTime < 3 * 24 * 3600;
end

-- 是否可以领取奖励
function UnknowPassAwardUI.HasCanGetReward()
	for i,info in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if info.ordinaryAwardState == BP_ENUM_UNKNOWPASS_CanGet then
			return true;
		end

		if info.eliteAwardState == BP_ENUM_UNKNOWPASS_CanGet then
			return true;
		end
	end

	return false;
end


-- 返回当天是否显示过的标记，
-- true，已经显示过
-- false，未显示过，并且当日下次调用此接口，将返回true
function UnknowPassAwardUI.TrySetIsTodayShow()
	local lastShowDay = GlobalData.GetGlobalConfigStringValue(UnknowPassAwardUI.seasonExpireConfigKey);
	local currentDay = os.date("!%Y%m%d", FuncUtil.GetServerTimeInSec());

	if currentDay == lastShowDay then
		return true;
	else
		GlobalData.SetGlobalConfigStringValue(UnknowPassAwardUI.seasonExpireConfigKey, currentDay);
		return false;
	end
end

-- bp事件
function EventOrdinaryItemClick()
	BP_UnknowPass_CurrentEliteGetLevel = 0;
	for i,v in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if v.level == BP_UnknowPass_CurrentOrdinaryGetLevel then
			-- log_tree("EventOrdinaryItemClick_Push", v);
            local canGet = v.ordinaryAwardState == BP_ENUM_UNKNOWPASS_CanGet;
			if canGet then				
				UnknowPassSystem.upass_get_level_award_req(v.level, false);
			end
			UnknowPassUI.ShowItemInfo(BP_UnknowPass_CurrentSelectItemID, false, canGet);
		end
	end	
end

-- 精英奖励点击
function EventEliteItemClick()
	BP_UnknowPass_CurrentOrdinaryGetLevel = 0;
	for i,v in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if v.level == BP_UnknowPass_CurrentEliteGetLevel then
			-- log_tree("EventEliteItemClick_Push", v);
			local canGet = v.eliteAwardState == BP_ENUM_UNKNOWPASS_CanGet;
			if canGet then
				UnknowPassSystem.upass_get_level_award_req(v.level, true);
			end
			UnknowPassUI.ShowItemInfo(BP_UnknowPass_CurrentSelectItemID,false, canGet);
		end
	end
end

-- 预览奖励的物品点击
function EventOrdinaryPreviewItemClick()
	UnknowPassUI.ShowItemInfo(BP_UnknowPass_CurrentSelectItemID);
end

-- 通行证购买
function EventUnknowPassAwardBuyClick()
	UnknowPassSystem.StopAction();
	UnknowPassBuy.ShowUI();
end

-- 精英奖励分组奖励获取
function EventUnknowPassAward_SplitGroupItemClicked()
	BP_UnknowPass_CurrentOrdinaryGetLevel = 0;
    log("EventUnknowPassAward_SplitGroupItemClicked")
	log(BP_UnknowPass_CurrentEliteGetLevel)
	log(BP_UnknowPass_CurrentEliteGetGroupID)
    for i,v in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
        if v.level == BP_UnknowPass_CurrentEliteGetLevel then
            for ii,reward in pairs(v.BP_Array_EliteAward) do
                if reward.groupId == BP_UnknowPass_CurrentEliteGetGroupID then
					if reward.status == BP_ENUM_UNKNOWPASS_CanGet then
						UnknowPassChooseAwardUI.Init(v);
						UnknowPassChooseAwardUI.Show();
						LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "HideBuyAnotherEliteAwardItem");
					elseif reward.status == BP_ENUM_UNKNOWPASS_NeedBuy then
						local reward_config = UnknowPassSystem.Award_Group_Data[BP_UnknowPass_CurrentEliteGetGroupID];
						if nil ~= reward_config then
							BP_UnknowPass_Current_Preview_Price = reward_config.show_price;
							BP_UnknowPass_Current_Preview_PriceType =  reward_config.price_type;
							BP_UnknowPass_Current_Preview_DiscountPrice =  reward_config.discount_price;
						end
						LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "ShowBuyAnotherEliteAwardItem");
					else						
						LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "HideBuyAnotherEliteAwardItem");
					end
					UnknowPassUI.ShowItemInfo(reward.resId, true);
					break;
				end
            end
        end
    end
end

function UnknowPassAwardUI.ConfirmBuyAnotherAward()
	for award_id,need_buy_award in pairs(UnknowPassSystem.Data.reward_status.need_by_awards) do
		if need_buy_award.level == BP_UnknowPass_CurrentEliteGetLevel and  need_buy_award.group_id ==  BP_UnknowPass_CurrentEliteGetGroupID then
			log("buy another award key:"..tostring(award_id));
			UnknowPassSystem.upass_buy_level_award_req(award_id);
			break;
		end
	end
end

-- 兑换奖励，分组奖励中已经领取了一个，剩余一个需要兑换才能购买
function EventUnknowPassAward_BuyAnotherSplitGroupItem()
	--处理道具不足
	local benough = UnknowPassSystem.ProcItemNotEnough(BP_UnknowPass_Current_Preview_PriceType, BP_UnknowPass_Current_Preview_DiscountPrice)
	if benough == false then
		return
	end

	--"是否以%s购买%s"
	local fmt = FuncUtil.GetLocalizeResStr("6393");
	-- 先用第一个物品的名称
	local item_id = UnknowPassSystem.Award_Group_Data[BP_UnknowPass_CurrentEliteGetGroupID].reward[1].item_id;
	local cfgItem = Client.GetTableData("Item", item_id)
	local cfgCostItem = Client.GetTableData("Item", BP_UnknowPass_Current_Preview_PriceType)
	if cfgCostItem == nil then
		return
	end
	local costStr = string.format("%s %s",tostring(BP_UnknowPass_Current_Preview_DiscountPrice),cfgCostItem.ItemName)
	local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;
	local tip = fmt
	tip = string.gsub(tip, "{0}", costStr);
	tip = string.gsub(tip, "{1}", cfgItem.ItemName);
	CommonMessageBoxUI:ShowPanel(2, strBuy, tip, UnknowPassAwardUI.ConfirmBuyAnotherAward)
end

-- 精英奖励分组预览
function EventUnknowPassAward_SplitGroupPreviewItemClicked()
	for i,v in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if v.level == BP_UnknowPass_CurrentEliteGetLevel then
			log_tree("BP_Array_EliteAward",v.BP_Array_EliteAward)
			for ii,reward in pairs(v.BP_Array_EliteAward) do
				if reward.groupId == BP_UnknowPass_CurrentEliteGetGroupID then
					UnknowPassUI.ShowItemInfo(reward.resId, true);
					LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "HideBuyAnotherEliteAwardItem");
					break;
				end
			end
		end
	end
end

-- 获取所有奖励
function EventUnknowPassAwardGetAllClick()
	UnknowPassSystem.SelectAwards = {};
	local NeedSelectAwards = {};
	for i,awardInfo in pairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if awardInfo.isSplitGroup then
			local needChooseAward = true;
			if awardInfo.level > UnknowPassSystem.Level then
				needChooseAward = false;
			else
				for ii,awardItem in pairs(awardInfo.BP_Array_EliteAward) do
					if awardItem.status == BP_ENUM_UNKNOWPASS_NeedBuy then
						needChooseAward = false;
						break;
					end
				end
				if needChooseAward then
					table.insert(NeedSelectAwards,awardInfo);
				end
			end
		end
	end
	
	if #NeedSelectAwards > 0 then
		UnknowPassChooseAwardUI.InitTotal(NeedSelectAwards);
	else -- 不需要选择的时候直接一键领取
		UnknowPassSystem.upass_batch_get_level_award_req();
	end
	GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassBatchGetLevelAward)
end

function EventOrdinaryGetClick()
	-- PopUpNoticeUI.ShowNewNotice("EventOrdinaryGetClick_Push" .. BP_UnknowPass_CurrentOrdinaryGetLevel);
	UnknowPassSystem.upass_get_level_award_req(BP_UnknowPass_CurrentOrdinaryGetLevel, false);
end

function EventEliteGetClick()
	-- PopUpNoticeUI.ShowNewNotice("EventEliteGetClick_Push" .. BP_UnknowPass_CurrentEliteGetLevel);
	UnknowPassSystem.upass_get_level_award_req(BP_UnknowPass_CurrentEliteGetLevel, true);
end

-- 奖励界面的购买积分入口
function EventBuyScoreClick()
	UnknowPassUI.HideTab();
	UnknowPassAwardUI.SwitchToBuyScorePanel()
end

-- 关闭购买等级积分面板
function EventCloseBuyScoreClick()
	UnknowPassUI.ShowTab();
	if UnknowPass_Tab_Show == UnknowPass_Tab_Award then
		UnknowPassAwardUI.SwitchToAwardPanel()
	end
end

-- 点按钮显示左侧升级通行证按钮，没有购买通行证才显示
function EventShowUnknowpassDetailClick()
	if BP_UnknowPass_HasBuy == false then
		UnknowPassSystem.ShowLeftDetail(UnkonwPass_ShowLeftDetailUpgradeUI);
	end	
end

-- 快速返回到当前位置
function EventUnknowpassAwardReuseListBack()
	UnknowPassAwardUI.UpdateAwardList()
	UnknowPassAwardUI.InitAwardLevelPosition()
end

function UnknowPassAwardUI.ConfirmBuyScore()
	local diff_score = BP_UnknowPass_BuyLevel * 100 - BP_UnknowPass_Score;
	UnknowPassSystem.upass_buy_score_req(diff_score, BP_UnknowPass_Level, BP_UnknowPass_Score);
	--EventCloseBuyScoreClick_Push();
	--UnknowPassSystem.upass_quick_level_up_req(BP_UnknowPass_BuyLevel, BP_UnknowPass_Level);
end

--购买积分点击加号
function EventUnknowPassAwardBuyClickAddScore()
	if not UnknowPassAwardUI.bCanClickAddOrSubScore then
		return
	end
	UnknowPassAwardUI.bCanClickAddOrSubScore = false
	UnknowPassAwardUI.nTimerIdClick = Timer.InsertTimer(0.5, function()
		UnknowPassAwardUI.bCanClickAddOrSubScore = true
	end,
	false, false);
	
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "ClickAddScore");
end

--购买积分点击+10
function EventUnknowPassAwardBuyClickAddTenScore()
	if not UnknowPassAwardUI.bCanClickAddOrSubScore then
		return
	end
	UnknowPassAwardUI.bCanClickAddOrSubScore = false
	UnknowPassAwardUI.nTimerIdClick = Timer.InsertTimer(0.5, function()
		UnknowPassAwardUI.bCanClickAddOrSubScore = true
	end,
			false, false);

	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "ClickAddTenScore");
end

--购买积分点击减号
function EventUnknowPassAwardBuyClickSubScore()
	if not UnknowPassAwardUI.bCanClickAddOrSubScore then
		return
	end
	UnknowPassAwardUI.bCanClickAddOrSubScore = false
	UnknowPassAwardUI.nTimerIdClick = Timer.InsertTimer(0.5, function()
		UnknowPassAwardUI.bCanClickAddOrSubScore = true
	end,
	false, false);
	
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "ClickSubScore");
end

-- 购买积分的确认操作
function EventBuyScoreConfirmClick()
	--UnknowPassUI.Show();
	--UnknowPassSystem.upass_quick_level_up_req(BP_UnknowPass_BuyLevel, BP_UnknowPass_Level);
	local strBuy = Client.GetTableData("LocalizeRes", "301185").TextValue;--购买
	local itemName = ""  --4576  {0}个等级 ， 4577 {0}个积分
	if BP_UnknowPass_Level < 100 then
		itemName = FuncUtil.GetLocalizeResStr("4576") --{0}个等级
		itemName = string.gsub(itemName, "{0}", tostring(BP_UnknowPass_BuyLevel))
	else
		itemName = FuncUtil.GetLocalizeResStr("4577") --{0}个积分
		itemName = string.gsub(itemName, "{0}", tostring(BP_UnknowPass_BuyLevel * 100))
	end

	local tip = FuncUtil.LocalizeResFormat(301372, tostring(BP_UnknowPass_BuyLevel * 100 - BP_UnknowPass_Score), itemName)
    CommonMessageBoxUI:ShowPanel(2, strBuy, tip, UnknowPassAwardUI.ConfirmBuyScore);
end

-- 购买积分的物品点击操作
function EventUnknowPassAwardBuyItemClick()
	UnknowPassUI.ShowItemInfo(BP_UnknowPass_Award_CurrentSelectBuyItemID);
end

-- 点击规则
function EventUnknowPassAwardRuleClick()
	log("EventUnknowPassAwardRuleClick")
	LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "ShowTips");
end

function UnknowPassAwardUI.UpdateBuyButton()
	LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "UpdateBuyButton");
end

function UnknowPassAwardUI.UpdatePassIcon()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "UpdatePassIcon");
end

function UnknowPassAwardUI.UpdateScore()
	BP_UnknowPass_Award_IsMaxLevel = UnknowPassSystem.Level >= UnknowPassSystem.MaxLevel;
	LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "UpdateScore");
end

function UnknowPassAwardUI.UpdateAwardList()
	if not UnknowPassAwardUI.isShowing then
		return;
	end

	--log_tree("BP_ARRAY_UnknowPass_Award_Level_List", BP_ARRAY_UnknowPass_Award_Level_List);
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "RefreshAwardList");

	-- 更新初始停留位置
	BP_UnknowPass_Award_StayLevel = UnknowPassSystem.Level;
	local bCanGetReward = false
	for i,info in ipairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		if info.ordinaryAwardState == BP_ENUM_UNKNOWPASS_CanGet then
			BP_UnknowPass_Award_StayLevel = info.level;
			bCanGetReward = true
			break;
		end

		if info.eliteAwardState == BP_ENUM_UNKNOWPASS_CanGet then
			BP_UnknowPass_Award_StayLevel = info.level;
			bCanGetReward = true
			break;
		end
	end
	
	if UnknowPassUI.jumpInfo then
		if UnknowPassUI.jumpInfo.Tab1 == 1 then
			local bJumpOK = UnknowPassAwardUI.JumpTo(UnknowPassUI.jumpInfo.itemId)
			UnknowPassUI.jumpInfo = nil
			LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "SetFirstShow");
			
			if bJumpOK == false then
				UnknowPassSystem.ShowLeftDetailDefault();
			end
		end
	else
		--没有可以领取的奖励，减1
		if bCanGetReward == false and BP_UnknowPass_Award_StayLevel > 1 then
			BP_UnknowPass_Award_StayLevel = BP_UnknowPass_Award_StayLevel - 1
		end
		if UnknowPassAwardUI.isNeedInitAwards then
			Timer.InsertTimer(0.2, function()
				UnknowPassAwardUI.InitAwardLevelPosition();
			end , false, true);
			UnknowPassAwardUI.isNeedInitAwards = false;
		end
	end

	Timer.InsertTimer(1.5, function()
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "SetFirstShow");
	end , false, true);
	
	local bPreviewLevel = false;
	local bUnlockLevel = false;
	for i,info in ipairs(BP_ARRAY_UnknowPass_Award_Level_Preview_List) do
		if not bPreviewLevel and info.level >  BP_UnknowPass_Award_StayLevel + 4 then
			BP_UnknowPass_Current_Preview_Level = info.level;
			bPreviewLevel = true;
		end

		if not bUnlockLevel and info.level > UnknowPassSystem.Level then
			BP_ARRAY_UnknowPass_Award_Preview_Unlock_Level = info.level;
			bUnlockLevel = true;
		end
		if bPreviewLevel and bUnlockLevel then
			break;
		end
	end

	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "FetchPreviewInfo");
end

-- 恢复初始位置
function UnknowPassAwardUI.InitAwardLevelPosition()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "InitAwardLevelPosition");
end

-- 退出pass，状态重置
function UnknowPassAwardUI.ResetLevelPositionOnExitPass()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "ResetReuseListOnHidePass");
end

-- 显示最右侧特殊等级突出预览
function UnknowPassAwardUI.UpdatePreviewInfo()
	LuaClassObj.HandleUIMessage(bp_unknow_pass_award, "UpdatePreviewInfo");
end

function UnknowPassAwardUI.GetAwardList(rewardInfo, level, state)
	rewardInfo = rewardInfo or {}
	local awardList = {}
	local isSplit = false;	-- 是否分组
	
	if rewardInfo.reward then
		isSplit = #rewardInfo.reward > 1;
		for i = 1,BP_UnknowPass_MaxGroupAwardCount do
			if rewardInfo.reward[i] then				
				local thisGroupId = rewardInfo.reward[i].item_id;
				local split_group_config = UnknowPassSystem.Award_Group_Data[thisGroupId];	--获取分组表物品
				if split_group_config and split_group_config.reward then
					-- 是否需要查询分组领取状态,如果是分组并且后台返回数据need_by_awards有东西,表示有物品可以购买,表示已经领取了一个物品了
					local need_check_status = false;
					if isSplit and UnknowPassSystem.Data.reward_status.need_by_awards then
						for ii,need_buy_award in pairs(UnknowPassSystem.Data.reward_status.need_by_awards) do
							if need_buy_award.level == level then
								need_check_status = true;
								break;
							end
						end
					end

					local award_status = BP_ENUM_UNKNOWPASS_CanGet;
					if level > BP_UnknowPass_Level or state == BP_ENUM_UNKNOWPASS_Lock then	 --账号等级不到，或者锁定了，物品锁定 
						award_status = BP_ENUM_UNKNOWPASS_Lock;
						need_check_status = false;		
					end
					
					for index = 1,#split_group_config.reward do
						local reward_item = split_group_config.reward[index];
						
						-- 分组的才需要得到各自的状态
						if need_check_status then
							award_status = BP_ENUM_UNKNOWPASS_HasGet;
							--如果是分组并且后台返回数据need_by_awards有东西,表示该物品需要购买,表示已经领取了另一个物品了
							for ii,need_buy_award in pairs(UnknowPassSystem.Data.reward_status.need_by_awards) do
								if need_buy_award.level == level and need_buy_award.group_id == thisGroupId then
									award_status = BP_ENUM_UNKNOWPASS_NeedBuy;
									break;
								end
							end
						elseif state == BP_ENUM_UNKNOWPASS_HasGet then
							award_status = BP_ENUM_UNKNOWPASS_HasGet;
						end
						
						table.insert(awardList, {
							resId = reward_item.item_id;
							number = reward_item.item_num,
							gender = DataMgr.avatarData.gamegender;
							status = award_status;
							groupId = thisGroupId;
							price = reward_item.show_price;
						});

					end -- for
				end
			end		--if rewardInfo.reward[i] then
		end
	end
	
	return awardList,isSplit;
end

function UnknowPassAwardUI.MakeTestData()
	BP_ARRAY_UnknowPass_Award_Level_List = {};
	table.insert(BP_ARRAY_UnknowPass_Award_Level_List, {
		BP_Array_OrdinaryAward = {
			{resId = 402011, number = 2},
			{resId = 101002, number = 1}
		},
		BP_Array_EliteAward = {
			{resId = 101002, number = 1},
		},
	});
end


function UnknowPassAwardUI.JumpTo(ItemId)
	log("ItemId: "..tostring(ItemId))
	local info = {}
	local ToLevel = -1
	for i, v in pairs(BP_ARRAY_UnknowPass_Award_Level_List) do
		local OrdinaryAward = v.BP_Array_OrdinaryAward
		local EliteAward    = v.BP_Array_EliteAward

		local bFind = false
		for _, Item in pairs(OrdinaryAward) do
			if Item.resId == ItemId then
				ToLevel       = v.level
				info.Idx      = i - 1
				info.IsElite  = false
				info.EliteIdx = 0
				break
			else
				local itemList = UnknowPassUI.GetJiPinBoxItemList(Item.resId)
				if itemList then
					for _, vv in pairs(itemList) do
						if vv.itemId == ItemId then
							ToLevel       = v.level
							info.Idx      = i - 1
							info.IsElite  = true
							info.EliteIdx = 0
							bFind = true
							break
						end
					end
				end
			end
			if bFind then
				break
			end
		end
		for idx, Item in pairs(EliteAward) do
			if Item.resId == ItemId then
				ToLevel       = v.level
				info.Idx      = i - 1
				info.IsElite  = true
				info.EliteIdx = idx - 1
				break
			else
				local itemList = UnknowPassUI.GetJiPinBoxItemList(Item.resId)
				if itemList then
					for _, vv in pairs(itemList) do
						if vv.itemId == ItemId then
							ToLevel       = v.level
							info.Idx      = i - 1
							info.IsElite  = true
							info.EliteIdx = idx - 1
							bFind = true
							break
						end
					end
				end
			end
			if bFind then
				break
			end
		end
		if ToLevel >= 0 then
			break
		end
	end
	log("UnknowPassAwardUI.JumpTo: " .. ToLevel)
	if ToLevel < 0 then
		return false
	end
	
	Timer.InsertTimer(0.2, function()
		UnknowPassAwardUI.SelectItemByJumpInfo(info)
		BP_UnknowPass_Award_StayLevel = ToLevel
		UnknowPassAwardUI.InitAwardLevelPosition();
	end , false, true);
	
	return true
end

function UnknowPassAwardUI.SelectItemByJumpInfo(info)
	BP_STRUCT_UnknowPass_Award_Jump_Info = info
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "SelectItemByJumpInfo")
end

-- 更新升级通行证UI
function EventUnknowPassAwardUpdateUpgradeUI()
    log("EventUnknowPassAwardUpdateUpgradeUI")    
    if UnknowPassAwardUI.isShowing then
		UnknowPassSystem.ShowLeftDetailDefault()
    end
end

-- 显示升级通行证UI
function UnknowPassAwardUI.ShowUpgradeUI()
    log("UnknowPassUI.ShowUpgradeUI")
	if UnknowPassAwardUI.bShowPassDetail == false then
		UnknowPassAwardUI.bShowPassDetail = true;
		LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "ShowUpgradePassUI");
	end
end

-- 隐藏升级通行证UI
function UnknowPassAwardUI.HideUpgradeUI()
    log("UnknowPassUI.HideUpgradeUI")
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_award, "HideUpgradePassUI");
	UnknowPassAwardUI.bShowPassDetail = false;
end
