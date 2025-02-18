1: pragma solidity ^0.4.13;
2: 
3: contract ERC827Token is ERC827, StandardToken {
4: 
5:   
6: 
7: 
8: 
9: 
10: 
11: 
12: 
13: 
14: 
15: 
16: 
17: 
18: 
19: 
20: 
21: 
22:   function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
23:     require(_spender != address(this));
24: 
25:     super.approve(_spender, _value);
26: 
27:     
28:     require(_spender.call.value(msg.value)(_data));
29: 
30:     return true;
31:   }
32: 
33:   
34: 
35: 
36: 
37: 
38: 
39: 
40: 
41: 
42: 
43:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
44:     require(_to != address(this));
45: 
46:     super.transfer(_to, _value);
47: 
48:     
49:     require(_to.call.value(msg.value)(_data));
50:     return true;
51:   }
52: 
53:   
54: 
55: 
56: 
57: 
58: 
59: 
60: 
61: 
62: 
63: 
64:   function transferFromAndCall(
65:     address _from,
66:     address _to,
67:     uint256 _value,
68:     bytes _data
69:   )
70:     public payable returns (bool)
71:   {
72:     require(_to != address(this));
73: 
74:     super.transferFrom(_from, _to, _value);
75: 
76:     
77:     require(_to.call.value(msg.value)(_data));
78:     return true;
79:   }
80: 
81:   
82: 
83: 
84: 
85: 
86: 
87: 
88: 
89: 
90: 
91: 
92: 
93: 
94:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
95:     require(_spender != address(this));
96: 
97:     super.increaseApproval(_spender, _addedValue);
98: 
99:     
100:     require(_spender.call.value(msg.value)(_data));
101: 
102:     return true;
103:   }
104: 
105:   
106: 
107: 
108: 
109: 
110: 
111: 
112: 
113: 
114: 
115: 
116: 
117: 
118:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
119:     require(_spender != address(this));
120: 
121:     super.decreaseApproval(_spender, _subtractedValue);
122: 
123:     
124:     require(_spender.call.value(msg.value)(_data));
125: 
126:     return true;
127:   }
128: 
129: }
130: 