UnknowPassShowAward = UnknowPassShowAward or
{
    IsUIShow = false,

    -- 当界面隐藏时，会调用这个回调函数
    HideCallBack = nil,
}

BP_STRUCT_UnknowPassShowAward_Item = {
	resId = 0,
    number = 0,
    showType = 0,
}

BP_ENUM_UnknowPassShowAward_ShowType_None = 0; -- 不需要特殊显示
BP_ENUM_UnknowPassShowAward_ShowType_Icon = 1; -- 特殊显示物品图标
BP_ENUM_UnknowPassShowAward_ShowType_Gun = 2; -- 特殊枪械，用于展示长条图

BP_UnknowPassShowAward_Level = 0;

BP_UnknowPassShowAward_SelectItem = 0;
BP_UnknowPassShowAward_ShowItemIndex = 0;
BP_UnknowPass_ShowAward_Can_Play_Animation = true;

BP_UnknowPass_Show_Award_Gender = 1;

-- 奖励列表
BP_ARRAY_UnknowPassShowAward_Item_List = 
{
	BP_STRUCT_UnknowPassShowAward_Item = _G.BP_STRUCT_UnknowPassShowAward_Item,
};

-- 特殊奖励列表
BP_ARRAY_UnknowPassShowAward_SpecialItem_List = 
{
	BP_STRUCT_UnknowPassShowAward_Item = _G.BP_STRUCT_UnknowPassShowAward_Item,
};

function bp_unknow_pass_show_award_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_show_award,
    {
        {Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Show_Award_Logic_BP.UnknowPass_Show_Award_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}
    },
    {"Lobby"},
    false,
    bp_unknow_pass_show_award_OnModeSwitched ~= nil,
    true);
end

function UnknowPassShowAward.ShowUI(itemList)
    BP_UnknowPass_Show_Award_Gender = DataMgr.avatarData.gamegender
    
    UnknowPassShowAward.IsUIShow = true;
	BP_UnknowPass_ShowAward_Can_Play_Animation = BP_UnknowPass_Can_Play_Animation

    BP_ARRAY_UnknowPassShowAward_Item_List = itemList;
    BP_ARRAY_UnknowPassShowAward_SpecialItem_List = {};
    
    for i,v in ipairs(itemList) do
        if v.showType ~= BP_ENUM_UnknowPassShowAward_ShowType_None then
			table.insert(BP_ARRAY_UnknowPassShowAward_SpecialItem_List, v);
        end
    end

    LuaClassObj.HandleDynamicCreation(bp_unknow_pass_show_award);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_show_award, "UIShow");
    UIManager.Show(eUIType.eUnknowPassShowAwardUI);
end

function UnknowPassShowAward.HideUI()
    UnknowPassShowAward.IsUIShow = false;
    UIManager.Hide(eUIType.eUnknowPassShowAwardUI);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_show_award, "UIHide");
    
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_CLOSE_SHOW_AWARD);
    
    if UnknowPassShowAward.HideCallBack then
        UnknowPassShowAward.HideCallBack();
        UnknowPassShowAward.HideCallBack = nil;
    end
end

-- bp event
function EventCloseUnknowPassShowAwardClick_Push()
    UnknowPassShowAward.HideUI();
end

--sami 弹出分享界面
function EventUnknowPassShowAwardShare()
	--log_tree("BP_ARRAY_UnknowPassShowAward_SpecialItem_List", BP_ARRAY_UnknowPassShowAward_SpecialItem_List)
	--log_tree("BP_UnknowPassShowAward_ShowItemIndex", BP_UnknowPassShowAward_ShowItemIndex)
	local item = BP_ARRAY_UnknowPassShowAward_SpecialItem_List[BP_UnknowPassShowAward_ShowItemIndex + 1] 
	if nil == item then
		return
	end
	--log_tree("item", item)
	local toShowItem = {res_id = item.resId, count = item.number, valid_hours_str = "" , shareType = item.showType};
	table.insert(BP_Array_GoodItemGet_ToShow, #BP_Array_GoodItemGet_ToShow + 1, toShowItem);
	
	ItemShareUI:ShowSharePanel()
end
