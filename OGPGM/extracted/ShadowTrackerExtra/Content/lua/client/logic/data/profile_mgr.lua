ProfileMgr = ProfileMgr or
{
	-- 详情数据结构
	profileData = 
	{
		isInit = false,
		uid = 0,
		city = "",	-- 所在城市
		level = 0,	-- 等级
		lastLoginTime = 0,	-- 上次登录时间
		segment_info = {},	-- 段位数据，数组
		nickName = "",	-- 游戏玩家名称
		platName = "",	-- 平台玩家名称
		sex = 1,	-- 性别
		signature = "",	-- 签名
		lastOnlineTime = 0,	-- 上次在线时间
		vipLevel = 0,	-- vip等级
		picUrl = "",	-- 头像url
		exp = 0,		-- 经验
		history_max_segment_level = 0,	--历史最高段位
		cur_max_segment_level = 0,	--当前最高段位
		cur_avatar_box_id = 0,  -- 头像框id
		startup_type = 0, -- 平台启动特权
		qq_vip = 0,	-- qq会员	
        social_card = {}, -- 名片
        corps_id = 0, -- 军团id
        credit = 0, -- 幸运分
	},
	
	-- 陌生人详情信息
	dicStrangerProfile = {},
	-- 好友详情信息
	dicFriendProfile = {},	
	-- 发送请求列表
	dicSendList = {},

	-- 模式名称缓存列表
	dicGameModeStr = {},

	-- 玩家组队状态和在线状态临时缓存列表
	dicTempTeamStatusAndOnline = {},

	-- 个人角色信息数据表
	dicRoleInfo = {},
	
	sendSeq = 0,
	
	maxSendUidCount = 100,

	CDTime = 1800,
}
function ProfileMgr.ResetProfileData()
	log("ProfileMgr.ResetProfileData!!!");
	ProfileMgr.dicStrangerProfile = {};
	ProfileMgr.dicFriendProfile = {};
	ProfileMgr.dicSendList = {};
	ProfileMgr.dicGameModeStr = {};
	ProfileMgr.dicTempTeamStatusAndOnline = {};
	ProfileMgr.sendSeq = 0;
end

-- 获取本地已获得的详情数据
-- 当前数据有可能是nil
function ProfileMgr.GetLocalProfileDataByUid(uid)
	if ProfileMgr.dicFriendProfile[tonumber(uid)] and ProfileMgr.dicFriendProfile[tonumber(uid)].isInit then
		return ProfileMgr.dicFriendProfile[tonumber(uid)];
	end	
	
	if ProfileMgr.dicStrangerProfile[tonumber(uid)] and ProfileMgr.dicStrangerProfile[tonumber(uid)].isInit then
		return ProfileMgr.dicStrangerProfile[tonumber(uid)];
	end	
	
	return nil;
end

-- 获取好友详情数据
---- listUid 列表数据
---- callback 回调函数
---- needRefresh 是否强行刷新数据
---- refreshOnlineStatus 是否刷新在线和组队状态
function ProfileMgr.GetFriendProfileList(listUid, callback, needRefresh, refreshOnlineStatus)		
	--log("GetFriendProfileList need get: "..#listUid);
	ProfileMgr.GetProfileList(listUid, callback, needRefresh, true, nil, refreshOnlineStatus);
	return;
end

-- 清理好友数据
function ProfileMgr.ClearFriendProfileList()
	ProfileMgr.dicFriendProfile = {};
end

-- 设置好友部分数据
function ProfileMgr.SetFriendSubData(listData)
	if listData.inner_list then
		-- 设置好友亲密度
		for k,v in pairs(listData.inner_list) do
			if ProfileMgr.dicFriendProfile[k] then
				ProfileMgr.dicFriendProfile[k].intimacy = v.intimacy;
				ProfileMgr.dicFriendProfile[k].isPlatFriend = false;		
			else
				ProfileMgr.dicFriendProfile[k] = {isInit = false, uid = tostring(k), remarks_name = "", intimacy = v.intimacy, isPlatFriend = false};
			end
		end
	end
	
	if listData.plat_list then
		-- 设置平台备注名称
		local remarksName = "";
		for k,v in pairs(listData.plat_list) do
			_, _, remarksName = FuncUtil:CheckName(v.remarks_name, nil, 14);
			if string.len(v.remarks_name) > string.len(remarksName) then
				remarksName = remarksName.."...";
			end
			
			if ProfileMgr.dicFriendProfile[k] then
				ProfileMgr.dicFriendProfile[k].remarks_name = remarksName;
				ProfileMgr.dicFriendProfile[k].isPlatFriend = true;				
				
				if ProfileMgr.dicFriendProfile[k].gameName and ProfileMgr.dicFriendProfile[k].remarks_name ~= "" then
					ProfileMgr.dicFriendProfile[k].nickName = ProfileMgr.dicFriendProfile[k].gameName.."("..remarksName..")";
				end
			else
				ProfileMgr.dicFriendProfile[k] = {isInit = false, uid = tostring(k), remarks_name = remarksName, intimacy = 0, isPlatFriend = true};
			end
		end
	end	
	
	--log_tree("dicFriendProfile",ProfileMgr.dicFriendProfile);
end

-- 获取陌生人详情数据
---- listUid 列表数据
---- callback 回调函数
---- needRefresh 是否强行刷新数据
---- isFriend 是否是好友数据
---- rankDataFlag 是否获取排行榜数据
---- refreshOnlineStatus 是否刷新在线和组队状态
function ProfileMgr.GetProfileList(listUid, callback, needRefresh, isFriend, rankDataFlag, refreshOnlineStatus)	

	--是否在CD 期内 
	local function IsInCDtime(timestamp)
		-- body
		local cdtime = tonumber(FuncUtil.GetServerTimeInSec() - tonumber(timestamp))
		log(" cdtime ".. tostring(cdtime))
		if cdtime < ProfileMgr.CDTime then
			return true
		else
			return false
		end
	end

	local listGot = {};
	local listNotGet = {};
	local binListUid = {};
	local sendCount = 1;
	local sendOnlineStatus = 0;
	needRefresh = needRefresh or false;
	isFriend = isFriend or false;
	rankDataFlag = rankDataFlag or 0;
	refreshOnlineStatus = refreshOnlineStatus or false;
	
	log("GetProfileList listUidLen:"..#listUid..", needRefresh:"..tostring(needRefresh)..", isFriend:"..tostring(isFriend)..", rankDataFlag:"..rankDataFlag..", refreshOnlineStatus:"..tostring(refreshOnlineStatus));
	--log_tree("GetProfileList: listUid", listUid);
	if listUid == nil or #listUid == 0 then
		log("GetProfileList listUid is nil or 0");
		return;
	end
		
	for k,v in pairs(listUid) do
		if tonumber(v) > 0 then
			if needRefresh == false then	--不是强拉	
				if ProfileMgr.dicFriendProfile[v] and ProfileMgr.dicFriendProfile[v].isInit then
					-- 先去好友里找
					table.insert(listGot, ProfileMgr.dicFriendProfile[v])
				elseif isFriend == false and ProfileMgr.dicStrangerProfile[v] and ProfileMgr.dicStrangerProfile[v].isInit then
					-- 再去陌生人里找
					table.insert(listGot, ProfileMgr.dicStrangerProfile[v])
				else
					table.insert(listNotGet, v)
				end
			else	--是强拉
				if #listUid > 1 then	--多个数据需要请求时候，1、看缓存是否存在  2、要看是否过了冷却的CD期
					if ProfileMgr.dicFriendProfile[v] and ProfileMgr.dicFriendProfile[v].isInit then
						if ProfileMgr.dicFriendProfile[v].timestamp then
							--超过CD期了 就去拉取
							log("ProfileMgr.dicFriendProfile[v].timestamp " .. ProfileMgr.dicFriendProfile[v].timestamp)
							if not IsInCDtime(ProfileMgr.dicFriendProfile[v].timestamp) or rankDataFlag == 1 then --排行榜信息必须插
								table.insert(listNotGet, v)
							else
								table.insert(listGot, ProfileMgr.dicFriendProfile[v])
							end
						end
					elseif isFriend == false and ProfileMgr.dicStrangerProfile[v] and ProfileMgr.dicStrangerProfile[v].isInit then
						if ProfileMgr.dicStrangerProfile[v].timestamp then
							--超过CD期了 就去拉取
							log("ProfileMgr.dicStrangerProfile[v].timestamp " .. ProfileMgr.dicStrangerProfile[v].timestamp)
							if not IsInCDtime(ProfileMgr.dicStrangerProfile[v].timestamp) or rankDataFlag == 1 then --排行榜信息必须插
								table.insert(listNotGet, v)
							else
								log_tree("ProfileMgr.dicStrangerProfile[v]",ProfileMgr.dicStrangerProfile[v] )
								table.insert(listGot, ProfileMgr.dicStrangerProfile[v])
							end
						end		
					else
						table.insert(listNotGet, v)				
					end
				else
					log_tree("tableinsert",v)
					table.insert(listNotGet, v)
				end
			end
		end
	end	
	--jaysunzhu，屏蔽。200个好友，接近3w行日志
	--log_tree("listGot", listGot);
	--log_tree("listNotGet", listNotGet);
			
	if #listNotGet > 0 or refreshOnlineStatus then
		--log("GetProfileList need get: "..#listNotGet);
		ProfileMgr.sendSeq = ProfileMgr.sendSeq + 1;
		
		-- 发送请求列表	
		if #listNotGet > ProfileMgr.maxSendUidCount then
			local listSendUid = {};
			local index = 1;
			for i,v in ipairs(listNotGet) do
				if index > ProfileMgr.maxSendUidCount then
					--log("send batch_get_profile_req part1");
					binListUid = Client.Save(LuaStateWrapper, listSendUid);
					ProfileHander.send_batch_get_bin_profile_req(ProfileMgr.sendSeq, binListUid, rankDataFlag, #listSendUid)
					
					listSendUid = {};
					index = 1;
					sendCount = sendCount + 1;
				end
				
				table.insert(listSendUid, v);
				index = index + 1;
			end
			
			if #listSendUid > 0 then
				--log("send batch_get_profile_req part2 seq:"..ProfileMgr.sendSeq..", rankDataFlag:"..rankDataFlag);
				--log_tree("listSendUid", listSendUid);
				binListUid = Client.Save(LuaStateWrapper, listSendUid);
				ProfileHander.send_batch_get_bin_profile_req(ProfileMgr.sendSeq, binListUid, rankDataFlag, #listSendUid);
				--NetUtil.SendPkg("batch_get_profile_req", ProfileMgr.sendSeq, listSendUid, rankDataFlag);
			end
		elseif #listNotGet > 0 then
			--log("send batch_get_profile_req part seq:"..ProfileMgr.sendSeq..", rankDataFlag:"..rankDataFlag);
			--log_tree("listNotGet", listNotGet);
			binListUid = Client.Save(LuaStateWrapper, listNotGet);
			ProfileHander.send_batch_get_bin_profile_req(ProfileMgr.sendSeq, binListUid, rankDataFlag, #listNotGet);
			--NetUtil.SendPkg("batch_get_profile_req", ProfileMgr.sendSeq, listNotGet, rankDataFlag);	
		else
			sendCount = 0;
		end
				
		if refreshOnlineStatus then
			-- 拉取在线状态相关数据
			sendOnlineStatus = 1;
			--log_tree("group_and_online_req listUid", listUid);
			-- log("zino ProfileMgrsendSeq" .. ProfileMgr.sendSeq)
			-- log_tree("zino listUid ",listUid)
			NetUtil.SendPkg("batch_get_group_and_online_req", tostring(ProfileMgr.sendSeq), listUid);
		end
				
		-- 记录请求数据
		table.insert(ProfileMgr.dicSendList, 
			{sendSeq = ProfileMgr.sendSeq, 
			listGot = listGot, 
			listNotGet = listNotGet, 
			isFriend = isFriend, 
			callback = callback,
			sendCount = sendCount,
			sendOnlineStatus = sendOnlineStatus});
	elseif callback then	
		--log("GetProfileList has got");							
		callback(listGot);
	end
end

-- 获取排行榜数据
function ProfileMgr.GetRankProfileList(listUid, callback)	
	--log_tree("GetRankProfileList: listUid", listUid);
	ProfileMgr.GetProfileList(listUid, callback, true, false, 1);
	return;
end	

-- 清理陌生人数据
function ProfileMgr.ClearStrangerProfileList()
	ProfileMgr.dicStrangerProfile = {};
end

-- 获取一个陌生人详情数据
---- Uid 
---- callback 回调函数
---- needRefresh 是否强行刷新数据
---- refreshOnlineStatus 是否刷新在线状态
function ProfileMgr.GetProfile(uid, callback, needRefresh, refreshOnlineStatus)
	ProfileMgr.GetProfileList({uid}, callback, needRefresh, false, nil, refreshOnlineStatus);
end

function ProfileMgr.GetGameModeStr(modeId)
	if modeId == 0 then
		-- 与后台约定规则
		modeId = 101;
	end
	
	if ProfileMgr.dicGameModeStr[modeId] then
		return ProfileMgr.dicGameModeStr[modeId];
	else
		local modelConfig = Client.GetTableData("MatchModeTable", modeId);
		if modelConfig then
			ProfileMgr.dicGameModeStr[modeId] = modelConfig.WordsToShow;
			return ProfileMgr.dicGameModeStr[modeId];
		end
	end
	
	return "";
end

-- 拉取玩家在线状态数据返回
function ProfileMgr.OnBatchGetGroupAndOnlineRsp(sendSeq, res, infos)
	 --log("2222222222222222222222OnBatchGetGroupAndOnlineRsp res:"..res..", sendSeq:"..sendSeq);
	 --log_tree("zino infoswdqd", infos);
	-- log_tree("OnBatchGetGroupAndOnlineRsp", infos,"corps");
	
	if res ~= "ok" then
		DataMgr.ShowMessageBoxByID(res);
		return;	
	end
	
	local profileInfo = {};
	
	for k,v in pairs(ProfileMgr.dicSendList) do
		--log_tree("zino vvvvvvvvvvv",v)
		if v.sendSeq == tonumber(sendSeq)  then
			v.sendOnlineStatus = 0;
			--log("OnBatchGetGroupAndOnlineRsp isFind");
			for k,v in pairs(infos) do
				
				--log_tree("zino infoswdqd", v);
				if ProfileMgr.dicFriendProfile[k] then
					-- 是好友
					profileInfo = ProfileMgr.dicFriendProfile[k];
					profileInfo.online = v.online;
					profileInfo.teamState = v.teamStateNew;
					profileInfo.currentTeamAmount = v.currentTeamAmount;
					profileInfo.maxTeamAmount = v.maxTeamAmount;
					profileInfo.timeSinceGameBegin = v.timeSinceGameBegin;
					profileInfo.timeSinceGameBeginStr = FuncUtil.FormatTime2(v.timeSinceGameBegin);
					profileInfo.gameMode = v.game_mode;
					profileInfo.gameModeStr = ProfileMgr.GetGameModeStr(v.game_mode);
					profileInfo.gameSubMode = v.game_sub_mode;
					profileInfo.watchUid = v.watch_uid;		
					profileInfo.enableWatch = v.enable_watch;					
				elseif ProfileMgr.dicStrangerProfile[k] then
					-- 是陌生人
					profileInfo = ProfileMgr.dicStrangerProfile[k];
					profileInfo.online = v.online;
					profileInfo.teamState = v.teamStateNew;
					profileInfo.currentTeamAmount = v.currentTeamAmount;
					profileInfo.maxTeamAmount = v.maxTeamAmount;
					profileInfo.timeSinceGameBegin = v.timeSinceGameBegin;
					profileInfo.timeSinceGameBeginStr = FuncUtil.FormatTime2(v.timeSinceGameBegin);
					profileInfo.gameMode = v.game_mode;
					profileInfo.gameModeStr = ProfileMgr.GetGameModeStr(v.game_mode);
					profileInfo.gameSubMode = v.game_sub_mode;
					profileInfo.watchUid = v.watch_uid;	
					profileInfo.enableWatch = v.enable_watch;
				else
					-- 创建一个陌生人数据
					profileInfo = {
						uid = tostring(k),
						online = v.online,
						teamState = v.teamState,
						currentTeamAmount = v.currentTeamAmount,
						maxTeamAmount = v.maxTeamAmount,
						timeSinceGameBegin = v.timeSinceGameBegin,
						timeSinceGameBeginStr = FuncUtil.FormatTime2(v.timeSinceGameBegin),
						gameMode = v.gameMode,
						gameModeStr = ProfileMgr.GetGameModeStr(v.game_mode),
						gameSubMode = v.game_sub_mode,
						watchUid = v.watch_uid,
						enableWatch = v.enable_watch,
					};
					-- 缓存状态数据
					ProfileMgr.dicTempTeamStatusAndOnline[k] = profileInfo;
				end
			end
			-- log("zino sendCount "..v,sendCount )
			-- log("zino sendOnlineStatus "..v,sendOnlineStatus )
			if v.sendCount == 0 and v.sendOnlineStatus == 0 then
				--log_tree("33333333333zino v",v)
				if v.callback then
					--log("OnBatchGetGroupAndOnlineRsp callback");			
					
					local listGot = {};
					for i,v in ipairs(v.listGot) do 
						if v.isInit then
							table.insert(listGot, v);	
						end
					end
					
					v.callback(listGot);
				end
				
				table.remove(ProfileMgr.dicSendList, k);
			else
				-- 继续等待回包
				--log("OnBatchGetGroupAndOnlineRsp need wait: "..v.sendCount..", sendOnlineStatus: "..v.sendOnlineStatus);
			end
		
			break;
		end
	end
end

--创建空的角色数据
function ProfileMgr.CreateEmptyRoleData(sex)
	local roleInfo = 
	{
	    gender = sex,
	    bshow = true,
	    --{[1]=resID, [2]=colorID, [3] = patternID}
	    wear_ext = 
	    {
	        [9] = {401993,0,0},
	        [10] = {40601001,0,0},
	        [13] = {0,0,0},
	        [14] = {0,0,0},
	    },
	};
	if(roleInfo.gender == nil or roleInfo.gender == 0) then
	    roleInfo.gender = 2;
	end
    --log("ProfileMgr.CreateEmptyRoleData");
	return roleInfo;
end


-- 详情协议返回
function ProfileMgr.OnBatchGetProfileRsp(sendSeq, res, profileList, hasRankData)
	--log("22222222222222222222222222222OnBatchGetProfileRsp res:"..res..", sendSeq:"..sendSeq..", type:"..hasRankData);
	if res ~= "ok" then
		DataMgr.ShowMessageBoxByID(res);
		return;	
	end
	
	--log_tree("ProfileMgr.dicFriendProfile", ProfileMgr.dicFriendProfile);
	--log_tree("profileList", profileList);
	--log_tree("ProfileMgr.dicSendList", ProfileMgr.dicSendList);
	
	local tmpSubData = {};
	
	for k,v in pairs(ProfileMgr.dicSendList) do
		if v.sendSeq == sendSeq then
			-- 更新请求数					
			v.sendCount = v.sendCount - 1;
			
			for kk,vv in pairs(profileList) do
				local data = ProfileMgr.CreateProfileData(kk, vv);	
				
				if tostring(data.uid) == tostring(DataMgr.roleData.uid) then
					-- 是自己的详情数据 更新详情数据
					--log("is my roledata")
					--log_tree("myData", vv);
					DataMgr.UpdateMyRoleProfileData(data, vv.rankdata, vv.upass, vv.alias);
				end
				
				-- 存储/更新详情数据
				if (v.isFriend or ProfileMgr.dicFriendProfile[kk]) and tostring(data.uid) ~= tostring(DataMgr.roleData.uid) then
					if ProfileMgr.dicFriendProfile[kk] then
						tmpData = ProfileMgr.dicFriendProfile[kk];
						
						data.isPlatFriend = tmpData.isPlatFriend or false;
						
						data.remarks_name = tmpData.remarks_name or "";
						data.intimacy = tmpData.intimacy or 0;
						
						if ProfileMgr.dicTempTeamStatusAndOnline[kk] then
							tmpData = ProfileMgr.dicTempTeamStatusAndOnline[kk];	
							ProfileMgr.dicTempTeamStatusAndOnline[kk] = nil;
							--log_tree("f ProfileMgr.dicTempTeamStatusAndOnline", ProfileMgr.dicTempTeamStatusAndOnline);
						end
						
						data.online = tmpData.online or 0;
						data.teamState = tmpData.teamState or 0;
						data.currentTeamAmount = tmpData.currentTeamAmount or 0;
						data.maxTeamAmount = tmpData.maxTeamAmount or 0;
						data.timeSinceGameBegin = tmpData.timeSinceGameBegin or 0;
						data.timeSinceGameBeginStr = tmpData.timeSinceGameBeginStr or "";
						data.gameMode = tmpData.gameMode or 0;
						data.gameModeStr = tmpData.gameModeStr or "";	
						data.gameSubMode = tmpData.gameSubMode or 0;
						data.watchUid = tmpData.watchUid or 0;
						data.enableWatch = tmpData.enableWatch or 1;

						if data.isPlatFriend then
							if data.remarks_name ~= "" then
								data.nickName = data.gameName.."("..data.remarks_name..")";
							elseif data.platName ~= "" then
								data.nickName = data.gameName.."("..data.platName..")";
							end
						end
					end
					
					ProfileMgr.dicFriendProfile[kk] = data;	
				else
					if ProfileMgr.dicStrangerProfile[kk] then
						tmpData = ProfileMgr.dicStrangerProfile[kk];
						
						data.remarks_name = tmpData.remarks_name or "";
						data.intimacy = tmpData.intimacy or 0;
						
						if ProfileMgr.dicTempTeamStatusAndOnline[kk] then
							tmpData = ProfileMgr.dicTempTeamStatusAndOnline[kk];
							ProfileMgr.dicTempTeamStatusAndOnline[kk] = nil;
							--log_tree("s ProfileMgr.dicTempTeamStatusAndOnline", ProfileMgr.dicTempTeamStatusAndOnline);
						end
						
						data.online = tmpData.online or 0;
						data.teamState = tmpData.teamState or 0;
						data.currentTeamAmount = tmpData.currentTeamAmount or 0;
						data.maxTeamAmount = tmpData.maxTeamAmount or 0;
						data.timeSinceGameBegin = tmpData.timeSinceGameBegin or 0;
						data.timeSinceGameBeginStr = tmpData.timeSinceGameBeginStr or "";
						data.gameMode = tmpData.gameMode or 0;
						data.gameModeStr = tmpData.gameModeStr or "";		
						data.gameSubMode = tmpData.gameSubMode or 0;
						data.watchUid = tmpData.watchUid or 0;		
						data.enableWatch = tmpData.enableWatch or 1;				
					end
					
					ProfileMgr.dicStrangerProfile[kk] = data;
				end

				--插一个空数据
	            if ProfileMgr.dicRoleInfo[kk] == nil then
	                ProfileMgr.dicRoleInfo[kk] = ProfileMgr.CreateEmptyRoleData(data.sex);
	            end
				
				if hasRankData == 1 then
					-- 带有排行榜数据的详情数据
					local dataIncludeRank = ProfileMgr.CreateProfileData(kk, vv);	
					dataIncludeRank.isPlatFriend = data.isPlatFriend;					
					dataIncludeRank.remarks_name = data.remarks_name;
					dataIncludeRank.intimacy = data.intimacy;	
					dataIncludeRank.nickName = data.nickName;	
					
					if ProfileMgr.dicTempTeamStatusAndOnline[kk] then
						tmpData = ProfileMgr.dicTempTeamStatusAndOnline[kk];
						ProfileMgr.dicTempTeamStatusAndOnline[kk] = nil;
						--log_tree("r ProfileMgr.dicTempTeamStatusAndOnline", ProfileMgr.dicTempTeamStatusAndOnline);
					end
						
					dataIncludeRank.online = data.online;
					dataIncludeRank.teamState = data.teamState;
					dataIncludeRank.currentTeamAmount = data.currentTeamAmount;
					dataIncludeRank.maxTeamAmount = data.maxTeamAmount;
					dataIncludeRank.timeSinceGameBegin = data.timeSinceGameBegin;
					dataIncludeRank.timeSinceGameBeginStr = data.timeSinceGameBeginStr;
					dataIncludeRank.gameMode = data.gameMode;
					dataIncludeRank.gameModeStr = data.gameModeStr;	
					dataIncludeRank.gameSubMode = data.gameSubMode;
					dataIncludeRank.watchUid = data.watchUid;	
					dataIncludeRank.enableWatch = data.enableWatch;
					
					-- 补充排行榜数据
					dataIncludeRank.rankdata = vv.rankdata;
					table.insert(v.listGot, dataIncludeRank);	
				else
					-- 普通详情数据
					table.insert(v.listGot, data);	
				end				
			end
			--log("v.sendCount" ..v.sendCount)		
			--log("v.sendsendOnlineStatusCount" ..v.sendOnlineStatus)			
			if v.sendCount == 0 and v.sendOnlineStatus == 0 then
				if v.callback then
					log("OnBatchGetProfileRsp callback");
					--log_tree("listGot", v.listGot);
					
					local listGot = {};
					for i,v in ipairs(v.listGot) do 
						if v.isInit then
							table.insert(listGot, v);	
						end
					end
					
					v.callback(listGot);
				end
				
				table.remove(ProfileMgr.dicSendList, k);
			else
				-- 继续等待回包
				--log("OnBatchGetProfileRsp need wait: "..v.sendCount..", sendOnlineStatus: "..v.sendOnlineStatus);
			end
			break;
		end
	end
end

-- 创建数据
-- 在profile新增字段要注意老数据容错哦，客户端或者后台做都可以
function ProfileMgr.CreateProfileData(uid, profile)
	if profile.alias ~= nil then
		profile.alias.title = FuncUtil:Gen_title(profile.alias.id, profile.alias.rank);
	else
		profile.alias = {
			id = 0,
			rank =0,
			nation = "",
			title = "",
		}
	end
	local data = 
	{
		isInit = true,
		uid = uid,
		city = profile.city,
		nation = profile.nation,
		level = profile.level,
		lastLoginTime = profile.lastLoginTime,
		segment_info = profile.segment_info,
		nickName = profile.nickName,
		platName = profile.platName,
		sex = profile.sex,
		signature = profile.signature,
		lastOnlineTime = profile.lastOnlineTime,
		vipLevel = profile.vipLevel,
		picUrl = profile.picUrl,
		exp = profile.exp,
		upvote = profile.upvote,
		startup_type = GetSafeNumber(profile.startup_type),
		qq_vip = GetSafeNumber(profile.qq_vip),		
		cur_avatar_box_id = profile.cur_avatar_box_id,
        social_card = profile.social_card,
        corps_id = profile.corps_id,
        history_max_segment_level = profile.history_max_segment_level,	--历史最高段位
        cur_max_segment_level = FuncUtil.GetCurMaxSegementLevel(profile.segment_info), --当前最高段位
        credit = profile.credit,
		avatar_show = profile.avatar_show;
		upass = profile.upass;  -- 绝地通行证
		alias = profile.alias;  -- 称号
		language = profile.language,
		warZoneID = profile.lbs_warzone_info.warzone_id or 0, -- 战区id
        lbs_warzone_info = profile.lbs_warzone_info;

		-- 以下数据需要通过其他协议来进行赋值，这里只声明		
		remarks_name = "", -- 平台玩家备注名
		intimacy = 0, -- 亲密度，陌生人为0
		online = 0,	
		teamState = 0,
		currentTeamAmount = 0,
		maxTeamAmount = 0,
		timeSinceGameBegin = 0,
		timeSinceGameBeginStr = "",
		gameMode = 0,
		gameModeStr = "",
		gameSubMode = 0,
		watchUid = 0,
		enableWatch = profile.enable_watch~=nil and profile.enable_watch or 1,
		corp_alias_id = profile.corps_alias_info and profile.corps_alias_info.cur_corps_alias_id or 25000001,
		carteam_id = profile.carteam_id,
		timestamp = FuncUtil.GetServerTimeInSec(),	--记录获取时间

		pve_level = profile.pve_level or 1,
		pve_exp = profile.pve_exp or 0,
	};
	
	return data;
end

--sami 获取当前玩家数据
function ProfileMgr.GetPlayerDataByUid(uid)	
	local profileInfo = {};
	local roleUid = tonumber(uid);
	--log("ProfileMgr.GetPlayerDataByUid " ..roleUid);
	
	if ProfileMgr.dicFriendProfile[roleUid] then
		profileInfo = ProfileMgr.dicFriendProfile[roleUid];
		--log("dicFriendProfile");
	elseif ProfileMgr.dicStrangerProfile[roleUid] then
		profileInfo = ProfileMgr.dicStrangerProfile[roleUid];
		--log("dicStrangerProfile");
	else
		--log("no player info");
		return nil;
	end
	return profileInfo;
end

--获取角色形象数据
function ProfileMgr.GetRoleInfoDataByUid(uid)	
	local profileInfo = {};
	local roleUid = tonumber(uid);
	--log("ProfileMgr.GetRoleInfoDataByUid " ..roleUid);
	
	if ProfileMgr.dicRoleInfo[roleUid] then
		profileInfo = ProfileMgr.dicRoleInfo[roleUid];
		--log("dicRoleInfo");
	else
		--log("no player info");
		return nil;
	end
	return profileInfo;
end

--更新個人空間穿戴
function ProfileMgr.UpdatePspaceWearByUid(uid, pspace_wear_ext)
	local data = ProfileMgr.GetRoleInfoDataByUid(uid)
	if data then
		data.pspace_wear_ext = pspace_wear_ext
	end
end

--获取性别
function ProfileMgr.GetRoleSexByUid(uid)
	local info = ProfileMgr.GetRoleInfoDataByUid(uid);
	local gender = 1;
	if nil ~= info then
		gender = info.gender;
	end
	return gender;
end

function ProfileMgr.UpdateRoleSexByUid(uid, gender)
    local info = ProfileMgr.GetRoleInfoDataByUid(uid);
    if info == nil then
        ProfileMgr.dicRoleInfo[uid] = ProfileMgr.CreateEmptyRoleData(gender)
        info = ProfileMgr.dicRoleInfo[uid]
    end
    info.gender = gender
end

--获取角色国籍
function ProfileMgr.GetRoleNationByUid(uid)	
	local profileInfo = ProfileMgr.GetPlayerDataByUid(uid);
	if tonumber(uid) == tonumber(DataMgr.roleData.uid) then
		profileInfo = DataMgr.roleData
	end
	
    local nation = "";
	if nil ~= profileInfo then
	    nation = profileInfo.nation;
	end
    return nation;
end

--获取角色称号
function ProfileMgr.GetRoleAliasByUid(uid)	
	local profileInfo = ProfileMgr.GetPlayerDataByUid(uid);
    local alias = {id = 0, title = "", nation = ""};
	if nil ~= profileInfo and nil ~= profileInfo.alias then
	    alias.id = profileInfo.alias.id;
	    alias.title = profileInfo.alias.title;
	    alias.nation = profileInfo.alias.nation;
	end
    return alias;
end

--sami 发送协议-是否允许别人查看角色
function ProfileMgr.send_show_role(showRole)
    NetUtil.SendPkg("chg_avatar_show_switch_req", showRole);
end

--回包，开关设置
function ProfileMgr.on_chg_avatar_show_switch_rsp(res, bShow)
	if res ~= "ok" then
		return;
	end	
	--log("ProfileMgr.on_chg_avatar_show_switch_rsp bShow = " ..tostring(bShow));
	
	--玩家自己数据
	local roleUid = DataMgr.roleData.uid;
	local playerInfo = ProfileMgr.GetRoleInfoDataByUid(roleUid);
	if(nil == playerInfo) then
		return;
	end
	
	--更新数据
	playerInfo.bshow = bShow;
	
	--更新界面
	EventSystem:postEvent(EVENTID_NET_ROLE_INFO_RSP, BP_ENUM_MODULE_SETTING);
end

--source
--0   --默认值， 代表老客户端
--1   --从个人空间拉取个人秀
--2   --从战区空间拉取个人秀
--3   --拉取搭档的个人秀
--4   --其他地方

AvatarShowSource = 
{
	OldVersion = 0, --老版本没有发，服务器端默认值
	FromPersonSpace = 1, -- 从个人空间拉取个人秀
	FromWarRegion = 2, --从战区空间拉取个人秀
	FromPartner = 3, --拉取搭档的个人秀
	FromOther = 4, --其他地方
}

--发送协议-拉取个人角色形象数据 
function ProfileMgr.get_avatar_show_req(uid, source)
	log("ProfileMgr.get_avatar_show_req uid = " ..uid .. ",source:" .. tostring(source));
	uid = tonumber(uid)
	if uid and uid > 0 then
		NetUtil.SendPkg("get_avatar_show_req", uid, source);
	end
end
 
--回包，开关设置
--[[wear_pos =
{
    [subtype_head] = 1;
    [subtype_face] = 2;
    [subtype_clothes] = 3;
    [subtype_pants] = 4;
    [subtype_shoes] = 5;
    [avatar.headid] = 9;
    [avatar.hairid] = 10;
    [weapon_id] = 13;
    [weapon_skin_id] = 14;
};--]]
function ProfileMgr.get_avatar_show_rsp(res, target_uid, data)
    --log("ProfileMgr.get_avatar_show_rsp target_uid = " ..tostring(target_uid) ..", res = " .. res);

    --玩家数据不存在，取默认
    if res == "data_not_exist" then
	if ProfileMgr.dicRoleInfo[target_uid] == nil then
		ProfileMgr.dicRoleInfo[target_uid] = ProfileMgr.CreateEmptyRoleData(1);
	end
        --log("ProfileMgr.get_avatar_show_rsp target_uid = " ..tostring(target_uid) .." data_not_exist");
    	--更新界面
		--RoleInfoUI.UpdateRoleInfoTab();
		EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, tonumber(target_uid));
        return;
    end

	if res ~= "ok" then
		return;
	end	
	--log_tree("data = ", data);

	--填充主题，载具默认值
	local bFillTheme = false
	if data.client_ver == nil or data.client_ver == "" then
		bFillTheme = true
	else
		local arr = string.split(data.client_ver, ".")
		if arr and arr[2] and tonumber(arr[2]) < 12 then
			bFillTheme = true
		end
	end
	if bFillTheme then
		if data.wear_ext == nil then
			data.wear_ext = {}
		end
		if data.wear_ext[101] == nil then
			data.wear_ext[101] = {}
		end
		if data.wear_ext[103] == nil then
			data.wear_ext[103] = {}
		end
		data.wear_ext[101][1] = 202408001
		data.wear_ext[103][1] = 1908001
		log("ProfileMgr.get_avatar_show_rsp fill theme")
	end
	
	-- 兼容老版本数据
	if not data.wear_ext and data.wear ~= nil then
		data.wear_ext = {};
		for k,v in pairs(data.wear) do
			data.wear_ext[k] = {v,0,0};
		end
	end
	
	--道具有效性校验
	data = ProfileMgr.RemoveNotFoundItem(data)
	
	--保存角色信息数据
	ProfileMgr.dicRoleInfo[target_uid] = data;

    --更新界面
	--RoleInfoUI.UpdateRoleInfoTab();

    EventSystem:postEvent(EVENTID_NET_ROLE_INFO_RSP, BP_ENUM_MODULE_SETTING);
    EventSystem:postEvent(EVENTTYPE_RANK, EVENTID_WARZONE_UPDATE_AVATAR, tonumber(target_uid));
end

function ProfileMgr.RemoveNotFoundItem(data)
	for k,v in pairs(data.wear_ext) do
		local itemId = v[1]
		local cfg = Client.GetTableData("Item", itemId)
		if cfg == nil then
			data.wear_ext[k][1] = 0
		end
	end
	for k,v in pairs(data.wear) do
		local itemId = v
		local cfg = Client.GetTableData("Item", itemId)
		if cfg == nil then
			data.wear[k] = 0
		end
	end
	return data
end

function ProfileMgr.GetNickName(uidStr)
	local profileInfo = ProfileMgr.dicFriendProfile[tonumber(uidStr)]
	-- log_tree("ProfileMgr.GetNickName uidStr "..uidStr, profileInfo)
	if profileInfo == nil then
		return nil
	else
		return profileInfo.nickName
	end
end

---------------------------------获取概要信息公共协议--------------------------------

--回包参数：
--listType			--列表类型
--res				--回包确认
--profileList		--概要信息列表
--systemType		--透传参数，判断是否本系统使用
--s2c["batch_get_profile_rsp"] = ProfileMgr.OnBatchGetProfileRsp;

s2c["batch_get_profile_rsp"] = ProfileMgr.OnBatchGetProfileRsp;

s2c["batch_get_group_and_online_rsp"] = function(...)
	FriendSystem.on_batch_get_group_and_online_rsp(...);-- 返回好友在线和组队信息
	TeamUpSystem.on_stranger_staus_rsp(...); --返回陌生人状态信息
	LobbyChatSystem.on_chatroom_status_rsp(...); --返回陌生人状态信息
	--MasterSystem.on_master_status_rsp(...);--返回师徒在线信息
	--CorpsMgr.GetMemberGroupStateRsp(...)--军团成员状态信息
	ProfileMgr.OnBatchGetGroupAndOnlineRsp(...)

	StatusManager.getInstance():processServerData(...)
end


-- 返回是否允许别人查看角色
s2c["chg_avatar_show_switch_rsp"] = function(...)
	ProfileMgr.on_chg_avatar_show_switch_rsp(...);
end

-- 返回角色信息数据
s2c["get_avatar_show_rsp"] = function(...)
	ProfileMgr.get_avatar_show_rsp(...);
end
