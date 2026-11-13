-- 新赛季开场UI
LeagueGameIntroduceUI = LeagueGameIntroduceUI or
{
	timerId = {},
}

--当前页面下标0,1,2
BP_LeagueGame_Introduce_Page_Index = 0
--当前播放动画下标0,1,2
BP_LeagueGame_Introduce_Ani_Index = 0
BP_LeagueGame_Introduce_Is_Revert = false
BP_LeagueGame_Introduce_Can_Play_Animation = true;


BP_LeagueGameIntroduce_SeaMatchTime1 = "";
BP_LeagueGameIntroduce_SeaMatchTime2 = "";
BP_LeagueGameIntroduce_SeaMatchInfo = "";

BP_LeagueGameIntroduce_GroupMatchTime = "";
BP_LeagueGameIntroduce_GroupMatchInfo = "";

BP_LeagueGameIntroduce_FinalMatchTime = "";
BP_LeagueGameIntroduce_FinalMatchInfo = "";

BP_LeagueGameIntroduce_SignDesc = "";
--注册Widget
function bp_leagueGame_introduce_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_introduce,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_Introduce_BP.LeagueGame_Introduce_BP_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+5}},
        {"Lobby"},
        false,
        false,
        true
    );
end

--sami 初始化显示
function LeagueGameIntroduceUI.Init()	
    log("LeagueGameIntroduceUI.Init")
    LeagueGameIntroduceUI.SetData();
	LuaClassObj.HandleDynamicCreation(bp_leagueGame_introduce);
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UIShow");
	UIManager.Show(eUIType.eLeagueGameIntroduce);

	BP_LeagueGame_Introduce_Page_Index = 0
	BP_LeagueGame_Introduce_Ani_Index = 0
	BP_LeagueGame_Introduce_Is_Revert = false
	BP_LeagueGame_Introduce_Can_Play_Animation = true
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "SetInfo");
	
	LeagueGameIntroduceUI.EnterFirstPage()
end

function LeagueGameIntroduceUI.Release()
    log("LeagueGameIntroduceUI.Release")
    LeagueGameIntroduceUI.StopAllTimer();
end

function LeagueGameIntroduceUI.SetData()
	BP_LeagueGameIntroduce_SeaMatchInfo = tostring(#LeagueGameSystem.LeagueTimeTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);
	BP_LeagueGameIntroduce_SeaMatchTime1 = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].client_show[1];
	BP_LeagueGameIntroduce_SeaMatchTime2 = "";
	if LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].client_show[2] then
		BP_LeagueGameIntroduce_SeaMatchTime2 = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].client_show[2];
	end

	BP_LeagueGameIntroduce_GroupMatchTime = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH].client_show[1];
	BP_LeagueGameIntroduce_GroupMatchInfo = tostring(#LeagueGameSystem.LeagueTimeTable[LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time); 

	BP_LeagueGameIntroduce_FinalMatchTime = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH].client_show[1];
	BP_LeagueGameIntroduce_FinalMatchInfo = tostring(#LeagueGameSystem.LeagueTimeTable[LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);

	BP_LeagueGameIntroduce_SignDesc = Client.GetTableData("LocalizeRes", 6057).TextValue .. Client.GetTableData("LocalizeRes", 6295).TextValue;
end

--停止单个定时器
function LeagueGameIntroduceUI.StopTimer(idStr)
	if LeagueGameIntroduceUI.timerId[idStr] and LeagueGameIntroduceUI.timerId[idStr] ~= 0 then
		log("LeagueGameIntroduceUI.StopTimer "..idStr)
		Timer.RemoveTimer(LeagueGameIntroduceUI.timerId[idStr])
		LeagueGameIntroduceUI.timerId[idStr] = 0
	end
end

--停止所有定时器
function LeagueGameIntroduceUI.StopAllTimer()
	for k, v in pairs(LeagueGameIntroduceUI.timerId) do
		LeagueGameIntroduceUI.StopTimer(k)
	end
end

function LeagueGameIntroduceUI.PrePage()
    log("LeagueGameIntroduceUI.PrePage .. " .. BP_LeagueGame_Introduce_Page_Index)
	if BP_LeagueGame_Introduce_Page_Index <= 0 then
		return
	end

	BP_LeagueGame_Introduce_Is_Revert = true
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "EnterNext");
	BP_LeagueGame_Introduce_Ani_Index = BP_LeagueGame_Introduce_Ani_Index - 1

	BP_LeagueGame_Introduce_Page_Index = BP_LeagueGame_Introduce_Page_Index - 1
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdateLeftRight");
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdatePage");
	
	--10s自动下一页
	LeagueGameIntroduceUI.timerId["10"] = Timer.InsertTimer(10, function()
		LeagueGameIntroduceUI.StopTimer("10")
		EventLeagueGameIntroduceUIClickNext()
	end,
	false, false);
end

--播放第一页
function LeagueGameIntroduceUI.EnterFirstPage()
    log("LeagueGameIntroduceUI.EnterFirstPage")
	--切换动画
	BP_LeagueGame_Introduce_Ani_Index = 0
	BP_LeagueGame_Introduce_Is_Revert = false
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "EnterNext");

	--翻页
	BP_LeagueGame_Introduce_Page_Index = -1
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdateLeftRight");
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdatePage");
	
	--3.4s后刷新page和箭头
	local t1 = 2.0
	if not BP_LeagueGame_Introduce_Can_Play_Animation then
		t1 = 0.1
	end
	log("LeagueGameIntroduceUI.EnterFirstPage.." .. tostring(t1))
	LeagueGameIntroduceUI.timerId["3.4"] = Timer.InsertTimer(t1, function()
		LeagueGameIntroduceUI.StopTimer("3.4")
		
		BP_LeagueGame_Introduce_Page_Index = 0
		--LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdateLeftRight");
		LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdatePage");
		
		log("LeagueGameIntroduceUI start 10")
		LeagueGameIntroduceUI.timerId["10"] = Timer.InsertTimer(10, function()
			LeagueGameIntroduceUI.StopTimer("10")
			EventLeagueGameIntroduceUIClickNext()
		end,
		false, false);
	end,
	false, false);
end

--切换到下一页
function LeagueGameIntroduceUI.NextPage()
    log("LeagueGameIntroduceUI.NextPage")
	if BP_LeagueGame_Introduce_Page_Index < 0 or BP_LeagueGame_Introduce_Page_Index > 4 then
		return
	end
	--动画下一页
	BP_LeagueGame_Introduce_Ani_Index = BP_LeagueGame_Introduce_Ani_Index + 1
	BP_LeagueGame_Introduce_Is_Revert = false
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "EnterNext");
	
	--翻页
	BP_LeagueGame_Introduce_Page_Index = BP_LeagueGame_Introduce_Page_Index + 1
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdateLeftRight");
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UpdatePage");

	--10s自动下一页
	LeagueGameIntroduceUI.timerId["10"] = Timer.InsertTimer(10, function()
		LeagueGameIntroduceUI.StopTimer("10")
		EventLeagueGameIntroduceUIClickNext()
	end,
	false, false);
end

--点击上一页
function EventLeagueGameIntroduceUIClickPre()
	log("EventLeagueGameIntroduceUIClickPre")
	LeagueGameIntroduceUI.StopAllTimer()
	LeagueGameIntroduceUI.PrePage()
end


--点击下一页
function EventLeagueGameIntroduceUIClickNext()
	log("EventLeagueGameIntroduceUIClickNext")
	LeagueGameIntroduceUI.StopAllTimer()
	LeagueGameIntroduceUI.NextPage()
end


--点击关闭按钮
function EventLeagueGameIntroduceUIClickClose()
	log("EventLeagueGameIntroduceUIClickClose")	
	LeagueGameIntroduceUI.StopAllTimer();
	local hasNewSeason = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LEAGUE, LeagueGameSystem.LeagueId);
	if hasNewSeason then
		DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LEAGUE, LeagueGameSystem.LeagueId);
	end
	LuaClassObj.HandleUIMessage(bp_leagueGame_introduce, "UIHide");
	UIManager.Hide(eUIType.eLeagueGameIntroduce);

end