NewteachingUI = NewteachingUI or {};
--标签按钮选择索引,在蓝图中赋值
BP_NewteachingUI_CurrentSelectIdx = 1;

function bp_newteaching_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_newteaching,
		{				
			{Path="/Game/UMG/UI_Logic/Newtaeching/Newteaching_LogicBP.Newteaching_LogicBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_cjhb_ZORDER},
		},
		{"Lobby"},
		false,
		false
	);
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_NEWTEACHING, NewteachingUI.Show);
end

function NewteachingUI.Show()
	NewteachingUI.SendReport();
	TaskSystem.Req_ReportTaskInfo(1)
	LuaClassObj.HandleUIMessage(bp_newteaching, "ShowUI");
end

function EventNewteaching_Push()

end

--新手训练标签按钮点击
function EventNewteachingTitleBtnClick()
	--上报点击事件
	NewteachingUI.SendReport();
	LuaClassObj.HandleUIMessage(bp_newteaching, "SetData")
end

function NewteachingUI.SendReport()
	ClientSendBAReport(_G["BP_BA_NEWTEACHING_CLICK_" .. BP_NewteachingUI_CurrentSelectIdx] , 0);
end