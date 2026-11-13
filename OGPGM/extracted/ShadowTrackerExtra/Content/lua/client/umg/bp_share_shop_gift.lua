--[[
	礼物中心分享界面
--]]

ShareShopGiftUI = ShareShopGiftUI or {
    friendUid = "",
    message = "",
}


BP_STRUCT_ShareGiftRecv =
{
    uid = "",
    myIconUrl = "",
    myGender = 1,
	myName = "",
    myAvatarBox = 1,
    senderGender = 1,
	senderName = "",
    itemId = 0,
    style = 0,
    give_type = "",
    notice = "",    --玩家自定义消息
    colorID = 0,
    patternID = 0,
};

--图片分享保存的路径
BP_ShareGift_ImagePath = "";

function bp_share_shop_gift_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_shop_gift,
		{
			{Path="/Game/UMG/UI_Logic/Shop/Shop_Gift/ShopGift_Share_BP.ShopGift_Share_BP_C", Container="Top", ZOrder=BP_ENUM_UI_Share_HonorWall_ZORDER},
		},
		{"Lobby"},
		false,
		false,
		true
	);
end

local function ShareReq(channel_type)
	ShareMgr.ShareSuccReq(9, channel_type);
end

local function OnShareSucessEventHandler(eventType, eventID, vars)

    log("ShareShopGiftUI OnShareSucessEventHandler")
	if vars then
        if vars[1] == 1 then
            --分享成功
            DataMgr.ShowNoticeFastQueueByID(501036);
        -- else
        --     --分享失败
        --     DataMgr.ShowNoticeFastQueueByID(501107);
        end
    end
end

function ShareShopGiftUI.ShowSharePanel(data)
	LuaClassObj.HandleDynamicCreation(bp_share_shop_gift);
	--ShareUI:SetShareInfo(11);

    BP_STRUCT_ShareGiftRecv.uid = data.uid;
    BP_STRUCT_ShareGiftRecv.myIconUrl = data.iconUrl;
    BP_STRUCT_ShareGiftRecv.myGender = DataMgr.roleData.gender;
    BP_STRUCT_ShareGiftRecv.myName = DataMgr.roleData.nickName;
    BP_STRUCT_ShareGiftRecv.myAvatarBox = data.avatarBox;
    BP_STRUCT_ShareGiftRecv.senderGender = data.gender;
    BP_STRUCT_ShareGiftRecv.senderName = data.name;
    BP_STRUCT_ShareGiftRecv.itemId = data.item;
    BP_STRUCT_ShareGiftRecv.give_type = data.give_type;
    BP_STRUCT_ShareGiftRecv.style = data.style;
    BP_STRUCT_ShareGiftRecv.notice = data.notice;
    BP_STRUCT_ShareGiftRecv.colorID = data.colorID;
    BP_STRUCT_ShareGiftRecv.patternID = data.patternID;


	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
	LuaClassObj.HandleUIMessage(bp_share_shop_gift, "UIShow");
end

function EventShareShopGiftHide()
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

function EventSetInfo_Push()
end

function EventFetchInfo()
end

function ShareShopGiftUI.shareToFriendCallback(openid, tag)

	local gamedata = {
        giftMsg_openid = openid
	}
    local params = {}
    params.openid = openid;
    params.desc = ShareShopGiftUI.message;
    params.adtag = GameCenterADTAG.giftsend
    if tag == 1 then
        params.gameTag = "MSG_GIFT_SEND"
        params.adtag = GameCenterADTAG.giftsend
    elseif tag == 2 then
        params.gameTag = "MSG_ASK_FOR_HEART"
        params.adtag = GameCenterADTAG.giftbeg
    elseif tag == 3 then
        params.gameTag = "MSG_CALL_COMPANION"
        params.adtag = GameCenterADTAG.giftthanks
    end
    local encodedstr = FuncUtil:EncodeURI(json.encode(gamedata));
    if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
        params.extendInfo = encodedstr;
    elseif _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
        params.targetUrl = ShareMgr:constructQQGameCenterURL(encodedstr, params.adtag);
        params.previewText = ShareShopGiftUI.message;
    end
    ShareMgr:shareToFriend(params);
    --log_tree("shareToFriend params=", params)
    --DataMgr.ShowNoticeFastQueueByID(501036);
end

function ShareShopGiftUI.shareToFriendSend(friendUid, nickname, msg)
    log("ShareShopGiftUI.shareToFriendSend:"..friendUid.." "..nickname.." "..msg)
    ShareShopGiftUI.friendUid = friendUid;
    ShareShopGiftUI.message = msg;
    FriendSystem.get_openid_by_gid_req(friendUid, "GiftShareToFriendSend")
end

function ShareShopGiftUI.shareToFriendBeg(friendUid, nickname, msg)
    log("ShareShopGiftUI.shareToFriendBeg:"..friendUid.." "..nickname.." "..msg)
    ShareShopGiftUI.friendUid = friendUid;
    ShareShopGiftUI.message = msg;
    FriendSystem.get_openid_by_gid_req(friendUid, "GiftShareToFriendBeg")
end

function ShareShopGiftUI.shareToFriendThanks(friendUid, nickname, msg)
    log("ShareShopGiftUI.shareToFriendThanks:"..friendUid.." "..nickname.." "..msg)
    ShareShopGiftUI.friendUid = friendUid;
    ShareShopGiftUI.message = msg;
    FriendSystem.get_openid_by_gid_req(friendUid, "GiftShareToFriendThanks")
end



--分享facebook 复用QQ
function EventGiftShareClickFacebookBtn()
	log("[HHF]EventGiftShareClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then
		--你还没有安装Facebook，无法使用此功能
		DataMgr.ShowNoticeByID(4005);
		return;
	end

	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_CHIJI, "", BP_ShareGift_ImagePath, ShareType.Moment);
	ClientSendBAReport(BP_BA_SHARE_QQSPACE, 0);
	ShareReq(BP_BA_SHARE_FACEBOOK);
end

--分享twitter
function EventGiftShareClickTwitterBtn()
	log("[HHF]EventGiftShareClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then
		--你还没有安装twitter，无法使用此功能
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end

	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareGift_ImagePath, "","", BP_ENUM_PLAYFORM_TWITTER);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_TW_COUNT, 0);
	ShareReq(BP_BA_SHARE_TWITTER);
end

--分享微信朋友圈
function EventGiftShareClickWXZoneBtn()
	log("[HHF]EventRankShareClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then
		--你还没有安装微信，无法使用此功能
		DataMgr.ShowNoticeByID(110126);
		return;
	end

	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareGift_ImagePath, "", "", BP_ENUM_PLAYFORM_WX);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_WX_ZONE_COUNT, 0);
	ShareReq(BP_BA_SHARE_WX_ZONE);
end

--分享VK
function EventGiftShareClickVKBtn()
	log("[HHF]EventRankShareClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then
		--你还没有安装VK，无法使用此功能
		DataMgr.ShowNoticeByID(4310);
		return;
	end

	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareGift_ImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	ShareReq(BP_BA_SHARE_VK);
end

--分享Line
function EventGiftShareClickLineBtn() 
    log("[HHF]EventGiftShareClickLineBtn");
    if Client.IsInstallLine(NetInterface) == false then 
        --你还没有安装Line，无法使用此功能
        DataMgr.ShowNoticeByID(4985);
        return;
    end
    
    ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareGift_ImagePath, "", "", BP_ENUM_PLAYFORM_LINE);
    --上报给后台做统计
    ClientSendBAReport(BP_BA_SHARE_LINE_COUNT, 0);
    ShareReq(BP_BA_SHARE_LINE);
end

--分享QQ
function EventGiftShareClickQQByiTOPBtn()	
	log("EventGiftShareClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_CHIJI, BP_ShareGift_ImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	ShareReq(BP_BA_SHARE_QQByiTOP);
end