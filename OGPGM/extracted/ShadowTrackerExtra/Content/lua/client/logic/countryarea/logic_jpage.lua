JPAgeSystem = JPAgeSystem or {}

function JPAgeSystem.jp_set_birthtime_req(birth_year, birth_month)
    log("[HHF]JPAgeSystem.SendJPBirthToServer, birth_year = " .. birth_year .. ", birth_month = " .. birth_month);
    NetUtil.SendPkg("jp_set_birthtime_req", birth_year, birth_month);
end

function JPAgeSystem.jp_set_birthtime_rsp(res, age)
    log("[HHF]JPAgeSystem.jp_set_birthtime_rsp")
    if res == nil then 
        DataMgr.ShowNoticeByID("4332") 
        return
    end
    
    log("[HHF]JPAgeSystem.jp_set_birthtime_rsp, res="..res);

    if res == "ok" then
        if age ~= nil and type(age) == "number" then
            log("[HHF]JPAgeSystem.jp_set_birthtime_rsp, age=" .. tostring(age));
            DataMgr.jp_age = age;
            DataMgr.ShowNoticeByID("4331");

            LuaClassObj.HandleUIMessage(bp_jpage_panel, "CloseUI");
        else
            DataMgr.ShowNoticeByID("4332");
        end
    elseif res == "not-jpkr-version" then
        DataMgr.ShowNoticeByID("4333");
    elseif res == "birth-time-nil" then
        DataMgr.ShowNoticeByID("4334");
    elseif res == "birth-time-is-set" then
        DataMgr.ShowNoticeByID("4336");
    elseif res == "birth-time-illegal" then    
        DataMgr.ShowNoticeByID("4335");  
    end
end

s2c["jp_set_birthtime_rsp"] = JPAgeSystem.jp_set_birthtime_rsp;
