-- 概率显示弹窗
Rate_Panel_UI = Rate_Panel_UI or 
{
	isShow = false
}

-- 品质掉落概率
BP_ARRAY_Drop_Rate = {
	rate = "",
};

-- 物品掉落概率------------
-- 物品信息
BP_STRUCT_Item_Drop_Rate_Info = 
{
	itemID = 0,
	limitEndTime = 0,
	rate = "",
	count = 0,
}

-- 物品列表
BP_ARRAY_Item_Drop_Rate = 
{
	BP_STRUCT_Item_Drop_Rate_Info = _G.BP_STRUCT_Item_Drop_Rate_Info;
}
----------------------------

BP_ARRAY_Drop_Title_Id = 6152 --本地化ID
BP_Drop_Rate_Desc = ""

--注册Widget
function bp_rate_panel_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_rate_panel,
		{{Path="/Game/UMG/UI_LOGIC/Lobby_Store/Drop_Rate_Panel.Drop_Rate_Panel_C", Container="Default", ZOrder=BP_ENUM_UI_COMMON_MESSAGEBOX_ZORDER - 1}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function Rate_Panel_UI.Show(rate_array, title, desc)
	log_tree("rate_array", rate_array);
	BP_ARRAY_Drop_Title_Id = title or 6152

	BP_ARRAY_Drop_Rate = rate_array;

	BP_Drop_Rate_Desc = desc or ""
	
	LuaClassObj.HandleDynamicCreation(bp_rate_panel);

	LuaClassObj.HandleUIMessage(bp_rate_panel, "UIShow");
	UIManager.Show(eUIType.eRatePanel);
	Rate_Panel_UI.isShow = true
end

function Rate_Panel_UI.Hide()
	log("Rate_Panel_UI.Hide")
	Rate_Panel_UI.isShow = false
	BP_ARRAY_Drop_Title = ""
	LuaClassObj.HandleUIMessageNoFetch(bp_rate_panel, "UIHide");
	UIManager.Hide(eUIType.eRatePanel);
end

function Rate_Panel_UI.ShowItemRate(rate_array, title)
	BP_ARRAY_Item_Drop_Rate = {};
	for k,v in pairs(rate_array) do
		local itemInfo = {};
		itemInfo.itemID = v.itemId;
		itemInfo.rate = v.rate;
		itemInfo.limitEndTime = v.limitEndTime;
		itemInfo.count = v.count and v.count > 1 and v.count or 0;
		BP_ARRAY_Item_Drop_Rate[#BP_ARRAY_Item_Drop_Rate + 1] = itemInfo;
	end
	BP_ARRAY_Drop_Title_Id = title or 6639
	LuaClassObj.HandleDynamicCreation(bp_rate_panel);
	LuaClassObj.HandleUIMessage(bp_rate_panel, "UIShowItemRate");
	UIManager.Show(eUIType.eRatePanel);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end

function EventRate_Panel_UI_Hide()
	Rate_Panel_UI.Hide()
end

function Rate_Panel_UI.StrSplit(str, reps)
    local resultStrList = {}
    string.gsub(str, '[^'..reps..']+', function(w)
        table.insert(resultStrList,w)
    end)
    return resultStrList
end