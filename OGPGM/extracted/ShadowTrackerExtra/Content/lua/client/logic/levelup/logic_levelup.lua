LevelUpSystem = LevelUpSystem or 
{
    IsLevelUp = false;  --是否是等级提升
    IsIOSCheck = false; --是否是IOS提审
    OldLevel = 1; -- 之前的等级

    IsPveLevelUp = false, --PVE等级提升
    PveOldLevel = 1,
};

function LevelUpSystem.OpenLevelupPanel(new)
    if not LevelUpSystem.IsLevelUp then
        return;
    end
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.levelup_panel, new);
        LevelUpSystem.IsLevelUp = false;
    end
end

function LevelUpSystem.OnClickRankContinue()
    local ui_manager = require("ui.manager");
    if ui_manager then
        if LevelUpSystem.IsLevelUp then
            ui_manager.ShowUI(ui_manager.UI_Config.levelup_panel, DataMgr.roleData.level);
            LevelUpSystem.IsLevelUp = false;
        else
            LevelUpSystem.CloseLevelupPanel();
        end
    end
end

function LevelUpSystem.CloseLevelupPanel()
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.levelup_panel);
    end
end


function LevelUpSystem.OpenPveLevelupPanel(new)
    if not LevelUpSystem.IsPveLevelUp then
        return;
    end
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.pve_levelup_panel, new);
        LevelUpSystem.IsPveLevelUp = false;
    end
end

function LevelUpSystem.ClosePveLevelupPanel()
    local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.CloseUI(ui_manager.UI_Config.pve_levelup_panel);
    end
end



function LevelUpSystem.OnGameStateChange(eventType, eventID, vars)
    log("LevelUpSystem.OnGameStateChange");
    log_tree("LevelUpSystem.OnGameStateChange", vars);
    if vars.current == GameStatus.Lobby then
        --LevelUpSystem.OpenLevelupPanel(DataMgr.roleData.level);

        LevelUpSystem.OpenPveLevelupPanel(DataMgr.roleData.pve_level);
    end
end

require("client.common.event.event_system")
EventSystem:registEvent(EVENTTYPE_STATE, EVENTID_ONGAMESTATECHANGE, LevelUpSystem.OnGameStateChange);