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
11: 11: library ECRecovery {
12: 12: 
13: 13:   
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18:   function recover(bytes32 hash, bytes sig)
19: 19:     internal
20: 20:     pure
21: 21:     returns (address)
22: 22:   {
23: 23:     bytes32 r;
24: 24:     bytes32 s;
25: 25:     uint8 v;
26: 26: 
27: 27:     
28: 28:     if (sig.length != 65) {
29: 29:       return (address(0));
30: 30:     }
31: 31: 
32: 32:     
33: 33:     
34: 34:     
35: 35:     
36: 36:     assembly {
37: 37:       r := mload(add(sig, 32))
38: 38:       s := mload(add(sig, 64))
39: 39:       v := byte(0, mload(add(sig, 96)))
40: 40:     }
41: 41: 
42: 42:     
43: 43:     if (v < 27) {
44: 44:       v += 27;
45: 45:     }
46: 46: 
47: 47:     
48: 48:     if (v != 27 && v != 28) {
49: 49:       return (address(0));
50: 50:     } else {
51: 51:       
52: 52:       return ecrecover(hash, v, r, s);
53: 53:     }
54: 54:   }
55: 55: 
56: 56:   
57: 57: 
58: 58: 
59: 59: 
60: 60: 
61: 61:   function toEthSignedMessageHash(bytes32 hash)
62: 62:     internal
63: 63:     pure
64: 64:     returns (bytes32)
65: 65:   {
66: 66:     
67: 67:     
68: 68:     return keccak256(
69: 69:       abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
70: 70:     );
71: 71:   }
72: 72: }
73: 73: 
74: 74: 
75: 75: library OrderStatisticTree {
76: 76: 
77: 77:     struct Node {
78: 78:         mapping (bool => uint) children; 
79: 79:         uint parent; 
80: 80:         bool side;   
81: 81:         uint height; 
82: 82:         uint count; 
83: 83:         uint dupes; 
84: 84:     }
85: 85: 
86: 86:     struct Tree {
87: 87:         
88: 88:         
89: 89:         
90: 90:         
91: 91:         mapping(uint => Node) nodes;
92: 92:     }
93: 93:     
94: 94: 
95: 95: 
96: 96: 
97: 97: 
98: 98: 
99: 99: 
100: 100: 
101: 101:     function rank(Tree storage _tree,uint _value) internal view returns (uint smaller) {
102: 102:         if (_value != 0) {
103: 103:             smaller = _tree.nodes[0].dupes;
104: 104: 
105: 105:             uint cur = _tree.nodes[0].children[true];
106: 106:             Node storage currentNode = _tree.nodes[cur];
107: 107: 
108: 108:             while (true) {
109: 109:                 if (cur <= _value) {
110: 110:                     if (cur<_value) {
111: 111:                         smaller = smaller + 1+currentNode.dupes;
112: 112:                     }
113: 113:                     uint leftChild = currentNode.children[false];
114: 114:                     if (leftChild!=0) {
115: 115:                         smaller = smaller + _tree.nodes[leftChild].count;
116: 116:                     }
117: 117:                 }
118: 118:                 if (cur == _value) {
119: 119:                     break;
120: 120:                 }
121: 121:                 cur = currentNode.children[cur<_value];
122: 122:                 if (cur == 0) {
123: 123:                     break;
124: 124:                 }
125: 125:                 currentNode = _tree.nodes[cur];
126: 126:             }
127: 127:         }
128: 128:     }
129: 129: 
130: 130:     function count(Tree storage _tree) internal view returns (uint) {
131: 131:         Node storage root = _tree.nodes[0];
132: 132:         Node memory child = _tree.nodes[root.children[true]];
133: 133:         return root.dupes+child.count;
134: 134:     }
135: 135: 
136: 136:     function updateCount(Tree storage _tree,uint _value) private {
137: 137:         Node storage n = _tree.nodes[_value];
138: 138:         n.count = 1+_tree.nodes[n.children[false]].count+_tree.nodes[n.children[true]].count+n.dupes;
139: 139:     }
140: 140: 
141: 141:     function updateCounts(Tree storage _tree,uint _value) private {
142: 142:         uint parent = _tree.nodes[_value].parent;
143: 143:         while (parent!=0) {
144: 144:             updateCount(_tree,parent);
145: 145:             parent = _tree.nodes[parent].parent;
146: 146:         }
147: 147:     }
148: 148: 
149: 149:     function updateHeight(Tree storage _tree,uint _value) private {
150: 150:         Node storage n = _tree.nodes[_value];
151: 151:         uint heightLeft = _tree.nodes[n.children[false]].height;
152: 152:         uint heightRight = _tree.nodes[n.children[true]].height;
153: 153:         if (heightLeft > heightRight)
154: 154:             n.height = heightLeft+1;
155: 155:         else
156: 156:             n.height = heightRight+1;
157: 157:     }
158: 158: 
159: 159:     function balanceFactor(Tree storage _tree,uint _value) private view returns (int bf) {
160: 160:         Node storage n = _tree.nodes[_value];
161: 161:         return int(_tree.nodes[n.children[false]].height)-int(_tree.nodes[n.children[true]].height);
162: 162:     }
163: 163: 
164: 164:     function rotate(Tree storage _tree,uint _value,bool dir) private {
165: 165:         bool otherDir = !dir;
166: 166:         Node storage n = _tree.nodes[_value];
167: 167:         bool side = n.side;
168: 168:         uint parent = n.parent;
169: 169:         uint valueNew = n.children[otherDir];
170: 170:         Node storage nNew = _tree.nodes[valueNew];
171: 171:         uint orphan = nNew.children[dir];
172: 172:         Node storage p = _tree.nodes[parent];
173: 173:         Node storage o = _tree.nodes[orphan];
174: 174:         p.children[side] = valueNew;
175: 175:         nNew.side = side;
176: 176:         nNew.parent = parent;
177: 177:         nNew.children[dir] = _value;
178: 178:         n.parent = valueNew;
179: 179:         n.side = dir;
180: 180:         n.children[otherDir] = orphan;
181: 181:         o.parent = _value;
182: 182:         o.side = otherDir;
183: 183:         updateHeight(_tree,_value);
184: 184:         updateHeight(_tree,valueNew);
185: 185:         updateCount(_tree,_value);
186: 186:         updateCount(_tree,valueNew);
187: 187:     }
188: 188: 
189: 189:     function rebalanceInsert(Tree storage _tree,uint _nValue) private {
190: 190:         updateHeight(_tree,_nValue);
191: 191:         Node storage n = _tree.nodes[_nValue];
192: 192:         uint pValue = n.parent;
193: 193:         if (pValue!=0) {
194: 194:             int pBf = balanceFactor(_tree,pValue);
195: 195:             bool side = n.side;
196: 196:             int sign;
197: 197:             if (side)
198: 198:                 sign = -1;
199: 199:             else
200: 200:                 sign = 1;
201: 201:             if (pBf == sign*2) {
202: 202:                 if (balanceFactor(_tree,_nValue) == (-1 * sign)) {
203: 203:                     rotate(_tree,_nValue,side);
204: 204:                 }
205: 205:                 rotate(_tree,pValue,!side);
206: 206:             } else if (pBf != 0) {
207: 207:                 rebalanceInsert(_tree,pValue);
208: 208:             }
209: 209:         }
210: 210:     }
211: 211: 
212: 212:     function rebalanceDelete(Tree storage _tree,uint _pValue,bool side) private {
213: 213:         if (_pValue!=0) {
214: 214:             updateHeight(_tree,_pValue);
215: 215:             int pBf = balanceFactor(_tree,_pValue);
216: 216:             int sign;
217: 217:             if (side)
218: 218:                 sign = 1;
219: 219:             else
220: 220:                 sign = -1;
221: 221:             int bf = balanceFactor(_tree,_pValue);
222: 222:             if (bf==(2*sign)) {
223: 223:                 Node storage p = _tree.nodes[_pValue];
224: 224:                 uint sValue = p.children[!side];
225: 225:                 int sBf = balanceFactor(_tree,sValue);
226: 226:                 if (sBf == (-1 * sign)) {
227: 227:                     rotate(_tree,sValue,!side);
228: 228:                 }
229: 229:                 rotate(_tree,_pValue,side);
230: 230:                 if (sBf!=0) {
231: 231:                     p = _tree.nodes[_pValue];
232: 232:                     rebalanceDelete(_tree,p.parent,p.side);
233: 233:                 }
234: 234:             } else if (pBf != sign) {
235: 235:                 p = _tree.nodes[_pValue];
236: 236:                 rebalanceDelete(_tree,p.parent,p.side);
237: 237:             }
238: 238:         }
239: 239:     }
240: 240: 
241: 241:     function fixParents(Tree storage _tree,uint parent,bool side) private {
242: 242:         if (parent!=0) {
243: 243:             updateCount(_tree,parent);
244: 244:             updateCounts(_tree,parent);
245: 245:             rebalanceDelete(_tree,parent,side);
246: 246:         }
247: 247:     }
248: 248: 
249: 249:     function insertHelper(Tree storage _tree,uint _pValue,bool _side,uint _value) private {
250: 250:         Node storage root = _tree.nodes[_pValue];
251: 251:         uint cValue = root.children[_side];
252: 252:         if (cValue==0) {
253: 253:             root.children[_side] = _value;
254: 254:             Node storage child = _tree.nodes[_value];
255: 255:             child.parent = _pValue;
256: 256:             child.side = _side;
257: 257:             child.height = 1;
258: 258:             child.count = 1;
259: 259:             updateCounts(_tree,_value);
260: 260:             rebalanceInsert(_tree,_value);
261: 261:         } else if (cValue==_value) {
262: 262:             _tree.nodes[cValue].dupes++;
263: 263:             updateCount(_tree,_value);
264: 264:             updateCounts(_tree,_value);
265: 265:         } else {
266: 266:             insertHelper(_tree,cValue,(_value >= cValue),_value);
267: 267:         }
268: 268:     }
269: 269: 
270: 270:     function insert(Tree storage _tree,uint _value) internal {
271: 271:         if (_value==0) {
272: 272:             _tree.nodes[_value].dupes++;
273: 273:         } else {
274: 274:             insertHelper(_tree,0,true,_value);
275: 275:         }
276: 276:     }
277: 277: 
278: 278:     function rightmostLeaf(Tree storage _tree,uint _value) private view returns (uint leaf) {
279: 279:         uint child = _tree.nodes[_value].children[true];
280: 280:         if (child!=0) {
281: 281:             return rightmostLeaf(_tree,child);
282: 282:         } else {
283: 283:             return _value;
284: 284:         }
285: 285:     }
286: 286: 
287: 287:     function zeroOut(Tree storage _tree,uint _value) private {
288: 288:         Node storage n = _tree.nodes[_value];
289: 289:         n.parent = 0;
290: 290:         n.side = false;
291: 291:         n.children[false] = 0;
292: 292:         n.children[true] = 0;
293: 293:         n.count = 0;
294: 294:         n.height = 0;
295: 295:         n.dupes = 0;
296: 296:     }
297: 297: 
298: 298:     function removeBranch(Tree storage _tree,uint _value,uint _left) private {
299: 299:         uint ipn = rightmostLeaf(_tree,_left);
300: 300:         Node storage i = _tree.nodes[ipn];
301: 301:         uint dupes = i.dupes;
302: 302:         removeHelper(_tree,ipn);
303: 303:         Node storage n = _tree.nodes[_value];
304: 304:         uint parent = n.parent;
305: 305:         Node storage p = _tree.nodes[parent];
306: 306:         uint height = n.height;
307: 307:         bool side = n.side;
308: 308:         uint ncount = n.count;
309: 309:         uint right = n.children[true];
310: 310:         uint left = n.children[false];
311: 311:         p.children[side] = ipn;
312: 312:         i.parent = parent;
313: 313:         i.side = side;
314: 314:         i.count = ncount+dupes-n.dupes;
315: 315:         i.height = height;
316: 316:         i.dupes = dupes;
317: 317:         if (left!=0) {
318: 318:             i.children[false] = left;
319: 319:             _tree.nodes[left].parent = ipn;
320: 320:         }
321: 321:         if (right!=0) {
322: 322:             i.children[true] = right;
323: 323:             _tree.nodes[right].parent = ipn;
324: 324:         }
325: 325:         zeroOut(_tree,_value);
326: 326:         updateCounts(_tree,ipn);
327: 327:     }
328: 328: 
329: 329:     function removeHelper(Tree storage _tree,uint _value) private {
330: 330:         Node storage n = _tree.nodes[_value];
331: 331:         uint parent = n.parent;
332: 332:         bool side = n.side;
333: 333:         Node storage p = _tree.nodes[parent];
334: 334:         uint left = n.children[false];
335: 335:         uint right = n.children[true];
336: 336:         if ((left == 0) && (right == 0)) {
337: 337:             p.children[side] = 0;
338: 338:             zeroOut(_tree,_value);
339: 339:             fixParents(_tree,parent,side);
340: 340:         } else if ((left != 0) && (right != 0)) {
341: 341:             removeBranch(_tree,_value,left);
342: 342:         } else {
343: 343:             uint child = left+right;
344: 344:             Node storage c = _tree.nodes[child];
345: 345:             p.children[side] = child;
346: 346:             c.parent = parent;
347: 347:             c.side = side;
348: 348:             zeroOut(_tree,_value);
349: 349:             fixParents(_tree,parent,side);
350: 350:         }
351: 351:     }
352: 352: 
353: 353:     function remove(Tree storage _tree,uint _value) internal {
354: 354:         Node storage n = _tree.nodes[_value];
355: 355:         if (_value==0) {
356: 356:             if (n.dupes==0) {
357: 357:                 return;
358: 358:             }
359: 359:         } else {
360: 360:             if (n.count==0) {
361: 361:                 return;
362: 362:             }
363: 363:         }
364: 364:         if (n.dupes>0) {
365: 365:             n.dupes--;
366: 366:             if (_value!=0) {
367: 367:                 n.count--;
368: 368:             }
369: 369:             fixParents(_tree,n.parent,n.side);
370: 370:         } else {
371: 371:             removeHelper(_tree,_value);
372: 372:         }
373: 373:     }
374: 374: 
375: 375: }
376: 376: 
377: 377: 
378: 378: 
379: 379: 
380: 380: 
381: 381: 
382: 382: 
383: 383: 
384: 384: 
385: 385: 
386: 386: 
387: 387: 
388: 388: 
389: 389: 
390: 390: 
391: 391: 
392: 392: 
393: 393: 
394: 394: library RealMath {
395: 395: 
396: 396:     
397: 397: 
398: 398: 
399: 399:     int256 constant REAL_BITS = 256;
400: 400: 
401: 401:     
402: 402: 
403: 403: 
404: 404:     int256 constant REAL_FBITS = 40;
405: 405: 
406: 406:     
407: 407: 
408: 408: 
409: 409:     int256 constant REAL_IBITS = REAL_BITS - REAL_FBITS;
410: 410: 
411: 411:     
412: 412: 
413: 413: 
414: 414:     int256 constant REAL_ONE = int256(1) << REAL_FBITS;
415: 415: 
416: 416:     
417: 417: 
418: 418: 
419: 419:     int256 constant REAL_HALF = REAL_ONE >> 1;
420: 420: 
421: 421:     
422: 422: 
423: 423: 
424: 424:     int256 constant REAL_TWO = REAL_ONE << 1;
425: 425: 
426: 426:     
427: 427: 
428: 428: 
429: 429:     int256 constant REAL_LN_TWO = 762123384786;
430: 430: 
431: 431:     
432: 432: 
433: 433: 
434: 434:     int256 constant REAL_PI = 3454217652358;
435: 435: 
436: 436:     
437: 437: 
438: 438: 
439: 439: 
440: 440:     int256 constant REAL_HALF_PI = 1727108826179;
441: 441: 
442: 442:     
443: 443: 
444: 444: 
445: 445:     int256 constant REAL_TWO_PI = 6908435304715;
446: 446: 
447: 447:     
448: 448: 
449: 449: 
450: 450:     int256 constant SIGN_MASK = int256(1) << 255;
451: 451: 
452: 452: 
453: 453:     
454: 454: 
455: 455: 
456: 456:     function toReal(int216 ipart) internal pure returns (int256) {
457: 457:         return int256(ipart) * REAL_ONE;
458: 458:     }
459: 459: 
460: 460:     
461: 461: 
462: 462: 
463: 463:     function fromReal(int256 realValue) internal pure returns (int216) {
464: 464:         return int216(realValue / REAL_ONE);
465: 465:     }
466: 466: 
467: 467:     
468: 468: 
469: 469: 
470: 470:     function round(int256 realValue) internal pure returns (int256) {
471: 471:         
472: 472:         int216 ipart = fromReal(realValue);
473: 473:         if ((fractionalBits(realValue) & (uint40(1) << (REAL_FBITS - 1))) > 0) {
474: 474:             
475: 475:             if (realValue < int256(0)) {
476: 476:                 
477: 477:                 ipart -= 1;
478: 478:             } else {
479: 479:                 ipart += 1;
480: 480:             }
481: 481:         }
482: 482:         return toReal(ipart);
483: 483:     }
484: 484: 
485: 485:     
486: 486: 
487: 487: 
488: 488:     function abs(int256 realValue) internal pure returns (int256) {
489: 489:         if (realValue > 0) {
490: 490:             return realValue;
491: 491:         } else {
492: 492:             return -realValue;
493: 493:         }
494: 494:     }
495: 495: 
496: 496:     
497: 497: 
498: 498: 
499: 499:     function fractionalBits(int256 realValue) internal pure returns (uint40) {
500: 500:         return uint40(abs(realValue) % REAL_ONE);
501: 501:     }
502: 502: 
503: 503:     
504: 504: 
505: 505: 
506: 506:     function fpart(int256 realValue) internal pure returns (int256) {
507: 507:         
508: 508:         return abs(realValue) % REAL_ONE;
509: 509:     }
510: 510: 
511: 511:     
512: 512: 
513: 513: 
514: 514:     function fpartSigned(int256 realValue) internal pure returns (int256) {
515: 515:         
516: 516:         int256 fractional = fpart(realValue);
517: 517:         if (realValue < 0) {
518: 518:             
519: 519:             return -fractional;
520: 520:         } else {
521: 521:             return fractional;
522: 522:         }
523: 523:     }
524: 524: 
525: 525:     
526: 526: 
527: 527: 
528: 528:     function ipart(int256 realValue) internal pure returns (int256) {
529: 529:         
530: 530:         return realValue - fpartSigned(realValue);
531: 531:     }
532: 532: 
533: 533:     
534: 534: 
535: 535: 
536: 536:     function mul(int256 realA, int256 realB) internal pure returns (int256) {
537: 537:         
538: 538:         
539: 539:         return int256((int256(realA) * int256(realB)) >> REAL_FBITS);
540: 540:     }
541: 541: 
542: 542:     
543: 543: 
544: 544: 
545: 545:     function div(int256 realNumerator, int256 realDenominator) internal pure returns (int256) {
546: 546:         
547: 547:         
548: 548:         return int256((int256(realNumerator) * REAL_ONE) / int256(realDenominator));
549: 549:     }
550: 550: 
551: 551:     
552: 552: 
553: 553: 
554: 554:     function fraction(int216 numerator, int216 denominator) internal pure returns (int256) {
555: 555:         return div(toReal(numerator), toReal(denominator));
556: 556:     }
557: 557: 
558: 558:     
559: 559:     
560: 560:     
561: 561: 
562: 562:     
563: 563: 
564: 564: 
565: 565: 
566: 566:     function ipow(int256 realBase, int216 exponent) internal pure returns (int256) {
567: 567:         if (exponent < 0) {
568: 568:             
569: 569:             revert();
570: 570:         }
571: 571: 
572: 572:         int256 tempRealBase = realBase;
573: 573:         int256 tempExponent = exponent;
574: 574: 
575: 575:         
576: 576:         int256 realResult = REAL_ONE;
577: 577:         while (tempExponent != 0) {
578: 578:             
579: 579:             if ((tempExponent & 0x1) == 0x1) {
580: 580:                 
581: 581:                 realResult = mul(realResult, tempRealBase);
582: 582:             }
583: 583:             
584: 584:             tempExponent = tempExponent >> 1;
585: 585:             
586: 586:             tempRealBase = mul(tempRealBase, tempRealBase);
587: 587:         }
588: 588: 
589: 589:         
590: 590:         return realResult;
591: 591:     }
592: 592: 
593: 593:     
594: 594: 
595: 595: 
596: 596: 
597: 597:     function hibit(uint256 _val) internal pure returns (uint256) {
598: 598:         
599: 599:         uint256 val = _val;
600: 600:         val |= (val >> 1);
601: 601:         val |= (val >> 2);
602: 602:         val |= (val >> 4);
603: 603:         val |= (val >> 8);
604: 604:         val |= (val >> 16);
605: 605:         val |= (val >> 32);
606: 606:         val |= (val >> 64);
607: 607:         val |= (val >> 128);
608: 608:         return val ^ (val >> 1);
609: 609:     }
610: 610: 
611: 611:     
612: 612: 
613: 613: 
614: 614:     function findbit(uint256 val) internal pure returns (uint8 index) {
615: 615:         index = 0;
616: 616:         
617: 617:         if (val & 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA != 0) {
618: 618:             
619: 619:             index |= 1;
620: 620:         }
621: 621:         if (val & 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC != 0) {
622: 622:             
623: 623:             index |= 2;
624: 624:         }
625: 625:         if (val & 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0 != 0) {
626: 626:             
627: 627:             index |= 4;
628: 628:         }
629: 629:         if (val & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00 != 0) {
630: 630:             
631: 631:             index |= 8;
632: 632:         }
633: 633:         if (val & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000 != 0) {
634: 634:             
635: 635:             index |= 16;
636: 636:         }
637: 637:         if (val & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000 != 0) {
638: 638:             
639: 639:             index |= 32;
640: 640:         }
641: 641:         if (val & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000 != 0) {
642: 642:             
643: 643:             index |= 64;
644: 644:         }
645: 645:         if (val & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 != 0) {
646: 646:             
647: 647:             index |= 128;
648: 648:         }
649: 649:     }
650: 650: 
651: 651:     
652: 652: 
653: 653: 
654: 654: 
655: 655: 
656: 656: 
657: 657: 
658: 658: 
659: 659:     function rescale(int256 realArg) internal pure returns (int256 realScaled, int216 shift) {
660: 660:         if (realArg <= 0) {
661: 661:             
662: 662:             revert();
663: 663:         }
664: 664: 
665: 665:         
666: 666:         int216 highBit = findbit(hibit(uint256(realArg)));
667: 667: 
668: 668:         
669: 669:         shift = highBit - int216(REAL_FBITS);
670: 670: 
671: 671:         if (shift < 0) {
672: 672:             
673: 673:             realScaled = realArg << -shift;
674: 674:         } else if (shift >= 0) {
675: 675:             
676: 676:             realScaled = realArg >> shift;
677: 677:         }
678: 678:     }
679: 679: 
680: 680:     
681: 681: 
682: 682: 
683: 683: 
684: 684: 
685: 685: 
686: 686: 
687: 687: 
688: 688: 
689: 689: 
690: 690:     function lnLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
691: 691:         if (realArg <= 0) {
692: 692:             
693: 693:             revert();
694: 694:         }
695: 695: 
696: 696:         if (realArg == REAL_ONE) {
697: 697:             
698: 698:             
699: 699:             return 0;
700: 700:         }
701: 701: 
702: 702:         
703: 703:         int256 realRescaled;
704: 704:         int216 shift;
705: 705:         (realRescaled, shift) = rescale(realArg);
706: 706: 
707: 707:         
708: 708:         int256 realSeriesArg = div(realRescaled - REAL_ONE, realRescaled + REAL_ONE);
709: 709: 
710: 710:         
711: 711:         int256 realSeriesResult = 0;
712: 712: 
713: 713:         for (int216 n = 0; n < maxIterations; n++) {
714: 714:             
715: 715:             int256 realTerm = div(ipow(realSeriesArg, 2 * n + 1), toReal(2 * n + 1));
716: 716:             
717: 717:             realSeriesResult += realTerm;
718: 718:             if (realTerm == 0) {
719: 719:                 
720: 720:                 break;
721: 721:             }
722: 722:             
723: 723:         }
724: 724: 
725: 725:         
726: 726:         realSeriesResult = mul(realSeriesResult, REAL_TWO);
727: 727: 
728: 728:         
729: 729:         return mul(toReal(shift), REAL_LN_TWO) + realSeriesResult;
730: 730: 
731: 731:     }
732: 732: 
733: 733:     
734: 734: 
735: 735: 
736: 736: 
737: 737: 
738: 738:     function ln(int256 realArg) internal pure returns (int256) {
739: 739:         return lnLimited(realArg, 100);
740: 740:     }
741: 741: 
742: 742:     
743: 743: 
744: 744: 
745: 745: 
746: 746: 
747: 747: 
748: 748: 
749: 749: 
750: 750: 
751: 751:     function expLimited(int256 realArg, int maxIterations) internal pure returns (int256) {
752: 752:         
753: 753:         int256 realResult = 0;
754: 754: 
755: 755:         
756: 756:         int256 realTerm = REAL_ONE;
757: 757: 
758: 758:         for (int216 n = 0; n < maxIterations; n++) {
759: 759:             
760: 760:             realResult += realTerm;
761: 761: 
762: 762:             
763: 763:             realTerm = mul(realTerm, div(realArg, toReal(n + 1)));
764: 764: 
765: 765:             if (realTerm == 0) {
766: 766:                 
767: 767:                 break;
768: 768:             }
769: 769:             
770: 770:         }
771: 771: 
772: 772:         
773: 773:         return realResult;
774: 774: 
775: 775:     }
776: 776: 
777: 777:     
778: 778: 
779: 779: 
780: 780: 
781: 781: 
782: 782:     function exp(int256 realArg) internal pure returns (int256) {
783: 783:         return expLimited(realArg, 100);
784: 784:     }
785: 785: 
786: 786:     
787: 787: 
788: 788: 
789: 789:     function pow(int256 realBase, int256 realExponent) internal pure returns (int256) {
790: 790:         if (realExponent == 0) {
791: 791:             
792: 792:             return REAL_ONE;
793: 793:         }
794: 794: 
795: 795:         if (realBase == 0) {
796: 796:             if (realExponent < 0) {
797: 797:                 
798: 798:                 revert();
799: 799:             }
800: 800:             
801: 801:             return 0;
802: 802:         }
803: 803: 
804: 804:         if (fpart(realExponent) == 0) {
805: 805:             
806: 806: 
807: 807:             if (realExponent > 0) {
808: 808:                 
809: 809:                 return ipow(realBase, fromReal(realExponent));
810: 810:             } else {
811: 811:                 
812: 812:                 return div(REAL_ONE, ipow(realBase, fromReal(-realExponent)));
813: 813:             }
814: 814:         }
815: 815: 
816: 816:         if (realBase < 0) {
817: 817:             
818: 818:             
819: 819:             
820: 820:             revert();
821: 821:         }
822: 822: 
823: 823:         
824: 824:         return exp(mul(realExponent, ln(realBase)));
825: 825:     }
826: 826: 
827: 827:     
828: 828: 
829: 829: 
830: 830:     function sqrt(int256 realArg) internal pure returns (int256) {
831: 831:         return pow(realArg, REAL_HALF);
832: 832:     }
833: 833: 
834: 834:     
835: 835: 
836: 836: 
837: 837:     function sinLimited(int256 _realArg, int216 maxIterations) internal pure returns (int256) {
838: 838:         
839: 839:         
840: 840:         
841: 841:         int256 realArg = _realArg;
842: 842:         realArg = realArg % REAL_TWO_PI;
843: 843: 
844: 844:         int256 accumulator = REAL_ONE;
845: 845: 
846: 846:         
847: 847:         for (int216 iteration = maxIterations - 1; iteration >= 0; iteration--) {
848: 848:             accumulator = REAL_ONE - mul(div(mul(realArg, realArg), toReal((2 * iteration + 2) * (2 * iteration + 3))), accumulator);
849: 849:             
850: 850:         }
851: 851: 
852: 852:         return mul(realArg, accumulator);
853: 853:     }
854: 854: 
855: 855:     
856: 856: 
857: 857: 
858: 858: 
859: 859:     function sin(int256 realArg) internal pure returns (int256) {
860: 860:         return sinLimited(realArg, 15);
861: 861:     }
862: 862: 
863: 863:     
864: 864: 
865: 865: 
866: 866:     function cos(int256 realArg) internal pure returns (int256) {
867: 867:         return sin(realArg + REAL_HALF_PI);
868: 868:     }
869: 869: 
870: 870:     
871: 871: 
872: 872: 
873: 873: 
874: 874:     function tan(int256 realArg) internal pure returns (int256) {
875: 875:         return div(sin(realArg), cos(realArg));
876: 876:     }
877: 877: }
878: 878: 
879: 879: 
880: 880: 
881: 881: 
882: 882: 
883: 883: contract ERC827Token is ERC827, StandardToken {
884: 884: 
885: 885:   
886: 886: 
887: 887: 
888: 888: 
889: 889: 
890: 890: 
891: 891: 
892: 892: 
893: 893: 
894: 894: 
895: 895: 
896: 896: 
897: 897: 
898: 898: 
899: 899:     function approveAndCall(
900: 900:         address _spender,
901: 901:         uint256 _value,
902: 902:         bytes _data
903: 903:     )
904: 904:     public
905: 905:     payable
906: 906:     returns (bool)
907: 907:     {
908: 908:         require(_spender != address(this));
909: 909: 
910: 910:         super.approve(_spender, _value);
911: 911: 
912: 912:         
913: 913:         require(_spender.call.value(msg.value)(_data));
914: 914: 
915: 915:         return true;
916: 916:     }
917: 917: 
918: 918:   
919: 919: 
920: 920: 
921: 921: 
922: 922: 
923: 923: 
924: 924: 
925: 925: 
926: 926:     function transferAndCall(
927: 927:         address _to,
928: 928:         uint256 _value,
929: 929:         bytes _data
930: 930:     )
931: 931:     public
932: 932:     payable
933: 933:     returns (bool)
934: 934:     {
935: 935:         require(_to != address(this));
936: 936: 
937: 937:         super.transfer(_to, _value);
938: 938: 
939: 939:         
940: 940:         require(_to.call.value(msg.value)(_data));
941: 941:         return true;
942: 942:     }
943: 943: 
944: 944:   
945: 945: 
946: 946: 
947: 947: 
948: 948: 
949: 949: 
950: 950: 
951: 951: 
952: 952: 
953: 953:     function transferFromAndCall(
954: 954:         address _from,
955: 955:         address _to,
956: 956:         uint256 _value,
957: 957:         bytes _data
958: 958:     )
959: 959:     public payable returns (bool)
960: 960:     {
961: 961:         require(_to != address(this));
962: 962: 
963: 963:         super.transferFrom(_from, _to, _value);
964: 964: 
965: 965:         
966: 966:         require(_to.call.value(msg.value)(_data));
967: 967:         return true;
968: 968:     }
969: 969: 
970: 970:   
971: 971: 
972: 972: 
973: 973: 
974: 974: 
975: 975: 
976: 976: 
977: 977: 
978: 978: 
979: 979: 
980: 980: 
981: 981:     function increaseApprovalAndCall(
982: 982:         address _spender,
983: 983:         uint _addedValue,
984: 984:         bytes _data
985: 985:     )
986: 986:     public
987: 987:     payable
988: 988:     returns (bool)
989: 989:     {
990: 990:         require(_spender != address(this));
991: 991: 
992: 992:         super.increaseApproval(_spender, _addedValue);
993: 993: 
994: 994:         
995: 995:         require(_spender.call.value(msg.value)(_data));
996: 996: 
997: 997:         return true;
998: 998:     }
999: 999: 
1000: 1000:   
1001: 1001: 
1002: 1002: 
1003: 1003: 
1004: 1004: 
1005: 1005: 
1006: 1006: 
1007: 1007: 
1008: 1008: 
1009: 1009: 
1010: 1010: 
1011: 1011:     function decreaseApprovalAndCall(
1012: 1012:         address _spender,
1013: 1013:         uint _subtractedValue,
1014: 1014:         bytes _data
1015: 1015:     )
1016: 1016:     public
1017: 1017:     payable
1018: 1018:     returns (bool)
1019: 1019:     {
1020: 1020:         require(_spender != address(this));
1021: 1021: 
1022: 1022:         super.decreaseApproval(_spender, _subtractedValue);
1023: 1023: 
1024: 1024:         
1025: 1025:         require(_spender.call.value(msg.value)(_data));
1026: 1026: 
1027: 1027:         return true;
1028: 1028:     }
1029: 1029: 
1030: 1030: }
1031: 1031: 
1032: 1032: 
1033: 1033: 
1034: 1034: 
1035: 1035: 
1036: 1036: 