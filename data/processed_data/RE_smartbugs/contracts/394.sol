1: 1: pragma solidity >=0.4.4;
2: 2: 
3: 3: contract ICO is EventDefinitions, Testable, SafeMath, Owned {
4: 4:     Token public token;
5: 5:     address public controller;
6: 6:     address public payee;
7: 7: 
8: 8:     Sale[] public sales;
9: 9:     
10: 10:     
11: 11:     mapping (uint => uint) saleMinimumPurchases;
12: 12: 
13: 13:     
14: 14:     mapping (address => uint) public nextClaim;
15: 15: 
16: 16:     
17: 17:     mapping (address => uint) refundInStop;
18: 18: 
19: 19:     modifier tokenIsSet() {
20: 20:         if (address(token) == 0) throw;
21: 21:         _;
22: 22:     }
23: 23: 
24: 24:     modifier onlyController() {
25: 25:         if (msg.sender != address(controller)) throw;
26: 26:         _;
27: 27:     }
28: 28: 
29: 29:     function ICO() { 
30: 30:         owner = msg.sender;
31: 31:         payee = msg.sender;
32: 32:         allStopper = msg.sender;
33: 33:     }
34: 34: 
35: 35:     
36: 36:     
37: 37:     
38: 38:     
39: 39:     function changePayee(address newPayee) 
40: 40:     onlyOwner notAllStopped {
41: 41:         payee = newPayee;
42: 42:     }
43: 43: 
44: 44:     function setToken(address _token) onlyOwner {
45: 45:         if (address(token) != 0x0) throw;
46: 46:         token = Token(_token);
47: 47:     }
48: 48: 
49: 49:     
50: 50:     
51: 51:     function setAsTest() onlyOwner {
52: 52:         if (sales.length == 0) {
53: 53:             testing = true;
54: 54:         }
55: 55:     }
56: 56: 
57: 57:     function setController(address _controller) 
58: 58:     onlyOwner notAllStopped {
59: 59:         if (address(controller) != 0x0) throw;
60: 60:         controller = _controller; 
61: 61:     }
62: 62: 
63: 63:     
64: 64:     
65: 65:     
66: 66: 
67: 67:     function addSale(address sale, uint minimumPurchase) 
68: 68:     onlyController notAllStopped {
69: 69:         uint salenum = sales.length;
70: 70:         sales.push(Sale(sale));
71: 71:         saleMinimumPurchases[salenum] = minimumPurchase;
72: 72:         logSaleStart(Sale(sale).startTime(), Sale(sale).stopTime());
73: 73:     }
74: 74: 
75: 75:     function addSale(address sale) onlyController {
76: 76:         addSale(sale, 0);
77: 77:     }
78: 78: 
79: 79:     function getCurrSale() constant returns (uint) {
80: 80:         if (sales.length == 0) throw; 
81: 81:         return sales.length - 1;
82: 82:     }
83: 83: 
84: 84:     function currSaleActive() constant returns (bool) {
85: 85:         return sales[getCurrSale()].isActive(currTime());
86: 86:     }
87: 87: 
88: 88:     function currSaleComplete() constant returns (bool) {
89: 89:         return sales[getCurrSale()].isComplete(currTime());
90: 90:     }
91: 91: 
92: 92:     function numSales() constant returns (uint) {
93: 93:         return sales.length;
94: 94:     }
95: 95: 
96: 96:     function numContributors(uint salenum) constant returns (uint) {
97: 97:         return sales[salenum].numContributors();
98: 98:     }
99: 99: 
100: 100:     
101: 101:     
102: 102:     
103: 103: 
104: 104:     event logPurchase(address indexed purchaser, uint value);
105: 105: 
106: 106:     function () payable {
107: 107:         deposit();
108: 108:     }
109: 109: 
110: 110:     function deposit() payable notAllStopped {
111: 111:         doDeposit(msg.sender, msg.value);
112: 112: 
113: 113:         
114: 114:         uint contrib = refundInStop[msg.sender];
115: 115:         refundInStop[msg.sender] = contrib + msg.value;
116: 116: 
117: 117:         logPurchase(msg.sender, msg.value);
118: 118:     }
119: 119: 
120: 120:     
121: 121:     function doDeposit(address _for, uint _value) private {
122: 122:         uint currSale = getCurrSale();
123: 123:         if (!currSaleActive()) throw;
124: 124:         if (_value < saleMinimumPurchases[currSale]) throw;
125: 125: 
126: 126:         uint tokensToMintNow = sales[currSale].buyTokens(_for, _value, currTime());
127: 127: 
128: 128:         if (tokensToMintNow > 0) {
129: 129:             token.mint(_for, tokensToMintNow);
130: 130:         }
131: 131:     }
132: 132: 
133: 133:     
134: 134:     
135: 135:     
136: 136: 
137: 137:     
138: 138:     
139: 139:     
140: 140:     
141: 141:     
142: 142:     
143: 143: 
144: 144:     event logPurchaseViaToken(
145: 145:                         address indexed purchaser, address indexed token, 
146: 146:                         uint depositedTokens, uint ethValue, 
147: 147:                         bytes32 _reference);
148: 148: 
149: 149:     event logPurchaseViaFiat(
150: 150:                         address indexed purchaser, uint ethValue, 
151: 151:                         bytes32 _reference);
152: 152: 
153: 153:     mapping (bytes32 => bool) public mintRefs;
154: 154:     mapping (address => uint) public raisedFromToken;
155: 155:     uint public raisedFromFiat;
156: 156: 
157: 157:     function depositFiat(address _for, uint _ethValue, bytes32 _reference) 
158: 158:     notAllStopped onlyOwner {
159: 159:         if (getCurrSale() > 0) throw; 
160: 160:         if (mintRefs[_reference]) throw; 
161: 161:         mintRefs[_reference] = true;
162: 162:         raisedFromFiat = safeAdd(raisedFromFiat, _ethValue);
163: 163: 
164: 164:         doDeposit(_for, _ethValue);
165: 165:         logPurchaseViaFiat(_for, _ethValue, _reference);
166: 166:     }
167: 167: 
168: 168:     function depositTokens(address _for, address _token, 
169: 169:                            uint _ethValue, uint _depositedTokens, 
170: 170:                            bytes32 _reference) 
171: 171:     notAllStopped onlyOwner {
172: 172:         if (getCurrSale() > 0) throw; 
173: 173:         if (mintRefs[_reference]) throw; 
174: 174:         mintRefs[_reference] = true;
175: 175:         raisedFromToken[_token] = safeAdd(raisedFromToken[_token], _ethValue);
176: 176: 
177: 177:         
178: 178:         
179: 179:         uint tokensPerEth = sales[0].tokensPerEth();
180: 180:         uint tkn = safeMul(_ethValue, tokensPerEth) / weiPerEth();
181: 181:         token.mint(_for, tkn);
182: 182:         
183: 183:         logPurchaseViaToken(_for, _token, _depositedTokens, _ethValue, _reference);
184: 184:     }
185: 185: 
186: 186:     
187: 187:     
188: 188:     
189: 189:     
190: 190:     
191: 191:     function safebalance(uint bal) private returns (uint) {
192: 192:         if (bal > this.balance) {
193: 193:             return this.balance;
194: 194:         } else {
195: 195:             return bal;
196: 196:         }
197: 197:     }
198: 198: 
199: 199:     
200: 200:     
201: 201:     
202: 202:     
203: 203: 
204: 204:     uint public topUpAmount;
205: 205: 
206: 206:     function topUp() payable onlyOwner notAllStopped {
207: 207:         topUpAmount = safeAdd(topUpAmount, msg.value);
208: 208:     }
209: 209: 
210: 210:     function withdrawTopUp() onlyOwner notAllStopped {
211: 211:         uint amount = topUpAmount;
212: 212:         topUpAmount = 0;
213: 213:         if (!msg.sender.call.value(safebalance(amount))()) throw;
214: 214:     }
215: 215: 
216: 216:     
217: 217:     
218: 218:     
219: 219: 
220: 220:     
221: 221:     
222: 222:     
223: 223:     
224: 224:     function claim() notAllStopped {
225: 225:         var (tokens, refund, nc) = claimable(msg.sender, true);
226: 226:         nextClaim[msg.sender] = nc;
227: 227:         logClaim(msg.sender, refund, tokens);
228: 228:         if (tokens > 0) {
229: 229:             token.mint(msg.sender, tokens);
230: 230:         }
231: 231:         if (refund > 0) {
232: 232:             refundInStop[msg.sender] = safeSub(refundInStop[msg.sender], refund);
233: 233:             if (!msg.sender.send(safebalance(refund))) throw;
234: 234:         }
235: 235:     }
236: 236: 
237: 237:     
238: 238:     
239: 239:     
240: 240:     
241: 241:     
242: 242:     
243: 243:     
244: 244:     function claimFor(address _from, address _to) 
245: 245:     onlyOwner notAllStopped {
246: 246:         var (tokens, refund, nc) = claimable(_from, false);
247: 247:         nextClaim[_from] = nc;
248: 248: 
249: 249:         logClaim(_from, refund, tokens);
250: 250: 
251: 251:         if (tokens > 0) {
252: 252:             token.mint(_to, tokens);
253: 253:         }
254: 254:         if (refund > 0) {
255: 255:             refundInStop[_from] = safeSub(refundInStop[_from], refund);
256: 256:             if (!_to.send(safebalance(refund))) throw;
257: 257:         }
258: 258:     }
259: 259: 
260: 260:     function claimable(address _a, bool _includeRecent) 
261: 261:     constant private tokenIsSet 
262: 262:     returns (uint tokens, uint refund, uint nc) {
263: 263:         nc = nextClaim[_a];
264: 264: 
265: 265:         while (nc < sales.length &&
266: 266:                sales[nc].isComplete(currTime()) &&
267: 267:                ( _includeRecent || 
268: 268:                  sales[nc].stopTime() + 1 years < currTime() )) 
269: 269:         {
270: 270:             refund = safeAdd(refund, sales[nc].getRefund(_a));
271: 271:             tokens = safeAdd(tokens, sales[nc].getTokens(_a));
272: 272:             nc += 1;
273: 273:         }
274: 274:     }
275: 275: 
276: 276:     function claimableTokens(address a) constant returns (uint) {
277: 277:         var (tokens, refund, nc) = claimable(a, true);
278: 278:         return tokens;
279: 279:     }
280: 280: 
281: 281:     function claimableRefund(address a) constant returns (uint) {
282: 282:         var (tokens, refund, nc) = claimable(a, true);
283: 283:         return refund;
284: 284:     }
285: 285: 
286: 286:     function claimableTokens() constant returns (uint) {
287: 287:         return claimableTokens(msg.sender);
288: 288:     }
289: 289: 
290: 290:     function claimableRefund() constant returns (uint) {
291: 291:         return claimableRefund(msg.sender);
292: 292:     }
293: 293: 
294: 294:     
295: 295:     
296: 296:     
297: 297: 
298: 298:     mapping (uint => bool) ownerClaimed;
299: 299: 
300: 300:     function claimableOwnerEth(uint salenum) constant returns (uint) {
301: 301:         uint time = currTime();
302: 302:         if (!sales[salenum].isComplete(time)) return 0;
303: 303:         return sales[salenum].getOwnerEth();
304: 304:     }
305: 305: 
306: 306:     function claimOwnerEth(uint salenum) onlyOwner notAllStopped {
307: 307:         if (ownerClaimed[salenum]) throw;
308: 308: 
309: 309:         uint ownereth = claimableOwnerEth(salenum);
310: 310:         if (ownereth > 0) {
311: 311:             ownerClaimed[salenum] = true;
312: 312:             if ( !payee.call.value(safebalance(ownereth))() ) throw;
313: 313:         }
314: 314:     }
315: 315: 
316: 316:     
317: 317:     
318: 318:     
319: 319: 
320: 320:     
321: 321:     
322: 322: 
323: 323:     event logTokenTransfer(address token, address to, uint amount);
324: 324: 
325: 325:     function transferTokens(address _token, address _to) onlyOwner {
326: 326:         Token token = Token(_token);
327: 327:         uint balance = token.balanceOf(this);
328: 328:         token.transfer(_to, balance);
329: 329:         logTokenTransfer(_token, _to, balance);
330: 330:     }
331: 331: 
332: 332:     
333: 333:     
334: 334:     
335: 335: 
336: 336:     bool allstopped;
337: 337:     bool permastopped;
338: 338: 
339: 339:     
340: 340:     
341: 341:     address allStopper;
342: 342:     function setAllStopper(address _a) onlyOwner {
343: 343:         if (allStopper != owner) return;
344: 344:         allStopper = _a;
345: 345:     }
346: 346:     modifier onlyAllStopper() {
347: 347:         if (msg.sender != allStopper) throw;
348: 348:         _;
349: 349:     }
350: 350: 
351: 351:     event logAllStop();
352: 352:     event logAllStart();
353: 353: 
354: 354:     modifier allStopped() {
355: 355:         if (!allstopped) throw;
356: 356:         _;
357: 357:     }
358: 358: 
359: 359:     modifier notAllStopped() {
360: 360:         if (allstopped) throw;
361: 361:         _;
362: 362:     }
363: 363: 
364: 364:     function allStop() onlyAllStopper {
365: 365:         allstopped = true;    
366: 366:         logAllStop();
367: 367:     }
368: 368: 
369: 369:     function allStart() onlyAllStopper {
370: 370:         if (!permastopped) {
371: 371:             allstopped = false;
372: 372:             logAllStart();
373: 373:         }
374: 374:     }
375: 375: 
376: 376:     function emergencyRefund(address _a, uint _amt) 
377: 377:     allStopped 
378: 378:     onlyAllStopper {
379: 379:         
380: 380:         
381: 381:         permastopped = true;
382: 382: 
383: 383:         uint amt = _amt;
384: 384: 
385: 385:         uint ethbal = refundInStop[_a];
386: 386: 
387: 387:         
388: 388:         
389: 389:         if (amt == 0) amt = ethbal; 
390: 390: 
391: 391:         
392: 392:         if (amt > ethbal) amt = ethbal;
393: 393: 
394: 394:         
395: 395:         
396: 396:         if ( !_a.call.value(safebalance(amt))() ) throw;
397: 397:     }
398: 398: 
399: 399:     function raised() constant returns (uint) {
400: 400:         return sales[getCurrSale()].raised();
401: 401:     }
402: 402: 
403: 403:     function tokensPerEth() constant returns (uint) {
404: 404:         return sales[getCurrSale()].tokensPerEth();
405: 405:     }
406: 406: }