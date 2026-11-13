----礼物赠送/索要UI
ShopGiftPacketUI = ShopGiftPacketUI or
{
	CheckBoxCtrlIdx = 0;  -- checkbox的选取索引
	productTbl      = nil;
	toUserTbl       = nil;
	CurCount        = 0,            --当前购买数量
    ChosenTimeLimit = 0,     --已选购买时限
    money_type      = 0,
    askIndex = 0,
}

BP_SHOPGIFT_UITYPE = 0;  -- 0 赠送礼物，1 请求礼物，2 查看请求礼物

BP_SHOPGIFT_CHECKBOX_NAME = "blue";

BP_SHOPGIFTPACK_UI_SHOW = false;

BP_STRUCT_Shop_GiftPack_Item_Info =
{
	--UserUID       = "",
	UserName     = "me",
	--UserIcon     = "",
	UserGender   = 0,
	--UserLV       = 1,
	--User_box_id  = 2001001,

	toUserUID       = "",
	toUserName     = "who",
	toUserIcon     = "",
	toUserGender   = 0,
	toUserLV       = 1,
	toUserPlatName = "",
	toUser_box_id  = 2001001,

	product_id     = 0,
	item_id        = 0,
	pruduct_name   = "商品名",
	product_price  = 12330,
	icon_path      = "",
	money_path     = "",
	msg            = "Undefined",
	CheckCtrName   = "",
	Quality        = 0,
	color_id 	   = 0,
	pattern_id     = 0,
};

BP_STRUCT_Shop_GiftPack_Data =
{
	CtrlName = "",
	content = "",
	ImagePath = "",
};

BP_ARRAY_GiftPack_PackStyle =
{
	BP_STRUCT_Shop_GiftPack_Data = _G.BP_STRUCT_Shop_GiftPack_Data,
};

--赠送寄语，或者索要寄语的中转文字
BP_SHOPGIFT_TEMP_TEXT = "";

--当前赠送次数
BP_SHOPGIFT_SEND_TIMES = -1;
--可赠送的最大次数
BP_SHOPGIFT_SEND_MAX_TIMES = 0;

-- 当前选中样式
BP_SHOPGIFT_STYLE = 1;

--注册Widget
function bp_shop_gift_packet_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_shop_gift_packet,
		{{Path="/Game/UMG/UI_Logic/Shop/Shop_Gift/Shop_Gift_Packet_BP.Shop_Gift_Packet_BP_C", Container="Default", ZOrder=BP_ENUM_UI_SHOP_ZORDER + 100}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function ShopGiftPacketUI:GetLocalString(id)
	local tt = Client.GetTableData("LocalizeRes", id);
	if tt ~= nil then
		return Client.GetTableData("LocalizeRes", id).TextValue;
	else
		return "未定义";
	end;
end

-- 打开查看索要礼物窗体
function ShopGiftPacketUI:OpenViewRequestGiftPanel(productTbl, toUserTbl, msg, askIndex)
	ShopGiftPacketUI.productTbl = productTbl;
	ShopGiftPacketUI.toUserTbl  = toUserTbl;
    ShopGiftPacketUI.askIndex = askIndex;
	BP_STRUCT_Shop_GiftPack_Item_Info.msg = msg;

	BP_SHOPGIFT_UITYPE = 2;

	self:Init()
end

-- 打开打包发送礼物窗体
function ShopGiftPacketUI:OpenSendGiftPanel(productTbl, toUserTbl)
	log("OpenSendGiftPanel open productTbl.money_type=".. productTbl.money_type);
	local money_price = 0;
	if productTbl.discount_price ~= nil and productTbl.discount_price > 0 then
		money_price = productTbl.discount_price;
	else
		money_price = productTbl.money_price;
	end

	ShopGiftPacketUI.productTbl = productTbl;
	ShopGiftPacketUI.toUserTbl  = toUserTbl;
	if StoreSystem.IsUseNewStore() then
		StoreFuncUtils.CheckMoneyIsEnough(productTbl.money_type, money_price, ShopGiftPacketUI.OpenSendGiftPanelCallBack)
	else
		MallSystem.CheckMoneyIsEnough(productTbl.money_type, money_price, ShopGiftPacketUI.OpenSendGiftPanelCallBack);
	end
end

function ShopGiftPacketUI.OpenSendGiftPanelCallBack( isEnough, clickType)
	if isEnough == false then
		log("samcen ShopGiftPacketUI.OpenSendGiftPanelCallBack isEnough == false")
		if StoreSystem.IsUseNewStore() then
			if clickType ==  StoreFuncUtils.CheckMoneyBtnType.Pay then
				EventGiftUIClose();
			end
		else
			if clickType ==  MallSystem.CheckMoneyBtnType.Pay then
				EventGiftUIClose();
			end
		end

		return;
	end

	-- 取消或前往 那么不打开
	if StoreSystem.IsUseNewStore() then
		if clickType ~= StoreFuncUtils.CheckMoneyBtnType.NIL then
			if clickType == StoreFuncUtils.CheckMoneyBtnType.Cancel or clickType == StoreFuncUtils.CheckMoneyBtnType.Pay then
				log("samcen ShopGiftPacketUI.OpenSendGiftPanelCallBack clickType == 0 or clickType == 2")
				return
			end
		end
	else
		if clickType ~= MallSystem.CheckMoneyBtnType.NIL then
			if clickType == MallSystem.CheckMoneyBtnType.Cancel or clickType == MallSystem.CheckMoneyBtnType.Pay then
				log("samcen ShopGiftPacketUI.OpenSendGiftPanelCallBack clickType == 0 or clickType == 2")
				return
			end
		end
	end

	BP_SHOPGIFT_UITYPE = 0;

	GiftPack_PackStyle =
	{
		[1] = {CtrlName="blue",content = ShopGiftPacketUI:GetLocalString("501006"), ImagePath = "/Game/Arts/UI/TableIcons/ItemIcon/Box/Icon_Box_Avatar_1.Icon_Box_Avatar_1"},
		[2] = {CtrlName="pink",content = ShopGiftPacketUI:GetLocalString("501007"), ImagePath = "/Game/Arts/UI/TableIcons/ItemIcon/Box/Icon_Box_Avatar_2.Icon_Box_Avatar_2"},
		[3] = {CtrlName="orange",content = ShopGiftPacketUI:GetLocalString("501008"), ImagePath = "/Game/Arts/UI/TableIcons/ItemIcon/Box/Icon_Box_Avatar_3.Icon_Box_Avatar_3"}
	};

	for i = 1, #GiftPack_PackStyle do
		BP_ARRAY_GiftPack_PackStyle[i] = GiftPack_PackStyle[i];
	end;

	ShopGiftPacketUI:Init()
end

-- 打开请求礼物窗体
function ShopGiftPacketUI:OpenRequireGiftPanel(productTbl, toUserTbl)
	ShopGiftPacketUI.productTbl = productTbl;
	ShopGiftPacketUI.toUserTbl  = toUserTbl;

	BP_SHOPGIFT_UITYPE = 1;

	-- 这个数组不能少于4个哦，蓝图有用到它
	GiftPack_PackStyle =
	{
		[1] = {CtrlName="love",content = ShopGiftPacketUI:GetLocalString("501009"), ImagePath ="/Game/Arts/UI/TableIcons/ItemIcon/Box/Icon_Box_Avatar_3.Icon_Box_Avatar_3"},
		[2] = {CtrlName="birthday",content = ShopGiftPacketUI:GetLocalString("501010"), ImagePath ="/Game/Arts/UI/TableIcons/ItemIcon/Box/Icon_Box_Avatar_3.Icon_Box_Avatar_3"},
		[3] = {CtrlName="console",content = ShopGiftPacketUI:GetLocalString("501011"), ImagePath ="/Game/Arts/UI/TableIcons/ItemIcon/Box/Icon_Box_Avatar_3.Icon_Box_Avatar_3"},
		[4] = {CtrlName="selfdef",content = ShopGiftPacketUI:GetLocalString("501012"), ImagePath ="/Game/Arts/UI/TableIcons/ItemIcon/Box/Icon_Box_Avatar_3.Icon_Box_Avatar_3"},
	};

	for i = 1, #GiftPack_PackStyle do
		BP_ARRAY_GiftPack_PackStyle[i] = GiftPack_PackStyle[i];
	end;

	self:Init()
end

function ShopGiftPacketUI:Init()
	log("samcen ShopGiftPacketUI:Init call")

	if ShopGiftPacketUI.productTbl == nil or ShopGiftPacketUI.toUserTbl == nil then
		return;
	end

	local productTbl = ShopGiftPacketUI.productTbl;
	local toUserTbl  = ShopGiftPacketUI.toUserTbl;


	--BP_STRUCT_Shop_GiftPack_Item_Info.UserUID        = DataMgr.roleData.uid;
	BP_STRUCT_Shop_GiftPack_Item_Info.UserName       = DataMgr.roleData.nickName;
	BP_STRUCT_Shop_GiftPack_Item_Info.UserGender     = DataMgr.roleData.gender;
	--BP_STRUCT_Shop_GiftPack_Item_Info.UserIcon       = DataMgr.roleData.headIconUrl;
	--BP_STRUCT_Shop_GiftPack_Item_Info.UserLV         = DataMgr.roleData.level;
	--BP_STRUCT_Shop_GiftPack_Item_Info.User_box_id    = DataMgr.roleData.cur_avatar_box_id;

	BP_STRUCT_Shop_GiftPack_Item_Info.toUserID       = toUserTbl.gid;
	BP_STRUCT_Shop_GiftPack_Item_Info.toUserName     = toUserTbl.nickName;
	BP_STRUCT_Shop_GiftPack_Item_Info.toUserIcon     = toUserTbl.picUrl;
	BP_STRUCT_Shop_GiftPack_Item_Info.toUserGender   = toUserTbl.sex;
	BP_STRUCT_Shop_GiftPack_Item_Info.toUserLV       = toUserTbl.level;
	BP_STRUCT_Shop_GiftPack_Item_Info.toUserPlatName = toUserTbl.platName;

	local friendData = FriendSystem.GetFriendDataByGID(BP_STRUCT_Shop_GiftPack_Item_Info.toUserID)
	if friendData ~= nil then
		BP_STRUCT_Shop_GiftPack_Item_Info.toUser_box_id  = friendData.cur_avatar_box_id;
	else
		BP_STRUCT_Shop_GiftPack_Item_Info.toUser_box_id  = 2001001;
	end

	BP_STRUCT_Shop_GiftPack_Item_Info.product_id     = productTbl.id;
	BP_STRUCT_Shop_GiftPack_Item_Info.item_id        = productTbl.item_id;
	BP_STRUCT_Shop_GiftPack_Item_Info.color_id       = productTbl.colorID;
	BP_STRUCT_Shop_GiftPack_Item_Info.pattern_id     = productTbl.patternID;
	BP_STRUCT_Shop_GiftPack_Item_Info.pruduct_name   = productTbl.name;
	ShopGiftPacketUI.ChosenTimeLimit                 = productTbl.time;
	ShopGiftPacketUI.ValidHours						 = productTbl.valid_hour
	ShopGiftPacketUI.CurCount                        = productTbl.cnt;
	ShopGiftPacketUI.money_type                      = productTbl.money_type;
	ShopGiftPacketUI.first_money					 = productTbl.first_money;

	if productTbl.discount_price ~= nil and productTbl.discount_price > 0 then
		BP_STRUCT_Shop_GiftPack_Item_Info.product_price  = productTbl.discount_price + productTbl.colorPatternCost;
	else
		BP_STRUCT_Shop_GiftPack_Item_Info.product_price  = productTbl.money_price + productTbl.colorPatternCost;
	end

	local itemData = nil;
	itemData = Client.GetTableData("Item", productTbl.item_id);
	if itemData ~= nil then
		BP_STRUCT_Shop_GiftPack_Item_Info.Quality = itemData.ItemQuality;
		BP_STRUCT_Shop_GiftPack_Item_Info.icon_path = itemData.ItemBigIcon;
	else
		BP_STRUCT_Shop_GiftPack_Item_Info.Quality = 0;
		BP_STRUCT_Shop_GiftPack_Item_Info.icon_path = "";
	end

	itemData = Client.GetTableData("Item", productTbl.money_type);
	if itemData ~= nil then
		BP_STRUCT_Shop_GiftPack_Item_Info.money_path = itemData.ItemSmallIcon;
	else
		BP_STRUCT_Shop_GiftPack_Item_Info.money_path = "";
	end

	print("money_path  = " .. BP_STRUCT_Shop_GiftPack_Item_Info.money_path);
	LuaClassObj.HandleDynamicCreation(bp_shop_gift_packet);
	log("samcen ShopGiftPacketUI:Init UIShow call")
	LuaClassObj.HandleUIMessage(bp_shop_gift_packet, "UIShow");
	UIManager.Show(eUIType.eShopGiftPacket)
	BP_SHOPGIFTPACK_UI_SHOW = true;
end

function ShopGiftPacketUI:Release()
end

function ShopGiftPacketUI.HideUI()
	log("samcen ShopGiftPacketUI.HideUI call")
	UIManager.Hide(eUIType.eShopGiftPacket)
	LuaClassObj.HandleUIMessage(bp_shop_gift_packet, "HideUI");
	BP_SHOPGIFTPACK_UI_SHOW = false;
end

function ShopGiftPacketUI.SendGift()
	log("SendGift");
	local touid         = BP_STRUCT_Shop_GiftPack_Item_Info.toUserID;
	local msg           = BP_STRUCT_Shop_GiftPack_Item_Info.msg;

	if StoreSystem.IsUseNewStore() then
		--ShopGiftPacketLogic.SendGift(touid, buyitem, ShopGiftPacketUI.CheckBoxCtrlIdx, msg, StoreSystem.store_version, ShopGiftPacketUI.askIndex);
		--TODO: sourceIdx
		local sourceIdx = 100
		local askIndex = ShopGiftPacketUI.askIndex
		if askIndex <= 0 then
			askIndex = nil
		end

		local params = {}
		params[StoreSystem.gift_index_uid]          = touid
		params[StoreSystem.gift_index_market_id]    = BP_STRUCT_Shop_GiftPack_Item_Info.product_id
		params[StoreSystem.gift_index_buy_type]     = StoreFuncUtils.ChinaMoneyTypeToMoneyType(ShopGiftPacketUI.money_type)
		params[StoreSystem.gift_index_market_count] = ShopGiftPacketUI.CurCount or 1
		params[StoreSystem.gift_index_letter_style] = ShopGiftPacketUI.CheckBoxCtrlIdx
		params[StoreSystem.gift_index_msg]          = msg
		params[StoreSystem.gift_index_ver]          = StoreSystem.store_version
		params[StoreSystem.gift_index_ask_index]    = askIndex
		params[StoreSystem.gift_index_color]        = nil
		params[StoreSystem.gift_index_pattern]      = nil
		params[StoreSystem.gift_index_valid_hours]  = ShopGiftPacketUI.ValidHours
		params[sourceIdx]                           = StoreFuncUtils.GetBuySource()

		StoreSystem.give_gift_from_market_req_v3(params)
		LuaClassObj.HandleUIMessage(bp_shop_gift_packet, "HideUI");
	else
		local buyitem = {
			shopitem_id = BP_STRUCT_Shop_GiftPack_Item_Info.product_id,
			item_id = BP_STRUCT_Shop_GiftPack_Item_Info.item_id,
			color = BP_STRUCT_Shop_GiftPack_Item_Info.color_id,
			pattern = BP_STRUCT_Shop_GiftPack_Item_Info.pattern_id,
			price = BP_STRUCT_Shop_GiftPack_Item_Info.product_price,
			num = ShopGiftPacketUI.CurCount,
			first_money = ShopGiftPacketUI.first_money;
			time_valid_index = ShopGiftPacketUI.ChosenTimeLimit,
			source = MallSystem.Buy_Source or 2,
		};
		ShopGiftPacketLogic.SendGift(touid, buyitem, ShopGiftPacketUI.CheckBoxCtrlIdx, msg, MallSystem.Version, ShopGiftPacketUI.askIndex);
	end
    ShopGiftPacketUI.askIndex = 0;
end

function ShopGiftPacketUI.PlayAnimation()
	LuaClassObj.HandleUIMessage(bp_shop_gift_packet, "PlayAnim");
end

function ShopGiftPacketUI.GiftPackTellFriendSend()
	local msg           = BP_STRUCT_Shop_GiftPack_Item_Info.msg;
	ShareShopGiftUI.shareToFriendSend(BP_STRUCT_Shop_GiftPack_Item_Info.toUserID, BP_STRUCT_Shop_GiftPack_Item_Info.toUserName, msg)
end

function ShopGiftPacketUI.GiftPackTellFriendBeg()
	local msg           = BP_STRUCT_Shop_GiftPack_Item_Info.msg;
	ShareShopGiftUI.shareToFriendBeg(BP_STRUCT_Shop_GiftPack_Item_Info.toUserID, BP_STRUCT_Shop_GiftPack_Item_Info.toUserName, msg)
end

function EventUpdateCheckIdx()
	ShopGiftPacketUI.CheckBoxCtrlIdx = 0;
	--log_tree("BP_ARRAY_GiftPack_PackStyle=",BP_ARRAY_GiftPack_PackStyle)
	print("BP_STRUCT_Shop_GiftPack_Item_Info.CheckCtrName="..BP_STRUCT_Shop_GiftPack_Item_Info.CheckCtrName);
	for i = 1, #BP_ARRAY_GiftPack_PackStyle do
		if BP_ARRAY_GiftPack_PackStyle[i].CtrlName ==  BP_STRUCT_Shop_GiftPack_Item_Info.CheckCtrName then
			ShopGiftPacketUI.CheckBoxCtrlIdx = i;
		end;
	end;
end

function EventAnimationCallBack()
	ShopGiftPacketUI.SendGift();
end


function EventOpenSendGiftPanel()
	ShopGiftPacketUI:OpenSendGiftPanel(ShopGiftPacketUI.productTbl, ShopGiftPacketUI.toUserTbl);
end

function EventGiftPacketUISendGift()
	log("EventGiftPacketUISendGift");
	-- local msg = string.format(DataMgr.GetMsgByID(501027), BP_STRUCT_Shop_GiftPack_Item_Info.product_price,
	-- 	MallSystem.GetMoneyName(ShopGiftPacketUI.money_type), BP_STRUCT_Shop_GiftPack_Item_Info.pruduct_name,
	-- 	BP_STRUCT_Shop_GiftPack_Item_Info.toUserName);
	local msg = string.format(DataMgr.GetMsgByID(501027), BP_STRUCT_Shop_GiftPack_Item_Info.product_price, BP_STRUCT_Shop_GiftPack_Item_Info.pruduct_name,
		BP_STRUCT_Shop_GiftPack_Item_Info.toUserName);
	CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), msg, ShopGiftPacketUI.PlayAnimation, nil, FuncUtil.GetLocalizeResStr("110036"), FuncUtil.GetLocalizeResStr("110035"));
end

function EventGiftPacketWaiting()
	-- CommonMessageBoxUI:ShowPanel(1, DataMgr.GetMsgByID(102012), "更多包装风格即将上线，敬请期待","确定");
end

function EventGiftPacketUIRequireGift()
	log("EventGiftPacketUIRequireGift");
	local touid         = BP_STRUCT_Shop_GiftPack_Item_Info.toUserID;
	local shopid          = BP_STRUCT_Shop_GiftPack_Item_Info.product_id;
	local msg           = BP_STRUCT_Shop_GiftPack_Item_Info.msg;
	ShopGiftPacketLogic.RequireGift(touid, shopid, ShopGiftPacketUI.CheckBoxCtrlIdx, msg);

	-- 刷新索取请求次数
	LogicGiftShop.market_get_askinfo_req(false)
end

function EventGiftPacketUICheckTempText()
	log("EventGiftPacketUICheckTempText");
	_ , _ , BP_SHOPGIFT_TEMP_TEXT = FuncUtil:CheckName(BP_SHOPGIFT_TEMP_TEXT, nil, nil, true)
end


function EventPushValue()
	log("pushVal");
end
