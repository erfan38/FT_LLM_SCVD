1: 1: 
2: 2: 
3: 3: 
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
14: 14: pragma solidity ^0.4.21;
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22: contract ERC827Token is ERC827, StandardToken {
23: 23: 
24: 24:   
25: 25: 
26: 26: 
27: 27: 
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32: 
33: 33: 
34: 34: 
35: 35: 
36: 36: 
37: 37: 
38: 38: 
39: 39: 
40: 40: 
41: 41:   function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
42: 42:     require(_spender != address(this));
43: 43: 
44: 44:     super.approve(_spender, _value);
45: 45: 
46: 46:     
47: 47:     require(_spender.call.value(msg.value)(_data));
48: 48: 
49: 49:     return true;
50: 50:   }
51: 51: 
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
62: 62:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
63: 63:     require(_to != address(this));
64: 64: 
65: 65:     super.transfer(_to, _value);
66: 66: 
67: 67:     
68: 68:     require(_to.call.value(msg.value)(_data));
69: 69:     return true;
70: 70:   }
71: 71: 
72: 72:   
73: 73: 
74: 74: 
75: 75: 
76: 76: 
77: 77: 
78: 78: 
79: 79: 
80: 80: 
81: 81: 
82: 82: 
83: 83:   function transferFromAndCall(
84: 84:     address _from,
85: 85:     address _to,
86: 86:     uint256 _value,
87: 87:     bytes _data
88: 88:   )
89: 89:     public payable returns (bool)
90: 90:   {
91: 91:     require(_to != address(this));
92: 92: 
93: 93:     super.transferFrom(_from, _to, _value);
94: 94: 
95: 95:     
96: 96:     require(_to.call.value(msg.value)(_data));
97: 97:     return true;
98: 98:   }
99: 99: 
100: 100:   
101: 101: 
102: 102: 
103: 103: 
104: 104: 
105: 105: 
106: 106: 
107: 107: 
108: 108: 
109: 109: 
110: 110: 
111: 111: 
112: 112: 
113: 113:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
114: 114:     require(_spender != address(this));
115: 115: 
116: 116:     super.increaseApproval(_spender, _addedValue);
117: 117: 
118: 118:     
119: 119:     require(_spender.call.value(msg.value)(_data));
120: 120: 
121: 121:     return true;
122: 122:   }
123: 123: 
124: 124:   
125: 125: 
126: 126: 
127: 127: 
128: 128: 
129: 129: 
130: 130: 
131: 131: 
132: 132: 
133: 133: 
134: 134: 
135: 135: 
136: 136: 
137: 137:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
138: 138:     require(_spender != address(this));
139: 139: 
140: 140:     super.decreaseApproval(_spender, _subtractedValue);
141: 141: 
142: 142:     
143: 143:     require(_spender.call.value(msg.value)(_data));
144: 144: 
145: 145:     return true;
146: 146:   }
147: 147: 
148: 148: }
149: 149: 
150: 150: 
151: 151: pragma solidity ^0.4.21;
152: 152: 
153: 153: 
154: 154: 
155: 155: 
156: 156: 
157: 157: 
158: 158: 