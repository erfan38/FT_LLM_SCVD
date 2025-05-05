1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: contract ERC827Caller {
9: 9:   function makeCall(address _target, bytes _data) external payable returns (bool) {
10: 10:     
11: 11:     return _target.call.value(msg.value)(_data);
12: 12:   }
13: 13: }
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22: 
23: 23: 