--设置界面

SettingPictureUI = SettingPictureUI or 
{
	
}

--注册widget
function bp_setting_picture_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_picture,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_Picture_UIBP.Setting_Picture_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby", "Fighting"},
	false,
	false,
	true
  );
end

function SettingPictureUI:Init()
	LuaClassObj.HandleDynamicCreation(bp_setting_picture);
	LuaClassObj.HandleUIMessage(bp_setting_picture, "InitUI");
end

function SettingPictureUI:Hide()
	LuaClassObj.HandleUIMessage(bp_setting_picture, "UIHide");
end

function SettingPictureUI:OnClickConfirm()
	LuaClassObj.HandleUIMessage(bp_setting_picture, "OnBtnConfirmClick");
end

function SettingPictureUI:OnClickCancle()
	LuaClassObj.HandleUIMessage(bp_setting_picture, "OnBtnCancleClick");
end