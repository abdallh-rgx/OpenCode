--[[
	军团推荐系统
--]]

CorpsSuggestionSystem = CorpsSuggestionSystem or 
{
	FriendUIDSet = {}, -- 好友UID集合
    SuggestionList = {}, -- 推荐列表

    -- 被邀请列表
    InvitedCorpsArray = {},
    hasNewIvitedCorps = false,
};

function CorpsSuggestionSystem.Init()
	log("CorpsSuggestionSystem.Init");
	BP_ARRAY_Corps_SuggestionList = {};
	BP_ARRAY_Corps_ApplicationList = {};
    BP_ARRAY_Corps_ApplicationTempIDList = {};
	BP_Corps_Suggestion_Toggle = 1;
	BP_Corps_Suggestion_CurSelectedIndex = 0;
	BP_Corps_Suggestion_SearchName = "";
	BP_Corps_Suggestion_SearchResult = false;
    BP_Corps_Suggestion_NotNeedApproval = false;
    BP_Corps_Suggestion_AccordRequirement = true;
    local friendIDList = FriendSystem.UnionFriendIDList(ID_PLAT_FRIENDLIST, ID_INNER_FRIENDLIST);
    for k, v in pairs(friendIDList) do
        CorpsSuggestionSystem.FriendUIDSet[v] = true;
    end
    RoleInfoSystem.get_social_card(); -- 请求下交友名片的位置信息
end

function CorpsSuggestionSystem.Release()
	log("CorpsSuggestionSystem.Release");
	BP_ARRAY_Corps_SuggestionList = {};
	BP_ARRAY_Corps_ApplicationList = {};
    BP_ARRAY_Corps_ApplicationTempIDList = {};
	BP_Corps_Suggestion_Toggle = 1;
	BP_Corps_Suggestion_CurSelectedIndex = 0;
	BP_Corps_Suggestion_SearchName = "";
	BP_Corps_Suggestion_SearchResult = false;
    CorpsSuggestionSystem.SuggestionList = {};
    CorpsSuggestionSystem.InvitedCorpsArray = {};
end

function CorpsSuggestionSystem.HandleErrorCode(msg)
    -- log_tree("CorpsSuggestionSystem.HandleErrorCode", msg);
	if msg == 411013 then -- 未申请
		BP_ARRAY_Corps_ApplicationList = {};
		EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SUGGESTIONLIST);
        return;
    elseif msg == 411024 then -- 不存在
        BP_ARRAY_Corps_SearchList = {};
        CorpsSuggestionUI.UpdateSearchResult();
        return;
    elseif msg == 411012 then
        ShowNotice(msg);
	end

    ShowNotice(msg);
end

-- 过滤推荐列表
function CorpsSuggestionSystem.FilterSuggestionList(need_approval, accord_requirement)
    local ret = {};
    local segment = math.max(DataMgr.roleData.segment.solo, DataMgr.roleData.segment.double, DataMgr.roleData.segment.team);
    local function IsCorpsAccordRequirement(corps_item)

        return (DataMgr.roleData.level >= corps_item.join_level) and (segment >= corps_item.join_segment);
    end

    for k, v in pairs(CorpsSuggestionSystem.SuggestionList) do
        local needAdd = true;
        if need_approval == false and v.need_approval == true then
            needAdd = false;
        elseif accord_requirement == true then
            local acc = IsCorpsAccordRequirement(v);
            if not acc then
                needAdd = false;
            end
        end

        if needAdd then
            ret[k] = v;
        end
    end
    -- log_tree("FilterSuggestionList:", ret);
    return ret;
end

-- 取选中item头像
function CorpsSuggestionSystem.GetSelectedHeadIcons()
    if (BP_Corps_Suggestion_CurSelectedIndex < 0) then
        return;
    end

    local memlist = {};
    local commander = "";
    if BP_Corps_Suggestion_Toggle == 1 then
        if BP_Corps_Suggestion_SearchResult == false then
            memlist = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].BP_ARRAY_Corps_MemberList;
            commander = BP_ARRAY_Corps_SuggestionList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_id;
        else
            memlist = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].BP_ARRAY_Corps_MemberList;
            commander = BP_ARRAY_Corps_SearchList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_id;
        end
    elseif BP_Corps_Suggestion_Toggle == 2 then
        memlist = BP_ARRAY_Corps_ApplicationList[BP_Corps_Suggestion_CurSelectedIndex + 1].BP_ARRAY_Corps_MemberList;
        commander = BP_ARRAY_Corps_ApplicationList[BP_Corps_Suggestion_CurSelectedIndex + 1].commander_id;
    elseif BP_Corps_Suggestion_Toggle == 3 then
        local info = BP_ARRAY_Corps_InvitedCorpsList[BP_Corps_Suggestion_CurSelectedIndex + 1];
        memlist = info.BP_ARRAY_Corps_MemberList or {};
        commander = info.commander_id;
    end

    local memFriendList = {};
    for k, v in pairs(memlist) do
        if CorpsSuggestionSystem.FriendUIDSet[tonumber(v)] == true then
            table.insert(memFriendList, tonumber(v));
        end
    end
    
    table.insert(memFriendList, 1, tonumber(commander));

    local getFriendUrlCallback = function (infoList)
        -- log_tree("getFriendUrlCallback", infoList);
        BP_ARRAY_Corps_SelectedFriends = {};
        for k, v in pairs(infoList) do
            if k == tonumber(commander) then
                BP_STRUCT_Corps_SelectedCommanderInfo.url = v.IconUrl;
                BP_STRUCT_Corps_SelectedCommanderInfo.level = v.Level;
                BP_STRUCT_Corps_SelectedCommanderInfo.frame = v.IconFrameID;

                if CorpsSuggestionSystem.FriendUIDSet[k] == true then
                    local temp = {};
                    temp.Frame = v.IconFrameID;
                    temp.HeadUrl = v.IconUrl;
                    temp.Level = v.Level;
                    table.insert(BP_ARRAY_Corps_SelectedFriends, temp);
                end
            else
                local temp = {};
                temp.Frame = v.IconFrameID;
                temp.HeadUrl = v.IconUrl;
                temp.Level = v.Level;
                table.insert(BP_ARRAY_Corps_SelectedFriends, temp);
            end
        end
        -- log_tree("BP_ARRAY_Corps_SelectedFriends", BP_ARRAY_Corps_SelectedFriends);
        LuaClassObj.HandleUIMessage(bp_corps_suggestion, "RefreshDetailHeadIcons");
    end

    if #memFriendList > 0 then
        CorpsMgr.GetAvatarBaseInfo(memFriendList, getFriendUrlCallback)
    else
        getFriendUrlCallback({});
    end
end

function CorpsSuggestionSystem.UpdateTempApplyIDList(corps_id)
    table.insert(BP_ARRAY_Corps_ApplicationTempIDList, tostring(corps_id));
    LuaClassObj.HandleUIMessage(bp_corps_suggestion, "RefreshSelectApplyState");
end


function CorpsSuggestionSystem.CompareItem(a, b)
    if a.friend_num > 0 or b.friend_num > 0 then
        if b.friend_num ~= a.friend_num then
            return b.friend_num < a.friend_num;
        else
            return tonumber(b.corps_id) < tonumber(a.corps_id);
        end
    elseif (a.city == DataMgr.roleData.nation or b.city == DataMgr.roleData.nation) then
        if a.city == DataMgr.roleData.nation and b.city ~= DataMgr.roleData.nation then
            return true;
        elseif a.city ~= DataMgr.roleData.nation and b.city == DataMgr.roleData.nation then
            return false;
        else
            return tonumber(b.corps_id) < tonumber(a.corps_id);
        end
    elseif a.activeness > 0 or b.activeness > 0 then
        return b.activeness < a.activeness;
    else
        return tonumber(b.corps_id) < tonumber(a.corps_id);
    end
end

function CorpsSuggestionSystem.TagActiveness(suggestion_list)
    local tagCnt = 0;
    for k,v in pairs(suggestion_list) do
        if tagCnt < 3 and v.friend_num == 0 and (v.city ~= BP_Corps_Suggestion_CityID or v.city == 0) and v.activeness > 5000 then
            v.activeness_tag = true;
            tagCnt = tagCnt + 1;
        else
            v.activeness_tag = false;
        end
    end
end

-- 请求推荐列表 
-- 		need_approval=true    需审批
-- 		accord_requirement=true 符合要求
function CorpsSuggestionSystem.SendReqSuggestionList(need_approval, accord_requirement)
    local friendIDList = FriendSystem.UnionFriendIDList(ID_PLAT_FRIENDLIST, ID_INNER_FRIENDLIST);
    friendIDList = FuncUtil:TableSlice(friendIDList, 1, 200);
    -- log_tree("CorpsSuggestionSystem.SendReqSuggestionList ".. tostring(need_approval) .. " ".. tostring(accord_requirement), friendIDList);
    NetUtil.SendPkg("corps_suggestion_list_req", friendIDList, need_approval, accord_requirement);
end

local function GetFriendNumCount(memIDlist, friendList)
    local friendIDList = friendList or FriendSystem.UnionFriendIDList(ID_PLAT_FRIENDLIST, ID_INNER_FRIENDLIST);
    local count = 0;
    for k, v in ipairs(memIDlist) do
        for k1, v1 in ipairs(friendIDList) do
            if v == v1 then
                count = count + 1;
                break;
            end
        end
    end
    return count;
end

-- 请求已申请列表
function CorpsSuggestionSystem.SendReqApplicationList()
    -- log_tree("CorpsSuggestionSystem.SendReqApplicationList");
	NetUtil.SendPkg("corps_apply_join_list_req");
end

-- 搜索军团
function CorpsSuggestionSystem.SendReqSearch(corps_name)
    -- log_tree("CorpsSuggestionSystem.SendReqSearch", corps_name);
    local friendIDList = FriendSystem.UnionFriendIDList(ID_PLAT_FRIENDLIST, ID_INNER_FRIENDLIST);
    friendIDList = FuncUtil:TableSlice(friendIDList, 1, 200);
	NetUtil.SendPkg("find_corps_by_name_req", corps_name, friendIDList);
end

-- 返回推荐列表
function CorpsSuggestionSystem.corps_suggestion_list_rsp(msg, suggestion_list)
    -- log_tree("CorpsSuggestionSystem.corps_suggestion_list_rsp "..tostring(msg), suggestion_list);
    
    if msg ~= "ok" then
        CorpsSuggestionSystem.HandleErrorCode(msg);
        return
    end
    
    for k, v in pairs(suggestion_list) do
        CorpsSuggestionSystem.SuggestionList[k] = v;
    end

    local filterList = CorpsSuggestionSystem.FilterSuggestionList(not BP_Corps_Suggestion_NotNeedApproval, BP_Corps_Suggestion_AccordRequirement);
    BP_ARRAY_Corps_SuggestionList = {};
    for k,v in pairs(filterList) do
        local corpsInfo = CorpsSuggestionSystem.CreateSuggestItem(v);
        table.insert(BP_ARRAY_Corps_SuggestionList, corpsInfo);
    end

    if #BP_ARRAY_Corps_SuggestionList == 0 then
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SUGGESTIONLIST);
        return;
    end

    table.sort(BP_ARRAY_Corps_SuggestionList, CorpsSuggestionSystem.CompareItem);
    CorpsSuggestionSystem.TagActiveness(BP_ARRAY_Corps_SuggestionList);

    local afterSetGenderCallback = function()
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SUGGESTIONLIST);
    end

    CorpsSuggestionSystem.UpdateListGender(BP_ARRAY_Corps_SuggestionList, afterSetGenderCallback);
    
end

function CorpsSuggestionSystem.UpdateListGender(tar_list, call_back)
    local uidList = {};
    for k, v in pairs(tar_list) do
        table.insert(uidList, tonumber(tar_list[k].commander_id));
    end

    local function getProfileCallback(profileList)
        log_tree("suggestion_list gender", profileList);
        for k, v in pairs(profileList) do
            for _, info in pairs(tar_list) do
                if tonumber(info.commander_id) == tonumber(v.uid) then
                    info.commander_gender = v.sex;
                end
            end
        end

        if call_back ~= nil then
            call_back();
        end
    end

    ProfileMgr.GetProfileList(uidList, getProfileCallback, false);
end

function CorpsSuggestionSystem.CreateSuggestItem(svrInfo)
    local corpsInfo = {};
    CorpsSuggestionSystem.InitSuggestItem(corpsInfo, svrInfo);
    return corpsInfo;
end

function CorpsSuggestionSystem.InitSuggestItem(corpsInfo, svrInfo, friendIDList)
    corpsInfo.commander_id = tostring(svrInfo.commander);
    corpsInfo.commander_name = ProfileMgr.GetNickName(svrInfo.commander) or svrInfo.commander_name
    corpsInfo.level = svrInfo.level;
    corpsInfo.icon = svrInfo.icon;
    corpsInfo.corps_id = tostring(svrInfo.corps_id);
    corpsInfo.name = svrInfo.name;
    corpsInfo.friend_num = GetFriendNumCount(svrInfo.members, friendIDList);
    corpsInfo.city = svrInfo.city;
    corpsInfo.province = svrInfo.province;
    corpsInfo.activeness = svrInfo.activeness;
    corpsInfo.activeness_tag = false;
    corpsInfo.join_segment = svrInfo.join_segment;
    corpsInfo.join_level = svrInfo.join_level;
    corpsInfo.need_approval = svrInfo.need_approval;
    corpsInfo.announcement = svrInfo.announcement or "";
    corpsInfo.icon_text = svrInfo.icon_text or "";
    corpsInfo.icon_text_colour = svrInfo.icon_text_colour or 0;
    corpsInfo.BP_ARRAY_Corps_MemberList = {};
    for k,v in ipairs(svrInfo.members) do
        table.insert(corpsInfo.BP_ARRAY_Corps_MemberList, tostring(v));
    end
    corpsInfo.apply_index = svrInfo.index or 0;
end

-- 返回军团申请列表
function CorpsSuggestionSystem.corps_apply_join_list_rsp(msg, apply_list)
    --log_tree("CorpsSuggestionSystem.corps_apply_join_list_rsp "..tostring(msg), apply_list);
    
    if msg ~= "ok" then
        CorpsSuggestionSystem.HandleErrorCode(msg);
        return
    end
    
    BP_ARRAY_Corps_ApplicationList = {}
    BP_ARRAY_Corps_ApplicationTempIDList = {};
    for k,v in pairs(apply_list) do
    	local corpsInfo = CorpsSuggestionSystem.CreateSuggestItem(v);
        table.insert(BP_ARRAY_Corps_ApplicationList, corpsInfo);
        table.insert(BP_ARRAY_Corps_ApplicationTempIDList, tostring(v.corps_id));
    end

    table.sort(BP_ARRAY_Corps_ApplicationList, function(a, b) 
            return a.apply_index < b.apply_index;
        end);

    local afterSetGenderCallback = function()
        EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_SUGGESTIONLIST);
    end

    CorpsSuggestionSystem.UpdateListGender(BP_ARRAY_Corps_ApplicationList, afterSetGenderCallback);
end

-- 返回军团搜索列表
function CorpsSuggestionSystem.find_corps_by_name_rsp(res, corps_name, corps_info)
    -- log_tree("CorpsSuggestionSystem.find_corps_by_name_rsp "..tostring(res), corps_info);
	if res ~= "ok" then
		CorpsSuggestionSystem.HandleErrorCode(res);
		return;
	end
 	if corps_info ~= nil then
		BP_ARRAY_Corps_SearchList = {};
		local corpsInfo = CorpsSuggestionSystem.CreateSuggestItem(corps_info);
	    table.insert(BP_ARRAY_Corps_SearchList, corpsInfo);

        local afterSetGenderCallback = function()
            CorpsSuggestionUI.UpdateSearchResult();
        end

        CorpsSuggestionSystem.UpdateListGender(BP_ARRAY_Corps_SearchList, afterSetGenderCallback);
	end

end

-- 拉取被邀请列表
-- invited_corps_list
-- └─ 1
   -- ├─ invite_uid: 410000699
   -- ├─ invite_name: "abcd"
   -- ├─ status: 0
   -- ├─ corps_id: 100079
   -- └─ time: 0
function CorpsSuggestionSystem.InitInvitedCorpsArray(invited_corps_list)
    log("CorpsSuggestionSystem.InitInvitedCorpsArray #invited_corps_list "..#invited_corps_list)
    -- log_tree("CorpsSuggestionSystem.InitInvitedCorpsArray invited_corps_list", invited_corps_list);
    CorpsSuggestionSystem.InvitedCorpsArray = {};

    for i,v in ipairs(invited_corps_list) do
        table.insert(CorpsSuggestionSystem.InvitedCorpsArray, {
            invite_uid = v.invite_uid,
            invite_name = v.invite_name,
            invite_status = v.status,
            corps_id = tostring(v.corps_id),
            time = v.time or 0,
        });
    end

    CorpsSuggestionSystem.UpdateInvitedCorpsRedDot()
    EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_INVITED_CORPS_LIST);
end

function CorpsSuggestionSystem.UpdateInvitedCorpsRedDot()
    -- local logMsg = debug.traceback()
    -- log("CorpsSuggestionSystem.UpdateInvitedCorpsRedDot:"..logMsg);

    local hasNew = false;
    for i,v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
        if v.invite_status == 0 then
            hasNew = true;
            break;
        end
    end

    CorpsSuggestionSystem.hasNewIvitedCorps = hasNew;
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"))
    log("CorpsSuggestionSystem.UpdateInvitedCorpsRedDot CorpsSuggestionSystem.hasNewIvitedCorps "..tostring(CorpsSuggestionSystem.hasNewIvitedCorps))
end

function CorpsSuggestionSystem.GetInvitedCorpsDataByID(corps_id)
    corps_id = tostring(corps_id)

    for i,v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
        if v.corps_id == corps_id then
            return v;
        end
    end

    return nil;
end

--拉取受邀者列表
function CorpsSuggestionSystem.get_corps_invitee_list_req(isWaitting)
    log("CorpsSuggestionSystem.get_corps_invitee_list_req")

    if isWaitting == nil then
        isWaitting = true;
    end

    if isWaitting then
        NetUtil.SendPkg("get_corps_invitee_list_req");
    else
        NetUtil.SendPkg("get_corps_invitee_list_req");
    end
end

function CorpsSuggestionSystem.sync_corps_invitee_list(res, corps_list)
    log("CorpsSuggestionSystem.sync_corps_invitee_list")
    if res == "ok" then
        -- log_tree("CorpsSuggestionSystem.sync_corps_invitee_list corps_list", corps_list);
        CorpsSuggestionSystem.InitInvitedCorpsArray(corps_list)
    end
end

function CorpsSuggestionSystem.CurrentInvitedCorpsSummaryReq()
    local idList = {}
    for i,v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
        table.insert(idList, tonumber(v.corps_id));
    end

    CorpsMgr.batch_get_corps_summary_req(CorpsSuggestionSystem.UpdateInvitedCorpsSummary, idList);
end

function CorpsSuggestionSystem.UpdateInvitedCorpsSummary(invited_corps_summary_list)
    log("CorpsSuggestionSystem.UpdateInvitedCorpsSummary")
    if invited_corps_summary_list then
        log("CorpsSuggestionSystem.UpdateInvitedCorpsSummary invited_corps_summary_list len "..#invited_corps_summary_list)
        -- log_tree("CorpsSuggestionSystem.UpdateInvitedCorpsSummary InvitedCorpsArray1", CorpsSuggestionSystem.InvitedCorpsArray);
        for k,v in pairs(invited_corps_summary_list) do
            local idx, info = CorpsSuggestionSystem.GetInvitedCorpsKvpByID(v.corps_id);
            if info ~= nil then
                CorpsSuggestionSystem.InitSuggestItem(info, v);
            end
        end
        -- log_tree("CorpsSuggestionSystem.UpdateInvitedCorpsSummary InvitedCorpsArray2", CorpsSuggestionSystem.InvitedCorpsArray);
    else
        CorpsSuggestionSystem.InvitedCorpsArray = {}
    end
    CorpsSuggestionUI.UpdateInvitedCorpsSummaryList();
end

-- 修改邀请状态
function CorpsSuggestionSystem.change_invitee_status_req(index)
    local v = CorpsSuggestionSystem.InvitedCorpsArray[index];
    if v ~= nil then
        if v.invite_status == 0 then
            NetUtil.SendPkg("change_invitee_status_req", index);
        end
        v.invite_status = 1;

        CorpsSuggestionSystem.UpdateInvitedCorpsRedDot();
    end
end

function CorpsSuggestionSystem.change_invitee_status_rsp(res, index)
end

-- 通过ID获取下标
function CorpsSuggestionSystem.GetInvitedCorpsKvpByID(corps_id)
    -- log_tree("CorpsSuggestionSystem.GetInvitedCorpsKvpByID 1", corps_id)
    -- log_tree("CorpsSuggestionSystem.GetInvitedCorpsKvpByID CorpsSuggestionSystem.InvitedCorpsArray", CorpsSuggestionSystem.InvitedCorpsArray);
    corps_id = tostring(corps_id)
    -- log_tree("CorpsSuggestionSystem.GetInvitedCorpsKvpByID 2", corps_id)

    for i,v in ipairs(CorpsSuggestionSystem.InvitedCorpsArray) do
        if v.corps_id == corps_id then
            return i, v;
        end
    end

    return 0, nil;
end

-- 移除邀请列表
function CorpsSuggestionSystem.RemoveInvitedCorpsByID(corps_id)
    corps_id = tostring(corps_id)
    local isRemoved = false
    for i=#CorpsSuggestionSystem.InvitedCorpsArray, 1, -1 do
        local info = CorpsSuggestionSystem.InvitedCorpsArray[i]
        if info.corps_id == corps_id then
            table.remove(CorpsSuggestionSystem.InvitedCorpsArray, i)
            isRemoved = true;
        end
    end

    if not isRemoved then
        log("CorpsSuggestionSystem.RemoveInvitedCorpsByID remove failed : id "..tostring(corps_id))
    end
    -- log_tree("CorpsSuggestionSystem.RemoveInvitedCorpsByID CorpsSuggestionSystem.InvitedCorpsArray", CorpsSuggestionSystem.InvitedCorpsArray);
end

function CorpsSuggestionSystem.easy_apply_join_corps_req()
    NetUtil.SendPkg("easy_apply_join_corps_req");
end


function CorpsSuggestionSystem.easy_apply_join_corps_rsp(res, join_time, aoto_join_corpsid)
    log_tree("CorpsSuggestionSystem.easy_apply_join_corps_rsp "..tostring(res).. " " .. tostring(join_time), aoto_join_corpsid);
    if res == "ok" then
        if aoto_join_corpsid ~= nil then
            CorpsMgr.InitID(aoto_join_corpsid);
             -- 显示加入成功通知
            LuaClassObj.HandleUIMessage(bp_corps, "UIClose");
            EventOnCorpsClose();
            LobbySystem.OpenCorpsUI()
            LobbyChatLogic.CloseUI();
            ShowNotice(410031)
            EventCorpsInvitationUIClose();
        else
            ShowNotice(410079); -- 已发出申请
        end
    else
        if res == 411039 then
            local msg = CorpsMemberSystem.GetRemainTimeStr(res, join_time);
            PopUpNoticeUI.ShowNewNotice(msg);
        elseif res == 411038 then
            CorpsMgr.ShowCorpsLimitError();
        else
            ShowNotice(res);
        end
    end
end

s2c["corps_suggestion_list_rsp"] = CorpsSuggestionSystem.corps_suggestion_list_rsp;
s2c["corps_apply_join_list_rsp"] = CorpsSuggestionSystem.corps_apply_join_list_rsp;
s2c["find_corps_by_name_rsp"] = CorpsSuggestionSystem.find_corps_by_name_rsp;
s2c["sync_corps_invitee_list"] = CorpsSuggestionSystem.sync_corps_invitee_list;
s2c["change_invitee_status_rsp"] = CorpsSuggestionSystem.change_invitee_status_rsp;
s2c["easy_apply_join_corps_rsp"] = CorpsSuggestionSystem.easy_apply_join_corps_rsp;