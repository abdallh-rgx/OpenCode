--[[
  版本升级相关逻辑
]]--

VersionUpdater =  VersionUpdater or {
	--是否可使用CDN更新方案
    bEnableUseCDNUpdate=true,
    --是否在cdn更新失败后启动Dolphin更新
    bUseDolphinUpdateAfterCDNFailed=false,
    --是否在dolphin更新失败后启动cdn更新
    bUseCDNUpdateAfterDolphinFailed=true,
    --cdn服务器根目录
    cdnUpdate_domain="https://filecdn.igamecj.com/igm/",
    cdndownload_retryTimes=3,
    --cdn下载延迟时间
    cdndownload_retryDelayTime=2,
    --dolphin更新错误码
    dolphinUpdaterErrorCode = 0,

    --GCloud更新开关URL根路径
    updateStateCDNConfigUrl="https://filecdn.igamecj.com/pubg/gcloud/",
}

-- lua -> cpp
function VersionUpdater.StartUpdate()
    
end

function VersionUpdater.CancelUpdate()
    
end

--cpp -> lua
function VersionUpdater.OnVersionUpdate(verinfo)
    -- lua -> bp
    -- 提示更新
    -- 强制 或者 非强制
end

function VersionUpdater.OnUpdateEnd(Successful, needRestart)
    -- 更新成功
        -- 直接刷新界面的版本号
        -- 提示重启以进游戏
    -- 更新失败
        -- 提示重试
        -- 提示重启
end

function VersionUpdater.OnUpdateProcess(stage, percent, finished)
    -- 根据 stage 显示文字
    -- 根据 percent 显示进度条
    --finished表示更新完全结束
end

function VersionUpdater.GetStageString(curStage)
    local stageString = 
    {
        --GCloud::VS_FirstExtract
        [69] = "GetingVerInfo", 
        --GCloud::VS_Dolphin_Version
        [10] = "extract first resource", 
        --GCloud::VS_ApkUpdateDownConfig
        [71] = "download apk-update config", 
        --GCloud::VS_ApkUpdateDownDiffFile
        [72] = "download apk-update diff file",
        --GCloud::VS_ApkUpdateDownFullApk
        [73] = "Downloading",
        -- GCloud::VS_ApkUpdateCheckCompletedApk
        [74] = "CheckDownload",
        --GCloud::VS_ApkUpdateCheckLocalApk:
        [75] = "check local apk",
        --GCloud::VS_ApkUpdateCheckConfig:
        [76] = "check apk-update config",
        --GCloud::VS_ApkUpdateCheckDiff:
        [77] = "check apk-update diff file",
        --GCloud::VS_ApkUpdateMergeDiff:
        [78] = "create apk file",
        --GCloud::VS_ApkUpdateCheckFull:
        [79] = "check download apk file",
        --GCloud::VS_SourceUpdateDownloadList:
        [91] = "download src-update config",
        --GCloud::VS_SourcePrepareUpdate:
        [92] = "prepare src-update",
        --GCloud::VS_SourceAnalyseDiff:
        [93] = "src-update analyse diff",
        --GCloud::VS_SourceDownload:
        [94] = "download src-update file",
        --GCloud::VS_SourceExtract:
        [95] = "Extraing",
        --VS_Success
        [99] = "success",
        --VS_Fail
        [100] = "failed",
    };
    
    if stageString[curStage] ~= nil then
        return stageString[curStage];
    end
    return "updating";
end

--[[
==================经分上报相关=================
--]]

function VersionUpdater.ReportEventsCount(id, value)
    local param = {};
    param[id] = value or 1;
    log("[HHF]VersionUpdater.ReportEventsCount, id = " .. id .. ", value = " .. param[id]);
    NetUtil.SendPkg("report_map_download_log", param);
end

function VersionUpdater.GetChannelDir(curChannel)
    local dirString = 
    {
        --全球-外网_iOS
        [48] = "live/global/ios/",     
        --全球-外网_PVRTC_Shipping
        [46] = "live/global/ios_5s_shipping/",     
        --全球-外网_PVRTC
        [43] = "live/global/ios_5s_dev/",     
        --全球-外网_Android
        [47] = "live/global/android/",   
        --全球-外网_三星 Android
        [59] = "live/global/android_samsung/",   
        --全球-外网_多渠道 Android
        [122] = "live/global/android_multichannel/",   

        --全球-预发布_iOS
        [33] = "preupdate/global/ios/",   
        --全球-预发布_PVRTC_Shipping
        [45] = "preupdate/global/ios_5s_shipping/",   
        --全球-预发布_PVRTC
        [44] = "preupdate/global/ios_5s_dev/",   
        --全球-预发布_Android
        [32] = "preupdate/global/android/",   
        --全球-预发布_三星 Android
        [60] = "preupdate/global/android_samsung/",   
        --全球-预发布_多渠道 Android
        [123] = "preupdate/global/android_multichannel/",   

        --全球-Trunk_iOS
        [30] = "trunk/global/windows/",   
        --全球-Trunk_iOS
        [29] = "trunk/global/ios/",   
        --全球-Trunk_PVRTC_Shipping
        [36] = "trunk/global/ios_5s_shipping/",   
        --全球-Trunk_PVRTC
        [35] = "trunk/global/ios_5s_dev/",   
        --全球-Trunk_Android
        [28] = "trunk/global/android/",   
        --全球-Trunk三星 Android
        [62] = "trunk/global/android_samsung/",   
        --全球-Trunk多渠道 Android
        [124] = "trunk/global/android_multichannel/",  

        --日韩-外网_iOS
        [3091] = "live/kr/ios/",   
        --日韩-外网_PVRTC_Shipping
        [3092] = "live/kr/ios_5s_shipping/",   
        --日韩-外网_PVRTC
        [3093] = "live/kr/ios_5s_dev/",   
        --日韩-外网_Android
        [3090] = "live/kr/android/", 
        --日韩-外网_三星 Android
        [3098] = "live/kr/android_samsung/", 

        --日韩-预发布_iOS
        [3095] = "preupdate/kr/ios/", 
        --日韩-预发布_PVRTC_Shipping
        [3097] = "preupdate/kr/ios_5s_shipping/", 
        --日韩-预发布_PVRTC
        [3096] = "preupdate/kr/ios_5s_dev/", 
        --日韩-预发布_Android
        [3094] = "preupdate/kr/android/", 
        --日韩-预发布_三星 Android
        [3099] = "preupdate/kr/android_samsung/", 

        --日韩-Trunk_iOS
        [3087] = "trunk/kr/ios/", 
        --日韩-Trunk_PVRTC_Shipping
        [3089] = "trunk/kr/ios_5s_shipping/", 
        --日韩-Trunk_PVRTC
        [3088] = "trunk/kr/ios_5s_dev/", 
        --日韩-Trunk_Android
        [3086] = "trunk/kr/android/", 
        --日韩-Trunk三星 Android     
        [3100] = "trunk/kr/android_samsung/", 

        --全球先游-外网_iOS
        [54] = "ce/global/ios/",     
        --全球先游-外网_PVRTC_Shipping
        [55] = "ce/global/ios_5s_shipping/",       
        --全球先游-外网_Android
        [49] = "ce/global/android/",   

        --越南-外网_iOS
        [119] = "live/vng/ios/",     
        --越南-外网_PVRTC_Shipping
        [121] = "live/vng/ios_5s_shipping/", 
        --越南-外网_Android
        [117] = "live/vng/android/",

        --越南-预发布_iOS
        [118] = "preupdate/vng/ios/",     
        --越南-预发布_PVRTC_Shipping
        [120] = "preupdate/vng/ios_5s_shipping/", 
        --越南-预发布_Android
        [116] = "preupdate/vng/android/",

        --越南-Trunk_iOS
        [125] = "trunk/vng/ios/",     
        --越南-Trunk_PVRTC_Shipping
        [126] = "trunk/vng/ios_5s_dev/", 
        --越南-Trunk_Android
        [127] = "trunk/vng/android/",

        --台湾-外网_iOS
        [138] = "live/tw/ios/",     
        --台湾-外网_PVRTC_Shipping
        [141] = "live/tw/ios_5s_shipping/", 
        --台湾-外网_Android
        [137] = "live/tw/android/",

        --台湾-外网_iOS
        [144] = "preupdate/tw/ios/",     
        --台湾-外网_PVRTC_Shipping
        [145] = "preupdate/tw/ios_5s_shipping/", 
        --台湾-外网_Android
        [143] = "preupdate/tw/android/",
    };

    if dirString[curChannel] ~= nil then
        return dirString[curChannel];
    end
    return "";
end

function VersionUpdater.GetCDNUpdateInfo()
    local curChannel = Client.GetCurrentChannel(GameFrontendHUD);
    local subDir = VersionUpdater.GetChannelDir(curChannel);
    local configURL = VersionUpdater.cdnUpdate_domain..subDir.."config.igm";
    local whitelistRedirectURL = VersionUpdater.cdnUpdate_domain..subDir.."whitelistDirect.igm";

    log("VersionUpdater.GetCDNUpdateInfo, curChannel="..curChannel..", configURL = "..configURL..", whitelistRedirectURL = "..whitelistRedirectURL);
    local data = {};
    data["configURL"] = configURL;
    data["whitelistRedirectURL"] = whitelistRedirectURL;
    data["bEnableUseCDNUpdate"] = tostring(VersionUpdater.bEnableUseCDNUpdate);
    data["bUseDolphinUpdateAfterCDNFailed"] = tostring(VersionUpdater.bUseDolphinUpdateAfterCDNFailed);
    data["bUseCDNUpdateAfterDolphinFailed"] = tostring(VersionUpdater.bUseCDNUpdateAfterDolphinFailed);
    data["cdndownload_retryTimes"] = tostring(VersionUpdater.cdndownload_retryTimes);
    data["cdndownload_retryDelayTime"] = tostring(VersionUpdater.cdndownload_retryDelayTime);
    data["dolphinUpdaterErrorCode"] = tostring(VersionUpdater.dolphinUpdaterErrorCode);

    Client.GetCDNUpdateInfo(GameFrontendHUD, data)
end

function VersionUpdater.StartCDNUpdate(code)
    log("GCloud update failed, will start cdn update: "..tostring(VersionUpdater.bUseCDNUpdateAfterDolphinFailed));
    log("bEnableUseCDNUpdate="..tostring(VersionUpdater.bEnableUseCDNUpdate));
    log("bUseDolphinUpdateAfterCDNFailed="..tostring(VersionUpdater.bUseDolphinUpdateAfterCDNFailed));
    log("bUseCDNUpdateAfterDolphinFailed="..tostring(VersionUpdater.bUseCDNUpdateAfterDolphinFailed));
    if VersionUpdater.bEnableUseCDNUpdate and VersionUpdater.bUseCDNUpdateAfterDolphinFailed then       
        log("hasRetried712 is true, start CDNUpdate after dolphinUpdate failed");

        --test3
        --local funcCall = function()
        --    log("delay StartCDNUpdateAfterDolphinUpdateFailed");
        --    local notice = "开始cdn更新";
        --    PopUpNoticeUI.ShowNewNotice(notice);
        --    VersionUpdater.StartCDNUpdateAfterDolphinUpdateFailed();
        --end
        --local notice = "更新失败，触发cdn更新";
        --PopUpNoticeUI.ShowNewNotice(notice);
        -- 延时请求
        --Timer.InsertTimer(12, funcCall,false, false);
        --test3 end

        VersionUpdater.StartCDNUpdateAfterDolphinUpdateFailed();
        return true;
    end
    log("Gcloud update failed，but bUseCDNUpdateAfterDolphinFailed equals false.");
    --local notice = "Gcloud更新失败，但cdn更新设置为在Gcloud更新失败后不触发";
    --PopUpNoticeUI.ShowNewNotice(notice);
    return false;
end

--GCloud更新失败后开始CDN更新
function VersionUpdater.StartCDNUpdateAfterDolphinUpdateFailed()
    log("VersionUpdater.StartCDNUpdateAfterDolphinUpdateFailed");
    Client.StartCDNUpdateAfterDolphinUpdateFailed(GameFrontendHUD);
end

--返回GCloud更新开关配置文件URL
function VersionUpdater.GetUpdateStateCDNConfigUrl()
    local isReleaseVersion = Client.IsReleaseVersion();
    local subDir = "test/";
    if isReleaseVersion then
        subDir = "live/";
    end
    local region = "";
    local strRegion = Client.GetPublishRegion();
    if strRegion == "JAPAN" or strRegion == "KOREA" then
        region = "kr/";
    elseif strRegion == "VNG" then
        region = "vng/";
    elseif strRegion == "TW" then
        region = "tw/";
    else
        region = "global/";
    end

    local url = VersionUpdater.updateStateCDNConfigUrl..subDir..region.."config.json";
    log("Get Gcloud update status cdn url: "..url.." region: "..region.." isReleaseVersion: "..tostring(isReleaseVersion));

    Client.OnGetUpdateStateCDNConfigUrl(GameFrontendHUD, url)
end
