WardrobeIndexSystem = WardrobeIndexSystem or
		{
			UIRoot_Common_Get = nil,
			first_tab = 4, 		--第一个要显示的页签	--默认为最大6
			is_have_decompose_item = false,
		}

function WardrobeIndexSystem.Init()
	WardrobeIndexSystem.first_tab = 4
	WardrobeIndexSystem.is_have_decompose_item = false
end

--判定是否弹出分解优化弹窗
function WardrobeIndexSystem.JudgeIsShow()
	if WardrobeUI.isShowNewBee or WardrobeUI.isShowVoiceGuild then
		log("WardrobeIndexSystem only one ")
		return false
	end
	local PlayerPrefs = slua.loadClass("/Game/UMG/UI_Utility/PlayerPrefs.PlayerPrefs")
	if PlayerPrefs then
		PlayerPrefs = PlayerPrefs:LoadData()
		local TriggerTimeStamp = PlayerPrefs:GetDecomposeIndexTriggerTime()
		if TriggerTimeStamp then
			log("TriggerTimeStamp " .. tostring(TriggerTimeStamp))
			if TriggerTimeStamp > 0 then
				local gap_time = FuncUtil.GetServerTimeInSec() - TriggerTimeStamp
				log("gap_time " .. tostring(gap_time))
				if gap_time < 86400 * 7 then	--7天内只显示1次
					return false
				end
			end
		end
	end
	WardrobeIndexSystem.Init()
	local depose_total_num = 0

	--log_tree("DataMgr.arrayHallDepotItemInfo",DataMgr.arrayHallDepotItemInfo)
	for i, v in pairs(DataMgr.arrayHallDepotItemInfo) do
		local deposeinfo,isvalid = DecomposeSystem.GetItemDecomposeInfo(v.resID)
		if isvalid and deposeinfo then
			--log("vv " .. tostring(v.resID))
			--log("vcount " .. tostring(v.count))
			--log("vvalidHours " .. tostring(v.validHours))
			--log("vitemSubType " .. tostring(v.itemSubType))
			if v.validHours > 0 then
				depose_total_num = depose_total_num + v.count
				WardrobeIndexSystem.is_have_decompose_item = true
			else
				if v.ItemType ~= 1 and v.ItemType ~= 9 and v.ItemType ~= 4 and v.itemSubType ~= 701 and v.count > 1 then
					--log("vmainTabType " .. tostring(v.mainTabType))
					depose_total_num = depose_total_num + v.count - 1
					if v.mainTabType < WardrobeIndexSystem.first_tab then
						WardrobeIndexSystem.first_tab = v.mainTabType
						WardrobeIndexSystem.is_have_decompose_item = true
					end
				end
			end
			--log("depose_total_num" .. tostring(depose_total_num))
		end
	end
	log("WardrobeIndexSystem.first_tab " .. tostring(WardrobeIndexSystem.first_tab))
	log("depose_total_num : " .. tostring(depose_total_num))
	if DataMgr.GetSystemConfig("WardrobeDecomposeTriggerNum") then
		log("WardrobeDecomposeTriggerNum " .. tostring(DataMgr.GetSystemConfig("WardrobeDecomposeTriggerNum")))
		local WardrobeDecomposeTriggerNum = tonumber(DataMgr.GetSystemConfig("WardrobeDecomposeTriggerNum"))
		if WardrobeDecomposeTriggerNum then
			if depose_total_num >= WardrobeDecomposeTriggerNum then
				return true
			end
		end

	end
	return false
end

----获取可分解物品总数量
--function WardrobeIndexSystem.GetCouldDecomposeNum()
--	local isTimeLimit = BP_ARRAY_ItemDecomposeTab[BP_ItemDecompose_TabIndex + 1].bTimeLimit;
--
--	local itemList = ItemDecomposeUI.GetDecomposeItemList(BP_ItemDecompose_TabIndex + 1, isReLoadItem, isTimeLimit);
--end
function WardrobeIndexSystem.GetDefault_ItemDecompose_TabIndex()
	if 	WardrobeIndexSystem.is_have_decompose_item then
		log("WardrobeIndexSystem.first_tab-1 " .. tostring(WardrobeIndexSystem.first_tab-1))
		return WardrobeIndexSystem.first_tab-1
	else
		return 0
	end
	
end
function WardrobeIndexSystem.Show()
	log(" WardrobeIndexSystem.Show()")
	local title = FuncUtil.GetLocalizeResStr(5077)

	local tips = GlobalData.GetLocalizeStringWithNum(6808,0,tostring(DataMgr.GetSystemConfig("WardrobeDecomposeTriggerNum")))
	CommonMessageBoxUI:ShowPanel(2, title, tips,
			function()

				EventclickDecompose()
				WardrobeIndexSystem.AfterShow()
			end,
			nil);
	local PlayerPrefs = slua.loadClass("/Game/UMG/UI_Utility/PlayerPrefs.PlayerPrefs")
	if PlayerPrefs then
		log("FuncUtil.GetServerTimeInSec() " .. tostring(FuncUtil.GetServerTimeInSec()))
		PlayerPrefs.SetDecomposeIndexTriggerTime(FuncUtil.GetServerTimeInSec())
	end
end

--处理展示了分解界面的后续逻辑
function WardrobeIndexSystem.AfterShow()
	local UIRoot_bp_item_decompose = UIUtil.GetWidgetByLogicName("bp_item_decompose")
	if UIRoot_bp_item_decompose then
		log("findbp_item_decompose ")

		UIRoot_bp_item_decompose:ChangeTabState(WardrobeIndexSystem.first_tab-1)
		for i, item in pairs(BP_ARRAY_DecomposeItemList) do
			item.isSelect = true;
			item.count = item.total
		end

		ItemDecomposeUI.UpdateItemList(false, true, false);
		ItemDecomposeUI.UpdateChooseInfo(true);
	end
end