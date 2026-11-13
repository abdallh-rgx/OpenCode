--[[
	分享 个人 2017-12-12
--]]

BP_SHARE_WX_CFG_ENABLED = false;
BP_SHARE_VK_CFG_ENABLED = false;
BP_SHARE_LINE_CFG_ENABLED = false;
BP_SHARE_QQByiTOP_CFG_ENABLED = false;

ShareUI = ShareUI or {
	shareType = 1,--物品分享
}

BP_STRUCT_ShareRoleData =
{
	roleUid = "",
	headIconUrl = "",
	gender = 0,
	nickName = "",
	cur_avatar_box_id = 0,
}


function bp_share_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_share,
		{	
			{Path="/Game/UMG/UI_BP/Lobby/Shareinterface_UIBP.Shareinterface_UIBP_C", Container="Default", ZOrder=10},
		},
		{"Lobby"},
		false,
		false
	);
end	 

local function OnShareSucessEventHandler(eventType, eventID, vars)
	LuaClassObj.HandleUIMessage(bp_item_get_share, "UIHide");	
end

-- ShareResultUI.ShowUI 里用到了，先从plusone分支里合过来
function ShareUI:SetShareInfo(shareType)
	ShareUI.shareType = shareType;
	--EventSystem:registEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

--组织数据
function ShareUI.ContructData()
	log("ShareUIContructData");
	BP_STRUCT_ShareRoleData = {};	
	BP_STRUCT_ShareRoleData.roleUid = DataMgr.roleData.uid;
	BP_STRUCT_ShareRoleData.headIconUrl = DataMgr.roleData.headIconUrl;
	BP_STRUCT_ShareRoleData.gender = DataMgr.roleData.gender;
	BP_STRUCT_ShareRoleData.nickName = DataMgr.roleData.nickName;	
	BP_STRUCT_ShareRoleData.cur_avatar_box_id = DataMgr.roleData.cur_avatar_box_id;	
	--log_tree("ShareUIContructData struct", BP_STRUCT_ShareRoleData);
end

function EventGetRoleData()
	log("EventGetRoleData");	
	ShareUI.ContructData();
end

function EventShare_Push()
	--蓝图变量同步给lua
end

function EventShareFetchInfo()
	--lua变量同步蓝图
end



--保存本地失败
function EventSaveLocalFail()
	DataMgr.ShowNoticeByID(4069);
end

--保存本地成功
function EventSaveLocalSuccess()
	DataMgr.ShowNoticeByID(110124);
end

--Facebook分享 复用qq好友分享
function EventClickQQFriendBtn()
	log("EventClickQQFrientBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_QQ;
end

--qq空间
function EventClickQQZoneBtn()
	log("EventClickQQZoneBtn");
end
	
--wx好友
function EventClickWXFriendBtn()
	log("EventClickWXFriendBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_WX;
end

--wx朋友圈
function EventClickWXZoneBtn()
	log("EventClickWXZoneBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_WX;
end

--Twitter分享
function EventClickTwitterBtn()
	log("EventClickTwitterBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_TWITTER;
end

--vk分享
function EventClickVKFriendBtn()
	log("EventClickVKFrientBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_VK;
end

--Line分享
function EventClickLineFriendBtn()
	log("EventClickLineFriendBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_LINE;
end

--QQ分享
function EventClickQQByiTOPFriendBtn()
	log("EventClickQQByiTOPFriendBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_QQByiTOP;
end

--More分享
function EventClickShareMoreBtn()
	log("EventClickShareMoreBtn");
	BP_Share_Platform = BP_ENUM_PLAYFORM_MORE;
end

--保存本地
function EventClickSaveLocal()
	log("EventClickSaveLocal");
end

--点击关闭
function EventClickClose()
	log("EventCliclClose");
	--EventSystem:unregistEvent(EVENTTYPE_SHARE, EVENTID_SHARE_SUCESSFUL, OnShareSucessEventHandler);
end

--结构化分享
function EventStructShare()
	--log("EventStructShare");
	--if _G.BP_Platform == BP_ENUM_PLAYFORM_WX then
	--	ShareMgr:shareWechat(MEDIA_TAG_SHARE_INVITE, "结构化分享测试", "structshare");
	--elseif _G.BP_Platform == BP_ENUM_PLAYFORM_QQ then
	--	ShareMgr:shareQQ(MEDIA_TAG_SHARE_INVITE, "结构化分享测试", ShareType.Friend);
	--end
	log("test livebroadcast");
	LuaClassObj.HandleUIMessage(bp_live_broadcast, "UIShow");
end

--分享给好友
function EventShareToFriend()
	--log("EventShareToFriend");
	--local params = {};
	--params.openid = DataMgr.roleData.openID;
	--ShareMgr:shareToFriend(params);
	----
	log("EventShowItemShare");
	local arrayItemData = {};
	table.insert(arrayItemData, {res_id = 404003, count = 1});
	CommonItemGetUI:ShowPanel(arrayItemData);
end


-- 获取登录类型配置
function EventShareGetLoginCfgEnabled()
    local strRegion = Client.GetPublishRegion() ;
    --log("EventShareGetLoginCfgEnabled strRegion:"..strRegion);
    BP_SHARE_WX_CFG_ENABLED = false;
	BP_SHARE_VK_CFG_ENABLED = false;
	BP_SHARE_LINE_CFG_ENABLED = false;
	BP_SHARE_QQByiTOP_CFG_ENABLED = false;

    local cfg = FuncUtil.GetLoginTypeTable(strRegion);
    if cfg ~= nil then

        -- wechat 插入到排序列表
        if (cfg.wechat ~= "0" and cfg.wechat ~= 0) then
        	BP_SHARE_WX_CFG_ENABLED = true;
        end

        -- vk 插入到排序列表
        if (cfg.vk ~= "0" and cfg.vk ~= 0) then
            BP_SHARE_VK_CFG_ENABLED = true;
        end

        -- Line 插入到排序列表
        if (cfg.line ~= "0" and cfg.line ~= 0) then
            BP_SHARE_LINE_CFG_ENABLED = true;
        end

		-- qq 插入到排序列表
        if (cfg.qq ~= "0" and cfg.qq ~= 0) then
            BP_SHARE_QQByiTOP_CFG_ENABLED = true;
        end
    end

end
