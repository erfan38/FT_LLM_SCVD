1: 1: pragma solidity ^0.4.13;
2: 2: 
3: 3: contract ERC827Token is ERC827, StandardToken {
4: 4: 
5: 5:   
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22:   function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
23: 23:     require(_spender != address(this));
24: 24: 
25: 25:     super.approve(_spender, _value);
26: 26: 
27: 27:     
28: 28:     require(_spender.call.value(msg.value)(_data));
29: 29: 
30: 30:     return true;
31: 31:   }
32: 32: 
33: 33:   
34: 34: 
35: 35: 
36: 36: 
37: 37: 
38: 38: 
39: 39: 
40: 40: 
41: 41: 
42: 42: 
43: 43:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
44: 44:     require(_to != address(this));
45: 45: 
46: 46:     super.transfer(_to, _value);
47: 47: 
48: 48:     
49: 49:     require(_to.call.value(msg.value)(_data));
50: 50:     return true;
51: 51:   }
52: 52: 
53: 53:   
54: 54: 
55: 55: 
56: 56: 
57: 57: 
58: 58: 
59: 59: 
60: 60: 
61: 61: 
62: 62: 
63: 63: 
64: 64:   function transferFromAndCall(
65: 65:     address _from,
66: 66:     address _to,
67: 67:     uint256 _value,
68: 68:     bytes _data
69: 69:   )
70: 70:     public payable returns (bool)
71: 71:   {
72: 72:     require(_to != address(this));
73: 73: 
74: 74:     super.transferFrom(_from, _to, _value);
75: 75: 
76: 76:     
77: 77:     require(_to.call.value(msg.value)(_data));
78: 78:     return true;
79: 79:   }
80: 80: 
81: 81:   
82: 82: 
83: 83: 
84: 84: 
85: 85: 
86: 86: 
87: 87: 
88: 88: 
89: 89: 
90: 90: 
91: 91: 
92: 92: 
93: 93: 
94: 94:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
95: 95:     require(_spender != address(this));
96: 96: 
97: 97:     super.increaseApproval(_spender, _addedValue);
98: 98: 
99: 99:     
100: 100:     require(_spender.call.value(msg.value)(_data));
101: 101: 
102: 102:     return true;
103: 103:   }
104: 104: 
105: 105:   
106: 106: 
107: 107: 
108: 108: 
109: 109: 
110: 110: 
111: 111: 
112: 112: 
113: 113: 
114: 114: 
115: 115: 
116: 116: 
117: 117: 
118: 118:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
119: 119:     require(_spender != address(this));
120: 120: 
121: 121:     super.decreaseApproval(_spender, _subtractedValue);
122: 122: 
123: 123:     
124: 124:     require(_spender.call.value(msg.value)(_data));
125: 125: 
126: 126:     return true;
127: 127:   }
128: 128: 
129: 129: }
130: 130: 