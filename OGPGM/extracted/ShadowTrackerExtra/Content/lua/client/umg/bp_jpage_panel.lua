JPAgeSystemUI = JPAgeSystemUI or 
{
	bInit = false;
}

BP_ARRAY_JPAgeYearList = 
{
	year = 0;
};

BP_ARRAY_JPAgeMonthList = 
{
	month = 0;
}

BP_JPAge_Input_Year = 0;
BP_JPAge_Input_Month = 0;

function bp_jpage_panel_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_jpage_panel,
		{{Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection07_BP.Protection07_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BLOCK_ZORDER}},
		{"Lobby"},
		false,
		false,
		true
	);
end

function EventInitializeData()

	if JPAgeSystemUI.bInit == true then
		return;
	end

	BP_ARRAY_JPAgeYearList = {};
	local currentTime = os.date("*t", os.time());
	local currentYear = currentTime.year;
	for i = 1900, currentYear do
		table.insert(BP_ARRAY_JPAgeYearList, i);
	end

	BP_ARRAY_JPAgeMonthList = {};
	for i = 1, 12 do
		table.insert(BP_ARRAY_JPAgeMonthList, i);
	end

	JPAgeSystemUI.bInit = true;
end

function EventJPAgeInputBirth_Push()

end

function EventJPAgeSyncBirthToServer()

	if BP_JPAge_Input_Year == nil or BP_JPAge_Input_Year <= 0 or BP_JPAge_Input_Month == nil or BP_JPAge_Input_Month <= 0 then
		
		DataMgr.ShowNoticeByID("4330");

		if (BP_JPAge_Input_Year == nil) then
			log("[HHF]JPAgeSystemUI.EventJPAgeSyncBirthToServer, BP_JPAge_Input_Year = nil");
		else
			log("[HHF]JPAgeSystemUI.EventJPAgeSyncBirthToServer, BP_JPAge_Input_Year = " .. tostring(BP_JPAge_Input_Year));
		end

		if (BP_JPAge_Input_Month == nil) then
			log("[HHF]JPAgeSystemUI.EventJPAgeSyncBirthToServer, BP_JPAge_Input_Month = nil");
		else
			log("[HHF]JPAgeSystemUI.EventJPAgeSyncBirthToServer, BP_JPAge_Input_Month = " .. tostring(BP_JPAge_Input_Month));
		end

		return;
	end

	local currentTime = os.date("*t", os.time());
	local currentYear = currentTime.year;
	local currentMonth = currentTime.month;

	-- 输入年大于当前年，或者输入年等于当前年但是输入月大于当前月，都是非法的
	if BP_JPAge_Input_Year > currentYear or (BP_JPAge_Input_Year == currentYear and BP_JPAge_Input_Month > currentMonth) then
		DataMgr.ShowNoticeByID("4330");
		return;
	end

	JPAgeSystem.jp_set_birthtime_req(BP_JPAge_Input_Year, BP_JPAge_Input_Month);
end

