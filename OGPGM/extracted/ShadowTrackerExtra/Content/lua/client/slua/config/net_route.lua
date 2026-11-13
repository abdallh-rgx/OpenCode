local Net_Route =
{
    anniversary_activity =
    {
        moduleName = "client.slua.logic.lobby_activity.logic_anniversary_activity", --模块名

        routes = {
            get_anniversary_activity_info_rsp = "get_anniversary_activity_info_rsp", --key为协议号，value为moduleName对应的函数名
            anniversary_activity_have_draw_rsp = "anniversary_activity_have_draw_rsp",
            take_award_of_anniversary_stage_award_rsp = "take_award_of_anniversary_stage_award_rsp",
            take_exchange_of_anniversary_activity_rsp = "take_exchange_of_anniversary_activity_rsp",
        },
    },
    pet =
    {
        moduleName = "client.slua.logic.pet.logic_pet", --模块名

        routes = {
            sync_pet_data = "sync_pet_data", --key为协议号，value为moduleName对应的函数名
            equip_pet_rsp = "equip_pet_rsp",
            unequip_pet_rsp = "unequip_pet_rsp",
            pet_add_exp_rsp = "pet_add_exp_rsp",
            notice_pet_change = "notice_pet_change",
            notice_pet_event_res = "notice_pet_event_res",
            pet_action_rsp = "pet_action_rsp",
            pet_reanme_rsp = "pet_reanme_rsp",
        },
    },

    roleinfo_decoration =
    {
        moduleName = "client.slua.logic.person_space.logic_roleinfo_decoration", --模块名

        routes = {
            select_use_pspace_rolewear_rsp = "select_use_pspace_rolewear_rsp", --key为协议号，value为moduleName对应的函数名
        },
    },

    roleinfo_popularity =
    {
        moduleName = "client.slua.logic.person_space.logic_roleinfo_popularity", --模块名

        routes = {
            get_popularity_rsp = "get_popularity_rsp", --
            pspace_send_gift_rsp = "pspace_send_gift_rsp", --
            show_popularity_detail_rsp = "show_popularity_detail_rsp",
            close_popularity_reddot_rsp = "close_popularity_reddot_rsp",
        },
    },

    actor_voice =
    {
        moduleName = "client.slua.logic.actor_voice.logic_actor_voice",

        routes = {
            get_voice_msg_info_rsp = "GetActorVoiceInfoRes", --获取语音包相关所有数据
            voice_dubber_changed_notify = "VoiceActorChangedNotify", --获取语音包权限数据
            voice_dubber_first_get_notify = "FirstGetActor", --新获得语音包
            voice_changed_notify = "VoiceChangedNotify", --通知单条语音变了
            voice_decompose_notify = "VoiceDecomposeNotify", --通知声优或是语音消息被拆分了
        }
    }
}
return Net_Route