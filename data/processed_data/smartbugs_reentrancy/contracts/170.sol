1: 1: pragma solidity ^0.4.25;
2: 2: 
3: 3: contract Exchange {
4: 4:     
5: 5: 
6: 6: 
7: 7:     
8: 8:     modifier onlyBagholders() {
9: 9:         require(myTokens() > 0);
10: 10:         _;
11: 11:     }
12: 12: 
13: 13:     
14: 14:     modifier onlyStronghands() {
15: 15:         require(myDividends(true) > 0);
16: 16:         _;
17: 17:     }
18: 18: 
19: 19:     modifier notContract() {
20: 20:       require (msg.sender == tx.origin);
21: 21:       _;
22: 22:     }
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
33: 33:     modifier onlyAdministrator(){
34: 34:         address _customerAddress = msg.sender;
35: 35:         require(administrators[_customerAddress]);
36: 36:         _;
37: 37:     }
38: 38: 
39: 39:     uint ACTIVATION_TIME = 1547996400;
40: 40: 
41: 41:     
42: 42:     
43: 43:     
44: 44:     modifier antiEarlyWhale(uint256 _amountOfEthereum){
45: 45: 
46: 46:         if (now >= ACTIVATION_TIME) {
47: 47:             onlyAmbassadors = false;
48: 48:         }
49: 49: 
50: 50:         
51: 51:         
52: 52:         if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
53: 53:             require(
54: 54:                 
55: 55:                 ambassadors_[msg.sender] == true &&
56: 56: 
57: 57:                 
58: 58:                 (ambassadorAccumulatedQuota_[msg.sender] + _amountOfEthereum) <= ambassadorMaxPurchase_
59: 59: 
60: 60:             );
61: 61: 
62: 62:             
63: 63:             ambassadorAccumulatedQuota_[msg.sender] = SafeMath.add(ambassadorAccumulatedQuota_[msg.sender], _amountOfEthereum);
64: 64: 
65: 65:             
66: 66:             _;
67: 67:         } else {
68: 68:             
69: 69:             onlyAmbassadors = false;
70: 70:             _;
71: 71:         }
72: 72: 
73: 73:     }
74: 74: 
75: 75:     
76: 76: 
77: 77: 
78: 78:     event onTokenPurchase(
79: 79:         address indexed customerAddress,
80: 80:         uint256 incomingEthereum,
81: 81:         uint256 tokensMinted,
82: 82:         address indexed referredBy,
83: 83:         bool isReinvest,
84: 84:         uint timestamp,
85: 85:         uint256 price
86: 86:     );
87: 87: 
88: 88:     event onTokenSell(
89: 89:         address indexed customerAddress,
90: 90:         uint256 tokensBurned,
91: 91:         uint256 ethereumEarned,
92: 92:         uint timestamp,
93: 93:         uint256 price
94: 94:     );
95: 95: 
96: 96:     event onReinvestment(
97: 97:         address indexed customerAddress,
98: 98:         uint256 ethereumReinvested,
99: 99:         uint256 tokensMinted
100: 100:     );
101: 101: 
102: 102:     event onWithdraw(
103: 103:         address indexed customerAddress,
104: 104:         uint256 ethereumWithdrawn,
105: 105:         uint256 estimateTokens,
106: 106:         bool isTransfer
107: 107:     );
108: 108: 
109: 109:     
110: 110:     event Transfer(
111: 111:         address indexed from,
112: 112:         address indexed to,
113: 113:         uint256 tokens
114: 114:     );
115: 115: 
116: 116: 
117: 117:     
118: 118: 
119: 119: 
120: 120:     string public name = "EXCHANGE";
121: 121:     string public symbol = "DICE";
122: 122:     uint8 constant public decimals = 18;
123: 123: 
124: 124:     uint8 constant internal dividendFee_ = 20; 
125: 125:     uint8 constant internal fundFee_ = 5; 
126: 126: 
127: 127:     uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;
128: 128:     uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;
129: 129:     uint256 constant internal magnitude = 2**64;
130: 130: 
131: 131:     
132: 132:     address public giveEthFundAddress = 0x0;
133: 133:     bool public finalizedEthFundAddress = false;
134: 134:     uint256 public totalEthFundReceived; 
135: 135:     uint256 public totalEthFundCollected; 
136: 136: 
137: 137:     
138: 138:     uint256 public stakingRequirement = 25e18;
139: 139: 
140: 140:     
141: 141:     mapping(address => bool) internal ambassadors_;
142: 142:     uint256 constant internal ambassadorMaxPurchase_ = 4 ether;
143: 143:     uint256 constant internal ambassadorQuota_ = 4 ether;
144: 144: 
145: 145:    
146: 146: 
147: 147: 
148: 148:     
149: 149:     mapping(address => uint256) internal tokenBalanceLedger_;
150: 150:     mapping(address => uint256) internal referralBalance_;
151: 151:     mapping(address => int256) internal payoutsTo_;
152: 152:     mapping(address => uint256) internal ambassadorAccumulatedQuota_;
153: 153:     uint256 internal tokenSupply_ = 0;
154: 154:     uint256 internal profitPerShare_;
155: 155: 
156: 156:     
157: 157:     mapping(address => bool) public administrators;
158: 158: 
159: 159:     
160: 160:     bool public onlyAmbassadors = true;
161: 161: 
162: 162:     
163: 163:     mapping(address => bool) public canAcceptTokens_; 
164: 164: 
165: 165:     
166: 166: 
167: 167: 
168: 168:     
169: 169: 
170: 170: 
171: 171:     constructor()
172: 172:         public
173: 173:     {
174: 174:         
175: 175:         administrators[0xB477ACeb6262b12a3c7b2445027a072f95C75Bd3] = true;
176: 176: 
177: 177:         
178: 178:         ambassadors_[0xB477ACeb6262b12a3c7b2445027a072f95C75Bd3] = true;
179: 179:     }
180: 180: 
181: 181: 
182: 182:     
183: 183: 
184: 184: 
185: 185:     function buy(address _referredBy)
186: 186:         public
187: 187:         payable
188: 188:         returns(uint256)
189: 189:     {
190: 190: 
191: 191:         require(tx.gasprice <= 0.05 szabo);
192: 192:         purchaseTokens(msg.value, _referredBy, false);
193: 193:     }
194: 194: 
195: 195:     
196: 196: 
197: 197: 
198: 198: 
199: 199:     function()
200: 200:         payable
201: 201:         public
202: 202:     {
203: 203: 
204: 204:         require(tx.gasprice <= 0.05 szabo);
205: 205:         purchaseTokens(msg.value, 0x0, false);
206: 206:     }
207: 207: 
208: 208:     function updateFundAddress(address _newAddress)
209: 209:         onlyAdministrator()
210: 210:         public
211: 211:     {
212: 212:         require(finalizedEthFundAddress == false);
213: 213:         giveEthFundAddress = _newAddress;
214: 214:     }
215: 215: 
216: 216:     function finalizeFundAddress(address _finalAddress)
217: 217:         onlyAdministrator()
218: 218:         public
219: 219:     {
220: 220:         require(finalizedEthFundAddress == false);
221: 221:         giveEthFundAddress = _finalAddress;
222: 222:         finalizedEthFundAddress = true;
223: 223:     }
224: 224: 
225: 225:     
226: 226: 
227: 227: 
228: 228: 
229: 229:     function payFund() payable public {
230: 230:         uint256 ethToPay = SafeMath.sub(totalEthFundCollected, totalEthFundReceived);
231: 231:         require(ethToPay > 0);
232: 232:         totalEthFundReceived = SafeMath.add(totalEthFundReceived, ethToPay);
233: 233:         if(!giveEthFundAddress.call.value(ethToPay)()) {
234: 234:             revert();
235: 235:         }
236: 236:     }
237: 237: 
238: 238:     
239: 239: 
240: 240: 
241: 241:     function reinvest()
242: 242:         onlyStronghands()
243: 243:         public
244: 244:     {
245: 245:         
246: 246:         uint256 _dividends = myDividends(false); 
247: 247: 
248: 248:         
249: 249:         address _customerAddress = msg.sender;
250: 250:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
251: 251: 
252: 252:         
253: 253:         _dividends += referralBalance_[_customerAddress];
254: 254:         referralBalance_[_customerAddress] = 0;
255: 255: 
256: 256:         
257: 257:         uint256 _tokens = purchaseTokens(_dividends, 0x0, true);
258: 258: 
259: 259:         
260: 260:         emit onReinvestment(_customerAddress, _dividends, _tokens);
261: 261:     }
262: 262: 
263: 263:     
264: 264: 
265: 265: 
266: 266:     function exit()
267: 267:         public
268: 268:     {
269: 269:         
270: 270:         address _customerAddress = msg.sender;
271: 271:         uint256 _tokens = tokenBalanceLedger_[_customerAddress];
272: 272:         if(_tokens > 0) sell(_tokens);
273: 273: 
274: 274:         
275: 275:         withdraw(false);
276: 276:     }
277: 277: 
278: 278:     
279: 279: 
280: 280: 
281: 281:     function withdraw(bool _isTransfer)
282: 282:         onlyStronghands()
283: 283:         public
284: 284:     {
285: 285:         
286: 286:         address _customerAddress = msg.sender;
287: 287:         uint256 _dividends = myDividends(false); 
288: 288: 
289: 289:         uint256 _estimateTokens = calculateTokensReceived(_dividends);
290: 290: 
291: 291:         
292: 292:         payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
293: 293: 
294: 294:         
295: 295:         _dividends += referralBalance_[_customerAddress];
296: 296:         referralBalance_[_customerAddress] = 0;
297: 297: 
298: 298:         
299: 299:         _customerAddress.transfer(_dividends);
300: 300: 
301: 301:         
302: 302:         emit onWithdraw(_customerAddress, _dividends, _estimateTokens, _isTransfer);
303: 303:     }
304: 304: 
305: 305:     
306: 306: 
307: 307: 
308: 308:     function sell(uint256 _amountOfTokens)
309: 309:         onlyBagholders()
310: 310:         public
311: 311:     {
312: 312:         
313: 313:         address _customerAddress = msg.sender;
314: 314:         
315: 315:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
316: 316:         uint256 _tokens = _amountOfTokens;
317: 317:         uint256 _ethereum = tokensToEthereum_(_tokens);
318: 318: 
319: 319:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
320: 320:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
321: 321: 
322: 322:         
323: 323:         uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
324: 324: 
325: 325:         
326: 326:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
327: 327: 
328: 328:         
329: 329:         tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
330: 330:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
331: 331: 
332: 332:         
333: 333:         int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
334: 334:         payoutsTo_[_customerAddress] -= _updatedPayouts;
335: 335: 
336: 336:         
337: 337:         if (tokenSupply_ > 0) {
338: 338:             
339: 339:             profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
340: 340:         }
341: 341: 
342: 342:         
343: 343:         emit onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());
344: 344:     }
345: 345: 
346: 346: 
347: 347:     
348: 348: 
349: 349: 
350: 350: 
351: 351:     function transfer(address _toAddress, uint256 _amountOfTokens)
352: 352:         onlyBagholders()
353: 353:         public
354: 354:         returns(bool)
355: 355:     {
356: 356:         
357: 357:         address _customerAddress = msg.sender;
358: 358: 
359: 359:         
360: 360:         
361: 361:         
362: 362:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
363: 363: 
364: 364:         
365: 365:         if(myDividends(true) > 0) withdraw(true);
366: 366: 
367: 367:         
368: 368:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
369: 369:         tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
370: 370: 
371: 371:         
372: 372:         payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
373: 373:         payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);
374: 374: 
375: 375: 
376: 376:         
377: 377:         emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
378: 378: 
379: 379:         
380: 380:         return true;
381: 381:     }
382: 382: 
383: 383:     
384: 384: 
385: 385: 
386: 386: 
387: 387: 
388: 388: 
389: 389: 
390: 390: 
391: 391:     function transferAndCall(address _to, uint256 _value, bytes _data) external returns (bool) {
392: 392:       require(_to != address(0));
393: 393:       require(canAcceptTokens_[_to] == true); 
394: 394:       require(transfer(_to, _value)); 
395: 395: 
396: 396:       if (isContract(_to)) {
397: 397:         AcceptsExchange receiver = AcceptsExchange(_to);
398: 398:         require(receiver.tokenFallback(msg.sender, _value, _data));
399: 399:       }
400: 400: 
401: 401:       return true;
402: 402:     }
403: 403: 
404: 404:     
405: 405: 
406: 406: 
407: 407: 
408: 408:      function isContract(address _addr) private constant returns (bool is_contract) {
409: 409:        
410: 410:        uint length;
411: 411:        assembly { length := extcodesize(_addr) }
412: 412:        return length > 0;
413: 413:      }
414: 414: 
415: 415:     
416: 416:     
417: 417: 
418: 418: 
419: 419: 
420: 420: 
421: 421:     function setAdministrator(address _identifier, bool _status)
422: 422:         onlyAdministrator()
423: 423:         public
424: 424:     {
425: 425:         administrators[_identifier] = _status;
426: 426:     }
427: 427: 
428: 428:     
429: 429: 
430: 430: 
431: 431:     function setStakingRequirement(uint256 _amountOfTokens)
432: 432:         onlyAdministrator()
433: 433:         public
434: 434:     {
435: 435:         stakingRequirement = _amountOfTokens;
436: 436:     }
437: 437: 
438: 438:     
439: 439: 
440: 440: 
441: 441:     function setCanAcceptTokens(address _address, bool _value)
442: 442:       onlyAdministrator()
443: 443:       public
444: 444:     {
445: 445:       canAcceptTokens_[_address] = _value;
446: 446:     }
447: 447: 
448: 448:     
449: 449: 
450: 450: 
451: 451:     function setName(string _name)
452: 452:         onlyAdministrator()
453: 453:         public
454: 454:     {
455: 455:         name = _name;
456: 456:     }
457: 457: 
458: 458:     
459: 459: 
460: 460: 
461: 461:     function setSymbol(string _symbol)
462: 462:         onlyAdministrator()
463: 463:         public
464: 464:     {
465: 465:         symbol = _symbol;
466: 466:     }
467: 467: 
468: 468: 
469: 469:     
470: 470:     
471: 471: 
472: 472: 
473: 473: 
474: 474:     function totalEthereumBalance()
475: 475:         public
476: 476:         view
477: 477:         returns(uint)
478: 478:     {
479: 479:         return address(this).balance;
480: 480:     }
481: 481: 
482: 482:     
483: 483: 
484: 484: 
485: 485:     function totalSupply()
486: 486:         public
487: 487:         view
488: 488:         returns(uint256)
489: 489:     {
490: 490:         return tokenSupply_;
491: 491:     }
492: 492: 
493: 493:     
494: 494: 
495: 495: 
496: 496:     function myTokens()
497: 497:         public
498: 498:         view
499: 499:         returns(uint256)
500: 500:     {
501: 501:         address _customerAddress = msg.sender;
502: 502:         return balanceOf(_customerAddress);
503: 503:     }
504: 504: 
505: 505:     
506: 506: 
507: 507: 
508: 508: 
509: 509: 
510: 510: 
511: 511:     function myDividends(bool _includeReferralBonus)
512: 512:         public
513: 513:         view
514: 514:         returns(uint256)
515: 515:     {
516: 516:         address _customerAddress = msg.sender;
517: 517:         return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
518: 518:     }
519: 519: 
520: 520:     
521: 521: 
522: 522: 
523: 523:     function balanceOf(address _customerAddress)
524: 524:         view
525: 525:         public
526: 526:         returns(uint256)
527: 527:     {
528: 528:         return tokenBalanceLedger_[_customerAddress];
529: 529:     }
530: 530: 
531: 531:     
532: 532: 
533: 533: 
534: 534:     function dividendsOf(address _customerAddress)
535: 535:         view
536: 536:         public
537: 537:         returns(uint256)
538: 538:     {
539: 539:         return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
540: 540:     }
541: 541: 
542: 542:     
543: 543: 
544: 544: 
545: 545:     function sellPrice()
546: 546:         public
547: 547:         view
548: 548:         returns(uint256)
549: 549:     {
550: 550:         
551: 551:         if(tokenSupply_ == 0){
552: 552:             return tokenPriceInitial_ - tokenPriceIncremental_;
553: 553:         } else {
554: 554:             uint256 _ethereum = tokensToEthereum_(1e18);
555: 555:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
556: 556:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
557: 557:             uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
558: 558:             return _taxedEthereum;
559: 559:         }
560: 560:     }
561: 561: 
562: 562:     
563: 563: 
564: 564: 
565: 565:     function buyPrice()
566: 566:         public
567: 567:         view
568: 568:         returns(uint256)
569: 569:     {
570: 570:         
571: 571:         if(tokenSupply_ == 0){
572: 572:             return tokenPriceInitial_ + tokenPriceIncremental_;
573: 573:         } else {
574: 574:             uint256 _ethereum = tokensToEthereum_(1e18);
575: 575:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
576: 576:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
577: 577:             uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _fundPayout);
578: 578:             return _taxedEthereum;
579: 579:         }
580: 580:     }
581: 581: 
582: 582:     
583: 583: 
584: 584: 
585: 585:     function calculateTokensReceived(uint256 _ethereumToSpend)
586: 586:         public
587: 587:         view
588: 588:         returns(uint256)
589: 589:     {
590: 590:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
591: 591:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, fundFee_), 100);
592: 592:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _fundPayout);
593: 593:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
594: 594:         return _amountOfTokens;
595: 595:     }
596: 596: 
597: 597:     
598: 598: 
599: 599: 
600: 600:     function calculateEthereumReceived(uint256 _tokensToSell)
601: 601:         public
602: 602:         view
603: 603:         returns(uint256)
604: 604:     {
605: 605:         require(_tokensToSell <= tokenSupply_);
606: 606:         uint256 _ethereum = tokensToEthereum_(_tokensToSell);
607: 607:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
608: 608:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
609: 609:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
610: 610:         return _taxedEthereum;
611: 611:     }
612: 612: 
613: 613:     
614: 614: 
615: 615: 
616: 616:     function etherToSendFund()
617: 617:         public
618: 618:         view
619: 619:         returns(uint256) {
620: 620:         return SafeMath.sub(totalEthFundCollected, totalEthFundReceived);
621: 621:     }
622: 622: 
623: 623:     
624: 624: 
625: 625: 
626: 626: 
627: 627:     function purchaseTokens(uint256 _incomingEthereum, address _referredBy, bool _isReinvest)
628: 628:         antiEarlyWhale(_incomingEthereum)
629: 629:         internal
630: 630:         returns(uint256)
631: 631:     {
632: 632:         
633: 633:         uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
634: 634:         uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
635: 635:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, fundFee_), 100);
636: 636:         uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
637: 637:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _undividedDividends), _fundPayout);
638: 638:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
639: 639: 
640: 640:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
641: 641:         uint256 _fee = _dividends * magnitude;
642: 642: 
643: 643:         
644: 644:         
645: 645:         
646: 646:         
647: 647:         require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
648: 648: 
649: 649:         
650: 650:         if(
651: 651:             
652: 652:             _referredBy != 0x0000000000000000000000000000000000000000 &&
653: 653: 
654: 654:             
655: 655:             _referredBy != msg.sender &&
656: 656: 
657: 657:             
658: 658:             
659: 659:             tokenBalanceLedger_[_referredBy] >= stakingRequirement
660: 660:         ){
661: 661:             
662: 662:             referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
663: 663:         } else {
664: 664:             
665: 665:             
666: 666:             _dividends = SafeMath.add(_dividends, _referralBonus);
667: 667:             _fee = _dividends * magnitude;
668: 668:         }
669: 669: 
670: 670:         
671: 671:         if(tokenSupply_ > 0){
672: 672: 
673: 673:             
674: 674:             tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
675: 675: 
676: 676:             
677: 677:             profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
678: 678: 
679: 679:             
680: 680:             _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
681: 681: 
682: 682:         } else {
683: 683:             
684: 684:             tokenSupply_ = _amountOfTokens;
685: 685:         }
686: 686: 
687: 687:         
688: 688:         tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);
689: 689: 
690: 690:         
691: 691:         
692: 692:         int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
693: 693:         payoutsTo_[msg.sender] += _updatedPayouts;
694: 694: 
695: 695:         
696: 696:         emit onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy, _isReinvest, now, buyPrice());
697: 697: 
698: 698:         return _amountOfTokens;
699: 699:     }
700: 700: 
701: 701:     
702: 702: 
703: 703: 
704: 704: 
705: 705: 
706: 706:     function ethereumToTokens_(uint256 _ethereum)
707: 707:         internal
708: 708:         view
709: 709:         returns(uint256)
710: 710:     {
711: 711:         uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
712: 712:         uint256 _tokensReceived =
713: 713:          (
714: 714:             (
715: 715:                 
716: 716:                 SafeMath.sub(
717: 717:                     (sqrt
718: 718:                         (
719: 719:                             (_tokenPriceInitial**2)
720: 720:                             +
721: 721:                             (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
722: 722:                             +
723: 723:                             (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
724: 724:                             +
725: 725:                             (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
726: 726:                         )
727: 727:                     ), _tokenPriceInitial
728: 728:                 )
729: 729:             )/(tokenPriceIncremental_)
730: 730:         )-(tokenSupply_)
731: 731:         ;
732: 732: 
733: 733:         return _tokensReceived;
734: 734:     }
735: 735: 
736: 736:     
737: 737: 
738: 738: 
739: 739: 
740: 740: 
741: 741:      function tokensToEthereum_(uint256 _tokens)
742: 742:         internal
743: 743:         view
744: 744:         returns(uint256)
745: 745:     {
746: 746: 
747: 747:         uint256 tokens_ = (_tokens + 1e18);
748: 748:         uint256 _tokenSupply = (tokenSupply_ + 1e18);
749: 749:         uint256 _etherReceived =
750: 750:         (
751: 751:             
752: 752:             SafeMath.sub(
753: 753:                 (
754: 754:                     (
755: 755:                         (
756: 756:                             tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
757: 757:                         )-tokenPriceIncremental_
758: 758:                     )*(tokens_ - 1e18)
759: 759:                 ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
760: 760:             )
761: 761:         /1e18);
762: 762:         return _etherReceived;
763: 763:     }
764: 764: 
765: 765: 
766: 766:     
767: 767:     
768: 768:     function sqrt(uint x) internal pure returns (uint y) {
769: 769:         uint z = (x + 1) / 2;
770: 770:         y = x;
771: 771:         while (z < y) {
772: 772:             y = z;
773: 773:             z = (x / z + z) / 2;
774: 774:         }
775: 775:     }
776: 776: }
777: 777: 
778: 778: 
779: 779: 
780: 780: 
781: 781: 
782: 782: library SafeMath {
783: 783: 
784: 784:     
785: 785: 
786: 786: 
787: 787:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
788: 788:         if (a == 0) {
789: 789:             return 0;
790: 790:         }
791: 791:         uint256 c = a * b;
792: 792:         assert(c / a == b);
793: 793:         return c;
794: 794:     }
795: 795: 
796: 796:     
797: 797: 
798: 798: 
799: 799:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
800: 800:         
801: 801:         uint256 c = a / b;
802: 802:         
803: 803:         return c;
804: 804:     }
805: 805: 
806: 806:     
807: 807: 
808: 808: 
809: 809:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
810: 810:         assert(b <= a);
811: 811:         return a - b;
812: 812:     }
813: 813: 
814: 814:     
815: 815: 
816: 816: 
817: 817:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
818: 818:         uint256 c = a + b;
819: 819:         assert(c >= a);
820: 820:         return c;
821: 821:     }
822: 822: }