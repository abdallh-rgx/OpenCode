-- sami 烧鸡活动UI
ActivtyShaoJiUI = ActivtyShaoJiUI or
{
	isShow = false,
	activityId = 18034011,
	bRedDot = false,
}

BP_Activty_ShaoJi_End_Time = ""
BP_Activty_ShaoJi_ShaoJi_Num = 0
BP_Activty_ShaoJi_Exchange_Index = 0

BP_STRUCT_Activty_ShaoJi_ItemInfo =
{
	itemId = 0,
	iconPath = "",
	itemNum = 0,
	nExchangeState = 0,	-- 0-可以兑换，1-已兑换，2-兑换道具不足
	qualityIconPath = "",
}
BP_ARRAY_Activty_ShaoJi_ItemInfo_List =
{
	BP_STRUCT_Activty_ShaoJi_ItemInfo = _G.BP_STRUCT_Activty_ShaoJi_ItemInfo;
}

--注册Widget
function bp_activity_shaoji_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_activity_shaoji,
        {{Path="/Game/UMG/UI_Logic/Activty/Activty_ShaoJi_Logic_BP.Activty_ShaoJi_Logic_BP_C", Container="Default", ZOrder=60}},
        {"Lobby"},
        false,
        false,
        true
    );
end

--sami 初始化显示
function ActivtyShaoJiUI.Init()
    log("ActivtyShaoJiUI.Init")
	
	if DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SHAOJI, 1) then
    	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SHAOJI, 1);
    end
	
	LuaClassObj.HandleDynamicCreation(bp_activity_shaoji);
	LuaClassObj.HandleUIMessage(bp_activity_shaoji, "UIShow");
	ActivtyShaoJiUI.isShow = true
	
	ActivtyShaoJiUI.UpdateUI()
	
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, ActivtyShaoJiUI.OnActInfo);
	EventSystem:registEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_EXCHANGE, ActivtyShaoJiUI.OnExchange);
	
end

function ActivtyShaoJiUI.UpdateUI()
	--设置数据
	local data = ActivitySystem.activityDataTable[ActivtyShaoJiUI.activityId]
	if data == nil then
		return
	end
	--log_tree("data = ", data)
	BP_Activty_ShaoJi_End_Time = FuncUtil.SecToDateStringUTC(data.cfg.start_time) .."-" ..FuncUtil.SecToDateStringUTC(data.cfg.end_time)
	BP_Activty_ShaoJi_ShaoJi_Num = UnknowPassTreasureBoxUI.GetItemCount(WardrobeSystem.GetShaoJiItemId())
	
	BP_ARRAY_Activty_ShaoJi_ItemInfo_List = {}
	for k,v in pairs(data.cfg.award) do
		local rewardInfo = {}
		rewardInfo.itemId = v.drop[1].item_id
		local cfg = Client.GetTableData("Item", rewardInfo.itemId)
		if cfg then
			rewardInfo.iconPath = cfg.ItemSmallIcon
		else
			rewardInfo.iconPath = ""
		end
		rewardInfo.itemNum = ActivtyShaoJiUI.GetConditionCount(v.cond)
		if data.data.award[k].exchange_cnt == nil or data.data.award[k].exchange_cnt <= 0 then
			if BP_Activty_ShaoJi_ShaoJi_Num >= rewardInfo.itemNum then
				rewardInfo.nExchangeState = 0
			else
				rewardInfo.nExchangeState = 2
			end
		else
			rewardInfo.nExchangeState = 1
		end

		rewardInfo.qualityIconPath = "/Game/UMG/Texture/Atlas/Quality/Frames/T_icon_quality_0" ..tostring(cfg.ItemQuality) .."_png.T_icon_quality_0" ..tostring(cfg.ItemQuality) .."_png"
		
		table.insert(BP_ARRAY_Activty_ShaoJi_ItemInfo_List, rewardInfo)
	end
	--log_tree("BP_ARRAY_Activty_ShaoJi_ItemInfo_List ", BP_ARRAY_Activty_ShaoJi_ItemInfo_List)
	LuaClassObj.HandleUIMessage(bp_activity_shaoji, "FreshUI");
	ActivtyShaoJiUI.UpdateExchangeRedpoint()
end

function ActivtyShaoJiUI.Release()
    log("ActivtyShaoJiUI.Release")
end

-- 从内部链接跳转
function ActivtyShaoJiUI.OpenFromUrl()
    log("ActivtyShaoJiUI.OpenFromUrl")
	ActivtyShaoJiUI.Init()
end

-- 获取条件数量 "1702010,50,0,0,1,0,0,0"
function ActivtyShaoJiUI.GetConditionCount(str)
	local arr = string.split(str, ",")
	if arr == nil or #arr <= 1 then
		return 0
	end
	return tonumber(arr[2])
end

-- 点击兑换按钮
function EventActivtyShaoJiExchangeClick()
	log("EventActivtyShaoJiExchangeClick " ..BP_Activty_ShaoJi_Exchange_Index)
	if BP_ARRAY_Activty_ShaoJi_ItemInfo_List[BP_Activty_ShaoJi_Exchange_Index + 1] == nil then
		log("EventActivtyShaoJiExchangeClick 1")
		return
	end

	local itemNum = BP_ARRAY_Activty_ShaoJi_ItemInfo_List[BP_Activty_ShaoJi_Exchange_Index + 1].itemNum
	local itemId = BP_ARRAY_Activty_ShaoJi_ItemInfo_List[BP_Activty_ShaoJi_Exchange_Index + 1].itemId
	local cfg = Client.GetTableData("Item", itemId)
	if cfg == nil then
		return
	end

	local title = FuncUtil.GetLocalizeResStr(102001)
	local okStr = FuncUtil.GetLocalizeResStr(110036)
	local cancelStr = FuncUtil.GetLocalizeResStr(110035)
	local content = FuncUtil.LocalizeResFormat(6191, itemNum, cfg.ItemName)
	CommonMessageBoxUI.ShowPlatformPanel(2, title, content, function ()
		ActivitySystem.Req_TakeActivityAward(ActivtyShaoJiUI.activityId, BP_Activty_ShaoJi_Exchange_Index + 1)
	end
	, nil, okStr, cancelStr);
end

-- 点击我要烧鸡按钮
function EventActivtyShaoJiWantShaoJiClick()
	log("EventActivtyShaoJiWantShaoJiClick")

	local data = ActivitySystem.activityDataTable[ActivtyShaoJiUI.activityId]
	if data == nil then
		ShowNotice(430104)
		return
	end
	local curTime = NetUtil.GetCurServerTime()
	if curTime < data.cfg.start_time or curTime > data.cfg.end_time then
		ShowNotice(430104)
		return
	end
	
	EventActivtyShaoJiClose()
	
	local page = 17;
	local itemId = 1541016;
	if FuncUtil.IsPlayerJPKR() then	-- 日韩版itemid为1541019
		itemId = 1541019;
	end
    FuncUtil.GotoBuyItemInMallSystem(page, itemId, false)
end

-- 点击关闭按钮
function EventActivtyShaoJiClose()
	log("EventActivtyShaoJiClose")
	ActivtyShaoJiUI.isShow = false
	
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, ActivtyShaoJiUI.OnActInfo);
	EventSystem:unregistEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_EXCHANGE, ActivtyShaoJiUI.OnExchange);
	
	LuaClassObj.HandleUIMessage(bp_activity_shaoji, "UIHide");
end

function EventActivtyShaoJiRuleClick()
    log("EventActivtyShaoJiRuleClick");
	local title = Client.GetTableData("LocalizeRes", 4726).TextValue
	local content = Client.GetTableData("LocalizeRes", 6225).TextValue
    PopUpNoticeUI.ShowMessageBox(title, content);
end

function ActivtyShaoJiUI.OnActInfo()
	log("ActivtyShaoJiUI.OnActInfo")
	ActivtyShaoJiUI.UpdateUI()
end

function ActivtyShaoJiUI.OnExchange()
	log("ActivtyShaoJiUI.OnExchange")
	DataMgr.ResetActivityData()
end


-- 更新兑换烧鸡道具红点
function ActivtyShaoJiUI.UpdateExchangeRedpoint()
	--log("ActivtyShaoJiUI.UpdateExchangeRedpoint")
	local bRedDot = false
	local data = ActivitySystem.activityDataTable[ActivtyShaoJiUI.activityId]
	if data == nil or data.cfg == nil or data.cfg.award == nil then
		bRedDot = false
	else
		local newbie = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_SHAOJI, 1);
		if newbie then
			bRedDot = true
		else
			local shaojiNum = UnknowPassTreasureBoxUI.GetItemCount(WardrobeSystem.GetShaoJiItemId())
			for k,v in pairs(data.cfg.award) do
				local itemNum = ActivtyShaoJiUI.GetConditionCount(v.cond)
				if data.data.award[k].exchange_cnt == nil or data.data.award[k].exchange_cnt <= 0 then
					if shaojiNum >= itemNum then
						bRedDot = true
						break
					end
				end
			end
		end
	end

	if bRedDot ~= ActivtyShaoJiUI.bRedDot then
		ActivtyShaoJiUI.bRedDot = bRedDot
		LobbyUI:LobbyRedPointUpdate(BP_ENUM_MODULE_ACTIVITY_SHAO_JI, bRedDot)
	end
end

-- 获取兑换奖励道具列表
function ActivtyShaoJiUI.GetExchangeRewardItemList(index)
	local itemList = {}
	local data = ActivitySystem.activityDataTable[ActivtyShaoJiUI.activityId]
	if data == nil or data.cfg == nil or data.cfg.award == nil or data.cfg.award[index] == nil then
		return itemList
	end
	
	local dropList = data.cfg.award[index].drop
	if dropList == nil then
		return itemList
	end
	
	for k,v in pairs(dropList) do
		local item = {}
		item.res_id = v.item_id
		item.count = v.item_num
		item.valid_hours = v.item_expire_time
		table.insert(itemList, item)
	end
	
	return itemList
end

-- 处理烧鸡活动兑换
function ActivtyShaoJiUI.ProcExchangeRewardRes(awardIndex)
	log("ActivtyShaoJiUI.ProcExchangeRewardRes " ..awardIndex)

	local arrayItemData = ActivtyShaoJiUI.GetExchangeRewardItemList(awardIndex)
	--log_tree("arrayItemData ", arrayItemData)
	CommonItemGetUI:ShowPanel(arrayItemData)
	EventSystem:postEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_EXCHANGE)
end

