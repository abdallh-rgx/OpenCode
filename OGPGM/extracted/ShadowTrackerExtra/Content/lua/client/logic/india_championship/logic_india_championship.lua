--线上锦标赛逻辑
IndiaChampionShipLogic = IndiaChampionShipLogic or {
	Score = 0,				-- 积分
	UnstableScore = 0,		-- 未确定是否下发的积分
	tournaments = {},		-- 赛事信息
	popUpTimer = nil,		-- 入房弹窗提醒timer
	popUpTimerStart = nil,	-- 开赛弹窗提醒timer
	matchCheckTimer = nil,	-- 匹配检查timer
	matchState = true,		-- 匹配状态,默认为成功
    tournamentHas = false;  -- 登录时候发现有赛事开启报名了
	LockEnter = true,		-- 是否关闭入口
	isNeedRedPoint = false,	--记录是否有小红点提示,每天提示一次
}

-- 报名错误码
err_tournament_enrolled			= 520001;	-- 已经报过名
err_tournament_invalid_price	= 520002;	-- 价格配置不对
err_tournament_enrolleding		= 520003;	-- 报名中
err_tournament_more_res			= 520004;	-- 报名资源不足
err_tournament_pay_fail			= 520005;	-- 支付失败
err_tournament_np_cfg			= 520006;	-- 没有这个比赛
err_tournament_not_enrolle_time	= 520007;	-- 不在报名时间内
err_tournament_ernoll_full		= 520008;	-- 报名满了

-- 加入房间错误码
room_err_room_not_exist       = 110068;   --房间不存在或已解散
room_err_room_in_game         = 110071;   --房间在游戏中
room_err_room_is_full         = 110075;   --房间已满
room_err_version_not_same     = 110091;   --版本号不一致，不能加入房间

-- 获取赛事列表错误码

-- 新手引导id
Newbie_Guide_India_Championship_Introduce = 1;		-- 新手引导
Newbie_Guide_India_Championship_Tournament_New = 2;	-- 新赛事
Newbie_Guide_India_Championship_Mall = 3;			-- 商城按钮点击

function IndiaChampionShipLogic.Init()
	IndiaChampionShipLogic.matchState = true;
	IndiaChampionShipLogic.LockEnter = true;
end

-- 请求报名线上锦标赛
-- @tournament_id 赛事id
-- @price_type 价格类型，金币、uc，对应物品中id
function IndiaChampionShipLogic.tournament_enroll_req(tournament_id, price_type)
	log("tournament_req,id:"..tournament_id..", price_type:"..price_type);
	NetUtil.SendPkg("tournament_enroll_req", tournament_id, price_type);
end

-- 锦标赛报名回包
function IndiaChampionShipLogic.tournament_enroll_rsp(res, tournament_id)
	log("tournament_enroll_rsp res:"..tostring(res)..", id:"..tostring(tournament_id))
	if res == 0 then
		--报名成功刷新条目
        IndiaChampionShipLogic.get_tournaments_req()
		IndiaCompetitionUI:SetCreditAndTicket()
		ShowNotice(6045);
	elseif res == 520004 then
		--UC不足指引充值
		local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
		local tip = Client.GetTableData("LocalizeRes", "4119").TextValue;
		CommonMessageBoxUI:ShowPanel(2, title, tip, function()
			RechargeUI:Init();
			return true;
		end);
		ShowNotice(res);
	else
		ShowNotice(res);
	end
end

-- 请求线上锦标赛进入房间
function IndiaChampionShipLogic.enter_tournament_room_req()
	NetUtil.SendPkg("enter_tournament_room_req");
end

-- 请求线上锦标赛进入房间回包
function IndiaChampionShipLogic.enter_tournament_room_rsp(res, room, members)
	log("enter_tournament_room_rsp res:"..tostring(res)..", room:"..tostring(room))
	log_tree("room",room);
	log_tree("members",members);
	if res ~= 0 then
		sandbox.LogNormal("join_room_respond failed = " .. res);
		--版本不一致
		if res == 110091 then
			DataMgr.ShowMessageBoxByID(res);
			RoomSystem.req_room_list();
			return;
		end

		--二维码扫描，组队或匹配中
		if RoomSystem.IsQRCodeEnterRoom == true then
			RoomSystem.IsQRCodeEnterRoom = false;
			if res == 110103 or res == 110133 then
				DataMgr.ShowNoticeByID(res);
				RoomUI:RoomHide()
				return;
			end
		end

		DataMgr.ShowNoticeByID(res);
		RoomSystem.req_room_list();
		return;
	end

	--res=0，成功进入房间
	base_info = room

	BattleResult.IgnoreDSError = false;

	RoomSystem.CurrentRoomInfo = base_info;
	RoomSystem.CurrentRoomInfo.owner_id = tostring(RoomSystem.CurrentRoomInfo.owner_id);

	RoomSystem.CurrentRoomInfo.MemberInfoList = {};
	for k, v in pairs(members) do
		local tmp = v;
		tmp.openid = tostring(k);
		tmp.isRoomMaster = (RoomSystem.CurrentRoomInfo.owner_id == tmp.openid);
		tmp["head_url"] = "";
		tmp["gender"] = "";
		tmp["frame_level"] = "";
		table.insert(RoomSystem.CurrentRoomInfo.MemberInfoList, tmp);
	end
	--清理计时器
	if IndiaChampionShipLogic.popUpTimer then
		Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimer)
		IndiaChampionShipLogic.popUpTimer = nil
	end
	if IndiaChampionShipLogic.popUpTimerStart then
		Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimerStart)
		IndiaChampionShipLogic.popUpTimerStart = nil
	end
	if IndiaChampionShipLogic.matchCheckTimer then
		Timer.RemoveTimer(IndiaChampionShipLogic.matchCheckTimer)
		IndiaChampionShipLogic.matchCheckTimer = nil
	end
	RoomSystem.req_profile_join_room();
end



--请求线上锦标赛比赛条目
function IndiaChampionShipLogic.get_tournaments_req()
	NetUtil.SendPkg("get_tournaments_req");
end

--[[
india_championship_list =
└─ 10001
   ├─ state: 2
   ├─ roundlimit: 1
   ├─ round: 1
   ├─ type: 1000
   ├─ type_data
   │  ├─ enroll_count: 0
   │  ├─ enter_time: 1547986200
   │  ├─ earn_score: 1000
   │  ├─ mode_group: 11003
   │  ├─ level_limit: 10
   │  ├─ cost
   │  │  └─ 1006: 10
   │  ├─ close_time: 1547988000
   │  ├─ min_segment: 0
   │  ├─ max_segment: 0(可能为空)
   │  ├─ enroll_endTime: 1547967600
   │  ├─ match_time: 1547985600
   │  ├─ enroll_limit: 8000
   │  ├─ enroll_begTime: 1547966700
   │  └─ start_time: 1547986800
   ├─ title: "记得配置标题"
   └─ user_data
      └─ enroll_state: 0
--]]
--请求线上锦标赛比赛条目回包
function IndiaChampionShipLogic.get_tournaments_rsp(tournaments)
	log_tree("india_championship_list = ",tournaments)
	if tournaments then
		IndiaChampionShipLogic.tournaments = tournaments;

		--清理计时器
		if IndiaChampionShipLogic.popUpTimer then
			Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimer)
			IndiaChampionShipLogic.popUpTimer = nil
		end
		if IndiaChampionShipLogic.popUpTimerStart then
			Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimerStart)
			IndiaChampionShipLogic.popUpTimerStart = nil
		end
		if IndiaChampionShipLogic.matchCheckTimer then
			Timer.RemoveTimer(IndiaChampionShipLogic.matchCheckTimer)
			IndiaChampionShipLogic.matchCheckTimer = nil
		end

		local is_enroll = false;
		for k,v in pairs(tournaments) do
			if v.user_data.enroll_state == 1 then
				is_enroll = true;
				local serverTime = FuncUtil.GetServerTimeInSec()
				---弹窗提醒倒计时处理逻辑
				if v.type_data.enter_time-serverTime > 0 then
					IndiaChampionShipLogic.popUpTimer = Timer.InsertTimer(v.type_data.enter_time-serverTime, IndiaChampionShipLogic.EnterRoomTimerFunc, false, false)
				end
				if v.type_data.start_time-120-serverTime > 0 then
					IndiaChampionShipLogic.popUpTimerStart = Timer.InsertTimer(v.type_data.start_time-120-serverTime, IndiaChampionShipLogic.StartGameTimerFunc, false, false)
				end

				---匹配成功检查处理逻辑
				local offset = math.random(0,10)
				local matchCheckSendTime = v.type_data.match_time - serverTime;
				--未超过匹配时间
				if matchCheckSendTime>0 then
					is_enroll = false
					IndiaChampionShipLogic.matchCheckTimer = Timer.InsertTimer(matchCheckSendTime+offset, IndiaChampionShipLogic.MatchTimerFunc, false, false)
				--已超过匹配时间直接触发检查
				else
					IndiaChampionShipLogic.MatchTimerFunc();
				end
				break;
			end
		end

		--是否更新匹配成功状态
		IndiaChampionShipLogic.matchState = not is_enroll or IndiaChampionShipLogic.matchState;
		IndiaCompetitionUI:SetTournamentData(tournaments);
	end
end

--入房timer函数
function IndiaChampionShipLogic.EnterRoomTimerFunc()
	if not RoomWaitingUI.IsShow then
		IndiaMatchTimeNoticeUI.Show();
	end
	if IndiaChampionShipLogic.popUpTimer then
		Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimer);
	end
end
--开赛timer函数
function IndiaChampionShipLogic.StartGameTimerFunc()
	if not RoomWaitingUI.IsShow then
		IndiaMatchTimeNoticeJumpUI.Show()
	end
	if IndiaChampionShipLogic.popUpTimerStart then
		Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimerStart)
	end
end
--匹配检查timer函数
function IndiaChampionShipLogic.MatchTimerFunc()
	IndiaChampionShipLogic.tournament_room_id_req()
end



--请求线上锦标赛历史战绩
function IndiaChampionShipLogic.tournament_info_req()
	NetUtil.SendPkg("tournament_info_req");
end

--请求线上锦标赛历史战绩回包
function IndiaChampionShipLogic.tournament_info_rsp(tournamentsInfo)
	log_tree("tournament_info_rsp list = ",tournamentsInfo)
	EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_HISTORY_RECORD_UPDATE, tournamentsInfo);
end

--请求线上锦标赛当前积分
function IndiaChampionShipLogic.get_tournament_score_req()
	NetUtil.SendPkg("get_tournament_score_req");
end

--请求线上锦标赛积分回包
function IndiaChampionShipLogic.get_tournament_score_rsp(score, unstableScore)
	log("get_tournament_score_rsp score:"..tostring(score)..", unstableScore:"..tostring(unstableScore))
	IndiaChampionShipLogic.Score = score;
	IndiaChampionShipLogic.UnstableScore = unstableScore;
	IndiaCompetitionUI:SetCreditAndTicket()
end

--线上锦标赛积分下发
function IndiaChampionShipLogic.notify_tournament_score_change(score, unstableScore)
	log("notify_tournament_score_change score:"..tostring(score)..", unstableScore:"..tostring(unstableScore))
	IndiaChampionShipLogic.Score = score;
	IndiaChampionShipLogic.UnstableScore = unstableScore;
	IndiaCompetitionUI:SetCreditAndTicket()
end

--请求锦标赛新手引导物品奖励
function IndiaChampionShipLogic.get_tournament_newbie_award_req()
	NetUtil.SendPkg("get_tournament_newbie_award_req");
end

--锦标赛新手引导物品奖励回包
function IndiaChampionShipLogic.get_tournament_newbie_award_rsp(res, items)
	log("get_tournament_newbie_award_rsp res:"..tostring(res));
	log_tree("items",items);
	if res == 0 or res == "ok" then
		IndiaCompetitionIntroduceUI.OnGetNewbieAwards(items)
	else
		IndiaCompetitionIntroduceUI.Hide()
	end
end

function IndiaChampionShipLogic.OpenUrl()
	local baseUrl = "https://www.pubgmobile.com/act/a20190107point/index.html";
	local strOpenid = DataMgr.roleData.openID;
	local strUid = DataMgr.roleData.uid;
	local myLanguage = tostring(Client.GetCurrentLanguage());
	if (myLanguage == "HK")then
		myLanguage = "zh-HK"
	elseif(myLanguage == "TW")then
		myLanguage = "zh-TW";
	end
	local current_version = Client.GetAppVersion() or "0.0.0.0";
	local webTicket = Client.GetWebViewTicket(NetInterface);
	local strUserName = FuncUtil:EncodeURI(DataMgr.roleData.nickName);
	
	local finalUrl = string.format("%s?nickName=%s&openid=%d&uid=%d&totalScore=%d&unstableScore=%d&ipRegion=%s&version=%s&language=%s&game_area=%s&sTicket=%s", 
			baseUrl, strUserName, strOpenid, strUid, IndiaChampionShipLogic.Score,IndiaChampionShipLogic.UnstableScore, 
			LoginSystem.ip_region, current_version,myLanguage, LobbySystem.matchZone, webTicket)

	local IndiaPrivateKey = "XEPPTNsQV5BAkGDA";
	local sign = "";
	local signUrl = string.format("openid=%d&uid=%d&totalScore=%d&unstableScore=%d&ipRegion=%s&language=%s&game_area=%s&version=%s",
			strOpenid, strUid, IndiaChampionShipLogic.Score,IndiaChampionShipLogic.UnstableScore,
			LoginSystem.ip_region, myLanguage, LobbySystem.matchZone, current_version);
	local encryptionStr = IndiaPrivateKey .. signUrl .. IndiaPrivateKey;
	sign = Client.MD5HashAnsiString(encryptionStr);
	finalUrl = finalUrl.."&sign="..sign;
	log("finalUrl url = " .. finalUrl)
	Client.OpenURL(finalUrl);
end

--获取注册比赛名称
function IndiaChampionShipLogic.GetEnrollName()
	for k ,v in pairs(IndiaChampionShipLogic.tournaments) do
		if v.user_data.enroll_state == 1 then
			return v.title
		end
	end
	return ""
end

--获取注册比赛开赛时间
function IndiaChampionShipLogic.GetEnrollStartTime()
	for k ,v in pairs(IndiaChampionShipLogic.tournaments) do
		if v.user_data.enroll_state == 1 then
			return v.type_data.start_time
		end
	end
	return 0
end

--点击匹配时检查锦标赛时间，返回false为不弹窗
function IndiaChampionShipLogic.LobbyMatchCheck()
	if not IndiaChampionShipLogic.tournaments or IndiaChampionShipLogic.tournaments == {} then
		return false
	end
	local modeInfo = TeamUpMatchInfoUI.GetCurrentModelInfo()
	if not modeInfo or not modeInfo.model_id then
		return false
	end

	for k,v in pairs(IndiaChampionShipLogic.tournaments) do
		if v.user_data and v.user_data.enroll_state == 1 then
			local modeInfo = TeamUpMatchInfoUI.GetCurrentModelInfo();
			if not modeInfo then
				return false
			end
			local gameTime = 2700
			if modeInfo.model_id>200 then
				gameTime=1200
			end

			local indiaTourmentTime = v.type_data.start_time
			local serverTime = FuncUtil.GetServerTimeInSec();
			if serverTime < indiaTourmentTime and serverTime+gameTime > indiaTourmentTime then
				IndiaMatchPopUpUI.ShowUI(indiaTourmentTime-serverTime);
				return true;
			end
			break;
		end
	end
	return false
end

--请求锦标赛分配房间ID（用于检查是否匹配成功）
function IndiaChampionShipLogic.tournament_room_id_req()
	NetUtil.SendPkg("tournament_room_id_req")
end

--请求锦标赛分配房间ID回包
function IndiaChampionShipLogic.tournament_room_id_rsp(res,roomId)
	log("tournament_room_id_rsp res = "..tostring(res))
	if IndiaChampionShipLogic.matchCheckTimer then
		Timer.RemoveTimer(IndiaChampionShipLogic.matchCheckTimer)
		IndiaChampionShipLogic.matchCheckTimer = nil
	end
	if res == 0 then
		IndiaChampionShipLogic.matchState = true;
	elseif res == 520017 then
		IndiaChampionShipLogic.matchState = false;
		if IndiaChampionShipLogic.popUpTimerStart then
			Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimerStart)
			IndiaChampionShipLogic.popUpTimerStart = nil
		end
		if IndiaChampionShipLogic.popUpTimer then
			Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimer)
			IndiaChampionShipLogic.popUpTimer = nil
		end
		IndiaCompetitionUI:OnReceiveMatchFail(IndiaChampionShipLogic.tournaments)
	else
		IndiaChampionShipLogic.matchCheckTimer = Timer.InsertTimer(15, IndiaChampionShipLogic.MatchTimerFunc, false, false)
		for k,v in pairs(IndiaChampionShipLogic.tournaments) do
			if v.user_data.enroll_state == 1 then
				local serverTime = FuncUtil.GetServerTimeInSec();
				--已超过匹配时间
				if v.type_data.enter_time - serverTime<=0 then
					IndiaChampionShipLogic.matchState = false;
					--不清理弹窗计时器改为在房间内不谈
					--[[if IndiaChampionShipLogic.popUpTimerStart then
						Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimerStart)
						IndiaChampionShipLogic.popUpTimerStart = nil
					end
					if IndiaChampionShipLogic.popUpTimer then
						Timer.RemoveTimer(IndiaChampionShipLogic.popUpTimer)
						IndiaChampionShipLogic.popUpTimer = nil
					end--]]
					Timer.RemoveTimer(IndiaChampionShipLogic.matchCheckTimer)
					IndiaChampionShipLogic.matchCheckTimer = nil
					IndiaCompetitionUI:OnReceiveMatchFail(IndiaChampionShipLogic.tournaments)
				end
				break;
			end
		end
	end
	IndiaCompetitionUI:SetTournamentData(IndiaChampionShipLogic.tournaments)
end

--有赛事开启报名了
function IndiaChampionShipLogic.notify_tournament_new()
	log("IndiaChampionShipLogic.notify_tournament_new");
	IndiaChampionShipLogic.LockEnter=false;
	-- 检查新手引导，当天不需要通知
	local timeData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP,Newbie_Guide_India_Championship_Tournament_New);
	if timeData then
		local nowData = math.floor(FuncUtil.GetServerTimeInSec() / 86400);
		if nowData - timeData > 0 then
			LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true);	-- 大厅的ui红点
			EventSystem:postEvent(EVENTTYPE_INDIA_COMPETITION, EVENTID_INDIA_CHAMPIONSHIP_TOURNAMENT_NEW_NOTIFY);	-- 里层的红点刷新
			IndiaChampionShipLogic.isNeedRedPoint = true;
		end
	end
end

--登录时下发有赛事已经开启报名了
function IndiaChampionShipLogic.notify_tournament_has()
    log("IndiaChampionShipLogic.notify_tournament_has")
	IndiaChampionShipLogic.LockEnter=false;
    IndiaChampionShipLogic.tournamentHas = true;
    local timeData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP,Newbie_Guide_India_Championship_Tournament_New);
    if timeData then
        local nowData = math.floor(FuncUtil.GetServerTimeInSec() / 86400);
        if nowData - timeData > 0 then
            LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true);	-- 大厅的ui红点
			IndiaChampionShipLogic.isNeedRedPoint = true;
        end
    end
end

s2c = s2c or {}
s2c["tournament_enroll_rsp"] = IndiaChampionShipLogic.tournament_enroll_rsp;
s2c["enter_tournament_room_rsp"] = IndiaChampionShipLogic.enter_tournament_room_rsp;
s2c["get_tournaments_rsp"] = IndiaChampionShipLogic.get_tournaments_rsp;
s2c["tournament_info_rsp"] = IndiaChampionShipLogic.tournament_info_rsp;
s2c["get_tournament_score_rsp"] = IndiaChampionShipLogic.get_tournament_score_rsp;
s2c["notify_tournament_score_change"] = IndiaChampionShipLogic.notify_tournament_score_change;
s2c["get_tournament_newbie_award_rsp"] = IndiaChampionShipLogic.get_tournament_newbie_award_rsp;
s2c["tournament_room_id_rsp"] = IndiaChampionShipLogic.tournament_room_id_rsp;
s2c["notify_tournament_new"] = IndiaChampionShipLogic.notify_tournament_new;
s2c["notify_tournament_has"] = IndiaChampionShipLogic.notify_tournament_has;