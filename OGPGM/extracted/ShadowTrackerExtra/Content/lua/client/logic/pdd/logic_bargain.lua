Bargain_Logic = Bargain_Logic or {
	pdd_bargain_errcode_success					= 0,
	pdd_bargain_errcode_param                   = 506001,     --参数错误
	pdd_bargain_errcode_not_in_period           = 506002,     --没有在活动周期内
	pdd_bargain_errcode_no_cfg                  = 506003,     --没有找到配置
	pdd_bargain_errcode_order_exsist            = 506004,     --订单已存在，无法重复创建
	pdd_bargain_errcode_unknown                 = 506005,     --未知错误
	pdd_bargain_errcode_db_err                  = 506006,     --db错误
	pdd_bargain_errcode_busy                    = 506007,     --服务器繁忙
	pdd_bargain_errcode_share_limit             = 506008,     --分享已达上限
	pdd_bargain_errcode_price_change            = 506009,     --订单价格发生变化
	pdd_bargain_errcode_no_ticket               = 506010,     --点券不足
	pdd_bargain_errcode_pay_err                 = 506011,     --支付失败
	pdd_bargain_errcode_order_state_err         = 506012,     --订单状态异常
	pdd_bargain_errcode_order_free              = 506013,     --订单已免费，已经砍到0
	pdd_bargain_errcode_order_cnt_limit         = 506014,     --订单数量已达上限
	pdd_bargain_errcode_already_help            = 506015,     --订单已经帮助过
	pdd_bargain_errcode_help_cnt_limit          = 506016,     --订单帮助达到上限
	pdd_bargain_errcode_region_limit            = 506017,     --运营区域限制
	pdd_bargain_errcode_level_limit             = 506018,     --玩家等级限制
	pdd_bargain_errcode_account_type_limit      = 506019,     --没有绑定社交账号
	pdd_bargain_errcode_relation_limit          = 506020,     --社交关系限制（非军团、非好友）
	pdd_bargain_errcode_has_share               = 506021,     --已经分享过了
	pdd_bargain_errcode_order_expired           = 506022,     --订单已过期
	pdd_bargain_errcode_league_help_limit       = 506023,     --该订单达到军团非好友砍价次数上限
	pdd_bargain_errcode_level_account_limit     = 506024,     --玩家等级不足 且 没有绑定社交账号 
    pdd_bargain_errcode_share_fail              = 506025,     --好友消息分享失败
    pdd_bargain_errcode_order_full_help         = 506026,     --砍价已满：该玩家已经获得足够多的砍价，请换个好友帮忙

    pdd_order_show_type_can_cut   = 100,  --可以正常砍价
    pdd_order_show_type_cut_limit = 101,  --达到砍价次数上限 -
    pdd_order_show_type_has_cut   = 102,  --拉取的人已经砍过该订单 
    pdd_order_show_type_has_buy   = 103,  --订单已经购买，无法再被砍
    pdd_order_show_type_expired   = 104,  --订单已经过期 -
    pdd_order_show_type_not_fri   = 105,  --不是朋友，如果是同军团才允许砍价 -

	current_buy_orderid = 0,

	current_help_is_friend = false,
	current_help_is_league = false,
}

function Bargain_Logic.GetSystemOpenState()
	local cur_ser_time = math.floor(Bargain_System_UI.serverTime);
	--[[
	local str_time = os.date('%Y-%m-%d %H:%M:%S', cur_ser_time);
	log("[HHF]Bargain_Logic.GetSystemOpenState, cur_ser_time = " .. tostring(str_time) .. 
		", open_time = " .. tostring(PDD_System_Logic.pddSystem_Time.open_time) .. 
		", end_time = " .. tostring(PDD_System_Logic.pddSystem_Time.end_time));
	--]]
	if cur_ser_time < PDD_System_Logic.pddSystem_Time.begin_timestamp then
		--log("[HHF]Bargain_Logic.GetSystemOpenState, return notStart");
		return Bargain_System_UI.notStart;
	elseif cur_ser_time < PDD_System_Logic.pddSystem_Time.end_timestamp then
		--log("[HHF]Bargain_Logic.GetSystemOpenState, return inProgress");
		return Bargain_System_UI.inProgress;
	else
		--log("[HHF]Bargain_Logic.GetSystemOpenState, return haveEnded");
		return Bargain_System_UI.haveEnded;
	end
end

function Bargain_Logic.ShowTipsByErrorCode(code)
	log("[HHF]Bargain_Logic.ShowTipsByErrorCode, code = " .. tostring(code));	
	if code == Bargain_Logic.pdd_bargain_errcode_param then
		local tips = FuncUtil.GetLocalizeResStr(505015);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_not_in_period then
		local tips = FuncUtil.GetLocalizeResStr(430104);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_no_cfg then
		local tips = FuncUtil.GetLocalizeResStr(9920033);
		PopUpNoticeUI.ShowNewNotice(tips);		
	elseif code == Bargain_Logic.pdd_bargain_errcode_order_exsist then
		local tips = FuncUtil.GetLocalizeResStr(6272);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_unknown then
		local tips = FuncUtil.GetLocalizeResStr(6273);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_db_err then
		local tips = FuncUtil.GetLocalizeResStr(117004);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_busy then
		local tips = FuncUtil.GetLocalizeResStr(6195);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_share_limit then
		local tips = FuncUtil.GetLocalizeResStr(6196);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_price_change then
		local tips = FuncUtil.GetLocalizeResStr(6197);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_no_ticket then		
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
		CommonMessageBoxUI:ShowPanel(2, title, tip, 
			function()
				RechargeUI:Init();
			end);
	elseif code == Bargain_Logic.pdd_bargain_errcode_pay_err then
		local tips = FuncUtil.GetLocalizeResStr(502005);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_order_state_err then
		local tips = FuncUtil.GetLocalizeResStr(6198);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_order_free then
		local tips = FuncUtil.GetLocalizeResStr(6199);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_order_cnt_limit then
		local tips = FuncUtil.GetLocalizeResStr(6209);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_already_help then
		local tips = FuncUtil.GetLocalizeResStr(6200);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_help_cnt_limit then
		local tips = FuncUtil.GetLocalizeResStr(6201);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_region_limit then
		local tips = FuncUtil.GetLocalizeResStr(6202);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_level_limit then
		local tips = FuncUtil.GetLocalizeResStr(6203);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_account_type_limit then
		local tips = FuncUtil.GetLocalizeResStr(6204);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_relation_limit then
		local tips = FuncUtil.GetLocalizeResStr(6205);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_has_share then
		local tips = FuncUtil.GetLocalizeResStr(6274);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_order_expired then
		local tips = FuncUtil.GetLocalizeResStr(6206);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_league_help_limit then
		local tips = FuncUtil.GetLocalizeResStr(6207);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_level_account_limit then
		local tips = FuncUtil.GetLocalizeResStr(6208);
		PopUpNoticeUI.ShowNewNotice(tips);
	elseif code == Bargain_Logic.pdd_bargain_errcode_order_full_help then
		local tips = FuncUtil.GetLocalizeResStr(6207);
		PopUpNoticeUI.ShowNewNotice(tips);
	else

	end
end

function Bargain_Logic.pdd_bargain_history_orders_req()
	log("[HHF]Bargain_Logic.pdd_bargain_history_orders_req");

	--NetUtil.SendPkg("pdd_bargain_history_orders_req");
	NetUtil.SendPriorityPkg(false, "pdd_bargain_history_orders_rsp", "pdd_bargain_history_orders_req");
end

function Bargain_Logic.pdd_bargain_history_orders_rsp(res, order_list, shop_cfgs, shop_states, now_time, max_discount, gain_gold, gain_corps_money)
	log("[HHF]Bargain_Logic.pdd_bargain_history_orders_rsp, res = " .. tostring(res) .. ", now_time = " .. tostring(now_time) .. 
            ", max_discount : " .. max_discount .. ", gain_gold : " .. gain_gold .. ", gain_corps : " .. gain_corps_money);
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_history_orders_rsp, shop_cfgs = ", shop_cfgs, "[HHFTEST]");
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_history_orders_rsp, shop_states = ", shop_states, "[HHFTEST]");
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_history_orders_rsp, order_list = ", order_list, "[HHFTEST]");

	if res == Bargain_Logic.pdd_bargain_errcode_success then
		Bargain_System_UI.SetServerTime(now_time);
		Bargain_System_UI.SetData(shop_cfgs, shop_states, order_list,max_discount, gain_gold, gain_corps_money);
	else
		Bargain_Logic.ShowTipsByErrorCode(res);
	end
end

function Bargain_Logic.pdd_bargain_create_order_req(shopID)
	log("[HHF]Bargain_Logic.pdd_bargain_create_order_req, shopID = " .. tostring(shopID));

	--NetUtil.SendPkg("pdd_bargain_create_order_req", shopID);
	NetUtil.SendPriorityPkg(false, "pdd_bargain_create_order_rsp", "pdd_bargain_create_order_req", shopID);
end

function Bargain_Logic.pdd_bargain_create_order_rsp(res, orderid, shopid, order_brief, create_cnt, max_help_cnt, node_index)
	log("[HHF]Bargain_Logic.pdd_bargain_create_order_rsp, res = " .. tostring(res) .. 
		", orderid = " .. tostring(orderid) .. 
		", shopid = " .. tostring(shopid) ..
		", create_cnt = " .. tostring(create_cnt));
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_create_order_rsp, order_brief = ", order_brief, "[HHFTEST]");

    BP_BargainDetail_MaxHelpTime = max_help_cnt;
    
	if res == Bargain_Logic.pdd_bargain_errcode_success then
		Bargain_System_UI.OnCreateOrder(orderid, shopid, order_brief, create_cnt, node_index);
	else
		Bargain_Logic.ShowTipsByErrorCode(res);
	end
end

function Bargain_Logic.pdd_bargain_do_help_req(orderid, own_uid, is_friend, is_league)
	log("[HHF]Bargain_Logic.pdd_bargain_do_help_req, orderid = " .. tostring(orderid) ..
		", own_uid = " .. tostring(own_uid) ..
		", is_friend = " .. tostring(is_friend) .. 
		", is_league = " .. tostring(is_league));
	Bargain_Logic.current_help_is_friend = is_friend;
	Bargain_Logic.current_help_is_league = is_league;
	NetUtil.SendPriorityPkg(false, "pdd_bargain_do_help_rsp", "pdd_bargain_do_help_req", orderid, own_uid, is_friend, is_league);
end

function Bargain_Logic.pdd_bargain_do_help_rsp(res, own_uid, orderid, ext_data, reward_gold, reward_corps_money, reward_inimacy, can_get_reward, total_money, total_coprs_money)
	log("[HHF]Bargain_Logic.pdd_bargain_do_help_rsp, res = " .. tostring(res) ..
		", own_uid = " .. tostring(own_uid) ..
		", orderid = " .. tostring(orderid) .. 
		", reward_gold = " .. tostring(reward_gold) ..
		", reward_corps_money = " .. tostring(reward_corps_money) ..
		", reward_inimacy = " .. tostring(reward_inimacy) .. 
	 	", can_get_reward = " .. tostring(can_get_reward) .. 
        ", total_money = " .. tostring(total_money) .. 
        ", total_coprs_money = " .. tostring(total_coprs_money)
    );
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_do_help_rsp, ext_data = ", ext_data, "[HHFTEST]");


	if res == Bargain_Logic.pdd_bargain_errcode_success then
		
		if reward_inimacy > 0 then
			--亲密度提示
			local friendName = "";
			for k, v in pairs(BP_ARRAY_BargainSystemUI_StateInfo) do
				if tostring(own_uid) == tostring(v.uid) then
					friendName = v.name;
					break;
				end
			end
			local tips =  GlobalData.GetLocalizeStringWithNum(6470, 1, friendName,tostring(reward_inimacy));
			PopUpNoticeUI.ShowNewNotice(tips);
		end

        BP_STRUCT_BargainDetail_IncomeInfo.canGetIncome = can_get_reward;
        BP_STRUCT_BargainDetail_IncomeInfo.goldNum = reward_gold;
        BP_STRUCT_BargainDetail_IncomeInfo.corpsGoldNum = reward_corps_money;
        BP_STRUCT_BargainDetail_ItemInfo.buy_price = ext_data.buy_price * Bargain_System_UI.priceRatio;
		BP_STRUCT_BargainDetail_ItemInfo.help_num = ext_data.helpnum;
        BP_BargainSystemUI_TotalMoney = total_money;
        BP_BargainSystemUI_TotalCorpsMoney = total_coprs_money;

        for k,v in pairs(BP_ARRAY_BargainSystemUI_StateInfo) do
            if v.id == orderid then
                v.show_type = 101;
				v.buy_price = ext_data.buy_price;
                break;
            end
        end

		Bargain_Detail_UI.OnHelpBargainSuccess(own_uid, orderid, ext_data);
		Bargain_System_UI.UpdateOrderDataAfterBargain(own_uid, orderid, ext_data);

		if Bargain_Detail_UI.IsFromCanDirectBargainChannel() == true then
			LobbyChatLogic.UpdateBargainOrderState();
		end
		PDD_System_UI.UpdateBargainedOrderList(orderid);
	else
		Bargain_Logic.ShowTipsByErrorCode(res);
		
		local show_type = "";
		local msg = "";
		local name = "";
		for k,v in pairs(BP_ARRAY_BargainSystemUI_StateInfo) do
			if v.id == orderid then
                if res == Bargain_Logic.pdd_bargain_errcode_order_full_help then
                    v.show_type = Bargain_Logic.pdd_order_show_type_cut_limit;
                elseif res == Bargain_Logic.pdd_bargain_errcode_relation_limit then
                    v.show_type = Bargain_Logic.pdd_order_show_type_not_fri;
                    name = v.name;
                elseif res == Bargain_Logic.pdd_bargain_errcode_order_state_err then
                    v.show_type = Bargain_Logic.pdd_order_show_type_has_buy;
                end
				show_type = v.show_type;
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
        BP_BargainDetail_NotHaveBargainDesc = msg;

		-- 订单已经成功交易，也算作砍价过。
		if res == Bargain_Logic.pdd_bargain_errcode_order_state_err then
			if Bargain_Detail_UI.directBargain == true then
				LobbyChatLogic.UpdateBargainOrderState();
				PDD_System_UI.UpdateBargainedOrderList(orderid);
			end
		end
        --对于部分错误码隐藏购买按钮
        if Bargain_Detail_UI.bShowing == true then
            if res == Bargain_Logic.pdd_bargain_errcode_not_in_period
                    or res == Bargain_Logic.pdd_bargain_errcode_order_state_err
                    or res == Bargain_Logic.pdd_bargain_errcode_order_free
                    or res == Bargain_Logic.pdd_bargain_errcode_already_help
                    or res == Bargain_Logic.pdd_bargain_errcode_relation_limit
                    or res == Bargain_Logic.pdd_bargain_errcode_order_expired
                    or res == Bargain_Logic.pdd_bargain_errcode_order_full_help then
                BP_STRUCT_BargainDetail_ItemInfo.open_state = -1;
                
            end
        end
	end
end

function Bargain_Logic.pdd_bargain_notify(orderid, ext_data)
	log("[HHF]Bargain_Logic.pdd_bargain_notify, orderid = " .. tostring(orderid));
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_notify, ext_data = ", ext_data, "[HHFTEST]");
    
    BP_STRUCT_BargainDetail_ItemInfo.help_num = ext_data.helpnum;
	BP_STRUCT_BargainDetail_ItemInfo.buy_price = ext_data.buy_price * Bargain_System_UI.priceRatio;
    
	Bargain_Detail_UI.UpdateOrderDataAfterBargain(DataMgr.roleData.uid, orderid, ext_data);
	Bargain_System_UI.UpdateOrderDataAfterBargain(DataMgr.roleData.uid, orderid, ext_data);

	--刷新购买的数据
	if Bargain_Detail_UI.bShowing == true then
		LuaClassObj.HandleUIMessage(bp_bargain_detail, "UpdateBuyPrice");
	end
end

function Bargain_Logic.pdd_bargain_redpoint_notify(msg)
	log("[HHFTEST]Bargain_Logic.pdd_bargain_redpoint_notify, msg = ", msg, "[HHFTEST]");
	PDD_System_UI.UpdateBargainNotifyReddotCache(true, msg.orderid);
end

function Bargain_Logic.pdd_bargain_buy_req(orderid, pay_price)
	log("[HHF]Bargain_Logic.pdd_bargain_buy_req, orderid = " .. tostring(orderid) .. ", pay_price = " .. tostring(pay_price));
	Bargain_Logic.current_buy_orderid = orderid;

	NetUtil.SendPriorityPkg(false, "pdd_bargain_buy_rsp", "pdd_bargain_buy_req", orderid, pay_price);
end

function Bargain_Logic.pdd_bargain_buy_rsp(res, items, price, orderid)
	log("[HHF]Bargain_Logic.pdd_bargain_buy_rsp, res = " .. tostring(res) .. ", price = " .. tostring(price));
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_buy_rsp, items = ", items, "[HHFTEST]");

	if res == Bargain_Logic.pdd_bargain_errcode_success then
		Bargain_Detail_UI.OnBuySuccess(Bargain_Logic.current_buy_orderid, items);
		PDD_System_UI.UpdateBargainNotifyReddotCache(false, orderid);
		PDD_System_UI.UpdateUCAfterBuy();
	else
		Bargain_Logic.ShowTipsByErrorCode(res);
	end
end

function Bargain_Logic.SendToJuntuan(itemInfo)
	log("[HHF]Bargain_Logic.SendToJuntuan.");
	local receiver = nil;
	local channel = LobbyChatSystem.channelCorpsBargain;
	local content = FuncUtil.GetLocalizeResStr(6210);
	local topicId = "world_Channel";
	local selectPlayer = {};
	local topicList = {};
	local msgType = LobbyChatSystem.bargainMessageType;
	local other = {};
	other.channel = Bargain_Detail_UI.juntuan_channel;
	other.msg_type = LobbyChatSystem.bargainMessageType;
	other.owner_id = itemInfo.uid;
	other.cur_orderid = itemInfo.cur_orderid;
	other.shop_id = itemInfo.shop_id;
	other.have_bargained = false;
	other.item_id = itemInfo.item_id;
	other.quality = itemInfo.quality;
	other.ori_price = itemInfo.ori_price;
	other.cur_price = itemInfo.cur_price;
	--local tips = FuncUtil.GetLocalizeResStr(6212);
	--tips = string.gsub(tips, "{1}", tostring(other.ori_price / Bargain_System_UI.priceRatio));
	--tips = string.gsub(tips, "{2}", tostring(itemInfo.name));
	other.description = "";--tips;
	LobbyChatSystem.on_chat_req(receiver, channel, content, topicId, selectPlayer, topicList, other, msgType);
end

function Bargain_Logic.SendToFriend(receiver_uid, receiver_name, itemInfo)
	log("[HHF]Bargain_Logic.SendToFriend, receiver_uid = " .. tostring(receiver_uid) .. ", receiver_name = " .. tostring(receiver_name));
	local receiver = tonumber(receiver_uid);
	local other = {};
	other.owner_id = itemInfo.uid;
	other.cur_orderid = itemInfo.cur_orderid;
	other.shop_id = itemInfo.shop_id;
	--other.have_bargained = false;
	other.item_id = itemInfo.item_id;
	--other.quality = itemInfo.quality;
	other.ori_price = itemInfo.ori_price;
	other.cur_price = itemInfo.cur_price;
	other.headicon_url = DataMgr.roleData.headIconUrl;
	other.name = DataMgr.roleData.nickName;
    other.frame_level = DataMgr.roleData.cur_avatar_box_id;
	
	local content = {};
	content.other = other;
	
	NetUtil.SendPkg("pdd_bargain_fri_share_req", receiver, content);
	--LobbyChatSystem.on_chat_req(receiver, channel, content, topicId, selectPlayer, topicList, other, msgType);

--[[
	local chat_content = {};
	chat_content.aliasid = 0;
	chat_content.topicList = {};
	chat_content.aliasnation = "";
	chat_content.selectPlayer = 0;
	chat_content.url = "10001";
	chat_content.avatarBox = 2001001;
	chat_content.quickMsg = false;
	chat_content.topic = "world_Channel";
	chat_content.voice = "";
	chat_content.upass = "";
	chat_content.level = 5;
	chat_content.aliarank = 0;
	chat_content.voiceLength = 0;
	chat_content.text = FuncUtil.GetLocalizeResStr(6210);
	chat_content.msgType = LobbyChatSystem.bargainMessageType;
	chat_content.other = other;
	LobbyChatSystem.chat_notify(4, receiver_name, 1, chat_content, receiver_uid, "G1");
--]]
end

function Bargain_Logic.pdd_bargain_chat_notify(errcode)	
	log("[HHF]Bargain_Logic.pdd_bargain_chat_notify, errcode = " .. tostring(errcode));
	Bargain_Logic.ShowTipsByErrorCode(errcode);
end

function Bargain_Logic.pdd_bargain_order_req(orderid, own_uid)
	log("[HHF]Bargain_Logic.pdd_bargain_order_req, orderid = " .. tostring(orderid) .. ", own_uid = " .. tostring(own_uid));
	--NetUtil.SendPkg("pdd_bargain_order_req", orderid, own_uid);
	NetUtil.SendPriorityPkg(false, "pdd_bargain_order_rsp", "pdd_bargain_order_req", orderid, own_uid);
end

function Bargain_Logic.pdd_bargain_order_rsp(res, req_orderid, order_brief, records, cfg, now_time, share_record, has_league_share, zero_cnt, max_help_cnt)
	log("[HHF]Bargain_Logic.pdd_bargain_order_rsp, res = " .. tostring(res) .. 
		", now_time = " .. tostring(now_time) .. 
		", req_orderid = " .. tostring(req_orderid) .. 
		", has_league_share = " .. tostring(has_league_share) ..
		", zero_cnt = " .. tostring(zero_cnt) ..
		", max_help_cnt = " .. tostring(max_help_cnt)
	);
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_order_rsp, order_brief = ", order_brief, "[HHFTEST]");
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_order_rsp, records = ", records, "[HHFTEST]");
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_order_rsp, cfg = ", cfg, "[HHFTEST]");
	--log_tree("[HHFTEST]Bargain_Logic.pdd_bargain_order_rsp, share_record = ", share_record, "[HHFTEST]");

    if res == Bargain_Logic.pdd_bargain_errcode_success then
        Bargain_System_UI.SetServerTime(now_time);

        local itemInfo = Client.GetTableData("Item", cfg.item_id);
        if itemInfo ~= nil then
            local saleItem = {};
            saleItem.tab = Bargain_System_UI.tabMySaleItems;
            saleItem.bargain_index = order_brief.index;
            saleItem.shop_id = order_brief.shopid;
            saleItem.item_id = cfg.item_id;
            saleItem.name = itemInfo.ItemName;
            saleItem.desc = itemInfo.ItemDesc;
            saleItem.path = itemInfo.ItemSmallIcon;
            saleItem.big_path = itemInfo.ItemBigIcon;
            saleItem.quality = itemInfo.ItemQuality;
            saleItem.selected = false;
            saleItem.wore = false;
            saleItem.sort = cfg.sort;
            saleItem.item_num = cfg.item_num;
            saleItem.expire_time = cfg.item_expire_time;
            saleItem.ori_price = cfg.ori_price * Bargain_System_UI.priceRatio;
            saleItem.cur_price = order_brief.cur_price * Bargain_System_UI.priceRatio;
            saleItem.current_times = 0;
            saleItem.limit_times = cfg.limit;
            saleItem.cur_orderid = order_brief.id;

            saleItem.start_time = PDD_System_Logic.pddSystem_Time.begin_timestamp;
            saleItem.end_time = PDD_System_Logic.pddSystem_Time.end_timestamp;
            saleItem.valid_time = cfg.valid_time;
            saleItem.zero_cnt = zero_cnt;

            saleItem.BP_STRUCT_BargainDetail_ItemGameInfo = {};
            saleItem.BP_STRUCT_BargainDetail_ItemGameInfo.gl = cfg.game_apps[1320] or false;
            saleItem.BP_STRUCT_BargainDetail_ItemGameInfo.jk = cfg.game_apps[1321] or false;
            saleItem.BP_STRUCT_BargainDetail_ItemGameInfo.lite = cfg.game_apps[1324] or false;

            saleItem.uid = tostring(order_brief.uid);
            saleItem.create_time = order_brief.createtime;
            saleItem.help_num = order_brief.helpnum;
            saleItem.last_time = order_brief.lasttime;
            saleItem.finish = order_brief.finish;

            saleItem.buy_price = order_brief.buy_price * Bargain_System_UI.priceRatio;

            saleItem.left_time = saleItem.create_time + saleItem.valid_time - Bargain_System_UI.serverTime;
            if saleItem.left_time < 0 then
                saleItem.left_time = 0;
            end

            saleItem.open_state = Bargain_System_UI.GetOrderState(saleItem.left_time, saleItem.finish);
            saleItem.node_id = cfg.node_index;
            BP_BargainDetail_MaxHelpTime = max_help_cnt;

            local cutList = {};
            for k, v in pairs(records) do
                local cutInfo = {};
                cutInfo.uid = tostring(k);
                cutInfo.cut = v.cut * Bargain_System_UI.priceRatio;
                cutInfo.name = v.name;
                cutInfo.time = v.time;
                table.insert(cutList, cutInfo);
            end

            if share_record == nil then
                share_record = {};
            else
                if has_league_share then
                    share_record[DataMgr.corpsInfo.id] = true;
                end
            end
            Bargain_Detail_UI.Show(saleItem, cutList, share_record);
        end
    else
        Bargain_Logic.ShowTipsByErrorCode(res);
        Bargain_Detail_UI.ProcessQueryOrderFailed(res);
        
    end
end

--[[
order_list
	├─ 1
	│  ├─ brief
	│  │  ├─ uid: 510002794
	│  │  ├─ createtime: 1546349295
	│  │  ├─ shopid: 1304
	│  │  ├─ price: 360
	│  │  ├─ id: 283346747
	│  │  ├─ helpnum: 2
	│  │  ├─ cur_price: 228.4
	│  │  ├─ finish: 0
	│  │  └─ index: 13
	│  └─ show_type: 102
	├─ 2
	│  ├─ brief
]]--
--批量拉取订单回包
function Bargain_Logic.pdd_bargain_batch_rsp(res,order_List)
	log("Bargain_Logic.on_pdd_bargain_batch_rsp res:" .. res);
	log_tree("Bargain_Logic.on_pdd_bargain_batch_rsp ",order_List);

	local tIsCorpsArray = {};--记录军团关系的临时数组
    
	--设置当前赛季
	for k,v in pairs(order_List) do
		--存储的黑名单
		if BP_PDDSystem_BatchCacheBlackListVersion ~= v.brief.index then
			log("Bargain_Logic.on_pdd_bargain_batch_rsp Version not Compare,Clear Black List. old = " .. BP_PDDSystem_BatchCacheBlackListVersion .."|| new = " .. v.brief.index);
			BP_ARRAY_PDDSystem_BatchCacheBlackList = {};
			
		end

		BP_PDDSystem_BatchCacheBlackListVersion = v.brief.index;
		log("Bargain_Logic.on_pdd_bargain_batch_rsp BP_PDDSystem_BatchCacheVersion = " .. BP_PDDSystem_BatchCacheBlackListVersion);
		break;
	end

    BP_ARRAY_PDDSystem_BatchCacheBlackList = {};
	--储存结构
	for k,v in pairs(order_List) do
		local id = v.brief.id;
		local uid = v.brief.uid;
		
		--log_tree("Bargain_Logic.on_pdd_bargain_batch_rsp TempInfo v:" ,v);

		--log("[test]BP_ARRAY_PDDSystem_BatchCacheBlackList id = " .. id .. "|| v.showType = " .. tostring(v.show_type) .. "|| tIsCorpsArray[uid] = " .. tostring(tIsCorpsArray[uid]));

        if tIsCorpsArray[uid] == nil then
            tIsCorpsArray[uid] = Bargain_Detail_UI.IsSameJuntuan(tostring(uid));
        end
		
        
		--不是朋友但是同军团的可以砍价
		if v.show_type == Bargain_Logic.pdd_order_show_type_not_fri and tIsCorpsArray[uid] == true then
			v.show_type = Bargain_Logic.pdd_order_show_type_can_cut;
		end
		
		--log("test id = " .. id .. "|| show_type =" .. v.show_type)
		
		--非可以砍价或者自己砍价的订单仅加入黑名单，不加入订单List并从列表删除
		if v.show_type ~= Bargain_Logic.pdd_order_show_type_can_cut and v.show_type ~= Bargain_Logic.pdd_order_show_type_has_cut then
			log("[test]add BP_ARRAY_PDDSystem_BatchCacheBlackList id =" .. id);
			BP_ARRAY_PDDSystem_BatchCacheBlackList[id] = 1;
			if BargainSystemUI_StateInfo_Map[id] ~= nil then
				BargainSystemUI_StateInfo_Map[id] = nil;
			end
		else
			if 	BargainSystemUI_StateInfo_Map[id] == nil then
				BargainSystemUI_StateInfo_Map[id] = {};
			end
			BargainSystemUI_StateInfo_Map[id].id = v.brief.id;
			BargainSystemUI_StateInfo_Map[id].uid = v.brief.uid;
			BargainSystemUI_StateInfo_Map[id].show_type = v.show_type
			BargainSystemUI_StateInfo_Map[id].cur_price = v.brief.cur_price;
			BargainSystemUI_StateInfo_Map[id].helpnum = v.brief.helpnum;
			BargainSystemUI_StateInfo_Map[id].shopid = v.brief.shopid;
			BargainSystemUI_StateInfo_Map[id].createtime = v.brief.createtime;
			BargainSystemUI_StateInfo_Map[id].ori_price = v.brief.price;
			BargainSystemUI_StateInfo_Map[id].timeString = os.date("%Y-%m-%d",v.brief.createtime)
			BargainSystemUI_StateInfo_Map[id].buy_price = v.brief.buy_price;
            
			BargainSystemUI_StateInfo_Map[id].isCrops = tIsCorpsArray[uid];

		end

	end
	Bargain_System_UI.SortBargainStateList();
    log_tree("Bargain_Logic.on_pdd_bargain_batch_rsp BP_ARRAY_BargainSystemUI_StateInfo：" ,BP_ARRAY_BargainSystemUI_StateInfo);
    
	--刷新界面
    if Bargain_System_UI.bShowing == true then
        Bargain_System_UI.UpdateTime();
        BP_BargainSystemUI_MyTabReddot = PDD_System_UI.NeedShowBargainMyTabReddot();
        LuaClassObj.HandleUIMessage(bp_bargain, "UIShow");
    end
end

--分享给好友的发送方回包
function Bargain_Logic.pdd_bargain_fri_share_rsp(res,dst_uid) 
	log("Bargain_Logic.pdd_bargain_fri_share_rsp res:" .. res .. "  ||uid:" .. dst_uid);
	if res == 0 then
		Bargain_Detail_UI.OnSendFriendSuccess(dst_uid);
	end
end

--拉取好友订单列表
function Bargain_Logic.pdd_bargain_get_fri_share_req()
    log("Bargain_Logic.pdd_bargain_get_fri_share_req");
    NetUtil.SendPkg("pdd_bargain_get_fri_share_req");
end

--拉取好友订单列表回包
function Bargain_Logic.pdd_bargain_get_fri_share_rsp(res,msg_list)
	log_tree("Bargain_Logic.pdd_bargain_get_fri_share_rsp",msg_list);
	BP_ARRAY_PDDSystem_FriendShareOrderList = {};
	for k,v in pairs(msg_list) do
		local cur_orderid = v.other.cur_orderid;

        if BargainSystemUI_StateInfo_Map[cur_orderid] == nil then
            BargainSystemUI_StateInfo_Map[cur_orderid] = {};
        end
		
		BargainSystemUI_StateInfo_Map[cur_orderid].headicon_url = v.other.headicon_url;
		BargainSystemUI_StateInfo_Map[cur_orderid].name = v.other.name;
		BargainSystemUI_StateInfo_Map[cur_orderid].id = v.other.cur_orderid;
		BargainSystemUI_StateInfo_Map[cur_orderid].uid = v.other.owner_id;
		BargainSystemUI_StateInfo_Map[cur_orderid].itemid = v.other.item_id;
        BargainSystemUI_StateInfo_Map[cur_orderid].frame_level = v.other.frame_level;
		
		BP_ARRAY_PDDSystem_FriendShareOrderList[cur_orderid] = v.other.owner_id;
	end
	log_tree("Bargain_Logic.pdd_bargain_get_fri_share_rsp orderList",BP_ARRAY_PDDSystem_FriendShareOrderList);
    Bargain_Logic.pdd_bargain_batch_req();
end

--筛选订单列表并请求状态列表
function Bargain_Logic.pdd_bargain_batch_req()
    local list = {};
    local arrayIsEmpty = true;

    log_tree("BP_ARRAY_PDDSystem_BatchCacheBlackList",BP_ARRAY_PDDSystem_BatchCacheBlackList);

    if BP_ARRAY_PDDSystem_CorpsShareOrderList[1] == 0 then
        BP_ARRAY_PDDSystem_CorpsShareOrderList[1] = nil;
    end
    
    --剔除在黑名单上的订单
    for k,v in pairs(BP_ARRAY_PDDSystem_BatchCacheBlackList) do
        if BP_ARRAY_PDDSystem_FriendShareOrderList[k] ~= nil then
            BP_ARRAY_PDDSystem_FriendShareOrderList[k] = nil;
			if BargainSystemUI_StateInfo_Map[k] ~= nil then
				BargainSystemUI_StateInfo_Map[k] = nil;
			end
            log("friend del KEY : " .. k);
        end
        if BP_ARRAY_PDDSystem_CorpsShareOrderList[k] ~= nil then
            BP_ARRAY_PDDSystem_CorpsShareOrderList[k] = nil;
			if BargainSystemUI_StateInfo_Map[k] ~= nil then
				BargainSystemUI_StateInfo_Map[k] = nil;
			end
            log("corps del KEY : " .. k)
        end
    end

    for k,v in pairs(BP_ARRAY_PDDSystem_FriendShareOrderList) do
        if list[v] == nil then
            list[v] = {};
        end
        list[v][k] = true;
        arrayIsEmpty = false;
    end
    log_tree("BP_ARRAY_PDDSystem_CorpsShareOrderList",BP_ARRAY_PDDSystem_CorpsShareOrderList);
    
    for k,v in pairs(BP_ARRAY_PDDSystem_CorpsShareOrderList) do
        if list[v] == nil then
            list[v] = {};
        end
        list[v][k] = true;
        arrayIsEmpty = false;
    end

    if arrayIsEmpty == true then
        --没有需要更新的数据时，不发包给后台，直接显示数据
        log("Bargain_Logic.pdd_bargain_batch_req array is empty");
        BP_ARRAY_BargainSystemUI_StateInfo = {};
        BargainSystemUI_StateInfo_Map = {};
        
        --刷新界面
        if Bargain_System_UI.bShowing == true then
            Bargain_System_UI.UpdateTime();
            BP_BargainSystemUI_MyTabReddot = PDD_System_UI.NeedShowBargainMyTabReddot();
            LuaClassObj.HandleUIMessage(bp_bargain, "UIShow");
        end
        return
    end

    log_tree("Bargain_Logic.pdd_bargain_batch_req",list);
    NetUtil.SendPkg("pdd_bargain_batch_req",list);
end

function Bargain_Logic.OnGetNewMessage()
    log("Bargain_Logic.OnGetNewMessage");
    BP_PDDSystem_InviteRedDot = true;
    EventShowPDDSystemReddot();
    LobbyUI.UpdatePDDSystemReddot();
    LuaClassObj.HandleUIMessage(bp_bargain, "SetMyTabReddot");
end


s2c["pdd_bargain_create_order_rsp"] = Bargain_Logic.pdd_bargain_create_order_rsp;
s2c["pdd_bargain_history_orders_rsp"] = Bargain_Logic.pdd_bargain_history_orders_rsp;
s2c["pdd_bargain_do_help_rsp"] = Bargain_Logic.pdd_bargain_do_help_rsp;
s2c["pdd_bargain_notify"] = Bargain_Logic.pdd_bargain_notify;
s2c["pdd_bargain_buy_rsp"] = Bargain_Logic.pdd_bargain_buy_rsp;
s2c["pdd_bargain_chat_notify"] = Bargain_Logic.pdd_bargain_chat_notify;
s2c["pdd_bargain_order_rsp"] = Bargain_Logic.pdd_bargain_order_rsp;
s2c["pdd_bargain_redpoint_notify"] = Bargain_Logic.pdd_bargain_redpoint_notify;
s2c["pdd_bargain_batch_rsp"] = Bargain_Logic.pdd_bargain_batch_rsp;--批量拉取状态缓存
s2c["pdd_bargain_fri_share_rsp"] = Bargain_Logic.pdd_bargain_fri_share_rsp;--发给好友回包
s2c["pdd_bargain_get_fri_share_rsp"] = Bargain_Logic.pdd_bargain_get_fri_share_rsp;--批量拉取好友订单
s2c["pdd_bargain_new_fri_share_notify"] = Bargain_Logic.OnGetNewMessage;--分享列表红点通知
