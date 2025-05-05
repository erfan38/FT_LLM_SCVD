contract GUB is MintableToken {
    
    function () public {
        revert();
    }

    string public constant name = "Ancient coins’ chain";
    string public constant symbol = "GUB";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 7000000000;
    
    
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, totalSupply_);
    }
}