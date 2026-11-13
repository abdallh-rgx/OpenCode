LeagueGameLobbyUI = LeagueGameLobbyUI or {
  countDownTimer = nil,
  countDownTime = 0,
  IsShow = false,
  TimeToCountDown = 0,
}

BP_LeagueGame_LeagueID = 0;     --赛事ID
BP_LeagueGame_Stage = 0;        --当前赛事阶段
BP_LeagueGame_SignState = 0;    --报名阶段


BP_LeagueGame_MatchTime1 = "";       --赛事时间
BP_LeagueGame_MatchTime2 = "";       --赛事时间--海选赛有2个时间阶段
BP_LeagueGame_MatchDate = "";
BP_LeagueGame_MatchTime = "";
BP_LeagueGame_MatchTimeOne = "";
BP_LeagueGame_MatchInfo = "";        --比赛信息
BP_LeagueGame_MatchStageName = "";   --赛事名字

BP_LeagueGame_Countdown = "";        --倒计时
BP_LeagueGame_CountdownDesc = "";    --倒计时描述 

BP_SeasonDesc = ""             --赛季描述
BP_Season_OverDesc = ""        --赛季结束描述
BP_Season_WaitingDesc = ""     --等待下个赛季描述
BP_IS_SIGN_END = false         --是否报名结束
BP_Text_SeasonReview = ""      --报名、晋级描述

BP_LeagueGame_DailyEntryNum = 2;        --海选赛每日最多参赛场数2

local _preShowCallback;
local _postShowCallback;

function bp_leagueGame_lobby_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_leagueGame_lobby,
    {{Path="/Game/UMG/UI_Logic/LeagueGame/LeagueGame_lobby_BP.LeagueGame_lobby_BP_C", Container="Default", ZOrder = BP_ENUM_UI_LEAGUEGAME_LOBBY}},
    {"Lobby"},
    false,
    false,
    true
  );
end

function LeagueGameLobbyUI.Init(PreShowCallback,PostShowCallback)
  _preShowCallback = PreShowCallback
  _postShowCallback = PostShowCallback
  --LeagueGameLobbyUI.CheckAndShowNewSeason();
  --LeagueGameLeagueInfoUI.Init();
  LeagueGameLobbyUI.IsAllianceUI = false

  ConnectionWaitingUI:Show()
  local HideWaitingUI = function() ConnectionWaitingUI:Hide() end
  Timer.InsertTimer(10, HideWaitingUI, false, false)
  LeagueGameSystem.LeagueGameStageReq();
  --LeagueGameSystem.LeagueGamePromoteStateReq();
end

function LeagueGameLobbyUI.AllianceInit()
  --LeagueGameLobbyUI.IsAllianceUI = true
  --LuaClassObj.HandleDynamicCreation(bp_leagueGame_lobby);
  --
  --LeagueGameSystem.LeagueGameStageReq()
  --log("LeagueGameLobbyUI.AllianceInitLeagueGameLobbyUI.AllianceInitLeagueGameLobbyUI.AllianceInit")
end

function LeagueGameLobbyUI.Release()
  if LeagueGameLobbyUI.countDownTimer ~= nil then
    Timer.RemoveTimer(LeagueGameLobbyUI.countDownTimer);
    LeagueGameLobbyUI.countDownTimer = nil;
  end
end

function LeagueGameLobbyUI.SetData()
  BP_LeagueGame_Stage = LeagueGameSystem.StageId;

  if BP_LeagueGame_Stage == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then

    BP_LeagueGame_MatchStageName = Client.GetTableData("LocalizeRes", "6049").TextValue;
    BP_LeagueGame_MatchInfo = tostring(#LeagueGameSystem.LeagueTimeTable[BP_LeagueGame_Stage][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);
    BP_LeagueGame_MatchTime1 = LeagueGameSystem.LeagueDateTable[BP_LeagueGame_Stage].client_show[1];
    BP_LeagueGame_MatchTime2 = "";
    if LeagueGameSystem.LeagueDateTable[BP_LeagueGame_Stage].client_show[2] then
      BP_LeagueGame_MatchTime2 = LeagueGameSystem.LeagueDateTable[BP_LeagueGame_Stage].client_show[2];
    end

  elseif BP_LeagueGame_Stage == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH then

    BP_LeagueGame_MatchStageName = Client.GetTableData("LocalizeRes", "6050").TextValue;
    BP_LeagueGame_MatchInfo = tostring(#LeagueGameSystem.LeagueTimeTable[BP_LeagueGame_Stage][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);
    BP_LeagueGame_MatchTime1 = LeagueGameSystem.LeagueDateTable[BP_LeagueGame_Stage].client_show[1];

  elseif BP_LeagueGame_Stage >= LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH and BP_LeagueGame_Stage < LeagueGameSystem.LEAGUE_STAGE_TOP_CLEAR then

    BP_LeagueGame_MatchStageName = Client.GetTableData("LocalizeRes", "6051").TextValue;
    BP_LeagueGame_MatchInfo = tostring(#LeagueGameSystem.LeagueTimeTable[LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH][LeagueGameSystem.LEAGUE_TPP_MODE][1].match_time);
    BP_LeagueGame_MatchTime1 = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH].client_show[1];
  end
end

--联赛显示
function LeagueGameLobbyUI.Show()
  --log("LeagueGameLobbyUI.ShowLeagueGameLobbyUI.Show .. " .. LeagueGameSystem.StageId);
  if LeagueGameLobbyUI.IsAllianceUI then
    --LeagueGameLobbyUI.alliance_show_init()
  else
    LeagueGameLobbyUI.show_init()
  end
end

function LeagueGameLobbyUI.DoCallBack()
  if _preShowCallback ~= nil and type(_preShowCallback) == "function" then
    _preShowCallback()
  end
  _preShowCallback = nil

  if _postShowCallback ~= nil and type(_postShowCallback) == "function" then
    _postShowCallback()
  end
  _postShowCallback = nil
end

function LeagueGameLobbyUI.Show_CallBack()
  if _preShowCallback ~= nil and type(_preShowCallback) == "function" then
    _preShowCallback()
  end
  _preShowCallback = nil

  --赛事入口UI--防止界面被销毁，再动态load一次
  LuaClassObj.HandleDynamicCreation(bp_leagueGame_lobby);
  LuaClassObj.HandleUIMessage(bp_leagueGame_lobby, "UIShow");
  LeagueGameLobbyUI.IsShow = true;

  ConnectionWaitingUI:Hide()
  if _postShowCallback ~= nil and type(_postShowCallback) == "function" then
    _postShowCallback()
  end
  _postShowCallback = nil
end

--联赛UI初始化
function LeagueGameLobbyUI.show_init()
  if not LeagueGameSystem.StageId or LeagueGameSystem.StageId < LeagueGameSystem.LEAGUE_STAGE_ENROLL then
    log("LeagueGameLobbyUI.show_init().ShowWaitingNextStageUI()")
    --TODO:添加本地化配置描述
    CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "116009").TextValue, nil);
    ConnectionWaitingUI:Hide()
  else
    if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
      --报名阶段UI
      log("LeagueGameSignUpUI.Init");
      local function postShowCallback()
        ConnectionWaitingUI:Hide()
      end
      LeagueGameSignUpUI.Init(nil, postShowCallback)
    elseif LeagueGameSystem.StageId > LeagueGameSystem.LEAGUE_STAGE_ENROLL and LeagueGameSystem.StageId < LeagueGameSystem.LEAGUE_STAGE_TOP_CLEAR then
      --赛事信息UI
      log("LeagueGameLeagueInfoUI.Init");
      local function postShowCallback()
        ConnectionWaitingUI:Hide()
      end
      LeagueGameLeagueInfoUI.Init(nil, postShowCallback);

      --赛事入口UI--初始化加载，优化打开时间
      LuaClassObj.HandleDynamicCreation(bp_leagueGame_lobby);
      LuaClassObj.HandleUIMessage(bp_leagueGame_lobby, "UIInit");

      if LeagueGameSystem.signUpState == 0 then
        --未参赛
        log("LeagueGameLobbyUI.show_init()" .. "未参赛")
        ---若要显示未参赛文字，则去掉注释并修改BP_Text_SeasonReview的文字---
        ---BP_Text_SeasonReview == "未参赛"
        ---LeagueGameLobbyUI.SetSignStateAndShow()
        ---------------------------------------------------------------
      else
        --只有在海选赛与战区决赛之间显示倒数与晋级信息
        if LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH
                and LeagueGameSystem.StageId <= LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH then
          if LeagueGameSystem.Ispromote == false
                  and LeagueGameSystem.StageId > LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
            --未晋级
            log("LeagueGameLobbyUI.show_init()" .. "未晋级")

            BP_Text_SeasonReview = Client.GetTableData("LocalizeRes", "6237").TextValue;
            --TODO:添加本地化配置描述
            LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowNotPromoteUI")
          else
            --海选赛、晋级
            log("LeagueGameLobbyUI.show_init()" .. "海选赛、晋级")
            LeagueGameLobbyUI.SetCountDownState()
          end
        end
      end

    elseif LeagueGameSystem.StageId > LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH then
      --赛事结束
      log("LeagueGameFinalChampionUI.Init");
      local function postShowCallback()
        ConnectionWaitingUI:Hide()
      end
      LeagueGameFinalChampionUI.Init(nil, postShowCallback);
    end
    LeagueGameLobbyUI.CheckAndShowNewSeason();
  end
end

--战队赛UI初始化
function LeagueGameLobbyUI.alliance_show_init()
  --当前没有全球总决赛阶段，即全球总决赛阶段（包含）之后为赛季结束阶段
  --local EndStage = LeagueGameSystem.LEAGUE_STAGE_GLOBAL_FINAL_MATCH
  --
  --if not LeagueGameSystem.StageId or LeagueGameSystem.StageId < LeagueGameSystem.LEAGUE_STAGE_ENROLL then
  --  --赛季未开始
  --  log("LeagueGameLobbyUI.alliance_show_init().ShowWaitingNextStageUI()")
  --  LeagueGameLobbyUI.ShowWaitingNextStageUI()
  --else
  --  --赛季已开始
  --  if LeagueGameSystem.StageId >= EndStage then
  --    --赛季已结束
  --    log("LeagueGameLobbyUI.alliance_show_init().ShowWaitingNextStageUI()")
  --    LeagueGameLobbyUI.ShowWaitingNextStageUI()
  --  else
  --    --赛季未结束
  --    LeagueGameLobbyUI.SetCountDownState()
  --  end
  --end
  --
  --LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "AllianceUIShow")
end

function LeagueGameLobbyUI.ShowWaitingNextStageUI()
  --TODO:添加本地化配置描述
  BP_SeasonDesc = "S2SEASON"
  BP_Season_OverDesc = "CREW S1 season is over"
  BP_Season_WaitingDesc = "Please wait for the start of the "
  LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby,"ShowWaitingNextStageUI")
end

function LeagueGameLobbyUI.Hide()
  LeagueGameLobbyUI.IsShow = false;
  LobbyChatEntranceUI.OnRoomModeChanged();
  LeagueGameLobbyUI.Release();
  LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "UIHide");
end

--设置状态
function LeagueGameLobbyUI.SetSignStateAndShow()
  BP_LeagueGame_SignState = LeagueGameSystem.signUpState;
  log("BP_LeagueGame_SignState.." .. BP_LeagueGame_SignState);
  if LeagueGameSystem.StageId and LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_ENROLL then
    if LeagueGameLobbyUI.IsAllianceUI and LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
      --LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "SetSignUpStageSignState")
    else
      LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "SetSignState");
    end
  end
end

--设置倒计时
function LeagueGameLobbyUI.SetCountDownState()
  local serverTime = FuncUtil.GetServerTimeInSec();
  LeagueGameLobbyUI.countDownTime = -1;
  LeagueGameLobbyUI.TimeToCountDown = 0
  BP_LeagueGame_Countdown = "";

  if LeagueGameSystem.StageId and LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_ENROLL then
    if LeagueGameLobbyUI.IsAllianceUI
            and serverTime < LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ENROLL].end_time then
      --报名阶段
      --log("LeagueGameLobbyUI.SetCountDownState" .. "报名阶段")
      --BP_IS_SIGN_END = false
      --LeagueGameLobbyUI.countDownTime = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ENROLL].end_time - serverTime
      --BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
      --BP_LeagueGame_CountdownDesc = Client.GetTableData("LocalizeRes", "6066").TextValue
      --LeagueGameLobbyUI.SetSignStateAndShow();
      --if BP_LeagueGame_Countdown ~= "" and string.find(BP_LeagueGame_Countdown, ":") ~= nil then
      --  LeagueGameLobbyUI.Release();
      --  LeagueGameLobbyUI.countDownTimer = Timer.InsertTimer(1, LeagueGameLobbyUI.ShowCountDown, true, false);
      --end
      --LeagueGameLobbyUI.SetSignStateAndShow();

    elseif serverTime >= LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_ENROLL].end_time
            and serverTime < LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].begin_time then
      --报名结束 比赛期未开始
      if LeagueGameLobbyUI.IsAllianceUI then
        --战队赛UI
        --log("LeagueGameLobbyUI.SetCountDownState" .. "等待赛季开始")
        --BP_IS_SIGN_END = true
        --LeagueGameLobbyUI.countDownTime = LeagueGameSystem.LeagueDateTable[LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH].begin_time - serverTime
        --BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
        ----TODO:添加本地化配置描述
        --BP_LeagueGame_CountdownDesc = "距离海选赛还有"
        --if BP_LeagueGame_Countdown ~= "" and string.find(BP_LeagueGame_Countdown, ":") ~= nil then
        --  LeagueGameLobbyUI.Release();
        --  LeagueGameLobbyUI.countDownTimer = Timer.InsertTimer(1, LeagueGameLobbyUI.ShowCountDown, true, false);
        --end
      else
        --赛事UI
        --LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowStageEndUI");
      end
      LeagueGameLobbyUI.SetSignStateAndShow();

    elseif serverTime < LeagueGameSystem.begin_time then
      --比赛准备阶段
      log("LeagueGameLobbyUI.SetCountDownState" .. "比赛还未开始")
      LeagueGameLobbyUI.TimeToCountDown = LeagueGameSystem.begin_time
      LeagueGameLobbyUI.countDownTime = LeagueGameLobbyUI.TimeToCountDown - serverTime;
      BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
      BP_LeagueGame_CountdownDesc = Client.GetTableData("LocalizeRes", "6179").TextValue;
      if BP_LeagueGame_Countdown ~= "" and string.find(BP_LeagueGame_Countdown, ":") ~= nil then
        LeagueGameLobbyUI.Release();
        LeagueGameLobbyUI.countDownTimer = Timer.InsertTimer(1, LeagueGameLobbyUI.ShowCountDown, true, false);
      end
      LeagueGameLobbyUI.SetSignStateAndShow();

    elseif serverTime >= LeagueGameSystem.begin_time and serverTime < LeagueGameSystem.end_time then
      --在匹配阶段
      log("LeagueGameLobbyUI.SetCountDownState" .. "在匹配阶段")
      LeagueGameLobbyUI.TimeToCountDown = LeagueGameSystem.end_time
      LeagueGameLobbyUI.countDownTime = LeagueGameLobbyUI.TimeToCountDown - serverTime;
      BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
      BP_LeagueGame_CountdownDesc = Client.GetTableData("LocalizeRes", "6180").TextValue;
      if BP_LeagueGame_Countdown ~= "" and string.find(BP_LeagueGame_Countdown, ":") ~= nil then
        LeagueGameLobbyUI.Release();
        LeagueGameLobbyUI.countDownTimer = Timer.InsertTimer(1, LeagueGameLobbyUI.ShowCountDown, true, false);
      end
      LeagueGameLobbyUI.SetSignStateAndShow();

    elseif LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH <= LeagueGameSystem.StageId
            and LeagueGameSystem.StageId <= LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH
            and LeagueGameSystem.begin_time <= 0 then
      log("LeagueGameLobbyUI.SetCountDownState" .. "比赛期结束阶段")
      --比赛期 比赛结束
      LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowStageEndUI");

    else
      log("LeagueGameLobbyUI.SetCountDownState" .. "未知阶段" .. tostring(serverTime))
    end

    if LeagueGameLobbyUI.countDownTime >= 0 then
      if LeagueGameLobbyUI.IsAllianceUI and LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
        --BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
        --LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowSignUpStageCountDown");
      else
        BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
        LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowCountDown");
      end
    end
  end
end

function LeagueGameLobbyUI.ShowCountDown()
  LeagueGameLobbyUI.countDownTime = LeagueGameLobbyUI.TimeToCountDown - FuncUtil.GetServerTimeInSec();
  if LeagueGameLobbyUI.countDownTime >= 0 then
    if LeagueGameSystem.StageId and LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_ENROLL then
      if LeagueGameLobbyUI.IsAllianceUI and LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_ENROLL then
        --BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
        --LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowSignUpStageCountDown");
      else
        BP_LeagueGame_Countdown = FuncUtil.FormatTimeCountDown2(LeagueGameLobbyUI.countDownTime);
        LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "ShowCountDown");
      end
    end
  else
    LeagueGameLobbyUI.Release();
    LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "HideCountDown");
    LeagueGameSystem.LeagueGameStageReq();
  end
end


function LeagueGameLobbyUI.CheckAndShowNewSeason()
  local hasNewSeason = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_LEAGUE, LeagueGameSystem.LeagueId);
  if hasNewSeason then
    LeagueGameIntroduceUI.Init();
  end
end

function LeagueGameLobbyUI.GetLeagueNextMatchTimeReq()
  LeagueGameSystem.league_next_match_time_req(false);
end

function LeagueGameLobbyUI.OnApplicationReactivated()
end

--关闭
function EventLeagueGameLobbyHideUI()
  LeagueGameLobbyUI.Hide();
end

--赛事介绍
function EventLeagueGameLobbyEnterIntroduce()
  LeagueGameIntroduceUI.Init();
end

--赛程介绍
function EventLeagueGameSchedule()
  --LeagueGameScheduleUI.Init();
  LeagueGameScheduleRuleUI.Init(BP_LeagueGame_Stage, 1);
  ClientSendBAReport(BP_ENUM_LOBBY_MENU_LEAGUEGAME_SCHEDULE, 0);
end

--赛程奖励
function EventLeagueGameForAward()
  LeagueGameTreasureBoxUI.ShowUI();
end

--进入匹配
function EventLeagueGameEnterMatch()
  if BP_LeagueGame_Stage == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
    AllianceCompetitionSystemHandler.participate_competition();
  elseif BP_LeagueGame_Stage == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH or BP_LeagueGame_Stage == LeagueGameSystem.LEAGUE_STAGE_ZONE_FINAL_MATCH then
    AllianceCompetitionSystemHandler.EnterRoomReq();
  end
end

function EventLeagueGameSignUpPop()
  LeagueGameSignUpPopUI.Init()
end

function EventOpenShop()
  AllianceCompetitionShopUI.Show()
  LeagueGameLobbyUI.Hide()
end

function EventEnterBroadcast()
  LobbyLeagueGameEntranceUI.openfrom = 1;
  LobbyLeagueGameEntranceUI.EnterBroadcast()
  ClientSendBAReport(BP_ENUM_LOBBY_MENU_LEAGUEGAME_BROADCASTONLINE, 0);
end

function EventLeagueGameLobbyJumpMallDIY()
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
    ["isFromLeague"] = 1,
    ["itemId"] = itemId,
  };
  --EventLeagueInfoHide();

  LeagueGameLeagueInfoUI.SetInvisible()
  LuaClassObj.HandleUIMessage(bp_lobby, "UIShowFromMall");
  -- LobbyUI:ShowLobbyPlayer(true);

  EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params);

  ClientSendBAReport(BP_ENUM_LOBBY_MENU_LEAGUEGAME_JUMPMALL, 0);
end

--打开海选赛tips
function EventLeagueGameLobbyShowTips()
  LeagueGameTipsUI.Init();
  ClientSendBAReport(BP_ENUM_LOBBY_MENU_LEAGUEGAME_SEAMATCHDETAIL, 0);
end

function EventCalMatchesTime()
  -- 已报名状态下
  -- 在海选赛时显示
  -- 或 在小组赛、总决赛间且已晋级时显示
    --log("EventCalMatchesTime..begin" .. LeagueGameSystem.begin_time);
    --log("EventCalMatchesTime..end" .. LeagueGameSystem.end_time);
  local IsCal = false
  if LeagueGameSystem.signUpState == 1 or LeagueGameSystem.signUpState == 2 then
    if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
      IsCal = true

    elseif LeagueGameSystem.StageId >= LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH
            and LeagueGameSystem.StageId <= LeagueGameSystem.LEAGUE_STAGE_GLOBAL_FINAL_MATCH
            and LeagueGameSystem.Ispromote then
      IsCal = true
    end
  end

  local DateStr = ""
  local TimeStr = ""
    BP_LeagueGame_MatchTimeOne = ""
  if IsCal then
    local Mode = AllianceCompetitionSystem.Mode
    local Zone = AllianceCompetitionSystem.Zone

    local MatchInfo = LeagueGameSystem.LeagueTimeTable[BP_LeagueGame_Stage][Mode][Zone]
    local MatchNum = #MatchInfo.match_time

    local SepCount = 0
    local SepNum = 1
    local MatchDate = {}
    local MatchesTimestamp = MatchInfo.vaild_match_time_slot
    if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_GROUP_MATCH then
      -- 小组赛只显示自己小组的场次
      local BeginTimestamp = MatchesTimestamp[BP_LeagueInfo_SelfGroupId * MatchNum]
      if BeginTimestamp then
        local BeginTime = os.date("*t", BeginTimestamp[1])
        local Str = string.format("%d.%d", BeginTime.month, BeginTime.day)
        table.insert(MatchDate, Str)
      else
        sandbox.LogWarning("小组不存在")
      end
    else
      -- 其他阶段显示所有场次
      for k, v in ipairs(MatchesTimestamp) do
        local BeginTimestamp = v[1]
        local BeginTime = os.date("*t", BeginTimestamp)
        local Str = string.format("%d.%d", BeginTime.month, BeginTime.day)

        -- 计算分隔符和换行符
        if (k - 1) % MatchNum == 0 then
          table.insert(MatchDate, Str)

          if SepCount < SepNum then
            table.insert(MatchDate, "/")
            SepCount = SepCount + 1
          else
            table.insert(MatchDate, "\n")
            SepCount = 0
          end
        end
        if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH then
          if LeagueGameSystem.begin_time == v[1] and LeagueGameSystem.end_time == v[2] then
            BP_LeagueGame_MatchTimeOne = Str;
            --后面日期还有比赛
            if MatchesTimestamp[k+MatchNum] then
              local BeginTimestampNext = MatchesTimestamp[k+MatchNum][1];
              local BeginTimeNext = os.date("*t", BeginTimestampNext)
              local StrNext = string.format("%d.%d", BeginTimeNext.month, BeginTimeNext.day)
              BP_LeagueGame_MatchTimeOne = BP_LeagueGame_MatchTimeOne .. "/" .. StrNext;
            else
              --取前面的日期
              --local BeginTimestampPre = MatchesTimestamp[k-1][1];
              --local BeginTimePre = os.date("*t", BeginTimestampPre)
              --local StrPre = string.format("%d.%d", BeginTimePre.month, BeginTimePre.day)
              --BP_LeagueGame_MatchTimeOne = StrPre;
              --BP_LeagueGame_MatchTimeOne = BP_LeagueGame_MatchTimeOne .. "/" .. Str;
            end
          end
        end
      end
      -- 把最后一个添加的分隔符或换行符删除
      table.remove(MatchDate, #MatchDate)
      --如果没有找到，则默认取前面的2个
      if LeagueGameSystem.StageId == LeagueGameSystem.LEAGUE_STAGE_FIRST_MATCH and BP_LeagueGame_MatchTimeOne == "" then
        local BeginTimestamp = MatchesTimestamp[1][1]
        local BeginTime = os.date("*t", BeginTimestamp)
        local Str = string.format("%d.%d", BeginTime.month, BeginTime.day)
        BP_LeagueGame_MatchTimeOne = Str;
        BeginTimestamp = MatchesTimestamp[2][1];
        BeginTime = os.date("*t", BeginTimestamp)
        Str = string.format("%d.%d", BeginTime.month, BeginTime.day)
        BP_LeagueGame_MatchTimeOne = BP_LeagueGame_MatchTimeOne .. "/" .. Str;
      end
    end

    DateStr = table.concat(MatchDate)

    SepCount = 0
    SepNum = 1
    local MatchTime = {}
    for i = 1, MatchNum do
      local MatchTimestamp = MatchesTimestamp[i]
      local BeginTimestamp = MatchTimestamp[1]
      local BeginTime = os.date("*t", BeginTimestamp)
      local Str = string.format("%02d:%02d", BeginTime.hour, BeginTime.min)
      table.insert(MatchTime, Str)

      -- 计算分隔符和换行符
      if SepCount < SepNum then
        table.insert(MatchTime, " ")
        SepCount = SepCount + 1
      else
        table.insert(MatchTime, "\n")
        SepCount = 0
      end
    end
    -- 把最后一个添加的分隔符或换行符删除
    table.remove(MatchTime, #MatchTime)

    TimeStr = table.concat(MatchTime)
  else
    LuaClassObj.HandleUIMessageNoFetch(bp_leagueGame_lobby, "Init");
  end

  BP_LeagueGame_MatchDate = DateStr
  BP_LeagueGame_MatchTime = TimeStr
  --log("DateStr\n" .. BP_LeagueGame_MatchDate, "martinhtma")
  --log("TimeStr\n" .. BP_LeagueGame_MatchTime, "martinhtma")
end
