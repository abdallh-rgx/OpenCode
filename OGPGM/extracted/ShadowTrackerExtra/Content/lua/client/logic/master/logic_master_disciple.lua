

MasterDiscipleSystem = MasterDiscipleSystem or
{
  ProfileReady = false,
  StatusReady = false,
  MaxProfileNum = 50,
  SummaryType = "", --recommend
  RecommendFriendIdList = {};
}

function MasterDiscipleSystem.RecommendFriendData(SubType)
  
  MasterDiscipleSystem.RecommendFriendIdList = {};

  local idlist = {};
  local recommendList = {};
  
  MasterDiscipleSystem.FilterFriendList(BP_ARRAY_All_Friend_Profile, recommendList, idlist, SubType);

  if (SubType == 1) then
      BP_ARRAY_RecommendDiscipleList = recommendList; --MasterDiscipleSystem.GetRandomList(recommendList, MasterDiscipleUI.MaxRecommendFriend);
      --log_tree("friend BP_ARRAY_RecommendDiscipleList", BP_ARRAY_RecommendDiscipleList);
  else
      BP_ARRAY_RecommendMasterList = recommendList; --MasterDiscipleSystem.GetRandomList(recommendList, MasterDiscipleUI.MaxRecommendFriend);
      --log_tree("friend BP_ARRAY_RecommendMasterList", BP_ARRAY_RecommendMasterList);
  end

   if (#idlist > 0) then
      MasterDiscipleSystem.master_batch_summary_req(idlist, "Recommend");
    else
      MasterDiscipleUI.SendServerRecommendReq();
   end
end


function MasterDiscipleSystem.FilterFriendList(friendList, recommendList, idlist, SubType)
    
    local CanNotTakeTeacherMaxHistoryRank = DataMgr.GetSystemConfig("CanNotTakeTeacherMaxHistoryRank"); --不能拜师的历史最高段位变量D 701
    local CanTakeTeacherMinLevel = DataMgr.GetSystemConfig("CanTakeTeacherMinLevel");   --能拜师的等级最小值B 10

    local CanGetApprenticeMinLevel = DataMgr.GetSystemConfig("CanGetApprenticeMinLevel");   --能收徒的等级最小值A
    local canGetApprenticeMinHistoryRank = DataMgr.GetSystemConfig("CanGetApprenticeMinHistoryRank"); --能收徒的要求的历史段位变量C 301

    local selfSegment = DataMgr.GetMaxHistoryRankLevel();
    local nowTime = os.time();
    --log_tree("friendList", friendList);
    if (friendList ~= nil and #friendList > 0) then
          local allFriendNum = #friendList;
          for i = 1, allFriendNum, 1 do 
                local friendData = friendList[i];

                local targetSegment = math.max(friendData.history_max_segment_level, friendData.segment_info_solo, friendData.segment_info_duo, friendData.segment_info_squad);
                local targetLevel = tonumber(friendData.level);
              
                local diff = nowTime - friendData.lastOnlineTime;
                local days = math.floor(diff/86400);
             
                local isMyMaster = MasterSystem.IsMyMaster(friendData.gid);
                local isMyDisciple = MasterSystem.IsMyDisciple(friendData.gid);

                --这里只过滤登陆时间在一周之内的好友
                if (isMyMaster == false and isMyDisciple == false and (friendData.online == 1 or days < 7)) then
                      if (SubType == 1) then
                            --推荐的徒弟的条件，玩家等级超过10级, 段位比自己低，没有打到过王者段位。在master_batch_summary_rsp判断是否有徒弟位置、师父位置，
                            if (#recommendList <= MasterDiscipleSystem.MaxProfileNum and targetLevel >= tonumber(CanTakeTeacherMinLevel) and targetSegment < selfSegment and targetSegment < tonumber(CanNotTakeTeacherMaxHistoryRank)) then
                                  friendData.isFriend = FriendSystem.IsInnerFriend(friendData.gid);
                                  table.insert(recommendList, friendData);
                                  table.insert(idlist, friendData.gid);
                            end
                      else
                            --推荐的师父的条件，玩家等级大于25，段位比自己高, 而且段位高于301。在master_batch_summary_rsp判断是否有徒弟位置、师父位置，
                            if (#recommendList <= MasterDiscipleSystem.MaxProfileNum and targetLevel >= tonumber(CanGetApprenticeMinLevel) and targetSegment >= tonumber(canGetApprenticeMinHistoryRank) and targetSegment > selfSegment) then
                                  friendData.isFriend = FriendSystem.IsInnerFriend(friendData.gid);
                                  table.insert(recommendList, friendData);
                                  table.insert(idlist, friendData.gid);
                            end
                      end
                end
          end
      end
end

function MasterDiscipleSystem.GetRandomList(recommendList, maxCount)
    if (#recommendList <= maxCount) then
        return recommendList;
    end

    local retList = {};
    for i = 1, maxCount, 1 do
      local len = #recommendList;
      local randomIndex = math.random(len);
      retList[i] = recommendList[randomIndex];
      table.remove(recommendList, randomIndex);
    end
    return retList;
end

 --收徒 申请成为师傅
function MasterDiscipleSystem.master_apply_teacher_req(uid, msg)
  log("master_apply_teacher_req uid = " .. tostring(uid) .. ", msg = " .. tostring(msg));

    NetUtil.SendPkg("master_apply_teacher_req", uid, msg);
end

--- -- 拜师 申请成为徒弟
function MasterDiscipleSystem.master_apply_student_req(uid, msg)
  log("master_apply_student_req uid = " .. tostring(uid) .. ", msg = " .. tostring(msg));
  NetUtil.SendPkg("master_apply_student_req", tonumber(uid), msg);
end

--- -- 推荐列表
--local apply_type_teacher = 1
--local apply_type_student = 2
function MasterDiscipleSystem.master_recommend_list_req(applytype, friendList)
  log("master_recommend_list_req applytype = " .. tostring(applytype));
  --log_tree("friendList", friendList);
  NetUtil.SendPkg("master_recommend_list_req", applytype, friendList);
end

function MasterDiscipleSystem.master_batch_summary_req(uidlist, SummaryType)
  MasterDiscipleSystem.SummaryType = SummaryType;
  log("master_batch_summary_req SummaryType = " .. tostring(SummaryType));
  --log_tree("uidlist", uidlist);
  NetUtil.SendPkg("master_batch_summary_req", uidlist);
end


 --收徒 申请成为师傅
function MasterDiscipleSystem.master_apply_teacher_rsp(res)
  log("master_apply_teacher_rsp res = " .. tostring(res));
  if (res == "ok") then
    MasterDiscipleUI.ReceiveDisicipleSuccess();
  else
     MasterSystem.ProtocolErroCode(tostring(res));
  end
end

--- -- 拜师 申请成为徒弟
function MasterDiscipleSystem.master_apply_student_rsp(res)
  log("master_apply_student_rsp res = " .. tostring(res));
  if (res == "ok") then
    MasterDiscipleUI.ReceiveMasterSuccess();
  else
     MasterSystem.ProtocolErroCode(tostring(res));
  end
end

function MasterDiscipleSystem.master_recommend_list_rsp(res, applytype, rlist)
  log("master_recommend_list_rsp res = " .. tostring(res) .. ", applytype = " .. tostring(applytype));
  if (res == "ok") then
    --log_tree("rlist", rlist);
    if (#rlist > 0) then
      local clientType = applytype == 1 and 2 or 1;
      local idlist = MasterDiscipleSystem.RemoveDuplicateIdList(clientType, rlist);
      --log_tree("idlist", idlist);
      ProfileMgr.GetProfileList(idlist,MasterDiscipleSystem.on_batch_get_server_recommend_profile_rsp);
      NetUtil.SendPkg("batch_get_group_and_online_req", "MasterServerRecommend", idlist);
    else
      MasterDiscipleUI.OnServerRecommendFail();
    end
  else
     MasterSystem.ProtocolErroCode(tostring(res));
  end
end

function MasterDiscipleSystem.RemoveDuplicateIdList(clientType, rlist)
  local serverIdDict = {};
  local len = 0;
  if (clientType == 1) then
        len = #BP_ARRAY_RecommendDiscipleList;
        for i = 1, len, 1 do
            serverIdDict[tostring(BP_ARRAY_RecommendDiscipleList[i].gid)] = 1;
        end
  else
       len = #BP_ARRAY_RecommendMasterList;
       for i = 1, len, 1 do
          serverIdDict[tostring(BP_ARRAY_RecommendMasterList[i].gid)] = 1;
       end
  end
  
  local idlist = {};
  for i = 1, #rlist, 1 do
      local isMyMaster = MasterSystem.IsMyMaster(rlist[i].uid);
      local isMyDisciple = MasterSystem.IsMyDisciple(rlist[i].uid)
      if (serverIdDict[tostring(rlist[i].uid)] == nil and isMyMaster == false and isMyDisciple == false) then
          table.insert(idlist, rlist[i].uid);
      end
  end

  local retIdList = MasterDiscipleSystem.GetRandomList(idlist, MasterDiscipleUI.MaxRecommendNum - len);
  return retIdList;
end

--搜索结果
function MasterDiscipleSystem.on_find_uid_by_name_rsp(res, name, uids)
  log("on_find_uid_by_name_rsp res = " .. tostring(res) .. ", name = " .. tostring(name));
  if (res == "ok") then
      MasterDiscipleSystem.ProfileReady = false;
      MasterDiscipleSystem.StatusReady = false;
      ProfileMgr.GetProfileList(uids,MasterDiscipleSystem.on_batch_get_search_profile_rsp);
      NetUtil.SendPkg("batch_get_group_and_online_req", "MasterDisciple", uids);
  else
      
      MasterDiscipleUI.ShowSearchFailResult();
  end
end

function MasterDiscipleSystem.CheckSearchReady()
  if (MasterDiscipleSystem.StatusReady == true and MasterDiscipleSystem.ProfileReady == true) then
      MasterDiscipleSystem.ProfileReady = false;
      MasterDiscipleSystem.StatusReady = false;
      MasterDiscipleUI.UpdateSearchList();
  end
end


function MasterDiscipleSystem.CheckServerRecommendReady()
  if (MasterDiscipleSystem.StatusReady == true and MasterDiscipleSystem.ProfileReady == true) then
      MasterDiscipleSystem.ProfileReady = false;
      MasterDiscipleSystem.StatusReady = false;
      MasterDiscipleUI.UpdateServerRecommendList();
  end
end

function MasterDiscipleSystem.on_batch_get_search_status_rsp()
  log("MasterDiscipleSystem.on_batch_get_search_status_rsp");
  MasterDiscipleSystem.StatusReady = true;
  MasterDiscipleSystem.CheckSearchReady();
end

function MasterDiscipleSystem.on_batch_get_server_recommend_status_rsp()
  log("MasterDiscipleSystem.on_batch_get_server_recommend_status_rsp");
  MasterDiscipleSystem.StatusReady = true;
  MasterDiscipleSystem.CheckServerRecommendReady();
end

function MasterDiscipleSystem.on_batch_get_server_recommend_profile_rsp(profileList)
  --log_tree("search profile:", profileList)
  
  if next(profileList) == nil then
    log("search empty")
    MasterDiscipleUI.OnServerRecommendFail();
    return
  end
  BP_ARRAY_ServerRecommendList = MasterDiscipleSystem.HandleProfileData(profileList);
 
  --log_tree("BP_ARRAY_Search_Friend_Profile:", BP_ARRAY_Search_Friend_Profile)
    --刷新查找列表
  MasterDiscipleSystem.ProfileReady = true; 
  MasterDiscipleSystem.CheckServerRecommendReady();
end

function MasterDiscipleSystem.on_batch_get_search_profile_rsp(profileList)
  --log_tree("search profile:", profileList)
  
  if next(profileList) == nil then
    log("search empty")
    MasterDiscipleUI.ShowSearchFailResult()
    return
  end
  BP_ARRAY_MasterDiscipleSearchList = MasterDiscipleSystem.HandleProfileData(profileList);
 
  --log_tree("BP_ARRAY_Search_Friend_Profile:", BP_ARRAY_Search_Friend_Profile)
    --刷新查找列表
  MasterDiscipleSystem.ProfileReady = true; 
  MasterDiscipleSystem.CheckSearchReady();
end

function MasterDiscipleSystem.HandleProfileData(profileList)
  local retList = {}
 for k,v in pairs(profileList) do
    local has = false
    for i = #retList,1,-1 do
      if tonumber(retList[i].gid) == tonumber(v.uid) then
        retList[i].nickName = v.nickName
        retList[i].level = v.level
        retList[i].vipLevel = v.vipLevel
        retList[i].picUrl = v.picUrl
        retList[i].platName = v.platName
        retList[i].sex = v.sex
        retList[i].signature = v.signature
        retList[i].lastOnlineTime = v.lastOnlineTime
        retList[i].lastOnlineTimeStr = FriendSystem.FormatTime(v.lastOnlineTime,"online")
        retList[i].lastLoginTime = v.lastLoginTime
        retList[i].exp = v.exp
        if v.segment_info then
          retList[i].segment_info_solo = v.segment_info[1]
          retList[i].segment_info_duo = v.segment_info[2]
          retList[i].segment_info_squad = v.segment_info[3]
        end
        retList[i].history_max_segment_level = v.history_max_segment_level;
        retList[i].startup_type = GetSafeNumber(v.startup_type)
        retList[i].qq_vip = GetSafeNumber(v.qq_vip)
        retList[i].cur_avatar_box_id = v.cur_avatar_box_id
        
        retList[i].isInnerFriendNotPlatFriend = FriendSystem.IsInnerFriendNotPlatFriend(v.uid)

        has = true
        break
      end
    end

    if not has then
      local data = {}
      data.gid = v.uid
      data.friendType = 0
      data.nickName = v.nickName
      data.level = v.level
      data.vipLevel = v.vipLevel
      data.picUrl = v.picUrl
      data.platName = v.platName
      data.sex = v.sex
      data.signature = v.signature
      data.lastOnlineTime = v.lastOnlineTime
      data.lastOnlineTimeStr = FriendSystem.FormatTime(v.lastOnlineTime,"online")
      data.lastLoginTime = v.lastLoginTime
      data.exp = v.exp
      if v.segment_info then
        data.segment_info_solo = v.segment_info[1]
        data.segment_info_duo = v.segment_info[2]
        data.segment_info_squad = v.segment_info[3]
      end
      data.history_max_segment_level = v.history_max_segment_level;
      data.startup_type = GetSafeNumber(v.startup_type)
      data.qq_vip = GetSafeNumber(v.qq_vip)
      data.cur_avatar_box_id = v.cur_avatar_box_id
      data.bPresentedCoin = 0
      data.lastPresentCoinTime = 0
      data.isInnerFriendNotPlatFriend = FriendSystem.IsInnerFriendNotPlatFriend(v.uid)
      table.insert(retList, data)
    end
  end

  if (#retList > 0) then
      for i = #retList,1,-1 do
          retList[i].isFriend = FriendSystem.IsInnerFriend(retList[i].gid);
      end
  end

  return retList;
end

function MasterDiscipleSystem.RandomRecommendFriendList(platFriendList, innerFriendList)
    
    --log_tree("platFriendList", platFriendList);
    --log_tree("innerFriendList", innerFriendList);

    local retList = {};
    if (#platFriendList >= MasterDiscipleUI.MaxRecommendFriend) then
        retList = MasterDiscipleSystem.GetRandomList(platFriendList, MasterDiscipleUI.MaxRecommendFriend);
        --log_tree("all plat friend retList", retList);
        return retList;
    else
        if (#platFriendList > 0) then
            for i = 1, #platFriendList, 1 do
                table.insert(retList, platFriendList[i]);
            end
        end

        if (#retList < MasterDiscipleUI.MaxRecommendFriend) then
            local innerRetList = MasterDiscipleSystem.GetRandomList(innerFriendList, MasterDiscipleUI.MaxRecommendFriend - #retList);
            if (#innerRetList > 0) then
                for i = 1, #innerRetList, 1 do
                    table.insert(retList, innerRetList[i]);
                end
            end
           --log_tree("innerRetList", innerRetList);
        end
    end
    --log_tree("retList", retList);
    return retList;
end

function MasterDiscipleSystem.HandleRecommendSummary(res, summary_list)
  if (res == "ok") then
      local platFriendList = {};
      local innerFriendList = {};

      if (BP_MasterDisciple_RecommendType == 1 and #BP_ARRAY_RecommendDiscipleList > 0) then

          for i = #BP_ARRAY_RecommendDiscipleList, 1, -1 do
       
            local friendData = BP_ARRAY_RecommendDiscipleList[i];
            local summary = summary_list[tonumber(friendData.gid)];
       
            if (summary ~= nil) then

                friendData.teacher_uid = summary.teacher_uid;
                friendData.student_num = summary.student_num;
                friendData.can_be_teacher = summary.can_be_teacher;
                friendData.max_history_rank = summary.max_history_rank;
                friendData.max_student_num = summary.max_student_num;

                --推荐徒弟条件：还没拜师
                if (friendData.teacher_uid > 0) then
                    --table.remove(BP_ARRAY_RecommendDiscipleList, i);
                else
                    local isPlat = FriendSystem.IsPlatFriend(friendData.gid);
                    if (isPlat) then
                        table.insert(platFriendList, friendData);
                    else
                        table.insert(innerFriendList, friendData);
                    end
                end
            else
                --table.remove(BP_ARRAY_RecommendDiscipleList, i);
            end
          end
          BP_ARRAY_RecommendDiscipleList = MasterDiscipleSystem.RandomRecommendFriendList(platFriendList, innerFriendList);
          MasterDiscipleSystem.SetRecommendFriendIdList(BP_ARRAY_RecommendDiscipleList);
         -- log_tree("master_batch_summary_rsp BP_ARRAY_RecommendDiscipleList", BP_ARRAY_RecommendDiscipleList);
       elseif (BP_MasterDisciple_RecommendType == 2 and #BP_ARRAY_RecommendMasterList > 0) then
          for i = #BP_ARRAY_RecommendMasterList, 1, -1 do
            local friendData = BP_ARRAY_RecommendMasterList[i];
            local summary = summary_list[tonumber(friendData.gid)];
            if (summary ~= nil) then
           
                friendData.teacher_uid = summary.teacher_uid;
                friendData.student_num = summary.student_num;
                friendData.can_be_teacher = summary.can_be_teacher;
                friendData.max_history_rank = summary.max_history_rank;
                friendData.max_student_num = summary.max_student_num;

                --推荐师父条件：对方已出师，而且徒弟数量没满
                if (friendData.can_be_teacher == false or (friendData.student_num ~= 0 and friendData.student_num >= friendData.max_student_num)) then
                    --table.remove(BP_ARRAY_RecommendMasterList, i);
                else
                      local isPlat = FriendSystem.IsPlatFriend(friendData.gid);
                    if (isPlat) then
                        table.insert(platFriendList, friendData);
                    else
                        table.insert(innerFriendList, friendData);
                    end
                end
            else
                --table.remove(BP_ARRAY_RecommendMasterList, i);
            end
          end
          BP_ARRAY_RecommendMasterList = MasterDiscipleSystem.RandomRecommendFriendList(platFriendList, innerFriendList);
          MasterDiscipleSystem.SetRecommendFriendIdList(BP_ARRAY_RecommendMasterList);
          --log_tree("master_batch_summary_rsp BP_ARRAY_RecommendMasterList", BP_ARRAY_RecommendMasterList);
       end
      MasterDiscipleUI.SendServerRecommendReq();
  else
      MasterSystem.ProtocolErroCode(tostring(res));
  end

end


function MasterDiscipleSystem.SetRecommendFriendIdList(list)
    MasterDiscipleSystem.RecommendFriendIdList = {};
    if (list ~= nil and #list > 0) then
        for i = 1, #list, 1 do 
            if (list[i] ~= nil and list[i].gid ~= nil) then
                local item = {};
                item.uid = tonumber(list[i].gid);
                table.insert(MasterDiscipleSystem.RecommendFriendIdList, item);
            end
        end
    end
end
--[[
03/01/22:13:17/DEBUG    infolist:
03/01/22:13:17/DEBUG    ├─ 410000002
03/01/22:13:17/DEBUG    │  ├─ can_be_teacher: false
03/01/22:13:17/DEBUG    │  ├─ teacher_uid: 0
03/01/22:13:17/DEBUG    │  ├─ max_history_rank: 505
03/01/22:13:17/DEBUG    │  ├─ max_student_num: 1
03/01/22:13:17/DEBUG    │  └─ student_num: 0
]]
function MasterDiscipleSystem.master_batch_summary_rsp(res, summary_list)
  log("master_batch_summary_rsp res = " .. tostring(res));
  --log_tree("summary_list", summary_list);
  if (MasterDiscipleSystem.SummaryType == "Recommend") then
      MasterDiscipleSystem.HandleRecommendSummary(res, summary_list);
  elseif (MasterDiscipleSystem.SummaryType == "RoleInfo") then
      RoleInfoUI.HandleRoleSummary(res, summary_list);
  end
end


s2c["master_apply_teacher_rsp"] = MasterDiscipleSystem.master_apply_teacher_rsp;  ---- 收徒 申请成为师傅
s2c["master_apply_student_rsp"] = MasterDiscipleSystem.master_apply_student_rsp;  ---- -- 拜师 申请成为徒弟
s2c["master_recommend_list_rsp"] = MasterDiscipleSystem.master_recommend_list_rsp;  ------ 推荐列表
s2c["master_batch_summary_rsp"] = MasterDiscipleSystem.master_batch_summary_rsp;  ------概要数据
