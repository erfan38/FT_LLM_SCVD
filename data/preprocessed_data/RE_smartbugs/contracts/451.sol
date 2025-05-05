1: 1: pragma solidity ^0.4.19;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: library SafeMath {
11: 11:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
12: 12:     if (a == 0) {
13: 13:       return 0;
14: 14:     }
15: 15:     uint256 c = a * b;
16: 16:     assert(c / a == b);
17: 17:     return c;
18: 18:   }
19: 19: 
20: 20:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
21: 21:     
22: 22:     uint256 c = a / b;
23: 23:     
24: 24:     return c;
25: 25:   }
26: 26: 
27: 27:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
28: 28:     assert(b <= a);
29: 29:     return a - b;
30: 30:   }
31: 31: 
32: 32:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
33: 33:     uint256 c = a + b;
34: 34:     assert(c >= a);
35: 35:     return c;
36: 36:   }
37: 37: }
38: 38: 
39: 39: 
40: 40: contract PresalePool {
41: 41: 
42: 42:   
43: 43:   
44: 44:   using SafeMath for uint;
45: 45:   
46: 46:   
47: 47:   
48: 48:   
49: 49:   
50: 50:   
51: 51:   uint8 public contractStage = 1;
52: 52:   
53: 53:   
54: 54:   
55: 55:   address public owner;
56: 56:   
57: 57:   uint public contributionMin;
58: 58:   
59: 59:   uint[] public contributionCaps;
60: 60:   
61: 61:   uint public feePct;
62: 62:   
63: 63:   address public receiverAddress;
64: 64:   
65: 65:   uint constant public maxGasPrice = 50000000000;
66: 66:   
67: 67:   WhiteList public whitelistContract;
68: 68:   
69: 69:   
70: 70:   
71: 71:   uint public finalBalance;
72: 72:   
73: 73:   uint[] public ethRefundAmount;
74: 74:   
75: 75:   address public activeToken;
76: 76:   
77: 77:   
78: 78:   struct Contributor {
79: 79:     bool authorized;
80: 80:     uint ethRefund;
81: 81:     uint balance;
82: 82:     uint cap;
83: 83:     mapping (address => uint) tokensClaimed;
84: 84:   }
85: 85:   
86: 86:   mapping (address => Contributor) whitelist;
87: 87:   
88: 88:   
89: 89:   struct TokenAllocation {
90: 90:     ERC20 token;
91: 91:     uint[] pct;
92: 92:     uint balanceRemaining;
93: 93:   }
94: 94:   
95: 95:   mapping (address => TokenAllocation) distribution;
96: 96:   
97: 97:   
98: 98:   
99: 99:   modifier onlyOwner () {
100: 100:     require (msg.sender == owner);
101: 101:     _;
102: 102:   }
103: 103:   
104: 104:   
105: 105:   bool locked;
106: 106:   modifier noReentrancy() {
107: 107:     require(!locked);
108: 108:     locked = true;
109: 109:     _;
110: 110:     locked = false;
111: 111:   }
112: 112:   
113: 113:   
114: 114:   
115: 115:   event ContributorBalanceChanged (address contributor, uint totalBalance);
116: 116:   event TokensWithdrawn (address receiver, uint amount);
117: 117:   event EthRefunded (address receiver, uint amount);
118: 118:   event WithdrawalsOpen (address tokenAddr);
119: 119:   event ERC223Received (address token, uint value);
120: 120:   event EthRefundReceived (address sender, uint amount);
121: 121:    
122: 122:   
123: 123:   
124: 124:   function _toPct (uint numerator, uint denominator ) internal pure returns (uint) {
125: 125:     return numerator.mul(10 ** 20) / denominator;
126: 126:   }
127: 127:   
128: 128:   
129: 129:   function _applyPct (uint numerator, uint pct) internal pure returns (uint) {
130: 130:     return numerator.mul(pct) / (10 ** 20);
131: 131:   }
132: 132:   
133: 133:   
134: 134:   
135: 135:   function PresalePool(address receiverAddr, address whitelistAddr, uint individualMin, uint[] capAmounts, uint fee) public {
136: 136:     require (receiverAddr != 0x00);
137: 137:     require (fee < 100);
138: 138:     require (100000000000000000 <= individualMin);
139: 139:     require (capAmounts.length>1 && capAmounts.length<256);
140: 140:     for (uint8 i=1; i<capAmounts.length; i++) {
141: 141:       require (capAmounts[i] <= capAmounts[0]);
142: 142:     }
143: 143:     owner = msg.sender;
144: 144:     receiverAddress = receiverAddr;
145: 145:     contributionMin = individualMin;
146: 146:     contributionCaps = capAmounts;
147: 147:     feePct = _toPct(fee,100);
148: 148:     whitelistContract = WhiteList(whitelistAddr);
149: 149:     whitelist[msg.sender].authorized = true;
150: 150:   }
151: 151:   
152: 152:   
153: 153:   
154: 154:   
155: 155:   function () payable public {
156: 156:     if (contractStage == 1) {
157: 157:       _ethDeposit();
158: 158:     } else if (contractStage == 3) {
159: 159:       _ethRefund();
160: 160:     } else revert();
161: 161:   }
162: 162:   
163: 163:   
164: 164:   function _ethDeposit () internal {
165: 165:     assert (contractStage == 1);
166: 166:     require (tx.gasprice <= maxGasPrice);
167: 167:     require (this.balance <= contributionCaps[0]);
168: 168:     var c = whitelist[msg.sender];
169: 169:     uint newBalance = c.balance.add(msg.value);
170: 170:     require (newBalance >= contributionMin);
171: 171:     require (newBalance <= _checkCap(msg.sender));
172: 172:     c.balance = newBalance;
173: 173:     ContributorBalanceChanged(msg.sender, newBalance);
174: 174:   }
175: 175:   
176: 176:   
177: 177:   function _ethRefund () internal {
178: 178:     assert (contractStage == 3);
179: 179:     require (msg.sender == owner || msg.sender == receiverAddress);
180: 180:     require (msg.value >= contributionMin);
181: 181:     ethRefundAmount.push(msg.value);
182: 182:     EthRefundReceived(msg.sender, msg.value);
183: 183:   }
184: 184:   
185: 185:   
186: 186:   
187: 187:   
188: 188:   
189: 189:   
190: 190:   function withdraw (address tokenAddr) public {
191: 191:     var c = whitelist[msg.sender];
192: 192:     require (c.balance > 0);
193: 193:     if (contractStage < 3) {
194: 194:       uint amountToTransfer = c.balance;
195: 195:       c.balance = 0;
196: 196:       msg.sender.transfer(amountToTransfer);
197: 197:       ContributorBalanceChanged(msg.sender, 0);
198: 198:     } else {
199: 199:       _withdraw(msg.sender,tokenAddr);
200: 200:     }  
201: 201:   }
202: 202:   
203: 203:   
204: 204:   function withdrawFor (address contributor, address tokenAddr) public onlyOwner {
205: 205:     require (contractStage == 3);
206: 206:     require (whitelist[contributor].balance > 0);
207: 207:     _withdraw(contributor,tokenAddr);
208: 208:   }
209: 209:   
210: 210:   
211: 211:   
212: 212:   function _withdraw (address receiver, address tokenAddr) internal {
213: 213:     assert (contractStage == 3);
214: 214:     var c = whitelist[receiver];
215: 215:     if (tokenAddr == 0x00) {
216: 216:       tokenAddr = activeToken;
217: 217:     }
218: 218:     var d = distribution[tokenAddr];
219: 219:     require ( (ethRefundAmount.length > c.ethRefund) || d.pct.length > c.tokensClaimed[tokenAddr] );
220: 220:     if (ethRefundAmount.length > c.ethRefund) {
221: 221:       uint pct = _toPct(c.balance,finalBalance);
222: 222:       uint ethAmount = 0;
223: 223:       for (uint i=c.ethRefund; i<ethRefundAmount.length; i++) {
224: 224:         ethAmount = ethAmount.add(_applyPct(ethRefundAmount[i],pct));
225: 225:       }
226: 226:       c.ethRefund = ethRefundAmount.length;
227: 227:       if (ethAmount > 0) {
228: 228:         receiver.transfer(ethAmount);
229: 229:         EthRefunded(receiver,ethAmount);
230: 230:       }
231: 231:     }
232: 232:     if (d.pct.length > c.tokensClaimed[tokenAddr]) {
233: 233:       uint tokenAmount = 0;
234: 234:       for (i=c.tokensClaimed[tokenAddr]; i<d.pct.length; i++) {
235: 235:         tokenAmount = tokenAmount.add(_applyPct(c.balance,d.pct[i]));
236: 236:       }
237: 237:       c.tokensClaimed[tokenAddr] = d.pct.length;
238: 238:       if (tokenAmount > 0) {
239: 239:         require(d.token.transfer(receiver,tokenAmount));
240: 240:         d.balanceRemaining = d.balanceRemaining.sub(tokenAmount);
241: 241:         TokensWithdrawn(receiver,tokenAmount);
242: 242:       }  
243: 243:     }
244: 244:     
245: 245:   }
246: 246:   
247: 247:   
248: 248:   
249: 249:   
250: 250:   function authorize (address addr, uint cap) public onlyOwner {
251: 251:     require (contractStage == 1);
252: 252:     _checkWhitelistContract(addr);
253: 253:     require (!whitelist[addr].authorized);
254: 254:     require ((cap > 0 && cap < contributionCaps.length) || (cap >= contributionMin && cap <= contributionCaps[0]) );
255: 255:     uint size;
256: 256:     assembly { size := extcodesize(addr) }
257: 257:     require (size == 0);
258: 258:     whitelist[addr].cap = cap;
259: 259:     whitelist[addr].authorized = true;
260: 260:   }
261: 261:   
262: 262:   
263: 263:   
264: 264:   function authorizeMany (address[] addr, uint cap) public onlyOwner {
265: 265:     require (addr.length < 255);
266: 266:     require (cap > 0 && cap < contributionCaps.length);
267: 267:     for (uint8 i=0; i<addr.length; i++) {
268: 268:       authorize(addr[i], cap);
269: 269:     }
270: 270:   }
271: 271:   
272: 272:   
273: 273:   
274: 274:   
275: 275:   function revoke (address addr) public onlyOwner {
276: 276:     require (contractStage < 3);
277: 277:     require (whitelist[addr].authorized);
278: 278:     require (whitelistContract.checkMemberLevel(addr) == 0);
279: 279:     whitelist[addr].authorized = false;
280: 280:     if (whitelist[addr].balance > 0) {
281: 281:       uint amountToTransfer = whitelist[addr].balance;
282: 282:       whitelist[addr].balance = 0;
283: 283:       addr.transfer(amountToTransfer);
284: 284:       ContributorBalanceChanged(addr, 0);
285: 285:     }
286: 286:   }
287: 287:   
288: 288:   
289: 289:   
290: 290:   function modifyIndividualCap (address addr, uint cap) public onlyOwner {
291: 291:     require (contractStage < 3);
292: 292:     require (cap < contributionCaps.length || (cap >= contributionMin && cap <= contributionCaps[0]) );
293: 293:     _checkWhitelistContract(addr);
294: 294:     var c = whitelist[addr];
295: 295:     require (c.authorized);
296: 296:     uint amount = c.balance;
297: 297:     c.cap = cap;
298: 298:     uint capAmount = _checkCap(addr);
299: 299:     if (amount > capAmount) {
300: 300:       c.balance = capAmount;
301: 301:       addr.transfer(amount.sub(capAmount));
302: 302:       ContributorBalanceChanged(addr, capAmount);
303: 303:     }
304: 304:   }
305: 305:   
306: 306:   
307: 307:   
308: 308:   function modifyLevelCap (uint level, uint cap) public onlyOwner {
309: 309:     require (contractStage < 3);
310: 310:     require (level > 0 && level < contributionCaps.length);
311: 311:     require (contributionCaps[level] < cap && contributionCaps[0] >= cap);
312: 312:     contributionCaps[level] = cap;
313: 313:   }
314: 314:   
315: 315:   
316: 316:   function modifyLevelCaps (uint[] cap) public onlyOwner {
317: 317:     require (contractStage < 3);
318: 318:     require (cap.length == contributionCaps.length-1);
319: 319:     for (uint8 i = 1; i<contributionCaps.length; i++) {
320: 320:       modifyLevelCap(i,cap[i-1]);
321: 321:     }
322: 322:   }
323: 323:   
324: 324:   
325: 325:   
326: 326:   
327: 327:   function modifyMaxContractBalance (uint amount) public onlyOwner {
328: 328:     require (contractStage < 3);
329: 329:     require (amount >= contributionMin);
330: 330:     require (amount >= this.balance);
331: 331:     contributionCaps[0] = amount;
332: 332:     for (uint8 i=1; i<contributionCaps.length; i++) {
333: 333:       if (contributionCaps[i]>amount) contributionCaps[i]=amount;
334: 334:     }
335: 335:   }
336: 336:   
337: 337:   
338: 338:   function _checkCap (address addr) internal returns (uint) {
339: 339:     _checkWhitelistContract(addr);
340: 340:     var c = whitelist[addr];
341: 341:     if (!c.authorized) return 0;
342: 342:     if (c.cap<contributionCaps.length) return contributionCaps[c.cap];
343: 343:     return c.cap; 
344: 344:   }
345: 345:   
346: 346:   
347: 347:   function _checkWhitelistContract (address addr) internal {
348: 348:     var c = whitelist[addr];
349: 349:     if (!c.authorized) {
350: 350:       var level = whitelistContract.checkMemberLevel(addr);
351: 351:       if (level == 0 || level >= contributionCaps.length) return;
352: 352:       c.cap = level;
353: 353:       c.authorized = true;
354: 354:     }
355: 355:   }
356: 356:   
357: 357:   
358: 358:   function checkPoolBalance () view public returns (uint poolCap, uint balance, uint remaining) {
359: 359:     if (contractStage == 1) {
360: 360:       remaining = contributionCaps[0].sub(this.balance);
361: 361:     } else {
362: 362:       remaining = 0;
363: 363:     }
364: 364:     return (contributionCaps[0],this.balance,remaining);
365: 365:   }
366: 366:   
367: 367:   
368: 368:   function checkContributorBalance (address addr) view public returns (uint balance, uint cap, uint remaining) {
369: 369:     var c = whitelist[addr];
370: 370:     if (!c.authorized) {
371: 371:       cap = whitelistContract.checkMemberLevel(addr);
372: 372:       if (cap == 0) return (0,0,0);
373: 373:     } else {
374: 374:       cap = c.cap;
375: 375:     }
376: 376:     balance = c.balance;
377: 377:     if (contractStage == 1) {
378: 378:       if (cap<contributionCaps.length) {
379: 379:         cap = contributionCaps[cap];
380: 380:       }
381: 381:       remaining = cap.sub(balance);
382: 382:       if (contributionCaps[0].sub(this.balance) < remaining) remaining = contributionCaps[0].sub(this.balance);
383: 383:     } else {
384: 384:       remaining = 0;
385: 385:     }
386: 386:     return (balance, cap, remaining);
387: 387:   }
388: 388:   
389: 389:   
390: 390:   function checkAvailableTokens (address addr, address tokenAddr) view public returns (uint tokenAmount) {
391: 391:     var c = whitelist[addr];
392: 392:     var d = distribution[tokenAddr];
393: 393:     for (uint i=c.tokensClaimed[tokenAddr]; i<d.pct.length; i++) {
394: 394:       tokenAmount = tokenAmount.add(_applyPct(c.balance,d.pct[i]));
395: 395:     }
396: 396:     return tokenAmount;
397: 397:   }
398: 398:   
399: 399:   
400: 400:   
401: 401:   
402: 402:   function closeContributions () public onlyOwner {
403: 403:     require (contractStage == 1);
404: 404:     contractStage = 2;
405: 405:   }
406: 406:   
407: 407:   
408: 408:   
409: 409:   function reopenContributions () public onlyOwner {
410: 410:     require (contractStage == 2);
411: 411:     contractStage = 1;
412: 412:   }
413: 413:   
414: 414: 
415: 415:   
416: 416:   
417: 417:   
418: 418:   
419: 419:   function submitPool (uint amountInWei) public onlyOwner noReentrancy {
420: 420:     require (contractStage < 3);
421: 421:     require (contributionMin <= amountInWei && amountInWei <= this.balance);
422: 422:     finalBalance = this.balance;
423: 423:     require (receiverAddress.call.value(amountInWei).gas(msg.gas.sub(5000))());
424: 424:     ethRefundAmount.push(this.balance);
425: 425:     contractStage = 3;
426: 426:   }
427: 427:   
428: 428:   
429: 429:   
430: 430:   
431: 431:   
432: 432:   
433: 433:   function enableTokenWithdrawals (address tokenAddr, bool notDefault) public onlyOwner noReentrancy {
434: 434:     require (contractStage == 3);
435: 435:     if (notDefault) {
436: 436:       require (activeToken != 0x00);
437: 437:     } else {
438: 438:       activeToken = tokenAddr;
439: 439:     }
440: 440:     var d = distribution[tokenAddr];    
441: 441:     if (d.pct.length==0) d.token = ERC20(tokenAddr);
442: 442:     uint amount = d.token.balanceOf(this).sub(d.balanceRemaining);
443: 443:     require (amount > 0);
444: 444:     if (feePct > 0) {
445: 445:       require (d.token.transfer(owner,_applyPct(amount,feePct)));
446: 446:     }
447: 447:     amount = d.token.balanceOf(this).sub(d.balanceRemaining);
448: 448:     d.balanceRemaining = d.token.balanceOf(this);
449: 449:     d.pct.push(_toPct(amount,finalBalance));
450: 450:   }
451: 451:   
452: 452:   
453: 453:   function tokenFallback (address from, uint value, bytes data) public {
454: 454:     ERC223Received (from, value);
455: 455:   }
456: 456:   
457: 457: }