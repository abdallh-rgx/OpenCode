
CorpsRankAwardUI = CorpsRankAwardUI or {
	isOnlyShow = true,
}

BP_STRUCT_BASE_INFO = {
    strUid = "",
    Name = "",
    Level = 1,
    Sex = 1,
    RankIntegralLevel = 1,
    IconUrl = "",
    IconFrameID  = 1,
    lastOnlineTimeStr = "",

    -- 绝地通行证
    upass_is_buy = 0, --是否购买(1为已购买，0为未购买)
    upass_is_show = 0, --是否显示(1为显示，0为不显示)
    --国籍
    nation = "",
}

BP_STRUCT_Corps_Rank_Award_Member1_Info = 
{
	is_init = false,
	BP_STRUCT_BASE_INFO = _G.BP_STRUCT_BASE_INFO,
}
BP_STRUCT_Corps_Rank_Award_Member2_Info = 
{
	is_init = false,
	BP_STRUCT_BASE_INFO = _G.BP_STRUCT_BASE_INFO,
}
BP_STRUCT_Corps_Rank_Award_Member3_Info = 
{
	is_init = false,
	BP_STRUCT_BASE_INFO = _G.BP_STRUCT_BASE_INFO,
}

BP_STRUCT_CorpsAwardInfo = 
{
	is_week = false,
	icon = 0,
	coprs_name = "",
	last_rank = 0,
	last_rank_per = 0,
    last_activity = 0,
    my_activity = 0,
    -- top_mumber_1 = 0,
    -- top_mumber_2 = 0,
    -- top_mumber_3 = 0,
    award_id = 0,
    award_num = 0,
    is_get_award = false,
    need_activity = 0,
    icon_text = "",
    icon_text_colour = 0,
};

BP_STRUCT_CorpsAwardInfo = _G.BP_STRUCT_CorpsAwardInfo

BP_CorpsRankAward_Player_ID = ""

local function CorpsRankEventHandler(eventType, eventID, vars)
	if eventType ~= EVENTTYPE_CORPS then
		return;
	end

	if eventID == EVENTID_CORPS_RANK_GET_AWARD then
        CorpsRankAwardUI.ShowAwardUI(vars == 101);
	end
	if eventID == EVENTID_CORPS_UPDATE_TOP_MEMBERINFO then
        CorpsRankAwardUI.UpdateTopMember();
	end
end

-- 注册Widget
function bp_corps_rank_award_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_corps_rank_award,
    	{{Path="/Game/UMG/UI_Logic/Corps/CorpsRankAward_BP.CorpsRankAward_BP_C", Container="Default", ZOrder = BP_ENUM_UI_OWN_CORPS_ZORDER + 2}},
    	{"Lobby"},
		false,
		false,
		true
  	);

  	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_RANK_GET_AWARD, CorpsRankEventHandler)
  	EventSystem:registEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_TOP_MEMBERINFO, CorpsRankEventHandler)
end


function CorpsRankAwardUI.ShowAwardUI( is_week )
	if is_week then
		log("显示周奖励UI")
	else
		log("显示季度奖励UI")
	end

	BP_STRUCT_CorpsAwardInfo = CorpsRankAwardInfo
	BP_STRUCT_CorpsAwardInfo.icon_text = DataMgr.corpsInfo.icon_text;
	BP_STRUCT_CorpsAwardInfo.icon_text_colour = DataMgr.corpsInfo.icon_text_colour;

	LuaClassObj.HandleDynamicCreation(bp_corps_rank_award);
	LuaClassObj.HandleUIMessage(bp_corps_rank_award, "UIShow")
	UIManager.Show(eUIType.eCorpsRankAwardUI)

	CorpsRankAwardUI.ChangeIsOnlyShow(true)
end

function EventCorpsRankAwardUICloseWeekSendSeason()
	CorpsRankSystem.SendIsGetAward()
	if #CorpsRankAwardShowList > 0 then
    	CommonItemGetUI:ShowPanel(CorpsRankAwardShowList)
    end
end

function EventCorpsRankAwardUICloseSeaon()
	CorpsRankSystem.SendIsGetAward()
	if #CorpsRankAwardShowList > 0 then
	    CommonItemGetUI:ShowPanelWithCallback(CorpsRankAwardShowList,function ()
	        CorpsRankSystem.SendGetRankAward(101)
	    end 
	    ,false)
	else
		CorpsRankSystem.SendGetRankAward(101)
	end
end

function CorpsRankAwardUI.UpdateTopMember()
	log("更新最活跃玩家信息")
	--log_tree("BP_STRUCT_Corps_Rank_Award_Member1_Info =",BP_STRUCT_Corps_Rank_Award_Member1_Info)
	--log_tree("BP_STRUCT_Corps_Rank_Award_Member2_Info =",BP_STRUCT_Corps_Rank_Award_Member2_Info)
	--log_tree("BP_STRUCT_Corps_Rank_Award_Member3_Info =",BP_STRUCT_Corps_Rank_Award_Member3_Info)
	LuaClassObj.HandleUIMessage(bp_corps_rank_award, "UpdateTopMember")

end

function EventCorpsRankAwardUIShowPlayerDetails()
    log("enter profile panel:"..tostring(BP_CorpsRankAward_Player_ID))
    RoleInfoSystem.Enter(BP_CorpsRankAward_Player_ID)
    RoleInfoUI.Init(true, RoleInfoOpenFromType.CorpsRankAward)

    -- ProfileMgr.GetProfile(tostring(BP_FRIEND_PROFILE_ID), LobbyFriendUI.OnFriendStatusListChange, true)
end

function EventCorpsRankAward_Close()
	UIManager.Hide(eUIType.eCorpsRankAwardUI)
end

function CorpsRankAwardUI.ChangeIsOnlyShow(isOnlyShow)
	log("CorpsRankAwardUI.ChangeIsOnlyShow:" .. tostring(isOnlyShow))
	CorpsRankAwardUI.isOnlyShow = isOnlyShow
	if CorpsRankAwardUI.isOnlyShow then
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_rank_award, "UIOnlyShow");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_corps_rank_award, "UIOnlyHide");
	end
end

function CorpsRankAwardUI.GetStatus()
	log("CorpsRankAwardUI.GetStatus:" .. tostring(CorpsRankAwardUI.isOnlyShow))
	return {isOnlyShow = CorpsRankAwardUI.isOnlyShow}
end

function CorpsRankAwardUI.RecoverStatus(status)
	if status and status.isOnlyShow ~= nil then
		log("CorpsRankAwardUI.RecoverStatus:" .. tostring(status.isOnlyShow))
		CorpsRankAwardUI.ChangeIsOnlyShow(status.isOnlyShow)
	end

end