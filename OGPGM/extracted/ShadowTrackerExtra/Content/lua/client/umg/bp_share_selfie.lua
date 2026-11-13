--[[
	���������ķ��� rainpan 2018-07-23
--]]

ShareSelfieUI = ShareSelfieUI or {
}

BP_ShareSelfieImagePath = "";

BP_LoginChannel = 0;

--ֻ��ս��������--
function bp_share_selfie_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share_selfie,
		{
			{Path="/Game/BluePrints/ControlInput/SelfieUI/ShareSelfie_UIBP.ShareSelfie_UIBP_C", Container="Default", ZOrder=BP_ENUM_UI_Share_Game_Result_ZORDER},
		},
		{"Fighting"},
		false,
		false,
		true
	);
end

function ShareSelfieUI.StartCapture()
	log("----ShareSelfieUI.StartCapture ----");
	LuaClassObj.HandleDynamicCreation(bp_share_selfie);
	LuaClassObj.HandleUIMessage(bp_share_selfie, "StartCapture");	
end

function ShareSelfieUI.SetShareSelfieImagePath(path)
	log("ShareSelfieUI.SetShareSelfieImagePath path: " .. tostring(path));
	BP_ShareSelfieImagePath = path;
end

--��ʾUI 
function ShareSelfieUI.ShowUI()
	log("----ShareSelfieUI.ShowUI ----");
	LuaClassObj.HandleDynamicCreation(bp_share_selfie);
	BP_LoginChannel = Client.GetLoginChannel(NetInterface);
	LuaClassObj.HandleUIMessage(bp_share_selfie, "UIShow");	

	EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnSelfieShareSucessEventHandler);
end

function ShareSelfieUI.HideUI()
	log("----ShareSelfieUI.HideUI ----");
	LuaClassObj.HandleUIMessage(bp_share_selfie, "UIHide");	
end

--����ɹ��Ļص�
function OnSelfieShareSucessEventHandler(eventType, eventID, vars)

	log("********selfie share call back *********");

	if eventType ~= EVENTTYPE_SHARE then
		return;
	end	

	local hasApp = DataMgr.HasInstallPlatApp();
	if hasApp ==  true then
		LuaClassObj.HandleUIMessage(bp_share_selfie, "UIHide");	
	end
	
	log("********selfie share success, hide share selfie ui *********");
	EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnSelfieShareSucessEventHandler);
end

--����facebook ����QQ
function EventShareSelfieClickFacebookBtn()	
	log("EventShareSelfieClickFacebookBtn");
	if Client.IsInstallQQ(NetInterface) == false then 
		--�㻹û�а�װFacebook���޷�ʹ�ô˹���
		DataMgr.ShowNoticeByID(4005);
		return;
	end
		
	ShareMgr:shareQQWithPhoto(MEDIA_TAG_SHARE_SELFIE, "", BP_ShareSelfieImagePath, ShareType.Moment);
	
	--ClientSendBAReport(BP_BA_SHARE_WXFRIENDCIRCLE, 0);
	--ClientSendBAReport(BP_BA_SHARE_SHAREBTN, 0);
end

--����twitter
function EventShareSelfieClickTwitterBtn()	
	log("EventShareSelfieClickTwitterBtn");
	if Client.IsInstallTwitter(NetInterface) == false then 
		--�㻹û�а�װtwitter���޷�ʹ�ô˹���
		--DataMgr.ShowNoticeByID(4062);
		--return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_SELFIE, BP_ShareSelfieImagePath, "", "", BP_ENUM_PLAYFORM_TWITTER);
	
	--ClientSendBAReport(BP_BA_SHARE_WXFRIENDCIRCLE, 0);
	--ClientSendBAReport(BP_BA_SHARE_SHAREBTN, 0);
end

--����΢������Ȧ
function EventShareSelfieClickWXZoneBtn()	
	log("EventShareSelfieClickWXZoneBtn");
	if Client.IsInstallWX(NetInterface) == false then 
		--�㻹û�а�װ΢�ţ��޷�ʹ�ô˹���
		DataMgr.ShowNoticeByID(110126);
		return;
	end

	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_SELFIE, BP_ShareSelfieImagePath, "", "", BP_ENUM_PLAYFORM_WX);

	--ClientSendBAReport(BP_BA_SHARE_WXFRIENDCIRCLE, 0);
	--ClientSendBAReport(BP_BA_SHARE_SHAREBTN, 0);
end

--����VK
function EventShareSelfieClickVKBtn()	
	log("EventShareSelfieClickVKBtn");
	if Client.IsInstallVK(NetInterface) == false then 
		--�㻹û�а�װVK���޷�ʹ�ô˹���
		DataMgr.ShowNoticeByID(4310);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_SELFIE, BP_ShareSelfieImagePath, "", "", BP_ENUM_PLAYFORM_VK);
	--�ϱ�����̨��ͳ��
	--ClientSendBAReport(BP_BA_SHARE_VK_COUNT, 0);
	--ShareReqDay(BP_BA_SHARE_VK);
end

--分享QQ
function EventShareSelfieClickQQByiTOPBtn()	
	log("EventShareSelfieClickQQByiTOPBtn");
	if Client.IsInstallQQByiTOP(NetInterface) == false then 
		--你还没有安装QQ，无法使用此功能
		DataMgr.ShowNoticeByID(110125);
		return;
	end
	
	ShareMgr:shareWithPhotoByChannel(MEDIA_TAG_SHARE_SELFIE, BP_ShareSelfieImagePath, "", "", BP_ENUM_PLAYFORM_QQByiTOP);
	--上报给后台做统计
	--ClientSendBAReport(BP_BA_SHARE_QQByiTOP_COUNT, 0);
	--ShareReq(BP_BA_SHARE_QQByiTOP);
end