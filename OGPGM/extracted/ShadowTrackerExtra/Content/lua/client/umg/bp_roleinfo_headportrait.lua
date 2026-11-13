--设置头像UI
RoleInfoHeadportraitUI = RoleInfoHeadportraitUI or
{
    bShow = false,
    headerProgress = {}
}

BP_STRUCT_RoleInfoHeadportrait =
{
	id = 0,
    name = "",
    state = "",     --状态 use使用中,has拥有,none未拥有
    desc = "",      --描述
    desc_get = "",  --获得途径
    path = "",      --path or url
    redpoint = 0,   --红点
};

BP_ARRAY_RoleInfoHeadportraitList =
{
    BP_STRUCT_RoleInfoHeadportrait = _G.BP_STRUCT_RoleInfoHeadportrait,
};

RoleInfoHeadportraitSelfUid = "";
RoleInfoHeadportraitSelfUrl = "";
RoleInfoHeadportraitSelfFrameId = 0;

RoleInfoHeadportraitSelfSelectId = 0;
RoleInfoHeadportraitSelfSelectUrl = "";

RoleInfoHeadportraitSelf_Progress = "";

--注册Widget
function bp_roleinfo_headportrait_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_headportrait,
		{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Headportrait_BP.RoleInfo_Headportrait_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+20}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function RoleInfoHeadportraitUI.Show()
    EventSystem:registEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, RoleInfoHeadportraitUI.UpdateHeadInfo);

	LuaClassObj.HandleDynamicCreation(bp_roleinfo_headportrait);
    RoleInfoHeadportraitSelfUid = tostring(DataMgr.roleData.uid);
    RoleInfoHeadportraitSelfUrl = DataMgr.roleData.headIconUrl;
    RoleInfoHeadportraitSelfFrameId = DataMgr.roleData.cur_avatar_box_id;
    LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "ShowUI");
    RoleInfoHeadportraitUI.bShow = true;
    
    RoleInfoHeadportraitSystem.get_unlock_progress_req();
    UIManager.Show(eUIType.eHeadportrait)
end

function RoleInfoHeadportraitUI.Refresh()
    BP_ARRAY_RoleInfoHeadportraitList = {}
	log("RoleInfoHeadportraitUI.Refresh, headIconUrl = " .. tostring(DataMgr.roleData.headIconUrl));
    --log_tree("BP_ARRAY_RoleInfoHeadportraitList = ", BP_ARRAY_RoleInfoHeadportraitList)

    local data = Client.GetTable("Headportrait");
	--local GCloudChannelID = Client.GetLoginChannel(NetInterface);
    for k, v in pairs(data) do
        if v.isShow then
            local dat = FuncUtil:CopyTable(BP_STRUCT_RoleInfoHeadportrait)
            dat.id = v.ID
			log("RoleInfoHeadportraitUI.Refresh, id = " .. tostring(dat.id));
            dat.name = v.Name
			log("RoleInfoHeadportraitUI.Refresh, name = " .. tostring(dat.name));
            dat.path = v.Icon;
            dat.desc = v.Desc
            dat.desc_get = v.UnlockDesc
            local show = true;
            local itm = RoleInfoHeadportraitSystem.HeadportraitList[tostring(v.ID)]
            if itm ~= nil then
				log("RoleInfoHeadportraitUI.Refresh, itm: " .. tostring(itm));
                dat.state = "has"
                if v.ID == 10002 then
                    dat.path = itm;
                end

                if DataMgr.roleData.headIconUrl == tostring(v.ID) then
                    dat.state = "use"
                else
                    if v.ID == 10002 then
                        local s, e = string.find(DataMgr.roleData.headIconUrl, "http");
                        if s ~= nil then
                            dat.state = "use";
                        end
                    end
                end
            else
				log("RoleInfoHeadportraitUI.Refresh, dat.state = none id = " .. tostring(v.ID));
                dat.state = "none"
                if v.ID == 10002 then
                    show = false;
                end
            end
			
			--当前登录渠道只要不是空或者游客，都算是社交平台渠道
			--跟策划后台沟通，先不这么改了
			--if v.ID == 10002 and GCloudChannelID ~= 0 and GCloudChannelID ~= 5 then
			--	dat.state = "use";
			--end
			
            local reditem = RoleInfoHeadportraitSystem.RedpointList[tostring(v.ID)]
            if reditem ~= nil then
                dat.redpoint = 1;
            else
                dat.redpoint = 0;
            end

            --if show == true then
            table.insert(BP_ARRAY_RoleInfoHeadportraitList, dat)
            --else
            --    log("[HHF]RoleInfoHeadportraitUI.Refresh, have didn't bind facebook!");
            --end
        else
            log("[HHF]RoleInfoHeadportraitUI.Refresh, hiden headportrait id = " .. tostring(v.ID));
        end;
    end

    local weight = {
        use = 1,
        has = 1,
        none = 100,
    }
    
    local function funcSort(a, b)
        return (a.id * weight[a.state]) < (b.id * weight[b.state])
    end
    table.sort(BP_ARRAY_RoleInfoHeadportraitList, funcSort)
    --log_tree("BP_ARRAY_RoleInfoHeadportraitList = ", BP_ARRAY_RoleInfoHeadportraitList)
    LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "RefreshUI");
end

function RoleInfoHeadportraitUI.RefreshSelect()
	log("RoleInfoHeadportraitUI.RefreshSelect, headIconUrl = " .. tostring(DataMgr.roleData.headIconUrl));
    --log_tree("BP_ARRAY_RoleInfoHeadportraitList = ", BP_ARRAY_RoleInfoHeadportraitList)
    local data = Client.GetTable("Headportrait");
    for i, v in ipairs(BP_ARRAY_RoleInfoHeadportraitList) do
        local itm = RoleInfoHeadportraitSystem.HeadportraitList[tostring(v.id)]
		log("RoleInfoHeadportraitUI.RefreshSelect, test0 " .. tostring(itm));
        if itm ~= nil then
            v.state = "has"                        
            if DataMgr.roleData.headIconUrl == tostring(v.id) then
                v.state = "use"
                log("[HHF]RoleInfoHeadportraitUI.RefreshSelect, use " .. tostring(v.id));
            else
                if v.id == 10002 then
                    local s, e = string.find(DataMgr.roleData.headIconUrl, "http");
                    if s ~= nil then
                        v.state = "use";
                        log("[HHF]RoleInfoHeadportraitUI.RefreshSelect, use Social or Platform Head");
                    end
                end
            end
        else
            v.state = "none"
        end
    end
    LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "RefreshSelect");
end

function RoleInfoHeadportraitUI.IsShow()
    return RoleInfoHeadportraitUI.bShow;
end

function RoleInfoHeadportraitUI.Release()
    EventSystem:unregistEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_HEAD_INFO, RoleInfoHeadportraitUI.UpdateHeadInfo);
end

function RoleInfoHeadportraitUI.UpdateHeadportraitIDByUrl(url)
	log("RoleInfoHeadportraitUI.UpdateHeadportraitIDByUrl url: " .. tostring(url));
	log("RoleInfoHeadportraitUI.UpdateHeadportraitIDByUrl RoleInfoHeadportraitSelfSelectUrl: " .. tostring(RoleInfoHeadportraitSelfSelectUrl));
    local s, e = string.find(url, "http");
	--local GCloudChannelID = Client.GetLoginChannel(NetInterface);
	--log("RoleInfoHeadportraitUI.UpdateHeadportraitIDByUrl GCloudChannelID: " .. tostring(GCloudChannelID));
    if s ~= nil then
        RoleInfoHeadportraitSelfSelectId = 10002;
	--当前登录渠道只要不是空或者游客，都算是社交平台渠道
	--elseif GCloudChannelID ~= 0 and GCloudChannelID ~= 5 then
    --    RoleInfoHeadportraitSelfSelectId = 10002;
	else
        RoleInfoHeadportraitSelfSelectId = tonumber(url);
    end
    RoleInfoHeadportraitSelfSelectUrl = RoleInfoHeadportraitSelfSelectId;
    log("[HHF]RoleInfoHeadportraitUI.UpdateHeadportraitIDByUrl, id = " .. tostring(RoleInfoHeadportraitSelfSelectId) .. ", url = " .. RoleInfoHeadportraitSelfSelectUrl)
end

function RoleInfoHeadportraitUI.SetProgress(curCount, maxCount)
    if curCount >= 0 and maxCount > 0 then
        RoleInfoHeadportraitSelf_Progress = string.format("%d/%d", curCount, maxCount);
    else
        RoleInfoHeadportraitSelf_Progress = "";
    end
    LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "UpdateProgress");
end

function EventRoleInfoHeadportraitUse()
    RoleInfoHeadportraitSystem.change_headportrait(tostring(RoleInfoHeadportraitSelfSelectId));
end

function EventRoleInfoHeadportraitFetchInfo()
    local strID = tostring(RoleInfoHeadportraitSelfSelectId);
    if RoleInfoHeadportraitSelfSelectId == 10002 then
        RoleInfoHeadportraitSelfSelectUrl = RoleInfoHeadportraitSystem.HeadportraitList[strID];
        if RoleInfoHeadportraitSelfSelectUrl == nil then
            RoleInfoHeadportraitSelfSelectUrl = "";
        end
    else
        RoleInfoHeadportraitSelfSelectUrl = strID;
    end
    
    RoleInfoHeadportraitSystem.UpdateRedpoint(strID);
    log("[HHF]EventRoleInfoHeadportraitFetchInfo, UpdateURLByID id = " .. tostring(RoleInfoHeadportraitSelfSelectId) .. ", url = " .. RoleInfoHeadportraitSelfSelectUrl)
end

function EventRoleInfoHeadportraitUIClose()
    RoleInfoHeadportraitSystem.Release();
    RoleInfoHeadportraitUI.Release();
    RoleInfoHeadportraitUI.bShow = false;
end

function EventRoleInfoHeadportraitGetProgress()
    local progress = RoleInfoHeadportraitUI.headerProgress[tostring(RoleInfoHeadportraitSelfSelectId)];
    if progress and progress.curCount >= 0 and progress.maxCount > 0 then
        RoleInfoHeadportraitSelf_Progress = string.format("%d/%d", progress.curCount, progress.maxCount);
    else
        RoleInfoHeadportraitSelf_Progress = "";
    end
    LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "UpdateProgress");
end


function RoleInfoHeadportraitUI.HideUI()
    log("RoleInfoHeadportraitUI.HideUI");
    LuaClassObj.HandleUIMessage(bp_roleinfo_headportrait, "HideUI");
    UIManager.Hide(eUIType.eHeadportrait)
end

-- 头像列表信息事件通知更新
function RoleInfoHeadportraitUI.UpdateHeadInfo(eventType, eventID, headportraiturl)
    RoleInfoHeadportraitUI.UpdateHeadportraitIDByUrl(headportraiturl);
    if RoleInfoHeadportraitUI.IsShow() then
        RoleInfoHeadportraitUI.Refresh()
    end
    --刷新个人信息界面与大厅界面的头像
    RoleInfoUI.UpdateHeadportrait()
    -- 更新大厅显示数据
    LobbyUI:RefreshPlayerData()
end