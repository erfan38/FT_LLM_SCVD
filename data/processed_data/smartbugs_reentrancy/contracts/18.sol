1: 1: 
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: pragma solidity ^0.4.25;
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: library SortitionSumTreeFactory {
21: 21:     
22: 22: 
23: 23:     struct SortitionSumTree {
24: 24:         uint K; 
25: 25:         
26: 26:         uint[] stack;
27: 27:         uint[] nodes;
28: 28:         
29: 29:         mapping(bytes32 => uint) IDsToNodeIndexes;
30: 30:         mapping(uint => bytes32) nodeIndexesToIDs;
31: 31:     }
32: 32: 
33: 33:     
34: 34: 
35: 35:     struct SortitionSumTrees {
36: 36:         mapping(bytes32 => SortitionSumTree) sortitionSumTrees;
37: 37:     }
38: 38: 
39: 39:     
40: 40: 
41: 41:     
42: 42: 
43: 43: 
44: 44: 
45: 45: 
46: 46:     function createTree(SortitionSumTrees storage self, bytes32 _key, uint _K) public {
47: 47:         SortitionSumTree storage tree = self.sortitionSumTrees[_key];
48: 48:         require(tree.K == 0, "Tree already exists.");
49: 49:         require(_K > 1, "K must be greater than one.");
50: 50:         tree.K = _K;
51: 51:         tree.stack.length = 0;
52: 52:         tree.nodes.length = 0;
53: 53:         tree.nodes.push(0);
54: 54:     }
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
65: 65:     function set(SortitionSumTrees storage self, bytes32 _key, uint _value, bytes32 _ID) public {
66: 66:         SortitionSumTree storage tree = self.sortitionSumTrees[_key];
67: 67:         uint treeIndex = tree.IDsToNodeIndexes[_ID];
68: 68: 
69: 69:         if (treeIndex == 0) { 
70: 70:             if (_value != 0) { 
71: 71:                 
72: 72:                 
73: 73:                 if (tree.stack.length == 0) { 
74: 74:                     
75: 75:                     treeIndex = tree.nodes.length;
76: 76:                     tree.nodes.push(_value);
77: 77: 
78: 78:                     
79: 79:                     if (treeIndex != 1 && (treeIndex - 1) % tree.K == 0) { 
80: 80:                         uint parentIndex = treeIndex / tree.K;
81: 81:                         bytes32 parentID = tree.nodeIndexesToIDs[parentIndex];
82: 82:                         uint newIndex = treeIndex + 1;
83: 83:                         tree.nodes.push(tree.nodes[parentIndex]);
84: 84:                         delete tree.nodeIndexesToIDs[parentIndex];
85: 85:                         tree.IDsToNodeIndexes[parentID] = newIndex;
86: 86:                         tree.nodeIndexesToIDs[newIndex] = parentID;
87: 87:                     }
88: 88:                 } else { 
89: 89:                     
90: 90:                     treeIndex = tree.stack[tree.stack.length - 1];
91: 91:                     tree.stack.length--;
92: 92:                     tree.nodes[treeIndex] = _value;
93: 93:                 }
94: 94: 
95: 95:                 
96: 96:                 tree.IDsToNodeIndexes[_ID] = treeIndex;
97: 97:                 tree.nodeIndexesToIDs[treeIndex] = _ID;
98: 98: 
99: 99:                 updateParents(self, _key, treeIndex, true, _value);
100: 100:             }
101: 101:         } else { 
102: 102:             if (_value == 0) { 
103: 103:                 
104: 104:                 
105: 105:                 uint value = tree.nodes[treeIndex];
106: 106:                 tree.nodes[treeIndex] = 0;
107: 107: 
108: 108:                 
109: 109:                 tree.stack.push(treeIndex);
110: 110: 
111: 111:                 
112: 112:                 delete tree.IDsToNodeIndexes[_ID];
113: 113:                 delete tree.nodeIndexesToIDs[treeIndex];
114: 114: 
115: 115:                 updateParents(self, _key, treeIndex, false, value);
116: 116:             } else if (_value != tree.nodes[treeIndex]) { 
117: 117:                 
118: 118:                 bool plusOrMinus = tree.nodes[treeIndex] <= _value;
119: 119:                 uint plusOrMinusValue = plusOrMinus ? _value - tree.nodes[treeIndex] : tree.nodes[treeIndex] - _value;
120: 120:                 tree.nodes[treeIndex] = _value;
121: 121: 
122: 122:                 updateParents(self, _key, treeIndex, plusOrMinus, plusOrMinusValue);
123: 123:             }
124: 124:         }
125: 125:     }
126: 126: 
127: 127:     
128: 128: 
129: 129:     
130: 130: 
131: 131: 
132: 132: 
133: 133: 
134: 134: 
135: 135: 
136: 136: 
137: 137: 
138: 138:     function queryLeafs(
139: 139:         SortitionSumTrees storage self,
140: 140:         bytes32 _key,
141: 141:         uint _cursor,
142: 142:         uint _count
143: 143:     ) public view returns(uint startIndex, uint[] values, bool hasMore) {
144: 144:         SortitionSumTree storage tree = self.sortitionSumTrees[_key];
145: 145: 
146: 146:         
147: 147:         for (uint i = 0; i < tree.nodes.length; i++) {
148: 148:             if ((tree.K * i) + 1 >= tree.nodes.length) {
149: 149:                 startIndex = i;
150: 150:                 break;
151: 151:             }
152: 152:         }
153: 153: 
154: 154:         
155: 155:         uint loopStartIndex = startIndex + _cursor;
156: 156:         values = new uint[](loopStartIndex + _count > tree.nodes.length ? tree.nodes.length - loopStartIndex : _count);
157: 157:         uint valuesIndex = 0;
158: 158:         for (uint j = loopStartIndex; j < tree.nodes.length; j++) {
159: 159:             if (valuesIndex < _count) {
160: 160:                 values[valuesIndex] = tree.nodes[j];
161: 161:                 valuesIndex++;
162: 162:             } else {
163: 163:                 hasMore = true;
164: 164:                 break;
165: 165:             }
166: 166:         }
167: 167:     }
168: 168: 
169: 169:     
170: 170: 
171: 171: 
172: 172: 
173: 173: 
174: 174: 
175: 175: 
176: 176: 
177: 177: 
178: 178:     function draw(SortitionSumTrees storage self, bytes32 _key, uint _drawnNumber) public view returns(bytes32 ID) {
179: 179:         SortitionSumTree storage tree = self.sortitionSumTrees[_key];
180: 180:         uint treeIndex = 0;
181: 181:         uint currentDrawnNumber = _drawnNumber % tree.nodes[0];
182: 182: 
183: 183:         while ((tree.K * treeIndex) + 1 < tree.nodes.length)  
184: 184:             for (uint i = 1; i <= tree.K; i++) { 
185: 185:                 uint nodeIndex = (tree.K * treeIndex) + i;
186: 186:                 uint nodeValue = tree.nodes[nodeIndex];
187: 187: 
188: 188:                 if (currentDrawnNumber >= nodeValue) currentDrawnNumber -= nodeValue; 
189: 189:                 else { 
190: 190:                     treeIndex = nodeIndex;
191: 191:                     break;
192: 192:                 }
193: 193:             }
194: 194:         
195: 195:         ID = tree.nodeIndexesToIDs[treeIndex];
196: 196:     }
197: 197: 
198: 198:     
199: 199: 
200: 200: 
201: 201: 
202: 202: 
203: 203:     function stakeOf(SortitionSumTrees storage self, bytes32 _key, bytes32 _ID) public view returns(uint value) {
204: 204:         SortitionSumTree storage tree = self.sortitionSumTrees[_key];
205: 205:         uint treeIndex = tree.IDsToNodeIndexes[_ID];
206: 206: 
207: 207:         if (treeIndex == 0) value = 0;
208: 208:         else value = tree.nodes[treeIndex];
209: 209:     }
210: 210: 
211: 211:     
212: 212: 
213: 213:     
214: 214: 
215: 215: 
216: 216: 
217: 217: 
218: 218: 
219: 219: 
220: 220: 
221: 221: 
222: 222: 
223: 223:     function updateParents(SortitionSumTrees storage self, bytes32 _key, uint _treeIndex, bool _plusOrMinus, uint _value) private {
224: 224:         SortitionSumTree storage tree = self.sortitionSumTrees[_key];
225: 225: 
226: 226:         uint parentIndex = _treeIndex;
227: 227:         while (parentIndex != 0) {
228: 228:             parentIndex = (parentIndex - 1) / tree.K;
229: 229:             tree.nodes[parentIndex] = _plusOrMinus ? tree.nodes[parentIndex] + _value : tree.nodes[parentIndex] - _value;
230: 230:         }
231: 231:     }
232: 232: }
233: 233: 
234: 234: 
235: 235: contract KlerosLiquid is TokenController, Arbitrator {
236: 236:     
237: 237: 
238: 238:     
239: 239:     enum Phase {
240: 240:       staking, 
241: 241:       generating, 
242: 242:       drawing 
243: 243:     }
244: 244: 
245: 245:     
246: 246:     enum Period {
247: 247:       evidence, 
248: 248:       commit, 
249: 249:       vote, 
250: 250:       appeal, 
251: 251:       execution 
252: 252:     }
253: 253: 
254: 254:     
255: 255: 
256: 256:     
257: 257:     struct Court {
258: 258:         uint96 parent; 
259: 259:         uint[] children; 
260: 260:         bool hiddenVotes; 
261: 261:         uint minStake; 
262: 262:         uint alpha; 
263: 263:         uint feeForJuror; 
264: 264:         
265: 265:         uint jurorsForCourtJump;
266: 266:         uint[4] timesPerPeriod; 
267: 267:     }
268: 268:     struct DelayedSetStake {
269: 269:         address account; 
270: 270:         uint96 subcourtID; 
271: 271:         uint128 stake; 
272: 272:     }
273: 273: 
274: 274:     
275: 275:     struct Vote {
276: 276:         address account; 
277: 277:         bytes32 commit; 
278: 278:         uint choice; 
279: 279:         bool voted; 
280: 280:     }
281: 281:     struct VoteCounter {
282: 282:         
283: 283:         uint winningChoice;
284: 284:         mapping(uint => uint) counts; 
285: 285:         bool tied; 
286: 286:     }
287: 287:     struct Dispute { 
288: 288:         uint96 subcourtID; 
289: 289:         Arbitrable arbitrated; 
290: 290:         
291: 291:         uint numberOfChoices;
292: 292:         Period period; 
293: 293:         uint lastPeriodChange; 
294: 294:         
295: 295:         Vote[][] votes;
296: 296:         VoteCounter[] voteCounters; 
297: 297:         uint[] tokensAtStakePerJuror; 
298: 298:         uint[] totalFeesForJurors; 
299: 299:         uint drawsInRound; 
300: 300:         uint commitsInRound; 
301: 301:         uint[] votesInEachRound; 
302: 302:         
303: 303:         uint[] repartitionsInEachRound;
304: 304:         uint[] penaltiesInEachRound; 
305: 305:         bool ruled; 
306: 306:     }
307: 307: 
308: 308:     
309: 309:     struct Juror {
310: 310:         
311: 311:         uint96[] subcourtIDs;
312: 312:         uint stakedTokens; 
313: 313:         uint lockedTokens; 
314: 314:     }
315: 315: 
316: 316:     
317: 317: 
318: 318:     
319: 319: 
320: 320: 
321: 321:     event NewPhase(Phase _phase);
322: 322: 
323: 323:     
324: 324: 
325: 325: 
326: 326: 
327: 327:     event NewPeriod(uint indexed _disputeID, Period _period);
328: 328: 
329: 329:     
330: 330: 
331: 331: 
332: 332: 
333: 333: 
334: 334: 
335: 335:     event StakeSet(address indexed _address, uint _subcourtID, uint128 _stake, uint _newTotalStake);
336: 336: 
337: 337:     
338: 338: 
339: 339: 
340: 340: 
341: 341: 
342: 342: 
343: 343:     event Draw(address indexed _address, uint indexed _disputeID, uint _appeal, uint _voteID);
344: 344: 
345: 345:     
346: 346: 
347: 347: 
348: 348: 
349: 349: 
350: 350: 
351: 351:     event TokenAndETHShift(address indexed _address, uint indexed _disputeID, int _tokenAmount, int _ETHAmount);
352: 352: 
353: 353:     
354: 354: 
355: 355:     
356: 356:     uint public constant MAX_STAKE_PATHS = 4; 
357: 357:     uint public constant MIN_JURORS = 3; 
358: 358:     uint public constant NON_PAYABLE_AMOUNT = (2 ** 256 - 2) / 2; 
359: 359:     uint public constant ALPHA_DIVISOR = 1e4; 
360: 360:     
361: 361:     address public governor; 
362: 362:     MiniMeToken public pinakion; 
363: 363:     RNG public RNGenerator; 
364: 364:     
365: 365:     Phase public phase; 
366: 366:     uint public lastPhaseChange; 
367: 367:     uint public disputesWithoutJurors; 
368: 368:     
369: 369:     uint public RNBlock;
370: 370:     uint public RN; 
371: 371:     uint public minStakingTime; 
372: 372:     uint public maxDrawingTime; 
373: 373:     
374: 374:     bool public lockInsolventTransfers = true;
375: 375:     
376: 376:     Court[] public courts; 
377: 377:     using SortitionSumTreeFactory for SortitionSumTreeFactory.SortitionSumTrees; 
378: 378:     SortitionSumTreeFactory.SortitionSumTrees internal sortitionSumTrees; 
379: 379:     
380: 380:     mapping(uint => DelayedSetStake) public delayedSetStakes;
381: 381:     
382: 382:     uint public nextDelayedSetStake = 1;
383: 383:     uint public lastDelayedSetStake; 
384: 384: 
385: 385:     
386: 386:     Dispute[] public disputes; 
387: 387: 
388: 388:     
389: 389:     mapping(address => Juror) public jurors; 
390: 390: 
391: 391:     
392: 392: 
393: 393:     
394: 394: 
395: 395: 
396: 396:     modifier onlyDuringPhase(Phase _phase) {require(phase == _phase); _;}
397: 397: 
398: 398:     
399: 399: 
400: 400: 
401: 401: 
402: 402:     modifier onlyDuringPeriod(uint _disputeID, Period _period) {require(disputes[_disputeID].period == _period); _;}
403: 403: 
404: 404:     
405: 405:     modifier onlyByGovernor() {require(governor == msg.sender); _;}
406: 406: 
407: 407:     
408: 408: 
409: 409:     
410: 410: 
411: 411: 
412: 412: 
413: 413: 
414: 414: 
415: 415: 
416: 416: 
417: 417: 
418: 418: 
419: 419: 
420: 420: 
421: 421: 
422: 422: 
423: 423:     constructor(
424: 424:         address _governor,
425: 425:         MiniMeToken _pinakion,
426: 426:         RNG _RNGenerator,
427: 427:         uint _minStakingTime,
428: 428:         uint _maxDrawingTime,
429: 429:         bool _hiddenVotes,
430: 430:         uint _minStake,
431: 431:         uint _alpha,
432: 432:         uint _feeForJuror,
433: 433:         uint _jurorsForCourtJump,
434: 434:         uint[4] _timesPerPeriod,
435: 435:         uint _sortitionSumTreeK
436: 436:     ) public {
437: 437:         
438: 438:         governor = _governor;
439: 439:         pinakion = _pinakion;
440: 440:         RNGenerator = _RNGenerator;
441: 441:         minStakingTime = _minStakingTime;
442: 442:         maxDrawingTime = _maxDrawingTime;
443: 443:         lastPhaseChange = now;
444: 444: 
445: 445:         
446: 446:         courts.push(Court({
447: 447:             parent: 0,
448: 448:             children: new uint[](0),
449: 449:             hiddenVotes: _hiddenVotes,
450: 450:             minStake: _minStake,
451: 451:             alpha: _alpha,
452: 452:             feeForJuror: _feeForJuror,
453: 453:             jurorsForCourtJump: _jurorsForCourtJump,
454: 454:             timesPerPeriod: _timesPerPeriod
455: 455:         }));
456: 456:         sortitionSumTrees.createTree(bytes32(0), _sortitionSumTreeK);
457: 457:     }
458: 458: 
459: 459:     
460: 460: 
461: 461:     
462: 462: 
463: 463: 
464: 464: 
465: 465: 
466: 466:     function executeGovernorProposal(address _destination, uint _amount, bytes _data) external onlyByGovernor {
467: 467:         require(_destination.call.value(_amount)(_data)); 
468: 468:     }
469: 469: 
470: 470:     
471: 471: 
472: 472: 
473: 473:     function changeGovernor(address _governor) external onlyByGovernor {
474: 474:         governor = _governor;
475: 475:     }
476: 476: 
477: 477:     
478: 478: 
479: 479: 
480: 480:     function changePinakion(MiniMeToken _pinakion) external onlyByGovernor {
481: 481:         pinakion = _pinakion;
482: 482:     }
483: 483: 
484: 484:     
485: 485: 
486: 486: 
487: 487:     function changeRNGenerator(RNG _RNGenerator) external onlyByGovernor {
488: 488:         RNGenerator = _RNGenerator;
489: 489:         if (phase == Phase.generating) {
490: 490:             RNBlock = block.number + 1;
491: 491:             RNGenerator.requestRN(RNBlock);
492: 492:         }
493: 493:     }
494: 494: 
495: 495:     
496: 496: 
497: 497: 
498: 498:     function changeMinStakingTime(uint _minStakingTime) external onlyByGovernor {
499: 499:         minStakingTime = _minStakingTime;
500: 500:     }
501: 501: 
502: 502:     
503: 503: 
504: 504: 
505: 505:     function changeMaxDrawingTime(uint _maxDrawingTime) external onlyByGovernor {
506: 506:         maxDrawingTime = _maxDrawingTime;
507: 507:     }
508: 508: 
509: 509:     
510: 510: 
511: 511: 
512: 512: 
513: 513: 
514: 514: 
515: 515: 
516: 516: 
517: 517: 
518: 518: 
519: 519:     function createSubcourt(
520: 520:         uint96 _parent,
521: 521:         bool _hiddenVotes,
522: 522:         uint _minStake,
523: 523:         uint _alpha,
524: 524:         uint _feeForJuror,
525: 525:         uint _jurorsForCourtJump,
526: 526:         uint[4] _timesPerPeriod,
527: 527:         uint _sortitionSumTreeK
528: 528:     ) external onlyByGovernor {
529: 529:         require(courts[_parent].minStake <= _minStake, "A subcourt cannot be a child of a subcourt with a higher minimum stake.");
530: 530: 
531: 531:         
532: 532:         uint96 subcourtID = uint96(
533: 533:             courts.push(Court({
534: 534:                 parent: _parent,
535: 535:                 children: new uint[](0),
536: 536:                 hiddenVotes: _hiddenVotes,
537: 537:                 minStake: _minStake,
538: 538:                 alpha: _alpha,
539: 539:                 feeForJuror: _feeForJuror,
540: 540:                 jurorsForCourtJump: _jurorsForCourtJump,
541: 541:                 timesPerPeriod: _timesPerPeriod
542: 542:             })) - 1
543: 543:         );
544: 544:         sortitionSumTrees.createTree(bytes32(subcourtID), _sortitionSumTreeK);
545: 545: 
546: 546:         
547: 547:         courts[_parent].children.push(subcourtID);
548: 548:     }
549: 549: 
550: 550:     
551: 551: 
552: 552: 
553: 553: 
554: 554:     function changeSubcourtMinStake(uint96 _subcourtID, uint _minStake) external onlyByGovernor {
555: 555:         require(_subcourtID == 0 || courts[courts[_subcourtID].parent].minStake <= _minStake);
556: 556:         for (uint i = 0; i < courts[_subcourtID].children.length; i++) {
557: 557:             require(
558: 558:                 courts[courts[_subcourtID].children[i]].minStake >= _minStake,
559: 559:                 "A subcourt cannot be the parent of a subcourt with a lower minimum stake."
560: 560:             );
561: 561:         }
562: 562: 
563: 563:         courts[_subcourtID].minStake = _minStake;
564: 564:     }
565: 565: 
566: 566:     
567: 567: 
568: 568: 
569: 569: 
570: 570:     function changeSubcourtAlpha(uint96 _subcourtID, uint _alpha) external onlyByGovernor {
571: 571:         courts[_subcourtID].alpha = _alpha;
572: 572:     }
573: 573: 
574: 574:     
575: 575: 
576: 576: 
577: 577: 
578: 578:     function changeSubcourtJurorFee(uint96 _subcourtID, uint _feeForJuror) external onlyByGovernor {
579: 579:         courts[_subcourtID].feeForJuror = _feeForJuror;
580: 580:     }
581: 581: 
582: 582:     
583: 583: 
584: 584: 
585: 585: 
586: 586:     function changeSubcourtJurorsForJump(uint96 _subcourtID, uint _jurorsForCourtJump) external onlyByGovernor {
587: 587:         courts[_subcourtID].jurorsForCourtJump = _jurorsForCourtJump;
588: 588:     }
589: 589: 
590: 590:     
591: 591: 
592: 592: 
593: 593: 
594: 594:     function changeSubcourtTimesPerPeriod(uint96 _subcourtID, uint[4] _timesPerPeriod) external onlyByGovernor {
595: 595:         courts[_subcourtID].timesPerPeriod = _timesPerPeriod;
596: 596:     }
597: 597: 
598: 598:     
599: 599:     function passPhase() external {
600: 600:         if (phase == Phase.staking) {
601: 601:             require(now - lastPhaseChange >= minStakingTime, "The minimum staking time has not passed yet.");
602: 602:             require(disputesWithoutJurors > 0, "There are no disputes that need jurors.");
603: 603:             RNBlock = block.number + 1;
604: 604:             RNGenerator.requestRN(RNBlock);
605: 605:             phase = Phase.generating;
606: 606:         } else if (phase == Phase.generating) {
607: 607:             RN = RNGenerator.getUncorrelatedRN(RNBlock);
608: 608:             require(RN != 0, "Random number is not ready yet.");
609: 609:             phase = Phase.drawing;
610: 610:         } else if (phase == Phase.drawing) {
611: 611:             require(disputesWithoutJurors == 0 || now - lastPhaseChange >= maxDrawingTime, "There are still disputes without jurors and the maximum drawing time has not passed yet.");
612: 612:             phase = Phase.staking;
613: 613:         }
614: 614: 
615: 615:         lastPhaseChange = now;
616: 616:         emit NewPhase(phase);
617: 617:     }
618: 618: 
619: 619:     
620: 620: 
621: 621: 
622: 622:     function passPeriod(uint _disputeID) external {
623: 623:         Dispute storage dispute = disputes[_disputeID];
624: 624:         if (dispute.period == Period.evidence) {
625: 625:             require(
626: 626:                 dispute.votes.length > 1 || now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)],
627: 627:                 "The evidence period time has not passed yet and it is not an appeal."
628: 628:             );
629: 629:             require(dispute.drawsInRound == dispute.votes[dispute.votes.length - 1].length, "The dispute has not finished drawing yet.");
630: 630:             dispute.period = courts[dispute.subcourtID].hiddenVotes ? Period.commit : Period.vote;
631: 631:         } else if (dispute.period == Period.commit) {
632: 632:             require(
633: 633:                 now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)] || dispute.commitsInRound == dispute.votes[dispute.votes.length - 1].length,
634: 634:                 "The commit period time has not passed yet and not every juror has committed yet."
635: 635:             );
636: 636:             dispute.period = Period.vote;
637: 637:         } else if (dispute.period == Period.vote) {
638: 638:             require(
639: 639:                 now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)] || dispute.votesInEachRound[dispute.votes.length - 1] == dispute.votes[dispute.votes.length - 1].length,
640: 640:                 "The vote period time has not passed yet and not every juror has voted yet."
641: 641:             );
642: 642:             dispute.period = Period.appeal;
643: 643:             emit AppealPossible(_disputeID, dispute.arbitrated);
644: 644:         } else if (dispute.period == Period.appeal) {
645: 645:             require(now - dispute.lastPeriodChange >= courts[dispute.subcourtID].timesPerPeriod[uint(dispute.period)], "The appeal period time has not passed yet.");
646: 646:             dispute.period = Period.execution;
647: 647:         } else if (dispute.period == Period.execution) {
648: 648:             revert("The dispute is already in the last period.");
649: 649:         }
650: 650: 
651: 651:         dispute.lastPeriodChange = now;
652: 652:         emit NewPeriod(_disputeID, dispute.period);
653: 653:     }
654: 654: 
655: 655:     
656: 656: 
657: 657: 
658: 658: 
659: 659:     function setStake(uint96 _subcourtID, uint128 _stake) external {
660: 660:         require(_setStake(msg.sender, _subcourtID, _stake));
661: 661:     }
662: 662: 
663: 663:     
664: 664: 
665: 665: 
666: 666:     function executeDelayedSetStakes(uint _iterations) external onlyDuringPhase(Phase.staking) {
667: 667:         uint actualIterations = (nextDelayedSetStake + _iterations) - 1 > lastDelayedSetStake ?
668: 668:             (lastDelayedSetStake - nextDelayedSetStake) + 1 : _iterations;
669: 669:         uint newNextDelayedSetStake = nextDelayedSetStake + actualIterations;
670: 670:         require(newNextDelayedSetStake >= nextDelayedSetStake);
671: 671:         for (uint i = nextDelayedSetStake; i < newNextDelayedSetStake; i++) {
672: 672:             DelayedSetStake storage delayedSetStake = delayedSetStakes[i];
673: 673:             _setStake(delayedSetStake.account, delayedSetStake.subcourtID, delayedSetStake.stake);
674: 674:             delete delayedSetStakes[i];
675: 675:         }
676: 676:         nextDelayedSetStake = newNextDelayedSetStake;
677: 677:     }
678: 678: 
679: 679:     
680: 680: 
681: 681: 
682: 682: 
683: 683: 
684: 684: 
685: 685: 
686: 686: 
687: 687:     function drawJurors(
688: 688:         uint _disputeID,
689: 689:         uint _iterations
690: 690:     ) external onlyDuringPhase(Phase.drawing) onlyDuringPeriod(_disputeID, Period.evidence) {
691: 691:         Dispute storage dispute = disputes[_disputeID];
692: 692:         uint endIndex = dispute.drawsInRound + _iterations;
693: 693:         require(endIndex >= dispute.drawsInRound);
694: 694: 
695: 695:         
696: 696:         if (endIndex > dispute.votes[dispute.votes.length - 1].length) endIndex = dispute.votes[dispute.votes.length - 1].length;
697: 697:         for (uint i = dispute.drawsInRound; i < endIndex; i++) {
698: 698:             
699: 699:             (
700: 700:                 address drawnAddress,
701: 701:                 uint subcourtID
702: 702:             ) = stakePathIDToAccountAndSubcourtID(sortitionSumTrees.draw(bytes32(dispute.subcourtID), uint(keccak256(RN, _disputeID, i))));
703: 703: 
704: 704:             
705: 705:             dispute.votes[dispute.votes.length - 1][i].account = drawnAddress;
706: 706:             jurors[drawnAddress].lockedTokens += dispute.tokensAtStakePerJuror[dispute.tokensAtStakePerJuror.length - 1];
707: 707:             emit Draw(drawnAddress, _disputeID, dispute.votes.length - 1, i);
708: 708: 
709: 709:             
710: 710:             if (i == dispute.votes[dispute.votes.length - 1].length - 1) disputesWithoutJurors--;
711: 711:         }
712: 712:         dispute.drawsInRound = endIndex;
713: 713:     }
714: 714: 
715: 715:     
716: 716: 
717: 717: 
718: 718: 
719: 719: 
720: 720: 
721: 721: 
722: 722:     function castCommit(uint _disputeID, uint[] _voteIDs, bytes32 _commit) external onlyDuringPeriod(_disputeID, Period.commit) {
723: 723:         Dispute storage dispute = disputes[_disputeID];
724: 724:         require(_commit != bytes32(0));
725: 725:         for (uint i = 0; i < _voteIDs.length; i++) {
726: 726:             require(dispute.votes[dispute.votes.length - 1][_voteIDs[i]].account == msg.sender, "The caller has to own the vote.");
727: 727:             require(dispute.votes[dispute.votes.length - 1][_voteIDs[i]].commit == bytes32(0), "Already committed this vote.");
728: 728:             dispute.votes[dispute.votes.length - 1][_voteIDs[i]].commit = _commit;
729: 729:         }
730: 730:         dispute.commitsInRound += _voteIDs.length;
731: 731:     }
732: 732: 
733: 733:     
734: 734: 
735: 735: 
736: 736: 
737: 737: 
738: 738: 
739: 739: 
740: 740: 
741: 741:     function castVote(uint _disputeID, uint[] _voteIDs, uint _choice, uint _salt) external onlyDuringPeriod(_disputeID, Period.vote) {
742: 742:         Dispute storage dispute = disputes[_disputeID];
743: 743:         require(_voteIDs.length > 0);
744: 744:         require(_choice <= dispute.numberOfChoices, "The choice has to be less than or equal to the number of choices for the dispute.");
745: 745: 
746: 746:         
747: 747:         for (uint i = 0; i < _voteIDs.length; i++) {
748: 748:             require(dispute.votes[dispute.votes.length - 1][_voteIDs[i]].account == msg.sender, "The caller has to own the vote.");
749: 749:             require(
750: 750:                 !courts[dispute.subcourtID].hiddenVotes || dispute.votes[dispute.votes.length - 1][_voteIDs[i]].commit == keccak256(_choice, _salt),
751: 751:                 "The commit must match the choice in subcourts with hidden votes."
752: 752:             );
753: 753:             require(!dispute.votes[dispute.votes.length - 1][_voteIDs[i]].voted, "Vote already cast.");
754: 754:             dispute.votes[dispute.votes.length - 1][_voteIDs[i]].choice = _choice;
755: 755:             dispute.votes[dispute.votes.length - 1][_voteIDs[i]].voted = true;
756: 756:         }
757: 757:         dispute.votesInEachRound[dispute.votes.length - 1] += _voteIDs.length;
758: 758: 
759: 759:         
760: 760:         VoteCounter storage voteCounter = dispute.voteCounters[dispute.voteCounters.length - 1];
761: 761:         voteCounter.counts[_choice] += _voteIDs.length;
762: 762:         if (_choice == voteCounter.winningChoice) { 
763: 763:             if (voteCounter.tied) voteCounter.tied = false; 
764: 764:         } else { 
765: 765:             if (voteCounter.counts[_choice] == voteCounter.counts[voteCounter.winningChoice]) { 
766: 766:                 if (!voteCounter.tied) voteCounter.tied = true;
767: 767:             } else if (voteCounter.counts[_choice] > voteCounter.counts[voteCounter.winningChoice]) { 
768: 768:                 voteCounter.winningChoice = _choice;
769: 769:                 voteCounter.tied = false;
770: 770:             }
771: 771:         }
772: 772:     }
773: 773: 
774: 774:     
775: 775: 
776: 776: 
777: 777: 
778: 778: 
779: 779:     function computeTokenAndETHRewards(uint _disputeID, uint _appeal) private view returns(uint tokenReward, uint ETHReward) {
780: 780:         Dispute storage dispute = disputes[_disputeID];
781: 781: 
782: 782:         
783: 783:         if (dispute.voteCounters[dispute.voteCounters.length - 1].tied) {
784: 784:             
785: 785:             uint activeCount = dispute.votesInEachRound[_appeal];
786: 786:             if (activeCount > 0) {
787: 787:                 tokenReward = dispute.penaltiesInEachRound[_appeal] / activeCount;
788: 788:                 ETHReward = dispute.totalFeesForJurors[_appeal] / activeCount;
789: 789:             } else {
790: 790:                 tokenReward = 0;
791: 791:                 ETHReward = 0;
792: 792:             }
793: 793:         } else {
794: 794:             
795: 795:             uint winningChoice = dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice;
796: 796:             uint coherentCount = dispute.voteCounters[_appeal].counts[winningChoice];
797: 797:             tokenReward = dispute.penaltiesInEachRound[_appeal] / coherentCount;
798: 798:             ETHReward = dispute.totalFeesForJurors[_appeal] / coherentCount;
799: 799:         }
800: 800:     }
801: 801: 
802: 802:     
803: 803: 
804: 804: 
805: 805: 
806: 806: 
807: 807: 
808: 808: 
809: 809: 
810: 810: 
811: 811: 
812: 812: 
813: 813: 
814: 814:     function execute(uint _disputeID, uint _appeal, uint _iterations) external onlyDuringPeriod(_disputeID, Period.execution) {
815: 815:         lockInsolventTransfers = false;
816: 816:         Dispute storage dispute = disputes[_disputeID];
817: 817:         uint end = dispute.repartitionsInEachRound[_appeal] + _iterations;
818: 818:         require(end >= dispute.repartitionsInEachRound[_appeal]);
819: 819:         uint penaltiesInRoundCache = dispute.penaltiesInEachRound[_appeal]; 
820: 820:         (uint tokenReward, uint ETHReward) = (0, 0);
821: 821: 
822: 822:         
823: 823:         if (
824: 824:             !dispute.voteCounters[dispute.voteCounters.length - 1].tied &&
825: 825:             dispute.voteCounters[_appeal].counts[dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice] == 0
826: 826:         ) {
827: 827:             
828: 828:             if (end > dispute.votes[_appeal].length) end = dispute.votes[_appeal].length;
829: 829:         } else {
830: 830:             
831: 831:             (tokenReward, ETHReward) = dispute.repartitionsInEachRound[_appeal] >= dispute.votes[_appeal].length ? computeTokenAndETHRewards(_disputeID, _appeal) : (0, 0); 
832: 832:             if (end > dispute.votes[_appeal].length * 2) end = dispute.votes[_appeal].length * 2;
833: 833:         }
834: 834:         for (uint i = dispute.repartitionsInEachRound[_appeal]; i < end; i++) {
835: 835:             Vote storage vote = dispute.votes[_appeal][i % dispute.votes[_appeal].length];
836: 836:             if (
837: 837:                 vote.voted &&
838: 838:                 (vote.choice == dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice || dispute.voteCounters[dispute.voteCounters.length - 1].tied)
839: 839:             ) { 
840: 840:                 if (i >= dispute.votes[_appeal].length) { 
841: 841: 
842: 842:                     
843: 843:                     pinakion.transfer(vote.account, tokenReward);
844: 844:                     
845: 845:                     vote.account.send(ETHReward); 
846: 846:                     emit TokenAndETHShift(vote.account, _disputeID, int(tokenReward), int(ETHReward));
847: 847:                     jurors[vote.account].lockedTokens -= dispute.tokensAtStakePerJuror[_appeal];
848: 848:                 }
849: 849:             } else { 
850: 850:                 if (i < dispute.votes[_appeal].length) { 
851: 851: 
852: 852:                     
853: 853:                     uint penalty = dispute.tokensAtStakePerJuror[_appeal] > pinakion.balanceOf(vote.account) ? pinakion.balanceOf(vote.account) : dispute.tokensAtStakePerJuror[_appeal];
854: 854:                     pinakion.transferFrom(vote.account, this, penalty);
855: 855:                     emit TokenAndETHShift(vote.account, _disputeID, -int(penalty), 0);
856: 856:                     penaltiesInRoundCache += penalty;
857: 857:                     jurors[vote.account].lockedTokens -= dispute.tokensAtStakePerJuror[_appeal];
858: 858: 
859: 859:                     
860: 860:                     if (pinakion.balanceOf(vote.account) < jurors[vote.account].stakedTokens || !vote.voted)
861: 861:                         for (uint j = 0; j < jurors[vote.account].subcourtIDs.length; j++)
862: 862:                             _setStake(vote.account, jurors[vote.account].subcourtIDs[j], 0);
863: 863: 
864: 864:                 }
865: 865:             }
866: 866:             if (i == dispute.votes[_appeal].length - 1) {
867: 867:                 
868: 868:                 if (dispute.votesInEachRound[_appeal] == 0 || !dispute.voteCounters[dispute.voteCounters.length - 1].tied && dispute.voteCounters[_appeal].counts[dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice] == 0) {
869: 869:                     
870: 870:                     governor.send(dispute.totalFeesForJurors[_appeal]); 
871: 871:                     pinakion.transfer(governor, penaltiesInRoundCache);
872: 872:                 } else if (i + 1 < end) {
873: 873:                     
874: 874:                     dispute.penaltiesInEachRound[_appeal] = penaltiesInRoundCache;
875: 875:                     (tokenReward, ETHReward) = computeTokenAndETHRewards(_disputeID, _appeal);
876: 876:                 }
877: 877:             }
878: 878:         }
879: 879:         if (dispute.penaltiesInEachRound[_appeal] != penaltiesInRoundCache) dispute.penaltiesInEachRound[_appeal] = penaltiesInRoundCache;
880: 880:         dispute.repartitionsInEachRound[_appeal] = end;
881: 881:         lockInsolventTransfers = true;
882: 882:     }
883: 883: 
884: 884:     
885: 885: 
886: 886: 
887: 887:     function executeRuling(uint _disputeID) external onlyDuringPeriod(_disputeID, Period.execution) {
888: 888:         Dispute storage dispute = disputes[_disputeID];
889: 889:         require(!dispute.ruled, "Ruling already executed.");
890: 890:         dispute.ruled = true;
891: 891:         uint winningChoice = dispute.voteCounters[dispute.voteCounters.length - 1].tied ? 0
892: 892:             : dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice;
893: 893:         dispute.arbitrated.rule(_disputeID, winningChoice);
894: 894:     }
895: 895: 
896: 896:     
897: 897: 
898: 898:     
899: 899: 
900: 900: 
901: 901: 
902: 902: 
903: 903:     function createDispute(
904: 904:         uint _numberOfChoices,
905: 905:         bytes _extraData
906: 906:     ) public payable requireArbitrationFee(_extraData) returns(uint disputeID)  {
907: 907:         (uint96 subcourtID, uint minJurors) = extraDataToSubcourtIDAndMinJurors(_extraData);
908: 908:         disputeID = disputes.length++;
909: 909:         Dispute storage dispute = disputes[disputeID];
910: 910:         dispute.subcourtID = subcourtID;
911: 911:         dispute.arbitrated = Arbitrable(msg.sender);
912: 912:         dispute.numberOfChoices = _numberOfChoices;
913: 913:         dispute.period = Period.evidence;
914: 914:         dispute.lastPeriodChange = now;
915: 915:         
916: 916:         dispute.votes[dispute.votes.length++].length = msg.value / courts[dispute.subcourtID].feeForJuror;
917: 917:         dispute.voteCounters[dispute.voteCounters.length++].tied = true;
918: 918:         dispute.tokensAtStakePerJuror.push((courts[dispute.subcourtID].minStake * courts[dispute.subcourtID].alpha) / ALPHA_DIVISOR);
919: 919:         dispute.totalFeesForJurors.push(msg.value);
920: 920:         dispute.votesInEachRound.push(0);
921: 921:         dispute.repartitionsInEachRound.push(0);
922: 922:         dispute.penaltiesInEachRound.push(0);
923: 923:         disputesWithoutJurors++;
924: 924: 
925: 925:         emit DisputeCreation(disputeID, Arbitrable(msg.sender));
926: 926:     }
927: 927: 
928: 928:     
929: 929: 
930: 930: 
931: 931: 
932: 932:     function appeal(
933: 933:         uint _disputeID,
934: 934:         bytes _extraData
935: 935:     ) public payable requireAppealFee(_disputeID, _extraData) onlyDuringPeriod(_disputeID, Period.appeal) {
936: 936:         Dispute storage dispute = disputes[_disputeID];
937: 937:         require(
938: 938:             msg.sender == address(dispute.arbitrated),
939: 939:             "Can only be called by the arbitrable contract."
940: 940:         );
941: 941:         if (dispute.votes[dispute.votes.length - 1].length >= courts[dispute.subcourtID].jurorsForCourtJump) 
942: 942:             dispute.subcourtID = courts[dispute.subcourtID].parent;
943: 943:         dispute.period = Period.evidence;
944: 944:         dispute.lastPeriodChange = now;
945: 945:         
946: 946:         dispute.votes[dispute.votes.length++].length = msg.value / courts[dispute.subcourtID].feeForJuror;
947: 947:         dispute.voteCounters[dispute.voteCounters.length++].tied = true;
948: 948:         dispute.tokensAtStakePerJuror.push((courts[dispute.subcourtID].minStake * courts[dispute.subcourtID].alpha) / ALPHA_DIVISOR);
949: 949:         dispute.totalFeesForJurors.push(msg.value);
950: 950:         dispute.drawsInRound = 0;
951: 951:         dispute.commitsInRound = 0;
952: 952:         dispute.votesInEachRound.push(0);
953: 953:         dispute.repartitionsInEachRound.push(0);
954: 954:         dispute.penaltiesInEachRound.push(0);
955: 955:         disputesWithoutJurors++;
956: 956: 
957: 957:         emit AppealDecision(_disputeID, Arbitrable(msg.sender));
958: 958:     }
959: 959: 
960: 960:     
961: 961: 
962: 962: 
963: 963: 
964: 964:     function proxyPayment(address _owner) public payable returns(bool allowed) { allowed = false; }
965: 965: 
966: 966:     
967: 967: 
968: 968: 
969: 969: 
970: 970: 
971: 971: 
972: 972:     function onTransfer(address _from, address _to, uint _amount) public returns(bool allowed) {
973: 973:         if (lockInsolventTransfers) { 
974: 974:             uint newBalance = pinakion.balanceOf(_from) - _amount;
975: 975:             if (newBalance < jurors[_from].stakedTokens || newBalance < jurors[_from].lockedTokens) return false;
976: 976:         }
977: 977:         allowed = true;
978: 978:     }
979: 979: 
980: 980:     
981: 981: 
982: 982: 
983: 983: 
984: 984: 
985: 985: 
986: 986:     function onApprove(address _owner, address _spender, uint _amount) public returns(bool allowed) { allowed = true; }
987: 987: 
988: 988:     
989: 989: 
990: 990:     
991: 991: 
992: 992: 
993: 993: 
994: 994:     function arbitrationCost(bytes _extraData) public view returns(uint cost) {
995: 995:         (uint96 subcourtID, uint minJurors) = extraDataToSubcourtIDAndMinJurors(_extraData);
996: 996:         cost = courts[subcourtID].feeForJuror * minJurors;
997: 997:     }
998: 998: 
999: 999:     
1000: 1000: 
1001: 1001: 
1002: 1002: 
1003: 1003: 
1004: 1004:     function appealCost(uint _disputeID, bytes _extraData) public view returns(uint cost) {
1005: 1005:         Dispute storage dispute = disputes[_disputeID];
1006: 1006:         uint lastNumberOfJurors = dispute.votes[dispute.votes.length - 1].length;
1007: 1007:         if (lastNumberOfJurors >= courts[dispute.subcourtID].jurorsForCourtJump) { 
1008: 1008:             if (dispute.subcourtID == 0) 
1009: 1009:                 cost = NON_PAYABLE_AMOUNT;
1010: 1010:             else 
1011: 1011:                 cost = courts[courts[dispute.subcourtID].parent].feeForJuror * ((lastNumberOfJurors * 2) + 1);
1012: 1012:         } else 
1013: 1013:             cost = courts[dispute.subcourtID].feeForJuror * ((lastNumberOfJurors * 2) + 1);
1014: 1014:     }
1015: 1015: 
1016: 1016:     
1017: 1017: 
1018: 1018: 
1019: 1019: 
1020: 1020:     function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {
1021: 1021:         Dispute storage dispute = disputes[_disputeID];
1022: 1022:         if (dispute.period == Period.appeal) {
1023: 1023:             start = dispute.lastPeriodChange;
1024: 1024:             end = dispute.lastPeriodChange + courts[dispute.subcourtID].timesPerPeriod[uint(Period.appeal)];
1025: 1025:         } else {
1026: 1026:             start = 0;
1027: 1027:             end = 0;
1028: 1028:         }
1029: 1029:     }
1030: 1030: 
1031: 1031:     
1032: 1032: 
1033: 1033: 
1034: 1034: 
1035: 1035:     function disputeStatus(uint _disputeID) public view returns(DisputeStatus status) {
1036: 1036:         Dispute storage dispute = disputes[_disputeID];
1037: 1037:         if (dispute.period < Period.appeal) status = DisputeStatus.Waiting;
1038: 1038:         else if (dispute.period < Period.execution) status = DisputeStatus.Appealable;
1039: 1039:         else status = DisputeStatus.Solved;
1040: 1040:     }
1041: 1041: 
1042: 1042:     
1043: 1043: 
1044: 1044: 
1045: 1045: 
1046: 1046:     function currentRuling(uint _disputeID) public view returns(uint ruling) {
1047: 1047:         Dispute storage dispute = disputes[_disputeID];
1048: 1048:         ruling = dispute.voteCounters[dispute.voteCounters.length - 1].tied ? 0
1049: 1049:             : dispute.voteCounters[dispute.voteCounters.length - 1].winningChoice;
1050: 1050:     }
1051: 1051: 
1052: 1052:     
1053: 1053: 
1054: 1054:     
1055: 1055: 
1056: 1056: 
1057: 1057: 
1058: 1058: 
1059: 1059: 
1060: 1060: 
1061: 1061: 
1062: 1062: 
1063: 1063: 
1064: 1064: 
1065: 1065:     function _setStake(address _account, uint96 _subcourtID, uint128 _stake) internal returns(bool succeeded) {
1066: 1066:         if (!(_subcourtID < courts.length))
1067: 1067:             return false;
1068: 1068: 
1069: 1069:         
1070: 1070:         if (phase != Phase.staking) {
1071: 1071:             delayedSetStakes[++lastDelayedSetStake] = DelayedSetStake({ account: _account, subcourtID: _subcourtID, stake: _stake });
1072: 1072:             return true;
1073: 1073:         }
1074: 1074: 
1075: 1075:         if (!(_stake == 0 || courts[_subcourtID].minStake <= _stake))
1076: 1076:             return false; 
1077: 1077:         Juror storage juror = jurors[_account];
1078: 1078:         bytes32 stakePathID = accountAndSubcourtIDToStakePathID(_account, _subcourtID);
1079: 1079:         uint currentStake = sortitionSumTrees.stakeOf(bytes32(_subcourtID), stakePathID);
1080: 1080:         if (!(_stake == 0 || currentStake > 0 || juror.subcourtIDs.length < MAX_STAKE_PATHS))
1081: 1081:             return false; 
1082: 1082:         uint newTotalStake = juror.stakedTokens - currentStake + _stake; 
1083: 1083:         if (!(_stake == 0 || pinakion.balanceOf(_account) >= newTotalStake))
1084: 1084:             return false; 
1085: 1085: 
1086: 1086:         
1087: 1087:         juror.stakedTokens = newTotalStake;
1088: 1088:         if (_stake == 0) {
1089: 1089:             for (uint i = 0; i < juror.subcourtIDs.length; i++)
1090: 1090:                 if (juror.subcourtIDs[i] == _subcourtID) {
1091: 1091:                     juror.subcourtIDs[i] = juror.subcourtIDs[juror.subcourtIDs.length - 1];
1092: 1092:                     juror.subcourtIDs.length--;
1093: 1093:                     break;
1094: 1094:                 }
1095: 1095:         } else if (currentStake == 0) juror.subcourtIDs.push(_subcourtID);
1096: 1096: 
1097: 1097:         
1098: 1098:         bool finished = false;
1099: 1099:         uint currentSubcourtID = _subcourtID;
1100: 1100:         while (!finished) {
1101: 1101:             sortitionSumTrees.set(bytes32(currentSubcourtID), _stake, stakePathID);
1102: 1102:             if (currentSubcourtID == 0) finished = true;
1103: 1103:             else currentSubcourtID = courts[currentSubcourtID].parent;
1104: 1104:         }
1105: 1105:         emit StakeSet(_account, _subcourtID, _stake, newTotalStake);
1106: 1106:         return true;
1107: 1107:     }
1108: 1108: 
1109: 1109:     
1110: 1110: 
1111: 1111: 
1112: 1112: 
1113: 1113:     function extraDataToSubcourtIDAndMinJurors(bytes _extraData) internal view returns (uint96 subcourtID, uint minJurors) {
1114: 1114:         if (_extraData.length >= 64) {
1115: 1115:             assembly { 
1116: 1116:                 subcourtID := mload(add(_extraData, 0x20))
1117: 1117:                 minJurors := mload(add(_extraData, 0x40))
1118: 1118:             }
1119: 1119:             if (subcourtID >= courts.length) subcourtID = 0;
1120: 1120:             if (minJurors == 0) minJurors = MIN_JURORS;
1121: 1121:         } else {
1122: 1122:             subcourtID = 0;
1123: 1123:             minJurors = MIN_JURORS;
1124: 1124:         }
1125: 1125:     }
1126: 1126: 
1127: 1127:     
1128: 1128: 
1129: 1129: 
1130: 1130: 
1131: 1131: 
1132: 1132:     function accountAndSubcourtIDToStakePathID(address _account, uint96 _subcourtID) internal pure returns (bytes32 stakePathID) {
1133: 1133:         assembly { 
1134: 1134:             let ptr := mload(0x40)
1135: 1135:             for { let i := 0x00 } lt(i, 0x14) { i := add(i, 0x01) } {
1136: 1136:                 mstore8(add(ptr, i), byte(add(0x0c, i), _account))
1137: 1137:             }
1138: 1138:             for { let i := 0x14 } lt(i, 0x20) { i := add(i, 0x01) } {
1139: 1139:                 mstore8(add(ptr, i), byte(i, _subcourtID))
1140: 1140:             }
1141: 1141:             stakePathID := mload(ptr)
1142: 1142:         }
1143: 1143:     }
1144: 1144: 
1145: 1145:     
1146: 1146: 
1147: 1147: 
1148: 1148: 
1149: 1149:     function stakePathIDToAccountAndSubcourtID(bytes32 _stakePathID) internal pure returns (address account, uint96 subcourtID) {
1150: 1150:         assembly { 
1151: 1151:             let ptr := mload(0x40)
1152: 1152:             for { let i := 0x00 } lt(i, 0x14) { i := add(i, 0x01) } {
1153: 1153:                 mstore8(add(add(ptr, 0x0c), i), byte(i, _stakePathID))
1154: 1154:             }
1155: 1155:             account := mload(ptr)
1156: 1156:             subcourtID := _stakePathID
1157: 1157:         }
1158: 1158:     }
1159: 1159:     
1160: 1160:     
1161: 1161: 
1162: 1162:     
1163: 1163: 
1164: 1164: 
1165: 1165: 
1166: 1166:     function getSubcourt(uint96 _subcourtID) external view returns(
1167: 1167:         uint[] children,
1168: 1168:         uint[4] timesPerPeriod
1169: 1169:     ) {
1170: 1170:         Court storage subcourt = courts[_subcourtID];
1171: 1171:         children = subcourt.children;
1172: 1172:         timesPerPeriod = subcourt.timesPerPeriod;
1173: 1173:     }
1174: 1174: 
1175: 1175:     
1176: 1176: 
1177: 1177: 
1178: 1178: 
1179: 1179: 
1180: 1180: 
1181: 1181:     function getVote(uint _disputeID, uint _appeal, uint _voteID) external view returns(
1182: 1182:         address account,
1183: 1183:         bytes32 commit,
1184: 1184:         uint choice,
1185: 1185:         bool voted
1186: 1186:     ) {
1187: 1187:         Vote storage vote = disputes[_disputeID].votes[_appeal][_voteID];
1188: 1188:         account = vote.account;
1189: 1189:         commit = vote.commit;
1190: 1190:         choice = vote.choice;
1191: 1191:         voted = vote.voted;
1192: 1192:     }
1193: 1193: 
1194: 1194:     
1195: 1195: 
1196: 1196: 
1197: 1197: 
1198: 1198: 
1199: 1199: 
1200: 1200: 
1201: 1201: 
1202: 1202:     function getVoteCounter(uint _disputeID, uint _appeal) external view returns(
1203: 1203:         uint winningChoice,
1204: 1204:         uint[] counts,
1205: 1205:         bool tied
1206: 1206:     ) {
1207: 1207:         Dispute storage dispute = disputes[_disputeID];
1208: 1208:         VoteCounter storage voteCounter = dispute.voteCounters[_appeal];
1209: 1209:         winningChoice = voteCounter.winningChoice;
1210: 1210:         counts = new uint[](dispute.numberOfChoices + 1);
1211: 1211:         for (uint i = 0; i <= dispute.numberOfChoices; i++) counts[i] = voteCounter.counts[i];
1212: 1212:         tied = voteCounter.tied;
1213: 1213:     }
1214: 1214: 
1215: 1215:     
1216: 1216: 
1217: 1217: 
1218: 1218: 
1219: 1219: 
1220: 1220: 
1221: 1221:     function getDispute(uint _disputeID) external view returns(
1222: 1222:         uint[] votesLengths,
1223: 1223:         uint[] tokensAtStakePerJuror,
1224: 1224:         uint[] totalFeesForJurors,
1225: 1225:         uint[] votesInEachRound,
1226: 1226:         uint[] repartitionsInEachRound,
1227: 1227:         uint[] penaltiesInEachRound
1228: 1228:     ) {
1229: 1229:         Dispute storage dispute = disputes[_disputeID];
1230: 1230:         votesLengths = new uint[](dispute.votes.length);
1231: 1231:         for (uint i = 0; i < dispute.votes.length; i++) votesLengths[i] = dispute.votes[i].length;
1232: 1232:         tokensAtStakePerJuror = dispute.tokensAtStakePerJuror;
1233: 1233:         totalFeesForJurors = dispute.totalFeesForJurors;
1234: 1234:         votesInEachRound = dispute.votesInEachRound;
1235: 1235:         repartitionsInEachRound = dispute.repartitionsInEachRound;
1236: 1236:         penaltiesInEachRound = dispute.penaltiesInEachRound;
1237: 1237:     }
1238: 1238: 
1239: 1239:     
1240: 1240: 
1241: 1241: 
1242: 1242: 
1243: 1243:     function getJuror(address _account) external view returns(
1244: 1244:         uint96[] subcourtIDs
1245: 1245:     ) {
1246: 1246:         Juror storage juror = jurors[_account];
1247: 1247:         subcourtIDs = juror.subcourtIDs;
1248: 1248:     }
1249: 1249: 
1250: 1250:     
1251: 1251: 
1252: 1252: 
1253: 1253: 
1254: 1254: 
1255: 1255:     function stakeOf(address _account, uint96 _subcourtID) external view returns(uint stake) {
1256: 1256:         return sortitionSumTrees.stakeOf(bytes32(_subcourtID), accountAndSubcourtIDToStakePathID(_account, _subcourtID));
1257: 1257:     }
1258: 1258: }