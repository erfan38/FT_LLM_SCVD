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
45: 45: contract MOB {
46: 46:     
47: 47: 
48: 48: 
49: 49:     
50: 50:     modifier onlyBagholders() {
51: 51:         require(myTokens() > 0);
52: 52:         _;
53: 53:     }
54: 54: 
55: 55:     
56: 56:     modifier onlyStronghands() {
57: 57:         require(myDividends(true) > 0);
58: 58:         _;
59: 59:     }
60: 60: 
61: 61:     modifier notContract() {
62: 62:       require (msg.sender == tx.origin);
63: 63:       _;
64: 64:     }
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
75: 75:     modifier onlyAdministrator(){
76: 76:         address _customerAddress = msg.sender;
77: 77:         require(administrators[_customerAddress]);
78: 78:         _;
79: 79:     }
80: 80:     
81: 81:     uint ACTIVATION_TIME = 1537491600;
82: 82: 
83: 83: 
84: 84:     
85: 85:     
86: 86:     
87: 87:     modifier antiEarlyWhale(uint256 _amountOfEthereum){
88: 88:         address _customerAddress = msg.sender;
89: 89:         
90: 90:         if (now >= ACTIVATION_TIME) {
91: 91:             onlyAmbassadors = false;
92: 92:         }
93: 93: 
94: 94:         
95: 95:         
96: 96:         if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
97: 97:             require(
98: 98:                 
99: 99:                 ambassadors_[_customerAddress] == true &&
100: 100: 
101: 101:                 
102: 102:                 (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
103: 103: 
104: 104:             );
105: 105: 
106: 106:             
107: 107:             ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
108: 108: 
109: 109:             
110: 110:             _;
111: 111:         } else {
112: 112:             
113: 113:             onlyAmbassadors = false;
114: 114:             _;
115: 115:         }
116: 116: 
117: 117:     }
118: 118: 
119: 119:     
120: 120: 
121: 121: 
122: 122:     event onTokenPurchase(
123: 123:         address indexed customerAddress,
124: 124:         uint256 incomingEthereum,
125: 125:         uint256 tokensMinted,
126: 126:         address indexed referredBy
127: 127:     );
128: 128: 
129: 129:     event onTokenSell(
130: 130:         address indexed customerAddress,
131: 131:         uint256 tokensBurned,
132: 132:         uint256 ethereumEarned
133: 133:     );
134: 134: 
135: 135:     event onReinvestment(
136: 136:         address indexed customerAddress,
137: 137:         uint256 ethereumReinvested,
138: 138:         uint256 tokensMinted
139: 139:     );
140: 140: 
141: 141:     event onWithdraw(
142: 142:         address indexed customerAddress,
143: 143:         uint256 ethereumWithdrawn
144: 144:     );
145: 145: 
146: 146:     
147: 147:     event Transfer(
148: 148:         address indexed from,
149: 149:         address indexed to,
150: 150:         uint256 tokens
151: 151:     );
152: 152: 
153: 153: 
154: 154:     
155: 155: 
156: 156: 
157: 157:     string public name = "MOB";
158: 158:     string public symbol = "MOB";
159: 159:     uint8 constant public decimals = 18;
160: 160:     uint8 constant internal dividendFee_ = 24; 
161: 161:     uint8 constant internal fundFee_ = 1; 
162: 162: 	uint256 constant internal tokenPriceInitial_ = 0.0000000001 ether;
163: 163: 	uint256 constant internal tokenPriceIncremental_ = 0.00000000001 ether;
164: 164:     uint256 constant internal magnitude = 2**64;
165: 165: 
166: 166:     
167: 167:     address public giveEthFundAddress = 0x16837e8f7d7e88E2E5B5392bD637122F2e21594A;
168: 168:     bool public finalizedEthFundAddress = false;
169: 169:     uint256 public totalEthFundRecieved; 
170: 170:     uint256 public totalEthFundCollected; 
171: 171: 
172: 172:     
173: 173:     uint256 public stakingRequirement = 25e18;
174: 174: 
175: 175:     
176: 176:     mapping(address => bool) internal ambassadors_;
177: 177:     uint256 constant internal ambassadorMaxPurchase_ = 1.0 ether;
178: 178:     uint256 constant internal ambassadorQuota_ = 5.0 ether;
179: 179: 
180: 180: 
181: 181: 
182: 182:    
183: 183: 
184: 184: 
185: 185:     
186: 186:     mapping(address => uint256) internal tokenBalanceLedger_;
187: 187:     mapping(address => uint256) internal referralBalance_;
188: 188:     mapping(address => int256) internal payoutsTo_;
189: 189:     mapping(address => uint256) internal ambassadorAccumulatedQuota_;
190: 190:     uint256 internal tokenSupply_ = 0;
191: 191:     uint256 internal profitPerShare_;
192: 192: 
193: 193:     
194: 194:     mapping(address => bool) public administrators;
195: 195: 
196: 196:     
197: 197:     bool public onlyAmbassadors = true;
198: 198: 
199: 199:     
200: 200:     mapping(address => bool) public canAcceptTokens_; 
201: 201: 
202: 202:     mapping(address => address) public stickyRef;
203: 203: 
204: 204:     
205: 205: 
206: 206: 
207: 207:     
208: 208: 
209: 209: 
210: 210:     constructor()
211: 211:         public
212: 212:     {
213: 213:         
214: 214:         administrators[0xb2A13A5AE7922325290ce4eAf5029Ef18045Ee2B] = true;
215: 215: 
216: 216: 		
217: 217:         ambassadors_[0xb2A13A5AE7922325290ce4eAf5029Ef18045Ee2B] = true;
218: 218:         
219: 219:         ambassadors_[0x41FE3738B503cBaFD01C1Fd8DD66b7fE6Ec11b01] = true;
220: 220:         
221: 221:         ambassadors_[0xa37172d3803cd1366608dfea5efeec767a880a8b] = true;
222: 222:         
223: 223:         ambassadors_[0xea1e475a57Dd5417238f437Df3C654381E946Db1] = true;
224: 224:         
225: 225:         ambassadors_[0xd1692f1c6b50d299993363be1c869e3e64842732] = true;
226: 226:     }
227: 227: 
228: 228: 
229: 229:     
230: 230: 
231: 231: 
232: 232:     function buy(address _referredBy)
233: 233:         public
234: 234:         payable
235: 235:         returns(uint256)
236: 236:     {
237: 237:         
238: 238:         require(tx.gasprice <= 0.25 szabo);
239: 239:         purchaseTokens(msg.value, _referredBy);
240: 240:     }
241: 241: 
242: 242:     
243: 243: 
244: 244: 
245: 245: 
246: 246:     function()
247: 247:         payable
248: 248:         public
249: 249:     {
250: 250:         
251: 251:         require(tx.gasprice <= 0.25 szabo);
252: 252:         purchaseTokens(msg.value, 0x0);
253: 253:     }
254: 254: 
255: 255:     function updateFundAddress(address _newAddress)
256: 256:         onlyAdministrator()
257: 257:         public
258: 258:     {
259: 259:         require(finalizedEthFundAddress == false);
260: 260:         giveEthFundAddress = _newAddress;
261: 261:     }
262: 262: 
263: 263:     function finalizeFundAddress(address _finalAddress)
264: 264:         onlyAdministrator()
265: 265:         public
266: 266:     {
267: 267:         require(finalizedEthFundAddress == false);
268: 268:         giveEthFundAddress = _finalAddress;
269: 269:         finalizedEthFundAddress = true;
270: 270:     }
271: 271: 
272: 272:     
273: 273: 
274: 274: 
275: 275: 
276: 276:     function payFund() payable public {
277: 277:         uint256 ethToPay = SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
278: 278:         require(ethToPay > 0);
279: 279:         totalEthFundRecieved = SafeMath.add(totalEthFundRecieved, ethToPay);
280: 280:         if(!giveEthFundAddress.call.value(ethToPay)()) {
281: 281:             revert();
282: 282:         }
283: 283:     }
284: 284: 
285: 285:     
286: 286: 
287: 287: 
288: 288:     function reinvest()
289: 289:         onlyStronghands()
290: 290:         public
291: 291:     {
292: 292:         
293: 293:         uint256 _dividends = myDividends(false); 
294: 294: 
295: 295:         
296: 296:         address _customerAddress = msg.sender;
297: 297:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
298: 298: 
299: 299:         
300: 300:         _dividends += referralBalance_[_customerAddress];
301: 301:         referralBalance_[_customerAddress] = 0;
302: 302: 
303: 303:         
304: 304:         uint256 _tokens = purchaseTokens(_dividends, 0x0);
305: 305: 
306: 306:         
307: 307:         emit onReinvestment(_customerAddress, _dividends, _tokens);
308: 308:     }
309: 309: 
310: 310:     
311: 311: 
312: 312: 
313: 313:     function exit()
314: 314:         public
315: 315:     {
316: 316:         
317: 317:         address _customerAddress = msg.sender;
318: 318:         uint256 _tokens = tokenBalanceLedger_[_customerAddress];
319: 319:         if(_tokens > 0) sell(_tokens);
320: 320: 
321: 321:         
322: 322:         withdraw();
323: 323:     }
324: 324: 
325: 325:     
326: 326: 
327: 327: 
328: 328:     function withdraw()
329: 329:         onlyStronghands()
330: 330:         public
331: 331:     {
332: 332:         
333: 333:         address _customerAddress = msg.sender;
334: 334:         uint256 _dividends = myDividends(false); 
335: 335: 
336: 336:         
337: 337:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
338: 338: 
339: 339:         
340: 340:         _dividends += referralBalance_[_customerAddress];
341: 341:         referralBalance_[_customerAddress] = 0;
342: 342: 
343: 343:         
344: 344:         _customerAddress.transfer(_dividends);
345: 345: 
346: 346:         
347: 347:         emit onWithdraw(_customerAddress, _dividends);
348: 348:     }
349: 349: 
350: 350:     
351: 351: 
352: 352: 
353: 353:     function sell(uint256 _amountOfTokens)
354: 354:         onlyBagholders()
355: 355:         public
356: 356:     {
357: 357:         
358: 358:         address _customerAddress = msg.sender;
359: 359:         
360: 360:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
361: 361:         uint256 _tokens = _amountOfTokens;
362: 362:         uint256 _ethereum = tokensToEthereum_(_tokens);
363: 363: 
364: 364:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
365: 365:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
366: 366:         uint256 _refPayout = _dividends / 3;
367: 367:         _dividends = SafeMath.sub(_dividends, _refPayout);
368: 368:         (_dividends,) = handleRef(stickyRef[msg.sender], _refPayout, _dividends, 0);
369: 369: 
370: 370:         
371: 371:         uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
372: 372: 
373: 373:         
374: 374:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
375: 375: 
376: 376:         
377: 377:         tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
378: 378:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
379: 379: 
380: 380:         
381: 381:         int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
382: 382:         payoutsTo_[_customerAddress] -= _updatedPayouts;
383: 383: 
384: 384:         
385: 385:         if (tokenSupply_ > 0) {
386: 386:             
387: 387:             profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
388: 388:         }
389: 389: 
390: 390:         
391: 391:         emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
392: 392:     }
393: 393: 
394: 394: 
395: 395:     
396: 396: 
397: 397: 
398: 398: 
399: 399:     function transfer(address _toAddress, uint256 _amountOfTokens)
400: 400:         onlyBagholders()
401: 401:         public
402: 402:         returns(bool)
403: 403:     {
404: 404:         
405: 405:         address _customerAddress = msg.sender;
406: 406: 
407: 407:         
408: 408:         
409: 409:         
410: 410:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
411: 411: 
412: 412:         
413: 413:         if(myDividends(true) > 0) withdraw();
414: 414: 
415: 415:         
416: 416:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
417: 417:         tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
418: 418: 
419: 419:         
420: 420:         payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
421: 421:         payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);
422: 422: 
423: 423: 
424: 424:         
425: 425:         emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
426: 426: 
427: 427:         
428: 428:         return true;
429: 429:     }
430: 430: 
431: 431:     
432: 432: 
433: 433: 
434: 434: 
435: 435: 
436: 436: 
437: 437: 
438: 438: 
439: 439:     function transferAndCall(address _to, uint256 _value, bytes _data) external returns (bool) {
440: 440:       require(_to != address(0));
441: 441:       require(canAcceptTokens_[_to] == true); 
442: 442:       require(transfer(_to, _value)); 
443: 443: 
444: 444:       if (isContract(_to)) {
445: 445:         AcceptsMOB receiver = AcceptsMOB(_to);
446: 446:         require(receiver.tokenFallback(msg.sender, _value, _data));
447: 447:       }
448: 448: 
449: 449:       return true;
450: 450:     }
451: 451: 
452: 452:     
453: 453: 
454: 454: 
455: 455: 
456: 456:      function isContract(address _addr) private constant returns (bool is_contract) {
457: 457:        
458: 458:        uint length;
459: 459:        assembly { length := extcodesize(_addr) }
460: 460:        return length > 0;
461: 461:      }
462: 462: 
463: 463:     
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
477: 477:     function setAdministrator(address _identifier, bool _status)
478: 478:         onlyAdministrator()
479: 479:         public
480: 480:     {
481: 481:         administrators[_identifier] = _status;
482: 482:     }
483: 483: 
484: 484:     
485: 485: 
486: 486: 
487: 487:     function setStakingRequirement(uint256 _amountOfTokens)
488: 488:         onlyAdministrator()
489: 489:         public
490: 490:     {
491: 491:         stakingRequirement = _amountOfTokens;
492: 492:     }
493: 493: 
494: 494:     
495: 495: 
496: 496: 
497: 497:     function setCanAcceptTokens(address _address, bool _value)
498: 498:       onlyAdministrator()
499: 499:       public
500: 500:     {
501: 501:       canAcceptTokens_[_address] = _value;
502: 502:     }
503: 503: 
504: 504:     
505: 505: 
506: 506: 
507: 507:     function setName(string _name)
508: 508:         onlyAdministrator()
509: 509:         public
510: 510:     {
511: 511:         name = _name;
512: 512:     }
513: 513: 
514: 514:     
515: 515: 
516: 516: 
517: 517:     function setSymbol(string _symbol)
518: 518:         onlyAdministrator()
519: 519:         public
520: 520:     {
521: 521:         symbol = _symbol;
522: 522:     }
523: 523: 
524: 524: 
525: 525:     
526: 526:     
527: 527: 
528: 528: 
529: 529: 
530: 530:     function totalEthereumBalance()
531: 531:         public
532: 532:         view
533: 533:         returns(uint)
534: 534:     {
535: 535:         return address(this).balance;
536: 536:     }
537: 537: 
538: 538:     
539: 539: 
540: 540: 
541: 541:     function totalSupply()
542: 542:         public
543: 543:         view
544: 544:         returns(uint256)
545: 545:     {
546: 546:         return tokenSupply_;
547: 547:     }
548: 548: 
549: 549:     
550: 550: 
551: 551: 
552: 552:     function myTokens()
553: 553:         public
554: 554:         view
555: 555:         returns(uint256)
556: 556:     {
557: 557:         address _customerAddress = msg.sender;
558: 558:         return balanceOf(_customerAddress);
559: 559:     }
560: 560: 
561: 561:     
562: 562: 
563: 563: 
564: 564: 
565: 565: 
566: 566: 
567: 567:     function myDividends(bool _includeReferralBonus)
568: 568:         public
569: 569:         view
570: 570:         returns(uint256)
571: 571:     {
572: 572:         address _customerAddress = msg.sender;
573: 573:         return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
574: 574:     }
575: 575: 
576: 576:     
577: 577: 
578: 578: 
579: 579:     function balanceOf(address _customerAddress)
580: 580:         view
581: 581:         public
582: 582:         returns(uint256)
583: 583:     {
584: 584:         return tokenBalanceLedger_[_customerAddress];
585: 585:     }
586: 586: 
587: 587:     
588: 588: 
589: 589: 
590: 590:     function dividendsOf(address _customerAddress)
591: 591:         view
592: 592:         public
593: 593:         returns(uint256)
594: 594:     {
595: 595:         return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
596: 596:     }
597: 597: 
598: 598:     
599: 599: 
600: 600: 
601: 601:     function sellPrice()
602: 602:         public
603: 603:         view
604: 604:         returns(uint256)
605: 605:     {
606: 606:         
607: 607:         if(tokenSupply_ == 0){
608: 608:             return tokenPriceInitial_ - tokenPriceIncremental_;
609: 609:         } else {
610: 610:             uint256 _ethereum = tokensToEthereum_(1e18);
611: 611:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
612: 612:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
613: 613:             uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
614: 614:             return _taxedEthereum;
615: 615:         }
616: 616:     }
617: 617: 
618: 618:     
619: 619: 
620: 620: 
621: 621:     function buyPrice()
622: 622:         public
623: 623:         view
624: 624:         returns(uint256)
625: 625:     {
626: 626:         
627: 627:         if(tokenSupply_ == 0){
628: 628:             return tokenPriceInitial_ + tokenPriceIncremental_;
629: 629:         } else {
630: 630:             uint256 _ethereum = tokensToEthereum_(1e18);
631: 631:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
632: 632:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
633: 633:             uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _fundPayout);
634: 634:             return _taxedEthereum;
635: 635:         }
636: 636:     }
637: 637: 
638: 638:     
639: 639: 
640: 640: 
641: 641:     function calculateTokensReceived(uint256 _ethereumToSpend)
642: 642:         public
643: 643:         view
644: 644:         returns(uint256)
645: 645:     {
646: 646:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
647: 647:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, fundFee_), 100);
648: 648:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _fundPayout);
649: 649:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
650: 650:         return _amountOfTokens;
651: 651:     }
652: 652: 
653: 653:     
654: 654: 
655: 655: 
656: 656:     function calculateEthereumReceived(uint256 _tokensToSell)
657: 657:         public
658: 658:         view
659: 659:         returns(uint256)
660: 660:     {
661: 661:         require(_tokensToSell <= tokenSupply_);
662: 662:         uint256 _ethereum = tokensToEthereum_(_tokensToSell);
663: 663:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
664: 664:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
665: 665:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
666: 666:         return _taxedEthereum;
667: 667:     }
668: 668: 
669: 669:     
670: 670: 
671: 671: 
672: 672:     function etherToSendFund()
673: 673:         public
674: 674:         view
675: 675:         returns(uint256) {
676: 676:         return SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
677: 677:     }
678: 678: 
679: 679: 
680: 680:     
681: 681: 
682: 682: 
683: 683: 
684: 684:     
685: 685:     function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
686: 686:       notContract()
687: 687:       internal
688: 688:       returns(uint256) {
689: 689: 
690: 690:       uint256 purchaseEthereum = _incomingEthereum;
691: 691:       uint256 excess;
692: 692:       if(purchaseEthereum > 2.5 ether) { 
693: 693:           if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 50 ether) { 
694: 694:               purchaseEthereum = 2.5 ether;
695: 695:               excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
696: 696:           }
697: 697:       }
698: 698: 
699: 699:       purchaseTokens(purchaseEthereum, _referredBy);
700: 700: 
701: 701:       if (excess > 0) {
702: 702:         msg.sender.transfer(excess);
703: 703:       }
704: 704:     }
705: 705: 
706: 706:     function handleRef(address _ref, uint _referralBonus, uint _currentDividends, uint _currentFee) internal returns (uint, uint){
707: 707:         uint _dividends = _currentDividends;
708: 708:         uint _fee = _currentFee;
709: 709:         address _referredBy = stickyRef[msg.sender];
710: 710:         if (_referredBy == address(0x0)){
711: 711:             _referredBy = _ref;
712: 712:         }
713: 713:         
714: 714:         if(
715: 715:             
716: 716:             _referredBy != 0x0000000000000000000000000000000000000000 &&
717: 717: 
718: 718:             
719: 719:             _referredBy != msg.sender &&
720: 720: 
721: 721:             
722: 722:             
723: 723:             tokenBalanceLedger_[_referredBy] >= stakingRequirement
724: 724:         ){
725: 725:             
726: 726:             if (stickyRef[msg.sender] == address(0x0)){
727: 727:                 stickyRef[msg.sender] = _referredBy;
728: 728:             }
729: 729:             referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus/2);
730: 730:             address currentRef = stickyRef[_referredBy];
731: 731:             if (currentRef != address(0x0) && tokenBalanceLedger_[currentRef] >= stakingRequirement){
732: 732:                 referralBalance_[currentRef] = SafeMath.add(referralBalance_[currentRef], (_referralBonus/10)*3);
733: 733:                 currentRef = stickyRef[currentRef];
734: 734:                 if (currentRef != address(0x0) && tokenBalanceLedger_[currentRef] >= stakingRequirement){
735: 735:                     referralBalance_[currentRef] = SafeMath.add(referralBalance_[currentRef], (_referralBonus/10)*2);
736: 736:                 }
737: 737:                 else{
738: 738:                     _dividends = SafeMath.add(_dividends, _referralBonus - _referralBonus/2 - (_referralBonus/10)*3);
739: 739:                     _fee = _dividends * magnitude;
740: 740:                 }
741: 741:             }
742: 742:             else{
743: 743:                 _dividends = SafeMath.add(_dividends, _referralBonus - _referralBonus/2);
744: 744:                 _fee = _dividends * magnitude;
745: 745:             }
746: 746:             
747: 747:             
748: 748:         } else {
749: 749:             
750: 750:             
751: 751:             _dividends = SafeMath.add(_dividends, _referralBonus);
752: 752:             _fee = _dividends * magnitude;
753: 753:         }
754: 754:         return (_dividends, _fee);
755: 755:     }
756: 756: 
757: 757: 
758: 758:     function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
759: 759:         antiEarlyWhale(_incomingEthereum)
760: 760:         internal
761: 761:         returns(uint256)
762: 762:     {
763: 763:         
764: 764:         uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
765: 765:         uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
766: 766:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, fundFee_), 100);
767: 767:         uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
768: 768:         uint256 _fee;
769: 769:         (_dividends, _fee) = handleRef(_referredBy, _referralBonus, _dividends, _fee);
770: 770:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _dividends), _fundPayout);
771: 771:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
772: 772: 
773: 773:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
774: 774: 
775: 775: 
776: 776:         
777: 777:         
778: 778:         
779: 779:         
780: 780:         require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
781: 781: 
782: 782: 
783: 783: 
784: 784:         
785: 785:         if(tokenSupply_ > 0){
786: 786:  
787: 787:             
788: 788:             tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
789: 789: 
790: 790:             
791: 791:             profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
792: 792: 
793: 793:             
794: 794:             _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
795: 795: 
796: 796:         } else {
797: 797:             
798: 798:             tokenSupply_ = _amountOfTokens;
799: 799:         }
800: 800: 
801: 801:         
802: 802:         tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);
803: 803: 
804: 804:         
805: 805:         
806: 806:         int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
807: 807:         payoutsTo_[msg.sender] += _updatedPayouts;
808: 808: 
809: 809:         
810: 810:         emit onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy);
811: 811: 
812: 812:         return _amountOfTokens;
813: 813:     }
814: 814: 
815: 815:     
816: 816: 
817: 817: 
818: 818: 
819: 819: 
820: 820:     function ethereumToTokens_(uint256 _ethereum)
821: 821:         internal
822: 822:         view
823: 823:         returns(uint256)
824: 824:     {
825: 825:         uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
826: 826:         uint256 _tokensReceived =
827: 827:          (
828: 828:             (
829: 829:                 
830: 830:                 SafeMath.sub(
831: 831:                     (sqrt
832: 832:                         (
833: 833:                             (_tokenPriceInitial**2)
834: 834:                             +
835: 835:                             (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
836: 836:                             +
837: 837:                             (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
838: 838:                             +
839: 839:                             (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
840: 840:                         )
841: 841:                     ), _tokenPriceInitial
842: 842:                 )
843: 843:             )/(tokenPriceIncremental_)
844: 844:         )-(tokenSupply_)
845: 845:         ;
846: 846: 
847: 847:         return _tokensReceived;
848: 848:     }
849: 849: 
850: 850:     
851: 851: 
852: 852: 
853: 853: 
854: 854: 
855: 855:      function tokensToEthereum_(uint256 _tokens)
856: 856:         internal
857: 857:         view
858: 858:         returns(uint256)
859: 859:     {
860: 860: 
861: 861:         uint256 tokens_ = (_tokens + 1e18);
862: 862:         uint256 _tokenSupply = (tokenSupply_ + 1e18);
863: 863:         uint256 _etherReceived =
864: 864:         (
865: 865:             
866: 866:             SafeMath.sub(
867: 867:                 (
868: 868:                     (
869: 869:                         (
870: 870:                             tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
871: 871:                         )-tokenPriceIncremental_
872: 872:                     )*(tokens_ - 1e18)
873: 873:                 ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
874: 874:             )
875: 875:         /1e18);
876: 876:         return _etherReceived;
877: 877:     }
878: 878: 
879: 879: 
880: 880:     
881: 881:     
882: 882:     function sqrt(uint x) internal pure returns (uint y) {
883: 883:         uint z = (x + 1) / 2;
884: 884:         y = x;
885: 885:         while (z < y) {
886: 886:             y = z;
887: 887:             z = (x / z + z) / 2;
888: 888:         }
889: 889:     }
890: 890: }
891: 891: 
892: 892: 
893: 893: 
894: 894: 
895: 895: 
896: 896: library SafeMath {
897: 897: 
898: 898:     
899: 899: 
900: 900: 
901: 901:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
902: 902:         if (a == 0) {
903: 903:             return 0;
904: 904:         }
905: 905:         uint256 c = a * b;
906: 906:         assert(c / a == b);
907: 907:         return c;
908: 908:     }
909: 909: 
910: 910:     
911: 911: 
912: 912: 
913: 913:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
914: 914:         
915: 915:         uint256 c = a / b;
916: 916:         
917: 917:         return c;
918: 918:     }
919: 919: 
920: 920:     
921: 921: 
922: 922: 
923: 923:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
924: 924:         assert(b <= a);
925: 925:         return a - b;
926: 926:     }
927: 927: 
928: 928:     
929: 929: 
930: 930: 
931: 931:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
932: 932:         uint256 c = a + b;
933: 933:         assert(c >= a);
934: 934:         return c;
935: 935:     }
936: 936: }