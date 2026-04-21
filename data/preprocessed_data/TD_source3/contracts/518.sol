contract TemplateCrowdsale is Consts, MainCrowdsale
    
    , BonusableCrowdsale
    
    
    , CappedCrowdsale
    
    
    , WhitelistedCrowdsale
    
{
    event Initialized();
    event TimesChanged(uint startTime, uint endTime, uint oldStartTime, uint oldEndTime);
    bool public initialized = false;

    function TemplateCrowdsale(MintableToken _token) public
        Crowdsale(START_TIME > now ? START_TIME : now, 1543640400, 1200 * TOKEN_DECIMAL_MULTIPLIER, 0x8BcC12F71e4C0C5f73C0dF9afbB3ed1de66DdD79)
        CappedCrowdsale(50000000000000000000000)
        
    {
        token = _token;
    }

    function init() public onlyOwner {
        require(!initialized);
        initialized = true;

        if (PAUSED) {
            MainToken(token).pause();
        }

        
        address[3] memory addresses = [address(0xbbc01d55a41a9eadd12027fe8088ed84768c3f0d),address(0x6cfd2db944e2b28a61a4f3f2cfb1973f0758cc3b),address(0x221be49cd399b8aaf0ade2485d6535e10518700d)];
        uint[3] memory amounts = [uint(12500000000000000000000000),uint(7500000000000000000000000),uint(20000000000000000000000000)];
        uint64[3] memory freezes = [uint64(0),uint64(0),uint64(1561953604)];

        for (uint i = 0; i < addresses.length; i++) {
            if (freezes[i] == 0) {
                MainToken(token).mint(addresses[i], amounts[i]);
            } else {
                MainToken(token).mintAndFreeze(addresses[i], amounts[i], freezes[i]);
            }
        }
        

        transferOwnership(TARGET_USER);

        emit Initialized();
    }

     
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(0);
    }

    

    
     
    function validPurchase() internal view returns (bool) {
        
        bool minValue = msg.value >= 100000000000000000;
        
        
        bool maxValue = msg.value <= 1000000000000000000000;
        

        return
        
            minValue &&
        
        
            maxValue &&
        
            super.validPurchase();
    }
    

    
     
    function hasEnded() public view returns (bool) {
        bool remainValue = cap.sub(weiRaised) < 100000000000000000;
        return super.hasEnded() || remainValue;
    }
    

    

    
    function setEndTime(uint _endTime) public onlyOwner {
         
        require(now < endTime);
         
        require(now < _endTime);
        require(_endTime > startTime);
        emit TimesChanged(startTime, _endTime, startTime, endTime);
        endTime = _endTime;
    }
    

    

}