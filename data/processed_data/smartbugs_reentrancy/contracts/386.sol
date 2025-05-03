1: 1: pragma solidity ^0.4.23;
2: 2: 
3: 3: library Math {
4: 4:   function max64(uint64 a, uint64 b) internal pure returns (uint64) {
5: 5:     return a >= b ? a : b;
6: 6:   }
7: 7: 
8: 8:   function min64(uint64 a, uint64 b) internal pure returns (uint64) {
9: 9:     return a < b ? a : b;
10: 10:   }
11: 11: 
12: 12:   function max256(uint256 a, uint256 b) internal pure returns (uint256) {
13: 13:     return a >= b ? a : b;
14: 14:   }
15: 15: 
16: 16:   function min256(uint256 a, uint256 b) internal pure returns (uint256) {
17: 17:     return a < b ? a : b;
18: 18:   }
19: 19: }
20: 20: 
21: 21: library SafeMath {
22: 22: 
23: 23:   
24: 24: 
25: 25: 
26: 26:   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
27: 27:     if (a == 0) {
28: 28:       return 0;
29: 29:     }
30: 30:     c = a * b;
31: 31:     assert(c / a == b);
32: 32:     return c;
33: 33:   }
34: 34: 
35: 35:   
36: 36: 
37: 37: 
38: 38:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
39: 39:     
40: 40:     
41: 41:     
42: 42:     return a / b;
43: 43:   }
44: 44: 
45: 45:   
46: 46: 
47: 47: 
48: 48:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
49: 49:     assert(b <= a);
50: 50:     return a - b;
51: 51:   }
52: 52: 
53: 53:   
54: 54: 
55: 55: 
56: 56:   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
57: 57:     c = a + b;
58: 58:     assert(c >= a);
59: 59:     return c;
60: 60:   }
61: 61: }
62: 62: 
63: 63: contract SatisfactionToken is ERC20, CheckpointStorage, NoOwner {
64: 64: 
65: 65:   event Transfer(address indexed from, address indexed to, uint256 value);
66: 66:   event Approval(address indexed owner, address indexed spender, uint256 value);
67: 67: 
68: 68:   event Mint(address indexed to, uint256 amount);
69: 69:   event MintFinished();
70: 70:   event Burn(address indexed burner, uint256 value);
71: 71: 
72: 72:   using SafeMath for uint256;
73: 73: 
74: 74:   string public name = "Satisfaction Token";
75: 75:   uint8 public decimals = 18;
76: 76:   string public symbol = "SAT";
77: 77:   string public version;
78: 78: 
79: 79:   
80: 80: 
81: 81: 
82: 82: 
83: 83:   SatisfactionToken public parentToken;
84: 84: 
85: 85:   
86: 86: 
87: 87: 
88: 88: 
89: 89:   uint256 public parentSnapShotBlock;
90: 90: 
91: 91:   
92: 92:   uint256 public creationBlock;
93: 93: 
94: 94:   
95: 95: 
96: 96: 
97: 97: 
98: 98: 
99: 99:   mapping(address => Checkpoint[]) internal balances;
100: 100: 
101: 101:   
102: 102:   mapping(address => mapping(address => uint256)) internal allowed;
103: 103: 
104: 104:   
105: 105:   bool public transfersEnabled;
106: 106: 
107: 107:   bool public mintingFinished = false;
108: 108: 
109: 109:   modifier canMint() {
110: 110:     require(!mintingFinished);
111: 111:     _;
112: 112:   }
113: 113: 
114: 114:   constructor(
115: 115:     address _parentToken,
116: 116:     uint256 _parentSnapShotBlock,
117: 117:     string _tokenVersion,
118: 118:     bool _transfersEnabled) public
119: 119:   {
120: 120:     version = _tokenVersion;
121: 121:     parentToken = SatisfactionToken(_parentToken);
122: 122:     parentSnapShotBlock = _parentSnapShotBlock;
123: 123:     transfersEnabled = _transfersEnabled;
124: 124:     creationBlock = block.number;
125: 125:   }
126: 126: 
127: 127:   
128: 128: 
129: 129: 
130: 130: 
131: 131: 
132: 132: 
133: 133:   function transfer(address _to, uint256 _value) public returns (bool) {
134: 134:     require(transfersEnabled);
135: 135:     require(parentSnapShotBlock < block.number);
136: 136:     require(_to != address(0));
137: 137: 
138: 138:     uint256 lastBalance = balanceOfAt(msg.sender, block.number);
139: 139:     require(_value <= lastBalance);
140: 140: 
141: 141:     return doTransfer(msg.sender, _to, _value, lastBalance);
142: 142:   }
143: 143: 
144: 144:   
145: 145: 
146: 146: 
147: 147: 
148: 148: 
149: 149: 
150: 150: 
151: 151: 
152: 152: 
153: 153: 
154: 154:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
155: 155:     require(_to != address(this));
156: 156: 
157: 157:     transfer(_to, _value);
158: 158: 
159: 159:     
160: 160:     require(_to.call.value(msg.value)(_data));
161: 161:     return true;
162: 162:   }
163: 163: 
164: 164:   
165: 165: 
166: 166: 
167: 167: 
168: 168: 
169: 169: 
170: 170: 
171: 171:   function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
172: 172:     require(transfersEnabled);
173: 173:     require(parentSnapShotBlock < block.number);
174: 174:     require(_to != address(0));
175: 175:     require(_value <= allowed[_from][msg.sender]);
176: 176: 
177: 177:     uint256 lastBalance = balanceOfAt(_from, block.number);
178: 178:     require(_value <= lastBalance);
179: 179: 
180: 180:     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
181: 181: 
182: 182:     return doTransfer(_from, _to, _value, lastBalance);
183: 183:   }
184: 184: 
185: 185:   
186: 186: 
187: 187: 
188: 188: 
189: 189: 
190: 190: 
191: 191: 
192: 192: 
193: 193: 
194: 194: 
195: 195: 
196: 196:   function transferFromAndCall(
197: 197:     address _from,
198: 198:     address _to,
199: 199:     uint256 _value,
200: 200:     bytes _data
201: 201:   )
202: 202:     public payable returns (bool)
203: 203:   {
204: 204:     require(_to != address(this));
205: 205: 
206: 206:     transferFrom(_from, _to, _value);
207: 207: 
208: 208:     
209: 209:     require(_to.call.value(msg.value)(_data));
210: 210:     return true;
211: 211:   }
212: 212: 
213: 213:   
214: 214: 
215: 215: 
216: 216: 
217: 217: 
218: 218: 
219: 219: 
220: 220: 
221: 221: 
222: 222: 
223: 223: 
224: 224:   function approve(address _spender, uint256 _value) public returns (bool) {
225: 225:     allowed[msg.sender][_spender] = _value;
226: 226:     emit Approval(msg.sender, _spender, _value);
227: 227:     return true;
228: 228:   }
229: 229: 
230: 230:   
231: 231: 
232: 232: 
233: 233: 
234: 234: 
235: 235: 
236: 236: 
237: 237:   function allowance(address _owner, address _spender) public view returns (uint256) {
238: 238:     return allowed[_owner][_spender];
239: 239:   }
240: 240: 
241: 241:   
242: 242: 
243: 243: 
244: 244: 
245: 245: 
246: 246: 
247: 247: 
248: 248: 
249: 249: 
250: 250: 
251: 251: 
252: 252:   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
253: 253:     allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
254: 254:     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
255: 255:     return true;
256: 256:   }
257: 257: 
258: 258:   
259: 259: 
260: 260: 
261: 261: 
262: 262: 
263: 263: 
264: 264: 
265: 265: 
266: 266: 
267: 267: 
268: 268: 
269: 269: 
270: 270: 
271: 271:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
272: 272:     require(_spender != address(this));
273: 273: 
274: 274:     increaseApproval(_spender, _addedValue);
275: 275: 
276: 276:     
277: 277:     require(_spender.call.value(msg.value)(_data));
278: 278: 
279: 279:     return true;
280: 280:   }
281: 281: 
282: 282:   
283: 283: 
284: 284: 
285: 285: 
286: 286: 
287: 287: 
288: 288: 
289: 289: 
290: 290: 
291: 291: 
292: 292: 
293: 293:   function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
294: 294:     uint oldValue = allowed[msg.sender][_spender];
295: 295:     if (_subtractedValue > oldValue) {
296: 296:       allowed[msg.sender][_spender] = 0;
297: 297:     } else {
298: 298:       allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
299: 299:     }
300: 300:     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
301: 301:     return true;
302: 302:   }
303: 303: 
304: 304:   
305: 305: 
306: 306: 
307: 307: 
308: 308: 
309: 309: 
310: 310: 
311: 311: 
312: 312: 
313: 313: 
314: 314: 
315: 315: 
316: 316: 
317: 317:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
318: 318:     require(_spender != address(this));
319: 319: 
320: 320:     decreaseApproval(_spender, _subtractedValue);
321: 321: 
322: 322:     
323: 323:     require(_spender.call.value(msg.value)(_data));
324: 324: 
325: 325:     return true;
326: 326:   }
327: 327: 
328: 328:   
329: 329: 
330: 330: 
331: 331: 
332: 332:   function balanceOf(address _owner) public view returns (uint256) {
333: 333:     return balanceOfAt(_owner, block.number);
334: 334:   }
335: 335: 
336: 336:   
337: 337: 
338: 338: 
339: 339: 
340: 340: 
341: 341: 
342: 342: 
343: 343:   function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256) {
344: 344:     
345: 345:     
346: 346:     
347: 347:     
348: 348:     
349: 349:     if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
350: 350:       if (address(parentToken) != address(0)) {
351: 351:         return parentToken.balanceOfAt(_owner, Math.min256(_blockNumber, parentSnapShotBlock));
352: 352:       } else {
353: 353:         
354: 354:         return 0;
355: 355:       }
356: 356:     
357: 357:     } else {
358: 358:       return getValueAt(balances[_owner], _blockNumber);
359: 359:     }
360: 360:   }
361: 361: 
362: 362:   
363: 363: 
364: 364: 
365: 365: 
366: 366: 
367: 367:   function totalSupply() public view returns (uint256) {
368: 368:     return totalSupplyAt(block.number);
369: 369:   }
370: 370: 
371: 371:   
372: 372: 
373: 373: 
374: 374: 
375: 375: 
376: 376: 
377: 377:   function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {
378: 378: 
379: 379:     
380: 380:     
381: 381:     
382: 382:     
383: 383:     
384: 384:     if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
385: 385:       if (address(parentToken) != 0) {
386: 386:         return parentToken.totalSupplyAt(Math.min256(_blockNumber, parentSnapShotBlock));
387: 387:       } else {
388: 388:         return 0;
389: 389:       }
390: 390:     
391: 391:     } else {
392: 392:       return getValueAt(totalSupplyHistory, _blockNumber);
393: 393:     }
394: 394:   }
395: 395: 
396: 396:   
397: 397: 
398: 398: 
399: 399: 
400: 400: 
401: 401: 
402: 402: 
403: 403:   function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
404: 404:     uint256 curTotalSupply = totalSupply();
405: 405:     uint256 lastBalance = balanceOf(_to);
406: 406: 
407: 407:     updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_amount));
408: 408:     updateValueAtNow(balances[_to], lastBalance.add(_amount));
409: 409: 
410: 410:     emit Mint(_to, _amount);
411: 411:     emit Transfer(address(0), _to, _amount);
412: 412:     return true;
413: 413:   }
414: 414: 
415: 415:   
416: 416: 
417: 417: 
418: 418: 
419: 419: 
420: 420:   function finishMinting() public onlyOwner canMint returns (bool) {
421: 421:     mintingFinished = true;
422: 422:     emit MintFinished();
423: 423:     return true;
424: 424:   }
425: 425: 
426: 426:   
427: 427: 
428: 428: 
429: 429: 
430: 430: 
431: 431:   function burn(uint256 _value) public {
432: 432:     uint256 lastBalance = balanceOf(msg.sender);
433: 433:     require(_value <= lastBalance);
434: 434: 
435: 435:     address burner = msg.sender;
436: 436:     uint256 curTotalSupply = totalSupply();
437: 437: 
438: 438:     updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));
439: 439:     updateValueAtNow(balances[burner], lastBalance.sub(_value));
440: 440: 
441: 441:     emit Burn(burner, _value);
442: 442:   }
443: 443: 
444: 444:   
445: 445: 
446: 446: 
447: 447: 
448: 448: 
449: 449: 
450: 450:   function burnFrom(address _from, uint256 _value) public {
451: 451:     require(_value <= allowed[_from][msg.sender]);
452: 452: 
453: 453:     uint256 lastBalance = balanceOfAt(_from, block.number);
454: 454:     require(_value <= lastBalance);
455: 455: 
456: 456:     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
457: 457: 
458: 458:     address burner = _from;
459: 459:     uint256 curTotalSupply = totalSupply();
460: 460: 
461: 461:     updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));
462: 462:     updateValueAtNow(balances[burner], lastBalance.sub(_value));
463: 463: 
464: 464:     emit Burn(burner, _value);
465: 465:   }
466: 466: 
467: 467:   
468: 468: 
469: 469: 
470: 470: 
471: 471: 
472: 472:   function enableTransfers(bool _transfersEnabled) public onlyOwner canMint {
473: 473:     transfersEnabled = _transfersEnabled;
474: 474:   }
475: 475: 
476: 476:   
477: 477: 
478: 478: 
479: 479: 
480: 480: 
481: 481: 
482: 482: 
483: 483: 
484: 484: 
485: 485: 
486: 486:   function doTransfer(address _from, address _to, uint256 _value, uint256 _lastBalance) internal returns (bool) {
487: 487:     if (_value == 0) {
488: 488:       return true;
489: 489:     }
490: 490: 
491: 491:     updateValueAtNow(balances[_from], _lastBalance.sub(_value));
492: 492: 
493: 493:     uint256 previousBalance = balanceOfAt(_to, block.number);
494: 494:     updateValueAtNow(balances[_to], previousBalance.add(_value));
495: 495: 
496: 496:     emit Transfer(_from, _to, _value);
497: 497:     return true;
498: 498:   }
499: 499: }