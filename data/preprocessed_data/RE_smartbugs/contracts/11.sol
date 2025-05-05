1: pragma solidity ^0.4.25;
2: 
3: 
4: 
5: 
6: 
7: interface IERC20 {
8:     function totalSupply() external view returns (uint256);
9: 
10:     function balanceOf(address who) external view returns (uint256);
11: 
12:     function allowance(address owner, address spender)
13:     external view returns (uint256);
14: 
15:     function transfer(address to, uint256 value) external returns (bool);
16: 
17:     function approve(address spender, uint256 value)
18:     external returns (bool);
19: 
20:     function transferFrom(address from, address to, uint256 value)
21:     external returns (bool);
22: 
23:     event Transfer(
24:         address indexed from,
25:         address indexed to,
26:         uint256 value
27:     );
28: 
29:     event Approval(
30:         address indexed owner,
31:         address indexed spender,
32:         uint256 value
33:     );
34: }
35: 
36: 
37: 
38: 
39: 
40: library SafeMath {
41: 
42:     
43: 
44: 
45:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
46:         
47:         
48:         
49:         if (a == 0) {
50:             return 0;
51:         }
52: 
53:         uint256 c = a * b;
54:         require(c / a == b);
55: 
56:         return c;
57:     }
58: 
59:     
60: 
61: 
62:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
63:         require(b > 0);
64:         
65:         uint256 c = a / b;
66:         
67: 
68:         return c;
69:     }
70: 
71:     
72: 
73: 
74:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
75:         require(b <= a);
76:         uint256 c = a - b;
77: 
78:         return c;
79:     }
80: 
81:     
82: 
83: 
84:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
85:         uint256 c = a + b;
86:         require(c >= a);
87: 
88:         return c;
89:     }
90: 
91:     
92: 
93: 
94: 
95:     function mod(uint256 a, uint256 b) internal pure returns (uint256) {
96:         require(b != 0);
97:         return a % b;
98:     }
99: }
100: 
101: 
102: 
103: 
104: 
105: contract SEEDDEX {
106: 
107:     
108:     address public admin; 
109:     address constant public FicAddress = 0x0DD83B5013b2ad7094b1A7783d96ae0168f82621;  
110:     address public manager; 
111:     address public feeAccount; 
112:     uint public feeTakeMaker; 
113:     uint public feeTakeSender; 
114:     uint public feeTakeMakerFic;
115:     uint public feeTakeSenderFic;
116:     bool private depositingTokenFlag; 
117:     mapping(address => mapping(address => uint)) public tokens; 
118:     mapping(address => mapping(bytes32 => bool)) public orders; 
119:     mapping(address => mapping(bytes32 => uint)) public orderFills; 
120:     address public predecessor; 
121:     address public successor; 
122:     uint16 public version; 
123: 
124:     
125:     event Order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address indexed user, bytes32 hash, uint amount);
126:     event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address indexed user, uint8 v, bytes32 r, bytes32 s);
127:     event Trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address get, address give, uint256 timestamp);
128:     event Deposit(address token, address indexed user, uint amount, uint balance);
129:     event Withdraw(address token, address indexed user, uint amount, uint balance);
130:     event FundsMigrated(address indexed user, address newContract);
131: 
132:     
133:     modifier isAdmin() {
134:         require(msg.sender == admin);
135:         _;
136:     }
137: 
138:     
139:     modifier isManager() {
140:         require(msg.sender == manager || msg.sender == admin);
141:         _;
142:     }
143: 
144:     
145:     function SEEDDEX(address admin_, address manager_, address feeAccount_, uint feeTakeMaker_, uint feeTakeSender_, uint feeTakeMakerFic_, uint feeTakeSenderFic_, address predecessor_) public {
146:         admin = admin_;
147:         manager = manager_;
148:         feeAccount = feeAccount_;
149:         feeTakeMaker = feeTakeMaker_;
150:         feeTakeSender = feeTakeSender_;
151:         feeTakeMakerFic = feeTakeMakerFic_;
152:         feeTakeSenderFic = feeTakeSenderFic_;
153:         depositingTokenFlag = false;
154:         predecessor = predecessor_;
155: 
156:         if (predecessor != address(0)) {
157:             version = SEEDDEX(predecessor).version() + 1;
158:         } else {
159:             version = 1;
160:         }
161:     }
162: 
163:     
164:     function() public {
165:         revert();
166:     }
167: 
168:     
169:     function changeAdmin(address admin_) public isAdmin {
170:         require(admin_ != address(0));
171:         admin = admin_;
172:     }
173: 
174:     
175:     function changeManager(address manager_) public isManager {
176:         require(manager_ != address(0));
177:         manager = manager_;
178:     }
179: 
180:     
181:     function changeFeeAccount(address feeAccount_) public isAdmin {
182:         feeAccount = feeAccount_;
183:     }
184: 
185:     
186:     function changeFeeTakeMaker(uint feeTakeMaker_) public isManager {
187:         feeTakeMaker = feeTakeMaker_;
188:     }
189: 
190:     function changeFeeTakeSender(uint feeTakeSender_) public isManager {
191:         feeTakeSender = feeTakeSender_;
192:     }
193: 
194:     function changeFeeTakeMakerFic(uint feeTakeMakerFic_) public isManager {
195:         feeTakeMakerFic = feeTakeMakerFic_;
196:     }
197: 
198:     function changeFeeTakeSenderFic(uint feeTakeSenderFic_) public isManager {
199:         feeTakeSenderFic = feeTakeSenderFic_;
200:     }
201: 
202:     
203:     function setSuccessor(address successor_) public isAdmin {
204:         require(successor_ != address(0));
205:         successor = successor_;
206:     }
207: 
208:     
209:     
210:     
211: 
212:     
213: 
214: 
215: 
216: 
217:     function deposit() public payable {
218:         tokens[0][msg.sender] = SafeMath.add(tokens[0][msg.sender], msg.value);
219:         Deposit(0, msg.sender, msg.value, tokens[0][msg.sender]);
220:     }
221: 
222:     
223: 
224: 
225: 
226: 
227: 
228:     function withdraw(uint amount) {
229:         if (tokens[0][msg.sender] < amount) throw;
230:         tokens[0][msg.sender] = SafeMath.sub(tokens[0][msg.sender], amount);
231:         if (!msg.sender.call.value(amount)()) throw;
232:         Withdraw(0, msg.sender, amount, tokens[0][msg.sender]);
233:     }
234: 
235:     
236: 
237: 
238: 
239: 
240: 
241: 
242: 
243: 
244:     function depositToken(address token, uint amount) {
245:         
246:         if (token == 0) throw;
247:         if (!IERC20(token).transferFrom(msg.sender, this, amount)) throw;
248:         tokens[token][msg.sender] = SafeMath.add(tokens[token][msg.sender], amount);
249:         Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
250:     }
251: 
252:     
253: 
254: 
255: 
256: 
257: 
258: 
259: 
260:     function tokenFallback(address sender, uint amount, bytes data) public returns (bool ok) {
261:         if (depositingTokenFlag) {
262:             
263:             return true;
264:         } else {
265:             
266:             
267:             revert();
268:         }
269:     }
270: 
271:     
272: 
273: 
274: 
275: 
276: 
277: 
278: 
279:     function withdrawToken(address token, uint amount) {
280:         if (token == 0) throw;
281:         if (tokens[token][msg.sender] < amount) throw;
282:         tokens[token][msg.sender] = SafeMath.sub(tokens[token][msg.sender], amount);
283:         if (!IERC20(token).transfer(msg.sender, amount)) throw;
284:         Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
285:     }
286: 
287:     
288: 
289: 
290: 
291: 
292: 
293:     function balanceOf(address token, address user) public constant returns (uint) {
294:         return tokens[token][user];
295:     }
296: 
297:     
298:     
299:     
300: 
301:     
302: 
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
314:     function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public {
315:         bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
316:         uint amount;
317:         orders[msg.sender][hash] = true;
318:         Order(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, hash, amount);
319:     }
320: 
321:     
322: 
323: 
324: 
325: 
326: 
327: 
328: 
329: 
330: 
331: 
332: 
333: 
334: 
335: 
336: 
337: 
338: 
339: 
340: 
341:     function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {
342:         bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
343:         require((
344:             (orders[user][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user) &&
345:             block.number <= expires &&
346:             SafeMath.add(orderFills[user][hash], amount) <= amountGet
347:             ));
348:         tradeBalances(tokenGet, amountGet, tokenGive, amountGive, user, amount);
349:         orderFills[user][hash] = SafeMath.add(orderFills[user][hash], amount);
350:         Trade(tokenGet, amount, tokenGive, amountGive * amount / amountGet, user, msg.sender, now);
351:     }
352: 
353:     
354: 
355: 
356: 
357: 
358: 
359: 
360: 
361: 
362: 
363: 
364: 
365: 
366: 
367:     function tradeBalances(address tokenGet, uint amountGet, address tokenGive, uint amountGive, address user, uint amount) private {
368:         if (tokenGet == FicAddress || tokenGive == FicAddress) {
369:             tokens[tokenGet][msg.sender] = SafeMath.sub(tokens[tokenGet][msg.sender], amount);
370:             tokens[tokenGet][user] = SafeMath.add(tokens[tokenGet][user], SafeMath.mul(amount, ((1 ether) - feeTakeMakerFic)) / (1 ether));
371:             tokens[tokenGet][feeAccount] = SafeMath.add(tokens[tokenGet][feeAccount], SafeMath.mul(amount, feeTakeMakerFic) / (1 ether));
372:             tokens[tokenGive][user] = SafeMath.sub(tokens[tokenGive][user], SafeMath.mul(amountGive, amount) / amountGet);
373:             tokens[tokenGive][msg.sender] = SafeMath.add(tokens[tokenGive][msg.sender], SafeMath.mul(SafeMath.mul(((1 ether) - feeTakeSenderFic), amountGive), amount) / amountGet / (1 ether));
374:             tokens[tokenGive][feeAccount] = SafeMath.add(tokens[tokenGive][feeAccount], SafeMath.mul(SafeMath.mul(feeTakeSenderFic, amountGive), amount) / amountGet / (1 ether));
375:         }
376:         else {
377:             tokens[tokenGet][msg.sender] = SafeMath.sub(tokens[tokenGet][msg.sender], amount);
378:             tokens[tokenGet][user] = SafeMath.add(tokens[tokenGet][user], SafeMath.mul(amount, ((1 ether) - feeTakeMaker)) / (1 ether));
379:             tokens[tokenGet][feeAccount] = SafeMath.add(tokens[tokenGet][feeAccount], SafeMath.mul(amount, feeTakeMaker) / (1 ether));
380:             tokens[tokenGive][user] = SafeMath.sub(tokens[tokenGive][user], SafeMath.mul(amountGive, amount) / amountGet);
381:             tokens[tokenGive][msg.sender] = SafeMath.add(tokens[tokenGive][msg.sender], SafeMath.mul(SafeMath.mul(((1 ether) - feeTakeSender), amountGive), amount) / amountGet / (1 ether));
382:             tokens[tokenGive][feeAccount] = SafeMath.add(tokens[tokenGive][feeAccount], SafeMath.mul(SafeMath.mul(feeTakeSender, amountGive), amount) / amountGet / (1 ether));
383:         }
384:     }
385: 
386:     
387: 
388: 
389: 
390: 
391: 
392: 
393: 
394: 
395: 
396: 
397: 
398: 
399: 
400: 
401: 
402: 
403: 
404:     function testTrade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount, address sender) public constant returns (bool) {
405:         if (!(
406:         tokens[tokenGet][sender] >= amount &&
407:         availableVolume(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, user, v, r, s) >= amount
408:         )) {
409:             return false;
410:         } else {
411:             return true;
412:         }
413:     }
414: 
415:     
416: 
417: 
418: 
419: 
420: 
421: 
422: 
423: 
424: 
425: 
426: 
427: 
428: 
429: 
430:     function availableVolume(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public constant returns (uint) {
431:         bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
432:         if (!(
433:         (orders[user][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == user) &&
434:         block.number <= expires
435:         )) {
436:             return 0;
437:         }
438:         uint[2] memory available;
439:         available[0] = SafeMath.sub(amountGet, orderFills[user][hash]);
440:         available[1] = SafeMath.mul(tokens[tokenGive][user], amountGet) / amountGive;
441:         if (available[0] < available[1]) {
442:             return available[0];
443:         } else {
444:             return available[1];
445:         }
446:     }
447: 
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
463:     function amountFilled(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s) public constant returns (uint) {
464:         bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
465:         return orderFills[user][hash];
466:     }
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
479: 
480: 
481: 
482: 
483: 
484: 
485:     function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public {
486:         bytes32 hash = keccak256(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce);
487:         require((orders[msg.sender][hash] || ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) == msg.sender));
488:         orderFills[msg.sender][hash] = amountGet;
489:         Cancel(tokenGet, amountGet, tokenGive, amountGive, expires, nonce, msg.sender, v, r, s);
490:     }
491: 
492: 
493: 
494:     
495:     
496:     
497: 
498:     
499: 
500: 
501: 
502: 
503: 
504:     function migrateFunds(address newContract, address[] tokens_) public {
505: 
506:         require(newContract != address(0));
507: 
508:         SEEDDEX newExchange = SEEDDEX(newContract);
509: 
510:         
511:         uint etherAmount = tokens[0][msg.sender];
512:         if (etherAmount > 0) {
513:             tokens[0][msg.sender] = 0;
514:             newExchange.depositForUser.value(etherAmount)(msg.sender);
515:         }
516: 
517:         
518:         for (uint16 n = 0; n < tokens_.length; n++) {
519:             address token = tokens_[n];
520:             require(token != address(0));
521:             
522:             uint tokenAmount = tokens[token][msg.sender];
523: 
524:             if (tokenAmount != 0) {
525:                 if (!IERC20(token).approve(newExchange, tokenAmount)) throw;
526:                 tokens[token][msg.sender] = 0;
527:                 newExchange.depositTokenForUser(token, tokenAmount, msg.sender);
528:             }
529:         }
530: 
531:         FundsMigrated(msg.sender, newContract);
532:     }
533: 
534: 
535:     
536: 
537: 
538: 
539: 
540:     function depositForUser(address user) public payable {
541:         require(user != address(0));
542:         require(msg.value > 0);
543:         tokens[0][user] = SafeMath.add(tokens[0][user], (msg.value));
544:     }
545: 
546:     
547: 
548: 
549: 
550: 
551: 
552: 
553: 
554: 
555:     function depositTokenForUser(address token, uint amount, address user) public {
556:         require(token != address(0));
557:         require(user != address(0));
558:         require(amount > 0);
559:         depositingTokenFlag = true;
560:         if (!IERC20(token).transferFrom(msg.sender, this, amount)) throw;
561:         depositingTokenFlag = false;
562:         tokens[token][user] = SafeMath.add(tokens[token][user], (amount));
563:     }
564: }