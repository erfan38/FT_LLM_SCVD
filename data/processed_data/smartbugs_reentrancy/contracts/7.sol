1: 1: pragma solidity ^0.4.24;
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
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22: 
23: 23: 
24: 24: 
25: 25: 
26: 26: 
27: 27: 
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32: 
33: 33: 
34: 34: 
35: 35: 
36: 36: 
37: 37: 
38: 38: 
39: 39: 
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
99: 99: contract SnailFarm3 {
100: 100:     using SafeMath for uint;
101: 101:     
102: 102:     
103: 103:     
104: 104:     event FundedTree (address indexed player, uint eth, uint acorns);
105: 105:     event ClaimedShare (address indexed player, uint eth, uint acorns);
106: 106:     event BecameMaster (address indexed player, uint indexed round);
107: 107:     event WithdrewBalance (address indexed player, uint eth);
108: 108:     event Hatched (address indexed player, uint eggs, uint snails, uint hatchery);
109: 109:     event SoldEgg (address indexed player, uint eggs, uint eth);
110: 110:     event BoughtEgg (address indexed player, uint eggs, uint eth, uint playereggs);
111: 111:     event StartedSnailing (address indexed player, uint indexed round);
112: 112:     event BecameQueen (address indexed player, uint indexed round, uint spiderreq, uint hatchery);
113: 113:     event BecameDuke (address indexed player, uint indexed round, uint squirrelreq, uint playerreds);
114: 114:     event BecamePrince (address indexed player, uint indexed round, uint tadpolereq);
115: 115:     event WonRound (address indexed roundwinner, uint indexed round, uint eth);
116: 116:     event BeganRound (uint indexed round);
117: 117:     event JoinedRound (address indexed player, uint indexed round, uint playerreds);
118: 118:     event GrabbedHarvest (address indexed player, uint indexed round, uint eth, uint playerreds);
119: 119:     event UsedRed (address indexed player, uint eggs, uint snails, uint hatchery);
120: 120:     event FoundSlug (address indexed player, uint indexed round, uint snails);
121: 121:     event FoundLettuce (address indexed player, uint indexed round, uint lettucereq, uint playerreds);
122: 122:     event FoundCarrot (address indexed player, uint indexed round);
123: 123:     event PaidThrone (address indexed player, uint eth);
124: 124:     event BoostedPot (address indexed player, uint eth);
125: 125: 
126: 126:     
127: 127:     
128: 128:     uint256 public constant FUND_TIMESTAMP       = 1544385600; 
129: 129:     uint256 public constant START_TIMESTAMP      = 1544904000; 
130: 130:     uint256 public constant TIME_TO_HATCH_1SNAIL = 86400; 
131: 131:     uint256 public constant STARTING_SNAIL       = 300;
132: 132:     uint256 public constant FROGKING_REQ         = 1000000;
133: 133:     uint256 public constant ACORN_PRICE          = 0.001 ether;
134: 134:     uint256 public constant ACORN_MULT           = 10;
135: 135:     uint256 public constant STARTING_SNAIL_COST  = 0.004 ether;
136: 136:     uint256 public constant HATCHING_COST        = 0.0008 ether;
137: 137:     uint256 public constant SPIDER_BASE_REQ      = 80;
138: 138:     uint256 public constant SQUIRREL_BASE_REQ    = 2;
139: 139:     uint256 public constant TADPOLE_BASE_REQ     = 0.02 ether;
140: 140:     uint256 public constant SLUG_MIN_REQ         = 100000;
141: 141:     uint256 public constant LETTUCE_BASE_REQ     = 20;
142: 142:     uint256 public constant CARROT_COST          = 0.02 ether;
143: 143:     uint256 public constant HARVEST_COUNT        = 300;
144: 144:     uint256 public constant HARVEST_DURATION     = 14400; 
145: 145:     uint256 public constant HARVEST_DUR_ROOT     = 120; 
146: 146:     uint256 public constant HARVEST_MIN_COST     = 0.002 ether;
147: 147:     uint256 public constant SNAILMASTER_REQ      = 4096;
148: 148:     uint256 public constant ROUND_DOWNTIME       = 43200; 
149: 149:     address public constant SNAILTHRONE          = 0x261d650a521103428C6827a11fc0CBCe96D74DBc;
150: 150: 
151: 151:     
152: 152:     
153: 153: 	
154: 154:     bool public gameActive             = false;
155: 155: 	
156: 156: 	
157: 157:     address public dev;
158: 158: 	
159: 159: 	
160: 160:     uint256 public round                = 0;
161: 161: 	
162: 162: 	
163: 163: 	address public currentLeader;
164: 164: 	
165: 165: 	
166: 166:     address public currentSpiderOwner;
167: 167:     address public currentTadpoleOwner;
168: 168: 	address public currentSquirrelOwner;
169: 169: 	address public currentSnailmaster;
170: 170: 	
171: 171: 	
172: 172: 	uint256 public spiderReq;
173: 173:     uint256 public tadpoleReq;
174: 174: 	uint256 public squirrelReq;
175: 175: 	
176: 176: 	
177: 177: 	uint256 public lettuceReq;
178: 178: 	
179: 179: 	
180: 180: 	uint256 public snailmasterReq       = SNAILMASTER_REQ;
181: 181: 	
182: 182: 	
183: 183: 	uint256 public nextRoundStart;
184: 184: 	
185: 185: 	
186: 186: 	uint256 public harvestStartCost;
187: 187: 	
188: 188: 	
189: 189: 	uint256 public harvestStartTime;
190: 190: 	
191: 191: 	
192: 192: 	uint256 public maxAcorn             = 0;
193: 193: 	
194: 194: 	
195: 195: 	uint256 public divPerAcorn          = 0;
196: 196: 	
197: 197: 	
198: 198:     uint256 public marketEgg            = 0;
199: 199: 		
200: 200: 	
201: 201:     uint256 public snailPot             = 0;
202: 202:     uint256 public roundPot             = 0;
203: 203:     
204: 204: 	
205: 205:     uint256 public eggPot               = 0;
206: 206:     
207: 207:     
208: 208:     uint256 public thronePot            = 0;
209: 209: 
210: 210:     
211: 211:     
212: 212: 	mapping (address => bool) public hasStartingSnail;
213: 213: 	mapping (address => bool) public hasSlug;
214: 214: 	mapping (address => bool) public hasLettuce;
215: 215: 	mapping (address => uint256) public gotCarrot;
216: 216: 	mapping (address => uint256) public playerRound;
217: 217:     mapping (address => uint256) public hatcherySnail;
218: 218:     mapping (address => uint256) public claimedEgg;
219: 219:     mapping (address => uint256) public lastHatch;
220: 220:     mapping (address => uint256) public redEgg;
221: 221:     mapping (address => uint256) public playerBalance;
222: 222:     mapping (address => uint256) public prodBoost;
223: 223:     mapping (address => uint256) public acorn;
224: 224:     mapping (address => uint256) public claimedShare;
225: 225:     
226: 226:     
227: 227:     
228: 228:     
229: 229:     
230: 230:     
231: 231:     
232: 232:     constructor() public {
233: 233:         nextRoundStart = START_TIMESTAMP;
234: 234:         
235: 235:         
236: 236:         dev = msg.sender;
237: 237:         currentSnailmaster = msg.sender;
238: 238:         currentTadpoleOwner = msg.sender;
239: 239:         currentSquirrelOwner = msg.sender;
240: 240:         currentSpiderOwner = msg.sender;
241: 241:         currentLeader = msg.sender;
242: 242:         prodBoost[msg.sender] = 4; 
243: 243:     }
244: 244:     
245: 245:     
246: 246:     
247: 247:     
248: 248:     
249: 249:     function BeginRound() public {
250: 250:         require(gameActive == false, "cannot start round while game is active");
251: 251:         require(now > nextRoundStart, "round downtime isn't over");
252: 252:         require(snailPot > 0, "cannot start round on empty pot");
253: 253:         
254: 254:         round = round.add(1);
255: 255: 		marketEgg = STARTING_SNAIL;
256: 256:         roundPot = snailPot.div(10);
257: 257:         spiderReq = SPIDER_BASE_REQ;
258: 258:         tadpoleReq = TADPOLE_BASE_REQ;
259: 259:         squirrelReq = SQUIRREL_BASE_REQ;
260: 260:         lettuceReq = LETTUCE_BASE_REQ.mul(round);
261: 261:         if(snailmasterReq > 2) {
262: 262:             snailmasterReq = snailmasterReq.div(2);
263: 263:         }
264: 264:         harvestStartTime = now;
265: 265:         harvestStartCost = roundPot;
266: 266:         
267: 267:         gameActive = true;
268: 268:         
269: 269:         emit BeganRound(round);
270: 270:     }
271: 271:     
272: 272:     
273: 273:     
274: 274:     
275: 275:     
276: 276:     function FundTree() public payable {
277: 277:         require(tx.origin == msg.sender, "no contracts allowed");
278: 278:         require(now > FUND_TIMESTAMP, "funding hasn't started yet");
279: 279:         
280: 280:         uint256 _acornsBought = ComputeAcornBuy(msg.value);
281: 281:         
282: 282:         
283: 283:         claimedShare[msg.sender] = claimedShare[msg.sender].add(_acornsBought.mul(divPerAcorn));
284: 284:         
285: 285:         
286: 286:         maxAcorn = maxAcorn.add(_acornsBought);
287: 287:         
288: 288:         
289: 289:         PotSplit(msg.value);
290: 290:         
291: 291:         
292: 292:         acorn[msg.sender] = acorn[msg.sender].add(_acornsBought);
293: 293:         
294: 294:         emit FundedTree(msg.sender, msg.value, _acornsBought);
295: 295:     }
296: 296:     
297: 297:     
298: 298:     
299: 299:     
300: 300:     
301: 301:     function ClaimAcornShare() public {
302: 302:         
303: 303:         uint256 _playerShare = ComputeMyShare();
304: 304:         
305: 305:         if(_playerShare > 0) {
306: 306:             
307: 307:             
308: 308:             claimedShare[msg.sender] = claimedShare[msg.sender].add(_playerShare);
309: 309:             
310: 310:             
311: 311:             playerBalance[msg.sender] = playerBalance[msg.sender].add(_playerShare);
312: 312:             
313: 313:             emit ClaimedShare(msg.sender, _playerShare, acorn[msg.sender]);
314: 314:         }
315: 315:     }
316: 316:     
317: 317:     
318: 318:     
319: 319:     
320: 320:     
321: 321: 	
322: 322:     function BecomeSnailmaster() public {
323: 323:         require(gameActive, "game is paused");
324: 324:         require(playerRound[msg.sender] == round, "join new round to play");
325: 325:         require(redEgg[msg.sender] >= snailmasterReq, "not enough red eggs");
326: 326:         
327: 327:         redEgg[msg.sender] = redEgg[msg.sender].sub(snailmasterReq);
328: 328:         snailmasterReq = snailmasterReq.mul(2);
329: 329:         currentSnailmaster = msg.sender;
330: 330:         
331: 331:         emit BecameMaster(msg.sender, round);
332: 332:     }
333: 333:     
334: 334:     
335: 335:     
336: 336:     
337: 337:     function WithdrawBalance() public {
338: 338:         require(playerBalance[msg.sender] > 0, "no ETH in player balance");
339: 339:         
340: 340:         uint _amount = playerBalance[msg.sender];
341: 341:         playerBalance[msg.sender] = 0;
342: 342:         msg.sender.transfer(_amount);
343: 343:         
344: 344:         emit WithdrewBalance(msg.sender, _amount);
345: 345:     }
346: 346:     
347: 347:     
348: 348: 	
349: 349: 	
350: 350:     
351: 351:     function PotSplit(uint256 _msgValue) private {
352: 352:         
353: 353:         snailPot = snailPot.add(_msgValue.div(2));
354: 354:         eggPot = eggPot.add(_msgValue.div(4));
355: 355:         thronePot = thronePot.add(_msgValue.div(10));
356: 356:         
357: 357:         
358: 358:         divPerAcorn = divPerAcorn.add(_msgValue.div(10).div(maxAcorn));
359: 359:         
360: 360:         
361: 361:         playerBalance[currentSnailmaster] = playerBalance[currentSnailmaster].add(_msgValue.div(20));
362: 362:     }
363: 363:     
364: 364:     
365: 365:     
366: 366:     
367: 367:     function JoinRound() public {
368: 368:         require(gameActive, "game is paused");
369: 369:         require(playerRound[msg.sender] != round, "player already in current round");
370: 370:         require(hasStartingSnail[msg.sender] == true, "buy starting snails first");
371: 371:         
372: 372:         uint256 _bonusRed = hatcherySnail[msg.sender].div(100);
373: 373:         hatcherySnail[msg.sender] = STARTING_SNAIL;
374: 374:         redEgg[msg.sender] = redEgg[msg.sender].add(_bonusRed);
375: 375:         
376: 376:         
377: 377:         if(gotCarrot[msg.sender] > 0) {
378: 378:             gotCarrot[msg.sender] = gotCarrot[msg.sender].sub(1);
379: 379:             
380: 380:             
381: 381:             if(gotCarrot[msg.sender] == 0) {
382: 382:                 prodBoost[msg.sender] = prodBoost[msg.sender].sub(1);
383: 383:             }
384: 384:         }
385: 385:         
386: 386:         
387: 387:         if(hasLettuce[msg.sender]) {
388: 388:             prodBoost[msg.sender] = prodBoost[msg.sender].sub(1);
389: 389:             hasLettuce[msg.sender] = false;
390: 390:         }
391: 391:         
392: 392: 		
393: 393: 		lastHatch[msg.sender] = now;
394: 394:         playerRound[msg.sender] = round;
395: 395:         
396: 396:         emit JoinedRound(msg.sender, round, redEgg[msg.sender]);
397: 397:     }
398: 398:     
399: 399:     
400: 400:     
401: 401:     
402: 402:     
403: 403:     
404: 404:     function WinRound(address _msgSender) private {
405: 405:         
406: 406:         gameActive = false;
407: 407:         nextRoundStart = now.add(ROUND_DOWNTIME);
408: 408:         
409: 409:         hatcherySnail[_msgSender] = 0;
410: 410:         snailPot = snailPot.sub(roundPot);
411: 411:         playerBalance[_msgSender] = playerBalance[_msgSender].add(roundPot);
412: 412:         
413: 413:         emit WonRound(_msgSender, round, roundPot);
414: 414:     }
415: 415:     
416: 416:     
417: 417:     
418: 418:     
419: 419:     
420: 420:     function HatchEgg() public payable {
421: 421:         require(gameActive, "game is paused");
422: 422:         require(playerRound[msg.sender] == round, "join new round to play");
423: 423:         require(msg.value == HATCHING_COST, "wrong ETH cost");
424: 424:         
425: 425:         PotSplit(msg.value);
426: 426:         uint256 eggUsed = ComputeMyEgg(msg.sender);
427: 427:         uint256 newSnail = eggUsed.mul(prodBoost[msg.sender]);
428: 428:         claimedEgg[msg.sender] = 0;
429: 429:         lastHatch[msg.sender] = now;
430: 430:         hatcherySnail[msg.sender] = hatcherySnail[msg.sender].add(newSnail);
431: 431:         
432: 432:         if(hatcherySnail[msg.sender] > hatcherySnail[currentLeader]) {
433: 433:             currentLeader = msg.sender;
434: 434:         }
435: 435:         
436: 436:         if(hatcherySnail[msg.sender] >= FROGKING_REQ) {
437: 437:             WinRound(msg.sender);
438: 438:         }
439: 439:         
440: 440:         emit Hatched(msg.sender, eggUsed, newSnail, hatcherySnail[msg.sender]);
441: 441:     }
442: 442:     
443: 443:     
444: 444:     
445: 445: 	
446: 446:     
447: 447:     function SellEgg() public {
448: 448:         require(gameActive, "game is paused");
449: 449:         require(playerRound[msg.sender] == round, "join new round to play");
450: 450:         
451: 451:         uint256 eggSold = ComputeMyEgg(msg.sender);
452: 452:         uint256 eggValue = ComputeSell(eggSold);
453: 453:         claimedEgg[msg.sender] = 0;
454: 454:         lastHatch[msg.sender] = now;
455: 455:         marketEgg = marketEgg.add(eggSold);
456: 456:         eggPot = eggPot.sub(eggValue);
457: 457:         playerBalance[msg.sender] = playerBalance[msg.sender].add(eggValue);
458: 458:         
459: 459:         emit SoldEgg(msg.sender, eggSold, eggValue);
460: 460:     }
461: 461:     
462: 462:     
463: 463:     
464: 464: 	
465: 465: 	
466: 466:     
467: 467:     function BuyEgg() public payable {
468: 468:         require(gameActive, "game is paused");
469: 469:         require(playerRound[msg.sender] == round, "join new round to play");
470: 470:         
471: 471:         uint256 _eggBought = ComputeBuy(msg.value);
472: 472:         
473: 473:         
474: 474:         uint256 _ethSpent = msg.value;
475: 475:         
476: 476:         
477: 477:         
478: 478:         uint256 _maxBuy = eggPot.div(4);
479: 479:         if (msg.value > _maxBuy) {
480: 480:             uint _excess = msg.value.sub(_maxBuy);
481: 481:             playerBalance[msg.sender] = playerBalance[msg.sender].add(_excess);
482: 482:             _ethSpent = _maxBuy;
483: 483:         }  
484: 484:         
485: 485:         PotSplit(_ethSpent);
486: 486:         marketEgg = marketEgg.sub(_eggBought);
487: 487:         claimedEgg[msg.sender] = claimedEgg[msg.sender].add(_eggBought);
488: 488:         
489: 489:         emit BoughtEgg(msg.sender, _eggBought, _ethSpent, hatcherySnail[msg.sender]);
490: 490:     }
491: 491:     
492: 492:     
493: 493:     
494: 494:     
495: 495:     function BuyStartingSnail() public payable {
496: 496:         require(gameActive, "game is paused");
497: 497:         require(tx.origin == msg.sender, "no contracts allowed");
498: 498:         require(hasStartingSnail[msg.sender] == false, "player already active");
499: 499:         require(msg.value == STARTING_SNAIL_COST, "wrongETH cost");
500: 500:         require(msg.sender != dev, "shoo shoo, developer");
501: 501: 
502: 502:         PotSplit(msg.value);
503: 503: 		hasStartingSnail[msg.sender] = true;
504: 504:         lastHatch[msg.sender] = now;
505: 505: 		prodBoost[msg.sender] = 1;
506: 506: 		playerRound[msg.sender] = round;
507: 507:         hatcherySnail[msg.sender] = STARTING_SNAIL;
508: 508:         
509: 509:         emit StartedSnailing(msg.sender, round);
510: 510:     }
511: 511:     
512: 512:     
513: 513:     
514: 514:     
515: 515:     
516: 516:     function GrabRedHarvest() public payable {
517: 517:         require(gameActive, "game is paused");
518: 518:         require(playerRound[msg.sender] == round, "join new round to play");
519: 519:         
520: 520:         
521: 521:         uint256 _harvestCost = ComputeHarvest();
522: 522:         require(msg.value >= _harvestCost);
523: 523:         
524: 524:         
525: 525:         if (msg.value > _harvestCost) {
526: 526:             uint _excess = msg.value.sub(_harvestCost);
527: 527:             playerBalance[msg.sender] = playerBalance[msg.sender].add(_excess);
528: 528:         }
529: 529:         
530: 530:         PotSplit(_harvestCost);
531: 531:         
532: 532:         
533: 533:         harvestStartCost = roundPot;
534: 534:         harvestStartTime = now;
535: 535:         
536: 536:         
537: 537:         redEgg[msg.sender] = redEgg[msg.sender].add(HARVEST_COUNT);
538: 538:         
539: 539:         emit GrabbedHarvest(msg.sender, round, msg.value, redEgg[msg.sender]);
540: 540:     }
541: 541:     
542: 542:     
543: 543:     
544: 544:     
545: 545:     
546: 546:     function UseRedEgg(uint256 _redAmount) public {
547: 547:         require(gameActive, "game is paused");
548: 548:         require(playerRound[msg.sender] == round, "join new round to play");
549: 549:         require(redEgg[msg.sender] >= _redAmount, "not enough red eggs");
550: 550:         
551: 551:         redEgg[msg.sender] = redEgg[msg.sender].sub(_redAmount);
552: 552:         uint256 _newSnail = _redAmount.mul(prodBoost[msg.sender]);
553: 553:         hatcherySnail[msg.sender] = hatcherySnail[msg.sender].add(_newSnail);
554: 554:         
555: 555:         if(hatcherySnail[msg.sender] > hatcherySnail[currentLeader]) {
556: 556:             currentLeader = msg.sender;
557: 557:         }
558: 558:         
559: 559:         if(hatcherySnail[msg.sender] >= FROGKING_REQ) {
560: 560:             WinRound(msg.sender);
561: 561:         }
562: 562:         
563: 563:         emit UsedRed(msg.sender, _redAmount, _newSnail, hatcherySnail[msg.sender]);
564: 564:     }
565: 565:     
566: 566:     
567: 567:     
568: 568:     
569: 569:     
570: 570:     function FindSlug() public {
571: 571:         require(gameActive, "game is paused");
572: 572:         require(playerRound[msg.sender] == round, "join new round to play");
573: 573:         require(hasSlug[msg.sender] == false, "already owns slug");
574: 574:         require(hatcherySnail[msg.sender] >= SLUG_MIN_REQ, "not enough snails");
575: 575:         
576: 576: 		uint256 _sacrifice = hatcherySnail[msg.sender];
577: 577:         hatcherySnail[msg.sender] = 0;
578: 578:         hasSlug[msg.sender] = true;
579: 579:         prodBoost[msg.sender] = prodBoost[msg.sender].add(1);
580: 580: 
581: 581:         emit FoundSlug(msg.sender, round, _sacrifice);
582: 582:     }
583: 583:     
584: 584:     
585: 585:     
586: 586:     
587: 587:     
588: 588:     function FindLettuce() public {
589: 589:         require(gameActive, "game is paused");
590: 590:         require(playerRound[msg.sender] == round, "join new round to play");
591: 591:         require(hasLettuce[msg.sender] == false, "already owns lettuce");
592: 592:         require(redEgg[msg.sender] >= lettuceReq, "not enough red eggs");
593: 593:         
594: 594:         uint256 _eventLettuceReq = lettuceReq;
595: 595:         redEgg[msg.sender] = redEgg[msg.sender].sub(lettuceReq);
596: 596:         lettuceReq = lettuceReq.sub(LETTUCE_BASE_REQ);
597: 597:         if(lettuceReq < LETTUCE_BASE_REQ) {
598: 598:             lettuceReq = LETTUCE_BASE_REQ;
599: 599:         }
600: 600:         
601: 601:         hasLettuce[msg.sender] = true;
602: 602:         prodBoost[msg.sender] = prodBoost[msg.sender].add(1);
603: 603: 
604: 604:         emit FoundLettuce(msg.sender, round, _eventLettuceReq, redEgg[msg.sender]);
605: 605:     }
606: 606:     
607: 607:     
608: 608:     
609: 609:     
610: 610:     function FindCarrot() public payable {
611: 611:         require(gameActive, "game is paused");
612: 612:         require(playerRound[msg.sender] == round, "join new round to play");
613: 613:         require(gotCarrot[msg.sender] == 0, "already owns carrot");
614: 614:         require(msg.value == CARROT_COST);
615: 615:         
616: 616:         PotSplit(msg.value);
617: 617:         gotCarrot[msg.sender] = 3;
618: 618:         prodBoost[msg.sender] = prodBoost[msg.sender].add(1);
619: 619: 
620: 620:         emit FoundCarrot(msg.sender, round);
621: 621:     }
622: 622:     
623: 623:     
624: 624:     
625: 625:     
626: 626:     function PayThrone() public {
627: 627:         uint256 _payThrone = thronePot;
628: 628:         thronePot = 0;
629: 629:         if (!SNAILTHRONE.call.value(_payThrone)()){
630: 630:             revert();
631: 631:         }
632: 632:         
633: 633:         emit PaidThrone(msg.sender, _payThrone);
634: 634:     }
635: 635:     
636: 636:     
637: 637:     
638: 638: 	
639: 639:     
640: 640:     function BecomeSpiderQueen() public {
641: 641:         require(gameActive, "game is paused");
642: 642:         require(playerRound[msg.sender] == round, "join new round to play");
643: 643:         require(hatcherySnail[msg.sender] >= spiderReq, "not enough snails");
644: 644: 
645: 645:         
646: 646:         hatcherySnail[msg.sender] = hatcherySnail[msg.sender].sub(spiderReq);
647: 647:         spiderReq = spiderReq.mul(2);
648: 648:         
649: 649:         
650: 650:         prodBoost[currentSpiderOwner] = prodBoost[currentSpiderOwner].sub(1);
651: 651:         
652: 652:         
653: 653:         currentSpiderOwner = msg.sender;
654: 654:         prodBoost[currentSpiderOwner] = prodBoost[currentSpiderOwner].add(1);
655: 655:         
656: 656:         emit BecameQueen(msg.sender, round, spiderReq, hatcherySnail[msg.sender]);
657: 657:     }
658: 658: 	
659: 659: 	
660: 660: 	
661: 661:     
662: 662:     
663: 663:     function BecomeSquirrelDuke() public {
664: 664:         require(gameActive, "game is paused");
665: 665:         require(playerRound[msg.sender] == round, "join new round to play");
666: 666:         require(redEgg[msg.sender] >= squirrelReq, "not enough red eggs");
667: 667:         
668: 668:         
669: 669:         redEgg[msg.sender] = redEgg[msg.sender].sub(squirrelReq);
670: 670:         squirrelReq = squirrelReq.mul(2);
671: 671:         
672: 672:         
673: 673:         prodBoost[currentSquirrelOwner] = prodBoost[currentSquirrelOwner].sub(1);
674: 674:         
675: 675:         
676: 676:         currentSquirrelOwner = msg.sender;
677: 677:         prodBoost[currentSquirrelOwner] = prodBoost[currentSquirrelOwner].add(1);
678: 678:         
679: 679:         emit BecameDuke(msg.sender, round, squirrelReq, redEgg[msg.sender]);
680: 680:     }
681: 681:     
682: 682:     
683: 683:     
684: 684: 	
685: 685:     
686: 686:     
687: 687:     function BecomeTadpolePrince() public payable {
688: 688:         require(gameActive, "game is paused");
689: 689:         require(playerRound[msg.sender] == round, "join new round to play");
690: 690:         require(msg.value >= tadpoleReq, "not enough ETH");
691: 691:         
692: 692:         
693: 693:         if (msg.value > tadpoleReq) {
694: 694:             uint _excess = msg.value.sub(tadpoleReq);
695: 695:             playerBalance[msg.sender] = playerBalance[msg.sender].add(_excess);
696: 696:         }  
697: 697:         
698: 698:         
699: 699:         
700: 700:         uint _extra = tadpoleReq.div(12); 
701: 701:         PotSplit(_extra);
702: 702:         
703: 703:         
704: 704:         
705: 705:         uint _previousFlip = tadpoleReq.mul(11).div(12);
706: 706:         playerBalance[currentTadpoleOwner] = playerBalance[currentTadpoleOwner].add(_previousFlip);
707: 707:         
708: 708:         
709: 709:         tadpoleReq = (tadpoleReq.mul(6)).div(5); 
710: 710:         
711: 711:         
712: 712:         prodBoost[currentTadpoleOwner] = prodBoost[currentTadpoleOwner].sub(1);
713: 713:         
714: 714:         
715: 715:         currentTadpoleOwner = msg.sender;
716: 716:         prodBoost[currentTadpoleOwner] = prodBoost[currentTadpoleOwner].add(1);
717: 717:         
718: 718:         emit BecamePrince(msg.sender, round, tadpoleReq);
719: 719:     }
720: 720:     
721: 721:     
722: 722:     
723: 723:     
724: 724:     function() public payable {
725: 725:         snailPot = snailPot.add(msg.value);
726: 726:         
727: 727:         emit BoostedPot(msg.sender, msg.value);
728: 728:     }
729: 729:     
730: 730:     
731: 731:     
732: 732:     
733: 733:     
734: 734:     
735: 735:     function ComputeAcornCost() public view returns(uint256) {
736: 736:         uint256 _acornCost;
737: 737:         if(round != 0) {
738: 738:             _acornCost = ACORN_PRICE.mul(ACORN_MULT).div(ACORN_MULT.add(round));
739: 739:         } else {
740: 740:             _acornCost = ACORN_PRICE.div(2);
741: 741:         }
742: 742:         return _acornCost;
743: 743:     }
744: 744:     
745: 745:     
746: 746:     
747: 747:     
748: 748:     function ComputeAcornBuy(uint256 _ether) public view returns(uint256) {
749: 749:         uint256 _costPerAcorn = ComputeAcornCost();
750: 750:         return _ether.div(_costPerAcorn);
751: 751:     }
752: 752:     
753: 753:     
754: 754:     
755: 755:     
756: 756:     function ComputeMyShare() public view returns(uint256) {
757: 757:         
758: 758:         uint256 _playerShare = divPerAcorn.mul(acorn[msg.sender]);
759: 759: 		
760: 760:         
761: 761:     	_playerShare = _playerShare.sub(claimedShare[msg.sender]);
762: 762:         return _playerShare;
763: 763:     }
764: 764:     
765: 765:     
766: 766:     
767: 767:     
768: 768:     
769: 769:     function ComputeHarvest() public view returns(uint256) {
770: 770: 
771: 771:         
772: 772:         uint256 _timeLapsed = now.sub(harvestStartTime);
773: 773:         
774: 774:         
775: 775:         if(_timeLapsed > HARVEST_DURATION) {
776: 776:             _timeLapsed = HARVEST_DURATION;
777: 777:         }
778: 778:         
779: 779:         
780: 780:         _timeLapsed = ComputeSquare(_timeLapsed);
781: 781:         
782: 782:         
783: 783:         uint256 _priceChange = harvestStartCost.sub(HARVEST_MIN_COST);
784: 784:         
785: 785:         
786: 786:         uint256 _harvestFactor = _priceChange.mul(_timeLapsed).div(HARVEST_DUR_ROOT);
787: 787:         
788: 788:         
789: 789:         return harvestStartCost.sub(_harvestFactor);
790: 790:     }
791: 791:     
792: 792:     
793: 793:     
794: 794:     
795: 795:     function ComputeSquare(uint256 base) public pure returns (uint256 squareRoot) {
796: 796:         uint256 z = (base + 1) / 2;
797: 797:         squareRoot = base;
798: 798:         while (z < squareRoot) {
799: 799:             squareRoot = z;
800: 800:             z = (base / z + z) / 2;
801: 801:         }
802: 802:     }
803: 803:     
804: 804:     
805: 805: 	
806: 806: 	
807: 807: 	
808: 808:     
809: 809:     function ComputeSell(uint256 eggspent) public view returns(uint256) {
810: 810:         uint256 _eggPool = eggspent.add(marketEgg);
811: 811:         uint256 _eggFactor = eggspent.mul(eggPot).div(_eggPool);
812: 812:         return _eggFactor.div(2);
813: 813:     }
814: 814:     
815: 815:     
816: 816: 	
817: 817:     
818: 818:     
819: 819:     
820: 820:     function ComputeBuy(uint256 ethspent) public view returns(uint256) {
821: 821:         uint256 _ethPool = ethspent.add(eggPot);
822: 822:         uint256 _ethFactor = ethspent.mul(marketEgg).div(_ethPool);
823: 823:         uint256 _maxBuy = marketEgg.div(5);
824: 824:         if(_ethFactor > _maxBuy) {
825: 825:             _ethFactor = _maxBuy;
826: 826:         }
827: 827:         return _ethFactor;
828: 828:     }
829: 829:     
830: 830:     
831: 831:     
832: 832: 	
833: 833:     
834: 834:     function ComputeMyEgg(address adr) public view returns(uint256) {
835: 835:         uint256 _eggs = now.sub(lastHatch[adr]);
836: 836:         _eggs = _eggs.mul(hatcherySnail[adr]).div(TIME_TO_HATCH_1SNAIL);
837: 837:         if (_eggs > hatcherySnail[adr]) {
838: 838:             _eggs = hatcherySnail[adr];
839: 839:         }
840: 840:         _eggs = _eggs.add(claimedEgg[adr]);
841: 841:         return _eggs;
842: 842:     }
843: 843: 
844: 844:     
845: 845:     
846: 846:     function GetSnail(address adr) public view returns(uint256) {
847: 847:         return hatcherySnail[adr];
848: 848:     }
849: 849:     
850: 850:     function GetAcorn(address adr) public view returns(uint256) {
851: 851:         return acorn[adr];
852: 852:     }
853: 853: 	
854: 854: 	function GetProd(address adr) public view returns(uint256) {
855: 855: 		return prodBoost[adr];
856: 856: 	}
857: 857:     
858: 858:     function GetMyEgg() public view returns(uint256) {
859: 859:         return ComputeMyEgg(msg.sender);
860: 860:     }
861: 861: 	
862: 862: 	function GetMyBalance() public view returns(uint256) {
863: 863: 	    return playerBalance[msg.sender];
864: 864: 	}
865: 865: 	
866: 866: 	function GetRed(address adr) public view returns(uint256) {
867: 867: 	    return redEgg[adr];
868: 868: 	}
869: 869: 	
870: 870: 	function GetLettuce(address adr) public view returns(bool) {
871: 871: 	    return hasLettuce[adr];
872: 872: 	}
873: 873: 	
874: 874: 	function GetCarrot(address adr) public view returns(uint256) {
875: 875: 	    return gotCarrot[adr];
876: 876: 	}
877: 877: 	
878: 878: 	function GetSlug(address adr) public view returns(bool) {
879: 879: 	    return hasSlug[adr];
880: 880: 	}
881: 881: 	
882: 882: 	function GetMyRound() public view returns(uint256) {
883: 883: 	    return playerRound[msg.sender];
884: 884: 	}
885: 885: }
886: 886: 
887: 887: library SafeMath {
888: 888: 
889: 889:   
890: 890: 
891: 891: 
892: 892:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
893: 893:     if (a == 0) {
894: 894:       return 0;
895: 895:     }
896: 896:     uint256 c = a * b;
897: 897:     assert(c / a == b);
898: 898:     return c;
899: 899:   }
900: 900: 
901: 901:   
902: 902: 
903: 903: 
904: 904:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
905: 905:     
906: 906:     uint256 c = a / b;
907: 907:     
908: 908:     return c;
909: 909:   }
910: 910: 
911: 911:   
912: 912: 
913: 913: 
914: 914:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
915: 915:     assert(b <= a);
916: 916:     return a - b;
917: 917:   }
918: 918: 
919: 919:   
920: 920: 
921: 921: 
922: 922:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
923: 923:     uint256 c = a + b;
924: 924:     assert(c >= a);
925: 925:     return c;
926: 926:   }
927: 927: }