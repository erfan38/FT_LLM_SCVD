1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: contract FomoDD is modularFomoDD {
4: 4:     using SafeMath for *;
5: 5:     using NameFilter for string;
6: 6:     using FDDKeysCalc for uint256;
7: 7: 	
8: 8:     
9: 9:     BankInterfaceForForwarder constant private Bank = BankInterfaceForForwarder(0xfa1678C00299fB685794865eA5e20dB155a8C913);
10: 10: 	PlayerBookInterface constant private PlayerBook = PlayerBookInterface(0xcB530be74c05a120F1fe6e490E45f1EE14c49157);
11: 11: 
12: 12:     address private admin = msg.sender;
13: 13:     string constant public name = "FomoDD";
14: 14:     string constant public symbol = "Chives";
15: 15: 
16: 16:     
17: 17:     uint256 private rndGap_ = 0;
18: 18:     uint256 private rndExtra_ = 0 minutes;
19: 19:     uint256 constant private rndInit_ = 12 hours;                
20: 20:     uint256 constant private rndInc_ = 30 seconds;              
21: 21:     uint256 constant private rndMax_ = 24 hours;                
22: 22: 
23: 23: 
24: 24: 
25: 25: 
26: 26: 	uint256 public airDropPot_;             
27: 27:     uint256 public airDropTracker_ = 0;     
28: 28: 
29: 29: 
30: 30: 
31: 31:     mapping (address => uint256) public pIDxAddr_;          
32: 32:     mapping (bytes32 => uint256) public pIDxName_;          
33: 33:     mapping (uint256 => FDDdatasets.Player) public plyr_;   
34: 34:     mapping (uint256 => FDDdatasets.PlayerRounds) public plyrRnds_; 
35: 35:     mapping (uint256 => mapping (uint256 => FDDdatasets.PlayerRounds)) public plyrRnds; 
36: 36:     mapping (uint256 => mapping (bytes32 => bool)) public plyrNames_; 
37: 37: 
38: 38: 
39: 39: 
40: 40:     uint256 public rID_;    
41: 41:     FDDdatasets.Round public round_;   
42: 42:     mapping (uint256 => FDDdatasets.Round) public round; 
43: 43: 
44: 44: 
45: 45: 
46: 46:     uint256 public fees_ = 60;          
47: 47:     uint256 public potSplit_ = 45;     
48: 48: 
49: 49: 
50: 50: 
51: 51: 
52: 52:     constructor()
53: 53:         public
54: 54:     {
55: 55: 	}
56: 56: 
57: 57: 
58: 58: 
59: 59: 
60: 60:     
61: 61: 
62: 62: 
63: 63: 
64: 64:     modifier isActivated() {
65: 65:         require(activated_ == true, "its not ready yet"); 
66: 66:         _;
67: 67:     }
68: 68:     
69: 69:     
70: 70: 
71: 71: 
72: 72:     modifier isHuman() {
73: 73:         address _addr = msg.sender;
74: 74:         uint256 _codeLength;
75: 75:         
76: 76:         assembly {_codeLength := extcodesize(_addr)}
77: 77:         require(_codeLength == 0, "non smart contract address only");
78: 78:         _;
79: 79:     }
80: 80: 
81: 81:     
82: 82: 
83: 83: 
84: 84:     modifier isWithinLimits(uint256 _eth) {
85: 85:         require(_eth >= 1000000000, "too little money");
86: 86:         require(_eth <= 100000000000000000000000, "too much money");
87: 87:         _;    
88: 88:     }
89: 89:     
90: 90: 
91: 91: 
92: 92: 
93: 93: 
94: 94:     
95: 95: 
96: 96: 
97: 97:     function()
98: 98:         isActivated()
99: 99:         isHuman()
100: 100:         isWithinLimits(msg.value)
101: 101:         public
102: 102:         payable
103: 103:     {
104: 104:         
105: 105:         FDDdatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
106: 106:             
107: 107:         
108: 108:         uint256 _pID = pIDxAddr_[msg.sender];
109: 109:         
110: 110:         
111: 111:         buyCore(_pID, plyr_[_pID].laff, _eventData_);
112: 112:     }
113: 113:     
114: 114:     
115: 115: 
116: 116: 
117: 117: 
118: 118: 
119: 119: 
120: 120: 
121: 121:     function buyXid(uint256 _affCode)
122: 122:         isActivated()
123: 123:         isHuman()
124: 124:         isWithinLimits(msg.value)
125: 125:         public
126: 126:         payable
127: 127:     {
128: 128:         
129: 129:         FDDdatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
130: 130:         
131: 131:         
132: 132:         uint256 _pID = pIDxAddr_[msg.sender];
133: 133:         
134: 134:         
135: 135:         
136: 136:         if (_affCode == 0 || _affCode == _pID)
137: 137:         {
138: 138:             
139: 139:             _affCode = plyr_[_pID].laff;
140: 140:             
141: 141:         
142: 142:         } else if (_affCode != plyr_[_pID].laff) {
143: 143:             
144: 144:             plyr_[_pID].laff = _affCode;
145: 145:         }
146: 146:                 
147: 147:         
148: 148:         buyCore(_pID, _affCode, _eventData_);
149: 149:     }
150: 150:     
151: 151:     function buyXaddr(address _affCode)
152: 152:         isActivated()
153: 153:         isHuman()
154: 154:         isWithinLimits(msg.value)
155: 155:         public
156: 156:         payable
157: 157:     {
158: 158:         
159: 159:         FDDdatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
160: 160:         
161: 161:         
162: 162:         uint256 _pID = pIDxAddr_[msg.sender];
163: 163:         
164: 164:         
165: 165:         uint256 _affID;
166: 166:         
167: 167:         if (_affCode == address(0) || _affCode == msg.sender)
168: 168:         {
169: 169:             
170: 170:             _affID = plyr_[_pID].laff;
171: 171:         
172: 172:         
173: 173:         } else {
174: 174:             
175: 175:             _affID = pIDxAddr_[_affCode];
176: 176:             
177: 177:             
178: 178:             if (_affID != plyr_[_pID].laff)
179: 179:             {
180: 180:                 
181: 181:                 plyr_[_pID].laff = _affID;
182: 182:             }
183: 183:         }
184: 184:         
185: 185:         
186: 186:         buyCore(_pID, _affID, _eventData_);
187: 187:     }
188: 188:     
189: 189:     function buyXname(bytes32 _affCode)
190: 190:         isActivated()
191: 191:         isHuman()
192: 192:         isWithinLimits(msg.value)
193: 193:         public
194: 194:         payable
195: 195:     {
196: 196:         
197: 197:         FDDdatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
198: 198:         
199: 199:         
200: 200:         uint256 _pID = pIDxAddr_[msg.sender];
201: 201:         
202: 202:         
203: 203:         uint256 _affID;
204: 204:         
205: 205:         if (_affCode == '' || _affCode == plyr_[_pID].name)
206: 206:         {
207: 207:             
208: 208:             _affID = plyr_[_pID].laff;
209: 209:         
210: 210:         
211: 211:         } else {
212: 212:             
213: 213:             _affID = pIDxName_[_affCode];
214: 214:             
215: 215:             
216: 216:             if (_affID != plyr_[_pID].laff)
217: 217:             {
218: 218:                 
219: 219:                 plyr_[_pID].laff = _affID;
220: 220:             }
221: 221:         }
222: 222:         
223: 223:         
224: 224:         buyCore(_pID, _affID, _eventData_);
225: 225:     }
226: 226:     
227: 227:     
228: 228: 
229: 229: 
230: 230: 
231: 231: 
232: 232: 
233: 233: 
234: 234: 
235: 235: 
236: 236:     function reLoadXid(uint256 _affCode, uint256 _eth)
237: 237:         isActivated()
238: 238:         isHuman()
239: 239:         isWithinLimits(_eth)
240: 240:         public
241: 241:     {
242: 242:         
243: 243:         FDDdatasets.EventReturns memory _eventData_;
244: 244:         
245: 245:         
246: 246:         uint256 _pID = pIDxAddr_[msg.sender];
247: 247:         
248: 248:         
249: 249:         
250: 250:         if (_affCode == 0 || _affCode == _pID)
251: 251:         {
252: 252:             
253: 253:             _affCode = plyr_[_pID].laff;
254: 254:             
255: 255:         
256: 256:         } else if (_affCode != plyr_[_pID].laff) {
257: 257:             
258: 258:             plyr_[_pID].laff = _affCode;
259: 259:         }
260: 260: 
261: 261:         
262: 262:         reLoadCore(_pID, _affCode, _eth, _eventData_);
263: 263:     }
264: 264:     
265: 265:     function reLoadXaddr(address _affCode, uint256 _eth)
266: 266:         isActivated()
267: 267:         isHuman()
268: 268:         isWithinLimits(_eth)
269: 269:         public
270: 270:     {
271: 271:         
272: 272:         FDDdatasets.EventReturns memory _eventData_;
273: 273:         
274: 274:         
275: 275:         uint256 _pID = pIDxAddr_[msg.sender];
276: 276:         
277: 277:         
278: 278:         uint256 _affID;
279: 279:         
280: 280:         if (_affCode == address(0) || _affCode == msg.sender)
281: 281:         {
282: 282:             
283: 283:             _affID = plyr_[_pID].laff;
284: 284:         
285: 285:         
286: 286:         } else {
287: 287:             
288: 288:             _affID = pIDxAddr_[_affCode];
289: 289:             
290: 290:             
291: 291:             if (_affID != plyr_[_pID].laff)
292: 292:             {
293: 293:                 
294: 294:                 plyr_[_pID].laff = _affID;
295: 295:             }
296: 296:         }
297: 297:                 
298: 298:         
299: 299:         reLoadCore(_pID, _affID, _eth, _eventData_);
300: 300:     }
301: 301:     
302: 302:     function reLoadXname(bytes32 _affCode, uint256 _eth)
303: 303:         isActivated()
304: 304:         isHuman()
305: 305:         isWithinLimits(_eth)
306: 306:         public
307: 307:     {
308: 308:         
309: 309:         FDDdatasets.EventReturns memory _eventData_;
310: 310:         
311: 311:         
312: 312:         uint256 _pID = pIDxAddr_[msg.sender];
313: 313:         
314: 314:         
315: 315:         uint256 _affID;
316: 316:         
317: 317:         if (_affCode == '' || _affCode == plyr_[_pID].name)
318: 318:         {
319: 319:             
320: 320:             _affID = plyr_[_pID].laff;
321: 321:         
322: 322:         
323: 323:         } else {
324: 324:             
325: 325:             _affID = pIDxName_[_affCode];
326: 326:             
327: 327:             
328: 328:             if (_affID != plyr_[_pID].laff)
329: 329:             {
330: 330:                 
331: 331:                 plyr_[_pID].laff = _affID;
332: 332:             }
333: 333:         }
334: 334:                 
335: 335:         
336: 336:         reLoadCore(_pID, _affID, _eth, _eventData_);
337: 337:     }
338: 338: 
339: 339:     
340: 340: 
341: 341: 
342: 342: 
343: 343:     function withdraw()
344: 344:         isActivated()
345: 345:         isHuman()
346: 346:         public
347: 347:     {
348: 348:         uint256 _rID = rID_;
349: 349: 
350: 350:         
351: 351:         uint256 _now = now;
352: 352:         
353: 353:         
354: 354:         uint256 _pID = pIDxAddr_[msg.sender];
355: 355:         
356: 356:         
357: 357:         uint256 _eth;
358: 358:         
359: 359:         
360: 360:         if (_now > round[_rID].end && round[_rID].ended == false && round[_rID].plyr != 0)
361: 361:         {
362: 362:             
363: 363:             FDDdatasets.EventReturns memory _eventData_;
364: 364:             
365: 365:             
366: 366: 			round[_rID].ended = true;
367: 367:             _eventData_ = endRound(_eventData_);
368: 368:             
369: 369: 			
370: 370:             _eth = withdrawEarnings(_pID);
371: 371:             
372: 372:             
373: 373:             if (_eth > 0)
374: 374:                 plyr_[_pID].addr.transfer(_eth);    
375: 375:             
376: 376:             
377: 377:             _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
378: 378:             _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
379: 379:             
380: 380:             
381: 381:             emit FDDEvents.onWithdrawAndDistribute
382: 382:             (
383: 383:                 msg.sender, 
384: 384:                 plyr_[_pID].name, 
385: 385:                 _eth, 
386: 386:                 _eventData_.compressedData, 
387: 387:                 _eventData_.compressedIDs, 
388: 388:                 _eventData_.winnerAddr, 
389: 389:                 _eventData_.winnerName, 
390: 390:                 _eventData_.amountWon, 
391: 391:                 _eventData_.newPot, 
392: 392:                 _eventData_.genAmount
393: 393:             );
394: 394:         
395: 395:         } else {
396: 396:             
397: 397:             _eth = withdrawEarnings(_pID);
398: 398:             
399: 399:             
400: 400:             if (_eth > 0)
401: 401:                 plyr_[_pID].addr.transfer(_eth);
402: 402:             
403: 403:             
404: 404:             emit FDDEvents.onWithdraw(_pID, msg.sender, plyr_[_pID].name, _eth, _now);
405: 405:         }
406: 406:     }
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
432: 432:     function registerNameXID(string _nameString, uint256 _affCode, bool _all)
433: 433:         isHuman()
434: 434:         public
435: 435:         payable
436: 436:     {
437: 437:         bytes32 _name = _nameString.nameFilter();
438: 438:         address _addr = msg.sender;
439: 439:         uint256 _paid = msg.value;
440: 440:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXIDFromDapp.value(_paid)(_addr, _name, _affCode, _all);
441: 441: 
442: 442:         uint256 _pID = pIDxAddr_[_addr];
443: 443:         
444: 444:         
445: 445:         emit FDDEvents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
446: 446:     }
447: 447:     
448: 448:     function registerNameXaddr(string _nameString, address _affCode, bool _all)
449: 449:         isHuman()
450: 450:         public
451: 451:         payable
452: 452:     {
453: 453:         bytes32 _name = _nameString.nameFilter();
454: 454:         address _addr = msg.sender;
455: 455:         uint256 _paid = msg.value;
456: 456:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXaddrFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
457: 457:         
458: 458:         uint256 _pID = pIDxAddr_[_addr];
459: 459:         
460: 460:         
461: 461:         emit FDDEvents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
462: 462:     }
463: 463:     
464: 464:     function registerNameXname(string _nameString, bytes32 _affCode, bool _all)
465: 465:         isHuman()
466: 466:         public
467: 467:         payable
468: 468:     {
469: 469:         bytes32 _name = _nameString.nameFilter();
470: 470:         address _addr = msg.sender;
471: 471:         uint256 _paid = msg.value;
472: 472:         (bool _isNewPlayer, uint256 _affID) = PlayerBook.registerNameXnameFromDapp.value(msg.value)(msg.sender, _name, _affCode, _all);
473: 473:         
474: 474:         uint256 _pID = pIDxAddr_[_addr];
475: 475:         
476: 476:         
477: 477:         emit FDDEvents.onNewName(_pID, _addr, _name, _isNewPlayer, _affID, plyr_[_affID].addr, plyr_[_affID].name, _paid, now);
478: 478:     }
479: 479: 
480: 480: 
481: 481: 
482: 482: 
483: 483:     
484: 484: 
485: 485: 
486: 486: 
487: 487: 
488: 488:     function getBuyPrice()
489: 489:         public 
490: 490:         view 
491: 491:         returns(uint256)
492: 492:     {
493: 493:         uint256 _rID = rID_;          
494: 494:         
495: 495:         uint256 _now = now;
496: 496:         
497: 497:         
498: 498:         if (_now > round[_rID].strt + rndGap_ && (_now <= round[_rID].end || (_now > round[_rID].end && round[_rID].plyr == 0)))
499: 499:             return ( (round[_rID].keys.add(1000000000000000000)).ethRec(1000000000000000000) );
500: 500:         else 
501: 501:             return ( 75000000000000 ); 
502: 502:     }
503: 503:     
504: 504:     
505: 505: 
506: 506: 
507: 507: 
508: 508: 
509: 509: 
510: 510:     function getTimeLeft()
511: 511:         public
512: 512:         view
513: 513:         returns(uint256)
514: 514:     {
515: 515:         uint256 _rID = rID_;
516: 516:         
517: 517:         uint256 _now = now;
518: 518:         
519: 519:         if (_now < round[_rID].end)
520: 520:             if (_now > round[_rID].strt + rndGap_)
521: 521:                 return( (round[_rID].end).sub(_now) );
522: 522:             else
523: 523:                 return( (round[_rID].strt + rndGap_).sub(_now));
524: 524:         else
525: 525:             return(0);
526: 526:     }
527: 527:     
528: 528:     
529: 529: 
530: 530: 
531: 531: 
532: 532: 
533: 533: 
534: 534: 
535: 535:     function getPlayerVaults(uint256 _pID)
536: 536:         public
537: 537:         view
538: 538:         returns(uint256 ,uint256, uint256)
539: 539:     {
540: 540:         uint256 _rID = rID_;
541: 541: 
542: 542:         
543: 543:         if (now > round[_rID].end && round[_rID].ended == false && round[_rID].plyr != 0)
544: 544:         {
545: 545:             
546: 546:             if (round[_rID].plyr == _pID)
547: 547:             {
548: 548:                 return
549: 549:                 (
550: 550:                     (plyr_[_pID].win).add( ((round[_rID].pot).mul(48)) / 100 ),
551: 551:                     (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds[_pID][_rID].mask)   ),
552: 552:                     plyr_[_pID].aff
553: 553:                 );
554: 554:             
555: 555:             } else {
556: 556:                 return
557: 557:                 (
558: 558:                     plyr_[_pID].win,
559: 559:                     (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds[_pID][_rID].mask)  ),
560: 560:                     plyr_[_pID].aff
561: 561:                 );
562: 562:             }
563: 563:             plyrRnds_[_pID] = plyrRnds[_pID][_rID];
564: 564:         
565: 565:         } else {
566: 566:             return
567: 567:             (
568: 568:                 plyr_[_pID].win,
569: 569:                 (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
570: 570:                 plyr_[_pID].aff
571: 571:             );
572: 572:         }
573: 573:     }
574: 574:     
575: 575:     
576: 576: 
577: 577: 
578: 578:     function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
579: 579:         private
580: 580:         view
581: 581:         returns(uint256)
582: 582:     {
583: 583:         return(  ((((round[_rID].mask).add(((((round[_rID].pot).mul(potSplit_)) / 100).mul(1000000000000000000)) / (round[_rID].keys))).mul(plyrRnds[_pID][_rID].keys)) / 1000000000000000000)  );
584: 584:     }
585: 585:     
586: 586:     
587: 587: 
588: 588: 
589: 589: 
590: 590: 
591: 591: 
592: 592: 
593: 593: 
594: 594: 
595: 595: 
596: 596: 
597: 597: 
598: 598:     function getCurrentRoundInfo()
599: 599:         public
600: 600:         view
601: 601:         returns(uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256)
602: 602:     {
603: 603:         uint256 _rID = rID_;
604: 604:         return
605: 605:         (
606: 606:             round[_rID].keys,              
607: 607:             round[_rID].end,               
608: 608:             round[_rID].strt,              
609: 609:             round[_rID].pot,               
610: 610:             round[_rID].plyr,              
611: 611:             plyr_[round[_rID].plyr].addr,  
612: 612:             plyr_[round[_rID].plyr].name,  
613: 613:             airDropTracker_ + (airDropPot_ * 1000)              
614: 614:         );
615: 615:     }
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
628: 628: 
629: 629: 
630: 630:     function getPlayerInfoByAddress(address _addr)
631: 631:         public 
632: 632:         view 
633: 633:         returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
634: 634:     {
635: 635:         uint256 _rID = rID_;
636: 636: 
637: 637:         if (_addr == address(0))
638: 638:         {
639: 639:             _addr == msg.sender;
640: 640:         }
641: 641:         uint256 _pID = pIDxAddr_[_addr];
642: 642:         
643: 643:         return
644: 644:         (
645: 645:             _pID,                               
646: 646:             plyr_[_pID].name,                   
647: 647:             plyrRnds[_pID][_rID].keys,         
648: 648:             plyr_[_pID].win,                    
649: 649:             (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       
650: 650:             plyr_[_pID].aff,                    
651: 651:             plyrRnds[_pID][_rID].eth           
652: 652:         );
653: 653:     }
654: 654: 
655: 655: 
656: 656: 
657: 657: 
658: 658: 
659: 659:     
660: 660: 
661: 661: 
662: 662: 
663: 663:     function buyCore(uint256 _pID, uint256 _affID, FDDdatasets.EventReturns memory _eventData_)
664: 664:         private
665: 665:     {
666: 666:         uint256 _rID = rID_;
667: 667: 
668: 668:         
669: 669:         uint256 _now = now;
670: 670:         
671: 671:         
672: 672:         if (_now > round[_rID].strt + rndGap_ && (_now <= round[_rID].end || (_now > round[_rID].end && round[_rID].plyr == 0))) 
673: 673:         {
674: 674:             
675: 675:             core(_rID, _pID, msg.value, _affID, _eventData_);
676: 676:         
677: 677:         
678: 678:         } else {
679: 679:             
680: 680:             if (_now > round[_rID].end && round[_rID].ended == false) 
681: 681:             {
682: 682:                 
683: 683: 			    round[_rID].ended = true;
684: 684:                 _eventData_ = endRound(_eventData_);
685: 685:                 
686: 686:                 
687: 687:                 _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
688: 688:                 _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
689: 689:                 
690: 690:                 
691: 691:                 emit FDDEvents.onBuyAndDistribute
692: 692:                 (
693: 693:                     msg.sender, 
694: 694:                     plyr_[_pID].name, 
695: 695:                     msg.value, 
696: 696:                     _eventData_.compressedData, 
697: 697:                     _eventData_.compressedIDs, 
698: 698:                     _eventData_.winnerAddr, 
699: 699:                     _eventData_.winnerName, 
700: 700:                     _eventData_.amountWon, 
701: 701:                     _eventData_.newPot, 
702: 702:                     _eventData_.genAmount
703: 703:                 );
704: 704:             }
705: 705:             
706: 706:             
707: 707:             plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
708: 708:         }
709: 709:     }
710: 710:     
711: 711:     
712: 712: 
713: 713: 
714: 714: 
715: 715:     function reLoadCore(uint256 _pID, uint256 _affID, uint256 _eth, FDDdatasets.EventReturns memory _eventData_)
716: 716:         private
717: 717:     {
718: 718:         uint256 _rID = rID_;
719: 719: 
720: 720:         
721: 721:         uint256 _now = now;
722: 722:         
723: 723:         
724: 724:         if (_now > round[_rID].strt + rndGap_ && (_now <= round[_rID].end || (_now > round[_rID].end && round[_rID].plyr == 0))) 
725: 725:         {
726: 726:             
727: 727:             
728: 728:             
729: 729:             plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
730: 730:             
731: 731:             
732: 732:             core(_rID, _pID, _eth, _affID, _eventData_);
733: 733:         
734: 734:         
735: 735:         } else if (_now > round[_rID].end && round[_rID].ended == false) {
736: 736:             
737: 737:             round[_rID].ended = true;
738: 738:             _eventData_ = endRound(_eventData_);
739: 739:                 
740: 740:             
741: 741:             _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
742: 742:             _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
743: 743:                 
744: 744:             
745: 745:             emit FDDEvents.onReLoadAndDistribute
746: 746:             (
747: 747:                 msg.sender, 
748: 748:                 plyr_[_pID].name, 
749: 749:                 _eventData_.compressedData, 
750: 750:                 _eventData_.compressedIDs, 
751: 751:                 _eventData_.winnerAddr, 
752: 752:                 _eventData_.winnerName, 
753: 753:                 _eventData_.amountWon, 
754: 754:                 _eventData_.newPot, 
755: 755:                 _eventData_.genAmount
756: 756:             );
757: 757:         }
758: 758:     }
759: 759:     
760: 760:     
761: 761: 
762: 762: 
763: 763: 
764: 764:     function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, FDDdatasets.EventReturns memory _eventData_)
765: 765:         private
766: 766:     {
767: 767:         
768: 768:         if (plyrRnds[_pID][_rID].keys == 0)
769: 769:             _eventData_ = managePlayer(_pID, _eventData_);
770: 770:         
771: 771:         
772: 772:         if (round[_rID].eth < 100000000000000000000 && plyrRnds[_pID][_rID].eth.add(_eth) > 10000000000000000000)
773: 773:         {
774: 774:             uint256 _availableLimit = (10000000000000000000).sub(plyrRnds[_pID][_rID].eth);
775: 775:             uint256 _refund = _eth.sub(_availableLimit);
776: 776:             plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
777: 777:             _eth = _availableLimit;
778: 778:         }
779: 779:         
780: 780:         
781: 781:         if (_eth > 1000000000) 
782: 782:         {
783: 783:             
784: 784:             
785: 785:             uint256 _keys = (round[_rID].eth).keysRec(_eth);
786: 786:             
787: 787:             
788: 788:             if (_keys >= 1000000000000000000)
789: 789:             {
790: 790:                 updateTimer(_keys, _rID);
791: 791: 
792: 792:                 
793: 793:                 if (round[_rID].plyr != _pID)
794: 794:                     round[_rID].plyr = _pID;  
795: 795:             
796: 796:                 
797: 797:                 _eventData_.compressedData = _eventData_.compressedData + 100;
798: 798:             }
799: 799:             
800: 800:             
801: 801:             if (_eth >= 100000000000000000)
802: 802:             {
803: 803:                 airDropTracker_++;
804: 804:                 if (airdrop() == true)
805: 805:                 {
806: 806:                     
807: 807:                     uint256 _prize;
808: 808:                     if (_eth >= 10000000000000000000)
809: 809:                     {
810: 810:                         
811: 811:                         _prize = ((airDropPot_).mul(75)) / 100;
812: 812:                         plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
813: 813:                         
814: 814:                         
815: 815:                         airDropPot_ = (airDropPot_).sub(_prize);
816: 816:                         
817: 817:                         
818: 818:                         _eventData_.compressedData += 300000000000000000000000000000000;
819: 819:                     } else if (_eth >= 1000000000000000000 && _eth < 10000000000000000000) {
820: 820:                         
821: 821:                         _prize = ((airDropPot_).mul(50)) / 100;
822: 822:                         plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
823: 823:                         
824: 824:                         
825: 825:                         airDropPot_ = (airDropPot_).sub(_prize);
826: 826:                         
827: 827:                         
828: 828:                         _eventData_.compressedData += 200000000000000000000000000000000;
829: 829:                     } else if (_eth >= 100000000000000000 && _eth < 1000000000000000000) {
830: 830:                         
831: 831:                         _prize = ((airDropPot_).mul(25)) / 100;
832: 832:                         plyr_[_pID].win = (plyr_[_pID].win).add(_prize);
833: 833:                         
834: 834:                         
835: 835:                         airDropPot_ = (airDropPot_).sub(_prize);
836: 836:                         
837: 837:                         
838: 838:                         _eventData_.compressedData += 100000000000000000000000000000000;
839: 839:                     }
840: 840:                     
841: 841:                     _eventData_.compressedData += 10000000000000000000000000000000;
842: 842:                     
843: 843:                     _eventData_.compressedData += _prize * 1000000000000000000000000000000000;
844: 844:                     
845: 845:                     
846: 846:                     airDropTracker_ = 0;
847: 847:                 }
848: 848:             }
849: 849:     
850: 850:             
851: 851:             _eventData_.compressedData = _eventData_.compressedData + (airDropTracker_ * 1000);
852: 852:             
853: 853:             
854: 854:             plyrRnds[_pID][_rID].keys = _keys.add(plyrRnds[_pID][_rID].keys);
855: 855:             plyrRnds[_pID][_rID].eth = _eth.add(plyrRnds[_pID][_rID].eth);
856: 856:             
857: 857:             
858: 858:             round[_rID].keys = _keys.add(round[_rID].keys);
859: 859:             round[_rID].eth = _eth.add(round[_rID].eth);
860: 860:     
861: 861:             
862: 862:             _eventData_ = distributeExternal(_pID, _eth, _affID, _eventData_);
863: 863:             _eventData_ = distributeInternal(_rID, _pID, _eth, _keys, _eventData_);
864: 864:             
865: 865:             
866: 866: 		    endTx(_pID, _eth, _keys, _eventData_);
867: 867:         }
868: 868:         plyrRnds_[_pID] = plyrRnds[_pID][_rID];
869: 869:         round_ = round[_rID];
870: 870:     }
871: 871: 
872: 872: 
873: 873: 
874: 874: 
875: 875:     
876: 876: 
877: 877: 
878: 878: 
879: 879:     function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
880: 880:         private
881: 881:         view
882: 882:         returns(uint256)
883: 883:     {
884: 884:         return((((round[_rIDlast].mask).mul(plyrRnds[_pID][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds[_pID][_rIDlast].mask));
885: 885:     }
886: 886:     
887: 887:     
888: 888: 
889: 889: 
890: 890: 
891: 891: 
892: 892: 
893: 893:     function calcKeysReceived(uint256 _eth)
894: 894:         public
895: 895:         view
896: 896:         returns(uint256)
897: 897:     {
898: 898:         uint256 _rID = rID_;
899: 899:         
900: 900:         uint256 _now = now;
901: 901:         
902: 902:         
903: 903:         if (_now > round[_rID].strt + rndGap_ && (_now <= round[_rID].end || (_now > round[_rID].end && round[_rID].plyr == 0)))
904: 904:             return ( (round[_rID].eth).keysRec(_eth) );
905: 905:         else 
906: 906:             return ( (_eth).keys() );
907: 907:     }
908: 908:     
909: 909:     
910: 910: 
911: 911: 
912: 912: 
913: 913: 
914: 914: 
915: 915:     function iWantXKeys(uint256 _keys)
916: 916:         public
917: 917:         view
918: 918:         returns(uint256)
919: 919:     {
920: 920:         uint256 _rID = rID_;
921: 921:         
922: 922:         uint256 _now = now;
923: 923:         
924: 924:         
925: 925:         if (_now > round[_rID].strt + rndGap_ && (_now <= round[_rID].end || (_now > round[_rID].end && round[_rID].plyr == 0)))
926: 926:             return ( (round[_rID].keys.add(_keys)).ethRec(_keys) );
927: 927:         else 
928: 928:             return ( (_keys).eth() );
929: 929:     }
930: 930: 
931: 931: 
932: 932: 
933: 933: 
934: 934:     
935: 935: 
936: 936: 
937: 937:     function receivePlayerInfo(uint256 _pID, address _addr, bytes32 _name, uint256 _laff)
938: 938:         external
939: 939:     {
940: 940:         require (msg.sender == address(PlayerBook), "only PlayerBook can call this function");
941: 941:         if (pIDxAddr_[_addr] != _pID)
942: 942:             pIDxAddr_[_addr] = _pID;
943: 943:         if (pIDxName_[_name] != _pID)
944: 944:             pIDxName_[_name] = _pID;
945: 945:         if (plyr_[_pID].addr != _addr)
946: 946:             plyr_[_pID].addr = _addr;
947: 947:         if (plyr_[_pID].name != _name)
948: 948:             plyr_[_pID].name = _name;
949: 949:         if (plyr_[_pID].laff != _laff)
950: 950:             plyr_[_pID].laff = _laff;
951: 951:         if (plyrNames_[_pID][_name] == false)
952: 952:             plyrNames_[_pID][_name] = true;
953: 953:     }
954: 954:     
955: 955:     
956: 956: 
957: 957: 
958: 958:     function receivePlayerNameList(uint256 _pID, bytes32 _name)
959: 959:         external
960: 960:     {
961: 961:         require (msg.sender == address(PlayerBook), "only PlayerBook can call this function");
962: 962:         if(plyrNames_[_pID][_name] == false)
963: 963:             plyrNames_[_pID][_name] = true;
964: 964:     }   
965: 965:         
966: 966:     
967: 967: 
968: 968: 
969: 969: 
970: 970:     function determinePID(FDDdatasets.EventReturns memory _eventData_)
971: 971:         private
972: 972:         returns (FDDdatasets.EventReturns)
973: 973:     {
974: 974:         uint256 _pID = pIDxAddr_[msg.sender];
975: 975:         
976: 976:         if (_pID == 0)
977: 977:         {
978: 978:             
979: 979:             _pID = PlayerBook.getPlayerID(msg.sender);
980: 980:             bytes32 _name = PlayerBook.getPlayerName(_pID);
981: 981:             uint256 _laff = PlayerBook.getPlayerLAff(_pID);
982: 982:             
983: 983:             
984: 984:             pIDxAddr_[msg.sender] = _pID;
985: 985:             plyr_[_pID].addr = msg.sender;
986: 986:             
987: 987:             if (_name != "")
988: 988:             {
989: 989:                 pIDxName_[_name] = _pID;
990: 990:                 plyr_[_pID].name = _name;
991: 991:                 plyrNames_[_pID][_name] = true;
992: 992:             }
993: 993:             
994: 994:             if (_laff != 0 && _laff != _pID)
995: 995:                 plyr_[_pID].laff = _laff;
996: 996:             
997: 997:             
998: 998:             _eventData_.compressedData = _eventData_.compressedData + 1;
999: 999:         } 
1000: 1000:         return (_eventData_);
1001: 1001:     }
1002: 1002: 
1003: 1003:     
1004: 1004: 
1005: 1005: 
1006: 1006: 
1007: 1007:     function managePlayer(uint256 _pID, FDDdatasets.EventReturns memory _eventData_)
1008: 1008:         private
1009: 1009:         returns (FDDdatasets.EventReturns)
1010: 1010:     {
1011: 1011:         if (plyr_[_pID].lrnd != 0)
1012: 1012:             updateGenVault(_pID, plyr_[_pID].lrnd);
1013: 1013: 
1014: 1014:         plyr_[_pID].lrnd = rID_;            
1015: 1015:         
1016: 1016:         _eventData_.compressedData = _eventData_.compressedData + 10;
1017: 1017:         
1018: 1018:         return(_eventData_);
1019: 1019:     }
1020: 1020:     
1021: 1021:     
1022: 1022: 
1023: 1023: 
1024: 1024:     function endRound(FDDdatasets.EventReturns memory _eventData_)
1025: 1025:         private
1026: 1026:         returns (FDDdatasets.EventReturns)
1027: 1027:     {        
1028: 1028:         uint256 _rID = rID_;
1029: 1029:         
1030: 1030:         uint256 _winPID = round[_rID].plyr;
1031: 1031:         
1032: 1032:         
1033: 1033:         
1034: 1034:         
1035: 1035:         uint256 _pot = round[_rID].pot;
1036: 1036:         
1037: 1037:         
1038: 1038:         
1039: 1039:         uint256 _win = (_pot.mul(45)) / 100;
1040: 1040:         uint256 _com = (_pot / 10);
1041: 1041:         uint256 _gen = (_pot.mul(potSplit_)) / 100;
1042: 1042:         
1043: 1043:         
1044: 1044:         uint256 _ppt = (_gen.mul(1000000000000000000)) / (round[_rID].keys);
1045: 1045:         uint256 _dust = _gen.sub((_ppt.mul(round[_rID].keys)) / 1000000000000000000);
1046: 1046:         if (_dust > 0)
1047: 1047:         {
1048: 1048:             _gen = _gen.sub(_dust);
1049: 1049:             _com = _com.add(_dust);
1050: 1050:         }
1051: 1051:         
1052: 1052:         
1053: 1053:         plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
1054: 1054:         
1055: 1055:         
1056: 1056:         
1057: 1057:         
1058: 1058:         
1059: 1059:         
1060: 1060:         
1061: 1061:         
1062: 1062:         
1063: 1063:         round[_rID].mask = _ppt.add(round[_rID].mask);
1064: 1064:             
1065: 1065:         
1066: 1066:         _eventData_.compressedData = _eventData_.compressedData + (round[_rID].end * 1000000);
1067: 1067:         _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000);
1068: 1068:         _eventData_.winnerAddr = plyr_[_winPID].addr;
1069: 1069:         _eventData_.winnerName = plyr_[_winPID].name;
1070: 1070:         _eventData_.amountWon = _win;
1071: 1071:         _eventData_.genAmount = _gen;
1072: 1072:         _eventData_.newPot = _com;
1073: 1073:         
1074: 1074:         
1075: 1075:         rID_++;
1076: 1076:         _rID++;
1077: 1077:         round[_rID].strt = now + rndExtra_;
1078: 1078:         round[_rID].end = now + rndInit_ + rndExtra_;
1079: 1079:         round[_rID].pot = _com;
1080: 1080:         round_ = round[_rID];
1081: 1081: 
1082: 1082:         return(_eventData_);
1083: 1083:     }
1084: 1084:     
1085: 1085:     
1086: 1086: 
1087: 1087: 
1088: 1088:     function updateGenVault(uint256 _pID, uint256 _rIDlast)
1089: 1089:         private 
1090: 1090:     {
1091: 1091:         uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
1092: 1092:         if (_earnings > 0)
1093: 1093:         {
1094: 1094:             
1095: 1095:             plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
1096: 1096:             
1097: 1097:             plyrRnds[_pID][_rIDlast].mask = _earnings.add(plyrRnds[_pID][_rIDlast].mask);
1098: 1098:             plyrRnds_[_pID] = plyrRnds[_pID][_rIDlast];
1099: 1099:         }
1100: 1100:     }
1101: 1101:     
1102: 1102:     
1103: 1103: 
1104: 1104: 
1105: 1105:     function updateTimer(uint256 _keys, uint256 _rID)
1106: 1106:         private
1107: 1107:     {
1108: 1108:         
1109: 1109:         uint256 _now = now;
1110: 1110:         
1111: 1111:         
1112: 1112:         uint256 _newTime;
1113: 1113:         if (_now > round[_rID].end && round[_rID].plyr == 0)
1114: 1114:             _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
1115: 1115:         else
1116: 1116:             _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round[_rID].end);
1117: 1117:         
1118: 1118:         
1119: 1119:         if (_newTime < (rndMax_).add(_now))
1120: 1120:             round[_rID].end = _newTime;
1121: 1121:         else
1122: 1122:             round[_rID].end = rndMax_.add(_now);
1123: 1123: 
1124: 1124:         round_ = round[_rID];
1125: 1125:     }
1126: 1126:     
1127: 1127:     
1128: 1128: 
1129: 1129: 
1130: 1130: 
1131: 1131: 
1132: 1132:     function airdrop()
1133: 1133:         private 
1134: 1134:         view 
1135: 1135:         returns(bool)
1136: 1136:     {
1137: 1137:         uint256 seed = uint256(keccak256(abi.encodePacked(
1138: 1138:             
1139: 1139:             (block.timestamp).add
1140: 1140:             (block.difficulty).add
1141: 1141:             ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
1142: 1142:             (block.gaslimit).add
1143: 1143:             ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
1144: 1144:             (block.number)
1145: 1145:             
1146: 1146:         )));
1147: 1147:         if((seed - ((seed / 1000) * 1000)) < airDropTracker_)
1148: 1148:             return(true);
1149: 1149:         else
1150: 1150:             return(false);
1151: 1151:     }
1152: 1152: 
1153: 1153:     
1154: 1154: 
1155: 1155: 
1156: 1156:     function distributeExternal(uint256 _pID, uint256 _eth, uint256 _affID, FDDdatasets.EventReturns memory _eventData_)
1157: 1157:         private
1158: 1158:         returns(FDDdatasets.EventReturns)
1159: 1159:     {
1160: 1160:         
1161: 1161:         uint256 _com = _eth * 5 / 100;
1162: 1162:                 
1163: 1163:         
1164: 1164:         uint256 _aff = _eth * 10 / 100;
1165: 1165:         
1166: 1166:         
1167: 1167:         
1168: 1168:         if (_affID != _pID && plyr_[_affID].name != '') {
1169: 1169:             plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
1170: 1170:             emit FDDEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, plyr_[_affID].name, _pID, _aff, now);
1171: 1171:         } else {
1172: 1172:             
1173: 1173:             _com += _aff;
1174: 1174:         }
1175: 1175: 
1176: 1176:         if (!address(Bank).call.value(_com)(bytes4(keccak256("deposit()"))))
1177: 1177:         {
1178: 1178:             
1179: 1179:             
1180: 1180:             
1181: 1181:             
1182: 1182:             
1183: 1183:             
1184: 1184:         }
1185: 1185: 
1186: 1186:         return(_eventData_);
1187: 1187:     }
1188: 1188:     
1189: 1189:     
1190: 1190: 
1191: 1191: 
1192: 1192:     function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _keys, FDDdatasets.EventReturns memory _eventData_)
1193: 1193:         private
1194: 1194:         returns(FDDdatasets.EventReturns)
1195: 1195:     {
1196: 1196:         
1197: 1197:         uint256 _gen = (_eth.mul(fees_)) / 100;
1198: 1198:         
1199: 1199:         
1200: 1200:         uint256 _air = (_eth / 20);
1201: 1201:         airDropPot_ = airDropPot_.add(_air);
1202: 1202:                 
1203: 1203:         
1204: 1204:         uint256 _pot = (_eth.mul(20) / 100);
1205: 1205:         
1206: 1206:         
1207: 1207:         
1208: 1208:         uint256 _dust = updateMasks(_rID, _pID, _gen, _keys);
1209: 1209:         if (_dust > 0)
1210: 1210:             _gen = _gen.sub(_dust);
1211: 1211:         
1212: 1212:         
1213: 1213:         round[_rID].pot = _pot.add(_dust).add(round[_rID].pot);
1214: 1214:         
1215: 1215:         
1216: 1216:         _eventData_.genAmount = _gen.add(_eventData_.genAmount);
1217: 1217:         _eventData_.potAmount = _pot;
1218: 1218:         round_ = round[_rID];
1219: 1219: 
1220: 1220:         return(_eventData_);
1221: 1221:     }
1222: 1222: 
1223: 1223:     
1224: 1224: 
1225: 1225: 
1226: 1226: 
1227: 1227:     function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _keys)
1228: 1228:         private
1229: 1229:         returns(uint256)
1230: 1230:     {
1231: 1231:         
1232: 1232: 
1233: 1233: 
1234: 1234: 
1235: 1235: 
1236: 1236: 
1237: 1237: 
1238: 1238: 
1239: 1239: 
1240: 1240: 
1241: 1241:         
1242: 1242:         
1243: 1243:         uint256 _ppt = (_gen.mul(1000000000000000000)) / (round[_rID].keys);
1244: 1244:         round[_rID].mask = _ppt.add(round[_rID].mask);
1245: 1245:             
1246: 1246:         
1247: 1247:         
1248: 1248:         uint256 _pearn = (_ppt.mul(_keys)) / (1000000000000000000);
1249: 1249:         plyrRnds[_pID][_rID].mask = (((round[_rID].mask.mul(_keys)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds[_pID][_rID].mask);
1250: 1250:         plyrRnds_[_pID] = plyrRnds[_pID][_rID];
1251: 1251:         round_ = round[_rID];
1252: 1252:         
1253: 1253:         return(_gen.sub((_ppt.mul(round[_rID].keys)) / (1000000000000000000)));
1254: 1254:     }
1255: 1255:     
1256: 1256:     
1257: 1257: 
1258: 1258: 
1259: 1259: 
1260: 1260:     function withdrawEarnings(uint256 _pID)
1261: 1261:         private
1262: 1262:         returns(uint256)
1263: 1263:     {
1264: 1264:         
1265: 1265:         updateGenVault(_pID, plyr_[_pID].lrnd);
1266: 1266:         
1267: 1267:         
1268: 1268:         uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
1269: 1269:         if (_earnings > 0)
1270: 1270:         {
1271: 1271:             plyr_[_pID].win = 0;
1272: 1272:             plyr_[_pID].gen = 0;
1273: 1273:             plyr_[_pID].aff = 0;
1274: 1274:         }
1275: 1275: 
1276: 1276:         return(_earnings);
1277: 1277:     }
1278: 1278:     
1279: 1279:     
1280: 1280: 
1281: 1281: 
1282: 1282:     function endTx(uint256 _pID, uint256 _eth, uint256 _keys, FDDdatasets.EventReturns memory _eventData_)
1283: 1283:         private
1284: 1284:     {
1285: 1285:         _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000);
1286: 1286:         _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
1287: 1287:         
1288: 1288:         emit FDDEvents.onEndTx
1289: 1289:         (
1290: 1290:             _eventData_.compressedData,
1291: 1291:             _eventData_.compressedIDs,
1292: 1292:             plyr_[_pID].name,
1293: 1293:             msg.sender,
1294: 1294:             _eth,
1295: 1295:             _keys,
1296: 1296:             _eventData_.winnerAddr,
1297: 1297:             _eventData_.winnerName,
1298: 1298:             _eventData_.amountWon,
1299: 1299:             _eventData_.newPot,
1300: 1300:             _eventData_.genAmount,
1301: 1301:             _eventData_.potAmount,
1302: 1302:             airDropPot_
1303: 1303:         );
1304: 1304:     }
1305: 1305: 
1306: 1306:     
1307: 1307: 
1308: 1308: 
1309: 1309:     bool public activated_ = false;
1310: 1310:     function activate()
1311: 1311:         public
1312: 1312:     {
1313: 1313:         
1314: 1314:         
1315: 1315:         require(msg.sender == admin);
1316: 1316:         
1317: 1317:         
1318: 1318:         require(activated_ == false, "FomoDD already activated");
1319: 1319:         
1320: 1320:         
1321: 1321:         activated_ = true;
1322: 1322:         
1323: 1323:         rID_ = 1;
1324: 1324:         round[1].strt = now + rndExtra_;
1325: 1325:         round[1].end = now + rndInit_ + rndExtra_;
1326: 1326:         round_ = round[1];
1327: 1327:     }
1328: 1328: }
1329: 1329: 
1330: 1330: 
1331: 1331: 
1332: 1332: 
1333: 1333: 
1334: 1334: library FDDdatasets {
1335: 1335:     
1336: 1336:     
1337: 1337:         
1338: 1338:         
1339: 1339:         
1340: 1340:         
1341: 1341:         
1342: 1342:         
1343: 1343:         
1344: 1344:         
1345: 1345:         
1346: 1346:         
1347: 1347:         
1348: 1348:         
1349: 1349:     
1350: 1350:     
1351: 1351:         
1352: 1352:         
1353: 1353:         
1354: 1354:     struct EventReturns {
1355: 1355:         uint256 compressedData;
1356: 1356:         uint256 compressedIDs;
1357: 1357:         address winnerAddr;         
1358: 1358:         bytes32 winnerName;         
1359: 1359:         uint256 amountWon;          
1360: 1360:         uint256 newPot;             
1361: 1361:         uint256 genAmount;          
1362: 1362:         uint256 potAmount;          
1363: 1363:     }
1364: 1364:     struct Player {
1365: 1365:         address addr;   
1366: 1366:         bytes32 name;   
1367: 1367:         uint256 win;    
1368: 1368:         uint256 gen;    
1369: 1369:         uint256 aff;    
1370: 1370:         uint256 lrnd;   
1371: 1371:         uint256 laff;   
1372: 1372:     }
1373: 1373:     struct PlayerRounds {
1374: 1374:         uint256 eth;    
1375: 1375:         uint256 keys;   
1376: 1376:         uint256 mask;   
1377: 1377:     }
1378: 1378:     struct Round {
1379: 1379:         uint256 plyr;   
1380: 1380:         uint256 end;    
1381: 1381:         bool ended;     
1382: 1382:         uint256 strt;   
1383: 1383:         uint256 keys;   
1384: 1384:         uint256 eth;    
1385: 1385:         uint256 pot;    
1386: 1386:         uint256 mask;   
1387: 1387:     }
1388: 1388: }
1389: 1389: 
1390: 1390: 
1391: 1391: 
1392: 1392: 
1393: 1393: 
1394: 1394: library FDDKeysCalc {
1395: 1395:     using SafeMath for *;
1396: 1396:     
1397: 1397: 
1398: 1398: 
1399: 1399: 
1400: 1400: 
1401: 1401: 
1402: 1402:     function keysRec(uint256 _curEth, uint256 _newEth)
1403: 1403:         internal
1404: 1404:         pure
1405: 1405:         returns (uint256)
1406: 1406:     {
1407: 1407:         return(keys((_curEth).add(_newEth)).sub(keys(_curEth)));
1408: 1408:     }
1409: 1409:     
1410: 1410:     
1411: 1411: 
1412: 1412: 
1413: 1413: 
1414: 1414: 
1415: 1415: 
1416: 1416:     function ethRec(uint256 _curKeys, uint256 _sellKeys)
1417: 1417:         internal
1418: 1418:         pure
1419: 1419:         returns (uint256)
1420: 1420:     {
1421: 1421:         return((eth(_curKeys)).sub(eth(_curKeys.sub(_sellKeys))));
1422: 1422:     }
1423: 1423: 
1424: 1424:     
1425: 1425: 
1426: 1426: 
1427: 1427: 
1428: 1428: 
1429: 1429:     function keys(uint256 _eth) 
1430: 1430:         internal
1431: 1431:         pure
1432: 1432:         returns(uint256)
1433: 1433:     {
1434: 1434:         return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
1435: 1435:     }
1436: 1436:     
1437: 1437:     
1438: 1438: 
1439: 1439: 
1440: 1440: 
1441: 1441: 
1442: 1442:     function eth(uint256 _keys) 
1443: 1443:         internal
1444: 1444:         pure
1445: 1445:         returns(uint256)  
1446: 1446:     {
1447: 1447:         return ((78125000).mul(_keys.sq()).add(((149999843750000).mul(_keys.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
1448: 1448:     }
1449: 1449: }
1450: 1450: 
1451: 1451: interface BankInterfaceForForwarder {
1452: 1452:     function deposit() external payable returns(bool);
1453: 1453: }
1454: 1454: 
1455: 1455: interface PlayerBookInterface {
1456: 1456:     function getPlayerID(address _addr) external returns (uint256);
1457: 1457:     function getPlayerName(uint256 _pID) external view returns (bytes32);
1458: 1458:     function getPlayerLAff(uint256 _pID) external view returns (uint256);
1459: 1459:     function getPlayerAddr(uint256 _pID) external view returns (address);
1460: 1460:     function getNameFee() external view returns (uint256);
1461: 1461:     function registerNameXIDFromDapp(address _addr, bytes32 _name, uint256 _affCode, bool _all) external payable returns(bool, uint256);
1462: 1462:     function registerNameXaddrFromDapp(address _addr, bytes32 _name, address _affCode, bool _all) external payable returns(bool, uint256);
1463: 1463:     function registerNameXnameFromDapp(address _addr, bytes32 _name, bytes32 _affCode, bool _all) external payable returns(bool, uint256);
1464: 1464: }
1465: 1465: 
1466: 1466: library NameFilter {
1467: 1467:     
1468: 1468: 
1469: 1469: 
1470: 1470: 
1471: 1471: 
1472: 1472: 
1473: 1473: 
1474: 1474: 
1475: 1475: 
1476: 1476: 
1477: 1477:     function nameFilter(string _input)
1478: 1478:         internal
1479: 1479:         pure
1480: 1480:         returns(bytes32)
1481: 1481:     {
1482: 1482:         bytes memory _temp = bytes(_input);
1483: 1483:         uint256 _length = _temp.length;
1484: 1484:         
1485: 1485:         
1486: 1486:         require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
1487: 1487:         
1488: 1488:         require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
1489: 1489:         
1490: 1490:         if (_temp[0] == 0x30)
1491: 1491:         {
1492: 1492:             require(_temp[1] != 0x78, "string cannot start with 0x");
1493: 1493:             require(_temp[1] != 0x58, "string cannot start with 0X");
1494: 1494:         }
1495: 1495:         
1496: 1496:         
1497: 1497:         bool _hasNonNumber;
1498: 1498:         
1499: 1499:         
1500: 1500:         for (uint256 i = 0; i < _length; i++)
1501: 1501:         {
1502: 1502:             
1503: 1503:             if (_temp[i] > 0x40 && _temp[i] < 0x5b)
1504: 1504:             {
1505: 1505:                 
1506: 1506:                 _temp[i] = byte(uint(_temp[i]) + 32);
1507: 1507:                 
1508: 1508:                 
1509: 1509:                 if (_hasNonNumber == false)
1510: 1510:                     _hasNonNumber = true;
1511: 1511:             } else {
1512: 1512:                 require
1513: 1513:                 (
1514: 1514:                     
1515: 1515:                     _temp[i] == 0x20 || 
1516: 1516:                     
1517: 1517:                     (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
1518: 1518:                     
1519: 1519:                     (_temp[i] > 0x2f && _temp[i] < 0x3a),
1520: 1520:                     "string contains invalid characters"
1521: 1521:                 );
1522: 1522:                 
1523: 1523:                 if (_temp[i] == 0x20)
1524: 1524:                     require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");
1525: 1525:                 
1526: 1526:                 
1527: 1527:                 if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
1528: 1528:                     _hasNonNumber = true;    
1529: 1529:             }
1530: 1530:         }
1531: 1531:         
1532: 1532:         require(_hasNonNumber == true, "string cannot be only numbers");
1533: 1533:         
1534: 1534:         bytes32 _ret;
1535: 1535:         assembly {
1536: 1536:             _ret := mload(add(_temp, 32))
1537: 1537:         }
1538: 1538:         return (_ret);
1539: 1539:     }
1540: 1540: }
1541: 1541: 
1542: 1542: 
1543: 1543: 
1544: 1544: 
1545: 1545: 
1546: 1546: 
1547: 1547: 
1548: 1548: 
1549: 1549: 
1550: 1550: 
1551: 1551: library SafeMath {
1552: 1552:     
1553: 1553:     
1554: 1554: 
1555: 1555: 
1556: 1556:     function mul(uint256 a, uint256 b) 
1557: 1557:         internal 
1558: 1558:         pure 
1559: 1559:         returns (uint256 c) 
1560: 1560:     {
1561: 1561:         if (a == 0) {
1562: 1562:             return 0;
1563: 1563:         }
1564: 1564:         c = a * b;
1565: 1565:         require(c / a == b, "SafeMath mul failed");
1566: 1566:         return c;
1567: 1567:     }
1568: 1568: 
1569: 1569:     
1570: 1570: 
1571: 1571: 
1572: 1572:     function sub(uint256 a, uint256 b)
1573: 1573:         internal
1574: 1574:         pure
1575: 1575:         returns (uint256) 
1576: 1576:     {
1577: 1577:         require(b <= a, "SafeMath sub failed");
1578: 1578:         return a - b;
1579: 1579:     }
1580: 1580: 
1581: 1581:     
1582: 1582: 
1583: 1583: 
1584: 1584:     function add(uint256 a, uint256 b)
1585: 1585:         internal
1586: 1586:         pure
1587: 1587:         returns (uint256 c) 
1588: 1588:     {
1589: 1589:         c = a + b;
1590: 1590:         require(c >= a, "SafeMath add failed");
1591: 1591:         return c;
1592: 1592:     }
1593: 1593: 
1594: 1594:     
1595: 1595: 
1596: 1596: 
1597: 1597:     function sqrt(uint256 x)
1598: 1598:         internal
1599: 1599:         pure
1600: 1600:         returns (uint256 y) 
1601: 1601:     {
1602: 1602:         uint256 z = ((add(x,1)) / 2);
1603: 1603:         y = x;
1604: 1604:         while (z < y) 
1605: 1605:         {
1606: 1606:             y = z;
1607: 1607:             z = ((add((x / z),z)) / 2);
1608: 1608:         }
1609: 1609:     }
1610: 1610: 
1611: 1611:     
1612: 1612: 
1613: 1613: 
1614: 1614:     function sq(uint256 x)
1615: 1615:         internal
1616: 1616:         pure
1617: 1617:         returns (uint256)
1618: 1618:     {
1619: 1619:         return (mul(x,x));
1620: 1620:     }
1621: 1621: }