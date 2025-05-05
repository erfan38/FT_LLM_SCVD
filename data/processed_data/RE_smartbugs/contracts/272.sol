1: 1: 
2: 2: pragma solidity ^0.4.20;
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: interface tokenRecipient {
8: 8:   function receiveApproval( address from, uint256 value, bytes data ) external;
9: 9: }
10: 10: 
11: 11: 
12: 12: 
13: 13: 
14: 14: interface ContractReceiver {
15: 15:   function tokenFallback( address from, uint value, bytes data ) external;
16: 16: }
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: contract Token is Owned {
22: 22:   string  public name;
23: 23:   string  public symbol;
24: 24:   uint8   public decimals = 18;
25: 25:   uint256 public totalSupply;
26: 26: 
27: 27:   mapping( address => uint256 ) balances;
28: 28:   mapping( address => mapping(address => uint256) ) allowances;
29: 29: 
30: 30:   
31: 31: 
32: 32: 
33: 33:   event Approval(
34: 34:     address indexed owner,
35: 35:     address indexed spender,
36: 36:     uint value
37: 37:   );
38: 38: 
39: 39:   
40: 40: 
41: 41: 
42: 42: 
43: 43:   event Transfer(
44: 44:     address indexed from,
45: 45:     address indexed to,
46: 46:     uint256 value
47: 47:   );
48: 48: 
49: 49:   function Token(
50: 50:     uint256 _initialSupply,
51: 51:     string _tokenName,
52: 52:     string _tokenSymbol
53: 53:   )
54: 54:     public
55: 55:   {
56: 56:     totalSupply = _initialSupply * 10**18;
57: 57:     balances[msg.sender] = _initialSupply * 10**18;
58: 58: 
59: 59:     name = _tokenName;
60: 60:     symbol = _tokenSymbol;
61: 61:   }
62: 62: 
63: 63:   
64: 64: 
65: 65: 
66: 66:   function balanceOf( address owner ) public constant returns (uint) {
67: 67:     return balances[owner];
68: 68:   }
69: 69: 
70: 70:   
71: 71: 
72: 72: 
73: 73:   function approve( address spender, uint256 value ) public returns (bool success) {
74: 74:     
75: 75:     
76: 76:     
77: 77:     
78: 78:     allowances[msg.sender][spender] = value;
79: 79:     Approval( msg.sender, spender, value );
80: 80:     return true;
81: 81:   }
82: 82: 
83: 83:   
84: 84: 
85: 85: 
86: 86:   function safeApprove(
87: 87:     address _spender,
88: 88:     uint256 _currentValue,
89: 89:     uint256 _value
90: 90:   )
91: 91:     public
92: 92:     returns (bool success)
93: 93:   {
94: 94:     
95: 95:     
96: 96: 
97: 97:     if (allowances[msg.sender][_spender] == _currentValue)
98: 98:       return approve(_spender, _value);
99: 99: 
100: 100:     return false;
101: 101:   }
102: 102: 
103: 103:   
104: 104: 
105: 105: 
106: 106:   function allowance(
107: 107:     address owner,
108: 108:     address spender
109: 109:   )
110: 110:     public constant
111: 111:     returns (uint256 remaining)
112: 112:   {
113: 113:     return allowances[owner][spender];
114: 114:   }
115: 115: 
116: 116:   
117: 117: 
118: 118: 
119: 119:   function transfer(
120: 120:     address to,
121: 121:     uint256 value
122: 122:   )
123: 123:     public
124: 124:     returns (bool success)
125: 125:   {
126: 126:     bytes memory empty; 
127: 127:     _transfer( msg.sender, to, value, empty );
128: 128:     return true;
129: 129:   }
130: 130: 
131: 131:   
132: 132: 
133: 133: 
134: 134:   function transferFrom(
135: 135:     address from,
136: 136:     address to,
137: 137:     uint256 value
138: 138:   )
139: 139:     public
140: 140:     returns (bool success)
141: 141:   {
142: 142:     require( value <= allowances[from][msg.sender] );
143: 143: 
144: 144:     allowances[from][msg.sender] -= value;
145: 145:     bytes memory empty;
146: 146:     _transfer( from, to, value, empty );
147: 147: 
148: 148:     return true;
149: 149:   }
150: 150: 
151: 151:   
152: 152: 
153: 153: 
154: 154:   function approveAndCall(
155: 155:     address spender,
156: 156:     uint256 value,
157: 157:     bytes context
158: 158:   )
159: 159:     public
160: 160:     returns (bool success)
161: 161:   {
162: 162:     if (approve(spender, value))
163: 163:     {
164: 164:       tokenRecipient recip = tokenRecipient(spender);
165: 165: 
166: 166:       if (isContract(recip))
167: 167:         recip.receiveApproval(msg.sender, value, context);
168: 168: 
169: 169:       return true;
170: 170:     }
171: 171: 
172: 172:     return false;
173: 173:   }
174: 174: 
175: 175: 
176: 176:   
177: 177: 
178: 178: 
179: 179:   function transfer(
180: 180:     address to,
181: 181:     uint value,
182: 182:     bytes data,
183: 183:     string custom_fallback
184: 184:   )
185: 185:     public
186: 186:     returns (bool success)
187: 187:   {
188: 188:     _transfer( msg.sender, to, value, data );
189: 189: 
190: 190:     
191: 191:     require(
192: 192:       address(to).call.value(0)(
193: 193:         bytes4(keccak256(custom_fallback)),
194: 194:         msg.sender,
195: 195:         value,
196: 196:         data
197: 197:       )
198: 198:     );
199: 199: 
200: 200:     return true;
201: 201:   }
202: 202: 
203: 203:   
204: 204: 
205: 205: 
206: 206:   function transfer(
207: 207:     address to,
208: 208:     uint value,
209: 209:     bytes data
210: 210:   )
211: 211:     public
212: 212:     returns (bool success)
213: 213:   {
214: 214:     if (isContract(to)) {
215: 215:       return transferToContract( to, value, data );
216: 216:     }
217: 217: 
218: 218:     _transfer( msg.sender, to, value, data );
219: 219:     return true;
220: 220:   }
221: 221: 
222: 222:   
223: 223: 
224: 224: 
225: 225:   function transferToContract(
226: 226:     address to,
227: 227:     uint value,
228: 228:     bytes data
229: 229:   )
230: 230:     private
231: 231:     returns (bool success)
232: 232:   {
233: 233:     _transfer( msg.sender, to, value, data );
234: 234: 
235: 235:     ContractReceiver rx = ContractReceiver(to);
236: 236: 
237: 237:     if (isContract(rx)) {
238: 238:       rx.tokenFallback( msg.sender, value, data );
239: 239:       return true;
240: 240:     }
241: 241: 
242: 242:     return false;
243: 243:   }
244: 244: 
245: 245:   
246: 246: 
247: 247: 
248: 248:   function isContract(address _addr)
249: 249:     private
250: 250:     constant
251: 251:     returns (bool)
252: 252:   {
253: 253:     uint length;
254: 254:     assembly { length := extcodesize(_addr) }
255: 255:     return (length > 0);
256: 256:   }
257: 257: 
258: 258:   
259: 259: 
260: 260: 
261: 261:   function _transfer(
262: 262:     address from,
263: 263:     address to,
264: 264:     uint value,
265: 265:     bytes data
266: 266:   )
267: 267:     internal
268: 268:   {
269: 269:     require( to != 0x0 );
270: 270:     require( balances[from] >= value );
271: 271:     require( balances[to] + value > balances[to] ); 
272: 272: 
273: 273:     balances[from] -= value;
274: 274:     balances[to] += value;
275: 275: 
276: 276:     bytes memory ignore;
277: 277:     ignore = data; 
278: 278:     Transfer( from, to, value ); 
279: 279:   }
280: 280: }