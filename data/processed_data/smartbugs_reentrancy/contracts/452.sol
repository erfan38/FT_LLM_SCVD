1: 1: pragma solidity ^0.4.13;
2: 2: 
3: 3: library SafeMath {
4: 4: 
5: 5:   
6: 6: 
7: 7: 
8: 8:   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
9: 9:     if (a == 0) {
10: 10:       return 0;
11: 11:     }
12: 12:     c = a * b;
13: 13:     assert(c / a == b);
14: 14:     return c;
15: 15:   }
16: 16: 
17: 17:   
18: 18: 
19: 19: 
20: 20:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
21: 21:     
22: 22:     
23: 23:     
24: 24:     return a / b;
25: 25:   }
26: 26: 
27: 27:   
28: 28: 
29: 29: 
30: 30:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
31: 31:     assert(b <= a);
32: 32:     return a - b;
33: 33:   }
34: 34: 
35: 35:   
36: 36: 
37: 37: 
38: 38:   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
39: 39:     c = a + b;
40: 40:     assert(c >= a);
41: 41:     return c;
42: 42:   }
43: 43: }
44: 44: 
45: 45: contract ERC827Token is ERC827, StandardToken {
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
62: 62: 
63: 63: 
64: 64:   function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
65: 65:     require(_spender != address(this));
66: 66: 
67: 67:     super.approve(_spender, _value);
68: 68: 
69: 69:     
70: 70:     require(_spender.call.value(msg.value)(_data));
71: 71: 
72: 72:     return true;
73: 73:   }
74: 74: 
75: 75:   
76: 76: 
77: 77: 
78: 78: 
79: 79: 
80: 80: 
81: 81: 
82: 82: 
83: 83: 
84: 84: 
85: 85:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
86: 86:     require(_to != address(this));
87: 87: 
88: 88:     super.transfer(_to, _value);
89: 89: 
90: 90:     
91: 91:     require(_to.call.value(msg.value)(_data));
92: 92:     return true;
93: 93:   }
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
104: 104: 
105: 105: 
106: 106:   function transferFromAndCall(
107: 107:     address _from,
108: 108:     address _to,
109: 109:     uint256 _value,
110: 110:     bytes _data
111: 111:   )
112: 112:     public payable returns (bool)
113: 113:   {
114: 114:     require(_to != address(this));
115: 115: 
116: 116:     super.transferFrom(_from, _to, _value);
117: 117: 
118: 118:     
119: 119:     require(_to.call.value(msg.value)(_data));
120: 120:     return true;
121: 121:   }
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
134: 134: 
135: 135: 
136: 136:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
137: 137:     require(_spender != address(this));
138: 138: 
139: 139:     super.increaseApproval(_spender, _addedValue);
140: 140: 
141: 141:     
142: 142:     require(_spender.call.value(msg.value)(_data));
143: 143: 
144: 144:     return true;
145: 145:   }
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
158: 158: 
159: 159: 
160: 160:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
161: 161:     require(_spender != address(this));
162: 162: 
163: 163:     super.decreaseApproval(_spender, _subtractedValue);
164: 164: 
165: 165:     
166: 166:     require(_spender.call.value(msg.value)(_data));
167: 167: 
168: 168:     return true;
169: 169:   }
170: 170: 
171: 171: }
172: 172: 