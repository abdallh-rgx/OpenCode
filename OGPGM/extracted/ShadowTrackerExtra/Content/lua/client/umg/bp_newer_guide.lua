-- 新手类型选择UI
NewerGuideUI = NewerGuideUI or {}

--注册Widget
function bp_newer_guide_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_newer_guide,
    {
        {Path="/Game/UMG/UI_BP/Lobby/Lobby_BeginnerGuide_UIBP.Lobby_BeginnerGuide_UIBP_C", Container="Top", ZOrder=BP_ENUM_TOP_UI_NEWER_GUIDE_ZORDER},

    },
    {"Lobby"},
	false,
	true,
    true
  );
end

BP_Newer_Guide_Selected_Type = 0
        
function bp_newer_guide_OnModeSwitched(gamestatus)
    
	if string.lower(gamestatus) == "lobby" then
        NewerGuideUI:ShowNewerTypeSelectionUI()
	end
end

function EventNewerGuideSelection()
    log("EventNewerGuideSelection()"..tostring(BP_Newer_Guide_Selected_Type))
    DataMgr.fresher_type = BP_Newer_Guide_Selected_Type
    NetUtil.SendPkg("set_fresher_type_req", BP_Newer_Guide_Selected_Type);
end

function NewerGuideUI:ShowNewerTypeSelectionUI()
    log("NewerGuideUI:ShowNewerTypeSelectionUI()"..tostring(DataMgr.fresher_type))
    log("NewerGuideUI:ShowNewerTypeSelectionUI()"..tostring(DataMgr.fresher_type ~= nil))
    if DataMgr.fresher_type ~= nil and DataMgr.fresher_type == 0 then
        LuaClassObj.HandleDynamicCreation(bp_newer_guide);
        LuaClassObj.HandleUIMessage(bp_newer_guide, "UIShow");
    end
end