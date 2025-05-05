1: 1: pragma solidity ^0.4.2;
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
33: 33: contract Etheroll is usingOraclize, DSSafeAddSub {
34: 34:     
35: 35:      using strings for *;
36: 36: 
37: 37:     
38: 38: 
39: 39: 
40: 40:     modifier betIsValid(uint _betSize, uint _playerNumber) {      
41: 41:         if(((((_betSize * (100-(safeSub(_playerNumber,1)))) / (safeSub(_playerNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize > maxProfit || _betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber) throw;        
42: 42: 		_;
43: 43:     }
44: 44: 
45: 45:     
46: 46: 
47: 47: 
48: 48:     modifier gameIsActive {
49: 49:         if(gamePaused == true) throw;
50: 50: 		_;
51: 51:     }    
52: 52: 
53: 53:     
54: 54: 
55: 55: 
56: 56:     modifier payoutsAreActive {
57: 57:         if(payoutsPaused == true) throw;
58: 58: 		_;
59: 59:     }    
60: 60: 
61: 61:     
62: 62: 
63: 63: 
64: 64:     modifier onlyOraclize {
65: 65:         if (msg.sender != oraclize_cbAddress()) throw;
66: 66:         _;
67: 67:     }
68: 68: 
69: 69:     
70: 70: 
71: 71: 
72: 72:     modifier onlyOwner {
73: 73:          if (msg.sender != owner) throw;
74: 74:          _;
75: 75:     }
76: 76: 
77: 77:     
78: 78: 
79: 79: 
80: 80:     modifier onlyTreasury {
81: 81:          if (msg.sender != treasury) throw;
82: 82:          _;
83: 83:     }    
84: 84: 
85: 85:     
86: 86: 
87: 87:  
88: 88:     uint constant public maxProfitDivisor = 1000000;
89: 89:     uint constant public houseEdgeDivisor = 1000;    
90: 90:     uint constant public maxNumber = 99; 
91: 91:     uint constant public minNumber = 2;
92: 92: 	bool public gamePaused;
93: 93:     uint32 public gasForOraclize;
94: 94:     address public owner;
95: 95:     bool public payoutsPaused; 
96: 96:     address public treasury;
97: 97:     uint public contractBalance;
98: 98:     uint public houseEdge;     
99: 99:     uint public maxProfit;   
100: 100:     uint public maxProfitAsPercentOfHouse;                    
101: 101:     uint public minBet;       
102: 102:     int public totalBets;
103: 103:     uint public maxPendingPayouts;
104: 104:     uint public costToCallOraclizeInWei;
105: 105:     uint public totalWeiWon;
106: 106: 
107: 107:     
108: 108: 
109: 109: 
110: 110:     mapping (bytes32 => address) playerAddress;
111: 111:     mapping (bytes32 => address) playerTempAddress;
112: 112:     mapping (bytes32 => bytes32) playerBetId;
113: 113:     mapping (bytes32 => uint) playerBetValue;
114: 114:     mapping (bytes32 => uint) playerTempBetValue;  
115: 115:     mapping (bytes32 => uint) playerRandomResult;     
116: 116:     mapping (bytes32 => uint) playerDieResult;
117: 117:     mapping (bytes32 => uint) playerNumber;
118: 118:     mapping (address => uint) playerPendingWithdrawals;      
119: 119:     mapping (bytes32 => uint) playerProfit;
120: 120:     mapping (bytes32 => uint) playerTempReward;    
121: 121:         
122: 122: 
123: 123:     
124: 124: 
125: 125: 
126: 126:     
127: 127:     event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber);      
128: 128:     
129: 129:     
130: 130: 	event LogResult(uint indexed ResultSerialNumber, bytes32 indexed BetID, address indexed PlayerAddress, uint PlayerNumber, uint DiceResult, uint Value, int Status, bytes Proof);   
131: 131:     
132: 132:     event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
133: 133:     
134: 134:     event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);               
135: 135: 
136: 136: 
137: 137:     
138: 138: 
139: 139: 
140: 140:     function Etheroll() {
141: 141: 
142: 142:         owner = msg.sender;
143: 143:         treasury = msg.sender;
144: 144:         
145: 145:         oraclize_setNetwork(networkID_auto);        
146: 146:         
147: 147: 		oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
148: 148:         
149: 149:         ownerSetHouseEdge(990);
150: 150:         
151: 151:         ownerSetMaxProfitAsPercentOfHouse(10000);
152: 152:         
153: 153:         ownerSetMinBet(100000000000000000);        
154: 154:                 
155: 155:         gasForOraclize = 250000;        
156: 156: 
157: 157:     }
158: 158: 
159: 159:     
160: 160: 
161: 161: 
162: 162: 
163: 163: 
164: 164:     function playerRollDice(uint rollUnder) public 
165: 165:         payable
166: 166:         gameIsActive
167: 167:         betIsValid(msg.value, rollUnder)
168: 168: 	{        
169: 169:         
170: 170:         
171: 171: 
172: 172: 
173: 173: 
174: 174: 
175: 175:         bytes32 rngId = oraclize_query("nested", "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BGTHWM0eEfofomIQf6Yh0YwRS47jhBH19wfMIQEnth4KbVg+wC8V220JO04JisgluUoDyDdI/sv4mAlRNcTyZg6lP6l+ociWxEsN9R9K3iygXAna2Q6yYqnhYvPoxxg5cqzR8MCkpAJ/AQm0M0VldM77Hzz31Cw=},\"n\":1,\"min\":1,\"max\":100,\"replacement\":true,\"base\":10${[identity] \"}\"},\"id\":1${[identity] \"}\"}']", gasForOraclize);
176: 176:         
177: 177:         
178: 178:         contractBalance = safeSub(contractBalance, costToCallOraclizeInWei);	        
179: 179:         
180: 180:         totalBets += 1;
181: 181:         
182: 182: 		playerBetId[rngId] = rngId;
183: 183:         
184: 184: 		playerNumber[rngId] = rollUnder;
185: 185:         
186: 186:         playerBetValue[rngId] = msg.value;
187: 187:         
188: 188:         playerAddress[rngId] = msg.sender;
189: 189:                              
190: 190:         playerProfit[rngId] = ((((msg.value * (100-(safeSub(rollUnder,1)))) / (safeSub(rollUnder,1))+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;        
191: 191:         
192: 192:         maxPendingPayouts = safeAdd(maxPendingPayouts, playerProfit[rngId]);
193: 193:         
194: 194:         if(maxPendingPayouts >= contractBalance) throw;
195: 195:         
196: 196:         LogBet(playerBetId[rngId], playerAddress[rngId], safeAdd(playerBetValue[rngId], playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumber[rngId]);          
197: 197: 
198: 198:     }   
199: 199:              
200: 200: 
201: 201:     
202: 202: 
203: 203: 
204: 204:     
205: 205: 	function __callback(bytes32 myid, string result, bytes proof) public   
206: 206: 		onlyOraclize
207: 207: 		payoutsAreActive
208: 208: 	{  
209: 209: 
210: 210:         
211: 211:         if (playerAddress[myid]==0x0) throw;
212: 212:         
213: 213:         
214: 214:         var sl_result = result.toSlice();
215: 215:         sl_result.beyond("[".toSlice()).until("]".toSlice());
216: 216:         uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());          
217: 217: 
218: 218: 	    
219: 219:         playerRandomResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());
220: 220:         
221: 221:         
222: 222: 
223: 223: 
224: 224:         playerDieResult[myid] = uint(sha3(playerRandomResult[myid], proof)) % 100 + 1;
225: 225:         
226: 226:         
227: 227:         playerTempAddress[myid] = playerAddress[myid];
228: 228:         
229: 229:         delete playerAddress[myid];
230: 230: 
231: 231:         
232: 232:         playerTempReward[myid] = playerProfit[myid];
233: 233:         
234: 234:         playerProfit[myid] = 0; 
235: 235: 
236: 236:         
237: 237:         maxPendingPayouts = safeSub(maxPendingPayouts, playerTempReward[myid]);         
238: 238: 
239: 239:         
240: 240:         playerTempBetValue[myid] = playerBetValue[myid];
241: 241:         
242: 242:         playerBetValue[myid] = 0;                                             
243: 243: 
244: 244:         
245: 245: 
246: 246: 
247: 247: 
248: 248: 
249: 249:         if(playerDieResult[myid]==0){                                
250: 250: 
251: 251:              LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 3, proof);            
252: 252: 
253: 253:             
254: 254: 
255: 255: 
256: 256: 
257: 257: 
258: 258:             if(!playerTempAddress[myid].send(playerTempBetValue[myid])){
259: 259:                 LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 4, proof);              
260: 260:                 
261: 261:                 playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);                        
262: 262:             }
263: 263: 
264: 264:             return;
265: 265:         }
266: 266: 
267: 267:         
268: 268: 
269: 269: 
270: 270: 
271: 271: 
272: 272: 
273: 273:         if(playerDieResult[myid] < playerNumber[myid]){ 
274: 274: 
275: 275:             
276: 276:             contractBalance = safeSub(contractBalance, playerTempReward[myid]); 
277: 277: 
278: 278:             
279: 279:             totalWeiWon = safeAdd(totalWeiWon, playerTempReward[myid]);              
280: 280: 
281: 281:             
282: 282:             playerTempReward[myid] = safeAdd(playerTempReward[myid], playerTempBetValue[myid]); 
283: 283: 
284: 284:             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 1, proof);                            
285: 285: 
286: 286:             
287: 287:             setMaxProfit();
288: 288:             
289: 289:             
290: 290: 
291: 291: 
292: 292: 
293: 293: 
294: 294:             if(!playerTempAddress[myid].send(playerTempReward[myid])){
295: 295:                 LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 2, proof);                   
296: 296:                 
297: 297:                 playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);                               
298: 298:             }
299: 299: 
300: 300:             return;
301: 301: 
302: 302:         }
303: 303: 
304: 304:         
305: 305: 
306: 306: 
307: 307: 
308: 308: 
309: 309:         if(playerDieResult[myid] >= playerNumber[myid]){
310: 310: 
311: 311:             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 0, proof);                                
312: 312: 
313: 313:             
314: 314: 
315: 315: 
316: 316: 
317: 317: 
318: 318:             contractBalance = safeAdd(contractBalance, (playerTempBetValue[myid]-1));                                                                         
319: 319: 
320: 320:             
321: 321:             setMaxProfit(); 
322: 322: 
323: 323:             
324: 324: 
325: 325: 
326: 326:             if(!playerTempAddress[myid].send(1)){
327: 327:                                 
328: 328:                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);                                
329: 329:             }                                   
330: 330: 
331: 331:             return;
332: 332: 
333: 333:         }
334: 334: 
335: 335:     }
336: 336:     
337: 337:     
338: 338: 
339: 339: 
340: 340: 
341: 341:     function playerWithdrawPendingTransactions() public 
342: 342:         payoutsAreActive
343: 343:         returns (bool)
344: 344:      {
345: 345:         uint withdrawAmount = playerPendingWithdrawals[msg.sender];
346: 346:         playerPendingWithdrawals[msg.sender] = 0;
347: 347:         
348: 348:         if (msg.sender.call.value(withdrawAmount)()) {
349: 349:             return true;
350: 350:         } else {
351: 351:             
352: 352:             
353: 353:             playerPendingWithdrawals[msg.sender] = withdrawAmount;
354: 354:             return false;
355: 355:         }
356: 356:     }
357: 357: 
358: 358:     
359: 359:     function playerGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
360: 360:         return playerPendingWithdrawals[addressToCheck];
361: 361:     }
362: 362: 
363: 363:     
364: 364: 
365: 365: 
366: 366: 
367: 367:     function setMaxProfit() internal {
368: 368:         maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;  
369: 369:     }   
370: 370: 
371: 371:     
372: 372: 
373: 373: 
374: 374:     function ()
375: 375:         payable
376: 376:         onlyTreasury
377: 377:     {
378: 378:         
379: 379:         contractBalance = safeAdd(contractBalance, msg.value);        
380: 380:         
381: 381:         setMaxProfit();
382: 382:     } 
383: 383: 
384: 384:     
385: 385:     function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 
386: 386: 		onlyOwner
387: 387: 	{
388: 388:     	gasForOraclize = newSafeGasToOraclize;
389: 389:     }
390: 390: 
391: 391:     
392: 392:     function ownerUpdateCostToCallOraclize(uint newCostToCallOraclizeInWei) public 
393: 393: 		onlyOwner
394: 394:     {        
395: 395:        costToCallOraclizeInWei = newCostToCallOraclizeInWei;
396: 396:     }     
397: 397: 
398: 398:     
399: 399:     function ownerSetHouseEdge(uint newHouseEdge) public 
400: 400: 		onlyOwner
401: 401:     {
402: 402:         houseEdge = newHouseEdge;
403: 403:     }
404: 404: 
405: 405:     
406: 406:     function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public 
407: 407: 		onlyOwner
408: 408:     {
409: 409:         
410: 410:         if(newMaxProfitAsPercent > 10000) throw;
411: 411:         maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
412: 412:         setMaxProfit();
413: 413:     }
414: 414: 
415: 415:     
416: 416:     function ownerSetMinBet(uint newMinimumBet) public 
417: 417: 		onlyOwner
418: 418:     {
419: 419:         minBet = newMinimumBet;
420: 420:     }       
421: 421: 
422: 422:     
423: 423:     function ownerTransferEther(address sendTo, uint amount) public 
424: 424: 		onlyOwner
425: 425:     {        
426: 426:         
427: 427:         contractBalance = safeSub(contractBalance, amount);		
428: 428:         
429: 429:         setMaxProfit();
430: 430:         if(!sendTo.send(amount)) throw;
431: 431:         LogOwnerTransfer(sendTo, amount); 
432: 432:     }
433: 433: 
434: 434:     
435: 435: 
436: 436: 
437: 437: 
438: 438: 
439: 439: 
440: 440: 
441: 441: 
442: 442:     function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public 
443: 443: 		onlyOwner
444: 444:     {        
445: 445:         
446: 446:         maxPendingPayouts = safeSub(maxPendingPayouts, originalPlayerProfit);
447: 447:         
448: 448:         if(!sendTo.send(originalPlayerBetValue)) throw;
449: 449:         
450: 450:         LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);        
451: 451:     }    
452: 452: 
453: 453:     
454: 454:     function ownerPauseGame(bool newStatus) public 
455: 455: 		onlyOwner
456: 456:     {
457: 457: 		gamePaused = newStatus;
458: 458:     }
459: 459: 
460: 460:     
461: 461:     function ownerPausePayouts(bool newPayoutStatus) public 
462: 462: 		onlyOwner
463: 463:     {
464: 464: 		payoutsPaused = newPayoutStatus;
465: 465:     } 
466: 466: 
467: 467:     
468: 468:     function ownerSetTreasury(address newTreasury) public 
469: 469: 		onlyOwner
470: 470: 	{
471: 471:         treasury = newTreasury;
472: 472:     }         
473: 473: 
474: 474:     
475: 475:     function ownerChangeOwner(address newOwner) public 
476: 476: 		onlyOwner
477: 477: 	{
478: 478:         owner = newOwner;
479: 479:     }
480: 480: 
481: 481:     
482: 482:     function ownerkill() public 
483: 483: 		onlyOwner
484: 484: 	{
485: 485: 		suicide(owner);
486: 486: 	}    
487: 487: 
488: 488: 
489: 489: }