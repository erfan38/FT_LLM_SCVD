1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: contract Kleros is Arbitrator, ApproveAndCallFallBack {
11: 11: 
12: 12:     
13: 13:     
14: 14:     
15: 15: 
16: 16:     
17: 17:     Pinakion public pinakion;
18: 18:     uint public constant NON_PAYABLE_AMOUNT = (2**256 - 2) / 2; 
19: 19: 
20: 20:     
21: 21:     
22: 22:     RNG public rng; 
23: 23:     uint public arbitrationFeePerJuror = 0.05 ether; 
24: 24:     uint16 public defaultNumberJuror = 3; 
25: 25:     uint public minActivatedToken = 0.1 * 1e18; 
26: 26:     uint[5] public timePerPeriod; 
27: 27:     uint public alpha = 2000; 
28: 28:     uint constant ALPHA_DIVISOR = 1e4; 
29: 29:     uint public maxAppeals = 5; 
30: 30:     
31: 31:     
32: 32:     address public governor; 
33: 33: 
34: 34:     
35: 35:     uint public session = 1;      
36: 36:     uint public lastPeriodChange; 
37: 37:     uint public segmentSize;      
38: 38:     uint public rnBlock;          
39: 39:     uint public randomNumber;     
40: 40: 
41: 41:     enum Period {
42: 42:         Activation, 
43: 43:         Draw,       
44: 44:         Vote,       
45: 45:         Appeal,     
46: 46:         Execution   
47: 47:     }
48: 48: 
49: 49:     Period public period;
50: 50: 
51: 51:     struct Juror {
52: 52:         uint balance;      
53: 53:         uint atStake;      
54: 54:         uint lastSession;  
55: 55:         uint segmentStart; 
56: 56:         uint segmentEnd;   
57: 57:     }
58: 58: 
59: 59:     mapping (address => Juror) public jurors;
60: 60: 
61: 61:     struct Vote {
62: 62:         address account; 
63: 63:         uint ruling;     
64: 64:     }
65: 65: 
66: 66:     struct VoteCounter {
67: 67:         uint winningChoice; 
68: 68:         uint winningCount;  
69: 69:         mapping (uint => uint) voteCount; 
70: 70:     }
71: 71: 
72: 72:     enum DisputeState {
73: 73:         Open,       
74: 74:         Resolving,  
75: 75:         Executable, 
76: 76:         Executed    
77: 77:     }
78: 78: 
79: 79:     struct Dispute {
80: 80:         Arbitrable arbitrated;       
81: 81:         uint session;                
82: 82:         uint appeals;                
83: 83:         uint choices;                
84: 84:         uint16 initialNumberJurors;  
85: 85:         uint arbitrationFeePerJuror; 
86: 86:         DisputeState state;          
87: 87:         Vote[][] votes;              
88: 88:         VoteCounter[] voteCounter;   
89: 89:         mapping (address => uint) lastSessionVote; 
90: 90:         uint currentAppealToRepartition; 
91: 91:         AppealsRepartitioned[] appealsRepartitioned; 
92: 92:     }
93: 93: 
94: 94:     enum RepartitionStage { 
95: 95:         Incoherent,
96: 96:         Coherent,
97: 97:         AtStake,
98: 98:         Complete
99: 99:     }
100: 100: 
101: 101:     struct AppealsRepartitioned {
102: 102:         uint totalToRedistribute;   
103: 103:         uint nbCoherent;            
104: 104:         uint currentIncoherentVote; 
105: 105:         uint currentCoherentVote;   
106: 106:         uint currentAtStakeVote;    
107: 107:         RepartitionStage stage;     
108: 108:     }
109: 109: 
110: 110:     Dispute[] public disputes;
111: 111: 
112: 112:     
113: 113:     
114: 114:     
115: 115: 
116: 116:     
117: 117: 
118: 118: 
119: 119: 
120: 120:     event NewPeriod(Period _period, uint indexed _session);
121: 121: 
122: 122:     
123: 123: 
124: 124: 
125: 125: 
126: 126: 
127: 127:     event TokenShift(address indexed _account, uint _disputeID, int _amount);
128: 128: 
129: 129:     
130: 130: 
131: 131: 
132: 132: 
133: 133: 
134: 134:     event ArbitrationReward(address indexed _account, uint _disputeID, uint _amount);
135: 135: 
136: 136:     
137: 137:     
138: 138:     
139: 139:     modifier onlyBy(address _account) {require(msg.sender == _account); _;}
140: 140:     modifier onlyDuring(Period _period) {require(period == _period); _;}
141: 141:     modifier onlyGovernor() {require(msg.sender == governor); _;}
142: 142: 
143: 143: 
144: 144:     
145: 145: 
146: 146: 
147: 147: 
148: 148: 
149: 149: 
150: 150:     constructor(Pinakion _pinakion, RNG _rng, uint[5] _timePerPeriod, address _governor) public {
151: 151:         pinakion = _pinakion;
152: 152:         rng = _rng;
153: 153:         lastPeriodChange = now;
154: 154:         timePerPeriod = _timePerPeriod;
155: 155:         governor = _governor;
156: 156:     }
157: 157: 
158: 158:     
159: 159:     
160: 160:     
161: 161:     
162: 162: 
163: 163:     
164: 164: 
165: 165: 
166: 166: 
167: 167:     function receiveApproval(address _from, uint _amount, address, bytes) public onlyBy(pinakion) {
168: 168:         require(pinakion.transferFrom(_from, this, _amount));
169: 169: 
170: 170:         jurors[_from].balance += _amount;
171: 171:     }
172: 172: 
173: 173:     
174: 174: 
175: 175: 
176: 176: 
177: 177: 
178: 178:     function withdraw(uint _value) public {
179: 179:         Juror storage juror = jurors[msg.sender];
180: 180:         require(juror.atStake <= juror.balance); 
181: 181:         require(_value <= juror.balance-juror.atStake);
182: 182:         require(juror.lastSession != session);
183: 183: 
184: 184:         juror.balance -= _value;
185: 185:         require(pinakion.transfer(msg.sender,_value));
186: 186:     }
187: 187: 
188: 188:     
189: 189:     
190: 190:     
191: 191:     
192: 192: 
193: 193:     
194: 194: 
195: 195:     function passPeriod() public {
196: 196:         require(now-lastPeriodChange >= timePerPeriod[uint8(period)]);
197: 197: 
198: 198:         if (period == Period.Activation) {
199: 199:             rnBlock = block.number + 1;
200: 200:             rng.requestRN(rnBlock);
201: 201:             period = Period.Draw;
202: 202:         } else if (period == Period.Draw) {
203: 203:             randomNumber = rng.getUncorrelatedRN(rnBlock);
204: 204:             require(randomNumber != 0);
205: 205:             period = Period.Vote;
206: 206:         } else if (period == Period.Vote) {
207: 207:             period = Period.Appeal;
208: 208:         } else if (period == Period.Appeal) {
209: 209:             period = Period.Execution;
210: 210:         } else if (period == Period.Execution) {
211: 211:             period = Period.Activation;
212: 212:             ++session;
213: 213:             segmentSize = 0;
214: 214:             rnBlock = 0;
215: 215:             randomNumber = 0;
216: 216:         }
217: 217: 
218: 218: 
219: 219:         lastPeriodChange = now;
220: 220:         NewPeriod(period, session);
221: 221:     }
222: 222: 
223: 223: 
224: 224:     
225: 225: 
226: 226: 
227: 227: 
228: 228:     function activateTokens(uint _value) public onlyDuring(Period.Activation) {
229: 229:         Juror storage juror = jurors[msg.sender];
230: 230:         require(_value <= juror.balance);
231: 231:         require(_value >= minActivatedToken);
232: 232:         require(juror.lastSession != session); 
233: 233: 
234: 234:         juror.lastSession = session;
235: 235:         juror.segmentStart = segmentSize;
236: 236:         segmentSize += _value;
237: 237:         juror.segmentEnd = segmentSize;
238: 238: 
239: 239:     }
240: 240: 
241: 241:     
242: 242: 
243: 243: 
244: 244: 
245: 245: 
246: 246: 
247: 247: 
248: 248: 
249: 249:     function voteRuling(uint _disputeID, uint _ruling, uint[] _draws) public onlyDuring(Period.Vote) {
250: 250:         Dispute storage dispute = disputes[_disputeID];
251: 251:         Juror storage juror = jurors[msg.sender];
252: 252:         VoteCounter storage voteCounter = dispute.voteCounter[dispute.appeals];
253: 253:         require(dispute.lastSessionVote[msg.sender] != session); 
254: 254:         require(_ruling <= dispute.choices);
255: 255:         
256: 256:         require(validDraws(msg.sender, _disputeID, _draws));
257: 257: 
258: 258:         dispute.lastSessionVote[msg.sender] = session;
259: 259:         voteCounter.voteCount[_ruling] += _draws.length;
260: 260:         if (voteCounter.winningCount < voteCounter.voteCount[_ruling]) {
261: 261:             voteCounter.winningCount = voteCounter.voteCount[_ruling];
262: 262:             voteCounter.winningChoice = _ruling;
263: 263:         } else if (voteCounter.winningCount==voteCounter.voteCount[_ruling] && _draws.length!=0) { 
264: 264:             voteCounter.winningChoice = 0; 
265: 265:         }
266: 266:         for (uint i = 0; i < _draws.length; ++i) {
267: 267:             dispute.votes[dispute.appeals].push(Vote({
268: 268:                 account: msg.sender,
269: 269:                 ruling: _ruling
270: 270:             }));
271: 271:         }
272: 272: 
273: 273:         juror.atStake += _draws.length * getStakePerDraw();
274: 274:         uint feeToPay = _draws.length * dispute.arbitrationFeePerJuror;
275: 275:         msg.sender.transfer(feeToPay);
276: 276:         ArbitrationReward(msg.sender, _disputeID, feeToPay);
277: 277:     }
278: 278: 
279: 279:     
280: 280: 
281: 281: 
282: 282: 
283: 283: 
284: 284: 
285: 285: 
286: 286: 
287: 287:     function penalizeInactiveJuror(address _jurorAddress, uint _disputeID, uint[] _draws) public {
288: 288:         Dispute storage dispute = disputes[_disputeID];
289: 289:         Juror storage inactiveJuror = jurors[_jurorAddress];
290: 290:         require(period > Period.Vote);
291: 291:         require(dispute.lastSessionVote[_jurorAddress] != session); 
292: 292:         dispute.lastSessionVote[_jurorAddress] = session; 
293: 293:         require(validDraws(_jurorAddress, _disputeID, _draws));
294: 294:         uint penality = _draws.length * minActivatedToken * 2 * alpha / ALPHA_DIVISOR;
295: 295:         penality = (penality < inactiveJuror.balance) ? penality : inactiveJuror.balance; 
296: 296:         inactiveJuror.balance -= penality;
297: 297:         TokenShift(_jurorAddress, _disputeID, -int(penality));
298: 298:         jurors[msg.sender].balance += penality / 2; 
299: 299:         TokenShift(msg.sender, _disputeID, int(penality / 2));
300: 300:         jurors[governor].balance += penality / 2; 
301: 301:         TokenShift(governor, _disputeID, int(penality / 2));
302: 302:         msg.sender.transfer(_draws.length*dispute.arbitrationFeePerJuror); 
303: 303:     }
304: 304: 
305: 305:     
306: 306: 
307: 307: 
308: 308: 
309: 309: 
310: 310: 
311: 311: 
312: 312:     function oneShotTokenRepartition(uint _disputeID) public onlyDuring(Period.Execution) {
313: 313:         Dispute storage dispute = disputes[_disputeID];
314: 314:         require(dispute.state == DisputeState.Open);
315: 315:         require(dispute.session+dispute.appeals <= session);
316: 316: 
317: 317:         uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
318: 318:         uint amountShift = getStakePerDraw();
319: 319:         for (uint i = 0; i <= dispute.appeals; ++i) {
320: 320:             
321: 321:             
322: 322:             
323: 323:             if (winningChoice!=0 || (dispute.voteCounter[dispute.appeals].voteCount[0] == dispute.voteCounter[dispute.appeals].winningCount)) {
324: 324:                 uint totalToRedistribute = 0;
325: 325:                 uint nbCoherent = 0;
326: 326:                 
327: 327:                 for (uint j = 0; j < dispute.votes[i].length; ++j) {
328: 328:                     Vote storage vote = dispute.votes[i][j];
329: 329:                     if (vote.ruling != winningChoice) {
330: 330:                         Juror storage juror = jurors[vote.account];
331: 331:                         uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
332: 332:                         juror.balance -= penalty;
333: 333:                         TokenShift(vote.account, _disputeID, int(-penalty));
334: 334:                         totalToRedistribute += penalty;
335: 335:                     } else {
336: 336:                         ++nbCoherent;
337: 337:                     }
338: 338:                 }
339: 339:                 if (nbCoherent == 0) { 
340: 340:                     jurors[governor].balance += totalToRedistribute;
341: 341:                     TokenShift(governor, _disputeID, int(totalToRedistribute));
342: 342:                 } else { 
343: 343:                     uint toRedistribute = totalToRedistribute / nbCoherent; 
344: 344:                     
345: 345:                     for (j = 0; j < dispute.votes[i].length; ++j) {
346: 346:                         vote = dispute.votes[i][j];
347: 347:                         if (vote.ruling == winningChoice) {
348: 348:                             juror = jurors[vote.account];
349: 349:                             juror.balance += toRedistribute;
350: 350:                             TokenShift(vote.account, _disputeID, int(toRedistribute));
351: 351:                         }
352: 352:                     }
353: 353:                 }
354: 354:             }
355: 355:             
356: 356:             for (j = 0; j < dispute.votes[i].length; ++j) {
357: 357:                 vote = dispute.votes[i][j];
358: 358:                 juror = jurors[vote.account];
359: 359:                 juror.atStake -= amountShift; 
360: 360:             }
361: 361:         }
362: 362:         dispute.state = DisputeState.Executable; 
363: 363:     }
364: 364: 
365: 365:     
366: 366: 
367: 367: 
368: 368: 
369: 369: 
370: 370: 
371: 371:     function multipleShotTokenRepartition(uint _disputeID, uint _maxIterations) public onlyDuring(Period.Execution) {
372: 372:         Dispute storage dispute = disputes[_disputeID];
373: 373:         require(dispute.state <= DisputeState.Resolving);
374: 374:         require(dispute.session+dispute.appeals <= session);
375: 375:         dispute.state = DisputeState.Resolving; 
376: 376: 
377: 377:         uint winningChoice = dispute.voteCounter[dispute.appeals].winningChoice;
378: 378:         uint amountShift = getStakePerDraw();
379: 379:         uint currentIterations = 0; 
380: 380:         for (uint i = dispute.currentAppealToRepartition; i <= dispute.appeals; ++i) {
381: 381:             
382: 382:             if (dispute.appealsRepartitioned.length < i+1) {
383: 383:                 dispute.appealsRepartitioned.length++;
384: 384:             }
385: 385: 
386: 386:             
387: 387:             if (winningChoice==0 && (dispute.voteCounter[dispute.appeals].voteCount[0] != dispute.voteCounter[dispute.appeals].winningCount)) {
388: 388:                 
389: 389:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
390: 390:             }
391: 391: 
392: 392:             
393: 393:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Incoherent) {
394: 394:                 for (uint j = dispute.appealsRepartitioned[i].currentIncoherentVote; j < dispute.votes[i].length; ++j) {
395: 395:                     if (currentIterations >= _maxIterations) {
396: 396:                         return;
397: 397:                     }
398: 398:                     Vote storage vote = dispute.votes[i][j];
399: 399:                     if (vote.ruling != winningChoice) {
400: 400:                         Juror storage juror = jurors[vote.account];
401: 401:                         uint penalty = amountShift<juror.balance ? amountShift : juror.balance;
402: 402:                         juror.balance -= penalty;
403: 403:                         TokenShift(vote.account, _disputeID, int(-penalty));
404: 404:                         dispute.appealsRepartitioned[i].totalToRedistribute += penalty;
405: 405:                     } else {
406: 406:                         ++dispute.appealsRepartitioned[i].nbCoherent;
407: 407:                     }
408: 408: 
409: 409:                     ++dispute.appealsRepartitioned[i].currentIncoherentVote;
410: 410:                     ++currentIterations;
411: 411:                 }
412: 412: 
413: 413:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.Coherent;
414: 414:             }
415: 415: 
416: 416:             
417: 417:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Coherent) {
418: 418:                 if (dispute.appealsRepartitioned[i].nbCoherent == 0) { 
419: 419:                     jurors[governor].balance += dispute.appealsRepartitioned[i].totalToRedistribute;
420: 420:                     TokenShift(governor, _disputeID, int(dispute.appealsRepartitioned[i].totalToRedistribute));
421: 421:                     dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
422: 422:                 } else { 
423: 423:                     uint toRedistribute = dispute.appealsRepartitioned[i].totalToRedistribute / dispute.appealsRepartitioned[i].nbCoherent; 
424: 424:                     
425: 425:                     for (j = dispute.appealsRepartitioned[i].currentCoherentVote; j < dispute.votes[i].length; ++j) {
426: 426:                         if (currentIterations >= _maxIterations) {
427: 427:                             return;
428: 428:                         }
429: 429:                         vote = dispute.votes[i][j];
430: 430:                         if (vote.ruling == winningChoice) {
431: 431:                             juror = jurors[vote.account];
432: 432:                             juror.balance += toRedistribute;
433: 433:                             TokenShift(vote.account, _disputeID, int(toRedistribute));
434: 434:                         }
435: 435: 
436: 436:                         ++currentIterations;
437: 437:                         ++dispute.appealsRepartitioned[i].currentCoherentVote;
438: 438:                     }
439: 439: 
440: 440:                     dispute.appealsRepartitioned[i].stage = RepartitionStage.AtStake;
441: 441:                 }
442: 442:             }
443: 443: 
444: 444:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.AtStake) {
445: 445:                 
446: 446:                 for (j = dispute.appealsRepartitioned[i].currentAtStakeVote; j < dispute.votes[i].length; ++j) {
447: 447:                     if (currentIterations >= _maxIterations) {
448: 448:                         return;
449: 449:                     }
450: 450:                     vote = dispute.votes[i][j];
451: 451:                     juror = jurors[vote.account];
452: 452:                     juror.atStake -= amountShift; 
453: 453: 
454: 454:                     ++currentIterations;
455: 455:                     ++dispute.appealsRepartitioned[i].currentAtStakeVote;
456: 456:                 }
457: 457: 
458: 458:                 dispute.appealsRepartitioned[i].stage = RepartitionStage.Complete;
459: 459:             }
460: 460: 
461: 461:             if (dispute.appealsRepartitioned[i].stage == RepartitionStage.Complete) {
462: 462:                 ++dispute.currentAppealToRepartition;
463: 463:             }
464: 464:         }
465: 465: 
466: 466:         dispute.state = DisputeState.Executable;
467: 467:     }
468: 468: 
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
480: 480:     function amountJurors(uint _disputeID) public view returns (uint nbJurors) {
481: 481:         Dispute storage dispute = disputes[_disputeID];
482: 482:         return (dispute.initialNumberJurors + 1) * 2**dispute.appeals - 1;
483: 483:     }
484: 484: 
485: 485:     
486: 486: 
487: 487: 
488: 488: 
489: 489: 
490: 490: 
491: 491: 
492: 492: 
493: 493: 
494: 494:     function validDraws(address _jurorAddress, uint _disputeID, uint[] _draws) public view returns (bool valid) {
495: 495:         uint draw = 0;
496: 496:         Juror storage juror = jurors[_jurorAddress];
497: 497:         Dispute storage dispute = disputes[_disputeID];
498: 498:         uint nbJurors = amountJurors(_disputeID);
499: 499: 
500: 500:         if (juror.lastSession != session) return false; 
501: 501:         if (dispute.session+dispute.appeals != session) return false; 
502: 502:         if (period <= Period.Draw) return false; 
503: 503:         for (uint i = 0; i < _draws.length; ++i) {
504: 504:             if (_draws[i] <= draw) return false; 
505: 505:             draw = _draws[i];
506: 506:             if (draw > nbJurors) return false;
507: 507:             uint position = uint(keccak256(randomNumber, _disputeID, draw)) % segmentSize; 
508: 508:             require(position >= juror.segmentStart);
509: 509:             require(position < juror.segmentEnd);
510: 510:         }
511: 511: 
512: 512:         return true;
513: 513:     }
514: 514: 
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
526: 526:     function createDispute(uint _choices, bytes _extraData) public payable returns (uint disputeID) {
527: 527:         uint16 nbJurors = extraDataToNbJurors(_extraData);
528: 528:         require(msg.value >= arbitrationCost(_extraData));
529: 529: 
530: 530:         disputeID = disputes.length++;
531: 531:         Dispute storage dispute = disputes[disputeID];
532: 532:         dispute.arbitrated = Arbitrable(msg.sender);
533: 533:         if (period < Period.Draw) 
534: 534:             dispute.session = session;
535: 535:         else 
536: 536:             dispute.session = session+1;
537: 537:         dispute.choices = _choices;
538: 538:         dispute.initialNumberJurors = nbJurors;
539: 539:         dispute.arbitrationFeePerJuror = arbitrationFeePerJuror; 
540: 540:         dispute.votes.length++;
541: 541:         dispute.voteCounter.length++;
542: 542: 
543: 543:         DisputeCreation(disputeID, Arbitrable(msg.sender));
544: 544:         return disputeID;
545: 545:     }
546: 546: 
547: 547:     
548: 548: 
549: 549: 
550: 550: 
551: 551:     function appeal(uint _disputeID, bytes _extraData) public payable onlyDuring(Period.Appeal) {
552: 552:         super.appeal(_disputeID,_extraData);
553: 553:         Dispute storage dispute = disputes[_disputeID];
554: 554:         require(msg.value >= appealCost(_disputeID, _extraData));
555: 555:         require(dispute.session+dispute.appeals == session); 
556: 556:         require(dispute.arbitrated == msg.sender);
557: 557:         
558: 558:         dispute.appeals++;
559: 559:         dispute.votes.length++;
560: 560:         dispute.voteCounter.length++;
561: 561:     }
562: 562: 
563: 563:     
564: 564: 
565: 565: 
566: 566:     function executeRuling(uint disputeID) public {
567: 567:         Dispute storage dispute = disputes[disputeID];
568: 568:         require(dispute.state == DisputeState.Executable);
569: 569: 
570: 570:         dispute.state = DisputeState.Executed;
571: 571:         dispute.arbitrated.rule(disputeID, dispute.voteCounter[dispute.appeals].winningChoice);
572: 572:     }
573: 573: 
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
584: 584:     function arbitrationCost(bytes _extraData) public view returns (uint fee) {
585: 585:         return extraDataToNbJurors(_extraData) * arbitrationFeePerJuror;
586: 586:     }
587: 587: 
588: 588:     
589: 589: 
590: 590: 
591: 591: 
592: 592: 
593: 593: 
594: 594:     function appealCost(uint _disputeID, bytes _extraData) public view returns (uint fee) {
595: 595:         Dispute storage dispute = disputes[_disputeID];
596: 596: 
597: 597:         if(dispute.appeals >= maxAppeals) return NON_PAYABLE_AMOUNT;
598: 598: 
599: 599:         return (2*amountJurors(_disputeID) + 1) * dispute.arbitrationFeePerJuror;
600: 600:     }
601: 601: 
602: 602:     
603: 603: 
604: 604: 
605: 605: 
606: 606:     function extraDataToNbJurors(bytes _extraData) internal view returns (uint16 nbJurors) {
607: 607:         if (_extraData.length < 2)
608: 608:             return defaultNumberJuror;
609: 609:         else
610: 610:             return (uint16(_extraData[0]) << 8) + uint16(_extraData[1]);
611: 611:     }
612: 612: 
613: 613:     
614: 614: 
615: 615: 
616: 616:     function getStakePerDraw() public view returns (uint minActivatedTokenInAlpha) {
617: 617:         return (alpha * minActivatedToken) / ALPHA_DIVISOR;
618: 618:     }
619: 619: 
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
631: 631:     function getVoteAccount(uint _disputeID, uint _appeals, uint _voteID) public view returns (address account) {
632: 632:         return disputes[_disputeID].votes[_appeals][_voteID].account;
633: 633:     }
634: 634: 
635: 635:     
636: 636: 
637: 637: 
638: 638: 
639: 639: 
640: 640: 
641: 641:     function getVoteRuling(uint _disputeID, uint _appeals, uint _voteID) public view returns (uint ruling) {
642: 642:         return disputes[_disputeID].votes[_appeals][_voteID].ruling;
643: 643:     }
644: 644: 
645: 645:     
646: 646: 
647: 647: 
648: 648: 
649: 649: 
650: 650:     function getWinningChoice(uint _disputeID, uint _appeals) public view returns (uint winningChoice) {
651: 651:         return disputes[_disputeID].voteCounter[_appeals].winningChoice;
652: 652:     }
653: 653: 
654: 654:     
655: 655: 
656: 656: 
657: 657: 
658: 658: 
659: 659:     function getWinningCount(uint _disputeID, uint _appeals) public view returns (uint winningCount) {
660: 660:         return disputes[_disputeID].voteCounter[_appeals].winningCount;
661: 661:     }
662: 662: 
663: 663:     
664: 664: 
665: 665: 
666: 666: 
667: 667: 
668: 668: 
669: 669:     function getVoteCount(uint _disputeID, uint _appeals, uint _choice) public view returns (uint voteCount) {
670: 670:         return disputes[_disputeID].voteCounter[_appeals].voteCount[_choice];
671: 671:     }
672: 672: 
673: 673:     
674: 674: 
675: 675: 
676: 676: 
677: 677: 
678: 678:     function getLastSessionVote(uint _disputeID, address _juror) public view returns (uint lastSessionVote) {
679: 679:         return disputes[_disputeID].lastSessionVote[_juror];
680: 680:     }
681: 681: 
682: 682:     
683: 683: 
684: 684: 
685: 685: 
686: 686: 
687: 687: 
688: 688:     function isDrawn(uint _disputeID, address _juror, uint _draw) public view returns (bool drawn) {
689: 689:         Dispute storage dispute = disputes[_disputeID];
690: 690:         Juror storage juror = jurors[_juror];
691: 691:         if (juror.lastSession != session
692: 692:         || (dispute.session+dispute.appeals != session)
693: 693:         || period<=Period.Draw
694: 694:         || _draw>amountJurors(_disputeID)
695: 695:         || _draw==0
696: 696:         || segmentSize==0
697: 697:         ) {
698: 698:             return false;
699: 699:         } else {
700: 700:             uint position = uint(keccak256(randomNumber,_disputeID,_draw)) % segmentSize;
701: 701:             return (position >= juror.segmentStart) && (position < juror.segmentEnd);
702: 702:         }
703: 703: 
704: 704:     }
705: 705: 
706: 706:     
707: 707: 
708: 708: 
709: 709: 
710: 710:     function currentRuling(uint _disputeID) public view returns (uint ruling) {
711: 711:         Dispute storage dispute = disputes[_disputeID];
712: 712:         return dispute.voteCounter[dispute.appeals].winningChoice;
713: 713:     }
714: 714: 
715: 715:     
716: 716: 
717: 717: 
718: 718: 
719: 719:     function disputeStatus(uint _disputeID) public view returns (DisputeStatus status) {
720: 720:         Dispute storage dispute = disputes[_disputeID];
721: 721:         if (dispute.session+dispute.appeals < session) 
722: 722:             return DisputeStatus.Solved;
723: 723:         else if(dispute.session+dispute.appeals == session) { 
724: 724:             if (dispute.state == DisputeState.Open) {
725: 725:                 if (period < Period.Appeal)
726: 726:                     return DisputeStatus.Waiting;
727: 727:                 else if (period == Period.Appeal)
728: 728:                     return DisputeStatus.Appealable;
729: 729:                 else return DisputeStatus.Solved;
730: 730:             } else return DisputeStatus.Solved;
731: 731:         } else return DisputeStatus.Waiting; 
732: 732:     }
733: 733: 
734: 734:     
735: 735:     
736: 736:     
737: 737: 
738: 738:     
739: 739: 
740: 740: 
741: 741: 
742: 742: 
743: 743:     function executeOrder(bytes32 _data, uint _value, address _target) public onlyGovernor {
744: 744:         _target.call.value(_value)(_data);
745: 745:     }
746: 746: 
747: 747:     
748: 748: 
749: 749: 
750: 750:     function setRng(RNG _rng) public onlyGovernor {
751: 751:         rng = _rng;
752: 752:     }
753: 753: 
754: 754:     
755: 755: 
756: 756: 
757: 757:     function setArbitrationFeePerJuror(uint _arbitrationFeePerJuror) public onlyGovernor {
758: 758:         arbitrationFeePerJuror = _arbitrationFeePerJuror;
759: 759:     }
760: 760: 
761: 761:     
762: 762: 
763: 763: 
764: 764:     function setDefaultNumberJuror(uint16 _defaultNumberJuror) public onlyGovernor {
765: 765:         defaultNumberJuror = _defaultNumberJuror;
766: 766:     }
767: 767: 
768: 768:     
769: 769: 
770: 770: 
771: 771:     function setMinActivatedToken(uint _minActivatedToken) public onlyGovernor {
772: 772:         minActivatedToken = _minActivatedToken;
773: 773:     }
774: 774: 
775: 775:     
776: 776: 
777: 777: 
778: 778:     function setTimePerPeriod(uint[5] _timePerPeriod) public onlyGovernor {
779: 779:         timePerPeriod = _timePerPeriod;
780: 780:     }
781: 781: 
782: 782:     
783: 783: 
784: 784: 
785: 785:     function setAlpha(uint _alpha) public onlyGovernor {
786: 786:         alpha = _alpha;
787: 787:     }
788: 788: 
789: 789:     
790: 790: 
791: 791: 
792: 792:     function setMaxAppeals(uint _maxAppeals) public onlyGovernor {
793: 793:         maxAppeals = _maxAppeals;
794: 794:     }
795: 795: 
796: 796:     
797: 797: 
798: 798: 
799: 799:     function setGovernor(address _governor) public onlyGovernor {
800: 800:         governor = _governor;
801: 801:     }
802: 802: }