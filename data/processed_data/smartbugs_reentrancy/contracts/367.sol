1: pragma solidity ^0.4.2;
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: 
10: 
11: 
12: 
13: 
14: 
15: 
16: 
17: 
18: 
19: 
20: 
21: 
22: 
23: 
24: 
25: 
26: 
27: 
28: 
29: 
30: 
31: 
32: 
33: contract Etheroll is usingOraclize, DSSafeAddSub {
34:     
35:      using strings for *;
36: 
37:     
38: 
39: 
40:     modifier betIsValid(uint _betSize, uint _playerNumber) {      
41:         if(((((_betSize * (100-(safeSub(_playerNumber,1)))) / (safeSub(_playerNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize > maxProfit || _betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber) throw;        
42: 		_;
43:     }
44: 
45:     
46: 
47: 
48:     modifier gameIsActive {
49:         if(gamePaused == true) throw;
50: 		_;
51:     }    
52: 
53:     
54: 
55: 
56:     modifier payoutsAreActive {
57:         if(payoutsPaused == true) throw;
58: 		_;
59:     }    
60: 
61:     
62: 
63: 
64:     modifier onlyOraclize {
65:         if (msg.sender != oraclize_cbAddress()) throw;
66:         _;
67:     }
68: 
69:     
70: 
71: 
72:     modifier onlyOwner {
73:          if (msg.sender != owner) throw;
74:          _;
75:     }
76: 
77:     
78: 
79: 
80:     modifier onlyTreasury {
81:          if (msg.sender != treasury) throw;
82:          _;
83:     }    
84: 
85:     
86: 
87:  
88:     uint constant public maxProfitDivisor = 1000000;
89:     uint constant public houseEdgeDivisor = 1000;    
90:     uint constant public maxNumber = 99; 
91:     uint constant public minNumber = 2;
92: 	bool public gamePaused;
93:     uint32 public gasForOraclize;
94:     address public owner;
95:     bool public payoutsPaused; 
96:     address public treasury;
97:     uint public contractBalance;
98:     uint public houseEdge;     
99:     uint public maxProfit;   
100:     uint public maxProfitAsPercentOfHouse;                    
101:     uint public minBet;       
102:     int public totalBets;
103:     uint public maxPendingPayouts;
104:     uint public costToCallOraclizeInWei;
105:     uint public totalWeiWon;
106: 
107:     
108: 
109: 
110:     mapping (bytes32 => address) playerAddress;
111:     mapping (bytes32 => address) playerTempAddress;
112:     mapping (bytes32 => bytes32) playerBetId;
113:     mapping (bytes32 => uint) playerBetValue;
114:     mapping (bytes32 => uint) playerTempBetValue;  
115:     mapping (bytes32 => uint) playerRandomResult;     
116:     mapping (bytes32 => uint) playerDieResult;
117:     mapping (bytes32 => uint) playerNumber;
118:     mapping (address => uint) playerPendingWithdrawals;      
119:     mapping (bytes32 => uint) playerProfit;
120:     mapping (bytes32 => uint) playerTempReward;    
121:         
122: 
123:     
124: 
125: 
126:     
127:     event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber);      
128:     
129:     
130: 	event LogResult(uint indexed ResultSerialNumber, bytes32 indexed BetID, address indexed PlayerAddress, uint PlayerNumber, uint DiceResult, uint Value, int Status, bytes Proof);   
131:     
132:     event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
133:     
134:     event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);               
135: 
136: 
137:     
138: 
139: 
140:     function Etheroll() {
141: 
142:         owner = msg.sender;
143:         treasury = msg.sender;
144:         
145:         oraclize_setNetwork(networkID_auto);        
146:         
147: 		oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
148:         
149:         ownerSetHouseEdge(990);
150:         
151:         ownerSetMaxProfitAsPercentOfHouse(10000);
152:         
153:         ownerSetMinBet(100000000000000000);        
154:                 
155:         gasForOraclize = 250000;        
156: 
157:     }
158: 
159:     
160: 
161: 
162: 
163: 
164:     function playerRollDice(uint rollUnder) public 
165:         payable
166:         gameIsActive
167:         betIsValid(msg.value, rollUnder)
168: 	{        
169:         
170:         
171: 
172: 
173: 
174: 
175:         bytes32 rngId = oraclize_query("nested", "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BGTHWM0eEfofomIQf6Yh0YwRS47jhBH19wfMIQEnth4KbVg+wC8V220JO04JisgluUoDyDdI/sv4mAlRNcTyZg6lP6l+ociWxEsN9R9K3iygXAna2Q6yYqnhYvPoxxg5cqzR8MCkpAJ/AQm0M0VldM77Hzz31Cw=},\"n\":1,\"min\":1,\"max\":100,\"replacement\":true,\"base\":10${[identity] \"}\"},\"id\":1${[identity] \"}\"}']", gasForOraclize);
176:         
177:         
178:         contractBalance = safeSub(contractBalance, costToCallOraclizeInWei);	        
179:         
180:         totalBets += 1;
181:         
182: 		playerBetId[rngId] = rngId;
183:         
184: 		playerNumber[rngId] = rollUnder;
185:         
186:         playerBetValue[rngId] = msg.value;
187:         
188:         playerAddress[rngId] = msg.sender;
189:                              
190:         playerProfit[rngId] = ((((msg.value * (100-(safeSub(rollUnder,1)))) / (safeSub(rollUnder,1))+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;        
191:         
192:         maxPendingPayouts = safeAdd(maxPendingPayouts, playerProfit[rngId]);
193:         
194:         if(maxPendingPayouts >= contractBalance) throw;
195:         
196:         LogBet(playerBetId[rngId], playerAddress[rngId], safeAdd(playerBetValue[rngId], playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumber[rngId]);          
197: 
198:     }   
199:              
200: 
201:     
202: 
203: 
204:     
205: 	function __callback(bytes32 myid, string result, bytes proof) public   
206: 		onlyOraclize
207: 		payoutsAreActive
208: 	{  
209: 
210:         
211:         if (playerAddress[myid]==0x0) throw;
212:         
213:         
214:         var sl_result = result.toSlice();
215:         sl_result.beyond("[".toSlice()).until("]".toSlice());
216:         uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());          
217: 
218: 	    
219:         playerRandomResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());
220:         
221:         
222: 
223: 
224:         playerDieResult[myid] = uint(sha3(playerRandomResult[myid], proof)) % 100 + 1;
225:         
226:         
227:         playerTempAddress[myid] = playerAddress[myid];
228:         
229:         delete playerAddress[myid];
230: 
231:         
232:         playerTempReward[myid] = playerProfit[myid];
233:         
234:         playerProfit[myid] = 0; 
235: 
236:         
237:         maxPendingPayouts = safeSub(maxPendingPayouts, playerTempReward[myid]);         
238: 
239:         
240:         playerTempBetValue[myid] = playerBetValue[myid];
241:         
242:         playerBetValue[myid] = 0;                                             
243: 
244:         
245: 
246: 
247: 
248: 
249:         if(playerDieResult[myid]==0){                                
250: 
251:              LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 3, proof);            
252: 
253:             
254: 
255: 
256: 
257: 
258:             if(!playerTempAddress[myid].send(playerTempBetValue[myid])){
259:                 LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 4, proof);              
260:                 
261:                 playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);                        
262:             }
263: 
264:             return;
265:         }
266: 
267:         
268: 
269: 
270: 
271: 
272: 
273:         if(playerDieResult[myid] < playerNumber[myid]){ 
274: 
275:             
276:             contractBalance = safeSub(contractBalance, playerTempReward[myid]); 
277: 
278:             
279:             totalWeiWon = safeAdd(totalWeiWon, playerTempReward[myid]);              
280: 
281:             
282:             playerTempReward[myid] = safeAdd(playerTempReward[myid], playerTempBetValue[myid]); 
283: 
284:             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 1, proof);                            
285: 
286:             
287:             setMaxProfit();
288:             
289:             
290: 
291: 
292: 
293: 
294:             if(!playerTempAddress[myid].send(playerTempReward[myid])){
295:                 LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 2, proof);                   
296:                 
297:                 playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);                               
298:             }
299: 
300:             return;
301: 
302:         }
303: 
304:         
305: 
306: 
307: 
308: 
309:         if(playerDieResult[myid] >= playerNumber[myid]){
310: 
311:             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 0, proof);                                
312: 
313:             
314: 
315: 
316: 
317: 
318:             contractBalance = safeAdd(contractBalance, (playerTempBetValue[myid]-1));                                                                         
319: 
320:             
321:             setMaxProfit(); 
322: 
323:             
324: 
325: 
326:             if(!playerTempAddress[myid].send(1)){
327:                                 
328:                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);                                
329:             }                                   
330: 
331:             return;
332: 
333:         }
334: 
335:     }
336:     
337:     
338: 
339: 
340: 
341:     function playerWithdrawPendingTransactions() public 
342:         payoutsAreActive
343:         returns (bool)
344:      {
345:         uint withdrawAmount = playerPendingWithdrawals[msg.sender];
346:         playerPendingWithdrawals[msg.sender] = 0;
347:         
348:         if (msg.sender.call.value(withdrawAmount)()) {
349:             return true;
350:         } else {
351:             
352:             
353:             playerPendingWithdrawals[msg.sender] = withdrawAmount;
354:             return false;
355:         }
356:     }
357: 
358:     
359:     function playerGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
360:         return playerPendingWithdrawals[addressToCheck];
361:     }
362: 
363:     
364: 
365: 
366: 
367:     function setMaxProfit() internal {
368:         maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;  
369:     }   
370: 
371:     
372: 
373: 
374:     function ()
375:         payable
376:         onlyTreasury
377:     {
378:         
379:         contractBalance = safeAdd(contractBalance, msg.value);        
380:         
381:         setMaxProfit();
382:     } 
383: 
384:     
385:     function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 
386: 		onlyOwner
387: 	{
388:     	gasForOraclize = newSafeGasToOraclize;
389:     }
390: 
391:     
392:     function ownerUpdateCostToCallOraclize(uint newCostToCallOraclizeInWei) public 
393: 		onlyOwner
394:     {        
395:        costToCallOraclizeInWei = newCostToCallOraclizeInWei;
396:     }     
397: 
398:     
399:     function ownerSetHouseEdge(uint newHouseEdge) public 
400: 		onlyOwner
401:     {
402:         houseEdge = newHouseEdge;
403:     }
404: 
405:     
406:     function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public 
407: 		onlyOwner
408:     {
409:         
410:         if(newMaxProfitAsPercent > 10000) throw;
411:         maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
412:         setMaxProfit();
413:     }
414: 
415:     
416:     function ownerSetMinBet(uint newMinimumBet) public 
417: 		onlyOwner
418:     {
419:         minBet = newMinimumBet;
420:     }       
421: 
422:     
423:     function ownerTransferEther(address sendTo, uint amount) public 
424: 		onlyOwner
425:     {        
426:         
427:         contractBalance = safeSub(contractBalance, amount);		
428:         
429:         setMaxProfit();
430:         if(!sendTo.send(amount)) throw;
431:         LogOwnerTransfer(sendTo, amount); 
432:     }
433: 
434:     
435: 
436: 
437: 
438: 
439: 
440: 
441: 
442:     function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public 
443: 		onlyOwner
444:     {        
445:         
446:         maxPendingPayouts = safeSub(maxPendingPayouts, originalPlayerProfit);
447:         
448:         if(!sendTo.send(originalPlayerBetValue)) throw;
449:         
450:         LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);        
451:     }    
452: 
453:     
454:     function ownerPauseGame(bool newStatus) public 
455: 		onlyOwner
456:     {
457: 		gamePaused = newStatus;
458:     }
459: 
460:     
461:     function ownerPausePayouts(bool newPayoutStatus) public 
462: 		onlyOwner
463:     {
464: 		payoutsPaused = newPayoutStatus;
465:     } 
466: 
467:     
468:     function ownerSetTreasury(address newTreasury) public 
469: 		onlyOwner
470: 	{
471:         treasury = newTreasury;
472:     }         
473: 
474:     
475:     function ownerChangeOwner(address newOwner) public 
476: 		onlyOwner
477: 	{
478:         owner = newOwner;
479:     }
480: 
481:     
482:     function ownerkill() public 
483: 		onlyOwner
484: 	{
485: 		suicide(owner);
486: 	}    
487: 
488: 
489: }