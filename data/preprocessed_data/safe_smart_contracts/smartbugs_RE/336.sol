pragma solidity ^0.4.24;



contract OriginToken is BurnableToken, MintableToken, WhitelistedPausableToken, DetailedERC20 {
    event AddCallSpenderWhitelist(address enabler, address spender);
    event RemoveCallSpenderWhitelist(address disabler, address spender);

    mapping (address => bool) public callSpenderWhitelist;

    
    constructor(uint256 _initialSupply) DetailedERC20("OriginToken", "OGN", 18) public {
        owner = msg.sender;
        mint(owner, _initialSupply);
    }

    
    
    

    
    
    function burn(uint256 _value) public onlyOwner {
        
        
        super.burn(_value);
    }

    
    
    
    function burn(address _who, uint256 _value) public onlyOwner {
        _burn(_who, _value);
    }

    
    
    

    
    
    function addCallSpenderWhitelist(address _spender) public onlyOwner {
        callSpenderWhitelist[_spender] = true;
        emit AddCallSpenderWhitelist(msg.sender, _spender);
    }

    
    
    function removeCallSpenderWhitelist(address _spender) public onlyOwner {
        delete callSpenderWhitelist[_spender];
        emit RemoveCallSpenderWhitelist(msg.sender, _spender);
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function approveAndCallWithSender(
        address _spender,
        uint256 _value,
        bytes4 _selector,
        bytes _callParams
    )
        public
        payable
        returns (bool)
    {
        require(_spender != address(this), "token contract can't be approved");
        require(callSpenderWhitelist[_spender], "spender not in whitelist");

        require(super.approve(_spender, _value), "approve failed");

        bytes memory callData = abi.encodePacked(_selector, uint256(msg.sender), _callParams);
        
        require(_spender.call.value(msg.value)(callData), "proxied call failed");
        return true;
    }
}