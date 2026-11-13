--活动UI
ActivtyUI = ActivtyUI or
{
	bShow = false,
	isFirstShow = true,
}

BP_STRUCT_SubActivtyItemInfo =
{
	itemId = 0, 
	count = 0,
	have_count = 0,
	expireTime = 0,

}

BP_ARRAY_SubActivtyDropList = 
{
	BP_STRUCT_SubActivtyItemInfo = _G.BP_STRUCT_SubActivtyItemInfo,
}

BP_ARRAY_SubActivtyCostList = 
{
	BP_STRUCT_SubActivtyItemInfo = _G.BP_STRUCT_SubActivtyItemInfo,
}

BP_STRUCT_SubActivtyInfo = 
{
	Key = "",
	ID = 0,
	Index = 0,
	Type = 0,
	Title = "",
	Status = 0,
	Total = 0,
	Progress = 0,
	IsCheckNotice = 0,
	ImgLink = "",
	IsShowExPage = false,
	CanGetTimes = 0,
	GlobalTotalNum = 0,
	GlobalPersonMaxGetNum = 0,
	ShowImgLink = "";
	BP_ARRAY_SubActivtyDropList = _G.BP_ARRAY_SubActivtyDropList,
	BP_ARRAY_SubActivtyCostList = _G.BP_ARRAY_SubActivtyCostList,
}

BP_ARRAY_SubActivtyList = 
{
	BP_STRUCT_SubActivtyInfo = _G.BP_STRUCT_SubActivtyInfo,
}

BP_STRUCT_ActivtyInfo = 
{
	ID = 0,
	Title = "",
	Desc = "",
	Detail = "",
	ImgUrl = "",
	ImgLink = "",
	StartTimeStr = "",
	EndTimeStr = "",
	LabelType = 0,
	LabelDesc = "",
	BP_ARRAY_SubActivtyList = _G.BP_ARRAY_SubActivtyList,
}

BP_STRUCT_ActivtyInfo = _G.BP_STRUCT_ActivtyInfo
------------------------------------公告系统-----------------------------------
BP_STRUCT_NoticeInfo = 
{
	ID = 0,
	button_desc="",
	mark_type=0,
	mark_desc="",
	jump_button1 = "",
	jump_button2 = "",
	jump_mode1="",
	jump_mode2="",
	pic_url="",
	title="",
	content ="",
}

BP_STRUCT_NoticeInfo = _G.BP_STRUCT_NoticeInfo

BP_CurrentNoticeJumpMode = ""
BP_CurrentActJumpID = 0
BP_Duihuan_RedPoint_Num = 0
BP_First_Act_ID = 0
BP_First_Notice_ID = 0
BP_Question_Act_ID = 0 -- 新手问卷活动ID

------------------------------------------------------------------------------
--点击活动或者公告按钮函数
BP_STRUCT_ActivtyNoticeBtn_Select ={
	NowSelectNoticeID = 0,
	NowSelectActID = 0,
	NowIsSelectNotice = false,
};

BP_STRUCT_ActivtyNoticeBtn_Select = _G.BP_STRUCT_ActivtyNoticeBtn_Select
------------------------------------------------------------------------------

BP_Panduola_Init = false	--潘多拉初始化
BP_Panduola_RedPoint = -1	--潘多拉小红点

--点击子函数按钮函数
BP_STRUCT_ActivtyInfo_Click ={
	SubActID = 0,
	SubActIndex = 0,
	SubActType = 0,
	Arg = 0,
};

BP_STRUCT_ActivtyInfo_Click = _G.BP_STRUCT_ActivtyInfo_Click
---------------------活动按钮结构--------------------------------------
BP_STRUCT_ActButtonInfo = 
{
	ActID = 0,
	IsRedPoint = false,
	Btn_Name = "",
	Btn_Type = 0,
	Btn_TypeName = "",
}
BP_ARRAY_ActButtonInfo =
{
	BP_STRUCT_ActButtonInfo = _G.BP_STRUCT_ActButtonInfo
}

---------------------公告按钮结构--------------------------------------
BP_STRUCT_NoticeButtonInfo = 
{
	NoticeID = 0,
	IsRedPoint = false,
	Btn_Name = "",
	Btn_Type = 0,
	Btn_TypeName = "",
}
BP_ARRAY_NoticeButtonInfo =
{
	BP_STRUCT_NoticeButtonInfo = _G.BP_STRUCT_NoticeButtonInfo
}

ActivtyUI.H5LeagueGameActivityID = 181030501;
ActivtyUI.KR_H5LeagueGameActivityID = 2189915;

---------------------世界杯活动引入的可选奖品兑换活动-----------------------
BP_ARRAY_SelectExchangeActID =
{
	ActID = 0
}

BP_ActExchangeSelectIndex = 0 -- 选中了哪一个
BP_Is_Not_Login = 0;
BP_Img_Link = "";
local IsCouldGetReq = true
local IsFromLobby = false

-----------------------------------------------------基础函数部分--------------------------------------------------------------------------------
--注册Widget
function bp_activty_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_activty,
		{{Path="/Game/UMG/UI_Logic/Activty/Activty_BP.Activty_BP_C", Container="Default", ZOrder=BP_ENUM_UI_ACTIVITY_ZORDER}},
		{"Login","Lobby"},
		false,
		bp_activty_OnModeSwitched ~= nil,
		true
	);

	 ----log("lua --- bp_activty_RegisterUI")
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_ACTIVITY_CHANGE, ActivtyUI.RefreshUI) 
	EventSystem:registEvent(EVENTTYPE_DATA_MGR, EVNETID_DATAMGR_BULLETIN_CHANGE, ActivtyUI.RefreshUI) 
	EventSystem:registEvent(EVENTTYPE_URL, BP_ENUM_MODULE_ACTIVITY, ActivtyUI.JumpIn);
end
function ActivtyUI.SetIsFromLobby()
	-- body
	log("set is from lobby " .. tostring(IsFromLobby))
	IsFromLobby = true
end

function ActivtyUI.JumpIn(eventType, eventID, vars)
	LuaClassObj.HandleDynamicCreation(bp_activty);
	--log("活动界面收到跳转信息")
	LuaClassObj.HandleUIMessage(bp_activty, "TryToShowActivty");
	ActivtyUI.ResetShow();
	if vars and vars.id then
		BP_CurrentActJumpID = vars.id
		--log("BP_CurrentActJumpID ="..BP_CurrentActJumpID)
		LuaClassObj.HandleUIMessage(bp_activty, "JumpToActID");
	else
		----log("没有跳转的活动号码")
	end
end

function ActivtyUI.IsShow()
	return ActivtyUI.bShow
end

function EventActivtyOnShow()
	ActivtyUI.bShow = true
	ActivtyUI.isFirstShow = false
end

function EventActivtyOnClose()
	ActivtyUI.bShow = false
	--[[--log("EventActivtyOnClose BP_STRUCT_ActivtyInfo_Click.SubActType "..tostring(BP_STRUCT_ActivtyInfo_Click.SubActType))
	if BP_STRUCT_ActivtyInfo_Click.SubActType == 0 then
		FaceSlapSystem.OnStepFinished(FaceSlapSystem.Step_Activity)
		ActivitySystem.CheckPlayBtnFx()
	else
		-- 结束拍脸
		FaceSlapSystem.StopShow()
	end--]]
end


function ActivtyUI.RefreshUI()
	BP_Question_Act_ID = ActivitySystem.questionID
	log("ActivtyUI.RefreshUI question id=" .. BP_Question_Act_ID)
	ActivtyUI.LoadData()
end


-------------------------------------------------------------------------------------------------------------------------------------

function ActivtyUI.GetItemNum(itemID)
	if itemID == 1000 then
		return DataMgr.gold
	elseif itemID == 1003 then
		return DataMgr.roleData.roleExp
	else
		local itemData = DataMgr.GetHallDepotItemDataByResID(itemID)
		if itemData == nil then
			return 0
		else
			return itemData.count
		end
	end

	return 0
end

function ActivtyUI.ClearCurrentActivityData()
	BP_STRUCT_ActivtyInfo.ID = 0;
	BP_STRUCT_ActivtyInfo.Title = "";
	BP_STRUCT_ActivtyInfo.Desc = "";
	BP_STRUCT_ActivtyInfo.Detail = "";
	BP_STRUCT_ActivtyInfo.ImgUrl = "";
	BP_STRUCT_ActivtyInfo.ImgLink = "";
	BP_STRUCT_ActivtyInfo.StartTimeStr = "";
	BP_STRUCT_ActivtyInfo.EndTimeStr = "";
	BP_STRUCT_ActivtyInfo.LabelType = 0;
	BP_STRUCT_ActivtyInfo.LabelDesc = "";
	BP_STRUCT_ActivtyInfo.BP_ARRAY_SubActivtyList = {};
	log("[HHF]ActivtyUI.ClearCurrentActivityData, clear current showed activity.");
end

function ActivtyUI.LoadData()
	--log("LoadData")
	local is_lobby_show_red = false

	local need_push_to_bp = false
	BP_STRUCT_ActivtyInfo = {}
	BP_STRUCT_NoticeInfo = {}
	BP_ARRAY_ActButtonInfo = {}
	BP_ARRAY_NoticeButtonInfo = {}

	BP_Duihuan_RedPoint_Num = 0
	BP_First_Act_ID = -1
	BP_First_Notice_ID = -1

	BP_ARRAY_SelectExchangeActID = {}
	--log_tree("DataMgr.activity.data",DataMgr.activity.data)
	for _, activity in ipairs(DataMgr.activity.data) do
		-- 排除吃鸡盛典和新兵八天活动 只显示通用活动
		if activity and activity.Type ~= nil and 
			ActivityTypeInActivtyPage[activity.Type] == true	
			then
			activity.BP_ARRAY_SubActivtyList = {}

			local btn_info = {}
			btn_info.IsRedPoint = ActivitySystem.HasActivityRedDotByID(activity.ID)

			--[[if activity.Type == ActivityType["ITEM_EXCHANGE"] then
				log_tree("Exchange sub activity ", activity.List)
			end--]]

			---可以领取的排在最上面
			--log_tree("zino activity.List",activity.List)
			for k,v in pairs(activity.List) do
				if v and v.Status == 1 and v.Drop and v.Drop[1] and v.Drop[1].itemId ~= 0 then
					activity.BP_ARRAY_SubActivtyList[#activity.BP_ARRAY_SubActivtyList + 1] = v
					if btn_info.IsRedPoint and v.BP_ARRAY_SubActivtyCostList and #v.BP_ARRAY_SubActivtyCostList > 0 and v.IsCheckNotice == 1 then
						BP_Duihuan_RedPoint_Num = BP_Duihuan_RedPoint_Num + 1
					end
				end
			end
			for k,v in ipairs(activity.List) do	--可领取状态为0 有掉落list 
				if (v and v.Status == 0 and v.Drop and v.Drop[1] and v.Drop[1].itemId ~= 0)
					or v.Type == ActivityType["IMAGES_GROUP_SUB"] then
					activity.BP_ARRAY_SubActivtyList[#activity.BP_ARRAY_SubActivtyList + 1] = v
				end
			end
			for k,v in ipairs(activity.List) do
				if v and v.Status == 2 and v.Drop and v.Drop[1] and v.Drop[1].itemId ~= 0 then
					activity.BP_ARRAY_SubActivtyList[#activity.BP_ARRAY_SubActivtyList + 1] = v
				end
			end
			--log_tree("activity.BP_ARRAY_SubActivtyList",activity.BP_ARRAY_SubActivtyList)
			for _, subActivity in pairs(activity.List) do
				subActivity.BP_ARRAY_SubActivtyCostList = subActivity.CostList
				subActivity.BP_ARRAY_SubActivtyDropList = subActivity.Drop

				--是否显示二级确定框
				subActivity.IsShowExPage = false
				subActivity.CanGetTimes = 0

				--cost list 赋值
				for k,v in pairs(subActivity.BP_ARRAY_SubActivtyCostList) do
					if v then
						v.have_count = ActivtyUI.GetItemNum(v.itemId)
					end
				end

				--log("((("..activity.Type..tostring(BP_STRUCT_ActivtyNoticeBtn_Select.NowIsSelectNotice)..BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID);
				if activity.Type == ActivityType["ITEM_EXCHANGE"] and
					(not BP_STRUCT_ActivtyNoticeBtn_Select.NowIsSelectNotice) and activity.ID == BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID then
					local can_exchange_num = 0 --身上的数量足够兑换多少次
					for k,v in pairs(subActivity.BP_ARRAY_SubActivtyCostList) do
						if v then
							v.have_count = ActivtyUI.GetItemNum(v.itemId)

							if v.have_count > 0 and v.count > 0 then
								local temp_exchange_num = math.floor(v.have_count / v.count)
								--log("temp_exchange_num ="..temp_exchange_num)

								if can_exchange_num == 0 then
									can_exchange_num = temp_exchange_num
								else
									if can_exchange_num > temp_exchange_num then
										can_exchange_num = temp_exchange_num
									end
								end
							end
						end
					end

					--log("can_exchange_num ="..can_exchange_num)
					--log("subActivity.Total ="..subActivity.Total)
					--log("subActivity.Progress ="..subActivity.Progress)
					local letf_times = subActivity.Total - subActivity.Progress
					--log("letf_times ="..letf_times)

					--用户背包兑换物，能兑换道具1次或1次以上，自动弹出二次确认框
					if letf_times >= 1 and can_exchange_num >= 1 then
						subActivity.IsShowExPage = true
						subActivity.CanGetTimes = letf_times

						if can_exchange_num < subActivity.CanGetTimes then
							subActivity.CanGetTimes = can_exchange_num
						end
						--log("需要显示二级对话框 "..subActivity.Title)
						--log("最大兑换次数 "..subActivity.CanGetTimes)
					end
				end
			end

			-- 处理特殊兑换类型，将活动ID记录下来，防止重复
			local found = false
			if activity.SelectExchange == true then
				for i,v in ipairs(BP_ARRAY_SelectExchangeActID) do
					if v == activity.ID then 
						found = true
						break
					end
				end
				if not found then
					table.insert(BP_ARRAY_SelectExchangeActID, activity.ID)
				end
			end
			
			btn_info.ActID = activity.ID
			
			btn_info.Btn_Name = activity.Title
			btn_info.Btn_Type = activity.LabelType
			btn_info.Btn_TypeName = activity.LabelDesc

			if btn_info.IsRedPoint then
				is_lobby_show_red = true
			end

			BP_ARRAY_ActButtonInfo[#BP_ARRAY_ActButtonInfo + 1] = btn_info
			--log("[HHF]ActivtyUI.LoadData, show activity btn ID = " .. btn_info.ActID .. ", reddot = " .. tostring(btn_info.IsRedPoint));

			if BP_First_Act_ID > 0 then
				if not BP_STRUCT_ActivtyNoticeBtn_Select.NowIsSelectNotice and activity.ID == BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID then
					need_push_to_bp = true
					BP_STRUCT_ActivtyInfo = activity
				end
			end

			if BP_First_Act_ID < 0 then
				BP_First_Act_ID = activity.ID
				need_push_to_bp = true
				BP_STRUCT_ActivtyInfo = activity
			end
		end
	end

	log("BP_Duihuan_RedPoint_Num =================="..BP_Duihuan_RedPoint_Num)

	--log_tree("[TAL]=====BP_STRUCT_ActivtyInfo", BP_STRUCT_ActivtyInfo)
	--log_tree("[HHF]ActivtyUI.LoadData, select exchange act id ", BP_ARRAY_SelectExchangeActID)

	--公告数据
	local notice_id = 1
	for k,v in pairs(DataMgr.bulletin.data) do
		if v then
			v.ID = notice_id

			local btn_info = {}
			btn_info.NoticeID = v.ID
			btn_info.IsRedPoint = false
			btn_info.Btn_Name = v.button_desc
			btn_info.Btn_Type = v.mark_type
			btn_info.Btn_TypeName = v.mark_desc

			if btn_info.IsRedPoint then
				is_lobby_show_red = true
			end

			BP_ARRAY_NoticeButtonInfo[#BP_ARRAY_NoticeButtonInfo + 1] = btn_info
			--log("添加公告按钮 id= "..btn_info.NoticeID)

			if BP_First_Notice_ID > 0 then
				if BP_STRUCT_ActivtyNoticeBtn_Select.NowIsSelectNotice and v.ID == BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectNoticeID then
					need_push_to_bp = true
					BP_STRUCT_NoticeInfo = v
				end
			end

			if BP_First_Notice_ID < 0 then
				BP_First_Notice_ID = v.ID
				need_push_to_bp = true
				BP_STRUCT_NoticeInfo = v
			end

			notice_id = notice_id + 1
		end
	end

	log("BP_First_Act_ID ="..BP_First_Act_ID)
	--log("BP_First_Notice_ID ="..BP_First_Notice_ID)

	--更新大厅界面小红点
	log("活动红点 ActivtyUI.LoadData " .. tostring(is_lobby_show_red))
	UpdateLobbyActivityRedPoint(is_lobby_show_red)
	--潘多拉系统屏蔽公告
	if PandoraSystem.NoticeIsCanUse() then
		BP_ARRAY_NoticeButtonInfo = {}
		if PandoraSystem.ActHasRedPoint(PandoraSystem.Act_Id_Notice) then
			BP_Panduola_RedPoint = 1;
		else
			BP_Panduola_RedPoint = 0;
		end
	end

	if need_push_to_bp then
		local theType = -1;
		log("#########");
		log("LuaClassObj.HandleUIMessage(bp_activty, LoadLuaData);")
		log(BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID);

		if BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID ~= 0 then
			for _, subActivity in pairs(DataMgr.activity.activityListMap) do
				if subActivity.ID == BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID then
					theType = subActivity.Type;
					break;
				end
			end
		end

		log(theType);
		if theType == 13 and BP_STRUCT_ActivtyInfo.ImgUrl == "" then
			log_tree("BP_STRUCT_ActivtyInfo", BP_STRUCT_ActivtyInfo.List)
			--log("!!!!!!"..BP_STRUCT_ActivtyInfo.List.ShowImgLink)
			local selectActID = BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID;
    		local tempActivityTable = ActivitySystem.activityDataTable
    		if selectActID ~=0 then
				for activityId, activityData in pairs(tempActivityTable) do
					if activityId == selectActID then
						log("%%%%%%%%."..activityData.cfg.activity_image_link);
						BP_STRUCT_ActivtyInfo.ImgUrl = activityData.cfg.activity_image_link
						break;
					end
				end
			end
		end
		if theType ~= 13 and theType ~= 29 and theType ~= 32 and theType ~= 46 then
			BP_STRUCT_ActivtyInfo.ImgUrl = ""
		end

		LuaClassObj.HandleUIMessage(bp_activty, "LoadLuaData");
		LuaClassObj.HandleUIMessage(bp_activty, "UpdateUIAfterClickRightBtn");
		if theType ~= 13 and theType ~= 29 and theType ~= 32 and theType ~= 46 and BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID ~= 0 then
			--BP_STRUCT_ActivtyInfo.ImgLink = "https://pythonhosted.org/pgmagick/_images/transparent.png"
			BP_Is_Not_Login = BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID;
    		--NetUtil.SendPkg("get_activity_list_req")
    		local tempActivityTable = ActivitySystem.activityDataTable
    		if BP_Is_Not_Login ~=0 then
				for activityId, activityData in pairs(tempActivityTable) do
					if activityId == BP_Is_Not_Login then
						log("**********."..activityData.cfg.activity_image_link);
						BP_Img_Link = activityData.cfg.activity_image_link
						break;
					end
				end
				BP_Is_Not_Login = 0;
			end
			LuaClassObj.HandleUIMessage(bp_activty, "UpdateActivityImage");
		end
	end
end

function ActivtyUI.ResetShow()
	local bp = UIUtil.GetWidgetByName("bp_activty", "Activty_BP")
	if bp then
		bp:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible);
	end
	--LuaClassObj.HandleUIMessage(bp_activty, "ShowSelf");
end

function ActivtyUI.ResetHide()
	local bp = UIUtil.GetWidgetByName("bp_activty", "Activty_BP")
	if bp then
		bp:SetVisibility(UEnums.ESlateVisibility.Collapsed);
	end
	--LuaClassObj.HandleUIMessage(bp_activty, "HideSelf");
end

--------------------------------------------------------按钮响应部分------------------------------------------------------------------------------
--点击领取/兑换按钮
function EventActivtyUIOnClickGetBtn()
	--log("BP_CLICK_SubActID ="..BP_STRUCT_ActivtyInfo_Click.SubActID)
	--log("BP_CLICK_SubActIndex ="..BP_STRUCT_ActivtyInfo_Click.SubActIndex)
	--log("BP_CLICK_SubActType ="..BP_STRUCT_ActivtyInfo_Click.SubActType)

	local get_times = BP_STRUCT_ActivtyInfo_Click.Arg or 1
	if get_times < 1 then
		get_times = 1 
	end

	log("[HHF]EventActivtyUIOnClickGetBtn "..get_times)
	ActivitySystem.Req_TakeActivityAwardBatch(BP_STRUCT_ActivtyInfo_Click.SubActID, BP_STRUCT_ActivtyInfo_Click.SubActIndex, get_times)
end

--点击跳转按钮
function EventActivtyUIOnClickJumpBtn()
	log("[HHF]EventActivtyUIOnClickJumpBtn, subActType = " .. BP_STRUCT_ActivtyInfo_Click.SubActType);

	if BP_STRUCT_ActivtyInfo_Click.SubActType == 4 then
		local function clickOkCallback()
	        LobbyUI.CloseOtherMenu()
			--设备平台
	        local temp = string.lower(Client.GetDevicePlatformName())
			local strRegion = Client.GetPublishRegion();
			if strRegion == "JAPAN" or strRegion == "KOREA" then
				--日韩版
				if temp == "ios" then
					GlobalData:JumpUrl("https://itunes.apple.com/app/id1366526331")
				elseif temp == "android" then
					if Client.GetAOSSHOP() == 'Samsung' then
						GDolphinUpdater.Install(Dolphin)
					else
						GlobalData:JumpUrl("https://play.google.com/store/apps/details?id=com.pubg.krmobile")
					end
				else
					log("[TAL]===Client.GetDevicePlatformName() is "..temp)	            
				end
			elseif strRegion == "VNG" then
				--越南版
				if temp == "ios" then
					GlobalData:JumpUrl("https://itunes.apple.com/app/id1438396625")
				else 
					GlobalData:JumpUrl("https://play.google.com/store/apps/details?id=com.vng.pubgmobile")    
				end      
			elseif strRegion == "TW" then
				--台湾版
				if temp == "ios" then
					GlobalData:JumpUrl("https://itunes.apple.com/app/id1453363650")
				else
					GlobalData:JumpUrl("https://play.google.com/store/apps/details?id=com.rekoo.pubgm")    
				end      
			else
				--全球版
				if temp == "ios" then
					GlobalData:JumpUrl("https://itunes.apple.com/ca/app/id1330123889")
				elseif temp == "android" then
					if Client.GetAOSSHOP() == 'Samsung' then
						GDolphinUpdater.Install(Dolphin)
					elseif Client.GetAOSSHOP() == 'Amazon' then
						GlobalData:JumpUrl("https://play.google.com/store/apps/details?id=com.tencent.ig")
					else
						GlobalData:JumpUrl("https://play.google.com/store/apps/details?id=com.tencent.ig")
					end
				else
					log("[TAL]===Client.GetDevicePlatformName() is "..temp)	            
				end
			end

	        return
	    end
	    CommonMessageBoxUI:ShowPanel(2, FuncUtil.GetLocalizeResStr("101001"), FuncUtil.GetLocalizeResStr("4423"), clickOkCallback, nil)
		return
	elseif BP_STRUCT_ActivtyInfo_Click.SubActType == 55 then --如果是H5跳转在跳转的时候发请求通知服务器
		ActivitySystem.Req_DealActivity(BP_STRUCT_ActivtyInfo_Click.SubActID, BP_STRUCT_ActivtyInfo_Click.SubActIndex, BP_STRUCT_ActivtyInfo_Click.Arg);
		EventActivtyUIOnNoticeJump();
		return
	end

	--版本一 :策划要求跳转不关闭 看国内做的仅有的跳转，是不关闭的 逻辑保持一致 
	--版本二 :背包这种半屏界面显示叠加，后和策划商量修改 代码统一修改到EventActivtyUIOnNoticeJump()中
	
	--LuaClassObj.HandleUIMessage(bp_activty, "OnCloseBtn");

	--直接根据配置跳转
	EventActivtyUIOnNoticeJump()
end

function EventActivtyClickOneBtn()
	--log("点击活动或者公告按钮")--
	--IsFromLobby
	log("	IsFromLobby  " .. tostring(IsFromLobby))
	log("	BP_Lobby_MenuOpen  " .. tostring(BP_Lobby_MenuOpen))
	log("BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID   " .. BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID)
	log("DataMgr.activity.isInit  " .. tostring(DataMgr.activity.isInit))
	--log_tree("zino BP_STRUCT_ActivtyInfo", DataMgr.activity.activityListMap)

	for _, subActivity in pairs(DataMgr.activity.activityListMap) do
		--log("zino subactivity.GlobalTotalNum:" .. subActivity.GlobalTotalNum)
		if subActivity.ID == BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID 
		and subActivity.GlobalTotalNum~=nil and subActivity.GlobalTotalNum>0 then
			log("zino ininininininininnininininini")
			for _, activity in ipairs(DataMgr.activity.data) do
				if activity.Type == ActivityType["ITEM_EXCHANGE"] and BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID~=nil
				and activity.ID == BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID and IsCouldGetReq and not IsFromLobby then
					log_tree("zino activity",activity)
					ActivitySystem.Req_AcitvityOneData(activity.ID)
					IsCouldGetReq = false
					log("zinotest globalchange so return")
					ActivtyUI.timer2 = Timer.InsertTimer(60, ActivtyUI.HandleIsCouldGetReq, false)
					return
				end
			end		
	 	end
	end
	IsFromLobby = false
	log("	ActivtyUI.LoadData()==================")
	ActivtyUI.LoadData()
	
end
function ActivtyUI.HandleIsCouldGetReq()
	log("ActivtyUI.HandleIsCouldGetReq==================")
	IsCouldGetReq = true
end

function EventActivtyUIOnClickCheckExchange()
	--log("点击提醒按钮")
	--log("BP_CLICK_SubActID ="..BP_STRUCT_ActivtyInfo_Click.SubActID)
	--log("BP_CLICK_SubActIndex ="..BP_STRUCT_ActivtyInfo_Click.SubActIndex)
	--log("BP_CLICK_SubActType ="..BP_STRUCT_ActivtyInfo_Click.SubActType)
	--log("Arg ="..BP_STRUCT_ActivtyInfo_Click.Arg)

	ActivitySystem.Req_DealActivity(BP_STRUCT_ActivtyInfo_Click.SubActID, BP_STRUCT_ActivtyInfo_Click.SubActIndex, BP_STRUCT_ActivtyInfo_Click.Arg)
end

function EventActivtyUIOnNoticeJump()
	log("[HHF]EventActivtyUIOnNoticeJump, jumpMode = " .. BP_CurrentNoticeJumpMode);
	--内部界面跳转关闭当前活动界面
	if JumpUtils.IsGameJumpUrl(BP_CurrentNoticeJumpMode) then
		GlobalData:JumpUrl(BP_CurrentNoticeJumpMode)
		LuaClassObj.HandleUIMessage(bp_activty, "OnCloseBtn");
	elseif string.starts(BP_CurrentNoticeJumpMode, "http") or string.starts(BP_CurrentNoticeJumpMode, "www") then   -- 外部链接跳转不关闭活动界面
		local activity = {}
		for _, subActivity in pairs(DataMgr.activity.activityListMap)do
			if(subActivity.ID == BP_STRUCT_ActivtyNoticeBtn_Select.NowSelectActID)then
				activity = subActivity
			end
		end
		if(activity.Total == 1)then
			local webTicket = Client.GetWebViewTicket(NetInterface)
			log("QppWebTicket".. webTicket)
			local gameID = Client.GetITopGameId()
			local str = BP_CurrentNoticeJumpMode
			str = string.gsub(str, "{gameid}", gameID, 1)
			str = string.gsub(str, "{itop_openid}", DataMgr.roleData.openID, 1)
			str = string.gsub(str, "{itop_ticket}", webTicket, 1)
			str = string.gsub(str, "{game_season}", DataMgr.season_id, 1)
			str = string.gsub(str, "{game_area}", LobbySystem.matchZone, 1)
			log("Game Area:".. LobbySystem.matchZone)
			str = string.gsub(str, "{language}", tostring(Client.GetCurrentLanguage()), 1)
			GlobalData:JumpUrl(str);
		else
			local str = string.gsub(BP_CurrentNoticeJumpMode, "{openid}", DataMgr.roleData.openID, 1)
			GlobalData:JumpUrl(str)
		end
		
	else
		--log("不是game，http开头，调用函数")
		if BP_CurrentNoticeJumpMode ~= "" and _G[BP_CurrentNoticeJumpMode] then
			local func = _G[BP_CurrentNoticeJumpMode]
			func()
		end
		LuaClassObj.HandleUIMessage(bp_activty, "OnCloseBtn");
	end
end

function ActivtyShowQQDingYueBox()
	if DataMgr.qqsubscribe and DataMgr.qqsubscribe == 1 then
		--log("已经qq订阅")
		CommonMessageBoxUI:ShowPanel(1, "提示", "已经订阅", nil, nil)
		return
	end

	--log("调用qq订阅信息")
	local function clickOkCallback()
        --这里发送订阅协议
        --log("发送订阅协议")
        DataMgr.SendQQSubscribeRet()
    end
    CommonMessageBoxUI:ShowPanel(2, "提示", "是否QQ订阅？", clickOkCallback, nil)
end

function ActivtyShowDingYueBox()
	if DataMgr.wxsubscribe and DataMgr.wxsubscribe == 1 then
		--log("已经wx订阅")
		CommonMessageBoxUI:ShowPanel(1, "提示", "已经微信订阅", nil, nil)
		return
	end
	--log("调用订阅信息")
	local function clickOkCallback()
        --这里发送订阅协议
        --log("发送订阅协议")
        DataMgr.SendSubscribeRet()
    end
    CommonMessageBoxUI:ShowPanel(2, "提示", "是否订阅？", clickOkCallback, nil)
end

--大厅按钮添加小红点（蓝图回调，如果有未读的新活动）
function EventActivtyUpdateLobbyRedPoint()
	--log("大厅按钮添加小红点")
	UpdateLobbyActivityRedPoint(true)
end

-- 设置问卷活动已完成，并通过大厅记录本地文件
function EventSaveQuestionDone()
	log("activity set question done")
	ActivitySystem.questionDone = true
	LuaClassObj.HandleUIMessage(bp_lobby, "SaveLocalQuestionData")
end

function EventSelectExchangeItem()
	log("[HHF]EventSelectExchangeItem "..BP_ActExchangeSelectIndex);
	if BP_ActExchangeSelectIndex ~= 0 then
		ActivitySystem.Req_TakeSpecialActivityAward(BP_STRUCT_ActivtyInfo_Click.SubActID, BP_ActExchangeSelectIndex)
	end
end

function EventNoticeOpen_ToPDL()
	if PandoraSystem.NoticeIsCanUse() then
		--log("点击公告页签，通知潘多拉")
		-- local jsonStr = "{\"type\":\"Show\",\"content\":\"Notice\"}";
		-- PandoraSystem.SendCmd(jsonStr);
		PandoraSystem.SendShowNotice();
	end
end
function EventNoticeClose_ToPDL()
	if PandoraSystem.CheckSysOpen() then
		--log("关闭,通知潘多拉")
		-- local jsonStr = "{\"type\":\"Hide\",\"content\":\"Notice\"}";
		-- PandoraSystem.SendCmd(jsonStr);
		PandoraSystem.SendHideNotice();
	end
end

function EventRegistEvent()
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, ActivtyUI.ResetHide);
	EventSystem:registEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, ActivtyUI.ResetShow);
end

function EventUnRegistEvent()
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_OPEN, ActivtyUI.ResetHide);
	EventSystem:unregistEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_AVATAR_RESET_CLOSE, ActivtyUI.ResetShow);
end