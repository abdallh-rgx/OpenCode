UnknowPassLevelUp = UnknowPassLevelUp or
{
    isShowing = false,

    -- 当界面隐藏时，会调用这个回调函数
    HideCallBack = nil,
}

-- 购买通行证之前的等级
BP_UnknowPass_LevelUp_BeforeLevel = 0;

-- 购买通行证之后的等级
BP_UnknowPass_LevelUp_CurLevel = 0;

-- 升级界面是否显示精英通行证
BP_UnknowPass_LevelUp_IsElitePass = false;
BP_UnknowPass_LevelUp_Can_Play_Animation = true



function bp_unknow_pass_levelup_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_unknow_pass_levelup,
    {
        {Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_LevelUp_Logic_BP.UnknowPass_LevelUp_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}
    },
    {"Lobby"},
    false,
    bp_unknow_pass_levelup_OnModeSwitched ~= nil,
    true);

    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_BUY_PASS, UnknowPassLevelUp.OnBuyPass);
    EventSystem:registEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_ADD_SCORE_NOTIFY, UnknowPassLevelUp.OnAddScore);
    EventSystem:registEvent(EVENTTYPE_SHOP, EVENTID_SHOP_BUY_AGAIN_CLICK, UnknowPassLevelUp.OnShopBuyAgain);
end

function UnknowPassLevelUp.ShowUnlock()
    UnknowPassLevelUp.isShowing = true;
	BP_UnknowPass_LevelUp_Can_Play_Animation = BP_UnknowPass_Can_Play_Animation
	
    LuaClassObj.HandleDynamicCreation(bp_unknow_pass_levelup);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_levelup, "UIShowUnlock");
end

function UnknowPassLevelUp.ShowLevelUp()
    UnknowPassLevelUp.isShowing = true;
	BP_UnknowPass_LevelUp_Can_Play_Animation = BP_UnknowPass_Can_Play_Animation

    BP_UnknowPass_LevelUp_CurLevel = UnknowPassSystem.Level;
    BP_UnknowPass_LevelUp_BeforeLevel = UnknowPassSystem.BuyBeforeLevel;
    BP_UnknowPass_LevelUp_IsElitePass = UnknowPassSystem.IsBuyElite;

    LuaClassObj.HandleDynamicCreation(bp_unknow_pass_levelup);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_levelup, "UIShowLevelUp");
end

function UnknowPassLevelUp.HideUI()
    UnknowPassLevelUp.isShowing = false;
    UIManager.Hide(eUIType.eUnknowPassLevelUpUI);
    LuaClassObj.HandleUIMessage(bp_unknow_pass_levelup, "UIHide");
    if UnknowPassLevelUp.HideCallBack then
        UnknowPassLevelUp.HideCallBack();
        UnknowPassLevelUp.HideCallBack = nil;
    end
end

function EventUnknowPassCloseUnlockClick_Push()
    if UnknowPassSystem.Level > UnknowPassSystem.BuyBeforeLevel then
        UnknowPassLevelUp.ShowLevelUp();
    else
        UnknowPassLevelUp.HideUI();
    end
end

function EventUnknowPassCloseLevelUpClick_Push()
    UnknowPassLevelUp.HideUI();
end

function UnknowPassLevelUp.OnBuyPass(evenType, eventID, reward_list)
    if reward_list and #reward_list > 0 then
        UnknowPassLevelUp.HideCallBack = function()
            UnknowPassShowAward.ShowUI(UnknowPassSystem:GetAwardList(reward_list));
        end
    end

    UnknowPassLevelUp.ShowUnlock();
end

function UnknowPassLevelUp.OnAddScore(evenType, eventID, reason)
    for i,v in ipairs(UnknowPassNeedShowLevelUpReasonList) do
        if reason == v then
            if UnknowPassSystem.Level > UnknowPassSystem.BuyBeforeLevel then
                UnknowPassLevelUp.ShowLevelUp();
            end
            break;
        end
    end
end

function UnknowPassLevelUp.OnShopBuyAgain()
    if (UnknowPassLevelUp.isShowing) then
        UnknowPassLevelUp.HideUI();
    end
end


function EventUnknowPassLevelUp_Show()
    UIManager.Show(eUIType.eUnknowPassLevelUpUI)
end

