1: 
2: 
3: 
4: 
5: 
6: 
7: 
8: pragma solidity ^0.4.24;
9: 
10: 
11: contract Kleros is Arbitrator, ApproveAndCallFallBack {
12: 
13:     
14:     
15:     
16: 
17:     
18:     Pinakion public pinakion;
19:     uint public constant NON_PAYABLE_AMOUNT = (2**256 - 2) / 2; 
20: 
21:     
22:     
23:     RNG public rng; 
24:     uint public arbitrationFeePerJuror = 0.05 ether; 
25:     uint16 public defaultNumberJuror = 3; 
26:     uint public minActivatedToken = 0.1 * 1e18; 
27:     uint[5] public timePerPeriod; 
28:     uint public alpha = 2000; 
29:     uint constant ALPHA_DIVISOR = 1e4; 
30:     uint public maxAppeals = 5; 
31:     
32:     
33:     address public governor; 
34: 
35:     
36:     uint public session = 1;      
37:     uint public lastPeriodChange; 
38:     uint public segmentSize;      
39:     uint public rnBlock;          
40:     uint public randomNumber;     
41: 
42:     enum Period {
43:         Activation, 
44:         Draw,       
45:         Vote,       
46:         Appeal,     
47:         Execution   
48:     }
49: 
50:     Period public period;
51: 
52:     struct Juror {
53:         uint balance;      
54:         uint atStake;      
55:         uint lastSession;  
56:         uint segmentStart; 
57:         uint segmentEnd;   
58:     }
59: 
60:     mapping (address => Juror) public jurors;
61: 
62:     struct Vote {
63:         address account; 
64:         uint ruling;     
65:     }
66: 
67:     struct VoteCounter {
68:         uint winningChoice; 
69:         uint winningCount;  
70:         mapping (uint => uint) voteCount; 
71:     }
72: 
73:     enum DisputeState {
74:         Open,       
75:         Resolving,  
76:         Executable, 
77:         Executed    
78:     }
79: 
80:     struct Dispute {
81:         Arbitrable arbitrated;       
82:         uint session;                
83:         uint appeals;                
84:         uint choices;                
85:         uint16 initialNumberJurors;  
86:         uint arbitrationFeePerJuror; 
87:         DisputeState state;          
88:         Vote[][] votes;              
89:         VoteCounter[] voteCounter;   
90:         mapping (address => uint) lastSessionVote; 
91:         uint currentAppealToRepartition; 
92:         AppealsRepartitioned[] appealsRepartitioned; 
93:     }
94: 
95:     enum RepartitionStage { 
96:         Incoherent,
97:         Coherent,
98:         AtStake,
99:         Complete
100:     }
101: 
102:     struct AppealsRepartitioned {
103:         uint totalToRedistribute;   
104:         uint nbCoherent;            
105:         uint currentIncoherentVote; 
106:         uint currentCoherentVote;   
107:         uint currentAtStakeVote;    
108:         RepartitionStage stage;     
109:     }
110: 
111:     Dispute[] public disputes;
112: 
113:     
114:     
115:     
116: 
117:     
118: 
119: 
120: 
121:     event NewPeriod(Period _period, uint indexed _session);
122: 
123:     
124: 
125: 
126: 
127: 
128:     event TokenShift(address indexed _account, uint _disputeID, int _amount);
129: 
130:     
131: 
132: 
133: 
134: 
135:     event ArbitrationReward(address indexed _account, uint _disputeID, uint _amount);
136: 
137:     
138:     
139:     
140:     modifier onlyBy(address _account) {require(msg.sender == _account); _;}
141:     modifier onlyDuring(Period _period) {require(period == _period); _;}
142:     modifier onlyGovernor() {require(msg.sender == governor); _;}
143: 
144: 
145:     
146: 
147: 
148: 
149: 
150: 
151:     constructor(Pinakion _pinakion, RNG _rng, uint[5] _timePerPeriod, address _governor) public {
152:         pinakion = _pinakion;
153:         rng = _rng;
154:         lastPeriodChange = now;
155:         timePerPeriod = _timePerPeriod;
156:         governor = _governor;
157:     }
158: 
159:     
160:     
161:     
162:     
163: 
164:     
165: 
166: 
167: 
168:     function receiveApproval(address _from, uint _amount, address, bytes) public onlyBy(pinakion) {
169:         require(pinakion.transferFrom(_from, this, _amount));
170: 
171:         jurors[_from].balance += _amount;
172:     }
173: 
174:     
175: 
176: 
177: 
178: 
179:     function withdraw(uint _value) public {
180:         Juror storage juror = jurors[msg.sender];
181:         require(juror.atStake <= juror.balance); 
182:         require(_value <= juror.balance-juror.atStake);
183:         require(juror.lastSession != session);
184: 
185:         juror.balance -= _value;
186:         require(pinakion.transfer(msg.sender,_value));
187:     }
188: 
189:     
190:     
191:     
192:     
193: 
194:     
195: 
196:     function passPeriod() public {
197:         require(now-lastPeriodChange >= timePerPeriod[uint8(period)]);
198: 
199:         if (period == Period.Activation) {
200:             rnBlock = block.number + 1;
201:             rng.requestRN(rnBlock);
202:             period = Period.Draw;
203:         } else if (period == Period.Draw) {
204:             randomNumber = rng.getUncorrelatedRN(rnBlock);
205:             require(randomNumber != 0);
206:             period = Period.Vote;
207:         } else if (period == Period.Vote) {
208:             period = Period.Appeal;
209:         } else if (period == Period.Appeal) {
210:             period = Period.Execution;
211:         } else if (period == Period.Execution) {
212:             period = Period.Activation;
213:             ++session;
214:             segmentSize = 0;
215:             rnBlock = 0;
216:             randomNumber = 0;
217:         }
218: 
219: 
220:         lastPeriodChange = now;
221:         NewPeriod(period, session);
222:     }
223: 
224: 
225:     
226: 
227: 
228: 
229:     function activateTokens(uint _value) public onlyDuring(Period.Activation) {
230:         Juror storage juror = jurors[msg.sender];
231:         require(_value <= juror.balance);
232:         require(_value >= minActivatedToken);
233:         require(juror.lastSession != session); 
234: 
235:         juror.lastSession = session;
236:         juror.segmentStart = segmentSize;
237:         segmentSize += _value;
238:         juror.segmentEnd = segmentSize;
239: 
240:     }
241: 
242:     
243: 
244: 
245: 
246: 
247: 
248: 
249: 
250:     function voteRuling(uint _disputeID, uint _ruling, uint[] _draws) public onlyDuring(Period.Vote) {
251:         Dispute storage dispute = disputes[_disputeID];
252:         Juror storage juror = jurors[msg.sender];
253:         VoteCounter storage voteCounter = dispute.voteCounter[dispute.appeals];
254:         require(dispute.lastSessionVote[msg.sender] != session); 
255:         require(_ruling <= dispute.choices);
256:         
257:         require(validDraws(msg.sender, _disputeID, _draws));
258: 
259:         dispute.lastSessionVote[msg.sender] = session;
260:         voteCounter.voteCount[_ruling] += _draws.length;
261:         if (voteCounter.winningCount < voteCounter.voteCount[_ruling]) {
262:             voteCounter.winningCount = voteCounter.voteCount[_ruling];
263:             voteCounter.winningChoice = _ruling;
264:         } else if (voteCounter.winningCount==voteCounter.voteCount[_ruling] && _draws.length!=0) { 
265:             voteCounter.winningChoice = 0; 
266:         }
267:         for (uint i = 0; i < _draws.length; ++i) {
268:             dispute.votes[dispute.appeals].push(Vote({
269:                 account: msg.sender,
270:                 ruling: _ruling
271:             }));
272:         }
273: 
274:         juror.atStake += _draws.length * getStakePerDraw();
275:         uint feeToPay = _draws.length * dispute.arbitrationFeePerJuror;
276:         msg.sender.transfer(feeToPay);
277:         ArbitrationReward(msg.sender, _disputeID, feeToPay);
278:     }
279: 
280:     
281: 
282: 
283: 
284: 
285: 
286: 
287: 
288:     function penalizeInactiveJuror(address _jurorAddress, uint _disputeID, uint[] _draws) public {
289:         Dispute storage dispute = disputes[_disputeID];
290:         Juror storage inactiveJuror = jurors[_jurorAddress];
291:         require(period > Period.Vote);
292:         require(dispute.lastSessionVote[_jurorAddress] != session); 
293:         dispute.lastSessionVote[_jurorAddress] = session; 
294:         require(validDraws(_jurorAddress, _disputeID, _draws));
295:         uint penality = _draws.length * minActivatedToken * 2 * alpha / ALPHA_DIVISOR;
296:         penality = (penality < inactiveJuror.balance) ? penality : inactiveJuror.balance; 
297:         inactiveJuror.balance -= penality;
298:         TokenShift(_jurorAddress, _disputeID, -int(penality));
299:         jurors[msg.sender].balance += penality / 2; 
300:         TokenShift(msg.sender, _disputeID, int(penality / 2));
301:         jurors[governor].balance += penality / 2; 
302:         TokenShift(governor, _disputeID, int(penality / 2));
303:         msg.sender.transfer(_draws.length*dispute.arbitrationFeePerJuror); 
304:     }
305: 
306:     
307: 
308: 
309: 
310: 
311: 
312: 
313:     function oneShotTokenRepartition(uint _disputeID) public onlyDuring(Period.Execution) {
314:         Dispute storage dispute = disputes[_disputeID];
315:         require(dispute.state == DisputeState.Open);
316:         require(dispute.session+dispute.appeals <= session);
317: 
318:         uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
319:         uint amountShift = getStakePerDraw();
320:         for (uint i = 0; i <= dispute.appeals; ++i) {
321:             
322:             
323:             
324:             if (winningChoice!=0 || (dispute.voteCounter[dispute.appeals].voteCount[0] == dispute.voteCounter[dispute.appeals].winningCount)) {
325:                 uint totalToRedistribute = 0;
326:                 uint nbCoherent = 0;
327:                 
328:                 for (uint j = 0; j < dispute.votes[i].length; ++j) {
329:                     Vote storage vote = dispute.votes[i][j];
330:                     if (vote.ruling != winningChoice) {
331:                         Juror storage juror = jurors[vote.account];
332:                         uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
333:                         juror.balance -= penalty;
334:                         TokenShift(vote.account, _disputeID, int(-penalty));
335:                         totalToRedistribute += penalty;
336:                     } else {
337:                         ++nbCoherent;
338:                     }
339:                 }
340:                 if (nbCoherent == 0) { 
341:                     jurors[governor].balance += totalToRedistribute;
342:                     TokenShift(governor, _disputeID, int(totalToRedistribute));
343:                 } else { 
344:                     uint toRedistribute = totalToRedistribute / nbCoherent; 
345:                     
346:                     for (j = 0; j < dispute.votes[i].length; ++j) {
347:                         vote = dispute.votes[i][j];
348:                         if (vote.ruling == winningChoice) {
349:                             juror = jurors[vote.account];
350:                             juror.balance += toRedistribute;
351:                             TokenShift(vote.account, _disputeID, int(toRedistribute));
352:                         }
353:                     }
354:                 }
355:             }
356:             
357:             for (j = 0; j < dispute.votes[i].length; ++j) {
358:                 vote = dispute.votes[i][j];
359:                 juror = jurors[vote.account];
360:                 juror.atStake -= amountShift; 
361:             }
362:         }
363:         dispute.state = DisputeState.Executable; 
364:     }
365: 
366:     
367: 
368: 
369: 
370: 
371: 
372:     function multipleShotTokenRepartition(uint _disputeID, uint _maxIterations) public onlyDuring(Period.Execution) {
373:         Dispute storage dispute = disputes[_disputeID];
374:         require(dispute.state <= DisputeState.Resolving);
375:         require(dispute.session+dispute.appeals <= session);
376:         dispute.state = DisputeState.Resolving; 
377: 
378:         uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
379:         uint amountShift = getStakePerDraw();
380:         uint currentIterations = 0; 
381:         for (uint i = dispute.currentAppealToRepartition; i <= dispute.appeals; ++i) {
382:             
383:             if (dispute.appealsRepartitioned.length < i+1) {
384:                 dispute.appealsRepartitioned.length++;
385:             }
386: 
387:             
388:             if (winningChoice==0 && (dispute.voteCounter[dispute.appeals].voteCount[0] != dispute.voteCounter[dispute.appeals].winningCount)) {
389:                 
390:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
391:             }
392: 
393:             
394:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Incoherent) {
395:                 for (uint j = dispute.appealsRepartitioned[i].currentIncoherentVote; j < dispute.votes[i].length; ++j) {
396:                     if (currentIterations >= _maxIterations) {
397:                         return;
398:                     }
399:                     Vote storage vote = dispute.votes[i][j];
400:                     if (vote.ruling != winningChoice) {
401:                         Juror storage juror = jurors[vote.account];
402:                         uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
403:                         juror.balance -= penalty;
404:                         TokenShift(vote.account, _disputeID, int(-penalty));
405:                         dispute.appealsRepartitioned[i].totalToRedistribute += penalty;
406:                     } else {
407:                         ++dispute.appealsRepartitioned[i].nbCoherent;
408:                     }
409: 
410:                     ++dispute.appealsRepartitioned[i].currentIncoherentVote;
411:                     ++currentIterations;
412:                 }
413: 
414:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.Coherent;
415:             }
416: 
417:             
418:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Coherent) {
419:                 if (dispute.appealsRepartitioned[i].nbCoherent == 0) { 
420:                     jurors[governor].balance += dispute.appealsRepartitioned[i].totalToRedistribute;
421:                     TokenShift(governor, _disputeID, int(dispute.appealsRepartitioned[i].totalToRedistribute));
422:                     dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
423:                 } else { 
424:                     uint toRedistribute = dispute.appealsRepartitioned[i].totalToRedistribute / dispute.appealsRepartitioned[i].nbCoherent; 
425:                     
426:                     for (j = dispute.appealsRepartitioned[i].currentCoherentVote; j < dispute.votes[i].length; ++j) {
427:                         if (currentIterations >= _maxIterations) {
428:                             return;
429:                         }
430:                         vote = dispute.votes[i][j];
431:                         if (vote.ruling == winningChoice) {
432:                             juror = jurors[vote.account];
433:                             juror.balance += toRedistribute;
434:                             TokenShift(vote.account, _disputeID, int(toRedistribute));
435:                         }
436: 
437:                         ++currentIterations;
438:                         ++dispute.appealsRepartitioned[i].currentCoherentVote;
439:                     }
440: 
441:                     dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
442:                 }
443:             }
444: 
445:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.AtStake) {
446:                 
447:                 for (j = dispute.appealsRepartitioned[i].currentAtStakeVote; j < dispute.votes[i].length; ++j) {
448:                     if (currentIterations >= _maxIterations) {
449:                         return;
450:                     }
451:                     vote = dispute.votes[i][j];
452:                     juror = jurors[vote.account];
453:                     juror.atStake -= amountShift; 
454: 
455:                     ++currentIterations;
456:                     ++dispute.appealsRepartitioned[i].currentAtStakeVote;
457:                 }
458: 
459:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.Complete;
460:             }
461: 
462:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Complete) {
463:                 ++dispute.currentAppealToRepartition;
464:             }
465:         }
466: 
467:         dispute.state = DisputeState.Executable;
468:     }
469: 
470:     
471:     
472:     
473:     
474: 
475:     
476: 
477: 
478: 
479: 
480: 
481:     function amountJurors(uint _disputeID) public view returns (uint nbJurors) {
482:         Dispute storage dispute = disputes[_disputeID];
483:         return (dispute.initialNumberJurors + 1) * 2**dispute.appeals - 1;
484:     }
485: 
486:     
487: 
488: 
489: 
490: 
491: 
492: 
493: 
494: 
495:     function validDraws(address _jurorAddress, uint _disputeID, uint[] _draws) public view returns (bool valid) {
496:         uint draw = 0;
497:         Juror storage juror = jurors[_jurorAddress];
498:         Dispute storage dispute = disputes[_disputeID];
499:         uint nbJurors = amountJurors(_disputeID);
500: 
501:         if (juror.lastSession != session) return false; 
502:         if (dispute.session+dispute.appeals != session) return false; 
503:         if (period <= Period.Draw) return false; 
504:         for (uint i = 0; i < _draws.length; ++i) {
505:             if (_draws[i] <= draw) return false; 
506:             draw = _draws[i];
507:             if (draw > nbJurors) return false;
508:             uint position = uint(keccak256(randomNumber, _disputeID, draw)) % segmentSize; 
509:             require(position >= juror.segmentStart);
510:             require(position < juror.segmentEnd);
511:         }
512: 
513:         return true;
514:     }
515: 
516:     
517:     
518:     
519:     
520: 
521:     
522: 
523: 
524: 
525: 
526: 
527:     function createDispute(uint _choices, bytes _extraData) public payable returns (uint disputeID) {
528:         uint16 nbJurors = extraDataToNbJurors(_extraData);
529:         require(msg.value >= arbitrationCost(_extraData));
530: 
531:         disputeID = disputes.length++;
532:         Dispute storage dispute = disputes[disputeID];
533:         dispute.arbitrated = Arbitrable(msg.sender);
534:         if (period < Period.Draw) 
535:             dispute.session = session;
536:         else 
537:             dispute.session = session+1;
538:         dispute.choices = _choices;
539:         dispute.initialNumberJurors = nbJurors;
540:         dispute.arbitrationFeePerJuror = arbitrationFeePerJuror; 
541:         dispute.votes.length++;
542:         dispute.voteCounter.length++;
543: 
544:         DisputeCreation(disputeID, Arbitrable(msg.sender));
545:         return disputeID;
546:     }
547: 
548:     
549: 
550: 
551: 
552:     function appeal(uint _disputeID, bytes _extraData) public payable onlyDuring(Period.Appeal) {
553:         super.appeal(_disputeID,_extraData);
554:         Dispute storage dispute = disputes[_disputeID];
555:         require(msg.value >= appealCost(_disputeID, _extraData));
556:         require(dispute.session+dispute.appeals == session); 
557:         require(dispute.arbitrated == msg.sender);
558:         
559:         dispute.appeals++;
560:         dispute.votes.length++;
561:         dispute.voteCounter.length++;
562:     }
563: 
564:     
565: 
566: 
567:     function executeRuling(uint disputeID) public {
568:         Dispute storage dispute = disputes[disputeID];
569:         require(dispute.state == DisputeState.Executable);
570: 
571:         dispute.state = DisputeState.Executed;
572:         dispute.arbitrated.rule(disputeID, dispute.voteCounter[dispute.appeals].winningChoice);
573:     }
574: 
575:     
576:     
577:     
578:     
579: 
580:     
581: 
582: 
583: 
584: 
585:     function arbitrationCost(bytes _extraData) public view returns (uint fee) {
586:         return extraDataToNbJurors(_extraData) * arbitrationFeePerJuror;
587:     }
588: 
589:     
590: 
591: 
592: 
593: 
594: 
595:     function appealCost(uint _disputeID, bytes _extraData) public view returns (uint fee) {
596:         Dispute storage dispute = disputes[_disputeID];
597: 
598:         if(dispute.appeals >= maxAppeals) return NON_PAYABLE_AMOUNT;
599: 
600:         return (2*amountJurors(_disputeID) + 1) * dispute.arbitrationFeePerJuror;
601:     }
602: 
603:     
604: 
605: 
606: 
607:     function extraDataToNbJurors(bytes _extraData) internal view returns (uint16 nbJurors) {
608:         if (_extraData.length < 2)
609:             return defaultNumberJuror;
610:         else
611:             return (uint16(_extraData[0]) << 8) + uint16(_extraData[1]);
612:     }
613: 
614:     
615: 
616: 
617:     function getStakePerDraw() public view returns (uint minActivatedTokenInAlpha) {
618:         return (alpha * minActivatedToken) / ALPHA_DIVISOR;
619:     }
620: 
621: 
622:     
623:     
624:     
625: 
626:     
627: 
628: 
629: 
630: 
631: 
632:     function getVoteAccount(uint _disputeID, uint _appeals, uint _voteID) public view returns (address account) {
633:         return disputes[_disputeID].votes[_appeals][_voteID].account;
634:     }
635: 
636:     
637: 
638: 
639: 
640: 
641: 
642:     function getVoteRuling(uint _disputeID, uint _appeals, uint _voteID) public view returns (uint ruling) {
643:         return disputes[_disputeID].votes[_appeals][_voteID].ruling;
644:     }
645: 
646:     
647: 
648: 
649: 
650: 
651:     function getWinningChoice(uint _disputeID, uint _appeals) public view returns (uint winningChoice) {
652:         return disputes[_disputeID].voteCounter[_appeals].winningChoice;
653:     }
654: 
655:     
656: 
657: 
658: 
659: 
660:     function getWinningCount(uint _disputeID, uint _appeals) public view returns (uint winningCount) {
661:         return disputes[_disputeID].voteCounter[_appeals].winningCount;
662:     }
663: 
664:     
665: 
666: 
667: 
668: 
669: 
670:     function getVoteCount(uint _disputeID, uint _appeals, uint _choice) public view returns (uint voteCount) {
671:         return disputes[_disputeID].voteCounter[_appeals].voteCount[_choice];
672:     }
673: 
674:     
675: 
676: 
677: 
678: 
679:     function getLastSessionVote(uint _disputeID, address _juror) public view returns (uint lastSessionVote) {
680:         return disputes[_disputeID].lastSessionVote[_juror];
681:     }
682: 
683:     
684: 
685: 
686: 
687: 
688: 
689:     function isDrawn(uint _disputeID, address _juror, uint _draw) public view returns (bool drawn) {
690:         Dispute storage dispute = disputes[_disputeID];
691:         Juror storage juror = jurors[_juror];
692:         if (juror.lastSession != session
693:         || (dispute.session+dispute.appeals != session)
694:         || period<=Period.Draw
695:         || _draw>amountJurors(_disputeID)
696:         || _draw==0
697:         || segmentSize==0
698:         ) {
699:             return false;
700:         } else {
701:             uint position = uint(keccak256(randomNumber,_disputeID,_draw)) % segmentSize;
702:             return (position >= juror.segmentStart) && (position < juror.segmentEnd);
703:         }
704: 
705:     }
706: 
707:     
708: 
709: 
710: 
711:     function currentRuling(uint _disputeID) public view returns (uint ruling) {
712:         Dispute storage dispute = disputes[_disputeID];
713:         return dispute.voteCounter[dispute.appeals].winningChoice;
714:     }
715: 
716:     
717: 
718: 
719: 
720:     function disputeStatus(uint _disputeID) public view returns (DisputeStatus status) {
721:         Dispute storage dispute = disputes[_disputeID];
722:         if (dispute.session+dispute.appeals < session) 
723:             return DisputeStatus.Solved;
724:         else if(dispute.session+dispute.appeals == session) { 
725:             if (dispute.state == DisputeState.Open) {
726:                 if (period < Period.Appeal)
727:                     return DisputeStatus.Waiting;
728:                 else if (period == Period.Appeal)
729:                     return DisputeStatus.Appealable;
730:                 else return DisputeStatus.Solved;
731:             } else return DisputeStatus.Solved;
732:         } else return DisputeStatus.Waiting; 
733:     }
734: 
735:     
736:     
737:     
738: 
739:     
740: 
741: 
742: 
743: 
744:     function executeOrder(bytes32 _data, uint _value, address _target) public onlyGovernor {
745:         _target.call.value(_value)(_data);
746:     }
747: 
748:     
749: 
750: 
751:     function setRng(RNG _rng) public onlyGovernor {
752:         rng = _rng;
753:     }
754: 
755:     
756: 
757: 
758:     function setArbitrationFeePerJuror(uint _arbitrationFeePerJuror) public onlyGovernor {
759:         arbitrationFeePerJuror = _arbitrationFeePerJuror;
760:     }
761: 
762:     
763: 
764: 
765:     function setDefaultNumberJuror(uint16 _defaultNumberJuror) public onlyGovernor {
766:         defaultNumberJuror = _defaultNumberJuror;
767:     }
768: 
769:     
770: 
771: 
772:     function setMinActivatedToken(uint _minActivatedToken) public onlyGovernor {
773:         minActivatedToken = _minActivatedToken;
774:     }
775: 
776:     
777: 
778: 
779:     function setTimePerPeriod(uint[5] _timePerPeriod) public onlyGovernor {
780:         timePerPeriod = _timePerPeriod;
781:     }
782: 
783:     
784: 
785: 
786:     function setAlpha(uint _alpha) public onlyGovernor {
787:         alpha = _alpha;
788:     }
789: 
790:     
791: 
792: 
793:     function setMaxAppeals(uint _maxAppeals) public onlyGovernor {
794:         maxAppeals = _maxAppeals;
795:     }
796: 
797:     
798: 
799: 
800:     function setGovernor(address _governor) public onlyGovernor {
801:         governor = _governor;
802:     }
803: }