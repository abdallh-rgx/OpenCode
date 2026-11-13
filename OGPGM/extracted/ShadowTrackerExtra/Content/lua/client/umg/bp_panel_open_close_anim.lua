PanelOpenCloseAnimSystem = PanelOpenCloseAnimSystem or 
{

}

BP_View_To_Lobby = 0;

BP_Open_Lua_Func = "";

BP_Close_lua_Func = "";

function bp_panel_open_close_anim_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_panel_open_close_anim,
	{
		{Path="/Game/UMG/UI_BP/Lobby/Lobby_MallSystemAnim_2_UIBP.Lobby_MallSystemAnim_2_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_COMMON_ITEM_GET_ZORDER}
	},
	{"Lobby"},
	false,
	false
	);
end

function PanelOpenCloseAnimSystem.OpenView(openFuncName, closeFuncName)
	BP_View_To_Lobby = 1;
	BP_Open_Lua_Func = openFuncName;
	BP_Close_lua_Func = closeFuncName;
	LuaClassObj.HandleUIMessage(bp_panel_open_close_anim, "UIShowMallAvatarAni");
end

function PanelOpenCloseAnimSystem.CloseView()
	BP_View_To_Lobby = 0;
	LuaClassObj.HandleUIMessage(bp_panel_open_close_anim, "UIShowMallAvatarAni");
end