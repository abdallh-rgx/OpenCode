--一设置界面

SettingMirrativUI = SettingMirrativUI or 
{
	
}

--注册widget
function bp_setting_mirrativ_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_setting_mirrativ,
    {{Path="/Game/UMG/UI_BP/Setting/Setting_mirratv_UIBP.Setting_mirratv_UIBP_C", Container="Default", ZOrder = 60}},
    {"Lobby"},
	false,
	false,
	true
  );
end

function SettingMirrativUI:Init()
	log("[HHF]SettingMirrativUI:Init");
	LuaClassObj.HandleDynamicCreation(bp_setting_mirrativ);
	LuaClassObj.HandleUIMessage(bp_setting_mirrativ, "InitUI");
end

function SettingMirrativUI:Hide()
	log("[HHF]SettingMirrativUI:Init");
	LuaClassObj.HandleUIMessage(bp_setting_mirrativ, "UIHide");
end


function SettingMirrativUI.LaunchMirrativDownLoadUrl()
    if string.lower(Client.GetDevicePlatformName()) == "ios" then
    	Client.LaunchUrl("https://itunes.apple.com/app/id1028944599");
    elseif string.lower(Client.GetDevicePlatformName()) == "android" then
    	if Client.GetAOSSHOP() == 'Samsung' then
			Client.LaunchUrl("https://www.samsungapps.com/appquery/appDetail.as?appId=com.dena.mirrativ");
		else
			Client.LaunchUrl("https://play.google.com/store/apps/details?id=com.dena.mirrativ");
		end	
    end
end

function EventLaunchMirrativUrlPlay()
    log("[HHF]EventLaunchMirrativUrlPlay");

    if Client.IsInstallMirrativ(NetInterface) == false then
        --你还没有安装Mirrativ，无法使用此功能
        --DataMgr.ShowNoticeByID(4737);

        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local msg = Client.GetTableData("LocalizeRes", "4737").TextValue;
        CommonMessageBoxUI:ShowPanel(1, title, msg, SettingMirrativUI.LaunchMirrativDownLoadUrl);
        return;
    end

    if string.lower(Client.GetDevicePlatformName()) == "ios" then
        Client.LaunchUrl("mirr:///broadcast/live?app_id=com.pubg.krmobile");
    elseif string.lower(Client.GetDevicePlatformName()) == "android" then
        Client.LaunchUrl("https://ws9f.adj.st//broadcast/live?adjust_t=duxszb6_k1wzyvz&adjust_deeplink=mirr%3A%2F%2F%2Fbroadcast%2Flive%3Fapp_id%3Dcom.pubg.krmobile&app_id=com.pubg.krmobile");
    end
end

function EventLaunchMirrativUrlBrowser()
    log("[HHF]EventLaunchMirrativUrlBrowser");

    if Client.IsInstallMirrativ(NetInterface) == false then
        --你还没有安装Mirrativ，无法使用此功能
        --DataMgr.ShowNoticeByID(4737);

        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local msg = Client.GetTableData("LocalizeRes", "4737").TextValue;
        CommonMessageBoxUI:ShowPanel(1, title, msg, SettingMirrativUI.LaunchMirrativDownLoadUrl);
        return;
    end

    if string.lower(Client.GetDevicePlatformName()) == "ios" then
        Client.LaunchUrl("mirr:///app/com.pubg.krmobile");
    elseif string.lower(Client.GetDevicePlatformName()) == "android" then
        Client.LaunchUrl("https://ws9f.adj.st//app/com.pubg.krmobile?adjust_t=duxszb6_k1wzyvz&adjust_deeplink=mirr:///app/com.pubg.krmobile");
    end
end

----OpenRec接入 begin
function SettingMirrativUI.LaunchOpenRecDownLoadUrl()
    if string.lower(Client.GetDevicePlatformName()) == "ios" then
        Client.LaunchUrl("https://itunes.apple.com/jp/app/openrec-tv/id912776162");
    elseif string.lower(Client.GetDevicePlatformName()) == "android" then
        Client.LaunchUrl("https://play.google.com/store/apps/details?id=jp.co.cyber_z.openrecviewapp");
    end
end

function SettingMirrativUI.CheckInstallOpenRec()
    if Client.IsInstallOpenRec(NetInterface) == false then
        --你还没有安装OpenRec，无法使用此功能

        local title = Client.GetTableData("LocalizeRes", "101001").TextValue;
        local msg = Client.GetTableData("LocalizeRes", "6833").TextValue;
        CommonMessageBoxUI:ShowPanel(1, title, msg, SettingMirrativUI.LaunchOpenRecDownLoadUrl);
        return false;
    end

    return true
end

function EventLaunchOpenRecUrlPlay()
    log("[HHF]EventLaunchOpenRecUrlPlay");

    if SettingMirrativUI.CheckInstallOpenRec() == false then
        return;
    end

    Client.LaunchUrl("jp.co.cyber-z.openrec://cast?title=PUBG&game_id=playerunknowns-battlegrounds-pubg");
end

function EventLaunchOpenRecUrlBrowser()
    log("[HHF]EventLaunchOpenRecUrlBrowser");

    if SettingMirrativUI.CheckInstallOpenRec() == false then
        return;
    end

    Client.LaunchUrl("jp.co.cyber-z.openrec://game?id=1438&identify_id=playerunknowns-battlegrounds-pubg");
end

function EventVisitOpenRecUrl()
    Client.LaunchUrl("https://article.openrec.tv/2142");
end
----OpenRec接入 end