contract ESportsMainCrowdsale is ESportsConstants, RefundableCrowdsale {
    uint constant OVERALL_AMOUNT_TOKENS = 60000000 * TOKEN_DECIMAL_MULTIPLIER; // overall 100.00%
    uint constant TEAM_BEN_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00% // Founders
    uint constant TEAM_PHIL_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER;
    uint constant COMPANY_COLD_STORAGE_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%
    uint constant INVESTOR_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00%
    uint constant BONUS_TOKENS = 3000000 * TOKEN_DECIMAL_MULTIPLIER; // 5.00% // Pre-sale
	uint constant BUFFER_TOKENS = 6000000 * TOKEN_DECIMAL_MULTIPLIER; // 10.00%
    uint constant PRE_SALE_TOKENS = 12000000 * TOKEN_DECIMAL_MULTIPLIER; // 20.00%

    // Mainnet addresses
    address constant TEAM_BEN_ADDRESS = 0x2E352Ed15C4321f4dd7EdFc19402666dE8713cd8;
    address constant TEAM_PHIL_ADDRESS = 0x4466de3a8f4f0a0f5470b50fdc9f91fa04e00e34;
    address constant INVESTOR_ADDRESS = 0x14f8d0c41097ca6fddb6aa4fd6a3332af3741847;
    address constant BONUS_ADDRESS = 0x5baee4a9938d8f59edbe4dc109119983db4b7bd6;
    address constant COMPANY_COLD_STORAGE_ADDRESS = 0x700d6ae53be946085bb91f96eb1cf9e420236762;
    address constant PRE_SALE_ADDRESS = 0xcb2809926e615245b3af4ebce5af9fbe1a6a4321;
    
    address btcBuyer = 0x1eee4c7d88aadec2ab82dd191491d1a9edf21e9a;

    ESportsBonusProvider public bonusProvider;

    bool private isInit = false;
    
	/**
     * Constructor function
     */
    function ESportsMainCrowdsale(
        uint32 _startTime,
        uint32 _endTime,
        uint _softCapWei, // 4000000 EUR
        address _wallet,
        address _token
	) RefundableCrowdsale(
        _startTime,
        _endTime, 
        RATE,
        OVERALL_AMOUNT_TOKENS,
        _wallet,
        _token,
        _softCapWei
	) {
	}

    /**
     * @dev Release delayed bonus tokens
     * @return Amount of got bonus tokens
     */
    function releaseBonus() returns(uint) {
        return bonusProvider.releaseBonus(msg.sender, soldTokens);
    }

    /**
     * @dev Trasfer bonuses and adding delayed bonuses
     * @param _beneficiary Future bonuses holder
     * @param _tokens Amount of bonus tokens
     */
    function postBuyTokens(address _beneficiary, uint _tokens) internal {
        uint bonuses = bonusProvider.getBonusAmount(_beneficiary, soldTokens, _tokens, startTime);
        bonusProvider.addDelayedBonus(_beneficiary, soldTokens, _tokens);

        if (bonuses > 0) {
            bonusProvider.sendBonus(_beneficiary, bonuses);
        }
    }

    /**
     * @dev Initialization of crowdsale. Starts once after deployment token contract
     * , deployment crowdsale 