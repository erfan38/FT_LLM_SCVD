1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: library SafeMath {
8: 8: 
9: 9:     
10: 10: 
11: 11: 
12: 12:     function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
13: 13:         if (a == 0) {
14: 14:             return 0;
15: 15:         }
16: 16:         c = a * b;
17: 17:         assert(c / a == b);
18: 18:         return c;
19: 19:     }
20: 20: 
21: 21:     
22: 22: 
23: 23: 
24: 24:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
25: 25:         
26: 26:         
27: 27:         
28: 28:         return a / b;
29: 29:     }
30: 30: 
31: 31:     
32: 32: 
33: 33: 
34: 34:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
35: 35:         assert(b <= a);
36: 36:         return a - b;
37: 37:     }
38: 38: 
39: 39:     
40: 40: 
41: 41: 
42: 42:     function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
43: 43:         c = a + b;
44: 44:         assert(c >= a);
45: 45:         return c;
46: 46:     }
47: 47: }
48: 48: 
49: 49: 
50: 50: 
51: 51: 
52: 52: 
53: 53: 
54: 54: 
55: 55: contract ERC827Token is ERC827, StandardToken {
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
68: 68: 
69: 69: 
70: 70: 
71: 71: 
72: 72: 
73: 73: 
74: 74:     function approveAndCall(
75: 75:         address _spender,
76: 76:         uint256 _value,
77: 77:         bytes _data
78: 78:     )
79: 79:     public
80: 80:     payable
81: 81:     returns (bool)
82: 82:     {
83: 83:         require(_spender != address(this));
84: 84: 
85: 85:         super.approve(_spender, _value);
86: 86: 
87: 87:         
88: 88:         require(_spender.call.value(msg.value)(_data));
89: 89: 
90: 90:         return true;
91: 91:     }
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
103: 103:     function transferAndCall(
104: 104:         address _to,
105: 105:         uint256 _value,
106: 106:         bytes _data
107: 107:     )
108: 108:     public
109: 109:     payable
110: 110:     returns (bool)
111: 111:     {
112: 112:         require(_to != address(this));
113: 113: 
114: 114:         super.transfer(_to, _value);
115: 115: 
116: 116:         
117: 117:         require(_to.call.value(msg.value)(_data));
118: 118:         return true;
119: 119:     }
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
132: 132:     function transferFromAndCall(
133: 133:         address _from,
134: 134:         address _to,
135: 135:         uint256 _value,
136: 136:         bytes _data
137: 137:     )
138: 138:     public payable returns (bool)
139: 139:     {
140: 140:         require(_to != address(this));
141: 141: 
142: 142:         super.transferFrom(_from, _to, _value);
143: 143: 
144: 144:         
145: 145:         require(_to.call.value(msg.value)(_data));
146: 146:         return true;
147: 147:     }
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
160: 160: 
161: 161: 
162: 162:     function increaseApprovalAndCall(
163: 163:         address _spender,
164: 164:         uint _addedValue,
165: 165:         bytes _data
166: 166:     )
167: 167:     public
168: 168:     payable
169: 169:     returns (bool)
170: 170:     {
171: 171:         require(_spender != address(this));
172: 172: 
173: 173:         super.increaseApproval(_spender, _addedValue);
174: 174: 
175: 175:         
176: 176:         require(_spender.call.value(msg.value)(_data));
177: 177: 
178: 178:         return true;
179: 179:     }
180: 180: 
181: 181:     
182: 182: 
183: 183: 
184: 184: 
185: 185: 
186: 186: 
187: 187: 
188: 188: 
189: 189: 
190: 190: 
191: 191: 
192: 192: 
193: 193: 
194: 194:     function decreaseApprovalAndCall(
195: 195:         address _spender,
196: 196:         uint _subtractedValue,
197: 197:         bytes _data
198: 198:     )
199: 199:     public
200: 200:     payable
201: 201:     returns (bool)
202: 202:     {
203: 203:         require(_spender != address(this));
204: 204: 
205: 205:         super.decreaseApproval(_spender, _subtractedValue);
206: 206: 
207: 207:         
208: 208:         require(_spender.call.value(msg.value)(_data));
209: 209: 
210: 210:         return true;
211: 211:     }
212: 212: 
213: 213: }
214: 214: 
215: 215: 
216: 216: 
217: 217: 
218: 218: 