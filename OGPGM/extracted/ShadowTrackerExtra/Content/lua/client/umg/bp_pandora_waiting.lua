--加载界面
PandoraWaitingUI = PandoraWaitingUI or 
{
	isShowing = false,
}


--注册widget
function bp_pandora_waiting_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_pandora_waiting,
    {{Path="/Game/UMG/UI_Logic/Pandora/Pandora_Waiting_BP.Pandora_Waiting_BP_C", Container="Top", ZOrder=BP_ENUM_UI_RECONNECT_WAITING_ZORDER}},
    {"Lobby"},
	false,
    false,
    true	
  );
end

-- 打开面板
function PandoraWaitingUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_pandora_waiting);
	
	log("gavin PandoraWaitingUI:Show()");
	
	PandoraWaitingUI.isShowing = true;	
	LuaClassObj.HandleUIMessage(bp_pandora_waiting, "UIShow");	
end

-- 关闭面板
function PandoraWaitingUI.Hide()
	log("gavin PandoraWaitingUI:Hide()");
	PandoraWaitingUI.isShowing = false;	
	LuaClassObj.HandleUIMessage(bp_pandora_waiting, "UIHide");	
end