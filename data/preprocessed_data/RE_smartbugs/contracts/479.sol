1: 1: pragma solidity ^0.4.19;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: library SafeMath {
8: 8:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
9: 9:     if (a == 0) {
10: 10:       return 0;
11: 11:     }
12: 12:     uint256 c = a * b;
13: 13:     assert(c / a == b);
14: 14:     return c;
15: 15:   }
16: 16: 
17: 17:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
18: 18:     
19: 19:     uint256 c = a / b;
20: 20:     
21: 21:     return c;
22: 22:   }
23: 23: 
24: 24:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
25: 25:     assert(b <= a);
26: 26:     return a - b;
27: 27:   }
28: 28: 
29: 29:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
30: 30:     uint256 c = a + b;
31: 31:     assert(c >= a);
32: 32:     return c;
33: 33:   }
34: 34: }
35: 35: 
36: 36: 
37: 37: contract PresalePool {
38: 38: 
39: 39:   
40: 40:   
41: 41:   using SafeMath for uint;
42: 42:   
43: 43:   
44: 44:   
45: 45:   
46: 46:   
47: 47:   
48: 48:   uint8 public contractStage = 1;
49: 49:   
50: 50:   
51: 51:   
52: 52:   address public owner;
53: 53:   
54: 54:   uint public contributionMin;
55: 55:   
56: 56:   uint[] public contributionCaps;
57: 57:   
58: 58:   uint public feePct;
59: 59:   
60: 60:   address public receiverAddress;
61: 61:   
62: 62:   uint constant public maxGasPrice = 50000000000;
63: 63:   WhiteList public whitelistContract;
64: 64:   
65: 65:   
66: 66:   
67: 67:   uint public finalBalance;
68: 68:   
69: 69:   uint[] public ethRefundAmount;
70: 70:   
71: 71:   address public activeToken;
72: 72:   
73: 73:   
74: 74:   struct Contributor {
75: 75:     bool authorized;
76: 76:     uint ethRefund;
77: 77:     uint balance;
78: 78:     uint cap;
79: 79:     mapping (address => uint) tokensClaimed;
80: 80:   }
81: 81:   
82: 82:   mapping (address => Contributor) whitelist;
83: 83:   
84: 84:   
85: 85:   struct TokenAllocation {
86: 86:     ERC20 token;
87: 87:     uint[] pct;
88: 88:     uint balanceRemaining;
89: 89:   }
90: 90:   
91: 91:   mapping (address => TokenAllocation) distribution;
92: 92:   
93: 93:   
94: 94:   
95: 95:   modifier onlyOwner () {
96: 96:     require (msg.sender == owner);
97: 97:     _;
98: 98:   }
99: 99:   
100: 100:   
101: 101:   bool locked;
102: 102:   modifier noReentrancy() {
103: 103:     require(!locked);
104: 104:     locked = true;
105: 105:     _;
106: 106:     locked = false;
107: 107:   }
108: 108:   
109: 109:   event ContributorBalanceChanged (address contributor, uint totalBalance);
110: 110:   event TokensWithdrawn (address receiver, uint amount);
111: 111:   event EthRefunded (address receiver, uint amount);
112: 112:   event WithdrawalsOpen (address tokenAddr);
113: 113:   event ERC223Received (address token, uint value);
114: 114:   event EthRefundReceived (address sender, uint amount);
115: 115:    
116: 116:   
117: 117:   
118: 118:   function _toPct (uint numerator, uint denominator ) internal pure returns (uint) {
119: 119:     return numerator.mul(10 ** 20) / denominator;
120: 120:   }
121: 121:   
122: 122:   
123: 123:   function _applyPct (uint numerator, uint pct) internal pure returns (uint) {
124: 124:     return numerator.mul(pct) / (10 ** 20);
125: 125:   }
126: 126:   
127: 127:   
128: 128:   
129: 129:   function PresalePool(address receiverAddr, address whitelistAddr, uint individualMin, uint[] capAmounts, uint fee) public {
130: 130:     require (receiverAddr != 0x00);
131: 131:     require (fee < 100);
132: 132:     require (100000000000000000 <= individualMin);
133: 133:     require (capAmounts.length>1 && capAmounts.length<256);
134: 134:     for (uint8 i=1; i<capAmounts.length; i++) {
135: 135:       require (capAmounts[i] <= capAmounts[0]);
136: 136:     }
137: 137:     owner = msg.sender;
138: 138:     receiverAddress = receiverAddr;
139: 139:     contributionMin = individualMin;
140: 140:     contributionCaps = capAmounts;
141: 141:     feePct = _toPct(fee,100);
142: 142:     whitelistContract = WhiteList(whitelistAddr);
143: 143:     whitelist[msg.sender].authorized = true;
144: 144:   }
145: 145:   
146: 146:   
147: 147:   
148: 148:   
149: 149:   function () payable public {
150: 150:     if (contractStage == 1) {
151: 151:       _ethDeposit();
152: 152:     } else if (contractStage == 3) {
153: 153:       _ethRefund();
154: 154:     } else revert();
155: 155:   }
156: 156:   
157: 157:   function _ethDeposit () internal {
158: 158:     assert (contractStage == 1);
159: 159:     require (tx.gasprice <= maxGasPrice);
160: 160:     require (this.balance <= contributionCaps[0]);
161: 161:     var c = whitelist[msg.sender];
162: 162:     uint newBalance = c.balance.add(msg.value);
163: 163:     require (newBalance >= contributionMin);
164: 164:     require (newBalance <= _checkCap(msg.sender));
165: 165:     c.balance = newBalance;
166: 166:     ContributorBalanceChanged(msg.sender, newBalance);
167: 167:   }
168: 168:   
169: 169:   
170: 170:   function _ethRefund () internal {
171: 171:     assert (contractStage == 3);
172: 172:     require (msg.sender == owner || msg.sender == receiverAddress);
173: 173:     require (msg.value >= contributionMin);
174: 174:     ethRefundAmount.push(msg.value);
175: 175:     EthRefundReceived(msg.sender, msg.value);
176: 176:   }
177: 177:   
178: 178:     
179: 179:   
180: 180:   
181: 181:   
182: 182:   
183: 183:   
184: 184:   function withdraw (address tokenAddr) public {
185: 185:     var c = whitelist[msg.sender];
186: 186:     require (c.balance > 0);
187: 187:     if (contractStage < 3) {
188: 188:       uint amountToTransfer = c.balance;
189: 189:       c.balance = 0;
190: 190:       msg.sender.transfer(amountToTransfer);
191: 191:       ContributorBalanceChanged(msg.sender, 0);
192: 192:     } else {
193: 193:       _withdraw(msg.sender,tokenAddr);
194: 194:     }  
195: 195:   }
196: 196:   
197: 197:   
198: 198:   
199: 199:   
200: 200:   function withdrawFor (address contributor, address tokenAddr) public onlyOwner {
201: 201:     require (contractStage == 3);
202: 202:     require (whitelist[contributor].balance > 0);
203: 203:     _withdraw(contributor,tokenAddr);
204: 204:   }
205: 205:   
206: 206:   
207: 207:   
208: 208:   function _withdraw (address receiver, address tokenAddr) internal {
209: 209:     assert (contractStage == 3);
210: 210:     var c = whitelist[receiver];
211: 211:     if (tokenAddr == 0x00) {
212: 212:       tokenAddr = activeToken;
213: 213:     }
214: 214:     var d = distribution[tokenAddr];
215: 215:     require ( (ethRefundAmount.length > c.ethRefund) || d.pct.length > c.tokensClaimed[tokenAddr] );
216: 216:     if (ethRefundAmount.length > c.ethRefund) {
217: 217:       uint pct = _toPct(c.balance,finalBalance);
218: 218:       uint ethAmount = 0;
219: 219:       for (uint i=c.ethRefund; i<ethRefundAmount.length; i++) {
220: 220:         ethAmount = ethAmount.add(_applyPct(ethRefundAmount[i],pct));
221: 221:       }
222: 222:       c.ethRefund = ethRefundAmount.length;
223: 223:       if (ethAmount > 0) {
224: 224:         receiver.transfer(ethAmount);
225: 225:         EthRefunded(receiver,ethAmount);
226: 226:       }
227: 227:     }
228: 228:     if (d.pct.length > c.tokensClaimed[tokenAddr]) {
229: 229:       uint tokenAmount = 0;
230: 230:       for (i=c.tokensClaimed[tokenAddr]; i<d.pct.length; i++) {
231: 231:         tokenAmount = tokenAmount.add(_applyPct(c.balance,d.pct[i]));
232: 232:       }
233: 233:       c.tokensClaimed[tokenAddr] = d.pct.length;
234: 234:       if (tokenAmount > 0) {
235: 235:         require(d.token.transfer(receiver,tokenAmount));
236: 236:         d.balanceRemaining = d.balanceRemaining.sub(tokenAmount);
237: 237:         TokensWithdrawn(receiver,tokenAmount);
238: 238:       }  
239: 239:     }
240: 240:     
241: 241:   }
242: 242:   
243: 243:   
244: 244:   
245: 245:   
246: 246:   function authorize (address addr, uint cap) public onlyOwner {
247: 247:     require (contractStage == 1);
248: 248:     _checkWhitelistContract(addr);
249: 249:     require (!whitelist[addr].authorized);
250: 250:     require ((cap > 0 && cap < contributionCaps.length) || (cap >= contributionMin && cap <= contributionCaps[0]) );
251: 251:     uint size;
252: 252:     assembly { size := extcodesize(addr) }
253: 253:     require (size == 0);
254: 254:     whitelist[addr].cap = cap;
255: 255:     whitelist[addr].authorized = true;
256: 256:   }
257: 257:   
258: 258:   
259: 259:   
260: 260:   function authorizeMany (address[] addr, uint cap) public onlyOwner {
261: 261:     require (addr.length < 255);
262: 262:     require (cap > 0 && cap < contributionCaps.length);
263: 263:     for (uint8 i=0; i<addr.length; i++) {
264: 264:       authorize(addr[i], cap);
265: 265:     }
266: 266:   }
267: 267:   
268: 268:   
269: 269:   
270: 270:   function revoke (address addr) public onlyOwner {
271: 271:     require (contractStage < 3);
272: 272:     require (whitelist[addr].authorized);
273: 273:     require (whitelistContract.checkMemberLevel(addr) == 0);
274: 274:     whitelist[addr].authorized = false;
275: 275:     if (whitelist[addr].balance > 0) {
276: 276:       uint amountToTransfer = whitelist[addr].balance;
277: 277:       whitelist[addr].balance = 0;
278: 278:       addr.transfer(amountToTransfer);
279: 279:       ContributorBalanceChanged(addr, 0);
280: 280:     }
281: 281:   }
282: 282:   
283: 283:   
284: 284:   
285: 285:   function modifyIndividualCap (address addr, uint cap) public onlyOwner {
286: 286:     require (contractStage < 3);
287: 287:     require (cap < contributionCaps.length || (cap >= contributionMin && cap <= contributionCaps[0]) );
288: 288:     _checkWhitelistContract(addr);
289: 289:     var c = whitelist[addr];
290: 290:     require (c.authorized);
291: 291:     uint amount = c.balance;
292: 292:     c.cap = cap;
293: 293:     uint capAmount = _checkCap(addr);
294: 294:     if (amount > capAmount) {
295: 295:       c.balance = capAmount;
296: 296:       addr.transfer(amount.sub(capAmount));
297: 297:       ContributorBalanceChanged(addr, capAmount);
298: 298:     }
299: 299:   }
300: 300:   
301: 301:   
302: 302:   
303: 303:   function modifyLevelCap (uint level, uint cap) public onlyOwner {
304: 304:     require (contractStage < 3);
305: 305:     require (level > 0 && level < contributionCaps.length);
306: 306:     require (contributionCaps[level] < cap && contributionCaps[0] >= cap);
307: 307:     contributionCaps[level] = cap;
308: 308:   }
309: 309:   
310: 310:   
311: 311:   
312: 312:   function modifyMaxContractBalance (uint amount) public onlyOwner {
313: 313:     require (contractStage < 3);
314: 314:     require (amount >= contributionMin);
315: 315:     require (amount >= this.balance);
316: 316:     contributionCaps[0] = amount;
317: 317:     for (uint8 i=1; i<contributionCaps.length; i++) {
318: 318:       if (contributionCaps[i]>amount) contributionCaps[i]=amount;
319: 319:     }
320: 320:   }
321: 321:   
322: 322:   
323: 323:   
324: 324:   function _checkCap (address addr) internal returns (uint) {
325: 325:     _checkWhitelistContract(addr);
326: 326:     var c = whitelist[addr];
327: 327:     if (!c.authorized) return 0;
328: 328:     if (c.cap<contributionCaps.length) return contributionCaps[c.cap];
329: 329:     return c.cap; 
330: 330:   }
331: 331:   
332: 332:   function _checkWhitelistContract (address addr) internal {
333: 333:     var c = whitelist[addr];
334: 334:     if (!c.authorized) {
335: 335:       var level = whitelistContract.checkMemberLevel(addr);
336: 336:       if (level == 0 || level >= contributionCaps.length) return;
337: 337:       c.cap = level;
338: 338:       c.authorized = true;
339: 339:     }
340: 340:   }
341: 341:   
342: 342:   
343: 343:   function checkPoolBalance () view public returns (uint poolCap, uint balance, uint remaining) {
344: 344:     if (contractStage == 1) {
345: 345:       remaining = contributionCaps[0].sub(this.balance);
346: 346:     } else {
347: 347:       remaining = 0;
348: 348:     }
349: 349:     return (contributionCaps[0],this.balance,remaining);
350: 350:   }
351: 351:   
352: 352:   
353: 353:   function checkContributorBalance (address addr) view public returns (uint balance, uint cap, uint remaining) {
354: 354:     var c = whitelist[addr];
355: 355:     if (!c.authorized) {
356: 356:       cap = whitelistContract.checkMemberLevel(addr);
357: 357:       if (cap == 0) return (0,0,0);
358: 358:     } else {
359: 359:       cap = c.cap;
360: 360:     }
361: 361:     balance = c.balance;
362: 362:     if (contractStage == 1) {
363: 363:       if (cap<contributionCaps.length) {
364: 364:         cap = contributionCaps[cap];
365: 365:       }
366: 366:       remaining = cap.sub(balance);
367: 367:       if (contributionCaps[0].sub(this.balance) < remaining) remaining = contributionCaps[0].sub(this.balance);
368: 368:     } else {
369: 369:       remaining = 0;
370: 370:     }
371: 371:     return (balance, cap, remaining);
372: 372:   }
373: 373:   
374: 374:   
375: 375:   function checkAvailableTokens (address addr, address tokenAddr) view public returns (uint tokenAmount) {
376: 376:     var c = whitelist[addr];
377: 377:     var d = distribution[tokenAddr];
378: 378:     for (uint i=c.tokensClaimed[tokenAddr]; i<d.pct.length; i++) {
379: 379:       tokenAmount = tokenAmount.add(_applyPct(c.balance,d.pct[i]));
380: 380:     }
381: 381:     return tokenAmount;
382: 382:   }
383: 383:   
384: 384:   
385: 385:   
386: 386:   
387: 387:   function closeContributions () public onlyOwner {
388: 388:     require (contractStage == 1);
389: 389:     contractStage = 2;
390: 390:   }
391: 391:   
392: 392:   
393: 393:   
394: 394:   function reopenContributions () public onlyOwner {
395: 395:     require (contractStage == 2);
396: 396:     contractStage = 1;
397: 397:   }
398: 398:   
399: 399: 
400: 400:   
401: 401:   
402: 402:   
403: 403:   
404: 404:   function submitPool (uint amountInWei) public onlyOwner noReentrancy {
405: 405:     require (contractStage < 3);
406: 406:     require (contributionMin <= amountInWei && amountInWei <= this.balance);
407: 407:     finalBalance = this.balance;
408: 408:     require (receiverAddress.call.value(amountInWei).gas(msg.gas.sub(5000))());
409: 409:     ethRefundAmount.push(this.balance);
410: 410:     contractStage = 3;
411: 411:   }
412: 412:   
413: 413:   
414: 414:   
415: 415:   
416: 416:   
417: 417:   
418: 418:   function enableTokenWithdrawals (address tokenAddr, bool notDefault) public onlyOwner noReentrancy {
419: 419:     require (contractStage == 3);
420: 420:     if (notDefault) {
421: 421:       require (activeToken != 0x00);
422: 422:     } else {
423: 423:       activeToken = tokenAddr;
424: 424:     }
425: 425:     var d = distribution[tokenAddr];    
426: 426:     if (d.pct.length==0) d.token = ERC20(tokenAddr);
427: 427:     uint amount = d.token.balanceOf(this).sub(d.balanceRemaining);
428: 428:     require (amount > 0);
429: 429:     if (feePct > 0) {
430: 430:       require (d.token.transfer(owner,_applyPct(amount,feePct)));
431: 431:     }
432: 432:     amount = d.token.balanceOf(this).sub(d.balanceRemaining);
433: 433:     d.balanceRemaining = d.token.balanceOf(this);
434: 434:     d.pct.push(_toPct(amount,finalBalance));
435: 435:   }
436: 436:   
437: 437:   
438: 438:   function tokenFallback (address from, uint value, bytes data) public {
439: 439:     ERC223Received (from, value);
440: 440:   }
441: 441:   
442: 442: }