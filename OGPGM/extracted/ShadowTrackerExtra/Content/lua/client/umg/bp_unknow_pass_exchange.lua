UnknowPassExchangeUI = UnknowPassExchangeUI or
{
	isShow = false;
}

-- 当前分数
BP_UnknowPass_ExchangeScore = 0;

BP_UnknowPass_ExchangeItemId = 0;
BP_UnknowPass_ExchangeBuyCount = 1;

BP_UnknowPass_Exchange_Season_Index = 1;
BP_UnknowPass_Exchange_EnableBuyScoreBtn = false;
BP_UnknowPass_Exchange_BuyScoreTitle = "";
BP_UnknowPass_Exchange_BuyScoreNum = "";
BP_UnknowPass_Exchange_BuyScoreCost = "";

BP_UnknowPass_Exchange_MaxBuyNum = 9900;
BP_UnknowPass_Exchange_MinBuyNum = 100;
BP_UnknowPass_Exchange_CurBuyNum = 0;

--当前金币数量
BP_UnknowPass_Exchange_Gold_Num = 0
BP_UnknowPass_Exchange_UC_Num = 0
BP_UnknowPass_Exchange_Score_Num = 0

--当前pass等级
BP_UnknowPass_Exchange_Pass_Level = 0
BP_UnknowPass_Exchange_Select_Index = 0

-- 单个兑换信息
BP_STRUCT_UnknowPass_Exchange_Item_Info =
{
	exchangeId = 0,		--配置ID
	limit = 0,			--兑换次数限制1-999次
	cost_item_num = 0,	--消耗物品数量
	item_num = 0,			--物品数量
	season_index = 0,		--赛季ID
	sort = 0,				--排序顺序
	pass_level_limit = 0,	--通行证等级限制
	disc_cost_item_num = 0,	--折扣消耗物品数量
	item_id = 0,			--物品ID
	item_expire_time = 0,	--物品有效时间
	item_show_type = 0,		--物品获取展示方式
	cost_item_id = 0,		--消耗物品ID
	buy_count = 0,			--已购买次数
	
	--额外计算变量
	strLevelLimit = "",
	strCostItemIcon = "",
};

-- 兑换列表
BP_ARRAY_UnknowPass_Exchange_Item_List = 
{
	BP_STRUCT_UnknowPass_Exchange_Item_Info = _G.BP_STRUCT_UnknowPass_Exchange_Item_Info,
};

BP_UnknowPass_Exchange_SeasonName = "";
BP_UnknowPass_Exchange_SeasonTime = "";

BP_UnknowPass_Exchange_Title_Tips = ""

-- 注册widget
function bp_unknow_pass_exchange_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_unknow_pass_exchange,
	{
		{Path="/Game/UMG/UI_Logic/Lobby/UnknowPass_Exchange_Logic_BP.UnknowPass_Exchange_Logic_BP_C", Container="Default", ZOrder=0},
		{Path="/Game/UMG/UI_Logic/Lobby/UnknowPass_Exchange_Buy_BP.UnknowPass_Exchange_Buy_BP_C", Container="Default", ZOrder=BP_ENUM_UI_RECHARGE_ZORDER-1},
	},
	{"UnknowPass","Lobby"},
	false,
	false
	);

    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_INFO_UPDATE, UnknowPassExchangeUI.OnInfoUpdate)
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_SCORE, UnknowPassExchangeUI.OnBuyScore)
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_EXCHANGE_SUCCESS, UnknowPassExchangeUI.OnExchangeSuccess)	
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, UnknowPassExchangeUI.On_UC_Gold_Score_Change)
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, UnknowPassExchangeUI.On_UC_Gold_Score_Change)	
	EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ADD_SCORE_NOTIFY, UnknowPassExchangeUI.On_UC_Gold_Score_Change);
	EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_SCORE, UnknowPassExchangeUI.On_UC_Gold_Score_Change);
end

function UnknowPassExchangeUI.Init()
end

--显示兑换页面
function UnknowPassExchangeUI.Show()
	UnknowPassExchangeUI.UpdateData()
	UnknowPassExchangeUI.HideSelectItem();
	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "UIShow");
	UIManager.Show(eUIType.eUnknowPassExchangeUI);
	UnknowPassExchangeUI.isShow = true
	if UnknowPassUI.jumpInfo then
		if UnknowPassUI.jumpInfo.Tab1 == 2 then
			UnknowPassExchangeUI.JumpTo(UnknowPassUI.jumpInfo.itemId)
		end
	end
end

-- 隐藏选中
function UnknowPassExchangeUI.HideSelectItem()
	BP_UnknowPass_Exchange_Select_Index = -1
	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "UpdateSelect");
end

--关闭兑换页面
function UnknowPassExchangeUI.Hide()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange, "CloseBuyDialog");
	UIManager.Hide(eUIType.eUnknowPassExchangeUI);
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange, "UIHide");
	UnknowPassExchangeUI.isShow = false
end

function UnknowPassExchangeUI.Release()
	UnknowPassExchangeUI.Hide();
end

function UnknowPassExchangeUI.GetItemIndex(itemId)
	for i=1,#BP_ARRAY_UnknowPass_Exchange_Item_List,1 do
		if BP_ARRAY_UnknowPass_Exchange_Item_List[i].item_id == itemId then
			return i-1
		else
			local itemList = UnknowPassUI.GetJiPinBoxItemList(BP_ARRAY_UnknowPass_Exchange_Item_List[i].item_id)
			if itemList then
				for _, v in pairs(itemList) do
					if v.itemId == itemId then
						return i - 1
					end
				end
			end
		end
	end
	return 0
end

function UnknowPassExchangeUI.JumpTo(itemId)
	BP_UnknowPass_Exchange_Select_Index = UnknowPassExchangeUI.GetItemIndex(itemId)
	local itemInfo = BP_ARRAY_UnknowPass_Exchange_Item_List[BP_UnknowPass_Exchange_Select_Index + 1]
	if itemInfo == nil then
		return
	end
	UnknowPassUI.ShowItemInfo(itemInfo.item_id)
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange, "UpdateSelect");
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange, "JumpToSelect");
end

function UnknowPassExchangeUI.UpdateData()
	BP_UnknowPass_Exchange_Gold_Num = DataMgr.gold
	BP_UnknowPass_Exchange_UC_Num = DataMgr.ticket or 0
	if UnknowPassSystem.Level < UnknowPassSystem.MaxLevel then
		BP_UnknowPass_Exchange_Score_Num = 0;
	else
		BP_UnknowPass_Exchange_Score_Num = UnknowPassSystem.Score;
	end
	BP_UnknowPass_Exchange_Pass_Level = UnknowPassSystem.Level
	if UnknowPassSystem.IsBuyElite then
		BP_UnknowPass_Exchange_Title_Tips = ""--FuncUtil.GetLocalizeResStr("502014");
	else
		BP_UnknowPass_Exchange_Title_Tips = FuncUtil.GetLocalizeResStr("6400");
	end
end

function UnknowPassExchangeUI.UpdateScore()
	if UnknowPassSystem.Level < UnknowPassSystem.MaxLevel then
		BP_UnknowPass_ExchangeScore = 0;
	else
		BP_UnknowPass_ExchangeScore = UnknowPassSystem.Score;
	end

	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "UpdateScore");
end

-- event
function UnknowPassExchangeUI.OnInfoUpdate(evenType, eventID)
	BP_UnknowPass_Exchange_Season_Index = UnknowPassSystem.Season;
	UnknowPassExchangeUI.UpdateScore();
	UnknowPassExchangeUI.On_UC_Gold_Score_Change()
end

function UnknowPassExchangeUI.OnBuyScore()
	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "CloseBuyDialog");
	PopUpNoticeUI.ShowNewNotice(FuncUtil.GetLocalizeResStr("4304"));
	UnknowPassExchangeUI.UpdateScore();
end

function UnknowPassExchangeUI.OnExchangeSuccess(evenType, eventID, reward_list)
	log_tree("reward_list", reward_list);
	UnknowPassShowAward.ShowUI(UnknowPassSystem:GetAwardList(reward_list));
end

--UC变化
function UnknowPassExchangeUI.On_UC_Gold_Score_Change()
	UnknowPassExchangeUI.UpdateData()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange, "FreshUCGoldScore");
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_exchange, "FreshTitleTips");
end

--sami 点击兑换格子，预览道具信息
function EventUnknowPassExchangeItemClick_Push()
	local itemInfo = BP_ARRAY_UnknowPass_Exchange_Item_List[BP_UnknowPass_Exchange_Select_Index + 1]
	if itemInfo == nil then
		return
	end
	UnknowPassUI.ShowItemInfo(itemInfo.item_id)
end

--sami 点击兑换按钮
function EventUnknowPassExchangeGetClick_Push()
	log("EventUnknowPassExchangeGetClick_Push")
	local itemInfo = BP_ARRAY_UnknowPass_Exchange_Item_List[BP_UnknowPass_Exchange_Select_Index + 1]
	if itemInfo == nil then
		return
	end
	if itemInfo.buy_count < itemInfo.limit then
		if UnknowPassSystem.IsBuyElite == false then
			local title = FuncUtil.GetLocalizeResStr("101001");
			local tip = FuncUtil.GetLocalizeResStr("6399");
			CommonMessageBoxUI:ShowPanel(2, title, tip, function ()
				UnknowPassBuy.ShowUI()
			end);
			return
		end
		
		BP_UnknowPass_Confirm_ExchangeId = itemInfo.exchangeId;
		BP_UnknowPass_Confirm_ExchangeItemId = itemInfo.item_id;
		BP_UnknowPass_Confirm_Cost_ItemId = itemInfo.cost_item_id;
		BP_UnknowPass_Confirm_Cost_ItemNum = itemInfo.disc_cost_item_num;
		BP_UnknowPass_Confirm_BuyCount = itemInfo.buy_count;
		BP_UnknowPass_Confirm_Limit = itemInfo.limit;
		UnknowPassExchangeConfirm.ShowUI();
	else
		UnknowPassSystem:PopErrorMsg(502012);
	end
end

function EventUnknowPassExchangeEnableBuyScoreBtn()
	if UnknowPassSystem.Level < UnknowPassSystem.MaxLevel then
		BP_UnknowPass_Exchange_EnableBuyScoreBtn = false;
	else
		BP_UnknowPass_Exchange_EnableBuyScoreBtn = true;
	end
	log("[HHF]EventUnknowPassExchangeEnableBuyScoreBtn, Enable = " .. tostring(BP_UnknowPass_Exchange_EnableBuyScoreBtn));
	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "UpdateBuyScoreBtnState");
end

function EventUnknowPassExchangeOpenBuyDialog()
	BP_UnknowPass_Exchange_CurBuyNum = 100
	BP_UnknowPass_Exchange_BuyScoreTitle = string.gsub(FuncUtil.GetLocalizeResStr("4575"), "{0}", tostring(BP_UnknowPass_Exchange_CurBuyNum));
	BP_UnknowPass_Exchange_BuyScoreNum = string.gsub(FuncUtil.GetLocalizeResStr("4577"), "{0}", BP_UnknowPass_Exchange_CurBuyNum);
	BP_UnknowPass_Exchange_BuyScoreCost = BP_UnknowPass_Exchange_CurBuyNum;
	log("[HHF]EventUnknowPassExchangeOpenBuyDialog, title = " .. BP_UnknowPass_Exchange_BuyScoreTitle .. ", num = " .. BP_UnknowPass_Exchange_BuyScoreNum .. ", cost = " .. BP_UnknowPass_Exchange_BuyScoreCost);

	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "OpenBuyDialog");
	UIManager.Show(eUIType.eUnknowPassExchangeUI)
end

function EventUnknowPassExchangeAdd()
	BP_UnknowPass_Exchange_CurBuyNum = BP_UnknowPass_Exchange_CurBuyNum + 100;
	if BP_UnknowPass_Exchange_CurBuyNum > BP_UnknowPass_Exchange_MaxBuyNum then
		BP_UnknowPass_Exchange_CurBuyNum = BP_UnknowPass_Exchange_MaxBuyNum
	end
	BP_UnknowPass_Exchange_BuyScoreTitle = string.gsub(FuncUtil.GetLocalizeResStr("4575"), "{0}", BP_UnknowPass_Exchange_CurBuyNum);
	BP_UnknowPass_Exchange_BuyScoreNum = string.gsub(FuncUtil.GetLocalizeResStr("4577"), "{0}", BP_UnknowPass_Exchange_CurBuyNum);
	BP_UnknowPass_Exchange_BuyScoreCost = BP_UnknowPass_Exchange_CurBuyNum;
	log("[HHF]EventUnknowPassExchangeAdd, title = " .. BP_UnknowPass_Exchange_BuyScoreTitle .. ", num = " .. BP_UnknowPass_Exchange_BuyScoreNum .. ", cost = " .. BP_UnknowPass_Exchange_BuyScoreCost);

	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "UpdateBuyDialog");
end

function EventUnknowPassExchangeSub()
	BP_UnknowPass_Exchange_CurBuyNum = BP_UnknowPass_Exchange_CurBuyNum - 100;
	if BP_UnknowPass_Exchange_CurBuyNum < BP_UnknowPass_Exchange_MinBuyNum then
		BP_UnknowPass_Exchange_CurBuyNum = BP_UnknowPass_Exchange_MinBuyNum
	end
	BP_UnknowPass_Exchange_BuyScoreTitle = string.gsub(FuncUtil.GetLocalizeResStr("4575"), "{0}", BP_UnknowPass_Exchange_CurBuyNum);
	BP_UnknowPass_Exchange_BuyScoreNum = string.gsub(FuncUtil.GetLocalizeResStr("4577"), "{0}", BP_UnknowPass_Exchange_CurBuyNum);
	BP_UnknowPass_Exchange_BuyScoreCost = BP_UnknowPass_Exchange_CurBuyNum;
	log("[HHF]EventUnknowPassExchangeSub, title = " .. BP_UnknowPass_Exchange_BuyScoreTitle .. ", num = " .. BP_UnknowPass_Exchange_BuyScoreNum .. ", cost = " .. BP_UnknowPass_Exchange_BuyScoreCost);

	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "UpdateBuyDialog");
end

function EventUnknowPassExchangeBuy()	
	local strBuy = FuncUtil.GetLocalizeResStr("301185");
	local itemName = FuncUtil.GetLocalizeResStr("4577");
	itemName = string.gsub(itemName, "{0}", tostring(BP_UnknowPass_Exchange_CurBuyNum));
	local tip = FuncUtil.LocalizeResFormat("301372", tostring(BP_UnknowPass_Exchange_CurBuyNum), itemName);
    CommonMessageBoxUI:ShowPanel(2, strBuy, tip, UnknowPassExchangeUI.ConfirmBuyScore);
end

function UnknowPassExchangeUI.ConfirmBuyScore()
	log("[HHF]UnknowPassExchangeUI.ConfirmBuyScore, buyNum = " .. tostring(BP_UnknowPass_Exchange_CurBuyNum) .. ", CurrentScore = " .. tostring(UnknowPassSystem.Score));
	UnknowPassSystem.upass_buy_score_req(BP_UnknowPass_Exchange_CurBuyNum, UnknowPassSystem.Level, UnknowPassSystem.Score);
end

function EventFetchUnknowPassExchangeInfo()
	-- body
end

--点击充值UC
function EventUnknowPassExchange_ClickAddUC()
	log("EventUnknowPassExchange_ClickAddUC")
	RechargeUI:Init()
end

function EventUnknowPassExchange_ClickCannotExchange()
	log("EventUnknowPassExchange_ClickCannotExchange")
	local itemInfo = BP_ARRAY_UnknowPass_Exchange_Item_List[BP_UnknowPass_Exchange_Select_Index + 1]
	if itemInfo == nil then
		return
	end
	local tip = FuncUtil.GetLocalizeResStr("6392");
	tip = string.format(tip, itemInfo.pass_level_limit);
	PopUpNoticeUI.ShowNewNotice(tip)
end

-- 积分加1000按钮
function EventUnknowPassExchangeAddTen()
	BP_UnknowPass_Exchange_CurBuyNum = BP_UnknowPass_Exchange_CurBuyNum + 1000;
	if BP_UnknowPass_Exchange_CurBuyNum > BP_UnknowPass_Exchange_MaxBuyNum then
		BP_UnknowPass_Exchange_CurBuyNum = BP_UnknowPass_Exchange_MaxBuyNum
	end
	BP_UnknowPass_Exchange_BuyScoreTitle = string.gsub(FuncUtil.GetLocalizeResStr("4575"), "{0}", BP_UnknowPass_Exchange_CurBuyNum);
	BP_UnknowPass_Exchange_BuyScoreNum = string.gsub(FuncUtil.GetLocalizeResStr("4577"), "{0}", BP_UnknowPass_Exchange_CurBuyNum);
	BP_UnknowPass_Exchange_BuyScoreCost = BP_UnknowPass_Exchange_CurBuyNum;
	log("[HHF]EventUnknowPassExchangeAdd, title = " .. BP_UnknowPass_Exchange_BuyScoreTitle .. ", num = " .. BP_UnknowPass_Exchange_BuyScoreNum .. ", cost = " .. BP_UnknowPass_Exchange_BuyScoreCost);

	LuaClassObj.HandleUIMessage(bp_unknow_pass_exchange, "UpdateBuyDialog");
end
