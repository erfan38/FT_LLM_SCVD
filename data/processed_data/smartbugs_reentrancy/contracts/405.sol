1: 1: 
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: pragma solidity ^0.4.24;
9: 9: 
10: 10: 
11: 11: contract Kleros is Arbitrator, ApproveAndCallFallBack {
12: 12: 
13: 13:     
14: 14:     
15: 15:     
16: 16: 
17: 17:     
18: 18:     Pinakion public pinakion;
19: 19:     uint public constant NON_PAYABLE_AMOUNT = (2**256 - 2) / 2; 
20: 20: 
21: 21:     
22: 22:     
23: 23:     RNG public rng; 
24: 24:     uint public arbitrationFeePerJuror = 0.05 ether; 
25: 25:     uint16 public defaultNumberJuror = 3; 
26: 26:     uint public minActivatedToken = 0.1 * 1e18; 
27: 27:     uint[5] public timePerPeriod; 
28: 28:     uint public alpha = 2000; 
29: 29:     uint constant ALPHA_DIVISOR = 1e4; 
30: 30:     uint public maxAppeals = 5; 
31: 31:     
32: 32:     
33: 33:     address public governor; 
34: 34: 
35: 35:     
36: 36:     uint public session = 1;      
37: 37:     uint public lastPeriodChange; 
38: 38:     uint public segmentSize;      
39: 39:     uint public rnBlock;          
40: 40:     uint public randomNumber;     
41: 41: 
42: 42:     enum Period {
43: 43:         Activation, 
44: 44:         Draw,       
45: 45:         Vote,       
46: 46:         Appeal,     
47: 47:         Execution   
48: 48:     }
49: 49: 
50: 50:     Period public period;
51: 51: 
52: 52:     struct Juror {
53: 53:         uint balance;      
54: 54:         uint atStake;      
55: 55:         uint lastSession;  
56: 56:         uint segmentStart; 
57: 57:         uint segmentEnd;   
58: 58:     }
59: 59: 
60: 60:     mapping (address => Juror) public jurors;
61: 61: 
62: 62:     struct Vote {
63: 63:         address account; 
64: 64:         uint ruling;     
65: 65:     }
66: 66: 
67: 67:     struct VoteCounter {
68: 68:         uint winningChoice; 
69: 69:         uint winningCount;  
70: 70:         mapping (uint => uint) voteCount; 
71: 71:     }
72: 72: 
73: 73:     enum DisputeState {
74: 74:         Open,       
75: 75:         Resolving,  
76: 76:         Executable, 
77: 77:         Executed    
78: 78:     }
79: 79: 
80: 80:     struct Dispute {
81: 81:         Arbitrable arbitrated;       
82: 82:         uint session;                
83: 83:         uint appeals;                
84: 84:         uint choices;                
85: 85:         uint16 initialNumberJurors;  
86: 86:         uint arbitrationFeePerJuror; 
87: 87:         DisputeState state;          
88: 88:         Vote[][] votes;              
89: 89:         VoteCounter[] voteCounter;   
90: 90:         mapping (address => uint) lastSessionVote; 
91: 91:         uint currentAppealToRepartition; 
92: 92:         AppealsRepartitioned[] appealsRepartitioned; 
93: 93:     }
94: 94: 
95: 95:     enum RepartitionStage { 
96: 96:         Incoherent,
97: 97:         Coherent,
98: 98:         AtStake,
99: 99:         Complete
100: 100:     }
101: 101: 
102: 102:     struct AppealsRepartitioned {
103: 103:         uint totalToRedistribute;   
104: 104:         uint nbCoherent;            
105: 105:         uint currentIncoherentVote; 
106: 106:         uint currentCoherentVote;   
107: 107:         uint currentAtStakeVote;    
108: 108:         RepartitionStage stage;     
109: 109:     }
110: 110: 
111: 111:     Dispute[] public disputes;
112: 112: 
113: 113:     
114: 114:     
115: 115:     
116: 116: 
117: 117:     
118: 118: 
119: 119: 
120: 120: 
121: 121:     event NewPeriod(Period _period, uint indexed _session);
122: 122: 
123: 123:     
124: 124: 
125: 125: 
126: 126: 
127: 127: 
128: 128:     event TokenShift(address indexed _account, uint _disputeID, int _amount);
129: 129: 
130: 130:     
131: 131: 
132: 132: 
133: 133: 
134: 134: 
135: 135:     event ArbitrationReward(address indexed _account, uint _disputeID, uint _amount);
136: 136: 
137: 137:     
138: 138:     
139: 139:     
140: 140:     modifier onlyBy(address _account) {require(msg.sender == _account); _;}
141: 141:     modifier onlyDuring(Period _period) {require(period == _period); _;}
142: 142:     modifier onlyGovernor() {require(msg.sender == governor); _;}
143: 143: 
144: 144: 
145: 145:     
146: 146: 
147: 147: 
148: 148: 
149: 149: 
150: 150: 
151: 151:     constructor(Pinakion _pinakion, RNG _rng, uint[5] _timePerPeriod, address _governor) public {
152: 152:         pinakion = _pinakion;
153: 153:         rng = _rng;
154: 154:         lastPeriodChange = now;
155: 155:         timePerPeriod = _timePerPeriod;
156: 156:         governor = _governor;
157: 157:     }
158: 158: 
159: 159:     
160: 160:     
161: 161:     
162: 162:     
163: 163: 
164: 164:     
165: 165: 
166: 166: 
167: 167: 
168: 168:     function receiveApproval(address _from, uint _amount, address, bytes) public onlyBy(pinakion) {
169: 169:         require(pinakion.transferFrom(_from, this, _amount));
170: 170: 
171: 171:         jurors[_from].balance += _amount;
172: 172:     }
173: 173: 
174: 174:     
175: 175: 
176: 176: 
177: 177: 
178: 178: 
179: 179:     function withdraw(uint _value) public {
180: 180:         Juror storage juror = jurors[msg.sender];
181: 181:         require(juror.atStake <= juror.balance); 
182: 182:         require(_value <= juror.balance-juror.atStake);
183: 183:         require(juror.lastSession != session);
184: 184: 
185: 185:         juror.balance -= _value;
186: 186:         require(pinakion.transfer(msg.sender,_value));
187: 187:     }
188: 188: 
189: 189:     
190: 190:     
191: 191:     
192: 192:     
193: 193: 
194: 194:     
195: 195: 
196: 196:     function passPeriod() public {
197: 197:         require(now-lastPeriodChange >= timePerPeriod[uint8(period)]);
198: 198: 
199: 199:         if (period == Period.Activation) {
200: 200:             rnBlock = block.number + 1;
201: 201:             rng.requestRN(rnBlock);
202: 202:             period = Period.Draw;
203: 203:         } else if (period == Period.Draw) {
204: 204:             randomNumber = rng.getUncorrelatedRN(rnBlock);
205: 205:             require(randomNumber != 0);
206: 206:             period = Period.Vote;
207: 207:         } else if (period == Period.Vote) {
208: 208:             period = Period.Appeal;
209: 209:         } else if (period == Period.Appeal) {
210: 210:             period = Period.Execution;
211: 211:         } else if (period == Period.Execution) {
212: 212:             period = Period.Activation;
213: 213:             ++session;
214: 214:             segmentSize = 0;
215: 215:             rnBlock = 0;
216: 216:             randomNumber = 0;
217: 217:         }
218: 218: 
219: 219: 
220: 220:         lastPeriodChange = now;
221: 221:         NewPeriod(period, session);
222: 222:     }
223: 223: 
224: 224: 
225: 225:     
226: 226: 
227: 227: 
228: 228: 
229: 229:     function activateTokens(uint _value) public onlyDuring(Period.Activation) {
230: 230:         Juror storage juror = jurors[msg.sender];
231: 231:         require(_value <= juror.balance);
232: 232:         require(_value >= minActivatedToken);
233: 233:         require(juror.lastSession != session); 
234: 234: 
235: 235:         juror.lastSession = session;
236: 236:         juror.segmentStart = segmentSize;
237: 237:         segmentSize += _value;
238: 238:         juror.segmentEnd = segmentSize;
239: 239: 
240: 240:     }
241: 241: 
242: 242:     
243: 243: 
244: 244: 
245: 245: 
246: 246: 
247: 247: 
248: 248: 
249: 249: 
250: 250:     function voteRuling(uint _disputeID, uint _ruling, uint[] _draws) public onlyDuring(Period.Vote) {
251: 251:         Dispute storage dispute = disputes[_disputeID];
252: 252:         Juror storage juror = jurors[msg.sender];
253: 253:         VoteCounter storage voteCounter = dispute.voteCounter[dispute.appeals];
254: 254:         require(dispute.lastSessionVote[msg.sender] != session); 
255: 255:         require(_ruling <= dispute.choices);
256: 256:         
257: 257:         require(validDraws(msg.sender, _disputeID, _draws));
258: 258: 
259: 259:         dispute.lastSessionVote[msg.sender] = session;
260: 260:         voteCounter.voteCount[_ruling] += _draws.length;
261: 261:         if (voteCounter.winningCount < voteCounter.voteCount[_ruling]) {
262: 262:             voteCounter.winningCount = voteCounter.voteCount[_ruling];
263: 263:             voteCounter.winningChoice = _ruling;
264: 264:         } else if (voteCounter.winningCount==voteCounter.voteCount[_ruling] && _draws.length!=0) { 
265: 265:             voteCounter.winningChoice = 0; 
266: 266:         }
267: 267:         for (uint i = 0; i < _draws.length; ++i) {
268: 268:             dispute.votes[dispute.appeals].push(Vote({
269: 269:                 account: msg.sender,
270: 270:                 ruling: _ruling
271: 271:             }));
272: 272:         }
273: 273: 
274: 274:         juror.atStake += _draws.length * getStakePerDraw();
275: 275:         uint feeToPay = _draws.length * dispute.arbitrationFeePerJuror;
276: 276:         msg.sender.transfer(feeToPay);
277: 277:         ArbitrationReward(msg.sender, _disputeID, feeToPay);
278: 278:     }
279: 279: 
280: 280:     
281: 281: 
282: 282: 
283: 283: 
284: 284: 
285: 285: 
286: 286: 
287: 287: 
288: 288:     function penalizeInactiveJuror(address _jurorAddress, uint _disputeID, uint[] _draws) public {
289: 289:         Dispute storage dispute = disputes[_disputeID];
290: 290:         Juror storage inactiveJuror = jurors[_jurorAddress];
291: 291:         require(period > Period.Vote);
292: 292:         require(dispute.lastSessionVote[_jurorAddress] != session); 
293: 293:         dispute.lastSessionVote[_jurorAddress] = session; 
294: 294:         require(validDraws(_jurorAddress, _disputeID, _draws));
295: 295:         uint penality = _draws.length * minActivatedToken * 2 * alpha / ALPHA_DIVISOR;
296: 296:         penality = (penality < inactiveJuror.balance) ? penality : inactiveJuror.balance; 
297: 297:         inactiveJuror.balance -= penality;
298: 298:         TokenShift(_jurorAddress, _disputeID, -int(penality));
299: 299:         jurors[msg.sender].balance += penality / 2; 
300: 300:         TokenShift(msg.sender, _disputeID, int(penality / 2));
301: 301:         jurors[governor].balance += penality / 2; 
302: 302:         TokenShift(governor, _disputeID, int(penality / 2));
303: 303:         msg.sender.transfer(_draws.length*dispute.arbitrationFeePerJuror); 
304: 304:     }
305: 305: 
306: 306:     
307: 307: 
308: 308: 
309: 309: 
310: 310: 
311: 311: 
312: 312: 
313: 313:     function oneShotTokenRepartition(uint _disputeID) public onlyDuring(Period.Execution) {
314: 314:         Dispute storage dispute = disputes[_disputeID];
315: 315:         require(dispute.state == DisputeState.Open);
316: 316:         require(dispute.session+dispute.appeals <= session);
317: 317: 
318: 318:         uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
319: 319:         uint amountShift = getStakePerDraw();
320: 320:         for (uint i = 0; i <= dispute.appeals; ++i) {
321: 321:             
322: 322:             
323: 323:             
324: 324:             if (winningChoice!=0 || (dispute.voteCounter[dispute.appeals].voteCount[0] == dispute.voteCounter[dispute.appeals].winningCount)) {
325: 325:                 uint totalToRedistribute = 0;
326: 326:                 uint nbCoherent = 0;
327: 327:                 
328: 328:                 for (uint j = 0; j < dispute.votes[i].length; ++j) {
329: 329:                     Vote storage vote = dispute.votes[i][j];
330: 330:                     if (vote.ruling != winningChoice) {
331: 331:                         Juror storage juror = jurors[vote.account];
332: 332:                         uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
333: 333:                         juror.balance -= penalty;
334: 334:                         TokenShift(vote.account, _disputeID, int(-penalty));
335: 335:                         totalToRedistribute += penalty;
336: 336:                     } else {
337: 337:                         ++nbCoherent;
338: 338:                     }
339: 339:                 }
340: 340:                 if (nbCoherent == 0) { 
341: 341:                     jurors[governor].balance += totalToRedistribute;
342: 342:                     TokenShift(governor, _disputeID, int(totalToRedistribute));
343: 343:                 } else { 
344: 344:                     uint toRedistribute = totalToRedistribute / nbCoherent; 
345: 345:                     
346: 346:                     for (j = 0; j < dispute.votes[i].length; ++j) {
347: 347:                         vote = dispute.votes[i][j];
348: 348:                         if (vote.ruling == winningChoice) {
349: 349:                             juror = jurors[vote.account];
350: 350:                             juror.balance += toRedistribute;
351: 351:                             TokenShift(vote.account, _disputeID, int(toRedistribute));
352: 352:                         }
353: 353:                     }
354: 354:                 }
355: 355:             }
356: 356:             
357: 357:             for (j = 0; j < dispute.votes[i].length; ++j) {
358: 358:                 vote = dispute.votes[i][j];
359: 359:                 juror = jurors[vote.account];
360: 360:                 juror.atStake -= amountShift; 
361: 361:             }
362: 362:         }
363: 363:         dispute.state = DisputeState.Executable; 
364: 364:     }
365: 365: 
366: 366:     
367: 367: 
368: 368: 
369: 369: 
370: 370: 
371: 371: 
372: 372:     function multipleShotTokenRepartition(uint _disputeID, uint _maxIterations) public onlyDuring(Period.Execution) {
373: 373:         Dispute storage dispute = disputes[_disputeID];
374: 374:         require(dispute.state <= DisputeState.Resolving);
375: 375:         require(dispute.session+dispute.appeals <= session);
376: 376:         dispute.state = DisputeState.Resolving; 
377: 377: 
378: 378:         uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
379: 379:         uint amountShift = getStakePerDraw();
380: 380:         uint currentIterations = 0; 
381: 381:         for (uint i = dispute.currentAppealToRepartition; i <= dispute.appeals; ++i) {
382: 382:             
383: 383:             if (dispute.appealsRepartitioned.length < i+1) {
384: 384:                 dispute.appealsRepartitioned.length++;
385: 385:             }
386: 386: 
387: 387:             
388: 388:             if (winningChoice==0 && (dispute.voteCounter[dispute.appeals].voteCount[0] != dispute.voteCounter[dispute.appeals].winningCount)) {
389: 389:                 
390: 390:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
391: 391:             }
392: 392: 
393: 393:             
394: 394:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Incoherent) {
395: 395:                 for (uint j = dispute.appealsRepartitioned[i].currentIncoherentVote; j < dispute.votes[i].length; ++j) {
396: 396:                     if (currentIterations >= _maxIterations) {
397: 397:                         return;
398: 398:                     }
399: 399:                     Vote storage vote = dispute.votes[i][j];
400: 400:                     if (vote.ruling != winningChoice) {
401: 401:                         Juror storage juror = jurors[vote.account];
402: 402:                         uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
403: 403:                         juror.balance -= penalty;
404: 404:                         TokenShift(vote.account, _disputeID, int(-penalty));
405: 405:                         dispute.appealsRepartitioned[i].totalToRedistribute += penalty;
406: 406:                     } else {
407: 407:                         ++dispute.appealsRepartitioned[i].nbCoherent;
408: 408:                     }
409: 409: 
410: 410:                     ++dispute.appealsRepartitioned[i].currentIncoherentVote;
411: 411:                     ++currentIterations;
412: 412:                 }
413: 413: 
414: 414:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.Coherent;
415: 415:             }
416: 416: 
417: 417:             
418: 418:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Coherent) {
419: 419:                 if (dispute.appealsRepartitioned[i].nbCoherent == 0) { 
420: 420:                     jurors[governor].balance += dispute.appealsRepartitioned[i].totalToRedistribute;
421: 421:                     TokenShift(governor, _disputeID, int(dispute.appealsRepartitioned[i].totalToRedistribute));
422: 422:                     dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
423: 423:                 } else { 
424: 424:                     uint toRedistribute = dispute.appealsRepartitioned[i].totalToRedistribute / dispute.appealsRepartitioned[i].nbCoherent; 
425: 425:                     
426: 426:                     for (j = dispute.appealsRepartitioned[i].currentCoherentVote; j < dispute.votes[i].length; ++j) {
427: 427:                         if (currentIterations >= _maxIterations) {
428: 428:                             return;
429: 429:                         }
430: 430:                         vote = dispute.votes[i][j];
431: 431:                         if (vote.ruling == winningChoice) {
432: 432:                             juror = jurors[vote.account];
433: 433:                             juror.balance += toRedistribute;
434: 434:                             TokenShift(vote.account, _disputeID, int(toRedistribute));
435: 435:                         }
436: 436: 
437: 437:                         ++currentIterations;
438: 438:                         ++dispute.appealsRepartitioned[i].currentCoherentVote;
439: 439:                     }
440: 440: 
441: 441:                     dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
442: 442:                 }
443: 443:             }
444: 444: 
445: 445:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.AtStake) {
446: 446:                 
447: 447:                 for (j = dispute.appealsRepartitioned[i].currentAtStakeVote; j < dispute.votes[i].length; ++j) {
448: 448:                     if (currentIterations >= _maxIterations) {
449: 449:                         return;
450: 450:                     }
451: 451:                     vote = dispute.votes[i][j];
452: 452:                     juror = jurors[vote.account];
453: 453:                     juror.atStake -= amountShift; 
454: 454: 
455: 455:                     ++currentIterations;
456: 456:                     ++dispute.appealsRepartitioned[i].currentAtStakeVote;
457: 457:                 }
458: 458: 
459: 459:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.Complete;
460: 460:             }
461: 461: 
462: 462:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Complete) {
463: 463:                 ++dispute.currentAppealToRepartition;
464: 464:             }
465: 465:         }
466: 466: 
467: 467:         dispute.state = DisputeState.Executable;
468: 468:     }
469: 469: 
470: 470:     
471: 471:     
472: 472:     
473: 473:     
474: 474: 
475: 475:     
476: 476: 
477: 477: 
478: 478: 
479: 479: 
480: 480: 
481: 481:     function amountJurors(uint _disputeID) public view returns (uint nbJurors) {
482: 482:         Dispute storage dispute = disputes[_disputeID];
483: 483:         return (dispute.initialNumberJurors + 1) * 2**dispute.appeals - 1;
484: 484:     }
485: 485: 
486: 486:     
487: 487: 
488: 488: 
489: 489: 
490: 490: 
491: 491: 
492: 492: 
493: 493: 
494: 494: 
495: 495:     function validDraws(address _jurorAddress, uint _disputeID, uint[] _draws) public view returns (bool valid) {
496: 496:         uint draw = 0;
497: 497:         Juror storage juror = jurors[_jurorAddress];
498: 498:         Dispute storage dispute = disputes[_disputeID];
499: 499:         uint nbJurors = amountJurors(_disputeID);
500: 500: 
501: 501:         if (juror.lastSession != session) return false; 
502: 502:         if (dispute.session+dispute.appeals != session) return false; 
503: 503:         if (period <= Period.Draw) return false; 
504: 504:         for (uint i = 0; i < _draws.length; ++i) {
505: 505:             if (_draws[i] <= draw) return false; 
506: 506:             draw = _draws[i];
507: 507:             if (draw > nbJurors) return false;
508: 508:             uint position = uint(keccak256(randomNumber, _disputeID, draw)) % segmentSize; 
509: 509:             require(position >= juror.segmentStart);
510: 510:             require(position < juror.segmentEnd);
511: 511:         }
512: 512: 
513: 513:         return true;
514: 514:     }
515: 515: 
516: 516:     
517: 517:     
518: 518:     
519: 519:     
520: 520: 
521: 521:     
522: 522: 
523: 523: 
524: 524: 
525: 525: 
526: 526: 
527: 527:     function createDispute(uint _choices, bytes _extraData) public payable returns (uint disputeID) {
528: 528:         uint16 nbJurors = extraDataToNbJurors(_extraData);
529: 529:         require(msg.value >= arbitrationCost(_extraData));
530: 530: 
531: 531:         disputeID = disputes.length++;
532: 532:         Dispute storage dispute = disputes[disputeID];
533: 533:         dispute.arbitrated = Arbitrable(msg.sender);
534: 534:         if (period < Period.Draw) 
535: 535:             dispute.session = session;
536: 536:         else 
537: 537:             dispute.session = session+1;
538: 538:         dispute.choices = _choices;
539: 539:         dispute.initialNumberJurors = nbJurors;
540: 540:         dispute.arbitrationFeePerJuror = arbitrationFeePerJuror; 
541: 541:         dispute.votes.length++;
542: 542:         dispute.voteCounter.length++;
543: 543: 
544: 544:         DisputeCreation(disputeID, Arbitrable(msg.sender));
545: 545:         return disputeID;
546: 546:     }
547: 547: 
548: 548:     
549: 549: 
550: 550: 
551: 551: 
552: 552:     function appeal(uint _disputeID, bytes _extraData) public payable onlyDuring(Period.Appeal) {
553: 553:         super.appeal(_disputeID,_extraData);
554: 554:         Dispute storage dispute = disputes[_disputeID];
555: 555:         require(msg.value >= appealCost(_disputeID, _extraData));
556: 556:         require(dispute.session+dispute.appeals == session); 
557: 557:         require(dispute.arbitrated == msg.sender);
558: 558:         
559: 559:         dispute.appeals++;
560: 560:         dispute.votes.length++;
561: 561:         dispute.voteCounter.length++;
562: 562:     }
563: 563: 
564: 564:     
565: 565: 
566: 566: 
567: 567:     function executeRuling(uint disputeID) public {
568: 568:         Dispute storage dispute = disputes[disputeID];
569: 569:         require(dispute.state == DisputeState.Executable);
570: 570: 
571: 571:         dispute.state = DisputeState.Executed;
572: 572:         dispute.arbitrated.rule(disputeID, dispute.voteCounter[dispute.appeals].winningChoice);
573: 573:     }
574: 574: 
575: 575:     
576: 576:     
577: 577:     
578: 578:     
579: 579: 
580: 580:     
581: 581: 
582: 582: 
583: 583: 
584: 584: 
585: 585:     function arbitrationCost(bytes _extraData) public view returns (uint fee) {
586: 586:         return extraDataToNbJurors(_extraData) * arbitrationFeePerJuror;
587: 587:     }
588: 588: 
589: 589:     
590: 590: 
591: 591: 
592: 592: 
593: 593: 
594: 594: 
595: 595:     function appealCost(uint _disputeID, bytes _extraData) public view returns (uint fee) {
596: 596:         Dispute storage dispute = disputes[_disputeID];
597: 597: 
598: 598:         if(dispute.appeals >= maxAppeals) return NON_PAYABLE_AMOUNT;
599: 599: 
600: 600:         return (2*amountJurors(_disputeID) + 1) * dispute.arbitrationFeePerJuror;
601: 601:     }
602: 602: 
603: 603:     
604: 604: 
605: 605: 
606: 606: 
607: 607:     function extraDataToNbJurors(bytes _extraData) internal view returns (uint16 nbJurors) {
608: 608:         if (_extraData.length < 2)
609: 609:             return defaultNumberJuror;
610: 610:         else
611: 611:             return (uint16(_extraData[0]) << 8) + uint16(_extraData[1]);
612: 612:     }
613: 613: 
614: 614:     
615: 615: 
616: 616: 
617: 617:     function getStakePerDraw() public view returns (uint minActivatedTokenInAlpha) {
618: 618:         return (alpha * minActivatedToken) / ALPHA_DIVISOR;
619: 619:     }
620: 620: 
621: 621: 
622: 622:     
623: 623:     
624: 624:     
625: 625: 
626: 626:     
627: 627: 
628: 628: 
629: 629: 
630: 630: 
631: 631: 
632: 632:     function getVoteAccount(uint _disputeID, uint _appeals, uint _voteID) public view returns (address account) {
633: 633:         return disputes[_disputeID].votes[_appeals][_voteID].account;
634: 634:     }
635: 635: 
636: 636:     
637: 637: 
638: 638: 
639: 639: 
640: 640: 
641: 641: 
642: 642:     function getVoteRuling(uint _disputeID, uint _appeals, uint _voteID) public view returns (uint ruling) {
643: 643:         return disputes[_disputeID].votes[_appeals][_voteID].ruling;
644: 644:     }
645: 645: 
646: 646:     
647: 647: 
648: 648: 
649: 649: 
650: 650: 
651: 651:     function getWinningChoice(uint _disputeID, uint _appeals) public view returns (uint winningChoice) {
652: 652:         return disputes[_disputeID].voteCounter[_appeals].winningChoice;
653: 653:     }
654: 654: 
655: 655:     
656: 656: 
657: 657: 
658: 658: 
659: 659: 
660: 660:     function getWinningCount(uint _disputeID, uint _appeals) public view returns (uint winningCount) {
661: 661:         return disputes[_disputeID].voteCounter[_appeals].winningCount;
662: 662:     }
663: 663: 
664: 664:     
665: 665: 
666: 666: 
667: 667: 
668: 668: 
669: 669: 
670: 670:     function getVoteCount(uint _disputeID, uint _appeals, uint _choice) public view returns (uint voteCount) {
671: 671:         return disputes[_disputeID].voteCounter[_appeals].voteCount[_choice];
672: 672:     }
673: 673: 
674: 674:     
675: 675: 
676: 676: 
677: 677: 
678: 678: 
679: 679:     function getLastSessionVote(uint _disputeID, address _juror) public view returns (uint lastSessionVote) {
680: 680:         return disputes[_disputeID].lastSessionVote[_juror];
681: 681:     }
682: 682: 
683: 683:     
684: 684: 
685: 685: 
686: 686: 
687: 687: 
688: 688: 
689: 689:     function isDrawn(uint _disputeID, address _juror, uint _draw) public view returns (bool drawn) {
690: 690:         Dispute storage dispute = disputes[_disputeID];
691: 691:         Juror storage juror = jurors[_juror];
692: 692:         if (juror.lastSession != session
693: 693:         || (dispute.session+dispute.appeals != session)
694: 694:         || period<=Period.Draw
695: 695:         || _draw>amountJurors(_disputeID)
696: 696:         || _draw==0
697: 697:         || segmentSize==0
698: 698:         ) {
699: 699:             return false;
700: 700:         } else {
701: 701:             uint position = uint(keccak256(randomNumber,_disputeID,_draw)) % segmentSize;
702: 702:             return (position >= juror.segmentStart) && (position < juror.segmentEnd);
703: 703:         }
704: 704: 
705: 705:     }
706: 706: 
707: 707:     
708: 708: 
709: 709: 
710: 710: 
711: 711:     function currentRuling(uint _disputeID) public view returns (uint ruling) {
712: 712:         Dispute storage dispute = disputes[_disputeID];
713: 713:         return dispute.voteCounter[dispute.appeals].winningChoice;
714: 714:     }
715: 715: 
716: 716:     
717: 717: 
718: 718: 
719: 719: 
720: 720:     function disputeStatus(uint _disputeID) public view returns (DisputeStatus status) {
721: 721:         Dispute storage dispute = disputes[_disputeID];
722: 722:         if (dispute.session+dispute.appeals < session) 
723: 723:             return DisputeStatus.Solved;
724: 724:         else if(dispute.session+dispute.appeals == session) { 
725: 725:             if (dispute.state == DisputeState.Open) {
726: 726:                 if (period < Period.Appeal)
727: 727:                     return DisputeStatus.Waiting;
728: 728:                 else if (period == Period.Appeal)
729: 729:                     return DisputeStatus.Appealable;
730: 730:                 else return DisputeStatus.Solved;
731: 731:             } else return DisputeStatus.Solved;
732: 732:         } else return DisputeStatus.Waiting; 
733: 733:     }
734: 734: 
735: 735:     
736: 736:     
737: 737:     
738: 738: 
739: 739:     
740: 740: 
741: 741: 
742: 742: 
743: 743: 
744: 744:     function executeOrder(bytes32 _data, uint _value, address _target) public onlyGovernor {
745: 745:         _target.call.value(_value)(_data);
746: 746:     }
747: 747: 
748: 748:     
749: 749: 
750: 750: 
751: 751:     function setRng(RNG _rng) public onlyGovernor {
752: 752:         rng = _rng;
753: 753:     }
754: 754: 
755: 755:     
756: 756: 
757: 757: 
758: 758:     function setArbitrationFeePerJuror(uint _arbitrationFeePerJuror) public onlyGovernor {
759: 759:         arbitrationFeePerJuror = _arbitrationFeePerJuror;
760: 760:     }
761: 761: 
762: 762:     
763: 763: 
764: 764: 
765: 765:     function setDefaultNumberJuror(uint16 _defaultNumberJuror) public onlyGovernor {
766: 766:         defaultNumberJuror = _defaultNumberJuror;
767: 767:     }
768: 768: 
769: 769:     
770: 770: 
771: 771: 
772: 772:     function setMinActivatedToken(uint _minActivatedToken) public onlyGovernor {
773: 773:         minActivatedToken = _minActivatedToken;
774: 774:     }
775: 775: 
776: 776:     
777: 777: 
778: 778: 
779: 779:     function setTimePerPeriod(uint[5] _timePerPeriod) public onlyGovernor {
780: 780:         timePerPeriod = _timePerPeriod;
781: 781:     }
782: 782: 
783: 783:     
784: 784: 
785: 785: 
786: 786:     function setAlpha(uint _alpha) public onlyGovernor {
787: 787:         alpha = _alpha;
788: 788:     }
789: 789: 
790: 790:     
791: 791: 
792: 792: 
793: 793:     function setMaxAppeals(uint _maxAppeals) public onlyGovernor {
794: 794:         maxAppeals = _maxAppeals;
795: 795:     }
796: 796: 
797: 797:     
798: 798: 
799: 799: 
800: 800:     function setGovernor(address _governor) public onlyGovernor {
801: 801:         governor = _governor;
802: 802:     }
803: 803: }