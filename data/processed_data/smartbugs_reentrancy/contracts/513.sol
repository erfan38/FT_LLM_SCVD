1: 1: pragma solidity ^0.4.24; 
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: contract AionClient {
10: 10:     
11: 11:     address private AionAddress;
12: 12: 
13: 13:     constructor(address addraion) public{
14: 14:         AionAddress = addraion;
15: 15:     }
16: 16: 
17: 17:     
18: 18:     function execfunct(address to, uint256 value, uint256 gaslimit, bytes data) external returns(bool) {
19: 19:         require(msg.sender == AionAddress);
20: 20:         return to.call.value(value).gas(gaslimit)(data);
21: 21: 
22: 22:     }
23: 23:     
24: 24: 
25: 25:     function () payable public {}
26: 26: 
27: 27: }
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32: 
33: 33: library SafeMath {
34: 34:   
35: 35:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
36: 36:         if (a == 0) {return 0;}
37: 37:         uint256 c = a * b;
38: 38:         require(c / a == b);
39: 39:         return c;
40: 40:     }
41: 41: 
42: 42:   
43: 43:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
44: 44:         uint256 c = a / b;
45: 45:         return c;
46: 46:     }
47: 47: 
48: 48:   
49: 49:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
50: 50:         require(b <= a);
51: 51:         return a - b;
52: 52:     }
53: 53: 
54: 54:   
55: 55:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
56: 56:         uint256 c = a + b;
57: 57:         require(c >= a);
58: 58:         return c;
59: 59:     }
60: 60: 
61: 61: }
62: 62: 
63: 63: 
64: 64: 
65: 65: 
66: 66: 
67: 67: 
68: 68: 