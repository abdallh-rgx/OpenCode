-- 副本buff前缀词汇弹窗
TeamUpMapTipsUI = TeamUpMapTipsUI or {}

-- 副本额外技能
BP_STRUCT_TeamUpMapTipsInfo =
{
    icon_path = "",	-- icon贴图
    name = "",		-- 技能名称
    content = ""	-- 描述内容
}

BP_ARRAY_TeamUpMap_TipsInfoList =
{
    BP_STRUCT_TeamUpMapTipsInfo = _G.BP_STRUCT_TeamUpMapTipsInfo,
}

--手动输入状态下，输入点击位置或者按钮位置，panel再计算摆放
BP_STRUCT_TeamUpMap_Pos = { x = 0,y = 0}

--说明
BP_TeamUpMapTips_Introduce = "";

-- 注册面板
function bp_teamup_map_tips_RegisterUI()
    log("CommonItemTipsUI:bp_common_itemtips_panel_RegisterUI");
    LuaClassObj.SubUIWidgetList(bp_teamup_map_tips,
            {{Path="/Game/UMG/UI_Logic/Common/TeamUp_Map_Tips_Logic_BP.TeamUp_Map_Tips_Logic_BP_C", Container="Default", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER}},
            {"Lobby"},
            false,
            false
    );
end

function TeamUpMapTipsUI.ShowPanel(mapId, pos)
    TeamUpMapTipsUI.GetMapSkillInfoData(mapId);
    BP_STRUCT_TeamUpMap_Pos = pos
    LuaClassObj.HandleDynamicCreation(bp_teamup_map_tips);
    LuaClassObj.HandleUIMessage(bp_teamup_map_tips, "UIShow");
    UIManager.Show(eUIType.eTeamupMapTips);
end

function TeamUpMapTipsUI.GetMapSkillInfoData(group_id)
    BP_ARRAY_TeamUpMap_TipsInfoList = {};
    local cur =  TeamUpMatchInfoUI.GetCurrentModelInfo()
    for k,group in pairs(TeamUpSystem.ModeInfoList) do
        if cur.model_id == k then
            for id, mode in pairs(group.mode_group) do
                if id == group_id and mode.skills and #mode.skills > 0 then
                    local infoConfig = Client.GetTableData("ModeTeamTable", id);
                    if infoConfig.Introduce ~= "" then
                        BP_TeamUpMapTips_Introduce = DataMgr.GetMsgByID(tonumber(infoConfig.mapTips));
                    end
                    local mapSkillInfo = {};
                    local mapInfo = {};
                    for index,skillId in pairs(mode.skills) do
                        local skillInfo = Client.GetTableData("MapSkillInfo", skillId);
                        if skillInfo then
                            local skills = {};
                            skills.icon_path = skillInfo.icon;
                            skills.name = skillInfo.name;
                            skills.content = skillInfo.content;

                            table.insert(BP_ARRAY_TeamUpMap_TipsInfoList, skills);
                            mapInfo[tostring(skillId)] = 1;
                            mapInfo["count"] = #mode.skills;
                        end
                    end
                    mapSkillInfo[tostring(id)] = mapInfo;
                    TeamUpSystem.mapSkillInfo = mapSkillInfo;
                    if nil ~= TeamUpSystem.mapSkillInfo then
                        local PlayerPrefs = require("client.tools.playerprefs")
                        PlayerPrefs.SavePlayerPrefs(mapSkillInfo,PlayerPrefs.ePlayerPrefsType.eMapSkill);
                    end
                end
            end
            break;
        end        
    end
    --log_tree("BP_ARRAY_TeamUpMap_TipsInfoList",BP_ARRAY_TeamUpMap_TipsInfoList)
end

function TeamUpMapTipsUI.ClosePanel()
    LuaClassObj.HandleUIMessageNoFetch(bp_teamup_map_tips, "UIHide")
    UIManager.Hide(eUIType.eTeamupMapTips);
end
