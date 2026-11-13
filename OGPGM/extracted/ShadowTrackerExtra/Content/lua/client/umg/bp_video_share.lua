VideoShareUI = VideoShareUI or {};
--注册Widget
function bp_video_share_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_video_share,
		{				
			{Path="/Game/UMG/UI_BP/PopupNotice/ShareVideo_BP.ShareVideo_BP_C", Container="Top", ZOrder=BP_ENUM_UI_COMMON_ITEMTIPS_ZORDER},
        },        
		{"Lobby", "Fighting"},
		false,
        false,
        true
	);
end

function VideoShareUI.Show()
	LuaClassObj.HandleDynamicCreation(bp_video_share);
	LuaClassObj.HandleUIMessage(bp_video_share, "UIShow"); 
end

function EventShowVidewShareFromCPlus()
	VideoShareUI.Show();
end
