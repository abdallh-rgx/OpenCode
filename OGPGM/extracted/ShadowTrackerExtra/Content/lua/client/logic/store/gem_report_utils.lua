--jaysunzhu Gem上报工具类

--概述：EventName 是用来把所有同类事件报到一个事件里面；SubEvent 再二层区分。每开一个新的EventName，都需要Gem同事在数据平台单独接入
--大业务就按照一个模块来分割一下（商城，对局，社交）。可以新建一个EventName
--一般中小业务建议把所有事件都报到相同的EventName 里面，通过SubEventName区分。可以复用EventName_CommonEvent，新建SubEventName

--接口：ReportEventImmediate，立即上报，适用于适用于低频率，重要数据
--ReportEventDelay，延时上报，适用于适用于高频率，不重要数据。杀进程会丢失最多60s内的数据

GemReportUtils = 
{


    --EventName
    EventName_CommonEvent = "CommonEvent", --通用立即上报
    EventName_JumpBuyEvent = "JumpBuyEvent", --商城购买统计来源
    EventName_ClickEvent = "ClickEvent", --按钮点击次数
    EventName_StarterPack= "StarterPackEvent", --StarterPackEvent
    EventName_LobbyEvent = "LobbyEvent", --大厅点击上报

    --SubEventName
    SubEventName_SupplyClick2D3D = "SupplyClick2D3D",           --补给点击2D，3D
    SubEventName_StoreClickSupply = "StoreClickSupply",         --商城点击补给入口
    SubEventName_StoreClickBanner = "StoreClickBanner",         --商城推荐页点击banner
    SubEventName_LobbyClickSupply = "LobbyClickSupply",         --大厅点击补给入口
    SubEventName_LobbyClickStore = "LobbyClickStore",           --大厅点击商城入口
    SubEventName_LobbyClickStore_JK = "LobbyClickStoreJK",      --大厅点击日韩商城入口
    SubEventName_ClothFilter = "ClothFilter",                   --衣服过滤列表点击
    SubEventName_WeaponFilterType = "WeaponFilterType",         --武器过滤列表类型点击（akm之类）
    SubEventName_WeaponFilterIndex = "WeaponFilterIndex",       --武器过滤列表索引点击（已拥有，未拥有）
    SubEventName_WeaponPreview = "WeaponPreview",               --武器全屏预览
    SubEventName_CarPreview = "CarPreview",                     --载具全屏预览
    SubEventName_PreviewLeft = "PreviewLeft",                   --全屏预览左箭头
    SubEventName_PreviewRight = "PreviewRight",                 --全屏预览右箭头
    SubEventName_SupplyDropInfo = "SupplyDropInfo",             --补给掉落详情

    SubEventName_JumpBuySupplyNoChangePageUC = "JumpBuySupplyNoChangePageUC",  --跳转补给购买不切页签uc
    SubEventName_JumpBuySupplyNoChangePageItem = "JumpBuySupplyNoChangePageItem",  --跳转补给购买不切页签道具
    SubEventName_JumpBuySupplyChangePageUC = "JumpBuySupplyChangePageUC",      --跳转补给购买切页签uc
    SubEventName_JumpBuySupplyChangePageItem = "JumpBuySupplyChangePageItem",      --跳转补给购买切页签道具
    
    SubEventName_JumpBuyPass = "JumpBuyPass",
    SubEventName_JumpBuyPassScore = "JumpBuyPassScore",
    SubEventName_JumpBuyPassItem = "JumpBuyPassItem",

    SubEventName_Pass = "Pass",                                                         -- pass排行榜好友按钮
    SubEventName_PassUpgradeFromGetLevelAward = "PassUpgradeFromGetLevelAward",         -- 一键领取等级奖励时升级通行证按钮
    SubEventName_PassUpgradeFromGetTaskAward = "PassUpgradeFromGetTaskAward",           -- 一键领取任务奖励时升级通行证按钮
    SubEventName_PassBatchGetLevelAward = "PassBatchGetLevelAward",                     -- 一键任务等级奖励
    SubEventName_PassBatchGetTaskAward = "PassBatchGetTaskAward",                       -- 一键领取任务奖励
    SubEventName_PassRank = "PassRank",                                                 -- pass排行榜
    SubEventName_PassRankFriend = "PassRankFriend",                                     -- pass排行榜好友按钮

    SubEventName_StarterPackPopUp = "StarterPackPopUp",                                 --新手礼包弹出事件
    SubEventName_StarterPackPopUpTimeBeforeBuy = "StarterPackPopUpTimeBeforeBuy",       --新手礼包弹出框弹出次数在购买礼包之前
    SubEventName_StarterPackBuyThroughPopUp = "StarterPackBuyThroughPopUp",              --新手礼包通过弹出框购买
    SubEventName_StarterPackCarouselClick = "StarterPackCarouselClick",                 --新手礼包循环展示框点击事件
    SubEventName_StarterPackBuyThroughCarousel = "StarterPackBuyThroughCarousel",       --新手礼包通过循环展示框购买
    SubEventName_StarterPackBuyThroughUCStore = "StarterPackBuyThroughUCStore",         --新手礼包通过uc商店购买
    SubEventName_StarterPackBuyThroughFinalOffer = "StarterPackBuyThroughFinalOffer",   --新手礼包通过最后机会购买

    SubEventName_SubActivityBanner = "SubActivityBanner",             --活动中心banner点击

    ------------------------个人空间---------------------------
    SubEventName_PersonSpaceMain = "PersonSpaceMain",               --个人空间主页
    SubEventName_PersonSpaceDecoration = "PersonSpaceDecoration",         --个人空间装扮
    SubEventName_PersonSpaceAchievement = "PersonSpaceAchievement",        --个人空间成就
    SubEventName_PersonSpaceCombat = "PersonSpaceCombat",             --个人空间个人战绩
    SubEventName_PersonSpaceSegment = "PersonSpaceSegment",            --个人空间段位总览
    SubEventName_PersonSpaceHistory = "PersonSpaceHistory",            --个人空间历史战绩
    SubEventName_PersonSpaceFoldAndUnfold = "PersonSpaceFoldAndUnfold", --个人空间 展开/收起个人信息详情
    SubEventName_PersonSpaceRelation = "PersonSpaceRelation", --个人空间 亲密关系
    SubEventName_PersonSpacePopularity = "PersonSpacePopularity", --个人空间 人气详情
    SubEventName_PersonSpaceSendGift = "PersonSpaceSendGift", --个人空间 送礼
    SubEventName_PersonSpaceAddFriend = "PersonSpaceAddFriend", --个人空间 添加好友
    SubEventName_PersonSpaceModifyInfo = "PersonSpaceModifyInfo", --个人空间 修改个人信息
    SubEventName_PersonSpaceFriendCard = "PersonSpaceFriendCard", --个人空间 交友名片
    ------------------------个人空间---------------------------

    ------------------------大厅点击---------------------------
    SubEventName_LobbyFirstCharge = "LobbyFirstCharge" ,             --右上角 首充活动
    SubEventName_LobbySeasonFirstCharge = "LobbySeasonFirstCharge" , --右上角 赛季首充活动
    SubEventName_LobbyCrates = "LobbyCrates",                        --补给宝箱 
    SubEventName_LobbyShop = "LobbyShop",                            --商城 
    SubEventName_LobbyRP = "LobbyRP" ,                               --RP 
    SubEventName_LobbyEventcenter = "LobbyEventcenter",              --活动中心 
    SubEventName_LobbyBanner = "LobbyBanner",                        --banner点击（不同bannerID计算为不同数据） 
    SubEventName_LobbySeason = "LobbySeason",                        --赛季
    SubEventName_LobbyClan = "LobbyClan",                            --军团
    SubEventName_LobbyCrew = "LobbyCrew" ,                           --战队
    SubEventName_LobbyCrmory = "LobbyCrmory" ,                       --军备
    SubEventName_LobbyInventory = "LobbyInventory",                  --仓库
    SubEventName_LobbyEsport = "LobbyEsport",                        --赛事
    SubEventName_LobbyRanking = "LobbyRanking",                      --排行榜
    SubEventName_LobbyMission = "LobbyMission",                      --任务
    SubEventName_LobbyMail = "LobbyMail",                            --邮件
    SubEventName_LobbySettings = "LobbySettings",                    --设置
    SubEventName_LobbyMore = "LobbyMore",                            --更多
    ------------------------大厅点击---------------------------

    SubEventName_FaceSlap = "FaceSlap",         --拍脸图点击展示上报

}

GemReportUtils.IsReciveOneGemInfo = false   --是否收到了1个数据来插入timer上报
GemReportUtils.CachedAllGemInfo = {}        --缓存1个发送周期内的GEM数据
GemReportUtils.CachedTime = 60        --缓存周期间隔
GemReportUtils.CanReportLobbyEvent = false --上报大厅点击事件的开关




--适用于适用于低频率，重要数据
function GemReportUtils.ReportEventImmediate(eventName, subEvent, para1, para2)
    log("GemReportUtils.ReportEventImmediate eventName=".. eventName .. ",subEvent=" .. subEvent ..",para1="..tostring(para1)..",para2="..tostring(para2))
    local para = { }
    local id = 1
    if para1 then
        para[id] = tostring(para1)
        id = id + 1
    end
    if para2 then
        para[id] = tostring(para2)
        id = id + 1
    end
    local GEM_param =
    {
        SubEvent = subEvent
    }
    for i=1,#para do
        GEM_param["K" .. (i-1)] = para[i];
    end
    --log_tree("GEM_param = ",GEM_param)
    Client.GEMReportEvent(GameFrontendHUD, eventName, GEM_param);
end

function GemReportUtils.ReportEventImmediateForCommon(subEvent, para1, para2)
    GemReportUtils.ReportEventImmediate(GemReportUtils.EventName_CommonEvent, subEvent, para1, para2);
end



function GemReportUtils.ReportBtnClickEvent(subEvent, para1, para2)
    GemReportUtils.ReportEventDelay(GemReportUtils.EventName_ClickEvent , subEvent, para1, para2)
end

--大厅按钮上报专用，为防止上报量过大，由后台控制仅部分用户会打开，精确数据统计不能用此接口
function GemReportUtils.ReportLobbyClickEvent(subEvent, para1, para2)
    if GemReportUtils.CanReportLobbyEvent then
        GemReportUtils.ReportEventDelay(GemReportUtils.EventName_LobbyEvent , subEvent, para1, para2)
    end
end

--Gem收到数据开始缓存
--60S后统一上报
--适用于适用于低频率，重要数据
function GemReportUtils.ReportEventDelay(eventName, subEvent, para1, para2)
    log("GemReportUtils.ReportEventDelay eventName=".. eventName .. ",subEvent=" .. subEvent ..",para1="..tostring(para1)..",para2="..tostring(para2))

    if para1 then
        subEvent = subEvent.."_"..para1  --拼接附加字段
    end
    if para2 then
        subEvent = subEvent.."_"..para2  --拼接附加字段
    end

    if not GemReportUtils.CachedAllGemInfo[eventName] then --没有这个ID
        GemReportUtils.CachedAllGemInfo[eventName] = {} --新建
    end

    if not GemReportUtils.CachedAllGemInfo[eventName][subEvent] then --没有这个ID 那么 计数1次
        GemReportUtils.CachedAllGemInfo[eventName][subEvent] = 1
    else    --有这个ID 累加1次
        GemReportUtils.CachedAllGemInfo[eventName][subEvent] = GemReportUtils.CachedAllGemInfo[eventName][subEvent] + 1
    end

    if not GemReportUtils.IsReciveOneGemInfo then   --没有开始准备发送的话，插入1个60s timer 发送
        GemReportUtils.IsReciveOneGemInfo = true
        Timer.InsertTimer(GemReportUtils.CachedTime, GemReportUtils._SendCachedGEMReport);
    end
end


function GemReportUtils._SendCachedGEMReport()
    -- body
    GemReportUtils.IsReciveOneGemInfo = false   --重置接收状态

    --log_tree("GemReportUtils cachedAllGemInfo",GemReportUtils.CachedAllGemInfo)

    for eventName,v in pairs(GemReportUtils.CachedAllGemInfo) do
        local stringid_json = json.encode(v); --将Table GemReportUtils.CachedAllGemInfo 转换为json格式

        --json 转化成功后 上报
        if stringid_json then
            log("GemReportUtils cachedAllGemInfo eventName=".. eventName ..",json param=".. stringid_json)
            local GEM_param = {SubEvent = stringid_json }
            Client.GEMReportEvent(GameFrontendHUD, eventName, GEM_param);
        end

    end
    GemReportUtils.CachedAllGemInfo = {}    --清空缓存
end

