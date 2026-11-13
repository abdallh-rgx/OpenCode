CorpsLocationEditorUI = {
	cityInfo = {}
}

BP_ARRAY_CorpsHomepageLocationCity = {
	city = ""
}

BP_ARRAY_CorpsHomepageLocationProvince = {
	province = ""
}

BP_CorpsHomepageLocationSelectCity = 0
BP_CorpsHomepageLocationSelectProvince = 0
function bp_corps_location_editor_RegisterUI()
    LuaClassObj.SubUIWidgetList(bp_corps_location_editor,
        {{Path = "/Game/UMG/UI_Logic/Corps/CorpsLocation_BP.CorpsLocation_BP_c", Container = "Default", ZOrder = BP_ENUM_UI_CORPS_ZORDER + 2}},
        {"Lobby"},
        false,
        false,
        true
    );
end

local function InitLocationData()
	BP_CorpsHomepageLocationSelectCity = 0
	BP_CorpsHomepageLocationSelectProvince = 0
	BP_ARRAY_CorpsHomepageLocationCity = {}
	BP_ARRAY_CorpsHomepageLocationProvince = {"--"}
	CorpsLocationEditorUI.cityInfo = {["--"] = {"--"}}
	local cityInfo = CorpsLocationEditorUI.cityInfo

	local cityInfoTb = Client.GetTable("SocialCardCity")
	local cityInfoList = {}
	for _, info in pairs(cityInfoTb) do
		table.insert(cityInfoList, info)
	end
	table.sort(cityInfoList, function(a, b) return a.ID < b.ID end)

	for _, info in ipairs(cityInfoList) do
		if cityInfo[info.City1] == nil then
			table.insert(BP_ARRAY_CorpsHomepageLocationProvince, info.City1)
			cityInfo[info.City1] =  {}
		end
		table.insert(cityInfo[info.City1], info.City2)
		if info.ID == DataMgr.corpsInfo.city then
			BP_CorpsHomepageLocationSelectProvince = #BP_ARRAY_CorpsHomepageLocationProvince - 1
			BP_CorpsHomepageLocationSelectCity = #cityInfo[info.City1] - 1
		end
	end

	local curProvince = BP_ARRAY_CorpsHomepageLocationProvince[BP_CorpsHomepageLocationSelectProvince + 1]
	BP_ARRAY_CorpsHomepageLocationCity = cityInfo[curProvince]
end

function CorpsLocationEditorUI.ShowUI()
    LuaClassObj.HandleDynamicCreation(bp_corps_location_editor);
    InitLocationData()
    LuaClassObj.HandleLobbyUIMessage(bp_corps_location_editor, "ShowUI")
end

function EventCorpsLocationEditorSelectProvince()
	local province = BP_ARRAY_CorpsHomepageLocationProvince[BP_CorpsHomepageLocationSelectProvince + 1]
	BP_ARRAY_CorpsHomepageLocationCity = CorpsLocationEditorUI.cityInfo[province]
end

function EventCorpsLocationEditorChange()
	log("===============EventCorpsLocationEditorChange")
	local province = BP_ARRAY_CorpsHomepageLocationProvince[BP_CorpsHomepageLocationSelectProvince + 1]
	local city = BP_ARRAY_CorpsHomepageLocationCity[BP_CorpsHomepageLocationSelectCity + 1]
	local cityInfoTb = Client.GetTable("SocialCardCity")
	local cityId = 0
	for _, info in pairs(cityInfoTb) do
		if info.City1 == province and info.City2 == city then
			cityId = info.ID
			break
		end
	end
	CorpsMgr.corps_change_city_req(cityId)
end