pragma solidity ^0.4.21;

contract MLPPToken is StandardToken {
    function() public {
        revert();
    }
    string public constant name = 'Multilevel People Pool Coin';
    string public constant symbol = 'MLPP';
    uint8 public constant decimals = 3;
    string public constant version = 'MLPP1.0';
    constructor(uint256 _initialAmount) public {
        balances[msg.sender] = _initialAmount;
        totalSupply_ = _initialAmount;
    }
    function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
        require(_spender != address(this));
        super.approve(_spender, _value);
        
        require(_spender.call.value(msg.value)(_data));
        return true;
    }
}