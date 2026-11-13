NationSystem = NationSystem or {}

function NationSystem.on_modify_nation_res(msg, param)
    RoleInfoSystem.PersonalBasicInfo.role_nation = param;
    log("NationSystem.on_modify_nation_res,msg " .. msg)
    log("NationSystem.on_modify_nation_res,BP_NATION_USE_FLAG_ITEM " .. tostring(BP_NATION_USE_FLAG_ITEM))
    if msg == "ok" then
        RoleInfoUI.UpdateRoleInfoNation(param);
        log("UpdateRoleNationInfo"..tostring(RoleInfoUI.IsShow))
        if RoleInfoUI.IsShow then
            log("BP_STRUCT_PersonalBasicInfo.role_nation"..BP_STRUCT_PersonalBasicInfo.role_nation)
            LuaClassObj.HandleUIMessage(bp_roleinfo, "UpdateRoleNationInfo");
            LuaClassObj.HandleUIMessage(bp_countryarea, "UIShow2");

            local CurrPage = GetRoleInfoPageByIndex(BP_CurrRoleInfoPageIndex)

            if CurrPage and CurrPage.UpdateRoleNationInfo then
                CurrPage.UpdateRoleNationInfo()
            end
        end
        DataMgr.last_modify_nation_time = FuncUtil.GetServerTimeInSec();
        log("NationSystem.on_modify_nation_res:"..tostring(BP_NATION_USE_FLAG_ITEM).."  "..tostring(DataMgr.last_modify_nation_time))
        if BP_NATION_USE_FLAG_ITEM then
            DataMgr.last_modify_nation_item_time = FuncUtil.GetServerTimeInSec();
            RoleInfoShowInfoUI.Hide();
        else
            --if not WardrobeUI.isShowing then
                --EventEnterRoleInfo();
            --end
        end
        -- dirty method to update role information
        --LuaClassObj.HandleUIMessage(bp_roleinfo, "UIHide");
        DataMgr.ShowNoticeByString(Client.GetTableData("LocalizeRes", 301192).TextValue);
        --LuaClassObj.HandleUIMessage(bp_roleinfo, "UIHide");
    elseif msg == "cd" then
        text = Client.GetTableData("LocalizeRes", 4359).TextValue  -- "修改失败，您需要等待%s天才能修改地区旗帜"
        --text = Client.GetTableData("LocalizeRes", 4042).TextValue; --"您需要等待60天才能修改地区旗（剩余%s）";
        cd = Client.GetTableData("IntlSystemConfig", "NationModifyCd").ConfigValue;
        leftDay = math.ceil((cd - (FuncUtil.GetServerTimeInSec() - param)) / 3600 / 24);
        content = string.format(text, leftDay);
        textPG = Client.GetTableData("LocalizeRes", "110036").TextValue;

        DataMgr.ShowNoticeByString(content);
        --CommonMessageBoxUI:ShowPanel(1, "", content, nil, nil ,textPG, nil);
    end
    BP_NATION_USE_FLAG_ITEM = false;  -- 重置旗帜卡使用状态
    CountryareaUI.SetNeedUseFlagItem(false);
end

s2c["modify_nation_res"] = NationSystem.on_modify_nation_res;

