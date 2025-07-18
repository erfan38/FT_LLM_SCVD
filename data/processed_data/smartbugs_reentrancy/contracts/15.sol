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
49: 49: pragma solidity ^0.4.6;
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
73: 73: contract FDC is TokenTracker, Phased, StepFunction, Targets, Parameters {
74: 74:   
75: 75:   string public name;
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
88: 88:   enum state {
89: 89:     pause,         
90: 90:     earlyContrib,  
91: 91:     round0,        
92: 92:     round1,        
93: 93:     offChainReg,   
94: 94:     finalization,  
95: 95:                    
96: 96:     done           
97: 97:   }
98: 98: 
99: 99:   
100: 100:   mapping(uint => state) stateOfPhase;
101: 101: 
102: 102:   
103: 103: 
104: 104: 
105: 105: 
106: 106: 
107: 107: 
108: 108: 
109: 109: 
110: 110: 
111: 111: 
112: 112: 
113: 113: 
114: 114: 
115: 115: 
116: 116: 
117: 117: 
118: 118:    
119: 119:   
120: 120:   mapping(bytes32 => bool) memoUsed;
121: 121: 
122: 122:   
123: 123:   address[] public donorList;  
124: 124:   address[] public earlyContribList;  
125: 125:   
126: 126:   
127: 127: 
128: 128: 
129: 129: 
130: 130: 
131: 131: 
132: 132: 
133: 133:    
134: 134:   
135: 135:   uint public weiPerCHF;       
136: 136:   
137: 137:   
138: 138:   uint public totalWeiDonated; 
139: 139:   
140: 140:   
141: 141:   mapping(address => uint) public weiDonated; 
142: 142: 
143: 143:   
144: 144: 
145: 145: 
146: 146: 
147: 147: 
148: 148: 
149: 149:    
150: 150:   
151: 151:   address public foundationWallet; 
152: 152:   
153: 153:   
154: 154:   
155: 155:   address public registrarAuth; 
156: 156:   
157: 157:   
158: 158:   address public exchangeRateAuth; 
159: 159: 
160: 160:   
161: 161:   address public masterAuth; 
162: 162: 
163: 163:   
164: 164: 
165: 165: 
166: 166:  
167: 167:   
168: 168:   
169: 169:   uint phaseOfRound0;
170: 170:   uint phaseOfRound1;
171: 171:   
172: 172:   
173: 173: 
174: 174: 
175: 175: 
176: 176: 
177: 177: 
178: 178: 
179: 179:   event DonationReceipt (address indexed addr,          
180: 180:                          string indexed currency,       
181: 181:                          uint indexed bonusMultiplierApplied, 
182: 182:                          uint timestamp,                
183: 183:                          uint tokenAmount,              
184: 184:                          bytes32 memo);                 
185: 185:   event EarlyContribReceipt (address indexed addr,      
186: 186:                              uint tokenAmount,          
187: 187:                              bytes32 memo);             
188: 188:   event BurnReceipt (address indexed addr,              
189: 189:                      uint tokenAmountBurned);           
190: 190: 
191: 191:   
192: 192: 
193: 193: 
194: 194: 
195: 195: 
196: 196: 
197: 197: 
198: 198: 
199: 199: 
200: 200: 
201: 201: 
202: 202: 
203: 203: 
204: 204:   function FDC(address _masterAuth, string _name)
205: 205:     TokenTracker(earlyContribShare)
206: 206:     StepFunction(round1EndTime-round1StartTime, round1InitialBonus, 
207: 207:                  round1BonusSteps) 
208: 208:   {
209: 209:     
210: 210: 
211: 211: 
212: 212:     name = _name;
213: 213: 
214: 214:     
215: 215: 
216: 216: 
217: 217:     foundationWallet  = _masterAuth;
218: 218:     masterAuth     = _masterAuth;
219: 219:     exchangeRateAuth  = _masterAuth;
220: 220:     registrarAuth  = _masterAuth;
221: 221: 
222: 222:     
223: 223: 
224: 224: 
225: 225: 
226: 226: 
227: 227: 
228: 228: 
229: 229: 
230: 230:     stateOfPhase[0] = state.earlyContrib; 
231: 231:     addPhase(round0StartTime);     
232: 232:     stateOfPhase[1] = state.round0;
233: 233:     addPhase(round0EndTime);       
234: 234:     stateOfPhase[2] = state.offChainReg;
235: 235:     addPhase(round1StartTime);     
236: 236:     stateOfPhase[3] = state.round1;
237: 237:     addPhase(round1EndTime);       
238: 238:     stateOfPhase[4] = state.offChainReg;
239: 239:     addPhase(finalizeStartTime);   
240: 240:     stateOfPhase[5] = state.finalization;
241: 241:     addPhase(finalizeEndTime);     
242: 242:     stateOfPhase[6] = state.done;
243: 243: 
244: 244:     
245: 245:     
246: 246:     phaseOfRound0 = 1;
247: 247:     phaseOfRound1 = 3;
248: 248:     
249: 249:     
250: 250:     setMaxDelay(phaseOfRound0 - 1, maxRoundDelay);
251: 251:     setMaxDelay(phaseOfRound1 - 1, maxRoundDelay);
252: 252: 
253: 253:     
254: 254: 
255: 255: 
256: 256:     setTarget(phaseOfRound0, round0Target);
257: 257:     setTarget(phaseOfRound1, round1Target);
258: 258:   }
259: 259:   
260: 260:   
261: 261: 
262: 262: 
263: 263: 
264: 264: 
265: 265: 
266: 266: 
267: 267: 
268: 268: 
269: 269: 
270: 270: 
271: 271: 
272: 272: 
273: 273: 
274: 274: 
275: 275: 
276: 276: 
277: 277: 
278: 278: 
279: 279: 
280: 280: 
281: 281: 
282: 282:   
283: 283: 
284: 284: 
285: 285:   function getState() constant returns (state) {
286: 286:     return stateOfPhase[getPhaseAtTime(now)];
287: 287:   }
288: 288:   
289: 289:   
290: 290: 
291: 291: 
292: 292: 
293: 293: 
294: 294: 
295: 295: 
296: 296: 
297: 297:   function getMultiplierAtTime(uint time) constant returns (uint) {
298: 298:     
299: 299:     uint n = getPhaseAtTime(time);
300: 300: 
301: 301:     
302: 302:     if (stateOfPhase[n] == state.round0) {
303: 303:       return 100 + round0Bonus;
304: 304:     }
305: 305: 
306: 306:     
307: 307:     if (stateOfPhase[n] == state.round1) {
308: 308:       return 100 + getStepFunction(time - getPhaseStartTime(n));
309: 309:     }
310: 310: 
311: 311:     
312: 312:     throw;
313: 313:   }
314: 314: 
315: 315:   
316: 316: 
317: 317: 
318: 318: 
319: 319: 
320: 320: 
321: 321:   function donateAsWithChecksum(address addr, bytes4 checksum) 
322: 322:     payable 
323: 323:     returns (bool) 
324: 324:   {
325: 325:     
326: 326:     bytes32 hash = sha256(addr);
327: 327:     
328: 328:     
329: 329:     if (bytes4(hash) != checksum) { throw ; }
330: 330: 
331: 331:     
332: 332:     return donateAs(addr);
333: 333:   }
334: 334: 
335: 335:   
336: 336: 
337: 337: 
338: 338: 
339: 339: 
340: 340: 
341: 341: 
342: 342: 
343: 343: 
344: 344:   function finalize(address addr) {
345: 345:     
346: 346:     if (getState() != state.finalization) { throw; }
347: 347: 
348: 348:     
349: 349:     closeAssignmentsIfOpen(); 
350: 350: 
351: 351:     
352: 352:     uint tokensBurned = unrestrict(addr); 
353: 353:     
354: 354:     
355: 355:     BurnReceipt(addr, tokensBurned);
356: 356: 
357: 357:     
358: 358:     if (isUnrestricted()) { 
359: 359:       
360: 360:       endCurrentPhaseIn(0); 
361: 361:     }
362: 362:   }
363: 363: 
364: 364:   
365: 365: 
366: 366: 
367: 367:   function empty() returns (bool) {
368: 368:     return foundationWallet.call.value(this.balance)();
369: 369:   }
370: 370: 
371: 371:   
372: 372: 
373: 373: 
374: 374: 
375: 375: 
376: 376: 
377: 377: 
378: 378: 
379: 379: 
380: 380: 
381: 381: 
382: 382: 
383: 383: 
384: 384: 
385: 385:   function getStatus(uint donationRound, address dfnAddr, address fwdAddr)
386: 386:     public constant
387: 387:     returns (
388: 388:       state currentState,     
389: 389:       uint fxRate,            
390: 390:       uint currentMultiplier, 
391: 391:       uint donationCount,     
392: 392:       uint totalTokenAmount,  
393: 393:       uint startTime,         
394: 394:       uint endTime,           
395: 395:       bool isTargetReached,   
396: 396:       uint chfCentsDonated,   
397: 397:       uint tokenAmount,       
398: 398:       uint fwdBalance,        
399: 399:       uint donated)           
400: 400:   {
401: 401:     
402: 402:     currentState = getState();
403: 403:     if (currentState == state.round0 || currentState == state.round1) {
404: 404:       currentMultiplier = getMultiplierAtTime(now);
405: 405:     } 
406: 406:     fxRate = weiPerCHF;
407: 407:     donationCount = totalUnrestrictedAssignments;
408: 408:     totalTokenAmount = totalUnrestrictedTokens;
409: 409:    
410: 410:     
411: 411:     if (donationRound == 0) {
412: 412:       startTime = getPhaseStartTime(phaseOfRound0);
413: 413:       endTime = getPhaseStartTime(phaseOfRound0 + 1);
414: 414:       isTargetReached = targetReached(phaseOfRound0);
415: 415:       chfCentsDonated = counter[phaseOfRound0];
416: 416:     } else {
417: 417:       startTime = getPhaseStartTime(phaseOfRound1);
418: 418:       endTime = getPhaseStartTime(phaseOfRound1 + 1);
419: 419:       isTargetReached = targetReached(phaseOfRound1);
420: 420:       chfCentsDonated = counter[phaseOfRound1];
421: 421:     }
422: 422:     
423: 423:     
424: 424:     tokenAmount = tokens[dfnAddr];
425: 425:     donated = weiDonated[dfnAddr];
426: 426:     
427: 427:     
428: 428:     fwdBalance = fwdAddr.balance;
429: 429:   }
430: 430:   
431: 431:   
432: 432: 
433: 433: 
434: 434: 
435: 435: 
436: 436:   function setWeiPerCHF(uint weis) {
437: 437:     
438: 438:     if (msg.sender != exchangeRateAuth) { throw; }
439: 439: 
440: 440:     
441: 441:     weiPerCHF = weis;
442: 442:   }
443: 443: 
444: 444:   
445: 445: 
446: 446: 
447: 447: 
448: 448: 
449: 449: 
450: 450: 
451: 451: 
452: 452: 
453: 453: 
454: 454:   function registerEarlyContrib(address addr, uint tokenAmount, bytes32 memo) {
455: 455:     
456: 456:     if (msg.sender != registrarAuth) { throw; }
457: 457: 
458: 458:     
459: 459:     if (getState() != state.earlyContrib) { throw; }
460: 460: 
461: 461:     
462: 462:     if (!isRegistered(addr, true)) {
463: 463:       earlyContribList.push(addr);
464: 464:     }
465: 465:     
466: 466:     
467: 467:     assign(addr, tokenAmount, true);
468: 468:     
469: 469:     
470: 470:     EarlyContribReceipt(addr, tokenAmount, memo);
471: 471:   }
472: 472: 
473: 473:   
474: 474: 
475: 475: 
476: 476: 
477: 477: 
478: 478: 
479: 479: 
480: 480: 
481: 481: 
482: 482: 
483: 483: 
484: 484: 
485: 485: 
486: 486: 
487: 487: 
488: 488: 
489: 489: 
490: 490: 
491: 491: 
492: 492: 
493: 493:   function registerOffChainDonation(address addr, uint timestamp, uint chfCents, 
494: 494:                                     string currency, bytes32 memo)
495: 495:   {
496: 496:     
497: 497:     if (msg.sender != registrarAuth) { throw; }
498: 498: 
499: 499:     
500: 500:     uint currentPhase = getPhaseAtTime(now);
501: 501:     state currentState = stateOfPhase[currentPhase];
502: 502:     
503: 503:     
504: 504:     
505: 505:     if (currentState != state.round0 && currentState != state.round1 &&
506: 506:         currentState != state.offChainReg) {
507: 507:       throw;
508: 508:     }
509: 509:    
510: 510:     
511: 511:     if (timestamp > now) { throw; }
512: 512:    
513: 513:     
514: 514:     uint timestampPhase = getPhaseAtTime(timestamp);
515: 515:     state timestampState = stateOfPhase[timestampPhase];
516: 516:    
517: 517:     
518: 518:     
519: 519:     if ((currentState == state.round0 || currentState == state.round1) &&
520: 520:         (timestampState != currentState)) { 
521: 521:       throw;
522: 522:     }
523: 523:     
524: 524:     
525: 525:     
526: 526:     if (currentState == state.offChainReg && timestampPhase != currentPhase-1) {
527: 527:       throw;
528: 528:     }
529: 529: 
530: 530:     
531: 531:     if (memoUsed[memo]) {
532: 532:       throw;
533: 533:     }
534: 534: 
535: 535:     
536: 536:     memoUsed[memo] = true;
537: 537: 
538: 538:     
539: 539:     bookDonation(addr, timestamp, chfCents, currency, memo);
540: 540:   }
541: 541: 
542: 542:   
543: 543: 
544: 544: 
545: 545: 
546: 546: 
547: 547: 
548: 548: 
549: 549: 
550: 550:   function delayDonPhase(uint donPhase, uint timedelta) {
551: 551:     
552: 552:     if (msg.sender != registrarAuth) { throw; }
553: 553: 
554: 554:     
555: 555:     
556: 556:     
557: 557:     if (donPhase == 0) {
558: 558:       delayPhaseEndBy(phaseOfRound0 - 1, timedelta);
559: 559:     } else if (donPhase == 1) {
560: 560:       delayPhaseEndBy(phaseOfRound1 - 1, timedelta);
561: 561:     }
562: 562:   }
563: 563: 
564: 564:   
565: 565: 
566: 566: 
567: 567: 
568: 568: 
569: 569:   function setFoundationWallet(address newAddr) {
570: 570:     
571: 571:     if (msg.sender != masterAuth) { throw; }
572: 572:     
573: 573:     
574: 574:     if (getPhaseAtTime(now) >= phaseOfRound0) { throw; }
575: 575:  
576: 576:     foundationWallet = newAddr;
577: 577:   }
578: 578: 
579: 579:   
580: 580: 
581: 581: 
582: 582: 
583: 583: 
584: 584:   function setExchangeRateAuth(address newAuth) {
585: 585:     
586: 586:     if (msg.sender != masterAuth) { throw; }
587: 587:  
588: 588:     exchangeRateAuth = newAuth;
589: 589:   }
590: 590: 
591: 591:   
592: 592: 
593: 593: 
594: 594: 
595: 595: 
596: 596:   function setRegistrarAuth(address newAuth) {
597: 597:     
598: 598:     if (msg.sender != masterAuth) { throw; }
599: 599:  
600: 600:     registrarAuth = newAuth;
601: 601:   }
602: 602: 
603: 603:   
604: 604: 
605: 605: 
606: 606: 
607: 607: 
608: 608:   function setMasterAuth(address newAuth) {
609: 609:     
610: 610:     if (msg.sender != masterAuth) { throw; }
611: 611:  
612: 612:     masterAuth = newAuth;
613: 613:   }
614: 614: 
615: 615:   
616: 616: 
617: 617: 
618: 618: 
619: 619: 
620: 620: 
621: 621:   
622: 622:   
623: 623: 
624: 624: 
625: 625: 
626: 626: 
627: 627: 
628: 628:   function donateAs(address addr) private returns (bool) {
629: 629:     
630: 630:     state st = getState();
631: 631:     
632: 632:     
633: 633:     if (st != state.round0 && st != state.round1) { throw; }
634: 634: 
635: 635:     
636: 636:     if (msg.value < minDonation) { throw; }
637: 637: 
638: 638:     
639: 639:     if (weiPerCHF == 0) { throw; } 
640: 640: 
641: 641:     
642: 642:     totalWeiDonated += msg.value;
643: 643:     weiDonated[addr] += msg.value;
644: 644: 
645: 645:     
646: 646:     uint chfCents = (msg.value * 100) / weiPerCHF;
647: 647:     
648: 648:     
649: 649:     bookDonation(addr, now, chfCents, "ETH", "");
650: 650: 
651: 651:     
652: 652:     return foundationWallet.call.value(this.balance)();
653: 653:   }
654: 654: 
655: 655:   
656: 656: 
657: 657: 
658: 658: 
659: 659: 
660: 660: 
661: 661: 
662: 662: 
663: 663: 
664: 664: 
665: 665:   function bookDonation(address addr, uint timestamp, uint chfCents, 
666: 666:                         string currency, bytes32 memo) private
667: 667:   {
668: 668:     
669: 669:     uint phase = getPhaseAtTime(timestamp);
670: 670:     
671: 671:     
672: 672:     bool targetReached = addTowardsTarget(phase, chfCents);
673: 673:     
674: 674:     
675: 675:     if (targetReached && phase == getPhaseAtTime(now)) {
676: 676:       if (phase == phaseOfRound0) {
677: 677:         endCurrentPhaseIn(gracePeriodAfterRound0Target);
678: 678:       } else if (phase == phaseOfRound1) {
679: 679:         endCurrentPhaseIn(gracePeriodAfterRound1Target);
680: 680:       }
681: 681:     }
682: 682: 
683: 683:     
684: 684:     uint bonusMultiplier = getMultiplierAtTime(timestamp);
685: 685:     
686: 686:     
687: 687:     chfCents = (chfCents * bonusMultiplier) / 100;
688: 688: 
689: 689:     
690: 690:     uint tokenAmount = (chfCents * tokensPerCHF) / 100;
691: 691: 
692: 692:     
693: 693:     if (!isRegistered(addr, false)) {
694: 694:       donorList.push(addr);
695: 695:     }
696: 696:     
697: 697:     
698: 698:     assign(addr,tokenAmount,false);
699: 699: 
700: 700:     
701: 701:     DonationReceipt(addr, currency, bonusMultiplier, timestamp, tokenAmount, 
702: 702:                     memo);
703: 703:   }
704: 704: }