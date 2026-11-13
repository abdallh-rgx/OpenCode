local Subscribe_Confirm_Buy_Tip =
{
	_subtype = 0,
}

function Subscribe_Confirm_Buy_Tip:ctor(selfType, subtype)
	--todo: 这里可以做些数据初始化工作
	if subtype then
		self._subtype = subtype
	end
end

function Subscribe_Confirm_Buy_Tip:OnInitialize()
	Subscribe_Confirm_Buy_Tip.__super.OnInitialize(self)

	--todo: 在这里做些初始化工作
end

function Subscribe_Confirm_Buy_Tip:RegistEvents()
	Subscribe_Confirm_Buy_Tip.__super.RegistEvents(self)
	self:AddOnClickedEvent("Button_Cancel", self.CloseSelf, self)
	self:AddOnClickedEvent("Button_OK", self.ClickOk, self)
	self:AddOnClickedEvent("Button_Service_Privacy", self.Click_Service_Privacy, self)
	self:AddOnClickedEvent("Button_Service_Agreement", self.ShowService, self)
	--todo: 在这里注册事件
end

function Subscribe_Confirm_Buy_Tip:UnRegistEvents()
	--todo: 在这里反注册事件

	Subscribe_Confirm_Buy_Tip.__super.UnRegistEvents(self)
end

function Subscribe_Confirm_Buy_Tip:OnPostInitialize()
	Subscribe_Confirm_Buy_Tip.__super.OnPostInitialize(self)
	local deviceplatform = string.lower(Client.GetDevicePlatformName());
	local tip = ""
	if deviceplatform == "ios" or "windows" == deviceplatform then
		log("self._subtype == NewSubscribeSystem.ENUM_SubId.Super")

		local fir_month_price = NewSubscribeSystem.Get_First_Month_Price()
		log("NewSubscribeSystem.fir_month_price " .. tostring(fir_month_price))
		if self._subtype == NewSubscribeSystem.ENUM_SubId.Super then
			local price = NewSubscribeSystem.Get_Price( NewSubscribeSystem.ENUM_SubId.Super)
			log("NewSubscribeSystem.Get_Price " .. tostring(price))
			if fir_month_price == "" then	--没有首月折扣
				tip = FuncUtil.LocalizeResFormat(6860,price,price)
			else
				tip = FuncUtil.LocalizeResFormat(6861,price,fir_month_price,price)
			end
			if tip then
				self.UIRoot.Text_Content:SetText(tip)
			end
		else
			local price = NewSubscribeSystem.Get_Price( NewSubscribeSystem.ENUM_SubId.Normal)
			tip = FuncUtil.LocalizeResFormat(6860,price,price)
			if tip then
				self.UIRoot.Text_Content:SetText(tip)
			end
		end
	else
		tip = FuncUtil.GetLocalizeResStr(6821)
		if tip then
			self.UIRoot.Text_Content:SetText(tip)
		end

	end

	--todo: OnPostInitialize在OnInitialize、RegistEvents之后，有需要在RegistEvents后初始化的工作写这里
end

-- 仅在需要监听状态变化时写这个函数
--[[function Subscribe_Confirm_Buy_Tip:OnModeSwitch(preStatus, currentStatus)

end
]]

function Subscribe_Confirm_Buy_Tip:Close()
	--todo: 这里做些消耗回收动作，注意UI_Template.__super.Close(self)一定要写在最后，遵循先进后出原则

	Subscribe_Confirm_Buy_Tip.__super.Close(self)
end

function Subscribe_Confirm_Buy_Tip:CloseSelf()
	local uiManager = require("ui.manager")
	if uiManager then
		uiManager.CloseUI(uiManager.UI_Config.ui_subscribe_confirm_buy)
	end
end
function Subscribe_Confirm_Buy_Tip:ClickOk()
	log("self._subtype " .. tostring(self._subtype))
	if self._subtype == NewSubscribeSystem.ENUM_SubId.Normal then
		local MidasManager = import("MidasManager")
		if MidasManager then
			local instance = MidasManager.GetInstance()
			if instance then
				log("productid " .. NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal))

				instance.Subscribe(instance, NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Normal), 30, "US", "USD", "PUBGPrime", "PUBGPrime", true)
			end
		end
	elseif self._subtype == NewSubscribeSystem.ENUM_SubId.Super then
		local MidasManager = import("MidasManager")
		if MidasManager then
			local instance = MidasManager.GetInstance()
			if instance then
				log("productid " .. NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super))
				instance:Subscribe(NewSubscribeSystem.Get_SubProduct_ID(NewSubscribeSystem.ENUM_SubId.Super), 30, "US", "USD", "PUBGPrimeP", "PUBGPrimeP", true)
			end
		end
	end
	Subscribe_Confirm_Buy_Tip:CloseSelf()
end

function Subscribe_Confirm_Buy_Tip:Click_Service_Privacy()
	local strRegion = Client.GetPublishRegion() ;
	log("Click_Service_Privacy = " .. strRegion);

	if strRegion == "JAPAN" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_jp, LongTxt.PrivacyAgreement_content_jp);
	elseif strRegion == "KOREA" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_kr, LongTxt.PrivacyAgreement_content_kr);
	else
		PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_en, LongTxt.PrivacyAgreement_content_en);
	end
end

function Subscribe_Confirm_Buy_Tip:ShowService()
	local strRegion = Client.GetPublishRegion();
	log("bp_authorization EventShowService strRegion = " .. strRegion);

	if strRegion == "JAPAN" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.UserAgreement_title_jp, LongTxt.UserAgreement_content_jp);
	elseif strRegion == "KOREA" then
		PopUpNoticeUI.ShowMessageBox(LongTxt.UserAgreement_title_kr, LongTxt.UserAgreement_content_kr);
	elseif strRegion == "VNG" then
		local url = "https://pubgm.zing.vn/noi-bat/thoa-thuan-su-dung.html";
		GlobalData:JumpUrl(url);
	else
		PopUpNoticeUI.ShowMessageBox(LongTxt.service_title_en, LongTxt.service_content_en);
	end
end

local class = require("class")
local ui_base = require("ui.base")
local CUITemplate = class(ui_base, nil, Subscribe_Confirm_Buy_Tip)

return CUITemplate