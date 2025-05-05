1: 1: pragma solidity ^0.4.19;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: library SafeMath {
9: 9:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
10: 10:     if (a == 0) {
11: 11:       return 0;
12: 12:     }
13: 13:     uint256 c = a * b;
14: 14:     assert(c / a == b);
15: 15:     return c;
16: 16:   }
17: 17: 
18: 18:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
19: 19:     
20: 20:     uint256 c = a / b;
21: 21:     
22: 22:     return c;
23: 23:   }
24: 24: 
25: 25:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
26: 26:     assert(b <= a);
27: 27:     return a - b;
28: 28:   }
29: 29: 
30: 30:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
31: 31:     uint256 c = a + b;
32: 32:     assert(c >= a);
33: 33:     return c;
34: 34:   }
35: 35: }
36: 36: 
37: 37: 
38: 38: contract PresalePool {
39: 39: 
40: 40:   
41: 41:   
42: 42:   using SafeMath for uint;
43: 43:   
44: 44:   
45: 45:   
46: 46:   
47: 47:   
48: 48:   
49: 49:   uint8 public contractStage = 1;
50: 50:   
51: 51:   
52: 52:   
53: 53:   address public owner;
54: 54:   
55: 55:   uint public contributionMin;
56: 56:   
57: 57:   uint public contractMax;
58: 58:   
59: 59:   uint public feePct;
60: 60:   
61: 61:   address public receiverAddress;
62: 62:   
63: 63:   
64: 64:   
65: 65:   uint public submittedAmount;
66: 66:   
67: 67:   uint public refundPct;
68: 68:   
69: 69:   uint public contributorCount;
70: 70:   
71: 71:   address public activeToken;
72: 72:   
73: 73:   
74: 74:   struct Contributor {
75: 75:     bool refundedEth;
76: 76:     uint balance;
77: 77:     mapping (address => uint) tokensClaimed;
78: 78:   }
79: 79:   
80: 80:   mapping (address => Contributor) contributors;
81: 81:   
82: 82:   
83: 83:   struct TokenAllocation {
84: 84:     ERC20 token;
85: 85:     uint pct;
86: 86:     uint claimRound;
87: 87:     uint claimCount;
88: 88:   }
89: 89:   
90: 90:   mapping (address => TokenAllocation) distribution;
91: 91:   
92: 92:   
93: 93:   
94: 94:   modifier onlyOwner () {
95: 95:     require (msg.sender == owner);
96: 96:     _;
97: 97:   }
98: 98:   
99: 99:   
100: 100:   bool locked;
101: 101:   modifier noReentrancy() {
102: 102:     require(!locked);
103: 103:     locked = true;
104: 104:     _;
105: 105:     locked = false;
106: 106:   }
107: 107:   
108: 108:   event ContributorBalanceChanged (address contributor, uint totalBalance);
109: 109:   event TokensWithdrawn (address receiver, uint amount);
110: 110:   event EthRefunded (address receiver, uint amount);
111: 111:   event ReceiverAddressChanged ( address _addr);
112: 112:   event WithdrawalsOpen (address tokenAddr);
113: 113:   event ERC223Received (address token, uint value);
114: 114:    
115: 115:   
116: 116:   
117: 117:   function _toPct (uint numerator, uint denominator ) internal pure returns (uint) {
118: 118:     return numerator.mul(10 ** 20) / denominator;
119: 119:   }
120: 120:   
121: 121:   
122: 122:   function _applyPct (uint numerator, uint pct) internal pure returns (uint) {
123: 123:     return numerator.mul(pct) / (10 ** 20);
124: 124:   }
125: 125:   
126: 126:   
127: 127:   function PresalePool(address receiver, uint individualMin, uint poolMax, uint fee) public {
128: 128:     require (fee < 100);
129: 129:     require (100000000000000000 <= individualMin);
130: 130:     require (individualMin <= poolMax);
131: 131:     require (receiver != 0x00);
132: 132:     owner = msg.sender;
133: 133:     receiverAddress = receiver;
134: 134:     contributionMin = individualMin;
135: 135:     contractMax = poolMax;
136: 136:     feePct = _toPct(fee,100);
137: 137:   }
138: 138:   
139: 139:   
140: 140:   
141: 141:   function () payable public {
142: 142:     require (contractStage == 1);
143: 143:     require (this.balance <= contractMax);
144: 144:     var c = contributors[msg.sender];
145: 145:     uint newBalance = c.balance.add(msg.value);
146: 146:     require (newBalance >= contributionMin);
147: 147:     if (contributors[msg.sender].balance == 0) {
148: 148:       contributorCount = contributorCount.add(1);
149: 149:     }
150: 150:     contributors[msg.sender].balance = newBalance;
151: 151:     ContributorBalanceChanged(msg.sender, newBalance);
152: 152:   }
153: 153:     
154: 154:   
155: 155:   
156: 156:   
157: 157:   
158: 158:   
159: 159:   function withdraw (address tokenAddr) public {
160: 160:     var c = contributors[msg.sender];
161: 161:     require (c.balance > 0);
162: 162:     if (contractStage < 3) {
163: 163:       uint amountToTransfer = c.balance;
164: 164:       c.balance = 0;
165: 165:       msg.sender.transfer(amountToTransfer);
166: 166:       contributorCount = contributorCount.sub(1);
167: 167:       ContributorBalanceChanged(msg.sender, 0);
168: 168:     } else {
169: 169:       _withdraw(msg.sender,tokenAddr);
170: 170:     }  
171: 171:   }
172: 172:   
173: 173:   
174: 174:   
175: 175:   
176: 176:   function withdrawFor (address contributor, address tokenAddr) public onlyOwner {
177: 177:     require (contractStage == 3);
178: 178:     require (contributors[contributor].balance > 0);
179: 179:     _withdraw(contributor,tokenAddr);
180: 180:   }
181: 181:   
182: 182:   
183: 183:   
184: 184:   function _withdraw (address receiver, address tokenAddr) internal {
185: 185:     assert (contractStage == 3);
186: 186:     var c = contributors[receiver];
187: 187:     if (tokenAddr == 0x00) {
188: 188:       tokenAddr = activeToken;
189: 189:     }
190: 190:     var d = distribution[tokenAddr];
191: 191:     require ( (refundPct > 0 && !c.refundedEth) || d.claimRound > c.tokensClaimed[tokenAddr] );
192: 192:     if (refundPct > 0 && !c.refundedEth) {
193: 193:       uint ethAmount = _applyPct(c.balance,refundPct);
194: 194:       c.refundedEth = true;
195: 195:       if (ethAmount == 0) return;
196: 196:       if (ethAmount+10 > c.balance) {
197: 197:         ethAmount = c.balance-10;
198: 198:       }
199: 199:       c.balance = c.balance.sub(ethAmount+10);
200: 200:       receiver.transfer(ethAmount);
201: 201:       EthRefunded(receiver,ethAmount);
202: 202:     }
203: 203:     if (d.claimRound > c.tokensClaimed[tokenAddr]) {
204: 204:       uint amount = _applyPct(c.balance,d.pct);
205: 205:       c.tokensClaimed[tokenAddr] = d.claimRound;
206: 206:       d.claimCount = d.claimCount.add(1);
207: 207:       if (amount > 0) {
208: 208:         require (d.token.transfer(receiver,amount));
209: 209:       }
210: 210:       TokensWithdrawn(receiver,amount);
211: 211:     }
212: 212:   }
213: 213:   
214: 214:   
215: 215:   
216: 216:   function modifyMaxContractBalance (uint amount) public onlyOwner {
217: 217:     require (contractStage < 3);
218: 218:     require (amount >= contributionMin);
219: 219:     require (amount >= this.balance);
220: 220:     contractMax = amount;
221: 221:   }
222: 222:   
223: 223:   
224: 224:   function checkPoolBalance () view public returns (uint poolCap, uint balance, uint remaining) {
225: 225:     return (contractMax,this.balance,contractMax.sub(this.balance));
226: 226:   }
227: 227:   
228: 228:   
229: 229:   function checkContributorBalance (address addr) view public returns (uint balance) {
230: 230:     return contributors[addr].balance;
231: 231:   }
232: 232:   
233: 233:   
234: 234:   function checkAvailableTokens (address addr, address tokenAddr) view public returns (uint amount) {
235: 235:     var c = contributors[addr];
236: 236:     var d = distribution[tokenAddr];
237: 237:     if (d.claimRound == c.tokensClaimed[tokenAddr]) return 0;
238: 238:     return _applyPct(c.balance,d.pct);
239: 239:   }
240: 240:   
241: 241:   
242: 242:   
243: 243:   
244: 244:   function closeContributions () public onlyOwner {
245: 245:     require (contractStage == 1);
246: 246:     contractStage = 2;
247: 247:   }
248: 248:   
249: 249:   
250: 250:   
251: 251:   function reopenContributions () public onlyOwner {
252: 252:     require (contractStage == 2);
253: 253:     contractStage = 1;
254: 254:   }
255: 255:   
256: 256:   
257: 257:   
258: 258:   
259: 259:   
260: 260:   function submitPool (uint amountInWei) public onlyOwner noReentrancy {
261: 261:     require (contractStage < 3);
262: 262:     require (contributionMin <= amountInWei && amountInWei <= this.balance);
263: 263:     uint b = this.balance;
264: 264:     require (receiverAddress.call.value(amountInWei).gas(msg.gas.sub(5000))());
265: 265:     submittedAmount = b.sub(this.balance);
266: 266:     refundPct = _toPct(this.balance,b);
267: 267:     contractStage = 3;
268: 268:   }
269: 269:   
270: 270:   
271: 271:   
272: 272:   
273: 273:   
274: 274:   
275: 275:   function enableTokenWithdrawals (address tokenAddr, bool notDefault) public onlyOwner noReentrancy {
276: 276:     require (contractStage == 3);
277: 277:     if (notDefault) {
278: 278:       require (activeToken != 0x00);
279: 279:     } else {
280: 280:       activeToken = tokenAddr;
281: 281:     }
282: 282:     var d = distribution[tokenAddr];
283: 283:     require (d.claimRound == 0 || d.claimCount == contributorCount);
284: 284:     d.token = ERC20(tokenAddr);
285: 285:     uint amount = d.token.balanceOf(this);
286: 286:     require (amount > 0);
287: 287:     if (feePct > 0) {
288: 288:       require (d.token.transfer(owner,_applyPct(amount,feePct)));
289: 289:     }
290: 290:     d.pct = _toPct(d.token.balanceOf(this),submittedAmount);
291: 291:     d.claimCount = 0;
292: 292:     d.claimRound = d.claimRound.add(1);
293: 293:   }
294: 294:   
295: 295:   
296: 296:   function tokenFallback (address from, uint value, bytes data) public {
297: 297:     ERC223Received (from, value);
298: 298:   }
299: 299:   
300: 300: }