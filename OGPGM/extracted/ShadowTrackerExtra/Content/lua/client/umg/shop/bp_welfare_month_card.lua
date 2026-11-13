-- 福利相关----月卡
WelfareMonthCardUI = WelfareMonthCardUI or {}

local bpLuaClassObj = nil;

--注册Widget
function bp_welfare_month_card_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_welfare_month_card,
		{{Path = "/Game/UMG/UI_Logic/Shop/Welfare_MonthCard_BP.Welfare_MonthCard_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_SHOP_ZORDER}},
		{"Lobby"},
		false,
		false,
		true
	);
end

---------------------------------------------------------
-- bp call lua ------------------------------------------

function WelfareMonthCardUI.B2LConstruct()
	bpLuaClassObj = bp_welfare_month_card;
end

function WelfareMonthCardUI.B2LOnButtonCloseClick()
	WelfareMonthCardUI.HideUI();
end

function WelfareMonthCardUI.B2LOnButtonGetAwardClick()
	MallSystem.GetMonthCardDailyAwardReq();
end

function WelfareMonthCardUI.B2LOnButtonGetGrayClick()
	DataMgr.ShowNoticeByID(430006);
end

-- 购买月卡
function WelfareMonthCardUI.B2LOnButtonBuyClick()
	-- 先显示转圈圈
    ConnectionWaitingUI:Show();
    local funcCall1 = function() ConnectionWaitingUI:Hide() end
    local funcCall2 = function()
		local info = MallSystem.GetMonthCardInfo();
		local cfg = info.cfg;
		Client.MidasPay(cfg.midasProductId,
						  cfg.midasPayItem,
						  cfg.midasCountry,
						  cfg.midasCurrency);
	end
    Timer.InsertTimer(2, funcCall1, false, false)
    Timer.InsertTimer(0.2, funcCall2,false, false);
end

-- 获取详情描述
function WelfareMonthCardUI.B2LGetTipsDesc()
	local res = Client.GetTableData("LocalizeRes",301108);
	if not res then
		return;
	end
	return res.TextValue;
end

function WelfareMonthCardUI.B2LGetAwardItemData()
	local info = MallSystem.GetMonthCardInfo();
	local cfg = info.cfg;
	local itemData = Client.GetTableData("Item", cfg.awardItemId);
	if not itemData then
		return;
	end
	-- 返回道具Id，图标，每日可领取数，可领取总数
	return cfg.awardItemId, 
	       itemData.ItemBigIcon,
	       cfg.awardDailyNum,
	       cfg.awardTotalNum;
end

-- 获取领取摘要信息
function WelfareMonthCardUI.B2LGetAwardBerif()
	local info = MallSystem.GetMonthCardInfo();
	local data = info.data;
	-- 是否已购买，今日是否可领取，已领取次数，剩余次数
	return data.buyFlag,
	       data.getTodayEnabled,
	       data.getAwradTimes,
	       data.lackOfTimes;
end

--获取摘要信息
function WelfareMonthCardUI.B2LGetMonthCardBerif()
	local info = MallSystem.GetMonthCardInfo();
	local cfg = info.cfg;
	-- 一次性获得uc
	return cfg.awardOnOffUC,
	       cfg.productPriceDesc;
end
---------------------------------------------------------
---------------------------------------------------------

function WelfareMonthCardUI.ShowUI()
	LuaClassObj.HandleDynamicCreation(bp_welfare_month_card);

	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_INFO, WelfareMonthCardUI.RefreshMonthCardInfo);
	EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, WelfareMonthCardUI.RefreshMidasProductInfo);
	EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, WelfareMonthCardUI.RefreshMidasProductInfo);

	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BShowUI");
	MallSystem.GetMonthCardInfoReq();
end

function WelfareMonthCardUI.HideUI()
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_MONTH_CARD_INFO, WelfareMonthCardUI.RefreshMonthCardInfo);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, WelfareMonthCardUI.RefreshMidasProductInfo);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, WelfareMonthCardUI.RefreshMidasProductInfo);
	
	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BHideUI");
end

---------------------------------------------------------
-- event notify function
---------------------------------------------------------
function WelfareMonthCardUI.RefreshMonthCardInfo()
	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BRefreshUI");

	-- 避免请求超时，所以这里主动延时刷新下
	local info = MallSystem.GetMonthCardInfo();
	if info.cfg.productPriceDesc == "" then
    	Timer.InsertTimer(2, WelfareMonthCardUI.RefreshMidasProductInfo,false, false);
	end
end

function WelfareMonthCardUI.RefreshMidasProductInfo()
	local info = MallSystem.GetMonthCardInfo();
	info.cfg.productPriceDesc = MidasManager.GetPriceByProductId(info.cfg.midasProductId,
                                                                 info.cfg.midasCurrency,
                                                                 info.cfg.configPrice);
	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BRefreshUI");
end
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------