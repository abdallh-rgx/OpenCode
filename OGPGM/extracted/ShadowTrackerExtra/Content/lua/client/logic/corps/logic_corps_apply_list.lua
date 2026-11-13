-- 概要信息
-- CorpsApplyListUILogic.OnUpdateApplyListUI applyList
-- └─ 1
--    ├─ lastOnlineTime: 1519744652
--    ├─ level: 17
--    ├─ social_card: { }
--    ├─ vipLevel: ""
--    ├─ startup_type: 0
--    ├─ lastLoginTime: 1519744545
--    ├─ uid: 410000009
--    ├─ platName: ""
--    ├─ nickName: "微笑阿德N"
--    ├─ cur_avatar_box_id: 2001001
--    ├─ picUrl: "http://q.qlogo.cn/qqapp/1106467070/E6A400CAC539EF1F8E8ACD1627A18970/100"
--    ├─ city: ""
--    ├─ signature: ""
--    ├─ sex: 1
--    ├─ segment_info
--    │  ├─ 1: 303
--    │  ├─ 2: 101
--    │  └─ 3: 101
--    ├─ exp: 745
--    └─ qq_vip: 0

CorpsApplyListUILogic = CorpsApplyListUILogic or
{
    isShow = false;
};

function CorpsApplyListUILogic.HideUI()
    if BP_Corps_ApplyList_ShowType == 1 then
        EventSystem:unregistEvent(EVENTTYPE_CORPS, EVENTID_CORPS_GET_APPLY_LIST, CorpsApplyListUILogic.OnUpdateApplyListUI);
    end

    CorpsApplyListUILogic.isShow = false;
    UIManager.Hide(eUIType.eCorpsApplyListUI)
    LuaClassObj.HandleUIMessage(bp_corps_apply_list, "HideUI");
end

-- 显示申请列表UI
function CorpsApplyListUILogic.ShowApplyListUI()

    log("CorpsApplyListUILogic.ShowApplyListUI")
    LuaClassObj.HandleDynamicCreation(bp_corps_apply_list);
    BP_Corps_ApplyList_ShowType = 1;
    CorpsApplyListUILogic.isShow = true;
    CorpsMemberSystem.SendGetCorpsApplyListReq(true);
    LuaClassObj.HandleUIMessage(bp_corps_apply_list, "ShowApplyListUI");
    UIManager.Show(eUIType.eCorpsApplyListUI)
    CorpsApplyListUI.ChangeIsOnlyShow(true)
end

-- 刷新申请列表UI
function CorpsApplyListUILogic.OnUpdateApplyListUI(applyList)
    if not CorpsApplyListUILogic.isShow or BP_Corps_ApplyList_ShowType ~= 1 then
         return;
     end
    BP_ARRAY_Corps_ApplyList = {}

    -- log_tree("CorpsApplyListUILogic.OnUpdateApplyListUI applyList", applyList);

    if applyList ~= nil then
        for k,v in pairs(CorpsMemberSystem.ApplyList) do
            local info = CorpsApplyListUILogic.CreateListItem(v, applyList[v.uid]);
            if info ~= nil then
                table.insert(BP_ARRAY_Corps_ApplyList, info);
            end
        end
    end

    -- log_tree("CorpsApplyListUILogic.UpdateApplyListUI BP_ARRAY_Corps_ApplyList", BP_ARRAY_Corps_ApplyList);
    LuaClassObj.HandleUIMessage(bp_corps_apply_list, "UpdateApplyListUI");
end

function CorpsApplyListUILogic.IsFriendRecomm(applyInfo)
    return applyInfo.recomm_name ~= nil or applyInfo.status ~= nil;
end

function CorpsApplyListUILogic.CreateListItem(applyInfo, baseInfo)
    -- log_tree("CorpsApplyListUILogic.CreateListItem applyInfo", applyInfo);
    -- log_tree("CorpsApplyListUILogic.CreateListItem baseInfo", baseInfo);
    if applyInfo == nil then
        return nil;
    end

    local recommName = "";

    if applyInfo.recomm_name ~= nil then
        recommName = FuncUtil.LocalizeResFormat("410037", ProfileMgr.GetNickName(applyInfo.recomm_uid) or applyInfo.recomm_name);
    end

    local info =
    {
        RecommendFriendName = recommName,
        BP_STRUCT_BASE_INFO = baseInfo or FuncUtil:CopyTable(BP_STRUCT_BASE_INFO),
    }

    return info;
end

function CorpsApplyListUILogic.RemoveItem(apply_uid)
    if not CorpsApplyListUILogic.isShow then
        return;
    end

    local hasChange = false;
    for i,v in ipairs(BP_ARRAY_Corps_ApplyList) do
        if v.BP_STRUCT_BASE_INFO.strUid == tostring(apply_uid) then
            table.remove(BP_ARRAY_Corps_ApplyList, i);
            hasChange = true;
            break;
        end
    end

    if hasChange then
        -- log_tree("CorpsApplyListUILogic.RemoveItem BP_ARRAY_Corps_ApplyList", BP_ARRAY_Corps_ApplyList);
        LuaClassObj.HandleUIMessage(bp_corps_apply_list, "UpdateApplyListUI");
    end
end

function CorpsApplyListUILogic.OnClickAgree(id)
    id = tonumber(id);
    log("CorpsApplyListUILogic.OnClickAgree id "..id)

    local applyInfo = CorpsMemberSystem.FindApplyByID(id);
    if applyInfo == nil then
        return;
    end

    if CorpsApplyListUILogic.IsFriendRecomm(applyInfo) then
        CorpsMemberSystem.SendInviteReq(id, 1);
    else
        CorpsMemberSystem.SendDealPlayerApplyReq(id, true);
    end
end

function CorpsApplyListUILogic.OnClickRefuse(id)
    id = tonumber(id);
    log("CorpsApplyListUILogic.OnClickRefuse id "..id)

    local applyInfo = CorpsMemberSystem.FindApplyByID(id);
    if applyInfo == nil then
        return;
    end

    if CorpsApplyListUILogic.IsFriendRecomm(applyInfo) then
        CorpsMemberSystem.SendInviteReq(id, 2);
    else
        CorpsMemberSystem.SendDealPlayerApplyReq(id, false);
    end
end