1: pragma solidity ^0.4.24;
2: 
3: library SafeMath {
4: 
5:   
6: 
7: 
8:   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
9:     
10:     
11:     
12:     if (a == 0) {
13:       return 0;
14:     }
15: 
16:     c = a * b;
17:     assert(c / a == b);
18:     return c;
19:   }
20: 
21:   
22: 
23: 
24:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
25:     
26:     
27:     
28:     return a / b;
29:   }
30: 
31:   
32: 
33: 
34:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
35:     assert(b <= a);
36:     return a - b;
37:   }
38: 
39:   
40: 
41: 
42:   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
43:     c = a + b;
44:     assert(c >= a);
45:     return c;
46:   }
47: }
48: 
49: contract ERC827Token is ERC827, StandardToken {
50: 
51:   
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
64: 
65: 
66: 
67: 
68:   function approveAndCall(
69:     address _spender,
70:     uint256 _value,
71:     bytes _data
72:   )
73:     public
74:     payable
75:     returns (bool)
76:   {
77:     require(_spender != address(this));
78: 
79:     super.approve(_spender, _value);
80: 
81:     
82:     require(_spender.call.value(msg.value)(_data));
83: 
84:     return true;
85:   }
86: 
87:   
88: 
89: 
90: 
91: 
92: 
93: 
94: 
95: 
96: 
97:   function transferAndCall(
98:     address _to,
99:     uint256 _value,
100:     bytes _data
101:   )
102:     public
103:     payable
104:     returns (bool)
105:   {
106:     require(_to != address(this));
107: 
108:     super.transfer(_to, _value);
109: 
110:     
111:     require(_to.call.value(msg.value)(_data));
112:     return true;
113:   }
114: 
115:   
116: 
117: 
118: 
119: 
120: 
121: 
122: 
123: 
124: 
125: 
126:   function transferFromAndCall(
127:     address _from,
128:     address _to,
129:     uint256 _value,
130:     bytes _data
131:   )
132:     public payable returns (bool)
133:   {
134:     require(_to != address(this));
135: 
136:     super.transferFrom(_from, _to, _value);
137: 
138:     
139:     require(_to.call.value(msg.value)(_data));
140:     return true;
141:   }
142: 
143:   
144: 
145: 
146: 
147: 
148: 
149: 
150: 
151: 
152: 
153: 
154: 
155: 
156:   function increaseApprovalAndCall(
157:     address _spender,
158:     uint _addedValue,
159:     bytes _data
160:   )
161:     public
162:     payable
163:     returns (bool)
164:   {
165:     require(_spender != address(this));
166: 
167:     super.increaseApproval(_spender, _addedValue);
168: 
169:     
170:     require(_spender.call.value(msg.value)(_data));
171: 
172:     return true;
173:   }
174: 
175:   
176: 
177: 
178: 
179: 
180: 
181: 
182: 
183: 
184: 
185: 
186: 
187: 
188:   function decreaseApprovalAndCall(
189:     address _spender,
190:     uint _subtractedValue,
191:     bytes _data
192:   )
193:     public
194:     payable
195:     returns (bool)
196:   {
197:     require(_spender != address(this));
198: 
199:     super.decreaseApproval(_spender, _subtractedValue);
200: 
201:     
202:     require(_spender.call.value(msg.value)(_data));
203: 
204:     return true;
205:   }
206: 
207: }
208: 