1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: library SafeMath {
10: 10: 
11: 11:   
12: 12: 
13: 13: 
14: 14:   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
15: 15:     
16: 16:     
17: 17:     
18: 18:     if (a == 0) {
19: 19:       return 0;
20: 20:     }
21: 21: 
22: 22:     c = a * b;
23: 23:     assert(c / a == b);
24: 24:     return c;
25: 25:   }
26: 26: 
27: 27:   
28: 28: 
29: 29: 
30: 30:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
31: 31:     
32: 32:     
33: 33:     
34: 34:     return a / b;
35: 35:   }
36: 36: 
37: 37:   
38: 38: 
39: 39: 
40: 40:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
41: 41:     assert(b <= a);
42: 42:     return a - b;
43: 43:   }
44: 44: 
45: 45:   
46: 46: 
47: 47: 
48: 48:   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
49: 49:     c = a + b;
50: 50:     assert(c >= a);
51: 51:     return c;
52: 52:   }
53: 53: }
54: 54: 
55: 55: 
56: 56: 
57: 57: 
58: 58: 
59: 59: 
60: 60: 
61: 61: 
62: 62: contract ERC1003Caller is Ownable {
63: 63:     function makeCall(address _target, bytes _data) external payable onlyOwner returns (bool) {
64: 64:         
65: 65:         return _target.call.value(msg.value)(_data);
66: 66:     }
67: 67: }
68: 68: 