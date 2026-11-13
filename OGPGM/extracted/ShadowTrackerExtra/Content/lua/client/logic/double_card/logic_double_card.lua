DoubleCardSystem = DoubleCardSystem or {}

function DoubleCardSystem.InitData(double_card)
    --log_tree("DoubleCardSystem.InitData double_card", double_card);
    if not double_card then
        DataMgr.doubleCard.expCardRatePlus = 0;
        DataMgr.doubleCard.expCardExpireTime = 0;
        DataMgr.doubleCard.goldCardRatePlus = 0;
        DataMgr.doubleCard.goldCardExpireTime = 0;
        return;
    end

    DataMgr.doubleCard.expCardRatePlus = double_card.exp_card_rate_plus or 0;
    DataMgr.doubleCard.expCardExpireTime = double_card.exp_card_expire_time or 0;
    DataMgr.doubleCard.goldCardRatePlus = double_card.gold_card_rate_plus or 0;
    DataMgr.doubleCard.goldCardExpireTime = double_card.gold_card_expire_time or 0;
end

function DoubleCardSystem.OnSyncDoubleCardInfo(cardInfo)
    DoubleCardSystem.InitData(cardInfo);
end

function DoubleCardSystem.HasGoldRate()
    return DataMgr.doubleCard.goldCardExpireTime ~= 0 and DataMgr.doubleCard.goldCardExpireTime > FuncUtil.GetServerTimeInSec();
end

function DoubleCardSystem.HasExpRate()
    return DataMgr.doubleCard.expCardExpireTime ~= 0 and DataMgr.doubleCard.expCardExpireTime > FuncUtil.GetServerTimeInSec();
end

function DoubleCardSystem.IsCanUse(itemCfg)
    if itemCfg == nil then
        return true;
    end

    local itemEffectsCfg = Client.GetTableData("ItemEffects", itemCfg.ItemID);
    if (itemEffectsCfg == nil) then
        return true;
    end
    -- log_tree("DoubleCardSystem.IsCanUse doubleCard", DataMgr.doubleCard);
    -- log_tree("DoubleCardSystem.IsCanUse itemCfg", itemCfg);

    local serverTime = FuncUtil.GetServerTimeInSec();
    -- log("DoubleCardSystem.IsCanUse serverTime "..serverTime);
    if itemCfg.ItemType == 21 and itemCfg.ItemSubType == 2101 then
        local plus = tonumber(itemEffectsCfg.Param2);
        if DataMgr.doubleCard.expCardExpireTime ~= 0 and DataMgr.doubleCard.expCardExpireTime > serverTime and plus ~= DataMgr.doubleCard.expCardRatePlus then
            return false;
        end
    elseif itemCfg.ItemType == 21 and itemCfg.ItemSubType == 2102 then
        local plus = tonumber(itemEffectsCfg.Param2);
        -- log("DoubleCardSystem.IsCanUse plus "..plus);
        if DataMgr.doubleCard.goldCardExpireTime ~= 0 and DataMgr.doubleCard.goldCardExpireTime > serverTime and plus ~= DataMgr.doubleCard.goldCardRatePlus then
            return false;
        end
    end

    return true;
end

s2c["sync_double_card_info"] = DoubleCardSystem.OnSyncDoubleCardInfo;
