RegionStrongerRankUI = RegionStrongerRankUI or 
{
    isShowing = false;
};

--榜单对应地区
BP_Region_Name = "";

--榜单对应地区人数
BP_Region_People_Number = "";

--国服最强文字
BP_Region_Strongest_Name = "";


--地区最强者榜(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_RankRegionStrongerInfo =
{
	no = 0,
	uid = "",               --唯一id
	name = "",              --名称
	url = "",               --头像
	level = 0,              --等级
	gender = 0,             --性别， 界面上0是女，1是男
	cur_avatar_box_id = 0,  --头像框
	stronger_type = 0,      --强者类型：国服最强、全省第一..
	strongerlist_type_name = "",  --榜单类型名
	rank_time_str = "",     --上榜次数
	rank_icon_path = "",    --榜单图标
	rank_icon_frame_path = "", --榜单边框图标
	showWarZone = true,
};
--列表
BP_ARRAY_RankStrongerList = 
{
	BP_STRUCT_RankRegionStrongerInfo = _G.BP_STRUCT_RankRegionStrongerInfo,
};

--注册Widget
function bp_regionstrongerrank_RegisterUI()
	LuaClassObj.SubUIWidgetList(
        bp_regionstrongerrank,
		{
            {Path="/Game/UMG/UI_Logic/WarZone/RegionStrongest_BP.RegionStrongest_BP_C", Container="Default", ZOrder=BP_ENUM_UI_WARZONE_STRONGER_RANK_ZORDER}
        },
		{"Lobby"},
		false,
		false,
		true
	);
end

--初始化显示
function RegionStrongerRankUI.Init()	
	LuaClassObj.HandleDynamicCreation(bp_regionstrongerrank);
    log("RegionStrongerRankUI.Init")
	EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_REGION_STRONGER_RANK_UPDATE_LIST, RegionStrongerEventHandler);	
end

function RegionStrongerRankUI.Release()
	EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_REGION_STRONGER_RANK_UPDATE_LIST, RegionStrongerEventHandler);
end

function RegionStrongerRankUI.Enter()
	StrongerRankSystem.GetRegionStrongerData();		
end

function EventOnWindowHide()
	log("UnRegister Event");
	UIManager.Hide(eUIType.eRegionStrongerRankUI)
    RegionStrongerRankUI.isShowing = false;
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, RegionStrongerRankUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, RegionStrongerRankUI.WardRobeAvatarResetClose);
end

--个人信息
BP_RegionStrongerRankUIShowRoleUid = ""
function EventRegionStrongerRankUIShowRole()
    --log("EventRankShowRole")
    ProfileMgr.GetProfileList({tonumber(BP_RegionStrongerRankUIShowRoleUid)}, function(profileList)
        local roleProfile = profileList[1]
        if roleProfile == nil or BP_RegionStrongerRankUIShowRoleUid == tostring(DataMgr.roleData.uid) then
            RoleInfoSystem.Enter(BP_RegionStrongerRankUIShowRoleUid);
            RoleInfoUI.Init(false, RoleInfoOpenFromType.RegionStrongerRank);
        else
            --if roleProfile.showWarZone then
            RoleInfoSystem.Enter(BP_RegionStrongerRankUIShowRoleUid);
            RoleInfoUI.Init(false, RoleInfoOpenFromType.RegionStrongerRank);
            --end
        end
    end)
end

--sami 个人信息角色开关处理
function RegionStrongerRankUI.WardRobeAvatarResetOpen()
    log("RegionStrongerRankUI.WardRobeAvatarResetOpen")
	if(RegionStrongerRankUI.isShowing == true) then
		LuaClassObj.HandleUIMessage(bp_regionstrongerrank, "HideSelf");
		RegionStrongerRankUI.isShowing = false;
	end
end

function RegionStrongerRankUI.WardRobeAvatarResetClose()
    log("RegionStrongerRankUI.WardRobeAvatarResetClose")
	if RegionStrongerRankUI.isShowing == false then
		LuaClassObj.HandleUIMessage(bp_regionstrongerrank, "ShowSelf")
		RegionStrongerRankUI.isShowing = true;

		if UIManager.GetUI(eUIType.eRegionStrongerRankUI) ~= nil then
			UIManager.Show(eUIType.eRegionStrongerRankUI)
		end
	end
end

--事件响应函数
function RegionStrongerEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_RANK then
		return;
	end
	--列表更新
	if eventID == EVENTID_REGION_STRONGER_RANK_UPDATE_LIST then
		log("EVENTID_REGION_STRONGER_RANK_UPDATE_LIST");
		RegionStrongerRankUI.RefreshRegionStrongerRankList()
    --elseif eventID == EVENTID_RANK_UPDATE_SELF then
        --log("EVENTID_RANK_UPDATE_SELF");
	end
end

--刷新地区强者列表, 这里同时也会刷新地区名及人数
function RegionStrongerRankUI.RefreshRegionStrongerRankList()
	BP_ARRAY_RankStrongerList = {};

    --log_tree("StrongerRankSystem.RegionStrongerList = ", StrongerRankSystem.RegionStrongerList);

    --地区榜人数
	for i,v in ipairs(StrongerRankSystem.RegionStrongerList) do
		local item = FuncUtil:CopyTable(BP_STRUCT_RankRegionStrongerInfo)
        local config = Client.GetTableData("lbsranktypetable", v.strongerlist_type);
		item.uid = v.uid;
		item.no = v.no;
		item.gender = v.gender;
		item.name = v.name;
		item.url = v.url;
		item.level = v.level;
		item.cur_avatar_box_id = v.cur_avatar_box_id;
		item.stronger_type = v.stronger_type;
		item.showWarZone = true
		ProfileMgr.GetProfileList({tonumber(v.uid)}, function(profileList)
			local roleProfile = profileList[1]
			if roleProfile == nil then
				item.showWarZone = true
			else
				item.showWarZone = roleProfile.showWarZone
			end
		end)
		if config ~= nil then
			item.strongerlist_type_name = config.rank_name;
			item.rank_icon_path = config.icon_path;
			item.rank_icon_frame_path = config.pedal_path;
			item.rank_time_str =  config.display_desc..":"..tostring(v.score);--tostring(v.rank_times);
		end       
		--item.rank_time_str = ("共"..tostring(v.rank_times).."次");
		
		table.insert(BP_ARRAY_RankStrongerList, item)
	end
	--国家名
    local curCountryName = "";
    for k,v in pairs(Client.GetTable("GlobalCountryCfg")) do
	    if v.Level == 1 and v.ID == BP_CurSelectCountryId then
		    curCountryName = v.WarzoneCountry;
            break;
	    end
    end
    local fmt = Client.GetTableData("LocalizeRes", "4788").TextValue;
	BP_Region_Name = string.format(fmt, curCountryName);
    --BP_Region_Strongest_Name = StrongerRankSystem.GetAreaStrongName(BP_CurSelectAreaId);

	--log_tree("BP_ARRAY_RankStrongerList = ", BP_ARRAY_RankStrongerList);
	
	LuaClassObj.HandleUIMessage(bp_regionstrongerrank, "RefreshItemList");
end

