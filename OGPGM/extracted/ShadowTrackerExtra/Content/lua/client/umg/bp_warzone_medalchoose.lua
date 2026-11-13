--注册Widget
function bp_warzone_medalchoose_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_warzone_medalchoose,
        {{Path = "/Game/UMG/UI_Logic/WarZone/WarZoneMedalChoose_BP.WarZoneMedalChoose_BP_C", Container = "Default", ZOrder = BP_ENUM_UI_WARZONE_RANK_ZORDER + 1 }},
        {"Lobby"},
        false,
        false,
        true
    );
end

WarZoneMedalChooseUI = WarZoneMedalChooseUI or {};

BP_STRUCT_WarZoneMedalChooseInfo =
{
    id = 1,
    rank_name = "单挑王者",
    order = 1,
    score_var = "solo_king_num",
    display_desc = "吃鸡次数",
    min_segment_id = 305,
    icon_path="/Game/Arts/UI/TableIcons/WarzonerankTitle/ZQ_icon_xunzhang_gangqiangwang.ZQ_icon_xunzhang_gangqiangwang", pedal_path="/Game/Arts/UI/TableIcons/WarzonerankTitle/ZQ_icon_xunzhang_jinse.ZQ_icon_xunzhang_jinse"
}

BP_ARRAY_WarZoneMedalChooseInfoList =
{
    BP_STRUCT_WarZoneMedalChooseInfo = _G.BP_STRUCT_WarZoneMedalChooseInfo
}


BP_ARRAY_WarZoneStreetMedalRank =
{
    k = 0,
}

BP_WarZoneMedalChooseType = 1
BP_WarZoneMedalRank_Tab = 0;
BP_WarZoneStreetGetMedalCount = 0;
BP_WarZoneStreetName = "";

function EventWarZoneMedalChooseClose()
    UIManager.Hide(eUIType.eWarZoneMedalChooseUI)
    WarZoneMedalChooseUI.Release()
    LuaClassObj.HandleUIMessageNoFetch(bp_warzone_medalchoose, "HideUI");
end

--[[
    @desc 初始化普通勋章列表（战区/好友），弹出UI
]]
function WarZoneMedalChooseUI.Init()
    log("WarZoneMedalChooseUI Init");
    BP_WarZoneMedalChooseType = BP_WarZoneRankSelectType
    BP_WarZoneMedalRank_Tab = BP_WarZoneRank_Tab
    BP_ARRAY_WarZoneMedalChooseInfoList = {}
    for k,v in pairs(Client.GetTable("lbsranktypetable")) do
        local item = FuncUtil:CopyTable(v)
        table.insert(BP_ARRAY_WarZoneMedalChooseInfoList, item);
    end
    table.sort(BP_ARRAY_WarZoneMedalChooseInfoList, function(a, b) return (a.order < b.order) end)

    LuaClassObj.HandleDynamicCreation(bp_warzone_medalchoose);
    LuaClassObj.HandleUIMessage(bp_warzone_medalchoose, "ShowUI");
    UIManager.Show(eUIType.eWarZoneMedalChooseUI)
end

--[[
    @desc 初始化街区勋章数据，弹出UI
    @param rankData key为BP_ARRAY_ lbsranktypetable.id, value为排名
]]
function WarZoneMedalChooseUI.InitStreetData(rankData)
    log("WarZoneMedalChooseUI InitStreetData");
    if rankData == nil then
        rankData = {}
    end
    BP_WarZoneMedalChooseType = BP_WarZoneRankSelectType
    BP_WarZoneMedalRank_Tab = BP_WarZoneRank_Tab
    BP_ARRAY_WarZoneMedalChooseInfoList = {}
    for k,v in pairs(Client.GetTable("GlobalCountryCfg")) do
        local item = FuncUtil:CopyTable(v)
        table.insert(BP_ARRAY_WarZoneMedalChooseInfoList, item);
    end

    table.sort(BP_ARRAY_WarZoneMedalChooseInfoList, function(a, b)
        local aRankFlag = (rankData[a.id] ~= nil) and 1 or 0
        local bRankFlag = (rankData[b.id] ~= nil) and 1 or 0
        if aRankFlag + bRankFlag == 1 then
            return aRankFlag == 1
        end
        return a.order < b.order
        end)

    BP_ARRAY_WarZoneStreetMedalRank = {}
    for k, item in ipairs(BP_ARRAY_WarZoneMedalChooseInfoList) do
        BP_ARRAY_WarZoneStreetMedalRank[k] = rankData[item.id] or 0
    end

    BP_WarZoneStreetGetMedalCount = 0
    for _, _ in pairs(rankData) do
        BP_WarZoneStreetGetMedalCount = BP_WarZoneStreetGetMedalCount + 1
    end

    local around_info = WarZoneRankSystem.StreetZoneLocationInfo.around_info or {}
    local street_info = around_info[BP_WarZoneStreetPkIndex+1]
    BP_WarZoneStreetName = street_info and street_info.name or " "

    LuaClassObj.HandleDynamicCreation(bp_warzone_medalchoose)
    LuaClassObj.HandleUIMessage(bp_warzone_medalchoose, "ShowUI")
end

function WarZoneMedalChooseUI.Release()
    log("WarZoneMedalChooseUI Release");

    BP_WarZoneRankSelectType = BP_WarZoneMedalChooseType
    for k,v in pairs(Client.GetTable("lbsranktypetable")) do
        if v.id == BP_WarZoneMedalChooseType then
            log("id=" .. tostring(v.id))
            BP_STRUCT_WarZoneMedalInfo = FuncUtil:CopyTable(v)
            log_tree("BP_STRUCT_WarZoneMedalInfo=", BP_STRUCT_WarZoneMedalInfo)
            break;
        end
    end
    EventWarZoneChangeType()
end
