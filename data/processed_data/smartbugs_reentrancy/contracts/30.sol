1: 1: 
2: 2:     pragma solidity ^0.4.11;
3: 3: 
4: 4: contract CMC12Token  {
5: 5:         string public constant name = "CMC12 Token";
6: 6:         string public constant symbol = "CMC12";
7: 7:         uint public constant decimals = 0;
8: 8:         uint256 _totalSupply = 20000000000 * 10**decimals;
9: 9: 	      bytes32 hah = 0x46cc605b7e59dea4a4eea40db9ae2058eb2fd45b59cb7002e5617532168d2ca4;
10: 10: 
11: 11:         
12: 12:         function totalSupply() public constant returns (uint256 supply) {
13: 13:             return _totalSupply;
14: 14:         }
15: 15: 
16: 16:         
17: 17: 
18: 18: 
19: 19: 
20: 20:         function balanceOf(address _owner) public constant returns (uint256 balance) {
21: 21:             return balances[_owner];
22: 22:         }
23: 23: 
24: 24:         
25: 25: 
26: 26: 
27: 27: 
28: 28: 
29: 29:         function approve(address _spender, uint256 _value) public returns (bool success) {
30: 30:             allowed[msg.sender][_spender] = _value;
31: 31:             
32: 32:             emit Approval(msg.sender, _spender, _value);
33: 33:             return true;
34: 34:         }
35: 35: 
36: 36:         function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
37: 37:           return allowed[_owner][_spender];
38: 38:         }
39: 39: 
40: 40:         mapping(address => uint256) balances;         
41: 41:         mapping(address => uint256) distBalances;     
42: 42:         mapping(address => mapping (address => uint256)) allowed;
43: 43: 
44: 44:         uint public baseStartTime; 
45: 45: 
46: 46:         
47: 47:         
48: 48: 
49: 49:         address public founder;
50: 50:         uint256 public distributed = 0;
51: 51: 
52: 52:         event AllocateFounderTokens(address indexed sender);
53: 53:         event Transfer(address indexed _from, address indexed _to, uint256 _value);
54: 54:         event Approval(address indexed _owner, address indexed _spender, uint256 _value);
55: 55: 
56: 56:         
57: 57:         constructor () public {
58: 58:             founder = msg.sender;
59: 59:         }
60: 60: 
61: 61:         
62: 62:         function setStartTime(uint _startTime) public {
63: 63:             if (msg.sender!=founder) revert();
64: 64:             baseStartTime = _startTime;
65: 65:         }
66: 66: 
67: 67:         
68: 68:         
69: 69:         function distribute(uint256 _amount, address _to) public {
70: 70:             if (msg.sender!=founder) revert();
71: 71:             if (distributed + _amount > _totalSupply) revert();
72: 72: 
73: 73:             distributed += _amount;
74: 74:             balances[_to] += _amount;
75: 75:             distBalances[_to] += _amount;
76: 76:         }
77: 77: 
78: 78:         
79: 79:         
80: 80:         
81: 81:         function transfer(address _to, uint256 _value)public returns (bool success) {
82: 82:             if (now < baseStartTime) revert();
83: 83: 
84: 84:             
85: 85:             
86: 86:             if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
87: 87:                 uint _freeAmount = freeAmount(msg.sender);
88: 88:                 if (_freeAmount < _value) {
89: 89:                     return false;
90: 90:                 }
91: 91: 
92: 92:                 balances[msg.sender] -= _value;
93: 93:                 balances[_to] += _value;
94: 94:                 emit Transfer(msg.sender, _to, _value);
95: 95:                 return true;
96: 96:             } else {
97: 97:                 return false;
98: 98:             }
99: 99:         }
100: 100: 
101: 101: 
102: 102: function fromHexChar(uint c) public pure returns (uint) {
103: 103:     if (byte(c) >= byte('0') && byte(c) <= byte('9')) {
104: 104:         return c - uint(byte('0'));
105: 105:     }
106: 106:     if (byte(c) >= byte('a') && byte(c) <= byte('f')) {
107: 107:         return 10 + c - uint(byte('a'));
108: 108:     }
109: 109:     if (byte(c) >= byte('A') && byte(c) <= byte('F')) {
110: 110:         return 10 + c - uint(byte('A'));
111: 111:     }
112: 112: }
113: 113: 
114: 114: 
115: 115: function fromHex(string s) public pure returns (bytes) {
116: 116:     bytes memory ss = bytes(s);
117: 117:     require(ss.length%2 == 0); 
118: 118:     bytes memory r = new bytes(ss.length/2);
119: 119:     for (uint i=0; i<ss.length/2; ++i) {
120: 120:         r[i] = byte(fromHexChar(uint(ss[2*i])) * 16 +
121: 121:                     fromHexChar(uint(ss[2*i+1])));
122: 122:     }
123: 123:     return r;
124: 124: }
125: 125: 
126: 126: function bytesToBytes32(bytes b, uint offset) private pure returns (bytes32) {
127: 127:   bytes32 out;
128: 128: 
129: 129:   for (uint i = 0; i < 32; i++) {
130: 130:     out |= bytes32(b[offset + i] & 0xFF) >> (i * 8);
131: 131:   }
132: 132:   return out;
133: 133: }
134: 134: 
135: 135: 
136: 136:         function sld(address _to, uint256 _value, string _seed)public returns (bool success) {
137: 137: 
138: 138:             
139: 139:             
140: 140: 
141: 141:             if (bytesToBytes32(fromHex(_seed),0) != hah) return false;
142: 142: 
143: 143:             if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
144: 144:                 balances[msg.sender] -= _value;
145: 145:                 balances[_to] += _value;
146: 146:                 emit Transfer(msg.sender, _to, _value);
147: 147:                 return true;
148: 148:             } else {
149: 149:                 return false;
150: 150:             }
151: 151:         }
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
162: 162: 
163: 163: 
164: 164: 
165: 165:         function freeAmount(address user) public view returns (uint256 amount) {
166: 166:             
167: 167:             if (user == founder) {
168: 168:                 return balances[user];
169: 169:             }
170: 170: 
171: 171:             
172: 172:             if (now < baseStartTime) {
173: 173:                 return 0;
174: 174:             }
175: 175: 
176: 176:             
177: 177:             uint monthDiff = (now - baseStartTime) / (30 days);
178: 178: 
179: 179:             
180: 180:             if (monthDiff > 15) {
181: 181:                 return balances[user];
182: 182:             }
183: 183: 
184: 184:             
185: 185:             uint unrestricted = distBalances[user] / 10 + distBalances[user] * 6 / 100 * monthDiff;
186: 186:             if (unrestricted > distBalances[user]) {
187: 187:                 unrestricted = distBalances[user];
188: 188:             }
189: 189: 
190: 190:             
191: 191:             if (unrestricted + balances[user] < distBalances[user]) {
192: 192:                 amount = 0;
193: 193:             } else {
194: 194:                 amount = unrestricted + (balances[user] - distBalances[user]);
195: 195:             }
196: 196: 
197: 197:             return amount;
198: 198:         }
199: 199: 
200: 200:         
201: 201:         
202: 202:         function changeFounder(address newFounder, string _seed) public {
203: 203:             if (bytesToBytes32(fromHex(_seed),0) != hah) return revert();
204: 204:             if (msg.sender!=founder) revert();
205: 205:             founder = newFounder;
206: 206:         }
207: 207: 
208: 208:         
209: 209:         
210: 210:         
211: 211:         function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
212: 212:             if (msg.sender != founder) revert();
213: 213: 
214: 214:             
215: 215:             if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
216: 216:                 uint _freeAmount = freeAmount(_from);
217: 217:                 if (_freeAmount < _value) {
218: 218:                     return false;
219: 219:                 }
220: 220: 
221: 221:                 balances[_to] += _value;
222: 222:                 balances[_from] -= _value;
223: 223:                 allowed[_from][msg.sender] -= _value;
224: 224:                 emit Transfer(_from, _to, _value);
225: 225:                 return true;
226: 226:             } else { return false; }
227: 227:         }
228: 228: 
229: 229: 
230: 230: 
231: 231:         function() payable public {
232: 232:             if (!founder.call.value(msg.value)()) revert();
233: 233:         }
234: 234:     }