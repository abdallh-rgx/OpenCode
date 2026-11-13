--赛事信息
LeagueGameSignUpUI = LeagueGameSignUpUI or {
	countDownTimer = nil,
	countDownTime = 0,
	IsShow = false,
	TimeToCountDown = 0,
	cancelCountDownTimer = nil,
}

BP_LeagueGameSignUp_MatchTime30 = ""; 		--海选赛时间1
BP_LeagueGameSignUp_MatchTime31 = "";		--海选赛时间2
BP_LeagueGameSignUp_MatchTime4 = "";		--小组赛时间	
BP_LeagueGameSignUp_MatchTime5= "";			--总决赛时间--分区决赛

BP_STRUCT_LeagueGameSignUp_AwardItemInfo = {
	itemID = 0,
	itemNum = 0,
}

--参与奖励
BP_ARRAY_LeagueGameSignUp_AwardList = {
	BP_STRUCT_LeagueGameSignUp_AwardItemInfo = _G.BP_STRUCT_LeagueGameSignUp_AwardItemInfo;
}

BP_LeagueGameSignUp_Countdown = "";				--报名倒计时
BP_LeagueGameSignUp_TimeDesc = "";				--赛事时间
BP_LeagueGameSignUp_CostCoin = 0;				--报名花费
BP_LeagueGameSignUp_State = 0;					--报名状态
BP_IS_SIGN_END = false

BP_LeagueGameSignUp_SeaMatchTime = "";
BP_LeagueGameSignUp_GroupMatchTime = "";
BP_LeagueGameSignUp_FinalMatchTime = "";

BP_LeagueGameSignUpCancel_CountDown = "";

BP_LeagueGameSignUp_ApplyMode = "";
BP_LeagueGameSignUp_ApplyZone = "";

local _preShowCallback
local _postShowCallback

--注册Widget
function bp_leagueGame_signUp_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_leagueGame_signUp,
        {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_signUp_BP.LeagueGame_signUp_BP_C", Container="Default", ZOrder=BP_ENUM_UI_LEAGUEGAME_LOBBY+1}},
        {"Lobby"},
        false,
        false,
        true
    );
end

function LeagueGameSignUpUI.Init(preShowCallback, postShowCallback)
	LeagueGameLobbyUI.DoCallBack()

	-- body
	_preShowCallback = preShowCallback
	_postShowCallback = postShowCallback

	if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
		LeagueGameSignUpUI.SetData();
		LeagueGameSignUpUI.Show();
	end
end

function LeagueGameSignUpUI.SetData()
	-- body
	--奖励
	BP_ARRAY_LeagueGameSignUp_AwardList = {};
	if LeagueGameSystem.LeagueRewardListTable then
		for k,v in pairs(LeagueGameSystem.LeagueRewardListTable) do
			if v.reward_stage == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
				local itemCfg = LeagueGameSystem.LeagueRewardItemCfg[v.reward_id];
				if itemCfg then
					for _k, _v in pairs(itemCfg.reward) do
						local item = {};
						item.itemID = _v.item_id;
						item.itemNum = _v.item_num;
						table.insert(BP_ARRAY_LeagueGameSignUp_AwardList, item);
					end
				end
			end
		end
	end
	--倒计时
	LeagueGameSignUpUI.SetCountDown();

	--赛事时间
	BP_LeagueGameSignUp_TimeDesc = FuncUtil.FormatTime4(LeagueGameSystem.LeagueBeginTime) .. "-" .. FuncUtil.FormatTime4(LeagueGameSystem.LeagueEndTime);

	--报名花费
	BP_LeagueGameSignUp_CostCoin = LeagueGameSystem.SignUpCostCoin;

	--报名状态
	BP_LeagueGameSignUp_State = LeagueGameSystem.signUpState;
	if LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].client_show[2] then
		BP_LeagueGameSignUp_SeaMatchTime = string.split(LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].client_show[1], "-")[1] .. "-" ..string.split(LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].client_show[2], "-")[2];
	else
		BP_LeagueGameSignUp_SeaMatchTime = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].client_show[1];
	end
	BP_LeagueGameSignUp_GroupMatchTime = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH].client_show[1];
	BP_LeagueGameSignUp_FinalMatchTime = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH].client_show[1];
	
	--检查报名CD倒计时
	LeagueGameSignUpUI.SetSignUpCancelCountDown();
	
	if LeagueGameSystem.apply_info ~= nil then
		BP_LeagueGameSignUp_ApplyMode = "";
		if LeagueGameSystem.apply_info.apply_mode == LeagueGameSystem.LEAGUE_TPP_MODE then
			BP_LeagueGameSignUp_ApplyMode = Client.GetTableData("LocalizeRes", 100054).TextValue;
		elseif 	LeagueGameSystem.apply_info.apply_mode == LeagueGameSystem.LEAGUE_FPP_MODE then
			BP_LeagueGameSignUp_ApplyMode = Client.GetTableData("LocalizeRes", 100053).TextValue;
		end
		BP_LeagueGameSignUp_ApplyZone = "";
		if LeagueGameSystem.apply_info.apply_zone then
			local zoneCfg = Client.GetTableData("ZoneConfig", LeagueGameSystem.apply_info.apply_zone);
			BP_LeagueGameSignUp_ApplyZone = zoneCfg.NameInChinese;
		end
	end
	--log_tree("BP_ARRAY_LeagueGameSignUp_AwardList", BP_ARRAY_LeagueGameSignUp_AwardList);

	--EventSystem:unregistEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_CONFIG_UPDATE, LeagueGameSignUpUI.Init);
	--EventSystem:registEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_CONFIG_UPDATE, LeagueGameSignUpUI.Init);
end

function LeagueGameSignUpUI.Release()
	-- body
	--EventSystem:unregistEvent(EVENTTYPE_LEAGUEGAME, EVENTID_LEAGUEGAME_CONFIG_UPDATE, LeagueGameSignUpUI.Init);
end

function LeagueGameSignUpUI.SetCountDown()
	if LeagueGameSystem.LeagueDateTable then
		local serverTime = FuncUtil.GetServerTimeInSec()
		if serverTime < LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ENROLL].end_time then
			LeagueGameSignUpUI.TimeToCountDown = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ENROLL].end_time
			LeagueGameSignUpUI.countDownTime = LeagueGameSignUpUI.TimeToCountDown - serverTime
			BP_LeagueGameSignUp_Countdown = FuncUtil.FormatTimeCountDown(LeagueGameSignUpUI.countDownTime);
			log("BP_LeagueGameSignUp_Countdown .." .. BP_LeagueGameSignUp_Countdown);
			if BP_LeagueGameSignUp_Countdown ~= "" and string.find(BP_LeagueGameSignUp_Countdown, ":") ~= nil then
				if LeagueGameSignUpUI.countDownTimer then
					Timer.RemoveTimer(LeagueGameSignUpUI.countDownTimer);
				end
				LeagueGameSignUpUI.countDownTimer = Timer.InsertTimer(1, LeagueGameSignUpUI.ShowCountDown, true, false);
			end
			BP_IS_SIGN_END = false
		elseif serverTime >= LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ENROLL].end_time
				and serverTime < LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].begin_time then
			LeagueGameSignUpUI.TimeToCountDown = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].begin_time
			LeagueGameSignUpUI.countDownTime = LeagueGameSignUpUI.TimeToCountDown - serverTime
			BP_LeagueGameSignUp_Countdown = FuncUtil.FormatTimeCountDown(LeagueGameSignUpUI.countDownTime);
			log("BP_LeagueGameSignUp_Countdown .." .. BP_LeagueGameSignUp_Countdown);
			if BP_LeagueGameSignUp_Countdown ~= "" and string.find(BP_LeagueGameSignUp_Countdown, ":") ~= nil then
				if LeagueGameSignUpUI.countDownTimer then
					Timer.RemoveTimer(LeagueGameSignUpUI.countDownTimer);
				end
				LeagueGameSignUpUI.countDownTimer = Timer.InsertTimer(1, LeagueGameSignUpUI.ShowCountDown, true, false);
			end
			BP_IS_SIGN_END = true
		elseif serverTime >= LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].begin_time then
			LeagueGameSignUpPopUI.Hide()
			LeagueGameSignUpUI.Hide()
			LeagueGameLobbyUI.Init()
			return
		end

		
	end
end

function LeagueGameSignUpUI.ShowCountDown()
	LeagueGameSignUpUI.countDownTime = LeagueGameSignUpUI.TimeToCountDown - FuncUtil.GetServerTimeInSec();
	if LeagueGameSignUpUI.countDownTime < 0 then
		log("LeagueGameSignUpUI.ShowCountDown():CountDown < 0!!!")
		LeagueGameSignUpPopUI.Hide()
		LeagueGameSignUpUI.Hide()
		LeagueGameLobbyUI.Init()
		return
	end
	if LeagueGameSignUpUI.countDownTime < 7200 then
		LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "HideCancelRegisteredBtn");
	end
	BP_LeagueGameSignUp_Countdown = FuncUtil.FormatTimeCountDown(LeagueGameSignUpUI.countDownTime);
 	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "ShowCountDown");
	log("BP_LeagueGameSignUp_Countdown .." .. BP_LeagueGameSignUp_Countdown);
end

function LeagueGameSignUpUI.Show()
	if _preShowCallback ~= nil and type(_preShowCallback) == "function" then
		_preShowCallback()
	end
	_preShowCallback = nil

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN);
    -- LobbyUI:ShowLobbyPlayer(false);

	LuaClassObj.HandleDynamicCreation(bp_leagueGame_signUp);
 	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "UIShow");
 	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "ShowCountDown");
 	LeagueGameSignUpUI.IsShow = true;

	if _postShowCallback ~= nil and type(_postShowCallback) == "function" then
		_postShowCallback()
	end
	_postShowCallback = nil

	if LeagueGameSignUpUI.countDownTime > 7200 and (LeagueGameSystem.signUpState ~= 2 and LeagueGameSystem.signUpState ~= 0) then
		LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "ShowCancelRegisteredBtn");
	else
		LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "HideCancelRegisteredBtn");
	end
end

function LeagueGameSignUpUI.Hide()
	-- body
	if LeagueGameSignUpUI.countDownTimer ~= nil then
		Timer.RemoveTimer(LeagueGameSignUpUI.countDownTimer);
		LeagueGameSignUpUI.countDownTimer = nil;
	end

	if LeagueGameSignUpUI.cancelCountDownTimer ~= nil then
		Timer.RemoveTimer(LeagueGameSignUpUI.cancelCountDownTimer);
		LeagueGameSignUpUI.cancelCountDownTimer = nil;
	end
 	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "UIHide");
 	LeagueGameSignUpUI.Release();
 	LeagueGameSignUpUI.IsShow = false;
end

function LeagueGameSignUpUI.SetInvisible()
	LeagueGameLeagueInfoUI.IsEnableToShow = false

	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "UIHide");
end

function LeagueGameSignUpUI.SetVisible()
	LeagueGameLeagueInfoUI.IsEnableToShow = true

	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "UIShow");
end

function LeagueGameSignUpUI.OnApplicationReactivated()
	if LeagueGameSignUpUI.IsShow then
		LeagueGameSignUpUI.SetCountDown();
	end
end

function LeagueGameSignUpUI.SendCancelSignUpInfo()
	LeagueGameSystem.carteam_cancel_enroll_league_req();
end

function LeagueGameSignUpUI.SetSignUpCancelCountDown()
	if LeagueGameSystem.LastCancelEnrollTime > 0 and LeagueGameSystem.EnrollCdTime > 0 then
		LeagueGameSystem.signUpState = 2;
		BP_LeagueGameSignUp_State = LeagueGameSystem.signUpState;
		local sec = (LeagueGameSystem.LastCancelEnrollTime + LeagueGameSystem.EnrollCdTime) - FuncUtil.GetServerTimeInSec();
		if sec > 0 then
			timeStr = FuncUtil.GetTimeBySec(sec);
			BP_LeagueGameSignUpCancel_CountDown = string.gsub(Client.GetTableData("LocalizeRes", "6329").TextValue, "{0}", timeStr);
			if LeagueGameSignUpUI.cancelCountDownTimer then
				Timer.RemoveTimer(LeagueGameSignUpUI.cancelCountDownTimer);
			end
			LeagueGameSignUpUI.cancelCountDownTimer = Timer.InsertTimer(1, LeagueGameSignUpUI.SetSignUpCancelCountDown, true, false);
		else
			BP_LeagueGameSignUpCancel_CountDown = "";
			if LeagueGameSignUpUI.cancelCountDownTimer then
				Timer.RemoveTimer(LeagueGameSignUpUI.cancelCountDownTimer);
			end
			LeagueGameSystem.signUpState = 0;
			BP_LeagueGameSignUp_State = LeagueGameSystem.signUpState;
			LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "Init");
		end
	end
	LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_signUp, "ShowCancelRegCountDown");
end

--赛事报名
function EventLeagueGameSignUpPop()
	--log_tree("BP_STRUCT_AllianceInfo", BP_STRUCT_AllianceInfo);
	if BP_STRUCT_AllianceInfo and BP_STRUCT_AllianceInfo.aid and #BP_STRUCT_AllianceInfo.aid > 0 then	
  		LeagueGameSignUpPopUI.Init();
  	else
		PopUpNoticeUI.ShowNewNotice(Client.GetTableData("LocalizeRes", 6514).TextValue);
  	end
end

function EventLeagueGameSignUpHide()
	LeagueGameSignUpPopUI.Hide();
	LeagueGameSignUpUI.Hide();

	EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE)
  	LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
    -- LobbyUI:ShowLobbyPlayer(true);
end

--赛事引导
function EventLeagueGameIntroduce()
	LeagueGameIntroduceUI.Init();
end
--赛程奖励
function EventLeagueGameForAward()
	LeagueGameTreasureBoxUI.ShowUI();
end

--海选赛
function EventLeagueGameSignUpToSeaRule()
	LeagueGameScheduleRuleUI.Init(LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH, 0);
end

--小组赛
function EventLeagueGameSignUpToGroupRule()
	LeagueGameScheduleRuleUI.Init(LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH, 0);
end

--总决赛
function EventLeagueGameSignUpToFinalRule()
	LeagueGameScheduleRuleUI.Init(LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH, 0);
end


function EventLeagueGameSignUpJumpMallDIY()
	local page = DIY_SUIT_INDEX
	local itemId = 1400708
	local shopId = MallSystem.GetShopId(page, itemId);
	log("EventLeagueGameJumpMallDIY shopId = " ..shopId);
	if(shopId == 0) then
		return;
	end
	local params = {
		["Tab1"] = page,
		["Tab2"] = MallSystem.GetShopTab2(page, itemId),
		["selectShopId"] = shopId,
   		["isFromLeague"] = 0,
		["itemId"] = itemId,
	};
  --EventLeagueGameSignUpHide();
  LeagueGameSignUpUI.SetInvisible();
  LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
  -- LobbyUI:ShowLobbyPlayer(true);  
  
  EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params);
end


function EventLeagueGameCancelSignUpSend()
	if LeagueGameSystem.EnrollCdTime == 0 then
		LeagueGameSystem.EnrollCdTime = 1800;
	end
	local content = Client.GetTableData("LocalizeRes", "6326").TextValue;
	local timeStr = FuncUtil.GetTimeBySec(LeagueGameSystem.EnrollCdTime);
	local coin = FuncUtil.LocalizeResFormat(4066, tostring(LeagueGameSystem.SignUpCostCoin / 2));
	--content = string.format(content, tostring(timeStr), tostring(coin));
	content = string.gsub(content, "{0}", tostring(timeStr));
	content = string.gsub(content, "{1}", tostring(coin));
	CommonMessageBoxUI:ShowPanel(2, Client.GetTableData("LocalizeRes", "6327").TextValue, content, function() LeagueGameSignUpUI.SendCancelSignUpInfo() end);
end