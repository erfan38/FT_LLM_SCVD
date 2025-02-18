1: 1: 1: 1: pragma solidity ^0.4.18;
2: 2: 2: 2: 
3: 3: 3: 3: 
4: 4: 4: 4: 
5: 5: 5: 5: 
6: 6: 6: 6: 
7: 7: 7: 7: 
8: 8: 8: 8: 
9: 9: 9: 9: 
10: 10: 10: 10: 
11: 11: 11: 11: 
12: 12: 12: 12: 
13: 13: 13: 13: 
14: 14: 14: 14: 
15: 15: 15: 15: 
16: 16: 16: 16: 
17: 17: 17: 17: 
18: 18: 18: 18: 
19: 19: 19: 19: 
20: 20: 20: 20: 
21: 21: 21: 21: 
22: 22: 22: 22: 
23: 23: 23: 23: 
24: 24: 24: 24: 
25: 25: 25: 25: 
26: 26: 26: 26: 
27: 27: 27: 27: 
28: 28: 28: 28: 
29: 29: 29: 29: 
30: 30: 30: 30: 
31: 31: 31: 31: 
32: 32: 32: 32: 
33: 33: 33: 33: contract Etheroll is usingOraclize, DSSafeAddSub {
34: 34: 34: 34:     
35: 35: 35: 35:      using strings for *;
36: 36: 36: 36: 
37: 37: 37: 37:     
38: 38: 38: 38: 
39: 39: 39: 39: 
40: 40: 40: 40:     modifier betIsValid(uint _betSize, uint _playerNumber) {      
41: 41: 41: 41:         if(((((_betSize * (100-(safeSub(_playerNumber,1)))) / (safeSub(_playerNumber,1))+_betSize))*houseEdge/houseEdgeDivisor)-_betSize > maxProfit || _betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber) throw;        
42: 42: 42: 42: 		_;
43: 43: 43: 43:     }
44: 44: 44: 44: 
45: 45: 45: 45:     
46: 46: 46: 46: 
47: 47: 47: 47: 
48: 48: 48: 48:     modifier gameIsActive {
49: 49: 49: 49:         if(gamePaused == true) throw;
50: 50: 50: 50: 		_;
51: 51: 51: 51:     }    
52: 52: 52: 52: 
53: 53: 53: 53:     
54: 54: 54: 54: 
55: 55: 55: 55: 
56: 56: 56: 56:     modifier payoutsAreActive {
57: 57: 57: 57:         if(payoutsPaused == true) throw;
58: 58: 58: 58: 		_;
59: 59: 59: 59:     }    
60: 60: 60: 60: 
61: 61: 61: 61:     
62: 62: 62: 62: 
63: 63: 63: 63: 
64: 64: 64: 64:     modifier onlyOraclize {
65: 65: 65: 65:         if (msg.sender != oraclize_cbAddress()) throw;
66: 66: 66: 66:         _;
67: 67: 67: 67:     }
68: 68: 68: 68: 
69: 69: 69: 69:     
70: 70: 70: 70: 
71: 71: 71: 71: 
72: 72: 72: 72:     modifier onlyOwner {
73: 73: 73: 73:          if (msg.sender != owner) throw;
74: 74: 74: 74:          _;
75: 75: 75: 75:     }
76: 76: 76: 76: 
77: 77: 77: 77:     
78: 78: 78: 78: 
79: 79: 79: 79: 
80: 80: 80: 80:     modifier onlyTreasury {
81: 81: 81: 81:          if (msg.sender != treasury) throw;
82: 82: 82: 82:          _;
83: 83: 83: 83:     }    
84: 84: 84: 84: 
85: 85: 85: 85:     
86: 86: 86: 86: 
87: 87: 87: 87:  
88: 88: 88: 88:     uint constant public maxProfitDivisor = 1000000;
89: 89: 89: 89:     uint constant public houseEdgeDivisor = 1000;    
90: 90: 90: 90:     uint constant public maxNumber = 99; 
91: 91: 91: 91:     uint constant public minNumber = 2;
92: 92: 92: 92: 	bool public gamePaused;
93: 93: 93: 93:     uint32 public gasForOraclize;
94: 94: 94: 94:     address public owner;
95: 95: 95: 95:     bool public payoutsPaused; 
96: 96: 96: 96:     address public treasury;
97: 97: 97: 97:     uint public contractBalance;
98: 98: 98: 98:     uint public houseEdge;     
99: 99: 99: 99:     uint public maxProfit;   
100: 100: 100: 100:     uint public maxProfitAsPercentOfHouse;                    
101: 101: 101: 101:     uint public minBet; 
102: 102: 102: 102:     
103: 103: 103: 103:     uint public totalBets = 263935;
104: 104: 104: 104:     uint public maxPendingPayouts;
105: 105: 105: 105:     
106: 106: 106: 106:     uint public totalWeiWon = 119805027051623961676537;
107: 107: 107: 107:     
108: 108: 108: 108:     uint public totalWeiWagered = 331721907637461976915056; 
109: 109: 109: 109:     uint public randomQueryID;
110: 110: 110: 110:     
111: 111: 111: 111: 
112: 112: 112: 112:     
113: 113: 113: 113: 
114: 114: 114: 114: 
115: 115: 115: 115:     mapping (bytes32 => address) playerAddress;
116: 116: 116: 116:     mapping (bytes32 => address) playerTempAddress;
117: 117: 117: 117:     mapping (bytes32 => bytes32) playerBetId;
118: 118: 118: 118:     mapping (bytes32 => uint) playerBetValue;
119: 119: 119: 119:     mapping (bytes32 => uint) playerTempBetValue;               
120: 120: 120: 120:     mapping (bytes32 => uint) playerDieResult;
121: 121: 121: 121:     mapping (bytes32 => uint) playerNumber;
122: 122: 122: 122:     mapping (address => uint) playerPendingWithdrawals;      
123: 123: 123: 123:     mapping (bytes32 => uint) playerProfit;
124: 124: 124: 124:     mapping (bytes32 => uint) playerTempReward;           
125: 125: 125: 125: 
126: 126: 126: 126:     
127: 127: 127: 127: 
128: 128: 128: 128: 
129: 129: 129: 129:     
130: 130: 130: 130:     event LogBet(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RewardValue, uint ProfitValue, uint BetValue, uint PlayerNumber, uint RandomQueryID);      
131: 131: 131: 131:     
132: 132: 132: 132:     
133: 133: 133: 133: 	event LogResult(uint indexed ResultSerialNumber, bytes32 indexed BetID, address indexed PlayerAddress, uint PlayerNumber, uint DiceResult, uint Value, int Status, bytes Proof);   
134: 134: 134: 134:     
135: 135: 135: 135:     event LogRefund(bytes32 indexed BetID, address indexed PlayerAddress, uint indexed RefundValue);
136: 136: 136: 136:     
137: 137: 137: 137:     event LogOwnerTransfer(address indexed SentToAddress, uint indexed AmountTransferred);               
138: 138: 138: 138: 
139: 139: 139: 139: 
140: 140: 140: 140:     
141: 141: 141: 141: 
142: 142: 142: 142: 
143: 143: 143: 143:     function Etheroll() {
144: 144: 144: 144: 
145: 145: 145: 145:         owner = msg.sender;
146: 146: 146: 146:         treasury = msg.sender;
147: 147: 147: 147:         oraclize_setNetwork(networkID_auto);        
148: 148: 148: 148:         
149: 149: 149: 149:         oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
150: 150: 150: 150:         
151: 151: 151: 151:         ownerSetHouseEdge(990);
152: 152: 152: 152:         
153: 153: 153: 153:         ownerSetMaxProfitAsPercentOfHouse(10000);
154: 154: 154: 154:         
155: 155: 155: 155:         ownerSetMinBet(100000000000000000);        
156: 156: 156: 156:                 
157: 157: 157: 157:         gasForOraclize = 235000;  
158: 158: 158: 158:         
159: 159: 159: 159:         oraclize_setCustomGasPrice(20000000000 wei);              
160: 160: 160: 160: 
161: 161: 161: 161:     }
162: 162: 162: 162: 
163: 163: 163: 163:     
164: 164: 164: 164: 
165: 165: 165: 165: 
166: 166: 166: 166: 
167: 167: 167: 167: 
168: 168: 168: 168:     function playerRollDice(uint rollUnder) public 
169: 169: 169: 169:         payable
170: 170: 170: 170:         gameIsActive
171: 171: 171: 171:         betIsValid(msg.value, rollUnder)
172: 172: 172: 172: 	{       
173: 173: 173: 173: 
174: 174: 174: 174:         
175: 175: 175: 175: 
176: 176: 176: 176: 
177: 177: 177: 177: 
178: 178: 178: 178:        
179: 179: 179: 179:         randomQueryID += 1;
180: 180: 180: 180:         string memory queryString1 = "[URL] ['json(https://api.random.org/json-rpc/1/invoke).result.random[\"serialNumber\",\"data\"]', '\\n{\"jsonrpc\":\"2.0\",\"method\":\"generateSignedIntegers\",\"params\":{\"apiKey\":${[decrypt] BJ8BMENGnafmVci9OE5n98MGZRU624r/QWOQi90YwuZzHL2jaK2SCf5L38gsyD3kG4CS3sjZVLPdprfbo+L9lUXQtVJb/8SPIjkMU3lk943v60Co2+oLMVgSRtNKAAzHS6DJPeLOYaDHLhbCLORoUt2fPKSp87E=},\"n\":1,\"min\":1,\"max\":100,\"replacement\":true,\"base\":10${[identity] \"}\"},\"id\":";
181: 181: 181: 181:         string memory queryString2 = uint2str(randomQueryID);
182: 182: 182: 182:         string memory queryString3 = "${[identity] \"}\"}']";
183: 183: 183: 183: 
184: 184: 184: 184:         string memory queryString1_2 = queryString1.toSlice().concat(queryString2.toSlice());
185: 185: 185: 185: 
186: 186: 186: 186:         string memory queryString1_2_3 = queryString1_2.toSlice().concat(queryString3.toSlice());
187: 187: 187: 187: 
188: 188: 188: 188:         bytes32 rngId = oraclize_query("nested", queryString1_2_3, gasForOraclize);   
189: 189: 189: 189:                  
190: 190: 190: 190:         
191: 191: 191: 191: 		playerBetId[rngId] = rngId;
192: 192: 192: 192:         
193: 193: 193: 193: 		playerNumber[rngId] = rollUnder;
194: 194: 194: 194:         
195: 195: 195: 195:         playerBetValue[rngId] = msg.value;
196: 196: 196: 196:         
197: 197: 197: 197:         playerAddress[rngId] = msg.sender;
198: 198: 198: 198:                              
199: 199: 199: 199:         playerProfit[rngId] = ((((msg.value * (100-(safeSub(rollUnder,1)))) / (safeSub(rollUnder,1))+msg.value))*houseEdge/houseEdgeDivisor)-msg.value;        
200: 200: 200: 200:         
201: 201: 201: 201:         maxPendingPayouts = safeAdd(maxPendingPayouts, playerProfit[rngId]);
202: 202: 202: 202:         
203: 203: 203: 203:         if(maxPendingPayouts >= contractBalance) throw;
204: 204: 204: 204:         
205: 205: 205: 205:         LogBet(playerBetId[rngId], playerAddress[rngId], safeAdd(playerBetValue[rngId], playerProfit[rngId]), playerProfit[rngId], playerBetValue[rngId], playerNumber[rngId], randomQueryID);          
206: 206: 206: 206: 
207: 207: 207: 207:     }   
208: 208: 208: 208:              
209: 209: 209: 209: 
210: 210: 210: 210:     
211: 211: 211: 211: 
212: 212: 212: 212: 
213: 213: 213: 213:     
214: 214: 214: 214: 	function __callback(bytes32 myid, string result, bytes proof) public   
215: 215: 215: 215: 		onlyOraclize
216: 216: 216: 216: 		payoutsAreActive
217: 217: 217: 217: 	{  
218: 218: 218: 218: 
219: 219: 219: 219:         
220: 220: 220: 220:         if (playerAddress[myid]==0x0) throw;
221: 221: 221: 221:         
222: 222: 222: 222:         
223: 223: 223: 223:         var sl_result = result.toSlice();
224: 224: 224: 224:         sl_result.beyond("[".toSlice()).until("]".toSlice());
225: 225: 225: 225:         uint serialNumberOfResult = parseInt(sl_result.split(', '.toSlice()).toString());          
226: 226: 226: 226: 
227: 227: 227: 227: 	    
228: 228: 228: 228:         playerDieResult[myid] = parseInt(sl_result.beyond("[".toSlice()).until("]".toSlice()).toString());        
229: 229: 229: 229:         
230: 230: 230: 230:         
231: 231: 231: 231:         playerTempAddress[myid] = playerAddress[myid];
232: 232: 232: 232:         
233: 233: 233: 233:         delete playerAddress[myid];
234: 234: 234: 234: 
235: 235: 235: 235:         
236: 236: 236: 236:         playerTempReward[myid] = playerProfit[myid];
237: 237: 237: 237:         
238: 238: 238: 238:         playerProfit[myid] = 0; 
239: 239: 239: 239: 
240: 240: 240: 240:         
241: 241: 241: 241:         maxPendingPayouts = safeSub(maxPendingPayouts, playerTempReward[myid]);         
242: 242: 242: 242: 
243: 243: 243: 243:         
244: 244: 244: 244:         playerTempBetValue[myid] = playerBetValue[myid];
245: 245: 245: 245:         
246: 246: 246: 246:         playerBetValue[myid] = 0; 
247: 247: 247: 247: 
248: 248: 248: 248:         
249: 249: 249: 249:         totalBets += 1;
250: 250: 250: 250: 
251: 251: 251: 251:         
252: 252: 252: 252:         totalWeiWagered += playerTempBetValue[myid];                                                           
253: 253: 253: 253: 
254: 254: 254: 254:         
255: 255: 255: 255: 
256: 256: 256: 256: 
257: 257: 257: 257: 
258: 258: 258: 258: 
259: 259: 259: 259:         if(playerDieResult[myid] == 0 || bytes(result).length == 0 || bytes(proof).length == 0){                                                     
260: 260: 260: 260: 
261: 261: 261: 261:              LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 3, proof);            
262: 262: 262: 262: 
263: 263: 263: 263:             
264: 264: 264: 264: 
265: 265: 265: 265: 
266: 266: 266: 266: 
267: 267: 267: 267: 
268: 268: 268: 268:             if(!playerTempAddress[myid].send(playerTempBetValue[myid])){
269: 269: 269: 269:                 LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 4, proof);              
270: 270: 270: 270:                 
271: 271: 271: 271:                 playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempBetValue[myid]);                        
272: 272: 272: 272:             }
273: 273: 273: 273: 
274: 274: 274: 274:             return;
275: 275: 275: 275:         }
276: 276: 276: 276: 
277: 277: 277: 277:         
278: 278: 278: 278: 
279: 279: 279: 279: 
280: 280: 280: 280: 
281: 281: 281: 281: 
282: 282: 282: 282: 
283: 283: 283: 283:         if(playerDieResult[myid] < playerNumber[myid]){ 
284: 284: 284: 284: 
285: 285: 285: 285:             
286: 286: 286: 286:             contractBalance = safeSub(contractBalance, playerTempReward[myid]); 
287: 287: 287: 287: 
288: 288: 288: 288:             
289: 289: 289: 289:             totalWeiWon = safeAdd(totalWeiWon, playerTempReward[myid]);              
290: 290: 290: 290: 
291: 291: 291: 291:             
292: 292: 292: 292:             playerTempReward[myid] = safeAdd(playerTempReward[myid], playerTempBetValue[myid]); 
293: 293: 293: 293: 
294: 294: 294: 294:             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 1, proof);                            
295: 295: 295: 295: 
296: 296: 296: 296:             
297: 297: 297: 297:             setMaxProfit();
298: 298: 298: 298:             
299: 299: 299: 299:             
300: 300: 300: 300: 
301: 301: 301: 301: 
302: 302: 302: 302: 
303: 303: 303: 303: 
304: 304: 304: 304:             if(!playerTempAddress[myid].send(playerTempReward[myid])){
305: 305: 305: 305:                 LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempReward[myid], 2, proof);                   
306: 306: 306: 306:                 
307: 307: 307: 307:                 playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], playerTempReward[myid]);                               
308: 308: 308: 308:             }
309: 309: 309: 309: 
310: 310: 310: 310:             return;
311: 311: 311: 311: 
312: 312: 312: 312:         }
313: 313: 313: 313: 
314: 314: 314: 314:         
315: 315: 315: 315: 
316: 316: 316: 316: 
317: 317: 317: 317: 
318: 318: 318: 318: 
319: 319: 319: 319:         if(playerDieResult[myid] >= playerNumber[myid]){
320: 320: 320: 320: 
321: 321: 321: 321:             LogResult(serialNumberOfResult, playerBetId[myid], playerTempAddress[myid], playerNumber[myid], playerDieResult[myid], playerTempBetValue[myid], 0, proof);                                
322: 322: 322: 322: 
323: 323: 323: 323:             
324: 324: 324: 324: 
325: 325: 325: 325: 
326: 326: 326: 326: 
327: 327: 327: 327: 
328: 328: 328: 328:             contractBalance = safeAdd(contractBalance, (playerTempBetValue[myid]-1));                                                                         
329: 329: 329: 329: 
330: 330: 330: 330:             
331: 331: 331: 331:             setMaxProfit(); 
332: 332: 332: 332: 
333: 333: 333: 333:             
334: 334: 334: 334: 
335: 335: 335: 335: 
336: 336: 336: 336:             if(!playerTempAddress[myid].send(1)){
337: 337: 337: 337:                                 
338: 338: 338: 338:                playerPendingWithdrawals[playerTempAddress[myid]] = safeAdd(playerPendingWithdrawals[playerTempAddress[myid]], 1);                                
339: 339: 339: 339:             }                                   
340: 340: 340: 340: 
341: 341: 341: 341:             return;
342: 342: 342: 342: 
343: 343: 343: 343:         }
344: 344: 344: 344: 
345: 345: 345: 345:     }
346: 346: 346: 346:     
347: 347: 347: 347:     
348: 348: 348: 348: 
349: 349: 349: 349: 
350: 350: 350: 350: 
351: 351: 351: 351:     function playerWithdrawPendingTransactions() public 
352: 352: 352: 352:         payoutsAreActive
353: 353: 353: 353:         returns (bool)
354: 354: 354: 354:      {
355: 355: 355: 355:         uint withdrawAmount = playerPendingWithdrawals[msg.sender];
356: 356: 356: 356:         playerPendingWithdrawals[msg.sender] = 0;
357: 357: 357: 357:         
358: 358: 358: 358:         if (msg.sender.call.value(withdrawAmount)()) {
359: 359: 359: 359:             return true;
360: 360: 360: 360:         } else {
361: 361: 361: 361:             
362: 362: 362: 362:             
363: 363: 363: 363:             playerPendingWithdrawals[msg.sender] = withdrawAmount;
364: 364: 364: 364:             return false;
365: 365: 365: 365:         }
366: 366: 366: 366:     }
367: 367: 367: 367: 
368: 368: 368: 368:     
369: 369: 369: 369:     function playerGetPendingTxByAddress(address addressToCheck) public constant returns (uint) {
370: 370: 370: 370:         return playerPendingWithdrawals[addressToCheck];
371: 371: 371: 371:     }
372: 372: 372: 372: 
373: 373: 373: 373:     
374: 374: 374: 374: 
375: 375: 375: 375: 
376: 376: 376: 376: 
377: 377: 377: 377:     function setMaxProfit() internal {
378: 378: 378: 378:         maxProfit = (contractBalance*maxProfitAsPercentOfHouse)/maxProfitDivisor;  
379: 379: 379: 379:     }      
380: 380: 380: 380: 
381: 381: 381: 381:     
382: 382: 382: 382: 
383: 383: 383: 383: 
384: 384: 384: 384:     function ()
385: 385: 385: 385:         payable
386: 386: 386: 386:         onlyTreasury
387: 387: 387: 387:     {
388: 388: 388: 388:         
389: 389: 389: 389:         contractBalance = safeAdd(contractBalance, msg.value);        
390: 390: 390: 390:         
391: 391: 391: 391:         setMaxProfit();
392: 392: 392: 392:     } 
393: 393: 393: 393: 
394: 394: 394: 394:     
395: 395: 395: 395:     function ownerSetCallbackGasPrice(uint newCallbackGasPrice) public 
396: 396: 396: 396: 		onlyOwner
397: 397: 397: 397: 	{
398: 398: 398: 398:         oraclize_setCustomGasPrice(newCallbackGasPrice);
399: 399: 399: 399:     }     
400: 400: 400: 400: 
401: 401: 401: 401:     
402: 402: 402: 402:     function ownerSetOraclizeSafeGas(uint32 newSafeGasToOraclize) public 
403: 403: 403: 403: 		onlyOwner
404: 404: 404: 404: 	{
405: 405: 405: 405:     	gasForOraclize = newSafeGasToOraclize;
406: 406: 406: 406:     }
407: 407: 407: 407: 
408: 408: 408: 408:     
409: 409: 409: 409:     function ownerUpdateContractBalance(uint newContractBalanceInWei) public 
410: 410: 410: 410: 		onlyOwner
411: 411: 411: 411:     {        
412: 412: 412: 412:        contractBalance = newContractBalanceInWei;
413: 413: 413: 413:     }    
414: 414: 414: 414: 
415: 415: 415: 415:     
416: 416: 416: 416:     function ownerSetHouseEdge(uint newHouseEdge) public 
417: 417: 417: 417: 		onlyOwner
418: 418: 418: 418:     {
419: 419: 419: 419:         houseEdge = newHouseEdge;
420: 420: 420: 420:     }
421: 421: 421: 421: 
422: 422: 422: 422:     
423: 423: 423: 423:     function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public 
424: 424: 424: 424: 		onlyOwner
425: 425: 425: 425:     {
426: 426: 426: 426:         
427: 427: 427: 427:         if(newMaxProfitAsPercent > 10000) throw;
428: 428: 428: 428:         maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
429: 429: 429: 429:         setMaxProfit();
430: 430: 430: 430:     }
431: 431: 431: 431: 
432: 432: 432: 432:     
433: 433: 433: 433:     function ownerSetMinBet(uint newMinimumBet) public 
434: 434: 434: 434: 		onlyOwner
435: 435: 435: 435:     {
436: 436: 436: 436:         minBet = newMinimumBet;
437: 437: 437: 437:     }       
438: 438: 438: 438: 
439: 439: 439: 439:     
440: 440: 440: 440:     function ownerTransferEther(address sendTo, uint amount) public 
441: 441: 441: 441: 		onlyOwner
442: 442: 442: 442:     {        
443: 443: 443: 443:         
444: 444: 444: 444:         contractBalance = safeSub(contractBalance, amount);		
445: 445: 445: 445:         
446: 446: 446: 446:         setMaxProfit();
447: 447: 447: 447:         if(!sendTo.send(amount)) throw;
448: 448: 448: 448:         LogOwnerTransfer(sendTo, amount); 
449: 449: 449: 449:     }
450: 450: 450: 450: 
451: 451: 451: 451:     
452: 452: 452: 452: 
453: 453: 453: 453: 
454: 454: 454: 454: 
455: 455: 455: 455: 
456: 456: 456: 456: 
457: 457: 457: 457: 
458: 458: 458: 458: 
459: 459: 459: 459:     function ownerRefundPlayer(bytes32 originalPlayerBetId, address sendTo, uint originalPlayerProfit, uint originalPlayerBetValue) public 
460: 460: 460: 460: 		onlyOwner
461: 461: 461: 461:     {        
462: 462: 462: 462:         
463: 463: 463: 463:         maxPendingPayouts = safeSub(maxPendingPayouts, originalPlayerProfit);
464: 464: 464: 464:         
465: 465: 465: 465:         if(!sendTo.send(originalPlayerBetValue)) throw;
466: 466: 466: 466:         
467: 467: 467: 467:         LogRefund(originalPlayerBetId, sendTo, originalPlayerBetValue);        
468: 468: 468: 468:     }    
469: 469: 469: 469: 
470: 470: 470: 470:     
471: 471: 471: 471:     function ownerPauseGame(bool newStatus) public 
472: 472: 472: 472: 		onlyOwner
473: 473: 473: 473:     {
474: 474: 474: 474: 		gamePaused = newStatus;
475: 475: 475: 475:     }
476: 476: 476: 476: 
477: 477: 477: 477:     
478: 478: 478: 478:     function ownerPausePayouts(bool newPayoutStatus) public 
479: 479: 479: 479: 		onlyOwner
480: 480: 480: 480:     {
481: 481: 481: 481: 		payoutsPaused = newPayoutStatus;
482: 482: 482: 482:     } 
483: 483: 483: 483: 
484: 484: 484: 484:     
485: 485: 485: 485:     function ownerSetTreasury(address newTreasury) public 
486: 486: 486: 486: 		onlyOwner
487: 487: 487: 487: 	{
488: 488: 488: 488:         treasury = newTreasury;
489: 489: 489: 489:     }         
490: 490: 490: 490: 
491: 491: 491: 491:     
492: 492: 492: 492:     function ownerChangeOwner(address newOwner) public 
493: 493: 493: 493: 		onlyOwner
494: 494: 494: 494: 	{
495: 495: 495: 495:         owner = newOwner;
496: 496: 496: 496:     }
497: 497: 497: 497: 
498: 498: 498: 498:     
499: 499: 499: 499:     function ownerkill() public 
500: 500: 500: 500: 		onlyOwner
501: 501: 501: 501: 	{
502: 502: 502: 502: 		suicide(owner);
503: 503: 503: 503: 	}    
504: 504: 504: 504: 
505: 505: 505: 505: 
506: 506: 506: 506: }