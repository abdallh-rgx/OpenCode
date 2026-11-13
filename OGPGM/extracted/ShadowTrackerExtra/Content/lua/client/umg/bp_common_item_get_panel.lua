CommonItemGetUI = CommonItemGetUI or 
{
	onClickCallback = nil,
	disableGoodItem = false,
	bShow = false;
}

BP_STRUCT_ItemGetPanel_ItemData =
{
	res_id = 0,
	count = 0,
	valid_hours = 0,
	expire_ts = 0,
	to_res_id = 0,
	to_res_cnt = 0,

	colorID = 0,
	patternID = 0,
};
BP_ARRAY_ItemGetPanel_ItemData =
{
    BP_STRUCT_ItemGetPanel_ItemData = _G.BP_STRUCT_ItemGetPanel_ItemData, --定义结构体数组，这种写法要作为规范规定下来
};
--给通用弹窗加个标题
BP_TitleText = ""
-- 注册面板
function bp_common_item_get_panel_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_common_item_get_panel,
		{
			{Path="/Game/UMG/UI_Logic/Common/Common_Item_Get_Panel_BP.Common_Item_Get_Panel_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEM_GET_ZORDER},
		 	{Path="/Game/UMG/UI_Logic/Common/Annual_Item_Get_Panel_BP.Annual_Item_Get_Panel_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEM_GET_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

-- 显示物品获得面板
--[[
	array
		BP_STRUCT_ItemGetPanel_ItemData
			res_id
			count			
			...
]]
local batchItems = {}

---isfromDecompose 为了分解多+了个按钮
function CommonItemGetUI:ShowPanel(arrayItemData,title)
	LuaClassObj.HandleDynamicCreation(bp_common_item_get_panel);
	--log_tree("CommonItemGetUI:ShowPanel", arrayItemData);
	CommonItemGetUI.onClickCallback = nil
	CommonItemGetUI.disableGoodItem = false

	BP_ARRAY_ItemGetPanel_ItemData = {};	

	--拷贝一份免得部分模块缺少字段
	for k,v in pairs(arrayItemData) do
		if v and v.res_id then
			local item = {}
			item.res_id = v.res_id
			item.count = v.count or 0
			item.valid_hours = v.valid_hours or 0
			item.expire_ts = v.expire_ts or 0
			item.colorID = v.color_id;
			item.patternID = v.pattern_id;
			item.to_res_id = v.to_res_id;
			item.to_res_cnt = v.to_res_cnt;
			BP_ARRAY_ItemGetPanel_ItemData[#BP_ARRAY_ItemGetPanel_ItemData + 1] = item
		end
	end
	--有标题传入的话
	if title and title~= "" then
		BP_TitleText = title
		LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "UISetTitle");
	else
		BP_TitleText = FuncUtil.GetLocalizeResStr("102008")
		LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "UISetTitle");
	end
	--是否显示周年庆特殊界面
	if BP_Lobby_BgAnniversaryGetSwitch == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "UIShowAnnual");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "UIShow");
	end
	CommonItemGetUI.bShow = true;
end

function CommonItemGetUI:ShowPanelWithCallback(arrayItemData,callback ,disableGoodItem)	
	CommonItemGetUI:ShowPanel(arrayItemData)
	CommonItemGetUI.onClickCallback = callback
	CommonItemGetUI.disableGoodItem = disableGoodItem
end

function CommonItemGetUI:ShowBatchPanel(arrayItemData)
	batchItems = arrayItemData

	local item = batchItems[1]
	table.remove(batchItems, 1)

	CommonItemGetUI:ShowPanel(item)
end

function EventTryToShowGetPanel()

	if EightDayUI and EightDayUI.IsClickButtonEightDay == true then
		ClientSendBAReport(BP_BA_EIGHT_DAYS_AWARD_OK, 0);
		EightDayUI.IsClickButtonEightDay = false;
	end
	if WeekSignUpUI and WeekSignUpUI.IsClickButtonWeekSign == true then
		ClientSendBAReport(BP_BA_WEEK_LOGIN_AWARD_OK, 0);
		WeekSignUpUI.IsClickButtonWeekSign = false;
	end

	if CommonItemGetUI.disableGoodItem == false then
		GoodItemGetUI:ShowGetPanel(BP_ARRAY_ItemGetPanel_ItemData);
	end
	
	if CommonItemGetUI.onClickCallback ~= nil then
		CommonItemGetUI.onClickCallback()
		CommonItemGetUI.onClickCallback = nil
	end 
end

function EventNextItem()
	if #batchItems == 0 then
		-- 恭喜获得结束
		EventSystem:postEvent(EVENTTYPE_LOBBY, EVNETID_ITEM_GET_DONE);
		return
	end

	local item = batchItems[1]
	table.remove(batchItems, 1)

	CommonItemGetUI:ShowPanel(item)
end

function EventCommonItemGetShowPanel_Push()	
    log("EventCommonItemGetShowPanel_Push");
end

--只用于从分解跳转到商城
function EventFromWardrobrGoToSupply()
	CommonItemGetUI:Hide()
	ItemDecomposeUI.Hide()
	WardrobeUI:Hide();
	local info = {}
	info.itemId = 0
	info.Tab1 = StoreSystem.Page_ID_Exchange
	info.Tab2 = 0
	info.bValid = true
	local strRegion = Client.GetPublishRegion()
	if strRegion and strRegion == "GLOBAL" then
		info.moduleId = JumpUtils.MODEL_ID_STORE
		JumpUtils.JumpReal(JumpUtils.MODEL_ID_LOBBY,JumpUtils.MODEL_ID_STORE,info)
	else
		info.moduleId = JumpUtils.MODEL_ID_SUPPLY
		JumpUtils.JumpReal(JumpUtils.MODEL_ID_LOBBY,JumpUtils.MODEL_ID_SUPPLY,info)
	end
end

function CommonItemGetUI:Hide()
	BP_ARRAY_ItemGetPanel_ItemData = {};
	if CommonItemGetUI.onClickCallback ~= nil then
		CommonItemGetUI.onClickCallback()
		CommonItemGetUI.onClickCallback = nil
	end
	if true == CommonItemGetUI.bShow then
	if BP_Lobby_BgAnniversaryGetSwitch == true then
		LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "UIHideAnnual");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_common_item_get_panel, "UIHide");
	end
    CommonItemGetUI.bShow =false;
	end
end
