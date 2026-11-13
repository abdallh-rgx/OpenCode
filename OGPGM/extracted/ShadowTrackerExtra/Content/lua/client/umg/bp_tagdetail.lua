--标签详情界面
TagDetailUI = TagDetailUI or {}

BP_TAG_NAME = "";
BP_TAG_PIC = "";
BP_TAG_DES = "";

--注册Widget
function bp_tagdetail_RegisterUI()
	log("Qpp bp_TagDetailUI_RegisterUI")
	LuaClassObj.SubUIWidgetList(bp_tagdetail,
			{{Path="/Game/UMG/UI_Logic/Wardrobe/TagDetail_BP.TagDetail_BP_C", Container="Default", ZOrder= BP_ENUM_LOBBY_MENU_WARDROBE + 1}},
			{"Lobby"},
			false,
			false,
			true
	);
end

function TagDetailUI.ShowUI(name, pic, des)
	BP_TAG_NAME = name;
	BP_TAG_PIC = pic;
	BP_TAG_DES = des;
	log("BP_TAG_NAME: ".. BP_TAG_NAME);
	log("BP_TAG_PIC: ".. BP_TAG_PIC);
	log("BP_TAG_DES: ".. BP_TAG_DES);
	log("Qpp Enter TagDetailUI UI")
	LuaClassObj.HandleDynamicCreation(bp_tagdetail);
	LuaClassObj.HandleUIMessageNoFetch(bp_tagdetail, "UIShow");
end

function TagDetailUI.HideUI()
	LuaClassObj.HandleUIMessageNoFetch(bp_tagdetail, "UIHide");
end