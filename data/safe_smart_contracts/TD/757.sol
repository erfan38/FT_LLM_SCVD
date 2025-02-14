contract TemplateCrowdsale is Consts, MainCrowdsale
    
    , BonusableCrowdsale
    
    
    , RefundableCrowdsale
    
    , CappedCrowdsale
    
{
    event Initialized();
    bool public initialized = false;

    function TemplateCrowdsale(MintableToken _token) public
        Crowdsale(START_TIME > now ? START_TIME : now, 1546297140, 1500 * TOKEN_DECIMAL_MULTIPLIER, 0x8F988d90C96282402b47b01D7EADE079eA6eBe36)
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

        
        address[4] memory addresses = [address(0x192ff136cd853ab6b9b5097bf017024d7da709c3),address(0xa00be5796cf65147a7494f2f27de08cca6847cbb),address(0xb1c1113f071fa97318074486e27efd8e753f6b54),address(0xbd3e941f88c892118a8fc50ffa8ccd1199e30704)];
        uint[4] memory amounts = [uint(1500000000000000000000000),uint(5000000000000000000000000),uint(10000000000000000000000000),uint(3500000000000000000000000)];
        uint64[4] memory freezes = [uint64(1577746808),uint64(1577746809),uint64(0),uint64(1561845608)];

        for (uint i = 0; i < addresses.length; i++) {
            if (freezes[i] == 0) {
                MainToken(token).mint(addresses[i], amounts[i]);
            } else {
                MainToken(token).mintAndFreeze(addresses[i], amounts[i], freezes[i]);
            }
        }
        

        transferOwnership(TARGET_USER);

        Initialized();
    }

     
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(0);
    }

    

    

    

}