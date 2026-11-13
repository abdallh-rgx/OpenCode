RoleInfoCorpAlias = RoleInfoCorpAlias or {
}

BP_Current_CorpAliasId = 0;
BP_Select_CorpAliasId = 0;
BP_STRUCT_RoleInfo_CorpsAliasData= 
{
	aliasId = 0,
	remainTime = "",
	aliasName = "",
	position = 0,
	aliasType = 0,
}

BP_ARRAY_RoleInfo_CorpsAliasDataList = {
	BP_STRUCT_RoleInfo_CorpsAliasData = _G.BP_STRUCT_RoleInfo_CorpsAliasData,
}

-- 注册Widget
function bp_roleinfo_corpalias_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_corpalias,
    	{{Path="/Game/UMG/UI_Logic/Corps/CorpsChoosetitle_BP.CorpsChoosetitle_BP_C", Container="Default", ZOrder = BP_ENUM_UI_ROLEINFO_ZORDER+2}},
    	{"Lobby"},
		false,
		false,
		true
  	);
end

function RoleInfoCorpAlias.InIt()
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_corpalias);
	RoleInfoCorpAliasSystem.get_corps_alias_list_request();
end

function RoleInfoCorpAlias.ShowUI()
	log("RoleInfoCorpAlias.ShowUI")
	LuaClassObj.HandleUIMessage(bp_roleinfo_corpalias, "ShowUI");
	UIManager.Show(eUIType.eCorpsChoosetitleUI)
end

function RoleInfoCorpAlias.Release()
	BP_ARRAY_RoleInfo_CorpsAliasDataList = {};
end

function EventCorpAliasHide()
	UIManager.Hide(eUIType.eCorpsChoosetitleUI)
	LuaClassObj.HandleUIMessage(bp_roleinfo_corpalias, "HideUI");
end

function EventSendCorpUseAlias()
	if BP_Current_CorpAliasId ~= BP_Select_CorpAliasId then
		RoleInfoCorpAliasSystem.change_corps_alias_request(BP_Select_CorpAliasId);
	end
end