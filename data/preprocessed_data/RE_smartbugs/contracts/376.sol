1: pragma solidity ^0.4.24;
2: 
3: 
4: contract SnowStorm is modularShort {
5:     using SafeMath for *;
6:     using NameFilter for string;
7:     using F3DKeysCalcShort for uint256;
8: 
9:     PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xf4FBEF849bcf02Ac4b305c2bc092FC270a14124C);
10: 
11:     address private admin = msg.sender;
12:     string constant public name = "SnowStorm";
13:     string constant public symbol = "SS";
14:     uint256 private rndExtra_ = 1 seconds;
15:     uint256 private rndGap_ = 1 seconds;
16:     uint256 constant private rndInit_ = 8 hours;
17:     uint256 constant private rndInc_ = 30 seconds;
18:     uint256 constant private rndMax_ = 8 hours;
19:     address treat;
20:     Snow action;
21: 
22:     uint256 public airDropPot_;             
23:     uint256 public airDropTracker_ = 0;     
24:     uint256 public rID_;    
25: 
26: 
27: 
28:     mapping (address => uint256) public pIDxAddr_;          
29:     mapping (bytes32 => uint256) public pIDxName_;          
30:     mapping (uint256 => F3Ddatasets.Player) public plyr_;   
31:     mapping (uint256 => mapping (uint256 => F3Ddatasets.PlayerRounds)) public plyrRnds_;    
32:     mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; 
33: 
34: 
35: 
36:     mapping (uint256 => F3Ddatasets.Round) public round_;   
37:     mapping (uint256 => mapping(uint256 => uint256)) public rndTmEth_;      
38: 
39: 
40: 
41:     mapping (uint256 => F3Ddatasets.TeamFee) public fees_;          
42:     mapping (uint256 => F3Ddatasets.PotSplit) public potSplit_;     
43: 
44: 
45: 
46: 
47:     constructor()
48:         public
49:     {   
50:         treat = 0x371308b6A7B6f80DF798589c48Dea369839951dd; 
51:         action = Snow(treat);
52: 
53: 		
54:         
55:         
56:         
57:         
58: 
59: 		
60:         
61:         
62:         fees_[0] = F3Ddatasets.TeamFee(46,10);   
63:         fees_[1] = F3Ddatasets.TeamFee(46,10);   
64:         fees_[2] = F3Ddatasets.TeamFee(46,10);   
65:         fees_[3] = F3Ddatasets.TeamFee(46,10);   
66: 
67:         
68:         
69:         potSplit_[0] = F3Ddatasets.PotSplit(35,5);  
70:         potSplit_[1] = F3Ddatasets.PotSplit(35,5);  
71:         potSplit_[2] = F3Ddatasets.PotSplit(35,5);  
72:         potSplit_[3] = F3Ddatasets.PotSplit(35,5);  
73:     }
74: 
75: 
76: 
77: 
78:     
79: 
80: 
81: 
82:     modifier isActivated() {
83:         require(activated_ == true, "its not ready yet.  check ?eta in discord");
84:         _;
85:     }
86: 
87:     
88: 
89: 
90:     modifier isHuman() {
91:         address _addr = msg.sender;
92:         uint256 _codeLength;
93: 
94:         assembly {_codeLength := extcodesize(_addr)}
95:         require(_codeLength == 0, "sorry humans only");
96:         _;
97:     }
98: 
99:     
100: 
101: 
102:     modifier isWithinLimits(uint256 _eth) {
103:         require(_eth >= 1000000000, "pocket lint: not a valid currency");
104:         require(_eth <= 100000000000000000000000, "no vitalik, no");
105:         _;
106:     }
107: 
108: 
109: 
110: 
111: 
112:     
113: 
114: 
115:     function()
116:         isActivated()
117:         isHuman()
118:         isWithinLimits(msg.value)
119:         public
120:         payable
121:     {
122:         
123:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
124: 
125:         
126:         uint256 _pID = pIDxAddr_[msg.sender];
127: 
128:         
129:         buyCore(_pID, plyr_[_pID].laff, 2, _eventData_);
130:     }
131: 
132:     
133: 
134: 
135: 
136: 
137: 
138: 
139: 
140:     function buyXid(uint256 _affCode, uint256 _team)
141:         isActivated()
142:         isHuman()
143:         isWithinLimits(msg.value)
144:         public
145:         payable
146:     {
147:         
148:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
149: 
150:         
151:         uint256 _pID = pIDxAddr_[msg.sender];
152: 
153:         
154:         
155:         if (_affCode == 0 || _affCode == _pID)
156:         {
157:             
158:             _affCode = plyr_[_pID].laff;
159: 
160:         
161:         } else if (_affCode != plyr_[_pID].laff) {
162:             
163:             plyr_[_pID].laff = _affCode;
164:         }
165: 
166:         
167:         _team = verifyTeam(_team);
168: 
169:         
170:         buyCore(_pID, _affCode, _team, _eventData_);
171:     }
172: 
173:     function buyXaddr(address _affCode, uint256 _team)
174:         isActivated()
175:         isHuman()
176:         isWithinLimits(msg.value)
177:         public
178:         payable
179:     {
180:         
181:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
182: 
183:         
184:         uint256 _pID = pIDxAddr_[msg.sender];
185: 
186:         
187:         uint256 _affID;
188:         
189:         if (_affCode == address(0) || _affCode == msg.sender)
190:         {
191:             
192:             _affID = plyr_[_pID].laff;
193: 
194:         
195:         } else {
196:             
197:             _affID = pIDxAddr_[_affCode];
198: 
199:             
200:             if (_affID != plyr_[_pID].laff)
201:             {
202:                 
203:                 plyr_[_pID].laff = _affID;
204:             }
205:         }
206: 
207:         
208:         _team = verifyTeam(_team);
209: 
210:         
211:         buyCore(_pID, _affID, _team, _eventData_);
212:     }
213: 
214:     function buyXname(bytes32 _affCode, uint256 _team)
215:         isActivated()
216:         isHuman()
217:         isWithinLimits(msg.value)
218:         public
219:         payable
220:     {
221:         
222:         F3Ddatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
223: 
224:         
225:         uint256 _pID = pIDxAddr_[msg.sender];
226: 
227:         
228:         uint256 _affID;
229:         
230:         if (_affCode == '' || _affCode == plyr_[_pID].name)
231:         {
232:             
233:             _affID = plyr_[_pID].laff;
234: 
235:         
236:         } else {
237:             
238:             _affID = pIDxName_[_affCode];
239: 
240:             
241:             if (_affID != plyr_[_pID].laff)
242:             {
243:                 
244:                 plyr_[_pID].laff = _affID;
245:             }
246:         }
247: 
248:         
249:         _team = verifyTeam(_team);
250: 
251:         
252:         buyCore(_pID, _affID, _team, _eventData_);
253:     }
254: 
255:     
256: 
257: 
258: 
259: 
260: 
261: 
262: 
263: 
264: 
265:     function reLoadXid(uint256 _affCode, uint256 _team, uint256 _eth)
266:         isActivated()
267:         isHuman()
268:         isWithinLimits(_eth)
269:         public
270:     {
271:         
272:         F3Ddatasets.EventReturns memory _eventData_;
273: 
274:         
275:         uint256 _pID = pIDxAddr_[msg.sender];
276: 
277:         
278:         
279:         if (_affCode == 0 || _affCode == _pID)
280:         {
281:             
282:             _affCode = plyr_[_pID].laff;
283: 
284:         
285:         } else if (_affCode != plyr_[_pID].laff) {
286:             
287:             plyr_[_pID].laff = _affCode;
288:         }
289: 
290:         
291:         _team = verifyTeam(_team);
292: 
293:         
294:         reLoadCore(_pID, _affCode, _team, _eth, _eventData_);
295:     }
296: 
297:     function reLoadXaddr(address _affCode, uint256 _team, uint256 _eth)
298:         isActivated()
299:         isHuman()
300:         isWithinLimits(_eth)
301:         public
302:     {
303:         
304:         F3Ddatasets.EventReturns memory _eventData_;
305: 
306:         
307:         uint256 _pID = pIDxAddr_[msg.sender];
308: 
309:         
310:         uint256 _affID;
311:         
312:         if (_affCode == address(0) || _affCode == msg.sender)
313:         {
314:             
315:             _affID = plyr_[_pID].laff;
316: 
317:         
318:         } else {
319:             
320:             _affID = pIDxAddr_[_affCode];
321: 
322:             
323:             if (_affID != plyr_[_pID].laff)
324:             {
325:                 
326:                 plyr_[_pID].laff = _affID;
327:             }
328:         }
329: 
330:         
331:         _team = verifyTeam(_team);
332: 
333:         
334:         reLoadCore(_pID, _affID, _team, _eth, _eventData_);
335:     }
336: 
337:     function reLoadXname(bytes32 _affCode, uint256 _team, uint256 _eth)
338:         isActivated()
339:         isHuman()
340:         isWithinLimits(_eth)
341:         public
342:     {
343:         
344:         F3Ddatasets.EventReturns memory _eventData_;
345: 
346:         
347:         uint256 _pID = pIDxAddr_[msg.sender];
348: 
349:         
350:         uint256 _affID;
351:         
352:         if (_affCode == '' || _affCode == plyr_[_pID].name)
353:         {
354:             
355:             _affID = plyr_[_pID].laff;
356: 
357:         
358:         } else {
359:             
360:             _affID = pIDxName_[_affCode];
361: 
362:             
363:             if (_affID != plyr_[_pID].laff)
364:             {
365:                 
366:                 plyr_[_pID].laff = _affID;
367:             }
368:         }
369: 
370:         
371:         _team = verifyTeam(_team);
372: 
373:         
374:         reLoadCore(_pID, _affID, _team, _eth, _eventData_);
375:     }
376: 
377:     
378: 
379: 
380: 
381:     function withdraw()
382:         isActivated()
383:         isHuman()
384:         public
385:     {
386:         
387:         uint256 _rID = rID_;
388: 
389:         
390:         uint256 _now = now;
391: 
392:         
393:         uint256 _pID = pIDxAddr_[msg.sender];
394: 
395:         
396:         uint256 _eth;
397: 
398:         
399:         if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
400:         {
401:             
402:             F3Ddatasets.EventReturns memory _eventData_;
403: 
404:             
405: 			round_[_rID].ended = true;
406:             _eventData_ = endRound(_eventData_);
407: 
408: 			
409:             _eth = withdrawEarnings(_pID);
410: 
411:             
412:             if (_eth > 0)
413:                 plyr_[_pID].addr.transfer(_eth);
414: 
415:             
416:             _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
417:             _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
418: 
419:             
420:             emit F3Devents.onWithdrawAndDistribute
421:             (
422:                 msg.sender,
423:                 plyr_[_pID].name,
424:                 _eth,
425:                 _eventData_.compressedData,
426:                 _eventData_.compressedIDs,
427:                 _eventData_.winnerAddr,
428:                 _eventData_.winnerName,
429:                 _eventData_.amountWon,
430:                 _eventData_.newPot,
431:                 _eventData_.P3DAmount,
432:                 _eventData_.genAmount
433:             );
434: 
435:         
436:         } else {
437:             
438:             _eth = withdrawEarnings(_pID);
439: 
440:             
441:             if (_eth > 0)
442:                 plyr_[_pID].addr.transfer(_eth);
443: 
444:             
445:             emit F3Devents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
446:         }
447:     }
448: 
449:     
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
473:     function registerNameXID(string _nameString, uint256 _affCode, bool _all)
474:         isHuman()
475:         public
476:         payable
477:     {
478:         bytes32 _name = _nameString.nameFilter();
479:         address _addr = msg.sender;
480:         uint256 _paid = msg.value;
481:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);
482: 
483:         uint256 _pID = pIDxAddr_[_addr];
484: 
485:         
486:         emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
487:     }
488: 
489:     function registerNameXaddr(string _nameString, address _affCode, bool _all)
490:         isHuman()
491:         public
492:         payable
493:     {
494:         bytes32 _name = _nameString.nameFilter();
495:         address _addr = msg.sender;
496:         uint256 _paid = msg.value;
497:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
498: 
499:         uint256 _pID = pIDxAddr_[_addr];
500: 
501:         
502:         emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
503:     }
504: 
505:     function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
506:         isHuman()
507:         public
508:         payable
509:     {
510:         bytes32 _name = _nameString.nameFilter();
511:         address _addr = msg.sender;
512:         uint256 _paid = msg.value;
513:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
514: 
515:         uint256 _pID = pIDxAddr_[_addr];
516: 
517:         
518:         emit F3Devents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
519:     }
520: 
521: 
522: 
523: 
524:     
525: 
526: 
527: 
528: 
529:     function getBuyPrice()
530:         public
531:         view
532:         returns(uint256)
533:     {
534:         
535:         uint256 _rID = rID_;
536: 
537:         
538:         uint256 _now = now;
539: 
540:         
541:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
542:             return ( (round_[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
543:         else 
544:             return ( 75000000000000 ); 
545:     }
546: 
547:     
548: 
549: 
550: 
551: 
552: 
553:     function getTimeLeft()
554:         public
555:         view
556:         returns(uint256)
557:     {
558:         
559:         uint256 _rID = rID_;
560: 
561:         
562:         uint256 _now = now;
563: 
564:         if (_now < round_[_rID].end)
565:             if (_now > round_[_rID].strt + rndGap_)
566:                 return( (round_[_rID].end).sub(_now) );
567:             else
568:                 return( (round_[_rID].strt + rndGap_).sub(_now) );
569:         else
570:             return(0);
571:     }
572: 
573:     
574: 
575: 
576: 
577: 
578: 
579: 
580:     function getPlayerVaults(uint256 _pID)
581:         public
582:         view
583:         returns(uint256 ,uint256, uint256)
584:     {
585:         
586:         uint256 _rID = rID_;
587: 
588:         
589:         if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
590:         {
591:             
592:             if (round_[_rID].plyr == _pID)
593:             {
594:                 return
595:                 (
596:                     (plyr_[_pID].win).add( ((round_[_rID].pot).mul(50)) / 100 ),
597:                     (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
598:                     plyr_[_pID].aff
599:                 );
600:             
601:             } else {
602:                 return
603:                 (
604:                     plyr_[_pID].win,
605:                     (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
606:                     plyr_[_pID].aff
607:                 );
608:             }
609: 
610:         
611:         } else {
612:             return
613:             (
614:                 plyr_[_pID].win,
615:                 (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
616:                 plyr_[_pID].aff
617:             );
618:         }
619:     }
620: 
621:     
622: 
623: 
624:     function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
625:         private
626:         view
627:         returns(uint256)
628:     {
629:         return(  ((((round_[_rID].mask).add(((((round_[_rID].pot).mul(potSplit_[round_[_rID].team].gen)) / 100).mul(1000000000000000000)) / (round_[_rID].keys))).mul(plyrRnds_[_pID][_rID].keys)) / 1000000000000000000)  );
630:     }
631: 
632:     
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
650:     function getCurrentRoundInfo()
651:         public
652:         view
653:         returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256, uint256, uint256, uint256, uint256)
654:     {
655:         
656:         uint256 _rID = rID_;
657: 
658:         return
659:         (
660:             round_[_rID].ico,               
661:             _rID,                           
662:             round_[_rID].keys,              
663:             round_[_rID].end,               
664:             round_[_rID].strt,              
665:             round_[_rID].pot,               
666:             (round_[_rID].team + (round_[_rID].plyr * 10)),     
667:             plyr_[round_[_rID].plyr].addr,  
668:             plyr_[round_[_rID].plyr].name,  
669:             rndTmEth_[_rID][0],             
670:             rndTmEth_[_rID][1],             
671:             rndTmEth_[_rID][2],             
672:             rndTmEth_[_rID][3],             
673:             airDropTracker_ + (airDropPot_ * 1000)              
674:         );
675:     }
676: 
677:     
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
690:     function getPlayerInfoByAddress(address _addr)
691:         public
692:         view
693:         returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
694:     {
695:         
696:         uint256 _rID = rID_;
697: 
698:         if (_addr == address(0))
699:         {
700:             _addr == msg.sender;
701:         }
702:         uint256 _pID = pIDxAddr_[_addr];
703: 
704:         return
705:         (
706:             _pID,                               
707:             plyr_[_pID].name,                   
708:             plyrRnds_[_pID][_rID].keys,         
709:             plyr_[_pID].win,                    
710:             (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       
711:             plyr_[_pID].aff,                    
712:             plyrRnds_[_pID][_rID].eth           
713:         );
714:     }
715: 
716: 
717: 
718: 
719: 
720:     
721: 
722: 
723: 
724:     function buyCore(uint256 _pID, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
725:         private
726:     {
727:         
728:         uint256 _rID = rID_;
729: 
730:         
731:         uint256 _now = now;
732: 
733:         
734:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
735:         {
736:             
737:             core(_rID, _pID, msg.value, _affID, _team, _eventData_);
738: 
739:         
740:         } else {
741:             
742:             if (_now > round_[_rID].end && round_[_rID].ended == false)
743:             {
744:                 
745: 			    round_[_rID].ended = true;
746:                 _eventData_ = endRound(_eventData_);
747: 
748:                 
749:                 _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
750:                 _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
751: 
752:                 
753:                 emit F3Devents.onBuyAndDistribute
754:                 (
755:                     msg.sender,
756:                     plyr_[_pID].name,
757:                     msg.value,
758:                     _eventData_.compressedData,
759:                     _eventData_.compressedIDs,
760:                     _eventData_.winnerAddr,
761:                     _eventData_.winnerName,
762:                     _eventData_.amountWon,
763:                     _eventData_.newPot,
764:                     _eventData_.P3DAmount,
765:                     _eventData_.genAmount
766:                 );
767:             }
768: 
769:             
770:             plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
771:         }
772:     }
773: 
774:     
775: 
776: 
777: 
778:     function reLoadCore(uint256 _pID, uint256 _affID, uint256 _team, uint256 _eth, F3Ddatasets.EventReturns memory _eventData_)
779:         private
780:     {
781:         
782:         uint256 _rID = rID_;
783: 
784:         
785:         uint256 _now = now;
786: 
787:         
788:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
789:         {
790:             
791:             
792:             
793:             plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
794: 
795:             
796:             core(_rID, _pID, _eth, _affID, _team, _eventData_);
797: 
798:         
799:         } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
800:             
801:             round_[_rID].ended = true;
802:             _eventData_ = endRound(_eventData_);
803: 
804:             
805:             _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
806:             _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
807: 
808:             
809:             emit F3Devents.onReLoadAndDistribute
810:             (
811:                 msg.sender,
812:                 plyr_[_pID].name,
813:                 _eventData_.compressedData,
814:                 _eventData_.compressedIDs,
815:                 _eventData_.winnerAddr,
816:                 _eventData_.winnerName,
817:                 _eventData_.amountWon,
818:                 _eventData_.newPot,
819:                 _eventData_.P3DAmount,
820:                 _eventData_.genAmount
821:             );
822:         }
823:     }
824: 
825:     
826: 
827: 
828: 
829:     function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
830:         private
831:     {
832:         
833:         if (plyrRnds_[_pID][_rID].keys == 0)
834:             _eventData_ = managePlayer(_pID, _eventData_);
835: 
836:         
837:         if (round_[_rID].eth < 100000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 5000000000000000000)
838:         {
839:             uint256 _availableLimit = (5000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
840:             uint256 _refund = _eth.sub(_availableLimit);
841:             plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
842:             _eth = _availableLimit;
843:         }
844: 
845:         
846:         if (_eth > 1000000000)
847:         {
848: 
849:             
850:             uint256 _keys = (round_[_rID].eth).keysRec(_eth);
851: 
852:             
853:             if (_keys >= 1000000000000000000)
854:             {
855:             updateTimer(_keys, _rID);
856: 
857:             
858:             if (round_[_rID].plyr != _pID)
859:                 round_[_rID].plyr = _pID;
860:             if (round_[_rID].team != _team)
861:                 round_[_rID].team = _team;
862: 
863:             
864:             _eventData_.compressedData = _eventData_.compressedData + 100;
865:         }
866: 
867:             
868:             if (_eth >= 100000000000000000)
869:             {
870:             airDropTracker_++;
871:             if (airdrop() == true)
872:             {
873:                 
874:                 uint256 _prize;
875:                 if (_eth >= 10000000000000000000)
876:                 {
877:                     
878:                     _prize = ((airDropPot_).mul(75)) / 100;
879:                     plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
880: 
881:                     
882:                     airDropPot_ = (airDropPot_).sub(_prize);
883: 
884:                     
885:                     _eventData_.compressedData += 300000000000000000000000000000000;
886:                 } else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
887:                     
888:                     _prize = ((airDropPot_).mul(50)) / 100;
889:                     plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
890: 
891:                     
892:                     airDropPot_ = (airDropPot_).sub(_prize);
893: 
894:                     
895:                     _eventData_.compressedData += 200000000000000000000000000000000;
896:                 } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
897:                     
898:                     _prize = ((airDropPot_).mul(25)) / 100;
899:                     plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
900: 
901:                     
902:                     airDropPot_ = (airDropPot_).sub(_prize);
903: 
904:                     
905:                     _eventData_.compressedData += 300000000000000000000000000000000;
906:                 }
907:                 
908:                 _eventData_.compressedData += 10000000000000000000000000000000;
909:                 
910:                 _eventData_.compressedData += _prize * 1000000000000000000000000000000000;
911: 
912:                 
913:                 airDropTracker_ = 0;
914:             }
915:         }
916: 
917:             
918:             _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
919: 
920:             
921:             plyrRnds_[_pID][_rID].keys = _keys.add(plyrRnds_[_pID][_rID].keys);
922:             plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
923: 
924:             
925:             round_[_rID].keys = _keys.add(round_[_rID].keys);
926:             round_[_rID].eth = _eth.add(round_[_rID].eth);
927:             rndTmEth_[_rID][_team] = _eth.add(rndTmEth_[_rID][_team]);
928: 
929:             
930:             _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _team, _eventData_);
931:             _eventData_ = distributeInternal(_rID, _pID, _eth, _team, _keys, _eventData_);
932: 
933:             
934: 		    endTx(_pID, _team, _eth, _keys, _eventData_);
935:         }
936:     }
937: 
938: 
939: 
940: 
941:     
942: 
943: 
944: 
945:     function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
946:         private
947:         view
948:         returns(uint256)
949:     {
950:         return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
951:     }
952: 
953:     
954: 
955: 
956: 
957: 
958: 
959: 
960:     function calcKeysReceived(uint256 _rID, uint256 _eth)
961:         public
962:         view
963:         returns(uint256)
964:     {
965:         
966:         uint256 _now = now;
967: 
968:         
969:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
970:             return ( (round_[_rID].eth).keysRec(_eth) );
971:         else 
972:             return ( (_eth).keys() );
973:     }
974: 
975:     
976: 
977: 
978: 
979: 
980: 
981:     function iWantXKeys(uint256 _keys)
982:         public
983:         view
984:         returns(uint256)
985:     {
986:         
987:         uint256 _rID = rID_;
988: 
989:         
990:         uint256 _now = now;
991: 
992:         
993:         if (_now > round_[_rID].strt + rndGap_ && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
994:             return ( (round_[_rID].keys.add(_keys)).ethRec(_keys) );
995:         else 
996:             return ( (_keys).eth() );
997:     }
998: 
999: 
1000: 
1001: 
1002:     
1003: 
1004: 
1005:     function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
1006:         external
1007:     {
1008:         require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
1009:         if (pIDxAddr_[_addr] != _pID)
1010:             pIDxAddr_[_addr] = _pID;
1011:         if (pIDxName_[_name] != _pID)
1012:             pIDxName_[_name] = _pID;
1013:         if (plyr_[_pID].addr != _addr)
1014:             plyr_[_pID].addr = _addr;
1015:         if (plyr_[_pID].name != _name)
1016:             plyr_[_pID].name = _name;
1017:         if (plyr_[_pID].laff != _laff)
1018:             plyr_[_pID].laff = _laff;
1019:         if (plyrNames_[_pID][_name] == false)
1020:             plyrNames_[_pID][_name] = true;
1021:     }
1022: 
1023:     
1024: 
1025: 
1026:     function receivePlayerNameList(uint256 _pID, bytes32 _name)
1027:         external
1028:     {
1029:         require (msg.sender == address(PlayerBook), "your not playerNames contract... hmmm..");
1030:         if(plyrNames_[_pID][_name] == false)
1031:             plyrNames_[_pID][_name] = true;
1032:     }
1033: 
1034:     
1035: 
1036: 
1037: 
1038:     function determinePID(F3Ddatasets.EventReturns memory _eventData_)
1039:         private
1040:         returns (F3Ddatasets.EventReturns)
1041:     {
1042:         uint256 _pID = pIDxAddr_[msg.sender];
1043:         
1044:         if (_pID == 0)
1045:         {
1046:             
1047:             _pID = PlayerBook.getPlayerID(msg.sender);
1048:             bytes32 _name = PlayerBook.getPlayerName(_pID);
1049:             uint256 _laff = PlayerBook.getPlayerLAff(_pID);
1050: 
1051:             
1052:             pIDxAddr_[msg.sender] = _pID;
1053:             plyr_[_pID].addr = msg.sender;
1054: 
1055:             if (_name != "")
1056:             {
1057:                 pIDxName_[_name] = _pID;
1058:                 plyr_[_pID].name = _name;
1059:                 plyrNames_[_pID][_name] = true;
1060:             }
1061: 
1062:             if (_laff != 0 && _laff != _pID)
1063:                 plyr_[_pID].laff = _laff;
1064: 
1065:             
1066:             _eventData_.compressedData = _eventData_.compressedData + 1;
1067:         }
1068:         return (_eventData_);
1069:     }
1070: 
1071:     
1072: 
1073: 
1074: 
1075:     function verifyTeam(uint256 _team)
1076:         private
1077:         pure
1078:         returns (uint256)
1079:     {
1080:         if (_team < 0 || _team > 3)
1081:             return(2);
1082:         else
1083:             return(_team);
1084:     }
1085: 
1086:     
1087: 
1088: 
1089: 
1090:     function managePlayer(uint256 _pID, F3Ddatasets.EventReturns memory _eventData_)
1091:         private
1092:         returns (F3Ddatasets.EventReturns)
1093:     {
1094:         
1095:         
1096:         if (plyr_[_pID].lrnd != 0)
1097:             updateGenVault(_pID, plyr_[_pID].lrnd);
1098: 
1099:         
1100:         plyr_[_pID].lrnd = rID_;
1101: 
1102:         
1103:         _eventData_.compressedData = _eventData_.compressedData + 10;
1104: 
1105:         return(_eventData_);
1106:     }
1107: 
1108:     
1109: 
1110: 
1111:     function endRound(F3Ddatasets.EventReturns memory _eventData_)
1112:         private
1113:         returns (F3Ddatasets.EventReturns)
1114:     {
1115:         
1116:         uint256 _rID = rID_;
1117: 
1118:         
1119:         uint256 _winPID = round_[_rID].plyr;
1120:         uint256 _winTID = round_[_rID].team;
1121: 
1122:         
1123:         uint256 _pot = round_[_rID].pot;
1124: 
1125:         
1126:         
1127:         uint256 _win = (_pot.mul(48)) / 100; 
1128:         uint256 _com = (_pot / 50); 
1129:         _win = _win+_com; 
1130:         uint256 _gen = (_pot.mul(potSplit_[_winTID].gen)) / 100;
1131:         uint256 _p3d = (_pot.mul(potSplit_[_winTID].p3d)) / 100;
1132:         uint256 _res = (((_pot.sub(_win)).sub(_com)).sub(_gen)).sub(_p3d);
1133: 
1134:         
1135:         uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
1136:         uint256 _dust = _gen.sub((_ppt.mul(round_[_rID].keys)) / 1000000000000000000);
1137:         if (_dust > 0)
1138:         {
1139:             _gen = _gen.sub(_dust);
1140:             _res = _res.add(_dust);
1141:         }
1142: 
1143:         
1144:         plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
1145: 
1146:         action.redistribution.value(_p3d).gas(1000000)(); 
1147: 
1148:         
1149:         round_[_rID].mask = _ppt.add(round_[_rID].mask);
1150: 
1151:         
1152:         _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
1153:         _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000) + (_winTID * 100000000000000000);
1154:         _eventData_.winnerAddr = plyr_[_winPID].addr;
1155:         _eventData_.winnerName = plyr_[_winPID].name;
1156:         _eventData_.amountWon = _win;
1157:         _eventData_.genAmount = _gen;
1158:         _eventData_.P3DAmount = _p3d;
1159:         _eventData_.newPot = _res;
1160: 
1161:         
1162:         rID_++;
1163:         _rID++;
1164:         round_[_rID].strt = now;
1165:         round_[_rID].end = now.add(rndInit_).add(rndGap_);
1166:         round_[_rID].pot = _res;
1167: 
1168:         return(_eventData_);
1169:     }
1170: 
1171:     
1172: 
1173: 
1174:     function updateGenVault(uint256 _pID, uint256 _rIDlast)
1175:         private
1176:     {
1177:         uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
1178:         if (_earnings > 0)
1179:         {
1180:             
1181:             plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
1182:             
1183:             plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
1184:         }
1185:     }
1186: 
1187:     
1188: 
1189: 
1190:     function updateTimer(uint256 _keys, uint256 _rID)
1191:         private
1192:     {
1193:         
1194:         uint256 _now = now;
1195: 
1196:         
1197:         uint256 _newTime;
1198:         if (_now > round_[_rID].end && round_[_rID].plyr == 0)
1199:             _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
1200:         else
1201:             _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);
1202: 
1203:         
1204:         if (_newTime < (rndMax_).add(_now))
1205:             round_[_rID].end = _newTime;
1206:         else
1207:             round_[_rID].end = rndMax_.add(_now);
1208:     }
1209: 
1210:     
1211: 
1212: 
1213: 
1214: 
1215:     function airdrop()
1216:         private
1217:         view
1218:         returns(bool)
1219:     {
1220:         uint256 seed = uint256(keccak256(abi.encodePacked(
1221: 
1222:             (block.timestamp).add
1223:             (block.difficulty).add
1224:             ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
1225:             (block.gaslimit).add
1226:             ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
1227:             (block.number)
1228: 
1229:         )));
1230:         if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
1231:             return(true);
1232:         else
1233:             return(false);
1234:     }
1235: 
1236:     
1237: 
1238: 
1239:     function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, uint256 _team, F3Ddatasets.EventReturns memory _eventData_)
1240:         private
1241:         returns(F3Ddatasets.EventReturns)
1242:     {
1243:         
1244:         uint256 _p1 = _eth / 100; 
1245:         uint256 _com = _eth / 50;  
1246:         _com = _com.add(_p1); 
1247: 
1248: 
1249:         uint256 _p3d;
1250:         if (!address(admin).call.value(_com)())
1251:         {
1252:             
1253:             
1254:             
1255:             
1256:             
1257:             
1258:             _p3d = _com;
1259:             _com = 0;
1260:         }
1261: 
1262: 
1263:         
1264:         uint256 _aff = _eth / 10;
1265: 
1266:         
1267:         
1268:         if (_affID != _pID && plyr_[_affID].name != '') {
1269:             plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
1270:             emit F3Devents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _rID, _pID, _aff, now);
1271:         } else {
1272:             _p3d = _aff;
1273:         }
1274: 
1275:         
1276:         _p3d = _p3d.add((_eth.mul(fees_[_team].p3d)) / (100));
1277:         if (_p3d > 0)
1278:         {
1279:             action.redistribution.value(_p3d).gas(1000000)();
1280: 
1281: 
1282:             
1283:             _eventData_.P3DAmount = _p3d.add(_eventData_.P3DAmount);
1284:         }
1285: 
1286:         return(_eventData_);
1287:     }
1288: 
1289:     function potSwap()
1290:         external
1291:         payable
1292:     {
1293:         
1294:         uint256 _rID = rID_ + 1;
1295: 
1296:         round_[_rID].pot = round_[_rID].pot.add(msg.value);
1297:         emit F3Devents.onPotSwapDeposit(_rID, msg.value);
1298:     }
1299: 
1300:     
1301: 
1302: 
1303:     function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _team, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
1304:         private
1305:         returns(F3Ddatasets.EventReturns)
1306:     {
1307:         
1308:         uint256 _gen = (_eth.mul(fees_[_team].gen)) / 100;
1309: 
1310:         
1311:         uint256 _air = (_eth / 100);
1312:         airDropPot_ = airDropPot_.add(_air);
1313: 
1314:         
1315:         _eth = _eth.sub(((_eth.mul(14)) / 100).add((_eth.mul(fees_[_team].p3d)) / 100));
1316: 
1317:         
1318:         uint256 _pot = _eth.sub(_gen);
1319: 
1320:         
1321:         
1322:         uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
1323:         if (_dust > 0)
1324:             _gen = _gen.sub(_dust);
1325: 
1326:         
1327:         round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
1328: 
1329:         
1330:         _eventData_.genAmount = _gen.add(_eventData_.genAmount);
1331:         _eventData_.potAmount = _pot;
1332: 
1333:         return(_eventData_);
1334:     }
1335: 
1336:     
1337: 
1338: 
1339: 
1340:     function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
1341:         private
1342:         returns(uint256)
1343:     {
1344:         
1345: 
1346: 
1347: 
1348: 
1349: 
1350: 
1351: 
1352: 
1353: 
1354: 
1355:         
1356:         uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].keys);
1357:         round_[_rID].mask = _ppt.add(round_[_rID].mask);
1358: 
1359:         
1360:         
1361:         uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
1362:         plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
1363: 
1364:         
1365:         return(_gen.sub((_ppt.mul(round_[_rID].keys)) / (1000000000000000000)));
1366:     }
1367: 
1368:     
1369: 
1370: 
1371: 
1372:     function withdrawEarnings(uint256 _pID)
1373:         private
1374:         returns(uint256)
1375:     {
1376:         
1377:         updateGenVault(_pID, plyr_[_pID].lrnd);
1378: 
1379:         
1380:         uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
1381:         if (_earnings > 0)
1382:         {
1383:             plyr_[_pID].win = 0;
1384:             plyr_[_pID].gen = 0;
1385:             plyr_[_pID].aff = 0;
1386:         }
1387: 
1388:         return(_earnings);
1389:     }
1390: 
1391:     
1392: 
1393: 
1394:     function endTx(uint256 _pID, uint256 _team, uint256 _eth, uint256 _keys, F3Ddatasets.EventReturns memory _eventData_)
1395:         private
1396:     {
1397:         _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000) + (_team * 100000000000000000000000000000);
1398:         _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
1399: 
1400:         emit F3Devents.onEndTx
1401:         (
1402:             _eventData_.compressedData,
1403:             _eventData_.compressedIDs,
1404:             plyr_[_pID].name,
1405:             msg.sender,
1406:             _eth,
1407:             _keys,
1408:             _eventData_.winnerAddr,
1409:             _eventData_.winnerName,
1410:             _eventData_.amountWon,
1411:             _eventData_.newPot,
1412:             _eventData_.P3DAmount,
1413:             _eventData_.genAmount,
1414:             _eventData_.potAmount,
1415:             airDropPot_
1416:         );
1417:     }
1418: 
1419: 
1420: 
1421: 
1422:     
1423: 
1424: 
1425:     bool public activated_ = false;
1426:     function activate()
1427:         public
1428:     {
1429:         
1430:         require(msg.sender == admin);
1431: 
1432: 
1433:         
1434:         require(activated_ == false);
1435: 
1436:         
1437:         activated_ = true;
1438: 
1439:         
1440:         rID_ = 1;
1441:             round_[1].strt = now + rndExtra_ - rndGap_;
1442:             round_[1].end = now + rndInit_ + rndExtra_;
1443:     }
1444: }
1445: 
1446: 
1447: 
1448: 
1449: 
1450: library F3Ddatasets {
1451:     
1452:     
1453:         
1454:         
1455:         
1456:         
1457:         
1458:         
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
1470:     struct EventReturns {
1471:         uint256 compressedData;
1472:         uint256 compressedIDs;
1473:         address winnerAddr;         
1474:         bytes32 winnerName;         
1475:         uint256 amountWon;          
1476:         uint256 newPot;             
1477:         uint256 P3DAmount;          
1478:         uint256 genAmount;          
1479:         uint256 potAmount;          
1480:     }
1481:     struct Player {
1482:         address addr;   
1483:         bytes32 name;   
1484:         uint256 win;    
1485:         uint256 gen;    
1486:         uint256 aff;    
1487:         uint256 lrnd;   
1488:         uint256 laff;   
1489:     }
1490:     struct PlayerRounds {
1491:         uint256 eth;    
1492:         uint256 keys;   
1493:         uint256 mask;   
1494:         uint256 ico;    
1495:     }
1496:     struct Round {
1497:         uint256 plyr;   
1498:         uint256 team;   
1499:         uint256 end;    
1500:         bool ended;     
1501:         uint256 strt;   
1502:         uint256 keys;   
1503:         uint256 eth;    
1504:         uint256 pot;    
1505:         uint256 mask;   
1506:         uint256 ico;    
1507:         uint256 icoGen; 
1508:         uint256 icoAvg; 
1509:     }
1510:     struct TeamFee {
1511:         uint256 gen;    
1512:         uint256 p3d;    
1513:     }
1514:     struct PotSplit {
1515:         uint256 gen;    
1516:         uint256 p3d;    
1517:     }
1518: }
1519: 
1520: 
1521: 
1522: 
1523: 
1524: library F3DKeysCalcShort {
1525:     using SafeMath for *;
1526:     
1527: 
1528: 
1529: 
1530: 
1531: 
1532:     function keysRec(uint256 _curEth, uint256 _newEth)
1533:         internal
1534:         pure
1535:         returns (uint256)
1536:     {
1537:         return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
1538:     }
1539: 
1540:     
1541: 
1542: 
1543: 
1544: 
1545: 
1546:     function ethRec(uint256 _curKeys, uint256 _sellKeys)
1547:         internal
1548:         pure
1549:         returns (uint256)
1550:     {
1551:         return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
1552:     }
1553: 
1554:     
1555: 
1556: 
1557: 
1558: 
1559:     function keys(uint256 _eth)
1560:         internal
1561:         pure
1562:         returns(uint256)
1563:     {
1564:         return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
1565:     }
1566: 
1567:     
1568: 
1569: 
1570: 
1571: 
1572:     function eth(uint256 _keys)
1573:         internal
1574:         pure
1575:         returns(uint256)
1576:     {
1577:         return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
1578:     }
1579: }
1580: 
1581: 
1582: 
1583: 
1584: 
1585: 
1586: interface PlayerBookInterface {
1587:     function getPlayerID(address _addr) external returns (uint256);
1588:     function getPlayerName(uint256 _pID) external view returns (bytes32);
1589:     function getPlayerLAff(uint256 _pID) external view returns (uint256);
1590:     function getPlayerAddr(uint256 _pID) external view returns (address);
1591:     function getNameFee() external view returns (uint256);
1592:     function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
1593:     function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
1594:     function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
1595: }
1596: 
1597: 
1598: library NameFilter {
1599:     
1600: 
1601: 
1602: 
1603: 
1604: 
1605: 
1606: 
1607: 
1608: 
1609:     function nameFilter(string _input)
1610:         internal
1611:         pure
1612:         returns(bytes32)
1613:     {
1614:         bytes memory _temp = bytes(_input);
1615:         uint256 _length = _temp.length;
1616: 
1617:         
1618:         require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
1619:         
1620:         require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
1621:         
1622:         if (_temp[0] == 0x30)
1623:         {
1624:             require(_temp[1] != 0x78, "string cannot start with 0x");
1625:             require(_temp[1] != 0x58, "string cannot start with 0X");
1626:         }
1627: 
1628:         
1629:         bool _hasNonNumber;
1630: 
1631:         
1632:         for (uint256 i = 0; i < _length; i++)
1633:         {
1634:             
1635:             if (_temp[i] > 0x40 && _temp[i] < 0x5b)
1636:             {
1637:                 
1638:                 _temp[i] = byte(uint(_temp[i]) + 32);
1639: 
1640:                 
1641:                 if (_hasNonNumber == false)
1642:                     _hasNonNumber = true;
1643:             } else {
1644:                 require
1645:                 (
1646:                     
1647:                     _temp[i] == 0x20 ||
1648:                     
1649:                     (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
1650:                     
1651:                     (_temp[i] > 0x2f && _temp[i] < 0x3a),
1652:                     "string contains invalid characters"
1653:                 );
1654:                 
1655:                 if (_temp[i] == 0x20)
1656:                     require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
1657: 
1658:                 
1659:                 if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
1660:                     _hasNonNumber = true;
1661:             }
1662:         }
1663: 
1664:         require(_hasNonNumber == true, "string cannot be only numbers");
1665: 
1666:         bytes32 _ret;
1667:         assembly {
1668:             _ret := mload(add(_temp, 32))
1669:         }
1670:         return (_ret);
1671:     }
1672: }
1673: 
1674: 
1675: 
1676: 
1677: 
1678: 
1679: 
1680: 
1681: 
1682: 
1683: 
1684: library SafeMath {
1685: 
1686:     
1687: 
1688: 
1689:     function mul(uint256 a, uint256 b)
1690:         internal
1691:         pure
1692:         returns (uint256 c)
1693:     {
1694:         if (a == 0) {
1695:             return 0;
1696:         }
1697:         c = a * b;
1698:         require(c / a == b, "SafeMath mul failed");
1699:         return c;
1700:     }
1701: 
1702:     
1703: 
1704: 
1705:     function sub(uint256 a, uint256 b)
1706:         internal
1707:         pure
1708:         returns (uint256)
1709:     {
1710:         require(b <= a, "SafeMath sub failed");
1711:         return a - b;
1712:     }
1713: 
1714:     
1715: 
1716: 
1717:     function add(uint256 a, uint256 b)
1718:         internal
1719:         pure
1720:         returns (uint256 c)
1721:     {
1722:         c = a + b;
1723:         require(c >= a, "SafeMath add failed");
1724:         return c;
1725:     }
1726: 
1727:     
1728: 
1729: 
1730:     function sqrt(uint256 x)
1731:         internal
1732:         pure
1733:         returns (uint256 y)
1734:     {
1735:         uint256 z = ((add(x,1)) / 2);
1736:         y = x;
1737:         while (z < y)
1738:         {
1739:             y = z;
1740:             z = ((add((x / z),z)) / 2);
1741:         }
1742:     }
1743: 
1744:     
1745: 
1746: 
1747:     function sq(uint256 x)
1748:         internal
1749:         pure
1750:         returns (uint256)
1751:     {
1752:         return (mul(x,x));
1753:     }
1754: 
1755:     
1756: 
1757: 
1758:     function pwr(uint256 x, uint256 y)
1759:         internal
1760:         pure
1761:         returns (uint256)
1762:     {
1763:         if (x==0)
1764:             return (0);
1765:         else if (y==0)
1766:             return (1);
1767:         else
1768:         {
1769:             uint256 z = x;
1770:             for (uint256 i=1; i < y; i++)
1771:                 z = mul(z,x);
1772:             return (z);
1773:         }
1774:     }
1775: }