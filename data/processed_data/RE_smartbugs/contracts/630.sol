pragma solidity ^0.4.21;

contract StudToken is StandardToken {
    function() public {
        revert();
    }
    string public constant name = 'Stud Coin';
    string public constant symbol = 'STUD';
    uint8 public constant decimals = 3;
    string public constant version = 'S1.0';
    function StudToken(uint256 _initialAmount) public {
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