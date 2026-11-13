--评价
AppraiseUI = AppraiseUI or
{
	
}


--注册Widget
function bp_appraise_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_appraise,
		{{Path="/Game/UMG/UI_Logic/Appraise/Appraise_BP.Appraise_BP_C", Container="Default", ZOrder=BP_ENUM_UI_APPRAISE_ZORDER}},
		{"Lobby"},
		false,
		bp_appraise_OnModeSwitched~=nil ,
		true
	);

end


function EventGotoAppraise()


end


function bp_appraise_OnModeSwitched(gamestatus)
	if string.lower(gamestatus) == "lobby" then
       	if AppraiseSystem.bShowUI then
			AppraiseUI.ShowUI();
		end
	elseif string.lower(gamestatus) == "login" then
		AppraiseSystem.Clear();
	end
end


function AppraiseUI.ShowUI()
	log("AppraiseUI.ShowUI")
	AppraiseSystem.Clear();
	--AppraiseSystem.Init();
	LuaClassObj.HandleDynamicCreation(bp_appraise);
    LuaClassObj.HandleUIMessage(bp_appraise, "UIShow");
end

function AppraiseUI.HideUI()
	LuaClassObj.HandleUIMessage(bp_appraise, "UIHide");
end





