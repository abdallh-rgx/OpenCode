
CountryStrongerRankUI = CountryStrongerRankUI or 
{
    isShowing = false;
};


BP_Strongerlist_Type_Name = "";  ----榜单类型名

BP_Strongerlist_Type_Icon_Path = "";    --榜单图标

BP_Strongerlist_Type_Icon_Frame_Path = ""; --榜单边框图标
BP_Country_Strongest_Name = "";
BP_UpRank_Data_Str = "";  --上榜数据显示， 上榜的10个人最低那个的数据，比如刚枪王就是击杀数

--地区最强者榜(定义结构体：当且仅当以BP_STRUCT_开头的table能作为结构体给蓝图访问)
BP_STRUCT_RankCountryStrongerInfo =
{
	no = 0,
	uid = "",               --唯一id
	name = "",              --名称
	url = "",               --头像
	level = 0,              --等级
	gender = 0,             --性别， 界面上0是女，1是男
	cur_avatar_box_id = 0,  --头像框
	locationName = "",       --地区名称，所在省份
	showWarZone = true,
    roleNation = "",
};
--列表
BP_ARRAY_CountryRankStrongerList = 
{
	BP_STRUCT_RankCountryStrongerInfo = _G.BP_STRUCT_RankCountryStrongerInfo,
};

--注册Widget
function bp_countrystrongerrank_RegisterUI()
	LuaClassObj.SubUIWidgetList(
        bp_countrystrongerrank,
		{
            {Path="/Game/UMG/UI_Logic/WarZone/CountryStrongest_BP.CountryStrongest_BP_C", Container="Default", ZOrder=BP_ENUM_UI_WARZONE_STRONGER_RANK_ZORDER}
        },
		{"Lobby"},
		false,
		false,
		true
	);
end

--初始化显示
function CountryStrongerRankUI.Init()	
	LuaClassObj.HandleDynamicCreation(bp_countrystrongerrank);
    --log("CountryStrongerRankUI.Init")
    EventSystem:registEvent(EVENTTYPE_RANK, EVENTID_COUNTRY_STRONGER_RANK_UPDATE_LIST, CountryStrongerEventHandler);
end

function CountryStrongerRankUI.Release()
    CountryStrongerRankUI.isShowing = false;
	EventSystem:unregistEvent(EVENTTYPE_RANK, EVENTID_COUNTRY_STRONGER_RANK_UPDATE_LIST, CountryStrongerEventHandler);
end

function CountryStrongerRankUI.Enter()
	StrongerRankSystem.ReqCountryStrongerData()
end


function EventCountryStrongHide()
	log("EventCountryStrongHide");
	UIManager.Hide(eUIType.eCountryStrongerRankUI)
    RegionStrongerRankUI.isShowing = false;
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, CountryStrongerRankUI.WardRobeAvatarResetOpen);
    EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, CountryStrongerRankUI.WardRobeAvatarResetClose);
end

--个人信息
BP_CountryStrongerRankUIShowRoleUid = ""
function EventCountryStrongerRankUIShowRole()
    ProfileMgr.GetProfileList({tonumber(BP_CountryStrongerRankUIShowRoleUid)}, function(profileList)
        local roleProfile = profileList[1]
        if roleProfile == nil or BP_CountryStrongerRankUIShowRoleUid == tostring(DataMgr.roleData.uid) then
            RoleInfoSystem.Enter(BP_CountryStrongerRankUIShowRoleUid);
            RoleInfoUI.Init(false, RoleInfoOpenFromType.CountryStrongerRank);
        else
            --if roleProfile.showWarZone then
            RoleInfoSystem.Enter(BP_CountryStrongerRankUIShowRoleUid);
            RoleInfoUI.Init(false, RoleInfoOpenFromType.CountryStrongerRank);
            --end
        end
    end)
end

--sami 个人信息角色开关处理
function CountryStrongerRankUI.WardRobeAvatarResetOpen()
    log("CountryStrongerRankUI.WardRobeAvatarResetOpen")
	if(CountryStrongerRankUI.isShowing == true) then
		LuaClassObj.HandleUIMessage(bp_countrystrongerrank, "HideSelf");
		CountryStrongerRankUI.isShowing = false;
	end
end

function CountryStrongerRankUI.WardRobeAvatarResetClose()
    log("CountryStrongerRankUI.WardRobeAvatarResetClose")
	if CountryStrongerRankUI.isShowing == false then
		LuaClassObj.HandleUIMessage(bp_countrystrongerrank, "ShowSelf")
		CountryStrongerRankUI.isShowing = true;

		if UIManager.GetUI(eUIType.eCountryStrongerRankUI) ~= nil then
			UIManager.Show(eUIType.eCountryStrongerRankUI)
		end
	end
end

--事件响应函数
function CountryStrongerEventHandler(eventType, eventID, vars)
    if eventType ~= EVENTTYPE_RANK then
		return;
	end
	--列表更新
	if eventID == EVENTID_COUNTRY_STRONGER_RANK_UPDATE_LIST then
        log("EVENTID_COUNTRY_STRONGER_RANK_UPDATE_LIST");
        CountryStrongerRankUI.RefreshCountryStrongerRankList();
    --elseif eventID == EVENTID_RANK_UPDATE_SELF then
        --log("EVENTID_RANK_UPDATE_SELF");
	end
end

--刷新地区强者列表, 这里同时也会刷新地区名及人数
function CountryStrongerRankUI.RefreshCountryStrongerRankList()
	BP_ARRAY_CountryRankStrongerList = {};
    --地区榜人数
	for i,v in ipairs(StrongerRankSystem.CountryStrongerList) do
		local item = FuncUtil:CopyTable(BP_STRUCT_RankCountryStrongerInfo);
		item.uid = v.uid;
		item.no = v.no;
		item.gender = v.gender;
		item.name = v.name;
		item.url = v.url;
		item.level = v.level;
		item.cur_avatar_box_id = v.cur_avatar_box_id;
		item.showWarZone = true;
		ProfileMgr.GetProfileList({tonumber(v.uid)}, function(profileList)
			local roleProfile = profileList[1]
			if roleProfile == nil then
				item.showWarZone = true
			else
				item.showWarZone = roleProfile.showWarZone
			end
		end)
        --地区名
        item.locationName = "";
        item.roleNation = ProfileMgr.GetRoleNationByUid(v.uid);
        --if city ~= nil then
        --    item.locationName = city.province_name;
        --end
		table.insert(BP_ARRAY_CountryRankStrongerList, item)
    end
       
    local config = Client.GetTableData("lbsranktypetable", StrongerRankSystem.CountryStrongerListType);
    if config ~= nil then
		BP_Strongerlist_Type_Name = config.rank_name;  ----榜单类型名
		BP_Strongerlist_Type_Icon_Path = config.icon_path;
		BP_Strongerlist_Type_Icon_Frame_Path = config.pedal_path;
    end    

    if #BP_ARRAY_CountryRankStrongerList < 10 then
    	StrongerRankSystem.CountryStrongerUpRankData = 1; -- 不满10人时，上榜数据为1
    end

    BP_Country_Strongest_Name = StrongerRankSystem.GetAreaStrongName(BP_CurSelectAreaId);
    BP_UpRank_Data_Str = Client.GetTableData("LocalizeRes", "4801").TextValue ..tostring(StrongerRankSystem.CountryStrongerUpRankData);  --上榜数据显示， 上榜的10个人最低那个的数据，比如刚枪王就是击杀数
    log(BP_UpRank_Data_Str)
	--log_tree("BP_ARRAY_CountryRankStrongerList = ", BP_ARRAY_CountryRankStrongerList);
	
	LuaClassObj.HandleUIMessage(bp_countrystrongerrank, "RefreshItemList");
end

