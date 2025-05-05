1: 1: pragma solidity 0.4.24;
2: 2: 
3: 3: contract Migrations {
4: 4:     address public owner;
5: 5: 
6: 6:     uint public last_completed_migration;
7: 7: 
8: 8:     modifier restricted() {
9: 9:         if (msg.sender == owner) {
10: 10:             _;
11: 11:         }
12: 12:     }
13: 13: 
14: 14:     function Migrations()  public {
15: 15:         owner = msg.sender;
16: 16:     }
17: 17: 
18: 18:     function setCompleted(uint completed) restricted  public {
19: 19:         last_completed_migration = completed;
20: 20:     }
21: 21: 
22: 22:     function upgrade(address new_address) restricted  public {
23: 23:         Migrations upgraded = Migrations(new_address);
24: 24:         upgraded.setCompleted(last_completed_migration);
25: 25:     }
26: 26: }
27: 27: 
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32: library ExecutionLib {
33: 33: 
34: 34:     struct ExecutionData {
35: 35:         address toAddress;                  
36: 36:         bytes callData;                     
37: 37:         uint callValue;                     
38: 38:         uint callGas;                       
39: 39:         uint gasPrice;                      
40: 40:     }
41: 41: 
42: 42:     
43: 43: 
44: 44: 
45: 45: 
46: 46:     function sendTransaction(ExecutionData storage self)
47: 47:         internal returns (bool)
48: 48:     {
49: 49:         
50: 50:         require(self.gasPrice <= tx.gasprice);
51: 51:         
52: 52:         return self.toAddress.call.value(self.callValue).gas(self.callGas)(self.callData);
53: 53:     }
54: 54: 
55: 55: 
56: 56:     
57: 57: 
58: 58: 
59: 59: 
60: 60: 
61: 61:     function CALL_GAS_CEILING(uint EXTRA_GAS) 
62: 62:         internal view returns (uint)
63: 63:     {
64: 64:         return block.gaslimit - EXTRA_GAS;
65: 65:     }
66: 66: 
67: 67:     
68: 68: 
69: 69: 
70: 70: 
71: 71:     function validateCallGas(uint callGas, uint EXTRA_GAS)
72: 72:         internal view returns (bool)
73: 73:     {
74: 74:         return callGas < CALL_GAS_CEILING(EXTRA_GAS);
75: 75:     }
76: 76: 
77: 77:     
78: 78: 
79: 79: 
80: 80:     function validateToAddress(address toAddress)
81: 81:         internal pure returns (bool)
82: 82:     {
83: 83:         return toAddress != 0x0;
84: 84:     }
85: 85: }
86: 86: 
87: 87: library MathLib {
88: 88:     uint constant INT_MAX = 57896044618658097711785492504343953926634992332820282019728792003956564819967;  
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
120: 120:     
121: 121:     
122: 122:     
123: 123:     
124: 124:     
125: 125: 
126: 126:     
127: 127: 
128: 128: 
129: 129:     function max(uint a, uint b) 
130: 130:         public pure returns (uint)
131: 131:     {
132: 132:         if (a >= b) {
133: 133:             return a;
134: 134:         } else {
135: 135:             return b;
136: 136:         }
137: 137:     }
138: 138: 
139: 139:     
140: 140: 
141: 141: 
142: 142:     function min(uint a, uint b) 
143: 143:         public pure returns (uint)
144: 144:     {
145: 145:         if (a <= b) {
146: 146:             return a;
147: 147:         } else {
148: 148:             return b;
149: 149:         }
150: 150:     }
151: 151: 
152: 152:     
153: 153: 
154: 154: 
155: 155: 
156: 156: 
157: 157:     function safeCastSigned(uint a) 
158: 158:         public pure returns (int)
159: 159:     {
160: 160:         assert(a <= INT_MAX);
161: 161:         return int(a);
162: 162:     }
163: 163:     
164: 164: }
165: 165: 
166: 166: 
167: 167: 
168: 168: 
169: 169: 
170: 170: library RequestMetaLib {
171: 171: 
172: 172:     struct RequestMeta {
173: 173:         address owner;              
174: 174: 
175: 175:         address createdBy;          
176: 176: 
177: 177:         bool isCancelled;           
178: 178:         
179: 179:         bool wasCalled;             
180: 180: 
181: 181:         bool wasSuccessful;         
182: 182:     }
183: 183: 
184: 184: }
185: 185: 
186: 186: library RequestLib {
187: 187:     using ClaimLib for ClaimLib.ClaimData;
188: 188:     using ExecutionLib for ExecutionLib.ExecutionData;
189: 189:     using PaymentLib for PaymentLib.PaymentData;
190: 190:     using RequestMetaLib for RequestMetaLib.RequestMeta;
191: 191:     using RequestScheduleLib for RequestScheduleLib.ExecutionWindow;
192: 192:     using SafeMath for uint;
193: 193: 
194: 194:     struct Request {
195: 195:         ExecutionLib.ExecutionData txnData;
196: 196:         RequestMetaLib.RequestMeta meta;
197: 197:         PaymentLib.PaymentData paymentData;
198: 198:         ClaimLib.ClaimData claimData;
199: 199:         RequestScheduleLib.ExecutionWindow schedule;
200: 200:     }
201: 201: 
202: 202:     enum AbortReason {
203: 203:         WasCancelled,       
204: 204:         AlreadyCalled,      
205: 205:         BeforeCallWindow,   
206: 206:         AfterCallWindow,    
207: 207:         ReservedForClaimer, 
208: 208:         InsufficientGas,    
209: 209:         TooLowGasPrice    
210: 210:     }
211: 211: 
212: 212:     event Aborted(uint8 reason);
213: 213:     event Cancelled(uint rewardPayment, uint measuredGasConsumption);
214: 214:     event Claimed();
215: 215:     event Executed(uint bounty, uint fee, uint measuredGasConsumption);
216: 216: 
217: 217:     
218: 218: 
219: 219: 
220: 220:     function validate(
221: 221:         address[4]  _addressArgs,
222: 222:         uint[12]    _uintArgs,
223: 223:         uint        _endowment
224: 224:     ) 
225: 225:         public view returns (bool[6] isValid)
226: 226:     {
227: 227:         
228: 228:         
229: 229:         isValid[0] = PaymentLib.validateEndowment(
230: 230:             _endowment,
231: 231:             _uintArgs[1],               
232: 232:             _uintArgs[0],               
233: 233:             _uintArgs[8],               
234: 234:             _uintArgs[9],               
235: 235:             _uintArgs[10],              
236: 236:             EXECUTION_GAS_OVERHEAD
237: 237:         );
238: 238:         isValid[1] = RequestScheduleLib.validateReservedWindowSize(
239: 239:             _uintArgs[4],               
240: 240:             _uintArgs[6]                
241: 241:         );
242: 242:         isValid[2] = RequestScheduleLib.validateTemporalUnit(_uintArgs[5]);
243: 243:         isValid[3] = RequestScheduleLib.validateWindowStart(
244: 244:             RequestScheduleLib.TemporalUnit(MathLib.min(_uintArgs[5], 2)),
245: 245:             _uintArgs[3],               
246: 246:             _uintArgs[7]                
247: 247:         );
248: 248:         isValid[4] = ExecutionLib.validateCallGas(
249: 249:             _uintArgs[8],               
250: 250:             EXECUTION_GAS_OVERHEAD
251: 251:         );
252: 252:         isValid[5] = ExecutionLib.validateToAddress(_addressArgs[3]);
253: 253: 
254: 254:         return isValid;
255: 255:     }
256: 256: 
257: 257:     
258: 258: 
259: 259: 
260: 260:     function initialize(
261: 261:         Request storage self,
262: 262:         address[4]      _addressArgs,
263: 263:         uint[12]        _uintArgs,
264: 264:         bytes           _callData
265: 265:     ) 
266: 266:         public returns (bool)
267: 267:     {
268: 268:         address[6] memory addressValues = [
269: 269:             0x0,                
270: 270:             _addressArgs[0],    
271: 271:             _addressArgs[1],    
272: 272:             _addressArgs[2],    
273: 273:             0x0,                
274: 274:             _addressArgs[3]     
275: 275:         ];
276: 276: 
277: 277:         bool[3] memory boolValues = [false, false, false];
278: 278: 
279: 279:         uint[15] memory uintValues = [
280: 280:             0,                  
281: 281:             _uintArgs[0],       
282: 282:             0,                  
283: 283:             _uintArgs[1],       
284: 284:             0,                  
285: 285:             _uintArgs[2],       
286: 286:             _uintArgs[3],       
287: 287:             _uintArgs[4],       
288: 288:             _uintArgs[5],       
289: 289:             _uintArgs[6],       
290: 290:             _uintArgs[7],       
291: 291:             _uintArgs[8],       
292: 292:             _uintArgs[9],       
293: 293:             _uintArgs[10],      
294: 294:             _uintArgs[11]       
295: 295:         ];
296: 296: 
297: 297:         uint8[1] memory uint8Values = [
298: 298:             0
299: 299:         ];
300: 300: 
301: 301:         require(deserialize(self, addressValues, boolValues, uintValues, uint8Values, _callData));
302: 302: 
303: 303:         return true;
304: 304:     }
305: 305:  
306: 306:     function serialize(Request storage self)
307: 307:         internal view returns(address[6], bool[3], uint[15], uint8[1])
308: 308:     {
309: 309:         address[6] memory addressValues = [
310: 310:             self.claimData.claimedBy,
311: 311:             self.meta.createdBy,
312: 312:             self.meta.owner,
313: 313:             self.paymentData.feeRecipient,
314: 314:             self.paymentData.bountyBenefactor,
315: 315:             self.txnData.toAddress
316: 316:         ];
317: 317: 
318: 318:         bool[3] memory boolValues = [
319: 319:             self.meta.isCancelled,
320: 320:             self.meta.wasCalled,
321: 321:             self.meta.wasSuccessful
322: 322:         ];
323: 323: 
324: 324:         uint[15] memory uintValues = [
325: 325:             self.claimData.claimDeposit,
326: 326:             self.paymentData.fee,
327: 327:             self.paymentData.feeOwed,
328: 328:             self.paymentData.bounty,
329: 329:             self.paymentData.bountyOwed,
330: 330:             self.schedule.claimWindowSize,
331: 331:             self.schedule.freezePeriod,
332: 332:             self.schedule.reservedWindowSize,
333: 333:             uint(self.schedule.temporalUnit),
334: 334:             self.schedule.windowSize,
335: 335:             self.schedule.windowStart,
336: 336:             self.txnData.callGas,
337: 337:             self.txnData.callValue,
338: 338:             self.txnData.gasPrice,
339: 339:             self.claimData.requiredDeposit
340: 340:         ];
341: 341: 
342: 342:         uint8[1] memory uint8Values = [
343: 343:             self.claimData.paymentModifier
344: 344:         ];
345: 345: 
346: 346:         return (addressValues, boolValues, uintValues, uint8Values);
347: 347:     }
348: 348: 
349: 349:     
350: 350: 
351: 351: 
352: 352: 
353: 353: 
354: 354:     function deserialize(
355: 355:         Request storage self,
356: 356:         address[6]  _addressValues,
357: 357:         bool[3]     _boolValues,
358: 358:         uint[15]    _uintValues,
359: 359:         uint8[1]    _uint8Values,
360: 360:         bytes       _callData
361: 361:     )
362: 362:         internal returns (bool)
363: 363:     {
364: 364:         
365: 365:         self.txnData.callData = _callData;
366: 366: 
367: 367:         
368: 368:         self.claimData.claimedBy = _addressValues[0];
369: 369:         self.meta.createdBy = _addressValues[1];
370: 370:         self.meta.owner = _addressValues[2];
371: 371:         self.paymentData.feeRecipient = _addressValues[3];
372: 372:         self.paymentData.bountyBenefactor = _addressValues[4];
373: 373:         self.txnData.toAddress = _addressValues[5];
374: 374: 
375: 375:         
376: 376:         self.meta.isCancelled = _boolValues[0];
377: 377:         self.meta.wasCalled = _boolValues[1];
378: 378:         self.meta.wasSuccessful = _boolValues[2];
379: 379: 
380: 380:         
381: 381:         self.claimData.claimDeposit = _uintValues[0];
382: 382:         self.paymentData.fee = _uintValues[1];
383: 383:         self.paymentData.feeOwed = _uintValues[2];
384: 384:         self.paymentData.bounty = _uintValues[3];
385: 385:         self.paymentData.bountyOwed = _uintValues[4];
386: 386:         self.schedule.claimWindowSize = _uintValues[5];
387: 387:         self.schedule.freezePeriod = _uintValues[6];
388: 388:         self.schedule.reservedWindowSize = _uintValues[7];
389: 389:         self.schedule.temporalUnit = RequestScheduleLib.TemporalUnit(_uintValues[8]);
390: 390:         self.schedule.windowSize = _uintValues[9];
391: 391:         self.schedule.windowStart = _uintValues[10];
392: 392:         self.txnData.callGas = _uintValues[11];
393: 393:         self.txnData.callValue = _uintValues[12];
394: 394:         self.txnData.gasPrice = _uintValues[13];
395: 395:         self.claimData.requiredDeposit = _uintValues[14];
396: 396: 
397: 397:         
398: 398:         self.claimData.paymentModifier = _uint8Values[0];
399: 399: 
400: 400:         return true;
401: 401:     }
402: 402: 
403: 403:     function execute(Request storage self) 
404: 404:         internal returns (bool)
405: 405:     {
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
423: 423: 
424: 424: 
425: 425: 
426: 426: 
427: 427: 
428: 428: 
429: 429: 
430: 430: 
431: 431: 
432: 432: 
433: 433: 
434: 434: 
435: 435: 
436: 436: 
437: 437: 
438: 438: 
439: 439: 
440: 440: 
441: 441: 
442: 442: 
443: 443: 
444: 444: 
445: 445: 
446: 446: 
447: 447: 
448: 448: 
449: 449:         
450: 450:         
451: 451:         uint startGas = gasleft();
452: 452: 
453: 453:         
454: 454:         
455: 455:         
456: 456: 
457: 457:         if (gasleft() < requiredExecutionGas(self).sub(PRE_EXECUTION_GAS)) {
458: 458:             emit Aborted(uint8(AbortReason.InsufficientGas));
459: 459:             return false;
460: 460:         } else if (self.meta.wasCalled) {
461: 461:             emit Aborted(uint8(AbortReason.AlreadyCalled));
462: 462:             return false;
463: 463:         } else if (self.meta.isCancelled) {
464: 464:             emit Aborted(uint8(AbortReason.WasCancelled));
465: 465:             return false;
466: 466:         } else if (self.schedule.isBeforeWindow()) {
467: 467:             emit Aborted(uint8(AbortReason.BeforeCallWindow));
468: 468:             return false;
469: 469:         } else if (self.schedule.isAfterWindow()) {
470: 470:             emit Aborted(uint8(AbortReason.AfterCallWindow));
471: 471:             return false;
472: 472:         } else if (self.claimData.isClaimed() && msg.sender != self.claimData.claimedBy && self.schedule.inReservedWindow()) {
473: 473:             emit Aborted(uint8(AbortReason.ReservedForClaimer));
474: 474:             return false;
475: 475:         } else if (self.txnData.gasPrice > tx.gasprice) {
476: 476:             emit Aborted(uint8(AbortReason.TooLowGasPrice));
477: 477:             return false;
478: 478:         }
479: 479: 
480: 480:         
481: 481:         
482: 482:         
483: 483:         
484: 484:         
485: 485:         
486: 486: 
487: 487:         
488: 488:         self.meta.wasCalled = true;
489: 489: 
490: 490:         
491: 491:         
492: 492:         
493: 493:         self.meta.wasSuccessful = self.txnData.sendTransaction();
494: 494: 
495: 495:         
496: 496:         
497: 497:         
498: 498:         
499: 499:         
500: 500:         
501: 501: 
502: 502:         
503: 503:         if (self.paymentData.hasFeeRecipient()) {
504: 504:             self.paymentData.feeOwed = self.paymentData.getFee()
505: 505:                 .add(self.paymentData.feeOwed);
506: 506:         }
507: 507: 
508: 508:         
509: 509:         
510: 510:         uint totalFeePayment = self.paymentData.feeOwed;
511: 511: 
512: 512:         
513: 513:         
514: 514:         self.paymentData.sendFee();
515: 515: 
516: 516:         
517: 517:         self.paymentData.bountyBenefactor = msg.sender;
518: 518:         if (self.claimData.isClaimed()) {
519: 519:             
520: 520:             
521: 521:             self.paymentData.bountyOwed = self.claimData.claimDeposit
522: 522:                 .add(self.paymentData.bountyOwed);
523: 523:             
524: 524:             
525: 525:             self.claimData.claimDeposit = 0;
526: 526:             
527: 527:             
528: 528:             self.paymentData.bountyOwed = self.paymentData.getBountyWithModifier(self.claimData.paymentModifier)
529: 529:                 .add(self.paymentData.bountyOwed);
530: 530:         } else {
531: 531:             
532: 532:             self.paymentData.bountyOwed = self.paymentData.getBounty().add(self.paymentData.bountyOwed);
533: 533:         }
534: 534: 
535: 535:         
536: 536:         uint measuredGasConsumption = startGas.sub(gasleft()).add(EXECUTE_EXTRA_GAS);
537: 537: 
538: 538:         
539: 539:         
540: 540:         
541: 541: 
542: 542:         
543: 543:         self.paymentData.bountyOwed = measuredGasConsumption
544: 544:             .mul(self.txnData.gasPrice)
545: 545:             .add(self.paymentData.bountyOwed);
546: 546: 
547: 547:         
548: 548:         
549: 549:         emit Executed(self.paymentData.bountyOwed, totalFeePayment, measuredGasConsumption);
550: 550:     
551: 551:         
552: 552:         self.paymentData.sendBounty();
553: 553: 
554: 554:         
555: 555:         _sendOwnerEther(self, self.meta.owner);
556: 556: 
557: 557:         
558: 558:         
559: 559:         
560: 560:         
561: 561:         return true;
562: 562:     }
563: 563: 
564: 564: 
565: 565:     
566: 566:     
567: 567:     
568: 568:     uint public constant PRE_EXECUTION_GAS = 25000;   
569: 569:     
570: 570:     
571: 571: 
572: 572: 
573: 573: 
574: 574:     uint public constant EXECUTION_GAS_OVERHEAD = 180000; 
575: 575:     
576: 576: 
577: 577: 
578: 578: 
579: 579:     uint public constant  EXECUTE_EXTRA_GAS = 90000; 
580: 580: 
581: 581:     
582: 582: 
583: 583: 
584: 584: 
585: 585:     uint public constant CANCEL_EXTRA_GAS = 85000; 
586: 586: 
587: 587:     function getEXECUTION_GAS_OVERHEAD()
588: 588:         public pure returns (uint)
589: 589:     {
590: 590:         return EXECUTION_GAS_OVERHEAD;
591: 591:     }
592: 592:     
593: 593:     function requiredExecutionGas(Request storage self) 
594: 594:         public view returns (uint requiredGas)
595: 595:     {
596: 596:         requiredGas = self.txnData.callGas.add(EXECUTION_GAS_OVERHEAD);
597: 597:     }
598: 598: 
599: 599:     
600: 600: 
601: 601: 
602: 602: 
603: 603: 
604: 604: 
605: 605: 
606: 606: 
607: 607: 
608: 608:     function isCancellable(Request storage self) 
609: 609:         public view returns (bool)
610: 610:     {
611: 611:         if (self.meta.isCancelled) {
612: 612:             
613: 613:             return false;
614: 614:         } else if (!self.meta.wasCalled && self.schedule.isAfterWindow()) {
615: 615:             
616: 616:             return true;
617: 617:         } else if (!self.claimData.isClaimed() && self.schedule.isBeforeFreeze() && msg.sender == self.meta.owner) {
618: 618:             
619: 619:             return true;
620: 620:         } else {
621: 621:             
622: 622:             return false;
623: 623:         }
624: 624:     }
625: 625: 
626: 626:     
627: 627: 
628: 628: 
629: 629: 
630: 630: 
631: 631: 
632: 632:     function cancel(Request storage self) 
633: 633:         public returns (bool)
634: 634:     {
635: 635:         uint startGas = gasleft();
636: 636:         uint rewardPayment;
637: 637:         uint measuredGasConsumption;
638: 638: 
639: 639:         
640: 640:         require(isCancellable(self));
641: 641: 
642: 642:         
643: 643:         self.meta.isCancelled = true;
644: 644: 
645: 645:         
646: 646:         require(self.claimData.refundDeposit());
647: 647: 
648: 648:         
649: 649:         
650: 650:         
651: 651:         
652: 652:         if (msg.sender != self.meta.owner) {
653: 653:             
654: 654:             address rewardBenefactor = msg.sender;
655: 655:             
656: 656:             
657: 657:             uint rewardOwed = self.paymentData.bountyOwed
658: 658:                 .add(self.paymentData.bounty.div(100));
659: 659: 
660: 660:             
661: 661:             measuredGasConsumption = startGas
662: 662:                 .sub(gasleft())
663: 663:                 .add(CANCEL_EXTRA_GAS);
664: 664:             
665: 665:             rewardOwed = measuredGasConsumption
666: 666:                 .mul(tx.gasprice)
667: 667:                 .add(rewardOwed);
668: 668: 
669: 669:             
670: 670:             rewardPayment = rewardOwed;
671: 671: 
672: 672:             
673: 673:             if (rewardOwed > 0) {
674: 674:                 self.paymentData.bountyOwed = 0;
675: 675:                 rewardBenefactor.transfer(rewardOwed);
676: 676:             }
677: 677:         }
678: 678: 
679: 679:         
680: 680:         emit Cancelled(rewardPayment, measuredGasConsumption);
681: 681: 
682: 682:         
683: 683:         return sendOwnerEther(self);
684: 684:     }
685: 685: 
686: 686:     
687: 687: 
688: 688: 
689: 689: 
690: 690:     function isClaimable(Request storage self) 
691: 691:         internal view returns (bool)
692: 692:     {
693: 693:         
694: 694:         require(!self.claimData.isClaimed());
695: 695:         require(!self.meta.isCancelled);
696: 696: 
697: 697:         
698: 698:         require(self.schedule.inClaimWindow());
699: 699:         require(msg.value >= self.claimData.requiredDeposit);
700: 700:         return true;
701: 701:     }
702: 702: 
703: 703:     
704: 704: 
705: 705: 
706: 706: 
707: 707: 
708: 708:     function claim(Request storage self) 
709: 709:         internal returns (bool claimed)
710: 710:     {
711: 711:         require(isClaimable(self));
712: 712:         
713: 713:         emit Claimed();
714: 714:         return self.claimData.claim(self.schedule.computePaymentModifier());
715: 715:     }
716: 716: 
717: 717:     
718: 718: 
719: 719: 
720: 720:     function refundClaimDeposit(Request storage self)
721: 721:         public returns (bool)
722: 722:     {
723: 723:         require(self.meta.isCancelled || self.schedule.isAfterWindow());
724: 724:         return self.claimData.refundDeposit();
725: 725:     }
726: 726: 
727: 727:     
728: 728: 
729: 729: 
730: 730: 
731: 731:     function sendFee(Request storage self) 
732: 732:         public returns (bool)
733: 733:     {
734: 734:         if (self.schedule.isAfterWindow()) {
735: 735:             return self.paymentData.sendFee();
736: 736:         }
737: 737:         return false;
738: 738:     }
739: 739: 
740: 740:     
741: 741: 
742: 742: 
743: 743: 
744: 744:     function sendBounty(Request storage self) 
745: 745:         public returns (bool)
746: 746:     {
747: 747:         
748: 748:         if (self.schedule.isAfterWindow()) {
749: 749:             return self.paymentData.sendBounty();
750: 750:         }
751: 751:         return false;
752: 752:     }
753: 753: 
754: 754:     function canSendOwnerEther(Request storage self) 
755: 755:         public view returns(bool) 
756: 756:     {
757: 757:         return self.meta.isCancelled || self.schedule.isAfterWindow() || self.meta.wasCalled;
758: 758:     }
759: 759: 
760: 760:     
761: 761: 
762: 762: 
763: 763: 
764: 764:     function sendOwnerEther(Request storage self, address recipient)
765: 765:         public returns (bool)
766: 766:     {
767: 767:         require(recipient != 0x0);
768: 768:         if(canSendOwnerEther(self) && msg.sender == self.meta.owner) {
769: 769:             return _sendOwnerEther(self, recipient);
770: 770:         }
771: 771:         return false;
772: 772:     }
773: 773: 
774: 774:     
775: 775: 
776: 776: 
777: 777: 
778: 778:     function sendOwnerEther(Request storage self)
779: 779:         public returns (bool)
780: 780:     {
781: 781:         if(canSendOwnerEther(self)) {
782: 782:             return _sendOwnerEther(self, self.meta.owner);
783: 783:         }
784: 784:         return false;
785: 785:     }
786: 786: 
787: 787:     function _sendOwnerEther(Request storage self, address recipient) 
788: 788:         private returns (bool)
789: 789:     {
790: 790:         
791: 791:         
792: 792:         uint ownerRefund = address(this).balance
793: 793:             .sub(self.claimData.claimDeposit)
794: 794:             .sub(self.paymentData.bountyOwed)
795: 795:             .sub(self.paymentData.feeOwed);
796: 796:         
797: 797:         return recipient.send(ownerRefund);
798: 798:     }
799: 799: }
800: 800: 
801: 801: 
802: 802: 
803: 803: 
804: 804: 
805: 805: library RequestScheduleLib {
806: 806:     using SafeMath for uint;
807: 807: 
808: 808:     
809: 809: 
810: 810: 
811: 811: 
812: 812: 
813: 813: 
814: 814: 
815: 815:     enum TemporalUnit {
816: 816:         Null,           
817: 817:         Blocks,         
818: 818:         Timestamp       
819: 819:     }
820: 820: 
821: 821:     struct ExecutionWindow {
822: 822: 
823: 823:         TemporalUnit temporalUnit;      
824: 824: 
825: 825:         uint windowStart;               
826: 826: 
827: 827:         uint windowSize;                
828: 828: 
829: 829:         uint freezePeriod;              
830: 830: 
831: 831:         uint reservedWindowSize;        
832: 832: 
833: 833:         uint claimWindowSize;           
834: 834:     }
835: 835: 
836: 836:     
837: 837: 
838: 838: 
839: 839: 
840: 840: 
841: 841:     function getNow(ExecutionWindow storage self) 
842: 842:         public view returns (uint)
843: 843:     {
844: 844:         return _getNow(self.temporalUnit);
845: 845:     }
846: 846: 
847: 847:     
848: 848: 
849: 849: 
850: 850: 
851: 851:     function _getNow(TemporalUnit _temporalUnit) 
852: 852:         internal view returns (uint)
853: 853:     {
854: 854:         if (_temporalUnit == TemporalUnit.Timestamp) {
855: 855:             return block.timestamp;
856: 856:         } 
857: 857:         if (_temporalUnit == TemporalUnit.Blocks) {
858: 858:             return block.number;
859: 859:         }
860: 860:         
861: 861:         revert();
862: 862:     }
863: 863: 
864: 864:     
865: 865: 
866: 866: 
867: 867: 
868: 868:     function computePaymentModifier(ExecutionWindow storage self) 
869: 869:         internal view returns (uint8)
870: 870:     {        
871: 871:         uint paymentModifier = (getNow(self).sub(firstClaimBlock(self)))
872: 872:             .mul(100)
873: 873:             .div(self.claimWindowSize); 
874: 874:         assert(paymentModifier <= 100); 
875: 875: 
876: 876:         return uint8(paymentModifier);
877: 877:     }
878: 878: 
879: 879:     
880: 880: 
881: 881: 
882: 882:     function windowEnd(ExecutionWindow storage self)
883: 883:         internal view returns (uint)
884: 884:     {
885: 885:         return self.windowStart.add(self.windowSize);
886: 886:     }
887: 887: 
888: 888:     
889: 889: 
890: 890: 
891: 891: 
892: 892:     function reservedWindowEnd(ExecutionWindow storage self)
893: 893:         internal view returns (uint)
894: 894:     {
895: 895:         return self.windowStart.add(self.reservedWindowSize);
896: 896:     }
897: 897: 
898: 898:     
899: 899: 
900: 900: 
901: 901:     function freezeStart(ExecutionWindow storage self) 
902: 902:         internal view returns (uint)
903: 903:     {
904: 904:         return self.windowStart.sub(self.freezePeriod);
905: 905:     }
906: 906: 
907: 907:     
908: 908: 
909: 909: 
910: 910:     function firstClaimBlock(ExecutionWindow storage self) 
911: 911:         internal view returns (uint)
912: 912:     {
913: 913:         return freezeStart(self).sub(self.claimWindowSize);
914: 914:     }
915: 915: 
916: 916:     
917: 917: 
918: 918: 
919: 919:     function isBeforeWindow(ExecutionWindow storage self)
920: 920:         internal view returns (bool)
921: 921:     {
922: 922:         return getNow(self) < self.windowStart;
923: 923:     }
924: 924: 
925: 925:     
926: 926: 
927: 927: 
928: 928:     function isAfterWindow(ExecutionWindow storage self) 
929: 929:         internal view returns (bool)
930: 930:     {
931: 931:         return getNow(self) > windowEnd(self);
932: 932:     }
933: 933: 
934: 934:     
935: 935: 
936: 936: 
937: 937:     function inWindow(ExecutionWindow storage self)
938: 938:         internal view returns (bool)
939: 939:     {
940: 940:         return self.windowStart <= getNow(self) && getNow(self) < windowEnd(self);
941: 941:     }
942: 942: 
943: 943:     
944: 944: 
945: 945: 
946: 946: 
947: 947:     function inReservedWindow(ExecutionWindow storage self)
948: 948:         internal view returns (bool)
949: 949:     {
950: 950:         return self.windowStart <= getNow(self) && getNow(self) < reservedWindowEnd(self);
951: 951:     }
952: 952: 
953: 953:     
954: 954: 
955: 955: 
956: 956:     function inClaimWindow(ExecutionWindow storage self) 
957: 957:         internal view returns (bool)
958: 958:     {
959: 959:         
960: 960:         
961: 961:         return firstClaimBlock(self) <= getNow(self) && getNow(self) < freezeStart(self);
962: 962:     }
963: 963: 
964: 964:     
965: 965: 
966: 966: 
967: 967:     function isBeforeFreeze(ExecutionWindow storage self) 
968: 968:         internal view returns (bool)
969: 969:     {
970: 970:         return getNow(self) < freezeStart(self);
971: 971:     }
972: 972: 
973: 973:     
974: 974: 
975: 975: 
976: 976:     function isBeforeClaimWindow(ExecutionWindow storage self)
977: 977:         internal view returns (bool)
978: 978:     {
979: 979:         return getNow(self) < firstClaimBlock(self);
980: 980:     }
981: 981: 
982: 982:     
983: 983:     
984: 984:     
985: 985: 
986: 986:     
987: 987: 
988: 988: 
989: 989: 
990: 990: 
991: 991: 
992: 992:     function validateReservedWindowSize(uint _reservedWindowSize, uint _windowSize)
993: 993:         public pure returns (bool)
994: 994:     {
995: 995:         return _reservedWindowSize <= _windowSize;
996: 996:     }
997: 997: 
998: 998:     
999: 999: 
1000: 1000: 
1001: 1001: 
1002: 1002: 
1003: 1003: 
1004: 1004: 
1005: 1005:     function validateWindowStart(TemporalUnit _temporalUnit, uint _freezePeriod, uint _windowStart) 
1006: 1006:         public view returns (bool)
1007: 1007:     {
1008: 1008:         return _getNow(_temporalUnit).add(_freezePeriod) <= _windowStart;
1009: 1009:     }
1010: 1010: 
1011: 1011:     
1012: 1012: 
1013: 1013: 
1014: 1014:     function validateTemporalUnit(uint _temporalUnitAsUInt) 
1015: 1015:         public pure returns (bool)
1016: 1016:     {
1017: 1017:         return (_temporalUnitAsUInt != uint(TemporalUnit.Null) &&
1018: 1018:             (_temporalUnitAsUInt == uint(TemporalUnit.Blocks) ||
1019: 1019:             _temporalUnitAsUInt == uint(TemporalUnit.Timestamp))
1020: 1020:         );
1021: 1021:     }
1022: 1022: }
1023: 1023: 
1024: 1024: library ClaimLib {
1025: 1025: 
1026: 1026:     struct ClaimData {
1027: 1027:         address claimedBy;          
1028: 1028:         uint claimDeposit;          
1029: 1029:         uint requiredDeposit;       
1030: 1030:         uint8 paymentModifier;      
1031: 1031:                                     
1032: 1032:     }
1033: 1033: 
1034: 1034:     
1035: 1035: 
1036: 1036: 
1037: 1037: 
1038: 1038: 
1039: 1039:     function claim(
1040: 1040:         ClaimData storage self, 
1041: 1041:         uint8 _paymentModifier
1042: 1042:     ) 
1043: 1043:         internal returns (bool)
1044: 1044:     {
1045: 1045:         self.claimedBy = msg.sender;
1046: 1046:         self.claimDeposit = msg.value;
1047: 1047:         self.paymentModifier = _paymentModifier;
1048: 1048:         return true;
1049: 1049:     }
1050: 1050: 
1051: 1051:     
1052: 1052: 
1053: 1053: 
1054: 1054:     function isClaimed(ClaimData storage self) 
1055: 1055:         internal view returns (bool)
1056: 1056:     {
1057: 1057:         return self.claimedBy != 0x0;
1058: 1058:     }
1059: 1059: 
1060: 1060: 
1061: 1061:     
1062: 1062: 
1063: 1063: 
1064: 1064: 
1065: 1065: 
1066: 1066:     function refundDeposit(ClaimData storage self) 
1067: 1067:         internal returns (bool)
1068: 1068:     {
1069: 1069:         
1070: 1070:         if (self.claimDeposit > 0) {
1071: 1071:             uint depositAmount;
1072: 1072:             depositAmount = self.claimDeposit;
1073: 1073:             self.claimDeposit = 0;
1074: 1074:             
1075: 1075:             return self.claimedBy.send(depositAmount);
1076: 1076:         }
1077: 1077:         return true;
1078: 1078:     }
1079: 1079: }
1080: 1080: 
1081: 1081: 
1082: 1082: 
1083: 1083: 
1084: 1084: 
1085: 1085: 
1086: 1086: 
1087: 1087: 
1088: 1088: 
1089: 1089: library PaymentLib {
1090: 1090:     using SafeMath for uint;
1091: 1091: 
1092: 1092:     struct PaymentData {
1093: 1093:         uint bounty;                
1094: 1094: 
1095: 1095:         address bountyBenefactor;   
1096: 1096: 
1097: 1097:         uint bountyOwed;            
1098: 1098: 
1099: 1099:         uint fee;                   
1100: 1100: 
1101: 1101:         address feeRecipient;       
1102: 1102: 
1103: 1103:         uint feeOwed;               
1104: 1104:     }
1105: 1105: 
1106: 1106:     
1107: 1107:     
1108: 1108:     
1109: 1109: 
1110: 1110:     
1111: 1111: 
1112: 1112: 
1113: 1113:     function hasFeeRecipient(PaymentData storage self)
1114: 1114:         internal view returns (bool)
1115: 1115:     {
1116: 1116:         return self.feeRecipient != 0x0;
1117: 1117:     }
1118: 1118: 
1119: 1119:     
1120: 1120: 
1121: 1121: 
1122: 1122:     function getFee(PaymentData storage self) 
1123: 1123:         internal view returns (uint)
1124: 1124:     {
1125: 1125:         return self.fee;
1126: 1126:     }
1127: 1127: 
1128: 1128:     
1129: 1129: 
1130: 1130: 
1131: 1131:     function getBounty(PaymentData storage self)
1132: 1132:         internal view returns (uint)
1133: 1133:     {
1134: 1134:         return self.bounty;
1135: 1135:     }
1136: 1136:  
1137: 1137:     
1138: 1138: 
1139: 1139: 
1140: 1140: 
1141: 1141:     function getBountyWithModifier(PaymentData storage self, uint8 _paymentModifier)
1142: 1142:         internal view returns (uint)
1143: 1143:     {
1144: 1144:         return getBounty(self).mul(_paymentModifier).div(100);
1145: 1145:     }
1146: 1146: 
1147: 1147:     
1148: 1148:     
1149: 1149:     
1150: 1150: 
1151: 1151:     
1152: 1152: 
1153: 1153: 
1154: 1154: 
1155: 1155:     function sendFee(PaymentData storage self) 
1156: 1156:         internal returns (bool)
1157: 1157:     {
1158: 1158:         uint feeAmount = self.feeOwed;
1159: 1159:         if (feeAmount > 0) {
1160: 1160:             
1161: 1161:             self.feeOwed = 0;
1162: 1162:             
1163: 1163:             return self.feeRecipient.send(feeAmount);
1164: 1164:         }
1165: 1165:         return true;
1166: 1166:     }
1167: 1167: 
1168: 1168:     
1169: 1169: 
1170: 1170: 
1171: 1171: 
1172: 1172:     function sendBounty(PaymentData storage self)
1173: 1173:         internal returns (bool)
1174: 1174:     {
1175: 1175:         uint bountyAmount = self.bountyOwed;
1176: 1176:         if (bountyAmount > 0) {
1177: 1177:             
1178: 1178:             self.bountyOwed = 0;
1179: 1179:             return self.bountyBenefactor.send(bountyAmount);
1180: 1180:         }
1181: 1181:         return true;
1182: 1182:     }
1183: 1183: 
1184: 1184:     
1185: 1185:     
1186: 1186:     
1187: 1187: 
1188: 1188:     
1189: 1189: 
1190: 1190: 
1191: 1191: 
1192: 1192: 
1193: 1193:     function computeEndowment(
1194: 1194:         uint _bounty,
1195: 1195:         uint _fee,
1196: 1196:         uint _callGas,
1197: 1197:         uint _callValue,
1198: 1198:         uint _gasPrice,
1199: 1199:         uint _gasOverhead
1200: 1200:     ) 
1201: 1201:         public pure returns (uint)
1202: 1202:     {
1203: 1203:         return _bounty
1204: 1204:             .add(_fee)
1205: 1205:             .add(_callGas.mul(_gasPrice))
1206: 1206:             .add(_gasOverhead.mul(_gasPrice))
1207: 1207:             .add(_callValue);
1208: 1208:     }
1209: 1209: 
1210: 1210:     
1211: 1211: 
1212: 1212: 
1213: 1213: 
1214: 1214: 
1215: 1215: 
1216: 1216: 
1217: 1217:     function validateEndowment(uint _endowment, uint _bounty, uint _fee, uint _callGas, uint _callValue, uint _gasPrice, uint _gasOverhead)
1218: 1218:         public pure returns (bool)
1219: 1219:     {
1220: 1220:         return _endowment >= computeEndowment(
1221: 1221:             _bounty,
1222: 1222:             _fee,
1223: 1223:             _callGas,
1224: 1224:             _callValue,
1225: 1225:             _gasPrice,
1226: 1226:             _gasOverhead
1227: 1227:         );
1228: 1228:     }
1229: 1229: }
1230: 1230: 
1231: 1231: 
1232: 1232: 
1233: 1233: 
1234: 1234: 
1235: 1235: library IterTools {
1236: 1236:     
1237: 1237: 
1238: 1238: 
1239: 1239: 
1240: 1240: 
1241: 1241:     function all(bool[6] _values) 
1242: 1242:         public pure returns (bool)
1243: 1243:     {
1244: 1244:         for (uint i = 0; i < _values.length; i++) {
1245: 1245:             if (!_values[i]) {
1246: 1246:                 return false;
1247: 1247:             }
1248: 1248:         }
1249: 1249:         return true;
1250: 1250:     }
1251: 1251: }
1252: 1252: 
1253: 1253: 
1254: 1254: 
1255: 1255: 
1256: 1256: 
1257: 1257: 
1258: 1258: 
1259: 1259: 
1260: 1260: 
1261: 1261: 
1262: 1262: 
1263: 1263: 
1264: 1264: 
1265: 1265: 
1266: 1266: 
1267: 1267: 
1268: 1268: 
1269: 1269: 
1270: 1270: 
1271: 1271: 
1272: 1272: 
1273: 1273: 
1274: 1274: 
1275: 1275: 
1276: 1276: 
1277: 1277: 
1278: 1278: 
1279: 1279: 