1: 1: pragma solidity ^0.4.15;
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
41: 41: pragma solidity ^0.4.14;
42: 42: 
43: 43: library strings {
44: 44:     struct slice {
45: 45:         uint _len;
46: 46:         uint _ptr;
47: 47:     }
48: 48: 
49: 49:     function memcpy(uint dest, uint src, uint len) private pure {
50: 50:         
51: 51:         for(; len >= 32; len -= 32) {
52: 52:             assembly {
53: 53:                 mstore(dest, mload(src))
54: 54:             }
55: 55:             dest += 32;
56: 56:             src += 32;
57: 57:         }
58: 58: 
59: 59:         
60: 60:         uint mask = 256 ** (32 - len) - 1;
61: 61:         assembly {
62: 62:             let srcpart := and(mload(src), not(mask))
63: 63:             let destpart := and(mload(dest), mask)
64: 64:             mstore(dest, or(destpart, srcpart))
65: 65:         }
66: 66:     }
67: 67: 
68: 68:     
69: 69: 
70: 70: 
71: 71: 
72: 72: 
73: 73:     function toSlice(string self) internal pure returns (slice) {
74: 74:         uint ptr;
75: 75:         assembly {
76: 76:             ptr := add(self, 0x20)
77: 77:         }
78: 78:         return slice(bytes(self).length, ptr);
79: 79:     }
80: 80: 
81: 81:     
82: 82: 
83: 83: 
84: 84: 
85: 85: 
86: 86:     function len(bytes32 self) internal pure returns (uint) {
87: 87:         uint ret;
88: 88:         if (self == 0)
89: 89:             return 0;
90: 90:         if (self & 0xffffffffffffffffffffffffffffffff == 0) {
91: 91:             ret += 16;
92: 92:             self = bytes32(uint(self) / 0x100000000000000000000000000000000);
93: 93:         }
94: 94:         if (self & 0xffffffffffffffff == 0) {
95: 95:             ret += 8;
96: 96:             self = bytes32(uint(self) / 0x10000000000000000);
97: 97:         }
98: 98:         if (self & 0xffffffff == 0) {
99: 99:             ret += 4;
100: 100:             self = bytes32(uint(self) / 0x100000000);
101: 101:         }
102: 102:         if (self & 0xffff == 0) {
103: 103:             ret += 2;
104: 104:             self = bytes32(uint(self) / 0x10000);
105: 105:         }
106: 106:         if (self & 0xff == 0) {
107: 107:             ret += 1;
108: 108:         }
109: 109:         return 32 - ret;
110: 110:     }
111: 111: 
112: 112:     
113: 113: 
114: 114: 
115: 115: 
116: 116: 
117: 117: 
118: 118: 
119: 119:     function toSliceB32(bytes32 self) internal pure returns (slice ret) {
120: 120:         
121: 121:         assembly {
122: 122:             let ptr := mload(0x40)
123: 123:             mstore(0x40, add(ptr, 0x20))
124: 124:             mstore(ptr, self)
125: 125:             mstore(add(ret, 0x20), ptr)
126: 126:         }
127: 127:         ret._len = len(self);
128: 128:     }
129: 129: 
130: 130:     
131: 131: 
132: 132: 
133: 133: 
134: 134: 
135: 135:     function copy(slice self) internal pure returns (slice) {
136: 136:         return slice(self._len, self._ptr);
137: 137:     }
138: 138: 
139: 139:     
140: 140: 
141: 141: 
142: 142: 
143: 143: 
144: 144:     function toString(slice self) internal pure returns (string) {
145: 145:         string memory ret = new string(self._len);
146: 146:         uint retptr;
147: 147:         assembly { retptr := add(ret, 32) }
148: 148: 
149: 149:         memcpy(retptr, self._ptr, self._len);
150: 150:         return ret;
151: 151:     }
152: 152: 
153: 153:     
154: 154: 
155: 155: 
156: 156: 
157: 157: 
158: 158: 
159: 159: 
160: 160: 
161: 161:     function len(slice self) internal pure returns (uint l) {
162: 162:         
163: 163:         uint ptr = self._ptr - 31;
164: 164:         uint end = ptr + self._len;
165: 165:         for (l = 0; ptr < end; l++) {
166: 166:             uint8 b;
167: 167:             assembly { b := and(mload(ptr), 0xFF) }
168: 168:             if (b < 0x80) {
169: 169:                 ptr += 1;
170: 170:             } else if(b < 0xE0) {
171: 171:                 ptr += 2;
172: 172:             } else if(b < 0xF0) {
173: 173:                 ptr += 3;
174: 174:             } else if(b < 0xF8) {
175: 175:                 ptr += 4;
176: 176:             } else if(b < 0xFC) {
177: 177:                 ptr += 5;
178: 178:             } else {
179: 179:                 ptr += 6;
180: 180:             }
181: 181:         }
182: 182:     }
183: 183: 
184: 184:     
185: 185: 
186: 186: 
187: 187: 
188: 188: 
189: 189:     function empty(slice self) internal pure returns (bool) {
190: 190:         return self._len == 0;
191: 191:     }
192: 192: 
193: 193:     
194: 194: 
195: 195: 
196: 196: 
197: 197: 
198: 198: 
199: 199: 
200: 200: 
201: 201: 
202: 202:     function compare(slice self, slice other) internal pure returns (int) {
203: 203:         uint shortest = self._len;
204: 204:         if (other._len < self._len)
205: 205:             shortest = other._len;
206: 206: 
207: 207:         uint selfptr = self._ptr;
208: 208:         uint otherptr = other._ptr;
209: 209:         for (uint idx = 0; idx < shortest; idx += 32) {
210: 210:             uint a;
211: 211:             uint b;
212: 212:             assembly {
213: 213:                 a := mload(selfptr)
214: 214:                 b := mload(otherptr)
215: 215:             }
216: 216:             if (a != b) {
217: 217:                 
218: 218:                 uint256 mask = uint256(-1); 
219: 219:                 if(shortest < 32) {
220: 220:                     mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
221: 221:                 }
222: 222:                 uint256 diff = (a & mask) - (b & mask);
223: 223:                 if (diff != 0)
224: 224:                     return int(diff);
225: 225:             }
226: 226:             selfptr += 32;
227: 227:             otherptr += 32;
228: 228:         }
229: 229:         return int(self._len) - int(other._len);
230: 230:     }
231: 231: 
232: 232:     
233: 233: 
234: 234: 
235: 235: 
236: 236: 
237: 237: 
238: 238:     function equals(slice self, slice other) internal pure returns (bool) {
239: 239:         return compare(self, other) == 0;
240: 240:     }
241: 241: 
242: 242:     
243: 243: 
244: 244: 
245: 245: 
246: 246: 
247: 247: 
248: 248: 
249: 249:     function nextRune(slice self, slice rune) internal pure returns (slice) {
250: 250:         rune._ptr = self._ptr;
251: 251: 
252: 252:         if (self._len == 0) {
253: 253:             rune._len = 0;
254: 254:             return rune;
255: 255:         }
256: 256: 
257: 257:         uint l;
258: 258:         uint b;
259: 259:         
260: 260:         assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
261: 261:         if (b < 0x80) {
262: 262:             l = 1;
263: 263:         } else if(b < 0xE0) {
264: 264:             l = 2;
265: 265:         } else if(b < 0xF0) {
266: 266:             l = 3;
267: 267:         } else {
268: 268:             l = 4;
269: 269:         }
270: 270: 
271: 271:         
272: 272:         if (l > self._len) {
273: 273:             rune._len = self._len;
274: 274:             self._ptr += self._len;
275: 275:             self._len = 0;
276: 276:             return rune;
277: 277:         }
278: 278: 
279: 279:         self._ptr += l;
280: 280:         self._len -= l;
281: 281:         rune._len = l;
282: 282:         return rune;
283: 283:     }
284: 284: 
285: 285:     
286: 286: 
287: 287: 
288: 288: 
289: 289: 
290: 290: 
291: 291:     function nextRune(slice self) internal pure returns (slice ret) {
292: 292:         nextRune(self, ret);
293: 293:     }
294: 294: 
295: 295:     
296: 296: 
297: 297: 
298: 298: 
299: 299: 
300: 300:     function ord(slice self) internal pure returns (uint ret) {
301: 301:         if (self._len == 0) {
302: 302:             return 0;
303: 303:         }
304: 304: 
305: 305:         uint word;
306: 306:         uint length;
307: 307:         uint divisor = 2 ** 248;
308: 308: 
309: 309:         
310: 310:         assembly { word:= mload(mload(add(self, 32))) }
311: 311:         uint b = word / divisor;
312: 312:         if (b < 0x80) {
313: 313:             ret = b;
314: 314:             length = 1;
315: 315:         } else if(b < 0xE0) {
316: 316:             ret = b & 0x1F;
317: 317:             length = 2;
318: 318:         } else if(b < 0xF0) {
319: 319:             ret = b & 0x0F;
320: 320:             length = 3;
321: 321:         } else {
322: 322:             ret = b & 0x07;
323: 323:             length = 4;
324: 324:         }
325: 325: 
326: 326:         
327: 327:         if (length > self._len) {
328: 328:             return 0;
329: 329:         }
330: 330: 
331: 331:         for (uint i = 1; i < length; i++) {
332: 332:             divisor = divisor / 256;
333: 333:             b = (word / divisor) & 0xFF;
334: 334:             if (b & 0xC0 != 0x80) {
335: 335:                 
336: 336:                 return 0;
337: 337:             }
338: 338:             ret = (ret * 64) | (b & 0x3F);
339: 339:         }
340: 340: 
341: 341:         return ret;
342: 342:     }
343: 343: 
344: 344:     
345: 345: 
346: 346: 
347: 347: 
348: 348: 
349: 349:     function keccak(slice self) internal pure returns (bytes32 ret) {
350: 350:         assembly {
351: 351:             ret := keccak256(mload(add(self, 32)), mload(self))
352: 352:         }
353: 353:     }
354: 354: 
355: 355:     
356: 356: 
357: 357: 
358: 358: 
359: 359: 
360: 360: 
361: 361:     function startsWith(slice self, slice needle) internal pure returns (bool) {
362: 362:         if (self._len < needle._len) {
363: 363:             return false;
364: 364:         }
365: 365: 
366: 366:         if (self._ptr == needle._ptr) {
367: 367:             return true;
368: 368:         }
369: 369: 
370: 370:         bool equal;
371: 371:         assembly {
372: 372:             let length := mload(needle)
373: 373:             let selfptr := mload(add(self, 0x20))
374: 374:             let needleptr := mload(add(needle, 0x20))
375: 375:             equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
376: 376:         }
377: 377:         return equal;
378: 378:     }
379: 379: 
380: 380:     
381: 381: 
382: 382: 
383: 383: 
384: 384: 
385: 385: 
386: 386: 
387: 387:     function beyond(slice self, slice needle) internal pure returns (slice) {
388: 388:         if (self._len < needle._len) {
389: 389:             return self;
390: 390:         }
391: 391: 
392: 392:         bool equal = true;
393: 393:         if (self._ptr != needle._ptr) {
394: 394:             assembly {
395: 395:                 let length := mload(needle)
396: 396:                 let selfptr := mload(add(self, 0x20))
397: 397:                 let needleptr := mload(add(needle, 0x20))
398: 398:                 equal := eq(sha3(selfptr, length), sha3(needleptr, length))
399: 399:             }
400: 400:         }
401: 401: 
402: 402:         if (equal) {
403: 403:             self._len -= needle._len;
404: 404:             self._ptr += needle._len;
405: 405:         }
406: 406: 
407: 407:         return self;
408: 408:     }
409: 409: 
410: 410:     
411: 411: 
412: 412: 
413: 413: 
414: 414: 
415: 415: 
416: 416:     function endsWith(slice self, slice needle) internal pure returns (bool) {
417: 417:         if (self._len < needle._len) {
418: 418:             return false;
419: 419:         }
420: 420: 
421: 421:         uint selfptr = self._ptr + self._len - needle._len;
422: 422: 
423: 423:         if (selfptr == needle._ptr) {
424: 424:             return true;
425: 425:         }
426: 426: 
427: 427:         bool equal;
428: 428:         assembly {
429: 429:             let length := mload(needle)
430: 430:             let needleptr := mload(add(needle, 0x20))
431: 431:             equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
432: 432:         }
433: 433: 
434: 434:         return equal;
435: 435:     }
436: 436: 
437: 437:     
438: 438: 
439: 439: 
440: 440: 
441: 441: 
442: 442: 
443: 443: 
444: 444:     function until(slice self, slice needle) internal pure returns (slice) {
445: 445:         if (self._len < needle._len) {
446: 446:             return self;
447: 447:         }
448: 448: 
449: 449:         uint selfptr = self._ptr + self._len - needle._len;
450: 450:         bool equal = true;
451: 451:         if (selfptr != needle._ptr) {
452: 452:             assembly {
453: 453:                 let length := mload(needle)
454: 454:                 let needleptr := mload(add(needle, 0x20))
455: 455:                 equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
456: 456:             }
457: 457:         }
458: 458: 
459: 459:         if (equal) {
460: 460:             self._len -= needle._len;
461: 461:         }
462: 462: 
463: 463:         return self;
464: 464:     }
465: 465: 
466: 466:     event log_bytemask(bytes32 mask);
467: 467: 
468: 468:     
469: 469:     
470: 470:     function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
471: 471:         uint ptr = selfptr;
472: 472:         uint idx;
473: 473: 
474: 474:         if (needlelen <= selflen) {
475: 475:             if (needlelen <= 32) {
476: 476:                 bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
477: 477: 
478: 478:                 bytes32 needledata;
479: 479:                 assembly { needledata := and(mload(needleptr), mask) }
480: 480: 
481: 481:                 uint end = selfptr + selflen - needlelen;
482: 482:                 bytes32 ptrdata;
483: 483:                 assembly { ptrdata := and(mload(ptr), mask) }
484: 484: 
485: 485:                 while (ptrdata != needledata) {
486: 486:                     if (ptr >= end)
487: 487:                         return selfptr + selflen;
488: 488:                     ptr++;
489: 489:                     assembly { ptrdata := and(mload(ptr), mask) }
490: 490:                 }
491: 491:                 return ptr;
492: 492:             } else {
493: 493:                 
494: 494:                 bytes32 hash;
495: 495:                 assembly { hash := sha3(needleptr, needlelen) }
496: 496: 
497: 497:                 for (idx = 0; idx <= selflen - needlelen; idx++) {
498: 498:                     bytes32 testHash;
499: 499:                     assembly { testHash := sha3(ptr, needlelen) }
500: 500:                     if (hash == testHash)
501: 501:                         return ptr;
502: 502:                     ptr += 1;
503: 503:                 }
504: 504:             }
505: 505:         }
506: 506:         return selfptr + selflen;
507: 507:     }
508: 508: 
509: 509:     
510: 510:     
511: 511:     function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
512: 512:         uint ptr;
513: 513: 
514: 514:         if (needlelen <= selflen) {
515: 515:             if (needlelen <= 32) {
516: 516:                 bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));
517: 517: 
518: 518:                 bytes32 needledata;
519: 519:                 assembly { needledata := and(mload(needleptr), mask) }
520: 520: 
521: 521:                 ptr = selfptr + selflen - needlelen;
522: 522:                 bytes32 ptrdata;
523: 523:                 assembly { ptrdata := and(mload(ptr), mask) }
524: 524: 
525: 525:                 while (ptrdata != needledata) {
526: 526:                     if (ptr <= selfptr)
527: 527:                         return selfptr;
528: 528:                     ptr--;
529: 529:                     assembly { ptrdata := and(mload(ptr), mask) }
530: 530:                 }
531: 531:                 return ptr + needlelen;
532: 532:             } else {
533: 533:                 
534: 534:                 bytes32 hash;
535: 535:                 assembly { hash := sha3(needleptr, needlelen) }
536: 536:                 ptr = selfptr + (selflen - needlelen);
537: 537:                 while (ptr >= selfptr) {
538: 538:                     bytes32 testHash;
539: 539:                     assembly { testHash := sha3(ptr, needlelen) }
540: 540:                     if (hash == testHash)
541: 541:                         return ptr + needlelen;
542: 542:                     ptr -= 1;
543: 543:                 }
544: 544:             }
545: 545:         }
546: 546:         return selfptr;
547: 547:     }
548: 548: 
549: 549:     
550: 550: 
551: 551: 
552: 552: 
553: 553: 
554: 554: 
555: 555: 
556: 556: 
557: 557:     function find(slice self, slice needle) internal pure returns (slice) {
558: 558:         uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
559: 559:         self._len -= ptr - self._ptr;
560: 560:         self._ptr = ptr;
561: 561:         return self;
562: 562:     }
563: 563: 
564: 564:     
565: 565: 
566: 566: 
567: 567: 
568: 568: 
569: 569: 
570: 570: 
571: 571: 
572: 572:     function rfind(slice self, slice needle) internal pure returns (slice) {
573: 573:         uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
574: 574:         self._len = ptr - self._ptr;
575: 575:         return self;
576: 576:     }
577: 577: 
578: 578:     
579: 579: 
580: 580: 
581: 581: 
582: 582: 
583: 583: 
584: 584: 
585: 585: 
586: 586: 
587: 587: 
588: 588:     function split(slice self, slice needle, slice token) internal pure returns (slice) {
589: 589:         uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
590: 590:         token._ptr = self._ptr;
591: 591:         token._len = ptr - self._ptr;
592: 592:         if (ptr == self._ptr + self._len) {
593: 593:             
594: 594:             self._len = 0;
595: 595:         } else {
596: 596:             self._len -= token._len + needle._len;
597: 597:             self._ptr = ptr + needle._len;
598: 598:         }
599: 599:         return token;
600: 600:     }
601: 601: 
602: 602:     
603: 603: 
604: 604: 
605: 605: 
606: 606: 
607: 607: 
608: 608: 
609: 609: 
610: 610: 
611: 611:     function split(slice self, slice needle) internal pure returns (slice token) {
612: 612:         split(self, needle, token);
613: 613:     }
614: 614: 
615: 615:     
616: 616: 
617: 617: 
618: 618: 
619: 619: 
620: 620: 
621: 621: 
622: 622: 
623: 623: 
624: 624: 
625: 625:     function rsplit(slice self, slice needle, slice token) internal pure returns (slice) {
626: 626:         uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
627: 627:         token._ptr = ptr;
628: 628:         token._len = self._len - (ptr - self._ptr);
629: 629:         if (ptr == self._ptr) {
630: 630:             
631: 631:             self._len = 0;
632: 632:         } else {
633: 633:             self._len -= token._len + needle._len;
634: 634:         }
635: 635:         return token;
636: 636:     }
637: 637: 
638: 638:     
639: 639: 
640: 640: 
641: 641: 
642: 642: 
643: 643: 
644: 644: 
645: 645: 
646: 646: 
647: 647:     function rsplit(slice self, slice needle) internal pure returns (slice token) {
648: 648:         rsplit(self, needle, token);
649: 649:     }
650: 650: 
651: 651:     
652: 652: 
653: 653: 
654: 654: 
655: 655: 
656: 656: 
657: 657:     function count(slice self, slice needle) internal pure returns (uint cnt) {
658: 658:         uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
659: 659:         while (ptr <= self._ptr + self._len) {
660: 660:             cnt++;
661: 661:             ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
662: 662:         }
663: 663:     }
664: 664: 
665: 665:     
666: 666: 
667: 667: 
668: 668: 
669: 669: 
670: 670: 
671: 671:     function contains(slice self, slice needle) internal pure returns (bool) {
672: 672:         return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
673: 673:     }
674: 674: 
675: 675:     
676: 676: 
677: 677: 
678: 678: 
679: 679: 
680: 680: 
681: 681: 
682: 682:     function concat(slice self, slice other) internal pure returns (string) {
683: 683:         string memory ret = new string(self._len + other._len);
684: 684:         uint retptr;
685: 685:         assembly { retptr := add(ret, 32) }
686: 686:         memcpy(retptr, self._ptr, self._len);
687: 687:         memcpy(retptr + self._len, other._ptr, other._len);
688: 688:         return ret;
689: 689:     }
690: 690: 
691: 691:     
692: 692: 
693: 693: 
694: 694: 
695: 695: 
696: 696: 
697: 697: 
698: 698: 
699: 699:     function join(slice self, slice[] parts) internal pure returns (string) {
700: 700:         if (parts.length == 0)
701: 701:             return "";
702: 702: 
703: 703:         uint length = self._len * (parts.length - 1);
704: 704:         for(uint i = 0; i < parts.length; i++)
705: 705:             length += parts[i]._len;
706: 706: 
707: 707:         string memory ret = new string(length);
708: 708:         uint retptr;
709: 709:         assembly { retptr := add(ret, 32) }
710: 710: 
711: 711:         for(i = 0; i < parts.length; i++) {
712: 712:             memcpy(retptr, parts[i]._ptr, parts[i]._len);
713: 713:             retptr += parts[i]._len;
714: 714:             if (i < parts.length - 1) {
715: 715:                 memcpy(retptr, self._ptr, self._len);
716: 716:                 retptr += self._len;
717: 717:             }
718: 718:         }
719: 719: 
720: 720:         return ret;
721: 721:     }
722: 722: }
723: 723: 
724: 724: 
725: 725: 
726: 726: 
727: 727: 
728: 728: 
729: 729: contract MyWill {
730: 730: 
731: 731:     using strings for *;
732: 732: 
733: 733:     
734: 734:     address club;
735: 735: 
736: 736:     
737: 737:     address owner;
738: 738: 
739: 739:     
740: 740:     string listWitnesses;
741: 741: 
742: 742:     
743: 743:     string listHeirs;
744: 744:     string listHeirsPercentages;
745: 745: 
746: 746:     
747: 747:     mapping (string => bool) mapHeirsVoteOwnerHasDied;
748: 748: 
749: 749:     
750: 750:     enum Status {CREATED, ALIVE, DEAD}
751: 751:     Status status;
752: 752: 
753: 753:     
754: 754:     event Deposit(address from, uint value);
755: 755:     event SingleTransact(address owner, uint value, address to, bytes data);
756: 756: 
757: 757:     
758: 758:     
759: 759:     
760: 760: 
761: 761:     function MyWill (address _owner, string _listHeirs, string _listHeirsPercentages, string _listWitnesses, address _club) {
762: 762:         club = _club;
763: 763:         owner = _owner;
764: 764:         status = Status.CREATED;
765: 765:         listHeirs = _listHeirs;
766: 766:         listHeirsPercentages = _listHeirsPercentages;
767: 767:         listWitnesses = _listWitnesses;
768: 768: 
769: 769:         
770: 770:         var s = _listHeirsPercentages.toSlice().copy();
771: 771:         var delim = ";".toSlice();
772: 772:         var parts = new uint256[](s.count(delim) + 1);
773: 773: 
774: 774:         uint256 countPercentage;
775: 775:         for(uint i = 0; i < parts.length; i++) {
776: 776:             countPercentage = countPercentage + stringToUint(s.split(delim).toString());
777: 777:         }
778: 778: 
779: 779:         require(countPercentage == 100000);
780: 780:     }
781: 781: 
782: 782:     
783: 783:     
784: 784:     
785: 785: 
786: 786:     modifier onlyOwner() {
787: 787:         require(msg.sender == owner);
788: 788:         _;
789: 789:     }
790: 790: 
791: 791:     modifier onlyAlive() {
792: 792:         require(status == Status.ALIVE || status == Status.CREATED);
793: 793:         _;
794: 794:     }
795: 795: 
796: 796:     modifier onlyDead() {
797: 797:         require(status == Status.DEAD);
798: 798:         _;
799: 799:     }
800: 800: 
801: 801:     modifier onlyHeir() {
802: 802: 
803: 803:         var s = listHeirs.toSlice().copy();
804: 804:         var delim = ";".toSlice();
805: 805:         string[] memory listOfHeirs = new string[](s.count(delim) + 1);
806: 806:         bool itsHeir = false;
807: 807: 
808: 808:         string memory senderStringAddress = addressToString(msg.sender);
809: 809: 
810: 810:         for(uint i = 0; i < listOfHeirs.length; i++) {
811: 811: 
812: 812:             if(keccak256(senderStringAddress) == keccak256(s.split(delim).toString())){
813: 813:                 itsHeir = true;
814: 814:                 break;
815: 815:             }
816: 816:         }
817: 817: 
818: 818:         require(itsHeir);
819: 819: 
820: 820:         _;
821: 821:     }
822: 822: 
823: 823:     modifier onlyWitness() {
824: 824: 
825: 825:         var s = listWitnesses.toSlice().copy();
826: 826:         var delim = ";".toSlice();
827: 827:         string[] memory arrayOfWitnesses = new string[](s.count(delim) + 1);
828: 828:         bool itsWitness = false;
829: 829: 
830: 830:         string memory senderStringAddress = addressToString(msg.sender);
831: 831: 
832: 832:         for(uint i = 0; i < arrayOfWitnesses.length; i++) {
833: 833: 
834: 834:             if(keccak256(senderStringAddress) == keccak256(s.split(delim).toString())){
835: 835:                 itsWitness = true;
836: 836:                 break;
837: 837:             }
838: 838:         }
839: 839: 
840: 840:         require(itsWitness);
841: 841: 
842: 842:         _;
843: 843:     }
844: 844: 
845: 845:     
846: 846:     
847: 847:     
848: 848: 
849: 849:     
850: 850:     function () payable onlyAlive {
851: 851:         if (status == Status.CREATED) {
852: 852:             
853: 853: 
854: 854:             
855: 855:             var witnessesList = listWitnesses.toSlice().copy();
856: 856:             var witnessesLength = witnessesList.count(";".toSlice()) + 1;
857: 857:             var needed = 1000000000000000 * witnessesLength + 5000000000000000; 
858: 858:             require(msg.value > needed);
859: 859: 
860: 860:             
861: 861:             for (uint i = 0; i < witnessesLength; i++) {
862: 862:                 var witnessAddress = parseAddr(witnessesList.split(";".toSlice()).toString());
863: 863:                 witnessAddress.transfer(1000000000000000);
864: 864:             }
865: 865: 
866: 866:             
867: 867:             club.transfer(5000000000000000);
868: 868: 
869: 869:             
870: 870:             status = Status.ALIVE;
871: 871: 
872: 872:             
873: 873:             Deposit(msg.sender, msg.value - needed);
874: 874:         } else {
875: 875:             Deposit(msg.sender, msg.value);
876: 876:         }
877: 877:     }
878: 878: 
879: 879:     
880: 880:     function ownerDied() onlyWitness onlyAlive {
881: 881: 
882: 882:         require (this.balance > 0);
883: 883: 
884: 884:         
885: 885:         mapHeirsVoteOwnerHasDied[addressToString(msg.sender)] = true;
886: 886: 
887: 887:         var users = listWitnesses.toSlice().copy();
888: 888:         uint256 listLength = users.count(";".toSlice()) + 1;
889: 889:         uint8 count = 0;
890: 890: 
891: 891:         for(uint i = 0; i < listLength; i++) {
892: 892: 
893: 893:             if(mapHeirsVoteOwnerHasDied[users.split(";".toSlice()).toString()] == true){
894: 894:                 count = count + 1;
895: 895:             }
896: 896:         }
897: 897: 
898: 898:         if(count == listLength){
899: 899: 
900: 900:             
901: 901: 
902: 902:             users = listHeirs.toSlice().copy();
903: 903:             var  percentages = listHeirsPercentages.toSlice().copy();
904: 904:             listLength = users.count(";".toSlice()) + 1;
905: 905: 
906: 906:             for(i = 0; i < listLength - 1; i++) {
907: 907:                 parseAddr(users.split(";".toSlice()).toString()).transfer(((this.balance * stringToUint(percentages.split(";".toSlice()).toString())) / 100000));
908: 908:             }
909: 909: 
910: 910:             
911: 911:             parseAddr(users.split(";".toSlice()).toString()).transfer(this.balance);
912: 912: 
913: 913:             status = Status.DEAD;
914: 914:         }
915: 915:     }
916: 916: 
917: 917:     
918: 918:     
919: 919:     
920: 920: 
921: 921:     function execute(address _to, uint _value, bytes _data) external onlyOwner {
922: 922:         SingleTransact(msg.sender, _value, _to, _data);
923: 923:         _to.call.value(_value)(_data);
924: 924:     }
925: 925: 
926: 926:     
927: 927:     
928: 928:     
929: 929: 
930: 930:     function isOwner() returns (bool){
931: 931:         return msg.sender == owner;
932: 932:     }
933: 933: 
934: 934:     function getStatus() returns (Status){
935: 935:         return status;
936: 936:     }
937: 937: 
938: 938:     function getHeirs() returns (string, string) {
939: 939:         return (listHeirs, listHeirsPercentages);
940: 940:     }
941: 941: 
942: 942:     function getWitnesses() returns (string) {
943: 943:         return listWitnesses;
944: 944:     }
945: 945: 
946: 946:     function getWitnessesCount() returns (uint) {
947: 947:         return listWitnesses.toSlice().copy().count(";".toSlice()) + 1;
948: 948:     }
949: 949: 
950: 950:     function getBalance() constant returns (uint) {
951: 951:         return  address(this).balance;
952: 952:     }
953: 953: 
954: 954:     function hasVoted() returns (bool){
955: 955:         return mapHeirsVoteOwnerHasDied[addressToString(msg.sender)];
956: 956:     }
957: 957: 
958: 958:     
959: 959:     
960: 960:     
961: 961: 
962: 962:     function stringToUint(string s) constant private returns (uint result) {
963: 963:         bytes memory b = bytes(s);
964: 964:         uint i;
965: 965:         result = 0;
966: 966:         for (i = 0; i < b.length; i++) {
967: 967:             uint c = uint(b[i]);
968: 968:             if (c >= 48 && c <= 57) {
969: 969:                 result = result * 10 + (c - 48);
970: 970:             }
971: 971:         }
972: 972:     }
973: 973: 
974: 974:     function addressToString(address x) private returns (string) {
975: 975:         bytes memory s = new bytes(42);
976: 976:         s[0] = "0";
977: 977:         s[1] = "x";
978: 978:         for (uint i = 0; i < 20; i++) {
979: 979:             byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
980: 980:             byte hi = byte(uint8(b) / 16);
981: 981:             byte lo = byte(uint8(b) - 16 * uint8(hi));
982: 982:             s[2+2*i] = char(hi);
983: 983:             s[2+2*i+1] = char(lo);
984: 984:         }
985: 985:         return string(s);
986: 986:     }
987: 987: 
988: 988:     function char(byte b) private returns (byte c) {
989: 989:         if (b < 10) return byte(uint8(b) + 0x30);
990: 990:         else return byte(uint8(b) + 0x57);
991: 991:     }
992: 992: 
993: 993: 
994: 994:     function parseAddr(string _a) internal returns (address){
995: 995:         bytes memory tmp = bytes(_a);
996: 996:         uint160 iaddr = 0;
997: 997:         uint160 b1;
998: 998:         uint160 b2;
999: 999:         for (uint i=2; i<2+2*20; i+=2){
1000: 1000:             iaddr *= 256;
1001: 1001:             b1 = uint160(tmp[i]);
1002: 1002:             b2 = uint160(tmp[i+1]);
1003: 1003:             if ((b1 >= 97)&&(b1 <= 102)) b1 -= 87;
1004: 1004:             else if ((b1 >= 48)&&(b1 <= 57)) b1 -= 48;
1005: 1005:             if ((b2 >= 97)&&(b2 <= 102)) b2 -= 87;
1006: 1006:             else if ((b2 >= 48)&&(b2 <= 57)) b2 -= 48;
1007: 1007:             iaddr += (b1*16+b2);
1008: 1008:         }
1009: 1009:         return address(iaddr);
1010: 1010:     }
1011: 1011: 
1012: 1012: 
1013: 1013: }
1014: 1014: 
1015: 1015: 
1016: 1016: 
1017: 1017: 
1018: 1018: 
1019: 1019: 
1020: 1020: 