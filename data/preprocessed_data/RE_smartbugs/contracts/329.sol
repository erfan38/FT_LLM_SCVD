1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: library SafeMath {
4: 4: 
5: 5:   
6: 6: 
7: 7: 
8: 8:   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
9: 9:     
10: 10:     
11: 11:     
12: 12:     if (a == 0) {
13: 13:       return 0;
14: 14:     }
15: 15: 
16: 16:     c = a * b;
17: 17:     assert(c / a == b);
18: 18:     return c;
19: 19:   }
20: 20: 
21: 21:   
22: 22: 
23: 23: 
24: 24:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
25: 25:     
26: 26:     
27: 27:     
28: 28:     return a / b;
29: 29:   }
30: 30: 
31: 31:   
32: 32: 
33: 33: 
34: 34:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
35: 35:     assert(b <= a);
36: 36:     return a - b;
37: 37:   }
38: 38: 
39: 39:   
40: 40: 
41: 41: 
42: 42:   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
43: 43:     c = a + b;
44: 44:     assert(c >= a);
45: 45:     return c;
46: 46:   }
47: 47: }
48: 48: 
49: 49: contract ERC827Token is ERC827, StandardToken {
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
64: 64: 
65: 65: 
66: 66: 
67: 67: 
68: 68:   function approveAndCall(
69: 69:     address _spender,
70: 70:     uint256 _value,
71: 71:     bytes _data
72: 72:   )
73: 73:     public
74: 74:     payable
75: 75:     returns (bool)
76: 76:   {
77: 77:     require(_spender != address(this));
78: 78: 
79: 79:     super.approve(_spender, _value);
80: 80: 
81: 81:     
82: 82:     require(_spender.call.value(msg.value)(_data));
83: 83: 
84: 84:     return true;
85: 85:   }
86: 86: 
87: 87:   
88: 88: 
89: 89: 
90: 90: 
91: 91: 
92: 92: 
93: 93: 
94: 94: 
95: 95: 
96: 96: 
97: 97:   function transferAndCall(
98: 98:     address _to,
99: 99:     uint256 _value,
100: 100:     bytes _data
101: 101:   )
102: 102:     public
103: 103:     payable
104: 104:     returns (bool)
105: 105:   {
106: 106:     require(_to != address(this));
107: 107: 
108: 108:     super.transfer(_to, _value);
109: 109: 
110: 110:     
111: 111:     require(_to.call.value(msg.value)(_data));
112: 112:     return true;
113: 113:   }
114: 114: 
115: 115:   
116: 116: 
117: 117: 
118: 118: 
119: 119: 
120: 120: 
121: 121: 
122: 122: 
123: 123: 
124: 124: 
125: 125: 
126: 126:   function transferFromAndCall(
127: 127:     address _from,
128: 128:     address _to,
129: 129:     uint256 _value,
130: 130:     bytes _data
131: 131:   )
132: 132:     public payable returns (bool)
133: 133:   {
134: 134:     require(_to != address(this));
135: 135: 
136: 136:     super.transferFrom(_from, _to, _value);
137: 137: 
138: 138:     
139: 139:     require(_to.call.value(msg.value)(_data));
140: 140:     return true;
141: 141:   }
142: 142: 
143: 143:   
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
156: 156:   function increaseApprovalAndCall(
157: 157:     address _spender,
158: 158:     uint _addedValue,
159: 159:     bytes _data
160: 160:   )
161: 161:     public
162: 162:     payable
163: 163:     returns (bool)
164: 164:   {
165: 165:     require(_spender != address(this));
166: 166: 
167: 167:     super.increaseApproval(_spender, _addedValue);
168: 168: 
169: 169:     
170: 170:     require(_spender.call.value(msg.value)(_data));
171: 171: 
172: 172:     return true;
173: 173:   }
174: 174: 
175: 175:   
176: 176: 
177: 177: 
178: 178: 
179: 179: 
180: 180: 
181: 181: 
182: 182: 
183: 183: 
184: 184: 
185: 185: 
186: 186: 
187: 187: 
188: 188:   function decreaseApprovalAndCall(
189: 189:     address _spender,
190: 190:     uint _subtractedValue,
191: 191:     bytes _data
192: 192:   )
193: 193:     public
194: 194:     payable
195: 195:     returns (bool)
196: 196:   {
197: 197:     require(_spender != address(this));
198: 198: 
199: 199:     super.decreaseApproval(_spender, _subtractedValue);
200: 200: 
201: 201:     
202: 202:     require(_spender.call.value(msg.value)(_data));
203: 203: 
204: 204:     return true;
205: 205:   }
206: 206: 
207: 207: }
208: 208: 