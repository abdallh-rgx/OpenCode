--赛事晋级奖励
LeagueGameAdvanceUI = LeagueGameAdvanceUI or {

}


BP_LeagueGameAdvance_Stage = 0;
BP_LeagueGameAdvance_Name = "";

--LeagueGameAdvanceUI.IsShowed = false

--注册Widget
function bp_leagueGame_Advance_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_Advance,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGameAdvance_BP.LeagueGameAdvance_BP_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+10}},
        {"Lobby"},
        false,
        false,
        true
    );
end


function LeagueGameAdvanceUI.Init()	
    log("LeagueGameAdvanceUI.Init");
	--if not LeagueGameAdvanceUI.IsShowed then
	LeagueGameAdvanceUI.SetData();
	LeagueGameAdvanceUI.Show();
		--LeagueGameAdvanceUI.IsShowed = true
	--end
end

function LeagueGameAdvanceUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_leagueGame_Advance);
	LuaClassObj.HandleUIMessage(bp_leagueGame_Advance, "UIShow");
end

function LeagueGameAdvanceUI.Hide()
	LuaClassObj.HandleUIMessage(bp_leagueGame_Advance, "UIHide");
	--LeagueGameAdvanceUI.IsShowed = false
end

function LeagueGameAdvanceUI.Release()
    log("LeagueGameAdvanceUI.Release");
end

function LeagueGameAdvanceUI.SetData()
	BP_LeagueGameAdvance_Stage = LeagueGameSystem.StageId;
	if BP_LeagueGameAdvance_Stage == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
    	BP_LeagueGameAdvance_Name = Client.GetTableData("LocalizeRes", "6049").TextValue;
 	elseif BP_LeagueGameAdvance_Stage == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH then
    	BP_LeagueGameAdvance_Name = Client.GetTableData("LocalizeRes", "6050").TextValue;
  	elseif BP_LeagueGameAdvance_Stage == LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH then
    	BP_LeagueGameAdvance_Name = Client.GetTableData("LocalizeRes", "6051").TextValue;
  	end
end

--检查晋级奖励
function LeagueGameAdvanceUI.CheckPromoteReward()
    if LeagueGameSystem.LeagueRewardListTable then
        log_tree("LeagueGameSystem.LeagueRewardListTable", LeagueGameSystem.LeagueRewardListTable);
        for k, v in pairs(LeagueGameSystem.LeagueRewardListTable) do
            if v.reward_type == 1 and v.reward_stage == BP_LeagueGameAdvance_Stage then
                log("LeagueGameSystem.LeagueRewardListTable .." .. k);
                LeagueGameLeagueInfo.get_league_promote_reward_req(k);
                --LuaClassObj.HandleUIMessage(bp_leagueGame_Advance, "ShowShareBtn");
            end
        end
    end
end

function EventLeagueGameAdvanceHide()
    LeagueGameAdvanceUI.Hide();
end


function EventLeagueGameAdvanceGet()
    LeagueGameAdvanceUI.CheckPromoteReward();
end

function EventLeagueGameAdvanceShare()
    LeagueGameShareAdvanceUI.Init(BP_LeagueGameAdvance_Stage);
end