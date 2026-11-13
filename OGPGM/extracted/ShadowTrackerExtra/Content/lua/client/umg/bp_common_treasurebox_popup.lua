CommonTreasureBoxPopup = CommonTreasureBoxPopup or 
{
    isShow = false,

}


-- 同步物品掉落列表
BP_STRUCT_DropItem = {
	DropItemID = 0, 
	DropItemNum = 0, 
	DropItemSort = 0,
    DropItemTime = 0 ---临时的东西
}

BP_STRUCT_ActiveAwardItem = {
	BP_ARRAY_FixItemList = {
		BP_STRUCT_DropItem = BP_STRUCT_DropItem
	},
	BP_ARRAY_RandomItemList = {
		BP_STRUCT_DropItem = BP_STRUCT_DropItem
	}
}

BP_TitleName_String = ""

-- 注册面板
function bp_common_treasurebox_popup_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_common_treasurebox_popup,
		{{Path="/Game/UMG/UI_Logic/Common/Common_TreasureBox_Popup_BP.Common_TreasureBox_Popup_BP_C", Container="Default", ZOrder=0}},
		{"Lobby","Fighting","CreateRole"},
		false,
		false,
		true
	);	
end

local function GenDataByDropId(dropId)
	BP_STRUCT_ActiveAwardItem = {
		BP_ARRAY_FixItemList = {},
		BP_ARRAY_RandomItemList = {}
	}

    local drop_util = require("client.common.drop_util")
    local dropTable = drop_util.GetDropsList({dropId});
    for _,dropInfo in pairs(dropTable) do
    	log("dropInfo.DropItemID")
    	if dropInfo.DropItemWeight >= 1000000 then
    		table.insert(BP_STRUCT_ActiveAwardItem.BP_ARRAY_FixItemList, dropInfo)
    	else
    		table.insert(BP_STRUCT_ActiveAwardItem.BP_ARRAY_RandomItemList, dropInfo)
    	end
    end
end

local function GenDataByID(dropID)
	local taskActiveName = TaskUI.GetTaskActiveTableName()
	local tableTaskActiveInfo = Client.GetTableData(taskActiveName, dropID)
	if tableTaskActiveInfo == nil then
		log("task active table data not found" .. dropID)
		return
	end

	GenDataByDropId(tableTaskActiveInfo.DropID)

    -- local dropTable = Client.GetTable("Drop")
    -- for _,dropInfo in pairs(dropTable) do
    --     if dropInfo.DropID == tableTaskActiveInfo.DropID then
    -- 		local itemInfo = {DropItemID = dropInfo.DropItemID, DropItemNum = dropInfo.DropItemNum, DropItemSort = dropInfo.DropItemSort}
    --     	if dropInfo.Weight >= 1000000 then
    --     		table.insert(BP_STRUCT_ActiveAwardItem.BP_ARRAY_FixItemList, itemInfo)
    --     	else
    --     		table.insert(BP_STRUCT_ActiveAwardItem.BP_ARRAY_RandomItemList, itemInfo)
    --     	end
    --     end
    -- end
    -- table.sort(BP_STRUCT_ActiveAwardItem.BP_ARRAY_FixItemList, function(a, b)
    --     return a.DropItemSort > b.DropItemSort
    -- end)
    -- table.sort(BP_STRUCT_ActiveAwardItem.BP_ARRAY_RandomItemList, function(a, b)
    --     return a.DropItemSort > b.DropItemSort
    -- end)
end

local function GenDataByRewardList(reward_list)
	BP_STRUCT_ActiveAwardItem = {
		BP_ARRAY_FixItemList = {},
		BP_ARRAY_RandomItemList = {}
	}

	log_tree("GenDataByRewardList", reward_list)
	for i,reward in ipairs(reward_list) do
    	table.insert(BP_STRUCT_ActiveAwardItem.BP_ARRAY_FixItemList, {
			DropItemID = reward.item_id, 
			DropItemNum = reward.item_num, 
			DropItemSort = i,
			DropItemTime = reward.item_expire_time
		})
    end
end

function CommonTreasureBoxPopup:showPanelByDropId(dropId)
    if CommonTreasureBoxPopup.isShow then 
        return
    end

    LuaClassObj.HandleDynamicCreation(bp_common_treasurebox_popup);

    CommonTreasureBoxPopup.isShow = true
	GenDataByDropId(dropId)
	UIManager.Show(eUIType.eTreasureBoxPopUp)
	LuaClassObj.HandleUIMessage(bp_common_treasurebox_popup, "UIShow");
end

function CommonTreasureBoxPopup:ShowPanel(dropID)
    if CommonTreasureBoxPopup.isShow then 
        return
    end

    LuaClassObj.HandleDynamicCreation(bp_common_treasurebox_popup);

    CommonTreasureBoxPopup.isShow = true
	GenDataByID(dropID)
	UIManager.Show(eUIType.eTreasureBoxPopUp)
	LuaClassObj.HandleUIMessage(bp_common_treasurebox_popup, "UIShow");
end

function CommonTreasureBoxPopup:ShowPanelByItemList(reward_list)
    if CommonTreasureBoxPopup.isShow then 
        return
    end

    LuaClassObj.HandleDynamicCreation(bp_common_treasurebox_popup);

    CommonTreasureBoxPopup.isShow = true
	GenDataByRewardList(reward_list)
	UIManager.Show(eUIType.eTreasureBoxPopUp)
	LuaClassObj.HandleUIMessage(bp_common_treasurebox_popup, "UIShow");
end

function CommonTreasureBoxPopup:ClosePanel()
    CommonTreasureBoxPopup.isShow = false
	UIManager.Hide(eUIType.eTreasureBoxPopUp)
	LuaClassObj.HandleUIMessage(bp_common_treasurebox_popup, "UIClose")
end

function CommonTreasureBoxPopup:SetTitleString(str)
	BP_TitleName_String = str
	LuaClassObj.HandleUIMessage(bp_common_treasurebox_popup, "SetTitle");
end

function EventCommonTreasureBoxPopupClosePanel()
    --CommonTreasureBoxPopup:ClosePanel()
    CommonTreasureBoxPopup.isShow = false
end
