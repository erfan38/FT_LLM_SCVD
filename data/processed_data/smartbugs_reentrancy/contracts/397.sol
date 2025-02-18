1: 1: pragma solidity ^0.4.23;
2: 2: 
3: 3: 
4: 4: library SafeMath {
5: 5:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
6: 6:         if (a == 0) {
7: 7:             return 0;
8: 8:         }
9: 9:         uint256 c = a * b;
10: 10:         assert(c / a == b);
11: 11:         return c;
12: 12:     }
13: 13: 
14: 14:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
15: 15:         uint256 c = a / b;
16: 16:         return c;
17: 17:     }
18: 18: 
19: 19:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
20: 20:         assert(b <= a);
21: 21:         return a - b;
22: 22:     }
23: 23: 
24: 24:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
25: 25:         uint256 c = a + b;
26: 26:         assert(c >= a);
27: 27:         return c;
28: 28:     }
29: 29: }
30: 30: 
31: 31: 
32: 32: 
33: 33: contract YOKOCHOCOIN is ERC223, Ownable {
34: 34:     using SafeMath for uint256;
35: 35: 
36: 36:     string public name = "Yokocho coin";
37: 37:     string public symbol = "YOKOCHO";
38: 38:     uint8 public decimals = 16;
39: 39:     uint256 public totalSupply;
40: 40: 
41: 41:     uint public chainStartTime; 
42: 42:     uint public chainStartBlockNumber; 
43: 43:     uint public stakeStartTime; 
44: 44:     uint public stakeMinAge = 3 days; 
45: 45:     uint public stakeMaxAge = 90 days; 
46: 46: 
47: 47:     uint256 public maxTotalSupply = 45e9 * 1e16;
48: 48:     uint256 public initialTotalSupply = 20e9 * 1e16;
49: 49: 
50: 50:     struct transferInStruct{
51: 51:       uint256 amount;
52: 52:       uint64 time;
53: 53:     }
54: 54: 
55: 55:     address public admin = 0xF773323FF8ae778E361dCdECCE61c08abfDF2A71;
56: 56:     address public presale = 0x0c1688278814D6D5f1b4cFF9A7380BB6299Ab69E;
57: 57:     address public develop = 0xBbc014cB376811B85AA36188e06BdD25dEaCa0aE;
58: 58:     address public pr = 0x751e6dBdCd7e644EDebf8B056DFb9C7b6F02C765;
59: 59:     address public manage = 0x8617F0e63728E1e7105b9b44912Eb1A253e0056C;
60: 60: 
61: 61:     mapping(address => uint256) public balanceOf;
62: 62:     mapping(address => mapping (address => uint256)) public allowance;
63: 63:     mapping(address => transferInStruct[]) public transferIns;
64: 64: 
65: 65:     event Burn(address indexed burner, uint256 value);
66: 66:     event PosMint(address indexed _address, uint _reward);
67: 67: 
68: 68:     constructor () public {
69: 69:         owner = admin;
70: 70:         totalSupply = initialTotalSupply;
71: 71:         balanceOf[owner] = totalSupply;
72: 72: 
73: 73:         chainStartTime = now;
74: 74:         chainStartBlockNumber = block.number;
75: 75:     }
76: 76: 
77: 77:     function name() public view returns (string _name) {
78: 78:         return name;
79: 79:     }
80: 80: 
81: 81:     function symbol() public view returns (string _symbol) {
82: 82:         return symbol;
83: 83:     }
84: 84: 
85: 85:     function decimals() public view returns (uint8 _decimals) {
86: 86:         return decimals;
87: 87:     }
88: 88: 
89: 89:     function totalSupply() public view returns (uint256 _totalSupply) {
90: 90:         return totalSupply;
91: 91:     }
92: 92: 
93: 93:     function balanceOf(address _owner) public view returns (uint256 balance) {
94: 94:         return balanceOf[_owner];
95: 95:     }
96: 96: 
97: 97:     
98: 98:     function transfer(address _to, uint _value) public returns (bool success) {
99: 99:         require(_value > 0);
100: 100: 
101: 101:         bytes memory empty;
102: 102:         if (isContract(_to)) {
103: 103:             return transferToContract(_to, _value, empty);
104: 104:         } else {
105: 105:             return transferToAddress(_to, _value, empty);
106: 106:         }
107: 107:     }
108: 108: 
109: 109:     function transfer(address _to, uint _value, bytes _data) public  returns (bool success) {
110: 110:         require(_value > 0);
111: 111: 
112: 112:         if (isContract(_to)) {
113: 113:             return transferToContract(_to, _value, _data);
114: 114:         } else {
115: 115:             return transferToAddress(_to, _value, _data);
116: 116:         }
117: 117:     }
118: 118: 
119: 119:     function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
120: 120:         require(_value > 0);
121: 121: 
122: 122:         if (isContract(_to)) {
123: 123:             require(balanceOf[msg.sender] >= _value);
124: 124:             balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
125: 125:             balanceOf[_to] = balanceOf[_to].add(_value);
126: 126:             assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
127: 127:             emit Transfer(msg.sender, _to, _value, _data);
128: 128:             emit Transfer(msg.sender, _to, _value);
129: 129: 
130: 130:             if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
131: 131:             uint64 _now = uint64(now);
132: 132:             transferIns[msg.sender].push(transferInStruct(uint256(balanceOf[msg.sender]),_now));
133: 133:             transferIns[_to].push(transferInStruct(uint256(_value),_now));
134: 134: 
135: 135:             return true;
136: 136:         } else {
137: 137:             return transferToAddress(_to, _value, _data);
138: 138:         }
139: 139:     }
140: 140: 
141: 141:     
142: 142:     function isContract(address _addr) private view returns (bool is_contract) {
143: 143:         uint length;
144: 144:         assembly {
145: 145:             
146: 146:             length := extcodesize(_addr)
147: 147:         }
148: 148:         return (length > 0);
149: 149:     }
150: 150: 
151: 151:     
152: 152:     function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
153: 153:         require(balanceOf[msg.sender] >= _value);
154: 154:         balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
155: 155:         balanceOf[_to] = balanceOf[_to].add(_value);
156: 156:         emit Transfer(msg.sender, _to, _value, _data);
157: 157:         emit Transfer(msg.sender, _to, _value);
158: 158: 
159: 159:         if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
160: 160:         uint64 _now = uint64(now);
161: 161:         transferIns[msg.sender].push(transferInStruct(uint256(balanceOf[msg.sender]),_now));
162: 162:         transferIns[_to].push(transferInStruct(uint256(_value),_now));
163: 163: 
164: 164:         return true;
165: 165:     }
166: 166: 
167: 167:     
168: 168:     function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
169: 169:         require(balanceOf[msg.sender] >= _value);
170: 170:         balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
171: 171:         balanceOf[_to] = balanceOf[_to].add(_value);
172: 172:         ContractReceiver receiver = ContractReceiver(_to);
173: 173:         receiver.tokenFallback(msg.sender, _value, _data);
174: 174:         emit Transfer(msg.sender, _to, _value, _data);
175: 175:         emit Transfer(msg.sender, _to, _value);
176: 176: 
177: 177:         if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
178: 178:         uint64 _now = uint64(now);
179: 179:         transferIns[msg.sender].push(transferInStruct(uint256(balanceOf[msg.sender]),_now));
180: 180:         transferIns[_to].push(transferInStruct(uint256(_value),_now));
181: 181: 
182: 182:         return true;
183: 183:     }
184: 184: 
185: 185:     
186: 186:     function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
187: 187:         require(_to != address(0)
188: 188:                 && _value > 0
189: 189:                 && balanceOf[_from] >= _value
190: 190:                 && allowance[_from][msg.sender] >= _value);
191: 191: 
192: 192:         balanceOf[_from] = balanceOf[_from].sub(_value);
193: 193:         balanceOf[_to] = balanceOf[_to].add(_value);
194: 194:         allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
195: 195:         emit Transfer(_from, _to, _value);
196: 196: 
197: 197:         if(transferIns[_from].length > 0) delete transferIns[_from];
198: 198:         uint64 _now = uint64(now);
199: 199:         transferIns[_from].push(transferInStruct(uint256(balanceOf[_from]),_now));
200: 200:         transferIns[_to].push(transferInStruct(uint256(_value),_now));
201: 201: 
202: 202:         return true;
203: 203:     }
204: 204: 
205: 205:     
206: 206:     function approve(address _spender, uint256 _value) public returns (bool success) {
207: 207:         allowance[msg.sender][_spender] = _value;
208: 208:         emit Approval(msg.sender, _spender, _value);
209: 209:         return true;
210: 210:     }
211: 211: 
212: 212:     
213: 213:     function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
214: 214:         return allowance[_owner][_spender];
215: 215:     }
216: 216: 
217: 217:     
218: 218:     function airdrop(address[] addresses, uint[] amounts) public returns (bool) {
219: 219:         require(addresses.length > 0
220: 220:                 && addresses.length == amounts.length);
221: 221: 
222: 222:         uint256 totalAmount = 0;
223: 223: 
224: 224:         for(uint j = 0; j < addresses.length; j++){
225: 225:             require(amounts[j] > 0
226: 226:                     && addresses[j] != 0x0);
227: 227: 
228: 228:             amounts[j] = amounts[j].mul(1e16);
229: 229:             totalAmount = totalAmount.add(amounts[j]);
230: 230:         }
231: 231:         require(balanceOf[msg.sender] >= totalAmount);
232: 232: 
233: 233:         uint64 _now = uint64(now);
234: 234:         for (j = 0; j < addresses.length; j++) {
235: 235:             balanceOf[addresses[j]] = balanceOf[addresses[j]].add(amounts[j]);
236: 236:             emit Transfer(msg.sender, addresses[j], amounts[j]);
237: 237: 
238: 238:             transferIns[addresses[j]].push(transferInStruct(uint256(amounts[j]),_now));
239: 239:         }
240: 240:         balanceOf[msg.sender] = balanceOf[msg.sender].sub(totalAmount);
241: 241: 
242: 242:         if(transferIns[msg.sender].length > 0) delete transferIns[msg.sender];
243: 243:         if(balanceOf[msg.sender] > 0) transferIns[msg.sender].push(transferInStruct(uint256(balanceOf[msg.sender]),_now));
244: 244: 
245: 245:         return true;
246: 246:     }
247: 247: 
248: 248:     function setStakeStartTime(uint timestamp) onlyOwner public {
249: 249:         require((stakeStartTime <= 0) && (timestamp >= chainStartTime));
250: 250:         stakeStartTime = timestamp;
251: 251:     }
252: 252: 
253: 253:     function ownerBurnToken(uint _value) onlyOwner public {
254: 254:         require(_value > 0);
255: 255: 
256: 256:         balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
257: 257:         delete transferIns[msg.sender];
258: 258:         transferIns[msg.sender].push(transferInStruct(uint128(balanceOf[msg.sender]),uint64(now)));
259: 259: 
260: 260:         totalSupply = totalSupply.sub(_value);
261: 261:         initialTotalSupply = initialTotalSupply.sub(_value);
262: 262:         maxTotalSupply = maxTotalSupply.sub(_value*10);
263: 263: 
264: 264:         emit Burn(msg.sender, _value);
265: 265:     }
266: 266: 
267: 267:     function getBlockNumber() constant public returns (uint blockNumber) {
268: 268:         blockNumber = block.number.sub(chainStartBlockNumber);
269: 269:     }
270: 270: 
271: 271:     modifier canPoSMint() {
272: 272:         require(totalSupply < maxTotalSupply);
273: 273:         _;
274: 274:     }
275: 275: 
276: 276:     function posMint() canPoSMint public returns (bool) {
277: 277:         if(balanceOf[msg.sender] <= 0) return false;
278: 278:         if(transferIns[msg.sender].length <= 0) return false;
279: 279: 
280: 280:         uint reward = getReward(msg.sender);
281: 281:         if(reward <= 0) return false;
282: 282: 
283: 283:         totalSupply = totalSupply.add(reward);
284: 284:         balanceOf[msg.sender] = balanceOf[msg.sender].add(reward);
285: 285:         delete transferIns[msg.sender];
286: 286:         transferIns[msg.sender].push(transferInStruct(uint256(balanceOf[msg.sender]),uint64(now)));
287: 287: 
288: 288:         emit PosMint(msg.sender, reward);
289: 289:         return true;
290: 290:     }
291: 291: 
292: 292:     function coinAge() constant public returns (uint myCoinAge) {
293: 293:         myCoinAge = getCoinAge(msg.sender,now);
294: 294:     }
295: 295: 
296: 296:     function getCoinAge(address _address, uint _now) internal view returns (uint _coinAge) {
297: 297:         if(transferIns[_address].length <= 0) return 0;
298: 298: 
299: 299:         for (uint i = 0; i < transferIns[_address].length; i++){
300: 300:             if( _now < uint(transferIns[_address][i].time).add(stakeMinAge) ) continue;
301: 301: 
302: 302:             uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));
303: 303:             if( nCoinSeconds > stakeMaxAge ) nCoinSeconds = stakeMaxAge;
304: 304: 
305: 305:             _coinAge = _coinAge.add(uint(transferIns[_address][i].amount).mul(nCoinSeconds).div(1 days));
306: 306:         }
307: 307:     }
308: 308: 
309: 309:     function getReward(address _address) internal view returns (uint reward) {
310: 310:         require( (now >= stakeStartTime) && (stakeStartTime > 0) );
311: 311: 
312: 312:         uint64 _now = uint64(now);
313: 313:         uint _coinAge = getCoinAge(_address, _now);
314: 314:         if(_coinAge <= 0) return 0;
315: 315: 
316: 316:         reward = _coinAge.mul(45).div(1000).div(365);
317: 317:         return reward;
318: 318:     }
319: 319: 
320: 320: }