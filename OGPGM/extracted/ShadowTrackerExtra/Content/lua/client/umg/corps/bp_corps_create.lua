-- 军团创建UI
CorpsCreateUI = CorpsCreateUI or 
{
	InitedData = false,
	ProvinceCityMap = {},
	CorpsCreate_City_ID = "",
}

BP_CorpsCreate_Province_Current = ""

BP_CorpsCreate_City_Current = ""

BP_ARRAY_CorpsCreate_ProvinceList =
{
	Province = ""
}


BP_ARRAY_CorpsCreate_CityList =
{
	City = ""
}

BP_CorpsCreate_Name = ""

BP_CorpsCreate_Announcement = ""

BP_CorpsCreate_Currency_Own = ""

BP_CorpsCreate_Currency_Price = 0

BP_CorpsCreate_Currency_Icon_ID = 0
BP_CorpsCreate_Currency_Icon_Text = ""
BP_CorpsCreate_Currency_Icon_ColourID = 0

--注册Widget
function bp_corps_create_RegisterUI()
  LuaClassObj.SubUIWidgetList(bp_corps_create,
    {{Path="/Game/UMG/UI_Logic/Corps/CorpsCreate_BP.CorpsCreate_BP_C", Container="Default", ZOrder=BP_ENUM_UI_CORPS_ZORDER +1}},
    {"Lobby"},
	false,
	false,
	true
  );
  BP_CorpsCreate_Currency_Icon_ID =2001001
  BP_CorpsCreate_Currency_Icon_Text = "NAME"
  BP_CorpsCreate_Currency_Icon_ColourID = 10001
  CorpsUI.RegisterPanelEvent(2,EventCorpsCreateShowUI,EventCorpsCreateHideUI)
end

function EventCorpsCreateShowUI()	
	log("EventCorpsCreateShowUI");
	BP_CorpsCreate_Currency_Icon_ID =2001001
 	BP_CorpsCreate_Currency_Icon_Text = "NAME"
 	BP_CorpsCreate_Currency_Icon_ColourID = 10001
  	BP_CorpsCreate_Currency_Price = CorpsMgr.GetCorpsConfig("CreateCorpsCostGold")
	BP_CorpsCreate_Currency_Own =  tostring(DataMgr.gold)

	if CorpsCreateUI.InitedData == false then
		CorpsCreateUI.InitedData = true
		CorpsCreateUI.InitData()
	end

	LuaClassObj.HandleDynamicCreation(bp_corps_create);
	LuaClassObj.HandleUIMessage(bp_corps_create, "UIShow")
	UIManager.Show(eUIType.eCorpsCreateUI)

end

function EventCorpsCreateHideUI()
	log("EventCorpsCreateHideUI");
	BP_CorpsCreate_Name = ""

	BP_CorpsCreate_Announcement = ""
	CorpsIconSelectUI.ClearSelection()
	UIManager.Hide(eUIType.eCorpsCreateUI)
	LuaClassObj.HandleUIMessage(bp_corps_create, "UIClose")
end

function CorpsCreateUI.InitData()
	CorpsCreateUI.ProvinceCityMap  = {}
	BP_ARRAY_CorpsCreate_ProvinceList = {}
	BP_ARRAY_CorpsCreate_CityList = {}

--填入默认值
	-- CorpsUI.ProvinceCityMap["--"] = {}
	-- table.insert(CorpsUI.ProvinceCityMap["--"],"--")
	local tableSortedList = {}
	local tableData = Client.GetTable("SocialCardCity")
	for k,v in pairs(tableData) do
		table.insert(tableSortedList,v)
	end
	table.sort(tableSortedList, function(a,b) return a.ID < b.ID end)

	for _,data in ipairs(tableSortedList) do
		CorpsCreateUI.ProvinceCityMap[data.City1]  = CorpsCreateUI.ProvinceCityMap[data.City1]  or {}
		table.insert(CorpsCreateUI.ProvinceCityMap[data.City1],data.City2)
	end

	local lastProvince = ""
	for _,data in ipairs(tableSortedList) do
		if data.City1 ~= lastProvince then
			table.insert(BP_ARRAY_CorpsCreate_ProvinceList,data.City1)
			lastProvince = data.City1
		end
	end

end

function EventFilerCitys_Push()
	BP_ARRAY_CorpsCreate_CityList = CorpsCreateUI.ProvinceCityMap[BP_CorpsCreate_Province_Current]
end

function EventCorpsCreateFetchInfo()
end

function EventOpenCorpsIconSelectPanel()
	BP_CorpsIconCurUseId = BP_CorpsCreate_Currency_Icon_ID
	BP_CorpsCurIconText = BP_CorpsCreate_Currency_Icon_Text
	BP_CorpsCurIconColourId = BP_CorpsCreate_Currency_Icon_ColourID
	CorpsIconSelectUI.ShowUI()
end

function FindCityIDByCityName(str)
		local tableData = FuncUtil.GetRegionConfigTable();
		for _,data in pairs(tableData) do
			if data.RegionName == str then
				return data.RegionCode
			end
		end

		return ""
end

function EventOnCorpsCreateButtonClicked_Push()
	if BP_CorpsCreate_Name == "" then
		DataMgr.ShowNoticeByID(410044);
		return
	end

	BP_CorpsCreate_Name = FuncUtil:StrTrim(BP_CorpsCreate_Name);	--去除两头的空格

	-- 支持空格,不支持特殊符号
	illegal,len,_ = FuncUtil:CheckName(BP_CorpsCreate_Name, true, 14, true)
	if illegal then 
		DataMgr.ShowNoticeByID(411019);
		return
	end

	if len > 14  then
		DataMgr.ShowNoticeByID(411017);
		_,_,str = FuncUtil:CheckName(BP_CorpsCreate_Name, true, 14, true)
		BP_CorpsCreate_Name = str
		CorpsCreateUI.UpdateCorpsName()
		return
	end

	if DataMgr.gold < BP_CorpsCreate_Currency_Price then
		DataMgr.ShowNoticeByID(410043);
		-- DataMgr.ShowNoticeByString("您的金币不足，无法创建军团。")
		return
	end

	if BP_CorpsCreate_City_Current ~= "" then
		CorpsCreateUI.CorpsCreate_City_ID = FindCityIDByCityName(BP_CorpsCreate_City_Current)
	end

	local strTile = Client.GetTableData("LocalizeRes", 111326).TextValue
	local strMsg = string.format(DataMgr.GetMultiLineMsgByID(111327), BP_CorpsCreate_Name,BP_CorpsCreate_Currency_Price);
	CommonMessageBoxUI:ShowPanel(2, strTile, strMsg, CorpsCreateUI.ClickOkCallback, nil);	
end

function CorpsCreateUI.ClickOkCallback()
	CorpsMgr.CreateCorpsReq()
end

function EventCorpsCreateUIFilterName()
	BP_CorpsCreate_Name = FuncUtil:StrTrim(BP_CorpsCreate_Name);	--去除两头的空格
	_,_,BP_CorpsCreate_Name = FuncUtil:CheckName(BP_CorpsCreate_Name,true, 14, true)
	_,_,BP_CorpsCreate_Announcement = FuncUtil:CheckName(BP_CorpsCreate_Announcement,nil,60)
	CorpsCreateUI.UpdateCorpsName()
end

function EventCorpsTaskHelpShow()
	log("function EventCorpsTaskHelpShow()")
	local strMsg = DataMgr.GetMultiLineMsgByID(4226)
	..DataMgr.GetMultiLineMsgByID(4812)
	..DataMgr.GetMultiLineMsgByID(4229)
	..DataMgr.GetMultiLineMsgByID(4813)
	..DataMgr.GetMultiLineMsgByID(4814)
	..DataMgr.GetMultiLineMsgByID(4232)
	..DataMgr.GetMultiLineMsgByID(4815)
	..DataMgr.GetMultiLineMsgByID(4816)
	..DataMgr.GetMultiLineMsgByID(4817)
	..DataMgr.GetMultiLineMsgByID(4818)
	..DataMgr.GetMultiLineMsgByID(4235)
	..DataMgr.GetMultiLineMsgByID(4236)
	..DataMgr.GetMultiLineMsgByID(4819)
	..DataMgr.GetMultiLineMsgByID(4820)
	..DataMgr.GetMultiLineMsgByID(4242)
	..DataMgr.GetMultiLineMsgByID(4821)
	..DataMgr.GetMultiLineMsgByID(4822)
	..DataMgr.GetMultiLineMsgByID(4823)
	PopUpNoticeUI.ShowMessageBox(Client.GetTableData("LocalizeRes", 410041).TextValue, strMsg)
	-- PopUpNoticeUI.ShowMessageBox("帮助","Surprise！！")
end

function CorpsCreateUI.UpdateCorpsName()
	LuaClassObj.HandleUIMessage(bp_corps_create, "UpdateCorpsName")
end

function CorpsCreateUI.UpdateCorpsIcon(ID,iconText,colourId)
	BP_CorpsCreate_Currency_Icon_ID = ID
	BP_CorpsCreate_Currency_Icon_Text = iconText
	BP_CorpsCreate_Currency_Icon_ColourID = colourId
	LuaClassObj.HandleUIMessage(bp_corps_create, "UpdateCorpsIcon")
end