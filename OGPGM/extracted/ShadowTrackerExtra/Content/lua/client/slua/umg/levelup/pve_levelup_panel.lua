local UI_PveLevelup ={}

function UI_PveLevelup:ctor(selfType, new)
    --todo: 这里可以做些数据初始化工作
    self.oldLevel = LevelUpSystem.PveOldLevel;
    self.newLevel = new;
    log("PveLevelup newLevel" .. tostring(new) .. ",oldLevel:" .. tostring(self.oldLevel));
end

function UI_PveLevelup:OnInitialize()
    UI_PveLevelup.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
end

function UI_PveLevelup:RegistEvents()
    UI_PveLevelup.__super.RegistEvents(self)
    self:AddOnClickedEvent("Button_OK", UI_PveLevelup.Button_OK, self);

    --todo: 在这里注册事件
end

function UI_PveLevelup:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_PveLevelup.__super.UnRegistEvents(self)
end

function UI_PveLevelup:Button_OK()
    local sound = require("client.slua.config.sound")
    self:PlayAudio(sound.confirm)

    LevelUpSystem.ClosePveLevelupPanel()
end

function UI_PveLevelup:OnPostInitialize()
    UI_PveLevelup.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:InitUI()

    self.UIRoot:PlayAnimation( self.UIRoot["NewAnimation_anim"], 0, 1, 0, 1)
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_PveLevelup:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_PveLevelup.__super.Close(self)
end

function UI_PveLevelup:InitUI()
    self.UIRoot["TextBlock_1"]:SetText("Lv." ..  tostring(LevelUpSystem.PveOldLevel))
    self.UIRoot["TextBlock_2"]:SetText("Lv." ..  tostring(DataMgr.roleData.pve_level))
    self.UIRoot["Text_Title"]:SetText(FuncUtil.GetLocalizeResStr(6884))
end




local class = require("class")
local ui_base = require("ui.base")
local CUI_PveLevelup = class(ui_base, nil, UI_PveLevelup)

return CUI_PveLevelup