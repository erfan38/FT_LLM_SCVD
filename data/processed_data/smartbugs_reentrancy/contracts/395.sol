1: pragma solidity ^0.4.24;
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: 
10: 
11: library ECRecovery {
12: 
13:   
14: 
15: 
16: 
17: 
18:   function recover(bytes32 hash, bytes sig)
19:     internal
20:     pure
21:     returns (address)
22:   {
23:     bytes32 r;
24:     bytes32 s;
25:     uint8 v;
26: 
27:     
28:     if (sig.length != 65) {
29:       return (address(0));
30:     }
31: 
32:     
33:     
34:     
35:     
36:     assembly {
37:       r := mload(add(sig, 32))
38:       s := mload(add(sig, 64))
39:       v := byte(0, mload(add(sig, 96)))
40:     }
41: 
42:     
43:     if (v < 27) {
44:       v += 27;
45:     }
46: 
47:     
48:     if (v != 27 && v != 28) {
49:       return (address(0));
50:     } else {
51:       
52:       return ecrecover(hash, v, r, s);
53:     }
54:   }
55: 
56:   
57: 
58: 
59: 
60: 
61:   function toEthSignedMessageHash(bytes32 hash)
62:     internal
63:     pure
64:     returns (bytes32)
65:   {
66:     
67:     
68:     return keccak256(
69:       abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
70:     );
71:   }
72: }
73: 
74: 
75: library OrderStatisticTree {
76: 
77:     struct Node {
78:         mapping (bool => uint) children; 
79:         uint parent; 
80:         bool side;   
81:         uint height; 
82:         uint count; 
83:         uint dupes; 
84:     }
85: 
86:     struct Tree {
87:         
88:         
89:         
90:         
91:         mapping(uint => Node) nodes;
92:     }
93:     
94: 
95: 
96: 
97: 
98: 
99: 
100: 
101:     function rank(Tree storage _tree,uint _value) internal view returns (uint smaller) {
102:         if (_value != 0) {
103:             smaller = _tree.nodes[0].dupes;
104: 
105:             uint cur = _tree.nodes[0].children[true];
106:             Node storage currentNode = _tree.nodes[cur];
107: 
108:             while (true) {
109:                 if (cur <= _value) {
110:                     if (cur<_value) {
111:                         smaller = smaller + 1+currentNode.dupes;
112:                     }
113:                     uint leftChild = currentNode.children[false];
114:                     if (leftChild!=0) {
115:                         smaller = smaller + _tree.nodes[leftChild].count;
116:                     }
117:                 }
118:                 if (cur == _value) {
119:                     break;
120:                 }
121:                 cur = currentNode.children[cur<_value];
122:                 if (cur == 0) {
123:                     break;
124:                 }
125:                 currentNode = _tree.nodes[cur];
126:             }
127:         }
128:     }
129: 
130:     function count(Tree storage _tree) internal view returns (uint) {
131:         Node storage root = _tree.nodes[0];
132:         Node memory child = _tree.nodes[root.children[true]];
133:         return root.dupes+child.count;
134:     }
135: 
136:     function updateCount(Tree storage _tree,uint _value) private {
137:         Node storage n = _tree.nodes[_value];
138:         n.count = 1+_tree.nodes[n.children[false]].count+_tree.nodes[n.children[true]].count+n.dupes;
139:     }
140: 
141:     function updateCounts(Tree storage _tree,uint _value) private {
142:         uint parent = _tree.nodes[_value].parent;
143:         while (parent!=0) {
144:             updateCount(_tree,parent);
145:             parent = _tree.nodes[parent].parent;
146:         }
147:     }
148: 
149:     function updateHeight(Tree storage _tree,uint _value) private {
150:         Node storage n = _tree.nodes[_value];
151:         uint heightLeft = _tree.nodes[n.children[false]].height;
152:         uint heightRight = _tree.nodes[n.children[true]].height;
153:         if (heightLeft > heightRight)
154:             n.height = heightLeft+1;
155:         else
156:             n.height = heightRight+1;
157:     }
158: 
159:     function balanceFactor(Tree storage _tree,uint _value) private view returns (int bf) {
160:         Node storage n = _tree.nodes[_value];
161:         return int(_tree.nodes[n.children[false]].height)-int(_tree.nodes[n.children[true]].height);
162:     }
163: 
164:     function rotate(Tree storage _tree,uint _value,bool dir) private {
165:         bool otherDir = !dir;
166:         Node storage n = _tree.nodes[_value];
167:         bool side = n.side;
168:         uint parent = n.parent;
169:         uint valueNew = n.children[otherDir];
170:         Node storage nNew = _tree.nodes[valueNew];
171:         uint orphan = nNew.children[dir];
172:         Node storage p = _tree.nodes[parent];
173:         Node storage o = _tree.nodes[orphan];
174:         p.children[side] = valueNew;
175:         nNew.side = side;
176:         nNew.parent = parent;
177:         nNew.children[dir] = _value;
178:         n.parent = valueNew;
179:         n.side = dir;
180:         n.children[otherDir] = orphan;
181:         o.parent = _value;
182:         o.side = otherDir;
183:         updateHeight(_tree,_value);
184:         updateHeight(_tree,valueNew);
185:         updateCount(_tree,_value);
186:         updateCount(_tree,valueNew);
187:     }
188: 
189:     function rebalanceInsert(Tree storage _tree,uint _nValue) private {
190:         updateHeight(_tree,_nValue);
191:         Node storage n = _tree.nodes[_nValue];
192:         uint pValue = n.parent;
193:         if (pValue!=0) {
194:             int pBf = balanceFactor(_tree,pValue);
195:             bool side = n.side;
196:             int sign;
197:             if (side)
198:                 sign = -1;
199:             else
200:                 sign = 1;
201:             if (pBf == sign*2) {
202:                 if (balanceFactor(_tree,_nValue) == (-1 * sign)) {
203:                     rotate(_tree,_nValue,side);
204:                 }
205:                 rotate(_tree,pValue,!side);
206:             } else if (pBf != 0) {
207:                 rebalanceInsert(_tree,pValue);
208:             }
209:         }
210:     }
211: 
212:     function rebalanceDelete(Tree storage _tree,uint _pValue,bool side) private {
213:         if (_pValue!=0) {
214:             updateHeight(_tree,_pValue);
215:             int pBf = balanceFactor(_tree,_pValue);
216:             int sign;
217:             if (side)
218:                 sign = 1;
219:             else
220:                 sign = -1;
221:             int bf = balanceFactor(_tree,_pValue);
222:             if (bf==(2*sign)) {
223:                 Node storage p = _tree.nodes[_pValue];
224:                 uint sValue = p.children[!side];
225:                 int sBf = balanceFactor(_tree,sValue);
226:                 if (sBf == (-1 * sign)) {
227:                     rotate(_tree,sValue,!side);
228:                 }
229:                 rotate(_tree,_pValue,side);
230:                 if (sBf!=0) {
231:                     p = _tree.nodes[_pValue];
232:                     rebalanceDelete(_tree,p.parent,p.side);
233:                 }
234:             } else if (pBf != sign) {
235:                 p = _tree.nodes[_pValue];
236:                 rebalanceDelete(_tree,p.parent,p.side);
237:             }
238:         }
239:     }
240: 
241:     function fixParents(Tree storage _tree,uint parent,bool side) private {
242:         if (parent!=0) {
243:             updateCount(_tree,parent);
244:             updateCounts(_tree,parent);
245:             rebalanceDelete(_tree,parent,side);
246:         }
247:     }
248: 
249:     function insertHelper(Tree storage _tree,uint _pValue,bool _side,uint _value) private {
250:         Node storage root = _tree.nodes[_pValue];
251:         uint cValue = root.children[_side];
252:         if (cValue==0) {
253:             root.children[_side] = _value;
254:             Node storage child = _tree.nodes[_value];
255:             child.parent = _pValue;
256:             child.side = _side;
257:             child.height = 1;
258:             child.count = 1;
259:             updateCounts(_tree,_value);
260:             rebalanceInsert(_tree,_value);
261:         } else if (cValue==_value) {
262:             _tree.nodes[cValue].dupes++;
263:             updateCount(_tree,_value);
264:             updateCounts(_tree,_value);
265:         } else {
266:             insertHelper(_tree,cValue,(_value >= cValue),_value);
267:         }
268:     }
269: 
270:     function insert(Tree storage _tree,uint _value) internal {
271:         if (_value==0) {
272:             _tree.nodes[_value].dupes++;
273:         } else {
274:             insertHelper(_tree,0,true,_value);
275:         }
276:     }
277: 
278:     function rightmostLeaf(Tree storage _tree,uint _value) private view returns (uint leaf) {
279:         uint child = _tree.nodes[_value].children[true];
280:         if (child!=0) {
281:             return rightmostLeaf(_tree,child);
282:         } else {
283:             return _value;
284:         }
285:     }
286: 
287:     function zeroOut(Tree storage _tree,uint _value) private {
288:         Node storage n = _tree.nodes[_value];
289:         n.parent = 0;
290:         n.side = false;
291:         n.children[false] = 0;
292:         n.children[true] = 0;
293:         n.count = 0;
294:         n.height = 0;
295:         n.dupes = 0;
296:     }
297: 
298:     function removeBranch(Tree storage _tree,uint _value,uint _left) private {
299:         uint ipn = rightmostLeaf(_tree,_left);
300:         Node storage i = _tree.nodes[ipn];
301:         uint dupes = i.dupes;
302:         removeHelper(_tree,ipn);
303:         Node storage n = _tree.nodes[_value];
304:         uint parent = n.parent;
305:         Node storage p = _tree.nodes[parent];
306:         uint height = n.height;
307:         bool side = n.side;
308:         uint ncount = n.count;
309:         uint right = n.children[true];
310:         uint left = n.children[false];
311:         p.children[side] = ipn;
312:         i.parent = parent;
313:         i.side = side;
314:         i.count = ncount+dupes-n.dupes;
315:         i.height = height;
316:         i.dupes = dupes;
317:         if (left!=0) {
318:             i.children[false] = left;
319:             _tree.nodes[left].parent = ipn;
320:         }
321:         if (right!=0) {
322:             i.children[true] = right;
323:             _tree.nodes[right].parent = ipn;
324:         }
325:         zeroOut(_tree,_value);
326:         updateCounts(_tree,ipn);
327:     }
328: 
329:     function removeHelper(Tree storage _tree,uint _value) private {
330:         Node storage n = _tree.nodes[_value];
331:         uint parent = n.parent;
332:         bool side = n.side;
333:         Node storage p = _tree.nodes[parent];
334:         uint left = n.children[false];
335:         uint right = n.children[true];
336:         if ((left == 0) && (right == 0)) {
337:             p.children[side] = 0;
338:             zeroOut(_tree,_value);
339:             fixParents(_tree,parent,side);
340:         } else if ((left != 0) && (right != 0)) {
341:             removeBranch(_tree,_value,left);
342:         } else {
343:             uint child = left+right;
344:             Node storage c = _tree.nodes[child];
345:             p.children[side] = child;
346:             c.parent = parent;
347:             c.side = side;
348:             zeroOut(_tree,_value);
349:             fixParents(_tree,parent,side);
350:         }
351:     }
352: 
353:     function remove(Tree storage _tree,uint _value) internal {
354:         Node storage n = _tree.nodes[_value];
355:         if (_value==0) {
356:             if (n.dupes==0) {
357:                 return;
358:             }
359:         } else {
360:             if (n.count==0) {
361:                 return;
362:             }
363:         }
364:         if (n.dupes>0) {
365:             n.dupes--;
366:             if (_value!=0) {
367:                 n.count--;
368:             }
369:             fixParents(_tree,n.parent,n.side);
370:         } else {
371:             removeHelper(_tree,_value);
372:         }
373:     }
374: 
375: }
376: 
377: 
378: 
379: 
380: 
381: 
382: 
383: 
384: 
385: 
386: 
387: 
388: 
389: 
390: 
391: 
392: 
393: 
394: library RealMath {
395: 
396:     
397: 
398: 
399:     int256 constant REAL_BITS = 256;
400: 
401:     
402: 
403: 
404:     int256 constant REAL_FBITS = 40;
405: 
406:     
407: 
408: 
409:     int256 constant REAL_IBITS = REAL_BITS - REAL_FBITS;
410: 
411:     
412: 
413: 
414:     int256 constant REAL_ONE = int256(1) << REAL_FBITS;
415: 
416:     
417: 
418: 
419:     int256 constant REAL_HALF = REAL_ONE >> 1;
420: 
421:     
422: 
423: 
424:     int256 constant REAL_TWO = REAL_ONE << 1;
425: 
426:     
427: 
428: 
429:     int256 constant REAL_LN_TWO = 762123384786;
430: 
431:     
432: 
433: 
434:     int256 constant REAL_PI = 3454217652358;
435: 
436:     
437: 
438: 
439: 
440:     int256 constant REAL_HALF_PI = 1727108826179;
441: 
442:     
443: 
444: 
445:     int256 constant REAL_TWO_PI = 6908435304715;
446: 
447:     
448: 
449: 
450:     int256 constant SIGN_MASK = int256(1) << 255;
451: 
452: 
453:     
454: 
455: 
456:     function toReal(int216 ipart) internal pure returns (int256) {
457:         return int256(ipart) * REAL_ONE;
458:     }
459: 
460:     
461: 
462: 
463:     function fromReal(int256 realValue) internal pure returns (int216) {
464:         return int216(realValue / REAL_ONE);
465:     }
466: 
467:     
468: 
469: 
470:     function round(int256 realValue) internal pure returns (int256) {
471:         
472:         int216 ipart = fromReal(realValue);
473:         if ((fractionalBits(realValue) & (uint40(1) << (REAL_FBITS - 1))) > 0) {
474:             
475:             if (realValue < int256(0)) {
476:                 
477:                 ipart -= 1;
478:             } else {
479:                 ipart += 1;
480:             }
481:         }
482:         return toReal(ipart);
483:     }
484: 
485:     
486: 
487: 
488:     function abs(int256 realValue) internal pure returns (int256) {
489:         if (realValue > 0) {
490:             return realValue;
491:         } else {
492:             return -realValue;
493:         }
494:     }
495: 
496:     
497: 
498: 
499:     function fractionalBits(int256 realValue) internal pure returns (uint40) {
500:         return uint40(abs(realValue) % REAL_ONE);
501:     }
502: 
503:     
504: 
505: 
506:     function fpart(int256 realValue) internal pure returns (int256) {
507:         
508:         return abs(realValue) % REAL_ONE;
509:     }
510: 
511:     
512: 
513: 
514:     function fpartSigned(int256 realValue) internal pure returns (int256) {
515:         
516:         int256 fractional = fpart(realValue);
517:         if (realValue < 0) {
518:             
519:             return -fractional;
520:         } else {
521:             return fractional;
522:         }
523:     }
524: 
525:     
526: 
527: 
528:     function ipart(int256 realValue) internal pure returns (int256) {
529:         
530:         return realValue - fpartSigned(realValue);
531:     }
532: 
533:     
534: 
535: 
536:     function mul(int256 realA, int256 realB) internal pure returns (int256) {
537:         
538:         
539:         return int256((int256(realA) * int256(realB)) >> REAL_FBITS);
540:     }
541: 
542:     
543: 
544: 
545:     function div(int256 realNumerator, int256 realDenominator) internal pure returns (int256) {
546:         
547:         
548:         return int256((int256(realNumerator) * REAL_ONE) / int256(realDenominator));
549:     }
550: 
551:     
552: 
553: 
554:     function fraction(int216 numerator, int216 denominator) internal pure returns (int256) {
555:         return div(toReal(numerator), toReal(denominator));
556:     }
557: 
558:     
559:     
560:     
561: 
562:     
563: 
564: 
565: 
566:     function ipow(int256 realBase, int216 exponent) internal pure returns (int256) {
567:         if (exponent < 0) {
568:             
569:             revert();
570:         }
571: 
572:         int256 tempRealBase = realBase;
573:         int256 tempExponent = exponent;
574: 
575:         
576:         int256 realResult = REAL_ONE;
577:         while (tempExponent != 0) {
578:             
579:             if ((tempExponent & 0x1) == 0x1) {
580:                 
581:                 realResult = mul(realResult, tempRealBase);
582:             }
583:             
584:             tempExponent = tempExponent >> 1;
585:             
586:             tempRealBase = mul(tempRealBase, tempRealBase);
587:         }
588: 
589:         
590:         return realResult;
591:     }
592: 
593:     
594: 
595: 
596: 
597:     function hibit(uint256 _val) internal pure returns (uint256) {
598:         
599:         uint256 val = _val;
600:         val |= (val >> 1);
601:         val |= (val >> 2);
602:         val |= (val >> 4);
603:         val |= (val >> 8);
604:         val |= (val >> 16);
605:         val |= (val >> 32);
606:         val |= (val >> 64);
607:         val |= (val >> 128);
608:         return val ^ (val >> 1);
609:     }
610: 
611:     
612: 
613: 
614:     function findbit(uint256 val) internal pure returns (uint8 index) {
615:         index = 0;
616:         
617:         if (val & 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA != 0) {
618:             
619:             index |= 1;
620:         }
621:         if (val & 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC != 0) {
622:             
623:             index |= 2;
624:         }
625:         if (val & 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0 != 0) {
626:             
627:             index |= 4;
628:         }
629:         if (val & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00 != 0) {
630:             
631:             index |= 8;
632:         }
633:         if (val & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000 != 0) {
634:             
635:             index |= 16;
636:         }
637:         if (val & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000 != 0) {
638:             
639:             index |= 32;
640:         }
641:         if (val & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000 != 0) {
642:             
643:             index |= 64;
644:         }
645:         if (val & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 != 0) {
646:             
647:             index |= 128;
648:         }
649:     }
650: 
651:     
652: 
653: 
654: 
655: 
656: 
657: 
658: 
659:     function rescale(int256 realArg) internal pure returns (int256 realScaled, int216 shift) {
660:         if (realArg <= 0) {
661:             
662:             revert();
663:         }
664: 
665:         
666:         int216 highBit = findbit(hibit(uint256(realArg)));
667: 
668:         
669:         shift = highBit - int216(REAL_FBITS);
670: 
671:         if (shift < 0) {
672:             
673:             realScaled = realArg << -shift;
674:         } else if (shift >= 0) {
675:             
676:             realScaled = realArg >> shift;
677:         }
678:     }
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
690:     function lnLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
691:         if (realArg <= 0) {
692:             
693:             revert();
694:         }
695: 
696:         if (realArg == REAL_ONE) {
697:             
698:             
699:             return 0;
700:         }
701: 
702:         
703:         int256 realRescaled;
704:         int216 shift;
705:         (realRescaled, shift) = rescale(realArg);
706: 
707:         
708:         int256 realSeriesArg = div(realRescaled - REAL_ONE, realRescaled + REAL_ONE);
709: 
710:         
711:         int256 realSeriesResult = 0;
712: 
713:         for (int216 n = 0; n < maxIterations; n++) {
714:             
715:             int256 realTerm = div(ipow(realSeriesArg, 2 * n + 1), toReal(2 * n + 1));
716:             
717:             realSeriesResult += realTerm;
718:             if (realTerm == 0) {
719:                 
720:                 break;
721:             }
722:             
723:         }
724: 
725:         
726:         realSeriesResult = mul(realSeriesResult, REAL_TWO);
727: 
728:         
729:         return mul(toReal(shift), REAL_LN_TWO) + realSeriesResult;
730: 
731:     }
732: 
733:     
734: 
735: 
736: 
737: 
738:     function ln(int256 realArg) internal pure returns (int256) {
739:         return lnLimited(realArg, 100);
740:     }
741: 
742:     
743: 
744: 
745: 
746: 
747: 
748: 
749: 
750: 
751:     function expLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
752:         
753:         int256 realResult = 0;
754: 
755:         
756:         int256 realTerm = REAL_ONE;
757: 
758:         for (int216 n = 0; n < maxIterations; n++) {
759:             
760:             realResult += realTerm;
761: 
762:             
763:             realTerm = mul(realTerm, div(realArg, toReal(n + 1)));
764: 
765:             if (realTerm == 0) {
766:                 
767:                 break;
768:             }
769:             
770:         }
771: 
772:         
773:         return realResult;
774: 
775:     }
776: 
777:     
778: 
779: 
780: 
781: 
782:     function exp(int256 realArg) internal pure returns (int256) {
783:         return expLimited(realArg, 100);
784:     }
785: 
786:     
787: 
788: 
789:     function pow(int256 realBase, int256 realExponent) internal pure returns (int256) {
790:         if (realExponent == 0) {
791:             
792:             return REAL_ONE;
793:         }
794: 
795:         if (realBase == 0) {
796:             if (realExponent < 0) {
797:                 
798:                 revert();
799:             }
800:             
801:             return 0;
802:         }
803: 
804:         if (fpart(realExponent) == 0) {
805:             
806: 
807:             if (realExponent > 0) {
808:                 
809:                 return ipow(realBase, fromReal(realExponent));
810:             } else {
811:                 
812:                 return div(REAL_ONE, ipow(realBase, fromReal(-realExponent)));
813:             }
814:         }
815: 
816:         if (realBase < 0) {
817:             
818:             
819:             
820:             revert();
821:         }
822: 
823:         
824:         return exp(mul(realExponent, ln(realBase)));
825:     }
826: 
827:     
828: 
829: 
830:     function sqrt(int256 realArg) internal pure returns (int256) {
831:         return pow(realArg, REAL_HALF);
832:     }
833: 
834:     
835: 
836: 
837:     function sinLimited(int256 _realArg, int216 maxIterations) internal pure returns (int256) {
838:         
839:         
840:         
841:         int256 realArg = _realArg;
842:         realArg = realArg % REAL_TWO_PI;
843: 
844:         int256 accumulator = REAL_ONE;
845: 
846:         
847:         for (int216 iteration = maxIterations - 1; iteration >= 0; iteration--) {
848:             accumulator = REAL_ONE - mul(div(mul(realArg, realArg), toReal((2 * iteration + 2) * (2 * iteration + 3))), accumulator);
849:             
850:         }
851: 
852:         return mul(realArg, accumulator);
853:     }
854: 
855:     
856: 
857: 
858: 
859:     function sin(int256 realArg) internal pure returns (int256) {
860:         return sinLimited(realArg, 15);
861:     }
862: 
863:     
864: 
865: 
866:     function cos(int256 realArg) internal pure returns (int256) {
867:         return sin(realArg + REAL_HALF_PI);
868:     }
869: 
870:     
871: 
872: 
873: 
874:     function tan(int256 realArg) internal pure returns (int256) {
875:         return div(sin(realArg), cos(realArg));
876:     }
877: }
878: 
879: 
880: 
881: 
882: 
883: contract ERC827Token is ERC827, StandardToken {
884: 
885:   
886: 
887: 
888: 
889: 
890: 
891: 
892: 
893: 
894: 
895: 
896: 
897: 
898: 
899:     function approveAndCall(
900:         address _spender,
901:         uint256 _value,
902:         bytes _data
903:     )
904:     public
905:     payable
906:     returns (bool)
907:     {
908:         require(_spender != address(this));
909: 
910:         super.approve(_spender, _value);
911: 
912:         
913:         require(_spender.call.value(msg.value)(_data));
914: 
915:         return true;
916:     }
917: 
918:   
919: 
920: 
921: 
922: 
923: 
924: 
925: 
926:     function transferAndCall(
927:         address _to,
928:         uint256 _value,
929:         bytes _data
930:     )
931:     public
932:     payable
933:     returns (bool)
934:     {
935:         require(_to != address(this));
936: 
937:         super.transfer(_to, _value);
938: 
939:         
940:         require(_to.call.value(msg.value)(_data));
941:         return true;
942:     }
943: 
944:   
945: 
946: 
947: 
948: 
949: 
950: 
951: 
952: 
953:     function transferFromAndCall(
954:         address _from,
955:         address _to,
956:         uint256 _value,
957:         bytes _data
958:     )
959:     public payable returns (bool)
960:     {
961:         require(_to != address(this));
962: 
963:         super.transferFrom(_from, _to, _value);
964: 
965:         
966:         require(_to.call.value(msg.value)(_data));
967:         return true;
968:     }
969: 
970:   
971: 
972: 
973: 
974: 
975: 
976: 
977: 
978: 
979: 
980: 
981:     function increaseApprovalAndCall(
982:         address _spender,
983:         uint _addedValue,
984:         bytes _data
985:     )
986:     public
987:     payable
988:     returns (bool)
989:     {
990:         require(_spender != address(this));
991: 
992:         super.increaseApproval(_spender, _addedValue);
993: 
994:         
995:         require(_spender.call.value(msg.value)(_data));
996: 
997:         return true;
998:     }
999: 
1000:   
1001: 
1002: 
1003: 
1004: 
1005: 
1006: 
1007: 
1008: 
1009: 
1010: 
1011:     function decreaseApprovalAndCall(
1012:         address _spender,
1013:         uint _subtractedValue,
1014:         bytes _data
1015:     )
1016:     public
1017:     payable
1018:     returns (bool)
1019:     {
1020:         require(_spender != address(this));
1021: 
1022:         super.decreaseApproval(_spender, _subtractedValue);
1023: 
1024:         
1025:         require(_spender.call.value(msg.value)(_data));
1026: 
1027:         return true;
1028:     }
1029: 
1030: }
1031: 
1032: 
1033: 
1034: 
1035: 
1036: 