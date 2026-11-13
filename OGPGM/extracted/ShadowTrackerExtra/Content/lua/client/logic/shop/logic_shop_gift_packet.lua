ShopGiftPacketLogic = ShopGiftPacketLogic or
{
}

--赠送礼物
function ShopGiftPacketLogic.SendGift(touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, askIndex)
	--log_tree("ShopGiftPacketLogic.SendGift=",{touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion})
    if buyitem == nil then
        return;
    end

    if buyitem.num == nil then
        buyitem.num = 1;
    end
    buyitem.first_money = 1;
    LuaClassObj.HandleUIMessage(bp_shop_gift_packet, "HideUI");
    if askIndex > 0 then
        NetUtil.SendPriorityPkg(false, "market_give_gift_rsp", "market_give_gift_req", touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, askIndex);
    else
        NetUtil.SendPriorityPkg(false, "market_give_gift_rsp", "market_give_gift_req", touid, buyitem, CheckBoxCtrlIdx, msg, clientVersion, nil);
    end
end

--向别人索要礼物
function ShopGiftPacketLogic.RequireGift(touid, shopid, style, msg)
	--log_tree("ShopGiftPacketLogic.RequireGift=",{touid, shopid, style, msg})
	NetUtil.SendPriorityPkg(false, "market_ask_for_rsp", "market_ask_for_req", touid, shopid, style, msg);
end

--拉取礼物中心记录
function ShopGiftPacketLogic.SendGetGiftMsgList(msgType)
	log("ShopGiftPacketLogic.SendGetGiftMsgList msgType:" .. msgType)
	NetUtil.SendPriorityPkg(false, "market_get_giftmsg_rsp", "market_get_giftmsg_req", msgType);
end

function ShopGiftPacketLogic.on_market_give_gift_rsp(res, askIndex)
    log("ShopGiftPacketLogic.on_market_give_gift_rsp " )
	if res == "ok" then
		local msg = string.format(DataMgr.GetMsgByID(501030), BP_STRUCT_Shop_GiftPack_Item_Info.pruduct_name, BP_STRUCT_Shop_GiftPack_Item_Info.toUserName);
        --暂时屏蔽平台好友推送
        -- if FriendSystem.IsPlatFriend(BP_STRUCT_Shop_GiftPack_Item_Info.toUserID) == true then
        --     CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), msg, ShopGiftPacketUI.GiftPackTellFriendSend, ShopGiftPacketUI.HideUI, "通知好友", "确定");
        -- else
            CommonMessageBoxUI:ShowPanel(1, DataMgr.GetMsgByID(102012), msg, ShopGiftPacketUI.HideUI, FuncUtil.GetLocalizeResStr("110036"));
        -- end
        if askIndex ~= nil and askIndex > 0 then
            NetUtil.SendPkg("market_get_giftmsg_req", 12);
        end
    else
		log("market_give_gift_rsp failed " .. res);
        -- if res == 501037 then
        --     local level = DataMgr.GetSystemConfig("MarketGiftSendLevelLimit");
        --     local datatable = Client.GetTableData("LocalizeRes", "501037")
        --     if datatable ~= nil then
        --         local tips = datatable.TextValue
        --         tips = string.format(tips, level)
        --         PopUpNoticeUI.ShowNewNotice(tips)
        --     end
        -- else
            DataMgr.ShowNoticeByID(res);
        -- end
    end
end

function ShopGiftPacketLogic.on_market_ask_for_rsp(res)
	if res == "ok" then
        if FriendSystem.IsPlatFriend(BP_STRUCT_Shop_GiftPack_Item_Info.toUserID) == true then
            -- CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(501028), ShopGiftPacketUI.GiftPackTellFriendBeg, ShopGiftPacketUI.HideUI, "通知好友", FuncUtil.GetLocalizeResStr("110036"));
            CommonMessageBoxUI:ShowPanel(2, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(501028), ShopGiftPacketUI.GiftPackTellFriendBeg, ShopGiftPacketUI.HideUI, "", FuncUtil.GetLocalizeResStr("110036"));
        else
            CommonMessageBoxUI:ShowPanel(1, DataMgr.GetMsgByID(102012), DataMgr.GetMsgByID(501028), ShopGiftPacketUI.HideUI, FuncUtil.GetLocalizeResStr("110036"));
        end
        -- 刷新索取请求次数
        LogicGiftShop.market_get_askinfo_req(false)
    else
		log("market_ask_for_rsp failed " .. res);
        DataMgr.ShowNoticeByID(res);
    end
    LuaClassObj.HandleUIMessage(bp_shop_gift_packet, "HideUI");
end

function ShopGiftPacketLogic.on_market_get_giftmsg_rsp(res, msgtype, msglist)
	--log("on_market_get_giftmsg_rsp res = "..res.." msgtype = "..msgtype)
    --log_tree("msglist = ", msglist)
    ShopGiftMsgCenter.recvGiftList(res, msgtype, msglist)
end

--设置不接收索取消息
function ShopGiftPacketLogic.SendMarketRefuseAskForReq(flag)
    log("ShopGiftPacketLogic.SendMarketRefuseAskForReq "..(flag and "true" or "false"))
	NetUtil.SendPriorityPkg(false, "market_refuse_ask_for_rsp", "market_refuse_ask_for_req", flag);
end

function ShopGiftPacketLogic.on_market_refuse_ask_for_rsp(flag)
    log("on_market_refuse_ask_for_rsp "..flag)
end

--领取别人赠送的礼物
function ShopGiftPacketLogic.SendMarketGiftTakeReq(indexid)
	log("ShopGiftPacketLogic.SendMarketGiftTakeReq:"..indexid)
	NetUtil.SendPriorityPkg(false, "market_gift_take_rsp", "market_gift_take_req", indexid);
end

function ShopGiftPacketLogic.on_market_gift_take_rsp(res, index)
    log("ShopGiftPacketLogic.on_market_gift_take_rsp "..res)
    if res == "ok" then
        ShopGiftMsgCenter.OnGetGift(res, index)
    else
        DataMgr.ShowNoticeByID(res);
    end
end

--一键领取别人赠送的礼物
function ShopGiftPacketLogic.SendMarketGiftAllTakeReq()
    log("ShopGiftPacketLogic.SendMarketGiftAllTakeReq:");
    NetUtil.SendPriorityPkg(false, "market_gift_all_take_rsp", "market_gift_all_take_req");
end

--indexList:  {index1, index2,...}
function ShopGiftPacketLogic.on_market_gift_all_take_rsp(msg, indexList)
    if msg ~= "ok" and msg ~="ver" then
        log("ShopGiftPacketLogic.on_market_gift_all_take_rsp: msg "..tostring(msg));
        DataMgr.ShowNoticeByID(msg);
        return
    end
    --log_tree("on_market_gift_all_take_rsp.indexList:", indexList);
    if next(table) ~= nil then
        ShopGiftMsgCenter.OnGetAllGift(indexList);
    end
    if msg == "ver" then
        --DataMgr.ShowNoticeByID("6312")
    end
end

--一键删除已领取的礼物
function ShopGiftPacketLogic.SendMarketDelAllGiftMsgReq()
    log("ShopGiftPacketLogic.SendMarketGiftAllTakeReq:");
    NetUtil.SendPriorityPkg(false, "market_del_all_giftmsg_rsp", "market_del_all_giftmsg_req");
end

--del_msg:  {1: {msgtype, index}, 2： {msgtype, index}}
function ShopGiftPacketLogic.on_market_del_all_giftmsg_rsp(msg, del_msg)
    log("on_market_del_all_giftmsg_rsp.msg:"..tostring(msg));
    log_tree("on_market_del_all_giftmsg_rsp.del_msg:", del_msg);
    if msg == "ok" then
        ShopGiftMsgCenter.OnDelAllGifts(del_msg);
    else
        DataMgr.ShowNoticeByID(msg);
    end
end

--一键已读
function ShopGiftPacketLogic.SendMarketMsgAllSetReadReq()
    log("SendMarketMsgAllSetReadReq");
    NetUtil.SendPriorityPkg(false, "market_msg_all_setread_rsp", "market_msg_all_setread_req");
end

--red_msg:  {1: {msgtype, index}, 2： {msgtype, index}}
function ShopGiftPacketLogic.on_market_msg_all_setread_rsp(list)
    --log("on_market_msg_all_setread_rsp msg = "..tostring(msg)..", list = "..tostring(msg));
    --log_tree("ShopGiftPacketLogic.on_market_msg_all_setread_rsp msg = ", msg);
    --log_tree("ShopGiftPacketLogic.on_market_msg_all_setread_rsp list = ", list);
    for i = 1, #list do
        ShopGiftMsgCenter.OnGetSetRead(list[i][1], list[i][2]);
    end
end

--发送感谢信
function ShopGiftPacketLogic.SendMarketSendThankReq(touid, item, style, msg)
	log("ShopGiftPacketLogic.SendMarketSendThankReq")
	NetUtil.SendPriorityPkg(false, "market_send_thank_rsp", "market_send_thank_req", touid, item, style, msg)
end

function ShopGiftPacketLogic.on_market_send_thank_rsp(res)
    log("ShopGiftPacketLogic.on_market_send_thank_rsp:"..res)
end

--设置单个消息已读
function ShopGiftPacketLogic.SendMarketMsgSetReadReq(msgtype, index, flag)
    --log_tree("ShopGiftPacketLogic.SendMarketMsgSetReadReq:",{msgtype, index, flag})
    NetUtil.SendPriorityPkg(false, "market_msg_setread_rsp", "market_msg_setread_req", msgtype, index, flag);
end

function ShopGiftPacketLogic.on_market_msg_setread_rsp(res, msgtype, index)
    --log_tree("ShopGiftPacketLogic.on_market_msg_setread_rsp:",{res, msgtype, index})
    if res ~= "ok" then
        return
    end
    ShopGiftMsgCenter.OnGetSetRead(msgtype, index)
end

--赠礼/索要/感谢信在线通知
function ShopGiftPacketLogic.on_market_give_gift_notify(info)
    --log_tree("ShopGiftPacketLogic.on_market_give_gift_notify:",{info})
	NetUtil.SendPkg("market_get_giftmsg_req", 11);
end
function ShopGiftPacketLogic.on_market_ask_for_notify(info)
    --log_tree("ShopGiftPacketLogic.on_market_ask_for_notify:",{info})
	NetUtil.SendPkg("market_get_giftmsg_req", 12);
end
function ShopGiftPacketLogic.on_market_send_thank_notify(info)
    --log_tree("ShopGiftPacketLogic.on_market_send_thank_notify:",{info})
end

--请求每日赠送次数
function ShopGiftPacketLogic.market_gift_give_count_req()
    NetUtil.SendPkg("market_gift_give_count_req")
end

function ShopGiftPacketLogic.market_gift_give_count_rsp(cur_count, max_count)
    BP_SHOPGIFT_SEND_TIMES = cur_count;
    BP_SHOPGIFT_SEND_MAX_TIMES = max_count;
    log("ShopGiftPacketLogic.market_gift_give_count_rsp .. cur_count:"  .. cur_count .. ", max_count:" .. max_count );
end

s2c["market_give_gift_rsp"] = ShopGiftPacketLogic.on_market_give_gift_rsp;
s2c["market_ask_for_rsp"] = ShopGiftPacketLogic.on_market_ask_for_rsp;
s2c["market_get_giftmsg_rsp"] = ShopGiftPacketLogic.on_market_get_giftmsg_rsp;
s2c["market_refuse_ask_for_rsp"] = ShopGiftPacketLogic.on_market_refuse_ask_for_rsp;
s2c["market_gift_take_rsp"] = ShopGiftPacketLogic.on_market_gift_take_rsp;
s2c["market_send_thank_rsp"] = ShopGiftPacketLogic.on_market_send_thank_rsp;
s2c["market_msg_setread_rsp"] = ShopGiftPacketLogic.on_market_msg_setread_rsp;

s2c["market_give_gift_notify"] = ShopGiftPacketLogic.on_market_give_gift_notify;
s2c["market_ask_for_notify"] = ShopGiftPacketLogic.on_market_ask_for_notify;
s2c["market_send_thank_notify"] = ShopGiftPacketLogic.on_market_send_thank_notify;

s2c["market_gift_give_count_rsp"] = ShopGiftPacketLogic.market_gift_give_count_rsp;
s2c["market_del_all_giftmsg_rsp"] = ShopGiftPacketLogic.on_market_del_all_giftmsg_rsp;
s2c["market_gift_all_take_rsp"] = ShopGiftPacketLogic.on_market_gift_all_take_rsp;
s2c["market_msg_all_setread_rsp"] = ShopGiftPacketLogic.on_market_msg_all_setread_rsp;
