-- sami 新版商城绑定手机界面UI
StoreBindPhoneUI = StoreBindPhoneUI or
{
	
}


BP_Store_Bind_Phone_OpenUrl = ""        --打开h5界面的url

--绑定手机获得道具列表
BP_STRUCT_Store_Bind_Phone_Item =
{
	itemId = 0,
	leftTime = 0,
}
BP_ARRAY_Store_Bind_Phone_Item_List = {
	BP_STRUCT_Store_Bind_Phone_Item = _G.BP_STRUCT_Store_Bind_Phone_Item,
}



--注册Widget
function bp_store_bind_phone_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_store_bind_phone,
        {{Path="/Game/UMG/UI_Logic/Store/Store/StoreBindPhoneLogicUI_BP.StoreBindPhoneLogicUI_BP_C", Container="Default", ZOrder=0}},
        {"Lobby"},
        false, 
	false,
        true
    );
end


--sami 初始化显示
function StoreBindPhoneUI.Init()
    log("StoreBindPhoneUI.Init")

	local items = {911400012}
	BP_ARRAY_Store_Bind_Phone_Item_List = {	}
	for k,v in pairs(items) do
		local item = {}
		item.itemId = v
		item.leftTime = 7*24*3600
		table.insert(BP_ARRAY_Store_Bind_Phone_Item_List, item)
	end
	
	LuaClassObj.HandleDynamicCreation(bp_store_bind_phone);
	LuaClassObj.HandleUIMessageNoFetch(bp_store_bind_phone, "UIShow");
	LuaClassObj.HandleUIMessageNoFetch(bp_store_bind_phone, "UpdateUI");
	UIManager.Show(eUIType.eStoreBindPhone)
	--EventSystem:registEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, StoreMainUI.OnTabListInfo);
end

-- 点击关闭按钮
function EventStoreBindPhone_Close()
	log("EventStoreBindPhone_Close")
	--EventSystem:unregistEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_LIST, StoreMainUI.OnTabListInfo);
	UIManager.Hide(eUIType.eStoreBindPhone)
	LuaClassObj.HandleUIMessageNoFetch(bp_store_bind_phone, "UIHide");
end


--首次绑定手机
function EventStoreBindPhone_ClickBindPhone()
	log("EventStoreBindPhone_ClickBindPhone")
	local language = Client.GetCurrentLanguage()
	local nation = LoginSystem.ip_region
	local bindingUrl = "https://www.pubgmobile.com/act/a20181022h5bind/mobile.html";
	local nickName = DataMgr.roleData.nickName
	nickName = SettingInformationUI.URLEncode(SettingInformationUI.URLEncode(nickName))
	BP_Store_Bind_Phone_OpenUrl = bindingUrl.."?language="..language.."&nation="..nation.."&nickName="..nickName;
	log("BP_Store_Bind_Phone_OpenUrl="..BP_Store_Bind_Phone_OpenUrl)
end


