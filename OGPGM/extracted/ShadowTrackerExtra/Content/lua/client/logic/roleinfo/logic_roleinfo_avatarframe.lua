--[[
  个人信息头像框的相关逻辑
]]--

RoleInfoAvatarFrameSystem = RoleInfoAvatarFrameSystem or
{
	AvatarFrameList = {},
    UsedId = 0,
    RedpointList = {}, -- 头像框红点通知

    AvartarFrameListUnClear = {},--和AvatarFrameList结构一直，但不会清除，持续维护
}

function RoleInfoAvatarFrameSystem.ResetData()
    log("[HHF]RoleInfoAvatarFrameSystem.ResetData");
    RoleInfoAvatarFrameSystem.RedpointList = {};
end

function RoleInfoAvatarFrameSystem.Enter()
	--log("RoleInfoAvatarFrameSystem Enter");
    RoleInfoAvatarFrameSystem.UsedId = DataMgr.roleData.cur_avatar_box_id;
    RoleInfoAvatarFrameSystem.get_avatar_box_list();
end

function RoleInfoAvatarFrameSystem.Release()
	--log("RoleInfoAvatarFrameSystem Release");
    RoleInfoAvatarFrameSystem.AvatarFrameList = {}
end

function RoleInfoAvatarFrameSystem.change_avatar_box(item_id)
	--log_tree("RoleInfoAvatarFrameSystem.change_avatar_box=", {item_id});
    NetUtil.SendPriorityPkg(false, "change_avatar_box_rsp", "change_avatar_box", item_id);
end

function RoleInfoAvatarFrameSystem.change_avatar_box_rsp(ok, item_id)
	--log_tree("RoleInfoAvatarFrameSystem.change_avatar_box_rsp=", {ok, item_id});
    if ok == 0 then
        DataMgr.roleData.cur_avatar_box_id = item_id;
        RoleInfoAvatarFrameSystem.UsedId = DataMgr.roleData.cur_avatar_box_id;
        if RoleInfoAvatarFrameUI.IsShow() then
            RoleInfoAvatarFrameUI.RefreshSelect()
        end
        --刷新个人信息界面与大厅界面的头像
        RoleInfoUI.UpdateAvatarFrame()
        -- 更新大厅显示数据
        LobbyUI:RefreshPlayerData()
    else
        DataMgr.ShowMessageBoxByID(ok)
    end    
end

function RoleInfoAvatarFrameSystem.get_avatar_box_list()
	--log_tree("RoleInfoAvatarFrameSystem.get_avatar_box_list");
    NetUtil.SendPriorityPkg(false, "get_avatar_box_list_rsp", "get_avatar_box_list");
end

function RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp(ok, list, cur_avatar_box_id)
	--log_tree("RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp=", {ok, list, cur_avatar_box_id});
    if ok == 0 then
        DataMgr.roleData.cur_avatar_box_id = cur_avatar_box_id;
        RoleInfoAvatarFrameSystem.UsedId = DataMgr.roleData.cur_avatar_box_id;
        RoleInfoAvatarFrameSystem.AvatarFrameList = list
        RoleInfoAvatarFrameSystem.AvartarFrameListUnClear = list;
        if RoleInfoAvatarFrameUI.IsShow() then
            RoleInfoAvatarFrameUI.Refresh()
        end
        if RoleInfoUI.IsShow then
            --刷新个人信息界面与大厅界面的头像
            RoleInfoUI.UpdateAvatarFrame()
        end

        -- 更新大厅显示数据
        LobbyUI:RefreshPlayerData()
    else
        DataMgr.ShowMessageBoxByID(ok)
    end
end

-- 头像框的红点更新通知
function RoleInfoAvatarFrameSystem.OnHeadFrameNotify(avatarBoxId, expireTime)
    local now = FuncUtil.GetServerTimeInSec()
    log("[HHF]RoleInfoAvatarFrameSystem.OnHeadFrameNotify "..tostring(avatarBoxId)..", "..tostring(expireTime)..", "..tostring(now))
    if expireTime ~= 1 and expireTime <= now then -- 1 表示永久
        return -- 已过期
    end

    RoleInfoAvatarFrameSystem.RedpointList[avatarBoxId] = expireTime
    
    -- update expire time
    local item = RoleInfoAvatarFrameSystem.AvatarFrameList[avatarBoxId]
    if item ~= nil then
        item.expire_time = expireTime
    end

    local data = RoleInfoAvatarFrameSystem.AvartarFrameListUnClear[avatarBoxId]
    if data == nil then
        data = {}
        RoleInfoAvatarFrameSystem.AvartarFrameListUnClear[avatarBoxId] = data;
    end
    data.expire_time = expireTime;
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_AVATAR_PORTRAIT);

    if RoleInfoAvatarFrameUI.IsShow() then
        RoleInfoAvatarFrameUI.Refresh()
    end
    
    RoleInfoUI.UpdateHeadportraitReddot();
    LobbyUI:UpdateHeadportraitReddot();
end

-- 是否有新的头像框
function RoleInfoAvatarFrameSystem.HaveNew()
    if next(RoleInfoAvatarFrameSystem.RedpointList) == nil then
        log("[HHF]RoleInfoAvatarFrameSystem.HaveNew false")
        return false;
    else
        log("[HHF]RoleInfoAvatarFrameSystem.HaveNew true")
        return true;
    end
end

-- 点击item后取消小红点
function RoleInfoAvatarFrameSystem.UpdateRedpoint(item_id)
    log("[HHF]RoleInfoAvatarFrameSystem.UpdateRedpoint, id = " .. tostring(item_id))
    if RoleInfoAvatarFrameSystem.RedpointList[item_id] ~= nil then
        RoleInfoAvatarFrameSystem.RedpointList[item_id] = nil
        log("[HHF]Remove red point #"..#RoleInfoAvatarFrameSystem.RedpointList)
    else
        return
    end
    
    if next(RoleInfoAvatarFrameSystem.RedpointList) == nil then
        RoleInfoUI.UpdateHeadportraitReddot();
        LobbyUI:UpdateHeadportraitReddot();
        LuaClassObj.HandleUIMessage(bp_lobby_roleinfo_showinformation, "UpdateMenuReddot");
    end
end

function RoleInfoAvatarFrameSystem.HasAvatarFrame(avatarFrameId)
    if RoleInfoAvatarFrameSystem.AvartarFrameListUnClear[avatarFrameId] ~= nil then
        return true;
    end
    return false;
end

--[[网络回调]]--
s2c["change_avatar_box_rsp"] = RoleInfoAvatarFrameSystem.change_avatar_box_rsp;
s2c["get_avatar_box_list_rsp"] = RoleInfoAvatarFrameSystem.get_avatar_box_list_rsp;
s2c["get_new_avatar_box_notify"] = RoleInfoAvatarFrameSystem.OnHeadFrameNotify;