StarterPackUI = StarterPackUI or
{
    bShouldSlap = false,    
    sStarterpackPriceDesc = "",
}

BP_STRUCT_StarterPackUI_Info =
{
    name = "",
    status = 0,
    itemName = "",
    itemImage = "",
    startTime = 0,
    timeRemaining = 0,
}

BP_Request_StarterPack_Price = "";    -- Starter pack Price
BP_Request_StarterPack_RewardUC = "";    -- Starter pack Price
BP_String_StarterPack_ActiveTime = "";
BP_String_StarterPack_RemainingTime = "";


function EventStarterPackShowUI()	
	StarterPackUI.ShowUI();
end

function EventStarterPackHideUI()
	StarterPackUI.HideUI();	
end


function StarterPackSignUpReq()
end

function StarterPackUpdateUI()
    StarterPackUI.UpdateUI();
end



function EventOnClickPurchaseBtn()
	if StarterPackUI.sStarterpackPriceDesc == nil or StarterPackUI.sStarterpackPriceDesc == "" then
		return
	end
	--StarterPackUI.HideUI();
	StarterPackSystem.StartDirectPurchase();
end

function StarterPackUI.UpdateUI()
    if not StarterPackUI.IsUIShow then
        return;
    end

    --LuaClassObj.HandleUIMessage(bp_eightday, "UpdateUI");
end


function StarterPackUI.GetActivityData()
    return DataMgr.GetActivityByType(ActivityType["STARTER_PACK_US"]);
end


-- update UI info
function StarterPackUI.ProcessProductRewardInfo(desc)
	--StarterPackUI.sStarterpackPriceDesc = desc;
	BP_Request_StarterPack_RewardUC = desc;
	LuaClassObj.HandleUIMessage(bp_starterpack, "UpdateStarterpackRewardUC");
	log("bp_starterpack get reward UC" .. tostring(desc));
end

function StarterPackUI.ProcessProductDesc(desc)
	StarterPackUI.sStarterpackPriceDesc = desc;
	BP_Request_StarterPack_Price = desc;
	LuaClassObj.HandleUIMessage(bp_starterpack, "UpdateStarterpackPrice");
	log("bp_starterpack get price" .. tostring(desc));
end

function StarterPackUI.OnGetProductPrice()
	StarterPackUI.ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	StarterPackUI.ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
end


function StarterPackUI.OnGetProductDesc()
	StarterPackUI.ProcessProductDesc(StarterPackSystem.GetPriceDesc());
	StarterPackUI.ProcessProductRewardInfo(StarterPackSystem.GetUCRewardsDesc());
end

--




function StarterPackUI.SetStarterPackUIShowOffCountToSaveData()
	LuaClassObj.HandleUIMessage(bp_starterpack, "SetStarterPackShowOffCount");
end


function StarterPackUI.OnJumpUrl(eventType, eventID, vars)
		log("StarterPackUI.OnJumpUrl");
		
		--if StarterPackSystem.IsOpen() == false then
		if StarterPackSystem.StaticEnabled == false then
				return;
		end
		if StarterPackSystem.Enabled == false then
				return;
		end
		
		if StarterPackSystem.bShowFinalOfferUI == true then
			--telemetry system
			StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.FINAL_POPWINDOW,true);
			
			StarterPackUI.ShowFinalUI();
		else
			--telemetry system
			StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.POPWINDOW,true);
			
    	StarterPackUI.ShowUI();
    	
    	StarterPackUI.ProcessProductDesc(StarterPackSystem.GetPriceDesc());
    	
    	--update local savedata
    	local iCounter = StarterPackSystem.iCurrentPopupCount + 1;
    	log("save local data on popup  " .. iCounter)
    	StarterPackSystem.SaveStarterPackUIShowOffCountBySaveData(iCounter);
    	
    	EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_INFO_UPDATED,StarterPackUI.OnGetProductDesc);
    	EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_PRICE_UPDATED,StarterPackUI.OnGetProductPrice);
    	EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_TIME_LIMIT_UPDATED,StarterPackUI.UpdateUICountDown);
    	EventSystem:registEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED,StarterPackUI.OnStarterPackIsOpenChanged);
    	
    	--telemetry system
		GemReportUtils.ReportEventImmediate(GemReportUtils.EventName_StarterPack, GemReportUtils.SubEventName_StarterPackPopUp)
    end
end


function StarterPackUI.OnStarterPackIsOpenChanged()
	local bStarterPackValid = StarterPackSystem.IsOpen();
    if bStarterPackValid == false then    
    	StarterPackUI.HideUI();
	end
end

function StarterPackUI.OnActivityChange()
    log("StarterPackUI.OnActivityChange");
    StarterPackUI.UpdateUI();
end

function StarterPackUI.ShowFinalUI()
	--StarterPackSystem.OpenUnlockStarterPackPanel();
	StarterPackSystem.OpenStarterPackFinalOfferUI(StarterPackUI.FinallizeFinalUI);
end


function StarterPackUI.UpdateUICountDown(sTimeRemain)
	BP_String_StarterPack_RemainingTime = StarterPackSystem.sStarterPack_RemainingTime;
	LuaClassObj.HandleUIMessage(bp_starterpack, "UpdateLabelTimeLeft");
end
function StarterPackUI.ShowUI()
		log("StarterPackUI Show UI")

    LuaClassObj.HandleDynamicCreation(bp_starterpack);
    LuaClassObj.HandleUIMessage(bp_starterpack, "UIShow");
		
end




function StarterPackUI.ResetData()
    StarterPackUI.IsFirstShow = true; 
end

function StarterPackUI.FinallizeFinalUI()
	StarterPackUI.IsUIShow = false;
    log("StarterPackUI HideFinalUI");
    FaceSlapSystem.ShowNext(BP_ENUM_MODULE_STARTER_PACK);
end

function StarterPackUI.HideUI()
    StarterPackUI.IsUIShow = false;
    log("StarterPackUI HideUI");
    StarterPackSystem.SetPurchaseUITrigger(StarterPackSystem.PurchaseTriggerUI.POPWINDOW,false);
    
    LuaClassObj.HandleUIMessage(bp_starterpack, "UIHide");
    EventSystem:unregistEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_INFO_UPDATED,StarterPackUI.OnGetProductDesc); --this is for price and reward info
    EventSystem:unregistEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_DROPITEM_PRICE_UPDATED,StarterPackUI.OnGetProductPrice);--this is for price only
    EventSystem:unregistEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_TIME_LIMIT_UPDATED,StarterPackUI.UpdateUICountDown);
    EventSystem:unregistEvent(EVENTTYPE_SHOPLIMIT, EVENTID_SHOPLIMIT_STARTERPACK_ISOPEN_UPDATED,StarterPackUI.OnStarterPackIsOpenChanged);
    FaceSlapSystem.ShowNext(BP_ENUM_MODULE_STARTER_PACK);
end


function StarterPackUI.ShouldSlap()	
	if not StarterPackSystem.StaticEnabled then 
		return false
	end
	if not StarterPackSystem.Enabled then	
		return false;
	end

	log("StarterPackUI.ShouldSlap");
	
	--get data from activity table saved from server
	StarterPackSystem.UpdateDateFromServer();

	--update current status, showFinalUi, showStarterPack, etc.,  
	--because PreparePurchase will use this the should... value, so this should called before PreparePurchase
	StarterPackSystem.InitStatusOnStartup();  

	-- update purchase allow status, if not allow to update then return
	--StarterPackSystem.PreparePurchase();
	
	if StarterPackSystem.IsOpen() == false then
		StarterPackUI.bShouldSlap = false;
		return false;
	end
    
  if StarterPackSystem.bShowStarterPackUI == true or StarterPackSystem.bShowFinalOfferUI == true then    
  	StarterPackUI.bShouldSlap = true;
  	return true;
  else
  	StarterPackUI.bShouldSlap = false;  	
  	return false;
  end
  return false;  
end

function bp_starterpack_OnModeSwitched(gamestatus)
    log("bp_starterpack_OnModeSwitched : "..gamestatus);
    -- 回到登录场景清数据    
	if string.lower(gamestatus) == "lobby" then
	--[[
		if StarterPackSystem.bShowStarterPackUnlockUI == true then
			--解锁starterpack后，尝试取服务器购买信息
			StarterPackSystem.SetIsCouldPurchase(true)--设置starter pack 活动开启
						
			if StarterPackSystem.iStarterPackDirectPurchaseId == nil or StarterPackSystem.iStarterPackDirectPurchaseId == 0 then
				StarterPackSystem.bForceUpdatePurchaseInf = true
			else
				StarterPackSystem.ReqOpenDirectPurchase(StarterPackSystem.iStarterPackDirectPurchaseId)
			end

			log("on OnGameStateChange trying to OpenUnlockStarterPackPanel")
			StarterPackSystem.OpenUnlockStarterPackPanel()
			StarterPackSystem.bShowStarterPackUnlockUI = false
		end
		]]
    end
end

function bp_starterpack_RegisterUI()
    log("StarterpackUI.bp_starterPack_RegisterUI");
    if LuaClassObj == nil then
        log("luaClassObj is empty in starter pack");
    else
        LuaClassObj.SubUIWidgetList(bp_starterpack,
        {{Path="/Game/UMG/UI_Logic/StarterPack/StarterPack_BP.StarterPack_BP_c", Container="Default", ZOrder=BP_ENUM_UI_SIGNIN_ZORDER}},
        {"Lobby"},
        false,
		true,
		--bp_starterpack_OnModeSwitched ~= nil,
        true);
        EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_STARTER_PACK, StarterPackUI.OnJumpUrl);
    end
end