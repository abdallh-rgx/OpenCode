
ShopGiftViewUI = ShopGiftViewUI or 
		{
			
		}

--注册Widget
function bp_shop_gift_view_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_shop_gift_view,
		{{Path="/Game/UMG/UI_Logic/Shop/Shop_Gift/Shop_GetGift_View_BP.Shop_GetGift_View_BP_C", Container="Default", ZOrder=BP_ENUM_UI_MAIL_ZORDER+10}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function ShopGiftViewUI.PlayGetGiftView()
	LuaClassObj.HandleDynamicCreation(bp_shop_gift_view);
	LuaClassObj.HandleUIMessage(bp_shop_gift_view, "PlayGetGiftView");
	
	UIManager.Show(eUIType.eShopGiftViewUI)
end

function ShopGiftViewUI.UIShowGetGift()
	LuaClassObj.HandleDynamicCreation(bp_shop_gift_view);
	LuaClassObj.HandleUIMessage(bp_shop_gift_view, "UIShowGetGift");

	UIManager.Show(eUIType.eShopGiftViewUI)
end


function ShopGiftViewUI.HideUI()
	LuaClassObj.HandleUIMessageNoFetch(bp_shop_gift_view, "UIHideGetGift");
	UIManager.Hide(eUIType.eShopGiftViewUI)
end

function EventShopGiftViewUI_HideUI()
	ShopGiftViewUI.HideUI()
end
