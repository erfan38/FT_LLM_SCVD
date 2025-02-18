1: 1: 1: 1: 1: pragma solidity ^0.4.16;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: library SafeMath {
8: 8: 8: 8: 8:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
9: 9: 9: 9: 9:     uint256 c = a * b;
10: 10: 10: 10: 10:     assert(a == 0 || c / a == b);
11: 11: 11: 11: 11:     return c;
12: 12: 12: 12: 12:   }
13: 13: 13: 13: 13: 
14: 14: 14: 14: 14:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
15: 15: 15: 15: 15:     
16: 16: 16: 16: 16:     uint256 c = a / b;
17: 17: 17: 17: 17:     
18: 18: 18: 18: 18:     return c;
19: 19: 19: 19: 19:   }
20: 20: 20: 20: 20: 
21: 21: 21: 21: 21:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
22: 22: 22: 22: 22:     assert(b <= a);
23: 23: 23: 23: 23:     return a - b;
24: 24: 24: 24: 24:   }
25: 25: 25: 25: 25: 
26: 26: 26: 26: 26:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
27: 27: 27: 27: 27:     uint256 c = a + b;
28: 28: 28: 28: 28:     assert(c >= a);
29: 29: 29: 29: 29:     return c;
30: 30: 30: 30: 30:   }
31: 31: 31: 31: 31: }
32: 32: 32: 32: 32: 
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37: 
38: 38: 38: 38: 38: contract Crowdsale is PausableToken {
39: 39: 39: 39: 39:     uint8 public decimals = 18;
40: 40: 40: 40: 40:     uint256 public ownerSupply = 18900000000 * (10 ** uint256(decimals));
41: 41: 41: 41: 41:     uint256 public supplyLimit = 21000000000 * (10 ** uint256(decimals));
42: 42: 42: 42: 42:     uint256 public crowdsaleSupply = 0;
43: 43: 43: 43: 43:     uint256 public crowdsalePrice = 20000;
44: 44: 44: 44: 44:     uint256 public crowdsaleTotal = 2100000000 * (10 ** uint256(decimals));
45: 45: 45: 45: 45:     uint256 public limit = 2 * (10 ** uint256(decimals));
46: 46: 46: 46: 46:     
47: 47: 47: 47: 47:     function crowdsale() public payable returns (bool) {
48: 48: 48: 48: 48:         require(msg.value >= limit);
49: 49: 49: 49: 49:         uint256 vv = msg.value;
50: 50: 50: 50: 50:         uint256 coin = crowdsalePrice.mul(vv);
51: 51: 51: 51: 51:         require(coin.add(totalSupply) <= supplyLimit);
52: 52: 52: 52: 52:         require(crowdsaleSupply.add(coin) <= crowdsaleTotal);
53: 53: 53: 53: 53:         
54: 54: 54: 54: 54:         balances[msg.sender] = coin.add(balances[msg.sender]);
55: 55: 55: 55: 55:         totalSupply = totalSupply.add(coin);
56: 56: 56: 56: 56:         crowdsaleSupply = crowdsaleSupply.add(coin);
57: 57: 57: 57: 57:         balances[msg.sender] = coin;
58: 58: 58: 58: 58:         require(owner.call.value(msg.value)());
59: 59: 59: 59: 59:         return true;
60: 60: 60: 60: 60:     }
61: 61: 61: 61: 61: }
62: 62: 62: 62: 62: 
63: 63: 63: 63: 63: 
64: 64: 64: 64: 64: 
65: 65: 65: 65: 65: 
66: 66: 66: 66: 66: 
67: 67: 67: 67: 67: 