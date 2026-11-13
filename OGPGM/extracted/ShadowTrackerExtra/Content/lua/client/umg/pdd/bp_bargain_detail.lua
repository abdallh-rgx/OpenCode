Bargain_Detail_UI = Bargain_Detail_UI or {
	bShowing = false,
	bNodeConfigInited = false;

	InviteBySMS = "sms",
	InviteByMessenger = "messenger",
	InviteByWhatsapp = "whatsapp",
	InviteBySystem = "system",
	InviteByLine = "line",

	fromChannel = 0,

	myorder_channel = 0,
	friend_channel = 1,
	juntuan_channel = 2,
	sns_application = 3,

	directBargain = false,
	bargainURL = "",

	cutFriendsList = {},
	totalNodeConfig = {},
}

BP_BargainDetail_Title = "";

BP_BargainDetail_IsMyOrder = false;
BP_BargainDetail_MyUID = "";

BP_BargainDetail_CurrentClickType = 0;
BP_BargainDetail_CurrentClickUID = "";
BP_BargainDetail_CurrentClickName = "";

BP_BargainDetail_CurrentCut = 0;
BP_BargainDetail_Congratulations = "";

BP_BargainDetail_FriendTab = 0;

BP_BargainDetail_HaveBargain = false;
BP_BargainDetail_HaveBargainCut = 0;
BP_BargainDetail_HaveBargainDesc = "";
BP_BargainDetail_OwnerName = "";
BP_BargainDetail_NotHaveBargainTitle = "";
BP_BargainDetail_NotHaveBargainDesc = "";

BP_BargainDetail_CheckBox = false;
BP_BargainDetail_IsFromSNS = false;

BP_BargainDetail_MaxHelpTime = 0;
BP_BargainDetail_SaveFileName = "";
BP_BargainDetail_TestName = "";

BP_BargainDetail_CertainDiscount = 0;
BP_BargainDetail_CurrentOrderid = 0;

BP_STRUCT_BargainNodeConfig ={
	ID = 0;
	bargainNeedNum = 0;
	bargainTotalNum = 0;
	discount = 0;
	messageType = 0;
}
BP_ARRAY_BargainNodeConfig = {
	BP_STRUCT_BargainNodeConfig = _G.BP_STRUCT_BargainNodeConfig;
}


BP_STRUCT_BargainDetail_ItemGameInfo = {
	gl = false,
	jk = false,
	lite = false,
}

--砍价成功收益弹框
BP_STRUCT_BargainDetail_IncomeInfo = {
	canGetIncome = false;
	goldNum = 0;
	corpsGoldNum = 0;
}

BP_STRUCT_BargainDetail_ItemInfo = {
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
	node_id = 0,
	
	BP_STRUCT_BargainDetail_ItemGameInfo = _G.BP_STRUCT_BargainDetail_ItemGameInfo,
}

BP_STRUCT_BargainDetail_CutInfo = {
    id = 0,
	uid = "",
	cut = 0,
	name = "",
	time = 0,
    cur_price = 0,
    
}

BP_ARRAY_BargainDetail_CutList = {
	BP_STRUCT_BargainDetail_CutInfo = _G.BP_STRUCT_BargainDetail_CutInfo,
}

BP_STRUCT_BargainDetail_FriendInfo = {
	item_type = 0;
	uid = "",
	openid = 0,
	name = "",
	headportrait = "",
	frame_level = 0,
	has_invited = false,
	online = 0,
	intimacy = 0,
}

BP_ARRAY_BargainDetail_FriendsList = {
	BP_STRUCT_BargainDetail_FriendInfo = _G.BP_STRUCT_BargainDetail_FriendInfo,
}



function bp_bargain_detail_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_bargain_detail,
		{
			{Path="/Game/UMG/UI_Logic/PDDSystem/Bargain_Detail_Logic_BP.Bargain_Detail_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_PDD_SYSTEM+5},
			{Path="/Game/UMG/UI_Logic/PDDSystem/Bargain_First_Logic_BP.Bargain_First_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_PDD_SYSTEM+6},
			{Path="/Game/UMG/UI_Logic/PDDSystem/Bargain_Buy_Logic_BP.Bargain_Buy_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_PDD_SYSTEM+7},
			{Path="/Game/UMG/UI_Logic/PDDSystem/Bargain_History_Logic_BP.Bargain_History_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_PDD_SYSTEM+8}
		},
		{"Lobby"},
		false,
		bp_bargain_detail_OnModeSwitched ~= nil,
		true
	);
end

function Bargain_Detail_UI.SetFromChannelInfo(channel, item_id)
	log("[HHF]Bargain_Detail_UI.SetFromChannelInfo, channel = " .. tostring(channel));
	Bargain_Detail_UI.fromChannel = channel;

	if Bargain_Detail_UI.IsFromCanDirectBargainChannel() == true then
		Bargain_Detail_UI.directBargain = PDD_System_UI.IsDirectBargainItem(item_id);
	else
		Bargain_Detail_UI.directBargain = false;
	end
end

function Bargain_Detail_UI.Show(saleItem, cutList, friendList)
	--http://tapd.oa.com/iGameInternational/bugtrace/bugs/view/1020360302067822319
	--【【ALL】拼多多砍价：通过外链进入游戏弹出帮忙砍价弹窗且有回流弹窗，帮忙砍价后点击“我要砍价”进入商品界面，出现回流弹窗】
	if Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.sns_application then
		ComeBackUI.HideUI();
		IMSDKNoticeUI.OnlyCloseUI();
	end

	log("[HHF]Bargain_Detail_UI.Show");
	log("[HHF]Bargain_Detail_UI.Show BP_BargainDetail_OwnerName = " .. BP_BargainDetail_OwnerName);
	log_tree("[HHFTEST]Bargain_Detail_UI.Show, saleItem = ", saleItem, "[HHFTEST]");
	log_tree("[HHFTEST]Bargain_Detail_UI.Show, cutList = ", cutList, "[HHFTEST]");
	log_tree("[HHFTEST]Bargain_Detail_UI.Show, friendList = ", friendList, "[HHFTEST]");

	LuaClassObj.HandleDynamicCreation(bp_bargain_detail);

	BP_STRUCT_BargainDetail_ItemInfo = saleItem;
	BP_STRUCT_BargainDetail_ItemInfo.open_state = 0;
	if Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.sns_application then
		BP_BargainDetail_IsFromSNS = true;
	else
		BP_BargainDetail_IsFromSNS = false;
	end

	if BP_STRUCT_BargainDetail_ItemInfo.uid == DataMgr.roleData.uid then
		BP_BargainDetail_IsMyOrder = true;
		BP_BargainDetail_Title = FuncUtil.GetLocalizeResStr(6226);
	else
		BP_BargainDetail_IsMyOrder = false;
		BP_BargainDetail_Title = string.gsub(FuncUtil.GetLocalizeResStr(6213), "{0}", BP_BargainDetail_OwnerName);
	end
    
	log("[HHF]Bargain_Detail_UI.Show, BP_BargainDetail_IsMyOrder = " .. tostring(BP_BargainDetail_IsMyOrder));
	if BP_STRUCT_BargainDetail_ItemInfo.finish >= 2 then
		if BP_BargainDetail_IsMyOrder == true then
			BP_BargainDetail_HaveBargainDesc = FuncUtil.GetLocalizeResStr(6221);
		else
            local show_type = 0;
            local name = "";
            local msg = "";
            for k,v in pairs(BP_ARRAY_BargainSystemUI_StateInfo) do
                if v.uid == DataMgr.roleData.uid then
                    show_type = v.show_type;
                    name = v.name;
                    break;
                end
            end
            if show_type == Bargain_Logic.pdd_order_show_type_cut_limit then
                msg = FuncUtil.GetLocalizeResStr(6207);
            elseif show_type == Bargain_Logic.pdd_order_show_type_not_fri then
                msg =  FuncUtil.LocalizeResFormat(6523, name);
            else
                msg = FuncUtil.GetLocalizeResStr(6219);
            end
            
			BP_BargainDetail_HaveBargainDesc = msg;
		end
	else
		if BP_STRUCT_BargainDetail_ItemInfo.open_state == Bargain_System_UI.haveEnded or
				BP_STRUCT_BargainDetail_ItemInfo.left_time == 0 then
			if BP_BargainDetail_IsMyOrder == true then
				BP_BargainDetail_NotHaveBargainDesc = FuncUtil.GetLocalizeResStr(6220);
			else
				BP_BargainDetail_NotHaveBargainDesc = FuncUtil.GetLocalizeResStr(6218);
			end
		else
			BP_BargainDetail_HaveBargain = false;
			BP_BargainDetail_HaveBargainCut = 0;
			BP_BargainDetail_HaveBargainDesc = "";
			for k, v in pairs(cutList) do
				if v.uid == DataMgr.roleData.uid then
					BP_BargainDetail_HaveBargain = true;
					BP_BargainDetail_HaveBargainCut = v.cut;
					local tips = FuncUtil.GetLocalizeResStr(6216);
					tips = string.gsub(tips, "{0}", BP_BargainDetail_OwnerName);
					BP_BargainDetail_HaveBargainDesc = tips;
					break;
				end
			end

			if BP_BargainDetail_IsMyOrder == true then
				Bargain_Detail_UI.InitFriendsList(friendList);
			else
				if BP_BargainDetail_HaveBargain == false then
					local tips = FuncUtil.GetLocalizeResStr(6214);
					tips = string.gsub(tips, "{0}", BP_BargainDetail_OwnerName);
					BP_BargainDetail_NotHaveBargainTitle = tips;
					tips = FuncUtil.GetLocalizeResStr(6215);
					tips = string.gsub(tips, "{0}", BP_BargainDetail_OwnerName);
					BP_BargainDetail_NotHaveBargainDesc = tips;
				end
			end
		end
	end
	--初始化节点信息
	if Bargain_Detail_UI.bNodeConfigInited == false then
		Bargain_Detail_UI.InitBargainNodeConfig()
		Bargain_Detail_UI.bNodeConfigInited = true;
	end
    log("Bargain_Detail_UI.Show, node_id = " .. saleItem.node_id);
	--根据下发id选择对应节点信息
	if Bargain_Detail_UI.totalNodeConfig[saleItem.node_id] ~= nil then
		BP_ARRAY_BargainNodeConfig = Bargain_Detail_UI.totalNodeConfig[saleItem.node_id];
	end
    log_tree("Bargain_Detail_UI.Show, BP_ARRAY_BargainNodeConfig = " ,BP_ARRAY_BargainNodeConfig);
	
	BP_BargainDetail_CheckBox = PDD_System_UI.GetBargainDetailCheckState();

	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIShow");
	Bargain_Detail_UI.bShowing = true;
	Bargain_Detail_UI.SetCutListInfo(cutList);
	Bargain_Detail_UI.SortCutListInfo();

	if Bargain_Detail_UI.IsFromCanDirectBargainChannel() == true then
		PDD_System_UI.UpdateDirectBargainItemList(BP_STRUCT_BargainDetail_ItemInfo.item_id);
	end
end

function Bargain_Detail_UI.BytesOfCharacter(byte)
    local separate = {0, 0xc0, 0xe0, 0xf0};
    for i = #separate, 1, -1 do
        if byte >= separate[i] then 
        	return i;
        end
    end

    return 1;
end

function Bargain_Detail_UI.GetCharactersLength(utf8Str, chineseCharBytes)
    chineseCharBytes = chineseCharBytes or 1;
    local length = 0;
    local i = 1;
    while i <= #utf8Str do
        local currCharLen = Bargain_Detail_UI.BytesOfCharacter(string.byte(utf8Str, i));
        length = length + (currCharLen > chineseCharBytes and chineseCharBytes or currCharLen);
        i = i + currCharLen;
    end

    return length;
end

function Bargain_Detail_UI.SubString(utf8Str, start, End, chineseCharBytes)
	chineseCharBytes = chineseCharBytes or 1;
    local result = "";
	local index = 0;
    local i = 1;
    while i <= #utf8Str do
        local currCharLen = Bargain_Detail_UI.BytesOfCharacter(string.byte(utf8Str, i));
        index = index + (currCharLen > chineseCharBytes and chineseCharBytes or currCharLen);
        if start <= index and index <= End then
        	result = result .. string.sub(utf8Str, i, i + currCharLen - 1);
        end
        i = i + currCharLen;
	end

	return result;
end

function Bargain_Detail_UI.ProcessName(name)
	local result = "";
	local len = Bargain_Detail_UI.GetCharactersLength(name);
	if len > 2 then
		result = Bargain_Detail_UI.SubString(name, 1, 1) .. string.rep("*", len-2) .. Bargain_Detail_UI.SubString(name, len, len);
	elseif len == 2 then
		result = Bargain_Detail_UI.SubString(name, 1, 1) .. "*";
	else
		result = "*";
	end

	return result;
end

function Bargain_Detail_UI.SetCutListInfo(cutList)
	log("[HHF]Bargain_Detail_UI.SetCutListInfo");
	BP_ARRAY_BargainDetail_CutList = cutList;

	if BP_BargainDetail_IsMyOrder == false then
		for k, v in pairs(BP_ARRAY_BargainDetail_CutList) do
			if v.uid ~= DataMgr.roleData.uid then
				v.name = Bargain_Detail_UI.ProcessName(v.name);
			end
		end
	end
end

function Bargain_Detail_UI.SortCutListInfo()
	log("[HHF]Bargain_Detail_UI.SortCutListInfo");
	if FuncUtil:CountTable(BP_ARRAY_BargainDetail_CutList) > 1 then		
		table.sort(BP_ARRAY_BargainDetail_CutList, 
			function(a, b)
				return a.time > b.time;
			end);
	end
end

function Bargain_Detail_UI.InitFriendsList(cutFriendsList)
	log_tree("[HHF]Bargain_Detail_UI.InitFriendsList, cutFriendsList = " ,cutFriendsList);
	if cutFriendsList == nil then
		if Bargain_Detail_UI.bShowing == false or BP_BargainDetail_IsMyOrder == false then
			log("[HHF]Bargain_Detail_UI.InitFriendsList, not showing and return.");
			return;
		end

		cutFriendsList = Bargain_Detail_UI.cutFriendsList;
	else
		Bargain_Detail_UI.cutFriendsList = cutFriendsList;
	end

	BP_ARRAY_BargainDetail_FriendsList = {};
	if DataMgr.corpsInfo.id ~= 0 then
		local friendItem = {};
		friendItem.item_type = 0;
		friendItem.uid = tostring(DataMgr.corpsInfo.id);
		friendItem.openid = 0;
		friendItem.name = FuncUtil.GetLocalizeResStr(6224);
		friendItem.headportrait = tostring(DataMgr.corpsInfo.icon);
		friendItem.frame_level = 0;
		friendItem.has_invited = false;
		friendItem.online = 0;
		friendItem.intimacy = 0;
		table.insert(BP_ARRAY_BargainDetail_FriendsList, friendItem);
	end

	local friendList = FriendSystem.SortFriendList();
	for k, v in pairs(friendList) do
		local region = Bargain_System_UI.GetReigonByUID(v.gid);
		if BP_STRUCT_BargainDetail_ItemInfo.BP_STRUCT_BargainDetail_ItemGameInfo[region] == true then
			local friendItem = {};
			friendItem.item_type = 1;
			friendItem.uid = tostring(v.gid);
			friendItem.openid = 0;
			friendItem.name = v.nickName;
			friendItem.headportrait = v.picUrl;
			friendItem.frame_level = v.cur_avatar_box_id;
			friendItem.has_invited = false;
			friendItem.online = v.online;
			friendItem.intimacy = v.intimacy;
			table.insert(BP_ARRAY_BargainDetail_FriendsList, friendItem);
		else
			log("[HHF]Bargain_Detail_UI.InitFriendsList, Hide friend name = " .. tostring(v.nickName));
		end
	end

	if cutFriendsList ~= nil then
		for k, v in pairs(BP_ARRAY_BargainDetail_FriendsList) do
			for k1, v1 in pairs(cutFriendsList) do
				if v.uid == tostring(k1) then
					v.has_invited = true;
					break;
				end
			end
		end
        --加层保护使排序不影响到其他功能
        if not pcall(Bargain_Detail_UI.SortFriendsList) then
            log_error("Bargain_Detail_UI.InitFriendsList SortFriendsList error!");
        end
	end

	if #BP_ARRAY_BargainDetail_FriendsList > 0 then
		BP_BargainDetail_FriendTab = 0;
	else
		BP_BargainDetail_NotHaveBargainDesc = FuncUtil.GetLocalizeResStr(6235);
		BP_BargainDetail_FriendTab = 1;
	end
end

function Bargain_Detail_UI.SortFriendsList()
	log_tree("[HHF]Bargain_Detail_UI.SortFriendsList" , BP_ARRAY_BargainDetail_FriendsList);
	if #BP_ARRAY_BargainDetail_FriendsList > 1 then
		table.sort(BP_ARRAY_BargainDetail_FriendsList,
			function(a, b)
                
                local point_a = 0;
                local point_b = 0;
                if a.has_invited == false then
                    point_a = point_a + 1000;
                end
                if b.has_invited == false then
                    point_b = point_b + 1000;
                end

                if a.uid == tostring(DataMgr.corpsInfo.id) then
                    point_a = point_a + 100;
                end
                if b.uid == tostring(DataMgr.corpsInfo.id) then
                    point_b = point_b + 100;
                end

                if a.online ~= 0 then
                    point_a = point_a + 10;
                end
                if b.online ~= 0 then
                    point_b = point_b + 10;
                end

                if a.intimacy > b.intimacy then
                    point_a = point_a + 1;
                elseif a.intimacy < b.intimacy then
                    point_b = point_b + 1;
                end
                return point_a > point_b;
                --[[
			--优先级1-未邀请优先
			if a.has_invited == b.has_invited then
				--优先级2-军团顺位1
                if a.uid == tostring(DataMgr.corpsInfo.id) then
                    return true;
                elseif b.uid == tostring(DataMgr.corpsInfo.id) then
                    return false;
                else
                    --优先级3-在线顺位2，不在线顺位3
                    if a.online == b.online then
                        --优先级4-亲密度高优先
                        return a.intimacy > b.intimacy;
                    else
                        return a.online == 1;
                    end
                end
			else
				return not a.has_invited;
			end
			]]--
		end);
	end
end


function Bargain_Detail_UI.GetDescForChat(channel, item_id, ori_price, receiver_name)
	log("[HHF]Bargain_Detail_UI.GetDescForChat, channel = " .. tostring(channel) .. 
		", item_id = " .. tostring(item_id) ..
		", ori_price = " .. tostring(ori_price) ..
		", receiver_name = " .. tostring(receiver_name));

	if channel == nil or item_id == nil or ori_price == nil or receiver_name == nil then
		log("[HHF]Bargain_Detail_UI.GetDescForChat, parameter is nil and return.");
		return "";
	end

	local tips = "";
	local itemName = "";
	local itemInfo = Client.GetTableData("Item", item_id);
	if itemInfo ~= nil then
		itemName = itemInfo.ItemName;
	end

	if channel == Bargain_Detail_UI.friend_channel then
		tips = FuncUtil.GetLocalizeResStr(6211);
		tips = string.gsub(tips, "{0}", receiver_name);
		tips = string.gsub(tips, "{1}", tostring(ori_price / Bargain_System_UI.priceRatio));
		tips = string.gsub(tips, "{2}", tostring(itemName));
	else
		tips = FuncUtil.GetLocalizeResStr(6212);
		tips = string.gsub(tips, "{1}", tostring(ori_price / Bargain_System_UI.priceRatio));
		tips = string.gsub(tips, "{2}", tostring(itemName));
	end

	log("[HHF]Bargain_Detail_UI.GetDescForChat, desc = " .. tostring(tips));
	return tips;
end

function Bargain_Detail_UI.ShowFirstDialog(cut,own_uid)
	log("[HHF]Bargain_Detail_UI.ShowFirstDialog, cut = " .. tostring(cut));
	BP_BargainDetail_CurrentCut = cut;
	LuaClassObj.HandleDynamicCreation(bp_bargain_detail);
    
    local name = "";
    for k,v in pairs(BargainSystemUI_StateInfo_Map) do
        if v.uid == own_uid then
            name = v.name;
            break;
        end
    end
	
	if tostring(own_uid) == DataMgr.roleData.uid then
		BP_BargainDetail_Congratulations = FuncUtil.GetLocalizeResStr(6222);
		LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIShowFirstMe");
	else
		local tips = FuncUtil.GetLocalizeResStr(6216);
		BP_BargainDetail_Congratulations = string.gsub(tips, "{0}", name);
		LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIShowFirstFriend");
	end
	
end

function Bargain_Detail_UI.ShowBuyDialog()
	log("[HHF]Bargain_Detail_UI.ShowBuyDialog");
	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIShowBuy");
end

function Bargain_Detail_UI.ShowHistoryDialog()
	log("[HHF]Bargain_Detail_UI.ShowHistoryDialog");
	BP_BargainDetail_MyUID = DataMgr.roleData.uid;
	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIShowHistory");
end

function Bargain_Detail_UI.UpdateOrderDataAfterBargain(own_uid, orderid, ext_data)
	if Bargain_Detail_UI.bShowing == true then
		if tostring(own_uid) == BP_STRUCT_BargainDetail_ItemInfo.uid and orderid == BP_STRUCT_BargainDetail_ItemInfo.cur_orderid then
			log("[HHF]Bargain_Detail_UI.UpdateOrderDataAfterBargain, update order info.");
			BP_STRUCT_BargainDetail_ItemInfo.cur_price = ext_data.cur_price * Bargain_System_UI.priceRatio;
			BP_BargainDetail_HaveBargain = true;
			BP_BargainDetail_HaveBargainCut = ext_data.cut * Bargain_System_UI.priceRatio;
			local tips = FuncUtil.GetLocalizeResStr(6216);
			tips = string.gsub(tips, "{0}", BP_BargainDetail_OwnerName);
			BP_BargainDetail_HaveBargainDesc = tips;

			local cutInfo = {};
			cutInfo.uid = tostring(ext_data.helper);
			cutInfo.cut = ext_data.cut * Bargain_System_UI.priceRatio;
			cutInfo.time = ext_data.time;
			if BP_BargainDetail_IsMyOrder == true then
				cutInfo.name = ext_data.name;
			else
				if cutInfo.uid ~= DataMgr.roleData.uid then
					cutInfo.name = Bargain_Detail_UI.ProcessName(ext_data.name);
				else
					cutInfo.name = ext_data.name;
				end
			end
			table.insert(BP_ARRAY_BargainDetail_CutList, cutInfo);

			if BP_BargainDetail_IsMyOrder == true then
				LuaClassObj.HandleUIMessage(bp_bargain_detail, "UpdateBuyPrice");
			end

			Bargain_Detail_UI.SortCutListInfo();
			LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIShow");
		else
			log("[HHF]Bargain_Detail_UI.UpdateOrderDataAfterBargain, why not the same order?");
			log("[HHF]Bargain_Detail_UI.UpdateOrderDataAfterBargain, showed orderid = " .. tostring(BP_STRUCT_BargainDetail_ItemInfo.cur_orderid) .. " which belonged to ownerid = " .. tostring(BP_STRUCT_BargainDetail_ItemInfo.uid));
		end	
	else
		log("[HHF]Bargain_Detail_UI.UpdateOrderDataAfterBargain, Bargain_Detail_UI.bShowing = false, don't need update");
	end
end

function Bargain_Detail_UI.OnHelpBargainSuccess(own_uid, orderid, ext_data)
	Bargain_Detail_UI.UpdateOrderDataAfterBargain(own_uid, orderid, ext_data);
	
	if Bargain_Detail_UI.directBargain == true then
		log("[HHF]Bargain_Detail_UI.OnHelpBargainSuccess, Bargain_Detail_UI.directBargain = true, don't need show.");
	else
		local cut = ext_data.cut * Bargain_System_UI.priceRatio;
		Bargain_Detail_UI.ShowFirstDialog(cut,own_uid);
	end
end

function Bargain_Detail_UI.ShowDetailAfterClickChat(channel, owner_id, owner_name, cur_orderid, item_id)	
	log("[HHF]Bargain_Detail_UI.ShowDetailAfterClickChat, channel = " .. tostring(channel) ..
		", owner_id = " .. tostring(owner_id) .. 
		", owner_name = " .. tostring(owner_name) ..
		", cur_orderid = " .. tostring(cur_orderid) ..
		", item_id = " .. tostring(item_id));
	BP_BargainDetail_OwnerName = owner_name;

	if owner_id == DataMgr.roleData.uid then
		Bargain_Detail_UI.SetFromChannelInfo(Bargain_Detail_UI.myorder_channel, item_id);
		Bargain_Logic.pdd_bargain_order_req(cur_orderid, owner_id);
	else
		Bargain_Detail_UI.SetFromChannelInfo(channel, item_id);
		if PDD_System_UI.HaveBargainedByOrderID(cur_orderid) == true then
			Bargain_Logic.pdd_bargain_order_req(cur_orderid, owner_id);
			if Bargain_Detail_UI.IsFromCanDirectBargainChannel() == true then
				LobbyChatLogic.UpdateBargainOrderState();
			end
		else
			if Bargain_Detail_UI.directBargain == true then
				local is_friend, is_league = Bargain_Detail_UI.GetRelationshipByUID(BP_STRUCT_BargainDetail_ItemInfo.uid);
				Bargain_Logic.pdd_bargain_do_help_req(cur_orderid, owner_id, is_friend, is_league);
			else
				Bargain_Logic.pdd_bargain_order_req(cur_orderid, owner_id);
			end
		end
	end
end

function Bargain_Detail_UI.UpdateData()
	if Bargain_Detail_UI.bShowing == true then
		local v = BP_STRUCT_BargainDetail_ItemInfo;
		v.left_time = v.create_time + v.valid_time - Bargain_System_UI.serverTime;
		if v.left_time < 0 then
			v.left_time = 0;
        elseif v.left_time > BP_BargainSystemUI_CurrentLeftTime then
			if BP_BargainSystemUI_CurrentLeftTime < 0 then
				v.left_time = 0;
			else
				v.left_time = BP_BargainSystemUI_CurrentLeftTime;
			end
            
        end
        
		if v.open_state ~= -1 then
			v.open_state = Bargain_System_UI.GetOrderState(v.left_time, v.finish);
		end
		
		LuaClassObj.HandleUIMessage(bp_bargain_detail, "UpdateData");
	end
end

function Bargain_Detail_UI.Hide()
	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIHide");
	Bargain_Detail_UI.Release();
	PDD_System_UI.SavePDDSaveGames();

	if Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.sns_application then
		log("[HHF]Bargain_Detail_UI.Hide, Clear adjust.");
		Bargain_Detail_UI.SetBargainURL("");
		Client.ClearAdjustDeepLink();
	end
end

function Bargain_Detail_UI.HideBuyDialog()
	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIHideBuy");
end

function Bargain_Detail_UI.HideHistoryDialog()
	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIHideHistory");
end

function Bargain_Detail_UI.HideFirstDialog()
	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UIHideFirst");
end

function Bargain_Detail_UI.OnBuySuccess(orderid, items)
	local arrayItemData = {};
	for k, v in pairs(items) do
		table.insert(arrayItemData, {res_id = v.resid, count = v.count});
	end

	log("[HHF]Bargain_Detail_UI.OnBuySuccess, #arrayItemData = " .. tostring(#arrayItemData));
	if #arrayItemData > 0 then
		Bargain_Detail_UI.HideBuyDialog();
		Bargain_Detail_UI.Hide();
		Bargain_System_UI.UpdateOrderAfterBuy(orderid);
		CommonItemGetUI:ShowPanel(arrayItemData);
	else

	end
end

function Bargain_Detail_UI.OnSendFriendSuccess(receiver_id)
	log("[HHF]Bargain_Detail_UI.OnSendFriendSuccess, receiver_id = " .. tostring(receiver_id));
	for k, v in pairs(BP_ARRAY_BargainDetail_FriendsList) do
		if v.uid == tostring(receiver_id) then
			v.has_invited = true;
			break;
		end
	end

	LuaClassObj.HandleUIMessage(bp_bargain_detail, "UpdateData");
	PopUpNoticeUI.ShowNewNotice(FuncUtil.GetLocalizeResStr(301265));
end

function Bargain_Detail_UI.Release()
	log("[HHF]Bargain_Detail_UI.Release");
	Bargain_Detail_UI.bShowing = false;
	Bargain_Detail_UI.cutFriendsList = {};
end

function EventOnClickCloseFirstBargain()
	log("[HHF]EventOnClickCloseFirstBargain");
	Bargain_Detail_UI.HideFirstDialog();
end

function EventOnClickCloseBargainDetail()
	log("[HHF]EventOnClickCloseFirstBargain");
	Bargain_Detail_UI.Hide();
	FaceSlapSystem.ShowNext(BP_ENUM_MODULE_PDD_BARGAIN);
end

function EventFetchBargainDetailInfo()
	--log("[HHF]EventFetchBargainDetailInfo");
end

function EventOnClickBargainInvite()
	log("[HHF]EventOnClickBargainInvite, BP_BargainDetail_CurrentClickType = " .. tostring(BP_BargainDetail_CurrentClickType));
	if BP_BargainDetail_CurrentClickType == 0 then
		Bargain_Logic.SendToJuntuan(BP_STRUCT_BargainDetail_ItemInfo);
	elseif BP_BargainDetail_CurrentClickType == 1 then
		Bargain_Logic.SendToFriend(BP_BargainDetail_CurrentClickUID, BP_BargainDetail_CurrentClickName, BP_STRUCT_BargainDetail_ItemInfo);
	end
end

function EventOnClickBargainHasInvited()
	log("[HHF]EventOnClickBargainHasInvited");
end

function EventOnClickBargainDetailBuyBtn()
	log("[HHF]EventOnClickBargainDetailBuyBtn");
	if BP_STRUCT_BargainDetail_ItemInfo.cur_price > 0 then
		Bargain_Detail_UI.ShowBuyDialog();
	else
		Bargain_Logic.pdd_bargain_buy_req(BP_STRUCT_BargainDetail_ItemInfo.cur_orderid, BP_STRUCT_BargainDetail_ItemInfo.cur_price / Bargain_System_UI.priceRatio);
	end
end

function EventOnClickBargainBuyOK()
	log("[HHF]EventOnClickBargainBuyOK");
	Bargain_Logic.pdd_bargain_buy_req(BP_STRUCT_BargainDetail_ItemInfo.cur_orderid, BP_STRUCT_BargainDetail_ItemInfo.cur_price / Bargain_System_UI.priceRatio);
end

function EventOnClickBargainBuyClose()
	log("[HHF]EventOnClickBargainBuyClose");
	Bargain_Detail_UI.HideBuyDialog();
end

function EventOnClickBargainHistory()
	log("[HHF]EventOnClickBargainHistory");
	Bargain_Detail_UI.ShowHistoryDialog();
end

function EventOnClickBargainHistoryClose()
	log("[HHF]EventOnClickBargainHistoryClose");
	Bargain_Detail_UI.HideHistoryDialog();
end

function Bargain_Detail_UI.IsMyFriend(uid)
	local result = false;
	for k, v in pairs(BP_ARRAY_BargainDetail_FriendsList) do
		if v.item_type == 1 and uid == v.uid then
			result = true;
			break;
		end
	end

	log("[HHF]Bargain_Detail_UI.IsMyFriend, uid = " .. tostring(uid) .. ", result = " .. tostring(result));
	return result;
end

function Bargain_Detail_UI.IsSameJuntuan(uid)
	local result = false;
    --log_tree("IsSameJuntuan",DataMgr.corpsInfo.corpsMemberList)
	for k, v in pairs(DataMgr.corpsInfo.corpsMemberList) do
		if uid == v.strId then
			result = true;
			break;
		end
	end

	--log("[HHF]Bargain_Detail_UI.IsSameJuntuan, uid = " .. tostring(uid) .. ", result = " .. tostring(result));
    
	return result;
end

function Bargain_Detail_UI.GetRelationshipByUID(uid)
	local is_friend = false;
	local is_league = false;
	if Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.myorder_channel then
		is_friend = false;
		is_league = false;
	elseif Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.friend_channel then
		is_friend = true;
		is_league = Bargain_Detail_UI.IsSameJuntuan(uid);
	elseif Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.juntuan_channel then
		is_friend = Bargain_Detail_UI.IsMyFriend(uid);
		is_league = true;
	elseif Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.sns_application then
		is_friend = Bargain_Detail_UI.IsMyFriend(uid);
		is_league = Bargain_Detail_UI.IsSameJuntuan(uid);
	end

	log("[HHF]Bargain_Detail_UI.GetRelationshipByID, uid = " .. tostring(uid) .. ", is_friend = " .. tostring(is_friend) .. ", is_league = " .. tostring(is_league));
	return is_friend, is_league;
end

function Bargain_Detail_UI.IsFromCanDirectBargainChannel()
	local result = false;
	if Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.friend_channel or Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.juntuan_channel then
		result = true;
	else
		result = false;
	end

	log("[HHF]Bargain_Detail_UI.IsFromCanDirectBargainChannel, Bargain_Detail_UI.fromChannel = " .. tostring(Bargain_Detail_UI.fromChannel) .. ", result = " .. tostring(result));
	return result;
end

function EventOnClickBargainHelpOthers()
	log("[HHF]EventOnClickBargainHelpOthers");
	local is_friend, is_league = Bargain_Detail_UI.GetRelationshipByUID(BP_STRUCT_BargainDetail_ItemInfo.uid);
	Bargain_Logic.pdd_bargain_do_help_req(BP_STRUCT_BargainDetail_ItemInfo.cur_orderid, BP_STRUCT_BargainDetail_ItemInfo.uid, is_friend, is_league);
end

function EventOnClickBargainCreateSameOrder()
	log("[HHF]EventOnClickBargainCreateSameOrder");
	Bargain_Detail_UI.Hide();
	PDD_System_UI.Show(PDD_System_UI.tabBargain, 0, true);
end

function Bargain_Detail_UI.SendToFriendBySNSApplication(inviteChannnel)	
	local title = FuncUtil.GetLocalizeResStr(106052);
	local tips = FuncUtil.GetLocalizeResStr(6230) .. FuncUtil.GetLocalizeResStr(6231);
	local link = Bargain_Detail_UI.ConstructInviteLink(Client.GetCurrentLanguage(), DataMgr.roleData.uid, BP_STRUCT_BargainDetail_ItemInfo.cur_orderid, DataMgr.roleData.nickName, inviteChannnel);
    
    log("SendToFriendBySNSApplication tip:" .. tips);
	
	if inviteChannnel == Bargain_Detail_UI.InviteByMessenger then
		local content = tips;
		Client.InviteFBOfflineFriends(NetInterface, title, content, link);
	elseif inviteChannnel == Bargain_Detail_UI.InviteBySMS then
		local content = tips .. " " .. link;
		Client.InviteSMSOfflineFriends(NetInterface, content);
	elseif inviteChannnel == Bargain_Detail_UI.InviteByWhatsapp then
		local content = tips .. " " .. link;
		Client.InviteWhatsappOfflineFriends(NetInterface, title, content);
	elseif inviteChannnel == Bargain_Detail_UI.InviteBySystem then
		local content = tips .. " " .. link;
		Client.InviteSystemOfflineFriends(NetInterface, title, content);
	elseif inviteChannnel == Bargain_Detail_UI.InviteByLine then
		local content = tips .. " " .. link;
		Client.InviteLineOfflineFriends(NetInterface, title, content);
	end
end

function Bargain_Detail_UI.URLEncode(str)
	log("[HHF]Bargain_Detail_UI.URLEncode, before str = " .. tostring(str));
	if str ~= nil then
		str = string.gsub(str, "([^%w%.%- ])", 
			function(c)
				return string.format("%%%02x", string.byte(c));
			end);
		str = string.gsub(str, " ", "+");
	end

	log("[HHF]Bargain_Detail_UI.URLEncode, after str = " .. tostring(str));
	return str;
end

function Bargain_Detail_UI.URLDecode(str)
	log("[HHF]Bargain_Detail_UI.URLDecode, before str = " .. tostring(str));
	if str ~= nil then
		str = string.gsub(str, "+", " ");
		str = string.gsub(str, "%%(%x%x)", 
			function(h)
				return string.char(tonumber(h, 16));
			end);
	end

	log("[HHF]Bargain_Detail_UI.URLDecode, after str = " .. tostring(str));
	return str;
end

function Bargain_Detail_UI.ConstructInviteLink(language, uid, orderid, name, source)
	name = Bargain_Detail_UI.URLEncode(name);
	local link = "";
	local region = Client.GetPublishRegion();
	if region == "JAPAN" or region == "KOREA" then
		link = "https://www.pubgmobile.com/" .. language .. "/event/bargain/?module=1007000&uid=" .. uid .. "&orderid=" .. orderid .. "&name=" .. name .. "&src=" .. source .. "&adjust_t=x1mtjpd_mqwt2n5&adjust_deeplink=igame1321%3a%2f%2fmodule%3d1007000%26uid%3d" .. uid .. "%26orderid%3d" .. orderid .. "%26name%3d" .. name .. "%26src%3d" .. source .. "&region=jk";
	elseif region == "VNG" then
		link = "https://www.pubgmobile.com/" .. language .. "/event/bargain/?module=1007000&uid=" .. uid .. "&orderid=" .. orderid .. "&name=" .. name .. "&src=" .. source .. "&adjust_t=9ejlhee_r825igb&adjust_deeplink=igame1380%3a%2f%2fmodule%3d1007000%26uid%3d" .. uid .. "%26orderid%3d" .. orderid .. "%26name%3d" .. name .. "%26src%3d" .. source .. "&region=vn";
	elseif region == "TW" then
		link = "https://www.pubgmobile.com/" .. language .. "/event/bargain/?module=1007000&uid=" .. uid .. "&orderid=" .. orderid .. "&name=" .. name .. "&src=" .. source .. "&adjust_t=9ejlhee_r825igb&adjust_deeplink=igame1380%3a%2f%2fmodule%3d1007000%26uid%3d" .. uid .. "%26orderid%3d" .. orderid .. "%26name%3d" .. name .. "%26src%3d" .. source .. "&region=tw";
	else
		link = "https://www.pubgmobile.com/" .. language .. "/event/bargain/?module=1007000&uid=" .. uid .. "&orderid=" .. orderid .. "&name=" .. name .. "&src=" .. source .. "&adjust_t=1ccqjjq_28blkbm&adjust_deeplink=igame1320%3a%2f%2fmodule%3d1007000%26uid%3d" .. uid .. "%26orderid%3d" .. orderid .. "%26name%3d" .. name .. "%26src%3d" .. source .. "&region=gl";
	end

	log("[HHF]Bargain_Detail_UI.ConstructInviteLink, link = " .. link);
	return link;
end

function EventOnClickBargainSendBySMS()
	log("[HHF]EventOnClickBargainSendBySMS");
	Bargain_Detail_UI.SendToFriendBySNSApplication(Bargain_Detail_UI.InviteBySMS);
end

function EventOnClickBargainSendByMessenger()
	log("[HHF]EventOnClickBargainSendByMessenger");
	if Client.IsInstallMessenger(NetInterface) == false then
		DataMgr.ShowNoticeByID(4466);
		return
	end

	Bargain_Detail_UI.SendToFriendBySNSApplication(Bargain_Detail_UI.InviteByMessenger);
end

function EventOnClickBargainSendByWhatsApp()
	log("[HHF]EventOnClickBargainSendByWhatsApp");
	if Client.IsInstallWhatsapp(NetInterface) == false then
		DataMgr.ShowNoticeByID(4714);
		return
	end

	Bargain_Detail_UI.SendToFriendBySNSApplication(Bargain_Detail_UI.InviteByWhatsapp);
end

function EventOnClickBargainSendByLine()
	log("[HHF]EventOnClickBargainSendByLine");
	Bargain_Detail_UI.SendToFriendBySNSApplication(Bargain_Detail_UI.InviteByLine);
end

function EventOnClickBargainSendByMore()
	log("[HHF]EventOnClickBargainSendByMore");
	Bargain_Detail_UI.SendToFriendBySNSApplication(Bargain_Detail_UI.InviteBySystem);
end

function EventOnClickBargainCheckbox()
	log("[HHF]EventOnClickBargainCheckbox, BP_BargainDetail_CheckBox = " .. tostring(BP_BargainDetail_CheckBox));
	PDD_System_UI.UpdateDirectBargainCheckState(BP_BargainDetail_CheckBox);
end

function Bargain_Detail_UI.ShouldSlap()
	local s = string.find(Bargain_Detail_UI.bargainURL, tostring(BP_ENUM_MODULE_PDD_BARGAIN));
	if s ~= nil then
		log("[HHF]Bargain_Detail_UI.ShouldSlap, return true");
		return true
	else
		log("[HHF]Bargain_Detail_UI.ShouldSlap, return false");
		return false
	end
end

--game://?module=1007000&uid=510002492&orderid=278359793&name=Win11&src=sms
function Bargain_Detail_UI.SetBargainURL(url)
	log("[HHF]Bargain_Detail_UI.SetBargainURL, url = " .. tostring(url));
	Bargain_Detail_UI.bargainURL = url;
end

function Bargain_Detail_UI.ProcessQueryOrderFailed(res)
	log("[HHF]Bargain_Detail_UI.ProcessQueryOrderFailed, res = " .. tostring(res));
	if res == Bargain_Logic.pdd_bargain_errcode_not_in_period then
		if Bargain_Detail_UI.fromChannel == Bargain_Detail_UI.sns_application then
			log("[HHF]Bargain_Detail_UI.Hide, Clear adjust and continue FaceSlapSystem.");
			Client.ClearAdjustDeepLink();
			FaceSlapSystem.ShowNext(BP_ENUM_MODULE_PDD_BARGAIN);
		end
	end
end

--初始化节点信息表
function Bargain_Detail_UI.InitBargainNodeConfig()
	log("Bargain_Detail_UI.InitBargainNodeConfig");
	local tableData = Client.GetTable("BargainNodeConfig");
	local temp = {};

	if tableData == nil then
		log("Bargain_Detail_UI.InitBargainNodeConfig nodeTable is NUll!!");
		return;
	end
	
	--读节点表并存储在临时表中
	for k,v in pairs(tableData) do
		if 	temp[v.nodeID] == nil then
			temp[v.nodeID] = {};
		end
		
		table.insert(temp[v.nodeID], {
					ID = v.ID;
					bargainNeedNum = v.bargainNeedNum;
					bargainTotalNum = v.bargainTotalNum;
					discount = 100-v.discount;
					messageType = v.messageType;
				}
		)
	end
	
	--临时表按ID升序整理
	for k, v in pairs(temp) do
		table.sort(v,function (a,b)
			return a.ID < b.ID;
		end)
	end

	Bargain_Detail_UI.totalNodeConfig = temp;
	log_tree("Bargain_Detail_UI.InitBargainNode totalNodeConfig：",Bargain_Detail_UI.totalNodeConfig);
end

function EventSaveUserNodeInfo()
	BP_PDDSystem_UserNodeDiscount = BP_BargainDetail_CertainDiscount;
	BP_PDDSystem_UserNodeOrderid = BP_BargainDetail_CurrentOrderid;
	PDD_System_UI.SaveUserNodeInfo();
	
	log("EventSaveUserNodeInfo ID : " .. BP_PDDSystem_UserNodeOrderid .. "|| Discount : " .. BP_PDDSystem_UserNodeDiscount)
end


