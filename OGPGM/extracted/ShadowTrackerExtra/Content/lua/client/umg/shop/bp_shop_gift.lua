----商店UI
ShopGiftUI = ShopGiftUI or
{
	selectProductTbl = {},
	isMoneyEnough = false,
	clickBtnType = nil,
	isOpenSendGiftWnd = false,
	uidFilterType = 1,
}


BP_STRUCT_Shop_Gift_Item_Info =
{
	item_id = 0,
	pruduct_name = "",
	product_desc = "",
	product_price = 0,
	before_discount_price = 0,
	icon_path = "",
	money_path = "",
	quality = 0,
	color_id = 0,
	pattern_id = 0,
};

--好友结构的定义
BP_STRUCT_FriendProfile_ForGift =
{
    gid="",
	nickName = "",
	level = 0,
	militaryRank = "";
    picUrl = "",
    vipLevel = 0,
    ladder = 0,-- 天梯
    platName = "",
    sex = 0,-- 1为男，2为女
    lastOnlineTime = 0,
	lastOnlineTimeStr = "",
	lastLoginTime = 0,
	exp = 0,
	signature = "",--个性签名
	segment_info_solo = 0,-- 段位数据
	segment_info_duo = 0,
	segment_info_squad = 0,
	history_max_segment_level = 0, --历史最高段位

	startup_type = 0,-- 启动类型
	qq_vip = 0,-- QQ会员

	friendType = 0,-- 好友类型（平台1、游戏内0）
	intimacy=0,--亲密度
	lastInviteTime=0,--上次邀请时间
	remarks_name="",--备注名称，有备注名称表示备注名称，无备注表示平台名称
	cur_avatar_box_id=0,

	bXiaoYue=0,--是否是小悦
	bNewMessage=0,--小悦是否有小红点

	online = 1, -- 0为离线，1为在线
	showInviteIcon = 0,

	relation=0,
	isInnerFriendNotPlatFriend = false,   -- 是游戏好友不是平台好友

	-- 申请列表
	applyMsg="", --好友申请里的留言
	createTime = 0,--好友申请的发送时间
	createTimeStr = "",

	-- 附近的人（大厅），好友（大厅），好友聊天
	teamState = 0, -- 0为空闲，1为组队中（组队中提供当前队伍人数，队伍最大可容纳人数，队伍id）,2为已开局状态（需已开局时间数据）
	currentTeamAmount = 1, -- 当前队伍人数
	maxTeamAmount = 4, -- 队伍最大可容纳人数
	teamId = 0, -- 队伍id
	timeSinceGameBegin = 0, -- 已开局时间
	timeSinceGameBeginStr = "",
	game_mode = 0,--0为默认模式
	gameModeStr = "",

	gameSubMode = 0, -- 子模式id(对应BTMode表),用于观战获取地图
	watchUid = 0, -- 若观战中则不为0

	-- 最近组队
	endtime=0,-- 战斗结算时间
	endtimeStr="",
	rank=0, --排名
	total=0, -- 总人数
	score="", --评分
	kill=0, --淘汰人数
	mode=0, --模式
	modeStr="",

	-- 平台好友 游戏好友
	lastPresentCoinTime=0,--上次赠送时间
	bPresentedCoin=0,--是否赠送过金币(0未赠送，1赠送过)

	-- 附近的人（好友）,附近的人（大厅）
	distance=0,
	isFriend=false,

	-- 添加好友搜索
	tendency=0,
	playDate=0,
	playTime=0,
	cityId=0,
	expertArea_1=0,
	expertArea_2=0,
	create_time = 0,
	isSameClient=false,--是否同服客户端（同为全球服或日韩服）
};

BP_STRUCT_FriendProfile_Gift_Select =
{
	gid="",
	level = 0,
	sex = 0,-- 1为男，2为女
	cur_avatar_box_id=0,
	platName = "",
	nickName = "",
	picUrl = "",
	intimacy=0,--亲密度
	create_time = 0, -- 成为好友的时间
}

BP_Array_Shop_Gift_FriendData =
{
	BP_STRUCT_FriendProfile_ForGift = _G.BP_STRUCT_FriendProfile_ForGift,
};

BP_Array_Shop_Gift_FriendSearch_Data =
{
	BP_STRUCT_FriendProfile_ForGift = _G.BP_STRUCT_FriendProfile_ForGift,
};

BP_Shop_Gift_Search_Word = ""
BP_Shop_Gift_Opr_Type = 0 --赠送0，索取1
BP_Shop_Gift_Money_Enough = true
--注册Widget
function bp_shop_gift_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_shop_gift,
		{{Path="/Game/UMG/UI_Logic/Shop/Shop_Gift/Shop_Gift_BP.Shop_Gift_BP_C", Container="Default", ZOrder=BP_ENUM_UI_SHOP_ZORDER + 99}},
		{"Lobby"},
		false,
		false,
		true
	);
end

-- 产品定义来自购买界面
-- productTbl = {
-- 	id = 0, -- 商品id
-- 	name = "", --产品名字
-- 	money_type = 0, --钱类型的物品id
-- 	item_id = 0,  -- 购买的物品id
-- 	discount_price = 0, --打折后价格
-- 	money_price = 0， -- 原价
--  give_type = "suit",
--  time = 1,
--  cnt = 1,
-- }
function ShopGiftUI:OpenGiftPanel(productTbl)
	if productTbl == nil then
		log("ShopGiftUI :OpenGiftPanel productInfo == nil")
		return
	end
	ShopGiftUI.selectProductTbl = productTbl
	ShopGiftUI.isOpenSendGiftWnd = false
	--log_tree("samcen productTbl:", productTbl)
	ShopGiftUI.isMoneyEnough = MallSystem.IsMoneyEnough(productTbl.money_type, productTbl.discount_price + productTbl.colorPatternCost)
	self:ReallyOpen(ShopGiftUI.selectProductTbl, ShopGiftUI.isMoneyEnough)
end

-- function ShopGiftUI:OpenGiftPanelByProductID(productID)
-- 	--MallSystem.get_market_shopitem_info_by
-- 参数1=true充足，false不够，参数2=nil无，0取消，1确定，2前往
function ShopGiftUI.OpenCallback(enough, btnClickType)
	ShopGiftUI.clickBtnType = btnClickType
end

-- BP_STRUCT_Shop_Gift_Item_Info =
-- {
-- 	pruduct_name = "商品名",
-- 	product_desc = "商品描述",
-- 	product_price = 0,
-- 	before_discount_price = 0,
-- 	icon_path = "",
-- 	money_path = "",
-- };

function ShopGiftUI:InitForTest()
	-- local testProductTbl = {}
	-- testProductTbl.id = 50004
	-- testProductTbl.money_type = 1001
	-- testProductTbl.item_id = 2102017
	-- testProductTbl.discount_price = 10
	-- testProductTbl.money_price = 10
	-- testProductTbl.name = "高级时装礼盒(3天)"

	-- self:OpenGiftPanel(testProductTbl)
	-- self:OpenGiftPanelByProductID(1040003)

	ShopGiftUI:ShowGiftPanel (50004, 1, 2102017, 10, 10, "abc" );
end

--调用此方法，打开赠送面板
function ShopGiftUI:ShowGiftPanel (data, moneyType, name, colorID, patternID)
	log("=========ShopGiftUI:ShowGiftPanel","martinhtma")

	if StoreSystem.IsUseNewStore() then
		log("ShopGiftWithDayUI.ShowWithData","martinhtma")
		local money_type, discount_price = StoreFuncUtils.get_money_type_and_price(data.id, 1, data)
		local testProductTbl = {};
		testProductTbl.data = data
		testProductTbl.name = name;
		testProductTbl.colorID = colorID or 0;
		testProductTbl.patternID = patternID or 0;
		testProductTbl.colorPatternCost = 0
		testProductTbl.money_type = StoreFuncUtils.MoneyTypeToChinaMoneyType(money_type)

		ShopGiftWithDayUI.ShowWithData(testProductTbl)
	else
		if MallSystemUI_2.GetCurClass(BP_Mall_First_Tab_Id) == MallPageDiyUI then
			log("self:OpenGiftPanel","martinhtma")
			local testProductTbl = {};
			local money_type, discount_price = MallSystemUI_2.get_money_type_and_price(data.id, 1, data)
			testProductTbl.id = data.id;
			testProductTbl.item_id = data.item_id;
			testProductTbl.discount_price = discount_price;
			testProductTbl.money_price = data.money1_price;
			testProductTbl.name = name;
			testProductTbl.colorID = colorID or 0;
			testProductTbl.patternID = patternID or 0;
			testProductTbl.colorPatternCost = MallSystemUI_2.get_color_and_pattern_cost(colorID, patternID);
			testProductTbl.money_type = MallSystem.MoneyTypeToChinaMoneyType(money_type);

			self:OpenGiftPanel(testProductTbl)
		else
			log("ShopGiftWithDayUI.ShowWithData","martinhtma")
			local testProductTbl = {};
			testProductTbl.data = data
			testProductTbl.name = name;
			testProductTbl.colorID = colorID or 0;
			testProductTbl.patternID = patternID or 0;
			testProductTbl.colorPatternCost = MallSystemUI_2.get_color_and_pattern_cost(colorID, patternID);
			testProductTbl.money_type = MallSystem.MoneyTypeToChinaMoneyType(moneyType)

			ShopGiftWithDayUI.ShowWithData(testProductTbl)
		end
	end
end

function ShopGiftUI:ReallyOpen(productTbl, enough, colorID, patternID)
	--log_tree("samcen productTbl:", productTbl)
	-- 获取价格
	BP_STRUCT_Shop_Gift_Item_Info.before_discount_price = productTbl.money_price + productTbl.colorPatternCost;
	BP_STRUCT_Shop_Gift_Item_Info.product_price = productTbl.discount_price + productTbl.colorPatternCost;

	--货币类型icon路径
	local moneyData = Client.GetTableData("Item", productTbl.money_type);
	if moneyData ~= nil then
		BP_STRUCT_Shop_Gift_Item_Info.money_path = moneyData.ItemSmallIcon
	else
		BP_STRUCT_Shop_Gift_Item_Info.money_path = ""
	end

	BP_STRUCT_Shop_Gift_Item_Info.pruduct_name = productTbl.name;
	BP_STRUCT_Shop_Gift_Item_Info.item_id = productTbl.item_id;
	BP_STRUCT_Shop_Gift_Item_Info.color_id = colorID;
	BP_STRUCT_Shop_Gift_Item_Info.pattern_id = patternID;
	-- 物品路径
	-- if productTbl.give_type == "suit" then
	-- 	local suitData = Client.GetTableData("MarketSuit", productTbl.item_id)
	-- 	if suitData ~= nil then
	-- 		BP_STRUCT_Shop_Gift_Item_Info.icon_path = suitData.SmallIcon
	-- 	else
	-- 		BP_STRUCT_Shop_Gift_Item_Info.icon_path = ""
	-- 	end
	-- else
	-- 	local itemData = Client.GetTableData("Item", productTbl.item_id)
	-- 	if itemData ~= nil then
	-- 		BP_STRUCT_Shop_Gift_Item_Info.icon_path = itemData.ItemSmallIcon
	-- 	else
	-- 		BP_STRUCT_Shop_Gift_Item_Info.icon_path = ""
	-- 	end
	-- end
	-- 套装也从物品表获取
	local itemData = Client.GetTableData("Item", productTbl.item_id)
	if itemData ~= nil then
		BP_STRUCT_Shop_Gift_Item_Info.icon_path = itemData.ItemSmallIcon
		BP_STRUCT_Shop_Gift_Item_Info.product_desc = itemData.ItemDesc
		if BP_STRUCT_Shop_Gift_Item_Info.pruduct_name == "" then
			BP_STRUCT_Shop_Gift_Item_Info.pruduct_name = itemData.ItemName
		end
		BP_STRUCT_Shop_Gift_Item_Info.quality = itemData.ItemQuality
	else
		BP_STRUCT_Shop_Gift_Item_Info.icon_path = ""
		BP_STRUCT_Shop_Gift_Item_Info.product_desc = ""
		BP_STRUCT_Shop_Gift_Item_Info.quality = 0
	end


	BP_Shop_Gift_Money_Enough = enough

	-- 请求索取好友的申请次数
	LogicGiftShop.market_get_askinfo_req(true)
	-- self:Init()
end

function ShopGiftUI:Init()
	--每次点开都获取数据，确保是最新的
	self:GetGiftPanelAllFriendData()

	LuaClassObj.HandleDynamicCreation(bp_shop_gift);

	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, ShopGiftUI.OnGoldChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, ShopGiftUI.OnDiamondChange);
    EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, ShopGiftUI.OnTicketChange);

	LuaClassObj.HandleUIMessage(bp_shop_gift, "UIShow");
	UIManager.Show(eUIType.eShopGift)


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

-- ├─ segment_info_duo: 101
-- LogNula: LuaLog:    ├─ friendType: 0
-- LogNula: LuaLog:    ├─ lastPresentCoinTime: 0
-- LogNula: LuaLog:    ├─ qq_vip: 2
-- LogNula: LuaLog:    ├─ exp: 365
-- LogNula: LuaLog:    ├─ platName: "夏染七日"
-- LogNula: LuaLog:    ├─ showInviteIcon: 1
-- LogNula: LuaLog:    ├─ teamState: 0
-- LogNula: LuaLog:    ├─ picUrl: "http://q.qlogo.cn/qqapp/1106467070/9F42B482D2942665717DA0E522D4BA18/100"
-- LogNula: LuaLog:    ├─ online: 0
-- LogNula: LuaLog:    ├─ intimacy: 1
-- LogNula: LuaLog:    ├─ segment_info_squad: 101
-- LogNula: LuaLog:    ├─ maxTeamAmount: 4
-- LogNula: LuaLog:    ├─ lastOnlineTime: 1521109564
-- LogNula: LuaLog:    ├─ timeSinceGameBeginStr: "(已开局1分钟)"
-- LogNula: LuaLog:    ├─ vipLevel: ""
-- LogNula: LuaLog:    ├─ nickName: "双瞳辛迪瑞拉"
-- LogNula: LuaLog:    ├─ sex: 1
-- LogNula: LuaLog:    ├─ reserveState: 0
-- LogNula: LuaLog:    ├─ remarks_name: ""
-- LogNula: LuaLog:    ├─ isInnerFriendNotPlatFriend: false
-- LogNula: LuaLog:    ├─ lastOnlineTimeStr: "最近上线13天前"
-- LogNula: LuaLog:    ├─ level: 41
-- LogNula: LuaLog:    ├─ game_mode: 0
-- LogNula: LuaLog:    ├─ history_max_segment_level: 0
-- LogNula: LuaLog:    ├─ cur_avatar_box_id: 2001001
-- LogNula: LuaLog:    ├─ startup_type: 0
-- LogNula: LuaLog:    ├─ corps_id: 0
-- LogNula: LuaLog:    ├─ signature: ""
-- LogNula: LuaLog:    ├─ segment_info_solo: 101
-- LogNula: LuaLog:    ├─ timeSinceGameBegin: 0
-- LogNula: LuaLog:    ├─ gameModeStr: "经典模式中"
-- LogNula: LuaLog:    ├─ lastLoginTime: 1521282363
-- LogNula: LuaLog:    ├─ currentTeamAmount: 1
-- LogNula: LuaLog:    ├─ bPresentedCoin: 0
-- LogNula: LuaLog:    └─ gid: 410000098

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

function ShopGiftUI:GetGiftPanelAllFriendData()

	local region = Client.GetPublishRegion();
	-- 刷新
	if region == "JAPAN" or region == "KOREA" then
		ShopGiftUI.uidFilterType = 1;
	else
		ShopGiftUI.uidFilterType = 2;
	end

	FriendSystem.SortInnerFriendList(LOGIC_FRIEND_SORT_TYPE.LAST_ONLINE_TIME)
	BP_Array_Shop_Gift_FriendData = {}
	for index, friendData in ipairs(BP_ARRAY_Inner_Friend_Profile) do
		if friendData and friendData.intimacy then
			friendData.isSameClient = (not IsFilter(ShopGiftUI.uidFilterType, friendData.gid));
			table.insert(BP_Array_Shop_Gift_FriendData, friendData);
		end
	end
	table.sort(BP_Array_Shop_Gift_FriendData, SortByIntimacyFunc);
end

function ShopGiftUI:IsFriendFound(FriendName)
	local findFlag = string.find(FriendName, BP_Shop_Gift_Search_Word)
	return findFlag ~= nil
end

function ShopGiftUI:NotifySearchFriendResult()
	-- log("samcen ShopGiftUI:NotifySearchFriendResult call")
	BP_Array_Shop_Gift_FriendSearch_Data = {}
	if BP_Shop_Gift_Search_Word == "" then
		DataMgr.ShowNoticeByID(501058);
		return
	end

	for i = 1, #BP_Array_Shop_Gift_FriendData do
		local NickName = BP_Array_Shop_Gift_FriendData[i].nickName
		local PlatName = BP_Array_Shop_Gift_FriendData[i].platName
		if NickName ~= nil and self:IsFriendFound(NickName) then
			table.insert(BP_Array_Shop_Gift_FriendSearch_Data, BP_Array_Shop_Gift_FriendData[i])
		elseif PlatName ~= nil and self:IsFriendFound(PlatName) then
			table.insert(BP_Array_Shop_Gift_FriendSearch_Data, BP_Array_Shop_Gift_FriendData[i])
		end
	end
	-- log_tree("samcen BP_Array_Shop_Gift_FriendSearch_Data", BP_Array_Shop_Gift_FriendSearch_Data)
	LuaClassObj.HandleUIMessage(bp_shop_gift, "OnShowSearchResult")
end

function ShopGiftUI:GetConfigTableValue(configName)
	local sysCfg = Client.GetTableData("SystemConfig", configName)
	if sysCfg ~= nil then
		return tonumber(sysCfg.ConfigValue)
	end
	return 0
end

function ShopGiftUI:PopLimitText(resID, limitPara)
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

function EventGiftUISearch()
	ShopGiftUI:NotifySearchFriendResult()
end

function EventGiftUIPushDataFunc()
end

function EventGiftSwitchToSendPanel()
	-- 货币不足，则提示充值，取消和前往都保留现在界面
	-- if not ShopGiftUI.isMoneyEnough then
	-- 	MallSystem.CheckMoneyIsEnough(ShopGiftUI.selectProductTbl.money_type, ShopGiftUI.selectProductTbl.discount_price, ShopGiftUI.OpenCallback)
	-- end
end

function EventGiftBtnGiveGrayClick()
	ShowNotice(501108);-- 客户端不同无法赠送
end

function ShopGiftUI.OnGoldChange()
	ShopGiftUI.FreshMoneyEnoughLogic()
end

function ShopGiftUI.OnDiamondChange()
	ShopGiftUI.FreshMoneyEnoughLogic()
end

function ShopGiftUI.OnTicketChange()
	ShopGiftUI.FreshMoneyEnoughLogic()
end

function ShopGiftUI.FreshMoneyEnoughLogic()
	ShopGiftUI.isMoneyEnough = MallSystem.IsMoneyEnough(ShopGiftUI.selectProductTbl.money_type, ShopGiftUI.selectProductTbl.discount_price)
	BP_Shop_Gift_Money_Enough = ShopGiftUI.isMoneyEnough
	LuaClassObj.HandleUIMessage(bp_shop_gift, "SetMoneyColor")
end


function EventGiftUIClose()
	EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_GOLD_CHANGE, ShopGiftUI.OnGoldChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_DIAMOND_CHANGE, ShopGiftUI.OnDiamondChange);
    EventSystem:unregistEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_TICKET_CHANGE, ShopGiftUI.OnTicketChange);

	BP_Array_Shop_Gift_FriendData = {}
	BP_Array_Shop_Gift_FriendSearch_Data = {}
	ShopGiftUI.selectProductTbl = {}
	ShopGiftUI.isMoneyEnough = false
	LogicGiftShop.Release()

	BP_Shop_Gift_Search_Word = ""
	BP_Shop_Gift_Opr_Type = 0
	ShopGiftUI.clickBtnType = nil
	ShopGiftUI.isOpenSendGiftWnd = false
	UIManager.Hide(eUIType.eShopGift)
	LuaClassObj.HandleUIMessage(bp_shop_gift, "UIHide");
end

function ShopGiftUI:OpenSendGift()

	-- EventGiftUIClose()
end

function ShopGiftUI:CheckBeFriendDayOK(limitDay)
	log("samcen ShopGiftUI:CheckBeFriendDayOK gid:"..BP_STRUCT_FriendProfile_Gift_Select.gid)
	if BP_STRUCT_FriendProfile_Gift_Select.create_time == nil or BP_STRUCT_FriendProfile_Gift_Select.create_time <= 0 then
		log("samcen ShopGiftUI:CheckBeFriendDayOK 1")
		return true
	end

	if limitDay <= 0 then
		log("samcen ShopGiftUI:CheckBeFriendDayOK limitDay <= 0")
		return true
	end

	local now_time = FuncUtil.GetServerTimeInSec()
	local beFriendTime = now_time - BP_STRUCT_FriendProfile_Gift_Select.create_time
	if beFriendTime <= 0 then
		log("samcen ShopGiftUI:CheckBeFriendDayOK 2 beFriendTime:"..beFriendTime)
		return false
	end
	local daySenconds = 86400
	local beFriendDay = beFriendTime / daySenconds
	if beFriendDay >= limitDay then
		log("samcen ShopGiftUI:CheckBeFriendDayOK 3 beFriendDay:"..beFriendDay)
		return true
	end
	log("samcen ShopGiftUI:CheckBeFriendDayOK 4 beFriendDay:"..beFriendDay)
	return false
end

function ShopGiftUI:CheckBeFriendTimeOK(limitTime)
	log("samcen ShopGiftUI:CheckBeFriendTimeOK gid:"..BP_STRUCT_FriendProfile_Gift_Select.gid)
	if BP_STRUCT_FriendProfile_Gift_Select.create_time == nil or BP_STRUCT_FriendProfile_Gift_Select.create_time <= 0 then
		log("samcen ShopGiftUI:CheckBeFriendTimeOK 1")
		return true
	end

	if limitTime <= 0 then
		log("samcen ShopGiftUI:CheckBeFriendTimeOK limitDay <= 0")
		return true
	end

	local now_time = FuncUtil.GetServerTimeInSec()
	local beFriendTime = now_time - BP_STRUCT_FriendProfile_Gift_Select.create_time
	if beFriendTime <= 0 then
		log("samcen ShopGiftUI:CheckBeFriendTimeOK 2 beFriendTime:"..beFriendTime)
		return false
	end

	if beFriendTime >= limitTime then
		log("samcen ShopGiftUI:CheckBeFriendTimeOK 3 beFriendTime:"..beFriendTime)
		return true
	end
	log("samcen ShopGiftUI:CheckBeFriendTimeOK 4 beFriendTime:"..beFriendTime)
	return false
end

function EventGiftUISendOrWant()
	-- 获取限制的亲密度
	if BP_Shop_Gift_Opr_Type == 0 then

		if BP_SHOPGIFT_SEND_TIMES >= BP_SHOPGIFT_SEND_MAX_TIMES then
			ShopGiftUI:PopLimitText(5000131)
			--log("ShopGiftUI:BP_SHOPGIFT_SEND_MAX_TIMES")
			return;
		end

		local SendMinIntimacy = ShopGiftUI:GetConfigTableValue("MarketGiftSendMinIntimacy")
		if BP_STRUCT_FriendProfile_Gift_Select.intimacy < SendMinIntimacy then
			ShopGiftUI:PopLimitText(5000144)
			--log("ShopGiftUI:MarketGiftSendMinIntimacy")
			return
		end

		local SendMinSeconds = ShopGiftUI:GetConfigTableValue("MarketGiftSendMinSeconds")
		if not ShopGiftUI:CheckBeFriendTimeOK(SendMinSeconds) then
			ShopGiftUI:PopLimitText(5000145)
			--log("ShopGiftUI:MarketGiftSendMinSeconds")
			return
		end
			-- 钱不足判断
		local SendLimitLevel = ShopGiftUI:GetConfigTableValue("MarketGiftSendLevelLimit")
		if DataMgr.roleData.level < SendLimitLevel then
			ShopGiftUI:PopLimitText(5000146)
			--log("ShopGiftUI:MarketGiftSendLevelLimit")

			return
		end

		ShopGiftPacketUI:OpenSendGiftPanel( ShopGiftUI.selectProductTbl, BP_STRUCT_FriendProfile_Gift_Select )
		-- log_tree("samcen 1 ShopGiftUI.selectProductTbl:", ShopGiftUI.selectProductTbl)
	elseif BP_Shop_Gift_Opr_Type == 1 then
		local WantLimitLevel = ShopGiftUI:GetConfigTableValue("MarketGiftWantLevelLimit")
		if DataMgr.roleData.level < WantLimitLevel then
			ShopGiftUI:PopLimitText(501057, WantLimitLevel)
			return
		end

		local WantDayLimit = ShopGiftUI:GetConfigTableValue("MarketGiftWantDayLimit")
		if not ShopGiftUI:CheckBeFriendDayOK(WantDayLimit) then
			ShopGiftUI:PopLimitText(501062, WantDayLimit)
			return
		end

		local wantTimesLimit = ShopGiftUI:GetConfigTableValue("GiftWantTimesLimit")
		if not LogicGiftShop.CheckWantGiftTimesOK(BP_STRUCT_FriendProfile_Gift_Select.gid, wantTimesLimit) then
			ShopGiftUI:PopLimitText(501105, wantTimesLimit)
			return
		end

		-- log_tree("samcen 2 ShopGiftUI.selectProductTbl:", ShopGiftUI.selectProductTbl)
		-- log_tree("samcen 2 BP_STRUCT_FriendProfile_Gift_Select:", BP_STRUCT_FriendProfile_Gift_Select)
		ShopGiftPacketUI:OpenRequireGiftPanel( ShopGiftUI.selectProductTbl, BP_STRUCT_FriendProfile_Gift_Select )
		-- EventGiftUIClose()
		--
	end

end
