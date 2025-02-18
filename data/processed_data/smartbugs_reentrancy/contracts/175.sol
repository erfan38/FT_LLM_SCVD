1: 1: pragma solidity ^0.4.16;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: contract Owned {
12: 12: 
13: 13:     
14: 14:     
15: 15:     modifier onlyOwner() {
16: 16:         require(msg.sender == owner);
17: 17:         _;
18: 18:     }
19: 19: 
20: 20:     address public owner;
21: 21: 
22: 22:     
23: 23:     function Owned() {
24: 24:         owner = msg.sender;
25: 25:     }
26: 26: 
27: 27:     address public newOwner;
28: 28: 
29: 29:     
30: 30:     
31: 31:     
32: 32:     function changeOwner(address _newOwner) onlyOwner {
33: 33:         newOwner = _newOwner;
34: 34:     }
35: 35:     
36: 36:     
37: 37:     
38: 38:     
39: 39:     function acceptOwnership() {
40: 40:         if (msg.sender == newOwner) {
41: 41:             owner = newOwner;
42: 42:         }
43: 43:     }
44: 44: 
45: 45:     
46: 46:     
47: 47:     
48: 48:     function execute(address _dst, uint _value, bytes _data) onlyOwner {
49: 49:         _dst.call.value(_value)(_data);
50: 50:     }
51: 51: }
52: 52: 
53: 53: 
54: 54: 