1: 1: pragma solidity ^0.4.25;
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
13: 13: contract Staking {
14: 14: 	using SafeMath for *;
15: 15: 	
16: 16: 	
17: 17: 
18: 18: 
19: 19:     
20: 20:     event Transfer (
21: 21:         address indexed from,
22: 22:         address indexed to,
23: 23:         uint256 tokens
24: 24:     );
25: 25: 	
26: 26: 	event onDeposit (
27: 27: 		address indexed customer,
28: 28: 		uint256 tokens
29: 29: 	);
30: 30: 	
31: 31: 	event onReinvestProfit (
32: 32: 		address indexed customer,
33: 33: 		uint256 tokens
34: 34: 	);
35: 35: 	
36: 36: 	event onWithdrawProfit (
37: 37: 		address indexed customer,
38: 38: 		uint256 tokens
39: 39: 	);
40: 40: 	
41: 41: 	event onWithdrawCapital (
42: 42: 		address indexed customer,
43: 43: 		uint256 tokens
44: 44: 	);
45: 45: 	
46: 46: 	
47: 47: 	
48: 48: 
49: 49: 	
50: 50: 	modifier onlyTokenContract {
51: 51:         require(msg.sender == address(tokenContract_));
52: 52:         _;
53: 53:     }
54: 54: 	
55: 55: 	
56: 56:     modifier onlyBagholders() {
57: 57:         require(myDeposit() > 0);
58: 58:         _;
59: 59:     }
60: 60:     
61: 61:     
62: 62:     modifier onlyStronghands() {
63: 63:         require(myProfit(msg.sender) > 0);
64: 64:         _;
65: 65:     }
66: 66: 	
67: 67: 	
68: 68:     
69: 69:     
70: 70:     
71: 71:     
72: 72:     
73: 73:     
74: 74:     modifier onlyAdministrator(){
75: 75:         address _customerAddress = msg.sender;
76: 76:         require(administrator_ == _customerAddress);
77: 77:         _;
78: 78:     }
79: 79: 	
80: 80: 	
81: 81: 	
82: 82: 
83: 83: 
84: 84:     
85: 85:     mapping(address => Dealer) internal dealers_; 	
86: 86:     uint256 internal totalDeposit_ = 0;
87: 87: 	
88: 88: 	
89: 89: 	HyperETH public tokenContract_;
90: 90: 	
91: 91: 	
92: 92:     address internal administrator_;
93: 93: 	
94: 94: 	
95: 95: 	struct Dealer {
96: 96: 		uint256 deposit;		
97: 97: 		uint256 profit;			
98: 98: 		uint256 time;			
99: 99: 	}
100: 100:     
101: 101: 	
102: 102: 	
103: 103: 
104: 104: 
105: 105:     constructor() public {
106: 106: 		administrator_ = 0x73018870D10173ae6F71Cac3047ED3b6d175F274;
107: 107:     }
108: 108: 	
109: 109: 	function() payable external {
110: 110: 		
111: 111: 		
112: 112: 	}
113: 113: 	
114: 114: 	
115: 115: 
116: 116: 
117: 117: 
118: 118: 
119: 119: 
120: 120: 
121: 121:     function tokenFallback(address _from, uint256 _value, bytes _data)
122: 122: 		onlyTokenContract()
123: 123: 		external
124: 124: 		returns (bool)
125: 125: 	{
126: 126:         
127: 127: 		Dealer storage _dealer = dealers_[_from];
128: 128: 		
129: 129: 		
130: 130: 		_dealer.profit = myProfit(_from);	
131: 131: 
132: 132: 		_dealer.time = now;					
133: 133:         
134: 134: 		
135: 135: 		_dealer.deposit = _dealer.deposit.add(_value);
136: 136: 		totalDeposit_ = totalDeposit_.add(_value);
137: 137: 		
138: 138: 		
139: 139: 		emit onDeposit(_from, _value);
140: 140: 		
141: 141: 		return true;
142: 142: 		
143: 143: 		
144: 144: 		_data;
145: 145: 	}
146: 146: 	
147: 147: 	
148: 148: 
149: 149: 
150: 150: 	function reinvestProfit()
151: 151: 		onlyStronghands()
152: 152: 		public 
153: 153: 	{
154: 154: 		address _customerAddress = msg.sender;
155: 155: 		Dealer storage _dealer = dealers_[_customerAddress];
156: 156: 		
157: 157: 		uint256 _profits = myProfit(_customerAddress);
158: 158: 		
159: 159: 		
160: 160: 		_dealer.deposit = _dealer.deposit.add(_profits);	
161: 161: 		_dealer.profit = 0;									
162: 162: 		_dealer.time = now;									
163: 163: 		
164: 164: 		
165: 165: 		totalDeposit_ = totalDeposit_.add(_profits);
166: 166: 		
167: 167: 		
168: 168: 		emit onReinvestProfit(_customerAddress, _profits);
169: 169: 	}
170: 170: 	
171: 171: 	
172: 172: 
173: 173: 
174: 174: 	function withdrawProfit()
175: 175: 		onlyStronghands()
176: 176: 		public
177: 177: 	{
178: 178: 		address _customerAddress = msg.sender;
179: 179: 		Dealer storage _dealer = dealers_[_customerAddress];
180: 180: 		
181: 181: 		uint256 _profits = myProfit(_customerAddress);
182: 182: 		
183: 183: 		
184: 184: 		_dealer.profit = 0;		
185: 185: 		_dealer.time = now;		
186: 186: 		
187: 187: 		
188: 188: 		tokenContract_.transfer(_customerAddress, _profits);
189: 189: 		
190: 190: 		
191: 191: 		emit onWithdrawProfit(_customerAddress, _profits);
192: 192: 	}
193: 193: 	
194: 194: 	
195: 195: 
196: 196: 
197: 197: 	function withdrawCapital()
198: 198: 		onlyBagholders()
199: 199: 		public
200: 200: 	{
201: 201: 		address _customerAddress = msg.sender;
202: 202: 		Dealer storage _dealer = dealers_[_customerAddress];
203: 203: 		
204: 204: 		uint256 _deposit = _dealer.deposit;
205: 205: 		uint256 _taxedDeposit = _deposit.mul(90).div(100);
206: 206: 		uint256 _profits = myProfit(_customerAddress);
207: 207: 		
208: 208: 		
209: 209: 		_dealer.deposit = 0;
210: 210: 		_dealer.profit = _profits;
211: 211: 		
212: 212: 		
213: 213: 		
214: 214: 		
215: 215: 		totalDeposit_ = totalDeposit_.sub(_deposit);
216: 216: 		
217: 217: 		
218: 218: 		tokenContract_.transfer(_customerAddress, _taxedDeposit);
219: 219: 		
220: 220: 		
221: 221: 		emit onWithdrawCapital(_customerAddress, _taxedDeposit);
222: 222: 	}
223: 223: 	
224: 224: 	
225: 225: 
226: 226: 
227: 227: 	function reinvestEther()
228: 228: 		public
229: 229: 	{
230: 230: 		uint256 _balance = address(this).balance;
231: 231: 		if (_balance > 0) {
232: 232: 			
233: 233: 			if(!address(tokenContract_).call.value(_balance)()) {
234: 234: 				
235: 235: 				revert();
236: 236: 			}
237: 237: 		}
238: 238: 	}
239: 239: 	
240: 240: 	
241: 241: 
242: 242: 
243: 243: 	function reinvestDividends()
244: 244: 		public
245: 245: 	{
246: 246: 		uint256 _dividends = myDividends(true);
247: 247: 		if (_dividends > 0) {
248: 248: 			tokenContract_.reinvest();
249: 249: 		}
250: 250: 	}
251: 251: 	
252: 252: 	
253: 253: 		
254: 254:     
255: 255: 
256: 256: 
257: 257:     function totalDeposit()
258: 258:         public
259: 259:         view
260: 260:         returns(uint256)
261: 261:     {
262: 262:         return totalDeposit_;
263: 263:     }
264: 264: 	
265: 265: 	
266: 266: 
267: 267: 
268: 268:     function totalSupply()
269: 269:         public
270: 270:         view
271: 271:         returns(uint256)
272: 272:     {
273: 273:         return tokenContract_.myTokens();
274: 274:     }
275: 275: 	
276: 276: 	function stakepool()
277: 277: 		public
278: 278: 		view
279: 279: 		returns(int256)
280: 280: 	{
281: 281: 		uint256 _tokens = totalSupply();
282: 282: 		
283: 283: 		
284: 284: 		if (totalDeposit_ > 0) {
285: 285: 			
286: 286: 			
287: 287: 			return int256((1000).mul(_tokens).div(totalDeposit_) - 1000);
288: 288: 		} else {
289: 289: 			return 1000;	
290: 290: 		}
291: 291: 	}
292: 292: 	
293: 293: 	
294: 294: 
295: 295: 
296: 296:     function myDeposit()
297: 297:         public
298: 298:         view
299: 299:         returns(uint256)
300: 300:     {
301: 301: 		address _customerAddress = msg.sender;
302: 302:         Dealer storage _dealer = dealers_[_customerAddress];
303: 303:         return _dealer.deposit;
304: 304:     }
305: 305: 	
306: 306: 	
307: 307: 
308: 308: 
309: 309: 	function myProfit(address _customerAddress)
310: 310: 		public
311: 311: 		view
312: 312: 		returns(uint256)
313: 313: 	{
314: 314: 		Dealer storage _dealer = dealers_[_customerAddress];
315: 315: 		uint256 _oldProfits = _dealer.profit;
316: 316: 		uint256 _newProfits = 0;
317: 317: 		
318: 318: 		if (
319: 319: 			
320: 320: 			_dealer.time == 0 ||
321: 321: 			
322: 322: 			
323: 323: 			_dealer.deposit == 0
324: 324: 		)
325: 325: 		{
326: 326: 			_newProfits = 0;
327: 327: 		} else {
328: 328: 			
329: 329: 			uint256 _timeStaking = now - _dealer.time;
330: 330: 			
331: 331: 			_newProfits = _timeStaking	
332: 332: 				.mul(_dealer.deposit)	
333: 333: 				.mul(1000)				
334: 334: 				.div(100000)			
335: 335: 				.div(86400);			
336: 336: 		}
337: 337: 		
338: 338: 		
339: 339: 		return _newProfits.add(_oldProfits);
340: 340: 	}
341: 341: 	
342: 342: 	function myDividends(bool _includeReferralBonus)
343: 343: 		public
344: 344: 		view
345: 345: 		returns(uint256)
346: 346: 	{
347: 347: 		return tokenContract_.myDividends(_includeReferralBonus);
348: 348: 	}
349: 349: 	
350: 350: 	
351: 351: 
352: 352: 
353: 353: 	function setTokenContract(address _tokenContract)
354: 354: 		onlyAdministrator()
355: 355: 		public
356: 356: 	{
357: 357: 		tokenContract_ = HyperETH(_tokenContract);
358: 358: 	}
359: 359: }
360: 360: 
361: 361: 
362: 362: 
363: 363: 
364: 364: 
365: 365: 
366: 366: library SafeMath {
367: 367: 
368: 368:     
369: 369: 
370: 370: 
371: 371:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
372: 372:         if (a == 0) {
373: 373:             return 0;
374: 374:         }
375: 375:         uint256 c = a * b;
376: 376:         assert(c / a == b);
377: 377:         return c;
378: 378:     }
379: 379: 
380: 380:     
381: 381: 
382: 382: 
383: 383:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
384: 384:         
385: 385:         uint256 c = a / b;
386: 386:         
387: 387:         return c;
388: 388:     }
389: 389: 
390: 390:     
391: 391: 
392: 392: 
393: 393:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
394: 394:         assert(b <= a);
395: 395:         return a - b;
396: 396:     }
397: 397: 
398: 398:     
399: 399: 
400: 400: 
401: 401:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
402: 402:         uint256 c = a + b;
403: 403:         assert(c >= a);
404: 404:         return c;
405: 405:     }
406: 406: }