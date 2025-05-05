1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: contract ConverterRamp is Ownable {
6: 6:     using LrpSafeMath for uint256;
7: 7: 
8: 8:     address public constant ETH_ADDRESS = 0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
9: 9:     uint256 public constant AUTO_MARGIN = 1000001;
10: 10: 
11: 11:     uint256 public constant I_MARGIN_SPEND = 0;
12: 12:     uint256 public constant I_MAX_SPEND = 1;
13: 13:     uint256 public constant I_REBUY_THRESHOLD = 2;
14: 14: 
15: 15:     uint256 public constant I_ENGINE = 0;
16: 16:     uint256 public constant I_INDEX = 1;
17: 17: 
18: 18:     uint256 public constant I_PAY_AMOUNT = 2;
19: 19:     uint256 public constant I_PAY_FROM = 3;
20: 20: 
21: 21:     uint256 public constant I_LEND_COSIGNER = 2;
22: 22: 
23: 23:     event RequiredRebuy(address token, uint256 amount);
24: 24:     event Return(address token, address to, uint256 amount);
25: 25:     event OptimalSell(address token, uint256 amount);
26: 26:     event RequiredRcn(uint256 required);
27: 27:     event RunAutoMargin(uint256 loops, uint256 increment);
28: 28: 
29: 29:     function pay(
30: 30:         TokenConverter converter,
31: 31:         Token fromToken,
32: 32:         bytes32[4] loanParams,
33: 33:         bytes oracleData,
34: 34:         uint256[3] convertRules
35: 35:     ) external payable returns (bool) {
36: 36:         Token rcn = NanoLoanEngine(address(loanParams[I_ENGINE])).rcn();
37: 37: 
38: 38:         uint256 initialBalance = rcn.balanceOf(this);
39: 39:         uint256 requiredRcn = getRequiredRcnPay(loanParams, oracleData);
40: 40:         emit RequiredRcn(requiredRcn);
41: 41: 
42: 42:         uint256 optimalSell = getOptimalSell(converter, fromToken, rcn, requiredRcn, convertRules[I_MARGIN_SPEND]);
43: 43:         emit OptimalSell(fromToken, optimalSell);
44: 44: 
45: 45:         pullAmount(fromToken, optimalSell);
46: 46:         uint256 bought = convertSafe(converter, fromToken, rcn, optimalSell);
47: 47: 
48: 48:         
49: 49:         require(
50: 50:             executeOptimalPay({
51: 51:                 params: loanParams,
52: 52:                 oracleData: oracleData,
53: 53:                 rcnToPay: bought
54: 54:             }),
55: 55:             "Error paying the loan"
56: 56:         );
57: 57: 
58: 58:         require(
59: 59:             rebuyAndReturn({
60: 60:                 converter: converter,
61: 61:                 fromToken: rcn,
62: 62:                 toToken: fromToken,
63: 63:                 amount: rcn.balanceOf(this) - initialBalance,
64: 64:                 spentAmount: optimalSell,
65: 65:                 convertRules: convertRules
66: 66:             }),
67: 67:             "Error rebuying the tokens"
68: 68:         );
69: 69: 
70: 70:         require(rcn.balanceOf(this) == initialBalance, "Converter balance has incremented");
71: 71:         return true;
72: 72:     }
73: 73: 
74: 74:     function requiredLendSell(
75: 75:         TokenConverter converter,
76: 76:         Token fromToken,
77: 77:         bytes32[3] loanParams,
78: 78:         bytes oracleData,
79: 79:         bytes cosignerData,
80: 80:         uint256[3] convertRules
81: 81:     ) external view returns (uint256) {
82: 82:         Token rcn = NanoLoanEngine(address(loanParams[0])).rcn();
83: 83:         return getOptimalSell(
84: 84:             converter,
85: 85:             fromToken,
86: 86:             rcn,
87: 87:             getRequiredRcnLend(loanParams, oracleData, cosignerData),
88: 88:             convertRules[I_MARGIN_SPEND]
89: 89:         );
90: 90:     }
91: 91: 
92: 92:     function requiredPaySell(
93: 93:         TokenConverter converter,
94: 94:         Token fromToken,
95: 95:         bytes32[4] loanParams,
96: 96:         bytes oracleData,
97: 97:         uint256[3] convertRules
98: 98:     ) external view returns (uint256) {
99: 99:         Token rcn = NanoLoanEngine(address(loanParams[0])).rcn();
100: 100:         return getOptimalSell(
101: 101:             converter,
102: 102:             fromToken,
103: 103:             rcn,
104: 104:             getRequiredRcnPay(loanParams, oracleData),
105: 105:             convertRules[I_MARGIN_SPEND]
106: 106:         );
107: 107:     }
108: 108: 
109: 109:     function lend(
110: 110:         TokenConverter converter,
111: 111:         Token fromToken,
112: 112:         bytes32[3] loanParams,
113: 113:         bytes oracleData,
114: 114:         bytes cosignerData,
115: 115:         uint256[3] convertRules
116: 116:     ) external payable returns (bool) {
117: 117:         Token rcn = NanoLoanEngine(address(loanParams[0])).rcn();
118: 118:         uint256 initialBalance = rcn.balanceOf(this);
119: 119:         uint256 requiredRcn = getRequiredRcnLend(loanParams, oracleData, cosignerData);
120: 120:         emit RequiredRcn(requiredRcn);
121: 121: 
122: 122:         uint256 optimalSell = getOptimalSell(converter, fromToken, rcn, requiredRcn, convertRules[I_MARGIN_SPEND]);
123: 123:         emit OptimalSell(fromToken, optimalSell);
124: 124: 
125: 125:         pullAmount(fromToken, optimalSell);      
126: 126:         uint256 bought = convertSafe(converter, fromToken, rcn, optimalSell);
127: 127: 
128: 128:         
129: 129:         require(rcn.approve(address(loanParams[0]), bought));
130: 130:         require(executeLend(loanParams, oracleData, cosignerData), "Error lending the loan");
131: 131:         require(rcn.approve(address(loanParams[0]), 0));
132: 132:         require(executeTransfer(loanParams, msg.sender), "Error transfering the loan");
133: 133: 
134: 134:         require(
135: 135:             rebuyAndReturn({
136: 136:                 converter: converter,
137: 137:                 fromToken: rcn,
138: 138:                 toToken: fromToken,
139: 139:                 amount: rcn.balanceOf(this) - initialBalance,
140: 140:                 spentAmount: optimalSell,
141: 141:                 convertRules: convertRules
142: 142:             }),
143: 143:             "Error rebuying the tokens"
144: 144:         );
145: 145: 
146: 146:         require(rcn.balanceOf(this) == initialBalance);
147: 147:         return true;
148: 148:     }
149: 149: 
150: 150:     function pullAmount(
151: 151:         Token token,
152: 152:         uint256 amount
153: 153:     ) private {
154: 154:         if (token == ETH_ADDRESS) {
155: 155:             require(msg.value >= amount, "Error pulling ETH amount");
156: 156:             if (msg.value > amount) {
157: 157:                 msg.sender.transfer(msg.value - amount);
158: 158:             }
159: 159:         } else {
160: 160:             require(token.transferFrom(msg.sender, this, amount), "Error pulling Token amount");
161: 161:         }
162: 162:     }
163: 163: 
164: 164:     function transfer(
165: 165:         Token token,
166: 166:         address to,
167: 167:         uint256 amount
168: 168:     ) private {
169: 169:         if (token == ETH_ADDRESS) {
170: 170:             to.transfer(amount);
171: 171:         } else {
172: 172:             require(token.transfer(to, amount), "Error sending tokens");
173: 173:         }
174: 174:     }
175: 175: 
176: 176:     function rebuyAndReturn(
177: 177:         TokenConverter converter,
178: 178:         Token fromToken,
179: 179:         Token toToken,
180: 180:         uint256 amount,
181: 181:         uint256 spentAmount,
182: 182:         uint256[3] memory convertRules
183: 183:     ) internal returns (bool) {
184: 184:         uint256 threshold = convertRules[I_REBUY_THRESHOLD];
185: 185:         uint256 bought = 0;
186: 186: 
187: 187:         if (amount != 0) {
188: 188:             if (amount > threshold) {
189: 189:                 bought = convertSafe(converter, fromToken, toToken, amount);
190: 190:                 emit RequiredRebuy(toToken, amount);
191: 191:                 emit Return(toToken, msg.sender, bought);
192: 192:                 transfer(toToken, msg.sender, bought);
193: 193:             } else {
194: 194:                 emit Return(fromToken, msg.sender, amount);
195: 195:                 transfer(fromToken, msg.sender, amount);
196: 196:             }
197: 197:         }
198: 198: 
199: 199:         uint256 maxSpend = convertRules[I_MAX_SPEND];
200: 200:         require(spentAmount.safeSubtract(bought) <= maxSpend || maxSpend == 0, "Max spend exceeded");
201: 201:         
202: 202:         return true;
203: 203:     } 
204: 204: 
205: 205:     function getOptimalSell(
206: 206:         TokenConverter converter,
207: 207:         Token fromToken,
208: 208:         Token toToken,
209: 209:         uint256 requiredTo,
210: 210:         uint256 extraSell
211: 211:     ) internal returns (uint256 sellAmount) {
212: 212:         uint256 sellRate = (10 ** 18 * converter.getReturn(toToken, fromToken, requiredTo)) / requiredTo;
213: 213:         if (extraSell == AUTO_MARGIN) {
214: 214:             uint256 expectedReturn = 0;
215: 215:             uint256 optimalSell = applyRate(requiredTo, sellRate);
216: 216:             uint256 increment = applyRate(requiredTo / 100000, sellRate);
217: 217:             uint256 returnRebuy;
218: 218:             uint256 cl;
219: 219: 
220: 220:             while (expectedReturn < requiredTo && cl < 10) {
221: 221:                 optimalSell += increment;
222: 222:                 returnRebuy = converter.getReturn(fromToken, toToken, optimalSell);
223: 223:                 optimalSell = (optimalSell * requiredTo) / returnRebuy;
224: 224:                 expectedReturn = returnRebuy;
225: 225:                 cl++;
226: 226:             }
227: 227:             emit RunAutoMargin(cl, increment);
228: 228: 
229: 229:             return optimalSell;
230: 230:         } else {
231: 231:             return applyRate(requiredTo, sellRate).safeMult(uint256(100000).safeAdd(extraSell)) / 100000;
232: 232:         }
233: 233:     }
234: 234: 
235: 235:     function convertSafe(
236: 236:         TokenConverter converter,
237: 237:         Token fromToken,
238: 238:         Token toToken,
239: 239:         uint256 amount
240: 240:     ) internal returns (uint256 bought) {
241: 241:         if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, amount));
242: 242:         uint256 prevBalance = toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance;
243: 243:         uint256 sendEth = fromToken == ETH_ADDRESS ? amount : 0;
244: 244:         uint256 boughtAmount = converter.convert.value(sendEth)(fromToken, toToken, amount, 1);
245: 245:         require(
246: 246:             boughtAmount == (toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance) - prevBalance,
247: 247:             "Bought amound does does not match"
248: 248:         );
249: 249:         if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, 0));
250: 250:         return boughtAmount;
251: 251:     }
252: 252: 
253: 253:     function executeOptimalPay(
254: 254:         bytes32[4] memory params,
255: 255:         bytes oracleData,
256: 256:         uint256 rcnToPay
257: 257:     ) internal returns (bool) {
258: 258:         NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
259: 259:         uint256 index = uint256(params[I_INDEX]);
260: 260:         Oracle oracle = engine.getOracle(index);
261: 261: 
262: 262:         uint256 toPay;
263: 263: 
264: 264:         if (oracle == address(0)) {
265: 265:             toPay = rcnToPay;
266: 266:         } else {
267: 267:             uint256 rate;
268: 268:             uint256 decimals;
269: 269:             bytes32 currency = engine.getCurrency(index);
270: 270: 
271: 271:             (rate, decimals) = oracle.getRate(currency, oracleData);
272: 272:             toPay = (rcnToPay * (10 ** (18 - decimals + (18 * 2)) / rate)) / 10 ** 18;
273: 273:         }
274: 274: 
275: 275:         Token rcn = engine.rcn();
276: 276:         require(rcn.approve(engine, rcnToPay));
277: 277:         require(engine.pay(index, toPay, address(params[I_PAY_FROM]), oracleData), "Error paying the loan");
278: 278:         require(rcn.approve(engine, 0));
279: 279:         
280: 280:         return true;
281: 281:     }
282: 282: 
283: 283:     function executeLend(
284: 284:         bytes32[3] memory params,
285: 285:         bytes oracleData,
286: 286:         bytes cosignerData
287: 287:     ) internal returns (bool) {
288: 288:         NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
289: 289:         uint256 index = uint256(params[I_INDEX]);
290: 290:         return engine.lend(index, oracleData, Cosigner(address(params[I_LEND_COSIGNER])), cosignerData);
291: 291:     }
292: 292: 
293: 293:     function executeTransfer(
294: 294:         bytes32[3] memory params,
295: 295:         address to
296: 296:     ) internal returns (bool) {
297: 297:         return NanoLoanEngine(address(params[0])).transfer(to, uint256(params[1]));
298: 298:     }
299: 299: 
300: 300:     function applyRate(
301: 301:         uint256 amount,
302: 302:         uint256 rate
303: 303:     ) pure internal returns (uint256) {
304: 304:         return amount.safeMult(rate) / 10 ** 18;
305: 305:     }
306: 306: 
307: 307:     function getRequiredRcnLend(
308: 308:         bytes32[3] memory params,
309: 309:         bytes oracleData,
310: 310:         bytes cosignerData
311: 311:     ) internal returns (uint256 required) {
312: 312:         NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
313: 313:         uint256 index = uint256(params[I_INDEX]);
314: 314:         Cosigner cosigner = Cosigner(address(params[I_LEND_COSIGNER]));
315: 315: 
316: 316:         if (cosigner != address(0)) {
317: 317:             required += cosigner.cost(engine, index, cosignerData, oracleData);
318: 318:         }
319: 319:         required += engine.convertRate(engine.getOracle(index), engine.getCurrency(index), oracleData, engine.getAmount(index));
320: 320:     }
321: 321:     
322: 322:     function getRequiredRcnPay(
323: 323:         bytes32[4] memory params,
324: 324:         bytes oracleData
325: 325:     ) internal returns (uint256) {
326: 326:         NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
327: 327:         uint256 index = uint256(params[I_INDEX]);
328: 328:         uint256 amount = uint256(params[I_PAY_AMOUNT]);
329: 329:         return engine.convertRate(engine.getOracle(index), engine.getCurrency(index), oracleData, amount);
330: 330:     }
331: 331: 
332: 332:     function sendTransaction(
333: 333:         address to,
334: 334:         uint256 value,
335: 335:         bytes data
336: 336:     ) external onlyOwner returns (bool) {
337: 337:         return to.call.value(value)(data);
338: 338:     }
339: 339: 
340: 340:     function() external {}
341: 341: }
342: 342: 
343: 343: 
344: 344: 
345: 345: 
346: 346: 
347: 347: 