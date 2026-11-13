--[[
使用称号界面逻辑
]]--

WarZoneTitleUI = WarZoneTitleUI or 
{
	isShow = false,
};

local  t_insert, t_sort = table.insert, table.sort

--(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_WarZoneTitle =
{
	warzone_id = 0,
	rank_id = 0,
	rank_no = 0,
	tab_id = 0,
    state = "",     --状态 use使用中,has拥有,none未拥有
    desc = "",      --描述:北京市第N刚枪王
    icon_path = "", --图标路径
    pedal_path = "", --图标背景
    rank_name = "",--绝地鸡王
};

--(定义结构体数组：当且仅当以BP_ARRAY_开头的table能作为数组给蓝图访问)
BP_Array_WarZoneTitleList = 
{
	BP_STRUCT_WarZoneTitle = _G.BP_STRUCT_WarZoneTitle, --定义结构体数组，这种写法要作为规范规定下来
};

WarZoneTitleCurZoneId = 0
WarZoneTitleCurRankId = 0
WarZoneTitleCurRankNo = 0

WarZoneTitleSelectTab = -1

WarZoneTitleRedPointTypeOne = false
WarZoneTitleRedPointTypeTwo = false
WarZoneTitleRedPointTypeThree = false
WarZoneTitleRedPointTypeFour = false

local TotalWarZoneTitleList = 
{

};

BP_WarZoneTitleUseTab = 1 --当前用的称号所在的tabid

--注册Widget
function bp_warzone_title_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_warzone_title,
		{{Path="/Game/UMG/UI_Logic/WarZone/WarZoneTitle_BP.WarZoneTitle_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ROLEINFO_ZORDER+1}},
		{"Lobby"},
		false,
		bp_warzone_title_OnModeSwitched ~= nil,
		true
		);
end


function WarZoneTitleUI.Init(  )
	log("WarZoneTitleUI Init");
	WarZoneTitleSelectTab = -1
	LuaClassObj.HandleDynamicCreation(bp_warzone_title);
	LuaClassObj.HandleUIMessage(bp_warzone_title, "ShowUI");
	WarZoneTitleUI.isShow = true;
end

function WarZoneTitleUI.RefreshUI( onlyRefreshCurTab )
	WarZoneTitleCurZoneId = WarZoneTitleSystem.UseTitle.warzone_id;
	WarZoneTitleCurRankId = WarZoneTitleSystem.UseTitle.rank_id;
	WarZoneTitleCurRankNo = WarZoneTitleSystem.UseTitle.rank_no;
	BP_WarZoneTitleUseTab = 1
	local title_list = WarZoneTitleSystem.TitleList;
	-- fill data
	TotalWarZoneTitleList = {}
	for k, v in pairs(title_list) do
		local data_template = FuncUtil:CopyTable(BP_STRUCT_WarZoneTitle)
		data_template.warzone_id = v.warzone_id
		data_template.rank_id = v.rank_id
		data_template.rank_no = v.rank_no
        local config = Client.GetTableData("lbsranktypetable", v.rank_id);
		data_template.rank_name = v.rank_id and config and config.rank_name or ""

		if v.warzone_id == WarZoneTitleCurZoneId and 
		v.rank_id ==  WarZoneTitleCurRankId and 
		v.rank_no == WarZoneTitleCurRankNo then
			data_template.state = "use"
		else
			data_template.state = "nouse"
		end
		data_template.tab_id, data_template.desc = WarZoneTitleSystem.get_title_tab_and_des(v)
		data_template.icon_path = WarZoneTitleSystem.get_title_image_path(v.rank_id)
		data_template.pedal_path = WarZoneTitleSystem.get_title_petal_image_path(v.rank_id)

		t_insert(TotalWarZoneTitleList, data_template)

		if data_template.state == "use" then
			BP_WarZoneTitleUseTab = tonumber(data_template.tab_id)
		end
	end

	if WarZoneTitleSelectTab > 0  and onlyRefreshCurTab
		and #BP_Array_WarZoneTitleList > 0 and BP_Array_WarZoneTitleList[1].tab_id == WarZoneTitleSelectTab then
		for k, v in pairs(BP_Array_WarZoneTitleList) do
			if v.warzone_id == WarZoneTitleCurZoneId and 
			v.rank_id ==  WarZoneTitleCurRankId and 
			v.rank_no == WarZoneTitleCurRankNo then
				v.state = "use"
			else
				v.state = "nouse"
			end
		end
		LuaClassObj.HandleUIMessage(bp_warzone_title, "RefreshCurTab");
	else
		LuaClassObj.HandleUIMessage(bp_warzone_title, "RefreshUI");
	end

end

function WarZoneTitleUI.UpdateRedPoint()
	log("WarZoneTitleUI.UpdateRedPoint")
	LuaClassObj.HandleUIMessage(bp_warzone_title, "UpdateRedPoint");
end

--(以Event开头的函数名就能暴露给蓝图调用)

function EventWarZoneTitleUIClose()
	--log("EventWarZoneTitleUIClose");
    WarZoneTitleSystem.Release();
    WarZoneTitleUI.isShow = false
end

function EventWarZoneTitleUse()
	local curUseTitle = WarZoneTitleSystem.UseTitle
	local newTitle = {warzone_id = WarZoneTitleCurZoneId, rank_id = WarZoneTitleCurRankId, rank_no = WarZoneTitleCurRankNo}
	if curUseTitle.warzone_id == WarZoneTitleCurZoneId and
		curUseTitle.rank_id	 == WarZoneTitleCurRankId and 
		curUseTitle.rank_no == WarZoneTitleCurRankNo then
		newTitle = {}
	end
	--log_tree("EventWarZoneTitleUse=", newTitle);
    WarZoneTitleSystem.modify_lbs_warzone_use_title_req(newTitle);
end

function EventWarZoneTitleOpenShareUI()
	local title = {warzone_id = WarZoneTitleCurZoneId, rank_id = WarZoneTitleCurRankId, rank_no = WarZoneTitleCurRankNo}
	-- log_tree("EventWarZoneTitleOpenShareUI=", title);
	local titleStr, rankStr =  WarZoneTitleSystem.GetShareTitleRankStr(title)
	local iconPath = WarZoneTitleSystem.get_title_image_path(WarZoneTitleCurRankId);
	local petalPath = WarZoneTitleSystem.get_title_petal_image_path(WarZoneTitleCurRankId);
	local titleList = WarZoneTitleSystem.TitleList
	local totalKill = nil
	for k, v in pairs(titleList) do
		if v ~= nil and v.warzone_id == WarZoneTitleCurZoneId and v.rank_id == WarZoneTitleCurRankId then
			totalKill = v.score
			break
		end
	end
	
    ShareWarZoneTitletUI.Enter(true, WarZoneTitleCurRankId, titleStr, rankStr,iconPath, petalPath, totalKill,0);
end

function EventWarZoneTitleFetchInfo()

end

function EventRefreshTitleListOfCurTab( )
	--log(WarZoneTitleSelectTab)
	BP_Array_WarZoneTitleList = {}
	for k, v in pairs(TotalWarZoneTitleList) do
		if v.tab_id == WarZoneTitleSelectTab then
			t_insert(BP_Array_WarZoneTitleList, v)
		end
	end

	local function sort_fun( a,b )
		local aval = (a.state == "use" and 0 or 1)
		local bval = (b.state == "use" and 0 or 1)
		return aval < bval
	end

	t_sort(BP_Array_WarZoneTitleList, sort_fun)

	WarZoneTitleSystem.clear_lbs_warzone_title_redpoint_req(WarZoneTitleSelectTab)
	--log_tree("TotalWarZoneTitleList", TotalWarZoneTitleList)
	--log_tree("BP_Array_WarZoneTitleList", BP_Array_WarZoneTitleList)
end

function EventOpenWarZoneTitleRule( )
    local title = Client.GetTableData("LocalizeRes", 200074).TextValue
    local context = Client.GetTableData("LocalizeRes", 200073).TextValue
    context = string.gsub(context, "\\n", "\n")
    PopUpNoticeUI.ShowMessageBox(title, context)
end