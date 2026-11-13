--sami pass新手引导界面
UnknowPassNewbieUI = UnknowPassNewbieUI or
{

}

BP_UnknowPass_SeasonName = "";
BP_UnknowPass_SeasonTime = "";



--注册Widget
function bp_unknow_pass_newbie_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_unknow_pass_newbie,
	{
		{Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Newbie_Logic_BP.UnknowPass_Newbie_Logic_BP_C", Container="Default", ZOrder=10},
	},
	{"Lobby"},
	false,
	false
	);
end

function UnknowPassNewbieUI.Show()
	BP_UnknowPass_SeasonName = UnknowPassSystem.SeasonInfo.cfg.season_name;
	BP_UnknowPass_SeasonTime = UnknowPassSystem.SeasonInfo.cfg.show_time;
	
	LuaClassObj.HandleDynamicCreation(bp_unknow_pass_newbie);
	LuaClassObj.HandleUIMessage(bp_unknow_pass_newbie, "UIShow");
	UIManager.Show(eUIType.eUnknowPassNewbieUI);
end

function UnknowPassNewbieUI.Hide()
	UIManager.Hide(eUIType.eUnknowPassNewbieUI);
	LuaClassObj.HandleUIMessage(bp_unknow_pass_newbie, "UIHide");
end

--退出
function EventUnknowPassNewbie_Close()
	UnknowPassNewbieUI.Hide()
	DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_PASS, 1);
end

