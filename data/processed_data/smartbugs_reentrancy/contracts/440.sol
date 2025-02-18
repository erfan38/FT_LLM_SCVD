1: 1: library SafeMath {
2: 2: 
3: 3:   
4: 4: 
5: 5: 
6: 6:   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
7: 7:     if (a == 0) {
8: 8:       return 0;
9: 9:     }
10: 10:     c = a * b;
11: 11:     assert(c / a == b);
12: 12:     return c;
13: 13:   }
14: 14: 
15: 15:   
16: 16: 
17: 17: 
18: 18:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
19: 19:     
20: 20:     
21: 21:     
22: 22:     return a / b;
23: 23:   }
24: 24: 
25: 25:   
26: 26: 
27: 27: 
28: 28:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
29: 29:     assert(b <= a);
30: 30:     return a - b;
31: 31:   }
32: 32: 
33: 33:   
34: 34: 
35: 35: 
36: 36:   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
37: 37:     c = a + b;
38: 38:     assert(c >= a);
39: 39:     return c;
40: 40:   }
41: 41: }
42: 42: 
43: 43: contract ERC827Token is ERC827, StandardToken {
44: 44: 
45: 45:   
46: 46: 
47: 47: 
48: 48: 
49: 49: 
50: 50: 
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
62: 62:   function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
63: 63:     require(_spender != address(this));
64: 64: 
65: 65:     super.approve(_spender, _value);
66: 66: 
67: 67:     
68: 68:     require(_spender.call.value(msg.value)(_data));
69: 69: 
70: 70:     return true;
71: 71:   }
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
83: 83:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
84: 84:     require(_to != address(this));
85: 85: 
86: 86:     super.transfer(_to, _value);
87: 87: 
88: 88:     
89: 89:     require(_to.call.value(msg.value)(_data));
90: 90:     return true;
91: 91:   }
92: 92: 
93: 93:   
94: 94: 
95: 95: 
96: 96: 
97: 97: 
98: 98: 
99: 99: 
100: 100: 
101: 101: 
102: 102: 
103: 103: 
104: 104:   function transferFromAndCall(
105: 105:     address _from,
106: 106:     address _to,
107: 107:     uint256 _value,
108: 108:     bytes _data
109: 109:   )
110: 110:     public payable returns (bool)
111: 111:   {
112: 112:     require(_to != address(this));
113: 113: 
114: 114:     super.transferFrom(_from, _to, _value);
115: 115: 
116: 116:     
117: 117:     require(_to.call.value(msg.value)(_data));
118: 118:     return true;
119: 119:   }
120: 120: 
121: 121:   
122: 122: 
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
134: 134:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
135: 135:     require(_spender != address(this));
136: 136: 
137: 137:     super.increaseApproval(_spender, _addedValue);
138: 138: 
139: 139:     
140: 140:     require(_spender.call.value(msg.value)(_data));
141: 141: 
142: 142:     return true;
143: 143:   }
144: 144: 
145: 145:   
146: 146: 
147: 147: 
148: 148: 
149: 149: 
150: 150: 
151: 151: 
152: 152: 
153: 153: 
154: 154: 
155: 155: 
156: 156: 
157: 157: 
158: 158:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
159: 159:     require(_spender != address(this));
160: 160: 
161: 161:     super.decreaseApproval(_spender, _subtractedValue);
162: 162: 
163: 163:     
164: 164:     require(_spender.call.value(msg.value)(_data));
165: 165: 
166: 166:     return true;
167: 167:   }
168: 168: 
169: 169: }
170: 170: 