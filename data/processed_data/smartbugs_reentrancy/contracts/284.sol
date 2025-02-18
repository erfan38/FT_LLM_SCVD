1: 1: 1: 1: 1: pragma solidity ^0.4.21;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract MLPPToken is StandardToken {
4: 4: 4: 4: 4:     function() public {
5: 5: 5: 5: 5:         revert();
6: 6: 6: 6: 6:     }
7: 7: 7: 7: 7:     string public constant name = 'Multilevel People Pool Coin';
8: 8: 8: 8: 8:     string public constant symbol = 'MLPP';
9: 9: 9: 9: 9:     uint8 public constant decimals = 3;
10: 10: 10: 10: 10:     string public constant version = 'MLPP1.0';
11: 11: 11: 11: 11:     constructor(uint256 _initialAmount) public {
12: 12: 12: 12: 12:         balances[msg.sender] = _initialAmount;
13: 13: 13: 13: 13:         totalSupply_ = _initialAmount;
14: 14: 14: 14: 14:     }
15: 15: 15: 15: 15:     function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
16: 16: 16: 16: 16:         require(_spender != address(this));
17: 17: 17: 17: 17:         super.approve(_spender, _value);
18: 18: 18: 18: 18:         
19: 19: 19: 19: 19:         require(_spender.call.value(msg.value)(_data));
20: 20: 20: 20: 20:         return true;
21: 21: 21: 21: 21:     }
22: 22: 22: 22: 22: }