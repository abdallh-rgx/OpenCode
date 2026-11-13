-- 新赛季开场UI
UnknowPassIntroduceUI = UnknowPassIntroduceUI or
{
}

BP_UnknowPass_IntroduceUI_PageCount = 5;

--注册Widget
function bp_unknow_pass_introduce_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_introduce,
        {{Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Introduce_Logic_BP.UnknowPass_Introduce_Logic_BP_C", Container="Default", ZOrder=16}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function UnknowPassIntroduceUI.Init()
	log("UnknowPassIntroduceUI.Init")
	LuaClassObj.HandleDynamicCreation(bp_unknow_pass_introduce);
	LuaClassObj.HandleUIMessage(bp_unknow_pass_introduce, "UIShow");
	UIManager.Show(eUIType.eUnknowPassIntroduceUI);
end

-- 隐藏
function UnknowPassIntroduceUI.Hide()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_introduce, "UIHide");
end

--新赛季id生成
function UnknowPassIntroduceUI.GetNewPassNewbieId()
	local season = UnknowPassSystem.Season
	return season * 1000
end

--点击关闭按钮
function EventUnknowPassIntroduceUIClickClose()
	log("EventUnknowPassIntroduceUIClickClose")
	UIManager.Hide(eUIType.eUnknowPassIntroduceUI);
	UnknowPassIntroduceUI.Hide();
	local id = UnknowPassIntroduceUI.GetNewPassNewbieId()
	local hasNewSeason = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, id)
	if hasNewSeason then
		DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, id);
	end		

	UnknowPassUI.CheckAndShowNewbie()
end