-- 分组奖励选择界面
UnknowPassChooseAwardUI = UnknowPassChooseAwardUI or
{
	isShowing = false,	
}

local UnKnowPassChooseAwardLevel = 0;
local UnknowPassChooseAwardLeftGroupId = 0;
local UnknowPassChooseAwardRightGroupId = 0;
local UnknowPassChooseAwardIsGetTotal = false;
local UnknowPassChooseAwardTotalAwards = {};

-- 是否是左侧
BP_UnknowPass_ChooseAward_IsLeft = true;

-- 注册widget
function bp_unknow_pass_choose_award_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_unknow_pass_choose_award,
	{
		{Path="/Game/UMG/UI_Logic/UnknowPass/UnknowPass_Choose_Award_Logic_BP.UnknowPass_Choose_Award_Logic_BP_C", Container="Default", ZOrder=0},
	},
	{"Lobby"},
	false,
	false
	);
	
end


-- 初始化单个level的选择数据
function UnknowPassChooseAwardUI.Init(rewards, isTotal)
	log_tree("rewards",rewards);
	UnknowPassChooseAwardIsGetTotal = isTotal;
	UnKnowPassChooseAwardLevel = rewards.level;
	if #rewards.BP_Array_EliteAward > 1 then
		UnknowPassChooseAwardLeftGroupId = rewards.BP_Array_EliteAward[1].groupId;
		UnknowPassChooseAwardRightGroupId = rewards.BP_Array_EliteAward[2].groupId;
	end
end

-- 依次显示选择界面
local function ShowUnknowPassChooseAwardOneBy()
	UnknowPassChooseAwardUI.Init(UnknowPassChooseAwardTotalAwards[1], true);
	table.remove(UnknowPassChooseAwardTotalAwards, 1);
end

-- 初始化一键领取逻辑
function UnknowPassChooseAwardUI.InitTotal(rewards)
	log("UnknowPassAwardUI InitTotal");
	if #rewards > 0 then	 -- 一键领取逻辑
		UnknowPassChooseAwardTotalAwards = rewards;
		ShowUnknowPassChooseAwardOneBy();
		UnknowPassChooseAwardUI.Show();
	else
		UnknowPassChooseAwardTotalAwards = {};
	end
end

function UnknowPassChooseAwardUI.Show()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_choose_award, "UIShow");
	UIManager.Show(eUIType.eUnknowPassChooseAwardUI);	
end

function UnknowPassChooseAwardUI.Hide()
	LuaClassObj.HandleUIMessageNoFetch(bp_unknow_pass_choose_award, "UIHide");
end

-- 请求奖励确认
local function ConfirmChooseAward()
	local groupid = 0;
	if BP_UnknowPass_ChooseAward_IsLeft then
		groupid = UnknowPassChooseAwardLeftGroupId;
	else
		groupid = UnknowPassChooseAwardRightGroupId;
	end
	
	if UnknowPassChooseAwardIsGetTotal then
		local selects = UnknowPassSystem.SelectAwards.elite or {};
		selects[UnKnowPassChooseAwardLevel] = groupid;
		UnknowPassSystem.SelectAwards.elite = selects;
		if #UnknowPassChooseAwardTotalAwards > 0 then
			ShowUnknowPassChooseAwardOneBy();
			UnknowPassChooseAwardUI.Show();
		else
			UnknowPassSystem.upass_batch_get_level_award_req(UnknowPassSystem.SelectAwards);
			UnknowPassChooseAwardUI.Hide();
		end
	else		
		UnknowPassSystem.upass_get_level_award_req(UnKnowPassChooseAwardLevel, true, groupid)
		UnknowPassChooseAwardUI.Hide();
	end
end

-- 请求奖励
function EventUnknowPassChooseAwardGet()
	local groupid = 0;
	if BP_UnknowPass_ChooseAward_IsLeft then
		groupid = UnknowPassChooseAwardLeftGroupId;
	else
		groupid = UnknowPassChooseAwardRightGroupId;
	end
	
	-- 先用第一个物品的名称
	local item_id = UnknowPassSystem.Award_Group_Data[groupid].reward[1].item_id;
	local cfgItem = Client.GetTableData("Item", item_id)
	local tip = FuncUtil.LocalizeResFormat(6521, cfgItem.ItemName);	-- 是否确认选择{0}作为终极奖励
	CommonMessageBoxUI:ShowPanel(2, "", tip, ConfirmChooseAward)
end 