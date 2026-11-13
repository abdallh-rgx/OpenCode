BP_STRUCT_OB_TOP_KILLER_SINGLE = 
{
	uid = "",
	kill_num = 0
}

BP_STRUCT_OB_TOP_DAMAGE_SINGLE = 
{
	uid = "",
	damage = 0
}

BP_STRUCT_OB_TOP_HIT_RATE_SINGLE = 
{
	uid = "",
	hit_rate = 0
}

BP_STRUCT_OB_TITLE_TOTAL =
{
	battle_id = 0,
	first_blood_uid = "",
	BP_ARRAY_TOP_KILLER_LIST =
	{
		tmp_UseExist_BP_STRUCT_OB_TOP_KILLER_SINGLE = {}
	},
	BP_ARRAY_TOP_DAMAGE_LIST = 
	{
		tmp_UseExist_BP_STRUCT_OB_TOP_DAMAGE_SINGLE = {}
	},
	BP_ARRAY_TOP_HIT_RATE_LIST = 
	{
		tmp_UseExist_BP_STRUCT_OB_TOP_HIT_RATE_SINGLE = {}
	}
}

BP_STRUCT_DETAIL_GENERAL_DATA = 
{
	title_pic_path = "",
	default_player_icon_path = "",
	player_name = "",
	title_detail = ""
}

BP_ARRAY_TITLE_MORE_DETAIL_GENERAL_DATA = 
{
	tmp_UseExist_BP_STRUCT_DETAIL_GENERAL_DATA = {}
}


function bp_observer_result_title_RegisterUI(self)

	LuaClassObj.SubUIWidgetList(bp_observer_result_title,
		{
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ResultsOB/ResultsOB_ResultTitle_Detail_UIBP.ResultsOB_ResultTitle_Detail_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_OB_RESULT_TITLE_MORE_DETAIL_ZORDER},
			{Path="/Game/BluePrints/ControlInput/ResultsshareUI/ResultsOB/ResultsOB_ResultTitle_UIBP.ResultsOB_ResultTitle_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_OB_RESULT_TITLE_ZORDER}
		},
		{"Fighting"},
		false,
		false,
		true
	);
end

CurDetailTitleName = ""

OBResultTitle = OBResultTitle or
{
}

function OBResultTitle.SyncTitleDataToBP()
	log("sync title data to bp")
	LuaClassObj.HandleUIMessage(bp_observer_result_title, "SyncTitleData"); 
end

function EventCreateResultTitle()
	log("Dynamic create ob result title")
	LuaClassObj.HandleDynamicCreation(bp_observer_result_title);
end

function EventShowResultTitle()
	log("Show ob result title")
	LuaClassObj.HandleUIMessage(bp_observer_result_title, "ShowOBResultTitle"); 
end

function EventTitleMoreDetailData_Push()

end

function EventShowMoreDetailPanel()
	log("Show more detail panel")
	LuaClassObj.HandleUIMessage(bp_observer_result_title, "ShowMoreDetailPanel");
end