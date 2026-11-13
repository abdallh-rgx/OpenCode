--设置军团头像框UI
CorpsIconSelectUI = CorpsIconSelectUI or
{
    openFromType_CorpsCreate = 1,
    openFromType_CorpsManager = 2,
    openFromType_CorpsHomepage = 3,
    openFrom = 1, --openFromType_CorpsCreate
}

BP_STRUCT_CorpsIconData =
{
	id = 0,
    state = 0,     --状态 0未选中；1选中
    path = "",   --图片地址
    unLockLv = 0,
    level = 0,
};

BP_ARRAY_CorpsIconList =
{
    BP_STRUCT_CorpsIconData = _G.BP_STRUCT_CorpsIconData,
};

BP_ARRAY_CorpsIconListOne =
{
    BP_STRUCT_CorpsIconData = _G.BP_STRUCT_CorpsIconData,
};

BP_ARRAY_CorpsIconListTwo =
{
    BP_STRUCT_CorpsIconData = _G.BP_STRUCT_CorpsIconData,
};

BP_ARRAY_CorpsIconListThree =
{
    BP_STRUCT_CorpsIconData = _G.BP_STRUCT_CorpsIconData,
};

BP_CorpsIconCurUseId = 0
BP_CorpsCurIconText = ""
BP_CorpsCurIconColourId = 0
BP_CorpsCurLv = 0

--注册Widget
function bp_corps_icon_select_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_corps_icon_select,
        {{Path="/Game/UMG/UI_Logic/Corps/CorpsIconPanelNew_BP.CorpsIconPanelNew_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_ZORDER+4}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function CorpsIconSelectUI.ShowUI(openFrom)
    CorpsIconSelectUI.openFrom = openFrom or CorpsIconSelectUI.openFromType_CorpsCreate;

    log("EventShowCorpsIconSelectUI")
    CorpsIconSelectUI.InitData()
	LuaClassObj.HandleDynamicCreation(bp_corps_icon_select);
    LuaClassObj.HandleUIMessage(bp_corps_icon_select, "ShowUI");
    UIManager.Show(eUIType.eCorpsIconSelectUI)
end

function CorpsIconSelectUI.HideUI()
    LuaClassObj.HandleUIMessage(bp_corps_icon_select, "HideUI");
end

function CorpsIconSelectUI.Release()
    log("CorpsIconSelectUI.Release")
end

function CorpsIconSelectUI.InitData()
    log("CorpsIconSelectUI.InitData")
    BP_ARRAY_CorpsIconList = {}
    BP_ARRAY_CorpsIconListOne = {}
    BP_ARRAY_CorpsIconListTwo = {}
    BP_ARRAY_CorpsIconListThree = {}
    BP_CorpsCurLv = 0
    local data = Client.GetTable("CorpsBadge");
	for _,v in pairs(data) do
        local lv= 0
        if DataMgr.corpsInfo then
            lv = DataMgr.corpsInfo.level
            BP_CorpsCurLv= DataMgr.corpsInfo.level
        end
        dataItem = {id = v.ID,state = 0,path = v.BigIconPath,unLockLv = v.UnLockLv,level = lv}
        if BP_CorpsIconCurUseId == v.ID or (BP_CorpsIconCurUseId == 0 and v.ID == 2001001) then
            dataItem.state = 1
        end
        table.insert(BP_ARRAY_CorpsIconList,dataItem)
        if v.TabPosi == 1 then
            table.insert(BP_ARRAY_CorpsIconListOne,dataItem)
        elseif v.TabPosi == 2 then
            table.insert(BP_ARRAY_CorpsIconListTwo,dataItem)
        elseif v.TabPosi == 3 then
            table.insert(BP_ARRAY_CorpsIconListThree,dataItem)
        end
    end

    table.sort(BP_ARRAY_CorpsIconList, function(a,b) return a.id < b.id end)
    table.sort(BP_ARRAY_CorpsIconListOne, function(a,b) return a.id < b.id end)
    table.sort(BP_ARRAY_CorpsIconListTwo, function(a,b) return a.id < b.id end)
    table.sort(BP_ARRAY_CorpsIconListThree, function(a,b) return a.id < b.id end)
    -- log_tree("BP_ARRAY_CorpsIconList=", BP_ARRAY_CorpsIconList)
end

function EventCorpsIconSelectUIClose()
    log("EventCorpsIconSelectUIClose")
    CorpsIconSelectUI.Release()
    -- RoleInfoAvatarFrameSystem.Release()
end

function EventOnCorpsIconSelectClicked()
    for _,v in pairs(BP_ARRAY_CorpsIconList) do
        if v.id == BP_CorpsIconCurUseId then
            v.state = 1
        else
            v.state = 0
        end
    end

    if CorpsIconSelectUI.openFrom == CorpsIconSelectUI.openFromType_CorpsCreate then
        CorpsIconSelectUI.HideUI()
        CorpsCreateUI.UpdateCorpsIcon(BP_CorpsIconCurUseId,BP_CorpsCurIconText,BP_CorpsCurIconColourId)
    else
        CorpsMgr.SendChangeIconReq(BP_CorpsIconCurUseId,BP_CorpsCurIconText,BP_CorpsCurIconColourId)
    end
end

function EventCorpsIconSelectUIFetchInfo()

end

function CorpsIconSelectUI.ClearSelection()
    BP_CorpsIconCurUseId = 0
    BP_CorpsCurIconText = ""
    BP_CorpsCurIconColourId = 0
end


function EventCorpsIconSelect_Hide()
    UIManager.Hide(eUIType.eCorpsIconSelectUI)
end

