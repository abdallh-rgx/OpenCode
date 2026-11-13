--[[
 师徒相关逻辑
]]--

MasterSystem = MasterSystem or
{   
    my_student_list={};
    same_students_list={};
    my_teacher_uid="";
    teacher_info={};
    dismissother_uid=0;
    apply_req_list = {}; --申请列表前台缓存

    client_redpoint_task=false ;
    client_redpoint_privilege=false ;
    client_redpoint_apply=false ;

    --记录申请列表接受、或者拒绝标记
    flagApplyOp = 0;
    teacher_name = "";
    task_state = 1;
}
----login begin


--是否有师父
function  MasterSystem.HasMaster()
    return MasterSystem.my_teacher_uid ~= "" ;
end

function MasterSystem.on_master_status_req(list)
    --log_tree("MasterSystem.on_master_status_req:",list);
    NetUtil.SendPkg("batch_get_group_and_online_req","MasterAndDisciple",list);
  end
  
  
  function MasterSystem.on_master_status_rsp(listType,res,infos)
    if res == "ok" then
          if listType == "MasterAndDisciple" then
              MasterUI.UpdateOnLineInfo(infos);
          end
      else
          log("MasterSystem.on_master_status_rsp fail:"..res)
      end
  end

function MasterSystem.IsRedPoint()
    return MasterSystem.client_redpoint_task or MasterSystem.client_redpoint_privilege or MasterSystem.client_redpoint_apply;
end

-- 客服端主动设置红点
-- flag true 代表 显示红点 , false 代表不显示红点
--sys  1: 任务红点  2：特权红点 3：申请列表红点
function MasterSystem.ClientSetRedPoint(flag,sys)
    log("devindzhang MasterSystem.ClientSetRedPoint::"..tostring(flag)..tostring(sys)) ;
    if sys==1 then
        MasterSystem.client_redpoint_task = flag ;
    elseif sys==2 then
        MasterSystem.client_redpoint_privilege = flag ;
    elseif sys==3 then
        MasterSystem.client_redpoint_apply = flag ;
    end
     EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_UPDATE_REDPOINT);
end

function  MasterSystem.IsTeacher(uid)
    log("devindzhang MasterSystem.IsTeacher uid："..tostring(uid)..tostring(MasterSystem.my_teacher_uid));
    return tostring(MasterSystem.my_teacher_uid) == tostring(uid) ;
end

function MasterSystem.TestData()
   
    MasterSystem.my_student_list={};
    local info = {};
    info.uid = 1100;
    info.can_be_teacher=false ;
    info.addtime = 1 ;
    table.insert(MasterSystem.my_student_list,info);

    info = {};
    info.uid = 1101;
    info.can_be_teacher=false ;
    info.addtime = 2 ;
    table.insert(MasterSystem.my_student_list,info);

    info = {};
    info.uid = 1103;
    info.can_be_teacher=false ;
    info.addtime=3;
    table.insert(MasterSystem.my_student_list,info);

    MasterSystem.SortByAddTime(MasterSystem.my_student_list);

    MasterSystem.teacher_info = 
    {
      level=1, score=0, level_rewards={[1]={status=0, reward_drop_id=100}}
   };
 
    MasterSystem.same_students_list={};
    
    local temTable = {};
    
    info = {};
    info.uid = 2001;
    info.can_be_teacher=true ; --已经出师
    info.can_be_teacher_time = 1 ;
    table.insert(temTable,info) ;
    --table.insert(MasterSystem.same_students_list,info);

    info = {};
    info.uid = 2002;
    info.can_be_teacher=true ; --已经出师
    info.can_be_teacher_time = 2;
    table.insert(temTable,info) ;

    --table.insert(MasterSystem.same_students_list,info);
    MasterSystem.SortByCanBeteacherTime(temTable);


    local temTable2 = {};
    info = {};
    info.uid = 2003;
    info.can_be_teacher=false ; --未出师
    info.can_be_teacher_time = 1;
    table.insert(temTable2,info) ;
    --table.insert(MasterSystem.same_students_list,info);

    info = {};
    info.uid = 2004;
    info.can_be_teacher=false ; --未出师
    info.can_be_teacher_time = 2;
    table.insert(temTable2,info) ;
    --table.insert(MasterSystem.same_students_list,info);
    MasterSystem.SortByCanBeteacherTime(temTable2);

    for k,v in pairs(temTable2) do
        table.insert(MasterSystem.same_students_list,v);
    end

    for k,v in pairs(temTable) do
        table.insert(MasterSystem.same_students_list,v);
    end
   
end

--是否有师徒关系
function MasterSystem.hasMasterOrDisciple()   
  return #MasterSystem.my_student_list>0 or #MasterSystem.same_students_list>0 or MasterSystem.my_teacher_uid ~= "" ;
end

--获取名师特权信息
function MasterSystem.GetMasterPrivilegeInfo()
  return MasterSystem.teacher_info;
end

--取名师奖励的领取状态，0表示未达到，1表示未领取，2表示已领取
function MasterSystem.GetPrivilegeByLvel( level )
  if MasterSystem.teacher_info ~= nil and MasterSystem.teacher_info.level_rewards ~= nil then
      local reward = MasterSystem.teacher_info.level_rewards[level];
      if reward ~= nil then
        return reward.status;
      end
  end

  return 0;
end

--取申请列表数据
function MasterSystem.GetApplistByUID(uid)

    if MasterSystem.apply_req_list ~= nil then
      return MasterSystem.apply_req_list[uid];
    end

    return nil; 
end

--拿到未出师的徒弟数量
function MasterSystem.GetCanBeNotTeacherDiscipleNum()
    local num  = 0;
    if #MasterSystem.my_student_list > 0 then
        for k,v in pairs(MasterSystem.my_student_list) do
            if v.can_be_teacher then 
               
            else--未出师
                num=num+1;
            end
        end
    end
    
    return num;
end

--协议错误码处理
function MasterSystem.ProtocolErroCode(errorString, param)

    log("MasterSystem.ProtocolErroCode, errorString = " .. tostring(errorString));
    --[[
        master_errcode_task_not_exist 	   = 110171	  --活动不存在
        master_errcode_task_cfg_not_exist  = 110172	  --活动配置不存在
        master_errcode_task_award_has_got  = 110173   --活动已领奖励
        master_errcode_task_not_done       = 110174   --活动未完成
        master_errcode_task_gen_loot_fail  = 110175	  --掉落id生成物品失败
        master_errcode_relation_not_sync   = 110176	  --师徒关系链尚未同步好

        master_errcode_my_apply_teacher_full  = 110177   --申请师傅达到当天限制
        master_errcode_my_apply_student_full  = 110178   --申请徒弟达到当天限制
        master_errcode_apply_full = 110179              --申请达到对方最大限制
        master_errcode_apply_reject = 110180              --对方设置拒绝
        master_errcode_student_full = 110181              --学生满了
        master_errcode_has_teacher = 110182               --已经有老师
        master_errcode_has_apply = 110183               --已经有申请了

    ]]

    --活动不存在
    if errorString == "master_errcode_task_not_exist" then
        DataMgr.ShowNoticeByID(110171 );
    --活动配置不存在
    elseif errorString == "master_errcode_task_cfg_not_exist" then
        DataMgr.ShowNoticeByID(110172);
    --活动已领奖励
    elseif errorString == "master_errcode_task_award_has_got" then
        DataMgr.ShowNoticeByID(110173);
    --活动未完成
    elseif errorString == "master_errcode_task_not_done" then
        DataMgr.ShowNoticeByID(110174);
    --掉落id生成物品失败
    elseif errorString == "master_errcode_task_gen_loot_fail" then
        DataMgr.ShowNoticeByID(110175);
    --师徒关系链尚未同步好
    elseif errorString == "master_errcode_relation_not_sync" then 
        DataMgr.ShowNoticeByID(110176);
    --申请师傅达到当天限制
    elseif errorString == "master_errcode_my_apply_teacher_full" then 
        DataMgr.ShowNoticeByID(110177);
--申请徒弟达到当天限制
    elseif errorString == "master_errcode_my_apply_student_full" then  
        DataMgr.ShowNoticeByID(110178);
--申请达到对方最大限制
    elseif errorString == "master_errcode_apply_full" then  
        DataMgr.ShowNoticeByID(110179);
--对方设置拒绝
    elseif errorString == "master_errcode_apply_reject" then  
        DataMgr.ShowNoticeByID(110180);
--学生满了
    elseif errorString == "master_errcode_student_full" then  
        DataMgr.ShowNoticeByID(110181);
      --已经有老师  
    elseif errorString == "master_errcode_has_teacher" then  
        DataMgr.ShowNoticeByID(110182);
--已经有申请了
    elseif errorString == "master_errcode_has_apply" then  
        DataMgr.ShowNoticeByID(110183);
--删除师徒关系CD
    elseif errorString == "master_errcode_remove_cdtime" then  
        DataMgr.ShowNoticeByID(110224);

        ----未给的错误码 ----start
 
    elseif errorString == "master_errcode_110184" then  
         --该玩家的徒弟数量已达上限  
        DataMgr.ShowNoticeByID(110184);
    elseif errorString == "master_errcode_110185" then 
        --你只能有一个师父 
        DataMgr.ShowNoticeByID(110185);
    elseif errorString == "master_errcode_110186" then  
        --你的历史段位高于该玩家
        DataMgr.ShowNoticeByID(110186);
    elseif errorString == "master_errcode_110187" then
        --你主动解除师徒关系12小时内不能拜师  
        DataMgr.ShowNoticeByID(110187);
    elseif errorString == "master_errcode_110188" then  
        --该玩家已有师父
        DataMgr.ShowNoticeByID(110188);
    elseif errorString == "master_errcode_110189" then  
        --你的徒弟数量已达上限
        DataMgr.ShowNoticeByID(110189);
    elseif errorString == "master_errcode_110190" then  
        --你的历史段位地狱该玩家
        DataMgr.ShowNoticeByID(110190);
    elseif errorString == "master_errcode_error_cdtime" then
        --CD时间还未到
        DataMgr.ShowNoticeByID(110214);        
    elseif errorString == "master_errcode_error_summary" then
        --段位或等级不符合条件
        DataMgr.ShowNoticeByID(110220);  
    elseif errorString == "master_errcode_my_student_full" then
        --自己学生满了
        DataMgr.ShowNoticeByID(110222);

    elseif errorString == "master_errcode_my_has_teacher" then
         --自己已经有老师
        DataMgr.ShowNoticeByID(110221);
    elseif errorString == "master_errcode_my_cannot_be_teacher" then
          --自己还未出师
       DataMgr.ShowNoticeByID(110228);
    elseif errorString == "master_errcode_teacher_rebuild_cdtime" then
         --老师重建关系CD时间还未到
       DataMgr.ShowNoticeByID(110191);
    elseif errorString == "master_errcode_teacher_error_summary" then
        --师父收徒时候段位不符合条件
       DataMgr.ShowNoticeByID(110220);
    elseif errorString == "master_errcode_teacher_remove_cdtime" then
        --老师保护关系CD未到
       DataMgr.ShowNoticeByID(110230);
    elseif errorString == "master_errcode_their_student_full" then
        --对方学生满了
       DataMgr.ShowNoticeByID(110231);
    elseif errorString == "master_errcode_their_has_teacher" then
        --对方已经有老师
       DataMgr.ShowNoticeByID(110232);
    elseif errorString == "master_errcode_their_cannot_be_teacher" then
           --对方还未出师
       DataMgr.ShowNoticeByID(110229);
    elseif errorString == "master_errcode_student_error_summary" then
          --徒弟拜师时候段位或等级不符合条件
       DataMgr.ShowNoticeByID(110234);
    elseif errorString == "master_errcode_student_rebuild_cdtime" then
          --徒弟重建关系CD时间还未到
       DataMgr.ShowNoticeByID(110187);
    elseif errorString == "master_errcode_student_remove_cdtime" then
         --徒弟保护关系CD未到
     DataMgr.ShowNoticeByID(110233);
    elseif errorString == "master_errcode_their_teacher_rebuild_cdtime" then
        DataMgr.ShowNoticeByID(110235);
    elseif errorString == "master_errcode_their_student_rebuild_cdtime" then
        DataMgr.ShowNoticeByID(110236);

         --不能收自己师傅为徒
    elseif errorString == "master_errcode_self_teacher" then
        DataMgr.ShowNoticeByID(110237);

         --不能拜自己徒弟为师
    elseif errorString == "master_errcode_self_student" then
        DataMgr.ShowNoticeByID(110238);

               --接受拜师时您历史段位要比对方高
    elseif errorString == "master_errcode_accept_student_error_summary" then
        DataMgr.ShowNoticeByID(110239);

         --接受收徒时您历史段位要比对方低
    elseif errorString == "master_errcode_accept_teacher_error_summary" then
        DataMgr.ShowNoticeByID(110240);
    elseif errorString == "master_errcode_my_student_max" then
        DataMgr.ShowNoticeByID(110247);
    elseif errorString == "master_errcode_their_student_max" then
        DataMgr.ShowNoticeByID(110246);
    elseif errorString == "master_errcode_already_student" then
        DataMgr.ShowNoticeByID(110248);
    else
        log("unknown error, errorString = " .. tostring(errorString));
        DataMgr.ShowNoticeByString(tostring(errorString));
        ----未给的错误码 ----end
    end
end
--  C2S  >>>>>> START

--请求 徒弟信息
function MasterSystem.on_master_students_list_req()
    log("devindzhang send msg on_master_students_list_req")   
    NetUtil.SendPkg("on_master_students_list_req");
end

--请求 同门信息
function MasterSystem.on_master_same_students_list_req()
    log("devindzhang send msg on_master_same_students_list_req")   
    NetUtil.SendPkg("on_master_same_students_list_req"); 
end

--请求 名师信息
function MasterSystem.on_master_teachter_info_req()
    log("on_master_teachter_info_req");
    NetUtil.SendPkg("on_master_teachter_info_req"); 
end

--含更新, 服务器主动推送协议
function MasterSystem.on_master_teacher_info_res(teacher_info)
 
--[[
ss.call("on_master_teacher_info_res", msg, teacher_info); --含更新, 服务器主动推送协议
参数: msg: "ok" 或错误消息, 待定
    teacher_info: 名师信息
    
    teacher_info
    ├─ teacher_info- 
    │ └─ level: 1
    │ └─ score: 1
    │ └─ level_rewards: 
        ├─ 1-
        │ └─ status: 奖励状态,0未完成, 1已完成未领取, 2已领取
        │ └─ reward_drop_id: 奖励掉落方案id
        │ ...
        └─ 6-
          └─ status: 奖励状态
          └─ reward_drop_id: 奖励掉落方案id
]]

    --log_tree("on_master_teacher_info_res",teacher_info);
    MasterSystem.teacher_info = teacher_info;
    MasterPrivilegeUI.UpdateUI();

    --设置特权红点
    local hasRedPoint  = MasterPrivilegeUI.CheckAllRedPoint();
    log("on_master_teacher_info_reshasRedPoint:"..tostring(hasRedPoint));
   MasterSystem.ClientSetRedPoint(hasRedPoint,2);
end


--解除师徒关系
function MasterSystem.on_master_remove_ts_relationship_req(masterId)
    log("devindzhang on_master_remove_ts_relationship_req");
    NetUtil.SendPkg("on_master_remove_ts_relationship_req",masterId);
end


--请求申请列表
function MasterSystem.master_apply_list_req()
    log("master_apply_list_req");
     NetUtil.SendPkg("master_apply_list_req"); 
end

--申请列表返回
function MasterSystem.master_apply_list_rsp(res, applyinfo)
--[[ applyinfo = {
            -- 是否防骚扰，true表示不开启，false开启
            apply_req_ok = true,

            --别人的申请列表 {uid = {applytype = 1, msg = "", applytime =123}, ....}
            apply_req_count = 0,
            apply_req_list={},

            --当天我向别人的申请个数和最后时间
            my_last_apply_teacher_time = 0,
            my_apply_teacher_num = 0,
            my_last_apply_student_time = 0,
            my_apply_student_num = 0,
}
]]
--log("master_apply_list_rsp"..tostring(res));
  if res == "ok" then
    --log_tree("master_apply_list_rsp",applyinfo);
    MasterSystem.apply_req_list = applyinfo.apply_req_list;
    MasterSystem.apply_req_list.apply_req_ok = applyinfo.apply_req_ok;

    local listID = {};
    --test数据
  --  table.insert( listID, 410000644);
    
    for k,v in pairs(applyinfo.apply_req_list) do
        if k ~= nil then        
            table.insert(listID,k);
        end        
    end
    log("master_apply_list_rsp"..tostring(#listID));
    if #listID == 0 then
        MasterApplyListUI.OnProcessEmpty();
    end

      --请求概要信息
    MasterSystem.on_profile_recruitApply_req(listID, true);

  else
    MasterSystem.ProtocolErroCode(res);
  end

end

--申请列表概要信息
function MasterSystem.on_profile_recruitApply_req(uidList, needRefresh)
   ProfileMgr.GetProfileList(uidList, MasterSystem.on_profile_recruitApply_rsp, needRefresh);
end

function MasterSystem.on_profile_recruitApply_rsp(role_basic_info_list)
    log("MasterSystem.on_profile_recruitApply_rsp");
    --派发事件更新UI
    EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_APPLIST_SUC,role_basic_info_list);  
end


--接受、拒绝申请和防骚扰（是否接受申请）
function MasterSystem.master_apply_resop_req(opuid, resop)
  -- opuid为批准或拒绝的对象，opuid为-1时，表示所有申请信息的拒绝与否
  -- resop 1表示批准，2表示拒绝 
    log("master_apply_resop_req"..tostring(opuid).."op:"..tostring(resop));
    MasterSystem.flagApplyOp = tonumber(resop);
    NetUtil.SendPkg("master_apply_resop_req",tonumber(opuid),resop);
end

--接受、拒绝申请和防骚扰（是否接受申请）返回
function MasterSystem.master_apply_resop_rsp(uid, res)
    log("master_apply_resop_rsp"..tostring(uid).."res"..tostring(res));
     --DataMgr.ShowNoticeByString(tostring(res));
    if res == "ok" then
       -- opuid为批准或拒绝的对象，opuid为-1时，表示所有申请信息的拒绝与否
       -- resop 1表示批准，2表示拒绝 
      --刷新UI
        if uid > 0 and MasterSystem.flagApplyOp == 1 then
            --操作成功
            DataMgr.ShowNoticeByID(110211);
          --张迪那边只需要接受的消息刷新列表
          EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_APPLIST_OP_SUC);  
       elseif uid == -1 then
          --取UI选中态
          --设置成功
           DataMgr.ShowNoticeByID(110208);
           MasterSystem.apply_req_list.apply_req_ok = BP_CurrentMasterCheck;
       elseif  uid > 0 and MasterSystem.flagApplyOp == 2 then
           --您已拒绝
           DataMgr.ShowNoticeByID(110209);        
       end
        --申请列表要知道是操作那个uid，要删除item操作
        EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_APPLIST_OP_ALL,uid);  
    else
        MasterSystem.ProtocolErroCode(res);
    end
  
end

--通过名师等级取徒弟数量
function MasterSystem.GetDiscipleNumByMasterLv(levelID)
    local result = 0;
    local lv = levelID;
    if levelID == nil or levelID ==0 then
        if MasterSystem.teacher_info ~= nil and  MasterSystem.teacher_info.level ~= nil then
          lv = MasterSystem.teacher_info.level;
        end
    end
    
    --未激活名师特权
    if lv == 0 then
        return result;
    end

    local config = Client.GetTableData("MasterPrivilegeConfig", lv);
    if config ~= nil then
        result = config.ApprenticeNum;
    end

    return result;  
end

--  C2S  >>>>>> END


-- S2C >>>>>> START
--申请列表红点，接受到这个协议，代表显示红点
function MasterSystem.on_master_show_apply_list_red_point()
    log("devindzhang MasterSystem.on_master_show_apply_list_red_point") ;
    MasterSystem.ClientSetRedPoint(true,3);
end

--任务红点，接受到这个协议，代表显示红点
function MasterSystem.on_show_t_or_s_task_rewards_red_point() 
    log("devindzhang MasterSystem.on_show_t_or_s_task_rewards_red_point") ;
    MasterSystem.ClientSetRedPoint(true,1);
end

--特权红点，接受到这个协议，代表显示红点
function MasterSystem.on_show_teacher_rewards_red_point()
    log("devindzhang MasterSystem.on_show_teacher_rewards_red_point") ;
    MasterSystem.ClientSetRedPoint(true,2);
end

function MasterSystem.IsMyDisciple(gid)
    if (MasterSystem.my_student_list ~= nil) then
        for k,v in pairs(MasterSystem.my_student_list) do
            if (v ~= nil and tostring(v.uid) == tostring(gid)) then
                return true;
            end
        end
    end
    return false;
end

function MasterSystem.IsMyMaster(gid)
    return tostring(gid) == tostring(MasterSystem.my_teacher_uid);
end

-- 得到徒弟列表
function MasterSystem.on_master_students_list_res(student_list)
  --log_tree("devindzhang on_master_students_list_res:",student_list);
   MasterSystem.my_student_list = {} ;

   if(student_list ~= nil) then
        local tmpTable = {};--出师列表
        local tmp2Table = {};--未出师列表
        for k,v in pairs(student_list) do
            if v.can_be_teacher then
                local tmp = {};  
                tmp.uid =  k;--v.uid;
                tmp.can_be_teacher=true ;
                tmp.logout_time=v.logout_time;
                tmp.addtime = v.addtime ;  -- 成为徒弟的时间
                tmp.can_be_teacher_time =  v.can_be_teacher_time -- 成为师父的时间
                table.insert(tmpTable,tmp);
            else
                local tmp2 = {} ; 
                tmp2.uid = k;--v.uid;
                tmp2.can_be_teacher = false;
                tmp2.addtime = v.addtime ;  -- 成为徒弟的时间
                tmp2.can_be_teacher_time =  v.can_be_teacher_time -- 成为师父的时间
                table.insert(tmp2Table,tmp2);
            end
        end

          --时间排序
          MasterSystem.SortByCanBeteacherTime(tmpTable);
          MasterSystem.SortByAddTime(tmp2Table)
  
          --先加未出师列表
          for k,v in pairs(tmp2Table) do
              table.insert( MasterSystem.my_student_list,v);
          end
          --再加未出师列表
          for k,v in pairs(tmpTable) do
              table.insert( MasterSystem.my_student_list,v);
          end
    end

    --log_tree("devindzhang my_student_list",MasterSystem.my_student_list);
   EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_UPDATE_STUEND_LIST);
end

-- 得到同门信息
function MasterSystem.on_master_same_students_list_res( teacher_uid, student_list)
 log("devindzhang on_master_same_students_list_res teachId:"..tostring(teacher_uid));
 --log_tree("devindzhang on_master_same_students_list_res:",student_list) ;

  MasterSystem.same_students_list = {} ;
  MasterSystem.my_teacher_uid="";
  if(student_list ~= nil) then
        MasterSystem.my_teacher_uid = tostring(teacher_uid);
        local tmpTable = {};--出师列表
        local tmp2Table = {};--未出师列表
        for k,v in pairs(student_list) do
            if(DataMgr.roleData.uid ~= tostring(k)) then

                if v.can_be_teacher then
                    local tmp = {};  
                    tmp.uid = k;--v.uid;
                    tmp.can_be_teacher = true;
                    tmp.logout_time=v.logout_time;
                    tmp.addtime = v.addtime ;  -- 成为徒弟的时间
                    tmp.can_be_teacher_time =  v.can_be_teacher_time -- 成为师父的时间
                    table.insert(tmpTable,tmp);
                else
                    local tmp2 = {} ; 
                    tmp2.uid = k;--v.uid;
                    tmp2.can_be_teacher = false;
                    tmp2.logout_time=v.logout_time;
                    tmp2.addtime = v.addtime ;  -- 成为徒弟的时间
                    tmp2.can_be_teacher_time =  v.can_be_teacher_time -- 成为师父的时间
                    table.insert(tmp2Table,tmp2);
                end
                --table.insert( MasterSystem.same_students_list,tmp);
            end
        end 
        
        --最先加老师
        local tmp3 = {}; 
        tmp3.uid = teacher_uid;--v.uid;
        table.insert( MasterSystem.same_students_list,tmp3); --老师放在最前面

        --时间排序
        MasterSystem.SortByCanBeteacherTime(tmpTable);
        MasterSystem.SortByAddTime(tmp2Table)

        --先加未出师列表
        for k,v in pairs(tmp2Table) do
            table.insert( MasterSystem.same_students_list,v);
        end
        --再加未出师列表
        for k,v in pairs(tmpTable) do
            table.insert( MasterSystem.same_students_list,v);
        end

       
   end
   --log_tree("devindzhang same_students_list",MasterSystem.same_students_list);
   EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_UPDATE_SAME_STUEND_LIST);
end


function MasterSystem.SortByCanBeteacherTime(list)
    table.sort(list,function(a,b)
        if(a.can_be_teacher_time ~= nil and b.can_be_teacher_time ~= nil) then
            return tonumber(a.can_be_teacher_time) < tonumber(b.can_be_teacher_time);
        end
    end);
end

--按照成为徒弟时间排序
function MasterSystem.SortByAddTime(list)
    --未出师（未出师按照时间短排序）排前面   出师（出师越早排在前面）排后面
    table.sort(list,function(a,b)
        if(a.addtime ~= nil and b.addtime ~= nil) then
            return tonumber(a.addtime) > tonumber(b.addtime);
        end
    end);
end

--获取升级名师奖励
function MasterSystem.on_master_get_teacher_level_rewards_req(level)
    --local level = 1 ;
    log("on_master_get_teacher_level_rewards_req"..tostring(level));
    NetUtil.SendPkg("on_master_get_teacher_level_rewards_req",tonumber(level));
end

--得到名师奖励
function MasterSystem.on_master_get_teacher_level_rewards_res(msg, itemlist)
  --[[
  参数: msg: "ok" 或错误消息, 待定
    itemlist: 获取的物品列表, 
          itemlist: 奖励
            └─ 1
            │  ├─ valid_hours: 0
            │  ├─ count: 1
            │  ├─ expire_ts: 0
            │  └─ res_id: 404003
            │─ 2
            │  ├─ valid_hours: 0
            │  ├─ count: 1
            │  ├─ expire_ts: 0
            │  └─ res_id: 404003
  ]]
 -- log("on_master_get_teacher_level_rewards_res");
 -- DataMgr.ShowNoticeByString(tostring(msg));
  if msg == "ok" then  
    --log_tree("on_master_get_teacher_level_rewards_res",itemlist);
     CommonItemGetUI:ShowPanel(itemlist);
  else
    MasterSystem.ProtocolErroCode(msg);
  end


    EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_UPDATE_GOOD_TEACHER_REWARDS);
end

--解除师徒关系
function MasterSystem.on_master_remove_ts_relationship_res(msg,other_uid)
  log("devindzhang on_master_remove_ts_relationship_res"..tostring(msg)) ;
  MasterSystem.my_teacher_uid = "" ;
  MasterSystem.my_student_list = {} ;
  MasterSystem.same_students_list={};
  if msg == "ok" then
    EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_DISMISS_SUC);
  else
    MasterSystem.ProtocolErroCode(msg);
  end
end
--[[
        simple_task: 简要信息
        ├─ master_id: 111 师父uid
        │  
        │─ state: 2  状态 2为师父任务 其它为徒弟状态
        ]]
function MasterSystem.on_simple_master_info_notify(simple_task)
  log("on_simple_master_info_notify");
  --log_tree("simple_task", simple_task);
  MasterSystem.my_teacher_uid = simple_task.master_id == nil and "" or tostring(simple_task.master_id);
  MasterSystem.task_state = tonumber(simple_task.state);
end

--是否已出师
function MasterSystem.HasFinishDiscipleTask()
  return MasterSystem.task_state ~= 1;
end

--是否有师父
function MasterSystem.HasMaster()
  return MasterSystem.my_teacher_uid ~= nil and MasterSystem.my_teacher_uid ~= "" and MasterSystem.my_teacher_uid ~= "0"
end



function  MasterSystem.on_notify_can_be_teacher(uid)
    if(#MasterSystem.my_student_list>0) then
        for i = 1, #MasterSystem.my_student_list, 1 do
            if tostring(MasterSystem.my_student_list[i].uid) == tostring(uid) then
                MasterSystem.my_student_list[i].can_be_teachter = true;
                break 
            end
        end
    end
    
    if(#MasterSystem.same_students_list>0) then
        for i = 1, #MasterSystem.same_students_list, 1 do
            if tostring(MasterSystem.same_students_list[i].uid) == tostring(uid) then
                MasterSystem.same_students_list[i].can_be_teachter = true;
                break 
            end
        end
    end
    
    EventSystem:postEvent(EVENTTYPE_MASTER, EVENTID_MASTER_UPDATE_MY_STUEND_OR_SAME_STUEND_STATE,uid);
end

-- S2C >>>>> END

--协议
s2c["on_master_show_apply_list_red_point"] = MasterSystem.on_master_show_apply_list_red_point
s2c["on_master_show_t_or_s_task_rewards_red_point"] = MasterSystem.on_show_t_or_s_task_rewards_red_point
s2c["on_show_teacher_rewards_red_point"] = MasterSystem.on_show_teacher_rewards_red_point
s2c["on_master_students_list_res"] = MasterSystem.on_master_students_list_res
s2c["on_master_same_students_list_res"]=MasterSystem.on_master_same_students_list_res
s2c["on_master_get_teacher_level_rewards_res"]=MasterSystem.on_master_get_teacher_level_rewards_res
s2c["on_master_remove_ts_relationship_res"]=MasterSystem.on_master_remove_ts_relationship_res
s2c["on_notify_can_be_teacher"]= MasterSystem.on_notify_can_be_teacher

s2c["on_master_teacher_info_res"]=MasterSystem.on_master_teacher_info_res;--请求名师信息回复
s2c["master_apply_list_rsp"]=MasterSystem.master_apply_list_rsp; --获取申请列表返回
s2c["master_apply_resop_rsp"]=MasterSystem.master_apply_resop_rsp; --申请批准或拒绝
s2c["on_simple_master_info_notify"]=MasterSystem.on_simple_master_info_notify; --是否已出师


--[[
    协议:
--申请列表是否为空红点
   ss.call("on_master_show_apply_list_red_point");
--老师或学生任务奖励红点
ss.call("on_master_show_t_or_s_task_rewards_red_point");
--名师特权奖励红点
    ss.call("on_show_teacher_rewards_red_point");
--徒弟列表
c2s.on_master_students_list_req(ss)
ss.call("on_master_students_list_res", msg, list);
--同门列表
c2s.on_master_same_students_list_req(ss)
ss.call("on_master_same_students_list_res", msg, my_teacher_uid, list);

--名师信息
c2s.on_master_teachter_info_req(ss )
ss.call("on_master_teacher_info_res", msg, info); --含升级通知

--获取升级名师奖励
c2s.on_master_get_teacher_level_rewards_req(ss, level)
ss.call("on_master_get_teacher_level_rewards_res", msg, rewards);

--解除师徒关系
c2s.on_master_remove_ts_relationship_req(ss, other_uid)
ss.call("on_master_remove_ts_relationship_res", msg, other_uid);

数据结构:
徒弟列表
my_student_list= {uid={}}
同门:
same_students_list={uid={can_be_teachter=true}, ...}
名师信息:
teacher_info={level=1, score=0, level_rewards={[1]={status=0, reward_drop_id=1}, ...}, level_rewards[i]中的i就表示等级

]]