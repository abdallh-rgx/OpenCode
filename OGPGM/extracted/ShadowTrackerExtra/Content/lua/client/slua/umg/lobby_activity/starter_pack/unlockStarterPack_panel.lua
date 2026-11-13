local UI_UnlockStarterPack ={}
--local KismetTextLibrary = import("KismetTextLibrary");

function UI_UnlockStarterPack:ctor()
    --todo: 这里可以做些数据初始化工作
    
end

function UI_UnlockStarterPack:OnInitialize()
    UI_UnlockStarterPack.__super.OnInitialize(self)

    --todo: 在这里做些初始化工作
    self.bInitialized = false;    
    self.sPrice = "";
	self.sRewardUC = "";
	log("#ZK UI_UnlockStarterPack local save data for final")
end

function UI_UnlockStarterPack:RegistEvents()
    UI_UnlockStarterPack.__super.RegistEvents(self)
    
    
    self:AddOnClickedEvent("Button_CloseUI", UI_UnlockStarterPack.CloseUI, self);
    self:AddOnClickedEvent("Button_buy", UI_UnlockStarterPack.PurchaseStarterPack, self);
    self:AddOnClickedEvent("Button_fullscreen", UI_UnlockStarterPack.PurchaseStarterPack, self);

    --self:AddCommonEvent(EVENTTYPE_SHARE, EVENTID_UPDATE_LEVELUPUI, self.SetShareButton, self);
    --todo: 在这里注册事件
  	
  	self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_INFO_UPDATED, self.OnGetProductDesc, self);
  	self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_PRICE_UPDATED, self.OnGetProductPrice, self);
  	self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_TIME_LIMIT_UPDATED, self.UpdateUICountDown, self);
  	self:AddCommonEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED, self.OnStarterPackIsOpenChanged, self);    
end

function UI_UnlockStarterPack:CloseUI()
	local ui_manager = require("ui.manager");
  if ui_manager then
      ui_manager.CloseUI(ui_manager.UI_Config.starterpack_unlock_panel);
  end
  log("#ZK UI_UnlockStarterPack:CloseUI")
  --clear current saved show up counter
  log("#ZK clean local save data for final")
  StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData(0);
end

function UI_UnlockStarterPack:OnStarterPackIsOpenChanged()
	local bStarterPackValid = StarterPackSystem.IsOpen();
    if bStarterPackValid == false then    
    	self:CloseUI();
		end
end

function UI_UnlockStarterPack:PurchaseStarterPack()	
	if StarterPackSystem.iStarterPackDirectPurchaseId > 0 then
		--self.CloseUI();
		StarterPackSystem.StartDirectPurchase();
		GemReportUtils.ReportEventImmediate(GemReportUtils.EventName_StarterPack, GemReportUtils.SubEventName_StarterPackBuyThroughUCStore);
	end
end

function UI_UnlockStarterPack:UnRegistEvents()
    --todo: 在这里反注册事件
    UI_UnlockStarterPack.__super.UnRegistEvents(self)
end

function UI_UnlockStarterPack:OnPostInitialize()
    UI_UnlockStarterPack.__super.OnPostInitialize(self)

    --todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
	
	if StarterPackSystem.bForceUpdate then
		log("#ZK UpdateDateFromServer on UI_UnlockStarterPack:OnPostInitialize");
		StarterPackSystem.UpdateDateFromServer();
	end

	self:InitUI();
    --self:InitLogic();
end

-- 仅在需要监听状态变化时写这个函数
--[[function UI_Template:OnModeSwitch(preStatus, currentStatus)
    
end
]]


function UI_UnlockStarterPack:Close()
    --todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

    UI_UnlockStarterPack.__super.Close(self)
end

function UI_UnlockStarterPack:InitUI()


	
	self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
   
  --log("UI_UnlockStarterPack  InitLogic");
  self.bInitialized= true;
end

function UI_UnlockStarterPack:UpdateUICountDown(timeStr)	
	self:ProcessTimeCountdown(StarterPackSystem.sStarterPack_RemainingTime);
	if self.sPrice == nil or self.sPrice == "" then
		self.sPrice = StarterPackSystem.GetPriceDesc();
		self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	end
		
	if self.sRewardUC == nil or self.sRewardUC == "" then
		self.sRewardUC = StarterPackSystem.GetUCRewardsDesc();
		self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
	end	
end

function UI_UnlockStarterPack:OnGetProductPrice()
		self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
    self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
end
function UI_UnlockStarterPack:OnGetProductDesc()
    self:ProcessProductDesc(StarterPackSystem.GetPriceDesc());
    self:ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
end



function UI_UnlockStarterPack:ProcessProductDesc(desc)
	--log("self.UIRoot:SetStarterPackPrice  " .. desc);;
	self.UIRoot.TextPrice:SetText(desc);
end
function UI_UnlockStarterPack:ProcessProductRewardInfo(desc)
	--log("self.UIRoot:SetStarterPackPrice  " .. desc);;
	self.UIRoot.UC:SetText(desc);
end
function UI_UnlockStarterPack:ProcessTimeCountdown(desc)
	self.UIRoot.TimeRemaining:SetText(desc);
	--self.UIRoot:SetStarterPackTimeRemaining(desc);
end



function UI_UnlockStarterPack:PlayAudio()
    self.UIRoot:PlayAudio();
end

local class = require("class")
local ui_base = require("ui.base")
local CUI_UI_UnlockStarterPack = class(ui_base, nil, UI_UnlockStarterPack)

return CUI_UI_UnlockStarterPack