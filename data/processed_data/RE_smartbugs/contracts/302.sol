1: 1: 
2: 2: 
3: 3: pragma solidity ^0.5.0;
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: interface IERC20 {
10: 10:     function transfer(address to, uint256 value) external returns (bool);
11: 11: 
12: 12:     function approve(address spender, uint256 value) external returns (bool);
13: 13: 
14: 14:     function transferFrom(address from, address to, uint256 value) external returns (bool);
15: 15: 
16: 16:     function totalSupply() external view returns (uint256);
17: 17: 
18: 18:     function balanceOf(address who) external view returns (uint256);
19: 19: 
20: 20:     function allowance(address owner, address spender) external view returns (uint256);
21: 21: 
22: 22:     event Transfer(address indexed from, address indexed to, uint256 value);
23: 23: 
24: 24:     event Approval(address indexed owner, address indexed spender, uint256 value);
25: 25: }
26: 26: 
27: 27: 
28: 28: 
29: 29: pragma solidity ^0.5.0;
30: 30: 
31: 31: 
32: 32: 
33: 33: 
34: 34: 
35: 35: library SafeMath {
36: 36:     
37: 37: 
38: 38: 
39: 39:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
40: 40:         
41: 41:         
42: 42:         
43: 43:         if (a == 0) {
44: 44:             return 0;
45: 45:         }
46: 46: 
47: 47:         uint256 c = a * b;
48: 48:         require(c / a == b);
49: 49: 
50: 50:         return c;
51: 51:     }
52: 52: 
53: 53:     
54: 54: 
55: 55: 
56: 56:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
57: 57:         
58: 58:         require(b > 0);
59: 59:         uint256 c = a / b;
60: 60:         
61: 61: 
62: 62:         return c;
63: 63:     }
64: 64: 
65: 65:     
66: 66: 
67: 67: 
68: 68:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
69: 69:         require(b <= a);
70: 70:         uint256 c = a - b;
71: 71: 
72: 72:         return c;
73: 73:     }
74: 74: 
75: 75:     
76: 76: 
77: 77: 
78: 78:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
79: 79:         uint256 c = a + b;
80: 80:         require(c >= a);
81: 81: 
82: 82:         return c;
83: 83:     }
84: 84: 
85: 85:     
86: 86: 
87: 87: 
88: 88: 
89: 89:     function mod(uint256 a, uint256 b) internal pure returns (uint256) {
90: 90:         require(b != 0);
91: 91:         return a % b;
92: 92:     }
93: 93: }
94: 94: 
95: 95: 
96: 96: 
97: 97: pragma solidity ^0.5.0;
98: 98: 
99: 99: 
100: 100: 
101: 101: 
102: 102: 
103: 103: 
104: 104: 
105: 105: 
106: 106: 
107: 107: library SafeERC20 {
108: 108:     using SafeMath for uint256;
109: 109: 
110: 110:     function safeTransfer(IERC20 token, address to, uint256 value) internal {
111: 111:         require(token.transfer(to, value));
112: 112:     }
113: 113: 
114: 114:     function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
115: 115:         require(token.transferFrom(from, to, value));
116: 116:     }
117: 117: 
118: 118:     function safeApprove(IERC20 token, address spender, uint256 value) internal {
119: 119:         
120: 120:         
121: 121:         
122: 122:         require((value == 0) || (token.allowance(address(this), spender) == 0));
123: 123:         require(token.approve(spender, value));
124: 124:     }
125: 125: 
126: 126:     function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
127: 127:         uint256 newAllowance = token.allowance(address(this), spender).add(value);
128: 128:         require(token.approve(spender, newAllowance));
129: 129:     }
130: 130: 
131: 131:     function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
132: 132:         uint256 newAllowance = token.allowance(address(this), spender).sub(value);
133: 133:         require(token.approve(spender, newAllowance));
134: 134:     }
135: 135: }
136: 136: 
137: 137: 
138: 138: 
139: 139: pragma solidity ^0.5.0;
140: 140: 
141: 141: contract DutchAuction is SignatureBouncer, Ownable {
142: 142:     using SafeERC20 for ERC20Burnable;
143: 143: 
144: 144:     
145: 145: 
146: 146: 
147: 147:     event BidSubmission(address indexed sender, uint256 amount);
148: 148: 
149: 149:     
150: 150: 
151: 151: 
152: 152:     uint constant public WAITING_PERIOD = 0; 
153: 153: 
154: 154:     
155: 155: 
156: 156: 
157: 157:     ERC20Burnable public token;
158: 158:     address public ambix;
159: 159:     address payable public wallet;
160: 160:     uint public maxTokenSold;
161: 161:     uint public ceiling;
162: 162:     uint public priceFactor;
163: 163:     uint public startBlock;
164: 164:     uint public endTime;
165: 165:     uint public totalReceived;
166: 166:     uint public finalPrice;
167: 167:     mapping (address => uint) public bids;
168: 168:     Stages public stage;
169: 169: 
170: 170:     
171: 171: 
172: 172: 
173: 173:     enum Stages {
174: 174:         AuctionDeployed,
175: 175:         AuctionSetUp,
176: 176:         AuctionStarted,
177: 177:         AuctionEnded,
178: 178:         TradingStarted
179: 179:     }
180: 180: 
181: 181:     
182: 182: 
183: 183: 
184: 184:     modifier atStage(Stages _stage) {
185: 185:         
186: 186:         require(stage == _stage);
187: 187:         _;
188: 188:     }
189: 189: 
190: 190:     modifier isValidPayload() {
191: 191:         require(msg.data.length == 4 || msg.data.length == 164);
192: 192:         _;
193: 193:     }
194: 194: 
195: 195:     modifier timedTransitions() {
196: 196:         if (stage == Stages.AuctionStarted && calcTokenPrice() <= calcStopPrice())
197: 197:             finalizeAuction();
198: 198:         if (stage == Stages.AuctionEnded && now > endTime + WAITING_PERIOD)
199: 199:             stage = Stages.TradingStarted;
200: 200:         _;
201: 201:     }
202: 202: 
203: 203:     
204: 204: 
205: 205: 
206: 206:     
207: 207:     
208: 208:     
209: 209:     
210: 210:     
211: 211:     constructor(address payable _wallet, uint _maxTokenSold, uint _ceiling, uint _priceFactor)
212: 212:         public
213: 213:     {
214: 214:         require(_wallet != address(0) && _ceiling > 0 && _priceFactor > 0);
215: 215: 
216: 216:         wallet = _wallet;
217: 217:         maxTokenSold = _maxTokenSold;
218: 218:         ceiling = _ceiling;
219: 219:         priceFactor = _priceFactor;
220: 220:         stage = Stages.AuctionDeployed;
221: 221:     }
222: 222: 
223: 223:     
224: 224:     
225: 225:     
226: 226:     function setup(ERC20Burnable _token, address _ambix)
227: 227:         public
228: 228:         onlyOwner
229: 229:         atStage(Stages.AuctionDeployed)
230: 230:     {
231: 231:         
232: 232:         require(_token != ERC20Burnable(0) && _ambix != address(0));
233: 233: 
234: 234:         token = _token;
235: 235:         ambix = _ambix;
236: 236: 
237: 237:         
238: 238:         require(token.balanceOf(address(this)) == maxTokenSold);
239: 239: 
240: 240:         stage = Stages.AuctionSetUp;
241: 241:     }
242: 242: 
243: 243:     
244: 244:     function startAuction()
245: 245:         public
246: 246:         onlyOwner
247: 247:         atStage(Stages.AuctionSetUp)
248: 248:     {
249: 249:         stage = Stages.AuctionStarted;
250: 250:         startBlock = block.number;
251: 251:     }
252: 252: 
253: 253:     
254: 254:     
255: 255:     function calcCurrentTokenPrice()
256: 256:         public
257: 257:         timedTransitions
258: 258:         returns (uint)
259: 259:     {
260: 260:         if (stage == Stages.AuctionEnded || stage == Stages.TradingStarted)
261: 261:             return finalPrice;
262: 262:         return calcTokenPrice();
263: 263:     }
264: 264: 
265: 265:     
266: 266:     
267: 267:     function updateStage()
268: 268:         public
269: 269:         timedTransitions
270: 270:         returns (Stages)
271: 271:     {
272: 272:         return stage;
273: 273:     }
274: 274: 
275: 275:     
276: 276:     
277: 277:     function bid(bytes calldata signature)
278: 278:         external
279: 279:         payable
280: 280:         isValidPayload
281: 281:         timedTransitions
282: 282:         atStage(Stages.AuctionStarted)
283: 283:         onlyValidSignature(signature)
284: 284:         returns (uint amount)
285: 285:     {
286: 286:         require(msg.value > 0);
287: 287:         amount = msg.value;
288: 288: 
289: 289:         address payable receiver = msg.sender;
290: 290: 
291: 291:         
292: 292:         uint maxWei = maxTokenSold * calcTokenPrice() / 10**9 - totalReceived;
293: 293:         uint maxWeiBasedOnTotalReceived = ceiling - totalReceived;
294: 294:         if (maxWeiBasedOnTotalReceived < maxWei)
295: 295:             maxWei = maxWeiBasedOnTotalReceived;
296: 296: 
297: 297:         
298: 298:         if (amount > maxWei) {
299: 299:             amount = maxWei;
300: 300:             
301: 301:             receiver.transfer(msg.value - amount);
302: 302:         }
303: 303: 
304: 304:         
305: 305:         (bool success,) = wallet.call.value(amount)("");
306: 306:         require(success);
307: 307: 
308: 308:         bids[receiver] += amount;
309: 309:         totalReceived += amount;
310: 310:         emit BidSubmission(receiver, amount);
311: 311: 
312: 312:         
313: 313:         if (amount == maxWei)
314: 314:             finalizeAuction();
315: 315:     }
316: 316: 
317: 317:     
318: 318:     function claimTokens()
319: 319:         public
320: 320:         isValidPayload
321: 321:         timedTransitions
322: 322:         atStage(Stages.TradingStarted)
323: 323:     {
324: 324:         address receiver = msg.sender;
325: 325:         uint tokenCount = bids[receiver] * 10**9 / finalPrice;
326: 326:         bids[receiver] = 0;
327: 327:         token.safeTransfer(receiver, tokenCount);
328: 328:     }
329: 329: 
330: 330:     
331: 331:     
332: 332:     function calcStopPrice()
333: 333:         view
334: 334:         public
335: 335:         returns (uint)
336: 336:     {
337: 337:         return totalReceived * 10**9 / maxTokenSold + 1;
338: 338:     }
339: 339: 
340: 340:     
341: 341:     
342: 342:     function calcTokenPrice()
343: 343:         view
344: 344:         public
345: 345:         returns (uint)
346: 346:     {
347: 347:         return priceFactor * 10**18 / (block.number - startBlock + 7500) + 1;
348: 348:     }
349: 349: 
350: 350:     
351: 351: 
352: 352: 
353: 353:     function finalizeAuction()
354: 354:         private
355: 355:     {
356: 356:         stage = Stages.AuctionEnded;
357: 357:         finalPrice = totalReceived == ceiling ? calcTokenPrice() : calcStopPrice();
358: 358:         uint soldTokens = totalReceived * 10**9 / finalPrice;
359: 359: 
360: 360:         if (totalReceived == ceiling) {
361: 361:             
362: 362:             token.safeTransfer(ambix, maxTokenSold - soldTokens);
363: 363:         } else {
364: 364:             
365: 365:             token.burn(maxTokenSold - soldTokens);
366: 366:         }
367: 367: 
368: 368:         endTime = now;
369: 369:     }
370: 370: }
371: 371: 
372: 372: 
373: 373: 
374: 374: pragma solidity ^0.5.0;
375: 375: 
376: 376: 
377: 377: library SharedCode {
378: 378:     
379: 379: 
380: 380: 
381: 381: 
382: 382:     function proxy(address _shared) internal returns (address instance) {
383: 383:         bytes memory code = abi.encodePacked(
384: 384:             hex"603160008181600b9039f3600080808080368092803773",
385: 385:             _shared, hex"5af43d828181803e808314603057f35bfd"
386: 386:         );
387: 387:         assembly {
388: 388:             instance := create(0, add(code, 0x20), 60)
389: 389:             if iszero(extcodesize(instance)) {
390: 390:                 revert(0, 0)
391: 391:             }
392: 392:         }
393: 393:     }
394: 394: }
395: 395: 
396: 396: 
397: 397: 
398: 398: pragma solidity ^0.5.0;
399: 399: 
400: 400: 
401: 401: 
402: 402: 