-- 一键领取所有任务奖励
UnknowPassMissionAwardAllUI = UnknowPassMissionAwardAllUI or
{
}

BP_UnknowPass_Mission_AwardAll_TotalScore = 0;		    -- 任务奖励
BP_UnknowPass_Mission_AwardAll_EliteScoreMore = 0;	    -- 升级通行证后的精英任务额外奖励积分数量
BP_UnknowPass_Mission_Award_NeedShowUpgrade = false;    -- 非精英通行证完成精英任务,显示升级通行证按钮

-- 注册widget
function bp_unknow_pass_mission_award_all_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_unknow_pass_mission_award_all,
	{
		{Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Mission_AwardALL_Logic.UnknowPass_Mission_AwardALL_Logic_C", Container="Default", ZOrder=0},
	},
	{"UnknowPass","Lobby"},
	false,
	false
	);
end

-- 根据后台回调数据初始化数据，显示界面
function UnknowPassMissionAwardAllUI.Init(total_score)
	BP_UnknowPass_Mission_AwardAll_TotalScore = total_score;
    BP_UnknowPass_Mission_AwardAll_EliteScoreMore = 0;
    BP_UnknowPass_Mission_Award_NeedShowUpgrade = false;

    -- 未购买通行证,需要显示升级通行证后可以额外获取的奖励内容
    if not UnknowPassSystem.IsBuyElite then      
        for id, task in pairs(UnknowPassSystem.Data.week_task) do
            local taskData = task.task_data;
            if taskData then
                if taskData.status == BP_UnknowPass_Mission_Finished then -- 精英任务虽然已经完成，需要升级通行证才能获取奖励
                    local taskCfgInfo = UnknowPassSystem.Data.all_week_task_cfg[id];
                    if taskCfgInfo and taskCfgInfo.is_elite_task == 1 then
                        BP_UnknowPass_Mission_AwardAll_EliteScoreMore = BP_UnknowPass_Mission_AwardAll_EliteScoreMore + taskCfgInfo.reward_score;
                        BP_UnknowPass_Mission_Award_NeedShowUpgrade = true;
                    end
                end  -- task.status
            end
        end    -- for
    end

    UnknowPassMissionAwardAllUI.Show();
    if nil ~= UIManager.GetUI(eUIType.eUnknowPassLevelUpUI) then
        UnknowPassLevelUp.ShowLevelUp();
    end
end

function UnknowPassMissionAwardAllUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_unknow_pass_mission_award_all);
	LuaClassObj.HandleUIMessage(bp_unknow_pass_mission_award_all, "UIShow");
	UIManager.Show(eUIType.eUnknowPassMissionAwardAllUI);
	EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, UnknowPassMissionAwardAllUI.OnBuyPass);
end

function UnknowPassMissionAwardAllUI.Hide()
	UIManager.Hide(eUIType.eUnknowPassMissionAwardAllUI);
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_mission_award_all, "UIHide");
	EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, UnknowPassMissionAwardAllUI.OnBuyPass);
end

-- 响应确定按钮事件
function EventUnknowPassMissionAwardAllConfirm()
    UnknowPassMissionAwardAllUI.Hide();
end

-- 响应升级通行证按钮事件
function EventUnknowPassMissionAwardAllUpgrade()
	UnknowPassBuy.ShowUI();	
end

-- 购买通行证回调,隐藏界面
function UnknowPassMissionAwardAllUI.OnBuyPass(evenType, eventID)
    UnknowPassMissionAwardAllUI.Hide();
    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassUpgradeFromGetTaskAward, tostring(UnknowPassSystem.IsBuyElite))
end