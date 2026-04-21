1: 1: pragma solidity ^0.4.24;
2: 2: pragma experimental "v0.5.0";
3: 3: pragma experimental ABIEncoderV2;
4: 4: 
5: 5: library AddressExtension {
6: 6: 
7: 7:   function isValid(address _address) internal pure returns (bool) {
8: 8:     return 0 != _address;
9: 9:   }
10: 10: 
11: 11:   function isAccount(address _address) internal view returns (bool result) {
12: 12:     assembly {
13: 13:       result := iszero(extcodesize(_address))
14: 14:     }
15: 15:   }
16: 16: 
17: 17:   function toBytes(address _address) internal pure returns (bytes b) {
18: 18:    assembly {
19: 19:       let m := mload(0x40)
20: 20:       mstore(add(m, 20), xor(0x140000000000000000000000000000000000000000, _address))
21: 21:       mstore(0x40, add(m, 52))
22: 22:       b := m
23: 23:     }
24: 24:   }
25: 25: }
26: 26: 
27: 27: library Math {
28: 28: 
29: 29:   struct Fraction {
30: 30:     uint256 numerator;
31: 31:     uint256 denominator;
32: 32:   }
33: 33: 
34: 34:   function isPositive(Fraction memory fraction) internal pure returns (bool) {
35: 35:     return fraction.numerator > 0 && fraction.denominator > 0;
36: 36:   }
37: 37: 
38: 38:   function mul(uint256 a, uint256 b) internal pure returns (uint256 r) {
39: 39:     r = a * b;
40: 40:     require((a == 0) || (r / a == b));
41: 41:   }
42: 42: 
43: 43:   function div(uint256 a, uint256 b) internal pure returns (uint256 r) {
44: 44:     r = a / b;
45: 45:   }
46: 46: 
47: 47:   function sub(uint256 a, uint256 b) internal pure returns (uint256 r) {
48: 48:     require((r = a - b) <= a);
49: 49:   }
50: 50: 
51: 51:   function add(uint256 a, uint256 b) internal pure returns (uint256 r) {
52: 52:     require((r = a + b) >= a);
53: 53:   }
54: 54: 
55: 55:   function min(uint256 x, uint256 y) internal pure returns (uint256 r) {
56: 56:     return x <= y ? x : y;
57: 57:   }
58: 58: 
59: 59:   function max(uint256 x, uint256 y) internal pure returns (uint256 r) {
60: 60:     return x >= y ? x : y;
61: 61:   }
62: 62: 
63: 63:   function mulDiv(uint256 value, uint256 m, uint256 d) internal pure returns (uint256 r) {
64: 64:     r = value * m;
65: 65:     if (r / value == m) {
66: 66:       r /= d;
67: 67:     } else {
68: 68:       r = mul(value / d, m);
69: 69:     }
70: 70:   }
71: 71: 
72: 72:   function mulDivCeil(uint256 value, uint256 m, uint256 d) internal pure returns (uint256 r) {
73: 73:     r = value * m;
74: 74:     if (r / value == m) {
75: 75:       if (r % d == 0) {
76: 76:         r /= d;
77: 77:       } else {
78: 78:         r = (r / d) + 1;
79: 79:       }
80: 80:     } else {
81: 81:       r = mul(value / d, m);
82: 82:       if (value % d != 0) {
83: 83:         r += 1;
84: 84:       }
85: 85:     }
86: 86:   }
87: 87: 
88: 88:   function mul(uint256 x, Fraction memory f) internal pure returns (uint256) {
89: 89:     return mulDiv(x, f.numerator, f.denominator);
90: 90:   }
91: 91: 
92: 92:   function mulCeil(uint256 x, Fraction memory f) internal pure returns (uint256) {
93: 93:     return mulDivCeil(x, f.numerator, f.denominator);
94: 94:   }
95: 95: 
96: 96:   function div(uint256 x, Fraction memory f) internal pure returns (uint256) {
97: 97:     return mulDiv(x, f.denominator, f.numerator);
98: 98:   }
99: 99: 
100: 100:   function divCeil(uint256 x, Fraction memory f) internal pure returns (uint256) {
101: 101:     return mulDivCeil(x, f.denominator, f.numerator);
102: 102:   }
103: 103: 
104: 104:   function mul(Fraction memory x, Fraction memory y) internal pure returns (Math.Fraction) {
105: 105:     return Math.Fraction({
106: 106:       numerator: mul(x.numerator, y.numerator),
107: 107:       denominator: mul(x.denominator, y.denominator)
108: 108:     });
109: 109:   }
110: 110: }
111: 111: 
112: 112: contract ERC20Like is SecureERC20, FsTKToken {
113: 113:   using AddressExtension for address;
114: 114:   using Math for uint256;
115: 115: 
116: 116:   modifier liquid {
117: 117:     require(isLiquid);
118: 118:      _;
119: 119:   }
120: 120:   modifier canUseDirectDebit {
121: 121:     require(isDirectDebitEnable);
122: 122:      _;
123: 123:   }
124: 124:   modifier canDelegate {
125: 125:     require(isDelegateEnable);
126: 126:      _;
127: 127:   }
128: 128: 
129: 129:   bool public erc20ApproveChecking;
130: 130:   bool public isLiquid = true;
131: 131:   bool public isDelegateEnable;
132: 132:   bool public isDirectDebitEnable;
133: 133:   string public metadata;
134: 134:   mapping(address => Account) internal accounts;
135: 135: 
136: 136:   constructor(string _metadata) public {
137: 137:     metadata = _metadata;
138: 138:   }
139: 139: 
140: 140:   function balanceOf(address owner) public view returns (uint256) {
141: 141:     return accounts[owner].balance;
142: 142:   }
143: 143: 
144: 144:   function allowance(address owner, address spender) public view returns (uint256) {
145: 145:     return accounts[owner].instruments[spender].allowance;
146: 146:   }
147: 147: 
148: 148:   function transfer(address to, uint256 value) public liquid returns (bool) {
149: 149:     Account storage senderAccount = accounts[msg.sender];
150: 150: 
151: 151:     senderAccount.balance = senderAccount.balance.sub(value);
152: 152:     accounts[to].balance += value;
153: 153: 
154: 154:     emit Transfer(msg.sender, to, value);
155: 155:     return true;
156: 156:   }
157: 157: 
158: 158:   function transferFrom(address from, address to, uint256 value) public liquid returns (bool) {
159: 159:     Account storage fromAccount = accounts[from];
160: 160:     Instrument storage senderInstrument = fromAccount.instruments[msg.sender];
161: 161: 
162: 162:     fromAccount.balance = fromAccount.balance.sub(value);
163: 163:     senderInstrument.allowance = senderInstrument.allowance.sub(value);
164: 164:     accounts[to].balance += value;
165: 165: 
166: 166:     emit Transfer(from, to, value);
167: 167:     return true;
168: 168:   }
169: 169: 
170: 170:   function approve(address spender, uint256 value) public returns (bool) {
171: 171:     Instrument storage spenderInstrument = accounts[msg.sender].instruments[spender];
172: 172:     if (erc20ApproveChecking) {
173: 173:       require((value == 0) || (spenderInstrument.allowance == 0));
174: 174:     }
175: 175: 
176: 176:     emit Approval(
177: 177:       msg.sender,
178: 178:       spender,
179: 179:       spenderInstrument.allowance = value
180: 180:     );
181: 181:     return true;
182: 182:   }
183: 183: 
184: 184:   function setERC20ApproveChecking(bool approveChecking) public {
185: 185:     emit SetERC20ApproveChecking(erc20ApproveChecking = approveChecking);
186: 186:   }
187: 187: 
188: 188:   function approve(address spender, uint256 expectedValue, uint256 newValue) public returns (bool) {
189: 189:     Instrument storage spenderInstrument = accounts[msg.sender].instruments[spender];
190: 190:     require(spenderInstrument.allowance == expectedValue);
191: 191: 
192: 192:     emit Approval(
193: 193:       msg.sender,
194: 194:       spender,
195: 195:       spenderInstrument.allowance = newValue
196: 196:     );
197: 197:     return true;
198: 198:   }
199: 199: 
200: 200:   function increaseAllowance(address spender, uint256 value) public returns (bool) {
201: 201:     Instrument storage spenderInstrument = accounts[msg.sender].instruments[spender];
202: 202: 
203: 203:     emit Approval(
204: 204:       msg.sender,
205: 205:       spender,
206: 206:       spenderInstrument.allowance = spenderInstrument.allowance.add(value)
207: 207:     );
208: 208:     return true;
209: 209:   }
210: 210: 
211: 211:   function decreaseAllowance(address spender, uint256 value, bool strict) public returns (bool) {
212: 212:     Instrument storage spenderInstrument = accounts[msg.sender].instruments[spender];
213: 213: 
214: 214:     uint256 currentValue = spenderInstrument.allowance;
215: 215:     uint256 newValue;
216: 216:     if (strict) {
217: 217:       newValue = currentValue.sub(value);
218: 218:     } else if (value < currentValue) {
219: 219:       newValue = currentValue - value;
220: 220:     }
221: 221: 
222: 222:     emit Approval(
223: 223:       msg.sender,
224: 224:       spender,
225: 225:       spenderInstrument.allowance = newValue
226: 226:     );
227: 227:     return true;
228: 228:   }
229: 229: 
230: 230:   function setMetadata0(string _metadata) internal {
231: 231:     emit SetMetadata(metadata = _metadata);
232: 232:   }
233: 233: 
234: 234:   function setLiquid0(bool liquidity) internal {
235: 235:     emit SetLiquid(isLiquid = liquidity);
236: 236:   }
237: 237: 
238: 238:   function setDelegate(bool delegate) public {
239: 239:     emit SetDelegate(isDelegateEnable = delegate);
240: 240:   }
241: 241: 
242: 242:   function setDirectDebit(bool directDebit) public {
243: 243:     emit SetDirectDebit(isDirectDebitEnable = directDebit);
244: 244:   }
245: 245: 
246: 246:   function spendableAllowance(address owner, address spender) public view returns (uint256) {
247: 247:     Account storage ownerAccount = accounts[owner];
248: 248:     return Math.min(
249: 249:       ownerAccount.instruments[spender].allowance,
250: 250:       ownerAccount.balance
251: 251:     );
252: 252:   }
253: 253: 
254: 254:   function transfer(uint256[] data) public liquid returns (bool) {
255: 255:     Account storage senderAccount = accounts[msg.sender];
256: 256:     uint256 totalValue;
257: 257: 
258: 258:     for (uint256 i = 0; i < data.length; i++) {
259: 259:       address receiver = address(data[i] >> 96);
260: 260:       uint256 value = data[i] & 0xffffffffffffffffffffffff;
261: 261: 
262: 262:       totalValue = totalValue.add(value);
263: 263:       accounts[receiver].balance += value;
264: 264: 
265: 265:       emit Transfer(msg.sender, receiver, value);
266: 266:     }
267: 267: 
268: 268:     senderAccount.balance = senderAccount.balance.sub(totalValue);
269: 269: 
270: 270:     return true;
271: 271:   }
272: 272: 
273: 273:   function transferAndCall(
274: 274:     address to,
275: 275:     uint256 value,
276: 276:     bytes data
277: 277:   )
278: 278:     public
279: 279:     payable
280: 280:     liquid
281: 281:     returns (bool)
282: 282:   {
283: 283:     require(
284: 284:       to != address(this) &&
285: 285:       data.length >= 68 &&
286: 286:       transfer(to, value)
287: 287:     );
288: 288:     assembly {
289: 289:         mstore(add(data, 36), value)
290: 290:         mstore(add(data, 68), caller)
291: 291:     }
292: 292:     require(to.call.value(msg.value)(data));
293: 293:     return true;
294: 294:   }
295: 295: 
296: 296:   function nonceOf(address owner) public view returns (uint256) {
297: 297:     return accounts[owner].nonce;
298: 298:   }
299: 299: 
300: 300:   function increaseNonce() public returns (bool) {
301: 301:     emit IncreaseNonce(msg.sender, accounts[msg.sender].nonce += 1);
302: 302:   }
303: 303: 
304: 304:   function delegateTransferAndCall(
305: 305:     uint256 nonce,
306: 306:     uint256 fee,
307: 307:     uint256 gasAmount,
308: 308:     address to,
309: 309:     uint256 value,
310: 310:     bytes data,
311: 311:     DelegateMode mode,
312: 312:     uint8 v,
313: 313:     bytes32 r,
314: 314:     bytes32 s
315: 315:   )
316: 316:     public
317: 317:     liquid
318: 318:     canDelegate
319: 319:     returns (bool)
320: 320:   {
321: 321:     require(to != address(this));
322: 322:     address signer;
323: 323:     address relayer;
324: 324:     if (mode == DelegateMode.PublicMsgSender) {
325: 325:       signer = ecrecover(
326: 326:         keccak256(abi.encodePacked(this, nonce, fee, gasAmount, to, value, data, mode, address(0))),
327: 327:         v,
328: 328:         r,
329: 329:         s
330: 330:       );
331: 331:       relayer = msg.sender;
332: 332:     } else if (mode == DelegateMode.PublicTxOrigin) {
333: 333:       signer = ecrecover(
334: 334:         keccak256(abi.encodePacked(this, nonce, fee, gasAmount, to, value, data, mode, address(0))),
335: 335:         v,
336: 336:         r,
337: 337:         s
338: 338:       );
339: 339:       relayer = tx.origin;
340: 340:     } else if (mode == DelegateMode.PrivateMsgSender) {
341: 341:       signer = ecrecover(
342: 342:         keccak256(abi.encodePacked(this, nonce, fee, gasAmount, to, value, data, mode, msg.sender)),
343: 343:         v,
344: 344:         r,
345: 345:         s
346: 346:       );
347: 347:       relayer = msg.sender;
348: 348:     } else if (mode == DelegateMode.PrivateTxOrigin) {
349: 349:       signer = ecrecover(
350: 350:         keccak256(abi.encodePacked(this, nonce, fee, gasAmount, to, value, data, mode, tx.origin)),
351: 351:         v,
352: 352:         r,
353: 353:         s
354: 354:       );
355: 355:       relayer = tx.origin;
356: 356:     } else {
357: 357:       revert();
358: 358:     }
359: 359: 
360: 360:     Account storage signerAccount = accounts[signer];
361: 361:     require(nonce == signerAccount.nonce);
362: 362:     emit IncreaseNonce(signer, signerAccount.nonce += 1);
363: 363: 
364: 364:     signerAccount.balance = signerAccount.balance.sub(value.add(fee));
365: 365:     accounts[to].balance += value;
366: 366:     if (fee != 0) {
367: 367:       accounts[relayer].balance += fee;
368: 368:       emit Transfer(signer, relayer, fee);
369: 369:     }
370: 370: 
371: 371:     if (!to.isAccount() && data.length >= 68) {
372: 372:       assembly {
373: 373:         mstore(add(data, 36), value)
374: 374:         mstore(add(data, 68), signer)
375: 375:       }
376: 376:       if (to.call.gas(gasAmount)(data)) {
377: 377:         emit Transfer(signer, to, value);
378: 378:       } else {
379: 379:         signerAccount.balance += value;
380: 380:         accounts[to].balance -= value;
381: 381:       }
382: 382:     } else {
383: 383:       emit Transfer(signer, to, value);
384: 384:     }
385: 385: 
386: 386:     return true;
387: 387:   }
388: 388: 
389: 389:   function directDebit(address debtor, address receiver) public view returns (DirectDebit) {
390: 390:     return accounts[debtor].instruments[receiver].directDebit;
391: 391:   }
392: 392: 
393: 393:   function setupDirectDebit(
394: 394:     address receiver,
395: 395:     DirectDebitInfo info
396: 396:   )
397: 397:     public
398: 398:     returns (bool)
399: 399:   {
400: 400:     accounts[msg.sender].instruments[receiver].directDebit = DirectDebit({
401: 401:       info: info,
402: 402:       epoch: 0
403: 403:     });
404: 404: 
405: 405:     emit SetupDirectDebit(msg.sender, receiver, info);
406: 406:     return true;
407: 407:   }
408: 408: 
409: 409:   function terminateDirectDebit(address receiver) public returns (bool) {
410: 410:     delete accounts[msg.sender].instruments[receiver].directDebit;
411: 411: 
412: 412:     emit TerminateDirectDebit(msg.sender, receiver);
413: 413:     return true;
414: 414:   }
415: 415: 
416: 416:   function withdrawDirectDebit(address debtor) public liquid canUseDirectDebit returns (bool) {
417: 417:     Account storage debtorAccount = accounts[debtor];
418: 418:     DirectDebit storage debit = debtorAccount.instruments[msg.sender].directDebit;
419: 419:     uint256 epoch = (block.timestamp.sub(debit.info.startTime) / debit.info.interval).add(1);
420: 420:     uint256 amount = epoch.sub(debit.epoch).mul(debit.info.amount);
421: 421:     require(amount > 0);
422: 422:     debtorAccount.balance = debtorAccount.balance.sub(amount);
423: 423:     accounts[msg.sender].balance += amount;
424: 424:     debit.epoch = epoch;
425: 425: 
426: 426:     emit Transfer(debtor, msg.sender, amount);
427: 427:     return true;
428: 428:   }
429: 429: 
430: 430:   function withdrawDirectDebit(address[] debtors, bool strict) public liquid canUseDirectDebit returns (bool result) {
431: 431:     Account storage receiverAccount = accounts[msg.sender];
432: 432:     result = true;
433: 433:     uint256 total;
434: 434: 
435: 435:     for (uint256 i = 0; i < debtors.length; i++) {
436: 436:       address debtor = debtors[i];
437: 437:       Account storage debtorAccount = accounts[debtor];
438: 438:       DirectDebit storage debit = debtorAccount.instruments[msg.sender].directDebit;
439: 439:       uint256 epoch = (block.timestamp.sub(debit.info.startTime) / debit.info.interval).add(1);
440: 440:       uint256 amount = epoch.sub(debit.epoch).mul(debit.info.amount);
441: 441:       require(amount > 0);
442: 442:       uint256 debtorBalance = debtorAccount.balance;
443: 443: 
444: 444:       if (amount > debtorBalance) {
445: 445:         if (strict) {
446: 446:           revert();
447: 447:         }
448: 448:         result = false;
449: 449:         emit WithdrawDirectDebitFailure(debtor, msg.sender);
450: 450:       } else {
451: 451:         debtorAccount.balance = debtorBalance - amount;
452: 452:         total += amount;
453: 453:         debit.epoch = epoch;
454: 454: 
455: 455:         emit Transfer(debtor, msg.sender, amount);
456: 456:       }
457: 457:     }
458: 458: 
459: 459:     receiverAccount.balance += total;
460: 460:   }
461: 461: }
462: 462: 