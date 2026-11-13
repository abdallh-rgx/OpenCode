--[[
	军团福利系统
--]]

CorpsWelfareSystem = CorpsWelfareSystem or 
{
	corpsMemberList = {};
};
Is_Corps_Welfare_Have_Receive = false;

function CorpsWelfareSystem.Release()
	CorpsWelfareSystem.corpsMemberList = {};
end

function CorpsWelfareSystem.GetCorpsWelfareReceiveData()
	BP_ARRAY_WelfareReceiveDataList = {};
	if BP_ARRAY_WelfareDataList and #BP_ARRAY_WelfareDataList > 0 then
		for i = 1, #BP_ARRAY_WelfareDataList do
			if BP_ARRAY_WelfareDataList[i].share_ticket_id == BP_CurrentDetailTicketId then
				for k, v in pairs(BP_ARRAY_WelfareDataList[i].recevie_table) do
					local item = {};
					item.uid = k;
					item.count = v.item_list[1].count;
					item.resId = v.item_list[1].res_id;
					item.receiveTime = FuncUtil.FormatTime3(v.recevie_time);
					item.timeForSort = v.recevie_time;
					item.BP_STRUCT_BASE_INFO = {};
					for _k,_v in pairs(CorpsWelfareSystem.corpsMemberList) do
						if _v.strUid == item.uid then
							item.BP_STRUCT_BASE_INFO = _v;		
						end
					end
					table.insert(BP_ARRAY_WelfareReceiveDataList, item);
					--log_tree("BP_ARRAY_WelfareReceiveDataList", BP_ARRAY_WelfareReceiveDataList);
				end
				if BP_ARRAY_WelfareReceiveDataList and #BP_ARRAY_WelfareReceiveDataList > 0 then
					table.sort( BP_ARRAY_WelfareReceiveDataList, function(a, b) return a.timeForSort > b.timeForSort end );
				end
			end
		end
	end
end

function CorpsWelfareSystem.sortFunction(a, b)
	if a.state == b.state then 
		return a.timeForSort > b.timeForSort;
	else
		return a.state < b.state;
	end 
end

function SetCorpsWelfareList(share_ticket_list, recevie_info)
	--log_tree("DataMgr.corpsInfo.corpsMemberList", CorpsWelfareSystem.corpsMemberList);
	--log_tree("share_ticket_list", share_ticket_list);
	if share_ticket_list and type(share_ticket_list) == "table" and #DataMgr.corpsInfo.corpsMemberList > 0 then
		BP_ARRAY_WelfareDataList = {};
		for k, v in pairs(share_ticket_list) do
			local item = {};
			item = v;
			item.share_ticket_id = tostring(v.share_ticket_id);
			item.elapse_time = FuncUtil.FormatTime3(item.create_time);
			item.timeForSort = item.create_time;
			item.BP_STRUCT_BASE_INFO = {};
			item.state = recevie_info[k];
			for _k,_v in pairs(CorpsWelfareSystem.corpsMemberList) do
				if _v.strUid == item.owner_uid then
					item.BP_STRUCT_BASE_INFO = _v;		
				end
				if not item.BP_STRUCT_BASE_INFO.strUid then
					item.BP_STRUCT_BASE_INFO.strUid = "";
					item.BP_STRUCT_BASE_INFO.Name = "";
				end
			end
			table.insert(BP_ARRAY_WelfareDataList, item);
		end
		if BP_ARRAY_WelfareDataList and #BP_ARRAY_WelfareDataList > 0 then
			--log_tree("BP_ARRAY_WelfareDataList", BP_ARRAY_WelfareDataList);
			table.sort( BP_ARRAY_WelfareDataList, CorpsWelfareSystem.sortFunction );
				
			CorpsWelfareUI.RefreshList();
		end
	end
end

--is_confirm：确认还是取消
--is_anonymous：是否匿名
function CorpsWelfareSystem.CorpsWelfareReq(is_confirm, is_anonymous)
	NetUtil.SendPkg("corps_share_ticket_request" , is_confirm, is_anonymous);
end

function CorpsWelfareSystem.CorpsWelfareRsp(msg)
	if msg == "ok" then
		--询问是否跳转到军团
		if BP_RedEnvelopes_IsConfirm then
			DataMgr.ShowNoticeByID(6464);
		end
	else
		DataMgr.ShowNoticeByID(msg);
	end
end

function CorpsWelfareSystem.GetCorpsWelfareListReq()
	BP_ARRAY_WelfareDataList = {};
	NetUtil.SendPkg("get_corps_share_ticket_list_request");
end

function CorpsWelfareSystem.CorpsWelfareListRsp(msg, share_ticket_list, recevie_info, is_have_can_receive)
	--log_tree("share_ticket_list", share_ticket_list);
	--log_tree("recevie_info", recevie_info);
	--log_tree("DataMgr.corpsInfo.corpsMemberList", DataMgr.corpsInfo.corpsMemberList);
	if msg == "ok" then
		SetCorpsWelfareList(share_ticket_list, recevie_info);
		Is_Corps_Welfare_Have_Receive = is_have_can_receive;	
   		UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"));
	else
		DataMgr.ShowNoticeByID(msg);
	end
end

function CorpsWelfareSystem.ReceiveCorpsWelfareReq(id)
	NetUtil.SendPkg("receive_corps_share_ticket_request", id);
end

function CorpsWelfareSystem.ReceiveCorpsWelfareRsp(msg, share_ticket_list, recevie_info, item_list, is_have_can_receive)
	log("msg.."..msg);
	if msg == "ok" then
		--log_tree("share_ticket_list", share_ticket_list);
		--log_tree("recevie_info", recevie_info);
		--log_tree("item_list.." , item_list);
		CommonItemGetUI:ShowPanel({{res_id = item_list[1].res_id, count = item_list[1].count, valid_hours = 0}});
		SetCorpsWelfareList(share_ticket_list, recevie_info);
		Is_Corps_Welfare_Have_Receive = is_have_can_receive;	
   		UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"));
	else
		DataMgr.ShowNoticeByID(msg);
	end
end

function CorpsWelfareSystem.have_can_recevie_share_ticket_request()
	NetUtil.SendPkg("have_can_recevie_share_ticket_request");
end

function CorpsWelfareSystem.HaveCanReceiveShareTicketRsp(msg, result)
	if msg == "ok" then
		Is_Corps_Welfare_Have_Receive = result;	
   		UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"));
	else
		DataMgr.ShowNoticeByID(msg);
	end
end

function CorpsWelfareSystem.NotifyMemberShareTicketRsp()
	Is_Corps_Welfare_Have_Receive = true;	
    UpdateLobbyCorpsRedDot(CorpsMgr.HasRedDot("lobby"));
end

function CorpsWelfareSystem.TriggerCorpsShareTicketRsp(corps_share_data)
	if corps_share_data and type(corps_share_data) == "table" and #corps_share_data > 0 then
		CorpsWelfareRedEnvelopesUI.ReceiveData(corps_share_data);
	end
end

s2c["corps_share_ticket_respond"] = CorpsWelfareSystem.CorpsWelfareRsp;
s2c["get_corps_share_ticket_list_respond"] = CorpsWelfareSystem.CorpsWelfareListRsp;
s2c["receive_corps_share_ticket_respond"] = CorpsWelfareSystem.ReceiveCorpsWelfareRsp;
s2c["have_can_recevie_share_ticket_respond"] = CorpsWelfareSystem.HaveCanReceiveShareTicketRsp;
s2c["notify_member_share_ticket_respond"] = CorpsWelfareSystem.NotifyMemberShareTicketRsp;
s2c["trigger_corps_share_ticket_respond"] = CorpsWelfareSystem.TriggerCorpsShareTicketRsp;
