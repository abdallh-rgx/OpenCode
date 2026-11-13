--[[
  个人信息头像的相关逻辑
--]]

RoleInfoHeadportraitSystem = RoleInfoHeadportraitSystem or
{
	HeadportraitList = {},
    RedpointList = {},
    HeadportraitListUnClear = {},
}

function RoleInfoHeadportraitSystem.ResetData()
    log("[HHF]RoleInfoHeadportraitSystem.ResetData");
    RoleInfoHeadportraitSystem.RedpointList = {};
end

function RoleInfoHeadportraitSystem.Init()
    RoleInfoHeadportraitSystem.get_headportrait_list();
end

function RoleInfoHeadportraitSystem.get_headportrait_list()
    NetUtil.SendPriorityPkg(false, "get_user_avatar_list_rsp", "get_user_avatar_list");
    --list = {["10001"]=1, ["10002"]="https://graph.facebook.com/100010716270985/picture", ["20001"]=1, ["30001"]=1};
    --RoleInfoHeadportraitSystem.get_user_avatar_list_rsp(0, list, "10001")  -- [HHF] for test
end

function RoleInfoHeadportraitSystem.get_user_avatar_list_rsp(ok, list, headportraiturl)
    log("[HHF]RoleInfoHeadportraitSystem.get_user_avatar_list_rsp, ok = " .. ok .. ", list.num = " .. FuncUtil:CountTable(list) .. ", headportraiturl = " .. headportraiturl);
    --log_tree("list = ", list);
    if ok == 0 then
        DataMgr.roleData.headIconUrl = headportraiturl;
        RoleInfoHeadportraitSystem.HeadportraitList = list;
        RoleInfoHeadportraitSystem.HeadportraitListUnClear = list;
        -- 发送头像信息更新事件
        EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, headportraiturl);
    else
        DataMgr.ShowMessageBoxByID(ok)
    end
end

function RoleInfoHeadportraitSystem.notify_unlock_new_avatar(list)
    log("[HHF]RoleInfoHeadportraitSystem.notify_unlock_new_avatar")
    --log_tree("list = ", list);
    for k, v in pairs(list) do
        if RoleInfoHeadportraitSystem.RedpointList[k] == nil then
            RoleInfoHeadportraitSystem.RedpointList[k] = v;
        end
        if RoleInfoHeadportraitSystem.HeadportraitListUnClear[k] == nil then
            RoleInfoHeadportraitSystem.HeadportraitListUnClear[k] = v;
        end
    end

    if RoleInfoHeadportraitUI.IsShow() then
        RoleInfoHeadportraitUI.Refresh()
    end
    
    RoleInfoUI.UpdateHeadportraitReddot();
    LobbyUI:UpdateHeadportraitReddot();
end

function RoleInfoHeadportraitSystem.UpdateRedpoint(item_id)
    log("[HHF]RoleInfoHeadportraitSystem.UpdateRedpoint, id = " .. item_id)
    if RoleInfoHeadportraitSystem.RedpointList[item_id] ~= nil then
        RoleInfoHeadportraitSystem.RedpointList[item_id] = nil
    end
    
    if RoleInfoHeadportraitUI.IsShow() then
        RoleInfoHeadportraitUI.Refresh()
    end
    
    if next(RoleInfoHeadportraitSystem.RedpointList) == nil then
        RoleInfoUI.UpdateHeadportraitReddot();
        LobbyUI:UpdateHeadportraitReddot();
        LuaClassObj.HandleUIMessage(bp_lobby_roleinfo_showinformation, "UpdateMenuReddot");
    end
end

function RoleInfoHeadportraitSystem.HaveNewHeadportrait()
    if next(RoleInfoHeadportraitSystem.RedpointList) == nil then
        return false;
    else
        return true;
    end
end

function RoleInfoHeadportraitSystem.change_headportrait(item_url)
    log("[HHF]RoleInfoHeadportraitSystem.change_headportrait, headIconUrl = " .. item_url);
    NetUtil.SendPriorityPkg(false, "change_user_avatar_rsp", "change_user_avatar", item_url);
    --RoleInfoHeadportraitSystem.change_user_avatar_rsp(0, item_url); -- [HHF] for test
end

function RoleInfoHeadportraitSystem.change_user_avatar_rsp(ok, item_url)
    log("[HHF]RoleInfoHeadportraitSystem.change_user_avatar_rsp, ok = " .. ok .. ", headIconUrl = " .. item_url);
    if ok == 0 then
        DataMgr.roleData.headIconUrl = item_url;
        if RoleInfoHeadportraitUI.IsShow() then
            RoleInfoHeadportraitUI.RefreshSelect()
        end
        --刷新个人信息界面与大厅界面的头像
        RoleInfoUI.UpdateHeadportrait()
        -- 更新大厅显示数据
        LobbyUI:RefreshPlayerData()
    else
        DataMgr.ShowMessageBoxByID(ok)
    end
end

function RoleInfoHeadportraitSystem.update_user_avatar_url(item_url)
    log("[HHF]RoleInfoHeadportraitSystem.update_user_avatar_url, headIconUrl = " .. item_url);
    RoleInfoHeadportraitSystem.change_user_avatar_rsp(0, item_url);
end

function RoleInfoHeadportraitSystem.Release()
    RoleInfoHeadportraitSystem.HeadportraitList = {}
end

function RoleInfoHeadportraitSystem.get_unlock_progress_req()
    NetUtil.SendPriorityPkg(false, "get_unlock_progress_rsp", "get_unlock_progress_req");
end

function RoleInfoHeadportraitSystem.get_unlock_progress_rsp(res, headerProgress)
    --log_tree("RoleInfoHeadportraitSystem.get_unlock_progress_rsp", headerProgress);
    RoleInfoHeadportraitUI.headerProgress = headerProgress;
end

function RoleInfoHeadportraitSystem.HasHeadPortrait(headId)
    if RoleInfoHeadportraitSystem.HeadportraitListUnClear[tostring(headId)] == 1 then
        return true;
    end
    return false;
end

--[[网络回调]]--
s2c["change_user_avatar_rsp"] = RoleInfoHeadportraitSystem.change_user_avatar_rsp;
s2c["update_user_avatar_url"] = RoleInfoHeadportraitSystem.update_user_avatar_url;
s2c["get_user_avatar_list_rsp"] = RoleInfoHeadportraitSystem.get_user_avatar_list_rsp;
s2c["notify_unlock_new_avatar"] = RoleInfoHeadportraitSystem.notify_unlock_new_avatar;
s2c["notify_unlock_new_avatar"] = RoleInfoHeadportraitSystem.notify_unlock_new_avatar;
s2c["get_unlock_progress_rsp"] = RoleInfoHeadportraitSystem.get_unlock_progress_rsp;