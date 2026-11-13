--赛事晋级奖励
LeagueGameFinalChampionUI = LeagueGameFinalChampionUI or {
	zoneIdList = {},
	currentModeId = 0,
	currentStageId = 0,
	rank_type_league_score = 1,                 --赛事积分
	currentZoneId = 0,
}

BP_LeagueGameFinalChampion_TPP = "";
BP_LeagueGameFinalChampion_FPP = "";

BP_LeagueGameFinalChampion_TeamIcon = 0;
BP_LeagueGameFinalChampion_TeamName  = "";

BP_ARRAY_GameLeagueChampionZoneSelect = {
	name = "",
}

BP_STRUCT_GameLeagueChampion = {
	Uid = "",
	IconUrl = "",
	nickName = "",
	IconFrameID = 0,
}

BP_LeagueGameFinalChampion_ZoneIndex = 0;
BP_LeagueGameFinalChampion_IsTpp = false;

BP_ARRAY_GameLeagueChampionList = {
	BP_STRUCT_GameLeagueChampion = _G.BP_STRUCT_GameLeagueChampion;
}

BP_LeagueGameFinalChampion_Desc = "";


BP_LeagueGameFinalChampion_ModeFpp_Available = false;
BP_LeagueGameFinalChampion_ModeTpp_Available = false;


BP_STRUCT_LeagueChampion_Data = {
	teamName = "",
	teamIcon = 0,
}

--北美第三人称
BP_ARRAY_LeagueGameFinalChampin_NorthAmericaTPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--北美第一人称
BP_ARRAY_LeagueGameFinalChampin_NorthAmericaFPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--欧洲第三人称
BP_ARRAY_LeagueGameFinalChampin_EuropeTPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--欧洲第一人称
BP_ARRAY_LeagueGameFinalChampin_EuropeFPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--亚洲第三人称
BP_ARRAY_LeagueGameFinalChampin_AsiaTPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--亚洲第一人称
BP_ARRAY_LeagueGameFinalChampin_AsiaFPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--南美第三人称
BP_ARRAY_LeagueGameFinalChampin_SouthAmericaTPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--南美第一人称
BP_ARRAY_LeagueGameFinalChampin_SouthAmericaFPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--日韩第三人称
BP_ARRAY_LeagueGameFinalChampin_KoreaJapanTPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}
--日韩第一人称
BP_ARRAY_LeagueGameFinalChampin_KoreaJapanFPP = {
	tmp_UseExist_BP_STRUCT_LeagueChampion_Data = {};
}

local _preShowCallback
local _postShowCallback

--注册Widget
function bp_leagueGame_FinalChampion_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_FinalChampion,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_Champion_BP1.LeagueGame_Champion_BP1_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function LeagueGameFinalChampionUI.Init(preShowCallback, postShowCallback)
    log("LeagueGameFinalChampionUI.Init");
	_preShowCallback = preShowCallback
	_postShowCallback = postShowCallback
    LeagueGameFinalChampionUI.SetData();
    LeagueGameFinalChampionUI.Show();
	--EventSystem:registEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_RANKDATE_UPDATE, LeagueGameFinalChampionUI.SetRankInfoData);
	--LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;

	--log("zoooneid .."  .. LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex + 1])
	--log("LeagueGameFinalChampionUI.currentStageId .."  .. LeagueGameFinalChampionUI.currentStageId)
	--log("LeagueGameSystem.LEAGUE_TPP_MODE .."  .. LeagueGameSystem.LEAGUE_TPP_MODE)
	--log("LeagueGameFinalChampionUI.rank_type_league_score .."  .. LeagueGameFinalChampionUI.rank_type_league_score)
	--LeagueGameLeagueInfo.league_rank_info_req(LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex + 1], LeagueGameFinalChampionUI.currentStageId, LeagueGameSystem.LEAGUE_TPP_MODE, LeagueGameFinalChampionUI.rank_type_league_score);
	LeagueGameLeagueInfo.league_final_winner_req();
end

function LeagueGameFinalChampionUI.Show()
	if _preShowCallback ~= nil and type(_preShowCallback) == "function" then
		_preShowCallback()
	end
	_preShowCallback = nil

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
    -- LobbyUI:ShowLobbyPlayer(false);

	LuaClassObj.HandleDynamicCreation(bp_leagueGame_FinalChampion);
	LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "UIShow");
	UIManager.Show(eUIType.eLeagueGameFinalChampion);

	if _postShowCallback ~= nil and type(_postShowCallback) == "function" then
		_postShowCallback()
	end
	_postShowCallback = nil
end

function LeagueGameFinalChampionUI.Hide()
	LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "UIHide");
	UIManager.Hide(eUIType.eLeagueGameFinalChampion);
end

function LeagueGameFinalChampionUI.Release()
    log("LeagueGameFinalChampionUI.Release");
end

function LeagueGameFinalChampionUI.SetData()
    BP_LeagueGameFinalChampion_ZoneIndex = 0;
	BP_LeagueGameFinalChampion_TPP = Client.GetTableData("LocalizeRes", 100054).TextValue;
	BP_LeagueGameFinalChampion_FPP = Client.GetTableData("LocalizeRes", 100053).TextValue;
	LeagueGameFinalChampionUI.currentStageId = LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH;
	--设置区服下拉
	if LeagueGameSystem.signUpInfo.zoneList then
		BP_ARRAY_GameLeagueChampionZoneSelect = {};
		LeagueGameFinalChampionUI.zoneIdList = {};
		for k, zoneId in pairs(LeagueGameSystem.signUpInfo.zoneList) do
			table.insert(LeagueGameFinalChampionUI.zoneIdList, zoneId);
			local zoneCfg = Client.GetTableData("ZoneConfig", zoneId);
			if zoneCfg ~= nil then
				table.insert(BP_ARRAY_GameLeagueChampionZoneSelect, zoneCfg.NameInChinese);
			end
		end
	end

	for _k,_v in pairs(LeagueGameSystem.signUpInfo.sub_mode) do
		local IsFpp = Client.GetTableData("BTMode", _v).IsFpp;
		local MapId = Client.GetTableData("BTMode", _v).MapID;
		local mapName = Client.GetTableData("Map", MapId).WatchingName;
		if IsFpp == true then
			BP_LeagueGameFinalChampion_ModeFpp_Available = true;
		else
			BP_LeagueGameFinalChampion_ModeTpp_Available = true;
		end
	end
	
	if not LeagueGameSystem.LeagueId then
		LeagueGameSystem.LeagueId = 1;
	end
	--log("BP_LeagueGameFinalChampion_Desc .." .. string.format(Client.GetTableData("LocalizeRes", 6193).TextValue, (LeagueGameSystem.LeagueId + 1)));
	BP_LeagueGameFinalChampion_Desc = string.format(Client.GetTableData("LocalizeRes", 6193).TextValue, (LeagueGameSystem.LeagueId + 1)); 
end

function LeagueGameFinalChampionUI.SetRankInfoData()
	log("LeagueGameFinalChampionUI.SetRankInfoData");
	BP_LeagueGameFinalChampion_TeamIcon = 0;
	BP_LeagueGameFinalChampion_TeamName = "";
	if LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_REWARD or FuncUtil.GetServerTimeInSec() >= LeagueGameSystem.LeagueEndTime then
		if LeagueGameLeagueInfo.FinalChampionData and LeagueGameLeagueInfo.FinalChampionData[LeagueGameFinalChampionUI.currentZoneId] then
			local championData = LeagueGameLeagueInfo.FinalChampionData[LeagueGameFinalChampionUI.currentZoneId][LeagueGameFinalChampionUI.currentModeId];
			if championData then
				if championData.members then
					LeagueGameFinalChampionUI.GetMemberProfile(championData.members);
				end
				if championData.team_summary then
					if not championData.team_summary.name then
						championData.team_summary.name = "";
					end
					if not championData.team_summary.team_flag then
						championData.team_summary.team_flag = 1;
					else
						championData.team_summary.team_flag = tonumber(championData.team_summary.team_flag);
					end
					if not championData.team_summary.team_flag then
						championData.team_summary.team_flag = 1;
					end
					BP_LeagueGameFinalChampion_TeamIcon = championData.team_summary.team_flag;
					BP_LeagueGameFinalChampion_TeamName = championData.team_summary.name;
				end
			end
			BP_ARRAY_GameLeagueChampionList = {};
			LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "ShowInfo");
			LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "ShowTeamInfo");
			LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "ShowChampionInfo");
			LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "ShowChampionDetail");
		end
	end
end

function LeagueGameFinalChampionUI.GetMemberProfile(idList)
    BP_ARRAY_GameLeagueChampionList = {};
    local function callback(profileList)
        for _,profileInfo in ipairs(profileList) do
            local info = {}
            info.Uid = profileInfo.uid;
            info.nickName = profileInfo.nickName;
            info.IconUrl = profileInfo.picUrl;
            info.IconFrameID = profileInfo.cur_avatar_box_id;
            --info.lastOnlineTime = profileInfo.lastOnlineTime;
            --info.lastOnlineTimeStr = FuncUtil.FormatTime(profileInfo.lastOnlineTime, "online");
            --info.nation = profileInfo.nation;
            table.insert(BP_ARRAY_GameLeagueChampionList, info);
        	log_tree("===============BP_ARRAY_GameLeagueChampionList ", BP_ARRAY_GameLeagueChampionList)
  			LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "ShowChampionInfo");
        end
    end
    ProfileMgr.GetProfileList(idList, callback, false, false, false, true);
end

local function ResetChampionMap()
	BP_ARRAY_LeagueGameFinalChampin_NorthAmericaTPP = {};
	BP_ARRAY_LeagueGameFinalChampin_EuropeTPP = {};
	BP_ARRAY_LeagueGameFinalChampin_AsiaTPP = {};
	BP_ARRAY_LeagueGameFinalChampin_SouthAmericaTPP = {};
	BP_ARRAY_LeagueGameFinalChampin_KoreaJapanTPP = {};
	BP_ARRAY_LeagueGameFinalChampin_NorthAmericaFPP = {};
	BP_ARRAY_LeagueGameFinalChampin_EuropeFPP = {};
	BP_ARRAY_LeagueGameFinalChampin_AsiaFPP = {};
	BP_ARRAY_LeagueGameFinalChampin_SouthAmericaFPP = {};
	BP_ARRAY_LeagueGameFinalChampin_KoreaJapanFPP = {};
end

function LeagueGameFinalChampionUI.SetChampionMap()
	ResetChampionMap();
	if LeagueGameLeagueInfo.FinalChampionData then
		for k, info in pairs(LeagueGameLeagueInfo.FinalChampionData) do
			if info then
				if info[LeagueGameSystem.LEAGUE_TPP_MODE] and info[LeagueGameSystem.LEAGUE_TPP_MODE].team_summary then
					if not info[LeagueGameSystem.LEAGUE_TPP_MODE].team_summary.name then
						info[LeagueGameSystem.LEAGUE_TPP_MODE].team_summary.name = "";
					end
					if not info[LeagueGameSystem.LEAGUE_TPP_MODE].team_summary.team_flag then
						info[LeagueGameSystem.LEAGUE_TPP_MODE].team_summary.team_flag = 1;
					end
					local nameTPP = info[LeagueGameSystem.LEAGUE_TPP_MODE].team_summary.name;
					local iconTPP = info[LeagueGameSystem.LEAGUE_TPP_MODE].team_summary.team_flag;
					if k == LeagueGameLeagueInfo.ZONE_NorthAmerica then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_NorthAmericaTPP , {teamName = nameTPP, teamIcon = iconTPP});
					elseif k == LeagueGameLeagueInfo.ZONE_Europe then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_EuropeTPP , {teamName = nameTPP, teamIcon = iconTPP});
					elseif k == LeagueGameLeagueInfo.ZONE_Asia then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_AsiaTPP , {teamName = nameTPP, teamIcon = iconTPP});
					elseif k == LeagueGameLeagueInfo.ZONE_SouthAmerica then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_SouthAmericaTPP , {teamName = nameTPP, teamIcon = iconTPP});
					elseif k == LeagueGameLeagueInfo.ZONE_KoreaJapan then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_KoreaJapanTPP , {teamName = nameTPP, teamIcon = iconTPP});
					end
				end
				if info[LeagueGameSystem.LEAGUE_FPP_MODE] and info[LeagueGameSystem.LEAGUE_FPP_MODE].team_summary then
					if not info[LeagueGameSystem.LEAGUE_FPP_MODE].team_summary.name then
						info[LeagueGameSystem.LEAGUE_FPP_MODE].team_summary.name = "";
					end
					if not info[LeagueGameSystem.LEAGUE_FPP_MODE].team_summary.team_flag then
						info[LeagueGameSystem.LEAGUE_FPP_MODE].team_summary.team_flag = 1;
					end
					local nameFPP = info[LeagueGameSystem.LEAGUE_FPP_MODE].team_summary.name;
					local iconFPP = info[LeagueGameSystem.LEAGUE_FPP_MODE].team_summary.team_flag;
					if k == LeagueGameLeagueInfo.ZONE_NorthAmerica then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_NorthAmericaFPP , {teamName = nameFPP, teamIcon = iconFPP});
					elseif k == LeagueGameLeagueInfo.ZONE_Europe then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_EuropeFPP , {teamName = nameFPP, teamIcon = iconFPP});
					elseif k == LeagueGameLeagueInfo.ZONE_Asia then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_AsiaFPP , {teamName = nameFPP, teamIcon = iconFPP});
					elseif k == LeagueGameLeagueInfo.ZONE_SouthAmerica then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_SouthAmericaFPP , {teamName = nameFPP, teamIcon = iconFPP});
					elseif k == LeagueGameLeagueInfo.ZONE_KoreaJapan then
						table.insert(BP_ARRAY_LeagueGameFinalChampin_KoreaJapanFPP , {teamName = nameFPP, teamIcon = iconFPP});
					end
				end
			end
		end
	end
	LuaClassObj.HandleUIMessage(bp_leagueGame_FinalChampion, "ShowChampionMap");
end

function LeagueGameFinalChampionUI.SetSelectZoneIndex()
	BP_LeagueGameFinalChampion_ZoneIndex = 0;
	if LeagueGameFinalChampionUI.zoneIdList then
		for k, v in pairs(LeagueGameFinalChampionUI.zoneIdList) do
			if v == LeagueGameFinalChampionUI.currentZoneId then
				BP_LeagueGameFinalChampion_ZoneIndex = k - 1;
			end
		end
	end
	log("LeagueGameFinalChampionUI.SetSelectZoneIndex .." .. BP_LeagueGameFinalChampion_ZoneIndex);
end

function EventLeagueGameChampionHide()
	LeagueGameFinalChampionUI.Hide();
	--EventSystem:unregistEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_RANKDATE_UPDATE, LeagueGameFinalChampionUI.SetRankInfoData);

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE)
  	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
    -- LobbyUI:ShowLobbyPlayer(true);
end


function EventLeagueGameChampionTppClick()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex+1];
	BP_LeagueGameFinalChampion_IsTpp = true;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
	--LeagueGameLeagueInfo.league_rank_info_req(LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex+1], LeagueGameFinalChampionUI.currentStageId, LeagueGameSystem.LEAGUE_TPP_MODE, LeagueGameFinalChampionUI.rank_type_league_score);
end


function EventLeagueGameChampionFppClick()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_FPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex+1];
	BP_LeagueGameFinalChampion_IsTpp = false;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
	--LeagueGameLeagueInfo.league_rank_info_req(LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex+1], LeagueGameFinalChampionUI.currentStageId, LeagueGameSystem.LEAGUE_FPP_MODE, LeagueGameFinalChampionUI.rank_type_league_score);
end


function EventLeagueGameChampionSelectZone()
	if BP_LeagueGameFinalChampion_IsTpp then
		LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	else
		LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_FPP_MODE;
	end
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex+1];
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
	--LeagueGameLeagueInfo.league_rank_info_req(LeagueGameFinalChampionUI.zoneIdList[BP_LeagueGameFinalChampion_ZoneIndex+1], LeagueGameFinalChampionUI.currentStageId, LeagueGameFinalChampionUI.currentModeId, LeagueGameFinalChampionUI.rank_type_league_score);
end

function EventLeagueGameChampionAsiaTPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_Asia;
	BP_LeagueGameFinalChampion_IsTpp = true; 
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end
	
function EventLeagueGameChampionAsiaFPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_FPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_Asia;
	BP_LeagueGameFinalChampion_IsTpp = false;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end

function EventLeagueGameChampionNorthAmericaTPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_NorthAmerica;
	BP_LeagueGameFinalChampion_IsTpp = true;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end
function EventLeagueGameChampionNorthAmericaFPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_FPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_NorthAmerica;
	BP_LeagueGameFinalChampion_IsTpp = false;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end

function EventLeagueGameChampionEuropeTPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_Europe;
	BP_LeagueGameFinalChampion_IsTpp = true;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end
function EventLeagueGameChampionEuropeFPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_FPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_Europe;
	BP_LeagueGameFinalChampion_IsTpp = false;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end

function EventLeagueGameChampionSouthAmericaTPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_SouthAmerica;
	BP_LeagueGameFinalChampion_IsTpp = true;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end
function EventLeagueGameChampionSouthAmericaFPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_FPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_SouthAmerica;
	BP_LeagueGameFinalChampion_IsTpp = false;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end

function EventLeagueGameChampionKoreaJapanTPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_TPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_KoreaJapan;
	BP_LeagueGameFinalChampion_IsTpp = true;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end
function EventLeagueGameChampionKoreaJapanFPP()
	LeagueGameFinalChampionUI.currentModeId = LeagueGameSystem.LEAGUE_FPP_MODE;
	LeagueGameFinalChampionUI.currentZoneId = LeagueGameLeagueInfo.ZONE_KoreaJapan;
	BP_LeagueGameFinalChampion_IsTpp = false;
	LeagueGameFinalChampionUI.SetSelectZoneIndex();
	LeagueGameFinalChampionUI.SetRankInfoData();
end

function EventLeagueGameChampionLiveClick()
    LobbyLeagueGameEntranceUI.openfrom = 1;
	LobbyLeagueGameEntranceUI.EnterBroadcast();
end


--打开个人信息
BP_LeagueGameChampionShowRoleUid = ""
function EventLeagueGameChampionShowRole()
	log("EventLeagueGameChampionShowRole")
	LeagueGameFinalChampionUI.Hide();
	RoleInfoSystem.Enter(BP_LeagueGameChampionShowRoleUid);
	RoleInfoUI.Init(false, RoleInfoOpenFromType.LeagueGameChampion);
end