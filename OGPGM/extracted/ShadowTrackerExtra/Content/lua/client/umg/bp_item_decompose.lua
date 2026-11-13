ItemDecomposeUI = ItemDecomposeUI or {
    isInited = false,
    isShow = false,

    mapItemList = {}
};

BP_ItemDecompose_TabIndex = 0;
BP_ItemDecompose_Reward = "0";
BP_ItemDecompose_Gold_Chip_Reward = "0";
BP_ItemDecompose_IsAllIn = false;
BP_ItemDecompose_IsReLoadList = false;
BP_ItemDecompose_IsCanDecompose = false;

BP_ItemDecompose_SetIndex = 0;

BP_STRUCT_ItemDecomposeTab = {
    labName = "";
    mainTabType = 1;
    bTimeLimit = false,
};

BP_ARRAY_ItemDecomposeTab = {
    BP_STRUCT_ItemDecomposeTab = _G.BP_STRUCT_ItemDecomposeTab;
};

BP_STRUCT_DecomposeItem = {
    ins_id = "",
    res_id = 0,
    count = 0,
    total = 0,
    WardrobeTabType = 0,
    itemName = "",
    itemImage = "",
    itemQuality = 0,
    isSelect = false,
};

BP_ARRAY_DecomposeItemList = {
    BP_STRUCT_DecomposeItem = _G.BP_STRUCT_DecomposeItem,
};

local emptyTable = {};
local mapWardrobeTabType = {
    ["头部"] = 1,
    ["脸部"] = 2,
    ["衣服"] = 3,
    ["裤子"] = 4,
    ["鞋子"] = 5,
};

local UI_SWITCH_ID = 70001;
local UI_AVARTER_TAB_SWITCH_ID = 70002;
local UI_WEAPON_TAB_SWITCH_ID = 70006;
local UI_VEHICLE_TAB_SWITCH_ID = 70007;
local UI_PARACHUTE_TAB_SWITCH_ID = 70008;
local UI_TOOL_TAB_SWITCH_ID = 70009;
local UI_TIMELIMIT_TAB_SWTICH_ID = 70012;

local mainTabToSwitchID = {
    [1] = UI_AVARTER_TAB_SWITCH_ID,
    [4] = UI_WEAPON_TAB_SWITCH_ID,
    [6] = UI_VEHICLE_TAB_SWITCH_ID,
    [5] = UI_PARACHUTE_TAB_SWITCH_ID,
    [3] = UI_TOOL_TAB_SWITCH_ID,
    [10] = UI_TIMELIMIT_TAB_SWTICH_ID,
};

local function CheckFuncSwitch(funcID)
    if nil == funcID then
        return false;
    end

    local switch = LobbySystem.LobbyMenuOpenStatus[funcID];
    if switch == nil then
        return false;
    end

    if switch.is_open == 1 then
        return true;
    else
        return false;
    end
end

local function GetWardrobeTabType(WardrobeTab)
    local tabType = mapWardrobeTabType[WardrobeTab];
    if nil == tabType then
        return 0;
    end

    return tabType;
end

--注册Widget
function bp_item_decompose_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_item_decompose,
		{{Path="/Game/UMG/UI_Logic/Wardrobe/DecomposeItem_BP.DecomposeItem_BP_C", Container="Default", ZOrder=BP_ENUM_UI_WARDROBE_ZORDER + 1}},
		{"Lobby"},
		false,
		bp_item_decompose_OnModeSwitched ~= nil,
		true
	);

    DecomposeSystem.Init();
end

function bp_item_decompose_OnModeSwitched(gamestatus)
	log("bp_item_decompose_OnModeSwitched gamestatus = " .. gamestatus);
    if string.lower(gamestatus) == "fighting" then
        ItemDecomposeUI.Release();
    elseif string.lower(gamestatus) == "login" then
        ItemDecomposeUI.Release();
	end
end

function ItemDecomposeUI.Init()
    if ItemDecomposeUI.isInited then
        return;
    end

    EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, ItemDecomposeUI.OnDecomposeItemInfoRsp);

    BP_ARRAY_DecomposeItemList = {};

    ItemDecomposeUI.InitTabList();

    ItemDecomposeUI.isInited = true;
end

function ItemDecomposeUI.Release()
    if not ItemDecomposeUI.isInited then
        return;
    end

    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_ITEM_DECOMPOSE, ItemDecomposeUI.OnDecomposeItemInfoRsp);

    BP_ARRAY_DecomposeItemList = {};
    ItemDecomposeUI.mapItemList = {};
    BP_ItemDecompose_IsCanDecompose = false;

    ItemDecomposeUI.isShow = false;
    ItemDecomposeUI.isInited = false;
end

function ItemDecomposeUI.ConvertToTabIndex(mainTabType)
    --if mainTabType == nil then
    --    return 0;
    --end

    for i, v in ipairs(BP_ARRAY_ItemDecomposeTab) do
        if v.mainTabType == mainTabType then
            return i - 1;
        end
    end

    return WardrobeIndexSystem.GetDefault_ItemDecompose_TabIndex()
end

function ItemDecomposeUI.Show(mainTabType)
    if mainTabType then
        log("ItemDecomposeUI Show " .. mainTabType);
    end

    if not CheckFuncSwitch(UI_SWITCH_ID) then
        ShowNotice(116009);
        return;
    end

    LuaClassObj.HandleDynamicCreation(bp_item_decompose);

    ItemDecomposeUI.isShow = true;

    ItemDecomposeUI.Init();

    BP_ItemDecompose_TabIndex = ItemDecomposeUI.ConvertToTabIndex(mainTabType);
    log("BP_ItemDecompose_TabIndex " ..tostring(BP_ItemDecompose_TabIndex))

    ItemDecomposeUI.UpdateUI();

    LuaClassObj.HandleUIMessage(bp_item_decompose, "UIShow");

end

function ItemDecomposeUI.Hide()
    log("ItemDecomposeUI Hide");
    ItemDecomposeUI.Release();
    LuaClassObj.HandleUIMessage(bp_item_decompose, "UIHide");
end

function ItemDecomposeUI.UpdateUI()
    if not ItemDecomposeUI.isShow then
        return;
    end

    log("ItemDecomposeUI.UpdateUI")

    ItemDecomposeUI.UpdateItemList(true, false, false);

    ItemDecomposeUI.UpdateChooseInfo(false);

    LuaClassObj.HandleUIMessage(bp_item_decompose, "UpdateUI");
end

function ItemDecomposeUI.InitTabList()
    BP_ARRAY_ItemDecomposeTab = {};

    ItemDecomposeUI.AddTabItem(FuncUtil.GetLocalizeResStr(660033), 1, false);--时装页签
    ItemDecomposeUI.AddTabItem(FuncUtil.GetLocalizeResStr(4661), 4, false);--枪械页签
    ItemDecomposeUI.AddTabItem(FuncUtil.GetLocalizeResStr(4663), 6, false);--载具页签
    ItemDecomposeUI.AddTabItem(FuncUtil.GetLocalizeResStr(4654), 5, false);--战备页签
    ItemDecomposeUI.AddTabItem(FuncUtil.GetLocalizeResStr(4669), 3, false);--道具页签
    ItemDecomposeUI.AddTabItem(FuncUtil.GetLocalizeResStr(660036), 10, true);--限时物品页签
end

function ItemDecomposeUI.AddTabItem(labName, mainTabType, bTimeLimit)
    local funcID = mainTabToSwitchID[mainTabType];
    if not CheckFuncSwitch(funcID) then
        return;
    end

    local tabItem = FuncUtil:CopyTable(BP_STRUCT_ItemDecomposeTab);
    tabItem.labName = labName;
    tabItem.mainTabType = mainTabType;
    tabItem.bTimeLimit = bTimeLimit

    table.insert(BP_ARRAY_ItemDecomposeTab, tabItem);
end

function ItemDecomposeUI.GetDecomposeBackMoneyIconByIndex(index)
    if #BP_ARRAY_ItemDecomposeTab > 0 and BP_ARRAY_ItemDecomposeTab[index] ~= nil then
        local tabItem = BP_ARRAY_ItemDecomposeTab[index];
        if mainTabToSwitchID[tabItem.mainTabType] ~= nil and mainTabToSwitchID[tabItem.mainTabType] == UI_TIMELIMIT_TAB_SWTICH_ID then
            return 1000
        end
    end
    return 1001
end

function ItemDecomposeUI.UpdateItemList(isReload, isUpdate, isReLoadItem)
    log("ItemDecomposeUI.UpdateItemList")

    local isTimeLimit = BP_ARRAY_ItemDecomposeTab[BP_ItemDecompose_TabIndex + 1].bTimeLimit;
    log("BP_ItemDecompose_TabIndex " ..tostring(BP_ItemDecompose_TabIndex))
    local itemList = ItemDecomposeUI.GetDecomposeItemList(BP_ItemDecompose_TabIndex + 1, isReLoadItem, isTimeLimit);
    
     BP_ARRAY_DecomposeItemList = {};
    
    for k, v in pairs(itemList) do
         table.insert( BP_ARRAY_DecomposeItemList, v);
    end

    table.sort( BP_ARRAY_DecomposeItemList, function(a, b)
        return (a.WardrobeTabType < b.WardrobeTabType) 
                or (a.WardrobeTabType == b.WardrobeTabType and a.itemQuality < b.itemQuality)
                or (a.WardrobeTabType == b.WardrobeTabType and a.itemQuality == b.itemQuality and a.res_id < b.res_id);
    end );
    
    BP_ItemDecompose_IsReLoadList = isReload;

    if isUpdate == true then
        LuaClassObj.HandleUIMessage(bp_item_decompose, "UpdateItemList");
    end
end

function ItemDecomposeUI.OnDecomposeItemInfoRsp()
    if ItemDecomposeUI.isShow then
        ItemDecomposeUI.UpdateItemList(true, true, true);
        ItemDecomposeUI.UpdateChooseInfo(true);
        LuaClassObj.HandleUIMessage(bp_item_decompose, "UpdateUI");
    end
end

function ItemDecomposeUI.UpdateChooseInfo(isUpdate)
    local minReward = 0;
    local maxReward = 0;
    local minGoldChipReward = 0;
    local maxGoldChipReward = 0;
    local allInNum = 0;
    local selNum = 0;

    for i, v in ipairs(BP_ARRAY_DecomposeItemList) do
        if v.isSelect  then
            selNum = selNum + 1;

            if v.total > 0 and v.count >= v.total then
                allInNum = allInNum + 1;
            end

            local decomposeInfo = DecomposeSystem.GetItemDecomposeInfo(v.res_id);--Client.GetTableData("ItemDecompose", v.res_id);
            if decomposeInfo then
                if v.isTimeLimit then
                    local remainTime = ItemDecomposeUI.GetRemainTimeHours(v.expireTS);
                    --if remainTime > 999 * 24 then
                    --    remainTime = 999 * 24;
                    --end

                    if decomposeInfo.timing_item_ratio ~= nil then
                        minReward = math.ceil((decomposeInfo.timing_item_ratio / 1000) * v.count * remainTime) + minReward;
                        maxReward = minReward;
                    end
                else
                    if decomposeInfo.new_dst_item_id == 1001 then-- 银碎片
                        minReward = minReward + decomposeInfo.new_min_count * v.count;
                        maxReward = maxReward + decomposeInfo.new_max_count * v.count;
                    else-- 金碎片
                        minGoldChipReward = minGoldChipReward + decomposeInfo.new_min_count * v.count;
                        maxGoldChipReward = maxGoldChipReward + decomposeInfo.new_max_count * v.count;
                    end
                end
            else
                return
            end
        end
    end

    -- 银碎片
    if minReward == 0 and maxReward == 0 then
        BP_ItemDecompose_Reward = "0";
    elseif minReward == maxReward then
        BP_ItemDecompose_Reward = tostring(maxReward);
    else
        BP_ItemDecompose_Reward = minReward.."-"..maxReward;
    end
    -- 金碎片
    if minGoldChipReward == 0 and maxGoldChipReward == 0 then
        BP_ItemDecompose_Gold_Chip_Reward = "0";
    elseif minGoldChipReward == maxGoldChipReward then
        BP_ItemDecompose_Gold_Chip_Reward = tostring(maxGoldChipReward);
    else
        BP_ItemDecompose_Gold_Chip_Reward = minGoldChipReward.."-"..maxGoldChipReward;
    end

    if allInNum > 0 and allInNum == #BP_ARRAY_DecomposeItemList then
        BP_ItemDecompose_IsAllIn = true;
    else
        BP_ItemDecompose_IsAllIn = false;
    end

    if selNum > 0 then
        BP_ItemDecompose_IsCanDecompose = true;
    else
        BP_ItemDecompose_IsCanDecompose = false;
    end

    if isUpdate == true then
        LuaClassObj.HandleUIMessage(bp_item_decompose, "UpdateChooseInfo");
    end
end

--计算剩余小时数
function ItemDecomposeUI.GetRemainTimeHours(expireTS)
    local remainTime = expireTS - FuncUtil.GetServerTimeInSec();

    if remainTime <= 0 then
        remainTime = 1;
    end

    local hour = math.ceil(remainTime * WardrobeUI.secToHour);

    return hour;
end

function ItemDecomposeUI.GetDecomposeItemList(tabType, isReload, bTimeLimit)
    log("ItemDecomposeUI.GetDecomposeItemList tabType="..tabType);
    if tabType < 1 then
        return emptyTable;
    end

    local list = ItemDecomposeUI.mapItemList[tabType];
    if list == nil or isReload then
        list = ItemDecomposeUI.LoadDecomposeItem(tabType, bTimeLimit);
    end
    log_tree("LoadDecomposeItem list ",list)
    return list;
end

function ItemDecomposeUI.GetRemainTimeDays(expireTS)
    local result = "";
    local remainTime = expireTS - FuncUtil.GetServerTimeInSec();
    if remainTime <= 0 then
        remainTime = 1;
    end

    -- 计算天数
    local day = math.ceil(remainTime * WardrobeUI.secToHour * WardrobeUI.hourToDay);
    local dayStr = "";

    if day ~= 0 then
        dayStr = FuncUtil.LocalizeResFormat(9910108, tostring(day));
    end

    if dayStr ~= "" then
        return "("..dayStr..")";
    end
end

function ItemDecomposeUI.LoadDecomposeItem(tabType, bTimeLimit)
    log("ItemDecomposeUI.LoadDecomposeItem"..tabType.."--"..tostring(bTimeLimit));
    if tabType < 1 then
        return emptyTable;
    end

    --log_tree("ItemDecomposeUI.LoadDecomposeItem BP_ARRAY_ItemDecomposeTab=", BP_ARRAY_ItemDecomposeTab);
    local tabInfo = BP_ARRAY_ItemDecomposeTab[tabType];
    if nil == tabInfo then
        return emptyTable;
    end

    log("ItemDecomposeUI.LoadDecomposeItem");

    ItemDecomposeUI.mapItemList[tabType] = {}
    local itemTable = ItemDecomposeUI.mapItemList[tabType];

    local serverTime = FuncUtil.GetServerTimeInSec();
    local needBatchGetDecomposeInfoList = {}
    for k, v in pairs(DataMgr.arrayHallDepotItemInfo) do
        if v.mainTabType == tabInfo.mainTabType or (bTimeLimit and v.expireTS > serverTime) then
            if DecomposeSystem.HasGetDecomposeInfo(v.resID) == true then
                local itemCfg = Client.GetTableData("Item", v.resID);
                if ItemDecomposeUI.CheckItemCanDecompose(v,itemCfg, bTimeLimit) then
                    local item = FuncUtil:CopyTable(BP_STRUCT_DecomposeItem);
                    item.ins_id = v.insID;
                    item.res_id = v.resID;
                    if bTimeLimit then
                        item.total = v.count;
                    else
                        item.total = v.count - math.max(1, WardrobeUI.GetUseCount(v.insID));
                    end
                    --item.total = v.count - math.max(1, WardrobeUI.GetUseCount(v.insID));
                    item.WardrobeTabType = GetWardrobeTabType(itemCfg.WardrobeTab);
                    item.itemName = itemCfg.ItemName;
                    item.itemImage = itemCfg.ItemSmallIcon;
                    item.itemQuality = itemCfg.ItemQuality;

                    item.expireTS = v.expireTS;
                    if v.expireTS > 0 and bTimeLimit then
                        item.isTimeLimit = bTimeLimit;
                        item.itemName = itemCfg.ItemName..ItemDecomposeUI.GetRemainTimeDays(v.expireTS);
                    else
                        item.itemName = itemCfg.ItemName;
                        item.isTimeLimit = false;
                    end
                    itemTable[v.insID] = item;
                end
            else
                needBatchGetDecomposeInfoList[#needBatchGetDecomposeInfoList + 1] = v.resID;
            end       
        end
    end

    if #needBatchGetDecomposeInfoList > 0 then
        DecomposeSystem.BatchGetListDecomposeInfo(needBatchGetDecomposeInfoList);
    end

    --log_tree("ItemDecomposeUI.LoadDecomposeItem itemTab=", itemTable);

    return itemTable;
end

function ItemDecomposeUI.CheckItemCanDecompose(itemInfo, itemCfg, bTimeLimit)
    if nil == itemInfo or nil == itemCfg then
        return false;
    end

    --log_tree("ItemDecomposeUI.CheckItemCanDecompose itemInfo=", itemInfo);
    if bTimeLimit then
        if itemInfo.expireTS <= 0 then
            return false;
        end
    else
        if itemInfo.count <= math.max(1, WardrobeUI.GetUseCount(itemInfo.insID)) then
            return false;
        end
    end


    if itemCfg.SellPrice ~= 0 then
		return false;
    end
    
    if FuncUtil.Find(WardrobeUI.decomposeItemSubType, itemCfg.ItemSubType) < 0 then
		return false;
    end
    
    local decomposeInfo = DecomposeSystem.GetItemDecomposeInfo(itemInfo.resID);--CClient.GetTableData("ItemDecompose", itemInfo.resID);

    if bTimeLimit then
        if decomposeInfo == nil or decomposeInfo.timing_dst_item_id == nil or decomposeInfo.timing_item_ratio == nil or decomposeInfo.timing_dst_item_id == 0 then
            return false;
        end
    end

    if  decomposeInfo == nil or decomposeInfo.new_dst_item_id == nil or decomposeInfo.new_dst_item_id == 0 then
        return false;
    end

    return true;
end

function ItemDecomposeUI.OnDecomposeOK()
    if not ItemDecomposeUI.isShow then
        return;
    end

    log("ItemDecomposeUI.OnDecomposeOK")

    ItemDecomposeUI.UpdateItemList(true, false, true);

    ItemDecomposeUI.UpdateChooseInfo(false);

    LuaClassObj.HandleUIMessage(bp_item_decompose, "UpdateUI");
end

function EventItemDecomposeUIHide()
    log("EventItemDecomposeUIHide")
    ItemDecomposeUI.Release();
end

function EventItemDecomposeUIUpdate()
    log("EventItemDecomposeUIUpdate");
    ItemDecomposeUI.UpdateUI();
end

function EventItemDecomposeItemChoose()
    local item = BP_ARRAY_DecomposeItemList[BP_ItemDecompose_SetIndex + 1];
    if item == nil then
        return;
    end

    if item.isSelect then
        item.isSelect = false;
        item.count = 0;
    else
        item.isSelect = true;
        if item.count == 0 then
            item.count = item.count + 1;
        end
    end

    ItemDecomposeUI.UpdateItemList(false, true, false);
    ItemDecomposeUI.UpdateChooseInfo(true);
end


function EventItemDecomposeOneItemAdd()
    local item = BP_ARRAY_DecomposeItemList[BP_ItemDecompose_SetIndex + 1];
    if item == nil then
        return;
    end

    if item.count < item.total then
        item.count = item.count + 1;
    end

    if item.count > 0 then
        item.isSelect = true;
    end

    ItemDecomposeUI.UpdateItemList(false, true, false);
    ItemDecomposeUI.UpdateChooseInfo(true);
end

function EventItemDecomposeOneItemDec()
    local item = BP_ARRAY_DecomposeItemList[BP_ItemDecompose_SetIndex + 1];
    if item == nil then
        return;
    end

    if item.count > 0 then
        item.count = item.count - 1;
    end

    if item.count > 0 then
        item.isSelect = true;
    else
        item.isSelect = false;
    end 
    
    ItemDecomposeUI.UpdateItemList(false, true, false);
    ItemDecomposeUI.UpdateChooseInfo(true);
end

function EventItemDecomposeOneItemMax()
    local item = BP_ARRAY_DecomposeItemList[BP_ItemDecompose_SetIndex + 1];
    if item == nil then
        return;
    end

    item.count = item.total;

    if item.count > 0 then
        item.isSelect = true;
    end

    ItemDecomposeUI.UpdateItemList(false, true, false);
    ItemDecomposeUI.UpdateChooseInfo(true);
end

function EventItemDecomposeAllIn()
    if #BP_ARRAY_DecomposeItemList <= 0 then
        return;
    end

    for i, v in ipairs(BP_ARRAY_DecomposeItemList) do
        if BP_ItemDecompose_IsAllIn then
             v.count = v.total;
             v.isSelect = true;
        else
            v.count = 0;
            v.isSelect = false;
        end
    end

    ItemDecomposeUI.UpdateItemList(false, true, false);
    ItemDecomposeUI.UpdateChooseInfo(true);
end

function EventItemDecompose()
    log("EventItemDecompose");
    if #BP_ARRAY_DecomposeItemList <= 0 then
        return;
    end

    local list = {};
    local num = 0;
    for i, v in ipairs(BP_ARRAY_DecomposeItemList) do
        if v.isSelect and v.count > 0 then
            list[tonumber(v.ins_id)] = v.count;
            num = num + 1;
        end
    end

    if num > 0 then
        local msgFmt = "";
        local msg = "";
        local moneyIcon = ItemDecomposeUI.GetDecomposeBackMoneyIconByIndex(BP_ItemDecompose_TabIndex + 1);
        if moneyIcon == 1000 then--限时分解
            msgFmt = FuncUtil.GetLocalizeResStr(660034);
            msgFmt = string.gsub(msgFmt, "\\n", "\n");
            msg = string.format(msgFmt, BP_ItemDecompose_Reward);
        else
            if BP_ItemDecompose_Gold_Chip_Reward ~= "0" then
                msgFmt = FuncUtil.GetLocalizeResStr(6824);
                msgFmt = string.gsub(msgFmt, "\\n", "\n");
                msg = string.format(msgFmt, BP_ItemDecompose_Reward, BP_ItemDecompose_Gold_Chip_Reward);
            else
                msgFmt = FuncUtil.GetLocalizeResStr(660032);
                msgFmt = string.gsub(msgFmt, "\\n", "\n");
                msg = string.format(msgFmt, BP_ItemDecompose_Reward);
            end
        end
        --msgFmt = string.gsub(msgFmt, "\\n", "\n");
        --local msg = string.format(msgFmt, BP_ItemDecompose_Reward);

        -- if moneyIcon == 1000 then
        --     local item = {}
        --     local itemList = {}
        --     item.res_id = 1000
        --     item.count = BP_ItemDecompose_Reward;
        --     item.valid_hours = 0
        --     item.expire_ts = 0
        --     table.insert(itemList, item);
        --     CommonMessageBoxUI:ShowPanel(2,
        --         Client.GetTableData("LocalizeRes", "101001").TextValue,
        --         msg,
        --         function()
        --             CommonItemGetUI:ShowPanel(itemList)
        --         end
        --     )
        -- else
            CommonMessageBoxUI:ShowPanel(2,
                Client.GetTableData("LocalizeRes", "101001").TextValue,
                msg,
                function()
                    DecomposeSystem.SendBatchDecompose(list);
                end
            )
        -- end
    end
end

function EventClickJumpShop()
    ItemDecomposeUI.Hide()
    WardrobeUI:Hide();
    local info = {}
    local strRegion = Client.GetPublishRegion()
    if strRegion == "JAPAN" or strRegion == "KOREA"then
        info.moduleId = JumpUtils.MODEL_ID_SUPPLY
    else
        info.moduleId = JumpUtils.MODEL_ID_STORE
    end
    info.itemId = 0
    info.Tab1 = StoreSystem.Page_ID_Exchange
    info.Tab2 = 0
    info.bValid = true
    JumpUtils.JumpReal(JumpUtils.MODEL_ID_LOBBY,info.moduleId,info)
end