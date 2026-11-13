
--创建房间协议
CreateRoomHandler = CreateRoomHandler or
{
    
}

function CreateRoomHandler.send_create_room_request( _roomName,_mapID,_passWd,_groupType,_host_can_ob,_allow_invite,_str,_battle_cfg,isfpp,is_use_pc_param)
    NetManager.SendPkg(eMsgID.eCreateRoom,  _roomName,_mapID,_passWd,_groupType,_host_can_ob,_allow_invite,_str,_battle_cfg,isfpp,is_use_pc_param)
end

function CreateRoomHandler.on_create_room_respond(res, room_info)
    --todo write response code here
    RoomSystem.on_create_room_respond(res, room_info);
end

eMsgID = eMsgID or {}