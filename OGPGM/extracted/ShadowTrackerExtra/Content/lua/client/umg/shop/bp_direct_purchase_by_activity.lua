-- 与活动绑定的直购,使用BP_ENUM_LOBBY_MENU_PURCHASE = 10504;--直购作为module id
Direct_Purchase_By_Ativity_UI = Direct_Purchase_By_Ativity_UI or 
{
	isShowing = false;
	activityId = 0,
}

BP_DirectPurchase_By_Activity_ImageUrl = "";	-- 商品礼包显示贴图
BP_DirectPurchase_By_Activity_IsOneDay = false;	-- 倒计时时间类型,用于switcher使用
BP_DirectPurchase_By_Activity_DataValue = "";	-- 倒计时时间
BP_DirectPurchase_By_Activity_CurrentPrice = "$19.99";	-- 商品当前价格显示,默认初始值为19.99

BP_Direct_Purchase_By_Activity_ServeryTime = 0;			-- 当前服务器时间
BP_Direct_Purchase_By_Activity_EndTime = 0;				-- 活动结束时间

BP_Direct_Purchase_By_Activity_IsJPKR = false;			-- 日韩活动显示不一样
BP_Direct_Purchase_By_Activity_Title = "";				-- 活动显示描述

local Direct_Purchase_ItemID = 0;						-- 礼包id

local Direct_Purchase_EndTime = 0;						-- 活动结束时间
local UpdateTimer = nil;								-- 时间更新timer
local InitiallyTimeOffset = 0;  						-- 本地时间与服务器时间偏移值
local Threshold = 2;									-- offset阈值

BP_STRUCT_DirectPurchase_By_Activity_Item_Info = 
{
    index = 0,	--因为奖励的id可能会相同，所以用index来区分
    id = 0,		-- 掉落物品id
    num = 0,	-- 掉落物品数量
	limit_time = 0,	--物品时效
}

BP_ARRAY__DirectPurchase_By_Activity_ItemInfoList = 
{
	BP_STRUCT_DirectPurchase_By_Activity_Item_Info = BP_STRUCT_DirectPurchase_By_Activity_Item_Info;
}

--注册Widget
function bp_direct_purchase_by_activity_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_direct_purchase_by_activity,
		{{Path = "/Game/UMG/UI_Logic/Lobby_Store/Lobby_Direct_Purchase_By_Activity_BP.Lobby_Direct_Purchase_By_Activity_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_DIRECT_PURCHASE_ZORDER}},
		{"Lobby"},
		false,
		false,
		true
	);
end

-- 刷新商品信息、显示UI
function Direct_Purchase_By_Ativity_UI.ShowUI()	
	log("Direct_Purchase_By_Ativity_UI.ShowUI");
	-- 避免请求超时，所以这里主动延时刷新下
	local rewardPkgInfo = MallSystem.GetRewardPkgInfo();
	local items = RechargePurchaseSystem.ChestInfoList[Direct_Purchase_ItemID];
	if items == nil or rewardPkgInfo == nil then
		return
	end
	-- 掉落物品集合
	BP_ARRAY__DirectPurchase_By_Activity_ItemInfoList = {};
	if nil ~= items and #items > 0 then
		for i, item in ipairs(items) do
			if nil ~= item then
				local data = {};
				data.index = i;
				data.id = item.DropItemID or 0;
				data.num = item.DropItemNum or 0;
				data.limit_time = item.DropItemTime or 0;
				if data.limit_time == 0 then
					local cfg = Client.GetTableData("Item", data.id);
					if cfg and cfg.ValidTimes and cfg.ValidTimes ~= 0 then
						data.limit_time = cfg.ValidTimes;
					end
				end
				table.insert(BP_ARRAY__DirectPurchase_By_Activity_ItemInfoList, data);
			end
		end
	end

	LuaClassObj.HandleDynamicCreation(bp_direct_purchase_by_activity);	
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR, Direct_Purchase_By_Ativity_UI.HideUI);
	EventSystem:registEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, Direct_Purchase_By_Ativity_UI.RefreshMidasProductInfo);

	Direct_Purchase_By_Ativity_UI.isShowing = true;
	LuaClassObj.HandleUIMessage(bp_direct_purchase_by_activity, "ShowUI");
	
	-- 如果id已经缓存，直接读取，当前只缓存一个id
	if Direct_Purchase_ItemID == rewardPkgInfo.item_id and rewardPkgInfo.productPriceDesc ~= "" then
		Direct_Purchase_By_Ativity_UI.RefreshMidasProductInfo();
	end
	InitiallyTimeOffset = FuncUtil.GetServerTimeInSec() - os.time();
	if nil == UpdateTimer then
		UpdateTimer = Timer.InsertTimer(0.5, Direct_Purchase_By_Ativity_UI.TickTimer, true, true);
	end	
end

-- 隐藏UI
function Direct_Purchase_By_Ativity_UI.HideUI()
	EventSystem:unregistEvent(EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, Direct_Purchase_By_Ativity_UI.ShowUI);
	EventSystem:unregistEvent (EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO, Direct_Purchase_By_Ativity_UI.ShowUI);
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CR, Direct_Purchase_By_Ativity_UI.HideUI);
	EventSystem:unregistEvent(EVENTTYPE_MIDAS_NOTIFY, EVENTID_MIDAS_GET_GOODS_PRODUCT_INFO_NOTIFY, Direct_Purchase_By_Ativity_UI.RefreshMidasProductInfo);
	LuaClassObj.HandleUIMessage(bp_direct_purchase_by_activity, "HideUI");
	Direct_Purchase_By_Ativity_UI.isShowing = false;
	if nil ~= UpdateTimer then
		Timer.RemoveTimer(UpdateTimer);
		UpdateTimer = nil;
	end
	tempTime = 0;
end

-- 检测活动是否到期
local function CheckActivityIsValid()
	local lackOfTime = Direct_Purchase_EndTime - FuncUtil.GetServerTimeInSec();
	if nil ~= lackOfTime then
		if lackOfTime <= 0 then
			---活动已结束
			DataMgr.ShowNoticeByID(4002);
			log("[Direct_Purchase_By_Ativity_UI.ShowUI] has none lackOfTime <= 0 !!!");
			LobbySystem.QueryActivityDisplayStatus()  -- 拉取一次banner
			return false;
		end
	end
	return true
end

-- 响应活动跳转,初始化活动数据,拉取商品信息
function Direct_Purchase_By_Ativity_UI.InitData(eventType, eventID, vars)
	log("Direct_Purchase_By_Ativity_UI.InitData");
	local activityId = tonumber(vars.dpid);
	local actInfo = ActivitySystem.GetActivityByID(activityId);
	if not actInfo then
		DataMgr.ShowNoticeByID(4002);
		log("[Direct_Purchase_By_Ativity_UI.ShowUI] has none Direct_Purchase_By_Ativity activity info!!!");
		return;
	end

	Direct_Purchase_By_Ativity_UI.activityId = activityId

	log_tree("actInfo:",actInfo);

	BP_Direct_Purchase_By_Activity_Title = actInfo.Title;
	BP_DirectPurchase_By_Activity_ImageUrl = actInfo.ImgUrl;
	
	Direct_Purchase_EndTime = actInfo.EndTime;		-- 获取结束时间

	if false == CheckActivityIsValid() then
		return;
	end
	BP_Direct_Purchase_By_Activity_IsJPKR = FuncUtil.IsPlayerJPKR();
	Direct_Purchase_By_Ativity_UI.UpdateTime();	
	-- 注册打开界面消息监听
	EventSystem:registEvent (EVENTTYPE_MALL, EVENTID_MALL_REWARD_PKG_INFO, Direct_Purchase_By_Ativity_UI.ShowUI);
	EventSystem:registEvent (EVENTTYPE_RECHARGE, EVENTID_RECHARGE_GET_CHEST_INFO, Direct_Purchase_By_Ativity_UI.ShowUI);

	-- 服务器取直购表信息的潜规则，使用物品Id做为key值
	Direct_Purchase_ItemID = Direct_Purchase_By_Ativity_UI.ParseActivityInfoConditional(actInfo.Condition);
	MallSystem.GetDirectPurchaseInfoReq(Direct_Purchase_ItemID);
	RechargePurchaseSystem.GetChestInfo(Direct_Purchase_ItemID);
end

-- 定时器刷新显示
function Direct_Purchase_By_Ativity_UI.TickTimer()
	Direct_Purchase_By_Ativity_UI.UpdateTime();
end


-- 更新时间
function Direct_Purchase_By_Ativity_UI.UpdateTime()
	local currentTimeOffset = FuncUtil.GetServerTimeInSec() - os.time();		
	if math.abs(currentTimeOffset - InitiallyTimeOffset) > Threshold then
		InitiallyTimeOffset = currentTimeOffset;	-- 时间差别过大刷新偏移值
	end
	local lackOfTime = Direct_Purchase_EndTime - os.time() - InitiallyTimeOffset;
	if lackOfTime < 0 then		-- 时间到了就关闭活动界面并且随机时间后拉取banner
		DataMgr.ShowNoticeByID(4002);
		Direct_Purchase_By_Ativity_UI.HideUI();
		local reqTime = XRandom.Random2(10,30);
		Timer.InsertTimer(reqTime, LobbySystem.QueryActivityDisplayStatus,false)
	elseif lackOfTime > 86400 then		-- 大于一天,显示时间
		BP_DirectPurchase_By_Activity_IsOneDay = false;
		BP_DirectPurchase_By_Activity_DataValue = math.ceil(lackOfTime / 86400);
	else	-- 小于一天显示 xx:xx:xx
		BP_DirectPurchase_By_Activity_IsOneDay = true;
		if BP_DirectPurchase_By_Activity_DataValue ~= lackOfTime then
			BP_DirectPurchase_By_Activity_DataValue = lackOfTime;
			if Direct_Purchase_By_Ativity_UI.isShowing == true then
				LuaClassObj.HandleUIMessageNoFetch(bp_direct_purchase_by_activity, "ShowTime");
			end
		end
	end
end

function Direct_Purchase_By_Ativity_UI.MidasGoods()

	local info = MallSystem.GetRewardPkgInfo();
	log_tree("RewardPkgInfo",info);
	log("midas buy goods");
	-- 使用直购接口MidasGoods;MidasPay是游戏币购买接口
	Client.MidasGoods(info.midasProductId,
			info.midasPayItem,
			info.midasPrice,
			info.midasCountry,
			info.midasCurrency);
end

-- 响应购买按钮
function EventDirectPurchaseByActivityBuyClick()

	if Direct_Purchase_By_Ativity_UI.activityId ~= 0 then
		RechargePurchaseSystem.GetBuyPreCheckReq(Direct_Purchase_By_Ativity_UI.activityId);
	end

	---- 先显示转圈圈
    --ConnectionWaitingUI:Show();
    --local funcCall1 = function() ConnectionWaitingUI:Hide() end
    --local funcCall2 = function()
	--
	--end
    --Timer.InsertTimer(2, funcCall1, false, false)
    --Timer.InsertTimer(0.2, funcCall2,false, false);
end



-- 活动到期，关闭界面，重新拉取活动数据
function  EventDirectPurchaseByActivityReqActivity()
	LobbySystem.QueryActivityDisplayStatus()
end

-- 响应关闭按钮关闭
function  EventDirectPurchaseByActivityClose()
	Direct_Purchase_By_Ativity_UI.HideUI();
end

-- 米大师物品回调刷新商品价格信息
function Direct_Purchase_By_Ativity_UI.RefreshMidasProductInfo()
	local info = MallSystem.GetRewardPkgInfo();
	log_tree("pkgInfo",info);
	if Direct_Purchase_ItemID == info.item_id then	-- 当前物品id和拉取到的物品id一致	
		info.productPriceDesc = MidasManager.GetPriceByProductId(info.midasProductId,
																 info.midasCurrency,
																 info.configPrice);	
		if info.productPriceDesc ~= "" then
			BP_DirectPurchase_By_Activity_CurrentPrice = info.productPriceDesc;
			LuaClassObj.HandleUIMessage(bp_direct_purchase_by_activity, "UpdateUI");
		end	
	end
end

-- 解析活动所附带的条件，取出物品Id
function Direct_Purchase_By_Ativity_UI.ParseActivityInfoConditional(cond)
	if not cond then
		return nil;
	end
	local strs = string.split(cond, ",");
	if strs and #strs > 0 then
		return tonumber(strs[1]);
	end
	return nil;
end