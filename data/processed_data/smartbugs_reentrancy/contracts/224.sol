1: 1: 1: 1: 1: pragma solidity ^0.5.3;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract Operator {
4: 4: 4: 4: 4:     uint256 public ONE_DAY = 86400;
5: 5: 5: 5: 5:     uint256 public MIN_DEP = 1 ether;
6: 6: 6: 6: 6:     uint256 public MAX_DEP = 100 ether;
7: 7: 7: 7: 7:     address public admin;
8: 8: 8: 8: 8:     address public admin2;
9: 9: 9: 9: 9:     address public querierAddress;
10: 10: 10: 10: 10:     uint256 public depositedAmountGross = 0;
11: 11: 11: 11: 11:     uint256 public paySystemCommissionTimes = 1;
12: 12: 12: 12: 12:     uint256 public payDailyIncomeTimes = 1;
13: 13: 13: 13: 13:     uint256 public lastPaySystemCommission = now;
14: 14: 14: 14: 14:     uint256 public lastPayDailyIncome = now;
15: 15: 15: 15: 15:     uint256 public contractStartAt = now;
16: 16: 16: 16: 16:     uint256 public lastReset = now;
17: 17: 17: 17: 17:     address payable public operationFund = 0x4357DE4549a18731fA8bF3c7b69439E87FAff8F6;
18: 18: 18: 18: 18:     address[] public investorAddresses;
19: 19: 19: 19: 19:     bytes32[] public investmentIds;
20: 20: 20: 20: 20:     bytes32[] public withdrawalIds;
21: 21: 21: 21: 21:     bytes32[] public maxOutIds;
22: 22: 22: 22: 22:     mapping (address => Investor) investors;
23: 23: 23: 23: 23:     mapping (bytes32 => Investment) public investments;
24: 24: 24: 24: 24:     mapping (bytes32 => Withdrawal) public withdrawals;
25: 25: 25: 25: 25:     mapping (bytes32 => MaxOut) public maxOuts;
26: 26: 26: 26: 26:     uint256 additionNow = 0;
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28:     uint256 public maxLevelsAddSale = 200;
29: 29: 29: 29: 29:     uint256 public maximumMaxOutInWeek = 2;
30: 30: 30: 30: 30:     bool public importing = true;
31: 31: 31: 31: 31: 
32: 32: 32: 32: 32:     Vote public currentVote;
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34:     struct Vote {
35: 35: 35: 35: 35:         uint256 startTime;
36: 36: 36: 36: 36:         string reason;
37: 37: 37: 37: 37:         mapping (address => uint8) votes;
38: 38: 38: 38: 38:         address payable emergencyAddress;
39: 39: 39: 39: 39:         uint256 yesPoint;
40: 40: 40: 40: 40:         uint256 noPoint;
41: 41: 41: 41: 41:         uint256 totalPoint;
42: 42: 42: 42: 42:     }
43: 43: 43: 43: 43: 
44: 44: 44: 44: 44:     struct Investment {
45: 45: 45: 45: 45:         bytes32 id;
46: 46: 46: 46: 46:         uint256 at;
47: 47: 47: 47: 47:         uint256 amount;
48: 48: 48: 48: 48:         address investor;
49: 49: 49: 49: 49:         address nextInvestor;
50: 50: 50: 50: 50:         bool nextBranch;
51: 51: 51: 51: 51:     }
52: 52: 52: 52: 52: 
53: 53: 53: 53: 53:     struct Withdrawal {
54: 54: 54: 54: 54:         bytes32 id;
55: 55: 55: 55: 55:         uint256 at;
56: 56: 56: 56: 56:         uint256 amount;
57: 57: 57: 57: 57:         address investor;
58: 58: 58: 58: 58:         address presentee;
59: 59: 59: 59: 59:         uint256 reason;
60: 60: 60: 60: 60:         uint256 times;
61: 61: 61: 61: 61:     }
62: 62: 62: 62: 62: 
63: 63: 63: 63: 63:     struct Investor {
64: 64: 64: 64: 64:         address parent;
65: 65: 65: 65: 65:         address leftChild;
66: 66: 66: 66: 66:         address rightChild;
67: 67: 67: 67: 67:         address presenter;
68: 68: 68: 68: 68:         uint256 generation;
69: 69: 69: 69: 69:         uint256 depositedAmount;
70: 70: 70: 70: 70:         uint256 withdrewAmount;
71: 71: 71: 71: 71:         bool isDisabled;
72: 72: 72: 72: 72:         uint256 lastMaxOut;
73: 73: 73: 73: 73:         uint256 maxOutTimes;
74: 74: 74: 74: 74:         uint256 maxOutTimesInWeek;
75: 75: 75: 75: 75:         uint256 totalSell;
76: 76: 76: 76: 76:         uint256 sellThisMonth;
77: 77: 77: 77: 77:         uint256 rightSell;
78: 78: 78: 78: 78:         uint256 leftSell;
79: 79: 79: 79: 79:         uint256 reserveCommission;
80: 80: 80: 80: 80:         uint256 dailyIncomeWithrewAmount;
81: 81: 81: 81: 81:         uint256 registerTime;
82: 82: 82: 82: 82:         uint256 minDeposit;
83: 83: 83: 83: 83:         bytes32[] investments;
84: 84: 84: 84: 84:         bytes32[] withdrawals;
85: 85: 85: 85: 85:     }
86: 86: 86: 86: 86: 
87: 87: 87: 87: 87:     struct MaxOut {
88: 88: 88: 88: 88:         bytes32 id;
89: 89: 89: 89: 89:         address investor;
90: 90: 90: 90: 90:         uint256 times;
91: 91: 91: 91: 91:         uint256 at;
92: 92: 92: 92: 92:     }
93: 93: 93: 93: 93: 
94: 94: 94: 94: 94:     constructor () public { admin = msg.sender; }
95: 95: 95: 95: 95:     
96: 96: 96: 96: 96:     modifier mustBeAdmin() {
97: 97: 97: 97: 97:         require(msg.sender == admin || msg.sender == querierAddress || msg.sender == admin2);
98: 98: 98: 98: 98:         _;
99: 99: 99: 99: 99:     }
100: 100: 100: 100: 100: 
101: 101: 101: 101: 101:     modifier mustBeImporting() { require(importing); require(msg.sender == querierAddress || msg.sender == admin); _; }
102: 102: 102: 102: 102:     
103: 103: 103: 103: 103:     function () payable external { deposit(); }
104: 104: 104: 104: 104: 
105: 105: 105: 105: 105:     function getNow() internal view returns(uint256) {
106: 106: 106: 106: 106:         return additionNow + now;
107: 107: 107: 107: 107:     }
108: 108: 108: 108: 108: 
109: 109: 109: 109: 109:     function depositProcess(address sender) internal {
110: 110: 110: 110: 110:         Investor storage investor = investors[sender];
111: 111: 111: 111: 111:         require(investor.generation != 0);
112: 112: 112: 112: 112:         if (investor.depositedAmount == 0) require(msg.value >= investor.minDeposit);
113: 113: 113: 113: 113:         require(investor.maxOutTimesInWeek < maximumMaxOutInWeek);
114: 114: 114: 114: 114:         require(investor.maxOutTimes < 50);
115: 115: 115: 115: 115:         require(investor.maxOutTimes == 0 || getNow() - investor.lastMaxOut < ONE_DAY * 7 || investor.depositedAmount != 0);
116: 116: 116: 116: 116:         depositedAmountGross += msg.value;
117: 117: 117: 117: 117:         bytes32 id = keccak256(abi.encodePacked(block.number, getNow(), sender, msg.value));
118: 118: 118: 118: 118:         uint256 investmentValue = investor.depositedAmount + msg.value <= MAX_DEP ? msg.value : MAX_DEP - investor.depositedAmount;
119: 119: 119: 119: 119:         if (investmentValue == 0) return;
120: 120: 120: 120: 120:         bool nextBranch = investors[investor.parent].leftChild == sender; 
121: 121: 121: 121: 121:         Investment memory investment = Investment({ id: id, at: getNow(), amount: investmentValue, investor: sender, nextInvestor: investor.parent, nextBranch: nextBranch  });
122: 122: 122: 122: 122:         investments[id] = investment;
123: 123: 123: 123: 123:         processInvestments(id);
124: 124: 124: 124: 124:         investmentIds.push(id);
125: 125: 125: 125: 125:     }
126: 126: 126: 126: 126: 
127: 127: 127: 127: 127:     function pushNewMaxOut(address investorAddress, uint256 times, uint256 depositedAmount) internal {
128: 128: 128: 128: 128:         bytes32 id = keccak256(abi.encodePacked(block.number, getNow(), investorAddress, times));
129: 129: 129: 129: 129:         MaxOut memory maxOut = MaxOut({ id: id, at: getNow(), investor: investorAddress, times: times });
130: 130: 130: 130: 130:         maxOutIds.push(id);
131: 131: 131: 131: 131:         maxOuts[id] = maxOut;
132: 132: 132: 132: 132:         investors[investorAddress].minDeposit = depositedAmount;
133: 133: 133: 133: 133:     }
134: 134: 134: 134: 134:     
135: 135: 135: 135: 135:     function deposit() payable public { depositProcess(msg.sender); }
136: 136: 136: 136: 136:     
137: 137: 137: 137: 137:     function processInvestments(bytes32 investmentId) internal {
138: 138: 138: 138: 138:         Investment storage investment = investments[investmentId];
139: 139: 139: 139: 139:         uint256 amount = investment.amount;
140: 140: 140: 140: 140:         Investor storage investor = investors[investment.investor];
141: 141: 141: 141: 141:         investor.investments.push(investmentId);
142: 142: 142: 142: 142:         investor.depositedAmount += amount;
143: 143: 143: 143: 143:         address payable presenterAddress = address(uint160(investor.presenter));
144: 144: 144: 144: 144:         Investor storage presenter = investors[presenterAddress];
145: 145: 145: 145: 145:         if (presenterAddress != address(0)) {
146: 146: 146: 146: 146:             presenter.totalSell += amount;
147: 147: 147: 147: 147:             presenter.sellThisMonth += amount;
148: 148: 148: 148: 148:         }
149: 149: 149: 149: 149:         if (presenter.depositedAmount >= MIN_DEP && !presenter.isDisabled) {
150: 150: 150: 150: 150:             sendEtherForInvestor(presenterAddress, amount / 10, 1, investment.investor, 0);
151: 151: 151: 151: 151:         }
152: 152: 152: 152: 152:     }
153: 153: 153: 153: 153: 
154: 154: 154: 154: 154:     function addSellForParents(bytes32 investmentId) public mustBeAdmin {
155: 155: 155: 155: 155:         Investment storage investment = investments[investmentId];
156: 156: 156: 156: 156:         require(investment.nextInvestor != address(0));
157: 157: 157: 157: 157:         uint256 amount = investment.amount;
158: 158: 158: 158: 158:         uint256 loopCount = 0;
159: 159: 159: 159: 159:         while (investment.nextInvestor != address(0) && loopCount < maxLevelsAddSale) {
160: 160: 160: 160: 160:             Investor storage investor = investors[investment.nextInvestor];
161: 161: 161: 161: 161:             if (investment.nextBranch) investor.leftSell += amount;
162: 162: 162: 162: 162:             else investor.rightSell += amount;
163: 163: 163: 163: 163:             investment.nextBranch = investors[investor.parent].leftChild == investment.nextInvestor;
164: 164: 164: 164: 164:             investment.nextInvestor = investor.parent;
165: 165: 165: 165: 165:             loopCount++;
166: 166: 166: 166: 166:         }
167: 167: 167: 167: 167:     }
168: 168: 168: 168: 168: 
169: 169: 169: 169: 169:     function sendEtherForInvestor(address payable investorAddress, uint256 value, uint256 reason, address presentee, uint256 times) internal {
170: 170: 170: 170: 170:         if (value == 0 && reason != 100) return; 
171: 171: 171: 171: 171:         if (investorAddress == address(0)) return;
172: 172: 172: 172: 172:         Investor storage investor = investors[investorAddress];
173: 173: 173: 173: 173:         uint256 unpaidSystemCommission = getUnpaidSystemCommission(investorAddress);
174: 174: 174: 174: 174:         uint256 totalPaidAfterThisTime = investor.reserveCommission + getDailyIncomeForUser(investorAddress) + unpaidSystemCommission;
175: 175: 175: 175: 175:         if (reason == 1) totalPaidAfterThisTime += value; 
176: 176: 176: 176: 176:         if (totalPaidAfterThisTime + investor.withdrewAmount >= 3 * investor.depositedAmount) { 
177: 177: 177: 177: 177:             payWithMaxOut(totalPaidAfterThisTime, investorAddress, unpaidSystemCommission);
178: 178: 178: 178: 178:             return;
179: 179: 179: 179: 179:         }
180: 180: 180: 180: 180:         if (investor.reserveCommission > 0) payWithNoMaxOut(investor.reserveCommission, investorAddress, 4, address(0), 0);
181: 181: 181: 181: 181:         payWithNoMaxOut(value, investorAddress, reason, presentee, times);
182: 182: 182: 182: 182:     }
183: 183: 183: 183: 183:     
184: 184: 184: 184: 184:     function payWithNoMaxOut(uint256 amountToPay, address payable investorAddress, uint256 reason, address presentee, uint256 times) internal {
185: 185: 185: 185: 185:         investors[investorAddress].withdrewAmount += amountToPay;
186: 186: 186: 186: 186:         if (reason == 4) investors[investorAddress].reserveCommission = 0;
187: 187: 187: 187: 187:         if (reason == 3) resetSystemCommision(investorAddress, times);
188: 188: 188: 188: 188:         if (reason == 2) investors[investorAddress].dailyIncomeWithrewAmount += amountToPay;
189: 189: 189: 189: 189:         pay(amountToPay, investorAddress, reason, presentee, times);
190: 190: 190: 190: 190:     }
191: 191: 191: 191: 191:     
192: 192: 192: 192: 192:     function payWithMaxOut(uint256 totalPaidAfterThisTime, address payable investorAddress, uint256 unpaidSystemCommission) internal {
193: 193: 193: 193: 193:         Investor storage investor = investors[investorAddress];
194: 194: 194: 194: 194:         uint256 amountToPay = investor.depositedAmount * 3 - investor.withdrewAmount;
195: 195: 195: 195: 195:         uint256 amountToReserve = totalPaidAfterThisTime - amountToPay;
196: 196: 196: 196: 196:         if (unpaidSystemCommission > 0) resetSystemCommision(investorAddress, 0);
197: 197: 197: 197: 197:         investor.maxOutTimes++;
198: 198: 198: 198: 198:         investor.maxOutTimesInWeek++;
199: 199: 199: 199: 199:         uint256 oldDepositedAmount = investor.depositedAmount;
200: 200: 200: 200: 200:         investor.depositedAmount = 0;
201: 201: 201: 201: 201:         investor.withdrewAmount = 0;
202: 202: 202: 202: 202:         investor.lastMaxOut = getNow();
203: 203: 203: 203: 203:         investor.dailyIncomeWithrewAmount = 0;
204: 204: 204: 204: 204:         investor.reserveCommission = amountToReserve;
205: 205: 205: 205: 205:         pushNewMaxOut(investorAddress, investor.maxOutTimes, oldDepositedAmount);
206: 206: 206: 206: 206:         pay(amountToPay, investorAddress, 0, address(0), 0);
207: 207: 207: 207: 207:     }
208: 208: 208: 208: 208: 
209: 209: 209: 209: 209:     function pay(uint256 amountToPay, address payable investorAddress, uint256 reason, address presentee, uint256 times) internal {
210: 210: 210: 210: 210:         if (amountToPay == 0) return;
211: 211: 211: 211: 211:         investorAddress.transfer(amountToPay / 100 * 90);
212: 212: 212: 212: 212:         operationFund.transfer(amountToPay / 100 * 10);
213: 213: 213: 213: 213:         bytes32 id = keccak256(abi.encodePacked(block.difficulty, getNow(), investorAddress, amountToPay, reason));
214: 214: 214: 214: 214:         Withdrawal memory withdrawal = Withdrawal({ id: id, at: getNow(), amount: amountToPay, investor: investorAddress, presentee: presentee, times: times, reason: reason });
215: 215: 215: 215: 215:         withdrawals[id] = withdrawal;
216: 216: 216: 216: 216:         investors[investorAddress].withdrawals.push(id);
217: 217: 217: 217: 217:         withdrawalIds.push(id);
218: 218: 218: 218: 218:     }
219: 219: 219: 219: 219: 
220: 220: 220: 220: 220:     function getAllIncomeTilNow(address investorAddress) internal view returns(uint256 allIncome) {
221: 221: 221: 221: 221:         Investor memory investor = investors[investorAddress];
222: 222: 222: 222: 222:         uint256 unpaidDailyIncome = getDailyIncomeForUser(investorAddress);
223: 223: 223: 223: 223:         uint256 withdrewAmount = investor.withdrewAmount;
224: 224: 224: 224: 224:         uint256 unpaidSystemCommission = getUnpaidSystemCommission(investorAddress);
225: 225: 225: 225: 225:         uint256 allIncomeNow = unpaidDailyIncome + withdrewAmount + unpaidSystemCommission;
226: 226: 226: 226: 226:         return allIncomeNow;
227: 227: 227: 227: 227:     }
228: 228: 228: 228: 228: 
229: 229: 229: 229: 229:     function putPresentee(address presenterAddress, address presenteeAddress, address parentAddress, bool isLeft) public mustBeAdmin {
230: 230: 230: 230: 230:         Investor storage presenter = investors[presenterAddress];
231: 231: 231: 231: 231:         Investor storage parent = investors[parentAddress];
232: 232: 232: 232: 232:         if (investorAddresses.length != 0) {
233: 233: 233: 233: 233:             require(presenter.generation != 0);
234: 234: 234: 234: 234:             require(parent.generation != 0);
235: 235: 235: 235: 235:             if (isLeft) {
236: 236: 236: 236: 236:                 require(parent.leftChild == address(0)); 
237: 237: 237: 237: 237:             } else {
238: 238: 238: 238: 238:                 require(parent.rightChild == address(0)); 
239: 239: 239: 239: 239:             }
240: 240: 240: 240: 240:         }
241: 241: 241: 241: 241:         Investor memory investor = Investor({
242: 242: 242: 242: 242:             parent: parentAddress,
243: 243: 243: 243: 243:             leftChild: address(0),
244: 244: 244: 244: 244:             rightChild: address(0),
245: 245: 245: 245: 245:             presenter: presenterAddress,
246: 246: 246: 246: 246:             generation: parent.generation + 1,
247: 247: 247: 247: 247:             depositedAmount: 0,
248: 248: 248: 248: 248:             withdrewAmount: 0,
249: 249: 249: 249: 249:             isDisabled: false,
250: 250: 250: 250: 250:             lastMaxOut: getNow(),
251: 251: 251: 251: 251:             maxOutTimes: 0,
252: 252: 252: 252: 252:             maxOutTimesInWeek: 0,
253: 253: 253: 253: 253:             totalSell: 0,
254: 254: 254: 254: 254:             sellThisMonth: 0,
255: 255: 255: 255: 255:             registerTime: getNow(),
256: 256: 256: 256: 256:             investments: new bytes32[](0),
257: 257: 257: 257: 257:             withdrawals: new bytes32[](0),
258: 258: 258: 258: 258:             minDeposit: MIN_DEP,
259: 259: 259: 259: 259:             rightSell: 0,
260: 260: 260: 260: 260:             leftSell: 0,
261: 261: 261: 261: 261:             reserveCommission: 0,
262: 262: 262: 262: 262:             dailyIncomeWithrewAmount: 0
263: 263: 263: 263: 263:         });
264: 264: 264: 264: 264:         investors[presenteeAddress] = investor;
265: 265: 265: 265: 265:        
266: 266: 266: 266: 266:         investorAddresses.push(presenteeAddress);
267: 267: 267: 267: 267:         if (parent.generation == 0) return;
268: 268: 268: 268: 268:         if (isLeft) {
269: 269: 269: 269: 269:             parent.leftChild = presenteeAddress;
270: 270: 270: 270: 270:         } else {
271: 271: 271: 271: 271:             parent.rightChild = presenteeAddress;
272: 272: 272: 272: 272:         }
273: 273: 273: 273: 273:     }
274: 274: 274: 274: 274: 
275: 275: 275: 275: 275:     function getDailyIncomeForUser(address investorAddress) internal view returns(uint256 amount) {
276: 276: 276: 276: 276:         Investor memory investor = investors[investorAddress];
277: 277: 277: 277: 277:         uint256 investmentLength = investor.investments.length;
278: 278: 278: 278: 278:         uint256 dailyIncome = 0;
279: 279: 279: 279: 279:         for (uint256 i = 0; i < investmentLength; i++) {
280: 280: 280: 280: 280:             Investment memory investment = investments[investor.investments[i]];
281: 281: 281: 281: 281:             if (investment.at < investor.lastMaxOut) continue; 
282: 282: 282: 282: 282:             if (getNow() - investment.at >= ONE_DAY) {
283: 283: 283: 283: 283:                 uint256 numberOfDay = (getNow() - investment.at) / ONE_DAY;
284: 284: 284: 284: 284:                 uint256 totalDailyIncome = numberOfDay * investment.amount / 100;
285: 285: 285: 285: 285:                 dailyIncome = totalDailyIncome + dailyIncome;
286: 286: 286: 286: 286:             }
287: 287: 287: 287: 287:         }
288: 288: 288: 288: 288:         return dailyIncome - investor.dailyIncomeWithrewAmount;
289: 289: 289: 289: 289:     }
290: 290: 290: 290: 290:     
291: 291: 291: 291: 291:     function payDailyIncomeForInvestor(address payable investorAddress, uint256 times) public mustBeAdmin {
292: 292: 292: 292: 292:         uint256 dailyIncome = getDailyIncomeForUser(investorAddress);
293: 293: 293: 293: 293:         Investor storage investor = investors[investorAddress];
294: 294: 294: 294: 294:         if (times > ONE_DAY) {
295: 295: 295: 295: 295:             uint256 investmentLength = investor.investments.length;
296: 296: 296: 296: 296:             bytes32 lastInvestmentId = investor.investments[investmentLength - 1];
297: 297: 297: 297: 297:             investments[lastInvestmentId].at -= times;
298: 298: 298: 298: 298:             investors[investorAddress].lastMaxOut = investments[lastInvestmentId].at;
299: 299: 299: 299: 299:             return;
300: 300: 300: 300: 300:         }
301: 301: 301: 301: 301:         if (investor.isDisabled) return;
302: 302: 302: 302: 302:         sendEtherForInvestor(investorAddress, dailyIncome, 2, address(0), times);
303: 303: 303: 303: 303:     }
304: 304: 304: 304: 304:     
305: 305: 305: 305: 305:     function payDailyIncomeByIndex(uint256 from, uint256 to) public mustBeAdmin{
306: 306: 306: 306: 306:         require(from >= 0 && to < investorAddresses.length);
307: 307: 307: 307: 307:         for(uint256 i = from; i <= to; i++) {
308: 308: 308: 308: 308:             payDailyIncomeForInvestor(address(uint160(investorAddresses[i])), payDailyIncomeTimes);
309: 309: 309: 309: 309:         }
310: 310: 310: 310: 310:     }
311: 311: 311: 311: 311: 
312: 312: 312: 312: 312:     function getUnpaidSystemCommission(address investorAddress) public view returns(uint256 unpaid) {
313: 313: 313: 313: 313:         Investor memory investor = investors[investorAddress];
314: 314: 314: 314: 314:         uint256 depositedAmount = investor.depositedAmount;
315: 315: 315: 315: 315:         uint256 totalSell = investor.totalSell;
316: 316: 316: 316: 316:         uint256 leftSell = investor.leftSell;
317: 317: 317: 317: 317:         uint256 rightSell = investor.rightSell;
318: 318: 318: 318: 318:         uint256 sellThisMonth = investor.sellThisMonth;
319: 319: 319: 319: 319:         uint256 sellToPaySystemCommission = rightSell < leftSell ? rightSell : leftSell;
320: 320: 320: 320: 320:         uint256 commission = sellToPaySystemCommission * getPercentage(depositedAmount, totalSell, sellThisMonth) / 100;
321: 321: 321: 321: 321:         return commission;
322: 322: 322: 322: 322:     }
323: 323: 323: 323: 323:     
324: 324: 324: 324: 324:     function paySystemCommissionInvestor(address payable investorAddress, uint256 times) public mustBeAdmin {
325: 325: 325: 325: 325:         Investor storage investor = investors[investorAddress];
326: 326: 326: 326: 326:         if (investor.isDisabled) return;
327: 327: 327: 327: 327:         uint256 systemCommission = getUnpaidSystemCommission(investorAddress);
328: 328: 328: 328: 328:         sendEtherForInvestor(investorAddress, systemCommission, 3, address(0), times);
329: 329: 329: 329: 329:     }
330: 330: 330: 330: 330: 
331: 331: 331: 331: 331:     function resetSystemCommision(address investorAddress, uint256 times) internal {
332: 332: 332: 332: 332:         Investor storage investor = investors[investorAddress];
333: 333: 333: 333: 333:         if (paySystemCommissionTimes > 3 && times != 0) {
334: 334: 334: 334: 334:             investor.rightSell = 0;
335: 335: 335: 335: 335:             investor.leftSell = 0;
336: 336: 336: 336: 336:         } else if (investor.rightSell >= investor.leftSell) {
337: 337: 337: 337: 337:             investor.rightSell = investor.rightSell - investor.leftSell;
338: 338: 338: 338: 338:             investor.leftSell = 0;
339: 339: 339: 339: 339:         } else {
340: 340: 340: 340: 340:             investor.leftSell = investor.leftSell - investor.rightSell;
341: 341: 341: 341: 341:             investor.rightSell = 0;
342: 342: 342: 342: 342:         }
343: 343: 343: 343: 343:         if (times != 0) investor.sellThisMonth = 0;
344: 344: 344: 344: 344:     }
345: 345: 345: 345: 345: 
346: 346: 346: 346: 346:     function paySystemCommissionByIndex(uint256 from, uint256 to) public mustBeAdmin {
347: 347: 347: 347: 347:          require(from >= 0 && to < investorAddresses.length);
348: 348: 348: 348: 348:         
349: 349: 349: 349: 349:         if (getNow() <= 30 * ONE_DAY + contractStartAt) return;
350: 350: 350: 350: 350:         for(uint256 i = from; i <= to; i++) {
351: 351: 351: 351: 351:             paySystemCommissionInvestor(address(uint160(investorAddresses[i])), paySystemCommissionTimes);
352: 352: 352: 352: 352:         }
353: 353: 353: 353: 353:     }
354: 354: 354: 354: 354:     
355: 355: 355: 355: 355:     function finishPayDailyIncome() public mustBeAdmin {
356: 356: 356: 356: 356:         lastPayDailyIncome = getNow();
357: 357: 357: 357: 357:         payDailyIncomeTimes++;
358: 358: 358: 358: 358:     }
359: 359: 359: 359: 359:     
360: 360: 360: 360: 360:     function finishPaySystemCommission() public mustBeAdmin {
361: 361: 361: 361: 361:         lastPaySystemCommission = getNow();
362: 362: 362: 362: 362:         paySystemCommissionTimes++;
363: 363: 363: 363: 363:     }
364: 364: 364: 364: 364:     
365: 365: 365: 365: 365:     function resetGame(uint256 from, uint256 to) public mustBeAdmin {
366: 366: 366: 366: 366:         require(from >= 0 && to < investorAddresses.length);
367: 367: 367: 367: 367:         require(currentVote.startTime != 0);
368: 368: 368: 368: 368:         require(getNow() - currentVote.startTime > 3 * ONE_DAY);
369: 369: 369: 369: 369:         require(currentVote.yesPoint > currentVote.totalPoint / 2);
370: 370: 370: 370: 370:         require(currentVote.emergencyAddress == address(0));
371: 371: 371: 371: 371:         lastReset = getNow();
372: 372: 372: 372: 372:         for (uint256 i = from; i < to; i++) {
373: 373: 373: 373: 373:             address investorAddress = investorAddresses[i];
374: 374: 374: 374: 374:             Investor storage investor = investors[investorAddress];
375: 375: 375: 375: 375:             uint256 currentVoteValue = currentVote.votes[investorAddress] != 0 ? currentVote.votes[investorAddress] : 2;
376: 376: 376: 376: 376:             if (currentVoteValue == 2) {
377: 377: 377: 377: 377:                 if (investor.maxOutTimes > 0 || (investor.withdrewAmount >= investor.depositedAmount && investor.withdrewAmount != 0)) {
378: 378: 378: 378: 378:                     investor.lastMaxOut = getNow();
379: 379: 379: 379: 379:                     investor.depositedAmount = 0;
380: 380: 380: 380: 380:                     investor.withdrewAmount = 0;
381: 381: 381: 381: 381:                     investor.dailyIncomeWithrewAmount = 0;
382: 382: 382: 382: 382:                 }
383: 383: 383: 383: 383:                 investor.reserveCommission = 0;
384: 384: 384: 384: 384:                 investor.rightSell = 0;
385: 385: 385: 385: 385:                 investor.leftSell = 0;
386: 386: 386: 386: 386:                 investor.totalSell = 0;
387: 387: 387: 387: 387:                 investor.sellThisMonth = 0;
388: 388: 388: 388: 388:             } else {
389: 389: 389: 389: 389:                 if (investor.maxOutTimes > 0 || (investor.withdrewAmount >= investor.depositedAmount && investor.withdrewAmount != 0)) {
390: 390: 390: 390: 390:                     investor.isDisabled = true;
391: 391: 391: 391: 391:                     investor.reserveCommission = 0;
392: 392: 392: 392: 392:                     investor.lastMaxOut = getNow();
393: 393: 393: 393: 393:                     investor.depositedAmount = 0;
394: 394: 394: 394: 394:                     investor.withdrewAmount = 0;
395: 395: 395: 395: 395:                     investor.dailyIncomeWithrewAmount = 0;
396: 396: 396: 396: 396:                 }
397: 397: 397: 397: 397:                 investor.reserveCommission = 0;
398: 398: 398: 398: 398:                 investor.rightSell = 0;
399: 399: 399: 399: 399:                 investor.leftSell = 0;
400: 400: 400: 400: 400:                 investor.totalSell = 0;
401: 401: 401: 401: 401:                 investor.sellThisMonth = 0;
402: 402: 402: 402: 402:             }
403: 403: 403: 403: 403:             
404: 404: 404: 404: 404:         }
405: 405: 405: 405: 405:     }
406: 406: 406: 406: 406: 
407: 407: 407: 407: 407:     function stopGame(uint256 percent, uint256 from, uint256 to) mustBeAdmin public {
408: 408: 408: 408: 408:         require(currentVote.startTime != 0);
409: 409: 409: 409: 409:         require(getNow() - currentVote.startTime > 3 * ONE_DAY);
410: 410: 410: 410: 410:         require(currentVote.noPoint > currentVote.totalPoint / 2);
411: 411: 411: 411: 411:         require(currentVote.emergencyAddress == address(0));
412: 412: 412: 412: 412:         require(percent <= 50);
413: 413: 413: 413: 413:         require(from >= 0 && to < investorAddresses.length);
414: 414: 414: 414: 414:         for (uint256 i = from; i <= to; i++) {
415: 415: 415: 415: 415:             address payable investorAddress = address(uint160(investorAddresses[i]));
416: 416: 416: 416: 416:             Investor storage investor = investors[investorAddress];
417: 417: 417: 417: 417:             if (investor.maxOutTimes > 0) continue;
418: 418: 418: 418: 418:             if (investor.isDisabled) continue;
419: 419: 419: 419: 419:             uint256 depositedAmount = investor.depositedAmount;
420: 420: 420: 420: 420:             uint256 withdrewAmount = investor.withdrewAmount;
421: 421: 421: 421: 421:             if (withdrewAmount >= depositedAmount / 2) continue;
422: 422: 422: 422: 422:             sendEtherForInvestor(investorAddress, depositedAmount * percent / 100 - withdrewAmount, 6, address(0), 0);
423: 423: 423: 423: 423:         }
424: 424: 424: 424: 424:     }
425: 425: 425: 425: 425:     
426: 426: 426: 426: 426:     function revivalInvestor(address investor) public mustBeAdmin { investors[investor].lastMaxOut = getNow(); }
427: 427: 427: 427: 427: 
428: 428: 428: 428: 428:     function payToReachMaxOut(address payable investorAddress) public mustBeAdmin {
429: 429: 429: 429: 429:         uint256 unpaidSystemCommissions = getUnpaidSystemCommission(investorAddress);
430: 430: 430: 430: 430:         uint256 unpaidDailyIncomes = getDailyIncomeForUser(investorAddress);
431: 431: 431: 431: 431:         uint256 withdrewAmount = investors[investorAddress].withdrewAmount;
432: 432: 432: 432: 432:         uint256 depositedAmount = investors[investorAddress].depositedAmount;
433: 433: 433: 433: 433:         uint256 reserveCommission = investors[investorAddress].reserveCommission;
434: 434: 434: 434: 434:         require(depositedAmount > 0  && withdrewAmount + unpaidSystemCommissions + unpaidDailyIncomes + reserveCommission >= 3 * depositedAmount);
435: 435: 435: 435: 435:         sendEtherForInvestor(investorAddress, 0, 100, address(0), 0);
436: 436: 436: 436: 436:     }
437: 437: 437: 437: 437: 
438: 438: 438: 438: 438:     function resetMaxOutInWeek(uint256 from, uint256 to) public mustBeAdmin {
439: 439: 439: 439: 439:         require(from >= 0 && to < investorAddresses.length);
440: 440: 440: 440: 440:         for (uint256 i = from; i < to; i++) {
441: 441: 441: 441: 441:             address investorAddress = investorAddresses[i];
442: 442: 442: 442: 442:             if (investors[investorAddress].maxOutTimesInWeek == 0) continue;
443: 443: 443: 443: 443:             investors[investorAddress].maxOutTimesInWeek = 0;
444: 444: 444: 444: 444:         }
445: 445: 445: 445: 445:     }
446: 446: 446: 446: 446: 
447: 447: 447: 447: 447:     function setMaximumMaxOutTimes(address investorAddress, uint256 times) public mustBeAdmin{ investors[investorAddress].maxOutTimes = times; }
448: 448: 448: 448: 448: 
449: 449: 449: 449: 449:     function disableInvestor(address investorAddress) public mustBeAdmin {
450: 450: 450: 450: 450:         Investor storage investor = investors[investorAddress];
451: 451: 451: 451: 451:         investor.isDisabled = true;
452: 452: 452: 452: 452:     }
453: 453: 453: 453: 453:     
454: 454: 454: 454: 454:     function enableInvestor(address investorAddress) public mustBeAdmin {
455: 455: 455: 455: 455:         Investor storage investor = investors[investorAddress];
456: 456: 456: 456: 456:         investor.isDisabled = false;
457: 457: 457: 457: 457:     }
458: 458: 458: 458: 458:     
459: 459: 459: 459: 459:     function donate() payable public { depositedAmountGross += msg.value; }
460: 460: 460: 460: 460: 
461: 461: 461: 461: 461:     
462: 462: 462: 462: 462:     
463: 463: 463: 463: 463:     function getTotalSellLevel(uint256 totalSell) internal pure returns (uint256 level){
464: 464: 464: 464: 464:         if (totalSell < 30 ether) return 0;
465: 465: 465: 465: 465:         if (totalSell < 60 ether) return 1;
466: 466: 466: 466: 466:         if (totalSell < 90 ether) return 2;
467: 467: 467: 467: 467:         if (totalSell < 120 ether) return 3;
468: 468: 468: 468: 468:         if (totalSell < 150 ether) return 4;
469: 469: 469: 469: 469:         return 5;
470: 470: 470: 470: 470:     }
471: 471: 471: 471: 471: 
472: 472: 472: 472: 472:     function getSellThisMonthLevel(uint256 sellThisMonth) internal pure returns (uint256 level){
473: 473: 473: 473: 473:         if (sellThisMonth < 2 ether) return 0;
474: 474: 474: 474: 474:         if (sellThisMonth < 4 ether) return 1;
475: 475: 475: 475: 475:         if (sellThisMonth < 6 ether) return 2;
476: 476: 476: 476: 476:         if (sellThisMonth < 8 ether) return 3;
477: 477: 477: 477: 477:         if (sellThisMonth < 10 ether) return 4;
478: 478: 478: 478: 478:         return 5;
479: 479: 479: 479: 479:     }
480: 480: 480: 480: 480:     
481: 481: 481: 481: 481:     function getDepositLevel(uint256 depositedAmount) internal pure returns (uint256 level){
482: 482: 482: 482: 482:         if (depositedAmount < 2 ether) return 0;
483: 483: 483: 483: 483:         if (depositedAmount < 4 ether) return 1;
484: 484: 484: 484: 484:         if (depositedAmount < 6 ether) return 2;
485: 485: 485: 485: 485:         if (depositedAmount < 8 ether) return 3;
486: 486: 486: 486: 486:         if (depositedAmount < 10 ether) return 4;
487: 487: 487: 487: 487:         return 5;
488: 488: 488: 488: 488:     }
489: 489: 489: 489: 489:     
490: 490: 490: 490: 490:     function getPercentage(uint256 depositedAmount, uint256 totalSell, uint256 sellThisMonth) internal pure returns(uint256 level) {
491: 491: 491: 491: 491:         uint256 totalSellLevel = getTotalSellLevel(totalSell);
492: 492: 492: 492: 492:         uint256 depLevel = getDepositLevel(depositedAmount);
493: 493: 493: 493: 493:         uint256 sellThisMonthLevel = getSellThisMonthLevel(sellThisMonth);
494: 494: 494: 494: 494:         uint256 min12 = totalSellLevel < depLevel ? totalSellLevel : depLevel;
495: 495: 495: 495: 495:         uint256 minLevel = sellThisMonthLevel < min12 ? sellThisMonthLevel : min12;
496: 496: 496: 496: 496:         return minLevel * 2;
497: 497: 497: 497: 497:     }
498: 498: 498: 498: 498:     
499: 499: 499: 499: 499:     function stringToBytes32(string memory source) internal pure returns (bytes32 result) {
500: 500: 500: 500: 500:         bytes memory tempEmptyStringTest = bytes(source);
501: 501: 501: 501: 501:         if (tempEmptyStringTest.length == 0) return 0x0;
502: 502: 502: 502: 502:         assembly { result := mload(add(source, 32)) }
503: 503: 503: 503: 503:     }
504: 504: 504: 504: 504:     
505: 505: 505: 505: 505:     
506: 506: 506: 506: 506: 
507: 507: 507: 507: 507:     function getInvestor(address investorAddress) view public returns (address[] memory addresses, bool isDisabled, uint256[] memory numbers) {
508: 508: 508: 508: 508:         addresses = new address[](4);
509: 509: 509: 509: 509:         numbers = new uint256[](16);
510: 510: 510: 510: 510:         Investor memory investor = investors[investorAddress];
511: 511: 511: 511: 511:         addresses[0] = investor.parent;
512: 512: 512: 512: 512:         addresses[1] = investor.leftChild;
513: 513: 513: 513: 513:         addresses[2] = investor.rightChild;
514: 514: 514: 514: 514:         addresses[3] = investor.presenter;
515: 515: 515: 515: 515:         numbers[0] = investor.generation;
516: 516: 516: 516: 516:         numbers[1] = investor.depositedAmount;
517: 517: 517: 517: 517:         numbers[2] = investor.withdrewAmount;
518: 518: 518: 518: 518:         numbers[3] = investor.lastMaxOut;
519: 519: 519: 519: 519:         numbers[4] = investor.maxOutTimes;
520: 520: 520: 520: 520:         numbers[5] = investor.maxOutTimesInWeek;
521: 521: 521: 521: 521:         numbers[6] = investor.totalSell;
522: 522: 522: 522: 522:         numbers[7] = investor.sellThisMonth;
523: 523: 523: 523: 523:         numbers[8] = investor.rightSell;
524: 524: 524: 524: 524:         numbers[9] = investor.leftSell;
525: 525: 525: 525: 525:         numbers[10] = investor.reserveCommission;
526: 526: 526: 526: 526:         numbers[11] = investor.dailyIncomeWithrewAmount;
527: 527: 527: 527: 527:         numbers[12] = investor.registerTime;
528: 528: 528: 528: 528:         numbers[13] = getUnpaidSystemCommission(investorAddress);
529: 529: 529: 529: 529:         numbers[14] = getDailyIncomeForUser(investorAddress);
530: 530: 530: 530: 530:         numbers[15] = investor.minDeposit;
531: 531: 531: 531: 531:         return (addresses, investor.isDisabled, numbers);
532: 532: 532: 532: 532:     }
533: 533: 533: 533: 533: 
534: 534: 534: 534: 534:     function getInvestorLength() view public returns(uint256) { return investorAddresses.length; }
535: 535: 535: 535: 535: 
536: 536: 536: 536: 536:     function getMaxOutsLength() view public returns(uint256) { return maxOutIds.length; }
537: 537: 537: 537: 537:     
538: 538: 538: 538: 538:     function getNodesAddresses(address rootNodeAddress) public view returns(address[] memory){
539: 539: 539: 539: 539:         uint256 maxLength = investorAddresses.length;
540: 540: 540: 540: 540:         address[] memory nodes = new address[](maxLength);
541: 541: 541: 541: 541:         nodes[0] = rootNodeAddress;
542: 542: 542: 542: 542:         uint256 processIndex = 0;
543: 543: 543: 543: 543:         uint256 nextIndex = 1;
544: 544: 544: 544: 544:         while (processIndex != nextIndex) {
545: 545: 545: 545: 545:             Investor memory currentInvestor = investors[nodes[processIndex++]];
546: 546: 546: 546: 546:             if (currentInvestor.leftChild != address(0)) nodes[nextIndex++] = currentInvestor.leftChild;
547: 547: 547: 547: 547:             if (currentInvestor.rightChild != address(0)) nodes[nextIndex++] = currentInvestor.rightChild;
548: 548: 548: 548: 548:         }
549: 549: 549: 549: 549:         return nodes;
550: 550: 550: 550: 550:     }
551: 551: 551: 551: 551:     
552: 552: 552: 552: 552:     
553: 553: 553: 553: 553:     
554: 554: 554: 554: 554:     function getInvestmentsLength () public view returns(uint256 length) { return investmentIds.length; }
555: 555: 555: 555: 555:     
556: 556: 556: 556: 556:     function getWithdrawalsLength() public view returns(uint256 length) { return withdrawalIds.length; }
557: 557: 557: 557: 557:     
558: 558: 558: 558: 558:     
559: 559: 559: 559: 559: 
560: 560: 560: 560: 560:     function importInvestor(address[] memory addresses, bool isDisabled, uint256[] memory numbers) public mustBeImporting {
561: 561: 561: 561: 561:         if (investors[addresses[4]].generation != 0) return;
562: 562: 562: 562: 562:         Investor memory investor = Investor({
563: 563: 563: 563: 563:             isDisabled: isDisabled,
564: 564: 564: 564: 564:             parent: addresses[0],
565: 565: 565: 565: 565:             leftChild: addresses[1],
566: 566: 566: 566: 566:             rightChild: addresses[2],
567: 567: 567: 567: 567:             presenter: addresses[3],
568: 568: 568: 568: 568:             generation: numbers[0],
569: 569: 569: 569: 569:             depositedAmount: numbers[1],
570: 570: 570: 570: 570:             withdrewAmount: numbers[2],
571: 571: 571: 571: 571:             lastMaxOut: numbers[3],
572: 572: 572: 572: 572:             maxOutTimes: numbers[4],
573: 573: 573: 573: 573:             maxOutTimesInWeek: numbers[5],
574: 574: 574: 574: 574:             totalSell: numbers[6],
575: 575: 575: 575: 575:             sellThisMonth: numbers[7],
576: 576: 576: 576: 576:             investments: new bytes32[](0),
577: 577: 577: 577: 577:             withdrawals: new bytes32[](0),
578: 578: 578: 578: 578:             rightSell: numbers[8],
579: 579: 579: 579: 579:             leftSell: numbers[9],
580: 580: 580: 580: 580:             reserveCommission: numbers[10],
581: 581: 581: 581: 581:             dailyIncomeWithrewAmount: numbers[11],
582: 582: 582: 582: 582:             registerTime: numbers[12],
583: 583: 583: 583: 583:             minDeposit: MIN_DEP
584: 584: 584: 584: 584:         });
585: 585: 585: 585: 585:         investors[addresses[4]] = investor;
586: 586: 586: 586: 586:         investorAddresses.push(addresses[4]);
587: 587: 587: 587: 587:     }
588: 588: 588: 588: 588:     
589: 589: 589: 589: 589:     function importInvestments(bytes32 id, uint256 at, uint256 amount, address investorAddress) public mustBeImporting {
590: 590: 590: 590: 590:         if (investments[id].at != 0) return;
591: 591: 591: 591: 591:         Investment memory investment = Investment({ id: id, at: at, amount: amount, investor: investorAddress, nextInvestor: address(0), nextBranch: false });
592: 592: 592: 592: 592:         investments[id] = investment;
593: 593: 593: 593: 593:         investmentIds.push(id);
594: 594: 594: 594: 594:         Investor storage investor = investors[investorAddress];
595: 595: 595: 595: 595:         investor.investments.push(id);
596: 596: 596: 596: 596:         depositedAmountGross += amount;
597: 597: 597: 597: 597:     }
598: 598: 598: 598: 598:     
599: 599: 599: 599: 599:     function importWithdrawals(bytes32 id, uint256 at, uint256 amount, address investorAddress, address presentee, uint256 reason, uint256 times) public mustBeImporting {
600: 600: 600: 600: 600:         if (withdrawals[id].at != 0) return;
601: 601: 601: 601: 601:         Withdrawal memory withdrawal = Withdrawal({ id: id, at: at, amount: amount, investor: investorAddress, presentee: presentee, times: times, reason: reason });
602: 602: 602: 602: 602:         withdrawals[id] = withdrawal;
603: 603: 603: 603: 603:         Investor storage investor = investors[investorAddress];
604: 604: 604: 604: 604:         investor.withdrawals.push(id);
605: 605: 605: 605: 605:         withdrawalIds.push(id);
606: 606: 606: 606: 606:     }
607: 607: 607: 607: 607:     
608: 608: 608: 608: 608:     function finishImporting() public mustBeAdmin { importing = false; }
609: 609: 609: 609: 609: 
610: 610: 610: 610: 610:     function finalizeVotes(uint256 from, uint256 to) public mustBeAdmin {
611: 611: 611: 611: 611:         require(getNow() - currentVote.startTime > 3 * ONE_DAY);
612: 612: 612: 612: 612:         for (uint256 index = from; index < to; index++) {
613: 613: 613: 613: 613:             address investorAddress = investorAddresses[index];
614: 614: 614: 614: 614:             if (currentVote.votes[investorAddress] != 0) continue;
615: 615: 615: 615: 615:             currentVote.votes[investorAddress] = 2;
616: 616: 616: 616: 616:             currentVote.yesPoint += 1;
617: 617: 617: 617: 617:         }
618: 618: 618: 618: 618:     }
619: 619: 619: 619: 619: 
620: 620: 620: 620: 620:     function createVote(string memory reason, address payable emergencyAddress) public mustBeAdmin {
621: 621: 621: 621: 621:         require(currentVote.startTime == 0);
622: 622: 622: 622: 622:         currentVote = Vote({
623: 623: 623: 623: 623:             startTime: getNow(),
624: 624: 624: 624: 624:             reason: reason,
625: 625: 625: 625: 625:             emergencyAddress: emergencyAddress,
626: 626: 626: 626: 626:             yesPoint: 0,
627: 627: 627: 627: 627:             noPoint: 0,
628: 628: 628: 628: 628:             totalPoint: investorAddresses.length
629: 629: 629: 629: 629:         });
630: 630: 630: 630: 630:     }
631: 631: 631: 631: 631: 
632: 632: 632: 632: 632:     function removeVote() public mustBeAdmin {
633: 633: 633: 633: 633:         currentVote.startTime = 0;
634: 634: 634: 634: 634:         currentVote.reason = '';
635: 635: 635: 635: 635:         currentVote.emergencyAddress = address(0);
636: 636: 636: 636: 636:         currentVote.yesPoint = 0;
637: 637: 637: 637: 637:         currentVote.noPoint = 0;
638: 638: 638: 638: 638:     }
639: 639: 639: 639: 639:     
640: 640: 640: 640: 640:     function sendEtherToNewContract() public mustBeAdmin {
641: 641: 641: 641: 641:         require(currentVote.startTime != 0);
642: 642: 642: 642: 642:         require(getNow() - currentVote.startTime > 3 * ONE_DAY);
643: 643: 643: 643: 643:         require(currentVote.yesPoint > currentVote.totalPoint / 2);
644: 644: 644: 644: 644:         require(currentVote.emergencyAddress != address(0));
645: 645: 645: 645: 645:         bool isTransferSuccess = false;
646: 646: 646: 646: 646:         (isTransferSuccess, ) = currentVote.emergencyAddress.call.value(address(this).balance)("");
647: 647: 647: 647: 647:         if (!isTransferSuccess) revert();
648: 648: 648: 648: 648:     }
649: 649: 649: 649: 649: 
650: 650: 650: 650: 650:     function voteProcess(address investor, bool isYes) internal {
651: 651: 651: 651: 651:         require(investors[investor].depositedAmount > 0);
652: 652: 652: 652: 652:         require(!investors[investor].isDisabled);
653: 653: 653: 653: 653:         require(getNow() - currentVote.startTime < 3 * ONE_DAY);
654: 654: 654: 654: 654:         uint8 newVoteValue = isYes ? 2 : 1;
655: 655: 655: 655: 655:         uint8 currentVoteValue = currentVote.votes[investor];
656: 656: 656: 656: 656:         require(newVoteValue != currentVoteValue);
657: 657: 657: 657: 657:         updateVote(isYes);
658: 658: 658: 658: 658:         if (currentVoteValue == 0) return;
659: 659: 659: 659: 659:         if (isYes) {
660: 660: 660: 660: 660:             currentVote.noPoint -= getVoteShare();
661: 661: 661: 661: 661:         } else {
662: 662: 662: 662: 662:             currentVote.yesPoint -= getVoteShare();
663: 663: 663: 663: 663:         }
664: 664: 664: 664: 664:     }
665: 665: 665: 665: 665:     
666: 666: 666: 666: 666:     function vote(bool isYes) public { voteProcess(msg.sender, isYes); }
667: 667: 667: 667: 667:     
668: 668: 668: 668: 668:     function updateVote(bool isYes) internal {
669: 669: 669: 669: 669:         currentVote.votes[msg.sender] = isYes ? 2 : 1;
670: 670: 670: 670: 670:         if (isYes) {
671: 671: 671: 671: 671:             currentVote.yesPoint += getVoteShare();
672: 672: 672: 672: 672:         } else {
673: 673: 673: 673: 673:             currentVote.noPoint += getVoteShare();
674: 674: 674: 674: 674:         }
675: 675: 675: 675: 675:     }
676: 676: 676: 676: 676:     
677: 677: 677: 677: 677:     function getVoteShare() public view returns(uint256) {
678: 678: 678: 678: 678:         if (investors[msg.sender].generation >= 3) return 1;
679: 679: 679: 679: 679:         if (currentVote.totalPoint > 40) return currentVote.totalPoint / 20;
680: 680: 680: 680: 680:         return 2;
681: 681: 681: 681: 681:     }
682: 682: 682: 682: 682:     
683: 683: 683: 683: 683:     function setQuerier(address _querierAddress) public mustBeAdmin {
684: 684: 684: 684: 684:         querierAddress = _querierAddress;
685: 685: 685: 685: 685:     }
686: 686: 686: 686: 686: 
687: 687: 687: 687: 687:     function setAdmin2(address _admin2) public mustBeAdmin {
688: 688: 688: 688: 688:         admin2 = _admin2;
689: 689: 689: 689: 689:     }
690: 690: 690: 690: 690: 
691: 691: 691: 691: 691:     function setInitialValue(uint256 _paySystemCommissionTimes, uint256 _payDailyIncomeTimes, uint256 _lastPaySystemCommission, uint256 _lastPayDailyIncome, uint256 _contractStartAt, uint256 _lastReset) public mustBeImporting {
692: 692: 692: 692: 692:         paySystemCommissionTimes = _paySystemCommissionTimes;
693: 693: 693: 693: 693:         payDailyIncomeTimes = _payDailyIncomeTimes;
694: 694: 694: 694: 694:         lastPaySystemCommission = _lastPaySystemCommission;
695: 695: 695: 695: 695:         lastPayDailyIncome = _lastPayDailyIncome;
696: 696: 696: 696: 696:         contractStartAt = _contractStartAt;
697: 697: 697: 697: 697:         lastReset = _lastReset;
698: 698: 698: 698: 698:     }
699: 699: 699: 699: 699: }