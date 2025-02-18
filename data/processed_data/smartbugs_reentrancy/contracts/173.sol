1: 1: 1: 1: 1: pragma solidity ^0.4.24;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract Proxy  {
4: 4: 4: 4: 4:     modifier onlyOwner { if (msg.sender == Owner) _; } address Owner = msg.sender;
5: 5: 5: 5: 5:     function transferOwner(address _owner) public onlyOwner { Owner = _owner; } 
6: 6: 6: 6: 6:     function proxy(address target, bytes data) public payable {
7: 7: 7: 7: 7:         target.call.value(msg.value)(data);
8: 8: 8: 8: 8:     }
9: 9: 9: 9: 9: }
10: 10: 10: 10: 10: 