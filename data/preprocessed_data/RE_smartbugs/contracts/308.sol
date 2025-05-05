1: 1: 
2: 2: pragma solidity ^0.4.20;
3: 3: 
4: 4: 
5: 5: interface tokenRecipient {
6: 6:   function receiveApproval( address from, uint256 value, bytes data ) external;
7: 7: }
8: 8: 
9: 9: 
10: 10: interface ContractReceiver {
11: 11:   function tokenFallback( address from, uint value, bytes data ) external;
12: 12: }
13: 13: 
14: 14: contract MONIToken is owned {
15: 15: 
16: 16:   string  public name;
17: 17:   string  public symbol;
18: 18:   uint8   public decimals;
19: 19:   uint256 public totalSupply;
20: 20:  
21: 21: 
22: 22:   uint256 public noTransferBefore;
23: 23: 
24: 24:   mapping( address => uint256 ) balances_;
25: 25:   mapping( address => mapping(address => uint256) ) allowances_;
26: 26: 
27: 27:   
28: 28:   event Approval( address indexed owner,
29: 29:                   address indexed spender,
30: 30:                   uint value );
31: 31: 
32: 32:   
33: 33:   
34: 34: 
35: 35:   event Transfer( address indexed from,
36: 36:                   address indexed to,
37: 37:                   uint256 value );
38: 38:                   
39: 39: 
40: 40:   
41: 41:   event Burn( address indexed from,
42: 42:               uint256 value );
43: 43: 
44: 44:   function MONIToken( uint8 _decimals,
45: 45:                           
46: 46:                           string _name,
47: 47:                           string _symbol,
48: 48:                           uint256 _noTransferBefore 
49: 49:   ) public {
50: 50: 
51: 51:     decimals = uint8(_decimals); 
52: 52:   
53: 53:     totalSupply = 0;
54: 54: 
55: 55:     name = _name;
56: 56:     symbol = _symbol;
57: 57:     noTransferBefore = _noTransferBefore;
58: 58:   }
59: 59: 
60: 60:   function mine( uint256 qty ) public onlyOwner {
61: 61:     require (    (totalSupply + qty) > totalSupply  );
62: 62: 
63: 63:     totalSupply += qty;
64: 64:     balances_[owner] += qty;
65: 65:     emit Transfer( address(0), owner, qty );
66: 66:   }
67: 67: 
68: 68: 
69: 69: 
70: 70: 
71: 71: 
72: 72:   
73: 73:   function balanceOf( address owner ) public constant returns (uint) {
74: 74:     return balances_[owner];
75: 75:   }
76: 76: 
77: 77:   
78: 78:   function approve( address spender, uint256 value ) public
79: 79:   returns (bool success)
80: 80:   {
81: 81:     
82: 82:     
83: 83:     
84: 84:     
85: 85: 
86: 86:     allowances_[msg.sender][spender] = value;
87: 87:     emit Approval( msg.sender, spender, value );
88: 88:     return true;
89: 89:   }
90: 90: 
91: 91:   
92: 92:   function safeApprove( address _spender,
93: 93:                         uint256 _currentValue,
94: 94:                         uint256 _value ) public
95: 95:   returns (bool success)
96: 96:   {
97: 97:     
98: 98:     
99: 99: 
100: 100:     if (allowances_[msg.sender][_spender] == _currentValue)
101: 101:       return approve(_spender, _value);
102: 102: 
103: 103:     return false;
104: 104:   }
105: 105: 
106: 106:   
107: 107:   function allowance( address owner, address spender ) public constant
108: 108:   returns (uint256 remaining)
109: 109:   {
110: 110:     return allowances_[owner][spender];
111: 111:   }
112: 112: 
113: 113:   
114: 114:   function transfer(address to, uint256 value) public
115: 115:   returns (bool success)
116: 116:   {
117: 117:     bytes memory empty; 
118: 118:     _transfer( msg.sender, to, value, empty );
119: 119:     return true;
120: 120:   }
121: 121: 
122: 122:   
123: 123:   function transferFrom( address from, address to, uint256 value ) public
124: 124:   returns (bool success)
125: 125:   {
126: 126:     require( value <= allowances_[from][msg.sender] );
127: 127: 
128: 128:     allowances_[from][msg.sender] -= value;
129: 129:     bytes memory empty;
130: 130:     _transfer( from, to, value, empty );
131: 131: 
132: 132:     return true;
133: 133:   }
134: 134: 
135: 135:   
136: 136:   function approveAndCall( address spender,
137: 137:                            uint256 value,
138: 138:                            bytes context ) public
139: 139:   returns (bool success)
140: 140:   {
141: 141:     if ( approve(spender, value) )
142: 142:     {
143: 143:       tokenRecipient recip = tokenRecipient( spender );
144: 144: 
145: 145:       if (isContract(recip))
146: 146:         recip.receiveApproval( msg.sender, value, context );
147: 147: 
148: 148:       return true;
149: 149:     }
150: 150: 
151: 151:     return false;
152: 152:   }
153: 153: 
154: 154:   
155: 155:   function burn( uint256 value ) public
156: 156:   returns (bool success)
157: 157:   {
158: 158:     require( balances_[msg.sender] >= value );
159: 159:     balances_[msg.sender] -= value;
160: 160:     totalSupply -= value;
161: 161: 
162: 162:     emit Burn( msg.sender, value );
163: 163:     return true;
164: 164:   }
165: 165: 
166: 166:   
167: 167:   function burnFrom( address from, uint256 value ) public
168: 168:   returns (bool success)
169: 169:   {
170: 170:     require( balances_[from] >= value );
171: 171:     require( value <= allowances_[from][msg.sender] );
172: 172: 
173: 173:     balances_[from] -= value;
174: 174:     allowances_[from][msg.sender] -= value;
175: 175:     totalSupply -= value;
176: 176: 
177: 177:     emit Burn( from, value );
178: 178:     return true;
179: 179:   }
180: 180: 
181: 181:   
182: 182:   function transfer( address to,
183: 183:                      uint value,
184: 184:                      bytes data,
185: 185:                      string custom_fallback ) public returns (bool success)
186: 186:   {
187: 187:     _transfer( msg.sender, to, value, data );
188: 188: 
189: 189:     
190: 190:     require( address(to).call.value(0)(bytes4(keccak256(custom_fallback)),
191: 191:              msg.sender,
192: 192:              value,
193: 193:              data) );
194: 194: 
195: 195:     return true;
196: 196:   }
197: 197: 
198: 198:   
199: 199:   function transfer( address to, uint value, bytes data ) public
200: 200:   returns (bool success)
201: 201:   {
202: 202:     if (isContract(to)) {
203: 203:       return transferToContract( to, value, data );
204: 204:     }
205: 205: 
206: 206:     _transfer( msg.sender, to, value, data );
207: 207:     return true;
208: 208:   }
209: 209: 
210: 210:   
211: 211:   function transferToContract( address to, uint value, bytes data ) private
212: 212:   returns (bool success)
213: 213:   {
214: 214:     _transfer( msg.sender, to, value, data );
215: 215: 
216: 216:     ContractReceiver rx = ContractReceiver(to);
217: 217: 
218: 218:     if (isContract(rx)) {
219: 219:       rx.tokenFallback( msg.sender, value, data );
220: 220:       return true;
221: 221:     }
222: 222: 
223: 223:     return false;
224: 224:   }
225: 225: 
226: 226:   
227: 227:   function isContract( address _addr ) private constant returns (bool)
228: 228:   {
229: 229:     uint length;
230: 230:     assembly { length := extcodesize(_addr) }
231: 231:     return (length > 0);
232: 232:   }
233: 233: 
234: 234:   function _transfer( address from,
235: 235:                       address to,
236: 236:                       uint value,
237: 237:                       bytes data ) internal
238: 238:   {
239: 239:     require( to != 0x0 );
240: 240:     require( balances_[from] >= value );
241: 241:     require( balances_[to] + value > balances_[to] ); 
242: 242: 
243: 243:     
244: 244:     if (msg.sender != owner) require( now >= noTransferBefore );
245: 245: 
246: 246:     balances_[from] -= value;
247: 247:     balances_[to] += value;
248: 248: 
249: 249:     bytes memory ignore;
250: 250:     ignore = data;                    
251: 251:     emit Transfer( from, to, value ); 
252: 252:   }
253: 253: }