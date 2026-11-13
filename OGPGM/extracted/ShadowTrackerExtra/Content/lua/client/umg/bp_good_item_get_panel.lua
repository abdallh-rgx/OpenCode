--获得高品质物品UI，带提示分享按钮
GoodItemGetUI = GoodItemGetUI or
{
	isShow = false,
	onClickCallback = nil,
}

--要炫耀的物品列表
BP_STRUCT_GoodItemGet_ToShow =
{
	res_id = 0,
	count = 0,
	valid_hours_str = "",
	color_id = 0,
	pattern_id = 0,
	shareType = 0,
};
BP_Array_GoodItemGet_ToShow = 
{
	BP_STRUCT_GoodItemGet_ToShow = _G.BP_STRUCT_GoodItemGet_ToShow,
};

BP_HasShareNum = 0;
BP_IsShareAwardGold = false; --每日首分享是否金币奖励

function bp_good_item_get_panel_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_good_item_get_panel,
		{		
			{Path="/Game/UMG/UI_Logic/Share/Good_Item_Get_BP.Good_Item_Get_BP_C", Container="Top", ZOrder=BP_ENUM_UI_GOOD_ITEM_GET_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
	BP_Array_GoodItemGet_ToShow = {};
	BP_HasShareNum = 0;
	BP_IsShareAwardGold = false;
    

    EventSystem:registEvent(EVENTTYPE_BIND_INTL, EVENTID_VERSION_UPDATE_IOS_CHECK, GoodItemGetUI.HandleIOSCheck);

end	 

function GoodItemGetUI.HandleIOSCheck()
	-- body
    if GlobalData:IsIOSCheck() then
        LuaClassObj.SubCollapseWidgetList(bp_good_item_get_panel,
            "Good_Item_Get_BP_C",
            {
                "Overlay_Sharebtn",
                "Overlay_GridTips",
            }
        );
    LuaClassObj.HandleCollapseWidgetList(bp_good_item_get_panel, "Good_Item_Get_BP_C");
    end
    
end


function GoodItemGetUI:ShowGetPanel(arrayItemData)
	GoodItemGetUI.onClickCallback = nil
	LuaClassObj.HandleDynamicCreation(bp_good_item_get_panel);
	for i,v in ipairs(arrayItemData) do
		local iteminfo = Client.GetTableData("Item", v.res_id);
		--高品质物品才弹面板
		if iteminfo.NeedShare ~= 0 then
			local str = "";
			if v.valid_hours ~= nil and v.valid_hours > 0 then
				if v.valid_hours >= 24 then
					--str = "[" .. tostring(math.ceil(v.valid_hours / 24)) .. "天]";
					str = string.format(Client.GetTableData("LocalizeRes", "301173").TextValue, tostring(math.ceil(v.valid_hours / 24)));
				else
					--str = "[" .. tostring(v.valid_hours) .. "小时]";
					str = string.format(Client.GetTableData("LocalizeRes", "301174").TextValue, tostring(v.valid_hours));
				end
			end
			local toShowItem = {res_id = v.res_id, count = v.count, valid_hours_str = str, color_id = v.color_id, pattern_id = v.pattern_id, shareType = iteminfo.NeedShare };
			table.insert(BP_Array_GoodItemGet_ToShow, #BP_Array_GoodItemGet_ToShow + 1, toShowItem);
		end
	end
	if GoodItemGetUI.isShow == false and #BP_Array_GoodItemGet_ToShow > 0 then
		GoodItemGetUI.isShow = true;
		BP_HasShareNum =  GoodItemGetUI:GetShareNum();--ShareMgr.GetShareNum();
		BP_IsShareAwardGold = ShareAwardMgr.IsAllAwardHasGet();
		LuaClassObj.HandleUIMessage(bp_good_item_get_panel, "UIShow");
	end
end


function GoodItemGetUI:ShowGetPanelWithCallback(arrayItemData,callback)

	GoodItemGetUI:ShowGetPanel(arrayItemData)
	GoodItemGetUI.onClickCallback = callback 
end

function GoodItemGetUI:GetShareNum()
	if ShareAwardMgr.IsTodayShareDone() then
		return 1;
	else
		return 0;
	end
end

function EventShowGetPanel()
	if #BP_Array_GoodItemGet_ToShow <= 0 then
		--没有公告，不处理
		GoodItemGetUI.isShow = false;
		return;
	end
	if #BP_Array_GoodItemGet_ToShow == 1 then
		--公告长度-1后，不处理
		GoodItemGetUI.isShow = false;
		BP_Array_GoodItemGet_ToShow = {};
		if GoodItemGetUI.onClickCallback ~= nil then
			-- 需要先清空回调，再调用，因为调用的逻辑里有设置这个回调
			local func = GoodItemGetUI.onClickCallback;
			GoodItemGetUI.onClickCallback = nil;
			func();
		end
		return;
	end
	
	LuaClassObj.HandleDynamicCreation(bp_good_item_get_panel);
	
	table.remove(BP_Array_GoodItemGet_ToShow, 1);
	BP_HasShareNum =  GoodItemGetUI:GetShareNum();--ShareMgr.GetShareNum();
	BP_IsShareAwardGold = ShareAwardMgr.IsAllAwardHasGet();
	LuaClassObj.HandleUIMessage(bp_good_item_get_panel, "UIShow");
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end
