local UI_Levelup ={}

function UI_Levelup:ctor(selfType, new)
    --todo: 这里可以做些数据初始化工作
    self.oldLevel = LevelUpSystem.OldLevel;
    self.newLevel = new;
    log("CurrentLevel" .. new);
end

function UI_Levelup:OnInitialize()
    UI_Levelup.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
end

function UI_Levelup:RegistEvents()
    UI_Levelup.__super.RegistEvents(self)
    self:AddOnClickedEvent("Continue", self.OnClickClose, self);

    self:AddOnClickedEvent("Button_Show", self.OnClickShare, self);

    self:AddCommonEvent(EVENTTYPE_SHARE, EVENTID_UPDATE_LEVELUPUI, self.SetShareButton, self);
    --todo: 在这里注册事件
end

function UI_Levelup:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_Levelup.__super.UnRegistEvents(self)
end

function UI_Levelup:OnPostInitialize()
    UI_Levelup.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
    self:InitUI();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_Levelup:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_Levelup.__super.Close(self)
end

function UI_Levelup:InitUI()
    self:SetOldLevelUI();
    self:SetNewLevelUI();
    self:SetShareButton();
    self:AutoClick();
    self:PlayRankUpAudio();
    self.UIRoot:PlayAnimation(self.UIRoot.DX_LeveUp, 0, 1, 0, 1);
end

function UI_Levelup:SetOldLevelUI()
    local config = Client.GetTableData("MilitaryRankLevel", self.oldLevel);
    if config == nil then
        log("config is nil, oldLevel is :" .. self.oldLevel);
        return;
    end
    log_tree("old level config : ", config);
    local BusinessHelper = import("BusinessHelper");
    local bg = BusinessHelper.UIGetResWithPath(config.MilitaryRankTypeIconPath);
    local fg = BusinessHelper.UIGetResWithPath(config.MilitaryRankBigIconPath);
    self.UIRoot.LRankBgImage:SetBrushFromTexture(bg, false);
    self.UIRoot.L_Level:SetBrushFromTexture(fg, false);
    self.UIRoot.RankNameText_L:SetText(config.MilitaryRankName);
end

function UI_Levelup:SetNewLevelUI()
    local config = Client.GetTableData("MilitaryRankLevel", self.newLevel);
    if config == nil then
        log("config is nil, newLevel is :" .. self.newLevel);
        return;
    end
    log_tree("new level config : ", config);
    local BusinessHelper = import("BusinessHelper");
    local bg = BusinessHelper.UIGetResWithPath(config.MilitaryRankTypeIconPath);
    local fg = BusinessHelper.UIGetResWithPath(config.MilitaryRankBigIconPath);
    self.UIRoot.RRankBgImage:SetBrushFromTexture(bg, false);
    self.UIRoot.RRankFgImage:SetBrushFromTexture(fg, false);
    self.UIRoot.RankNameText_R:SetText(config.MilitaryRankName);
end

function UI_Levelup:SetShareButton()
    if BP_IOS_CHECK == true then
        self.UIRoot.CanvasShow:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        self.UIRoot.Text_tips:SetVisibility(UEnums.ESlateVisibility.Collapsed);
        self.UIRoot.TipsGroup:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    else
        self.UIRoot.CanvasShow:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
        self.UIRoot.TipsGroup:SetVisibility(UEnums.ESlateVisibility.Collapsed);
    end
end

function UI_Levelup:AutoClick()
    local script = import("STExtraGameInstance");
    print("STExtraGameTestGame", script);
    if script.IsAutoRunTestGame() == true then
        Timer.InsertTimer(0.5, function ()
            LevelUpSystem.CloseLevelupPanel();
        end, false, false);
    else
        print("no auto");
    end
end

function UI_Levelup:OnClickClose()
    self:PlayAudio(require("client.slua.config.sound").close);
    LevelUpSystem.CloseLevelupPanel();
end

function UI_Levelup:OnClickShare()
    self:PlayAudio(require("client.slua.config.sound").click);
    ShareLevelUpUI.ShowSharePanel();
end

function UI_Levelup:PlayRankUpAudio()
    self.UIRoot:PlayAudio();
end

local class = require("class")
local ui_base = require("ui.base")
local CUILevelup = class(ui_base, nil, UI_Levelup)

return CUILevelup