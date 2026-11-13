-- added by haifenghe, 2018/09/11

Bargain_System_UI = Bargain_System_UI or {
	bShowing = false,
	tabAllSaleItems = 0,
	tabMySaleItems = 1,
	tabInviteItems = 2,

	serverTime = 0,
	preUpdateTime = 0,

	notStart = 0,
	inProgress = 1,
	haveEnded = 2,

	priceRatio = 10,

	friendsHelpedMe = {},
	showTipsInterval = 60,
	preShowTipsTime = 0,

	treasureChestDrop = {},
}

BP_STRUCT_Bargain_ItemGameInfo = {
	gl = false,
	jk = false,
	lite = false,
}

BP_STRUCT_Bargain_ItemInfo = {
	tab = 0,
	bargain_index = 0,
	shop_id = 0,
	item_id = 0,
	item_type = 0,
	sub_type = 0,
	name = "",
	desc = "",
	path = "",
	big_path = "",
	quality = 0,
	selected = false,
	wore = false,
	sort = 0,
	item_num = 0,
	expire_time = 0,
	ori_price = 0,
	cur_price = 0,
	buy_price = 0,
	current_times = 0,
	limit_times = 0,
	cur_orderid = 0,

	start_time = 0,
	end_time = 0,
	valid_time = 0,
	open_state = 0,
	left_time = 0,
	zero_cnt = 0,

	uid = "",
	create_time = 0,
	create_date = "",
	help_num = 0,
	last_time = 0,
	finish = 0,
	is_helpnum_max = false;

	BP_STRUCT_Bargain_ItemGameInfo = _G.BP_STRUCT_Bargain_ItemGameInfo,
}

BP_BargainSystemUI_Switch = Bargain_System_UI.tabAllSaleItems;
BP_BargainSystemUI_MyTabReddot = false;
BP_BargainSystemUI_CurrentLeftTime = 0;
BP_BargainSystemUI_SystemOpenState = Bargain_System_UI.notStart;
BP_BargainSystemUI_Maxdiscount = 100;

BP_BargainSystemUI_CurrentClickShopID = 0;
BP_BargainSystemUI_CurrentClickItemID = 0;
BP_BargainSystemUI_CurrentClickItemSubType = 0;
BP_BargainSystemUI_CurrentClickOrderID = 0;

---[[用于跳转并选中物品时
BP_BargainSystemUI_CurrentClickItemIndex = 0;
BP_BargainSystemUI_CurrentClickItemName = "";
BP_BargainSystemUI_CurrentClickItemQuality = 0;
BP_BargainSystemUI_CurrentClickItemDesc = "";
--]]

BP_ARRAY_BargainSystemUI_AllSaleItems = {
	BP_STRUCT_Bargain_ItemInfo = _G.BP_STRUCT_Bargain_ItemInfo,
}

BP_ARRAY_BargainSystemUI_MySaleItems = {
	BP_STRUCT_Bargain_ItemInfo = _G.BP_STRUCT_Bargain_ItemInfo,
}

BP_ARRAY_BargainSystemUI_TreasureChestItems = {
	BP_STRUCT_Bargain_ItemInfo = _G.BP_STRUCT_Bargain_ItemInfo,
}


BP_STRUCT_BargainSystemUI_StateInfo = {
	id = 0,
	uid = "",
	show_type = 0,
	helpnum = 0,
	cur_price = 0,
	ori_price = 0,
	shopid = 0,
	createtime = 0,
	headicon_url = "",
	frame_level = 0,
	name = "",
	itemid = 0,
	isCrops = false;
	timeString = "";
	buy_price = 0;
}

--拼多多统一好友和军团的状态消息（map，无排序）
BargainSystemUI_StateInfo_Map = {
	BP_STRUCT_BargainSystemUI_StateInfo = _G.BP_STRUCT_BargainSystemUI_StateInfo,
}

--拼多多统一好友和军团的状态消息(array，有排序)
BP_ARRAY_BargainSystemUI_StateInfo = {
	BP_STRUCT_BargainSystemUI_StateInfo = _G.BP_STRUCT_BargainSystemUI_StateInfo,
}

--当期总金币数
BP_BargainSystemUI_TotalMoney = 0;

--档期总军团币数
BP_BargainSystemUI_TotalCorpsMoney = 0;

--分享界面红点
BP_BargainSystemUI_InviteRedDot = false;


function bp_bargain_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_bargain,
		{
			{Path="/Game/UMG/UI_Logic/PDDSystem/Bargain_Logic_BP.Bargain_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_PDD_SYSTEM+2}
		},
		{"Lobby"},
		false, 
		Bargain_System_UI.bp_bargain_OnModeSwitched ~= nil,
		true
	);
end

function Bargain_System_UI.Show(shopID)
	log("[HHF]Bargain_System_UI.Show, shopID = " .. tostring(shopID));
	Bargain_Logic.pdd_bargain_history_orders_req();
	Bargain_System_UI.Init();
	BP_BargainSystemUI_MyTabReddot = PDD_System_UI.NeedShowBargainMyTabReddot();
	LuaClassObj.HandleUIMessage(bp_bargain, "UIShow");
	Bargain_System_UI.bShowing = true;
	Bargain_System_UI.needSelectItemID = shopID;
end

function Bargain_System_UI.SetServerTime(now_time)
	log("[HHF]Bargain_System_UI.SetServerTime, now_time = " .. tostring(now_time));
	Bargain_System_UI.serverTime = now_time;
	Bargain_System_UI.preUpdateTime = 0;
	Bargain_System_UI.preShowTipsTime = 0;
end

function Bargain_System_UI.Tick(deltaTime)
	--log("[HHF]Bargain_System_UI.Tick, localTimespan = " .. tostring(localTimespan));
	if Bargain_System_UI.serverTime ~= 0 then
		Bargain_System_UI.serverTime = Bargain_System_UI.serverTime + deltaTime;

		if Bargain_System_UI.serverTime - Bargain_System_UI.preUpdateTime > 1 then
			Bargain_System_UI.preUpdateTime = Bargain_System_UI.serverTime;
			if Bargain_System_UI.bShowing == true then
				Bargain_System_UI.UpdateTime();
				BP_BargainSystemUI_MyTabReddot = PDD_System_UI.NeedShowBargainMyTabReddot();
				LuaClassObj.HandleUIMessage(bp_bargain, "UpdateData");
			end

			Bargain_Detail_UI.UpdateData();
		end

		if Bargain_System_UI.serverTime - Bargain_System_UI.preShowTipsTime > Bargain_System_UI.showTipsInterval then
			Bargain_System_UI.preShowTipsTime = Bargain_System_UI.serverTime;
			local curStatus = string.lower(LuaClassObj.GetGameStatus(bp_lobby));
			if curStatus == "lobby" then				
				local tips = Bargain_System_UI.GetTotalHelpMeInfo();
				if tips ~= nil then
					PopUpNoticeUI.ShowNewNotice(tips);
				end
			end
		end
	end
end

function Bargain_System_UI.GetTotalHelpMeInfo()
	--log("[HHF]Bargain_System_UI.GetTotalHelpMeInfo");
	local num = FuncUtil:CountTable(Bargain_System_UI.friendsHelpedMe);
	if num > 0 then
		local name = "";
		local total_cut = 0;		
		for k, v in pairs(Bargain_System_UI.friendsHelpedMe) do
			if name == "" then
				name = v.name;
			end
			total_cut = total_cut + v.cut;
		end
		Bargain_System_UI.friendsHelpedMe = {};

		if num > 1 then
			local tips = FuncUtil.GetLocalizeResStr(6293);
			tips = string.format(tips, name);
			tips = string.gsub(tips, "{0}", tostring(num));
			tips = string.gsub(tips, "{1}", tostring(total_cut));
			return tips;
		else
			local tips = FuncUtil.GetLocalizeResStr(6292);
			tips = string.format(tips, name);
			tips = string.gsub(tips, "{0}", tostring(total_cut));
			return tips;
		end
	else
		return nil;
	end
end

function Bargain_System_UI.UpdateTime()
	BP_BargainSystemUI_SystemOpenState = Bargain_Logic.GetSystemOpenState();
	if BP_BargainSystemUI_SystemOpenState == Bargain_System_UI.notStart then
		BP_BargainSystemUI_CurrentLeftTime = PDD_System_Logic.pddSystem_Time.begin_timestamp - Bargain_System_UI.serverTime;
	elseif BP_BargainSystemUI_SystemOpenState == Bargain_System_UI.inProgress then
		BP_BargainSystemUI_CurrentLeftTime = PDD_System_Logic.pddSystem_Time.end_timestamp - Bargain_System_UI.serverTime;
	elseif BP_BargainSystemUI_SystemOpenState == Bargain_System_UI.haveEnded then
		BP_BargainSystemUI_CurrentLeftTime = -1;
	else
		log("[HHF]Bargain_System_UI.UpdateTime, why enter this branch?");
	end
	--log("[HHF]Bargain_System_UI.UpdateTime, BP_BargainSystemUI_SystemOpenState = " .. tostring(BP_BargainSystemUI_SystemOpenState) .. ", BP_BargainSystemUI_CurrentLeftTime = " .. tostring(BP_BargainSystemUI_CurrentLeftTime));

	Bargain_System_UI.UpdateItemLeftTime(BP_ARRAY_BargainSystemUI_AllSaleItems);
	Bargain_System_UI.UpdateItemLeftTime(BP_ARRAY_BargainSystemUI_MySaleItems);
end

function Bargain_System_UI.UpdateItemLeftTime(tempList)	
	for k, v in pairs(tempList) do
		if v.tab == Bargain_System_UI.tabAllSaleItems then
			v.open_state = Bargain_System_UI.GetOpenState(v.start_time, v.end_time, Bargain_System_UI.serverTime);
			if v.open_state == Bargain_System_UI.notStart then
				v.left_time = PDD_System_Logic.pddSystem_Time.begin_timestamp - Bargain_System_UI.serverTime;
			elseif v.open_state == Bargain_System_UI.inProgress then
				if v.cur_orderid == 0 then
					v.left_time = 0;
				else
					v.left_time = v.create_time + v.valid_time - Bargain_System_UI.serverTime;
				end
			else
				v.left_time = 0;
			end

			if v.left_time < 0 then
				v.left_time = 0;
			end
		else
			v.left_time = v.create_time + v.valid_time - Bargain_System_UI.serverTime;
			if v.left_time < 0 then
				v.left_time = 0;
			end

			v.open_state = Bargain_System_UI.GetOrderState(v.left_time, v.finish);
		end
        if v.left_time > BP_BargainSystemUI_CurrentLeftTime then
            v.left_time = BP_BargainSystemUI_CurrentLeftTime;
        end
	end
end

function Bargain_System_UI.GetReigonByUID(uid)
	local result = "";
	if string.sub(tostring(uid), 1, 1) == "5" then
		result = "gl";
	elseif string.sub(tostring(uid), 1, 1) == "6" then
		result = "jk";
	elseif string.sub(tostring(uid), 1, 1) == "7" then
		result = "lite";
	else
		result = "gl";
	end

	--log("[HHF]Bargain_System_UI.GetReigonByUID, uid = " .. tostring(uid) .. ", result = " .. tostring(result));
	return result;
end

function Bargain_System_UI.SetData(shop_cfg, shop_stat, order_list, max_discount ,total_money,total_corpsmoney)
	BP_ARRAY_BargainSystemUI_AllSaleItems = {};
	for k, v in pairs(shop_cfg) do
		local saleItem = Bargain_System_UI.GenerateBargainItemInfo(v, shop_stat);
		if saleItem ~= nil then
			local region = Bargain_System_UI.GetReigonByUID(DataMgr.roleData.uid);
			if saleItem.BP_STRUCT_Bargain_ItemGameInfo[region] == true then
				saleItem.tab = Bargain_System_UI.tabAllSaleItems;
				saleItem.uid = DataMgr.roleData.uid;
				saleItem.help_num = 0;
				saleItem.last_time = 0;
				saleItem.finish = 0;

				saleItem.open_state = Bargain_System_UI.GetOpenState(saleItem.start_time, saleItem.end_time, Bargain_System_UI.serverTime);
				if saleItem.open_state == Bargain_System_UI.notStart then
					saleItem.left_time = saleItem.start_time - Bargain_System_UI.serverTime;
				elseif saleItem.open_state == Bargain_System_UI.inProgress and saleItem.cur_orderid ~= 0 then
					saleItem.left_time = saleItem.create_time + v.valid_time - Bargain_System_UI.serverTime;
				else
					saleItem.left_time = 0;
				end

				if saleItem.left_time < 0 then
					saleItem.left_time = 0;
				elseif saleItem.left_time > BP_BargainSystemUI_CurrentLeftTime then
					saleItem.left_time = BP_BargainSystemUI_CurrentLeftTime;
				end

				table.insert(BP_ARRAY_BargainSystemUI_AllSaleItems, saleItem);
			else
				log("[HHF]Bargain_System_UI.SetData, Hide shop_id = " .. tostring(saleItem.shop_id));
			end
		end
	end
	Bargain_System_UI.SortItemList(Bargain_System_UI.tabAllSaleItems);

	BP_ARRAY_BargainSystemUI_MySaleItems = {};
	for k, v in pairs(order_list) do
		if v.brief ~= nil then
			local shopInfo = shop_cfg[v.brief.shopid];
			if shopInfo ~= nil then
				local saleItem = Bargain_System_UI.GenerateBargainItemInfo(shopInfo, shop_stat);
				if saleItem ~= nil then
					saleItem.tab = Bargain_System_UI.tabMySaleItems;
					saleItem.uid = tostring(v.uid);
					saleItem.help_num = v.brief.helpnum;
					saleItem.last_time = v.brief.lasttime;
					saleItem.finish = v.brief.finish;

					saleItem.create_time = v.brief.createtime;
					saleItem.create_date = os.date('!%Y-%m-%d', saleItem.create_time);
					saleItem.cur_orderid = v.orderid;
					saleItem.cur_price = v.brief.cur_price * Bargain_System_UI.priceRatio;
					saleItem.zero_cnt = 0;
					saleItem.buy_price = v.brief.buy_price * Bargain_System_UI.priceRatio;

					saleItem.left_time = saleItem.create_time + shopInfo.valid_time - Bargain_System_UI.serverTime;
					saleItem.is_helpnum_max = (v.brief.helpnum >= BP_BargainDetail_MaxHelpTime);
					if saleItem.left_time < 0 then
						saleItem.left_time = 0;
					elseif saleItem.left_time > BP_BargainSystemUI_CurrentLeftTime then
						saleItem.left_time = BP_BargainSystemUI_CurrentLeftTime;
					end
					saleItem.open_state = Bargain_System_UI.GetOrderState(saleItem.left_time, saleItem.finish);

					
					table.insert(BP_ARRAY_BargainSystemUI_MySaleItems, saleItem);
				end
			else
				log("[HHF]Bargain_System_UI.SetData, no exist shopid = " .. tostring(v.brief.shopid));
			end
		end
	end
	Bargain_System_UI.SortItemList(Bargain_System_UI.tabMySaleItems);
	
	BP_BargainSystemUI_TotalMoney = total_money;
	BP_BargainSystemUI_TotalCorpsMoney = total_corpsmoney;

	if max_discount ~= nil then
		BP_BargainSystemUI_Maxdiscount = max_discount;
	end
	
	if Bargain_System_UI.bShowing then
		LuaClassObj.HandleUIMessage(bp_bargain, "SetData");
	end

	Bargain_System_UI.SelectItemByID(Bargain_System_UI.needSelectItemID);
end

function Bargain_System_UI.SelectItemByID(itemID)
	log("[HHF]Bargain_System_UI.SelectItemByID, itemID = " .. tostring(itemID));
	if itemID ~= nil then
		local found = false;
		for k, v in pairs(BP_ARRAY_BargainSystemUI_AllSaleItems) do
			if v.item_id == itemID then
				found = true;

				BP_BargainSystemUI_CurrentClickItemID = itemID;
				BP_BargainSystemUI_CurrentClickItemSubType = v.sub_type;
				BP_BargainSystemUI_CurrentClickShopID = v.shop_id;
				BP_BargainSystemUI_CurrentClickOrderID = v.cur_orderid;
				EventOnClickBargainItem();

				BP_BargainSystemUI_CurrentClickItemIndex = k - 1;
				BP_BargainSystemUI_CurrentClickItemName = v.name;
				BP_BargainSystemUI_CurrentClickItemQuality = v.quality;
				BP_BargainSystemUI_CurrentClickItemDesc = v.desc;
				LuaClassObj.HandleUIMessageNoFetch(bp_bargain, "SetNameAndDescInfo");
				break;
			end
		end
	end
end

function Bargain_System_UI.SortItemList(tab)
	log("[HHF]Bargain_System_UI.SortItemList, tab = " .. tostring(tab));
	if tab == Bargain_System_UI.tabAllSaleItems then
		if #BP_ARRAY_BargainSystemUI_AllSaleItems > 1 then
			table.sort(BP_ARRAY_BargainSystemUI_AllSaleItems, 
				function(a, b)
					if a.open_state == b.open_state then
						if (a.limit_times - a.current_times > 0 or a.left_time > 0) and 
						   (b.limit_times - b.current_times > 0 or b.left_time > 0) then
							return a.sort < b.sort;
						else
							return a.limit_times - a.current_times + a.left_time > b.limit_times - b.current_times + b.left_time;
						end
					else
						return a.open_state < b.open_state;
					end
				end);
		end
	elseif tab == Bargain_System_UI.tabMySaleItems then
		if #BP_ARRAY_BargainSystemUI_MySaleItems > 1 then
			table.sort(BP_ARRAY_BargainSystemUI_MySaleItems, 
				function(a, b)
					if a.open_state == b.open_state then
						return a.create_time > b.create_time;
					else
						return a.open_state < b.open_state;
					end
				end);
		end
	end
end

function Bargain_System_UI.GenerateBargainItemInfo(shop_item_cfg, shop_stat)
	if shop_item_cfg.item_id ~= nil then
		local itemInfo = Client.GetTableData("Item", shop_item_cfg.item_id);
		--log_tree("[HHFTEST]Bargain_System_UI.GenerateBargainItemInfo, shop_stat = ", shop_stat);
		if itemInfo ~= nil then
			local saleItem = {};
			saleItem.bargain_index = shop_item_cfg.index;
			saleItem.shop_id = shop_item_cfg.id;
			saleItem.item_id = shop_item_cfg.item_id;
			saleItem.item_type = itemInfo.ItemType;
			saleItem.sub_type = Bargain_System_UI.GetBargainTypeByItemType(itemInfo);
			saleItem.name = itemInfo.ItemName;
			saleItem.desc = itemInfo.ItemDesc;
			saleItem.path = itemInfo.ItemSmallIcon;
			saleItem.big_path = itemInfo.ItemBigIcon;
			saleItem.quality = itemInfo.ItemQuality;
			saleItem.selected = false;
			saleItem.wore = false;
			saleItem.sort = shop_item_cfg.sort;
			saleItem.item_num = shop_item_cfg.item_num;
			saleItem.expire_time = shop_item_cfg.item_expire_time;
			saleItem.ori_price = shop_item_cfg.ori_price * Bargain_System_UI.priceRatio;

			if shop_stat[saleItem.shop_id] ~= nil then
				saleItem.cur_price = shop_stat[saleItem.shop_id].cur_price * Bargain_System_UI.priceRatio;
				saleItem.current_times = shop_stat[saleItem.shop_id].create_cnt;
				saleItem.limit_times = shop_stat[saleItem.shop_id].limit;
				saleItem.cur_orderid = shop_stat[saleItem.shop_id].cur_orderid;
				saleItem.create_time = shop_stat[saleItem.shop_id].create_time;
				saleItem.zero_cnt = shop_stat[saleItem.shop_id].zero_cnt;
				saleItem.buy_price = shop_stat[saleItem.shop_id].buy_price * Bargain_System_UI.priceRatio;
			else
				saleItem.cur_price = 0;
				saleItem.current_times = 0;
				saleItem.limit_times = 1;
				saleItem.cur_orderid = 0;
				saleItem.create_time = 0;
				saleItem.zero_cnt = 0;
			end

			saleItem.start_time = PDD_System_Logic.pddSystem_Time.begin_timestamp;
			saleItem.end_time = PDD_System_Logic.pddSystem_Time.end_timestamp;
			saleItem.valid_time = shop_item_cfg.valid_time;

			saleItem.BP_STRUCT_Bargain_ItemGameInfo = {};
			saleItem.BP_STRUCT_Bargain_ItemGameInfo.gl = shop_item_cfg.game_apps[1320] or false;
			saleItem.BP_STRUCT_Bargain_ItemGameInfo.jk = shop_item_cfg.game_apps[1321] or false;
			saleItem.BP_STRUCT_Bargain_ItemGameInfo.lite = shop_item_cfg.game_apps[1324] or false;

			return saleItem;
		end
	end

	return nil;
end

function Bargain_System_UI.GetBargainTypeByItemType(itemInfo)
	local type = Bargain_System_UI.generalSubType;
	if itemInfo.ItemType == 1 then 													            -- 武器
		type = PDD_System_UI.type_Weapon;
	elseif itemInfo.ItemType == 4 and math.floor(itemInfo.ItemSubType / 100) == 4 then      -- Avatar
		type = itemInfo.ItemSubType;
	elseif itemInfo.ItemType == 5 then                                                          -- 背包（头盔）
		type = itemInfo.ItemSubType;
	elseif itemInfo.ItemType == 8 or itemInfo.ItemType == 9 then                                -- 载具
		type = PDD_System_UI.type_Vehicle;
	elseif itemInfo.ItemType == 15 and math.floor(itemInfo.ItemSubType / 100) == 15 then    -- 宝箱
		type = PDD_System_UI.type_TreasureChest;
	elseif itemInfo.ItemType == 22 then 											            -- 表情
		type = PDD_System_UI.type_Expression;
	elseif itemInfo.ItemType == 4 and math.floor(itemInfo.ItemSubType / 100) == 7 then      -- 降落伞
		type = PDD_System_UI.type_GeneralItem;
	else
		type = PDD_System_UI.type_GeneralItem;
	end

	--[[log("[HHF]Bargain_System_UI.GetBargainTypeByItemType, PDDType = " .. tostring(type) ..
		" when ItemType = " .. tostring(itemInfo.ItemType) ..
		" and ItemSubType = " .. tostring(itemInfo.ItemSubType));
		]]
	return type;
end

function Bargain_System_UI.GetOpenState(start_time, end_time, now)
	if now < start_time then
		return Bargain_System_UI.notStart;
	elseif now < end_time then
		return Bargain_System_UI.inProgress;
	else
		return Bargain_System_UI.haveEnded;
	end
end

function Bargain_System_UI.GetOrderState(left_time, finish)
	if finish >= 2 then
		return Bargain_System_UI.inProgress;
	else
		if left_time > 0 then
			return Bargain_System_UI.notStart;
		else
			return Bargain_System_UI.haveEnded;
		end
	end
end

function Bargain_System_UI.Init()
	log("[HHF]Bargain_System_UI.Init");
	LuaClassObj.HandleDynamicCreation(bp_bargain);
end

function Bargain_System_UI.Release()
	log("[HHF]Bargain_System_UI.Release");
	BP_BargainSystemUI_Switch = Bargain_System_UI.tabAllSaleItems;
	BP_ARRAY_BargainSystemUI_AllSaleItems = {};
	BP_ARRAY_BargainSystemUI_MySaleItems = {};
	Bargain_System_UI.serverTime = 0;
	Bargain_System_UI.friendsHelpedMe = {};
	Bargain_System_UI.bShowing = false;
	Bargain_System_UI.treasureChestDrop = {};
end

function Bargain_System_UI.Hide()
	LuaClassObj.HandleUIMessage(bp_bargain, "UIHide");
	Bargain_System_UI.bShowing = false;
end

function Bargain_System_UI.GetCurrentArrayList()
	--log("[HHF]Bargain_System_UI.GetCurrentArrayList, BP_BargainSystemUI_Switch = " .. tostring(BP_BargainSystemUI_Switch));
	local tempList = {};

	if BP_BargainSystemUI_Switch == Bargain_System_UI.tabAllSaleItems then
		tempList = BP_ARRAY_BargainSystemUI_AllSaleItems;
	elseif BP_BargainSystemUI_Switch == Bargain_System_UI.tabMySaleItems then
		tempList = BP_ARRAY_BargainSystemUI_MySaleItems;
	end
	
	return tempList;
end

function EventCloseBargainSystemUI()
	Bargain_System_UI.Hide();
end

function EventBargainSystemUIFetchInfo()
	-- body
end

function EventOnClickBargainItem()
	log("[HHF]EventOnClickBargainItem");
	local wearInfo = {};
	wearInfo.itemID = BP_BargainSystemUI_CurrentClickItemID;
	wearInfo.colorID = 0;
	wearInfo.patternID = 0;
	wearInfo.itemType = BP_BargainSystemUI_CurrentClickItemSubType;
	local shopID = BP_BargainSystemUI_CurrentClickShopID;
	local orderID = BP_BargainSystemUI_CurrentClickOrderID;

	if wearInfo.itemType == PDD_System_UI.type_GeneralItem then
		local _, bHaveUpdate = Bargain_System_UI.OnClickBargainItem(wearInfo, shopID, orderID);
		LuaClassObj.HandleUIMessage(bp_pdd_system, "HideEquipment");
		log("[HHF]EventOnClickBargainItem, clicked type_GeneralItem, bHaveUpdate = " .. tostring(bHaveUpdate));

		if bHaveUpdate then
			PDD_System_UI.ShowGeneralItem(wearInfo);
		end
	elseif wearInfo.itemType == PDD_System_UI.type_Weapon or
		   wearInfo.itemType == PDD_System_UI.type_Vehicle then
		local _, bHaveUpdate = Bargain_System_UI.OnClickBargainItem(wearInfo, shopID, orderID);
		log("[HHF]EventOnClickBargainItem, clicked Weapon or Vehicle, bHaveUpdate = " .. tostring(bHaveUpdate));

		if bHaveUpdate then
			PDD_System_UI.ShowEquipment(wearInfo);
		end
	elseif wearInfo.itemType == PDD_System_UI.type_Expression then
		local _, bHaveUpdate = Bargain_System_UI.OnClickBargainItem(wearInfo, shopID, orderID);
		log("[HHF]EventOnClickBargainItem, click type_Expression, bHaveUpdate = " .. tostring(bHaveUpdate));

		if bHaveUpdate then
			PDD_System_UI.DoAction(wearInfo);
		end
	elseif wearInfo.itemType == PDD_System_UI.type_TreasureChest then
		local _, _, bargainItem = Bargain_System_UI.OnClickBargainItem(wearInfo, shopID, orderID);
		log("[HHF]EventOnClickBargainItem, clicked type_TreasureChest, bargainItem = " .. tostring(bargainItem));
		BP_ARRAY_BargainSystemUI_TreasureChestItems = Bargain_System_UI.GetDropItemsByTreasureChestID(wearInfo.itemID, bargainItem);

		LuaClassObj.HandleUIMessage(bp_pdd_system, "HideGeneralItem");
		LuaClassObj.HandleUIMessage(bp_pdd_system, "HideEquipment");
		
		local haveWore = {};
		for k, v in pairs(BP_ARRAY_BargainSystemUI_TreasureChestItems) do
			if Bargain_System_UI.IsAvatarType(v.sub_type) then
				if haveWore[v.sub_type] == nil then
					log("[HHF]EventOnClickBargainItem, PutOn avatar id = " .. tostring(v.item_id) .. " in default");
					local wearInfo2 = {};
					wearInfo2.itemID = v.item_id;
					wearInfo2.colorID = 0;
					wearInfo2.patternID = 0;
					wearInfo2.itemType = v.sub_type;
					haveWore[v.sub_type] = wearInfo2;

					local bPutOn, bNeedUpdate = Bargain_System_UI.OnClickItemInTreasureChest(wearInfo2, shopID, orderID, true);
					local _, bHaveUpdate = Bargain_System_UI.OnClickBargainItem(wearInfo2, shopID, orderID, true);
					--log("[HHF]EventOnClickBargainItem, clicked type_TreasureChest, bPutOn = " .. tostring(bPutOn) .. ", bHaveUpdate = " .. tostring(bHaveUpdate));

					if bNeedUpdate == true and bHaveUpdate == false then
						LuaClassObj.HandleUIMessage(bp_bargain, "UpdateData");
					end

					if bPutOn then
						PDD_System_UI.PutOnClothes(wearInfo2);
					else
						PDD_System_UI.PutOffClothes(wearInfo2);
					end
				end
			end
		end
	else
		local bPutOn, bHaveUpdate = Bargain_System_UI.OnClickBargainItem(wearInfo, shopID, orderID);
		log("[HHF]EventOnClickBargainItem, clicked avatar, bPutOn = " .. tostring(bPutOn) .. ", bHaveUpdate = " .. tostring(bHaveUpdate));

		if bPutOn then
			PDD_System_UI.PutOnClothes(wearInfo);
		else
			PDD_System_UI.PutOffClothes(wearInfo);
		end
	end
end

function EventOnClickBargainTreasureChestItem()
	local wearInfo = {};
	wearInfo.itemID = BP_BargainSystemUI_CurrentClickItemID;
	wearInfo.colorID = 0;
	wearInfo.patternID = 0;
	wearInfo.itemType = BP_BargainSystemUI_CurrentClickItemSubType;
	local shopID = BP_BargainSystemUI_CurrentClickShopID;
	local orderID = BP_BargainSystemUI_CurrentClickOrderID;

	if wearInfo.itemType == PDD_System_UI.type_GeneralItem or
	   wearInfo.itemType == PDD_System_UI.type_TreasureChest then
		local _, bNeedUpdate = Bargain_System_UI.OnClickItemInTreasureChest(wearInfo, shopID, orderID);
		log("[HHF]EventOnClickBargainTreasureChestItem, clicked type_GeneralItem, bNeedUpdate = " .. tostring(bNeedUpdate));

		if bNeedUpdate then
			LuaClassObj.HandleUIMessage(bp_bargain, "UpdateData");
			PDD_System_UI.ShowGeneralItem(wearInfo);
		end
	elseif wearInfo.itemType == PDD_System_UI.type_Weapon or
		   wearInfo.itemType == PDD_System_UI.type_Vehicle then
		local _, bNeedUpdate = Bargain_System_UI.OnClickItemInTreasureChest(wearInfo, shopID, orderID);
		log("[HHF]EventOnClickBargainTreasureChestItem, clicked Weapon or Vehicle, bNeedUpdate = " .. tostring(bNeedUpdate));

		if bNeedUpdate then
			LuaClassObj.HandleUIMessage(bp_bargain, "UpdateData");
			PDD_System_UI.ShowEquipment(wearInfo);
		end
	elseif wearInfo.itemType == PDD_System_UI.type_Expression then
		local _, bNeedUpdate = Bargain_System_UI.OnClickItemInTreasureChest(wearInfo, shopID, orderID);
		log("[HHF]EventOnClickBargainTreasureChestItem, click type_Expression, bNeedUpdate = " .. tostring(bNeedUpdate));

		if bNeedUpdate then
			LuaClassObj.HandleUIMessage(bp_bargain, "UpdateData");
			PDD_System_UI.DoAction(wearInfo);
		end
	else
		local bPutOn, bNeedUpdate = Bargain_System_UI.OnClickItemInTreasureChest(wearInfo, shopID, orderID);
		local _, bHaveUpdate = Bargain_System_UI.OnClickBargainItem(wearInfo, shopID, orderID, true);
		log("[HHF]EventOnClickBargainTreasureChestItem, clicked avatar, bPutOn = " .. tostring(bPutOn) .. ", bNeedUpdate = " .. tostring(bNeedUpdate));

		if bNeedUpdate == true and bHaveUpdate == false then
			LuaClassObj.HandleUIMessage(bp_bargain, "UpdateData");
		end

		if bPutOn then
			PDD_System_UI.PutOnClothes(wearInfo);
		else
			PDD_System_UI.PutOffClothes(wearInfo);
		end
	end
end

function Bargain_System_UI.GetDropItemsByTreasureChestID(treasureChestID, bargainItem)
	if Bargain_System_UI.treasureChestDrop[treasureChestID] ~= nil then
		for k, v in pairs(Bargain_System_UI.treasureChestDrop[treasureChestID]) do
			v.wore = false;
			v.selected = false;
		end
	else
		Bargain_System_UI.treasureChestDrop[treasureChestID] = {};
		local dropID = 0;
		local chestDropTable = Client.GetTable("ChestDrop");
		for _, chestDrop in pairs(chestDropTable) do
			if chestDrop.ChestID == treasureChestID then
				dropID = chestDrop.DropID;
				break;
			end
		end

		local dropMappingIDs = {};
		if dropID ~= 0 then
            local drop_util = require("client.common.drop_util")
            dropMappingIDs = drop_util.GetByDropID(dropID)
		end

		if #dropMappingIDs > 0 then
			local male = DataMgr.roleData.gender;
			local dropMappingTable = Client.GetTable("DropMapping");
			for _, v in pairs(dropMappingIDs) do
				for _, dropMapping in pairs(dropMappingTable) do
					if v.DropMappingID == dropMapping.DropMappingID then
						if male == 1 then
							local saleItem = Bargain_System_UI.CloneBargainItemForTreasureChest(bargainItem, dropMapping.DropItemMaleID);
							saleItem.item_num = v.DropItemNum;
							saleItem.sort = v.Weight;
							saleItem.expire_time = dropMapping.DropItemTime;
							table.insert(Bargain_System_UI.treasureChestDrop[treasureChestID], saleItem);
						else
							local saleItem = Bargain_System_UI.CloneBargainItemForTreasureChest(bargainItem, dropMapping.DropItemFemaleID);
							saleItem.item_num = v.DropItemNum;
							saleItem.sort = v.Weight;
							saleItem.expire_time = dropMapping.DropItemTime;
							table.insert(Bargain_System_UI.treasureChestDrop[treasureChestID], saleItem);
						end
						break;
					end
				end
			end

			if #Bargain_System_UI.treasureChestDrop[treasureChestID] > 1 then
				table.sort(Bargain_System_UI.treasureChestDrop[treasureChestID],
					function(a, b)
						return a.sort > b.sort;
					end);
			end
		end
	end

	--log_tree("[HHFTEST]Bargain_System_UI.GetDropItemsByTreasureChestID, treasureChestDrop[" .. tostring(treasureChestID) .. "] = ", Bargain_System_UI.treasureChestDrop[treasureChestID], "[HHFTEST]")
	return Bargain_System_UI.treasureChestDrop[treasureChestID];
end

function Bargain_System_UI.CloneBargainItemForTreasureChest(bargainItem, itemID)
	local saleItem = FuncUtil:CopyTable(bargainItem);
	local itemInfo = Client.GetTableData("Item", itemID);
	if itemInfo ~= nil then
		saleItem.item_id = itemID;
		saleItem.item_type = itemInfo.ItemType;
		saleItem.sub_type = Bargain_System_UI.GetBargainTypeByItemType(itemInfo);
		saleItem.name = itemInfo.ItemName;
		saleItem.desc = itemInfo.ItemDesc;
		saleItem.path = itemInfo.ItemSmallIcon;
		saleItem.big_path = itemInfo.ItemBigIcon;
		saleItem.quality = itemInfo.ItemQuality;
		saleItem.selected = false;
		saleItem.wore = false;
		saleItem.item_num = 1;
	end

	--log_tree("[HHFTEST]Bargain_System_UI.CloneBargainItemForTreasureChest, saleItem = ", saleItem, "[HHFTEST]");
	return saleItem;
end

function Bargain_System_UI.OnClickBargainItem(itemInfo, shopID, orderID, unselect)
	log("[HHF]Bargain_System_UI.OnClickBargainItem, itemInfo.itemID = " .. tostring(itemInfo.itemID) ..
		", shopID = " .. tostring(shopID) ..
		", orderID = " .. tostring(orderID) ..
		", unselect = " .. tostring(unselect));
	local bPutOn = false;
	local bNeedUpdate = true;
	local bargainItem = nil;
	local tempList = Bargain_System_UI.GetCurrentArrayList();

	for k, v in pairs(tempList) do
		if v.item_id == itemInfo.itemID and v.shop_id == shopID and v.cur_orderid == orderID then
			bargainItem = v;
			if Bargain_System_UI.IsAvatarType(v.sub_type) then
				v.wore = not v.wore;
				bPutOn = v.wore;
			end
			if v.selected == true and Bargain_System_UI.IsAvatarType(v.sub_type) == false then
				bNeedUpdate = false;
			end
			if unselect == true then

			else
				v.selected = true;
			end
		else
			if Bargain_System_UI.IsSameType(v.sub_type, itemInfo.itemType) then
				v.wore = false;
			end
			if unselect == true then

			else
				v.selected = false;
			end
		end
	end

	if bNeedUpdate == true then
		LuaClassObj.HandleUIMessage(bp_bargain, "UpdateData");
	end
	return bPutOn, bNeedUpdate, bargainItem;
end

function Bargain_System_UI.IsSameType(preType, curType)
	if Bargain_System_UI.IsAvatarType(preType) == false then
		return true;
	else
		return preType == curType;
	end
end

function Bargain_System_UI.IsAvatarType(type)
	if type == PDD_System_UI.type_GeneralItem or
	   type == PDD_System_UI.type_Expression or
	   type == PDD_System_UI.type_TreasureChest or
	   type == PDD_System_UI.type_Vehicle or
	   type == PDD_System_UI.type_Weapon then
		return false;
	else
		return true;
	end
end

function Bargain_System_UI.OnClickItemInTreasureChest(itemInfo, shopID, orderID, unselect)
	local bPutOn = false;
	local bNeedUpdate = true;

	for k, v in pairs(BP_ARRAY_BargainSystemUI_TreasureChestItems) do
		if v.item_id == itemInfo.itemID and v.shop_id == shopID then
			if Bargain_System_UI.IsAvatarType(v.sub_type) then
				v.wore = not v.wore;
				bPutOn = v.wore;
			end
			if v.selected == true and Bargain_System_UI.IsAvatarType(v.sub_type) == false then
				bNeedUpdate = false;
			end
			if unselect == true then

			else
				v.selected = true;
			end
			log("[HHF]Bargain_System_UI.OnClickItemInTreasureChest, itemInfo.id = " .. tostring(itemInfo.itemID) ..
				", wore = " .. tostring(v.wore) ..
				", selected = " .. tostring(v.selected));
		else
			if Bargain_System_UI.IsSameType(v.sub_type, itemInfo.itemType) then
				v.wore = false;
			end
			if unselect == true then

			else
				v.selected = false;
			end
		end
	end

	return bPutOn, bNeedUpdate;
end

function EventOnClickBargainSelf()	
	local tempList = Bargain_System_UI.GetCurrentArrayList();
	if BP_BargainSystemUI_Switch == Bargain_System_UI.tabAllSaleItems then
		log("[HHF]EventOnClickBargainSelf, BP_BargainSystemUI_CurrentClickShopID = " .. tostring(BP_BargainSystemUI_CurrentClickShopID));
		for k, v in pairs(tempList) do
			if v.shop_id == BP_BargainSystemUI_CurrentClickShopID then
				--log_tree("[HHFTEST]EventOnClickBargainSelf, current iteminfo = ", v, "[HHFTEST]");
				break;
			end
		end
	elseif BP_BargainSystemUI_Switch == Bargain_System_UI.tabMySaleItems then
		log("[HHF]EventOnClickBargainSelf, BP_BargainSystemUI_CurrentClickOrderID = " .. tostring(BP_BargainSystemUI_CurrentClickOrderID));
		for k, v in pairs(tempList) do
			if v.cur_orderid == BP_BargainSystemUI_CurrentClickOrderID then
				--log_tree("[HHFTEST]EventOnClickBargainSelf, current iteminfo = ", v, "[HHFTEST]");
				break;
			end
		end
	end
end

function EventOnClickFirstBargain()
	log("[HHF]EventOnClickFirstBargain, BP_BargainSystemUI_CurrentClickShopID = " .. tostring(BP_BargainSystemUI_CurrentClickShopID));
	local existOrder = true;
	for k, v in pairs(BP_ARRAY_BargainSystemUI_AllSaleItems) do
		if BP_BargainSystemUI_CurrentClickShopID == v.shop_id then
			if v.cur_orderid == 0 then
				existOrder = false;
			end
			break;
		end
	end

	if existOrder then		
		local title = FuncUtil.GetLocalizeResStr(101001);
		local okLabel = FuncUtil.GetLocalizeResStr(5078);
		local cancelLabel = FuncUtil.GetLocalizeResStr(110035);
		local notice = FuncUtil.GetLocalizeResStr(6236);

		CommonMessageBoxUI:ShowPanel(2, title, notice,
			function()
				EventOnClickBargainOrderDetail();
			end,
			nil,
			okLabel,
			cancelLabel);
	else
		Bargain_Logic.pdd_bargain_create_order_req(BP_BargainSystemUI_CurrentClickShopID);
	end
end

function Bargain_System_UI.OnCreateOrder(orderid, shopid, order_brief, current_times, node_index)
	log("[HHF]Bargain_System_UI.OnCreateOrder");
	for k, v in pairs(BP_ARRAY_BargainSystemUI_AllSaleItems) do
		if v.shop_id == shopid then
			v.create_time = order_brief.createtime;
			v.create_date = os.date('!%Y-%m-%d', v.create_time);
			v.finish = order_brief.finish;
			v.help_num = order_brief.helpnum;
			v.last_time = order_brief.lasttime;
			v.cur_orderid = order_brief.id;
			v.uid = tostring(order_brief.uid);
			v.current_times = current_times;
			v.cur_price = order_brief.cur_price * Bargain_System_UI.priceRatio;
			v.left_time = v.create_time + v.valid_time - Bargain_System_UI.serverTime;
            v.buy_price = order_brief.buy_price * Bargain_System_UI.priceRatio;

			local saleItem = FuncUtil:CopyTable(v);
			saleItem.tab = Bargain_System_UI.tabMySaleItems;
			table.insert(BP_ARRAY_BargainSystemUI_MySaleItems, saleItem);

			--LuaClassObj.HandleUIMessage(bp_bargain, "SetData");

			local detailItem = FuncUtil:CopyTable(saleItem);
			detailItem.BP_STRUCT_BargainDetail_ItemGameInfo = {};
			detailItem.BP_STRUCT_BargainDetail_ItemGameInfo.gl = detailItem.BP_STRUCT_Bargain_ItemGameInfo.gl;
			detailItem.BP_STRUCT_BargainDetail_ItemGameInfo.jk = detailItem.BP_STRUCT_Bargain_ItemGameInfo.jk;
			detailItem.BP_STRUCT_BargainDetail_ItemGameInfo.lite = detailItem.BP_STRUCT_Bargain_ItemGameInfo.lite;
			detailItem.BP_STRUCT_Bargain_ItemGameInfo = nil;
			detailItem.node_id = node_index;
			local detailCut = {};
			local cutFriendList = {};
			Bargain_Detail_UI.SetFromChannelInfo(Bargain_Detail_UI.myorder_channel, detailItem.item_id);
			Bargain_Detail_UI.Show(detailItem, detailCut, cutFriendList);
			Bargain_Logic.pdd_bargain_do_help_req(orderid, DataMgr.roleData.uid, false, false);
			break;
		end
	end
end

function Bargain_System_UI.UpdateOrderDataAfterBargain(own_uid, orderid, ext_data)
	for k, v in pairs(BP_ARRAY_BargainSystemUI_AllSaleItems) do
		if v.cur_orderid == orderid then
			v.cur_price = ext_data.cur_price * Bargain_System_UI.priceRatio;
			v.buy_price = ext_data.buy_price * Bargain_System_UI.priceRatio;
			v.is_helpnum_max = (ext_data.helpnum >= BP_BargainDetail_MaxHelpTime);
			break;
		end
	end

	for k, v in pairs(BP_ARRAY_BargainSystemUI_MySaleItems) do
		if v.cur_orderid == orderid then
			v.cur_price = ext_data.cur_price * Bargain_System_UI.priceRatio;
			v.buy_price = ext_data.buy_price * Bargain_System_UI.priceRatio;
			v.is_helpnum_max = (ext_data.helpnum >= BP_BargainDetail_MaxHelpTime);
			break;
		end
	end


	local helperUID = tostring(ext_data.helper)
	if helperUID ~= DataMgr.roleData.uid then
		log("[HHF]Bargain_System_UI.UpdateOrderDataAfterBargain, others help me.");
		local have = false;
		for k, v in pairs(Bargain_System_UI.friendsHelpedMe) do
			if v.uid == helperUID then
				v.cut = v.cut + ext_data.cut;
				have = true;
				break;
			end
		end

		if have == false then
			local temp = {};
			temp.uid = helperUID;
			temp.name = ext_data.name;
			temp.cut = ext_data.cut;
			table.insert(Bargain_System_UI.friendsHelpedMe, temp);
		end
	else
		log("[HHF]Bargain_System_UI.UpdateOrderDataAfterBargain, I help myself or others.");
	end
end

function Bargain_System_UI.UpdateOrderAfterBuy(orderid)
	log("[HHF]Bargain_System_UI.UpdateOrderAfterBuy, orderid = " .. tostring(orderid));
	for k, v in pairs(BP_ARRAY_BargainSystemUI_AllSaleItems) do
		if v.cur_orderid == orderid then
			v.cur_orderid = 0;
			break;
		end
	end

	for k, v in pairs(BP_ARRAY_BargainSystemUI_MySaleItems) do
		if v.cur_orderid == orderid then
			v.finish = 2;
			break;
		end
	end
end

function EventOnClickBargainOrderDetail()
	log("[HHF]EventOnClickOrderDetail, BP_BargainSystemUI_CurrentClickShopID = " .. tostring(BP_BargainSystemUI_CurrentClickShopID));
	if BP_BargainSystemUI_Switch == 2 then
		local stateInfo = nil;
		for k,v in pairs(BP_ARRAY_BargainSystemUI_StateInfo) do
			if v.id == BP_BargainSystemUI_CurrentClickOrderID and v.shopid == BP_BargainSystemUI_CurrentClickShopID then
				stateInfo = v;
				break;
			end
		end
		
		Bargain_Detail_UI.ShowDetailAfterClickChat(0, stateInfo.uid, stateInfo.name, stateInfo.id, stateInfo.itemid);
	else
		local saleItem = nil;
		local tempList = Bargain_System_UI.GetCurrentArrayList();
		for k, v in pairs(tempList) do
			if v.shop_id == BP_BargainSystemUI_CurrentClickShopID then
				saleItem = v;
				break;
			end

		end
		Bargain_Detail_UI.ShowDetailAfterClickChat(Bargain_Detail_UI.myorder_channel, saleItem.uid, DataMgr.roleData.nickName, saleItem.cur_orderid, saleItem.item_id);
	end

end

function EventOnClickBargainTabSort()
	log("[HHF]EventOnClickBargainTabSort, BP_BargainSystemUI_Switch = " .. tostring(BP_BargainSystemUI_Switch));
	Bargain_System_UI.SortItemList(BP_BargainSystemUI_Switch);
	if BP_BargainSystemUI_Switch == 2 then
		Bargain_Logic.pdd_bargain_get_fri_share_req();
		BP_PDDSystem_InviteRedDot = false;
	elseif  BP_BargainSystemUI_Switch == Bargain_System_UI.tabMySaleItems then
		BP_ARRAY_PDDSystem_ItemListBargainedToFree = {};
	end
end

function EventOnClickBargainOrderRecover()
	log("[HHF]EventOnClickOrderRecover, BP_BargainSystemUI_CurrentClickShopID = " .. tostring(BP_BargainSystemUI_CurrentClickShopID));
	if BP_BargainSystemUI_Switch == 2 then
		local stateInfo = nil;
		for k,v in pairs(BP_ARRAY_BargainSystemUI_StateInfo) do
			if v.id == BP_BargainSystemUI_CurrentClickOrderID and v.shopid == BP_BargainSystemUI_CurrentClickShopID then
				stateInfo = v;
				break;
			end
		end
		local is_friend, is_league = Bargain_Detail_UI.GetRelationshipByUID(stateInfo.uid);
		Bargain_Logic.pdd_bargain_do_help_req(stateInfo.id, stateInfo.uid, is_friend, is_league);
		
	end
end

function EventGetInviteRedDot()
	BP_BargainSystemUI_InviteRedDot = BP_PDDSystem_InviteRedDot;
end

--整理状态信息List
function Bargain_System_UI.SortBargainStateList()
	BP_ARRAY_BargainSystemUI_StateInfo = {};
	
	if BargainSystemUI_StateInfo_Map.BP_STRUCT_BargainSystemUI_StateInfo ~= nil then
		BargainSystemUI_StateInfo_Map.BP_STRUCT_BargainSystemUI_StateInfo = nil;
	end

	for k,v in pairs(BargainSystemUI_StateInfo_Map) do
		if v.show_type == nil then
			BargainSystemUI_StateInfo_Map[k] = nil;
		else
			table.insert(BP_ARRAY_BargainSystemUI_StateInfo,v); 
		end
	end


	--优先级1.未帮助 2.时间早
	table.sort(BP_ARRAY_BargainSystemUI_StateInfo,function (a,b)
		if a.show_type == 100 and b.show_type ~= 100 then
			return true;
		elseif b.show_type == 100 and a.show_type ~= 100 then
			return false;
		else
			return a.createtime > b.createtime;
		end
	end)
end