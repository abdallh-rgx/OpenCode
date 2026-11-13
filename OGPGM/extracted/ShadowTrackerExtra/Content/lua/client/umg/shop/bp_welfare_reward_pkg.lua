-- 福利相关--奖赏包返赠活动。直购后，返回一定UC并赠送道具
WelfareRewardPkgUI = WelfareRewardPkgUI or {}

local bpLuaClassObj = nil;

--注册Widget
function bp_welfare_reward_pkg_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_welfare_reward_pkg,
		{{Path = "/Game/UMG/UI_Logic/Shop/Welfare_RewardPkg_BP.Welfare_RewardPkg_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_SHOP_ZORDER}},
		{"Lobby"},
		false,
		false,
		true
	);
end

---------------------------------------------------------
-- bp call lua ------------------------------------------
function WelfareRewardPkgUI.B2LConstruct()
	bpLuaClassObj = bp_welfare_reward_pkg;
end

function WelfareRewardPkgUI.B2LOnButtonCloseClick()
	WelfareRewardPkgUI.HideUI();
end

function WelfareRewardPkgUI.B2LOnButtonBuyClick()
	-- 先显示转圈圈
    ConnectionWaitingUI:Show();
    local funcCall1 = function() ConnectionWaitingUI:Hide() end
    local funcCall2 = function()
		local info = MallSystem.GetRewardPkgInfo();
		Client.MidasPay(info.midasProductId,
						  info.midasPayItem,
						  info.midasCountry,
						  info.midasCurrency);
	end
    Timer.InsertTimer(2, funcCall1, false, false)
    Timer.InsertTimer(0.2, funcCall2,false, false);
end

function WelfareRewardPkgUI.B2LGetRewardPkgBerif()
	local info = MallSystem.GetRewardPkgInfo();
	local tipsDesc = "";
	if FuncUtil.IsPlayerJP() then
		tipsDesc = Client.GetTableData("LocalizeRes",5019).TextValue;
	else
		tipsDesc = Client.GetTableData("LocalizeRes",5020).TextValue;
	end
	local timeTips = Client.GetTableData("LocalizeRes",4587).TextValue;
	--转换为剩余时间描述
	local lackOfTime = info.actEndTime - FuncUtil.GetServerTimeInSec();
	--local lackOfTimeDesc = timeTips..": "..FuncUtil.TimeFormatExtNoZero(lackOfTime);
	-- 返回  活动截止时间，显示价格，提示描述
	return lackOfTime,
		   info.productPriceDesc,
		   tipsDesc;
end

function WelfareRewardPkgUI.B2LGetRewardItemListCnt()
	local info = MallSystem.GetRewardPkgInfo();
	return #info.rewardItems;
end

function WelfareRewardPkgUI.B2LGetRewardItem(index)
	-- lua数组从1开始
	index = index + 1;
	local info = MallSystem.GetRewardPkgInfo();
	local itemInfo = info.rewardItems[index];
	if not itemInfo then
		return;
	end
	-- 返回 道具数量,道具Id
	return itemInfo.itemNum, itemInfo.itemId;
end
---------------------------------------------------------
---------------------------------------------------------
function WelfareRewardPkgUI.ShowUI()

	--print_r(DataMgr.activity.activityMap);
	local actInfo = ActivitySystem.GetActivityInfoByType(ActivityType["WelFARE_REWARD_PKG"]);
	if not actInfo then
		log("[WelfareRewardPkgUI.ShowUI] has none WelFARE_REWARD_PKG activity info!!!");
		return;
	end

	local lackOfTime = actInfo.EndTime - FuncUtil.GetServerTimeInSec();
	if lackOfTime <= 0 then
		---活动已结束
		DataMgr.ShowNoticeByID(4002);
		log("[WelfareRewardPkgUI.ShowUI] has none lackOfTime <= 0 !!!");
		return;
	end
	if not actInfo.Condition then
		log("[WelfareRewardPkgUI.ShowUI] has none condition in activity info!!!");
		return;
	end
	local info = MallSystem.GetRewardPkgInfo();
	info.productPriceDesc = "";
	------------------------------------------
	------------------------------------------
	------------------------------------------
	LuaClassObj.HandleDynamicCreation(bp_welfare_reward_pkg);

	EventSystem:registEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO, WelfareRewardPkgUI.RefreshRewardPkgInfo);
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR, WelfareRewardPkgUI.RemoveActRewardPkg);
	EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, WelfareRewardPkgUI.RefreshMidasProductInfo);
	EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, WelfareRewardPkgUI.RefreshMidasProductInfo);

	local info = MallSystem.GetRewardPkgInfo();
	info.actEndTime = actInfo.EndTime;
	-- 服务器取直购表信息的潜规则，使用物品Id做为key值
	local itemId = WelfareRewardPkgUI.ParseActivityInfoConditional(actInfo.Condition);
	MallSystem.GetDirectPurchaseInfoReq(itemId);
	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BShowUI");
	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BRefreshUI");
end

function WelfareRewardPkgUI.HideUI()
	EventSystem:unregistEvent(EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO, WelfareRewardPkgUI.RefreshRewardPkgInfo);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR, WelfareRewardPkgUI.RemoveActRewardPkg);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY,EVENTID_MIDAS_GET_RECHARGE_PRODUCT_INFO_NOTIFY, WelfareRewardPkgUI.RefreshMidasProductInfo);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, WelfareRewardPkgUI.RefreshMidasProductInfo);

	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BHideUI");
end

---------------------------------------------------------
-- event notify function
---------------------------------------------------------
function WelfareRewardPkgUI.RefreshRewardPkgInfo()
	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BRefreshUI");
	-- 避免请求超时，所以这里主动延时刷新下
	local info = MallSystem.GetRewardPkgInfo();
	if info.productPriceDesc == "" then
    	Timer.InsertTimer(2, WelfareRewardPkgUI.RefreshMidasProductInfo,false, false);
	end
end

function WelfareRewardPkgUI.RemoveActRewardPkg()
	WelfareRewardPkgUI.HideUI();
end

function WelfareRewardPkgUI.RefreshMidasProductInfo()
	local info = MallSystem.GetRewardPkgInfo();
	info.productPriceDesc = MidasManager.GetPriceByProductId(info.midasProductId,
                                                             info.midasCurrency,
                                                             info.configPrice);

	LuaClassObj.HandleUIMessage(bpLuaClassObj, "L2BRefreshUI");
end
---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------
-- 解析活动所附带的条件，取出物品Id
function WelfareRewardPkgUI.ParseActivityInfoConditional(cond)
	if not cond then
		return nil;
	end
	local strs = string.split(cond, ",");
	if strs and #strs > 0 then
		return tonumber(strs[1]);
	end
	return nil;
end