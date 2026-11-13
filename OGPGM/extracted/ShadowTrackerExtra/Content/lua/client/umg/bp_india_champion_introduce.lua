-- 新赛季开场UI
IndiaCompetitionIntroduceUI = IndiaCompetitionIntroduceUI or {
    
}

BP_IndiaCompetition_IntroduceUI_PageCount = 5;

--注册Widget
function bp_india_champion_introduce_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_india_champion_introduce,
            {{Path="/Game/UMG/UI_Logic/ChampionshipIndia/ChampionIndia_Introduce_LogicBp.ChampionIndia_Introduce_LogicBp_C", Container="Default", ZOrder=16}},
            {"Lobby"},
            false,
            false,
            true
    );
end

function IndiaCompetitionIntroduceUI.Show()
    log("UnknowPassIntroduceUI.Init")
    LuaClassObj.HandleDynamicCreation(bp_india_champion_introduce);
    LuaClassObj.HandleUIMessage(bp_india_champion_introduce, "UIShow");
    UIManager.Show(eUIType.eIndiaChampionShipIntroduce);
end

-- 隐藏
function IndiaCompetitionIntroduceUI.Hide()
    LuaClassObj.HandleUIMessageNoFetch(bp_india_champion_introduce, "UIHide");
end

-- 展示按钮点击展示
function IndiaCompetitionIntroduceUI.ShowByClick()
    IndiaCompetitionIntroduceUI.Show();
end

--判断弹出指引动画
function IndiaCompetitionIntroduceUI.CheckAndShow()
    local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Introduce)
    if newbieGuide then
        IndiaCompetitionIntroduceUI.Show()
    end
end

-- 结束引导,暂时先不发协议，直接显示空物品
function EventIndiaChampionIntroduceFinished()
    local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Introduce)
    if newbieGuide then
        IndiaChampionShipLogic.get_tournament_newbie_award_req();
    else
        IndiaCompetitionIntroduceUI.Hide()
    end
end

function IndiaCompetitionIntroduceUI.OnGetNewbieAwards(arrayItemData)
    local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, 1)
    if newbieGuide then
        DataMgr.SetNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, 1)
        
        -- 后台发来的协议数据使用resid,为了对齐通用数据，额外使用res_id
        for k,v in pairs(arrayItemData) do
            if v and v.resid then
                v.res_id = v.resid
            end
        end
        CommonItemGetUI:ShowPanel(arrayItemData)
        IndiaChampionShipLogic.get_tournament_score_req()
    end
    IndiaCompetitionIntroduceUI.Hide();
end

--刷新赛事入口红点
function IndiaCompetitionIntroduceUI.UpdateRedPoint()    
    if not IndiaChampionShipLogic.LockEnter then
        -- 新手引导显示红点
        local newbieGuide = DataMgr.HaveNewbieGuide(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP, Newbie_Guide_India_Championship_Introduce)
        if newbieGuide then
            IndiaChampionShipLogic.isNeedRedPoint = true;
            LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true);	-- 大厅的ui红点
            return;
        end
        
        -- 有比赛显示红点
        local timeData = DataMgr.GetNewbieGuideValue(DataMgr.NEWBIE_GUIDE_MODULE_ID_INDIA_CHAMPIONSHIP,Newbie_Guide_India_Championship_Tournament_New);
        if timeData then
            local nowData = math.floor(FuncUtil.GetServerTimeInSec() / 86400);
            if nowData - timeData > 0 then
                IndiaChampionShipLogic.isNeedRedPoint = true;
                LobbyUI:LobbyRedPointUpdate(BP_ENUM_LOBBY_MENU_BROADCAST, true);	-- 大厅的ui红点
            end
        end
    end
end