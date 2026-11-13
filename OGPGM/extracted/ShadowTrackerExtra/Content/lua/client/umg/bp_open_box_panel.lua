OpenBoxtUI = OpenBoxtUI or 
{
	isShow = false;
	isShow10Box = false;
	hasDecomposeItem = false;
	timerList = {};

	minGuarantee = {};
	currentBoxID = 0;
}

BP_STRUCT_OpenBoxPanel_ItemData =
{
	res_id = 0,
	count = 0,
	valid_hours_str = "",
	product_price = 0,
	price_type = 0,
	is_cur_season = "", -- 勇者令积分
	key_price = 0,
	key_10price = 0,
	key_item_id = 0,
	to_res_id = 0,
	to_res_cnt = 0,
	valid_hours = 0,
};
BP_ARRAY_10Box_ItemData =
{
    BP_STRUCT_OpenBoxPanel_ItemData = _G.BP_STRUCT_OpenBoxPanel_ItemData, --定义结构体数组，这种写法要作为规范规定下来
};

BP_Shop_Box_Name  = "Box_MatineeActor";
BP_Shop_BackCamera = "mall_system_weapon";
BP_Open_Box_DecomposeItemId = 0;
BP_Open_10Box_CurBoxIndex = 0;
BP_Open_Box_HaveMinGuarantee = false;
BP_Open_Box_ShowGetGuarantee = false;

BP_IS_Show_10Animation = false;
-- 注册面板
function bp_open_box_panel_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_open_box_panel,
		{
			{Path="/Game/UMG/UI_Logic/Shop/OpenBox_BP.OpenBox_BP_C", Container="Top", ZOrder=BP_ENUM_UI_OPEN_BOX_ZORDER},
			{Path="/Game/UMG/UI_Logic/Shop/OpenBox_Actor_BP.OpenBox_Actor_BP_C", Container="Top", ZOrder=BP_ENUM_UI_OPEN_BOX_ZORDER}
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

local function ShopEventHandler(eventType, eventID, vars)
	if eventID == EVENTID_SHOP_PRICE_UPDATE then
		if ShopSystem.LastBuyInfo ~= nil and next(ShopSystem.LastBuyInfo) ~= nil then
			for shopId,_ in pairs(ShopSystem.LastBuyInfo) do
				BP_STRUCT_OpenBoxPanel_ItemData.product_price = ShopSystem.ItemInfoList[shopId].product_gold_price;
				break;
			end
		end

		LuaClassObj.HandleUIMessage(bp_open_box_panel, "UpdatePrice");
	elseif eventID == EVENTID_UPDATE_OPEN_BOX_PANEL then
		if SupplyMainUI.lastBuyItemData[3] == StoreSystem.label_price_type_fp then	--炸猪令牌
			return;
		end

		if vars ~= nil then
			--local shop_id = vars[1];
			--local priceList = vars[2];
			local info = vars
			local isTen = SupplyMainUI.lastBuyItemData[8] == 10;
			--log_tree("[edward][bp_open_box_panel] SupplyMainUI.lastBuyInfo", vars);

			local priceType = info.price_type;
			local priceNum = 0;
			if priceType == StoreSystem.label_price_type_bp then-- 金币
				priceNum = info.product_gold_price;
				if isTen then
					priceNum = info.ten_price;
				end
			elseif priceType == StoreSystem.label_price_type_fp then--炸猪令牌
				priceNum = info.fp_token_price;
			elseif priceType == StoreSystem.label_price_type_uc then-- 点券
				priceNum = info.ticket_price;
				if isTen then
					priceNum = info.ten_price;
				end
			else-- 1为银碎片，理论上不存在
			end

			if BP_STRUCT_OpenBoxPanel_ItemData.key_item_id > 0 and priceType == StoreSystem.label_price_type_uc and priceNum == 0 then
				BP_STRUCT_OpenBoxPanel_ItemData.key_item_id = 0;
			end

			BP_STRUCT_OpenBoxPanel_ItemData.product_price = priceNum;

			if not isTen then
				LuaClassObj.HandleUIMessage(bp_open_box_panel, "UpdatePrice");
			else
				LuaClassObj.HandleUIMessage(bp_open_box_panel, "Update10BoxPrice");
			end
		end
	end
end
--  0 大厅 1 大厅有组队 2 商城 3 新商城
function OpenBoxtUI.SetOpenBoxBackCamera(cameraType)
	log("OpenBoxtUI.SetOpenBoxBackCamera="..tostring(cameraType));
	if cameraType == 0 then
		BP_Shop_BackCamera = "Lobby1";
	elseif cameraType == 1 then
		BP_Shop_BackCamera = "Lobby2";
	elseif cameraType == 2 then
		BP_Shop_BackCamera = "mall_system_weapon";
	else
		BP_Shop_BackCamera = "new_mall_system_weapon";
	end
	
end

function OpenBoxtUI:ShowPanel(arrayItemData,is10Box,boxPlayModel, boxId, guarantee)
	OpenBoxtUI.isShow = true;
	OpenBoxtUI.isShow10Box = false;
	OpenBoxtUI.hasDecomposeItem = false;
	BP_Open_Box_ShowGetGuarantee = guarantee or false;
	BP_CurSceneCameraIndex = 10101;
	GlobalData.GetMallShow10Animation();
	BP_IS_Show_10Animation = BP_Global_IS_Show_10Animation;
	LuaClassObj.HandleDynamicCreation(bp_open_box_panel);
	EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE, ShopEventHandler);
	EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_UPDATE_OPEN_BOX_PANEL, ShopEventHandler);
	EventSystem:postEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_OPEN_BOX_PANEL);
	BP_STRUCT_OpenBoxPanel_ItemData = {};
	BP_ARRAY_10Box_ItemData = {};
	BP_Open_10Box_CurBoxIndex = 0;

	if is10Box == false then
		for k,v in pairs(arrayItemData) do
			if v and v.res_id then
				if StoreSystem.IsUseNewStore() then
					BP_STRUCT_OpenBoxPanel_ItemData = OpenBoxtUI:GetItemNew(v, false);
				else
					BP_STRUCT_OpenBoxPanel_ItemData = OpenBoxtUI:GetItem(v, false);
				end
				log_tree("BP_STRUCT_OpenBoxPanel_ItemData",BP_STRUCT_OpenBoxPanel_ItemData)
				break;
			end
		end
	else
		log_tree("arrayItemData",arrayItemData);
		OpenBoxtUI.isShow10Box = true;
		for k,v in pairs(arrayItemData) do
			if v and v.res_id then				
				local item = {};	
				if StoreSystem.IsUseNewStore() then
					item = OpenBoxtUI:GetItemNew(v, true);
				else
					item = OpenBoxtUI:GetItem(v, true);
				end	
				--item.count = 1;
				--log_tree("item ",item);
				BP_ARRAY_10Box_ItemData[#BP_ARRAY_10Box_ItemData + 1] = item;
				--[[for i = 1,v.count do
					
				end	--]]			
				BP_STRUCT_OpenBoxPanel_ItemData = item;
				if item.to_res_id ~= 0 then
					OpenBoxtUI.hasDecomposeItem = true;
				end
			end
		end
		if StoreSystem.IsUseNewStore() then
			log_tree("BP_ARRAY_10Box_ItemData",SupplyMainUI.lastBuyInfo);
			if SupplyMainUI.lastBuyInfo ~= nil and next(SupplyMainUI.lastBuyInfo) ~= nil then
				for shopId,Info in pairs(SupplyMainUI.lastBuyInfo) do	
					local shopData = Info;
					if shopData.is_cur_season == nil or shopData.is_cur_season == 0 then
						BP_STRUCT_OpenBoxPanel_ItemData.is_cur_season = "";
					else
						BP_STRUCT_OpenBoxPanel_ItemData.is_cur_season = ""--string.format(Client.GetTableData("LocalizeRes", "4585").TextValue, tostring( tonumber(shopData.is_cur_season)* 10 ));
					end				
					break;
				end
			else
				BP_STRUCT_OpenBoxPanel_ItemData.is_cur_season = "";	
			end
		else
			log_tree("BP_ARRAY_10Box_ItemData",ShopSystem.LastBuyInfo);
			if ShopSystem.LastBuyInfo ~= nil and next(ShopSystem.LastBuyInfo) ~= nil then
				for shopId,Info in pairs(ShopSystem.LastBuyInfo) do	
					local shopData = Info;
					if shopData.is_cur_season == nil or shopData.is_cur_season == 0 then
						BP_STRUCT_OpenBoxPanel_ItemData.is_cur_season = "";
					else
						BP_STRUCT_OpenBoxPanel_ItemData.is_cur_season = "";--string.format(Client.GetTableData("LocalizeRes", "4585").TextValue, tostring( tonumber(shopData.is_cur_season)* 10 ));
					end				
					break;
				end
			else
				BP_STRUCT_OpenBoxPanel_ItemData.is_cur_season = "";	
			end
		end
	end
	
	log("BP_Shop_Box_Name.price_type---------"..BP_STRUCT_OpenBoxPanel_ItemData.price_type);
	--是否是点卷购买 0 是金币 1是国内点卷 2 点卷	
	if BP_STRUCT_OpenBoxPanel_ItemData.price_type == 0 then
		BP_Shop_Box_Name  = "Box_MatineeActor";
	else
		--BP_Shop_Box_Name  = "Box_MatineeActor";
		BP_Shop_Box_Name  = "Box_Mall_Normal";	
		
		local iteminfo = Client.GetTableData("Item", BP_STRUCT_OpenBoxPanel_ItemData.res_id);
		--高品质物品才弹面板
		if iteminfo ~= nil and tonumber(iteminfo.ItemQuality) >= 5 then		
			BP_Shop_Box_Name  = "Box_Mall_Excellent";	
		end	
		 --需要新增加一个动画类型商品id 22000-23000 播放专用动画Box_Mall_KPJP 并且对应红色的宝箱图片

		OpenBoxtUI.currentBoxID = boxId;
		local res_id_num = tonumber(boxId);
		log("res_id_num = ".. tostring(res_id_num));
		log("BP_Shop_Box_Buy_Item_ID = ".. tostring(boxId));


		--特殊处理：在新版本中，这三个宝箱虽然处于旧版本的数值范围内，但是依然使用最新的动画。010版本新加
		local special =
		{
			[10037] = true,
			[10513] = true,
			[10705] = true,
		}
		if special[res_id_num] then 
			if res_id_num == 10037 then
				BP_Shop_Box_Name = "AmmoBox_int_04";
			end

			if res_id_num == 10513  then
				BP_Shop_Box_Name = "AmmoBox_int_02";
			end

			if res_id_num == 10705  then
				BP_Shop_Box_Name = "AmmoBox_int_05";
			end
		else
			if res_id_num >= 22000 and res_id_num <= 22999  then
				BP_Shop_Box_Name  = "Box_Mall_KPJP";
			elseif res_id_num >= 10500 and res_id_num <= 10599 then
				BP_Shop_Box_Name  = "Box_Mall_Yellow";
			elseif res_id_num >= 20500 and res_id_num <= 20599  then
				BP_Shop_Box_Name  = "Box_Mall_Yellow";
			elseif res_id_num >= 10600 and res_id_num <= 10699 then
				BP_Shop_Box_Name  = "Box_Mall_Blue";
			elseif res_id_num >= 20600 and res_id_num <= 20699  then
				BP_Shop_Box_Name  = "Box_Mall_Blue";
			elseif res_id_num >= 20700 and res_id_num <= 20799  then
				BP_Shop_Box_Name  = "Box_MatineeActor";
			elseif res_id_num >= 10700 and res_id_num <= 10799  then
				BP_Shop_Box_Name  = "Box_MatineeActor";

				--新的宝箱
			elseif res_id_num >= 100000 and res_id_num <= 100999  then
				BP_Shop_Box_Name  = "AmmoBox_int_04";
			elseif res_id_num >= 101000 and res_id_num <= 101999 then
				BP_Shop_Box_Name  = "AmmoBox_int_02";
			elseif res_id_num >= 102000 and res_id_num <= 102999  then
				BP_Shop_Box_Name  = "AmmoBox_int_05";
			elseif res_id_num >= 103000 and res_id_num <= 103999  then
				BP_Shop_Box_Name  = "AmmoBox_int_01";
			elseif res_id_num >= 104000 and res_id_num <= 104999  then
				BP_Shop_Box_Name  = "AmmoBox_int_03";
			elseif res_id_num >= 105000 and res_id_num <= 105999  then		--周年庆补给的动画
				BP_Shop_Box_Name  = "AmmoBox_int_7";				
			end
		end
	end
	log("BP_Shop_Box_Name---------"..BP_Shop_Box_Name);
	if is10Box == false then
		--暂定playModel=9为语音包用宝箱界面
		if boxPlayModel == 9 then
			log("ShowActorOpenBoxPanel");
			LuaClassObj.HandleUIMessage(bp_open_box_panel, "UIShowActor");
		else
			LuaClassObj.HandleUIMessage(bp_open_box_panel, "UIShow");
		end
	else		
		LuaClassObj.HandleUIMessage(bp_open_box_panel, "UIShow10Box");
	end
	
	-- LuaClassObj.HandleUIMessage(bp_lobby, "HidePlayers");
    TeamAvatarManager.GetMutex(TeamAvatarManager.MUTEX_OPEN_BOX)
	TeamAvatarManager.HideAllAvatar(TeamAvatarManager.MUTEX_OPEN_BOX)
end

function OpenBoxtUI.CheckCanBuyAgain()
	return MallSystemUI_2.CheckFirstTabIsExited(SHOP_BOX_INDEX) == true;
end

-- 新商城
function OpenBoxtUI.CheckCanBuyAgainNew()
	return SupplyMainUI.CheckHasSupply() == true;
end

-- 对应新商城中的补给开宝箱
function OpenBoxtUI:GetItemNew(v, is10Box)
	local item = {};
	item.res_id = v.res_id
	item.count = v.count or 0
	local str = "";
	if v.valid_hours ~= nil and v.valid_hours > 0 then
		if v.valid_hours >= 24 then
			str = string.gsub(FuncUtil.GetLocalizeResStr(6749), "{0}", tostring(math.ceil(v.valid_hours / 24)));
		else
			str = string.gsub(FuncUtil.GetLocalizeResStr(6748), "{0}", tostring(v.valid_hours));
		end
	end
	item.valid_hours = v.valid_hours or 0;
	item.valid_hours_str = str;
	item.price_type = 0;
	item.product_price = 0;
	item.to_res_id = v.to_res_id or 0;
	item.to_res_cnt = v.to_res_cnt or 0;
	if SupplyMainUI.lastBuyInfo ~= nil and next(SupplyMainUI.lastBuyInfo) ~= nil then
		for shopId,info in pairs(SupplyMainUI.lastBuyInfo) do
			local priceType = info.price_type
			if priceType == StoreSystem.label_price_type_bp then-- 金币
				item.product_price = info.product_gold_price;
				if is10Box then
					item.product_price = info.ten_price;
				end
			elseif priceType == StoreSystem.label_price_type_fp then	--炸猪令牌
				item.product_price = info.fp_token_price;
				item.price_type = 102;-- 对应旧的炸猪令牌类型是102，因为用的旧的开箱逻辑
			elseif priceType == StoreSystem.label_price_type_uc then-- 点券
				item.product_price = info.ticket_price;
				if is10Box then
					item.product_price = info.ten_price;
				end
				item.price_type = 2;
			else-- 1为银碎片，理论上不存在

			end
			if info.is_cur_season == 0 then
				item.is_cur_season = "";
			else
				item.is_cur_season = ""--string.format(Client.GetTableData("LocalizeRes", "4585").TextValue, tostring(info.is_cur_season));
			end
			
			local shopData = info;
			item.key_price = 0;
			item.key_10price = 0;
			item.key_item_id = 0;	
			if shopData ~= nil and shopData.key_item_id > 0 then
				--log("shopData.key_item_id = "..tostring(shopData.key_item_id))
				local itemData = DataMgr.GetHallDepotItemDataByResID(shopData.key_item_id);
				if (itemData ~= nil) then
					--log("itemData.count = "..tostring(itemData.count))
					--log("shopData.key_number = "..tostring(shopData.key_number))
					if shopData.key_number <= itemData.count then
						item.key_price = shopData.key_number;
						if(itemData.count >= 10*tonumber(shopData.key_number)) then
							item.key_10price = 10*tonumber(shopData.key_number);
						end
						item.key_item_id = shopData.key_item_id;
					end 
				 end						
			end
			if item.key_item_id == 0 and next(SupplyMainUI.lastBuyItemData) ~= nil and SupplyMainUI.lastBuyItemData[3] == StoreSystem.label_price_type_exchage then
				SupplyMainUI.lastBuyItemData[3] = StoreSystem.label_price_type_uc;
			end
			break;
		end
	else				
		item.product_price = 0;				
	end
	return item;
end

function OpenBoxtUI:GetItem(v,is10Box)
	local item = {};
	item.res_id = v.res_id
	item.count = v.count or 0
	local str = "";
	if v.valid_hours ~= nil and v.valid_hours > 0 then
		if v.valid_hours >= 24 then
			str = string.format(Client.GetTableData("LocalizeRes", "301173").TextValue, tostring(math.ceil(v.valid_hours / 24)));
		else
			str = string.format(Client.GetTableData("LocalizeRes", "301174").TextValue, tostring(v.valid_hours));
		end
	end
	item.valid_hours = v.valid_hours or 0;
	item.valid_hours_str = str;
	item.price_type = 0;
	item.product_price = 0;
	item.to_res_id = v.to_res_id or 0;
	item.to_res_cnt = v.to_res_cnt or 0;
	if ShopSystem.LastBuyInfo ~= nil and next(ShopSystem.LastBuyInfo) ~= nil then
		for shopId,info in pairs(ShopSystem.LastBuyInfo) do		
			--是否是点卷购买 0 是金币 1 点卷	
			--item.product_price = ShopSystem.ItemInfoList[shopId].product_gold_price;
			local priceType = ShopSystem.ItemInfoList[shopId].price_type;
			if info and info.moneytype then
				priceType = info.moneytype;
			end

			if priceType == 0 then
				item.product_price = ShopSystem.ItemInfoList[shopId].product_gold_price;
			elseif priceType == 102 then--炸猪令牌
				item.product_price = ShopSystem.ItemInfoList[shopId].fp_token_price;
				item.price_type = 102;
			else
				item.product_price = ShopSystem.ItemInfoList[shopId].ticket_price;
				if is10Box then
					item.product_price = ShopSystem.ItemInfoList[shopId].ten_price;
				end
				item.price_type = 2;
			end
			if ShopSystem.ItemInfoList[shopId].is_cur_season == 0 then
				item.is_cur_season = "";
			else
				item.is_cur_season = "";--string.format(Client.GetTableData("LocalizeRes", "4585").TextValue, tostring(ShopSystem.ItemInfoList[shopId].is_cur_season));
			end
			
			local shopData = ShopSystem.ItemInfoList[shopId];
			item.key_price = 0;
			item.key_10price = 0;
			item.key_item_id = 0;	
			if shopData ~= nil and shopData.key_item_id > 0 then
				--log("shopData.key_item_id = "..tostring(shopData.key_item_id))
				local itemData = DataMgr.GetHallDepotItemDataByResID(shopData.key_item_id);
				if (itemData ~= nil) then
					--log("itemData.count = "..tostring(itemData.count))
					--log("shopData.key_number = "..tostring(shopData.key_number))
					if shopData.key_number <= itemData.count then
						item.key_price = shopData.key_number;
						if(itemData.count >= 10*tonumber(shopData.key_number)) then
							item.key_10price = 10*tonumber(shopData.key_number);
						end
						item.key_item_id = shopData.key_item_id;
					end 
				 end						
			end
			
			
			
			break;
		end
	else				
		item.product_price = 0;				
	end
	return item;
end


--检查打开宝箱
function EventCheckOpenBox()
	--log("EventCheckOpenBox")
	--如果打开宝箱获得了高品质物品，则弹高品质物品弹框
	if OpenBoxtUI.isShow10Box then
		local items = {};
		for k,v in pairs(BP_ARRAY_10Box_ItemData) do
			if v and v.res_id then				
				local iteminfo = Client.GetTableData("Item", v.res_id);
				if iteminfo ~= nil then					
					table.insert(items, v);					
				end							
			end
		end
		--log_tree("items",items);
		GoodItemGetUI:ShowGetPanel(items);
	else
		local iteminfo = Client.GetTableData("Item", BP_STRUCT_OpenBoxPanel_ItemData.res_id);-- BP_ARRAY_Item[BP_STRUCT_OpenBoxPanel_ItemData.res_id];
		if iteminfo ~= nil then
			local items = {};
			table.insert(items, BP_STRUCT_OpenBoxPanel_ItemData);

			--GoodItemGetUI:ShowGetPanelWithCallback(items, OpenBoxtUI.FinishShowGoodItemFor1Box);
			GoodItemGetUI:ShowGetPanelWithCallback(items, nil);
		end
		--log_tree("items",items);
		LuaClassObj.HandleUIMessage(bp_open_box_panel, "immediateBtnIn");
	end
	
end

--检查打开宝箱
function EventCheckOpen10Box()
	log("EventCheckOpen10Box BP_Open_10Box_CurBoxIndex = "..tostring(BP_Open_10Box_CurBoxIndex));
	--如果打开宝箱获得了高品质物品，则弹高品质物品弹框
	if OpenBoxtUI.isShow10Box then
		local items = {};
		table.insert(items, BP_ARRAY_10Box_ItemData[BP_Open_10Box_CurBoxIndex]);
		
		--EventOpenNext10Box();
		--if BP_IS_Show_10Animation == false then
			GoodItemGetUI:ShowGetPanelWithCallback(items,EventOpenNext10Box);
		--end
		--log("GoodItemGetUI.isShow"..tostring(GoodItemGetUI.isShow));
		-- rain 十连抽红包触发时机改动 http://tapd.oa.com/iGameInternational/prong/stories/view/1020360302063686607
		if GoodItemGetUI.isShow == false then
			for _, timer in ipairs(OpenBoxtUI.timerList) do
				Timer.RemoveTimer(timer);
			end
			OpenBoxtUI.timerList = {};
			if BP_Open_10Box_CurBoxIndex >= 10 then
				local corpsWelfareRedEnvelopesfuncCall = function()
					--rainpan timer的callback不能为nil，否则会报error traceback
				end
				if OpenBoxtUI.hasDecomposeItem == true then
					table.insert(OpenBoxtUI.timerList, Timer.InsertTimer(0.7 + 0.84 + 0.7, corpsWelfareRedEnvelopesfuncCall, false, false));
				else
					table.insert(OpenBoxtUI.timerList, Timer.InsertTimer(0.7, corpsWelfareRedEnvelopesfuncCall,false, false))
				end
			end
			
			LuaClassObj.HandleUIMessage(bp_open_box_panel, "DelayShow10BoxItem");
		end
		
		if BP_Open_10Box_CurBoxIndex >= 10 then
			-- 10个物品显示完成
			local playDecomposeAnimfuncCall = function()
				LuaClassObj.HandleUIMessageNoFetch(bp_open_box_panel, "PlayDecomposeAnims");
			end
			if OpenBoxtUI.hasDecomposeItem == true then
				table.insert(OpenBoxtUI.timerList, Timer.InsertTimer(0.7, playDecomposeAnimfuncCall, false, false));
			end
		end
	end	
end

function OpenBoxtUI.FinishShowGoodItemFor1Box()
	CorpsWelfareRedEnvelopesUI.ShowPanel();
end

-- 高品质物品展示后，关闭的回调
function EventOpenNext10Box()
	-- rainpan 所有弹红包的时机应都在关闭单抽/十连抽界面后 http://tapd.oa.com/20360302/bugtrace/bugs/view?bug_id=1020360302069574043&url_cache_key=4d62a4484785e3fc4c99ba88a06bd8d5
	--[[
	if BP_Open_10Box_CurBoxIndex >= 10 then
		-- 10个物品显示完成
		CorpsWelfareRedEnvelopesUI.ShowPanel();
	end
	--]]
	LuaClassObj.HandleUIMessage(bp_open_box_panel, "Show10BoxItem");
end
--再买一次
function EventOpenBoxBuyAgain()
	if StoreSystem.IsUseNewStore() then
		-- 新商城再买一次
		if next(SupplyMainUI.lastBuyInfo) ~= nil and next(SupplyMainUI.lastBuyItemData) ~= nil and next(StoreSystem.supply_data) ~= nil then
			for _, supplyData in pairs(SupplyMainUI.lastBuyInfo) do
				local data = StoreSystem.supply_data[supplyData.product_id];
				if data ~= nil then
					local item = SupplyMainUI.MakeSupplyInfo(data);
					-- 单抽
					SupplyMainUI.UpdateSupplyOneDiscountInfoByVip(item);
					SupplyMainUI.UpdateSupplyOneDiscountInfo(item);
					-- 10连抽
					SupplyMainUI.UpdateSupplyTenDiscountInfo(item);

					if SupplyMainUI.lastBuyItemData[8] == 1 then
						SupplyMainUI.UpdateSupplyOneDiscountInfo(item);
						SupplyMainUI.RequestBuySupplyBox(item, true, SupplyMainUI.lastBuyItemData[3], true);
					else
						SupplyMainUI.UpdateSupplyTenDiscountInfo(item);
						SupplyMainUI.RequestBuyTenSupplyBox(item, true);
					end
				end
				break;
			end
		end
	else
		-- 老商城再买一次
		ShopSystem.shop_buy_req(ShopSystem.LastBuyInfo);
	end

	EventSystem:postEvent(EVENTTYPE_SHOP, EVENTID_SHOP_BUY_AGAIN_CLICK);
end

function OpenBoxtUI.NotifyMinGuaranteeInfo(reward_items)
	log("[HHF]OpenBoxtUI.NotifyMinGuaranteeInfo");
	if FuncUtil:CountTable(reward_items) > 0 then
		BP_Open_Box_HaveMinGuarantee = true;
		OpenBoxtUI.minGuarantee = reward_items;
	else
		BP_Open_Box_HaveMinGuarantee = false;
		OpenBoxtUI.minGuarantee = {};
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_open_box_panel, "SetHaveGuaranteeValue");
end

function EventCollectMinGuarantee()
	log("[HHF]EventCollectMinGuarantee");
	--[[for test
	OpenBoxtUI.minGuarantee = {};
	OpenBoxtUI.minGuarantee[1532001] = 3;
	--]]
	StoreSystem.receive_guarantee_reward_req(OpenBoxtUI.minGuarantee);
end

function OpenBoxtUI.OnGetMinGuarantee()
	log("[HHF]OpenBoxtUI.OnGetMinGuarantee");
	local arrayItemData = {};
	for k, v in pairs(OpenBoxtUI.minGuarantee) do
		local temp = {};
		temp.res_id = k;
		temp.count = v;
		temp.valid_hours = 0;
		table.insert(arrayItemData, temp);
	end

	OpenBoxtUI:ShowPanel(arrayItemData, false, 0, OpenBoxtUI.currentBoxID, true);
	BP_Open_Box_HaveMinGuarantee = false;
	LuaClassObj.HandleUIMessageNoFetch(bp_open_box_panel, "SetHaveGuaranteeValue");
end

function EventAfterHideOpenBox()
	--log_tree("33333333333333333333333333333333333333333", ShopSystem.LastBuyInfo);
	log("EventAfterHideOpenBox close");
	if OpenBoxtUI.isShow ==  true then	

		EventSystem:unregistEvent(EVENTTYPE_SHOP, EVENTID_SHOP_PRICE_UPDATE, ShopEventHandler);
		EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_UPDATE_OPEN_BOX_PANEL, ShopEventHandler);
			
		-- LuaClassObj.HandleUIMessage(bp_lobby, "ShowPlayers");
    	TeamAvatarManager.ReleaseMutex(TeamAvatarManager.MUTEX_OPEN_BOX)
		TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_OPEN_BOX)
		
		MallSystemUI_2.RevertFromBox();
		OpenBoxtUI.isShow = false;
		OpenBoxtUI.isShow10Box = false;
	end
	if LuckAirDropUI.GetEndTimeStamp() > 0 then --如果是
		LuaClassObj.HandleUIMessage(bp_lobby, "ShowLobbyAirDropBoxActor");
	end
end

function EventShowCorpsWelfareRedEnvelopesUI()
	CorpsWelfareRedEnvelopesUI.ShowPanel();
end

function OpenBoxtUI.HidePanel()
	LuaClassObj.HandleUIMessage(bp_open_box_panel, "UIHide");
end

function EventOnBPDestruct()
	TeamAvatarManager.ReleaseMutex(TeamAvatarManager.MUTEX_OPEN_BOX)
	TeamAvatarManager.ShowAllAvatar(TeamAvatarManager.MUTEX_OPEN_BOX)
end

function EventSetInfo_Push()	
end

function EventFetchInfo()
end

function OpenBoxtUI.ShowCantBuyAgainMessage()
	DataMgr.ShowMessageBoxByID(430104);
end

function EventSaveIsShow10Animation()
	BP_Global_IS_Show_10Animation = BP_IS_Show_10Animation;
	GlobalData.SaveMallShow10Animation();
end

function OpenBoxtUI.Close()
	LuaClassObj.HandleUIMessage(bp_open_box_panel, "OnClickOK");
end

