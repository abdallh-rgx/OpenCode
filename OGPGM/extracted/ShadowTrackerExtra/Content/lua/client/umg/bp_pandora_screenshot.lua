PandoraScreenShot = PandoraScreenShot or {};

--注册Widget
function bp_pandora_screenshot_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_pandora_screenshot,
		{{Path="/Game/UMG/UI_Logic/Pandora/Pandora_Screenshot_BP.Pandora_Screenshot_BP_C", Container="Default", ZOrder=250}},
		{"Lobby"},
		false,
		false,
		true
	);
end

BP_PandoraScreenShot_PicPath = "";
BP_PandoraScreenShot_PicX_f = 0;
BP_PandoraScreenShot_PicY_f = 0;
BP_PandoraScreenShot_PicW_f = 0;
BP_PandoraScreenShot_PicH_f = 0;

function PandoraScreenShot.MakePicture(x, y, w, h)
    log("PandoraScreenShot.MakePicture x="..tostring(x)..", y="..tostring(y)..", w="..tostring(w)..", h="..tostring(h));
    if x == nil or y == nil or w == nil or h == nil then
        return;
    end

    BP_PandoraScreenShot_PicX_f = tonumber(x);
    BP_PandoraScreenShot_PicY_f = tonumber(y);
    BP_PandoraScreenShot_PicW_f = tonumber(w);
    BP_PandoraScreenShot_PicH_f = tonumber(h);

    LuaClassObj.HandleDynamicCreation(bp_pandora_screenshot);

    LuaClassObj.HandleUIMessage(bp_pandora_screenshot, "MakePic");
end


function EventPandoraScreenShotCaptured()
    local jsonStr = "{\"type\":\"RtnPic\",\"content\":\"\",\"imgPath\":\""..BP_PandoraScreenShot_PicPath.."\"}";
	log("EventPandoraScreenShotCaptured "..jsonStr);
	PandoraSystem.SendCmd(jsonStr);
end

