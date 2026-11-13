----商店UI
ShopGiftWithDayUI = ShopGiftWithDayUI or {
	first_money = 1
}

BP_STRUCT_ShopGiftWithDayUI_ItemInfo =
{
	itemId = 0,
    itemName = ""
}

-- BP_ShopGiftWithDayUI_SelectedPriceIndex = 0

-- 当前选中价格
BP_STRUCT_ShopGiftWithDayUI_PriceInfos =
{
	index = 0,
    dayStr = "",
    price = 0,
	validHours = 0,
}

-- 价格列表
BP_ARRAY_ShopGiftWithDayUI_PriceInfosList = 
{
    BP_STRUCT_ShopGiftWithDayUI_PriceInfos = _G.BP_STRUCT_ShopGiftWithDayUI_PriceInfos,
}

-- 赠送好友列表
BP_Array_ShopGiftWithDayUI_FriendData =
{
	tmp_UseExist_BP_STRUCT_FriendProfile_ForGift = {}
}

-- 搜索好友列表
BP_Array_ShopGiftWithDayUI_FriendSearch_Data =
{
	tmp_UseExist_BP_STRUCT_FriendProfile_ForGift = {}
}

-- 赠送的好友
BP_Array_ShopGiftWithDayUI_SendFriendData =
{
	tmp_UseExist_BP_STRUCT_FriendProfile_ForGift = {}
}

-- 搜索内容
BP_ShopGiftWithDayUI_Search_Word = ""

local _shopData = {}
local _allFriend = {}
local _itemData = {}

function bp_shop_gift_with_day_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_shop_gift_with_day,
		{{Path="/Game/UMG/UI_Logic/Shop/Shop_Gift/Shop_Gift_With_Day_LogicBP.Shop_Gift_With_Day_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_SHOP_ZORDER + 99}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function ShopGiftWithDayUI.ShowWithData(shopData, shopInfo)
	-- LuaClassObj.HandleDynamicCreation(bp_shop_gift_with_day)

	_shopData = shopData
	_itemData = shopData.data

	-- LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_with_day, "UIShow")
	ShopGiftWithDayUI.Show()
end

function ShopGiftWithDayUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_shop_gift_with_day)

	BP_STRUCT_ShopGiftWithDayUI_PriceInfos = nil
	BP_Array_ShopGiftWithDayUI_FriendSearch_Data = {}
	local IsValid = ShopGiftWithDayUI.UpdateUI()
	if not IsValid then
		return
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_with_day, "UIShow")
	UIManager.Show(eUIType.eShopGiftWithDay)
end

function ShopGiftWithDayUI.Hide()
	UIManager.Hide(eUIType.eShopGiftWithDay)
	LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_with_day, "UIHide")
end

--@return string
function ShopGiftWithDayUI.GetValidTimeByHour(hour)
	local str = ""
	if hour == nil or hour < 0 then
		return str
	end
	if hour == 0 then
		str = FuncUtil.GetLocalizeResStr(501059)
		return str
	end
	local days = math.floor(hour / 24)

	if days > 0 then
		str = FuncUtil.LocalizeResFormat("301153", days)
	end

	return str
end

function ShopGiftWithDayUI.UpdateUI()
	--log_tree("_shopData",_shopData,"asd")
	-- for test
	-- _shopData.id = 1400237
	BP_ARRAY_ShopGiftWithDayUI_PriceInfosList = {}
	local UCType = 2
	if _itemData.money1_type == UCType then
		ShopGiftWithDayUI.first_money = 1
		local priceKeyList = {"money1_price", "money1_price2", "money1_price3"};
		for i, v in ipairs(priceKeyList) do
			if _itemData[v] ~= 0 then
				local hoursKey = "valid_hours" .. i;
				local data = {};
				data.index = i;
				data.validHours = _itemData[hoursKey];
				data.dayStr = ShopGiftWithDayUI.GetValidTimeByHour(_itemData[hoursKey]);
				data.price = _itemData[v];
				table.insert(BP_ARRAY_ShopGiftWithDayUI_PriceInfosList, data);
			end
		end
	elseif _itemData.money2_type == UCType then
		ShopGiftWithDayUI.first_money = 2
		local priceKeyList = {"money2_price", "money2_price2", "money2_price3"};
		for i, v in ipairs(priceKeyList) do
			if _itemData[v] ~= 0 then
				local hoursKey = "valid2_hours" .. i;
				local data = {};
				data.index = i;
				data.validHours = _itemData[hoursKey];
				data.dayStr = ShopGiftWithDayUI.GetValidTimeByHour(_itemData[hoursKey]);
				data.price = _itemData[v];
				table.insert(BP_ARRAY_ShopGiftWithDayUI_PriceInfosList, data);
			end
		end
	else
		log_error("不能赠送无法通过UC购买的的商品。Can't give sth which can't be purchased through UC.")
		return false
	end

	local itemDataCfg = Client.GetTableData("Item", _itemData.item_id)

	BP_STRUCT_ShopGiftWithDayUI_ItemInfo.itemId = _itemData.item_id
	BP_STRUCT_ShopGiftWithDayUI_ItemInfo.itemName = itemDataCfg.ItemName

	LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_with_day, "UpdateUI")
	LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_with_day, "UpdatePrice")

	ShopGiftWithDayUI.GetGiftPanelAllFriendData()
	LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_with_day, "UpdateFriendList")
	return true
end

local function SortByIntimacyFunc(a,b)
	if a.intimacy == nil or b.intimacy == nil then
		return false
	end
	if not a.isSameClient then
		return false;
	end
	if not b.isSameClient then
		return true;
	end
	if a.intimacy == b.intimacy then
		if a.lastOnlineTime == nil or b.lastOnlineTime == nil then
			return false
		end
		return tonumber(a.lastOnlineTime) > tonumber(b.lastOnlineTime)
	else
		return a.intimacy > b.intimacy
	end
end

local function IsFilter(filterType, uid)
	if filterType == 1 then -- 过滤全球服的
        if FuncUtil.IsUidGlobal(uid) then
            return true;
        end
    elseif filterType == 2 then -- 过滤日韩服的
        if FuncUtil.IsUidJPKR(uid) then
            return true;
        end
    end
    return false;
end

function ShopGiftWithDayUI.GetGiftPanelAllFriendData()
	local region = Client.GetPublishRegion();
	-- 刷新
	if region == "JAPAN" or region == "KOREA" then
		ShopGiftWithDayUI.uidFilterType = 1
	else
		ShopGiftWithDayUI.uidFilterType = 2
	end

	FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.LAST_ONLINE_TIME)

	BP_Array_ShopGiftWithDayUI_FriendData = {}
	_allFriend = {}
	
	for index, friendData in ipairs(BP_ARRAY_Inner_Friend_Profile) do
		if friendData and friendData.intimacy then
			friendData.isSameClient = (not IsFilter(ShopGiftWithDayUI.uidFilterType, friendData.gid))
			table.insert(BP_Array_ShopGiftWithDayUI_FriendData, friendData)
			table.insert(_allFriend, friendData)
		end
	end

	table.sort(BP_Array_ShopGiftWithDayUI_FriendData, SortByIntimacyFunc)
	table.sort(_allFriend, SortByIntimacyFunc)

	log_tree("BP_Array_ShopGiftWithDayUI_FriendData",BP_Array_ShopGiftWithDayUI_FriendData,"shop")
end

function ShopGiftWithDayUI.IsFriendFound(FriendName)
	local findFlag = string.find(FriendName, BP_ShopGiftWithDayUI_Search_Word)
	return findFlag ~= nil
end

function ShopGiftWithDayUI.NotifySearchFriendResult()
	log("ShopGiftWithDayUI.NotifySearchFriendResult call")
	BP_Array_ShopGiftWithDayUI_FriendData = {}

	--if BP_ShopGiftWithDayUI_Search_Word == "" then
	--	DataMgr.ShowNoticeByID(501058)
	--	return
	--end

	for i = 1, #_allFriend do
		local NickName = _allFriend[i].nickName
		local PlatName = _allFriend[i].platName
		if NickName ~= nil and ShopGiftWithDayUI.IsFriendFound(NickName) then
			table.insert(BP_Array_ShopGiftWithDayUI_FriendData, _allFriend[i])
		elseif PlatName ~= nil and ShopGiftWithDayUI.IsFriendFound(PlatName) then
			table.insert(BP_Array_ShopGiftWithDayUI_FriendData, _allFriend[i])
		end
	end
	-- log_tree
	LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_with_day, "UpdateFriendList")
end

function ShopGiftWithDayUI.PopLimitText(resID, limitPara)
	local SendTipsTemplate = ""
	local ResTbl = Client.GetTableData("LocalizeRes", resID)
	if ResTbl ~= nil then
		SendTipsTemplate = ResTbl.TextValue
	end
	local TipsContent = SendTipsTemplate;
	if limitPara ~= nil then
		TipsContent = string.format(SendTipsTemplate, limitPara)
	end
	DataMgr.ShowNoticeByString(TipsContent)
end

function ShopGiftWithDayUI.CheckBeFriendTimeOK(limitTime)
	local selectedFriend = BP_Array_ShopGiftWithDayUI_SendFriendData[1]
	log("samcen ,ShopGiftWithDayUI.CheckBeFriendTimeOK gid:"..selectedFriend.gid)
	if selectedFriend.create_time == nil or selectedFriend.create_time <= 0 then
		log("samcen ,ShopGiftWithDayUI.CheckBeFriendTimeOK 1")
		return true
	end

	if limitTime <= 0 then
		log("samcen ,ShopGiftWithDayUI.CheckBeFriendTimeOK limitDay <= 0")
		return true
	end

	local now_time = FuncUtil.GetServerTimeInSec()
	local beFriendTime = now_time - selectedFriend.create_time
	if beFriendTime <= 0 then
		log("samcen ,ShopGiftWithDayUI.CheckBeFriendTimeOK 2 beFriendTime:"..beFriendTime)
		return false
	end

	if beFriendTime >= limitTime then
		log("samcen ,ShopGiftWithDayUI.CheckBeFriendTimeOK 3 beFriendTime:"..beFriendTime)
		return true
	end
	log("samcen ,ShopGiftWithDayUI.CheckBeFriendTimeOK 4 beFriendTime:"..beFriendTime)
	return false
end

function ShopGiftWithDayUI.GetConfigTableValue(configName)
	local sysCfg = Client.GetTableData("SystemConfig", configName)
	if sysCfg ~= nil then
		return tonumber(sysCfg.ConfigValue)
	end
	return 0
end

function EventShopGiftWithDayUIClickClose()
	ShopGiftWithDayUI.Hide()
end

-- 价格选择
function EventShopGiftWithDayUIClickPrice()
	-- body
end

-- 赠送点击
function EventShopGiftWithDayUIClickSend()
	if BP_STRUCT_ShopGiftWithDayUI_PriceInfos == nil then
		log("EventShopGiftWithDayUIClickSend BP_STRUCT_ShopGiftWithDayUI_PriceInfos is nil")
		return
	end

	if BP_SHOPGIFT_SEND_TIMES >= BP_SHOPGIFT_SEND_MAX_TIMES then
		ShopGiftWithDayUI.PopLimitText(5000131)
		log("ShopGiftWithDayUI:BP_SHOPGIFT_SEND_MAX_TIMES")
		return;
	end

	local selectedFriend = BP_Array_ShopGiftWithDayUI_SendFriendData[1]

	local SendMinIntimacy = ShopGiftWithDayUI.GetConfigTableValue("MarketGiftSendMinIntimacy")
	if selectedFriend.intimacy < SendMinIntimacy then
		ShopGiftWithDayUI.PopLimitText(5000144)
		log("ShopGiftWithDayUI:MarketGiftSendMinIntimacy")
		return
	end

	local SendMinSeconds = ShopGiftWithDayUI.GetConfigTableValue("MarketGiftSendMinSeconds")
	if not ShopGiftWithDayUI.CheckBeFriendTimeOK(SendMinSeconds) then
		ShopGiftWithDayUI.PopLimitText(5000145)
		log("ShopGiftWithDayUI:MarketGiftSendMinSeconds")
		return
	end
		-- 钱不足判断
	local SendLimitLevel = ShopGiftWithDayUI.GetConfigTableValue("MarketGiftSendLevelLimit")
	if DataMgr.roleData.level < SendLimitLevel then
		ShopGiftWithDayUI.PopLimitText(5000146)
		log("ShopGiftWithDayUI:MarketGiftSendLevelLimit")

		return
	end
	local colorPatternCost = 0
	if StoreSystem.IsUseNewStore() then
		colorPatternCost = 0
	else
		colorPatternCost = MallSystemUI_2.get_color_and_pattern_cost(_shopData.colorID, _shopData.patternID)
	end
	local SendData = {
		money_type = 1006,		-- 赠送必定是UC
		first_money = ShopGiftWithDayUI.first_money,
		money_price = BP_STRUCT_ShopGiftWithDayUI_PriceInfos.price,
		id = _itemData.id,
		item_id = _itemData.item_id,
		valid_hour = BP_STRUCT_ShopGiftWithDayUI_PriceInfos.validHours,
		colorID = _shopData.colorID,
		patternID = _shopData.patternID,
		name = _shopData.name,
		time = BP_STRUCT_ShopGiftWithDayUI_PriceInfos.index,
		cnt = 1,
		discount_price = nil,
		colorPatternCost = colorPatternCost,
	}
	ShopGiftPacketUI:OpenSendGiftPanel(SendData, selectedFriend)
end

function EventShopGiftWithDayUIClickSearch()
	ShopGiftWithDayUI.NotifySearchFriendResult()
end

function EventGiftBtnGiveGrayClick()
	ShowNotice(501108);-- 客户端不同无法赠送
end