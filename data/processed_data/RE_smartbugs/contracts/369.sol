1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: contract ERC1003Caller is Ownable {
11: 11:     function makeCall(address target, bytes data) external payable onlyOwner returns (bool) {
12: 12:         
13: 13:         return target.call.value(msg.value)(data);
14: 14:     }
15: 15: }
16: 16: 
17: 17: 