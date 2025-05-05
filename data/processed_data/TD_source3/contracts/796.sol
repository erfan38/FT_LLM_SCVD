contract EGOLD is Consts, FreezableMintableToken, BurnableToken, Pausable
    
{
    
    event Initialized();
    bool public initialized = false;

    function MainToken() public {
        init();
        transferOwnership(TARGET_USER);
    }

    function init() private {
        require(!initialized);
        initialized = true;

        if (PAUSED) {
            pause();
        }

        
        address[1] memory addresses = [address(0x8f71659fb57E6C6Be3Ab563D0dD45101235ae762)];
        uint[1] memory amounts = [uint(100000000000000000000000000)];
        uint64[1] memory freezes = [uint64(0)];

        for (uint i = 0; i < addresses.length; i++) {
            if (freezes[i] == 0) {
                mint(addresses[i], amounts[i]);
            } else {
                mintAndFreeze(addresses[i], amounts[i], freezes[i]);
            }
        }
        

        if (!CONTINUE_MINTING) {
            finishMinting();
        }

        Initialized();
    }
    

    function name() pure public returns (string _name) {
        return TOKEN_NAME;
    }

    function symbol() pure public returns (string _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() pure public returns (uint8 _decimals) {
        return TOKEN_DECIMALS_UINT8;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool _success) {
        require(!paused);
        return super.transfer(_to, _value);
    }
}