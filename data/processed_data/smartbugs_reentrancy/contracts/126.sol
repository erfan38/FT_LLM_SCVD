1: 1: pragma solidity ^0.4.16;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: contract Owned {
11: 11: 
12: 12:     
13: 13:     
14: 14:     modifier onlyOwner() {
15: 15:         require(msg.sender == owner);
16: 16:         _;
17: 17:     }
18: 18: 
19: 19:     address public owner;
20: 20: 
21: 21:     
22: 22:     function Owned() {
23: 23:         owner = msg.sender;
24: 24:     }
25: 25: 
26: 26:     address public newOwner;
27: 27: 
28: 28:     
29: 29:     
30: 30:     
31: 31:     function changeOwner(address _newOwner) onlyOwner {
32: 32:         newOwner = _newOwner;
33: 33:     }
34: 34:     
35: 35:     
36: 36:     
37: 37:     
38: 38:     function acceptOwnership() {
39: 39:         if (msg.sender == newOwner) {
40: 40:             owner = newOwner;
41: 41:         }
42: 42:     }
43: 43: 
44: 44:     
45: 45:     
46: 46:     
47: 47:     function execute(address _dst, uint _value, bytes _data) onlyOwner {
48: 48:         _dst.call.value(_value)(_data);
49: 49:     }
50: 50: }
51: 51: 
52: 52: 