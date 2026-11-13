--礼物消息中心
ShopGiftMsgCenter = ShopGiftMsgCenter or {
    isShowing = false,
    tmpData = {},
    thanks = {},
    isOnlyShow = true,
}

BP_STRUCT_Shop_GiftRecv =
{
    uid = "",
    name = "",
    nickName = "",
    iconUrl = "",
    gender = 1,
    level = 1,
    avatarBox = 1,
    intimacy = 0,
    relation = 0,
    date = "",
    shopid = 0,
    item = 0,
    give_type = "",
    read = 0,
    style = 0,
    message = "",   --列表展示文字
    notice = "",    --玩家自定义消息
    index = 0,
    isFetched = false,
    inited = false,
    time = 0,
    roleNation = "",
    alias_id = 0,
    alias_title = "",
    alias_nation = "",
    colorID = 0,
    patternID = 0,
    valid_hours= 0, --物品有效时间
};

BP_STRUCT_Shop_GiftBeg =
{
    uid = "",
    name = "",
    nickName = "",
    iconUrl = "",
    gender = 1,
    level = 1,
    avatarBox = 1,
    intimacy = 0,
    relation = 0,
    date = "",
    shopid = 0,
    item = 0,
    give_type = "",
    read = 0,
    style = 0,
    message = "",
    notice = "",
    index = 0,
    gived = 0,
    inited = false,
    time = 0,
    roleNation = "",
    alias_id = 0,
    alias_title = "",
    alias_nation = "",
};

BP_STRUCT_Shop_GiftSend =
{
    uid = "",
    name = "",
    nickName = "",
    iconUrl = "",
    gender = 1,
    level = 1,
    avatarBox = 1,
    intimacy = 0,
    relation = 0,
    date = "",
    shopid = 0,
    item = 0,
    give_type = "",
    read = 0,
    style = 0,
    message = "",
    index = 0,
    inited = false,
    time = 0,
    roleNation = "",
    alias_id = 0,
    alias_title = "",
    alias_nation = "",
};

--收到了礼物列表
BP_ARRAY_Shop_GiftRecvList =
{
	BP_STRUCT_Shop_GiftRecv=_G.BP_STRUCT_Shop_GiftRecv,
};

--索要礼物列表
BP_ARRAY_Shop_GiftBegList =
{
	BP_STRUCT_Shop_GiftBeg=_G.BP_STRUCT_Shop_GiftBeg,
};

--赠送礼物列表
BP_ARRAY_Shop_GiftSendList =
{
	BP_STRUCT_Shop_GiftSend=_G.BP_STRUCT_Shop_GiftSend,
};

-- 要刷新的Item索引
BP_ARRAY_Shop_GiftRefreshItemIndexList=
{
    index = 1,
}

--0:收礼 1:索要 2:赠送 3:感谢信
BP_Gift_MsgCenter_TabType = 0;
--0:允许别人索要 1:拒绝索要
BP_Gift_MsgCenter_RefuseBeg = 0;
--当前点击列索引
BP_Gift_MsgCenter_ClickIndex = 1;
--当前要拉取玩家信息的UID
BP_Gift_MsgCenter_Uid = "";
BP_Gift_MsgCenter_MyName = "";
BP_Gift_MsgCenter_MyGender = 1;
BP_Gift_MsgCenter_RefuseBeg = false;
BP_Gift_MsgCenter_ClickUid = "";
BP_Gift_MsgCenter_IsPlatformFriend = false;


local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end

--注册Widget
function bp_shop_gift_msgcenter_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_shop_gift_msgcenter,
		{{Path="/Game/UMG/UI_Logic/Shop/Shop_Gift/Shop_Getgift_BP.Shop_Getgift_BP_C", Container="Default", ZOrder=BP_ENUM_UI_MAIL_ZORDER},
         {Path="/Game/UMG/UI_Logic/Shop/Shop_Gift/Shop_Getgift_Box_BP.Shop_Getgift_Box_BP_C", Container="Default", ZOrder=BP_ENUM_UI_MAIL_ZORDER}},
		{"Lobby"},
		false,
		true,
		true
	);
end

function bp_shop_gift_msgcenter_OnModeSwitched(gamestatus)
	log("bp_shop_gift_msgcenter_OnModeSwitched gamestatus = " .. gamestatus);
    status = string.lower(gamestatus);
	if status == "login" then
        ShopGiftMsgCenter.Release()
    elseif status == "lobby" then
        ShopGiftPacketLogic.market_gift_give_count_req();
	end
end

function ShopGiftMsgCenter.Show()
    log("ShopGiftMsgCenter.Show")
    ShopGiftMsgCenter.isShowing = true
	LuaClassObj.HandleDynamicCreation(bp_shop_gift_msgcenter);
    BP_Gift_MsgCenter_MyName = DataMgr.roleData.nickName;
    BP_Gift_MsgCenter_MyGender = DataMgr.roleData.gender;
    LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "UIShow");
    EventGiftMsgCenterClickRecv()
    EventSystem:registEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_UPDATE, ShopGiftMsgCenter.UpdateFriendIntimacy);

    ShopGiftMsgCenter.ChangeIsOnlyShow(true)
    UIManager.Show(eUIType.eShopGiftMsgCenter)
end

function ShopGiftMsgCenter.Hide()
    log("ShopGiftMsgCenter.Hide")
    ShopGiftMsgCenter.isShowing = false
    LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "UIHide");
    EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_UPDATE, ShopGiftMsgCenter.UpdateFriendIntimacy);
    UIManager.Hide(eUIType.eShopGiftMsgCenter)
end

function ShopGiftMsgCenter.Init()
    ShopGiftMsgCenter.isShowing = false

end

function ShopGiftMsgCenter.Release()
    ShopGiftMsgCenter.isShowing = false;
    ShopGiftMsgCenter.thanks = {};
    BP_ARRAY_Shop_GiftRecvList = {};
    BP_ARRAY_Shop_GiftBegList ={};
    BP_ARRAY_Shop_GiftSendList ={};
    EventSystem:unregistEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_INTIMACY_UPDATE, ShopGiftMsgCenter.UpdateFriendIntimacy);
end

function ShopGiftMsgCenter.UpdateFriendIntimacy (evenType, eventID, friUid, newIntimacy)
    log("ShopGiftMsgCenter.UpdateFriendIntimacy")
    local tmplist2 = {};
    if BP_Gift_MsgCenter_TabType == 0 then
        tmplist2 = BP_ARRAY_Shop_GiftRecvList
    elseif BP_Gift_MsgCenter_TabType == 1 then
        tmplist2 =  BP_ARRAY_Shop_GiftBegList
    elseif BP_Gift_MsgCenter_TabType == 2 then
        tmplist2 =  BP_ARRAY_Shop_GiftSendList
    end

    for kk,vv in pairs(tmplist2) do
        if tonumber(vv.uid) == tonumber(friUid) then
            local friendData = FriendSystem.GetFriendDataByGID(tonumber(friUid));
            if(friendData ~= nil and friendData.intimacy ~= nil) then
                vv.intimacy = friendData.intimacy
            else
                vv.intimacy = -1
            end
            vv.relation = FriendSystem.getRelationByGid(tonumber(friUid))

            local hasKK = false;
            for kkk,vvvv in ipairs(BP_ARRAY_Shop_GiftRefreshItemIndexList) do
                if vvvv == kk then
                    hasKK = true;
                end
            end
            if hasKK == false then
                table.insert(BP_ARRAY_Shop_GiftRefreshItemIndexList, kk);
            end
        end
    end

    if ShopGiftMsgCenter.isShowing then
        LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "DelayRefreshItems");
    end
end


function ShopGiftMsgCenter.GetRandomThanksMsg()
    log("ShopGiftMsgCenter.GetRandomThanksMsg")
    local msg = {
        Client.GetTableData("LocalizeRes",501021).TextValue,
        Client.GetTableData("LocalizeRes",501022).TextValue,
        Client.GetTableData("LocalizeRes",501023).TextValue,
    }
    return msg[math.random(1,#msg)];
end

function ShopGiftMsgCenter.SortGiftRecvList(tmplist)
    local list1 = {}
    local list2 = {}
    for i = 1, #tmplist do
        local tmp = tmplist[i]
        if tmp.isFetched == false then
            table.insert(list1, tmp);
        else
            table.insert(list2, tmp);
        end
    end
    table.sort(list1, function(a,b)
         return a.time>b.time end)
    table.sort(list2, function(a,b) return a.time>b.time end)
    BP_ARRAY_Shop_GiftRecvList = {}
    for i,v in ipairs(list1) do
        table.insert(BP_ARRAY_Shop_GiftRecvList, v)
    end
    for i,v in ipairs(list2) do
        table.insert(BP_ARRAY_Shop_GiftRecvList, v)
    end
end

function ShopGiftMsgCenter.SortGiftBegList(tmplist)
    local list1 = {}
    local list2 = {}
    for i = 1, #tmplist do
        local tmp = tmplist[i]
        if tmp.read == 0 then
            table.insert(list1, tmp);
        else
            table.insert(list2, tmp);
        end
    end
    table.sort(list1, function(a,b) return a.time>b.time end)
    table.sort(list2, function(a,b) return a.time>b.time end)
    BP_ARRAY_Shop_GiftBegList = {}
    for i,v in ipairs(list1) do
        table.insert(BP_ARRAY_Shop_GiftBegList, v)
    end
    for i,v in ipairs(list2) do
        table.insert(BP_ARRAY_Shop_GiftBegList, v)
    end
end

function ShopGiftMsgCenter.SortGiftSendList()
    table.sort(BP_ARRAY_Shop_GiftSendList, function(a,b) return a.time>b.time end)
end

function ShopGiftMsgCenter.GetShopItemName(itemid, giveType, colorID, patternID)
    colorID = colorID or 0;
    patternID = patternID or 0;
    if giveType == "item" then
        local itemDataCfg = Client.GetTableData("Item", itemid);
        if itemDataCfg ~= nil then
            return FuncUtil.GetItemName(itemDataCfg.ItemName, colorID, patternID)
        end
    elseif giveType == "suit" then
        local itemDataCfg = Client.GetTableData("MarketSuit", itemid);
        if itemDataCfg ~= nil then
            return FuncUtil.GetItemName(itemDataCfg.SuitName, colorID, patternID)
        end
    end
    return ""
end

function ShopGiftMsgCenter.CheckLobbyMenuOpen(menuId)
    if LobbySystem.LobbyMenuOpenStatus[menuId] == nil then
        return true
    end

    if LobbySystem.LobbyMenuOpenStatus[menuId].is_open == 0 then
        return false
    else
        return true
    end
end

function ShopGiftMsgCenter.GetSuitItemList(itemid, giveType, colorID, patternID, valid_hours)
    local items = {}
    colorID = colorID or 0;
    patternID = patternID or 0;
    valid_hours = valid_hours or 0;
    if giveType ~= "suit" then
        table.insert(items,{res_id = itemid, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
        return items;
    end
    local dataCfg = Client.GetTableData("MarketSuit", itemid);
    if dataCfg.CoatID > 0 then
        table.insert(items,{res_id = dataCfg.CoatID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
    end
    if dataCfg.PantsID > 0 then
        table.insert(items,{res_id = dataCfg.PantsID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
    end
    if dataCfg.CapID > 0 then
        table.insert(items,{res_id = dataCfg.CapID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
    end
    if dataCfg.ShoeID > 0 then
        table.insert(items,{res_id = dataCfg.ShoeID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
    end
    if dataCfg.MaskID > 0 then
        table.insert(items,{res_id = dataCfg.MaskID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
    end
    return items
end

function ShopGiftMsgCenter.GetSuitItemListByItemList(itemList)
    local items = {}
    for i = 1, #itemList do
        local itemid = itemList[i].item;
        local giveType = itemList[i].give_type;
        local colorID = itemList[i].colorID or 0;
        local patternID = itemList[i].patternID or 0;
        local valid_hours = itemList[i].valid_hours or 0;
        if giveType ~= "suit" then
            table.insert(items,{res_id = itemid, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
        else
            local dataCfg = Client.GetTableData("MarketSuit", itemid);
            if dataCfg.CoatID > 0 then
                table.insert(items,{res_id = dataCfg.CoatID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
            end
            if dataCfg.PantsID > 0 then
                table.insert(items,{res_id = dataCfg.PantsID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
            end
            if dataCfg.CapID > 0 then
                table.insert(items,{res_id = dataCfg.CapID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
            end
            if dataCfg.ShoeID > 0 then
                table.insert(items,{res_id = dataCfg.ShoeID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
            end
            if dataCfg.MaskID > 0 then
                table.insert(items,{res_id = dataCfg.MaskID, count = 1, color_id = colorID, pattern_id = patternID, valid_hours = valid_hours});
            end
        end
    end
    return items
end

function ShopGiftMsgCenter.recvGiftList(res, msgtype, msglist)
    log("ShopGiftMsgCenter.recvGiftList res = "..res)
    -- log_tree("recvGiftList",msglist)
    if res ~= "ok" then
        return
    end

    if msgtype == 11 then
        local tmplist = {}
        for i, v in pairs(msglist) do
            local data = v
            if data ~= nil then
                local alias = ProfileMgr.GetRoleAliasByUid(data.sender);
                local recv = {
                    uid = tostring(data.sender),
                    name = "",
                    nickName = "",
                    iconUrl = "",
                    gender = 1,
                    level = 1,
                    avatarBox = 1,
                    intimacy = 0,
                    relation = 0,
                    time = data.time or 0,
                    date = "",
                    shopid = data.shopid,
                    item = data.itemid,
                    give_type = data.give_type,
                    read = data.read or 0,
                    style = data.style,
                    message = "",
                    notice = data.msg,
                    index = i,
                    isFetched = (data.fetch ~= 0),
                    inited = false,
                    roleNation = ProfileMgr.GetRoleNationByUid(data.sender),
                    alias_id = alias.id,
                    alias_title = alias.title,
                    alias_nation = alias.nation,
                    colorID = data.color,
                    patternID = data.pattern,
                    valid_hours = data.valid_hours,
                }
                log("gift center 11 rolenation = " ..recv.roleNation);
                local date = os.date("*t", data.time)
                recv.date = string.format(Client.GetTableData("LocalizeRes",501005).TextValue, date.month, date.day);
                if recv.isFetched then
                    local text = FuncUtil.GetLocalizeResStr(501002)
                    recv.message = string.format(text, "", ShopGiftMsgCenter.GetShopItemName(recv.item, recv.give_type, recv.colorID, recv.patternID))
                else
                    recv.message = FuncUtil.GetLocalizeResStr(501001)
                end
                table.insert(tmplist,recv);
            end
        end
        ShopGiftMsgCenter.SortGiftRecvList(tmplist)
        ShopGiftMsgCenter.UpdateRedPoint()
        -- log_tree("BP_ARRAY_Shop_GiftRecvList = ",BP_ARRAY_Shop_GiftRecvList)
    elseif msgtype == 12 then
        BP_ARRAY_Shop_GiftBegList = {}
        BP_Gift_MsgCenter_RefuseBeg = msglist["refuse_askfor"]
        local tmplist = {}
        for i, v in pairs(msglist) do
            local data = v
            if data ~= nil then
                local alias = ProfileMgr.GetRoleAliasByUid(data.sender);
                local recv = {
                    uid = tostring(data.sender),
                    name = "",
                    nickName = "",
                    iconUrl = "",
                    gender = 1,
                    level = 1,
                    avatarBox = 1,
                    intimacy = 0,
                    relation = 0,
                    time = data.time or 0,
                    date = "",
                    shopid = data.shopid,
                    item = data.itemid,
                    give_type = data.give_type,
                    read = data.read or 0,
                    style = data.style,
                    message = "",
                    notice = data.msg,
                    index = i,
                    gived = data.gived,
                    inited = false,
                    roleNation = ProfileMgr.GetRoleNationByUid(data.sender),
                    alias_id = alias.id,
                    alias_title = alias.title,
                    alias_nation = alias.nation,
                    valid_hours = data.valid_hours,
                };
                log("gift center 12 rolenation = " ..recv.roleNation);

                local date = os.date("*t", data.time)
                recv.date = string.format(Client.GetTableData("LocalizeRes",501005).TextValue, date.month, date.day);
                local text = FuncUtil.GetLocalizeResStr(501003)
                recv.message = string.format(text, ShopGiftMsgCenter.GetShopItemName(recv.item, recv.give_type))
                table.insert(tmplist, recv);
            end
        end
        ShopGiftMsgCenter.SortGiftBegList(tmplist)
        ShopGiftMsgCenter.UpdateRedPoint()
        --log_tree("BP_ARRAY_Shop_GiftBegList = ",BP_ARRAY_Shop_GiftBegList)
    elseif msgtype == 13 then
        BP_ARRAY_Shop_GiftSendList = {}
        local tmplist = {}
        for i, v in pairs(msglist) do
            local data = v
            local alias = ProfileMgr.GetRoleAliasByUid(data.receiver);
            if data ~= nil then
                local recv = {
                    uid = tostring(data.receiver),
                    name = "",
                    nickName = "",
                    iconUrl = "",
                    gender = 1,
                    level = 1,
                    avatarBox = 1,
                    intimacy = 0,
                    relation = 0,
                    time = data.time,
                    date = "",
                    shopid = data.shopid,
                    item = data.itemid,
                    give_type = data.give_type,
                    read = data.read,
                    style = data.style,
                    message = data.msg,
                    index = i,
                    inited = false,
                    roleNation = ProfileMgr.GetRoleNationByUid(data.receiver),
                    alias_id = alias.id,
                    alias_title = alias.title,
                    alias_nation = alias.nation,
                    valid_hours = data.valid_hours,
                };
                log("gift center 13 rolenation = " ..recv.roleNation);
                local date = os.date("*t", data.time)
                recv.date = string.format(Client.GetTableData("LocalizeRes",501005).TextValue, date.month, date.day);
                local text = FuncUtil.GetLocalizeResStr(501004)
                recv.message = string.format(text, ShopGiftMsgCenter.GetShopItemName(recv.item, recv.give_type))
                table.insert(BP_ARRAY_Shop_GiftSendList, recv);
            end
        end

        ShopGiftMsgCenter.SortGiftSendList()
        --log_tree("BP_ARRAY_Shop_GiftSendList = ",BP_ARRAY_Shop_GiftSendList)
    end

    if ShopGiftMsgCenter.isShowing then
        LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    end
end

function ShopGiftMsgCenter.GetRedPointCount()
    local count = 0
    for i,v in ipairs(BP_ARRAY_Shop_GiftRecvList) do
        if(v.read == 0) then
            count = count + 1
        end
    end
    for i,v in ipairs(BP_ARRAY_Shop_GiftBegList) do
        if(v.read == 0) then
            count = count + 1
        end
    end
    return count
end

function ShopGiftMsgCenter.GetName(profileInfo)
    --log_tree("ShopGiftMsgCenter.GetName =", profileInfo)
    local friendData = FriendSystem.GetFriendDataByGID(profileInfo.uid);
    local tagName = "";
    if friendData ~= nil then
        if friendData.remarks_name and friendData.remarks_name ~= "" then
            tagName = friendData.remarks_name;
        elseif profileInfo.platName and profileInfo.platName ~= "" then
            tagName = profileInfo.platName;
        end
    end

    local name = profileInfo.nickName;
    if FriendSystem.IsPlatFriend(profileInfo.uid) then
        if tagName ~= "" then
            tagName = FuncUtil.SubString(tagName, 1, 15)
            name = string.format("%s(%s)", profileInfo.nickName, tagName);
        end
    end
    return name, profileInfo.nickName, tagName;
end

function ShopGiftMsgCenter.UpdateListData(typeTab, profileList)
    --log_tree("profileList = ",profileList)
    -- BP_ARRAY_Shop_GiftRefreshItemIndexList = {};
    local tmplist = {};
    if typeTab == 0 then
        tmplist = BP_ARRAY_Shop_GiftRecvList
    elseif typeTab == 1 then
        tmplist =  BP_ARRAY_Shop_GiftBegList
    elseif typeTab == 2 then
        tmplist =  BP_ARRAY_Shop_GiftSendList
    end
	for k,v in pairs(profileList) do
        for kk,vv in pairs(tmplist) do
            if tonumber(vv.uid) == tonumber(v.uid) then
                vv.name,vv.nickName,vv.platName = ShopGiftMsgCenter.GetName(v)
                vv.level = v.level
                vv.iconUrl = v.picUrl
                vv.vipLevel = v.vipLevel
                vv.gender = v.sex
                vv.avatarBox = v.cur_avatar_box_id
                vv.inited = true
                local friendData = FriendSystem.GetFriendDataByGID(tonumber(v.uid));
                if(friendData ~= nil and friendData.intimacy ~= nil) then
                    vv.intimacy = friendData.intimacy
                else
                    vv.intimacy = -1
                end
                vv.relation = FriendSystem.getRelationByGid(tonumber(v.uid))

                local hasKK = false;
                for kkk,vvvv in ipairs(BP_ARRAY_Shop_GiftRefreshItemIndexList) do
                    if vvvv == kk then
                        hasKK = true;
                    end
                end
                if hasKK == false then
                    table.insert(BP_ARRAY_Shop_GiftRefreshItemIndexList, kk);
                end
            end
        end
    end
end

--更新玩家信息
function ShopGiftMsgCenter.OnGetPlayerInfoByProfile(profileList)
    --log_tree("profileList = " , profileList);
	ShopGiftMsgCenter.UpdateListData(BP_Gift_MsgCenter_TabType, profileList)
    -- ShopGiftMsgCenter.UpdateListData(0, profileList)
	-- ShopGiftMsgCenter.UpdateListData(1, profileList)
	-- ShopGiftMsgCenter.UpdateListData(2, profileList)
	-- ShopGiftMsgCenter.UpdateListData(3, profileList)
    if ShopGiftMsgCenter.isShowing then
        LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "DelayRefreshItems");
        -- LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    end
end

function ShopGiftMsgCenter.GetIndexDataList(list, index)
    for i,v in ipairs(list) do
        if(v.index == index) then
            return v
        end
    end
    return nil
end

function ShopGiftMsgCenter.OnDelAllGifts(del_msg_list)
    local del_map = {
        [11] = {recordList = {}, targetList = BP_ARRAY_Shop_GiftRecvList},
        [12] = {recordList = {}, targetList = BP_ARRAY_Shop_GiftBegList},
        [13] = {recordList = {}, targetList = BP_ARRAY_Shop_GiftSendList}
    };
    for i = 1, #del_msg_list do
        local msgtype = del_msg_list[i][1];
        local index = del_msg_list[i][2];
        local recordList = del_map[msgtype].recordList;
        recordList[#recordList + 1] = index;
    end
    for msgtype, v in pairs(del_map) do
        local del_gifts = {};
        for i = 1, #v.recordList do
            local gift = ShopGiftMsgCenter.GetIndexDataList(v.targetList, v.recordList[i]);
            if gift then
                del_gifts[#del_gifts + 1] = gift;
            end
        end
        for i = 1, #del_gifts do
            for j = 1, #v.targetList do
                if v.targetList[j] == del_gifts[i] then
                    table.remove(v.targetList, j);
                    break;
                end
            end
        end
    end

    if ShopGiftMsgCenter.isShowing then
        LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    end
end

--设置消息已读(去掉红点)
function ShopGiftMsgCenter.OnGetSetRead(msgtype, index)
    if msgtype == 11 then
        if index <= #BP_ARRAY_Shop_GiftRecvList then
            ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftRecvList, index).read = 1
            ShopGiftMsgCenter.SortGiftRecvList(BP_ARRAY_Shop_GiftRecvList)
        end
    elseif msgtype == 12 then
        if index <= #BP_ARRAY_Shop_GiftBegList then
            ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftBegList, index).read = 1
            ShopGiftMsgCenter.SortGiftBegList(BP_ARRAY_Shop_GiftBegList)
        end
    elseif msgtype == 13 then
        if index <= #BP_ARRAY_Shop_GiftSendList then
            ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftSendList, index).read = 1
            ShopGiftMsgCenter.SortGiftSendList()
        end
    end

    if ShopGiftMsgCenter.isShowing then
        LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    end
    ShopGiftMsgCenter.UpdateRedPoint()
end

--更新红点
function ShopGiftMsgCenter.UpdateRedPoint()
    MailUI.Mail_CalcUnreadNum()
    MailSystem.CheckNotRead()
	LuaClassObj.HandleUIMessage(bp_mail, "UpdateTabRedpoint");
end

--领取礼物回调
function ShopGiftMsgCenter.OnGetGift(res, index)

    --if index <= #BP_ARRAY_Shop_GiftRecvList then

        local tmp = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftRecvList, index)
        if(tmp == nil) then
            return
        end
        tmp.isFetched = true
        log_tree("ShopGiftMsgCenter.OnGetGift", tmp)
        local strMsg = DataMgr.GetMsgByID(501026);
        local msg = string.format(strMsg, ShopGiftMsgCenter.GetShopItemName(tmp.item, tmp.give_type, tmp.colorID, tmp.patternID))
        PopUpNoticeUI.ShowFastNoticeQueue(msg);

        BP_Gift_MsgCenter_IsPlatformFriend = FriendSystem.IsPlatFriend(tmp.uid)

        LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_view, "UpdateGetGiftView");

        local text = FuncUtil.GetLocalizeResStr(501002)
        tmp.message = string.format(text, "", ShopGiftMsgCenter.GetShopItemName(tmp.item, tmp.give_type, tmp.colorID, tmp.patternID))

        -- --领取完成把红点去掉
        ----- @soloer由后台主动下发协议刷新，所以屏蔽这行代码
        -- ShopGiftPacketLogic.SendMarketMsgSetReadReq(11, index, 1)

        --播放获得道具动画
        if not StoreFuncUtils.CheckIsChest(tmp.item) then
            local arrayItemData = ShopGiftMsgCenter.GetSuitItemList(tmp.item, tmp.give_type, tmp.colorID, tmp.patternID, tmp.valid_hours)
            CommonItemGetUI:ShowPanel(arrayItemData);
        end
    --end
end

--领取全部礼物回调
function ShopGiftMsgCenter.OnGetAllGift(indexList)
    --log_tree("ShopGiftMsgCenter.OnGetAllGift", indexList)
    --log_tree("BP_ARRAY_Shop_GiftRecvList", BP_ARRAY_Shop_GiftRecvList)
    local itemList = {};
    for i = 1, #indexList do
        --if indexList[i] <= #BP_ARRAY_Shop_GiftRecvList then
            local tmp = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftRecvList, indexList[i]);
            if tmp ~= nil then
                if not StoreFuncUtils.CheckIsChest(tmp.item) then
                    table.insert(itemList, tmp);
                end
                tmp.isFetched = true;

                local strMsg = DataMgr.GetMsgByID(501026);
                local msg = string.format(strMsg, ShopGiftMsgCenter.GetShopItemName(tmp.item, tmp.give_type, tmp.colorID, tmp.patternID));
                PopUpNoticeUI.ShowFastNoticeQueue(msg);

                local text = FuncUtil.GetLocalizeResStr(501002);
                tmp.message = string.format(text, "", ShopGiftMsgCenter.GetShopItemName(tmp.item, tmp.give_type, tmp.colorID, tmp.patternID));
                tmp.read = 1;
            end
        --end
    end
    --bug=71872543 【全量测试】邮件-礼物中心：多物品（礼包和商品）一起领取，礼包"领取"没有反馈
    --获得物品的提示不走这里，统一用 market_buy_chest_item_notify----steveou 后台jielingyin
    --if #itemList > 0 then
    --    --播放获得道具动画
    --    local arrayItemData = ShopGiftMsgCenter.GetSuitItemListByItemList(itemList);
    --    CommonItemGetUI:ShowPanel(arrayItemData);
    --end
end

--跳转到商城某个商品赠送界面
function ShopGiftMsgCenter.JumpToMarket(productTbl)
	--log_tree("ShopGiftMsgCenter.JumpToMarket productTbl", productTbl)
	--log_tree("ShopGiftMsgCenter.JumpToMarket tmp=", ShopGiftMsgCenter.tmpData)

    productTbl.cnt = 1
    productTbl.time = -1

	local toUserTbl =
	{
		 gid = ShopGiftMsgCenter.tmpData.uid,
         openid = ShopGiftMsgCenter.tmpData.openid,
		 level = ShopGiftMsgCenter.tmpData.level,
		 sex = ShopGiftMsgCenter.tmpData.gender,-- 1为男，2为女
		 cur_avatar_box_id = ShopGiftMsgCenter.tmpData.avatarBox,
		 platName = ShopGiftMsgCenter.tmpData.platName,
		 nickName = ShopGiftMsgCenter.tmpData.nickName,
		 picUrl = ShopGiftMsgCenter.tmpData.iconUrl,
	}

	ShopGiftPacketUI:OpenViewRequestGiftPanel(productTbl, toUserTbl, ShopGiftMsgCenter.tmpData.notice, ShopGiftMsgCenter.tmpData.index);
end

function ShopGiftMsgCenter.Reconnect()
    if ShopGiftMsgCenter.isShowing == true then
        if BP_Gift_MsgCenter_TabType == 0 then
            ShopGiftPacketLogic.SendGetGiftMsgList(11);
        end
    end
end

--[[
off_msg_type_give_gift     = 11  --赠送消息  别人送给我的
off_msg_type_ask_for       = 12  --索取消息
off_msg_type_gift_record   = 13 --赠礼记录  我送给别人的
--]]
--切换Tab
function EventGiftMsgCenterClickRecv()
    BP_Gift_MsgCenter_TabType = 0
    -- LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    ShopGiftPacketLogic.SendGetGiftMsgList(11)
end
function EventGiftMsgCenterClickBeg()
    BP_Gift_MsgCenter_TabType = 1
    -- LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    ShopGiftPacketLogic.SendGetGiftMsgList(12)
end
function EventGiftMsgCenterClickSend()
    BP_Gift_MsgCenter_TabType = 2
    -- LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    ShopGiftPacketLogic.SendGetGiftMsgList(13)
end
function EventGiftMsgCenterClickThanks()
    BP_Gift_MsgCenter_TabType = 3
    -- LuaClassObj.HandleUIMessage(bp_shop_gift_msgcenter, "RefreshUI");
    ShopGiftPacketLogic.SendGetGiftMsgList(14)
end

--一键删除
function EventGiftMsgCenterClickDeleteAll()
    log("EventGiftMsgCenterClickDeleteAll");
    if BP_Gift_MsgCenter_TabType == 0 then
        local mailList = {};
        for i = 1, #BP_ARRAY_Shop_GiftRecvList do
            if BP_ARRAY_Shop_GiftRecvList[i].read == 1 then
                mailList[#mailList + 1] = BP_ARRAY_Shop_GiftRecvList[i];
            end
        end
        if #mailList > 0 then
            local function funcDel()
                ShopGiftPacketLogic.SendMarketDelAllGiftMsgReq();
            end
            CommonMessageBoxUI:ShowPanel(2, localText(102012), localText(102002), funcDel);
        else
            DataMgr.ShowNoticeByID(102014);
        end
    end
end

--一键领取
function EventGiftMsgCenterClickReceiveAll()
    log("EventGiftMsgCenterClickReceiveAll");
    if BP_Gift_MsgCenter_TabType == 0 then
        ShopGiftPacketLogic.SendMarketGiftAllTakeReq();
    end
end

--一键已读
function EventGiftMsgCenterClickOneKey()
    if BP_Gift_MsgCenter_TabType == 0 then
        --需要领取才去掉红点
    end
end

--拒绝和接受索要
function EventGiftMsgCenterClickBegRefuse()
    log("EventGiftMsgCenterClickBegRefuse")
    ShopGiftPacketLogic.SendMarketRefuseAskForReq(true)
end
function EventGiftMsgCenterClickBegAccept()
    log("EventGiftMsgCenterClickBegAccept")
    ShopGiftPacketLogic.SendMarketRefuseAskForReq(false)
end

function EventFetchInfo()
end

function EventSetInfo_Push()
end

--设置信息已读
function EventGiftMsgCenterClickRemoveRedPoint()
    log("EventGiftMsgCenterClickRemoveRedPoint "..BP_Gift_MsgCenter_TabType.." "..BP_Gift_MsgCenter_ClickIndex)
    local index = BP_Gift_MsgCenter_ClickIndex
    if BP_Gift_MsgCenter_TabType == 0 then
        --需要领取才去掉红点
    elseif BP_Gift_MsgCenter_TabType == 1 then
        if index <= #BP_ARRAY_Shop_GiftBegList then
            local tmp = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftBegList, index)
            if(tmp ~= nil and tmp.read == 0) then
                ShopGiftPacketLogic.SendMarketMsgSetReadReq(12, index, 1)
            end
        end
    elseif BP_Gift_MsgCenter_TabType == 2 then
        if index <= #BP_ARRAY_Shop_GiftSendList then
            local tmp = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftSendList, index)
            if(tmp ~= nil and tmp.read == 0) then
                ShopGiftPacketLogic.SendMarketMsgSetReadReq(13, index, 1)
            end
        end
    end
end

--领取礼物
function EventGiftMsgCenterRequestGetGift()
    log("EventRequestGetGift")
    ShopGiftPacketLogic.SendMarketGiftTakeReq(BP_Gift_MsgCenter_ClickIndex)
end

--礼物打开动画
function EventGiftMsgCenterOpenGiftAnimation()
    local data = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftRecvList, BP_Gift_MsgCenter_ClickIndex)
    if data == nil then
        return
    end
    log("check gift item valid"..data.item)
    local GiftItem = Client.GetTableData("item", data.item);
    if GiftItem == nil then
        --DataMgr.ShowNoticeByID("6311")
        return
    end

    ShopGiftViewUI.PlayGetGiftView()
end

--显示领取/查看界面
function EventGiftMsgCenterOpenGiftGetView()

    local data = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftRecvList, BP_Gift_MsgCenter_ClickIndex)
    if data == nil then
        return
    end

    BP_Gift_MsgCenter_IsPlatformFriend = FriendSystem.IsPlatFriend(data.uid)

    ShopGiftViewUI.UIShowGetGift()

    if ShopGiftMsgCenter.thanks[data.index] then
        LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_view, "HidePlatformShareButton");
    end
end

--跳转到索要的赠送界面
function EventGiftMsgCenterJumpMarket()
    log("EventGiftMsgCenterJumpMarket")
    ShopGiftMsgCenter.tmpData = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftBegList, BP_Gift_MsgCenter_ClickIndex)
    if ShopGiftMsgCenter.tmpData == nil then
        return
    end
    log("EventGiftMsgCenterJumpMarket:"..ShopGiftMsgCenter.tmpData.shopid)
    MallSystem.GetShopItemInfoByIdReq(ShopGiftMsgCenter.tmpData.shopid, ShopGiftMsgCenter.JumpToMarket)
end

--告诉好友
function EventGiftMsgCenterTellFriend()
    log("EventGiftMsgCenterTellFriend")
    local tmp = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftRecvList, BP_Gift_MsgCenter_ClickIndex)
    if tmp == nil then
        return
    end
    local notice = ShopGiftMsgCenter.GetRandomThanksMsg()
    notice = string.gsub(notice, "<GiftItemFont>", "")
    notice = string.gsub(notice, "</>", "")
    notice = string.format(notice, ShopGiftMsgCenter.GetShopItemName(tmp.item, tmp.give_type, tmp.colorID, tmp.patternID))
    ShareShopGiftUI.shareToFriendThanks(tmp.uid, tmp.nickName, notice)
    ShopGiftMsgCenter.thanks[tmp.index] = true

    LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_view, "HidePlatformShareButton");
end

--分享一下
function EventGiftMsgCenterShare()
    log("EventGiftMsgCenterShare")
    local data = ShopGiftMsgCenter.GetIndexDataList(BP_ARRAY_Shop_GiftRecvList, BP_Gift_MsgCenter_ClickIndex)
    ShareShopGiftUI.ShowSharePanel(data)
end


--获取玩家信息
function EventGiftMsgCenterRequestPlayerInfo()
    log("EventGetGiftBoxPlayerIcon:"..BP_Gift_MsgCenter_Uid)
    ProfileMgr.GetProfile(BP_Gift_MsgCenter_Uid, ShopGiftMsgCenter.OnGetPlayerInfoByProfile, false)
end

--点击玩家头像
function EventGiftMsgCenterClickPlayerInfo()
    log("EventGiftMsgCenterClickPlayerInfo "..BP_Gift_MsgCenter_ClickUid);
    if BP_Gift_MsgCenter_ClickUid == "" then
        return
    end
	RoleInfoSystem.Enter(BP_Gift_MsgCenter_ClickUid);
	RoleInfoUI.Init(true, RoleInfoOpenFromType.shop_gift_msgcenter);
end

--点击说明
function EventGiftMsgCenterClickHelpInfo()
    log("EventGiftMsgCenterClickHelpInfo ");
    local level = DataMgr.GetSystemConfig("MarketGiftSendLevelLimit");
    local day = DataMgr.GetSystemConfig("MarketGiftSendDayLimit");
    local datatable = Client.GetTableData("LocalizeRes", "4499")
    if datatable ~= nil then
        local tips = datatable.TextValue
        -- tips = string.format(tips, level, day)
        tips = string.format(tips, level)
        tips = string.gsub(tips, "\\n", "\n");

        local title = DataMgr.GetMsgByID(501039);
        PopUpNoticeUI.ShowMessageBox(title, tips);
    end
end



function ShopGiftMsgCenter.ChangeIsOnlyShow(isOnlyShow)
    log("RoomUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
    ShopGiftMsgCenter.isOnlyShow = isOnlyShow
    if ShopGiftMsgCenter.isOnlyShow then
        LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_msgcenter, "UIOnlyShow");
    else
        LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_msgcenter, "UIOnlyHide");
    end
end

function ShopGiftMsgCenter.GetStatus()
    log("RoomUI.GetStatus:" .. tostring(ShopGiftMsgCenter.isOnlyShow))
    return {isOnlyShow = ShopGiftMsgCenter.isOnlyShow}
end

function ShopGiftMsgCenter.RecoverStatus(status)
    if status and status.isOnlyShow ~= nil then
        log("ShopGiftMsgCenter.RecoverStatus:" .. tostring(status.isOnlyShow))
        ShopGiftMsgCenter.ChangeIsOnlyShow(status.isOnlyShow)
    end

end
