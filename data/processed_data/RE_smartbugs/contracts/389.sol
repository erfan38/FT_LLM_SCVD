1: 1: pragma solidity^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: interface MobiusToken {
13: 13:     function disburseDividends() external payable;
14: 14: }
15: 15: 
16: 16: interface LastVersion {
17: 17:     function withdrawReturns() external;
18: 18:     function roundInfo(uint roundID) external view 
19: 19:     returns(
20: 20:         address leader, 
21: 21:         uint price,
22: 22:         uint jackpot, 
23: 23:         uint airdrop, 
24: 24:         uint shares, 
25: 25:         uint totalInvested,
26: 26:         uint distributedReturns,
27: 27:         uint _hardDeadline,
28: 28:         uint _softDeadline,
29: 29:         bool finalized
30: 30:         );
31: 31:     function totalsInfo() external view 
32: 32:     returns(
33: 33:         uint totalReturns,
34: 34:         uint totalShares,
35: 35:         uint totalDividends,
36: 36:         uint totalJackpots
37: 37:     );
38: 38:     function latestRoundID() external returns(uint);
39: 39: }
40: 40: 
41: 41: 
42: 42: 
43: 43: 
44: 44: 
45: 45: 
46: 46: 
47: 47: 
48: 48: 
49: 49: 
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
68: 68: 
69: 69: 
70: 70: 
71: 71: 
72: 72: 
73: 73: 
74: 74: 
75: 75: 
76: 76: 
77: 77: 
78: 78: 
79: 79: 
80: 80: 
81: 81: 
82: 82: 
83: 83: 
84: 84: 
85: 85: 
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
97: 97: 
98: 98: 
99: 99: 
100: 100: 
101: 101:  
102: 102: contract Mobius2Dv2 is UsingOraclizeRandom, DSMath {
103: 103:     
104: 104:     
105: 105:     string public ipfsHash;
106: 106:     string public ipfsHashType = "ipfs"; 
107: 107: 
108: 108:     MobiusToken public constant token = MobiusToken(0x54cdC9D889c28f55F59f6b136822868c7d4726fC);
109: 109: 
110: 110:     
111: 111:     
112: 112:     bool public upgraded;
113: 113:     bool public initialized;
114: 114:     address public nextVersion;
115: 115:     LastVersion public constant lastVersion = LastVersion(0xA74642Aeae3e2Fd79150c910eB5368B64f864B1e);
116: 116:     uint public previousRounds;
117: 117: 
118: 118:     
119: 119:     uint public totalRevenue;
120: 120:     uint public totalSharesSold;
121: 121:     uint public totalEarningsGenerated;
122: 122:     uint public totalDividendsPaid;
123: 123:     uint public totalJackpotsWon;
124: 124: 
125: 125:     
126: 126:     uint public constant DEV_DIVISOR = 20;                      
127: 127: 
128: 128:     uint public constant RETURNS_FRACTION = 60 * 10**16;        
129: 129:     
130: 130:     uint public constant REFERRAL_FRACTION = 3 * 10**16;        
131: 131: 
132: 132:     uint public constant JACKPOT_SEED_FRACTION = WAD / 20;      
133: 133:     uint public constant JACKPOT_FRACTION = 15 * 10**16;        
134: 134:     uint public constant DAILY_JACKPOT_FRACTION = 6 * 10**16;    
135: 135:     uint public constant DIVIDENDS_FRACTION = 9 * 10**16;       
136: 136: 
137: 137:     
138: 138:     uint public startingSharePrice = 1 finney;   
139: 139:     uint public _priceIncreasePeriod = 1 hours;  
140: 140:     uint public _priceMultiplier = 101 * 10**16; 
141: 141: 
142: 142:     uint public _secondaryPrice = 100 finney;    
143: 143:     uint public maxDailyJackpot = 5 ether; 
144: 144: 
145: 145:     uint public constant SOFT_DEADLINE_DURATION = 1 days; 
146: 146:     uint public constant DAILY_JACKPOT_PERIOD = 1 days;
147: 147:     uint public constant TIME_PER_SHARE = 5 minutes; 
148: 148: 
149: 149:     uint public nextRoundTime; 
150: 150:     uint public jackpotSeed;
151: 151:     uint public devBalance; 
152: 152: 
153: 153:     
154: 154:     uint public unclaimedReturns;
155: 155:     uint public constant MULTIPLIER = RAY;
156: 156: 
157: 157:     
158: 158:     mapping (address => uint) public lastDailyEntry;
159: 159: 
160: 160:     
161: 161:     
162: 162:     struct Investor {
163: 163:         uint lastCumulativeReturnsPoints;
164: 164:         uint shares;
165: 165:     }
166: 166: 
167: 167:     
168: 168:     struct MobiusRound {
169: 169:         uint totalInvested;        
170: 170:         uint jackpot;
171: 171:         uint dailyJackpot;
172: 172:         uint totalShares;
173: 173:         uint cumulativeReturnsPoints; 
174: 174:         uint softDeadline;
175: 175:         uint price;
176: 176:         uint secondaryPrice;
177: 177:         uint priceMultiplier;
178: 178:         uint priceIncreasePeriod;
179: 179:         uint lastPriceIncreaseTime;
180: 180:         uint lastDailyJackpot;
181: 181:         address lastInvestor;
182: 182:         bool finalized;
183: 183:         mapping (address => Investor) investors;
184: 184:     }
185: 185: 
186: 186:     struct DailyJackpotRound {
187: 187:         address[] entrants;
188: 188:         address winner;
189: 189:         bool finalized;
190: 190:     }
191: 191: 
192: 192:     struct Vault {
193: 193:         uint totalReturns; 
194: 194:         uint refReturns; 
195: 195:     }
196: 196: 
197: 197:     mapping (address => Vault) vaults;
198: 198: 
199: 199:     uint public latestRoundID;
200: 200:     uint public latestDailyID;
201: 201:     MobiusRound[] rounds;
202: 202:     DailyJackpotRound[] dailyRounds;
203: 203: 
204: 204:     event SharesIssued(address indexed to, uint shares);
205: 205:     event ReturnsWithdrawn(address indexed by, uint amount);
206: 206:     event JackpotWon(address by, uint amount);
207: 207:     event DailyJackpotWon(address indexed by, uint amount);
208: 208:     event RoundStarted(uint ID, uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod);
209: 209:     event IPFSHashSet(string _type, string _hash);
210: 210: 
211: 211:     constructor() public {
212: 212:     }
213: 213: 
214: 214:     function initOraclize() public auth {
215: 215:         oraclizeCallbackGas = 250000;
216: 216:         if(oraclize_setNetwork()){
217: 217:             oraclize_setProof(proofType_Ledger);
218: 218:         }
219: 219:     }
220: 220: 
221: 221:     
222: 222:     
223: 223:     function estimateReturns(address investor, uint roundID) public view 
224: 224:     returns (uint totalReturns, uint refReturns) 
225: 225:     {
226: 226:         MobiusRound storage rnd = rounds[roundID];
227: 227:         uint outstanding;
228: 228:         if(rounds.length > 1) {
229: 229:             if(hasReturns(investor, roundID - 1)) {
230: 230:                 MobiusRound storage prevRnd = rounds[roundID - 1];
231: 231:                 outstanding = _outstandingReturns(investor, prevRnd);
232: 232:             }
233: 233:         }
234: 234: 
235: 235:         outstanding += _outstandingReturns(investor, rnd);
236: 236:         
237: 237:         totalReturns = vaults[investor].totalReturns + outstanding;
238: 238:         refReturns = vaults[investor].refReturns;
239: 239:     }
240: 240: 
241: 241:     function hasReturns(address investor, uint roundID) public view returns (bool) {
242: 242:         MobiusRound storage rnd = rounds[roundID];
243: 243:         return rnd.cumulativeReturnsPoints > rnd.investors[investor].lastCumulativeReturnsPoints;
244: 244:     }
245: 245: 
246: 246:     function investorInfo(address investor, uint roundID) external view
247: 247:     returns(uint shares, uint totalReturns, uint referralReturns, bool inNextDailyDraw) 
248: 248:     {
249: 249:         MobiusRound storage rnd = rounds[roundID];
250: 250:         shares = rnd.investors[investor].shares;
251: 251:         (totalReturns, referralReturns) = estimateReturns(investor, roundID);
252: 252:         inNextDailyDraw = lastDailyEntry[investor] > rnd.lastDailyJackpot;
253: 253:     }
254: 254: 
255: 255:     function roundInfo(uint roundID) external view 
256: 256:     returns(
257: 257:         address leader, 
258: 258:         uint price,
259: 259:         uint secondaryPrice,
260: 260:         uint priceMultiplier,
261: 261:         uint priceIncreasePeriod,
262: 262:         uint jackpot, 
263: 263:         uint dailyJackpot, 
264: 264:         uint lastDailyJackpot,
265: 265:         uint shares, 
266: 266:         uint totalInvested,
267: 267:         uint distributedReturns,
268: 268:         uint _softDeadline,
269: 269:         bool finalized
270: 270:         )
271: 271:     {
272: 272:         MobiusRound storage rnd = rounds[roundID];
273: 273:         leader = rnd.lastInvestor;
274: 274:         price = rnd.price;
275: 275:         secondaryPrice = _secondaryPrice;
276: 276:         priceMultiplier = rnd.priceMultiplier;
277: 277:         priceIncreasePeriod = rnd.priceIncreasePeriod;
278: 278:         jackpot = rnd.jackpot;
279: 279:         dailyJackpot = min(maxDailyJackpot, rnd.dailyJackpot/2);
280: 280:         lastDailyJackpot = rnd.lastDailyJackpot;
281: 281:         shares = rnd.totalShares;
282: 282:         totalInvested = rnd.totalInvested;
283: 283:         distributedReturns = wmul(rnd.totalInvested, RETURNS_FRACTION);
284: 284:         _softDeadline = rnd.softDeadline;
285: 285:         finalized = rnd.finalized;
286: 286:     }
287: 287: 
288: 288:     function totalsInfo() external view 
289: 289:     returns(
290: 290:         uint totalReturns,
291: 291:         uint totalShares,
292: 292:         uint totalDividends,
293: 293:         uint totalJackpots,
294: 294:         uint totalInvested,
295: 295:         uint totalRounds
296: 296:     ) {
297: 297:         MobiusRound storage rnd = rounds[latestRoundID];
298: 298:         if(rnd.softDeadline > now) {
299: 299:             totalShares = totalSharesSold + rnd.totalShares;
300: 300:             totalReturns = totalEarningsGenerated + wmul(rnd.totalInvested, RETURNS_FRACTION);
301: 301:             totalDividends = totalDividendsPaid + wmul(rnd.totalInvested, DIVIDENDS_FRACTION);
302: 302:             totalInvested = totalRevenue + rnd.totalInvested;
303: 303:         } else {
304: 304:             totalShares = totalSharesSold;
305: 305:             totalReturns = totalEarningsGenerated;
306: 306:             totalDividends = totalDividendsPaid;
307: 307:             totalInvested = totalRevenue;
308: 308:         }
309: 309:         totalJackpots = totalJackpotsWon;
310: 310:         totalRounds = previousRounds + rounds.length;
311: 311:     }
312: 312: 
313: 313:     function () public payable {
314: 314:         if(!initialized){
315: 315:             jackpotSeed += msg.value;
316: 316:         } else {
317: 317:             buyShares(address(0x0));
318: 318:         }
319: 319:     }
320: 320: 
321: 321:     
322: 322:     function buyShares(address ref) public payable {        
323: 323:         if(rounds.length > 0) {
324: 324:             MobiusRound storage rnd = rounds[latestRoundID];                  
325: 325:             _purchase(rnd, msg.value, ref);            
326: 326:         } else {
327: 327:             revert("Not yet started");
328: 328:         }
329: 329:     }
330: 330: 
331: 331:     
332: 332:     function reinvestReturns(uint value) public {        
333: 333:         reinvestReturns(value, address(0x0));
334: 334:     }
335: 335: 
336: 336:     function reinvestReturns(uint value, address ref) public {        
337: 337:         MobiusRound storage rnd = rounds[latestRoundID];
338: 338:         _updateReturns(msg.sender, rnd);        
339: 339:         require(vaults[msg.sender].totalReturns >= value, "Can't spend what you don't have");        
340: 340:         vaults[msg.sender].totalReturns = sub(vaults[msg.sender].totalReturns, value);
341: 341:         vaults[msg.sender].refReturns = min(vaults[msg.sender].refReturns, vaults[msg.sender].totalReturns);
342: 342:         unclaimedReturns = sub(unclaimedReturns, value);
343: 343:         _purchase(rnd, value, ref);
344: 344:     }
345: 345: 
346: 346:     function withdrawReturns() public {
347: 347:         MobiusRound storage rnd = rounds[latestRoundID];
348: 348: 
349: 349:         if(rounds.length > 1) {
350: 350:             if(hasReturns(msg.sender, latestRoundID - 1)) {
351: 351:                 MobiusRound storage prevRnd = rounds[latestRoundID - 1];
352: 352:                 _updateReturns(msg.sender, prevRnd);
353: 353:             }
354: 354:         }
355: 355:         _updateReturns(msg.sender, rnd);
356: 356:         uint amount = vaults[msg.sender].totalReturns;
357: 357:         require(amount > 0, "Nothing to withdraw!");
358: 358:         unclaimedReturns = sub(unclaimedReturns, amount);
359: 359:         vaults[msg.sender].totalReturns = 0;
360: 360:         vaults[msg.sender].refReturns = 0;
361: 361:         
362: 362:         rnd.investors[msg.sender].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
363: 363:         msg.sender.transfer(amount);
364: 364: 
365: 365:         emit ReturnsWithdrawn(msg.sender, amount);
366: 366:     }
367: 367: 
368: 368:     
369: 369:     function updateMyReturns(uint roundID) public {
370: 370:         MobiusRound storage rnd = rounds[roundID];
371: 371:         _updateReturns(msg.sender, rnd);
372: 372:     }
373: 373: 
374: 374:     function finalizeAndRestart() public payable {
375: 375:         finalizeLastRound();
376: 376:         startNewRound();
377: 377:     }
378: 378: 
379: 379:     
380: 380:     function startNewRound() public payable {
381: 381:         require(!upgraded && initialized, "This contract has been upgraded, or is not yet initialized!");
382: 382:         require(now >= nextRoundTime, "Too early!");
383: 383:         if(rounds.length > 0) {
384: 384:             require(rounds[latestRoundID].finalized, "Previous round not finalized");
385: 385:             require(rounds[latestRoundID].softDeadline < now, "Previous round still running");
386: 386:         }
387: 387:         uint _rID = rounds.length++;
388: 388:         MobiusRound storage rnd = rounds[_rID];
389: 389:         latestRoundID = _rID;
390: 390: 
391: 391:         rnd.lastInvestor = msg.sender;
392: 392:         rnd.price = startingSharePrice;
393: 393:         rnd.secondaryPrice = _secondaryPrice;
394: 394:         rnd.priceMultiplier = _priceMultiplier;
395: 395:         rnd.priceIncreasePeriod = _priceIncreasePeriod;
396: 396:         rnd.lastPriceIncreaseTime = now;
397: 397:         rnd.lastDailyJackpot = now;
398: 398:         rnd.softDeadline = now + SOFT_DEADLINE_DURATION;
399: 399:         rnd.jackpot = jackpotSeed;
400: 400:         jackpotSeed = 0; 
401: 401:         _startNewDailyRound();
402: 402:         _purchase(rnd, msg.value, address(0x0));
403: 403:         emit RoundStarted(_rID, startingSharePrice, _priceMultiplier, _priceIncreasePeriod);
404: 404:     }
405: 405: 
406: 406:     
407: 407:     function finalizeLastRound() public {
408: 408:         MobiusRound storage rnd = rounds[latestRoundID];
409: 409:         _finalizeRound(rnd);
410: 410:     }
411: 411: 
412: 412:     function setRoundParams(uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod) public auth {
413: 413:         startingSharePrice = startingPrice;
414: 414:         _priceMultiplier = priceMultiplier;
415: 415:         _priceIncreasePeriod = priceIncreasePeriod;
416: 416:     }
417: 417: 
418: 418:     function setSecondaryPrice(uint newPrice) public auth {
419: 419:         _secondaryPrice = newPrice;
420: 420:     }
421: 421: 
422: 422:     function setMaxDailyJackpot(uint newLimit) public auth {
423: 423:         maxDailyJackpot = newLimit;
424: 424:     }
425: 425: 
426: 426:     
427: 427:     function setNextRoundTimestamp(uint timestamp) public auth {
428: 428:         require(now > nextRoundTime);
429: 429:         require(timestamp <= now + 2 days);
430: 430:         nextRoundTime = timestamp;
431: 431:     }
432: 432: 
433: 433:     function setNextRoundDelay(uint delayInSeconds) public auth {
434: 434:         require(now > nextRoundTime);
435: 435:         require(now + delayInSeconds <= now + 2 days);
436: 436:         nextRoundTime = now + delayInSeconds;
437: 437:     }
438: 438:     
439: 439:     
440: 440:     function withdrawDevShare() public auth {
441: 441:         uint value = sub(devBalance, totalPaidOraclize); 
442: 442:         devBalance = 0;
443: 443:         totalPaidOraclize = 0;
444: 444:         msg.sender.transfer(value);
445: 445:     }
446: 446: 
447: 447:     function setIPFSHash(string _type, string _hash) public auth {
448: 448:         ipfsHashType = _type;
449: 449:         ipfsHash = _hash;
450: 450:         emit IPFSHashSet(_type, _hash);
451: 451:     }
452: 452: 
453: 453:     function upgrade(address _nextVersion) public auth {
454: 454:         require(_nextVersion != address(0x0), "Invalid Address!");
455: 455:         require(!upgraded, "Already upgraded!");
456: 456:         upgraded = true;
457: 457:         nextVersion = _nextVersion;
458: 458:     }
459: 459: 
460: 460:     
461: 461:     function getSeed() public {
462: 462:         require(upgraded, "Not upgraded!");
463: 463:         require(msg.sender == nextVersion, "You can't do that!");
464: 464:         MobiusRound storage rnd = rounds[latestRoundID];
465: 465:         require(rnd.finalized, "Still running!");
466: 466:         
467: 467:         require(nextVersion.call.value(jackpotSeed)(), "Transfer failed!");
468: 468:     }
469: 469: 
470: 470:     
471: 471:     
472: 472:     function init() public auth {
473: 473:         
474: 474:         require(!initialized, "Already initialized!");
475: 475:         uint _rID = lastVersion.latestRoundID();
476: 476:         previousRounds = 1 + _rID;
477: 477:         uint _shares;
478: 478:         uint _invested;
479: 479:         uint _returns;
480: 480:         uint _dividends;
481: 481:         uint _jackpots;
482: 482:         bool finalized;
483: 483:         ( , , , , , _invested, , , , finalized) = lastVersion.roundInfo(_rID);
484: 484:         require(finalized, "Last round is still not finalized!");
485: 485:         (_returns, _shares, _dividends, _jackpots) = lastVersion.totalsInfo();
486: 486: 
487: 487:         totalSharesSold = _shares;
488: 488:         totalRevenue = _invested;
489: 489:         totalEarningsGenerated = _returns;
490: 490:         totalDividendsPaid = _dividends;
491: 491:         totalJackpotsWon = _jackpots;
492: 492:         
493: 493:         
494: 494:         
495: 495:         initialized = true;
496: 496:     }
497: 497: 
498: 498:     function _startNewDailyRound() internal {
499: 499:         if(dailyRounds.length > 0) {
500: 500:             require(dailyRounds[latestDailyID].finalized, "Previous round not finalized");
501: 501:         }
502: 502:         uint _rID = dailyRounds.length++;
503: 503:         latestDailyID = _rID;
504: 504:     }
505: 505: 
506: 506:     
507: 507:     function _purchase(MobiusRound storage rnd, uint value, address ref) internal {
508: 508:         require(rnd.softDeadline >= now, "After deadline!");
509: 509:         require(value >= 100 szabo, "Not enough Ether!");
510: 510:         rnd.totalInvested = add(rnd.totalInvested, value);
511: 511: 
512: 512:         
513: 513:         if(value >= rnd.price) {
514: 514:             rnd.lastInvestor = msg.sender;
515: 515:         }
516: 516:         
517: 517:         _dailyJackpot(rnd, value);
518: 518:         
519: 519:         _splitRevenue(rnd, value, ref);
520: 520:         
521: 521:         _updateReturns(msg.sender, rnd);
522: 522:         
523: 523:         uint newShares = _issueShares(rnd, msg.sender, value);
524: 524: 
525: 525:         uint timeIncreases = newShares/WAD;
526: 526:         
527: 527:         uint newDeadline = add(rnd.softDeadline, mul(timeIncreases, TIME_PER_SHARE));
528: 528:         rnd.softDeadline = min(newDeadline, now + SOFT_DEADLINE_DURATION);
529: 529:         
530: 530:         
531: 531:         if(now > rnd.lastPriceIncreaseTime + rnd.priceIncreasePeriod) {
532: 532:             rnd.price = wmul(rnd.price, rnd.priceMultiplier);
533: 533:             rnd.lastPriceIncreaseTime = now;
534: 534:         }
535: 535:         
536: 536:     }
537: 537: 
538: 538:     function _finalizeRound(MobiusRound storage rnd) internal {
539: 539:         require(!rnd.finalized, "Already finalized!");
540: 540:         require(rnd.softDeadline < now, "Round still running!");
541: 541: 
542: 542:         
543: 543:         vaults[rnd.lastInvestor].totalReturns = add(vaults[rnd.lastInvestor].totalReturns, rnd.jackpot);
544: 544:         unclaimedReturns = add(unclaimedReturns, rnd.jackpot);
545: 545:         
546: 546:         emit JackpotWon(rnd.lastInvestor, rnd.jackpot);
547: 547:         totalJackpotsWon += rnd.jackpot;
548: 548:         
549: 549:         jackpotSeed = add(jackpotSeed, wmul(rnd.totalInvested, JACKPOT_SEED_FRACTION));
550: 550:         
551: 551:         jackpotSeed = add(jackpotSeed, rnd.dailyJackpot);
552: 552:                
553: 553:         
554: 554:         uint _div = wmul(rnd.totalInvested, DIVIDENDS_FRACTION);            
555: 555:         
556: 556:         token.disburseDividends.value(_div)();
557: 557:         totalDividendsPaid += _div;
558: 558:         totalSharesSold += rnd.totalShares;
559: 559:         totalEarningsGenerated += wmul(rnd.totalInvested, RETURNS_FRACTION);
560: 560:         totalRevenue += rnd.totalInvested;
561: 561:         dailyRounds[latestDailyID].finalized = true;
562: 562:         rnd.finalized = true;
563: 563:     }
564: 564: 
565: 565:     
566: 566: 
567: 567: 
568: 568: 
569: 569:     function _updateReturns(address _investor, MobiusRound storage rnd) internal {
570: 570:         if(rnd.investors[_investor].shares == 0) {
571: 571:             return;
572: 572:         }
573: 573:         
574: 574:         uint outstanding = _outstandingReturns(_investor, rnd);
575: 575: 
576: 576:         
577: 577:         if (outstanding > 0) {
578: 578:             vaults[_investor].totalReturns = add(vaults[_investor].totalReturns, outstanding);
579: 579:         }
580: 580: 
581: 581:         rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
582: 582:     }
583: 583: 
584: 584:     function _outstandingReturns(address _investor, MobiusRound storage rnd) internal view returns(uint) {
585: 585:         if(rnd.investors[_investor].shares == 0) {
586: 586:             return 0;
587: 587:         }
588: 588:         
589: 589:         uint newReturns = sub(
590: 590:             rnd.cumulativeReturnsPoints, 
591: 591:             rnd.investors[_investor].lastCumulativeReturnsPoints
592: 592:             );
593: 593: 
594: 594:         uint outstanding = 0;
595: 595:         if(newReturns != 0) { 
596: 596:             
597: 597:             
598: 598:             outstanding = mul(newReturns, rnd.investors[_investor].shares) / MULTIPLIER;
599: 599:         }
600: 600: 
601: 601:         return outstanding;
602: 602:     }
603: 603: 
604: 604:     
605: 605:     function _splitRevenue(MobiusRound storage rnd, uint value, address ref) internal {
606: 606:         uint roundReturns;
607: 607:         
608: 608:         if(ref != address(0x0) && ref != msg.sender) {
609: 609:             
610: 610:             roundReturns = wmul(value, RETURNS_FRACTION - REFERRAL_FRACTION);
611: 611:             uint _ref = wmul(value, REFERRAL_FRACTION);
612: 612:             vaults[ref].totalReturns = add(vaults[ref].totalReturns, _ref);            
613: 613:             vaults[ref].refReturns = add(vaults[ref].refReturns, _ref);
614: 614:             unclaimedReturns = add(unclaimedReturns, _ref);
615: 615:         } else {
616: 616:             roundReturns = wmul(value, RETURNS_FRACTION);
617: 617:         }
618: 618:         
619: 619:         uint dailyJackpot = wmul(value, DAILY_JACKPOT_FRACTION);
620: 620:         uint jackpot = wmul(value, JACKPOT_FRACTION);
621: 621:         
622: 622:         uint dev;
623: 623:         
624: 624:         dev = value / DEV_DIVISOR;
625: 625:         
626: 626:         
627: 627:         if(rnd.totalShares == 0) {
628: 628:             rnd.jackpot = add(rnd.jackpot, roundReturns);
629: 629:         } else {
630: 630:             _disburseReturns(rnd, roundReturns);
631: 631:         }
632: 632:         
633: 633:         rnd.dailyJackpot = add(rnd.dailyJackpot, dailyJackpot);
634: 634:         rnd.jackpot = add(rnd.jackpot, jackpot);
635: 635:         devBalance = add(devBalance, dev);
636: 636:     }
637: 637: 
638: 638:     function _disburseReturns(MobiusRound storage rnd, uint value) internal {
639: 639:         unclaimedReturns = add(unclaimedReturns, value);
640: 640:         
641: 641:         
642: 642:         if(rnd.totalShares == 0) {
643: 643:             rnd.cumulativeReturnsPoints = mul(value, MULTIPLIER) / wdiv(value, rnd.price);
644: 644:         } else {
645: 645:             rnd.cumulativeReturnsPoints = add(
646: 646:                 rnd.cumulativeReturnsPoints, 
647: 647:                 mul(value, MULTIPLIER) / rnd.totalShares
648: 648:             );
649: 649:         }
650: 650:     }
651: 651: 
652: 652:     function _issueShares(MobiusRound storage rnd, address _investor, uint value) internal returns(uint) {    
653: 653:         if(rnd.investors[_investor].lastCumulativeReturnsPoints == 0) {
654: 654:             rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
655: 655:         }    
656: 656:         
657: 657:         uint newShares = wdiv(value, rnd.price);
658: 658:         
659: 659:         
660: 660:         if(value >= 100 ether) {
661: 661:             newShares = mul(newShares, 2);
662: 662:         } else if(value >= 10 ether) {
663: 663:             newShares = add(newShares, newShares/2);
664: 664:         } else if(value >= 1 ether) {
665: 665:             newShares = add(newShares, newShares/3);
666: 666:         } else if(value >= 100 finney) {
667: 667:             newShares = add(newShares, newShares/10);
668: 668:         }
669: 669: 
670: 670:         rnd.investors[_investor].shares = add(rnd.investors[_investor].shares, newShares);
671: 671:         rnd.totalShares = add(rnd.totalShares, newShares);
672: 672:         emit SharesIssued(_investor, newShares);
673: 673:         return newShares;
674: 674:     }    
675: 675: 
676: 676:     function _dailyJackpot(MobiusRound storage rnd, uint value) internal {
677: 677:         
678: 678:         if(value >= rnd.secondaryPrice) {
679: 679:             dailyRounds[latestDailyID].entrants.push(msg.sender);
680: 680:             lastDailyEntry[msg.sender] = now; 
681: 681:         }
682: 682:         
683: 683:         if(now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
684: 684:             
685: 685:             if(rnd.dailyJackpot < rnd.secondaryPrice * 4) {
686: 686:                 return;
687: 687:             }
688: 688:             if(!oraclizePending) {                
689: 689:                 _requestRandom(0);
690: 690:             } else {
691: 691:                 if(now > oraclizeLastRequestTime + 10 minutes){
692: 692:                     
693: 693:                     
694: 694:                     oraclizeGasPrice = min(150000000000, oraclizeGasPrice * 2); 
695: 695:                     oraclize_setCustomGasPrice(oraclizeGasPrice);
696: 696:                 }
697: 697:             }
698: 698:         }
699: 699:     }
700: 700: 
701: 701:     
702: 702:     function _onRandom(uint _rand, bytes32 _queryId) internal {
703: 703:         MobiusRound storage rnd = rounds[latestRoundID];
704: 704:         
705: 705:         if(rnd.softDeadline >= now && now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
706: 706:             _drawDailyJackpot(dailyRounds[latestDailyID], rnd, _rand);
707: 707:         }
708: 708:     }
709: 709: 
710: 710:     event FailedRNGVerification(bytes32 qID);
711: 711: 
712: 712:     function _onRandomFailed(bytes32 _queryId) internal {
713: 713:         emit FailedRNGVerification(_queryId);
714: 714:     }
715: 715: 
716: 716:     
717: 717:     function _triggerOraclize() public auth {
718: 718:         _requestRandom(0);
719: 719:     }
720: 720: 
721: 721:     function _drawDailyJackpot(DailyJackpotRound storage dRnd, MobiusRound storage rnd, uint _rand) internal {
722: 722:         if(dRnd.entrants.length != 0){
723: 723:             uint winner = _rand % dRnd.entrants.length;
724: 724:             uint prize = min(maxDailyJackpot, rnd.dailyJackpot / 2);
725: 725:             rnd.dailyJackpot = sub(rnd.dailyJackpot, prize);
726: 726:             vaults[dRnd.entrants[winner]].totalReturns = add(vaults[dRnd.entrants[winner]].totalReturns, prize);
727: 727:             emit DailyJackpotWon(dRnd.entrants[winner], prize);
728: 728:             dRnd.finalized = true;       
729: 729:             unclaimedReturns = add(unclaimedReturns, prize);
730: 730:             totalJackpotsWon += prize;
731: 731: 
732: 732:             _startNewDailyRound();
733: 733:         }        
734: 734:         rnd.lastDailyJackpot = now; 
735: 735:     }
736: 736: 
737: 737: }