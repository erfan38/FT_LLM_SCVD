1: 1: pragma solidity ^0.4.21;
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
49: 49: contract FUNDS {
50: 50:     
51: 51: 
52: 52: 
53: 53:     
54: 54:     modifier onlyBagholders() {
55: 55:         require(myTokens() > 0);
56: 56:         _;
57: 57:     }
58: 58: 
59: 59:     
60: 60:     modifier onlyStronghands() {
61: 61:         require(myDividends(true) > 0);
62: 62:         _;
63: 63:     }
64: 64: 
65: 65:     modifier notContract() {
66: 66:       require (msg.sender == tx.origin);
67: 67:       _;
68: 68:     }
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
79: 79:     modifier onlyAdministrator(){
80: 80:         address _customerAddress = msg.sender;
81: 81:         require(administrators[_customerAddress]);
82: 82:         _;
83: 83:     }
84: 84:     
85: 85:     uint ACTIVATION_TIME = 1536258600;
86: 86: 
87: 87: 
88: 88:     
89: 89:     
90: 90:     
91: 91:     modifier antiEarlyWhale(uint256 _amountOfEthereum){
92: 92:         address _customerAddress = msg.sender;
93: 93:         
94: 94:         if (now >= ACTIVATION_TIME) {
95: 95:             onlyAmbassadors = false;
96: 96:         }
97: 97: 
98: 98:         
99: 99:         
100: 100:         if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
101: 101:             require(
102: 102:                 
103: 103:                 ambassadors_[_customerAddress] == true &&
104: 104: 
105: 105:                 
106: 106:                 (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
107: 107: 
108: 108:             );
109: 109: 
110: 110:             
111: 111:             ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
112: 112: 
113: 113:             
114: 114:             _;
115: 115:         } else {
116: 116:             
117: 117:             onlyAmbassadors = false;
118: 118:             _;
119: 119:         }
120: 120: 
121: 121:     }
122: 122: 
123: 123:     
124: 124: 
125: 125: 
126: 126:     event onTokenPurchase(
127: 127:         address indexed customerAddress,
128: 128:         uint256 incomingEthereum,
129: 129:         uint256 tokensMinted,
130: 130:         address indexed referredBy
131: 131:     );
132: 132: 
133: 133:     event onTokenSell(
134: 134:         address indexed customerAddress,
135: 135:         uint256 tokensBurned,
136: 136:         uint256 ethereumEarned
137: 137:     );
138: 138: 
139: 139:     event onReinvestment(
140: 140:         address indexed customerAddress,
141: 141:         uint256 ethereumReinvested,
142: 142:         uint256 tokensMinted
143: 143:     );
144: 144: 
145: 145:     event onWithdraw(
146: 146:         address indexed customerAddress,
147: 147:         uint256 ethereumWithdrawn
148: 148:     );
149: 149: 
150: 150:     
151: 151:     event Transfer(
152: 152:         address indexed from,
153: 153:         address indexed to,
154: 154:         uint256 tokens
155: 155:     );
156: 156: 
157: 157: 
158: 158:     
159: 159: 
160: 160: 
161: 161:     string public name = "FUNDS";
162: 162:     string public symbol = "FUNDS";
163: 163:     uint8 constant public decimals = 18;
164: 164:     uint8 constant internal dividendFee_ = 24; 
165: 165:     uint8 constant internal fundFee_ = 1; 
166: 166:     uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;
167: 167:     uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;
168: 168:     uint256 constant internal magnitude = 2**64;
169: 169: 
170: 170:     
171: 171:     address public giveEthFundAddress = 0x6BeF5C40723BaB057a5972f843454232EEE1Db50;
172: 172:     bool public finalizedEthFundAddress = false;
173: 173:     uint256 public totalEthFundRecieved; 
174: 174:     uint256 public totalEthFundCollected; 
175: 175: 
176: 176:     
177: 177:     uint256 public stakingRequirement = 25e18;
178: 178: 
179: 179:     
180: 180:     mapping(address => bool) internal ambassadors_;
181: 181:     uint256 constant internal ambassadorMaxPurchase_ = 0.5 ether;
182: 182:     uint256 constant internal ambassadorQuota_ = 2.0 ether;
183: 183: 
184: 184: 
185: 185: 
186: 186:    
187: 187: 
188: 188: 
189: 189:     
190: 190:     mapping(address => uint256) internal tokenBalanceLedger_;
191: 191:     mapping(address => uint256) internal referralBalance_;
192: 192:     mapping(address => int256) internal payoutsTo_;
193: 193:     mapping(address => uint256) internal ambassadorAccumulatedQuota_;
194: 194:     uint256 internal tokenSupply_ = 0;
195: 195:     uint256 internal profitPerShare_;
196: 196: 
197: 197:     
198: 198:     mapping(address => bool) public administrators;
199: 199: 
200: 200:     
201: 201:     bool public onlyAmbassadors = true;
202: 202: 
203: 203:     
204: 204:     mapping(address => bool) public canAcceptTokens_; 
205: 205: 
206: 206:     mapping(address => address) public stickyRef;
207: 207: 
208: 208:     
209: 209: 
210: 210: 
211: 211:     
212: 212: 
213: 213: 
214: 214:     constructor()
215: 215:         public
216: 216:     {
217: 217:         
218: 218:         administrators[0x8c691931c6c4ECD92ECc26F9706FAaF4aebE137D] = true;
219: 219: 
220: 220:         
221: 221:         ambassadors_[0x40a90c18Ec757a355D3dD96c8ef91762a335f524] = true;
222: 222:         
223: 223:         ambassadors_[0x5632CA98e5788edDB2397757Aa82d1Ed6171e5aD] = true;
224: 224:         
225: 225:         ambassadors_[0x8c691931c6c4ECD92ECc26F9706FAaF4aebE137D] = true;
226: 226:         
227: 227:         ambassadors_[0x53943B4b05Af138dD61FF957835B288d30cB8F0d] = true;
228: 228:     }
229: 229: 
230: 230: 
231: 231:     
232: 232: 
233: 233: 
234: 234:     function buy(address _referredBy)
235: 235:         public
236: 236:         payable
237: 237:         returns(uint256)
238: 238:     {
239: 239:         
240: 240:         require(tx.gasprice <= 0.05 szabo);
241: 241:         purchaseTokens(msg.value, _referredBy);
242: 242:     }
243: 243: 
244: 244:     
245: 245: 
246: 246: 
247: 247: 
248: 248:     function()
249: 249:         payable
250: 250:         public
251: 251:     {
252: 252:         
253: 253:         require(tx.gasprice <= 0.05 szabo);
254: 254:         purchaseTokens(msg.value, 0x0);
255: 255:     }
256: 256: 
257: 257:     function updateFundAddress(address _newAddress)
258: 258:         onlyAdministrator()
259: 259:         public
260: 260:     {
261: 261:         require(finalizedEthFundAddress == false);
262: 262:         giveEthFundAddress = _newAddress;
263: 263:     }
264: 264: 
265: 265:     function finalizeFundAddress(address _finalAddress)
266: 266:         onlyAdministrator()
267: 267:         public
268: 268:     {
269: 269:         require(finalizedEthFundAddress == false);
270: 270:         giveEthFundAddress = _finalAddress;
271: 271:         finalizedEthFundAddress = true;
272: 272:     }
273: 273: 
274: 274:     
275: 275: 
276: 276: 
277: 277: 
278: 278:     function payFund() payable public {
279: 279:         uint256 ethToPay = SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
280: 280:         require(ethToPay > 0);
281: 281:         totalEthFundRecieved = SafeMath.add(totalEthFundRecieved, ethToPay);
282: 282:         if(!giveEthFundAddress.call.value(ethToPay)()) {
283: 283:             revert();
284: 284:         }
285: 285:     }
286: 286: 
287: 287:     
288: 288: 
289: 289: 
290: 290:     function reinvest()
291: 291:         onlyStronghands()
292: 292:         public
293: 293:     {
294: 294:         
295: 295:         uint256 _dividends = myDividends(false); 
296: 296: 
297: 297:         
298: 298:         address _customerAddress = msg.sender;
299: 299:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
300: 300: 
301: 301:         
302: 302:         _dividends += referralBalance_[_customerAddress];
303: 303:         referralBalance_[_customerAddress] = 0;
304: 304: 
305: 305:         
306: 306:         uint256 _tokens = purchaseTokens(_dividends, 0x0);
307: 307: 
308: 308:         
309: 309:         emit onReinvestment(_customerAddress, _dividends, _tokens);
310: 310:     }
311: 311: 
312: 312:     
313: 313: 
314: 314: 
315: 315:     function exit()
316: 316:         public
317: 317:     {
318: 318:         
319: 319:         address _customerAddress = msg.sender;
320: 320:         uint256 _tokens = tokenBalanceLedger_[_customerAddress];
321: 321:         if(_tokens > 0) sell(_tokens);
322: 322: 
323: 323:         
324: 324:         withdraw();
325: 325:     }
326: 326: 
327: 327:     
328: 328: 
329: 329: 
330: 330:     function withdraw()
331: 331:         onlyStronghands()
332: 332:         public
333: 333:     {
334: 334:         
335: 335:         address _customerAddress = msg.sender;
336: 336:         uint256 _dividends = myDividends(false); 
337: 337: 
338: 338:         
339: 339:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
340: 340: 
341: 341:         
342: 342:         _dividends += referralBalance_[_customerAddress];
343: 343:         referralBalance_[_customerAddress] = 0;
344: 344: 
345: 345:         
346: 346:         _customerAddress.transfer(_dividends);
347: 347: 
348: 348:         
349: 349:         emit onWithdraw(_customerAddress, _dividends);
350: 350:     }
351: 351: 
352: 352:     
353: 353: 
354: 354: 
355: 355:     function sell(uint256 _amountOfTokens)
356: 356:         onlyBagholders()
357: 357:         public
358: 358:     {
359: 359:         
360: 360:         address _customerAddress = msg.sender;
361: 361:         
362: 362:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
363: 363:         uint256 _tokens = _amountOfTokens;
364: 364:         uint256 _ethereum = tokensToEthereum_(_tokens);
365: 365: 
366: 366:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
367: 367:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
368: 368:         uint256 _refPayout = _dividends / 3;
369: 369:         _dividends = SafeMath.sub(_dividends, _refPayout);
370: 370:         (_dividends,) = handleRef(stickyRef[msg.sender], _refPayout, _dividends, 0);
371: 371: 
372: 372:         
373: 373:         uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
374: 374: 
375: 375:         
376: 376:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
377: 377: 
378: 378:         
379: 379:         tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
380: 380:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
381: 381: 
382: 382:         
383: 383:         int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
384: 384:         payoutsTo_[_customerAddress] -= _updatedPayouts;
385: 385: 
386: 386:         
387: 387:         if (tokenSupply_ > 0) {
388: 388:             
389: 389:             profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
390: 390:         }
391: 391: 
392: 392:         
393: 393:         emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
394: 394:     }
395: 395: 
396: 396: 
397: 397:     
398: 398: 
399: 399: 
400: 400: 
401: 401:     function transfer(address _toAddress, uint256 _amountOfTokens)
402: 402:         onlyBagholders()
403: 403:         public
404: 404:         returns(bool)
405: 405:     {
406: 406:         
407: 407:         address _customerAddress = msg.sender;
408: 408: 
409: 409:         
410: 410:         
411: 411:         
412: 412:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
413: 413: 
414: 414:         
415: 415:         if(myDividends(true) > 0) withdraw();
416: 416: 
417: 417:         
418: 418:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
419: 419:         tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
420: 420: 
421: 421:         
422: 422:         payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
423: 423:         payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);
424: 424: 
425: 425: 
426: 426:         
427: 427:         emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
428: 428: 
429: 429:         
430: 430:         return true;
431: 431:     }
432: 432: 
433: 433:     
434: 434: 
435: 435: 
436: 436: 
437: 437: 
438: 438: 
439: 439: 
440: 440: 
441: 441:     function transferAndCall(address _to, uint256 _value, bytes _data) external returns (bool) {
442: 442:       require(_to != address(0));
443: 443:       require(canAcceptTokens_[_to] == true); 
444: 444:       require(transfer(_to, _value)); 
445: 445: 
446: 446:       if (isContract(_to)) {
447: 447:         AcceptsFUNDS receiver = AcceptsFUNDS(_to);
448: 448:         require(receiver.tokenFallback(msg.sender, _value, _data));
449: 449:       }
450: 450: 
451: 451:       return true;
452: 452:     }
453: 453: 
454: 454:     
455: 455: 
456: 456: 
457: 457: 
458: 458:      function isContract(address _addr) private constant returns (bool is_contract) {
459: 459:        
460: 460:        uint length;
461: 461:        assembly { length := extcodesize(_addr) }
462: 462:        return length > 0;
463: 463:      }
464: 464: 
465: 465:     
466: 466:     
467: 467: 
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
479: 479:     function setAdministrator(address _identifier, bool _status)
480: 480:         onlyAdministrator()
481: 481:         public
482: 482:     {
483: 483:         administrators[_identifier] = _status;
484: 484:     }
485: 485: 
486: 486:     
487: 487: 
488: 488: 
489: 489:     function setStakingRequirement(uint256 _amountOfTokens)
490: 490:         onlyAdministrator()
491: 491:         public
492: 492:     {
493: 493:         stakingRequirement = _amountOfTokens;
494: 494:     }
495: 495: 
496: 496:     
497: 497: 
498: 498: 
499: 499:     function setCanAcceptTokens(address _address, bool _value)
500: 500:       onlyAdministrator()
501: 501:       public
502: 502:     {
503: 503:       canAcceptTokens_[_address] = _value;
504: 504:     }
505: 505: 
506: 506:     
507: 507: 
508: 508: 
509: 509:     function setName(string _name)
510: 510:         onlyAdministrator()
511: 511:         public
512: 512:     {
513: 513:         name = _name;
514: 514:     }
515: 515: 
516: 516:     
517: 517: 
518: 518: 
519: 519:     function setSymbol(string _symbol)
520: 520:         onlyAdministrator()
521: 521:         public
522: 522:     {
523: 523:         symbol = _symbol;
524: 524:     }
525: 525: 
526: 526: 
527: 527:     
528: 528:     
529: 529: 
530: 530: 
531: 531: 
532: 532:     function totalEthereumBalance()
533: 533:         public
534: 534:         view
535: 535:         returns(uint)
536: 536:     {
537: 537:         return address(this).balance;
538: 538:     }
539: 539: 
540: 540:     
541: 541: 
542: 542: 
543: 543:     function totalSupply()
544: 544:         public
545: 545:         view
546: 546:         returns(uint256)
547: 547:     {
548: 548:         return tokenSupply_;
549: 549:     }
550: 550: 
551: 551:     
552: 552: 
553: 553: 
554: 554:     function myTokens()
555: 555:         public
556: 556:         view
557: 557:         returns(uint256)
558: 558:     {
559: 559:         address _customerAddress = msg.sender;
560: 560:         return balanceOf(_customerAddress);
561: 561:     }
562: 562: 
563: 563:     
564: 564: 
565: 565: 
566: 566: 
567: 567: 
568: 568: 
569: 569:     function myDividends(bool _includeReferralBonus)
570: 570:         public
571: 571:         view
572: 572:         returns(uint256)
573: 573:     {
574: 574:         address _customerAddress = msg.sender;
575: 575:         return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
576: 576:     }
577: 577: 
578: 578:     
579: 579: 
580: 580: 
581: 581:     function balanceOf(address _customerAddress)
582: 582:         view
583: 583:         public
584: 584:         returns(uint256)
585: 585:     {
586: 586:         return tokenBalanceLedger_[_customerAddress];
587: 587:     }
588: 588: 
589: 589:     
590: 590: 
591: 591: 
592: 592:     function dividendsOf(address _customerAddress)
593: 593:         view
594: 594:         public
595: 595:         returns(uint256)
596: 596:     {
597: 597:         return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
598: 598:     }
599: 599: 
600: 600:     
601: 601: 
602: 602: 
603: 603:     function sellPrice()
604: 604:         public
605: 605:         view
606: 606:         returns(uint256)
607: 607:     {
608: 608:         
609: 609:         if(tokenSupply_ == 0){
610: 610:             return tokenPriceInitial_ - tokenPriceIncremental_;
611: 611:         } else {
612: 612:             uint256 _ethereum = tokensToEthereum_(1e18);
613: 613:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
614: 614:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
615: 615:             uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
616: 616:             return _taxedEthereum;
617: 617:         }
618: 618:     }
619: 619: 
620: 620:     
621: 621: 
622: 622: 
623: 623:     function buyPrice()
624: 624:         public
625: 625:         view
626: 626:         returns(uint256)
627: 627:     {
628: 628:         
629: 629:         if(tokenSupply_ == 0){
630: 630:             return tokenPriceInitial_ + tokenPriceIncremental_;
631: 631:         } else {
632: 632:             uint256 _ethereum = tokensToEthereum_(1e18);
633: 633:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
634: 634:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
635: 635:             uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _fundPayout);
636: 636:             return _taxedEthereum;
637: 637:         }
638: 638:     }
639: 639: 
640: 640:     
641: 641: 
642: 642: 
643: 643:     function calculateTokensReceived(uint256 _ethereumToSpend)
644: 644:         public
645: 645:         view
646: 646:         returns(uint256)
647: 647:     {
648: 648:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
649: 649:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, fundFee_), 100);
650: 650:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _fundPayout);
651: 651:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
652: 652:         return _amountOfTokens;
653: 653:     }
654: 654: 
655: 655:     
656: 656: 
657: 657: 
658: 658:     function calculateEthereumReceived(uint256 _tokensToSell)
659: 659:         public
660: 660:         view
661: 661:         returns(uint256)
662: 662:     {
663: 663:         require(_tokensToSell <= tokenSupply_);
664: 664:         uint256 _ethereum = tokensToEthereum_(_tokensToSell);
665: 665:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
666: 666:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
667: 667:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
668: 668:         return _taxedEthereum;
669: 669:     }
670: 670: 
671: 671:     
672: 672: 
673: 673: 
674: 674:     function etherToSendFund()
675: 675:         public
676: 676:         view
677: 677:         returns(uint256) {
678: 678:         return SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
679: 679:     }
680: 680: 
681: 681: 
682: 682:     
683: 683: 
684: 684: 
685: 685: 
686: 686:     
687: 687:     function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
688: 688:       notContract()
689: 689:       internal
690: 690:       returns(uint256) {
691: 691: 
692: 692:       uint256 purchaseEthereum = _incomingEthereum;
693: 693:       uint256 excess;
694: 694:       if(purchaseEthereum > 2.5 ether) { 
695: 695:           if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 100 ether) { 
696: 696:               purchaseEthereum = 2.5 ether;
697: 697:               excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
698: 698:           }
699: 699:       }
700: 700: 
701: 701:       purchaseTokens(purchaseEthereum, _referredBy);
702: 702: 
703: 703:       if (excess > 0) {
704: 704:         msg.sender.transfer(excess);
705: 705:       }
706: 706:     }
707: 707: 
708: 708:     function handleRef(address _ref, uint _referralBonus, uint _currentDividends, uint _currentFee) internal returns (uint, uint){
709: 709:         uint _dividends = _currentDividends;
710: 710:         uint _fee = _currentFee;
711: 711:         address _referredBy = stickyRef[msg.sender];
712: 712:         if (_referredBy == address(0x0)){
713: 713:             _referredBy = _ref;
714: 714:         }
715: 715:         
716: 716:         if(
717: 717:             
718: 718:             _referredBy != 0x0000000000000000000000000000000000000000 &&
719: 719: 
720: 720:             
721: 721:             _referredBy != msg.sender &&
722: 722: 
723: 723:             
724: 724:             
725: 725:             tokenBalanceLedger_[_referredBy] >= stakingRequirement
726: 726:         ){
727: 727:             
728: 728:             if (stickyRef[msg.sender] == address(0x0)){
729: 729:                 stickyRef[msg.sender] = _referredBy;
730: 730:             }
731: 731:             referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus/2);
732: 732:             address currentRef = stickyRef[_referredBy];
733: 733:             if (currentRef != address(0x0) && tokenBalanceLedger_[currentRef] >= stakingRequirement){
734: 734:                 referralBalance_[currentRef] = SafeMath.add(referralBalance_[currentRef], (_referralBonus/10)*3);
735: 735:                 currentRef = stickyRef[currentRef];
736: 736:                 if (currentRef != address(0x0) && tokenBalanceLedger_[currentRef] >= stakingRequirement){
737: 737:                     referralBalance_[currentRef] = SafeMath.add(referralBalance_[currentRef], (_referralBonus/10)*2);
738: 738:                 }
739: 739:                 else{
740: 740:                     _dividends = SafeMath.add(_dividends, _referralBonus - _referralBonus/2 - (_referralBonus/10)*3);
741: 741:                     _fee = _dividends * magnitude;
742: 742:                 }
743: 743:             }
744: 744:             else{
745: 745:                 _dividends = SafeMath.add(_dividends, _referralBonus - _referralBonus/2);
746: 746:                 _fee = _dividends * magnitude;
747: 747:             }
748: 748:             
749: 749:             
750: 750:         } else {
751: 751:             
752: 752:             
753: 753:             _dividends = SafeMath.add(_dividends, _referralBonus);
754: 754:             _fee = _dividends * magnitude;
755: 755:         }
756: 756:         return (_dividends, _fee);
757: 757:     }
758: 758: 
759: 759: 
760: 760:     function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
761: 761:         antiEarlyWhale(_incomingEthereum)
762: 762:         internal
763: 763:         returns(uint256)
764: 764:     {
765: 765:         
766: 766:         uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
767: 767:         uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
768: 768:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, fundFee_), 100);
769: 769:         uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
770: 770:         uint256 _fee;
771: 771:         (_dividends, _fee) = handleRef(_referredBy, _referralBonus, _dividends, _fee);
772: 772:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _dividends), _fundPayout);
773: 773:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
774: 774: 
775: 775:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
776: 776: 
777: 777: 
778: 778:         
779: 779:         
780: 780:         
781: 781:         
782: 782:         require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
783: 783: 
784: 784: 
785: 785: 
786: 786:         
787: 787:         if(tokenSupply_ > 0){
788: 788:  
789: 789:             
790: 790:             tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
791: 791: 
792: 792:             
793: 793:             profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
794: 794: 
795: 795:             
796: 796:             _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
797: 797: 
798: 798:         } else {
799: 799:             
800: 800:             tokenSupply_ = _amountOfTokens;
801: 801:         }
802: 802: 
803: 803:         
804: 804:         tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);
805: 805: 
806: 806:         
807: 807:         
808: 808:         int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
809: 809:         payoutsTo_[msg.sender] += _updatedPayouts;
810: 810: 
811: 811:         
812: 812:         emit onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy);
813: 813: 
814: 814:         return _amountOfTokens;
815: 815:     }
816: 816: 
817: 817:     
818: 818: 
819: 819: 
820: 820: 
821: 821: 
822: 822:     function ethereumToTokens_(uint256 _ethereum)
823: 823:         internal
824: 824:         view
825: 825:         returns(uint256)
826: 826:     {
827: 827:         uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
828: 828:         uint256 _tokensReceived =
829: 829:          (
830: 830:             (
831: 831:                 
832: 832:                 SafeMath.sub(
833: 833:                     (sqrt
834: 834:                         (
835: 835:                             (_tokenPriceInitial**2)
836: 836:                             +
837: 837:                             (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
838: 838:                             +
839: 839:                             (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
840: 840:                             +
841: 841:                             (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
842: 842:                         )
843: 843:                     ), _tokenPriceInitial
844: 844:                 )
845: 845:             )/(tokenPriceIncremental_)
846: 846:         )-(tokenSupply_)
847: 847:         ;
848: 848: 
849: 849:         return _tokensReceived;
850: 850:     }
851: 851: 
852: 852:     
853: 853: 
854: 854: 
855: 855: 
856: 856: 
857: 857:      function tokensToEthereum_(uint256 _tokens)
858: 858:         internal
859: 859:         view
860: 860:         returns(uint256)
861: 861:     {
862: 862: 
863: 863:         uint256 tokens_ = (_tokens + 1e18);
864: 864:         uint256 _tokenSupply = (tokenSupply_ + 1e18);
865: 865:         uint256 _etherReceived =
866: 866:         (
867: 867:             
868: 868:             SafeMath.sub(
869: 869:                 (
870: 870:                     (
871: 871:                         (
872: 872:                             tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
873: 873:                         )-tokenPriceIncremental_
874: 874:                     )*(tokens_ - 1e18)
875: 875:                 ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
876: 876:             )
877: 877:         /1e18);
878: 878:         return _etherReceived;
879: 879:     }
880: 880: 
881: 881: 
882: 882:     
883: 883:     
884: 884:     function sqrt(uint x) internal pure returns (uint y) {
885: 885:         uint z = (x + 1) / 2;
886: 886:         y = x;
887: 887:         while (z < y) {
888: 888:             y = z;
889: 889:             z = (x / z + z) / 2;
890: 890:         }
891: 891:     }
892: 892: }
893: 893: 
894: 894: 
895: 895: 
896: 896: 
897: 897: 
898: 898: library SafeMath {
899: 899: 
900: 900:     
901: 901: 
902: 902: 
903: 903:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
904: 904:         if (a == 0) {
905: 905:             return 0;
906: 906:         }
907: 907:         uint256 c = a * b;
908: 908:         assert(c / a == b);
909: 909:         return c;
910: 910:     }
911: 911: 
912: 912:     
913: 913: 
914: 914: 
915: 915:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
916: 916:         
917: 917:         uint256 c = a / b;
918: 918:         
919: 919:         return c;
920: 920:     }
921: 921: 
922: 922:     
923: 923: 
924: 924: 
925: 925:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
926: 926:         assert(b <= a);
927: 927:         return a - b;
928: 928:     }
929: 929: 
930: 930:     
931: 931: 
932: 932: 
933: 933:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
934: 934:         uint256 c = a + b;
935: 935:         assert(c >= a);
936: 936:         return c;
937: 937:     }
938: 938: }