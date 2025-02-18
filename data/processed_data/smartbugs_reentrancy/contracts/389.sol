1: pragma solidity^0.4.24;
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: 
10: 
11: 
12: interface MobiusToken {
13:     function disburseDividends() external payable;
14: }
15: 
16: interface LastVersion {
17:     function withdrawReturns() external;
18:     function roundInfo(uint roundID) external view 
19:     returns(
20:         address leader, 
21:         uint price,
22:         uint jackpot, 
23:         uint airdrop, 
24:         uint shares, 
25:         uint totalInvested,
26:         uint distributedReturns,
27:         uint _hardDeadline,
28:         uint _softDeadline,
29:         bool finalized
30:         );
31:     function totalsInfo() external view 
32:     returns(
33:         uint totalReturns,
34:         uint totalShares,
35:         uint totalDividends,
36:         uint totalJackpots
37:     );
38:     function latestRoundID() external returns(uint);
39: }
40: 
41: 
42: 
43: 
44: 
45: 
46: 
47: 
48: 
49: 
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
68: 
69: 
70: 
71: 
72: 
73: 
74: 
75: 
76: 
77: 
78: 
79: 
80: 
81: 
82: 
83: 
84: 
85: 
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
97: 
98: 
99: 
100: 
101:  
102: contract Mobius2Dv2 is UsingOraclizeRandom, DSMath {
103:     
104:     
105:     string public ipfsHash;
106:     string public ipfsHashType = "ipfs"; 
107: 
108:     MobiusToken public constant token = MobiusToken(0x54cdC9D889c28f55F59f6b136822868c7d4726fC);
109: 
110:     
111:     
112:     bool public upgraded;
113:     bool public initialized;
114:     address public nextVersion;
115:     LastVersion public constant lastVersion = LastVersion(0xA74642Aeae3e2Fd79150c910eB5368B64f864B1e);
116:     uint public previousRounds;
117: 
118:     
119:     uint public totalRevenue;
120:     uint public totalSharesSold;
121:     uint public totalEarningsGenerated;
122:     uint public totalDividendsPaid;
123:     uint public totalJackpotsWon;
124: 
125:     
126:     uint public constant DEV_DIVISOR = 20;                      
127: 
128:     uint public constant RETURNS_FRACTION = 60 * 10**16;        
129:     
130:     uint public constant REFERRAL_FRACTION = 3 * 10**16;        
131: 
132:     uint public constant JACKPOT_SEED_FRACTION = WAD / 20;      
133:     uint public constant JACKPOT_FRACTION = 15 * 10**16;        
134:     uint public constant DAILY_JACKPOT_FRACTION = 6 * 10**16;    
135:     uint public constant DIVIDENDS_FRACTION = 9 * 10**16;       
136: 
137:     
138:     uint public startingSharePrice = 1 finney;   
139:     uint public _priceIncreasePeriod = 1 hours;  
140:     uint public _priceMultiplier = 101 * 10**16; 
141: 
142:     uint public _secondaryPrice = 100 finney;    
143:     uint public maxDailyJackpot = 5 ether; 
144: 
145:     uint public constant SOFT_DEADLINE_DURATION = 1 days; 
146:     uint public constant DAILY_JACKPOT_PERIOD = 1 days;
147:     uint public constant TIME_PER_SHARE = 5 minutes; 
148: 
149:     uint public nextRoundTime; 
150:     uint public jackpotSeed;
151:     uint public devBalance; 
152: 
153:     
154:     uint public unclaimedReturns;
155:     uint public constant MULTIPLIER = RAY;
156: 
157:     
158:     mapping (address => uint) public lastDailyEntry;
159: 
160:     
161:     
162:     struct Investor {
163:         uint lastCumulativeReturnsPoints;
164:         uint shares;
165:     }
166: 
167:     
168:     struct MobiusRound {
169:         uint totalInvested;        
170:         uint jackpot;
171:         uint dailyJackpot;
172:         uint totalShares;
173:         uint cumulativeReturnsPoints; 
174:         uint softDeadline;
175:         uint price;
176:         uint secondaryPrice;
177:         uint priceMultiplier;
178:         uint priceIncreasePeriod;
179:         uint lastPriceIncreaseTime;
180:         uint lastDailyJackpot;
181:         address lastInvestor;
182:         bool finalized;
183:         mapping (address => Investor) investors;
184:     }
185: 
186:     struct DailyJackpotRound {
187:         address[] entrants;
188:         address winner;
189:         bool finalized;
190:     }
191: 
192:     struct Vault {
193:         uint totalReturns; 
194:         uint refReturns; 
195:     }
196: 
197:     mapping (address => Vault) vaults;
198: 
199:     uint public latestRoundID;
200:     uint public latestDailyID;
201:     MobiusRound[] rounds;
202:     DailyJackpotRound[] dailyRounds;
203: 
204:     event SharesIssued(address indexed to, uint shares);
205:     event ReturnsWithdrawn(address indexed by, uint amount);
206:     event JackpotWon(address by, uint amount);
207:     event DailyJackpotWon(address indexed by, uint amount);
208:     event RoundStarted(uint ID, uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod);
209:     event IPFSHashSet(string _type, string _hash);
210: 
211:     constructor() public {
212:     }
213: 
214:     function initOraclize() public auth {
215:         oraclizeCallbackGas = 250000;
216:         if(oraclize_setNetwork()){
217:             oraclize_setProof(proofType_Ledger);
218:         }
219:     }
220: 
221:     
222:     
223:     function estimateReturns(address investor, uint roundID) public view 
224:     returns (uint totalReturns, uint refReturns) 
225:     {
226:         MobiusRound storage rnd = rounds[roundID];
227:         uint outstanding;
228:         if(rounds.length > 1) {
229:             if(hasReturns(investor, roundID - 1)) {
230:                 MobiusRound storage prevRnd = rounds[roundID - 1];
231:                 outstanding = _outstandingReturns(investor, prevRnd);
232:             }
233:         }
234: 
235:         outstanding += _outstandingReturns(investor, rnd);
236:         
237:         totalReturns = vaults[investor].totalReturns + outstanding;
238:         refReturns = vaults[investor].refReturns;
239:     }
240: 
241:     function hasReturns(address investor, uint roundID) public view returns (bool) {
242:         MobiusRound storage rnd = rounds[roundID];
243:         return rnd.cumulativeReturnsPoints > rnd.investors[investor].lastCumulativeReturnsPoints;
244:     }
245: 
246:     function investorInfo(address investor, uint roundID) external view
247:     returns(uint shares, uint totalReturns, uint referralReturns, bool inNextDailyDraw) 
248:     {
249:         MobiusRound storage rnd = rounds[roundID];
250:         shares = rnd.investors[investor].shares;
251:         (totalReturns, referralReturns) = estimateReturns(investor, roundID);
252:         inNextDailyDraw = lastDailyEntry[investor] > rnd.lastDailyJackpot;
253:     }
254: 
255:     function roundInfo(uint roundID) external view 
256:     returns(
257:         address leader, 
258:         uint price,
259:         uint secondaryPrice,
260:         uint priceMultiplier,
261:         uint priceIncreasePeriod,
262:         uint jackpot, 
263:         uint dailyJackpot, 
264:         uint lastDailyJackpot,
265:         uint shares, 
266:         uint totalInvested,
267:         uint distributedReturns,
268:         uint _softDeadline,
269:         bool finalized
270:         )
271:     {
272:         MobiusRound storage rnd = rounds[roundID];
273:         leader = rnd.lastInvestor;
274:         price = rnd.price;
275:         secondaryPrice = _secondaryPrice;
276:         priceMultiplier = rnd.priceMultiplier;
277:         priceIncreasePeriod = rnd.priceIncreasePeriod;
278:         jackpot = rnd.jackpot;
279:         dailyJackpot = min(maxDailyJackpot, rnd.dailyJackpot/2);
280:         lastDailyJackpot = rnd.lastDailyJackpot;
281:         shares = rnd.totalShares;
282:         totalInvested = rnd.totalInvested;
283:         distributedReturns = wmul(rnd.totalInvested, RETURNS_FRACTION);
284:         _softDeadline = rnd.softDeadline;
285:         finalized = rnd.finalized;
286:     }
287: 
288:     function totalsInfo() external view 
289:     returns(
290:         uint totalReturns,
291:         uint totalShares,
292:         uint totalDividends,
293:         uint totalJackpots,
294:         uint totalInvested,
295:         uint totalRounds
296:     ) {
297:         MobiusRound storage rnd = rounds[latestRoundID];
298:         if(rnd.softDeadline > now) {
299:             totalShares = totalSharesSold + rnd.totalShares;
300:             totalReturns = totalEarningsGenerated + wmul(rnd.totalInvested, RETURNS_FRACTION);
301:             totalDividends = totalDividendsPaid + wmul(rnd.totalInvested, DIVIDENDS_FRACTION);
302:             totalInvested = totalRevenue + rnd.totalInvested;
303:         } else {
304:             totalShares = totalSharesSold;
305:             totalReturns = totalEarningsGenerated;
306:             totalDividends = totalDividendsPaid;
307:             totalInvested = totalRevenue;
308:         }
309:         totalJackpots = totalJackpotsWon;
310:         totalRounds = previousRounds + rounds.length;
311:     }
312: 
313:     function () public payable {
314:         if(!initialized){
315:             jackpotSeed += msg.value;
316:         } else {
317:             buyShares(address(0x0));
318:         }
319:     }
320: 
321:     
322:     function buyShares(address ref) public payable {        
323:         if(rounds.length > 0) {
324:             MobiusRound storage rnd = rounds[latestRoundID];                  
325:             _purchase(rnd, msg.value, ref);            
326:         } else {
327:             revert("Not yet started");
328:         }
329:     }
330: 
331:     
332:     function reinvestReturns(uint value) public {        
333:         reinvestReturns(value, address(0x0));
334:     }
335: 
336:     function reinvestReturns(uint value, address ref) public {        
337:         MobiusRound storage rnd = rounds[latestRoundID];
338:         _updateReturns(msg.sender, rnd);        
339:         require(vaults[msg.sender].totalReturns >= value, "Can't spend what you don't have");        
340:         vaults[msg.sender].totalReturns = sub(vaults[msg.sender].totalReturns, value);
341:         vaults[msg.sender].refReturns = min(vaults[msg.sender].refReturns, vaults[msg.sender].totalReturns);
342:         unclaimedReturns = sub(unclaimedReturns, value);
343:         _purchase(rnd, value, ref);
344:     }
345: 
346:     function withdrawReturns() public {
347:         MobiusRound storage rnd = rounds[latestRoundID];
348: 
349:         if(rounds.length > 1) {
350:             if(hasReturns(msg.sender, latestRoundID - 1)) {
351:                 MobiusRound storage prevRnd = rounds[latestRoundID - 1];
352:                 _updateReturns(msg.sender, prevRnd);
353:             }
354:         }
355:         _updateReturns(msg.sender, rnd);
356:         uint amount = vaults[msg.sender].totalReturns;
357:         require(amount > 0, "Nothing to withdraw!");
358:         unclaimedReturns = sub(unclaimedReturns, amount);
359:         vaults[msg.sender].totalReturns = 0;
360:         vaults[msg.sender].refReturns = 0;
361:         
362:         rnd.investors[msg.sender].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
363:         msg.sender.transfer(amount);
364: 
365:         emit ReturnsWithdrawn(msg.sender, amount);
366:     }
367: 
368:     
369:     function updateMyReturns(uint roundID) public {
370:         MobiusRound storage rnd = rounds[roundID];
371:         _updateReturns(msg.sender, rnd);
372:     }
373: 
374:     function finalizeAndRestart() public payable {
375:         finalizeLastRound();
376:         startNewRound();
377:     }
378: 
379:     
380:     function startNewRound() public payable {
381:         require(!upgraded && initialized, "This contract has been upgraded, or is not yet initialized!");
382:         require(now >= nextRoundTime, "Too early!");
383:         if(rounds.length > 0) {
384:             require(rounds[latestRoundID].finalized, "Previous round not finalized");
385:             require(rounds[latestRoundID].softDeadline < now, "Previous round still running");
386:         }
387:         uint _rID = rounds.length++;
388:         MobiusRound storage rnd = rounds[_rID];
389:         latestRoundID = _rID;
390: 
391:         rnd.lastInvestor = msg.sender;
392:         rnd.price = startingSharePrice;
393:         rnd.secondaryPrice = _secondaryPrice;
394:         rnd.priceMultiplier = _priceMultiplier;
395:         rnd.priceIncreasePeriod = _priceIncreasePeriod;
396:         rnd.lastPriceIncreaseTime = now;
397:         rnd.lastDailyJackpot = now;
398:         rnd.softDeadline = now + SOFT_DEADLINE_DURATION;
399:         rnd.jackpot = jackpotSeed;
400:         jackpotSeed = 0; 
401:         _startNewDailyRound();
402:         _purchase(rnd, msg.value, address(0x0));
403:         emit RoundStarted(_rID, startingSharePrice, _priceMultiplier, _priceIncreasePeriod);
404:     }
405: 
406:     
407:     function finalizeLastRound() public {
408:         MobiusRound storage rnd = rounds[latestRoundID];
409:         _finalizeRound(rnd);
410:     }
411: 
412:     function setRoundParams(uint startingPrice, uint priceMultiplier, uint priceIncreasePeriod) public auth {
413:         startingSharePrice = startingPrice;
414:         _priceMultiplier = priceMultiplier;
415:         _priceIncreasePeriod = priceIncreasePeriod;
416:     }
417: 
418:     function setSecondaryPrice(uint newPrice) public auth {
419:         _secondaryPrice = newPrice;
420:     }
421: 
422:     function setMaxDailyJackpot(uint newLimit) public auth {
423:         maxDailyJackpot = newLimit;
424:     }
425: 
426:     
427:     function setNextRoundTimestamp(uint timestamp) public auth {
428:         require(now > nextRoundTime);
429:         require(timestamp <= now + 2 days);
430:         nextRoundTime = timestamp;
431:     }
432: 
433:     function setNextRoundDelay(uint delayInSeconds) public auth {
434:         require(now > nextRoundTime);
435:         require(now + delayInSeconds <= now + 2 days);
436:         nextRoundTime = now + delayInSeconds;
437:     }
438:     
439:     
440:     function withdrawDevShare() public auth {
441:         uint value = sub(devBalance, totalPaidOraclize); 
442:         devBalance = 0;
443:         totalPaidOraclize = 0;
444:         msg.sender.transfer(value);
445:     }
446: 
447:     function setIPFSHash(string _type, string _hash) public auth {
448:         ipfsHashType = _type;
449:         ipfsHash = _hash;
450:         emit IPFSHashSet(_type, _hash);
451:     }
452: 
453:     function upgrade(address _nextVersion) public auth {
454:         require(_nextVersion != address(0x0), "Invalid Address!");
455:         require(!upgraded, "Already upgraded!");
456:         upgraded = true;
457:         nextVersion = _nextVersion;
458:     }
459: 
460:     
461:     function getSeed() public {
462:         require(upgraded, "Not upgraded!");
463:         require(msg.sender == nextVersion, "You can't do that!");
464:         MobiusRound storage rnd = rounds[latestRoundID];
465:         require(rnd.finalized, "Still running!");
466:         
467:         require(nextVersion.call.value(jackpotSeed)(), "Transfer failed!");
468:     }
469: 
470:     
471:     
472:     function init() public auth {
473:         
474:         require(!initialized, "Already initialized!");
475:         uint _rID = lastVersion.latestRoundID();
476:         previousRounds = 1 + _rID;
477:         uint _shares;
478:         uint _invested;
479:         uint _returns;
480:         uint _dividends;
481:         uint _jackpots;
482:         bool finalized;
483:         ( , , , , , _invested, , , , finalized) = lastVersion.roundInfo(_rID);
484:         require(finalized, "Last round is still not finalized!");
485:         (_returns, _shares, _dividends, _jackpots) = lastVersion.totalsInfo();
486: 
487:         totalSharesSold = _shares;
488:         totalRevenue = _invested;
489:         totalEarningsGenerated = _returns;
490:         totalDividendsPaid = _dividends;
491:         totalJackpotsWon = _jackpots;
492:         
493:         
494:         
495:         initialized = true;
496:     }
497: 
498:     function _startNewDailyRound() internal {
499:         if(dailyRounds.length > 0) {
500:             require(dailyRounds[latestDailyID].finalized, "Previous round not finalized");
501:         }
502:         uint _rID = dailyRounds.length++;
503:         latestDailyID = _rID;
504:     }
505: 
506:     
507:     function _purchase(MobiusRound storage rnd, uint value, address ref) internal {
508:         require(rnd.softDeadline >= now, "After deadline!");
509:         require(value >= 100 szabo, "Not enough Ether!");
510:         rnd.totalInvested = add(rnd.totalInvested, value);
511: 
512:         
513:         if(value >= rnd.price) {
514:             rnd.lastInvestor = msg.sender;
515:         }
516:         
517:         _dailyJackpot(rnd, value);
518:         
519:         _splitRevenue(rnd, value, ref);
520:         
521:         _updateReturns(msg.sender, rnd);
522:         
523:         uint newShares = _issueShares(rnd, msg.sender, value);
524: 
525:         uint timeIncreases = newShares/WAD;
526:         
527:         uint newDeadline = add(rnd.softDeadline, mul(timeIncreases, TIME_PER_SHARE));
528:         rnd.softDeadline = min(newDeadline, now + SOFT_DEADLINE_DURATION);
529:         
530:         
531:         if(now > rnd.lastPriceIncreaseTime + rnd.priceIncreasePeriod) {
532:             rnd.price = wmul(rnd.price, rnd.priceMultiplier);
533:             rnd.lastPriceIncreaseTime = now;
534:         }
535:         
536:     }
537: 
538:     function _finalizeRound(MobiusRound storage rnd) internal {
539:         require(!rnd.finalized, "Already finalized!");
540:         require(rnd.softDeadline < now, "Round still running!");
541: 
542:         
543:         vaults[rnd.lastInvestor].totalReturns = add(vaults[rnd.lastInvestor].totalReturns, rnd.jackpot);
544:         unclaimedReturns = add(unclaimedReturns, rnd.jackpot);
545:         
546:         emit JackpotWon(rnd.lastInvestor, rnd.jackpot);
547:         totalJackpotsWon += rnd.jackpot;
548:         
549:         jackpotSeed = add(jackpotSeed, wmul(rnd.totalInvested, JACKPOT_SEED_FRACTION));
550:         
551:         jackpotSeed = add(jackpotSeed, rnd.dailyJackpot);
552:                
553:         
554:         uint _div = wmul(rnd.totalInvested, DIVIDENDS_FRACTION);            
555:         
556:         token.disburseDividends.value(_div)();
557:         totalDividendsPaid += _div;
558:         totalSharesSold += rnd.totalShares;
559:         totalEarningsGenerated += wmul(rnd.totalInvested, RETURNS_FRACTION);
560:         totalRevenue += rnd.totalInvested;
561:         dailyRounds[latestDailyID].finalized = true;
562:         rnd.finalized = true;
563:     }
564: 
565:     
566: 
567: 
568: 
569:     function _updateReturns(address _investor, MobiusRound storage rnd) internal {
570:         if(rnd.investors[_investor].shares == 0) {
571:             return;
572:         }
573:         
574:         uint outstanding = _outstandingReturns(_investor, rnd);
575: 
576:         
577:         if (outstanding > 0) {
578:             vaults[_investor].totalReturns = add(vaults[_investor].totalReturns, outstanding);
579:         }
580: 
581:         rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
582:     }
583: 
584:     function _outstandingReturns(address _investor, MobiusRound storage rnd) internal view returns(uint) {
585:         if(rnd.investors[_investor].shares == 0) {
586:             return 0;
587:         }
588:         
589:         uint newReturns = sub(
590:             rnd.cumulativeReturnsPoints, 
591:             rnd.investors[_investor].lastCumulativeReturnsPoints
592:             );
593: 
594:         uint outstanding = 0;
595:         if(newReturns != 0) { 
596:             
597:             
598:             outstanding = mul(newReturns, rnd.investors[_investor].shares) / MULTIPLIER;
599:         }
600: 
601:         return outstanding;
602:     }
603: 
604:     
605:     function _splitRevenue(MobiusRound storage rnd, uint value, address ref) internal {
606:         uint roundReturns;
607:         
608:         if(ref != address(0x0) && ref != msg.sender) {
609:             
610:             roundReturns = wmul(value, RETURNS_FRACTION - REFERRAL_FRACTION);
611:             uint _ref = wmul(value, REFERRAL_FRACTION);
612:             vaults[ref].totalReturns = add(vaults[ref].totalReturns, _ref);            
613:             vaults[ref].refReturns = add(vaults[ref].refReturns, _ref);
614:             unclaimedReturns = add(unclaimedReturns, _ref);
615:         } else {
616:             roundReturns = wmul(value, RETURNS_FRACTION);
617:         }
618:         
619:         uint dailyJackpot = wmul(value, DAILY_JACKPOT_FRACTION);
620:         uint jackpot = wmul(value, JACKPOT_FRACTION);
621:         
622:         uint dev;
623:         
624:         dev = value / DEV_DIVISOR;
625:         
626:         
627:         if(rnd.totalShares == 0) {
628:             rnd.jackpot = add(rnd.jackpot, roundReturns);
629:         } else {
630:             _disburseReturns(rnd, roundReturns);
631:         }
632:         
633:         rnd.dailyJackpot = add(rnd.dailyJackpot, dailyJackpot);
634:         rnd.jackpot = add(rnd.jackpot, jackpot);
635:         devBalance = add(devBalance, dev);
636:     }
637: 
638:     function _disburseReturns(MobiusRound storage rnd, uint value) internal {
639:         unclaimedReturns = add(unclaimedReturns, value);
640:         
641:         
642:         if(rnd.totalShares == 0) {
643:             rnd.cumulativeReturnsPoints = mul(value, MULTIPLIER) / wdiv(value, rnd.price);
644:         } else {
645:             rnd.cumulativeReturnsPoints = add(
646:                 rnd.cumulativeReturnsPoints, 
647:                 mul(value, MULTIPLIER) / rnd.totalShares
648:             );
649:         }
650:     }
651: 
652:     function _issueShares(MobiusRound storage rnd, address _investor, uint value) internal returns(uint) {    
653:         if(rnd.investors[_investor].lastCumulativeReturnsPoints == 0) {
654:             rnd.investors[_investor].lastCumulativeReturnsPoints = rnd.cumulativeReturnsPoints;
655:         }    
656:         
657:         uint newShares = wdiv(value, rnd.price);
658:         
659:         
660:         if(value >= 100 ether) {
661:             newShares = mul(newShares, 2);
662:         } else if(value >= 10 ether) {
663:             newShares = add(newShares, newShares/2);
664:         } else if(value >= 1 ether) {
665:             newShares = add(newShares, newShares/3);
666:         } else if(value >= 100 finney) {
667:             newShares = add(newShares, newShares/10);
668:         }
669: 
670:         rnd.investors[_investor].shares = add(rnd.investors[_investor].shares, newShares);
671:         rnd.totalShares = add(rnd.totalShares, newShares);
672:         emit SharesIssued(_investor, newShares);
673:         return newShares;
674:     }    
675: 
676:     function _dailyJackpot(MobiusRound storage rnd, uint value) internal {
677:         
678:         if(value >= rnd.secondaryPrice) {
679:             dailyRounds[latestDailyID].entrants.push(msg.sender);
680:             lastDailyEntry[msg.sender] = now; 
681:         }
682:         
683:         if(now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
684:             
685:             if(rnd.dailyJackpot < rnd.secondaryPrice * 4) {
686:                 return;
687:             }
688:             if(!oraclizePending) {                
689:                 _requestRandom(0);
690:             } else {
691:                 if(now > oraclizeLastRequestTime + 10 minutes){
692:                     
693:                     
694:                     oraclizeGasPrice = min(150000000000, oraclizeGasPrice * 2); 
695:                     oraclize_setCustomGasPrice(oraclizeGasPrice);
696:                 }
697:             }
698:         }
699:     }
700: 
701:     
702:     function _onRandom(uint _rand, bytes32 _queryId) internal {
703:         MobiusRound storage rnd = rounds[latestRoundID];
704:         
705:         if(rnd.softDeadline >= now && now > rnd.lastDailyJackpot + DAILY_JACKPOT_PERIOD) {
706:             _drawDailyJackpot(dailyRounds[latestDailyID], rnd, _rand);
707:         }
708:     }
709: 
710:     event FailedRNGVerification(bytes32 qID);
711: 
712:     function _onRandomFailed(bytes32 _queryId) internal {
713:         emit FailedRNGVerification(_queryId);
714:     }
715: 
716:     
717:     function _triggerOraclize() public auth {
718:         _requestRandom(0);
719:     }
720: 
721:     function _drawDailyJackpot(DailyJackpotRound storage dRnd, MobiusRound storage rnd, uint _rand) internal {
722:         if(dRnd.entrants.length != 0){
723:             uint winner = _rand % dRnd.entrants.length;
724:             uint prize = min(maxDailyJackpot, rnd.dailyJackpot / 2);
725:             rnd.dailyJackpot = sub(rnd.dailyJackpot, prize);
726:             vaults[dRnd.entrants[winner]].totalReturns = add(vaults[dRnd.entrants[winner]].totalReturns, prize);
727:             emit DailyJackpotWon(dRnd.entrants[winner], prize);
728:             dRnd.finalized = true;       
729:             unclaimedReturns = add(unclaimedReturns, prize);
730:             totalJackpotsWon += prize;
731: 
732:             _startNewDailyRound();
733:         }        
734:         rnd.lastDailyJackpot = now; 
735:     }
736: 
737: }