CountryareaUI = CountryareaUI or {};

BP_ARRAY_SORTED_NATION = {
    "",
};
BP_NATION_SELECTED = "";
BP_NATION_IS_IN_ROLEINFO = false;
BP_NATION_OPEN_TYPE = 0;  --0：默认（创角界面旗帜选择）， 1：角色信息界面旗帜选择 2：好友搜序旗帜选择

BP_NATION_LOGINED = "G1";

BP_NATION_SEARCH_KEYWORD = "";
BP_ARRAY_NATION_SEARCH_RES = {
    "", 
};
BP_NATION_USE_FLAG_ITEM = false;  -- 是否使用旗帜卡

CountryareaUI.search_index = {};

CountryareaUI.OPEN_TYPE_GUIDON = 101
CountryareaUI.OPEN_TYPE_TEAM_NATION = 102
--注册Widget
function bp_countryarea_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_countryarea,
    {  
        {Path="/Game/UMG/UI_BP/PopupNotice/Countryarea_BP.Countryarea_BP_C", Container="Top", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+1},
        {Path="/Game/UMG/UI_BP/PopupNotice/Countryarea2_BP.Countryarea2_BP_C", Container="Top", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+1}
    },
	{"CreateRole","Lobby"},
	false,
    false,
    true
  );
end

function RegionTableDataCompare(a, b)
    return a[2]:lower() < b[2]:lower();
end

function EventNationSyncParam_Push()
    BP_NATION_LOGINED = LoginSystem.ip_region;
end

function CountryareaUI.getConfigByType()
    if BP_NATION_OPEN_TYPE == CountryareaUI.OPEN_TYPE_GUIDON then
        return Client.GetTable("GuidonConfig");
    end
    
    return FuncUtil.GetRegionConfigTable();
end

function CountryareaUI.SortNationCode(nation_code)
    local tmpTable = {};
    local regionConfig = CountryareaUI.getConfigByType();

    for k, v in pairs(nation_code) do
        table.insert(tmpTable, {v, regionConfig[v].sort_key});
    end

    table.sort(tmpTable, RegionTableDataCompare);
    local result_table = {}
    for k, v in pairs(tmpTable) do
        table.insert(result_table, v[1]);
    end

    return result_table;
end

function EventSortNationKey_Push()
    log("EventSortNationKey_Push")
    BP_ARRAY_SORTED_NATION = {}

    local regionConfig = CountryareaUI.getConfigByType();
    local allNationCode = {};
    local n = 0;
    for k,v in pairs(regionConfig) do
        n=n+1
        allNationCode[n]=k;
    end
    BP_ARRAY_SORTED_NATION = CountryareaUI.SortNationCode(allNationCode);
    -- log_tree("BP_ARRAY_SORTED_NATION",BP_ARRAY_SORTED_NATION)
end

function EventNationInitSearchList()
    -- 为优化内存，此函数清空
end

function EventSearchNation_Push()
    BP_ARRAY_SORTED_NATION = {};

    local region_config = CountryareaUI.getConfigByType();
    for k, v in pairs(region_config) do
        if string.find(v.RegionName:lower(), BP_NATION_SEARCH_KEYWORD) then
            table.insert(BP_ARRAY_SORTED_NATION, k);
        end
    end

    BP_ARRAY_SORTED_NATION = CountryareaUI.SortNationCode(BP_ARRAY_SORTED_NATION);
end

-- 判断是否超过旗帜修改时间
function CountryareaUI.IsOverNationModifyCd(lastTime, nowTime)
    local time = Client.GetTableData("IntlSystemConfig", "NationModifyCd").ConfigValue;
    return nowTime - lastTime > tonumber(time);
end

function CountryareaUI.UseFlagItemShow()
    BP_NATION_OPEN_TYPE = 1;
    LuaClassObj.HandleDynamicCreation(bp_countryarea);
    -- LuaClassObj.HandleUIMessage(bp_countryarea, "UIShow2");
    BP_Current_CheckBox = 1; --展开个人信息设置页面，默认选中国家旗帜项
    RoleInfoShowInfoUI.Show();
end

function EventShowCountryAreaUI( ... )
    BP_NATION_USE_FLAG_ITEM = false;
    LuaClassObj.HandleDynamicCreation(bp_countryarea);
    EventSortNationKey_Push()
    if BP_NATION_OPEN_TYPE == 1 then
        LuaClassObj.HandleUIMessage(bp_countryarea, "UIShow2");
    else
        LuaClassObj.HandleUIMessage(bp_countryarea, "UIShow");
    end

    -- UIManager.Show(eUIType.eCountryarea)
end

--个人信息页面打开国家旗帜
function CountryareaUI.ShowFromRoleInfo()
    --BP_NATION_OPEN_TYPE = 1;
    BP_NATION_LOGINED = LoginSystem.ip_region;
    EventSortNationKey_Push()
    LuaClassObj.HandleDynamicCreation(bp_countryarea);
    BP_NATION_OPEN_TYPE = 1;
    LuaClassObj.HandleUIMessage(bp_countryarea, "UIShow2");
    -- UIManager.Show(eUIType.eCountryarea)
end

function CountryareaUI.SetNeedUseFlagItem(bUse)
    BP_NATION_USE_FLAG_ITEM = bUse;
end

--国家选择回调
function EventSelectNationCallBack_Push()
    log("EventSelectNationCallBack_Push, BP_NATION_OPEN_TYPE: " .. tostring(BP_NATION_OPEN_TYPE))

    log("BP_NATION_SELECTED......"..BP_NATION_SELECTED)
    if (BP_NATION_OPEN_TYPE == 0) then
        BP_NATION_LOGINED = LoginSystem.ip_region;
        LuaClassObj.HandleUIMessage(bp_createrole, "SetNation");
        LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide");
    elseif (BP_NATION_OPEN_TYPE == 1) then
        text = Client.GetTableData("LocalizeRes", 4358).TextValue -- "地区旗帜变更后需要60天才可再次修改，是否确认修改？"
        CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), text, CountryareaUI.ModifyNationConfirm_YES, CountryareaUI.ModifyNationConfirm_NO);
    elseif (BP_NATION_OPEN_TYPE == 2) then
        LuaClassObj.HandleUIMessage(bp_lobby_friend, "SetSearchNation");
        LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide");
    elseif (BP_NATION_OPEN_TYPE == 3) then
        LuaClassObj.HandleUIMessage(bp_corps_create, "SetNation");
        LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide");
    elseif (BP_NATION_OPEN_TYPE == 4) then
        --LuaClassObj.HandleUIMessage(bp_corps_create, "SetNation");
        --[[
        CorpsMgr.corps_change_city_req(BP_NATION_SELECTED)
        LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide");
        ]]
        text = Client.GetTableData("LocalizeRes", 4721).TextValue
        CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), text, CountryareaUI.ModifyCorpsNationConfirm_YES, CountryareaUI.ModifyNationConfirm_NO);
    end

    if BP_NATION_OPEN_TYPE == CountryareaUI.OPEN_TYPE_GUIDON then
        AllianceCompetitionSystemHandler.ChangeGuidonReq(BP_NATION_SELECTED)
       
    end

    if BP_NATION_OPEN_TYPE == CountryareaUI.OPEN_TYPE_TEAM_NATION then
        AllianceCompetitionSystemHandler.ChangeNationReq(BP_NATION_SELECTED)

    end
       
    -- UIManager.Hide(eUIType.eCountryarea)
end

function CountryareaUI.ModifyCorpsNationConfirm_YES()
    log("ModifyCorpsNationConfirm_YES" .. tostring(BP_NATION_SELECTED))
    CorpsMgr.corps_change_city_req(BP_NATION_SELECTED)
    LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide");
    -- UIManager.Hide(eUIType.eCountryarea)
end

--修改国家确认
function CountryareaUI.ModifyNationConfirm_YES()
    log("modify_nation " .. tostring(BP_NATION_SELECTED).."   "..tostring(BP_NATION_USE_FLAG_ITEM))
    NetUtil.SendPkg("modify_nation_req", BP_NATION_SELECTED, BP_NATION_USE_FLAG_ITEM);
    LuaClassObj.HandleUIMessage(bp_countryarea, "UIHide");
    -- UIManager.Hide(eUIType.eCountryarea)
end

function CountryareaUI.ModifyNationConfirm_NO()
end

function CountryareaUI.HideUI()
    log("CountryareaUI.HideUI")
    LuaClassObj.HandleUIMessageNoFetch(bp_countryarea, "UIHide");
    -- UIManager.Hide(eUIType.eCountryarea)
end

function CountryareaUI.HideUI2()
    log("CountryareaUI.HideUI2")
    LuaClassObj.HandleUIMessageNoFetch(bp_countryarea, "UIHide2");
    -- UIManager.Hide(eUIType.eCountryarea)
end

-- 战队赛打开选择队旗
function CountryareaUI.ShowForAllianceCompetitionGuidon()
    log("CountryareaUI.ShowForAllianceCompetitionGuidon")
    LuaClassObj.HandleDynamicCreation(bp_countryarea);
    BP_NATION_SELECTED = AllianceCompetitionSystem.GuidonId or ""
    BP_NATION_OPEN_TYPE = CountryareaUI.OPEN_TYPE_GUIDON

    EventSortNationKey_Push()
    LuaClassObj.HandleUIMessage(bp_countryarea, "UIShow");
    -- UIManager.Show(eUIType.eCountryarea)
end

-- 战队赛打开选择国旗
function CountryareaUI.ShowForAllianceCompetitionNation()
    log("CountryareaUI.ShowForAllianceCompetitionNation")
    LuaClassObj.HandleDynamicCreation(bp_countryarea);
    BP_NATION_SELECTED = AllianceCompetitionSystem.NationFlagId or ""
    BP_NATION_OPEN_TYPE = CountryareaUI.OPEN_TYPE_TEAM_NATION

    EventSortNationKey_Push()
    LuaClassObj.HandleUIMessage(bp_countryarea, "UIShow");
    -- UIManager.Show(eUIType.eCountryarea)
end