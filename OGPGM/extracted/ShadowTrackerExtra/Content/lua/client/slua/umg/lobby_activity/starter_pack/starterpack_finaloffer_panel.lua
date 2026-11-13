local UI_StarterPack_FinalOffer ={}

function UI_StarterPack_FinalOffer:ctor()
    --todo: 这里可以做些数据初始化工作    
end

function UI_StarterPack_FinalOffer:OnInitialize()
    UI_StarterPack_FinalOffer.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
    bInitialized = false;
    sPrice = "";
	self.sRewardUC = "";
	log("#ZK UI_StarterPack_FinalOffer:OnInitialize");
end

function UI_StarterPack_FinalOffer:RegistEvents()
    UI_StarterPack_FinalOffer.__super.RegistEvents(self)
	self:AddOnClickedEvent("Button_buy", UI_StarterPack_FinalOffer.DirectPurchase, self);	
    self:AddOnClickedEvent("Button_fullscreen", UI_StarterPack_FinalOffer.DirectPurchase, self);

    self:AddOnClickedEvent("Button_CloseUI", UI_StarterPack_FinalOffer.CloseUI, self);

    --self:AddCommonEvent(EVENTTYPE_SHARE, EVENTID_UPDATE_LEVELUPUI, self.SetShareButton, self);
    self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_INFO_UPDATED, self.OnGetProductDesc, self);
    self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_PRICE_UPDATED, self.OnGetProductPrice, self);
    self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_TIME_LIMIT_UPDATED, self.UpdateUIPurchase, self);
    self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED, self.OnStarterPackIsOpenChanged, self);    
    --todo: 在这里注册事件
end



function UI_StarterPack_FinalOffer:OpenCheckMessageBox(callback, title, content)
	local ui_manager = require("ui.manager");
	if ui_manager then
		local ui = ui_manager.ShowUI(ui_manager.UI_Config.starterPack_messageBox, callback, title, content,"No Thanks","Get");
	end
end


function UI_StarterPack_FinalOffer:FinalCloseUI()
	log("#ZK UI_StarterPack_FinalOffer:FinalCloseUI");
	local ui_manager = require("ui.manager");
	if ui_manager then
		ui_manager.CloseUI(ui_manager.UI_Config.starterpack_finaloffer_panel)
	end
	if StarterPackSystem.CloseFinaUICB ~= nil then
		StarterPackSystem.CloseFinaUICB();
		StarterPackSystem.CloseFinaUICB = nil;
	end
	StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.FINAL_POPWINDOW,false);
	StarterPackSystem.EndPurchase();
	StarterPackSystem.Enabled = false;
end

function UI_StarterPack_FinalOffer:ReopenUI()
		log("#ZK UI_StarterPack_FinalOffer:ReopenUI");
		--[[
		local ui_manager = require("ui.manager");
    if ui_manager then
        ui_manager.ShowUI(ui_manager.UI_Config.starterpack_finaloffer_panel, new);
    end
    ]]
end
function UI_StarterPack_FinalOffer:CloseUI()
	log("UI_StarterPack_FinalOffer:CloseUI")
	local title = "Final Offer";
	local msg = "This is your final chance to purchase the Starter Pack. Are you sure?";
	--CommonMessageBoxUI:ShowPanel(2,title , msg, UI_StarterPack_FinalOffer:FinalCloseUI(), UI_StarterPack_FinalOffer:ReopenUI(),"Don't Purchase","Go Back",false,nil,false);	
	--CommonMessageBoxUI:ShowPanel(2,title , msg, UI_StarterPack_FinalOffer:FinalCloseUI);
	--UI_StarterPack_FinalOffer.OpenCheckMessageBox(self.FinalCloseUI,title,msg);
		UI_StarterPack_FinalOffer:OpenCheckMessageBox(self.FinalCloseUI,title,msg);
	--UI_StarterPack_FinalOffer:FinalCloseUI()
end
function UI_StarterPack_FinalOffer:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_StarterPack_FinalOffer.__super.UnRegistEvents(self)    
end

function UI_StarterPack_FinalOffer:OnPostInitialize()
    UI_StarterPack_FinalOffer.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里	
	if StarterPackSystem.bForceUpdate then
		log("#ZK UI_StarterPack_FinalOffer:OnPostInitialize");
		StarterPackSystem.UpdateDateFromServer();
	end

	self:InitUI();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]

function UI_StarterPack_FinalOffer:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_StarterPack_FinalOffer.__super.Close(self)
end

function UI_StarterPack_FinalOffer:OnStarterPackIsOpenChanged()	
	local bStarterPackValid = StarterPackSystem.IsOpen();
	log("ZK at final offer event trigger OnStarterPackIsOpenChanged ".. tostring(bStarterPackValid));
    if bStarterPackValid == false then
		self:FinalCloseUI();
		log("ZK at final offer event trigger OnStarterPackIsOpenChanged finall close UI");
	end
end

function UI_StarterPack_FinalOffer:UpdateUIPurchase()
	if self.sPrice == nil or self.sPrice == "" then
		self.sPrice = StarterPackSystem.GetPriceDesc();
		self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	end
	if self.sRewardUC == nil or self.sRewardUC == "" then
		self.sRewardUC = StarterPackSystem.GetUCRewardsDesc();
		self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
	end	
end

function UI_StarterPack_FinalOffer:OnGetProductPrice()
	self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
end


function UI_StarterPack_FinalOffer:OnGetProductDesc()
	self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
end

function UI_StarterPack_FinalOffer:ProcessProductRewardInfo(desc)
	log("set UC desc" .. desc);
	self.UIRoot.UC:SetText(desc);
end


function UI_StarterPack_FinalOffer:ProcessProductDesc(desc)
	log("set  price desc" .. desc);
	self.UIRoot.TextPrice:SetText(desc);
end

 
function UI_StarterPack_FinalOffer:InitUI()   

		
	self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
	
	self.bInitialized = true;
end

function UI_StarterPack_FinalOffer:DirectPurchase()
	--log("Click DirectPurchase on Final offer dialog")
	if StarterPackSystem.iStarterPackDirectPurchaseId > 0 then
		--self.CloseUI();
		StarterPackSystem.StartDirectPurchase();
	end
end


function UI_StarterPack_FinalOffer:PlayAudio()
    self.UIRoot:PlayAudio();
end

local class = require("class")
local ui_base = require("ui.base")
local CUI_StarterPack_FinalOffer = class(ui_base, nil, UI_StarterPack_FinalOffer)

return CUI_StarterPack_FinalOffer