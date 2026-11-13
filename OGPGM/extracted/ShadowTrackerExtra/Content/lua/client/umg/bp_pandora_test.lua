PandoraTestUI = PandoraTestUI or {};

BP_STRUCT_PandoraUserData = {
    openId = "",
    roleId = "",
    appId = "",
    platId = "1",
    accType = "qq",
    area  = "1",
    partion = "1",
    cloudTest = "1",
    accessToken = "",
    sdkVersion = "",
    gameAppVersion = "",
    roleName = "",
    payToken = "",

};

BP_PandoraTest_Cmd = "";

--注册Widget
function bp_pandora_test_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_pandora_test,
		{{Path="/Game/UMG/UI_Logic/Pandora/Pandora_Test_BP.Pandora_Test_BP_C", Container="Default", ZOrder=250}},
		{"Lobby"},
		false,
		bp_pandora_test_OnModeSwitched ~= nil,
		true,
        true
	);
end

function PandoraTestUI.Show()
    LuaClassObj.HandleDynamicCreation(bp_pandora_test);

    LuaClassObj.HandleUIMessage(bp_pandora_test, "UIShow");
end

function EventPandoraTestGetUserData()
    BP_STRUCT_PandoraUserData.openId = tostring(DataMgr.roleData.openID);
    BP_STRUCT_PandoraUserData.roleId = tostring(DataMgr.roleData.uid);
    BP_STRUCT_PandoraUserData.appId = Client.GetITopGameId(NetInterface);
    BP_STRUCT_PandoraUserData.platId = "1";
    BP_STRUCT_PandoraUserData.accType = "qq";
    BP_STRUCT_PandoraUserData.area = "1";
    BP_STRUCT_PandoraUserData.partion = "1";
    BP_STRUCT_PandoraUserData.cloudTest = "1";
    BP_STRUCT_PandoraUserData.accessToken = Client.GetAccessToken(NetInterface);
    BP_STRUCT_PandoraUserData.sdkVersion = "GziPubgM_Android_V1";
    BP_STRUCT_PandoraUserData.gameAppVersion = Client.GetAppVersion();
end

function EventPandoraTestInit()
    PandoraSystem.Init();
end

function EventPandoraTestClose()
    PandoraSystem.Release();
end

--{"type":"Open","content":"Pop"}
function EventPandoraTestToCmd()
    if BP_PandoraTest_Cmd == "" then
        return;
    end
    log("BP_PandoraTest_Cmd="..BP_PandoraTest_Cmd);

    PandoraSystem.SendCmd(BP_PandoraTest_Cmd);
end

function EventPandoraTestPopShow()
    --local jsonStr = "{\"type\":\"Show\",\"content\":\"Pop\"}";
   --PandoraSystem.SendCmd(jsonStr);;
   --PandoraSystem.StartPop();
   --PandoraSystem.PopJumpScene("game://?module="..BP_ENUM_MODULE_MARKET.."&pagetype=2&id=21030024","ShowNext");
end

function EventPandoraTestWish()
    --PandoraSystem.PopJumpScene("game://?module="..BP_ENUM_MODULE_PANDORA_WISH,"Close");
end

function EventPandoraTestCollection()
    --PandoraSystem.PopJumpScene("game://?module="..BP_ENUM_MODULE_PANDORA_COllECTION,"Close");
end

function EventPandoraTestShare()
    PandoraSystem.Share("分享测试Title","分享测试Desc","http://www.qq.com","0");
end

function EventPandoraTestPopHide()
    local jsonStr = "{\"type\":\"Hide\",\"content\":\"Pop\"}";
    PandoraSystem.SendCmd(jsonStr);
    --PandoraPopUI.Hide();
end

----------------------
function EventPandoraJumpScene()
    local Actid = BP_PandoraTest_Cmd;
    log("EventPandoraJumpScene Actid: "..Actid);
    PandoraSystem.PopJumpScene("game://?module="..Actid,"Close");
end

function EventPandoraJumpURL()
    local url = BP_PandoraTest_Cmd;
    log("EventPandoraJumpURL url: "..url);
    GlobalData:JumpUrl(url);
end

function EventPandoraRefreshCoin()
    log("EventPandoraRefreshCoin");

end

function EventPandoraShowItem()
    log("EventPandoraShowItem");
    
end

function EventPandoraShowActivityNavigator()
    log("EventPandoraShowActivityNavigator");
    
    local Content = "";
    local Actid = PandoraSystem.Act_Id_ActivityNavigator;
    local Margin = "50,0,50,0";
    -- isPopPanel: 0表示不是拍脸活动，1表示是拍脸活动
    local IsPopPanel = 0;
    CmdJsonString = "{\"type\":\"show\",\"content\":\""..Content.."\",\"actid\":\""..tostring(Actid).."\",\"margin\":\""..Margin.."\",\"isPopPanel\":\""..tostring(IsPopPanel).."\"}";
    PandoraSystem.TestSendCmdToPandora(CmdJsonString);
end

function EventPandoraShowMysteriousShop()
    log("EventPandoraShowMysteriousShop");
    
end

function EventPandoraPicShare()
    log("EventPandoraPicShare");
    local Content = "1,1,2,4";
    local Source = "";
    local MediaTagName = "MSG_friend_exceed";
    local MessageAction = "WECHAT_SNS_JUMP_APP";
    --local CmdJsonString = "{\"type\":\"PicShare\",\"content\":\""..Content.."\",\"source\":\""..Source.."\",\"mediaTagName\":\""..MediaTagName.."\",\"messageAction\":\""..MessageAction.."\"}";
    local CmdJsonString = "{\"type\":\"PicShare\",\"content\":\""..Content.."\",\"source\":\""..Source.."\",\"mediaTagName\":\""..MediaTagName.."\",\"messageAction\":\""..MessageAction.."\",\"imagePath\":\"".."../../../ShadowTrackerExtra/Saved/Pandora/HOTUPDATE/1.jpg".."\"}";
        
    PandoraShareUI.ShowUI(CmdJsonString);
end

function EventPandoraTextShare()
    log("EventPandoraTextShare");
    PandoraSystem.Share("分享测试Title","分享测试Desc","http://www.qq.com","0");
end

