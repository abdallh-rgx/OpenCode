--绑定手机邮箱界面

SettingInformationUI = SettingInformationUI or 
{
	is_show = false,
}

BP_Setting_InfoBinding_NeedShow = false    --该功能是否开放
BP_Setting_InfoBinding_Mobile = ""         --绑定过的手机号
BP_Setting_InfoBinding_Email = ""          --绑定过的邮箱号
BP_Setting_InfoBinding_NationCode = ""     --绑定过的手机的地区编号
BP_Setting_InfoBinding_CanMobile = false   --本日手机是否可以再次绑定
BP_Setting_InfoBinding_CanEmail = false    --本日邮箱是否可以再次绑定
BP_Setting_InfoBinding_OpenUrl = ""        --打开h5界面的url

--注册widget
function bp_setting_informationbinding_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_informationbinding,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Informationbinding_UIBP.Setting_Informationbinding_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby"},
	false,
	false,
	true
  );
end

--打开界面，拉取绑定信息
function SettingInformationUI:Init()
	log("SettingInformationUI:Init")
	SettingInformationUI.is_show = true
	NetUtil.SendPkg("get_account_bind_req")
	LuaClassObj.HandleDynamicCreation(bp_setting_informationbinding);
	LuaClassObj.HandleUIMessage(bp_setting_informationbinding, "InitUI");
end

--关闭界面
function SettingInformationUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_informationbinding, "UIHide");
	SettingInformationUI.is_show = false
end

--拉取绑定信息回包
function SettingInformationUI.get_account_bind_rsp(is_need_show, nation_code, mobile, email)
	log("SettingInformationUI.get_account_bind_rsp ".." is_need_show "..tostring(is_need_show))
	BP_Setting_InfoBinding_NeedShow = is_need_show
	--如果绑定界面还未展示，那么这种情况将绑定界面页签隐藏掉
	if is_need_show == false and SettingInformationUI.is_show == false and mobile == nil and email == nil then
		log("SettingUI.HideInfoBindTab")
		SettingUI.HideInfoBindTab()
		return
	end
	-- if is_need_show == true and SettingInformationUI.is_show == false then
	-- 	log("SettingUI.ShowInfoBindTab")
	-- 	SettingUI.ShowInfoBindTab()
	-- end
	if mobile ~= nil then
		BP_Setting_InfoBinding_Mobile = mobile
		if nation_code ~= nil and nation_code ~= 0 then
			BP_Setting_InfoBinding_Mobile = "(+"..tostring(nation_code)..")"..BP_Setting_InfoBinding_Mobile
		end
	else
		BP_Setting_InfoBinding_Mobile = ""
	end
	if email ~= nil then
		BP_Setting_InfoBinding_Email = email
	else
		BP_Setting_InfoBinding_Email = ""
	end
	--BP_Setting_InfoBinding_CanMobile = can_change_mobile
	--BP_Setting_InfoBinding_CanEmail = can_change_email
	log("SettingInformationUI.is_show"..tostring(SettingInformationUI.is_show))
	if SettingInformationUI.is_show == true then
		LuaClassObj.HandleUIMessage(bp_setting_informationbinding, "RefreshUI");
	end
end

function EventInfoBindingFetchInfo()

end

function SettingInformationUI.URLEncode(str)
	log("[HHF]SettingInformationUI.URLEncode, before str = " .. tostring(str));
	if str ~= nil then
		str = string.gsub(str, "([^%w%.%- ])", 
			function(c)
				return string.format("%%%02x", string.byte(c));
			end);
		str = string.gsub(str, " ", "+");
	end

	log("[HHF]SettingInformationUI.URLEncode, after str = " .. tostring(str));
	return str;
end

--点击绑定后拼接url
function EventSettingClickBindInformation()
	local language = Client.GetCurrentLanguage()
	local nation = LoginSystem.ip_region
	local bindingUrl = "https://www.pubgmobile.com/act/a20181022h5bind/index.html";
	local nickName = DataMgr.roleData.nickName
	nickName = SettingInformationUI.URLEncode(SettingInformationUI.URLEncode(nickName))
    BP_Setting_InfoBinding_OpenUrl = bindingUrl.."?language="..language.."&nation="..nation.."&nickName="..nickName;
	log("BP_Setting_InfoBinding_OpenUrl"..BP_Setting_InfoBinding_OpenUrl)
end

--首次绑定手机
function EventSettingClickBindMobileInformation()
	local language = Client.GetCurrentLanguage()
	local nation = LoginSystem.ip_region
	local bindingUrl = "https://www.pubgmobile.com/act/a20181022h5bind/mobile.html";
	local nickName = DataMgr.roleData.nickName
	nickName = SettingInformationUI.URLEncode(SettingInformationUI.URLEncode(nickName))
    BP_Setting_InfoBinding_OpenUrl = bindingUrl.."?language="..language.."&nation="..nation.."&nickName="..nickName;
	log("BP_Setting_InfoBinding_OpenUrl"..BP_Setting_InfoBinding_OpenUrl)
end

--首次绑定邮箱
function EventSettingClickBindEmailInformation()
	local language = Client.GetCurrentLanguage()
	local nation = LoginSystem.ip_region
	local bindingUrl = "https://www.pubgmobile.com/act/a20181022h5bind/mail.html";
	local nickName = DataMgr.roleData.nickName
	nickName = SettingInformationUI.URLEncode(SettingInformationUI.URLEncode(nickName))
    BP_Setting_InfoBinding_OpenUrl = bindingUrl.."?language="..language.."&nation="..nation.."&nickName="..nickName;
	log("BP_Setting_InfoBinding_OpenUrl"..BP_Setting_InfoBinding_OpenUrl)
end

--点击更改邮箱
function EventSettingClickChangeEmail()
	local language = Client.GetCurrentLanguage()
	local nation = LoginSystem.ip_region
	local bindingUrl = "https://www.pubgmobile.com/act/a20181022h5bind/change_mai.html";
	local nickName = DataMgr.roleData.nickName
	nickName = SettingInformationUI.URLEncode(SettingInformationUI.URLEncode(nickName))
    BP_Setting_InfoBinding_OpenUrl = bindingUrl.."?language="..language.."&nation="..nation.."&nickName="..nickName;
	log("BP_Setting_InfoBinding_OpenUrl"..BP_Setting_InfoBinding_OpenUrl)
end

--点击更改手机
function EventSettingClickChangeMobile()
	local language = Client.GetCurrentLanguage()
	local nation = LoginSystem.ip_region
	local bindingUrl = "https://www.pubgmobile.com/act/a20181022h5bind/change_mobile.html";
	local nickName = DataMgr.roleData.nickName
	nickName = SettingInformationUI.URLEncode(SettingInformationUI.URLEncode(nickName))
    BP_Setting_InfoBinding_OpenUrl = bindingUrl.."?language="..language.."&nation="..nation.."&nickName="..nickName;
	log("BP_Setting_InfoBinding_OpenUrl"..BP_Setting_InfoBinding_OpenUrl)
end

--邮箱绑定次数到达上限
function EventSettingChangeEmailLimit()
	log("EventSettingChangeEmailLimit")
end

--手机绑定次数到达上限
function EventSettingChangeMobileLimit()
	log("EventSettingChangeMobileLimit")
end

--删除绑定的邮箱
function EventSettingClickDeleteEmail()
	local title = Client.GetTableData("LocalizeRes", "6356").TextValue;
    local tip = Client.GetTableData("LocalizeRes", "6357").TextValue;
    CommonMessageBoxUI:ShowPanel(2, title, tip, function()
            NetUtil.SendPkg("delete_account_bind_req", 2);
        return true;
    end);
end

--删除绑定的手机
function EventSettingClickDeleteMobile()
	local title = Client.GetTableData("LocalizeRes", "6354").TextValue;
    local tip = Client.GetTableData("LocalizeRes", "6355").TextValue;
    CommonMessageBoxUI:ShowPanel(2, title, tip, function()
            NetUtil.SendPkg("delete_account_bind_req", 1);
        return true;
    end);
end

s2c = s2c or {};
s2c["get_account_bind_rsp"] = SettingInformationUI.get_account_bind_rsp;