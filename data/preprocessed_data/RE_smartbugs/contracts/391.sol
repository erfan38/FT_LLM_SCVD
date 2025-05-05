1: pragma solidity ^0.4.24;
2: 
3: contract F3DGo is modularShort {
4:     using SafeMath for *;
5:     using NameFilter for string;
6:     using F3DKeysCalcShort for uint256;
7: 
8:     PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0x82e0C3626622d9a8234BFBaf6DD0f8d070C2609D);
9: 
10: 
11: 
12: 
13: 
14:     address private admin = 0xacb257873b064b956BD9be84dc347C55F7b2ae8C;
15:     address private coin_base = 0x345A756a49DF0eD24002857dd25DAb6a5F4E83FF;
16:     string constant public name = "F3DGo";
17:     string constant public symbol = "F3DGo";
18:     uint256 private rndExtra_ = 0;     
19:     uint256 private rndGap_ = 2 minutes;         
20:     uint256 constant private rndInit_ = 8 minutes;                
21:     uint256 constant private rndInc_ = 30 seconds;              
22:     uint256 constant private rndMax_ = 6 hours;                
23: 
24: 
25: 
26: 
27:     uint256 public airDropPot_;             
28:     uint256 public airDropTracker_ = 0;     
29:     uint256 public rID_;    
30: 
31: 
32: 
33:     mapping (address => uint256) public pIDxAddr_;          
34:     mapping (bytes32 => uint256) public pIDxName_;          
35:     mapping (uint256 => F3Ddatasets.Player) public plyr_;   
36:     mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;    
37:     mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; 
38: 
39: 
40: 
41:     mapping (uint256 => F3Ddatasets.Round) public round_;   
42:     mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      
43: 
44: 
45: 
46:     mapping (uint256 => F3Ddatasets.TeamFee) public fees_;          
47:     mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;     
48: 
49: 
50: 
51: 
52:     constructor()
53:         public
54:     {
55: 		
56:         
57:         
58:         
59:         
60: 
61: 		
62:         
63:             
64:         fees_[0] = F3Ddatasets.TeamFee(22,6);   
65:         fees_[1] = F3Ddatasets.TeamFee(38,0);   
66:         fees_[2] = F3Ddatasets.TeamFee(52,10);  
67:         fees_[3] = F3Ddatasets.TeamFee(68,8);   
68: 
69:         
70:         
71:         potSplit_[0] = F3Ddatasets.PotSplit(15,10);  
72:         potSplit_[1] = F3Ddatasets.PotSplit(25,0);   
73:         potSplit_[2] = F3Ddatasets.PotSplit(20,20);  
74:         potSplit_[3] = F3Ddatasets.PotSplit(30,10);  
75: 	}
76: 
77: 
78: 
79: 
80:     
81: 
82: 
83: 
84:     modifier isActivated() {
85:         require(activated_ == true, "its not ready yet.  check ?eta in discord");
86:         _;
87:     }
88: 
89:     
90: 
91: 
92:     modifier isHuman() {
93:         address _addr = msg.sender;
94:         uint256 _codeLength;
95: 
96:         assembly {_codeLength := extcodesize(_addr)}
97:         require(_codeLength == 0, "sorry humans only");
98:         _;
99:     }
100: 
101:     
102: 
103: 
104:     modifier isWithinLimits(uint256 _eth) {
105:         require(_eth >= 1000000000, "pocket lint: not a valid currency");
106:         require(_eth <= 100000000000000000000000, "no vitalik, no");
107:         _;
108:     }
109: 
110: 
111: 
112: 
113: 
114:     
115: 
116: 
117:     function()
118:         isActivated()
119:         isHuman()
120:         isWithinLimits(msg.value)
121:         public
122:         payable
123:     {
124:         
125:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
126: 
127:         
128:         uint256 _pID = pIDxAddr_[msg.sender];
129: 
130:         
131:         buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
132:     }
133: 
134:     
135: 
136: 
137: 
138: 
139: 
140: 
141: 
142:     function buyXid(uint256 _affCode, uint256 _team)
143:         isActivated()
144:         isHuman()
145:         isWithinLimits(msg.value)
146:         public
147:         payable
148:     {
149:         
150:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
151: 
152:         
153:         uint256 _pID = pIDxAddr_[msg.sender];
154: 
155:         
156:         
157:         if (_affCode == 0 || _affCode == _pID)
158:         {
159:             
160:             _affCode = plyr_[_pID].laff;
161: 
162:         
163:         } else if (_affCode != plyr_[_pID].laff) {
164:             
165:             plyr_[_pID].laff = _affCode;
166:         }
167: 
168:         
169:         _team = verifyTeam(_team);
170: 
171:         
172:         buyCore(_pID, _affCode, _team, _eventData_);
173:     }
174: 
175:     function buyXaddr(address _affCode, uint256 _team)
176:         isActivated()
177:         isHuman()
178:         isWithinLimits(msg.value)
179:         public
180:         payable
181:     {
182:         
183:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
184: 
185:         
186:         uint256 _pID = pIDxAddr_[msg.sender];
187: 
188:         
189:         uint256 _affID;
190:         
191:         if (_affCode == address(0) || _affCode == msg.sender)
192:         {
193:             
194:             _affID = plyr_[_pID].laff;
195: 
196:         
197:         } else {
198:             
199:             _affID = pIDxAddr_[_affCode];
200: 
201:             
202:             if (_affID != plyr_[_pID].laff)
203:             {
204:                 
205:                 plyr_[_pID].laff = _affID;
206:             }
207:         }
208: 
209:         
210:         _team = verifyTeam(_team);
211: 
212:         
213:         buyCore(_pID, _affID, _team, _eventData_);
214:     }
215: 
216:     function buyXname(bytes32 _affCode, uint256 _team)
217:         isActivated()
218:         isHuman()
219:         isWithinLimits(msg.value)
220:         public
221:         payable
222:     {
223:         
224:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
225: 
226:         
227:         uint256 _pID = pIDxAddr_[msg.sender];
228: 
229:         
230:         uint256 _affID;
231:         
232:         if (_affCode == '' || _affCode == plyr_[_pID].name)
233:         {
234:             
235:             _affID = plyr_[_pID].laff;
236: 
237:         
238:         } else {
239:             
240:             _affID = pIDxName_[_affCode];
241: 
242:             
243:             if (_affID != plyr_[_pID].laff)
244:             {
245:                 
246:                 plyr_[_pID].laff = _affID;
247:             }
248:         }
249: 
250:         
251:         _team = verifyTeam(_team);
252: 
253:         
254:         buyCore(_pID, _affID, _team, _eventData_);
255:     }
256: 
257:     
258: 
259: 
260: 
261: 
262: 
263: 
264: 
265: 
266: 
267:     function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
268:         isActivated()
269:         isHuman()
270:         isWithinLimits(_eth)
271:         public
272:     {
273:         
274:         F3Ddatasets.EventReturns memory _eventData_;
275: 
276:         
277:         uint256 _pID = pIDxAddr_[msg.sender];
278: 
279:         
280:         
281:         if (_affCode == 0 || _affCode == _pID)
282:         {
283:             
284:             _affCode = plyr_[_pID].laff;
285: 
286:         
287:         } else if (_affCode != plyr_[_pID].laff) {
288:             
289:             plyr_[_pID].laff = _affCode;
290:         }
291: 
292:         
293:         _team = verifyTeam(_team);
294: 
295:         
296:         reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
297:     }
298: 
299:     function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
300:         isActivated()
301:         isHuman()
302:         isWithinLimits(_eth)
303:         public
304:     {
305:         
306:         F3Ddatasets.EventReturns memory _eventData_;
307: 
308:         
309:         uint256 _pID = pIDxAddr_[msg.sender];
310: 
311:         
312:         uint256 _affID;
313:         
314:         if (_affCode == address(0) || _affCode == msg.sender)
315:         {
316:             
317:             _affID = plyr_[_pID].laff;
318: 
319:         
320:         } else {
321:             
322:             _affID = pIDxAddr_[_affCode];
323: 
324:             
325:             if (_affID != plyr_[_pID].laff)
326:             {
327:                 
328:                 plyr_[_pID].laff = _affID;
329:             }
330:         }
331: 
332:         
333:         _team = verifyTeam(_team);
334: 
335:         
336:         reLoadCore(_pID, _affID, _team, _eth, _eventData_);
337:     }
338: 
339:     function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
340:         isActivated()
341:         isHuman()
342:         isWithinLimits(_eth)
343:         public
344:     {
345:         
346:         F3Ddatasets.EventReturns memory _eventData_;
347: 
348:         
349:         uint256 _pID = pIDxAddr_[msg.sender];
350: 
351:         
352:         uint256 _affID;
353:         
354:         if (_affCode == '' || _affCode == plyr_[_pID].name)
355:         {
356:             
357:             _affID = plyr_[_pID].laff;
358: 
359:         
360:         } else {
361:             
362:             _affID = pIDxName_[_affCode];
363: 
364:             
365:             if (_affID != plyr_[_pID].laff)
366:             {
367:                 
368:                 plyr_[_pID].laff = _affID;
369:             }
370:         }
371: 
372:         
373:         _team = verifyTeam(_team);
374: 
375:         
376:         reLoadCore(_pID, _affID, _team, _eth, _eventData_);
377:     }
378: 
379:     
380: 
381: 
382: 
383:     function withdraw()
384:         isActivated()
385:         isHuman()
386:         public
387:     {
388:         
389:         uint256 _rID = rID_;
390: 
391:         
392:         uint256 _now = now;
393: 
394:         
395:         uint256 _pID = pIDxAddr_[msg.sender];
396: 
397:         
398:         uint256 _eth;
399: 
400:         
401:         if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
402:         {
403:             
404:             F3Ddatasets.EventReturns memory _eventData_;
405: 
406:             
407: 			round_[_rID].ended = true;
408:             _eventData_ = endRound(_eventData_);
409: 
410: 			
411:             _eth = withdrawEarnings(_pID);
412: 
413:             
414:             if (_eth > 0)
415:                 plyr_[_pID].addr.transfer(_eth);
416: 
417:             
418:             _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
419:             _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
420: 
421:             
422:             emit F3Devents.onWithdrawAndDistribute
423:             (
424:                 msg.sender,
425:                 plyr_[_pID].name,
426:                 _eth,
427:                 _eventData_.compressedData,
428:                 _eventData_.compressedIDs,
429:                 _eventData_.winnerAddr,
430:                 _eventData_.winnerName,
431:                 _eventData_.amountWon,
432:                 _eventData_.newPot,
433:                 _eventData_.P3DAmount,
434:                 _eventData_.genAmount
435:             );
436: 
437:         
438:         } else {
439:             
440:             _eth = withdrawEarnings(_pID);
441: 
442:             
443:             if (_eth > 0)
444:                 plyr_[_pID].addr.transfer(_eth);
445: 
446:             
447:             emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
448:         }
449:     }
450: 
451:     
452: 
453: 
454: 
455: 
456: 
457: 
458: 
459: 
460: 
461: 
462: 
463: 
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
475:     function registerNameXID(string _nameString, uint256 _affCode, bool _all)
476:         isHuman()
477:         public
478:         payable
479:     {
480:         bytes32 _name = _nameString.nameFilter();
481:         address _addr = msg.sender;
482:         uint256 _paid = msg.value;
483:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);
484: 
485:         uint256 _pID = pIDxAddr_[_addr];
486: 
487:         
488:         emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
489:     }
490: 
491:     function registerNameXaddr(string _nameString, address _affCode, bool _all)
492:         isHuman()
493:         public
494:         payable
495:     {
496:         bytes32 _name = _nameString.nameFilter();
497:         address _addr = msg.sender;
498:         uint256 _paid = msg.value;
499:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
500: 
501:         uint256 _pID = pIDxAddr_[_addr];
502: 
503:         
504:         emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
505:     }
506: 
507:     function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
508:         isHuman()
509:         public
510:         payable
511:     {
512:         bytes32 _name = _nameString.nameFilter();
513:         address _addr = msg.sender;
514:         uint256 _paid = msg.value;
515:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
516: 
517:         uint256 _pID = pIDxAddr_[_addr];
518: 
519:         
520:         emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
521:     }
522: 
523: 
524: 
525: 
526:     
527: 
528: 
529: 
530: 
531:     function getBuyPrice()
532:         public
533:         view
534:         returns(uint256)
535:     {
536:         
537:         uint256 _rID = rID_;
538: 
539:         
540:         uint256 _now = now;
541: 
542:         
543:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
544:             return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
545:         else 
546:             return ( 75000000000000 ); 
547:     }
548: 
549:     
550: 
551: 
552: 
553: 
554: 
555:     function getTimeLeft()
556:         public
557:         view
558:         returns(uint256)
559:     {
560:         
561:         uint256 _rID = rID_;
562: 
563:         
564:         uint256 _now = now;
565: 
566:         if (_now < round_[_rID].end)
567:             if (_now > round_[_rID].strt + rndGap_)
568:                 return( (round_[_rID].end).sub(_now) );
569:             else
570:                 return( (round_[_rID].strt + rndGap_).sub(_now) );
571:         else
572:             return(0);
573:     }
574: 
575:     
576: 
577: 
578: 
579: 
580: 
581: 
582:     function getPlayerVaults(uint256 _pID)
583:         public
584:         view
585:         returns(uint256 ,uint256, uint256)
586:     {
587:         
588:         uint256 _rID = rID_;
589: 
590:         
591:         if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
592:         {
593:             
594:             if (round_[_rID].plyr == _pID)
595:             {
596:                 return
597:                 (
598:                     (plyr_[_pID].win).add( ((round_[_rID].pot).mul(48)) / 100 ),
599:                     (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
600:                     plyr_[_pID].aff
601:                 );
602:             
603:             } else {
604:                 return
605:                 (
606:                     plyr_[_pID].win,
607:                     (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
608:                     plyr_[_pID].aff
609:                 );
610:             }
611: 
612:         
613:         } else {
614:             return
615:             (
616:                 plyr_[_pID].win,
617:                 (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
618:                 plyr_[_pID].aff
619:             );
620:         }
621:     }
622: 
623:     
624: 
625: 
626:     function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
627:         private
628:         view
629:         returns(uint256)
630:     {
631:         return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
632:     }
633: 
634:     
635: 
636: 
637: 
638: 
639: 
640: 
641: 
642: 
643: 
644: 
645: 
646: 
647: 
648: 
649: 
650: 
651: 
652:     function getCurrentRoundInfo()
653:         public
654:         view
655:         returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
656:     {
657:         
658:         uint256 _rID = rID_;
659: 
660:         return
661:         (
662:             round_[_rID].ico,               
663:             _rID,                           
664:             round_[_rID].keys,              
665:             round_[_rID].end,               
666:             round_[_rID].strt,              
667:             round_[_rID].pot,               
668:             (round_[_rID].team + (round_[_rID].plyr * 10)),     
669:             plyr_[round_[_rID].plyr].addr,  
670:             plyr_[round_[_rID].plyr].name,  
671:             rndTmEth_[_rID][0],             
672:             rndTmEth_[_rID][1],             
673:             rndTmEth_[_rID][2],             
674:             rndTmEth_[_rID][3],             
675:             airDropTracker_ + (airDropPot_ * 1000)              
676:         );
677:     }
678: 
679:     
680: 
681: 
682: 
683: 
684: 
685: 
686: 
687: 
688: 
689: 
690: 
691: 
692:     function getPlayerInfoByAddress(address _addr)
693:         public
694:         view
695:         returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
696:     {
697:         
698:         uint256 _rID = rID_;
699: 
700:         if (_addr == address(0))
701:         {
702:             _addr == msg.sender;
703:         }
704:         uint256 _pID = pIDxAddr_[_addr];
705: 
706:         return
707:         (
708:             _pID,                               
709:             plyr_[_pID].name,                   
710:             plyrRnds_[_pID][_rID].keys,         
711:             plyr_[_pID].win,                    
712:             (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       
713:             plyr_[_pID].aff,                    
714:             plyrRnds_[_pID][_rID].eth           
715:         );
716:     }
717: 
718: 
719: 
720: 
721: 
722:     
723: 
724: 
725: 
726:     function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
727:         private
728:     {
729:         
730:         uint256 _rID = rID_;
731: 
732:         
733:         uint256 _now = now;
734: 
735:         
736:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
737:         {
738:             
739:             core(_rID, _pID, msg.value, _affID, _team, _eventData_);
740: 
741:         
742:         } else {
743:             
744:             if (_now > round_[_rID].end && round_[_rID].ended == false)
745:             {
746:                 
747: 			    round_[_rID].ended = true;
748:                 _eventData_ = endRound(_eventData_);
749: 
750:                 
751:                 _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
752:                 _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
753: 
754:                 
755:                 emit F3Devents.onBuyAndDistribute
756:                 (
757:                     msg.sender,
758:                     plyr_[_pID].name,
759:                     msg.value,
760:                     _eventData_.compressedData,
761:                     _eventData_.compressedIDs,
762:                     _eventData_.winnerAddr,
763:                     _eventData_.winnerName,
764:                     _eventData_.amountWon,
765:                     _eventData_.newPot,
766:                     _eventData_.P3DAmount,
767:                     _eventData_.genAmount
768:                 );
769:             }
770: 
771:             
772:             plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
773:         }
774:     }
775: 
776:     
777: 
778: 
779: 
780:     function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
781:         private
782:     {
783:         
784:         uint256 _rID = rID_;
785: 
786:         
787:         uint256 _now = now;
788: 
789:         
790:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
791:         {
792:             
793:             
794:             
795:             plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
796: 
797:             
798:             core(_rID, _pID, _eth, _affID, _team, _eventData_);
799: 
800:         
801:         } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
802:             
803:             round_[_rID].ended = true;
804:             _eventData_ = endRound(_eventData_);
805: 
806:             
807:             _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
808:             _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
809: 
810:             
811:             emit F3Devents.onReLoadAndDistribute
812:             (
813:                 msg.sender,
814:                 plyr_[_pID].name,
815:                 _eventData_.compressedData,
816:                 _eventData_.compressedIDs,
817:                 _eventData_.winnerAddr,
818:                 _eventData_.winnerName,
819:                 _eventData_.amountWon,
820:                 _eventData_.newPot,
821:                 _eventData_.P3DAmount,
822:                 _eventData_.genAmount
823:             );
824:         }
825:     }
826: 
827:     
828: 
829: 
830: 
831:     function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
832:         private
833:     {
834:         
835:         if (plyrRnds_[_pID][_rID].keys == 0)
836:             _eventData_ = managePlayer(_pID, _eventData_);
837: 
838:         
839:         if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000)
840:         {
841:             uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
842:             uint256 _refund = _eth.sub(_availableLimit);
843:             plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
844:             _eth = _availableLimit;
845:         }
846: 
847:         
848:         if (_eth > 1000000000)
849:         {
850: 
851:             
852:             uint256 _keys = (round_[_rID].eth).keysRec(_eth);
853: 
854:             
855:             if (_keys >= 1000000000000000000)
856:             {
857:             updateTimer(_keys, _rID);
858: 
859:             
860:             if (round_[_rID].plyr != _pID)
861:                 round_[_rID].plyr = _pID;
862:             if (round_[_rID].team != _team)
863:                 round_[_rID].team = _team;
864: 
865:             
866:             _eventData_.compressedData = _eventData_.compressedData + 100;
867:         }
868: 
869:             
870:             if (_eth >= 100000000000000000)
871:             {
872:             airDropTracker_++;
873:             if (airdrop() == true)
874:             {
875:                 
876:                 uint256 _prize;
877:                 if (_eth >= 10000000000000000000)
878:                 {
879:                     
880:                     _prize = ((airDropPot_).mul(75)) / 100;
881:                     plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
882: 
883:                     
884:                     airDropPot_ = (airDropPot_).sub(_prize);
885: 
886:                     
887:                     _eventData_.compressedData += 300000000000000000000000000000000;
888:                 } else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
889:                     
890:                     _prize = ((airDropPot_).mul(50)) / 100;
891:                     plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
892: 
893:                     
894:                     airDropPot_ = (airDropPot_).sub(_prize);
895: 
896:                     
897:                     _eventData_.compressedData += 200000000000000000000000000000000;
898:                 } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
899:                     
900:                     _prize = ((airDropPot_).mul(25)) / 100;
901:                     plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
902: 
903:                     
904:                     airDropPot_ = (airDropPot_).sub(_prize);
905: 
906:                     
907:                     _eventData_.compressedData += 300000000000000000000000000000000;
908:                 }
909:                 
910:                 _eventData_.compressedData += 10000000000000000000000000000000;
911:                 
912:                 _eventData_.compressedData += _prize * 1000000000000000000000000000000000;
913: 
914:                 
915:                 airDropTracker_ = 0;
916:             }
917:         }
918: 
919:             
920:             _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
921: 
922:             
923:             plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
924:             plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
925: 
926:             
927:             round_[_rID].keys = _keys.add(round_[_rID].keys);
928:             round_[_rID].eth = _eth.add(round_[_rID].eth);
929:             rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);
930: 
931:             
932:             _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
933:             _eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);
934: 
935:             
936: 		    endTx(_pID, _team, _eth, _keys, _eventData_);
937:         }
938:     }
939: 
940: 
941: 
942: 
943:     
944: 
945: 
946: 
947:     function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
948:         private
949:         view
950:         returns(uint256)
951:     {
952:         return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
953:     }
954: 
955:     
956: 
957: 
958: 
959: 
960: 
961: 
962:     function calcKeysReceived(uint256 _rID, uint256 _eth)
963:         public
964:         view
965:         returns(uint256)
966:     {
967:         
968:         uint256 _now = now;
969: 
970:         
971:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
972:             return ( (round_[_rID].eth).keysRec(_eth) );
973:         else 
974:             return ( (_eth).keys() );
975:     }
976: 
977:     
978: 
979: 
980: 
981: 
982: 
983:     function iWantXKeys(uint256 _keys)
984:         public
985:         view
986:         returns(uint256)
987:     {
988:         
989:         uint256 _rID = rID_;
990: 
991:         
992:         uint256 _now = now;
993: 
994:         
995:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
996:             return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
997:         else 
998:             return ( (_keys).eth() );
999:     }
1000: 
1001: 
1002: 
1003: 
1004:     
1005: 
1006: 
1007:     function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
1008:         external
1009:     {
1010:         require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
1011:         if (pIDxAddr_[_addr] != _pID)
1012:             pIDxAddr_[_addr] = _pID;
1013:         if (pIDxName_[_name] != _pID)
1014:             pIDxName_[_name] = _pID;
1015:         if (plyr_[_pID].addr != _addr)
1016:             plyr_[_pID].addr = _addr;
1017:         if (plyr_[_pID].name != _name)
1018:             plyr_[_pID].name = _name;
1019:         if (plyr_[_pID].laff != _laff)
1020:             plyr_[_pID].laff = _laff;
1021:         if (plyrNames_[_pID][_name] == false)
1022:             plyrNames_[_pID][_name] = true;
1023:     }
1024: 
1025:     
1026: 
1027: 
1028:     function receivePlayerNameList(uint256 _pID, bytes32 _name)
1029:         external
1030:     {
1031:         require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
1032:         if(plyrNames_[_pID][_name] == false)
1033:             plyrNames_[_pID][_name] = true;
1034:     }
1035: 
1036:     
1037: 
1038: 
1039: 
1040:     function determinePID(F3Ddatasets.EventReturns memory _eventData_)
1041:         private
1042:         returns (F3Ddatasets.EventReturns)
1043:     {
1044:         uint256 _pID = pIDxAddr_[msg.sender];
1045:         
1046:         if (_pID == 0)
1047:         {
1048:             
1049:             _pID = PlayerBook.getPlayerID(msg.sender);
1050:             bytes32 _name = PlayerBook.getPlayerName(_pID);
1051:             uint256 _laff = PlayerBook.getPlayerLAff(_pID);
1052: 
1053:             
1054:             pIDxAddr_[msg.sender] = _pID;
1055:             plyr_[_pID].addr = msg.sender;
1056: 
1057:             if (_name != "")
1058:             {
1059:                 pIDxName_[_name] = _pID;
1060:                 plyr_[_pID].name = _name;
1061:                 plyrNames_[_pID][_name] = true;
1062:             }
1063: 
1064:             if (_laff != 0 && _laff != _pID)
1065:                 plyr_[_pID].laff = _laff;
1066: 
1067:             
1068:             _eventData_.compressedData = _eventData_.compressedData + 1;
1069:         }
1070:         return (_eventData_);
1071:     }
1072: 
1073:     
1074: 
1075: 
1076: 
1077:     function verifyTeam(uint256 _team)
1078:         private
1079:         pure
1080:         returns (uint256)
1081:     {
1082:         if (_team < 0 || _team > 3)
1083:             return(2);
1084:         else
1085:             return(_team);
1086:     }
1087: 
1088:     
1089: 
1090: 
1091: 
1092:     function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
1093:         private
1094:         returns (F3Ddatasets.EventReturns)
1095:     {
1096:         
1097:         
1098:         if (plyr_[_pID].lrnd != 0)
1099:             updateGenVault(_pID, plyr_[_pID].lrnd);
1100: 
1101:         
1102:         plyr_[_pID].lrnd = rID_;
1103: 
1104:         
1105:         _eventData_.compressedData = _eventData_.compressedData + 10;
1106: 
1107:         return(_eventData_);
1108:     }
1109: 
1110:     
1111: 
1112: 
1113:     function endRound(F3Ddatasets.EventReturns memory _eventData_)
1114:         private
1115:         returns (F3Ddatasets.EventReturns)
1116:     {
1117:         
1118:         uint256 _rID = rID_;
1119: 
1120:         
1121:         uint256 _winPID = round_[_rID].plyr;
1122:         uint256 _winTID = round_[_rID].team;
1123: 
1124:         
1125:         uint256 _pot = round_[_rID].pot;
1126: 
1127:         
1128:         
1129:         uint256 _win = (_pot.mul(48)) / 100;
1130:         uint256 _com = (_pot / 50);
1131:         uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
1132:         uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;
1133:         uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);
1134: 
1135:         
1136:         uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
1137:         uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
1138:         if (_dust > 0)
1139:         {
1140:             _gen = _gen.sub(_dust);
1141:             _res = _res.add(_dust);
1142:         }
1143: 
1144:         
1145:         plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
1146: 
1147:         
1148:         _com = _com.add(_p3d.sub(_p3d / 2));
1149:         coin_base.transfer(_com);
1150: 
1151:         _res = _res.add(_p3d / 2);
1152: 
1153:         
1154:         round_[_rID].mask = _ppt.add(round_[_rID].mask);
1155: 
1156:         
1157:         _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
1158:         _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
1159:         _eventData_.winnerAddr = plyr_[_winPID].addr;
1160:         _eventData_.winnerName = plyr_[_winPID].name;
1161:         _eventData_.amountWon = _win;
1162:         _eventData_.genAmount = _gen;
1163:         _eventData_.P3DAmount = _p3d;
1164:         _eventData_.newPot = _res;
1165: 
1166:         
1167:         rID_++;
1168:         _rID++;
1169:         round_[_rID].strt = now;
1170:         round_[_rID].end = now.add(rndInit_).add(rndGap_);
1171:         round_[_rID].pot = _res;
1172: 
1173:         return(_eventData_);
1174:     }
1175: 
1176:     
1177: 
1178: 
1179:     function updateGenVault(uint256 _pID, uint256 _rIDlast)
1180:         private
1181:     {
1182:         uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
1183:         if (_earnings > 0)
1184:         {
1185:             
1186:             plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
1187:             
1188:             plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
1189:         }
1190:     }
1191: 
1192:     
1193: 
1194: 
1195:     function updateTimer(uint256 _keys, uint256 _rID)
1196:         private
1197:     {
1198:         
1199:         uint256 _now = now;
1200: 
1201:         
1202:         uint256 _newTime;
1203:         if (_now > round_[_rID].end && round_[_rID].plyr == 0)
1204:             _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
1205:         else
1206:             _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
1207: 
1208:         
1209:         if (_newTime < (rndMax_).add(_now))
1210:             round_[_rID].end = _newTime;
1211:         else
1212:             round_[_rID].end = rndMax_.add(_now);
1213:     }
1214: 
1215:     
1216: 
1217: 
1218: 
1219: 
1220:     function airdrop()
1221:         private
1222:         view
1223:         returns(bool)
1224:     {
1225:         uint256 seed = uint256(keccak256(abi.encodePacked(
1226: 
1227:             (block.timestamp).add
1228:             (block.difficulty).add
1229:             ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
1230:             (block.gaslimit).add
1231:             ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
1232:             (block.number)
1233: 
1234:         )));
1235:         if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
1236:             return(true);
1237:         else
1238:             return(false);
1239:     }
1240: 
1241:     
1242: 
1243: 
1244:     function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
1245:         private
1246:         returns(F3Ddatasets.EventReturns)
1247:     {
1248:         
1249:         uint256 _p1 = _eth / 100;
1250:         uint256 _com = _eth / 50;
1251:         _com = _com.add(_p1);
1252: 
1253:         uint256 _p3d;
1254:         if (!address(coin_base).call.value(_com)())
1255:         {
1256:             
1257:             
1258:             
1259:             
1260:             
1261:             
1262:             _p3d = _com;
1263:             _com = 0;
1264:         }
1265: 
1266: 
1267:         
1268:         uint256 _aff = _eth / 10;
1269: 
1270:         
1271:         
1272:         if (_affID != _pID && plyr_[_affID].name != '') {
1273:             plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
1274:             emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
1275:         } else {
1276:             _p3d = _p3d.add(_aff);
1277:         }
1278: 
1279:         
1280:         _p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
1281:         if (_p3d > 0)
1282:         {
1283:             
1284:             uint256 _potAmount = _p3d / 2;
1285: 
1286:             coin_base.transfer(_p3d.sub(_potAmount));
1287: 
1288:             round_[_rID].pot = round_[_rID].pot.add(_potAmount);
1289: 
1290:             
1291:             _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
1292:         }
1293: 
1294:         return(_eventData_);
1295:     }
1296: 
1297:     function potSwap()
1298:         external
1299:         payable
1300:     {
1301:         
1302:         uint256 _rID = rID_ + 1;
1303: 
1304:         round_[_rID].pot = round_[_rID].pot.add(msg.value);
1305:         emit F3Devents.onPotSwapDeposit(_rID, msg.value);
1306:     }
1307: 
1308:     
1309: 
1310: 
1311:     function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
1312:         private
1313:         returns(F3Ddatasets.EventReturns)
1314:     {
1315:         
1316:         uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;
1317: 
1318:         
1319:         uint256 _air = (_eth / 100);
1320:         airDropPot_ = airDropPot_.add(_air);
1321: 
1322:         
1323:         _eth = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));
1324: 
1325:         
1326:         uint256 _pot = _eth.sub(_gen);
1327: 
1328:         
1329:         
1330:         uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
1331:         if (_dust > 0)
1332:             _gen = _gen.sub(_dust);
1333: 
1334:         
1335:         round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
1336: 
1337:         
1338:         _eventData_.genAmount = _gen.add(_eventData_.genAmount);
1339:         _eventData_.potAmount = _pot;
1340: 
1341:         return(_eventData_);
1342:     }
1343: 
1344:     
1345: 
1346: 
1347: 
1348:     function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
1349:         private
1350:         returns(uint256)
1351:     {
1352:         
1353: 
1354: 
1355: 
1356: 
1357: 
1358: 
1359: 
1360: 
1361: 
1362: 
1363:         
1364:         uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
1365:         round_[_rID].mask = _ppt.add(round_[_rID].mask);
1366: 
1367:         
1368:         
1369:         uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
1370:         plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
1371: 
1372:         
1373:         return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
1374:     }
1375: 
1376:     
1377: 
1378: 
1379: 
1380:     function withdrawEarnings(uint256 _pID)
1381:         private
1382:         returns(uint256)
1383:     {
1384:         
1385:         updateGenVault(_pID, plyr_[_pID].lrnd);
1386: 
1387:         
1388:         uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
1389:         if (_earnings > 0)
1390:         {
1391:             plyr_[_pID].win = 0;
1392:             plyr_[_pID].gen = 0;
1393:             plyr_[_pID].aff = 0;
1394:         }
1395: 
1396:         return(_earnings);
1397:     }
1398: 
1399:     
1400: 
1401: 
1402:     function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
1403:         private
1404:     {
1405:         _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
1406:         _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
1407: 
1408:         emit F3Devents.onEndTx
1409:         (
1410:             _eventData_.compressedData,
1411:             _eventData_.compressedIDs,
1412:             plyr_[_pID].name,
1413:             msg.sender,
1414:             _eth,
1415:             _keys,
1416:             _eventData_.winnerAddr,
1417:             _eventData_.winnerName,
1418:             _eventData_.amountWon,
1419:             _eventData_.newPot,
1420:             _eventData_.P3DAmount,
1421:             _eventData_.genAmount,
1422:             _eventData_.potAmount,
1423:             airDropPot_
1424:         );
1425:     }
1426: 
1427: 
1428: 
1429: 
1430:     
1431: 
1432: 
1433:     bool public activated_ = false;
1434:     function activate()
1435:         public
1436:     {
1437:         
1438:         require(msg.sender == admin, "only admin can activate");
1439: 
1440: 
1441:         
1442:         require(activated_ == false, "FOMO Short already activated");
1443: 
1444:         
1445:         activated_ = true;
1446: 
1447:         
1448:         rID_ = 1;
1449:             round_[1].strt = now + rndExtra_ - rndGap_;
1450:             round_[1].end = now + rndInit_ + rndExtra_;
1451:     }
1452: }
1453: 
1454: 
1455: 
1456: 
1457: 
1458: library F3Ddatasets {
1459:     
1460:     
1461:         
1462:         
1463:         
1464:         
1465:         
1466:         
1467:         
1468:         
1469:         
1470:         
1471:         
1472:         
1473:     
1474:     
1475:         
1476:         
1477:         
1478:     struct EventReturns {
1479:         uint256 compressedData;
1480:         uint256 compressedIDs;
1481:         address winnerAddr;         
1482:         bytes32 winnerName;         
1483:         uint256 amountWon;          
1484:         uint256 newPot;             
1485:         uint256 P3DAmount;          
1486:         uint256 genAmount;          
1487:         uint256 potAmount;          
1488:     }
1489:     struct Player {
1490:         address addr;   
1491:         bytes32 name;   
1492:         uint256 win;    
1493:         uint256 gen;    
1494:         uint256 aff;    
1495:         uint256 lrnd;   
1496:         uint256 laff;   
1497:     }
1498:     struct PlayerRounds {
1499:         uint256 eth;    
1500:         uint256 keys;   
1501:         uint256 mask;   
1502:         uint256 ico;    
1503:     }
1504:     struct Round {
1505:         uint256 plyr;   
1506:         uint256 team;   
1507:         uint256 end;    
1508:         bool ended;     
1509:         uint256 strt;   
1510:         uint256 keys;   
1511:         uint256 eth;    
1512:         uint256 pot;    
1513:         uint256 mask;   
1514:         uint256 ico;    
1515:         uint256 icoGen; 
1516:         uint256 icoAvg; 
1517:     }
1518:     struct TeamFee {
1519:         uint256 gen;    
1520:         uint256 p3d;    
1521:     }
1522:     struct PotSplit {
1523:         uint256 gen;    
1524:         uint256 p3d;    
1525:     }
1526: }
1527: 
1528: 
1529: 
1530: 
1531: 
1532: library F3DKeysCalcShort {
1533:     using SafeMath for *;
1534:     
1535: 
1536: 
1537: 
1538: 
1539: 
1540:     function keysRec(uint256 _curEth, uint256 _newEth)
1541:         internal
1542:         pure
1543:         returns (uint256)
1544:     {
1545:         return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
1546:     }
1547: 
1548:     
1549: 
1550: 
1551: 
1552: 
1553: 
1554:     function ethRec(uint256 _curKeys, uint256 _sellKeys)
1555:         internal
1556:         pure
1557:         returns (uint256)
1558:     {
1559:         return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
1560:     }
1561: 
1562:     
1563: 
1564: 
1565: 
1566: 
1567:     function keys(uint256 _eth)
1568:         internal
1569:         pure
1570:         returns(uint256)
1571:     {
1572:         return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
1573:     }
1574: 
1575:     
1576: 
1577: 
1578: 
1579: 
1580:     function eth(uint256 _keys)
1581:         internal
1582:         pure
1583:         returns(uint256)
1584:     {
1585:         return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
1586:     }
1587: }
1588: 
1589: 
1590: 
1591: 
1592: 
1593: 
1594: interface PlayerBookInterface {
1595:     function getPlayerID(address _addr) external returns (uint256);
1596:     function getPlayerName(uint256 _pID) external view returns (bytes32);
1597:     function getPlayerLAff(uint256 _pID) external view returns (uint256);
1598:     function getPlayerAddr(uint256 _pID) external view returns (address);
1599:     function getNameFee() external view returns (uint256);
1600:     function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
1601:     function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
1602:     function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
1603: }
1604: 
1605: 
1606: 
1607: 
1608: 
1609: 
1610: 
1611: 
1612: 
1613: 
1614: 
1615: 
1616: 
1617: 
1618: 
1619: 
1620: 
1621: 
1622: 
1623: 
1624: 
1625: 
1626: 
1627: 
1628: 
1629: library NameFilter {
1630:     
1631: 
1632: 
1633: 
1634: 
1635: 
1636: 
1637: 
1638: 
1639: 
1640:     function nameFilter(string _input)
1641:         internal
1642:         pure
1643:         returns(bytes32)
1644:     {
1645:         bytes memory _temp = bytes(_input);
1646:         uint256 _length = _temp.length;
1647: 
1648:         
1649:         require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
1650:         
1651:         require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
1652:         
1653:         if (_temp[0] == 0x30)
1654:         {
1655:             require(_temp[1] != 0x78, "string cannot start with 0x");
1656:             require(_temp[1] != 0x58, "string cannot start with 0X");
1657:         }
1658: 
1659:         
1660:         bool _hasNonNumber;
1661: 
1662:         
1663:         for (uint256 i = 0; i < _length; i++)
1664:         {
1665:             
1666:             if (_temp[i] > 0x40 && _temp[i] < 0x5b)
1667:             {
1668:                 
1669:                 _temp[i] = byte(uint(_temp[i]) + 32);
1670: 
1671:                 
1672:                 if (_hasNonNumber == false)
1673:                     _hasNonNumber = true;
1674:             } else {
1675:                 require
1676:                 (
1677:                     
1678:                     _temp[i] == 0x20 ||
1679:                     
1680:                     (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
1681:                     
1682:                     (_temp[i] > 0x2f && _temp[i] < 0x3a),
1683:                     "string contains invalid characters"
1684:                 );
1685:                 
1686:                 if (_temp[i] == 0x20)
1687:                     require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
1688: 
1689:                 
1690:                 if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
1691:                     _hasNonNumber = true;
1692:             }
1693:         }
1694: 
1695:         require(_hasNonNumber == true, "string cannot be only numbers");
1696: 
1697:         bytes32 _ret;
1698:         assembly {
1699:             _ret := mload(add(_temp, 32))
1700:         }
1701:         return (_ret);
1702:     }
1703: }
1704: 
1705: 
1706: 
1707: 
1708: 
1709: 
1710: 
1711: 
1712: 
1713: 
1714: 
1715: library SafeMath {
1716: 
1717:     
1718: 
1719: 
1720:     function mul(uint256 a, uint256 b)
1721:         internal
1722:         pure
1723:         returns (uint256 c)
1724:     {
1725:         if (a == 0) {
1726:             return 0;
1727:         }
1728:         c = a * b;
1729:         require(c / a == b, "SafeMath mul failed");
1730:         return c;
1731:     }
1732: 
1733:     
1734: 
1735: 
1736:     function sub(uint256 a, uint256 b)
1737:         internal
1738:         pure
1739:         returns (uint256)
1740:     {
1741:         require(b <= a, "SafeMath sub failed");
1742:         return a - b;
1743:     }
1744: 
1745:     
1746: 
1747: 
1748:     function add(uint256 a, uint256 b)
1749:         internal
1750:         pure
1751:         returns (uint256 c)
1752:     {
1753:         c = a + b;
1754:         require(c >= a, "SafeMath add failed");
1755:         return c;
1756:     }
1757: 
1758:     
1759: 
1760: 
1761:     function sqrt(uint256 x)
1762:         internal
1763:         pure
1764:         returns (uint256 y)
1765:     {
1766:         uint256 z = ((add(x,1)) / 2);
1767:         y = x;
1768:         while (z < y)
1769:         {
1770:             y = z;
1771:             z = ((add((x / z),z)) / 2);
1772:         }
1773:     }
1774: 
1775:     
1776: 
1777: 
1778:     function sq(uint256 x)
1779:         internal
1780:         pure
1781:         returns (uint256)
1782:     {
1783:         return (mul(x,x));
1784:     }
1785: 
1786:     
1787: 
1788: 
1789:     function pwr(uint256 x, uint256 y)
1790:         internal
1791:         pure
1792:         returns (uint256)
1793:     {
1794:         if (x==0)
1795:             return (0);
1796:         else if (y==0)
1797:             return (1);
1798:         else
1799:         {
1800:             uint256 z = x;
1801:             for (uint256 i=1; i < y; i++)
1802:                 z = mul(z,x);
1803:             return (z);
1804:         }
1805:     }
1806: }