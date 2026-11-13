EUGDPRSystem = EUGDPRSystem or {}

--[[
--隐私策略同意状态                  --后台
--_G.EUGDPR_PRIVICY_DEFAULT = 0     --默认，新用户
--_G.EUGDPR_PRIVICY_AGREE = 1       --同意隐私协议和数据传输
--_G.EUGDPR_PRIVICY_REJECT = 2      --不同意隐私策略
--_G.EUGDPR_DATA_TRANS_REJECT = 3   --不同意数据传输

--GDPR用户类型定义                    --后台
--_G.EUGDPR_DEFAULT = 0             --默认，新用户
--_G.EUGDPR_NON_EU = 1              --非欧盟区用户
--_G.EUGDPR_EU_ADULT = 2            --欧盟区用户成人
--_G.EUGDPR_EU_PARENT_WAIT= 3       --欧盟区用户，等待家长同意
--_G.EUGDPR_EU_PARENT_AGREE = 4     --欧盟区用户，家长已经同意游戏
--_G.EUGDPR_EU_PARENT_NOT_AGREE = 5 --欧盟区用户，家长不同意游戏
--_G.EUGDPR_EU_PERSON = 6           --欧盟区用户(不确定年龄)
--_G.EUGDPR_MAX = 7                 --最大用户类型

local CommonSwitch = {
    FirstVoicePopupSwitch = server_game_config.FirstVoicePopupSwitch or false,
    EUGDPRForbidVoice = server_game_config.EUGDPRForbidVoice or false,
    EUGDPRSettingSwitch = server_game_config.EUGDPRSettingSwitch or false,
    
    EUGDPRFunctionSwitch = server_game_config.EUGDPRFunctionSwitch or false,
    EUGDPRDataTranPopupSwitch = server_game_config.EUGDPRAgePopupSwitch or false,
    EUGDPRPrivacyPopupSwitch = server_game_config.EUGDPRAgePopupSwitch or false,
    EUGDPRAgePopupSwitch = server_game_config.EUGDPRAgePopupSwitch or false,
    EUGDPRAgreePopupSwitch = server_game_config.EUGDPRAgreePopupSwitch or false,
    
    EUGDPRDelAccountTime = _G.eugdpr_del_account_time,
    EUGDPRChangeParentAgreeTime = _G.eugdpr_change_parent_agree_time 
};
--]]

function EUGDPRSystem.ReportBtnClick(isNew, btnID)
    log("[HHF]EUGDPRSystem.ReportBtnClick, isnew = " .. tostring(isNew) .. ", btnID = " .. btnID);
    local param = {};
    param.is_new_user = isNew;
    param.tlog_reason = btnID;
    param.tlog_sub_reason = 0;
    NetUtil.SendPkg("eugdpr_report_tlog_req", param);
end

local bDeleteAsync = false -- 是否需要异步处理删号
local bShouldLogoutAfterDelete = false -- 删除账号后是否要退出登录

function EUGDPRSystem.DeleteAccountReq(async, shouldLogout)
    log("[HHF]EUGDPRSystem.DeleteAccountReq "..tostring(async).."  "..tostring(shouldLogout));
    bShouldLogoutAfterDelete = shouldLogout;
    if DataMgr.roleData.eugdpr == nil then
        log("[HHF]EUGDPRSystem.DeleteAccountReq, gdpr is nil")
        return
    end

    if DataMgr.roleData.eugdpr.is_deleting then
        -- 已经在删号过程中，直接退出
        EventCloseAllGDPRUI();
        LoginSystem.sendLogout();
        return
    end

    NetUtil.SendPkg("eugdpr_del_account_req");

    -- 转个菊花，等待回包
    if async then
        ConnectionWaitingUI:Show()
        bDeleteAsync = true
    end
end

function EUGDPRSystem.DeleteKoreaAccountReq(async, shouldLogout)
    log("[HHF]EUGDPRSystem.DeleteKoreaAccountReq "..tostring(async).."  "..tostring(shouldLogout));
    bShouldLogoutAfterDelete = shouldLogout;

    if DataMgr.krjp_del_account_left_time  > 0 then
        -- 已经在删号过程中，直接退出
        LoginSystem.sendLogout();
        return
    end

    NetUtil.SendPkg("krjp_del_account_req");

    -- 转个菊花，等待回包
    if async then
        ConnectionWaitingUI:Show()
        bDeleteAsync = true
    end
end

function EUGDPRSystem.DeleteAccountImmediatelyReq()
    log("[HHF]EUGDPRSystem.DeleteAccountImmediatelyReq");
    NetUtil.SendPkg("eugdpr_direct_del_account_req");
end

function EUGDPRSystem.CancelDeleteAccountReq()
    log("[HHF]EUGDPRSystem.CancelDeleteAccountReq");
    NetUtil.SendPkg("eugdpr_cancel_del_account_req");
end

function EUGDPRSystem.SendStateToServer(state)
    log("[HHF]EUGDPRSystem.SendStateToServer, state = " .. state);
    NetUtil.SendPkg("eugdpr_update_type_req", state);
    if DataMgr.roleData.eugdpr ~= nil then
        DataMgr.roleData.eugdpr.user_type = state;
        Client.SetGDPRUserType(GameFrontendHUD, DataMgr.roleData.eugdpr.user_type);
    end
end

function EUGDPRSystem.SendPrivacyToServer(state)
    log("[HHF]EUGDPRSystem.SendPrivacyToServer, state = " .. state);
    NetUtil.SendPkg("eugdpr_update_policy_req", state);
    if DataMgr.roleData.eugdpr ~= nil then
        DataMgr.roleData.eugdpr.policy_state = state;
    end
end

function EUGDPRSystem.SendKoreaCancelDeleteAccount()
    log("[HHF]EUGDPRSystem.SendKoreaCancelDeleteAccount" );
    NetUtil.SendPkg("krjp_cancel_del_account_req");
    if DataMgr.roleData.eugdpr ~= nil then
        DataMgr.roleData.eugdpr.policy_state = nil;
    end
end

function EUGDPRSystem.eugdpr_update_type_rsp(res)
    log("[HHF]EUGDPRSystem.eugdpr_update_type_rsp, res = " .. res);
    if res ~= "ok" then
        if res == "not open" then
        elseif res == "bad param" then
        elseif res == "not need to update" then
        end
    end
end

function EUGDPRSystem.eugdpr_update_policy_rsp(res)
    log("[HHF]EUGDPRSystem.eugdpr_update_policy_rsp, res = " .. res);
    if res ~= "ok" then
        if res == "not open" then
        elseif res == "bad param" then
        elseif res == "not need to update" then
        end
    end
end

function EUGDPRSystem.eugdpr_del_account_rsp(res)
    log("[HHF]EUGDPRSystem.eugdpr_del_account_rsp, res = " .. res);

    -- 退出到登录，或者弹出返回的错误码提示
    if bDeleteAsync then
        if res == "fail" then
            ShowNotice(4372) -- 删除帐号失败，请稍后再试
        else
            EventCloseAllGDPRUI()

            if bShouldLogoutAfterDelete == true then
                LoginSystem.sendLogout();
            end 
        end

        ConnectionWaitingUI:Hide()
        bDeleteAsync = false
    end
end

function EUGDPRSystem.eugdpr_cancel_del_account_rsp(res)
    log("[HHF]EUGDPRSystem.eugdpr_cancel_del_account_rsp, res = " .. res);
    if res ~= "ok" then
        ShowNotice(4372) -- 删除帐号失败，请稍后再试
    else 
        DataMgr.roleData.eugdpr.is_deleting = false;
    end
end

function EUGDPRSystem.krjp_del_account_rsp(res)
    log("[HHF]EUGDPRSystem.krjp_del_account_rsp, res = " .. res);

    -- 退出到登录，或者弹出返回的错误码提示
    if bDeleteAsync then
        if res == "fail" then
            ShowNotice(4372) -- 删除帐号失败，请稍后再试
        else
            if bShouldLogoutAfterDelete == true then
                LoginSystem.sendLogout();
            end 
        end

        ConnectionWaitingUI:Hide()
        bDeleteAsync = false
    end
end

function EUGDPRSystem.krjp_cancel_del_account_rsp(res)
    log("[HHF]EUGDPRSystem.krjp_cancel_del_account_rsp, res = " .. res);
    --重置删除时间
    DataMgr.krjp_del_account_left_time = 0;
    BP_krjp_del_account_time = 0;
end

function EUGDPRSystem.eugdpr_direct_del_account_rsp(res)
    log("[HHF]EUGDPRSystem.eugdpr_direct_del_account_rsp, res = " .. res);
    if res ~= "ok" then
    end
end

function EUGDPRSystem.eugdpr_notify(res)
    if res == "delete account relogin" then
        log("[HHF]EUGDPRSystem.eugdpr_notify, res = delete account relogin, and ReConnect");
        EventConnectToGate();
    elseif res == "delete account direct" then
        LoginSystem.sendLogout();
    else
        log("[HHF]EUGDPRSystem.eugdpr_notify, res = " .. res);
    end
end

s2c["eugdpr_update_type_rsp"] = EUGDPRSystem.eugdpr_update_type_rsp;
s2c["eugdpr_update_policy_rsp"] = EUGDPRSystem.eugdpr_update_policy_rsp;
s2c["eugdpr_del_account_rsp"] = EUGDPRSystem.eugdpr_del_account_rsp;
s2c["krjp_del_account_rsp"] = EUGDPRSystem.krjp_del_account_rsp;
s2c["eugdpr_cancel_del_account_rsp"] = EUGDPRSystem.eugdpr_cancel_del_account_rsp;
s2c["krjp_cancel_del_account_rsp"] = EUGDPRSystem.krjp_cancel_del_account_rsp;
s2c["eugdpr_notify"] = EUGDPRSystem.eugdpr_notify;
s2c["eugdpr_direct_del_account_rsp"] = EUGDPRSystem.eugdpr_direct_del_account_rsp;

--[[ 
tlog 按钮上报ID
首次弹窗  10
地区继续  11 12 13
年月继续  14 15 16
未成成年  17 18

数据传输  211 212
删号返回  221 222
确定删除  231 232
退出返回  241 242
新手退返  251 252
删号退返  261 262

隐私政策  311 312
删号返回  321 322
确定删除  331 332
退出返回  341 342
新手退返  351 352
删号退返  361 362

家长许可  411 412
删号退返  421 422
新老退出  431 432

退出返回  511 512
--]]