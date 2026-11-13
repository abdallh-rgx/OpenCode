--获得物品分享UI
ItemShareUI = ItemShareUI or
{

}

BP_STRUCT_ItemGetShare_ShowInfo = 
{
	res_id = 0,--物品id
	valid_hours_str = "",
	tip = "",--文字提示
	play_name = "",--玩家昵称
	uid = "",
	icon_url = "";
	gender = 1;
	quality = 0;
	isWeapon = false;
	color_id = 0;
	pattern_id = 0;
	shareType = 0;
}

--图片分享保存的路径
BP_ItemGetShare_ImagePath = "";

function bp_item_get_share_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_item_get_share,
		{		
			{Path="/Game/UMG/UI_Logic/Share/Share_Item_Get_BP.Share_Item_Get_BP_C", Container="Top", ZOrder=BP_ENUM_UI_SHARE_ITEM_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

function EventShowSharePanel()
	ItemShareUI:ShowSharePanel();
end

local function ShareReq(channel_type)
	ShareMgr.ShareSuccReq(1, channel_type);
end 

local function OnShareSucessEventHandler(eventType, eventID, vars)

    local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_item_get_share, "UIHide");	
	end
		
end

function ItemShareUI:ShowSharePanel()
	LuaClassObj.HandleDynamicCreation(bp_item_get_share);
	
	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	local itemGetInfo = _G.BP_Array_GoodItemGet_ToShow[1];
	BP_STRUCT_ItemGetShare_ShowInfo = {};
	BP_STRUCT_ItemGetShare_ShowInfo.res_id = itemGetInfo.res_id;
	local iteminfo = Client.GetTableData("Item", itemGetInfo.res_id);
	BP_STRUCT_ItemGetShare_ShowInfo.valid_hours_str = itemGetInfo.valid_hours_str;
	BP_STRUCT_ItemGetShare_ShowInfo.tip = ShareMgr.GetTraitidNum(iteminfo.ItemQuality);
	BP_STRUCT_ItemGetShare_ShowInfo.play_name = DataMgr.roleData.nickName;
	BP_STRUCT_ItemGetShare_ShowInfo.uid = DataMgr.roleData.uid;
	BP_STRUCT_ItemGetShare_ShowInfo.icon_url = DataMgr.roleData.headIconUrl;
	BP_STRUCT_ItemGetShare_ShowInfo.gender = DataMgr.roleData.gender;
	BP_STRUCT_ItemGetShare_ShowInfo.quality = iteminfo.ItemQuality;
	BP_STRUCT_ItemGetShare_ShowInfo.color_id = itemGetInfo.color_id;
	BP_STRUCT_ItemGetShare_ShowInfo.pattern_id = itemGetInfo.pattern_id;
	BP_STRUCT_ItemGetShare_ShowInfo.shareType = itemGetInfo.shareType;
	if iteminfo.ItemType == 1 or iteminfo.ItemType == 8 or iteminfo.ItemType == 9 then
		BP_STRUCT_ItemGetShare_ShowInfo.isWeapon = true;
	else
		BP_STRUCT_ItemGetShare_ShowInfo.isWeapon = false;
	end
	LuaClassObj.HandleUIMessage(bp_item_get_share, "UIShow");
	
	ClientSendBAReport(BP_BA_SHARE_ITEMPANEL, 0);
	ClientSendBAReport(BP_BA_SHARE_MAINPANEL, 0);
end

--保存本地/相册
function EventItemShareClickSaveLocalBtn()
	
end

--分享facebook 复用QQ
function EventItemShareClickFacebookBtn()	
	log("[HHF]EventItemShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ItemGetShare_ImagePath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, BP_STRUCT_ItemGetShare_ShowInfo.res_id);
	ShareReq(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventItemShareClickTwitterBtn()	
	log("[HHF]EventItemShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ItemGetShare_ImagePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, BP_STRUCT_ItemGetShare_ShowInfo.res_id);
	ShareReq(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventItemShareClickWXZoneBtn()	
	log("[HHF]EventItemShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ItemGetShare_ImagePath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, BP_STRUCT_ItemGetShare_ShowInfo.res_id);
	ShareReq(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventItemShareClickVKBtn()	
	log("[HHF]EventItemShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ItemGetShare_ImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, BP_STRUCT_ItemGetShare_ShowInfo.res_id);
	ShareReq(BP_BA_SHARE_VK);
end

--分享Line
function EventItemShareClickLineBtn()	
	log("[HHF]EventItemShareClickLineBtn");
	if Client.IsInstallLine(NetInterface) == false then 
		--你还没有安装Line，无法使用此功能
		DataMgr.ShowNoticeByID(4985);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ItemGetShare_ImagePath, "", "", BP_ENUM_PLAYFORM_LINE);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, BP_STRUCT_ItemGetShare_ShowInfo.res_id);
	ShareReq(BP_BA_SHARE_LINE);
end

--分享QQ
function EventItemShareClickQQByiTOPBtn()	
	log("EventItemShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ItemGetShare_ImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, BP_STRUCT_ItemGetShare_ShowInfo.res_id);
	ShareReq(BP_BA_SHARE_QQByiTOP);
end

function EventItemShareHide()
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end
