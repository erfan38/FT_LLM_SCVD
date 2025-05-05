1: pragma solidity ^0.4.21;
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
12: 
13: 
14: 
15: 
16: 
17: 
18: 
19: 
20: 
21: 
22: 
23: 
24: 
25: 
26: 
27: 
28: 
29: 
30: 
31: 
32: 
33: 
34: contract Elyxr {
35:     
36: 
37: 
38:     
39:     modifier onlyBagholders() {
40:         require(myTokens() > 0);
41:         _;
42:     }
43: 
44:     
45:     modifier onlyStronghands() {
46:         require(myDividends(true) > 0);
47:         _;
48:     }
49: 
50:     modifier notContract() {
51:       require (msg.sender == tx.origin);
52:       _;
53:     }
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
64:     modifier onlyAdministrator(){
65:         address _customerAddress = msg.sender;
66:         require(administrators[_customerAddress]);
67:         _;
68:     }
69: 
70: 
71:     
72:     
73:     
74:     modifier antiEarlyWhale(uint256 _amountOfEthereum){
75:         address _customerAddress = msg.sender;
76: 
77:         
78:         
79:         if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
80:             require(
81:                 
82:                 ambassadors_[_customerAddress] == true &&
83: 
84:                 
85:                 (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
86: 
87:             );
88: 
89:             
90:             ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
91: 
92:             
93:             _;
94:         } else {
95:             
96:             onlyAmbassadors = false;
97:             _;
98:         }
99: 
100:     }
101: 
102:     
103: 
104: 
105:     event onTokenPurchase(
106:         address indexed customerAddress,
107:         uint256 incomingEthereum,
108:         uint256 tokensMinted,
109:         address indexed referredBy
110:     );
111: 
112:     event onTokenSell(
113:         address indexed customerAddress,
114:         uint256 tokensBurned,
115:         uint256 ethereumEarned
116:     );
117: 
118:     event onReinvestment(
119:         address indexed customerAddress,
120:         uint256 ethereumReinvested,
121:         uint256 tokensMinted
122:     );
123: 
124:     event onWithdraw(
125:         address indexed customerAddress,
126:         uint256 ethereumWithdrawn
127:     );
128: 
129:     
130:     event Transfer(
131:         address indexed from,
132:         address indexed to,
133:         uint256 tokens
134:     );
135: 
136: 
137:     
138: 
139: 
140:     string public name = "Elyxr";
141:     string public symbol = "ELXR";
142:     uint8 constant public decimals = 18;
143:     uint8 constant internal dividendFee_ = 10; 
144:     uint8 constant internal jackpotFee_ = 5; 
145:     uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;
146:     uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;
147:     uint256 constant internal magnitude = 2**64;
148: 
149:     
150:     
151:     address constant public giveEthJackpotAddress = 0x083EA7627ED7F4b48E7aFA3AF552cd30B2Dff3af;
152:     uint256 public totalEthJackpotRecieved; 
153:     uint256 public totalEthJackpotCollected; 
154: 
155:     
156:     uint256 public stakingRequirement = 30e18;
157: 
158:     
159:     mapping(address => bool) internal ambassadors_;
160:     uint256 constant internal ambassadorMaxPurchase_ = 0.5 ether;
161:     uint256 constant internal ambassadorQuota_ = 3 ether; 
162: 
163: 
164: 
165:    
166: 
167: 
168:     
169:     mapping(address => uint256) internal tokenBalanceLedger_;
170:     mapping(address => uint256) internal referralBalance_;
171:     mapping(address => int256) internal payoutsTo_;
172:     mapping(address => uint256) internal ambassadorAccumulatedQuota_;
173:     uint256 internal tokenSupply_ = 0;
174:     uint256 internal profitPerShare_;
175: 
176:     
177:     mapping(address => bool) public administrators;
178: 
179:     
180:     bool public onlyAmbassadors = true;
181: 
182:     
183:     mapping(address => bool) public canAcceptTokens_; 
184: 
185: 
186: 
187:     
188: 
189: 
190:     
191: 
192: 
193:     function Elyxr()
194:         public
195:     {
196:         
197:         administrators[0xA1D81A181ad53ccfFD643f23102ee6CB5F6d5E4B] = true;
198: 
199:         
200:         ambassadors_[0xA1D81A181ad53ccfFD643f23102ee6CB5F6d5E4B] = true;
201:         
202:         ambassadors_[0xb03bEF1D9659363a9357aB29a05941491AcCb4eC] = true;
203:         
204:         ambassadors_[0x87A7e71D145187eE9aAdc86954d39cf0e9446751] = true;
205:         
206:         ambassadors_[0xab73e01ba3a8009d682726b752c11b1e9722f059] = true;
207:         
208:         ambassadors_[0x008ca4f1ba79d1a265617c6206d7884ee8108a78] = true;
209:         
210:         ambassadors_[0x05f2c11996d73288AbE8a31d8b593a693FF2E5D8] = true;
211:         
212:         
213:         
214:         
215:         
216:     }
217: 
218: 
219:     
220: 
221: 
222:     function buy(address _referredBy)
223:         public
224:         payable
225:         returns(uint256)
226:     {
227:         purchaseInternal(msg.value, _referredBy);
228:     }
229: 
230:     
231: 
232: 
233: 
234:     function()
235:         payable
236:         public
237:     {
238:         purchaseInternal(msg.value, 0x0);
239:     }
240: 
241:     
242: 
243: 
244: 
245:     function payJackpot() payable public {
246:       uint256 ethToPay = SafeMath.sub(totalEthJackpotCollected, totalEthJackpotRecieved);
247:       require(ethToPay > 1);
248:       totalEthJackpotRecieved = SafeMath.add(totalEthJackpotRecieved, ethToPay);
249:       if(!giveEthJackpotAddress.call.value(ethToPay).gas(400000)()) {
250:          totalEthJackpotRecieved = SafeMath.sub(totalEthJackpotRecieved, ethToPay);
251:       }
252:     }
253: 
254:     
255: 
256: 
257:     function reinvest()
258:         onlyStronghands()
259:         public
260:     {
261:         
262:         uint256 _dividends = myDividends(false); 
263: 
264:         
265:         address _customerAddress = msg.sender;
266:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
267: 
268:         
269:         _dividends += referralBalance_[_customerAddress];
270:         referralBalance_[_customerAddress] = 0;
271: 
272:         
273:         uint256 _tokens = purchaseTokens(_dividends, 0x0);
274: 
275:         
276:         onReinvestment(_customerAddress, _dividends, _tokens);
277:     }
278: 
279:     
280: 
281: 
282:     function exit()
283:         public
284:     {
285:         
286:         address _customerAddress = msg.sender;
287:         uint256 _tokens = tokenBalanceLedger_[_customerAddress];
288:         if(_tokens > 0) sell(_tokens);
289: 
290:         
291:         withdraw();
292:     }
293: 
294:     
295: 
296: 
297:     function withdraw()
298:         onlyStronghands()
299:         public
300:     {
301:         
302:         address _customerAddress = msg.sender;
303:         uint256 _dividends = myDividends(false); 
304: 
305:         
306:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
307: 
308:         
309:         _dividends += referralBalance_[_customerAddress];
310:         referralBalance_[_customerAddress] = 0;
311: 
312:         
313:         _customerAddress.transfer(_dividends);
314: 
315:         
316:         onWithdraw(_customerAddress, _dividends);
317:     }
318: 
319:     
320: 
321: 
322:     function sell(uint256 _amountOfTokens)
323:         onlyBagholders()
324:         public
325:     {
326:         
327:         address _customerAddress = msg.sender;
328:         
329:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
330:         uint256 _tokens = _amountOfTokens;
331:         uint256 _ethereum = tokensToEthereum_(_tokens);
332: 
333:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
334:         uint256 _jackpotPayout = SafeMath.div(SafeMath.mul(_ethereum, jackpotFee_), 100);
335: 
336:         
337:         uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _jackpotPayout);
338: 
339:         
340:         totalEthJackpotCollected = SafeMath.add(totalEthJackpotCollected, _jackpotPayout);
341: 
342:         
343:         tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
344:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
345: 
346:         
347:         int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
348:         payoutsTo_[_customerAddress] -= _updatedPayouts;
349: 
350:         
351:         if (tokenSupply_ > 0) {
352:             
353:             profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
354:         }
355: 
356:         
357:         onTokenSell(_customerAddress, _tokens, _taxedEthereum);
358:     }
359: 
360: 
361:     
362: 
363: 
364: 
365:     function transfer(address _toAddress, uint256 _amountOfTokens)
366:         onlyBagholders()
367:         public
368:         returns(bool)
369:     {
370:         
371:         address _customerAddress = msg.sender;
372: 
373:         
374:         
375:         
376:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
377: 
378:         
379:         if(myDividends(true) > 0) withdraw();
380: 
381:         
382:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
383:         tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
384: 
385:         
386:         payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
387:         payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);
388: 
389: 
390:         
391:         Transfer(_customerAddress, _toAddress, _amountOfTokens);
392: 
393:         
394:         return true;
395:     }
396: 
397:     
398: 
399: 
400: 
401: 
402: 
403: 
404: 
405:     function transferAndCall(address _to, uint256 _value, bytes _data) external returns (bool) {
406:       require(_to != address(0));
407:       require(canAcceptTokens_[_to] == true); 
408:       require(transfer(_to, _value)); 
409: 
410:       if (isContract(_to)) {
411:         AcceptsElyxr receiver = AcceptsElyxr(_to);
412:         require(receiver.tokenFallback(msg.sender, _value, _data));
413:       }
414: 
415:       return true;
416:     }
417: 
418:     
419: 
420: 
421: 
422:      function isContract(address _addr) private constant returns (bool is_contract) {
423:        
424:        uint length;
425:        assembly { length := extcodesize(_addr) }
426:        return length > 0;
427:      }
428: 
429:     
430:     
431: 
432: 
433:     function disableInitialStage()
434:         onlyAdministrator()
435:         public
436:     {
437:         onlyAmbassadors = false;
438:     }
439: 
440:     
441: 
442: 
443:     function setAdministrator(address _identifier, bool _status)
444:         onlyAdministrator()
445:         public
446:     {
447:         administrators[_identifier] = _status;
448:     }
449: 
450:     
451: 
452: 
453:     function setStakingRequirement(uint256 _amountOfTokens)
454:         onlyAdministrator()
455:         public
456:     {
457:         stakingRequirement = _amountOfTokens;
458:     }
459: 
460:     
461: 
462: 
463:     function setCanAcceptTokens(address _address, bool _value)
464:       onlyAdministrator()
465:       public
466:     {
467:       canAcceptTokens_[_address] = _value;
468:     }
469: 
470:     
471: 
472: 
473:     function setName(string _name)
474:         onlyAdministrator()
475:         public
476:     {
477:         name = _name;
478:     }
479: 
480:     
481: 
482: 
483:     function setSymbol(string _symbol)
484:         onlyAdministrator()
485:         public
486:     {
487:         symbol = _symbol;
488:     }
489: 
490: 
491:     
492:     
493: 
494: 
495: 
496:     function totalEthereumBalance()
497:         public
498:         view
499:         returns(uint)
500:     {
501:         return this.balance;
502:     }
503: 
504:     
505: 
506: 
507:     function totalSupply()
508:         public
509:         view
510:         returns(uint256)
511:     {
512:         return tokenSupply_;
513:     }
514: 
515:     
516: 
517: 
518:     function myTokens()
519:         public
520:         view
521:         returns(uint256)
522:     {
523:         address _customerAddress = msg.sender;
524:         return balanceOf(_customerAddress);
525:     }
526: 
527:     
528: 
529: 
530: 
531: 
532: 
533:     function myDividends(bool _includeReferralBonus)
534:         public
535:         view
536:         returns(uint256)
537:     {
538:         address _customerAddress = msg.sender;
539:         return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
540:     }
541: 
542:     
543: 
544: 
545:     function balanceOf(address _customerAddress)
546:         view
547:         public
548:         returns(uint256)
549:     {
550:         return tokenBalanceLedger_[_customerAddress];
551:     }
552: 
553:     
554: 
555: 
556:     function dividendsOf(address _customerAddress)
557:         view
558:         public
559:         returns(uint256)
560:     {
561:         return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
562:     }
563: 
564:     
565: 
566: 
567:     function sellPrice()
568:         public
569:         view
570:         returns(uint256)
571:     {
572:         
573:         if(tokenSupply_ == 0){
574:             return tokenPriceInitial_ - tokenPriceIncremental_;
575:         } else {
576:             uint256 _ethereum = tokensToEthereum_(1e18);
577:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
578:             uint256 _jackpotPayout = SafeMath.div(SafeMath.mul(_ethereum, jackpotFee_), 100);
579:             uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _jackpotPayout);
580:             return _taxedEthereum;
581:         }
582:     }
583: 
584:     
585: 
586: 
587:     function buyPrice()
588:         public
589:         view
590:         returns(uint256)
591:     {
592:         
593:         if(tokenSupply_ == 0){
594:             return tokenPriceInitial_ + tokenPriceIncremental_;
595:         } else {
596:             uint256 _ethereum = tokensToEthereum_(1e18);
597:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
598:             uint256 _jackpotPayout = SafeMath.div(SafeMath.mul(_ethereum, jackpotFee_), 100);
599:             uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _jackpotPayout);
600:             return _taxedEthereum;
601:         }
602:     }
603: 
604:     
605: 
606: 
607:     function calculateTokensReceived(uint256 _ethereumToSpend)
608:         public
609:         view
610:         returns(uint256)
611:     {
612:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
613:         uint256 _jackpotPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, jackpotFee_), 100);
614:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _jackpotPayout);
615:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
616:         return _amountOfTokens;
617:     }
618: 
619:     
620: 
621: 
622:     function calculateEthereumReceived(uint256 _tokensToSell)
623:         public
624:         view
625:         returns(uint256)
626:     {
627:         require(_tokensToSell <= tokenSupply_);
628:         uint256 _ethereum = tokensToEthereum_(_tokensToSell);
629:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
630:         uint256 _jackpotPayout = SafeMath.div(SafeMath.mul(_ethereum, jackpotFee_), 100);
631:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _jackpotPayout);
632:         return _taxedEthereum;
633:     }
634: 
635:     
636: 
637: 
638:     function etherToSendJackpot()
639:         public
640:         view
641:         returns(uint256) {
642:         return SafeMath.sub(totalEthJackpotCollected, totalEthJackpotRecieved);
643:     }
644: 
645: 
646:     
647: 
648: 
649: 
650:     
651:     function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
652:       notContract()
653:       internal
654:       returns(uint256) {
655: 
656:       uint256 purchaseEthereum = _incomingEthereum;
657:       uint256 excess;
658:       if(purchaseEthereum > 4 ether) { 
659:           if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 100 ether) { 
660:               purchaseEthereum = 4 ether;
661:               excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
662:           }
663:       }
664: 
665:       purchaseTokens(purchaseEthereum, _referredBy);
666: 
667:       if (excess > 0) {
668:         msg.sender.transfer(excess);
669:       }
670:     }
671: 
672: 
673:     function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
674:         antiEarlyWhale(_incomingEthereum)
675:         internal
676:         returns(uint256)
677:     {
678:         
679:         uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
680:         uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
681:         uint256 _jackpotPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, jackpotFee_), 100);
682:         uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
683:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _undividedDividends), _jackpotPayout);
684: 
685:         totalEthJackpotCollected = SafeMath.add(totalEthJackpotCollected, _jackpotPayout);
686: 
687:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
688:         uint256 _fee = _dividends * magnitude;
689: 
690:         
691:         
692:         
693:         
694:         require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
695: 
696:         
697:         if(
698:             
699:             _referredBy != 0x0000000000000000000000000000000000000000 &&
700: 
701:             
702:             _referredBy != msg.sender &&
703: 
704:             
705:             
706:             tokenBalanceLedger_[_referredBy] >= stakingRequirement
707:         ){
708:             
709:             referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
710:         } else {
711:             
712:             
713:             _dividends = SafeMath.add(_dividends, _referralBonus);
714:             _fee = _dividends * magnitude;
715:         }
716: 
717:         
718:         if(tokenSupply_ > 0){
719: 
720:             
721:             tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
722: 
723:             
724:             profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
725: 
726:             
727:             _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
728: 
729:         } else {
730:             
731:             tokenSupply_ = _amountOfTokens;
732:         }
733: 
734:         
735:         tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);
736: 
737:         
738:         
739:         int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
740:         payoutsTo_[msg.sender] += _updatedPayouts;
741: 
742:         
743:         onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy);
744: 
745:         return _amountOfTokens;
746:     }
747: 
748:     
749: 
750: 
751: 
752: 
753:     function ethereumToTokens_(uint256 _ethereum)
754:         internal
755:         view
756:         returns(uint256)
757:     {
758:         uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
759:         uint256 _tokensReceived =
760:          (
761:             (
762:                 
763:                 SafeMath.sub(
764:                     (sqrt
765:                         (
766:                             (_tokenPriceInitial**2)
767:                             +
768:                             (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
769:                             +
770:                             (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
771:                             +
772:                             (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
773:                         )
774:                     ), _tokenPriceInitial
775:                 )
776:             )/(tokenPriceIncremental_)
777:         )-(tokenSupply_)
778:         ;
779: 
780:         return _tokensReceived;
781:     }
782: 
783:     
784: 
785: 
786: 
787: 
788:      function tokensToEthereum_(uint256 _tokens)
789:         internal
790:         view
791:         returns(uint256)
792:     {
793: 
794:         uint256 tokens_ = (_tokens + 1e18);
795:         uint256 _tokenSupply = (tokenSupply_ + 1e18);
796:         uint256 _etherReceived =
797:         (
798:             
799:             SafeMath.sub(
800:                 (
801:                     (
802:                         (
803:                             tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
804:                         )-tokenPriceIncremental_
805:                     )*(tokens_ - 1e18)
806:                 ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
807:             )
808:         /1e18);
809:         return _etherReceived;
810:     }
811: 
812: 
813:     
814:     
815:     function sqrt(uint x) internal pure returns (uint y) {
816:         uint z = (x + 1) / 2;
817:         y = x;
818:         while (z < y) {
819:             y = z;
820:             z = (x / z + z) / 2;
821:         }
822:     }
823: }
824: 
825: 
826: 
827: 
828: 
829: library SafeMath {
830: 
831:     
832: 
833: 
834:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
835:         if (a == 0) {
836:             return 0;
837:         }
838:         uint256 c = a * b;
839:         assert(c / a == b);
840:         return c;
841:     }
842: 
843:     
844: 
845: 
846:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
847:         
848:         uint256 c = a / b;
849:         
850:         return c;
851:     }
852: 
853:     
854: 
855: 
856:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
857:         assert(b <= a);
858:         return a - b;
859:     }
860: 
861:     
862: 
863: 
864:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
865:         uint256 c = a + b;
866:         assert(c >= a);
867:         return c;
868:     }
869: }