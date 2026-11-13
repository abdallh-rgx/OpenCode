--设置标签UI
RoleInfoTagUI = RoleInfoTagUI or
{
    lst_selected = {},
    maxCount = 4,
}

BP_STRUCT_RoleInfoTag =
{
	id = 0,
    text = "",
    selected = false,
};

BP_ARRAY_RoleInfoTagList =
{
    BP_STRUCT_RoleInfoTag = _G.BP_STRUCT_RoleInfoTag,
};

BP_STRUCT_RoleInfoSelectTag =
{
	id = 0,
    selected = false,
};

BP_RoleInfoSelected_Count = 0

--注册Widget
function bp_roleinfo_tag_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_roleinfo_tag,
		{{Path="/Game/UMG/UI_Logic/RoleInfo/RoleInfo_Tag_BP.RoleInfo_Tag_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+1}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function RoleInfoTagUI.Show(lst, callback)
	--log("RoleInfoTagUI.Show");
    RoleInfoTagUI.lst_selected = {}
    if type(lst) == "table" then
        for i,v in ipairs(lst) do
            RoleInfoTagUI.lst_selected[v] = 1
        end
    end
    RoleInfoTagUI.callback = callback
	LuaClassObj.HandleDynamicCreation(bp_roleinfo_tag);
    LuaClassObj.HandleUIMessage(bp_roleinfo_tag, "ShowUI");
    UIManager.Show(eUIType.eRoleInfoTagUI)
    BP_ARRAY_RoleInfoTagList = {}
	local Social_Card_Label = Client.GetTable("SocialCardLabel")
    for i,v in pairs(Social_Card_Label) do
        local tmp = {
            id = v.ID,
            text = v.Label,
            selected = false,
        }
        if RoleInfoTagUI.lst_selected[tmp.id] then
            tmp.selected = true
        end
        table.insert(BP_ARRAY_RoleInfoTagList, tmp)
    end
    table.sort(BP_ARRAY_RoleInfoTagList, function(a,b) return a.id < b.id end)
    RoleInfoTagUI.RefreshSelectNum()
    LuaClassObj.HandleUIMessage(bp_roleinfo_tag, "RefreshUI");
end

function RoleInfoTagUI.Release()
	--log("RoleInfoTagUI.Release");
    BP_ARRAY_RoleInfoTagList = {}
end

function RoleInfoTagUI.RefreshSelectNum()
	BP_RoleInfoSelected_Count = 0
    for i,v in ipairs(BP_ARRAY_RoleInfoTagList) do
        if v.selected then
            BP_RoleInfoSelected_Count = BP_RoleInfoSelected_Count + 1
        end
    end
    LuaClassObj.HandleUIMessage(bp_roleinfo_tag, "RefreshSelectNum");
end

--(以Event开头的函数名就能暴露给蓝图调用)

function EventRoleInfoTagClose()
	--log("EventRoleInfoTagClose");
    RoleInfoTagUI.Release()
end

function EventRoleInfoTagUIChg()
	--log("EventRoleInfoTagChg");
    if RoleInfoTagUI.callback then
        local lst = {}
        for k,v in pairs(RoleInfoTagUI.lst_selected) do
            table.insert(lst, k)
        end
        RoleInfoTagUI.callback(lst)
    end
    UIManager.Hide(eUIType.eRoleInfoTagUI)
    LuaClassObj.HandleUIMessage(bp_roleinfo_tag, "HideUI");
end

function EventRoleInfoTagSelect()
    BP_RoleInfoSelected_Count = 0
    
    for i,v in ipairs(BP_ARRAY_RoleInfoTagList) do
        if v.selected then
            BP_RoleInfoSelected_Count = BP_RoleInfoSelected_Count + 1
        end
    end
    
    for i,v in ipairs(BP_ARRAY_RoleInfoTagList) do
        if v.id == BP_STRUCT_RoleInfoSelectTag.id then

            if not v.selected and BP_STRUCT_RoleInfoSelectTag.selected then     --如果大于最大数量
                if BP_RoleInfoSelected_Count >= RoleInfoTagUI.maxCount then
                    LuaClassObj.HandleUIMessage(bp_roleinfo_tag, "RefreshAll")
                    return
                end
            end
            
            v.selected = BP_STRUCT_RoleInfoSelectTag.selected
            if v.selected then
                RoleInfoTagUI.lst_selected[v.id] = 1
            else
                RoleInfoTagUI.lst_selected[v.id] = nil
            end
            RoleInfoTagUI.RefreshSelectNum()
            LuaClassObj.HandleUIMessage(bp_roleinfo_tag, "RefreshAll")
            return
        end
    end
end
