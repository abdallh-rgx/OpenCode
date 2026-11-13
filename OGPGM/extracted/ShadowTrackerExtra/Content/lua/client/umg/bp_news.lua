  NewsUI = NewsUI or 
{
    isShow = false
}
BP_ARRAY_NewsItem_IDS = {
    itemid = 0
}
BP_CurrentClickedItemId = 0
BP_News_Show_Title = ""
BP_News_Show_Content = ""
BP_News_Show_Pos = 0
  --注册Widget
function bp_news_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_news,
    {{Path="/Game/UMG/UI_Logic/Common/logic_Common_News_BP.logic_Common_News_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BINDFB_ZORDER}},
	{"Lobby"},
	false,
	false,
	true
    );
end
function NewsUI.SetNewsItem( itemidlist )
    BP_ARRAY_NewsItem_IDS = itemidlist

    log_tree("zino bpnews itemidlist",BP_ARRAY_NewsItem_IDS)
end
local function localText(id)
    local data = Client.GetTableData("LocalizeRes",id);
    if data then
        return data.TextValue
    end
    return ""
end
--去根据点击的ITEMID 去拿 对应的页签信息做跳转
function EventClickItem(  )
    -- body
    if BP_CurrentClickedItemId > 0 then
        log("yes ID     zino     " .. BP_CurrentClickedItemId)
        --拿信息
        local shopInfo = MallSystem.getTabInfoByItemID(BP_CurrentClickedItemId)
         if shopInfo == nil then
            --自己跳到商城
            --log("zino not get mall info")
            EventOpenMallSystem()
            LuaClassObj.HandleUIMessageNoFetch(bp_news, "UIHide");
            return
        end
        --log_tree("zino...",shopInfo)
        local tap1 = shopInfo.first_tab
        local tap2 = shopInfo.second_tab
        local params = {
            ["Tab1"] = tap1,
            ["Tab2"] = tap2,
            ["isForceTab2"] = true,
            ["itemId"] = BP_CurrentClickedItemId,
            --["selectShopId"] = shopInfo.shop_id,
        };
        --log_tree("zino shopparams",params)
        LuaClassObj.HandleUIMessageNoFetch(bp_news, "UIHide");
        EventSystem:postEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MALL_CHILD, params)
        

    else
        log("no ID     zino")
    end
end
