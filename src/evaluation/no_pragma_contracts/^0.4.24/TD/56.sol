contract MainToken is Consts, FreezableMintableToken, BurnableToken, Pausable    
{  
    event Initialized();
    bool public initialized = false;

    constructor() public {
        init();
        transferOwnership(TARGET_USER);
    }
    
    function name() public pure returns (string _name) {
        return TOKEN_NAME;
    }

    function symbol() public pure returns (string _symbol) {
        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint8 _decimals) {
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

    
    function init() private {
        require(!initialized);
        initialized = true;

        if (PAUSED) {
            pause();
        }

        
        address[1] memory addresses = [address(0x210d60d0ec127f0fff477a1b1b9424bb1c32876d)];
        uint[1] memory amounts = [uint(690000000000)];
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

        emit Initialized();
    }
    
}