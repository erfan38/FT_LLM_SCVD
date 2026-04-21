contract Controlled is Owned{

    function Controlled() {
       setExclude(msg.sender);
    }

    // Flag that determines if the token is transferable or not.
    bool public transferEnabled = false;

    // flag that makes locked address effect
    bool lockFlag=true;
    mapping(address => bool) locked;
    mapping(address => bool) exclude;

    function enableTransfer(bool _enable) 
    public onlyOwner{
        transferEnabled=_enable;
    }
    function disableLock(bool _enable)
    onlyOwner
    returns (bool success){
        lockFlag=_enable;
        return true;
    }
    function addLock(address _addr) 
    onlyOwner 
    returns (bool success){
        require(_addr!=msg.sender);
        locked[_addr]=true;
        return true;
    }

    function setExclude(address _addr) 
    onlyOwner 
    returns (bool success){
        exclude[_addr]=true;
        return true;
    }
    function removeLock(address _addr)
    onlyOwner
    returns (bool success){
        locked[_addr]=false;
        return true;
    }

    modifier transferAllowed {
        if (!exclude[msg.sender]) {
            assert(transferEnabled);
            if(lockFlag){
                assert(!locked[msg.sender]);
            }
        }
        
        _;
    }
  
}

/*
You should inherit from StandardToken or, for a token like you would want to
deploy in something like Mist, see HumanStandardToken.sol.
(This implements ONLY the standard functions and NOTHING else.
If you deploy this, you won't have anything useful.)

Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
.*/

