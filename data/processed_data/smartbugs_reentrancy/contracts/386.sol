1: pragma solidity ^0.4.23;
2: 
3: library Math {
4:   function max64(uint64 a, uint64 b) internal pure returns (uint64) {
5:     return a >= b ? a : b;
6:   }
7: 
8:   function min64(uint64 a, uint64 b) internal pure returns (uint64) {
9:     return a < b ? a : b;
10:   }
11: 
12:   function max256(uint256 a, uint256 b) internal pure returns (uint256) {
13:     return a >= b ? a : b;
14:   }
15: 
16:   function min256(uint256 a, uint256 b) internal pure returns (uint256) {
17:     return a < b ? a : b;
18:   }
19: }
20: 
21: library SafeMath {
22: 
23:   
24: 
25: 
26:   function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
27:     if (a == 0) {
28:       return 0;
29:     }
30:     c = a * b;
31:     assert(c / a == b);
32:     return c;
33:   }
34: 
35:   
36: 
37: 
38:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
39:     
40:     
41:     
42:     return a / b;
43:   }
44: 
45:   
46: 
47: 
48:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
49:     assert(b <= a);
50:     return a - b;
51:   }
52: 
53:   
54: 
55: 
56:   function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
57:     c = a + b;
58:     assert(c >= a);
59:     return c;
60:   }
61: }
62: 
63: contract SatisfactionToken is ERC20, CheckpointStorage, NoOwner {
64: 
65:   event Transfer(address indexed from, address indexed to, uint256 value);
66:   event Approval(address indexed owner, address indexed spender, uint256 value);
67: 
68:   event Mint(address indexed to, uint256 amount);
69:   event MintFinished();
70:   event Burn(address indexed burner, uint256 value);
71: 
72:   using SafeMath for uint256;
73: 
74:   string public name = "Satisfaction Token";
75:   uint8 public decimals = 18;
76:   string public symbol = "SAT";
77:   string public version;
78: 
79:   
80: 
81: 
82: 
83:   SatisfactionToken public parentToken;
84: 
85:   
86: 
87: 
88: 
89:   uint256 public parentSnapShotBlock;
90: 
91:   
92:   uint256 public creationBlock;
93: 
94:   
95: 
96: 
97: 
98: 
99:   mapping(address => Checkpoint[]) internal balances;
100: 
101:   
102:   mapping(address => mapping(address => uint256)) internal allowed;
103: 
104:   
105:   bool public transfersEnabled;
106: 
107:   bool public mintingFinished = false;
108: 
109:   modifier canMint() {
110:     require(!mintingFinished);
111:     _;
112:   }
113: 
114:   constructor(
115:     address _parentToken,
116:     uint256 _parentSnapShotBlock,
117:     string _tokenVersion,
118:     bool _transfersEnabled) public
119:   {
120:     version = _tokenVersion;
121:     parentToken = SatisfactionToken(_parentToken);
122:     parentSnapShotBlock = _parentSnapShotBlock;
123:     transfersEnabled = _transfersEnabled;
124:     creationBlock = block.number;
125:   }
126: 
127:   
128: 
129: 
130: 
131: 
132: 
133:   function transfer(address _to, uint256 _value) public returns (bool) {
134:     require(transfersEnabled);
135:     require(parentSnapShotBlock < block.number);
136:     require(_to != address(0));
137: 
138:     uint256 lastBalance = balanceOfAt(msg.sender, block.number);
139:     require(_value <= lastBalance);
140: 
141:     return doTransfer(msg.sender, _to, _value, lastBalance);
142:   }
143: 
144:   
145: 
146: 
147: 
148: 
149: 
150: 
151: 
152: 
153: 
154:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
155:     require(_to != address(this));
156: 
157:     transfer(_to, _value);
158: 
159:     
160:     require(_to.call.value(msg.value)(_data));
161:     return true;
162:   }
163: 
164:   
165: 
166: 
167: 
168: 
169: 
170: 
171:   function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
172:     require(transfersEnabled);
173:     require(parentSnapShotBlock < block.number);
174:     require(_to != address(0));
175:     require(_value <= allowed[_from][msg.sender]);
176: 
177:     uint256 lastBalance = balanceOfAt(_from, block.number);
178:     require(_value <= lastBalance);
179: 
180:     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
181: 
182:     return doTransfer(_from, _to, _value, lastBalance);
183:   }
184: 
185:   
186: 
187: 
188: 
189: 
190: 
191: 
192: 
193: 
194: 
195: 
196:   function transferFromAndCall(
197:     address _from,
198:     address _to,
199:     uint256 _value,
200:     bytes _data
201:   )
202:     public payable returns (bool)
203:   {
204:     require(_to != address(this));
205: 
206:     transferFrom(_from, _to, _value);
207: 
208:     
209:     require(_to.call.value(msg.value)(_data));
210:     return true;
211:   }
212: 
213:   
214: 
215: 
216: 
217: 
218: 
219: 
220: 
221: 
222: 
223: 
224:   function approve(address _spender, uint256 _value) public returns (bool) {
225:     allowed[msg.sender][_spender] = _value;
226:     emit Approval(msg.sender, _spender, _value);
227:     return true;
228:   }
229: 
230:   
231: 
232: 
233: 
234: 
235: 
236: 
237:   function allowance(address _owner, address _spender) public view returns (uint256) {
238:     return allowed[_owner][_spender];
239:   }
240: 
241:   
242: 
243: 
244: 
245: 
246: 
247: 
248: 
249: 
250: 
251: 
252:   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
253:     allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
254:     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
255:     return true;
256:   }
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
267: 
268: 
269: 
270: 
271:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
272:     require(_spender != address(this));
273: 
274:     increaseApproval(_spender, _addedValue);
275: 
276:     
277:     require(_spender.call.value(msg.value)(_data));
278: 
279:     return true;
280:   }
281: 
282:   
283: 
284: 
285: 
286: 
287: 
288: 
289: 
290: 
291: 
292: 
293:   function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
294:     uint oldValue = allowed[msg.sender][_spender];
295:     if (_subtractedValue > oldValue) {
296:       allowed[msg.sender][_spender] = 0;
297:     } else {
298:       allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
299:     }
300:     emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
301:     return true;
302:   }
303: 
304:   
305: 
306: 
307: 
308: 
309: 
310: 
311: 
312: 
313: 
314: 
315: 
316: 
317:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
318:     require(_spender != address(this));
319: 
320:     decreaseApproval(_spender, _subtractedValue);
321: 
322:     
323:     require(_spender.call.value(msg.value)(_data));
324: 
325:     return true;
326:   }
327: 
328:   
329: 
330: 
331: 
332:   function balanceOf(address _owner) public view returns (uint256) {
333:     return balanceOfAt(_owner, block.number);
334:   }
335: 
336:   
337: 
338: 
339: 
340: 
341: 
342: 
343:   function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256) {
344:     
345:     
346:     
347:     
348:     
349:     if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
350:       if (address(parentToken) != address(0)) {
351:         return parentToken.balanceOfAt(_owner, Math.min256(_blockNumber, parentSnapShotBlock));
352:       } else {
353:         
354:         return 0;
355:       }
356:     
357:     } else {
358:       return getValueAt(balances[_owner], _blockNumber);
359:     }
360:   }
361: 
362:   
363: 
364: 
365: 
366: 
367:   function totalSupply() public view returns (uint256) {
368:     return totalSupplyAt(block.number);
369:   }
370: 
371:   
372: 
373: 
374: 
375: 
376: 
377:   function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {
378: 
379:     
380:     
381:     
382:     
383:     
384:     if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
385:       if (address(parentToken) != 0) {
386:         return parentToken.totalSupplyAt(Math.min256(_blockNumber, parentSnapShotBlock));
387:       } else {
388:         return 0;
389:       }
390:     
391:     } else {
392:       return getValueAt(totalSupplyHistory, _blockNumber);
393:     }
394:   }
395: 
396:   
397: 
398: 
399: 
400: 
401: 
402: 
403:   function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
404:     uint256 curTotalSupply = totalSupply();
405:     uint256 lastBalance = balanceOf(_to);
406: 
407:     updateValueAtNow(totalSupplyHistory, curTotalSupply.add(_amount));
408:     updateValueAtNow(balances[_to], lastBalance.add(_amount));
409: 
410:     emit Mint(_to, _amount);
411:     emit Transfer(address(0), _to, _amount);
412:     return true;
413:   }
414: 
415:   
416: 
417: 
418: 
419: 
420:   function finishMinting() public onlyOwner canMint returns (bool) {
421:     mintingFinished = true;
422:     emit MintFinished();
423:     return true;
424:   }
425: 
426:   
427: 
428: 
429: 
430: 
431:   function burn(uint256 _value) public {
432:     uint256 lastBalance = balanceOf(msg.sender);
433:     require(_value <= lastBalance);
434: 
435:     address burner = msg.sender;
436:     uint256 curTotalSupply = totalSupply();
437: 
438:     updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));
439:     updateValueAtNow(balances[burner], lastBalance.sub(_value));
440: 
441:     emit Burn(burner, _value);
442:   }
443: 
444:   
445: 
446: 
447: 
448: 
449: 
450:   function burnFrom(address _from, uint256 _value) public {
451:     require(_value <= allowed[_from][msg.sender]);
452: 
453:     uint256 lastBalance = balanceOfAt(_from, block.number);
454:     require(_value <= lastBalance);
455: 
456:     allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
457: 
458:     address burner = _from;
459:     uint256 curTotalSupply = totalSupply();
460: 
461:     updateValueAtNow(totalSupplyHistory, curTotalSupply.sub(_value));
462:     updateValueAtNow(balances[burner], lastBalance.sub(_value));
463: 
464:     emit Burn(burner, _value);
465:   }
466: 
467:   
468: 
469: 
470: 
471: 
472:   function enableTransfers(bool _transfersEnabled) public onlyOwner canMint {
473:     transfersEnabled = _transfersEnabled;
474:   }
475: 
476:   
477: 
478: 
479: 
480: 
481: 
482: 
483: 
484: 
485: 
486:   function doTransfer(address _from, address _to, uint256 _value, uint256 _lastBalance) internal returns (bool) {
487:     if (_value == 0) {
488:       return true;
489:     }
490: 
491:     updateValueAtNow(balances[_from], _lastBalance.sub(_value));
492: 
493:     uint256 previousBalance = balanceOfAt(_to, block.number);
494:     updateValueAtNow(balances[_to], previousBalance.add(_value));
495: 
496:     emit Transfer(_from, _to, _value);
497:     return true;
498:   }
499: }