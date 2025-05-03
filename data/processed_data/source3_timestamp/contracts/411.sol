contract MainToken is Consts, FreezableMintableToken, BurnableToken, Pausable
    
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

        

        if (!CONTINUE_MINTING) {
            finishMinting();
        }

        emit Initialized();
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