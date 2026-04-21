contract ThroneRulesMixin {

    // See World.createKingdom(..) for documentation.
    struct ThroneRules {
        uint startingClaimPriceWei;
        uint maximumClaimPriceWei;
        uint claimPriceAdjustPercent;
        uint curseIncubationDurationSeconds;
        uint commissionPerThousand;
    }

}


/// @title Maintains the throne of a kingdom.
