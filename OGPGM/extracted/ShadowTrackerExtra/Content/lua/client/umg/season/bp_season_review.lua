--组队模式选 or
SeasonReviewUI = SeasonReviewUI or
{	
	listSeasonTabInfo = {},
	
	curSeasonReviewOwnerUid = "",
	
	PAGE_RANK = 1,
	PAGE_SEGMENT = 2,
}

-- 赛季概要数据
BP_STRUCT_SeasonReview_Summary = 
{
	id = 1,					-- 赛季id
	seasonName = "", 		-- 赛季名称
	seasonInfo = "", 		-- 赛季说明
	maxSegmentLevel = 0,	-- 赛季最高段位
	maxSegmentModelName = "",-- 模式名称
	segmentName = "",		-- 段位名称
	
	isProcessing = false,	-- 是否是当前赛季
	isPageShowing = false,	-- 当前Page是否开启
	
	curTab = 0,
};
BP_ARRAY_SeasonReview_Summary = 
{
	BP_STRUCT_SeasonReview_Summary = _G.BP_STRUCT_SeasonReview_Summary,
};

-- 当前开启的排行页签
BP_STRUCT_SeasonReview_Page_Rank = 
{
	tabType = 0,			-- 页签类型
	subTabType = 0,			-- 子页签类型
	totalRating = 0,		-- 总积分
	totalRank = 0,			-- 总排名
	taotalRankRefer = "",	-- 排名参考
	showRankNumber = true,	-- 是否显示排名信息
};
-- 当前开启的排行页签item数据
BP_STRUCT_SeasonReview_Page_RankItem = 
{
	maxRating = 0,				-- 总积分
	maxSegmentLevel = 0,		-- 最高段位
	maxSegmentName = "",		-- 最高段位名称
	maxSegmentModelName = "",	-- 最高段位模式名称
	
	gameNumber = 0,				-- 总局数
	winNumber = 0,				-- 吃鸡数
	top10Number = 0,			-- 前十次数
	failedNumber_str = "",		-- 失败比例
};
BP_ARRAY_SeasonReview_Page_RankItem = 
{
	BP_STRUCT_SeasonReview_Page_RankItem = _G.BP_STRUCT_SeasonReview_Page_RankItem,
};
-- 当前开启的排行页签子页签数据
BP_STRUCT_SeasonReview_Page_RankSubTab = 
{
	tab = 1,
	tabName = "",
	isSelected = false,
}
BP_ARRAY_SeasonReview_Page_RankSubTab = 
{
	BP_STRUCT_SeasonReview_Page_RankSubTab = _G.BP_STRUCT_SeasonReview_Page_RankSubTab,
};


-- 当前开启的功勋页签
BP_STRUCT_SeasonReview_Page_SegmentItem = 
{
	id = 0,
	num = 0,
	iconPath = "";
	titlePath = "";
};
BP_ARRAY_SeasonReview_Page_SegmentItem = 
{
	BP_STRUCT_SeasonReview_Page_SegmentItem = _G.BP_STRUCT_SeasonReview_Page_SegmentItem,
};

-- 当前开启的档案支持的页签数据
BP_STRUCT_SeasonReview_Tab = 
{
	tab = 1,
	tabName = "",
	isSelected = false,
};
BP_ARRAY_SeasonReview_Tab = 
{
	BP_STRUCT_SeasonReview_Tab = _G.BP_STRUCT_SeasonReview_Tab,
};

-- 赛季功勋墙title
BP_SeasonReview_Segment_Title = "";
-- 当前操作的赛季档案ID
BP_SeasonReview_CurSeasonID = 1;
-- 当前操作的赛季档案页签ID
BP_SeasonReview_CurSeasonTab = 1;
-- 当前操作的赛季档案子页签ID
BP_SeasonReview_CurSeasonSubTab = 1;

-- 注册面板
function bp_season_review_RegisterUI()
	LuaClassObj.SubUIWidgetList(bp_season_review,
        {
			{Path="/Game/UMG/UI_Logic/SeasonReview/Lobby_Season_Review_BP.Lobby_Season_Review_BP_C", Container="Default", ZOrder=BP_ENUM_UI_SEASON_REVIEW_ZORDER},
		},
		{"Lobby"},
		false,
		bp_season_review_OnModeSwitched ~= nil
	);		
	
	SeasonReviewUI.listSeasonTabInfo = {};
	BP_ARRAY_SeasonReview_Summary = {};
	BP_ARRAY_SeasonReview_Tab = {};
	BP_ARRAY_SeasonReview_Page_SegmentItem = {};
	BP_ARRAY_SeasonReview_Page_RankSubTab = {};
end



function SeasonReviewUI.ShowPanel(uid)
	uid = uid or DataMgr.roleData.uid;	
	SeasonReviewUI.curSeasonReviewOwnerUid = tonumber(uid);
	
	SeasonReviewUI.listSeasonTabInfo = {};
	BP_ARRAY_SeasonReview_Summary = {};
	BP_ARRAY_SeasonReview_Tab = {};
	BP_ARRAY_SeasonReview_Page_SegmentItem = {};
	
	BP_ARRAY_SeasonReview_Page_RankSubTab = {};
	table.insert(BP_ARRAY_SeasonReview_Page_RankSubTab, {tab = 1, tabName = Client.GetTableData("LocalizeRes", "100040").TextValue, isSelected = false});
	table.insert(BP_ARRAY_SeasonReview_Page_RankSubTab, {tab = 2, tabName = Client.GetTableData("LocalizeRes", "100050").TextValue, isSelected = false});
	
	SeasonReviewSystem.sendGetSeasonReviewSummy(uid);
	
	LuaClassObj.HandleUIMessage(bp_season_review, "UIShow");
end

function SeasonReviewUI.HidePanel()
	LuaClassObj.HandleUIMessage(bp_season_review, "UIHide");
end

function SeasonReviewUI.InitReviewData(listSummary)	
	BP_ARRAY_SeasonReview_Summary = {};
	
	-- 增加赛季的排序功能
	local listSummaryKeys = {};
	for k in pairs(listSummary) do
		table.insert(listSummaryKeys, k);
	end
	table.sort(listSummaryKeys);
	
	for i, k in ipairs(listSummaryKeys) do
		local v = listSummary[k];
		local seasonInfoConfig = Client.GetTableData("SeasonInfo", k);
		local modelConfig = Client.GetTableData("MatchModeTable", v.mode);
		local segmentConfig = Client.GetTableData("RankIntegralLevel", v.reached_max_segment);
		local seasonTabConfig = Client.GetTableData("SeasonReviewTab", k);
		
		if seasonInfoConfig and modelConfig and segmentConfig and seasonTabConfig then		
			local summaryData = {
				id = seasonInfoConfig.SeasonID,					-- 赛季id
				seasonName = seasonInfoConfig.SeasonName, 		-- 赛季名称
				seasonInfo = seasonInfoConfig.DisplayTime, 		-- 赛季说明
								
				maxSegmentModelName = DataMgr.GetMsgByID(modelConfig.WordsToShowID),-- 模式名称
				
				maxSegmentLevel = v.reached_max_segment,	-- 赛季最高段位
				segmentIconPath = "",	-- 段位icon路径
				segmentName = segmentConfig.Name,		-- 段位名称		
				
				isProcessing = false,	-- 是否是当前赛季
				curTab = 1,
			};
						
			-- 初始化页签数据
			SeasonReviewUI.listSeasonTabInfo[seasonInfoConfig.SeasonID] = {};
			if seasonTabConfig.SeasonRankFlag == 1 then
				table.insert(SeasonReviewUI.listSeasonTabInfo[seasonInfoConfig.SeasonID], {tabType = SeasonReviewUI.PAGE_RANK, info = nil});				
			end
			
			if seasonTabConfig.SeasonRecordFlag == 1 then
				table.insert(SeasonReviewUI.listSeasonTabInfo[seasonInfoConfig.SeasonID], {tabType = SeasonReviewUI.PAGE_SEGMENT, info = nil});
			end
			
			if #SeasonReviewUI.listSeasonTabInfo[seasonInfoConfig.SeasonID] > 0 then
				summaryData.curTab = SeasonReviewUI.listSeasonTabInfo[seasonInfoConfig.SeasonID][1].tabType;
			end
			
			table.insert(BP_ARRAY_SeasonReview_Summary, summaryData);	
		else
			if not seasonInfoConfig then
				log("SeasonReviewUI.InitReviewData Error seasonInfoConfig:"..k);
			end
			if not modelConfig then
				log("SeasonReviewUI.InitReviewData Error modelConfig:"..v.mode);
			end
			if not segmentConfig then
				log("SeasonReviewUI.InitReviewData Error segmentConfig:"..v.reached_max_segment);
			end
			if not seasonTabConfig then
				log("SeasonReviewUI.InitReviewData Error seasonTabConfig:"..k);
			end
		end
	end
		
	--log_tree("SeasonReviewUI.InitReviewData BP_ARRAY_SeasonReview_Summary", BP_ARRAY_SeasonReview_Summary);
	--log_tree("SeasonReviewUI.InitReviewData listSeasonTabInfo", SeasonReviewUI.listSeasonTabInfo);
	
	if #BP_ARRAY_SeasonReview_Summary > 0 then	
		LuaClassObj.HandleUIMessage(bp_season_review, "InitView");
	else
		LuaClassObj.HandleUIMessage(bp_season_review, "EmptyView");
	end
end

-- 创建页签数据
function SeasonReviewUI.CreatePageTabInfo(curTab, seasonInfo)
	local tabPageInfo = {};
	local tabName = "";
	for i,v in ipairs(seasonInfo) do
		if v.tabType == SeasonReviewUI.PAGE_RANK then
			tabName = Client.GetTableData("LocalizeRes", "5070").TextValue;
			table.insert(tabPageInfo, {tab = v.tabType, tabName = tabName, isSelected = (v.tabType == curTab)});
		elseif v.tabType == SeasonReviewUI.PAGE_SEGMENT then
			tabName = Client.GetTableData("LocalizeRes", "5071").TextValue;
			table.insert(tabPageInfo, {tab = v.tabType, tabName = tabName, isSelected = (v.tabType == curTab)});
		end
	end
	
	return tabPageInfo;
end

-- 刷新页签内容
function SeasonReviewUI.UpdatePageData(targetUid, seasonId, tabType, record)	
	log("SeasonReviewUI.UpdatePageData seasonId:"..seasonId..", tabType:"..tabType);
	for i,v in ipairs(BP_ARRAY_SeasonReview_Summary) do
		if v.id == seasonId then
			-- 切换页签
			v.curTab = tabType;
			break;
		end
	end	
		
	BP_SeasonReview_CurSeasonTab = tabType;
	BP_ARRAY_SeasonReview_Tab = SeasonReviewUI.CreatePageTabInfo(tabType, SeasonReviewUI.listSeasonTabInfo[seasonId]);
	
	if tabType == SeasonReviewUI.PAGE_RANK then		
		BP_SeasonReview_CurSeasonSubTab = 1;	
		if record.total_rank_rating < record.fpp_total_rank_rating then
			BP_SeasonReview_CurSeasonSubTab = 2;
		end
				
		for i,v in ipairs(BP_ARRAY_SeasonReview_Page_RankSubTab) do
			v.isSelected = BP_SeasonReview_CurSeasonSubTab == v.tab;
		end
		BP_STRUCT_SeasonReview_Page_Rank, BP_ARRAY_SeasonReview_Page_RankItem = SeasonReviewUI.CreateRankPageData(seasonId, tabType, BP_SeasonReview_CurSeasonSubTab, record);
	elseif tabType == SeasonReviewUI.PAGE_SEGMENT then
		BP_ARRAY_SeasonReview_Page_SegmentItem = SeasonReviewUI.CreateSegmentPageData(seasonId, tabType, record);
		BP_SeasonReview_Segment_Title = "";
		for i,v in ipairs(BP_ARRAY_SeasonReview_Summary) do
			if v.id == seasonId then
				BP_SeasonReview_Segment_Title = v.seasonName..Client.GetTableData("LocalizeRes", "5072").TextValue;
				break;
			end
		end
		
		--log_tree("BP_ARRAY_SeasonReview_Page_SegmentItem", BP_ARRAY_SeasonReview_Page_SegmentItem);
	else
		return;
	end
	
	LuaClassObj.HandleUIMessage(bp_season_review, "UpdateItemPageStatus");
end

-- 创建成就数据
function SeasonReviewUI.CreateSegmentPageData(seasonID, tabType, record)
	local arraySegmentData = {};
	for k,v in pairs(record) do
		local titleConfig = Client.GetTableData("ResultTitleConfig", k);
		if titleConfig then
			table.insert(arraySegmentData, {id = k, num = v.num, iconPath = titleConfig.IconPath, titlePath = titleConfig.PedalPath});
		end
	end	

	for i,v in ipairs(SeasonReviewUI.listSeasonTabInfo[seasonID]) do
		if v.tabType == tabType then
			v.info = arraySegmentData;
			break;
		end
	end
	log("SeasonReviewUI.CreateSegmentPageData tabType:"..tabType);
	--log_tree("arraySegmentData", arraySegmentData);
	
	return arraySegmentData;
end

-- 创建排行数据
function SeasonReviewUI.CreateRankPageData(seasonID, tabType, subTabType, record)
	local seasonTabConfig = Client.GetTableData("SeasonReviewTab", seasonID);
	
	local taotalRankRefer = "";
	if record.tpp_rank == 0 then
		taotalRankRefer = FuncUtil.calc_topn_percentage(record.total_rank_rating, record.tpp_refer_rating);
		if taotalRankRefer then
			--taotalRankRefer = Client.GetTableData("LocalizeRes", "5073").TextValue..taotalRankRefer;
		else
			taotalRankRefer = "";
		end
	end
	local pageRankDataThreePerson = 
	{
		tabType = tabType,			-- 页签类型
		subTabType = 1,			-- 子页签类型
		totalRating = record.total_rank_rating,		-- 总积分
		totalRank = record.tpp_rank,			-- 总排名
		taotalRankRefer = taotalRankRefer,	-- 排名参考		
		showRankNumber = (seasonTabConfig and seasonTabConfig.SeasonRecordFlag == 1),	-- 是否显示排名信息	
	};
	
	taotalRankRefer = "";
	--log_tree("record", record);
	if record.fpp_rank == 0 then
		taotalRankRefer = FuncUtil.calc_topn_percentage(record.fpp_total_rank_rating, record.fpp_refer_rating);
		--log("taotalRankRefer "..tostring(taotalRankRefer));
		if taotalRankRefer then
			--taotalRankRefer = Client.GetTableData("LocalizeRes", "5073").TextValue..taotalRankRefer;
		else
			taotalRankRefer = "";
		end
	end
	local pageRankDataOnePerson = 
	{
		tabType = tabType,			-- 页签类型
		subTabType = 2,			-- 子页签类型
		totalRating = record.fpp_total_rank_rating,		-- 总积分
		totalRank = record.fpp_rank,			-- 总排名
		taotalRankRefer = taotalRankRefer,	-- 排名参考		
		showRankNumber = (seasonTabConfig and seasonTabConfig.SeasonRecordFlag == 1),	-- 是否显示排名信息
	};	
	
	
	
	-- 第三人称
	local listRankItemDataThreePerson = {};
	local segmentConfig = {};
	local segmentName = "";
	
	if record.solo then
		segmentConfig = Client.GetTableData("RankIntegralLevel", record.solo.segment);
		segmentName = "";
		if segmentConfig then
			segmentName = segmentConfig.Name;
		end
		table.insert(listRankItemDataThreePerson, 
		{
			maxRating = record.solo.rating,				-- 总积分
			maxSegmentLevel = record.solo.segment,		-- 最高段位
			maxSegmentName = segmentName,				-- 最高段位名称
			maxSegmentModelName = Client.GetTableData("LocalizeRes", "100030").TextValue,				-- 最高段位模式名称
			
			gameNumber = record.solo.game_num,				-- 总局数
			winNumber = record.solo.win_num,				-- 吃鸡数
			top10Number = record.solo.top10_count,			-- 前十次数
			--failedNumber = record.solo.kd,			-- 失败次数
			failedNumber_str = string.format("%.2f", record.solo.kd), 	-- 失败次数
		});
	end
	
	if record.duo then		
		segmentConfig = Client.GetTableData("RankIntegralLevel", record.duo.segment);
		segmentName = "";
		if segmentConfig then
			segmentName = segmentConfig.Name;
		end
		table.insert(listRankItemDataThreePerson, 
		{
			maxRating = record.duo.rating,				-- 总积分
			maxSegmentLevel = record.duo.segment,		-- 最高段位
			maxSegmentName = segmentName,				-- 最高段位名称
			maxSegmentModelName = Client.GetTableData("LocalizeRes", "100031").TextValue,				-- 最高段位模式名称
			
			gameNumber = record.duo.game_num,				-- 总局数
			winNumber = record.duo.win_num,				-- 吃鸡数
			top10Number = record.duo.top10_count,			-- 前十次数
			--failedNumber = record.duo.kd,			-- 失败次数
			failedNumber_str = string.format("%.2f", record.duo.kd), 	-- 失败次数
		});
	end
	if record.squad then
		segmentConfig = Client.GetTableData("RankIntegralLevel", record.squad.segment);
		segmentName = "";
		if segmentConfig then
			segmentName = segmentConfig.Name;
		end
		table.insert(listRankItemDataThreePerson, 
		{
			maxRating = record.squad.rating,				-- 总积分
			maxSegmentLevel = record.squad.segment,		-- 最高段位
			maxSegmentName = segmentName,				-- 最高段位名称
			maxSegmentModelName = Client.GetTableData("LocalizeRes", "100032").TextValue,				-- 最高段位模式名称
			
			gameNumber = record.squad.game_num,				-- 总局数
			winNumber = record.squad.win_num,				-- 吃鸡数
			top10Number = record.squad.top10_count,			-- 前十次数
			--failedNumber = record.squad.kd,			-- 失败次数
			failedNumber_str = string.format("%.2f", record.squad.kd), 	-- 失败次数
		});
	end
	
	
	-- 第一人称
	local listRankItemDataOnePerson = {};
	if record.fppsolo then
		segmentConfig = Client.GetTableData("RankIntegralLevel", record.fppsolo.segment);
		segmentName = "";
		if segmentConfig then
			segmentName = segmentConfig.Name;
		end
		table.insert(listRankItemDataOnePerson, 
		{
			maxRating = record.fppsolo.rating,				-- 总积分
			maxSegmentLevel = record.fppsolo.segment,		-- 最高段位
			maxSegmentName = segmentName,				-- 最高段位名称
			maxSegmentModelName = Client.GetTableData("LocalizeRes", "100030").TextValue,				-- 最高段位模式名称
			
			gameNumber = record.fppsolo.game_num,				-- 总局数
			winNumber = record.fppsolo.win_num,				-- 吃鸡数
			top10Number = record.fppsolo.top10_count,			-- 前十次数
			--failedNumber = record.fppsolo.kd,			-- 失败次数
			failedNumber_str = string.format("%.2f", record.fppsolo.kd), 	-- 失败次数
		});
	end
	if record.fppduo then
		segmentConfig = Client.GetTableData("RankIntegralLevel", record.fppduo.segment);
		segmentName = "";
		if segmentConfig then
			segmentName = segmentConfig.Name;
		end
		table.insert(listRankItemDataOnePerson, 
		{
			maxRating = record.fppduo.rating,				-- 总积分
			maxSegmentLevel = record.fppduo.segment,		-- 最高段位
			maxSegmentName = segmentName,				-- 最高段位名称
			maxSegmentModelName = Client.GetTableData("LocalizeRes", "100031").TextValue,				-- 最高段位模式名称
			
			gameNumber = record.fppduo.game_num,				-- 总局数
			winNumber = record.fppduo.win_num,				-- 吃鸡数
			top10Number = record.fppduo.top10_count,			-- 前十次数
			--failedNumber = record.fppduo.kd,			-- 失败次数
			failedNumber_str = string.format("%.2f", record.fppduo.kd), 	-- 失败次数
		});
	end
	if record.fppsquad then
		segmentConfig = Client.GetTableData("RankIntegralLevel", record.fppsquad.segment);
		segmentName = "";
		if segmentConfig then
			segmentName = segmentConfig.Name;
		end
		table.insert(listRankItemDataOnePerson, 
		{
			maxRating = record.fppsquad.rating,				-- 总积分
			maxSegmentLevel = record.fppsquad.segment,		-- 最高段位
			maxSegmentName = segmentName,				-- 最高段位名称
			maxSegmentModelName = Client.GetTableData("LocalizeRes", "100032").TextValue,				-- 最高段位模式名称
			
			gameNumber = record.fppsquad.game_num,				-- 总局数
			winNumber = record.fppsquad.win_num,				-- 吃鸡数
			top10Number = record.fppsquad.top10_count,			-- 前十次数
			--failedNumber = record.fppsquad.kd,			-- 失败次数
			failedNumber_str = string.format("%.2f", record.fppsquad.kd), 	-- 失败次数
		});
	end
	
	-- 存储数据
	for i,v in ipairs(SeasonReviewUI.listSeasonTabInfo[seasonID]) do
		if v.tabType == tabType then
			v.info = {};
			if #listRankItemDataThreePerson > 0 then
				v.info[1] = {rankData = pageRankDataThreePerson, itemData = listRankItemDataThreePerson};				
			end
			if #listRankItemDataOnePerson > 0 then
				v.info[2] = {rankData = pageRankDataOnePerson, itemData = listRankItemDataOnePerson};
			end
			break;
		end
	end
	log("SeasonReviewUI.CreateRankPageData tabType:"..tabType);
	
	if subTabType == 1 then
		return pageRankDataThreePerson, listRankItemDataThreePerson;
	elseif subTabType == 2 then
		return pageRankDataOnePerson, listRankItemDataOnePerson;
	end
end

function EventFetchInfo()
	
end

-- 点击赛季item
function EventClickSummaryItem_Push()
	log("EventClickSummaryItem_Push BP_SeasonReview_CurSeasonID:"..BP_SeasonReview_CurSeasonID);
	local isPageShowing = false;
	for i,v in ipairs(BP_ARRAY_SeasonReview_Summary) do
		if BP_SeasonReview_CurSeasonID == v.id then
			v.isPageShowing = not v.isPageShowing;	
			isPageShowing = v.isPageShowing;
		else
			v.isPageShowing = false;
		end
	end	
	
	--log_tree("BP_ARRAY_SeasonReview_Summary", BP_ARRAY_SeasonReview_Summary);
	
	if isPageShowing then
		log("EventClickSummaryItem_Push OpenPage......");
		local seasonId = BP_SeasonReview_CurSeasonID;
		local pageInfo = SeasonReviewUI.listSeasonTabInfo[BP_SeasonReview_CurSeasonID][1].info;
		local tabType = SeasonReviewUI.listSeasonTabInfo[BP_SeasonReview_CurSeasonID][1].tabType;
		
		BP_SeasonReview_CurSeasonTab = tabType;
		BP_ARRAY_SeasonReview_Tab = SeasonReviewUI.CreatePageTabInfo(tabType, SeasonReviewUI.listSeasonTabInfo[seasonId]);
				
		--log_tree("SeasonReviewUI.listSeasonTabInfo", SeasonReviewUI.listSeasonTabInfo);		
		
		if pageInfo then	
			-- 打开page			
			if tabType == SeasonReviewUI.PAGE_RANK then
				BP_SeasonReview_CurSeasonSubTab = 1;	
				if #pageInfo > 1 and pageInfo[1].rankData.totalRating < pageInfo[2].rankData.totalRating then
					BP_SeasonReview_CurSeasonSubTab = 2;
				end
				
				
				for i,v in ipairs(BP_ARRAY_SeasonReview_Page_RankSubTab) do
					v.isSelected = BP_SeasonReview_CurSeasonSubTab == v.tab;
				end
				
				BP_STRUCT_SeasonReview_Page_Rank = pageInfo[BP_SeasonReview_CurSeasonSubTab].rankData;
				BP_ARRAY_SeasonReview_Page_RankItem = pageInfo[BP_SeasonReview_CurSeasonSubTab].itemData;
				
				if BP_STRUCT_SeasonReview_Page_Rank and BP_ARRAY_SeasonReview_Page_RankItem then
					log("has Rank Data seasonId:"..seasonId..", tabType:"..tabType);		
					LuaClassObj.HandleUIMessage(bp_season_review, "UpdateItemPageStatus");					
				else
					log("EventClickSummaryItem_Push error RnakData or ItemData is nil!");	
				end
				
			elseif tabType == SeasonReviewUI.PAGE_SEGMENT then
				BP_ARRAY_SeasonReview_Page_SegmentItem = pageInfo;
				BP_SeasonReview_Segment_Title = "";
				for i,v in ipairs(BP_ARRAY_SeasonReview_Summary) do
					if v.id == seasonId then
						BP_SeasonReview_Segment_Title = v.seasonName..Client.GetTableData("LocalizeRes", "5072").TextValue;
						break;
					end
				end
		
				log("has Seqment Data seasonId:"..seasonId..", tabType:"..tabType);
				LuaClassObj.HandleUIMessage(bp_season_review, "UpdateItemPageStatus");
			else
				return;
			end
		else
			-- 请求page数据
			log("has not SeasonTab Data seasonId:"..seasonId..", tabType:"..tabType);
			SeasonReviewSystem.sendGetSeasonFile(SeasonReviewUI.curSeasonReviewOwnerUid, seasonId, tabType);
			--SeasonReviewSystem.OnGetSeasonFileRsp("ok", SeasonReviewUI.curSeasonReviewOwnerUid, seasonId, tabType, {});
		end
	else
		-- 关闭page
		log("EventClickSummaryItem_Push ClosePage......");
		LuaClassObj.HandleUIMessage(bp_season_review, "UpdateItemPageStatus");
	end
end

-- 点击赛季视图的页签按钮
function EventClickSummaryTabButton_Push()
	log("EventClickSummaryTabButton_Push SeasonID:"..BP_SeasonReview_CurSeasonID..", CurSeasonTab:"..BP_SeasonReview_CurSeasonTab);
	
	local pageInfo = nil;
	for k,v in pairs(SeasonReviewUI.listSeasonTabInfo[BP_SeasonReview_CurSeasonID]) do
		if v.tabType == BP_SeasonReview_CurSeasonTab then
			pageInfo = v.info;
			break;
		end
	end
	
	if pageInfo then
		--log_tree("pageInfo", pageInfo);
		for i,v in ipairs(BP_ARRAY_SeasonReview_Tab) do
			v.isSelected = BP_SeasonReview_CurSeasonTab == v.tab;
		end
			
		if BP_SeasonReview_CurSeasonTab == SeasonReviewUI.PAGE_RANK then	
			for i,v in ipairs(BP_ARRAY_SeasonReview_Page_RankSubTab) do
				v.isSelected = BP_SeasonReview_CurSeasonSubTab == v.tab;
			end
			
			BP_STRUCT_SeasonReview_Page_Rank = pageInfo[BP_SeasonReview_CurSeasonSubTab].rankData;
			BP_ARRAY_SeasonReview_Page_RankItem = pageInfo[BP_SeasonReview_CurSeasonSubTab].itemData;
			
			if BP_STRUCT_SeasonReview_Page_Rank and BP_ARRAY_SeasonReview_Page_RankItem then
				LuaClassObj.HandleUIMessage(bp_season_review, "UpdateItemPageStatus");
			else
				log("EventClickSummaryTabButton_Push RankData or RankItemData is nil!!!");
			end
			
		elseif BP_SeasonReview_CurSeasonTab == SeasonReviewUI.PAGE_SEGMENT then
			BP_ARRAY_SeasonReview_Page_SegmentItem = pageInfo;			
			LuaClassObj.HandleUIMessage(bp_season_review, "UpdateItemPageStatus"); 
		else
			return;
		end
	else
		-- 请求page数据
		SeasonReviewSystem.sendGetSeasonFile(SeasonReviewUI.curSeasonReviewOwnerUid, BP_SeasonReview_CurSeasonID, BP_SeasonReview_CurSeasonTab);
		--SeasonReviewSystem.OnGetSeasonFileRsp("ok", SeasonReviewUI.curSeasonReviewOwnerUid, BP_SeasonReview_CurSeasonID, BP_SeasonReview_CurSeasonTab, {});
	end
end

-- 点击排行榜子页签按钮
function EventClickSummaryRankTabButton_Push()
	log("EventClickSummaryRankTabButton_Push SeasonID:"..BP_SeasonReview_CurSeasonID..", CurSeasonTab:"..BP_SeasonReview_CurSeasonTab..", RankTab:"..BP_SeasonReview_CurSeasonSubTab);
	local rankInfo = nil;
	for k,v in pairs(SeasonReviewUI.listSeasonTabInfo[BP_SeasonReview_CurSeasonID]) do
		if v.tabType == SeasonReviewUI.PAGE_RANK then
			rankInfo = v.info;
			break;
		end
	end
	
	if rankInfo then
		--log_tree("rankInfo", rankInfo);
		BP_STRUCT_SeasonReview_Page_Rank = rankInfo[BP_SeasonReview_CurSeasonSubTab].rankData;
		BP_ARRAY_SeasonReview_Page_RankItem = rankInfo[BP_SeasonReview_CurSeasonSubTab].itemData;
		
		log("UpdateItemPageStatus~~~");
		LuaClassObj.HandleUIMessage(bp_season_review, "UpdateItemPageStatus");
	end	
end
