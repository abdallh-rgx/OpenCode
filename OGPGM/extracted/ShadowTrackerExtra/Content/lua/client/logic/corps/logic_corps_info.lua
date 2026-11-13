CorpsInfoSystem = CorpsInfoSystem or {}

function CorpsInfoSystem.InitCorpsInfo(corpsInfo)
	local fieldMap = {
		["id"] = {"corps_id"},
		["exp"] = {"exp"},					--军团经验
		["level"] = {"level"},					--军团等级
		["group_id"] = {"group_id"},
		-- ["weekRank"] = {""}, 				--军团本周活跃排行
		["announcement"] = {"announcement"},			--军团宣言
		["name"] = {"name"},  				--军团名字
		["icon"] = {"icon"},  					--军团图标ID
		["icon_text"] = {"icon_text"},
		["icon_text_colour"] = {"icon_text_colour"},
		["city"] = {"city"},  					--军团所在城市
		["memberNum"] = {"member_num"},				--军团成员数量
		["leader"] = {"leader"},					--军团团长
		["day_active"] = {"active", "day_active"},				--军团日活跃
		["week_active"] = {"active", "week_active"},			--军团周活跃
		["season_active"] = {"active", "season_active"},			--军团赛季活跃
		["chest_star"] = {"active", "chest_star"},				--军团宝箱星级
		["fund"] = {"active", "fund"},				--军团宝箱星级
		["isAcceptApply"] = {"accept_apply"},
		["isNeedApproval"] = {"need_approval"},
		["joinLevel"] = {"join_level"},
		["joinSegment"] = {"join_segment"},
		["changeNameTime"] = {"change_name_time"},			-- 上次改名时间
		["lastAutoInviteTime"] = {"last_auto_invite_time"},	-- 上次邀请时间
	}
	for k,k2Arr in pairs(fieldMap) do
		local tempInfo = nil
		for index,k2 in pairs(k2Arr) do
			if tempInfo == nil then
				tempInfo = corpsInfo[k2]
			else
				tempInfo = tempInfo[k2]
			end
			if index == #k2Arr then
				DataMgr.corpsInfo[k] = tempInfo
			end
		end
	end

	-- 登录时同步服务器的军团数据
	--log_tree("CorpsInfoSystem.InitCorpsInfo ", DataMgr.corpsInfo)
end

local EventId = {
	["join_in"] = 1,
	["exit"] = 2,
	["be_kicked"] = 3,
	["level_up"] = 4,
	["transfer_leader"] = 5,
	["appoint_deputy"] = 6,
	["remove_deputy"] = 7,
	["appoint_elite"] = 8,
	["remove_elite"] = 9,
	["create_corps"] = 10,
	["change_name"] = 11,
}
local EventUserPos = {
	[EventId["join_in"]] = {true},
	[EventId["exit"]] = {true},
	[EventId["be_kicked"]] = {true, true},
	[EventId["level_up"]] = {false},
	[EventId["transfer_leader"]] = {true, true},
	[EventId["appoint_deputy"]] = {true, true},
	[EventId["remove_deputy"]] = {true, true},
	[EventId["appoint_elite"]] = {true, true},
	[EventId["remove_elite"]] = {true, true},
	[EventId["create_corps"]] = {true},
	[EventId["change_name"]] = {true},
}
local EventHasIcon = {
	[EventId["join_in"]] = true,
	[EventId["exit"]] = true,
	[EventId["be_kicked"]] = true,
	[EventId["level_up"]] = false,
	[EventId["transfer_leader"]] = true,
	[EventId["appoint_deputy"]] = true,
	[EventId["remove_deputy"]] = true,
	[EventId["appoint_elite"]] = true,
	[EventId["remove_elite"]] = true,
	[EventId["create_corps"]] = true,
	[EventId["change_name"]] = {true},
}

local EventStrTemp = {
	[EventId["join_in"]] = 410049,
	[EventId["exit"]] = 410050,
	[EventId["be_kicked"]] = 410051,
	[EventId["level_up"]] = 410052,
	[EventId["transfer_leader"]] = 410053,
	[EventId["appoint_deputy"]] = 410054,
	[EventId["remove_deputy"]] = 410055,
	[EventId["appoint_elite"]] = 410056,
	[EventId["remove_elite"]] = 410057,
	[EventId["create_corps"]] = 410064,
	[EventId["change_name"]] = 6052,
}

function CorpsInfoSystem.InitCorpsLog(event_list)
	local idList = {}
	for _, eventInfo in ipairs(event_list) do
		for paramIndex, param in ipairs(eventInfo.param_list) do
			if EventUserPos[eventInfo.event_id][paramIndex] then
				table.insert(idList, param)
			end
		end
	end
	local function processData(profileList)
		local result = {}
		local dateStr = ""
		local profileMap = {}
		for _, profileInfo in ipairs(profileList) do
			profileMap[tonumber(profileInfo.uid)] = profileInfo
		end

		for index, eventInfoData in ipairs(event_list) do
			local tempId = EventStrTemp[eventInfoData.event_id]
			local eventInfo = {icon = ""}
			local args = {}
			for paramIndex, param in ipairs(eventInfoData.param_list) do
				if EventUserPos[eventInfoData.event_id][paramIndex] then
					if EventHasIcon[eventInfoData.event_id] and eventInfo.icon == "" then
                        local profile = profileMap[param]
                        if profile == nil then
                        	eventInfo.icon = ""
                        	eventInfo.level = 1
                        	eventInfo.iconFrameID = 0
                        else
                        	eventInfo.icon = profile.picUrl
                        	eventInfo.level = profile.level
                        	eventInfo.iconFrameID = profile.cur_avatar_box_id
                        end
					end
					if profileMap[param] then
						local nickname = profileMap[param].nickName
						table.insert(args, FuncUtil.SubString(nickname, 1, 12))
					else
						table.insert(args, "账号不存在")
					end
				else
					table.insert(args, param)
				end
			end
			eventInfo.msg = FuncUtil.LocalizeResFormat(tempId, table.unpack(args))
			local tempDateStr = os.date(FuncUtil.GetLocalizeResStr(410058), eventInfoData.time)
			if dateStr == nil or dateStr ~= tempDateStr then
				dateStr = tempDateStr
				eventInfo.date = tempDateStr
			end
			eventInfo.time = os.date("%H:%M", eventInfoData.time)
			table.insert(result, eventInfo)
		end
		EventSystem:postEvent(EVENTTYPE_CORPS, EVENTID_CORPS_UPDATE_LOGINFO, result)
	end
	ProfileMgr.GetProfileList(idList, processData, false);
end

function CorpsInfoSystem.InitCorpsTaskInfo(corps)
	DataMgr.corpsInfo.star = corps.active.chest_star or 0
	DataMgr.corpsActiveness.star = corps.active.chest_star or 1
	for k,v in pairs(corps.members) do
		if  k == tonumber(DataMgr.roleData.uid) then
			DataMgr.corpsActiveness.value = v.week_active
		end
	end

	-- DataMgr.ResetCorpsActivenessData()
	log("$$CorpsInfoSystem.InitCorpsInfo ..DataMgr.corpsActiveness" .. DataMgr.corpsActiveness.star .. "::" .. DataMgr.corpsActiveness.value)
end
