contract TemplateCrowdsale is Consts, MainCrowdsale
    
    , BonusableCrowdsale
    
    
    , RefundableCrowdsale
    
    , CappedCrowdsale
    
{
    event Initialized();
    event TimesChanged(uint startTime, uint endTime, uint oldStartTime, uint oldEndTime);
    bool public initialized = false;

    function TemplateCrowdsale(MintableToken _token) public
        Crowdsale(START_TIME > now ? START_TIME : now, 1546297140, 1500 * TOKEN_DECIMAL_MULTIPLIER, 0x04B21fe3FBa3E8E548EfC51013E71242a55212cF)
        CappedCrowdsale(20000000000000000000000)
        
        RefundableCrowdsale(1000000000000000000000)
        
    {
        token = _token;
    }

    function init() public onlyOwner {
        require(!initialized);
        initialized = true;

        if (PAUSED) {
            MainToken(token).pause();
        }

        
        address[4] memory addresses = [address(0xdadc35adc3091329a2a593a6c2ba2f1539aae965),address(0xe99d4d19b23bfe83916b346814ee06043154ae78),address(0xaae82f543abb3abda4faacb887e2f802d48ed2da),address(0xaf2bde98fe39733b0f2a89053a3060c0bf8f77da)];
        uint[4] memory amounts = [uint(1500000000000000000000000),uint(5000000000000000000000000),uint(10000000000000000000000000),uint(3500000000000000000000000)];
        uint64[4] memory freezes = [uint64(1577746805),uint64(1577746805),uint64(0),uint64(0)];

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

    

    

    

    

    
    function setEndTime(uint _endTime) public onlyOwner {
         
        require(now < endTime);
         
        require(now < _endTime);
        require(_endTime > startTime);
        emit TimesChanged(startTime, _endTime, startTime, endTime);
        endTime = _endTime;
    }
    

    

}