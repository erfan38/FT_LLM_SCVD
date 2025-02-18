1: pragma solidity ^0.4.24;
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: 
10: contract ERC1003Caller is Ownable {
11:     function makeCall(address target, bytes data) external payable onlyOwner returns (bool) {
12:         
13:         return target.call.value(msg.value)(data);
14:     }
15: }
16: 
17: 