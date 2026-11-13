-- 普通账号获取普通奖励
UnknowPassShowOrdinaryAward = UnknowPassShowOrdinaryAward or
{
    IsUIShow = false,
}

BP_UnknowPassShowOrdinaryAward_SelectItem = 0;
BP_UnknowPassShowOrdinaryAward_ShowItemIndex = 0;
BP_UnknowPass_ShowOrdinaryAward_Can_Play_Animation = true;

BP_UnknowPass_Show_Ordinary_Award_Gender = 1;

local UnknowPass_Show_Ordinary_Award_UC_ID = 1006;

-- 奖励普通列表
BP_ARRAY_UnknowPassShowOrdinaryAward_OrdinaryItem_List =
{
    tmp_UseExist_BP_STRUCT_UnknowPassShowAward_Item = {}
};

--精英奖励列表
BP_ARRAY_UnknowPassShowOrdinaryAward_EliteItem_List =
{
    tmp_UseExist_BP_STRUCT_UnknowPassShowAward_Item = {}
};

--特殊奖励列表
BP_ARRAY_UnknowPassShowOrdinaryAward_SpecialItem_List =
{
    tmp_UseExist_BP_STRUCT_UnknowPassShowAward_Item = {}
};

function bp_unknow_pass_show_ordinary_award_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_show_ordinary_award,
    {
        {Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Show_Ordinary_Award_Logic_BP.UnknowPass_Show_Ordinary_Award_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}
    },
    {"Lobby"},
    false,
    bp_unknow_pass_show_ordinary_award_OnModeSwitched ~= nil,
    true);
end

-- 获取精英奖励
local function GetEliteItem()
    BP_ARRAY_UnknowPassShowOrdinaryAward_EliteItem_List = {};
    local elite_reward_map = {};
    for _,eliteReward in pairs(UnknowPassSystem.Data.elite_reward_cfg) do
        if eliteReward.level <= UnknowPassSystem.Level then
            for i,v in ipairs(eliteReward.reward) do                
                local groupId = v.item_id;
                local split_group_config = UnknowPassSystem.Award_Group_Data[groupId];	--获取分组表物品
                for i,reward_item in pairs(split_group_config.reward)  do                    
                    local itemId = reward_item.item_id;
                    local reward = elite_reward_map[itemId];
                    local resItem = Client.GetTableData("Item",itemId);
                    if nil ~= resItem then
                        reward_item.item_quality = resItem.ItemQuality
                        if nil ~=  reward then
                            reward.item_num = reward.item_num + reward_item.item_num;
                        else
                            local item ={
                                item_id = reward_item.item_id,
                                item_num = reward_item.item_num,
                                item_show_type = reward_item.item_show_type,
                                item_quality = reward_item.item_quality;
                            };
                            elite_reward_map[itemId] = item;
                        end
                    end
                end                
            end
        end
    end

    local elite_reward_array = {};
    for _,eliteReward in pairs(elite_reward_map) do
        table.insert(elite_reward_array, {
            item_id = eliteReward.item_id,
            item_num = eliteReward.item_num,
            item_show_type = eliteReward.item_show_type,
            item_quality = eliteReward.item_quality;
        })
    end

    table.sort(elite_reward_array, function(a, b)
        return a.item_quality > b.item_quality
    end)

    for _,eliteReward in pairs(elite_reward_array) do
        -- UC 放前面
        if eliteReward.item_id == UnknowPass_Show_Ordinary_Award_UC_ID then
            table.insert(BP_ARRAY_UnknowPassShowOrdinaryAward_EliteItem_List, 1, {
                resId = eliteReward.item_id,
                number = eliteReward.item_num,
                showType = eliteReward.item_show_type,
            })
        else
            table.insert(BP_ARRAY_UnknowPassShowOrdinaryAward_EliteItem_List, {
                resId = eliteReward.item_id,
                number = eliteReward.item_num,
                showType = eliteReward.item_show_type,
            })
        end
    end
end

-- 显示界面
function UnknowPassShowOrdinaryAward.ShowUI(itemList)
    BP_UnknowPass_Show_Ordinary_Award_Gender = DataMgr.avatarData.gamegender;
    
    UnknowPassShowAward.IsUIShow = true;
    BP_UnknowPass_ShowOrdinaryAward_Can_Play_Animation = BP_UnknowPass_Can_Play_Animation;
    BP_ARRAY_UnknowPassShowOrdinaryAward_OrdinaryItem_List = itemList;
    BP_ARRAY_UnknowPassShowOrdinaryAward_SpecialItem_List = {};
    for i,v in ipairs(itemList) do
        if v.showType ~= BP_ENUM_UnknowPassShowAward_ShowType_None then
            table.insert(BP_ARRAY_UnknowPassShowOrdinaryAward_SpecialItem_List, v);
        end
    end

    GetEliteItem();

    LuaClassObj.HandleDynamicCreation(bp_unknow_pass_show_ordinary_award);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_show_ordinary_award, "UIShow");
    UIManager.Show(eUIType.eUnknowPassShowOrdinaryAwardUI);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, UnknowPassShowOrdinaryAward.OnBuyPass);
end

-- 关闭界面
function UnknowPassShowOrdinaryAward.HideUI()
    UnknowPassShowAward.IsUIShow = false;
    UIManager.Hide(eUIType.eUnknowPassShowOrdinaryAwardUI);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_show_ordinary_award, "UIHide");

    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_CLOSE_SHOW_AWARD);
    EventSystem:unregistEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, UnknowPassShowOrdinaryAward.OnBuyPass);
end

function EventUnknowPassAwardShowOrdinaryAwardBuyClick_Push()
    UnknowPassBuy.ShowUI();
end

-- 关闭ui
function EventCloseUnknowPassShowOrdinaryAwardClick()
    UnknowPassShowOrdinaryAward.HideUI();
end

-- 弹出分享界面
function EventUnknowPassShowOrdinaryAwardShare()
    local item = BP_ARRAY_UnknowPassShowOrdinaryAward_SpecialItem_List[BP_UnknowPassShowOrdinaryAward_ShowItemIndex + 1]
    if nil == item then
        return
    end
    --log_tree("item", item)
    local toShowItem = {res_id = item.resId, count = item.number, valid_hours_str = ""};
    table.insert(BP_Array_GoodItemGet_ToShow, #BP_Array_GoodItemGet_ToShow + 1, toShowItem);

    ItemShareUI:ShowSharePanel()
end

-- 购买通行证
function UnknowPassShowOrdinaryAward.OnBuyPass(evenType, eventID)
    UnknowPassShowOrdinaryAward.HideUI();
    GemReportUtils.ReportBtnClickEvent(GemReportUtils.SubEventName_PassUpgradeFromGetLevelAward)
end

