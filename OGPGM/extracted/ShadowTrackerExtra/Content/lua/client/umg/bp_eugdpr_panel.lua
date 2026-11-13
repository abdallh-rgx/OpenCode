EUGDPRSystemUI = EUGDPRSystemUI or 
{
	EUGDPR_RegionType = 0; 			--选国家和地区
	EUGDPR_BirthdayType = 1; 		--选出生年月

	EUGDPR_DefaultState = 0;		--未开始
	EUGDPR_NotEUState = 1; 			--非欧盟用户
	EUGDPR_EUState = 2; 			--欧盟用户

	EUGDPR_AdultState = 7; 			--欧盟用户成年人
	EUGDPR_YoungState = 8; 			--欧盟用户未成年人

	EUGDPR_ParentNotAgreeState = 9;	--欧盟用户未成年，家长不同意
	EUGDPR_ParentAgreeState = 10; 	--欧盟用户未成年，家长同意

	EUGDPR_NotAgreeDataState = 3; 	--欧盟用户（成年or家长同意的未成年），不同意传输
	EUGDPR_AgreeDataState = 4; 		--欧盟用户（成年or家长同意的未成年），同意传输
	EUGDPR_NotAgreePrivacyState = 5;--欧盟用户（成年or家长同意的未成年），同意传输，但不同意隐私
	EUGDPR_BothAgreeState = 6; 		--欧盟用户（成年or家长同意的未成年），同意传输，也同意隐私

	EUGDPR_DeletingConfirmState = 11; 					--欧盟用户删号确认状态??

	EUGDPR_NotAgreeDataAndDeleteState = 13; 			--欧盟用户不同意传输，且确定删号
	EUGDPR_NotAgreePrivacyAndDeleteState = 15; 			--欧盟用户同意传输，但不同意隐私，且确定删号

	EUGDPR_ParentNotAgreeAndDeleteState = 19; 			--欧盟用户未成年，家长不同意，且确定删号，但可再次登录
	EUGDPR_ParentNotAgreeDeleteAndCantLoginState = 20; 	--欧盟用户同意协议，未成年，家长不同意，且确定删号短时间内还不能登录
	
	EUGDPR_DeleteWithoutReasonState = 21; 				--欧盟用户同意协议，成年或者未成年但家长同意，自己无理由删号

	-----------------------------------------------------------------

	EUGDPR_PRIVICY_DEFAULT = 0;     --默认，新用户
	EUGDPR_PRIVICY_AGREE = 1;       --同意隐私协议和数据传输
	EUGDPR_PRIVICY_REJECT = 2;      --不同意隐私策略
	EUGDPR_DATA_TRANS_REJECT = 3;   --不同意数据传输
	EUGDPR_DATA_TRANS_AGREE = 4;    --仅同意数据传输（隐私协议还没有设置）

	EUGDPR_DEFAULT = 0;             --默认，新用户
	EUGDPR_NON_EU = 1;              --非欧盟区用户
	EUGDPR_EU_ADULT = 2;            --欧盟区用户成人
	EUGDPR_EU_PARENT_WAIT= 3;       --欧盟区用户，等待家长同意
	EUGDPR_EU_PARENT_AGREE = 4;     --欧盟区用户，家长已经同意游戏
	EUGDPR_EU_PARENT_NOT_AGREE = 5; --欧盟区用户，家长不同意游戏
	EUGDPR_EU_PERSON = 6;           --欧盟区用户(不确定年龄)

	EUGDPR_Asia = 1;				--亚洲
	EUGDPR_North_America = 2;		--北美洲
	EUGDPR_South_America = 3;		--南美洲
	EUGDPR_Europe = 4;				--欧洲
	EUGDPR_Africa = 5;				--非洲
	EUGDPR_Oceania = 6;				--大洋洲
}

BP_STRUCT_EUGDPRDateOfBirth =
{
	year = 0;
	month = 0;
}

BP_STRUCT_EUGDPRTipsByState =
{
	state = 0;
	text = "";
}

BP_STRUCT_GDPRNationsPool = 
{
	id = 0;
	code = "";
	nation = "";
};

BP_EUGDPR_Type = 0;
BP_EUGDPR_State = 0;
BP_EUGDPR_IsNewUser = false;
BP_EUGDPR_EuropeTxt = "";
EP_EUGDPR_Recommend = "--";
EP_EUGDPR_RecommendNation = "--";
BP_EUGDPR_SelectedCountry = "";
BP_EUGDPR_IsEUByCountry = false;
BP_EUGDPR_IsAdult = false; -- 选完日期后记录是否成年人

BP_EUGDPR_ChangeAgeTime = 0;
PB_EUGDPR_ParentAgreeTime = 0;
BP_EUGDPR_CountDown = 10;
BP_EUGDPR_DeleteTime = 0;
BP_EUGPPR_BtnID = 0;

BP_ARRAY_GDPRStateTextList =
{
	BP_STRUCT_EUGDPRTipsByState = _G.BP_STRUCT_EUGDPRTipsByState;
};

BP_ARRAY_GDPRContinentsList =
{
	continent = "";
};

BP_ARRAY_GDPRNationsList =
{
	BP_STRUCT_GDPRNationsPool = _G.BP_STRUCT_GDPRNationsPool;
};

BP_ARRAY_GDPREUNationsList = 
{
	nation = "";
};

BP_ARRAY_GDPRYearList = 
{
	year = 0;
};

BP_ARRAY_GDPRMonthList = 
{
	month = 0;
}


function bp_eugdpr_panel_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_eugdpr_panel,
		{{Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection01_BP.Protection01_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BLOCK_ZORDER},
		 {Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection05_BP.Protection05_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BLOCK_ZORDER},
		 {Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection04_BP.Protection04_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BLOCK_ZORDER},
		 {Path="/Game/UMG/UI_BP/PopupNotice/Gameplayerprotection/Protection03_BP.Protection03_BP_C", Container="Default", ZOrder=BP_ENUM_UI_BLOCK_ZORDER}},
		{"Lobby","Login","CreateRole"},
		false,
		false,
		true
	);
end

function EUGDPRSystemUI.CalculateMinAgeDateOfBirth()
	local age = 16;
	local strRegion = Client.GetPublishRegion();
	if strRegion == "VNG" then
		age = 18;
	end
	
	local currentTime = os.date("*t", os.time());
	local currentYear = currentTime.year;
	local currentMonth = currentTime.month;
	BP_STRUCT_EUGDPRDateOfBirth.year = currentYear - age;
	BP_STRUCT_EUGDPRDateOfBirth.month = currentMonth - 1;
	if BP_STRUCT_EUGDPRDateOfBirth.month == 0 then 
		BP_STRUCT_EUGDPRDateOfBirth.month = 12;
		BP_STRUCT_EUGDPRDateOfBirth.year = BP_STRUCT_EUGDPRDateOfBirth.year - 1;
	end
	log("[HHF]EUGDPRSystemUI.CalculateMinAgeDateOfBirth, date = " .. BP_STRUCT_EUGDPRDateOfBirth.year .. "-" .. BP_STRUCT_EUGDPRDateOfBirth.month);
end

function EUGDPRSystemUI.CheckDataValidity()
	if LoginSystem.commonSwitch == nil then
		log("[HHF]EUGDPRSystemUI.CheckDataValidity, LoginSystem.commonSwitch = nil");
		return false;
	else
		if LoginSystem.commonSwitch.EUGDPRDelAccountTime ~= nil then
			BP_EUGDPR_DeleteTime = LoginSystem.commonSwitch.EUGDPRDelAccountTime;
			log("[HHF]EUGDPRSystemUI.CheckDataValidity, BP_EUGDPR_DeleteTime = " .. BP_EUGDPR_DeleteTime);
		end

		if LoginSystem.commonSwitch.EUGDPRChangeParentAgreeTime ~= nil then
			PB_EUGDPR_ParentAgreeTime = LoginSystem.commonSwitch.EUGDPRChangeParentAgreeTime;
			log("[HHF]EUGDPRSystemUI.CheckDataValidity, PB_EUGDPR_ParentAgreeTime = " .. PB_EUGDPR_ParentAgreeTime);
		end

		if LoginSystem.commonSwitch.EUGDPRFunctionSwitch == nil then
			log("[HHF]EUGDPRSystemUI.CheckDataValidity, LoginSystem.commonSwitch.EUGDPRFunctionSwitch = nil");
			return false;
		end
	end

	if BP_EUGDPR_IsNewUser == true then
		if BP_EUGDPR_State ~= EUGDPRSystemUI.EUGDPR_DefaultState then
			BP_EUGDPR_IsNewUser = false;
			log("[HHF]EUGDPRSystemUI.CheckDataValidity, reset BP_EUGDPR_IsNewUser = false and return");
			return false;
		end
	else
		if DataMgr.roleData.eugdpr == nil then
			log("[HHF]EUGDPRSystemUI.CheckDataValidity, DataMgr.roleData.eugdpr = nil");
			return false;
		else
			if DataMgr.roleData.eugdpr.user_type == nil then
				log("[HHF]EUGDPRSystemUI.CheckDataValidity, DataMgr.roleData.eugdpr.user_type = nil");
				return false;
			elseif DataMgr.roleData.eugdpr.policy_state == nil then
				log("[HHF]EUGDPRSystemUI.CheckDataValidity, DataMgr.roleData.eugdpr.policy_state = nil");
				return false;
			elseif DataMgr.roleData.eugdpr.is_deleting == nil then
				log("[HHF]EUGDPRSystemUI.CheckDataValidity, DataMgr.roleData.eugdpr.is_deleting = nil");
				return false;
			end
		end
	end

	return true;
end

function EUGDPRSystemUI.InitializeData()
	DataMgr.roleData.eugdpr = nil;

	BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_RegionType;
	BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_DefaultState;
	BP_EUGDPR_IsNewUser = false;
	EP_EUGDPR_Recommend = "--";
	EP_EUGDPR_RecommendNation = "--";
	BP_EUGDPR_SelectedCountry = "";
	BP_EUGDPR_IsEUByCountry = false;
	BP_EUGDPR_IsAdult = false;

	BP_EUGDPR_ChangeAgeTime = 365 * 24 * 60 * 60;
	PB_EUGDPR_ParentAgreeTime = 36 * 60 * 60;
	BP_EUGDPR_CountDown = 10;
	BP_EUGDPR_DeleteTime = 7 * 24 * 60 * 60;
	BP_EUGPPR_BtnID = 0;

	-- 顺序调整——北美，南美，亚洲，非洲，大洋洲，欧洲
	BP_ARRAY_GDPRContinentsList = {};
	table.insert(BP_ARRAY_GDPRContinentsList, FuncUtil.GetLocalizeResStr("4087"));
	table.insert(BP_ARRAY_GDPRContinentsList, FuncUtil.GetLocalizeResStr("4088"));
	table.insert(BP_ARRAY_GDPRContinentsList, FuncUtil.GetLocalizeResStr("4089"));
	table.insert(BP_ARRAY_GDPRContinentsList, FuncUtil.GetLocalizeResStr("4090"));
	table.insert(BP_ARRAY_GDPRContinentsList, FuncUtil.GetLocalizeResStr("4091"));
	table.insert(BP_ARRAY_GDPRContinentsList, FuncUtil.GetLocalizeResStr("4092"));
	BP_EUGDPR_EuropeTxt = FuncUtil.GetLocalizeResStr("4092"); -- 欧洲

	-- 国家读表
	BP_ARRAY_GDPRNationsList = {};
    BP_ARRAY_GDPREUNationsList = {};
    local ecTable = Client.GetTable("EuropeanCountries");
    for _, v in pairs(ecTable) do
		local country = {};
		country.id = v.CountryID;
    	country.code = v.CountryCode;
    	country.nation = v.CountryName;
		table.insert(BP_ARRAY_GDPRNationsList, country);
		if v.isEEU == true then
			table.insert(BP_ARRAY_GDPREUNationsList, v.CountryName);
		end
	end
	
	table.sort(BP_ARRAY_GDPRNationsList, function(a, b)
        return a.id < b.id
    end)

	BP_ARRAY_GDPRYearList = {};
	local currentTime = os.date("*t", os.time());
	local currentYear = currentTime.year;
	for i = 1970, currentYear do
		table.insert(BP_ARRAY_GDPRYearList, i);
	end

	BP_ARRAY_GDPRMonthList = {};
	for i = 1, 12 do
		table.insert(BP_ARRAY_GDPRMonthList, i);
	end

	local tips0 = {};
	tips0.state = EUGDPRSystemUI.EUGDPR_AdultState; -- EUGDPR_EUState 7
	tips0.text = FuncUtil.GetLocalizeResStr("4448");
	local tips1 = {};
	tips1.state = EUGDPRSystemUI.EUGDPR_ParentAgreeState; -- 10
	tips1.text = FuncUtil.GetLocalizeResStr("4448");
	local tips2 = {};
	tips2.state = EUGDPRSystemUI.EUGDPR_NotAgreeDataState; -- 3
	tips2.text = FuncUtil.GetLocalizeResStr("4373"); -- 很抱歉，因您不同意将数据传输到非欧盟地区，您无法继续进行游戏。是否需要返回再次确认？
	local tips3 = {};
	tips3.state = EUGDPRSystemUI.EUGDPR_NotAgreeDataAndDeleteState; -- 13
	tips3.text = FuncUtil.GetLocalizeResStr("4413"); -- 请您注意：您的帐号将在<GDPR_Remind>{0}后自动删除</>。\n\n因您不同意将数据传输到非欧盟地区，您无法继续进行游戏。是否需要返回再次确认？
	local tips4 = {};
	tips4.state = EUGDPRSystemUI.EUGDPR_AgreeDataState; -- 4
	tips4.text = FuncUtil.GetLocalizeResStr("4382"); -- 您已经同意将您的数据向欧盟以外传输。您可在“设置”界面撤销您的同意。
	local tips5 = {};
	tips5.state = EUGDPRSystemUI.EUGDPR_NotAgreePrivacyState; -- 5
	tips5.text = FuncUtil.GetLocalizeResStr("4390"); -- 很抱歉，由于您未同意您的数据向欧盟以外传输，目前您将无法继续进行游戏。请问是否需要重新考虑？
	local tips6 = {};
	tips6.state = EUGDPRSystemUI.EUGDPR_NotAgreePrivacyAndDeleteState; -- 15
	tips6.text = FuncUtil.GetLocalizeResStr("4389"); -- 请注意，您已经选择删除您的账号。您的帐号将在{0}后删除。账号删除后所有数据将一并删除且无法撤销。请问您是否需要取消账号删除请求？
	local tips7 = {};
	tips7.state = EUGDPRSystemUI.EUGDPR_DeletingConfirmState; -- 11
	tips7.text = FuncUtil.GetLocalizeResStr("4099"); -- 您是否确定要<GDPR_Remind>删除</>你的帐号？
	local tips8 = {};
	tips8.state = EUGDPRSystemUI.EUGDPR_YoungState; -- 8
	tips8.text = FuncUtil.GetLocalizeResStr("4391"); -- 由于您未满16岁，请先确认您是否获得了父母或监护人的允许使用PUBG MOBILE应用，并接受PUBG MOBILE的<GDPR_Link_Tips> 隐私协议</>？
	local tips9 = {};
	tips9.state = EUGDPRSystemUI.EUGDPR_ParentNotAgreeState; -- 9
	tips9.text = FuncUtil.GetLocalizeResStr("4393"); -- 很抱歉，因您还未获得家长同意，根据<GDPR_Remind>《GDPR法》</>规定，您无法继续进行游戏。
	local tips10 = {};
	tips10.state = EUGDPRSystemUI.EUGDPR_ParentNotAgreeAndDeleteState; -- 19
	tips10.text = FuncUtil.GetLocalizeResStr("4122"); -- 请您注意：您的帐号将在<GDPR_Remind>{0}后自动删除</>。\n\n因您还未获得家长同意，您无法继续进行游戏。是否需要返回再次获得家长同意？
	local tips11 = {};
	tips11.state = EUGDPRSystemUI.EUGDPR_ParentNotAgreeDeleteAndCantLoginState; -- 20
	tips11.text = FuncUtil.GetLocalizeResStr("4394"); -- 请您注意：你的帐号{0}后才能再次登录，\n您的帐号将在<GDPR_Remind>{1}后自动删除</>。\n\n因您还未获得家长同意，根据<GDPR_Remind>《GDPR法》</>规定，您无法继续进行游戏。
	local tips12 = {};
	tips12.state = EUGDPRSystemUI.EUGDPR_DeleteWithoutReasonState; -- 21
	tips12.text = FuncUtil.GetLocalizeResStr("4389"); -- 请注意，您已经选择删除您的账号。您的帐号将在{0}后删除。账号删除后所有数据将一并删除且无法撤销。请问您是否需要取消账号删除请求？

	BP_ARRAY_GDPRStateTextList = {};
	table.insert(BP_ARRAY_GDPRStateTextList, tips0);
	table.insert(BP_ARRAY_GDPRStateTextList, tips1);
	table.insert(BP_ARRAY_GDPRStateTextList, tips2);
	table.insert(BP_ARRAY_GDPRStateTextList, tips3);
	table.insert(BP_ARRAY_GDPRStateTextList, tips4);
	table.insert(BP_ARRAY_GDPRStateTextList, tips5);
	table.insert(BP_ARRAY_GDPRStateTextList, tips6);
	table.insert(BP_ARRAY_GDPRStateTextList, tips7);
	table.insert(BP_ARRAY_GDPRStateTextList, tips8);
	table.insert(BP_ARRAY_GDPRStateTextList, tips9);
	table.insert(BP_ARRAY_GDPRStateTextList, tips10);
	table.insert(BP_ARRAY_GDPRStateTextList, tips11);
	table.insert(BP_ARRAY_GDPRStateTextList, tips12);

	EUGDPRSystemUI.bInitialized = true;
	log("[HHF]EUGDPRSystemUI.InitializeData, nations.num = " .. FuncUtil:CountTable(BP_ARRAY_GDPRNationsList));
end

-- 都同意了，返回false
function EUGDPRSystemUI.ManagePrivacy()
	if DataMgr.roleData.eugdpr.policy_state == EUGDPRSystemUI.EUGDPR_DATA_TRANS_REJECT then
		log("[HHF]EUGDPRSystemUI.ManagePrivacy, policy_state = 3");
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_NotAgreeDataState;
		EventShowGDPRAbortPanel();
		return true;
	elseif DataMgr.roleData.eugdpr.policy_state == EUGDPRSystemUI.EUGDPR_PRIVICY_REJECT then
		log("[HHF]EUGDPRSystemUI.ManagePrivacy, policy_state = 2");
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_NotAgreePrivacyState;
		EventShowGDPRAbortPanel();
		return true;
	elseif DataMgr.roleData.eugdpr.policy_state == EUGDPRSystemUI.EUGDPR_DATA_TRANS_AGREE then -- 仅同意数据传输（隐私协议还没有设置）
		log("[HHF]EUGDPRSystemUI.ManagePrivacy, policy_state = 4");
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_AgreeDataState;
		EventShowGDPRagreementPanel();
		return true;
	elseif DataMgr.roleData.eugdpr.policy_state == EUGDPRSystemUI.EUGDPR_PRIVICY_DEFAULT then -- 初始化
		log("[HHF]EUGDPRSystemUI.ManagePrivacy, policy_state = 0");
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		if DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_ADULT then
			BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_AdultState;
		else
			BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_ParentAgreeState;
		end
		EventShowGDPRagreementPanel();
		return true;
	else
		log("[HHF]EUGDPRSystemUI.ManagePrivacy, policy_state = " .. DataMgr.roleData.eugdpr.policy_state); -- EUGDPR_PRIVICY_AGREE
		return false;
	end
end

function EUGDPRSystemUI.ManageDeleting()
	if BP_EUGDPR_IsNewUser == true then
		return false;
	else
		if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.is_deleting == true then
			log("[HHF]EventTryToShowEUGDPR, is_deleting = true, lefttime = " .. DataMgr.roleData.eugdpr.left_del_time);
			BP_EUGDPR_DeleteTime = DataMgr.roleData.eugdpr.left_del_time;
			if DataMgr.roleData.eugdpr.policy_state == EUGDPRSystemUI.EUGDPR_DATA_TRANS_REJECT then
				log("[HHF]EventTryToShowEUGDPR, policy_state = 3");
				BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
				BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_NotAgreeDataAndDeleteState;
				EventShowGDPRAbortPanel();
			elseif DataMgr.roleData.eugdpr.policy_state == EUGDPRSystemUI.EUGDPR_PRIVICY_REJECT then
				log("[HHF]EventTryToShowEUGDPR, policy_state = 2");
				BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
				BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_NotAgreePrivacyAndDeleteState;
				EventShowGDPRAbortPanel();
			elseif  DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_PARENT_NOT_AGREE then
				log("[HHF]EventTryToShowEUGDPR, user_type = 5");
				if DataMgr.roleData.eugdpr.left_parent_agree_time <=0 then
					BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
					BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_ParentNotAgreeAndDeleteState;
				else
					BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
					BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_ParentNotAgreeDeleteAndCantLoginState;
				end
				EventShowGDPRAbortPanel();
			else
				log("[HHF]EventTryToShowEUGDPR, deleting without reason.");
				BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
				BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_DeleteWithoutReasonState;
				EventShowGDPRAbortPanel();
			end
			return true;
		else
			return false;
		end
	end
end

function EUGDPRSystemUI.GetRecommendInfo()
	EP_EUGDPR_RecommendNation = "--";

	if LoginSystem.continent == EUGDPRSystemUI.EUGDPR_Asia then
		EP_EUGDPR_Recommend = FuncUtil.GetLocalizeResStr("4089");
	elseif LoginSystem.continent == EUGDPRSystemUI.EUGDPR_North_America then
		EP_EUGDPR_Recommend = FuncUtil.GetLocalizeResStr("4087");
	elseif LoginSystem.continent == EUGDPRSystemUI.EUGDPR_South_America then
		EP_EUGDPR_Recommend = FuncUtil.GetLocalizeResStr("4088");
	elseif LoginSystem.continent == EUGDPRSystemUI.EUGDPR_Europe then
		EP_EUGDPR_Recommend = FuncUtil.GetLocalizeResStr("4092");
		if LoginSystem.ip_region ~= "G1" then
			for _, v in pairs(BP_ARRAY_GDPRNationsList) do
				if LoginSystem.ip_region == v.code then
					EP_EUGDPR_RecommendNation = v.nation;
					BP_EUGDPR_SelectedCountry = EP_EUGDPR_RecommendNation;
					break;
				end
			end
		end
	elseif LoginSystem.continent == EUGDPRSystemUI.EUGDPR_Africa then
		EP_EUGDPR_Recommend = FuncUtil.GetLocalizeResStr("4090");
	elseif LoginSystem.continent == EUGDPRSystemUI.EUGDPR_Oceania then
		EP_EUGDPR_Recommend = FuncUtil.GetLocalizeResStr("4091");
	else
		EP_EUGDPR_Recommend = "--";
	end
end

-- 不能更改年龄返回false
function EUGDPRSystemUI.CanChangeAge()
	log("[HHF]EUGDPRSystemUI.CanChangeAge, left_change_age_time = " .. DataMgr.roleData.eugdpr.left_change_age_time);
	BP_EUGDPR_ChangeAgeTime = DataMgr.roleData.eugdpr.left_change_age_time;
	if DataMgr.roleData.eugdpr.left_change_age_time <= 0 then
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_EUState;
		EventShowGDPRDateOfBirth();
		return true;
	else
		return false;
	end
end

-- 从P01_BP中过来的入口函数
function EventTryToShowEUGDPR()
	log("[HHF]EventTryToShowEUGDPR");
	--[[ for test
	if DataMgr.roleData.eugdpr ~= nil then
		DataMgr.roleData.eugdpr.user_type = EUGDPRSystemUI.EUGDPR_DEFAULT;
	end
	--]]

	--[[ local debug 各种数据开关
	LoginSystem.commonSwitch.EUGDPRFunctionSwitch = true
	LoginSystem.commonSwitch.EUGDPRAgreePopupSwitch = true
	LoginSystem.commonSwitch.EUGDPRDataTranPopupSwitch = true
	LoginSystem.commonSwitch.EUGDPRPrivacyPopupSwitch = false
	--]]

	-- 数据非法或者日韩/越南版本，不走整个GDPR流程，直接进游戏。
	--jaysunzhu dominicwang review。只有全球版才需要GDPR。以下是特殊用法，正确用法参考http://tapd.oa.com/iGameInternational/markdown_wikis/view/#1020360302008071849
	if EUGDPRSystemUI.CheckDataValidity() == false or Client.GetPublishRegion() ~= "GLOBAL" then
		EUGDPRSystemUI.GoToFaceSlapSystem();
		return;
	end

	LuaClassObj.HandleDynamicCreation(bp_eugdpr_panel);

	if DataMgr.roleData ~= nil and DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_ADULT then
		log("[HHF]EventTryToShowEUGDPR, old adult user");
		BP_EUGDPR_IsAdult = true;
	end

	if EUGDPRSystemUI.ManageDeleting() == true then		
		return;
	end

	if LoginSystem.commonSwitch.EUGDPRFunctionSwitch == false then
		log("[HHF]EventTryToShowEUGDPR, FunctionSwitch = false");
		EUGDPRSystemUI.GoToFaceSlapSystem();
	elseif DataMgr.roleData.eugdpr == nil or DataMgr.roleData.eugdpr.user_type == nil or DataMgr.roleData.eugdpr.user_type == 0 then
		log("[HHF]EventTryToShowEUGDPR, eugdpr = nil or user_type = nil or 0"); -- 第一步，选地区
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_RegionType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_DefaultState;
		EUGDPRSystemUI.GetRecommendInfo();
		log("[HHF]ShowCountriesAndRegionsPanel");
		LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "ShowCountriesAndRegions");
		BP_EUGPPR_BtnID = 10;
		EventEUGDPRReportBtnClick();
	elseif DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_NON_EU then
		log("[HHF]EventTryToShowEUGDPR, user_type = 1 (not EU)"); -- 非欧盟，直接进游戏
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_NotEUState;
		EUGDPRSystemUI.GoToFaceSlapSystem();
	elseif DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_PERSON then		
		log("[HHF]EventTryToShowEUGDPR, user_type = 6 (EU)"); -- 选择年龄
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_EUState;
		EventShowGDPRDateOfBirth();
	elseif DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_ADULT then
		log("[HHF]EventTryToShowEUGDPR, user_type = 2 (EU Adult)");
		if EUGDPRSystemUI.ManagePrivacy() == false then
			EUGDPRSystemUI.GoToFaceSlapSystem();
		end
	elseif DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_PARENT_WAIT then
		log("[HHF]EventTryToShowEUGDPR, user_type = 3 (EU young)"); -- 询问家长同意
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_YoungState;
		EventShowGDPRagreementPanel();
	elseif DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_PARENT_AGREE then
		log("[HHF]EventTryToShowEUGDPR, user_type = 4 (EU young, and agree)");
		if EUGDPRSystemUI.CanChangeAge() == false then -- 这段时间内不能改年龄了
			if EUGDPRSystemUI.ManagePrivacy() == false then -- 都同意了，结束流程，进入游戏
				EUGDPRSystemUI.GoToFaceSlapSystem();
			end
		end
	elseif DataMgr.roleData.eugdpr.user_type == EUGDPRSystemUI.EUGDPR_EU_PARENT_NOT_AGREE then
		log("[HHF]EventTryToShowEUGDPR, user_type = 5 (EU young, not agree)");
		if EUGDPRSystemUI.CanChangeAge() == false then -- 这段时间内不能改年龄了
			PB_EUGDPR_ParentAgreeTime = DataMgr.roleData.eugdpr.left_parent_agree_time;
			if DataMgr.roleData.eugdpr.left_parent_agree_time <= 0 then -- 以前没有家长授权
				BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
				BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_ParentNotAgreeAndDeleteState; -- 可进入游戏
				EventShowGDPRAbortPanel();
			else
				BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
				BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_ParentNotAgreeDeleteAndCantLoginState; -- 不能进游戏
				EventShowGDPRAbortPanel();
			end
		end
	else
		log("[HHF]EventTryToShowEUGDPR, what happend? user_type = " .. DataMgr.roleData.eugdpr.user_type);
		EUGDPRSystemUI.GoToFaceSlapSystem();
	end
end

-- 询问对话框，三种情况：家长同意、数据传输、隐私条款
function EventShowGDPRagreementPanel()
	if BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_AdultState or BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_YoungState then
		-- 总开关关闭，全部都不检查
		if LoginSystem.commonSwitch.EUGDPRAgreePopupSwitch == false then
			log("[HHF]EventShowGDPRagreementPanel, EUGDPRAgreePopupSwitch = false");
			EUGDPRSystemUI.GoToFaceSlapSystem();
			return
		end
	end

	-- 成年人，或家长同意了的未成年人
	if BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_AdultState or BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_ParentAgreeState then
		-- 不检查数据传输
		if LoginSystem.commonSwitch.EUGDPRDataTranPopupSwitch == false then
			log("[HHF]EventShowGDPRagreementPanel, EUGDPRDataTranPopupSwitch = false");
			EUGDPRSystemUI.GoToFaceSlapSystem();
			return
		end
	elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_AgreeDataState then
		-- 不检查隐私
		if LoginSystem.commonSwitch.EUGDPRPrivacyPopupSwitch == false then
			log("[HHF]EventShowGDPRagreementPanel, EUGDPRPrivacyPopupSwitch = false");
			EUGDPRSystemUI.GoToFaceSlapSystem();
			return
		end
	end

	log("[HHF]EventShowGDPRagreementPanel state="..BP_EUGDPR_State);
	LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "ShowGDPRAgreementPanel");
end

function EventShowGDPRAbortPanel()
	log("[HHF]EventShowGDPRAbortPanel");
	LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "ShowAbortPanel");
end

-- 显示年龄选择框
function EventShowGDPRDateOfBirth()
	if LoginSystem.commonSwitch.EUGDPRAgePopupSwitch == false then
		log("[HHF]EventTryToShowEUGDPR, EUGDPRAgePopupSwitch = false");
		EUGDPRSystemUI.GoToFaceSlapSystem();
		return;
	end

	if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.left_change_age_time > 0 then
		log("[HHF]EventShowGDPRDateOfBirth, left_change_age_time = " .. DataMgr.roleData.eugdpr.left_change_age_time);
		EUGDPRSystemUI.GoToFaceSlapSystem();
	else
		log("[HHF]EventShowGDPRDateOfBirth state="..BP_EUGDPR_State);
		EUGDPRSystemUI.CalculateMinAgeDateOfBirth();
		BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
		LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "ShowDateOfBirth");

		-- 是欧盟新用户，则创建角色面板显示修改昵称tip按钮
		if BP_EUGDPR_IsNewUser and BP_EUGDPR_IsEUByCountry then
			LuaClassObj.HandleUIMessage(bp_createrole, "ShowCreateTipBtn");
		end
	end
end

function EventEUGDPRReturnToLogin()
	log("[HHF]EventEUGDPRReturnToLogin");
    LoginSystem.sendLogout();
end

function EventSyncEUGDPRDeleteAccount()
	log("[HHF]EventSyncEUGDPRDeleteAccount");
	EUGDPRSystem.DeleteAccountReq(true, true);
end

function EventSyncEUGDPRCancelDeleteAccount()
	log("[HHF]EventSyncEUGDPRCancelDeleteAccount");
	if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.is_deleting == true then
		EUGDPRSystem.CancelDeleteAccountReq();
	end
end

function EventSyncEUGDPRStateToServer()
    log("[HHF]EventSyncEUGDPRStateToServer, BP_EUGDPR_State = " .. BP_EUGDPR_State);

    if BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_NotEUState then
    	EUGDPRSystem.SendStateToServer(EUGDPRSystemUI.EUGDPR_NON_EU);
    elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_EUState then
    	EUGDPRSystem.SendStateToServer(EUGDPRSystemUI.EUGDPR_EU_PERSON);
    elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_NotAgreeDataState or BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_NotAgreeDataAndDeleteState then
    	EUGDPRSystem.SendPrivacyToServer(EUGDPRSystemUI.EUGDPR_DATA_TRANS_REJECT);
    elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_AgreeDataState then
    	EUGDPRSystem.SendPrivacyToServer(EUGDPRSystemUI.EUGDPR_DATA_TRANS_AGREE);
    elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_NotAgreePrivacyState or BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_NotAgreePrivacyAndDeleteState then
    	EUGDPRSystem.SendPrivacyToServer(EUGDPRSystemUI.EUGDPR_PRIVICY_REJECT);
    elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_BothAgreeState then
    	EUGDPRSystem.SendPrivacyToServer(EUGDPRSystemUI.EUGDPR_PRIVICY_AGREE);
	elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_AdultState then
		BP_EUGDPR_IsAdult = true
    	EUGDPRSystem.SendStateToServer(EUGDPRSystemUI.EUGDPR_EU_ADULT);
	elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_YoungState then
		BP_EUGDPR_IsAdult = false
    	EUGDPRSystem.SendStateToServer(EUGDPRSystemUI.EUGDPR_EU_PARENT_WAIT);
    elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_ParentNotAgreeState or BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_ParentNotAgreeAndDeleteState then
    	EUGDPRSystem.SendStateToServer(EUGDPRSystemUI.EUGDPR_EU_PARENT_NOT_AGREE);
    elseif BP_EUGDPR_State == EUGDPRSystemUI.EUGDPR_ParentAgreeState then
    	EUGDPRSystem.SendStateToServer(EUGDPRSystemUI.EUGDPR_EU_PARENT_AGREE);
    end;
end

function EventEUGDPRReportBtnClick()
	if DataMgr.roleData.eugdpr ~= nil and DataMgr.roleData.eugdpr.is_deleting == true then
		if BP_EUGPPR_BtnID == 241 then
			BP_EUGPPR_BtnID = 261;
		elseif BP_EUGPPR_BtnID == 242 then
			BP_EUGPPR_BtnID = 262;
		elseif BP_EUGPPR_BtnID == 341 then
			BP_EUGPPR_BtnID = 361;
		elseif BP_EUGPPR_BtnID == 342 then
			BP_EUGPPR_BtnID = 362;
		end
	end
	EUGDPRSystem.ReportBtnClick(BP_EUGDPR_IsNewUser, BP_EUGPPR_BtnID);
end

-- P04_BP OnClicked(deleteBtn)
function EventShowGDPRCountDownPanel()
	log("[HHF]EventShowGDPRCountDownPanel");
	LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "ShowCountDownPanel");
end

function EventIsEUCountry()
	for _, v in pairs(BP_ARRAY_GDPREUNationsList) do
		if v == BP_EUGDPR_SelectedCountry then
			BP_EUGDPR_IsEUByCountry = true;
			log("[HHF]EventIsEUCountry, BP_EUGDPR_IsEUByCountry = true");
			return;
		end
	end

	log("[HHF]EventIsEUCountry, BP_EUGDPR_IsEUByCountry = false");
	BP_EUGDPR_IsEUByCountry = false;
end

function EventShowGDPRPrivacyPanel()
	log("[HHF]EventShowGDPRPrivacyPanel");
	PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_en, LongTxt.PrivacyAgreement_content_en);
end

function EventCloseAllGDPRUI()
	LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "CloseUI");
end

function EventFetchInfo()
	
end

function EventTryToShowVNGBirth()
	log("EventTryToShowVNGBirth")
	EUGDPRSystemUI.InitializeData()
	BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
	BP_EUGDPR_State = EUGDPRSystemUI.EUGDPR_EUState;
	EventShowVNGDateOfBirth();
end

-- 越南版复用GDPR的生日弹框
function EventShowVNGDateOfBirth()
	log("[HHF]EventShowVNGDateOfBirth state="..BP_EUGDPR_State);
	EUGDPRSystemUI.CalculateMinAgeDateOfBirth();
	BP_EUGDPR_Type = EUGDPRSystemUI.EUGDPR_BirthdayType;
	LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "ShowDateOfBirth");
	return;

end

function EventVNGIsAdult()
	log("EventVNGIsAdult");
	LuaClassObj.HandleUIMessage(bp_authorization, "SetIsVNGAdult");
	AuthorizationUI.AutoLogin();
end

function EventVNGIsNotAdult()
	log("EventVNGIsNotAdult");
	CommonMessageBoxUI:ShowPanel(1, Client.GetTableData("LocalizeRes", "101001").TextValue, Client.GetTableData("LocalizeRes", "16017").TextValue);
end

function EUGDPRSystemUI.OnHyperLinkClicked(MetaData)
	log("EUGDPRSystemUI.OnHyperLinkClicked")
    if MetaData.id == "GDPRHyperLink" and MetaData.url == "privacy" then
        PopUpNoticeUI.ShowMessageBox(LongTxt.PrivacyAgreement_title_en, LongTxt.PrivacyAgreement_content_en);
    elseif MetaData.id == "GDPRHyperLink" and MetaData.url == "CustomerService" then
    	LuaClassObj.HandleUIMessage(bp_eugdpr_panel, "ShowCustomerService");
    end
end

function EUGDPRSystemUI.GoToFaceSlapSystem()
	log("[HHF]EUGDPRSystemUI.GoToFaceSlapSystem");
	FaceSlapSystem.BeginShow();
end

function EventGoToFaceSlapSystem()
	EUGDPRSystemUI.GoToFaceSlapSystem();
end
