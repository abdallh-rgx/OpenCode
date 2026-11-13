-- 分队UI
AllianceRoleInfoUI = AllianceRoleInfoUI or 
{
	isShowing = false;
    teamId = 0;
    NationFlagId = nil;
    --最好成绩
    stage = 0;
    rank = 0;
    group_id = 0;
    carteam = {};
}

-- 分队相关数据结构
BP_STRUCT_AllianceInfo_RoleInfo ={
    aid = "",               -- 分队ID
    name = "",              -- 分队名称
    icon = "",              -- 分队资源图标路径
    iconId = 0,             -- 分队图标ID
    notice = "",            -- 分队公告
    memberNum = 0,          -- 分队人数 
    captainId = "",         -- 分队长资料
    captainName = "",       -- 分队长资料
    trainValue = 0,         -- 训练值
    bonusPercent = 0,       -- 训练奖励
    bind_group = "0",        -- 绑定群
}

--分队列表
BP_ARRAY_AllianceRoleInfo_Info_List =
{
    tmp_UseExist_BP_STRUCT_AllianceInfo = {},
}

--分队成员列表
BP_ARRAY_AllianceRoleInfo_Member_Profile_List =
{
    tmp_UseExist_BP_STRUCT_AllianceMemberProfile = {},
}

-- 选择人员profile
BP_STRUCT_SelectedRoleInfo_Member_Profile = BP_STRUCT_AllianceMemberProfile

BP_AllianceRoleInfo_Selected_Member_Id = ""

BP_AllianceRoleInfo_SelfUID = ""

--国籍
BP_AllianceRoleInfo_NationFlagUrl = "";

--是否有最好成绩
BP_AllianceRoleInfo_HasHistory = false;
--最好成绩str
BP_AllianceRoleInfo_HistoryStr = "";
--switch索引
BP_AllianceRoleInfo_RankIndex = 0;
--注册Widget
function bp_allianceForRoleInfo_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_allianceForRoleInfo,
    {
        {Path="/Game/UMG/UI_Logic/Lobby_Team/LobbyTeamOther_LogicBP.LobbyTeamOther_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_PersonInfo},
        
    },
    {"Lobby"},
	false,
	false,
	true
  );

   --EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, AllianceRoleInfoUI.HandleIOSCheck);
end

function AllianceRoleInfoUI.HandleIOSCheck()
    -- body
    if GlobalData:IsIOSCheck() then
        LuaClassObj.SubCollapseWidgetList(bp_allianceForRoleInfo,
        "LobbyTeamOther_LogicBP_C",
        {
            "PlatformGroupBtns",
        }
    );
    LuaClassObj.HandleCollapseWidgetList(bp_allianceForRoleInfo, "LobbyTeamOther_LogicBP_C");
    end
end

function EventFetchInfo()	
end

function EventSetInfo_Push()
end

--协议错误码处理
function AllianceRoleInfoUI.ProtocolErroCode(errorString, param)

    if errorString == "already-in-carteam" then
        --已经在车队里
         --DataMgr.ShowNoticeByString("已经在车队里");
         DataMgr.ShowNoticeByID(117001);
    elseif errorString == "not-in-carteam" then
        --不在车队里
        --DataMgr.ShowNoticeByString("不在车队里");
        DataMgr.ShowNoticeByID(117002);
    elseif errorString == "carteam-exists" then
        --车队已存在  
        --DataMgr.ShowNoticeByString("车队已存在");
        DataMgr.ShowNoticeByID(117003);
    elseif errorString == "db-error" then
        --DB出错
        --DataMgr.ShowNoticeByString("DB出错");
        DataMgr.ShowNoticeByID(117004);
    elseif errorString  == "insert-offmsg-failed" then  
        --插入离线消息失败 
        --DataMgr.ShowNoticeByString("插入离线消息失败");   
        DataMgr.ShowNoticeByID(117005);  
    elseif errorString == "invite-already" then
        --已被邀请
        --DataMgr.ShowNoticeByString("已被邀请");
        DataMgr.ShowNoticeByID(117006); 
    elseif errorString == "have-member-in-carteam" then
        --队长退出时, 车队还有其它人
        --DataMgr.ShowNoticeByString("车队还有其它人");
        DataMgr.ShowNoticeByID(117007);
    elseif errorString == "carteam-not-exists" then
        --车队不存在
        --DataMgr.ShowNoticeByString("车队不存在");
        DataMgr.ShowNoticeByID(117008);
    elseif errorString == "not-carteam-leader" then  
        --不是车队队长
        --DataMgr.ShowNoticeByString("不是车队队长");  
        DataMgr.ShowNoticeByID(117009);
    elseif errorString == "not-invited" then      
        --没被邀请
        --DataMgr.ShowNoticeByString("没被邀请");
        DataMgr.ShowNoticeByID(117010);
        
    elseif errorString == "level-not-enough" then  
        --创建时,等级不够
        local tipsStr = DataMgr.GetMsgByID(117011) -- "达到%s才能创建车队!";
        local rankConfig = Client.GetTableData("MilitaryRankLevel", param);	
        local name = ""
        if rankConfig ~= nil then
            name = rankConfig.MilitaryRankName
        end
        local strFormat = string.format(tipsStr, tostring(param), name);

        DataMgr.ShowNoticeByString(strFormat);
        
    elseif errorString == "carteam-is-full" then  
        --车队已满      
        DataMgr.ShowNoticeByID(117012);       
        
    elseif errorString == "create-too-much-today" then
        -- 当天创建次数过多
        --DataMgr.ShowNoticeByString("当天创建次数过多"); 
        DataMgr.ShowNoticeByID(117013);  
    
    elseif errorString == "group-not-bind" then
        -- 群尚未绑定
        --DataMgr.ShowNoticeByString("群尚未绑定");  
        DataMgr.ShowNoticeByID(117037);  
        
    elseif errorString == "apollo-failed" then
        -- 解绑失败，Apollo内部错误
        --DataMgr.ShowNoticeByString("解绑失败");  
        --DataMgr.ShowNoticeByID(117038);  
        DataMgr.ShowNoticeByID(117051);  

    elseif errorString == "bind-apollo-failed" then
        -- 解绑失败，Apollo内部错误
        --DataMgr.ShowNoticeByString("解绑失败");  
        --DataMgr.ShowNoticeByID(117038);  
        DataMgr.ShowNoticeByID(117052);  
        
    elseif errorString == "get-apollo-failed" then
        -- 解绑失败，Apollo内部错误
        --DataMgr.ShowNoticeByString("解绑失败");  
        --DataMgr.ShowNoticeByID(117038);  
        DataMgr.ShowNoticeByID(117055);  
    
    elseif errorString == "join-apollo-failed" then
        -- 解绑失败，Apollo内部错误
        --DataMgr.ShowNoticeByString("解绑失败");  
        --DataMgr.ShowNoticeByID(117038);  
        DataMgr.ShowNoticeByID(117053);  
    
    elseif errorString == "have-bind-this-day" then
        -- 解绑失败，Apollo内部错误
        --DataMgr.ShowNoticeByString("今天已经创建过群了");  
        DataMgr.ShowNoticeByID(117056);  
        
    elseif errorString == "unbind-apollo-failed" then
        -- 解绑失败，Apollo内部错误
        --DataMgr.ShowNoticeByString("解绑失败");  
        --DataMgr.ShowNoticeByID(117038);  
        DataMgr.ShowNoticeByID(117054);  
       
    elseif errorString == "name-is-empty" then
        -- 名字为空
        --DataMgr.ShowNoticeByString("名字为空");  
        DataMgr.ShowNoticeByID(117039);  
        
    elseif errorString == "name-too-short" then
        -- 名字太短
        --DataMgr.ShowNoticeByString("名字太短"); 
        DataMgr.ShowNoticeByID(117039);  
        
    elseif errorString == "name-too-long" then
        -- 名字太长
        --DataMgr.ShowNoticeByString("名字太长"); 
        DataMgr.ShowNoticeByID(117041);  
        
    elseif errorString == "have-dirty-in-name" then
        -- 含有敏感词
        --DataMgr.ShowNoticeByString("名字含有敏感词"); 
        DataMgr.ShowNoticeByID(117042);  
    
    elseif errorString == "announcement-too-long" then
        -- 公告太长
        --DataMgr.ShowNoticeByString("公告太长"); 
        DataMgr.ShowNoticeByID(117043);  
    
    elseif errorString == "have-dirty-in-announcement" then
        -- 公告中含敏感词
        --DataMgr.ShowNoticeByString("公告中含敏感词"); 
        DataMgr.ShowNoticeByID(117044); 

    elseif errorString == "already-join" then
        -- 已经发出申请
        DataMgr.ShowNoticeByID(117059);  
        
    elseif errorString == "daily-req-join-limited" then
        -- 每天最多申请x次
        local tipsStr = DataMgr.GetMsgByID(117058);        
        log(tipsStr)
        DataMgr.ShowNoticeByString(string.format(tipsStr, tostring(param)));             
    elseif errorString == "time-out" then
        -- Time out
        DataMgr.ShowNoticeByID(117060);
    
    elseif errorString == "joined-other-carteam" then
        -- 已加入其他车队
        DataMgr.ShowNoticeByID(117061);
        
    elseif errorString == "already-accept" then
        -- 已获得该车队邀请
        DataMgr.ShowNoticeByID(117064);
        ---------------------------------------------------客户端的提示-------------- 
    elseif errorString == "client-apply-send-ok" then
        -- 已经发出申请
        DataMgr.ShowNoticeByID(117057);  
        
    elseif errorString == "client_send_ok" then
        --DataMgr.ShowNoticeByString("邀请已经发送");
         DataMgr.ShowNoticeByID(117014);  
        
    elseif errorString == "cline_JoinCarTeam" then
        local tipsStr =DataMgr.GetMsgByID(117015); -- "恭喜你成为<MessageProductColor>%s</>车队一员,今后请和大家一起建设车队吧!";
        local strFormat = string.format(tipsStr,param);
        local promptTip = FuncUtil.GetLocalizeResStr("101001");
        CommonMessageBoxUI:ShowPanel(1, promptTip, strFormat);
    else
         DataMgr.ShowNoticeByID(errorString)
    end
    
end


--初始化
function AllianceRoleInfoUI.Init(carteam)
    AllianceRoleInfoUI.SetData(carteam);
    AllianceRoleInfoUI.Show();
end



function AllianceRoleInfoUI.SetData(carteam)
    if carteam then
        AllianceRoleInfoUI.teamId = carteam.team_id;
        BP_STRUCT_AllianceInfo_RoleInfo.iconId = carteam.icon;
        BP_STRUCT_AllianceInfo_RoleInfo.name = carteam.name or "";
        BP_STRUCT_AllianceInfo_RoleInfo.notice = carteam.announcement or "";
        if carteam.leader then
            if not carteam.team_flag then
                carteam.team_flag = 1;
            else
                carteam.team_flag = tonumber(carteam.team_flag);
            end
            BP_STRUCT_AllianceInfo_RoleInfo.icon = AllianceRoleInfoUI.getGuidonUrl(carteam.team_flag);
        end

        --成员数量
        local member = 0;
        if carteam.members then
            for k,v in pairs(carteam.members) do
                --已加入的成员判断
                if v.status == 3 then
                    member = member + 1;
                end
            end
        end
        BP_STRUCT_AllianceInfo_RoleInfo.memberNum = member;
        --国籍
        AllianceRoleInfoUI.NationFlagId = carteam.nation_flag;
        BP_AllianceRoleInfo_NationFlagUrl = AllianceRoleInfoUI.getNationFlagUrl();
        BP_STRUCT_AllianceInfo_RoleInfo.captainName = carteam.leader.name;
        --赛事最好成绩
        if carteam.league_history and carteam.league_history.best_rank then
            BP_AllianceRoleInfo_HasHistory = true;
            local list = {};
            for _k, _v in pairs(carteam.league_history.best_rank) do
                table.insert(list, _v);
            end
            table.sort(list, function(a, b)
                return a.rank_no < b.rank_no
            end);
            AllianceRoleInfoUI.stage = list[1].stage;
            AllianceRoleInfoUI.rank = list[1].rank_no;
            AllianceRoleInfoUI.group_id = list[1].group_id;
            BP_AllianceRoleInfo_HistoryStr = AllianceRoleInfoUI.getTeamMainRankContentText();

            --设置index
            if AllianceRoleInfoUI.stage == AllianceCompetitionSystem.FirstStep.GROUP_MATCH then
                BP_AllianceRoleInfo_RankIndex = 2
            end
            if AllianceRoleInfoUI.stage == AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH then
                if AllianceRoleInfoUI.rank == 1 then
                    BP_AllianceRoleInfo_RankIndex = 0
                else
                    BP_AllianceRoleInfo_RankIndex = 1
                end
            end
        else
            BP_AllianceRoleInfo_HasHistory = false;
        end
    end
end

function AllianceRoleInfoUI.SetCarTeamData(carteam)
    log_tree("AllianceRoleInfoUI.SetCarTeamData", carteam);
    AllianceRoleInfoUI.carteam = carteam;
end

function AllianceRoleInfoUI.Show()
    LuaClassObj.HandleDynamicCreation(bp_allianceForRoleInfo);
    LuaClassObj.HandleUIMessage(bp_allianceForRoleInfo, "SetTeamData");
    LuaClassObj.HandleUIMessageNoFetch(bp_allianceForRoleInfo, "ShowSelf");
    UIManager.Show(eUIType.eAllianceForRoleInfo);
end

function EventAllianceRoleInfoHide()
    UIManager.Hide(eUIType.eAllianceForRoleInfo);
end

function AllianceRoleInfoUI.UpdateMemberList()
    if AllianceRoleInfoUI.carteam and AllianceRoleInfoUI.carteam.leader then
        for k,v in pairs(BP_ARRAY_AllianceRoleInfo_Member_Profile_List) do
            if tonumber(v.gid) == AllianceRoleInfoUI.carteam.leader.uid then
                v.isCaptain = true;
            else
                v.isCaptain = false;
            end
        end
    end
    LuaClassObj.HandleUIMessage(bp_allianceForRoleInfo, "SetTeamData");
end

function AllianceRoleInfoUI.getGuidonUrl(iconId)
    if iconId == nil then
        local allNationCode = {};
        for k,v in pairs(Client.GetTable("GuidonConfig")) do
            table.insert(allNationCode, k)
        end

        local data = CountryareaUI.SortNationCode(allNationCode)
        iconId = data[1]
    end

    if Client.GetTable("GuidonConfig")[iconId] == nil then return "" end
    return Client.GetTable("GuidonConfig")[iconId].res_path;
end

function AllianceRoleInfoUI.getNationFlagUrl()
    local tabRegion = FuncUtil.GetRegionConfigTable();
    if AllianceRoleInfoUI.NationFlagId == nil then
        local allNationCode = {};
        for k,v in pairs(tabRegion) do
            table.insert(allNationCode, k)
        end

        local data = CountryareaUI.SortNationCode(allNationCode)
        AllianceRoleInfoUI.NationFlagId = data[1]
    end
    if tabRegion[AllianceRoleInfoUI.NationFlagId] == nil then return "" end
    return tabRegion[AllianceRoleInfoUI.NationFlagId].res_path;
end


function AllianceRoleInfoUI.getTeamMainRankContentText()
    local text = ""
    if AllianceRoleInfoUI.stage == 0 or AllianceRoleInfoUI.rank == 0 or AllianceRoleInfoUI.group_id == 0 then
        return text;
    end
    if AllianceRoleInfoUI.stage == AllianceCompetitionSystem.FirstStep.GROUP_MATCH then
        text = Client.GetTableData("LocalizeRes",6346).TextValue

        text = string.gsub(text, "{0}", AllianceCompetitionSystem.GruopStr[AllianceRoleInfoUI.group_id]);
        text = string.gsub(text, "{1}", AllianceRoleInfoUI.rank)
    end

    if AllianceRoleInfoUI.stage == AllianceCompetitionSystem.FirstStep.ZONE_FINAL_MATCH then
        text = Client.GetTableData("LocalizeRes",6347).TextValue
        text = string.gsub(text, "{0}", AllianceRoleInfoUI.rank)
    end
    return text
end

-- 点击查看个人信息
function EventAllianceRoleInfoClickOpenView()
    log("EventAllianceClickOpenView"..BP_Alliance_Selected_Member_Id)
    RoleInfoSystem.Enter(BP_Alliance_Selected_Member_Id)
    RoleInfoUI.Init(true, RoleInfoOpenFromType.AllianceRoleInfo);
end

-- 点击添加好友
function EventAllianceRoleInfoClickAddFriend()
    log("EventAllianceClickAddFriend"..BP_Alliance_Selected_Member_Id)
    local sex = 0
    for k,v in pairs(BP_ARRAY_Alliance_Member_Profile_List) do
        if v.gid == tostring(BP_Alliance_Selected_Member_Id) then
            sex = v.sex
        end
    end
    
    if sex == 1 then
        FriendSystem.AddFriend(BP_Alliance_Selected_Member_Id, BP_ENUM_ADD_FRIEND_FROM_ALLIANCE, 17)
    else
        FriendSystem.AddFriend(BP_Alliance_Selected_Member_Id, BP_ENUM_ADD_FRIEND_FROM_ALLIANCE, 18)
    end
end

-- 点击聊天
function EventAllianceRoleInfoClickChat()
    log("EventAllianceClickChat"..BP_Alliance_Selected_Member_Id)
    LobbyChatSystem.ChatWithFriend(BP_Alliance_Selected_Member_Id)	
end

--申请加入
function EventAllianceRoleInfoJoin()
    AllianceSystem.join_carteam_req(tonumber(AllianceRoleInfoUI.teamId));
end