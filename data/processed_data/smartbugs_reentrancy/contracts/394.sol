1: pragma solidity >=0.4.4;
2: 
3: contract ICO is EventDefinitions, Testable, SafeMath, Owned {
4:     Token public token;
5:     address public controller;
6:     address public payee;
7: 
8:     Sale[] public sales;
9:     
10:     
11:     mapping (uint => uint) saleMinimumPurchases;
12: 
13:     
14:     mapping (address => uint) public nextClaim;
15: 
16:     
17:     mapping (address => uint) refundInStop;
18: 
19:     modifier tokenIsSet() {
20:         if (address(token) == 0) throw;
21:         _;
22:     }
23: 
24:     modifier onlyController() {
25:         if (msg.sender != address(controller)) throw;
26:         _;
27:     }
28: 
29:     function ICO() { 
30:         owner = msg.sender;
31:         payee = msg.sender;
32:         allStopper = msg.sender;
33:     }
34: 
35:     
36:     
37:     
38:     
39:     function changePayee(address newPayee) 
40:     onlyOwner notAllStopped {
41:         payee = newPayee;
42:     }
43: 
44:     function setToken(address _token) onlyOwner {
45:         if (address(token) != 0x0) throw;
46:         token = Token(_token);
47:     }
48: 
49:     
50:     
51:     function setAsTest() onlyOwner {
52:         if (sales.length == 0) {
53:             testing = true;
54:         }
55:     }
56: 
57:     function setController(address _controller) 
58:     onlyOwner notAllStopped {
59:         if (address(controller) != 0x0) throw;
60:         controller = _controller; 
61:     }
62: 
63:     
64:     
65:     
66: 
67:     function addSale(address sale, uint minimumPurchase) 
68:     onlyController notAllStopped {
69:         uint salenum = sales.length;
70:         sales.push(Sale(sale));
71:         saleMinimumPurchases[salenum] = minimumPurchase;
72:         logSaleStart(Sale(sale).startTime(), Sale(sale).stopTime());
73:     }
74: 
75:     function addSale(address sale) onlyController {
76:         addSale(sale, 0);
77:     }
78: 
79:     function getCurrSale() constant returns (uint) {
80:         if (sales.length == 0) throw; 
81:         return sales.length - 1;
82:     }
83: 
84:     function currSaleActive() constant returns (bool) {
85:         return sales[getCurrSale()].isActive(currTime());
86:     }
87: 
88:     function currSaleComplete() constant returns (bool) {
89:         return sales[getCurrSale()].isComplete(currTime());
90:     }
91: 
92:     function numSales() constant returns (uint) {
93:         return sales.length;
94:     }
95: 
96:     function numContributors(uint salenum) constant returns (uint) {
97:         return sales[salenum].numContributors();
98:     }
99: 
100:     
101:     
102:     
103: 
104:     event logPurchase(address indexed purchaser, uint value);
105: 
106:     function () payable {
107:         deposit();
108:     }
109: 
110:     function deposit() payable notAllStopped {
111:         doDeposit(msg.sender, msg.value);
112: 
113:         
114:         uint contrib = refundInStop[msg.sender];
115:         refundInStop[msg.sender] = contrib + msg.value;
116: 
117:         logPurchase(msg.sender, msg.value);
118:     }
119: 
120:     
121:     function doDeposit(address _for, uint _value) private {
122:         uint currSale = getCurrSale();
123:         if (!currSaleActive()) throw;
124:         if (_value < saleMinimumPurchases[currSale]) throw;
125: 
126:         uint tokensToMintNow = sales[currSale].buyTokens(_for, _value, currTime());
127: 
128:         if (tokensToMintNow > 0) {
129:             token.mint(_for, tokensToMintNow);
130:         }
131:     }
132: 
133:     
134:     
135:     
136: 
137:     
138:     
139:     
140:     
141:     
142:     
143: 
144:     event logPurchaseViaToken(
145:                         address indexed purchaser, address indexed token, 
146:                         uint depositedTokens, uint ethValue, 
147:                         bytes32 _reference);
148: 
149:     event logPurchaseViaFiat(
150:                         address indexed purchaser, uint ethValue, 
151:                         bytes32 _reference);
152: 
153:     mapping (bytes32 => bool) public mintRefs;
154:     mapping (address => uint) public raisedFromToken;
155:     uint public raisedFromFiat;
156: 
157:     function depositFiat(address _for, uint _ethValue, bytes32 _reference) 
158:     notAllStopped onlyOwner {
159:         if (getCurrSale() > 0) throw; 
160:         if (mintRefs[_reference]) throw; 
161:         mintRefs[_reference] = true;
162:         raisedFromFiat = safeAdd(raisedFromFiat, _ethValue);
163: 
164:         doDeposit(_for, _ethValue);
165:         logPurchaseViaFiat(_for, _ethValue, _reference);
166:     }
167: 
168:     function depositTokens(address _for, address _token, 
169:                            uint _ethValue, uint _depositedTokens, 
170:                            bytes32 _reference) 
171:     notAllStopped onlyOwner {
172:         if (getCurrSale() > 0) throw; 
173:         if (mintRefs[_reference]) throw; 
174:         mintRefs[_reference] = true;
175:         raisedFromToken[_token] = safeAdd(raisedFromToken[_token], _ethValue);
176: 
177:         
178:         
179:         uint tokensPerEth = sales[0].tokensPerEth();
180:         uint tkn = safeMul(_ethValue, tokensPerEth) / weiPerEth();
181:         token.mint(_for, tkn);
182:         
183:         logPurchaseViaToken(_for, _token, _depositedTokens, _ethValue, _reference);
184:     }
185: 
186:     
187:     
188:     
189:     
190:     
191:     function safebalance(uint bal) private returns (uint) {
192:         if (bal > this.balance) {
193:             return this.balance;
194:         } else {
195:             return bal;
196:         }
197:     }
198: 
199:     
200:     
201:     
202:     
203: 
204:     uint public topUpAmount;
205: 
206:     function topUp() payable onlyOwner notAllStopped {
207:         topUpAmount = safeAdd(topUpAmount, msg.value);
208:     }
209: 
210:     function withdrawTopUp() onlyOwner notAllStopped {
211:         uint amount = topUpAmount;
212:         topUpAmount = 0;
213:         if (!msg.sender.call.value(safebalance(amount))()) throw;
214:     }
215: 
216:     
217:     
218:     
219: 
220:     
221:     
222:     
223:     
224:     function claim() notAllStopped {
225:         var (tokens, refund, nc) = claimable(msg.sender, true);
226:         nextClaim[msg.sender] = nc;
227:         logClaim(msg.sender, refund, tokens);
228:         if (tokens > 0) {
229:             token.mint(msg.sender, tokens);
230:         }
231:         if (refund > 0) {
232:             refundInStop[msg.sender] = safeSub(refundInStop[msg.sender], refund);
233:             if (!msg.sender.send(safebalance(refund))) throw;
234:         }
235:     }
236: 
237:     
238:     
239:     
240:     
241:     
242:     
243:     
244:     function claimFor(address _from, address _to) 
245:     onlyOwner notAllStopped {
246:         var (tokens, refund, nc) = claimable(_from, false);
247:         nextClaim[_from] = nc;
248: 
249:         logClaim(_from, refund, tokens);
250: 
251:         if (tokens > 0) {
252:             token.mint(_to, tokens);
253:         }
254:         if (refund > 0) {
255:             refundInStop[_from] = safeSub(refundInStop[_from], refund);
256:             if (!_to.send(safebalance(refund))) throw;
257:         }
258:     }
259: 
260:     function claimable(address _a, bool _includeRecent) 
261:     constant private tokenIsSet 
262:     returns (uint tokens, uint refund, uint nc) {
263:         nc = nextClaim[_a];
264: 
265:         while (nc < sales.length &&
266:                sales[nc].isComplete(currTime()) &&
267:                ( _includeRecent || 
268:                  sales[nc].stopTime() + 1 years < currTime() )) 
269:         {
270:             refund = safeAdd(refund, sales[nc].getRefund(_a));
271:             tokens = safeAdd(tokens, sales[nc].getTokens(_a));
272:             nc += 1;
273:         }
274:     }
275: 
276:     function claimableTokens(address a) constant returns (uint) {
277:         var (tokens, refund, nc) = claimable(a, true);
278:         return tokens;
279:     }
280: 
281:     function claimableRefund(address a) constant returns (uint) {
282:         var (tokens, refund, nc) = claimable(a, true);
283:         return refund;
284:     }
285: 
286:     function claimableTokens() constant returns (uint) {
287:         return claimableTokens(msg.sender);
288:     }
289: 
290:     function claimableRefund() constant returns (uint) {
291:         return claimableRefund(msg.sender);
292:     }
293: 
294:     
295:     
296:     
297: 
298:     mapping (uint => bool) ownerClaimed;
299: 
300:     function claimableOwnerEth(uint salenum) constant returns (uint) {
301:         uint time = currTime();
302:         if (!sales[salenum].isComplete(time)) return 0;
303:         return sales[salenum].getOwnerEth();
304:     }
305: 
306:     function claimOwnerEth(uint salenum) onlyOwner notAllStopped {
307:         if (ownerClaimed[salenum]) throw;
308: 
309:         uint ownereth = claimableOwnerEth(salenum);
310:         if (ownereth > 0) {
311:             ownerClaimed[salenum] = true;
312:             if ( !payee.call.value(safebalance(ownereth))() ) throw;
313:         }
314:     }
315: 
316:     
317:     
318:     
319: 
320:     
321:     
322: 
323:     event logTokenTransfer(address token, address to, uint amount);
324: 
325:     function transferTokens(address _token, address _to) onlyOwner {
326:         Token token = Token(_token);
327:         uint balance = token.balanceOf(this);
328:         token.transfer(_to, balance);
329:         logTokenTransfer(_token, _to, balance);
330:     }
331: 
332:     
333:     
334:     
335: 
336:     bool allstopped;
337:     bool permastopped;
338: 
339:     
340:     
341:     address allStopper;
342:     function setAllStopper(address _a) onlyOwner {
343:         if (allStopper != owner) return;
344:         allStopper = _a;
345:     }
346:     modifier onlyAllStopper() {
347:         if (msg.sender != allStopper) throw;
348:         _;
349:     }
350: 
351:     event logAllStop();
352:     event logAllStart();
353: 
354:     modifier allStopped() {
355:         if (!allstopped) throw;
356:         _;
357:     }
358: 
359:     modifier notAllStopped() {
360:         if (allstopped) throw;
361:         _;
362:     }
363: 
364:     function allStop() onlyAllStopper {
365:         allstopped = true;    
366:         logAllStop();
367:     }
368: 
369:     function allStart() onlyAllStopper {
370:         if (!permastopped) {
371:             allstopped = false;
372:             logAllStart();
373:         }
374:     }
375: 
376:     function emergencyRefund(address _a, uint _amt) 
377:     allStopped 
378:     onlyAllStopper {
379:         
380:         
381:         permastopped = true;
382: 
383:         uint amt = _amt;
384: 
385:         uint ethbal = refundInStop[_a];
386: 
387:         
388:         
389:         if (amt == 0) amt = ethbal; 
390: 
391:         
392:         if (amt > ethbal) amt = ethbal;
393: 
394:         
395:         
396:         if ( !_a.call.value(safebalance(amt))() ) throw;
397:     }
398: 
399:     function raised() constant returns (uint) {
400:         return sales[getCurrSale()].raised();
401:     }
402: 
403:     function tokensPerEth() constant returns (uint) {
404:         return sales[getCurrSale()].tokensPerEth();
405:     }
406: }