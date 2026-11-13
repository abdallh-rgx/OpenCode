require("client.common.event.event_define")
require("client.umg.bp_macros")

local Event_Config =
{
    -- eventType为事件类型，eventID为事件ID，moduleName为处理的lua模块名，funcName为对应模块的函数名
    {eventType = EVENTTYPE_URL, eventID = BP_ENUM_MODULE_ANNIVERSARY,
     moduleName = "client.slua.logic.lobby_activity.logic_anniversary_activity", funcName = "get_anniversary_activity_info_req"},

    {eventType = EVENTTYPE_URL, eventID = BP_ENUM_MODULE_PRIME,
     moduleName = "client.logic.subscribe.logic_subscribe_new", funcName = "ShowSubscribe"},

    {eventType = EVENTTYPE_MIDAS_NOTIFY, eventID = EVENTID_MIDAS_SUBSCRIBE_NOTIFY,
     moduleName = "client.logic.subscribe.logic_subscribe_new", funcName = "buy_callback"},

    {eventType = EVENTTYPE_MIDAS_NOTIFY, eventID = EVENTID_MIDAS_GET_SUBSCRIBE_PRODUCT_INFO_NOTIFY,
     moduleName = "client.logic.subscribe.logic_subscribe_new", funcName = "GetMidasGoodsInfo"},

    {eventType = EVENTTYPE_MIDAS_NOTIFY, eventID = EVENTID_MIDAS_GET_INTRO_PRICE_INFO_NOTIFY,
     moduleName = "client.logic.subscribe.logic_subscribe_new", funcName = "LoadIntroPriceFromCached"},
    {eventType = EVENTTYPE_LOGIN, eventID = EVENTID_BACKLOGIN,
     moduleName = "client.logic.subscribe.logic_subscribe_new", funcName = "Handle_LogOut"},
}

return Event_Config