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
34: 
35: 
36: 
37: 
38: 
39: 
40: 
41: 
42: 
43: 
44: 
45: 
46: 
47: 
48: 
49: contract FUNDS {
50:     
51: 
52: 
53:     
54:     modifier onlyBagholders() {
55:         require(myTokens() > 0);
56:         _;
57:     }
58: 
59:     
60:     modifier onlyStronghands() {
61:         require(myDividends(true) > 0);
62:         _;
63:     }
64: 
65:     modifier notContract() {
66:       require (msg.sender == tx.origin);
67:       _;
68:     }
69: 
70:     
71:     
72:     
73:     
74:     
75:     
76:     
77:     
78:     
79:     modifier onlyAdministrator(){
80:         address _customerAddress = msg.sender;
81:         require(administrators[_customerAddress]);
82:         _;
83:     }
84:     
85:     uint ACTIVATION_TIME = 1536258600;
86: 
87: 
88:     
89:     
90:     
91:     modifier antiEarlyWhale(uint256 _amountOfEthereum){
92:         address _customerAddress = msg.sender;
93:         
94:         if (now >= ACTIVATION_TIME) {
95:             onlyAmbassadors = false;
96:         }
97: 
98:         
99:         
100:         if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
101:             require(
102:                 
103:                 ambassadors_[_customerAddress] == true &&
104: 
105:                 
106:                 (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
107: 
108:             );
109: 
110:             
111:             ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
112: 
113:             
114:             _;
115:         } else {
116:             
117:             onlyAmbassadors = false;
118:             _;
119:         }
120: 
121:     }
122: 
123:     
124: 
125: 
126:     event onTokenPurchase(
127:         address indexed customerAddress,
128:         uint256 incomingEthereum,
129:         uint256 tokensMinted,
130:         address indexed referredBy
131:     );
132: 
133:     event onTokenSell(
134:         address indexed customerAddress,
135:         uint256 tokensBurned,
136:         uint256 ethereumEarned
137:     );
138: 
139:     event onReinvestment(
140:         address indexed customerAddress,
141:         uint256 ethereumReinvested,
142:         uint256 tokensMinted
143:     );
144: 
145:     event onWithdraw(
146:         address indexed customerAddress,
147:         uint256 ethereumWithdrawn
148:     );
149: 
150:     
151:     event Transfer(
152:         address indexed from,
153:         address indexed to,
154:         uint256 tokens
155:     );
156: 
157: 
158:     
159: 
160: 
161:     string public name = "FUNDS";
162:     string public symbol = "FUNDS";
163:     uint8 constant public decimals = 18;
164:     uint8 constant internal dividendFee_ = 24; 
165:     uint8 constant internal fundFee_ = 1; 
166:     uint256 constant internal tokenPriceInitial_ = 0.00000001 ether;
167:     uint256 constant internal tokenPriceIncremental_ = 0.000000001 ether;
168:     uint256 constant internal magnitude = 2**64;
169: 
170:     
171:     address public giveEthFundAddress = 0x6BeF5C40723BaB057a5972f843454232EEE1Db50;
172:     bool public finalizedEthFundAddress = false;
173:     uint256 public totalEthFundRecieved; 
174:     uint256 public totalEthFundCollected; 
175: 
176:     
177:     uint256 public stakingRequirement = 25e18;
178: 
179:     
180:     mapping(address => bool) internal ambassadors_;
181:     uint256 constant internal ambassadorMaxPurchase_ = 0.5 ether;
182:     uint256 constant internal ambassadorQuota_ = 2.0 ether;
183: 
184: 
185: 
186:    
187: 
188: 
189:     
190:     mapping(address => uint256) internal tokenBalanceLedger_;
191:     mapping(address => uint256) internal referralBalance_;
192:     mapping(address => int256) internal payoutsTo_;
193:     mapping(address => uint256) internal ambassadorAccumulatedQuota_;
194:     uint256 internal tokenSupply_ = 0;
195:     uint256 internal profitPerShare_;
196: 
197:     
198:     mapping(address => bool) public administrators;
199: 
200:     
201:     bool public onlyAmbassadors = true;
202: 
203:     
204:     mapping(address => bool) public canAcceptTokens_; 
205: 
206:     mapping(address => address) public stickyRef;
207: 
208:     
209: 
210: 
211:     
212: 
213: 
214:     constructor()
215:         public
216:     {
217:         
218:         administrators[0x8c691931c6c4ECD92ECc26F9706FAaF4aebE137D] = true;
219: 
220:         
221:         ambassadors_[0x40a90c18Ec757a355D3dD96c8ef91762a335f524] = true;
222:         
223:         ambassadors_[0x5632CA98e5788edDB2397757Aa82d1Ed6171e5aD] = true;
224:         
225:         ambassadors_[0x8c691931c6c4ECD92ECc26F9706FAaF4aebE137D] = true;
226:         
227:         ambassadors_[0x53943B4b05Af138dD61FF957835B288d30cB8F0d] = true;
228:     }
229: 
230: 
231:     
232: 
233: 
234:     function buy(address _referredBy)
235:         public
236:         payable
237:         returns(uint256)
238:     {
239:         
240:         require(tx.gasprice <= 0.05 szabo);
241:         purchaseTokens(msg.value, _referredBy);
242:     }
243: 
244:     
245: 
246: 
247: 
248:     function()
249:         payable
250:         public
251:     {
252:         
253:         require(tx.gasprice <= 0.05 szabo);
254:         purchaseTokens(msg.value, 0x0);
255:     }
256: 
257:     function updateFundAddress(address _newAddress)
258:         onlyAdministrator()
259:         public
260:     {
261:         require(finalizedEthFundAddress == false);
262:         giveEthFundAddress = _newAddress;
263:     }
264: 
265:     function finalizeFundAddress(address _finalAddress)
266:         onlyAdministrator()
267:         public
268:     {
269:         require(finalizedEthFundAddress == false);
270:         giveEthFundAddress = _finalAddress;
271:         finalizedEthFundAddress = true;
272:     }
273: 
274:     
275: 
276: 
277: 
278:     function payFund() payable public {
279:         uint256 ethToPay = SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
280:         require(ethToPay > 0);
281:         totalEthFundRecieved = SafeMath.add(totalEthFundRecieved, ethToPay);
282:         if(!giveEthFundAddress.call.value(ethToPay)()) {
283:             revert();
284:         }
285:     }
286: 
287:     
288: 
289: 
290:     function reinvest()
291:         onlyStronghands()
292:         public
293:     {
294:         
295:         uint256 _dividends = myDividends(false); 
296: 
297:         
298:         address _customerAddress = msg.sender;
299:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
300: 
301:         
302:         _dividends += referralBalance_[_customerAddress];
303:         referralBalance_[_customerAddress] = 0;
304: 
305:         
306:         uint256 _tokens = purchaseTokens(_dividends, 0x0);
307: 
308:         
309:         emit onReinvestment(_customerAddress, _dividends, _tokens);
310:     }
311: 
312:     
313: 
314: 
315:     function exit()
316:         public
317:     {
318:         
319:         address _customerAddress = msg.sender;
320:         uint256 _tokens = tokenBalanceLedger_[_customerAddress];
321:         if(_tokens > 0) sell(_tokens);
322: 
323:         
324:         withdraw();
325:     }
326: 
327:     
328: 
329: 
330:     function withdraw()
331:         onlyStronghands()
332:         public
333:     {
334:         
335:         address _customerAddress = msg.sender;
336:         uint256 _dividends = myDividends(false); 
337: 
338:         
339:         payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
340: 
341:         
342:         _dividends += referralBalance_[_customerAddress];
343:         referralBalance_[_customerAddress] = 0;
344: 
345:         
346:         _customerAddress.transfer(_dividends);
347: 
348:         
349:         emit onWithdraw(_customerAddress, _dividends);
350:     }
351: 
352:     
353: 
354: 
355:     function sell(uint256 _amountOfTokens)
356:         onlyBagholders()
357:         public
358:     {
359:         
360:         address _customerAddress = msg.sender;
361:         
362:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
363:         uint256 _tokens = _amountOfTokens;
364:         uint256 _ethereum = tokensToEthereum_(_tokens);
365: 
366:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
367:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
368:         uint256 _refPayout = _dividends / 3;
369:         _dividends = SafeMath.sub(_dividends, _refPayout);
370:         (_dividends,) = handleRef(stickyRef[msg.sender], _refPayout, _dividends, 0);
371: 
372:         
373:         uint256 _taxedEthereum =  SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
374: 
375:         
376:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
377: 
378:         
379:         tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
380:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
381: 
382:         
383:         int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
384:         payoutsTo_[_customerAddress] -= _updatedPayouts;
385: 
386:         
387:         if (tokenSupply_ > 0) {
388:             
389:             profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
390:         }
391: 
392:         
393:         emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
394:     }
395: 
396: 
397:     
398: 
399: 
400: 
401:     function transfer(address _toAddress, uint256 _amountOfTokens)
402:         onlyBagholders()
403:         public
404:         returns(bool)
405:     {
406:         
407:         address _customerAddress = msg.sender;
408: 
409:         
410:         
411:         
412:         require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
413: 
414:         
415:         if(myDividends(true) > 0) withdraw();
416: 
417:         
418:         tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
419:         tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
420: 
421:         
422:         payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
423:         payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);
424: 
425: 
426:         
427:         emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
428: 
429:         
430:         return true;
431:     }
432: 
433:     
434: 
435: 
436: 
437: 
438: 
439: 
440: 
441:     function transferAndCall(address _to, uint256 _value, bytes _data) external returns (bool) {
442:       require(_to != address(0));
443:       require(canAcceptTokens_[_to] == true); 
444:       require(transfer(_to, _value)); 
445: 
446:       if (isContract(_to)) {
447:         AcceptsFUNDS receiver = AcceptsFUNDS(_to);
448:         require(receiver.tokenFallback(msg.sender, _value, _data));
449:       }
450: 
451:       return true;
452:     }
453: 
454:     
455: 
456: 
457: 
458:      function isContract(address _addr) private constant returns (bool is_contract) {
459:        
460:        uint length;
461:        assembly { length := extcodesize(_addr) }
462:        return length > 0;
463:      }
464: 
465:     
466:     
467: 
468: 
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
479:     function setAdministrator(address _identifier, bool _status)
480:         onlyAdministrator()
481:         public
482:     {
483:         administrators[_identifier] = _status;
484:     }
485: 
486:     
487: 
488: 
489:     function setStakingRequirement(uint256 _amountOfTokens)
490:         onlyAdministrator()
491:         public
492:     {
493:         stakingRequirement = _amountOfTokens;
494:     }
495: 
496:     
497: 
498: 
499:     function setCanAcceptTokens(address _address, bool _value)
500:       onlyAdministrator()
501:       public
502:     {
503:       canAcceptTokens_[_address] = _value;
504:     }
505: 
506:     
507: 
508: 
509:     function setName(string _name)
510:         onlyAdministrator()
511:         public
512:     {
513:         name = _name;
514:     }
515: 
516:     
517: 
518: 
519:     function setSymbol(string _symbol)
520:         onlyAdministrator()
521:         public
522:     {
523:         symbol = _symbol;
524:     }
525: 
526: 
527:     
528:     
529: 
530: 
531: 
532:     function totalEthereumBalance()
533:         public
534:         view
535:         returns(uint)
536:     {
537:         return address(this).balance;
538:     }
539: 
540:     
541: 
542: 
543:     function totalSupply()
544:         public
545:         view
546:         returns(uint256)
547:     {
548:         return tokenSupply_;
549:     }
550: 
551:     
552: 
553: 
554:     function myTokens()
555:         public
556:         view
557:         returns(uint256)
558:     {
559:         address _customerAddress = msg.sender;
560:         return balanceOf(_customerAddress);
561:     }
562: 
563:     
564: 
565: 
566: 
567: 
568: 
569:     function myDividends(bool _includeReferralBonus)
570:         public
571:         view
572:         returns(uint256)
573:     {
574:         address _customerAddress = msg.sender;
575:         return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
576:     }
577: 
578:     
579: 
580: 
581:     function balanceOf(address _customerAddress)
582:         view
583:         public
584:         returns(uint256)
585:     {
586:         return tokenBalanceLedger_[_customerAddress];
587:     }
588: 
589:     
590: 
591: 
592:     function dividendsOf(address _customerAddress)
593:         view
594:         public
595:         returns(uint256)
596:     {
597:         return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
598:     }
599: 
600:     
601: 
602: 
603:     function sellPrice()
604:         public
605:         view
606:         returns(uint256)
607:     {
608:         
609:         if(tokenSupply_ == 0){
610:             return tokenPriceInitial_ - tokenPriceIncremental_;
611:         } else {
612:             uint256 _ethereum = tokensToEthereum_(1e18);
613:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
614:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
615:             uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
616:             return _taxedEthereum;
617:         }
618:     }
619: 
620:     
621: 
622: 
623:     function buyPrice()
624:         public
625:         view
626:         returns(uint256)
627:     {
628:         
629:         if(tokenSupply_ == 0){
630:             return tokenPriceInitial_ + tokenPriceIncremental_;
631:         } else {
632:             uint256 _ethereum = tokensToEthereum_(1e18);
633:             uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
634:             uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
635:             uint256 _taxedEthereum =  SafeMath.add(SafeMath.add(_ethereum, _dividends), _fundPayout);
636:             return _taxedEthereum;
637:         }
638:     }
639: 
640:     
641: 
642: 
643:     function calculateTokensReceived(uint256 _ethereumToSpend)
644:         public
645:         view
646:         returns(uint256)
647:     {
648:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, dividendFee_), 100);
649:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereumToSpend, fundFee_), 100);
650:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereumToSpend, _dividends), _fundPayout);
651:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
652:         return _amountOfTokens;
653:     }
654: 
655:     
656: 
657: 
658:     function calculateEthereumReceived(uint256 _tokensToSell)
659:         public
660:         view
661:         returns(uint256)
662:     {
663:         require(_tokensToSell <= tokenSupply_);
664:         uint256 _ethereum = tokensToEthereum_(_tokensToSell);
665:         uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, dividendFee_), 100);
666:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_ethereum, fundFee_), 100);
667:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_ethereum, _dividends), _fundPayout);
668:         return _taxedEthereum;
669:     }
670: 
671:     
672: 
673: 
674:     function etherToSendFund()
675:         public
676:         view
677:         returns(uint256) {
678:         return SafeMath.sub(totalEthFundCollected, totalEthFundRecieved);
679:     }
680: 
681: 
682:     
683: 
684: 
685: 
686:     
687:     function purchaseInternal(uint256 _incomingEthereum, address _referredBy)
688:       notContract()
689:       internal
690:       returns(uint256) {
691: 
692:       uint256 purchaseEthereum = _incomingEthereum;
693:       uint256 excess;
694:       if(purchaseEthereum > 2.5 ether) { 
695:           if (SafeMath.sub(address(this).balance, purchaseEthereum) <= 100 ether) { 
696:               purchaseEthereum = 2.5 ether;
697:               excess = SafeMath.sub(_incomingEthereum, purchaseEthereum);
698:           }
699:       }
700: 
701:       purchaseTokens(purchaseEthereum, _referredBy);
702: 
703:       if (excess > 0) {
704:         msg.sender.transfer(excess);
705:       }
706:     }
707: 
708:     function handleRef(address _ref, uint _referralBonus, uint _currentDividends, uint _currentFee) internal returns (uint, uint){
709:         uint _dividends = _currentDividends;
710:         uint _fee = _currentFee;
711:         address _referredBy = stickyRef[msg.sender];
712:         if (_referredBy == address(0x0)){
713:             _referredBy = _ref;
714:         }
715:         
716:         if(
717:             
718:             _referredBy != 0x0000000000000000000000000000000000000000 &&
719: 
720:             
721:             _referredBy != msg.sender &&
722: 
723:             
724:             
725:             tokenBalanceLedger_[_referredBy] >= stakingRequirement
726:         ){
727:             
728:             if (stickyRef[msg.sender] == address(0x0)){
729:                 stickyRef[msg.sender] = _referredBy;
730:             }
731:             referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus/2);
732:             address currentRef = stickyRef[_referredBy];
733:             if (currentRef != address(0x0) && tokenBalanceLedger_[currentRef] >= stakingRequirement){
734:                 referralBalance_[currentRef] = SafeMath.add(referralBalance_[currentRef], (_referralBonus/10)*3);
735:                 currentRef = stickyRef[currentRef];
736:                 if (currentRef != address(0x0) && tokenBalanceLedger_[currentRef] >= stakingRequirement){
737:                     referralBalance_[currentRef] = SafeMath.add(referralBalance_[currentRef], (_referralBonus/10)*2);
738:                 }
739:                 else{
740:                     _dividends = SafeMath.add(_dividends, _referralBonus - _referralBonus/2 - (_referralBonus/10)*3);
741:                     _fee = _dividends * magnitude;
742:                 }
743:             }
744:             else{
745:                 _dividends = SafeMath.add(_dividends, _referralBonus - _referralBonus/2);
746:                 _fee = _dividends * magnitude;
747:             }
748:             
749:             
750:         } else {
751:             
752:             
753:             _dividends = SafeMath.add(_dividends, _referralBonus);
754:             _fee = _dividends * magnitude;
755:         }
756:         return (_dividends, _fee);
757:     }
758: 
759: 
760:     function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
761:         antiEarlyWhale(_incomingEthereum)
762:         internal
763:         returns(uint256)
764:     {
765:         
766:         uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, dividendFee_), 100);
767:         uint256 _referralBonus = SafeMath.div(_undividedDividends, 3);
768:         uint256 _fundPayout = SafeMath.div(SafeMath.mul(_incomingEthereum, fundFee_), 100);
769:         uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
770:         uint256 _fee;
771:         (_dividends, _fee) = handleRef(_referredBy, _referralBonus, _dividends, _fee);
772:         uint256 _taxedEthereum = SafeMath.sub(SafeMath.sub(_incomingEthereum, _dividends), _fundPayout);
773:         totalEthFundCollected = SafeMath.add(totalEthFundCollected, _fundPayout);
774: 
775:         uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
776: 
777: 
778:         
779:         
780:         
781:         
782:         require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
783: 
784: 
785: 
786:         
787:         if(tokenSupply_ > 0){
788:  
789:             
790:             tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
791: 
792:             
793:             profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
794: 
795:             
796:             _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
797: 
798:         } else {
799:             
800:             tokenSupply_ = _amountOfTokens;
801:         }
802: 
803:         
804:         tokenBalanceLedger_[msg.sender] = SafeMath.add(tokenBalanceLedger_[msg.sender], _amountOfTokens);
805: 
806:         
807:         
808:         int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
809:         payoutsTo_[msg.sender] += _updatedPayouts;
810: 
811:         
812:         emit onTokenPurchase(msg.sender, _incomingEthereum, _amountOfTokens, _referredBy);
813: 
814:         return _amountOfTokens;
815:     }
816: 
817:     
818: 
819: 
820: 
821: 
822:     function ethereumToTokens_(uint256 _ethereum)
823:         internal
824:         view
825:         returns(uint256)
826:     {
827:         uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
828:         uint256 _tokensReceived =
829:          (
830:             (
831:                 
832:                 SafeMath.sub(
833:                     (sqrt
834:                         (
835:                             (_tokenPriceInitial**2)
836:                             +
837:                             (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
838:                             +
839:                             (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
840:                             +
841:                             (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
842:                         )
843:                     ), _tokenPriceInitial
844:                 )
845:             )/(tokenPriceIncremental_)
846:         )-(tokenSupply_)
847:         ;
848: 
849:         return _tokensReceived;
850:     }
851: 
852:     
853: 
854: 
855: 
856: 
857:      function tokensToEthereum_(uint256 _tokens)
858:         internal
859:         view
860:         returns(uint256)
861:     {
862: 
863:         uint256 tokens_ = (_tokens + 1e18);
864:         uint256 _tokenSupply = (tokenSupply_ + 1e18);
865:         uint256 _etherReceived =
866:         (
867:             
868:             SafeMath.sub(
869:                 (
870:                     (
871:                         (
872:                             tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
873:                         )-tokenPriceIncremental_
874:                     )*(tokens_ - 1e18)
875:                 ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
876:             )
877:         /1e18);
878:         return _etherReceived;
879:     }
880: 
881: 
882:     
883:     
884:     function sqrt(uint x) internal pure returns (uint y) {
885:         uint z = (x + 1) / 2;
886:         y = x;
887:         while (z < y) {
888:             y = z;
889:             z = (x / z + z) / 2;
890:         }
891:     }
892: }
893: 
894: 
895: 
896: 
897: 
898: library SafeMath {
899: 
900:     
901: 
902: 
903:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
904:         if (a == 0) {
905:             return 0;
906:         }
907:         uint256 c = a * b;
908:         assert(c / a == b);
909:         return c;
910:     }
911: 
912:     
913: 
914: 
915:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
916:         
917:         uint256 c = a / b;
918:         
919:         return c;
920:     }
921: 
922:     
923: 
924: 
925:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
926:         assert(b <= a);
927:         return a - b;
928:     }
929: 
930:     
931: 
932: 
933:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
934:         uint256 c = a + b;
935:         assert(c >= a);
936:         return c;
937:     }
938: }