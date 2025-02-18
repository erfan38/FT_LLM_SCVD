1: 1: 1: 1: 1: pragma solidity ^0.5.0;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: 
8: 8: 8: 8: 8: 
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10: 
11: 11: 11: 11: 11: 
12: 12: 12: 12: 12: 
13: 13: 13: 13: 13: 
14: 14: 14: 14: 14: 
15: 15: 15: 15: 15: 
16: 16: 16: 16: 16: 
17: 17: 17: 17: 17: 
18: 18: 18: 18: 18: 
19: 19: 19: 19: 19: 
20: 20: 20: 20: 20: 
21: 21: 21: 21: 21: 
22: 22: 22: 22: 22: 
23: 23: 23: 23: 23: 
24: 24: 24: 24: 24: 
25: 25: 25: 25: 25: 
26: 26: 26: 26: 26: 
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28: 
29: 29: 29: 29: 29: 
30: 30: 30: 30: 30: 
31: 31: 31: 31: 31: 
32: 32: 32: 32: 32: 
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37: 
38: 38: 38: 38: 38: 
39: 39: 39: 39: 39: 
40: 40: 40: 40: 40: 
41: 41: 41: 41: 41: 
42: 42: 42: 42: 42: 
43: 43: 43: 43: 43: 
44: 44: 44: 44: 44: 
45: 45: 45: 45: 45: 
46: 46: 46: 46: 46: 
47: 47: 47: 47: 47: 
48: 48: 48: 48: 48: 
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50: 
51: 51: 51: 51: 51: 
52: 52: 52: 52: 52: 
53: 53: 53: 53: 53: 
54: 54: 54: 54: 54: 
55: 55: 55: 55: 55: 
56: 56: 56: 56: 56: 
57: 57: 57: 57: 57: interface ERC20interface {
58: 58: 58: 58: 58: 	function transfer(address to, uint value) external returns(bool success);
59: 59: 59: 59: 59: 	function approve(address spender, uint tokens) external returns(bool success);
60: 60: 60: 60: 60: 	function transferFrom(address from, address to, uint tokens) external returns(bool success);
61: 61: 61: 61: 61: 
62: 62: 62: 62: 62: 	function allowance(address tokenOwner, address spender) external view returns(uint remaining);
63: 63: 63: 63: 63: 	function balanceOf(address tokenOwner) external view returns(uint balance);
64: 64: 64: 64: 64: }
65: 65: 65: 65: 65: 
66: 66: 66: 66: 66: interface ERC223interface {
67: 67: 67: 67: 67: 	function transfer(address to, uint value) external returns(bool ok);
68: 68: 68: 68: 68: 	function transfer(address to, uint value, bytes calldata data) external returns(bool ok);
69: 69: 69: 69: 69: 	function transfer(address to, uint value, bytes calldata data, string calldata customFallback) external returns(bool ok);
70: 70: 70: 70: 70: 
71: 71: 71: 71: 71: 	function balanceOf(address who) external view returns(uint);
72: 72: 72: 72: 72: }
73: 73: 73: 73: 73: 
74: 74: 74: 74: 74: 
75: 75: 75: 75: 75: interface ERC223Handler {
76: 76: 76: 76: 76: 	function tokenFallback(address _from, uint _value, bytes calldata _data) external;
77: 77: 77: 77: 77: }
78: 78: 78: 78: 78: 
79: 79: 79: 79: 79: 
80: 80: 80: 80: 80: interface ExternalGauntletInterface {
81: 81: 81: 81: 81: 	function gauntletRequirement(address wearer, uint256 oldAmount, uint256 newAmount) external returns(bool);
82: 82: 82: 82: 82: 	function gauntletRemovable(address wearer) external view returns(bool);
83: 83: 83: 83: 83: }
84: 84: 84: 84: 84: 
85: 85: 85: 85: 85: 
86: 86: 86: 86: 86: interface Hourglass {
87: 87: 87: 87: 87: 	function decimals() external view returns(uint8);
88: 88: 88: 88: 88: 	function stakingRequirement() external view returns(uint256);
89: 89: 89: 89: 89: 	function balanceOf(address tokenOwner) external view returns(uint);
90: 90: 90: 90: 90: 	function dividendsOf(address tokenOwner) external view returns(uint);
91: 91: 91: 91: 91: 	function calculateTokensReceived(uint256 _ethereumToSpend) external view returns(uint256);
92: 92: 92: 92: 92: 	function calculateEthereumReceived(uint256 _tokensToSell) external view returns(uint256);
93: 93: 93: 93: 93: 	function myTokens() external view returns(uint256);
94: 94: 94: 94: 94: 	function myDividends(bool _includeReferralBonus) external view returns(uint256);
95: 95: 95: 95: 95: 	function totalSupply() external view returns(uint256);
96: 96: 96: 96: 96: 
97: 97: 97: 97: 97: 	function transfer(address to, uint value) external returns(bool);
98: 98: 98: 98: 98: 	function buy(address referrer) external payable returns(uint256);
99: 99: 99: 99: 99: 	function sell(uint256 amount) external;
100: 100: 100: 100: 100: 	function withdraw() external;
101: 101: 101: 101: 101: }
102: 102: 102: 102: 102: 
103: 103: 103: 103: 103: 
104: 104: 104: 104: 104: interface TeamJustPlayerBook {
105: 105: 105: 105: 105: 	function pIDxName_(bytes32 name) external view returns(uint256);
106: 106: 106: 106: 106: 	function pIDxAddr_(address addr) external view returns(uint256);
107: 107: 107: 107: 107: 	function getPlayerAddr(uint256 pID) external view returns(address);
108: 108: 108: 108: 108: }
109: 109: 109: 109: 109: 
110: 110: 110: 110: 110: 
111: 111: 111: 111: 111: 
112: 112: 112: 112: 112: 
113: 113: 113: 113: 113: 
114: 114: 114: 114: 114: 
115: 115: 115: 115: 115: 
116: 116: 116: 116: 116: 
117: 117: 117: 117: 117: 
118: 118: 118: 118: 118: 
119: 119: 119: 119: 119: 
120: 120: 120: 120: 120: 
121: 121: 121: 121: 121: 
122: 122: 122: 122: 122: 
123: 123: 123: 123: 123: 
124: 124: 124: 124: 124: 
125: 125: 125: 125: 125: 
126: 126: 126: 126: 126: 
127: 127: 127: 127: 127: 
128: 128: 128: 128: 128: 
129: 129: 129: 129: 129: 
130: 130: 130: 130: 130: 
131: 131: 131: 131: 131: 
132: 132: 132: 132: 132: 
133: 133: 133: 133: 133: 
134: 134: 134: 134: 134: 
135: 135: 135: 135: 135: 
136: 136: 136: 136: 136: 
137: 137: 137: 137: 137: 
138: 138: 138: 138: 138: 
139: 139: 139: 139: 139: 
140: 140: 140: 140: 140: 
141: 141: 141: 141: 141: 
142: 142: 142: 142: 142: 
143: 143: 143: 143: 143: 
144: 144: 144: 144: 144: 
145: 145: 145: 145: 145: 
146: 146: 146: 146: 146: 
147: 147: 147: 147: 147: 
148: 148: 148: 148: 148: 
149: 149: 149: 149: 149: 
150: 150: 150: 150: 150: 
151: 151: 151: 151: 151: 
152: 152: 152: 152: 152: 
153: 153: 153: 153: 153: 
154: 154: 154: 154: 154: 
155: 155: 155: 155: 155: 
156: 156: 156: 156: 156: 
157: 157: 157: 157: 157: 
158: 158: 158: 158: 158: 
159: 159: 159: 159: 159: 
160: 160: 160: 160: 160: 
161: 161: 161: 161: 161: 
162: 162: 162: 162: 162: 
163: 163: 163: 163: 163: 
164: 164: 164: 164: 164: 
165: 165: 165: 165: 165: 
166: 166: 166: 166: 166: 
167: 167: 167: 167: 167: 
168: 168: 168: 168: 168: 
169: 169: 169: 169: 169: 
170: 170: 170: 170: 170: 
171: 171: 171: 171: 171: 
172: 172: 172: 172: 172: 
173: 173: 173: 173: 173: 
174: 174: 174: 174: 174: 
175: 175: 175: 175: 175: 
176: 176: 176: 176: 176: 
177: 177: 177: 177: 177: 
178: 178: 178: 178: 178: 
179: 179: 179: 179: 179: 
180: 180: 180: 180: 180: 
181: 181: 181: 181: 181: 
182: 182: 182: 182: 182: 
183: 183: 183: 183: 183: 
184: 184: 184: 184: 184: 
185: 185: 185: 185: 185: 
186: 186: 186: 186: 186: 
187: 187: 187: 187: 187: 
188: 188: 188: 188: 188: 
189: 189: 189: 189: 189: 
190: 190: 190: 190: 190: 
191: 191: 191: 191: 191: 
192: 192: 192: 192: 192: 
193: 193: 193: 193: 193: 
194: 194: 194: 194: 194: 
195: 195: 195: 195: 195: 
196: 196: 196: 196: 196: 
197: 197: 197: 197: 197: contract HourglassX {
198: 198: 198: 198: 198: 	using SafeMath for uint256;
199: 199: 199: 199: 199: 	using SafeMath for uint;
200: 200: 200: 200: 200: 	using SafeMath for int256;
201: 201: 201: 201: 201: 
202: 202: 202: 202: 202: 	modifier onlyOwner {
203: 203: 203: 203: 203: 		require(msg.sender == owner);
204: 204: 204: 204: 204: 		_;
205: 205: 205: 205: 205: 	}
206: 206: 206: 206: 206: 
207: 207: 207: 207: 207: 	modifier playerBookEnabled {
208: 208: 208: 208: 208: 		require(address(playerBook) != NULL_ADDRESS, "named referrals not enabled");
209: 209: 209: 209: 209: 		_;
210: 210: 210: 210: 210: 	}
211: 211: 211: 211: 211: 
212: 212: 212: 212: 212: 	
213: 213: 213: 213: 213: 	constructor(address h, address p) public {
214: 214: 214: 214: 214: 		
215: 215: 215: 215: 215: 		name = "PoWH3D Extended";
216: 216: 216: 216: 216: 		symbol = "P3X";
217: 217: 217: 217: 217: 		decimals = 18;
218: 218: 218: 218: 218: 		totalSupply = 0;
219: 219: 219: 219: 219: 
220: 220: 220: 220: 220: 		
221: 221: 221: 221: 221: 		hourglass = Hourglass(h);
222: 222: 222: 222: 222: 		playerBook = TeamJustPlayerBook(p);
223: 223: 223: 223: 223: 
224: 224: 224: 224: 224: 		
225: 225: 225: 225: 225: 		referralRequirement = hourglass.stakingRequirement();
226: 226: 226: 226: 226: 
227: 227: 227: 227: 227: 		
228: 228: 228: 228: 228: 		refHandler = new HourglassXReferralHandler(hourglass);
229: 229: 229: 229: 229: 
230: 230: 230: 230: 230: 		
231: 231: 231: 231: 231: 		ignoreTokenFallbackEnable = false;
232: 232: 232: 232: 232: 		owner = msg.sender;
233: 233: 233: 233: 233: 	}
234: 234: 234: 234: 234: 	
235: 235: 235: 235: 235: 	address owner;
236: 236: 236: 236: 236: 	address newOwner;
237: 237: 237: 237: 237: 
238: 238: 238: 238: 238: 	uint256 referralRequirement;
239: 239: 239: 239: 239: 	uint256 internal profitPerShare = 0;
240: 240: 240: 240: 240: 	uint256 public lastTotalBalance = 0;
241: 241: 241: 241: 241: 	uint256 constant internal ROUNDING_MAGNITUDE = 2**64;
242: 242: 242: 242: 242: 	address constant internal NULL_ADDRESS = 0x0000000000000000000000000000000000000000;
243: 243: 243: 243: 243: 
244: 244: 244: 244: 244: 	
245: 245: 245: 245: 245: 	uint8 constant internal HOURGLASS_FEE = 10;
246: 246: 246: 246: 246: 	uint8 constant internal HOURGLASS_BONUS = 3;
247: 247: 247: 247: 247: 
248: 248: 248: 248: 248: 	
249: 249: 249: 249: 249: 	Hourglass internal hourglass;
250: 250: 250: 250: 250: 	HourglassXReferralHandler internal refHandler;
251: 251: 251: 251: 251: 	TeamJustPlayerBook internal playerBook;
252: 252: 252: 252: 252: 
253: 253: 253: 253: 253: 	
254: 254: 254: 254: 254: 	mapping(address => int256) internal payouts;
255: 255: 255: 255: 255: 	mapping(address => uint256) internal bonuses;
256: 256: 256: 256: 256: 	mapping(address => address) public savedReferral;
257: 257: 257: 257: 257: 
258: 258: 258: 258: 258: 	
259: 259: 259: 259: 259: 	mapping(address => mapping (address => bool)) internal ignoreTokenFallbackList;
260: 260: 260: 260: 260: 	bool internal ignoreTokenFallbackEnable;
261: 261: 261: 261: 261: 
262: 262: 262: 262: 262: 	
263: 263: 263: 263: 263: 	mapping(address => uint256) internal gauntletBalance;
264: 264: 264: 264: 264: 	mapping(address => uint256) internal gauntletEnd;
265: 265: 265: 265: 265: 	mapping(address => uint8) internal gauntletType; 
266: 266: 266: 266: 266: 
267: 267: 267: 267: 267: 	
268: 268: 268: 268: 268: 	mapping(address => uint256) internal balances;
269: 269: 269: 269: 269: 	mapping(address => mapping (address => uint256)) internal allowances;
270: 270: 270: 270: 270: 	string public name;
271: 271: 271: 271: 271: 	string public symbol;
272: 272: 272: 272: 272: 	uint8 public decimals;
273: 273: 273: 273: 273: 	uint256 public totalSupply;
274: 274: 274: 274: 274: 
275: 275: 275: 275: 275: 	
276: 276: 276: 276: 276: 	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
277: 277: 277: 277: 277: 	event Transfer(address indexed from, address indexed to, uint value);
278: 278: 278: 278: 278: 	event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
279: 279: 279: 279: 279: 	
280: 280: 280: 280: 280: 	
281: 281: 281: 281: 281: 	
282: 282: 282: 282: 282: 
283: 283: 283: 283: 283: 
284: 284: 284: 284: 284: 	event onTokenPurchase(
285: 285: 285: 285: 285: 		address indexed accountHolder,
286: 286: 286: 286: 286: 		uint256 ethereumSpent,
287: 287: 287: 287: 287: 		uint256 tokensCreated,
288: 288: 288: 288: 288: 		
289: 289: 289: 289: 289: 		uint256 tokensGiven,
290: 290: 290: 290: 290: 		address indexed referrer,
291: 291: 291: 291: 291: 		uint8 indexed bitFlags 
292: 292: 292: 292: 292: 	);
293: 293: 293: 293: 293: 	event onTokenSell(
294: 294: 294: 294: 294: 		address indexed accountHolder,
295: 295: 295: 295: 295: 		uint256 tokensDestroyed,
296: 296: 296: 296: 296: 		uint256 ethereumEarned
297: 297: 297: 297: 297: 	);
298: 298: 298: 298: 298: 	event onWithdraw(
299: 299: 299: 299: 299: 		address indexed accountHolder,
300: 300: 300: 300: 300: 		uint256 earningsWithdrawn,
301: 301: 301: 301: 301: 		uint256 refBonusWithdrawn,
302: 302: 302: 302: 302: 		bool indexed reinvestment
303: 303: 303: 303: 303: 	);
304: 304: 304: 304: 304: 	event onDonatedDividends(
305: 305: 305: 305: 305: 		address indexed donator,
306: 306: 306: 306: 306: 		uint256 ethereumDonated
307: 307: 307: 307: 307: 	);
308: 308: 308: 308: 308: 	event onGauntletAcquired(
309: 309: 309: 309: 309: 		address indexed strongHands,
310: 310: 310: 310: 310: 		uint256 stakeAmount,
311: 311: 311: 311: 311: 		uint8 indexed gauntletType,
312: 312: 312: 312: 312: 		uint256 end
313: 313: 313: 313: 313: 	);
314: 314: 314: 314: 314: 	event onExternalGauntletAcquired(
315: 315: 315: 315: 315: 		address indexed strongHands,
316: 316: 316: 316: 316: 		uint256 stakeAmount,
317: 317: 317: 317: 317: 		address indexed extGauntlet
318: 318: 318: 318: 318: 	);
319: 319: 319: 319: 319: 	
320: 320: 320: 320: 320: 
321: 321: 321: 321: 321: 	
322: 322: 322: 322: 322: 	function setNewOwner(address o) public onlyOwner {
323: 323: 323: 323: 323: 		newOwner = o;
324: 324: 324: 324: 324: 	}
325: 325: 325: 325: 325: 
326: 326: 326: 326: 326: 	function acceptNewOwner() public {
327: 327: 327: 327: 327: 		require(msg.sender == newOwner);
328: 328: 328: 328: 328: 		owner = msg.sender;
329: 329: 329: 329: 329: 	}
330: 330: 330: 330: 330: 
331: 331: 331: 331: 331: 	
332: 332: 332: 332: 332: 	function rebrand(string memory n, string memory s) public onlyOwner {
333: 333: 333: 333: 333: 		name = n;
334: 334: 334: 334: 334: 		symbol = s;
335: 335: 335: 335: 335: 	}
336: 336: 336: 336: 336: 
337: 337: 337: 337: 337: 	
338: 338: 338: 338: 338: 	function setReferralRequirement(uint256 r) public onlyOwner {
339: 339: 339: 339: 339: 		referralRequirement = r;
340: 340: 340: 340: 340: 	}
341: 341: 341: 341: 341: 
342: 342: 342: 342: 342: 	
343: 343: 343: 343: 343: 	function allowIgnoreTokenFallback() public onlyOwner {
344: 344: 344: 344: 344: 		ignoreTokenFallbackEnable = true;
345: 345: 345: 345: 345: 	}
346: 346: 346: 346: 346: 	
347: 347: 347: 347: 347: 
348: 348: 348: 348: 348: 	
349: 349: 349: 349: 349: 
350: 350: 350: 350: 350: 	
351: 351: 351: 351: 351: 	
352: 352: 352: 352: 352: 	
353: 353: 353: 353: 353: 	
354: 354: 354: 354: 354: 	function ignoreTokenFallback(address to, bool ignore) public {
355: 355: 355: 355: 355: 		require(ignoreTokenFallbackEnable, "This function is disabled");
356: 356: 356: 356: 356: 		ignoreTokenFallbackList[msg.sender][to] = ignore;
357: 357: 357: 357: 357: 	}
358: 358: 358: 358: 358: 
359: 359: 359: 359: 359: 	
360: 360: 360: 360: 360: 	function transfer(address payable to, uint value, bytes memory data, string memory func) public returns(bool) {
361: 361: 361: 361: 361: 		actualTransfer(msg.sender, to, value, data, func, true);
362: 362: 362: 362: 362: 		return true;
363: 363: 363: 363: 363: 	}
364: 364: 364: 364: 364: 
365: 365: 365: 365: 365: 	
366: 366: 366: 366: 366: 	function transfer(address payable to, uint value, bytes memory data) public returns(bool) {
367: 367: 367: 367: 367: 		actualTransfer(msg.sender, to, value, data, "", true);
368: 368: 368: 368: 368: 		return true;
369: 369: 369: 369: 369: 	}
370: 370: 370: 370: 370: 
371: 371: 371: 371: 371: 	
372: 372: 372: 372: 372: 	function transfer(address payable to, uint value) public returns(bool) {
373: 373: 373: 373: 373: 		actualTransfer(msg.sender, to, value, "", "", !ignoreTokenFallbackList[msg.sender][to]);
374: 374: 374: 374: 374: 		return true;
375: 375: 375: 375: 375: 	}
376: 376: 376: 376: 376: 
377: 377: 377: 377: 377: 	
378: 378: 378: 378: 378: 	function approve(address spender, uint value) public returns(bool) {
379: 379: 379: 379: 379: 		require(updateUsableBalanceOf(msg.sender) >= value, "Insufficient balance to approve");
380: 380: 380: 380: 380: 		allowances[msg.sender][spender] = value;
381: 381: 381: 381: 381: 		emit Approval(msg.sender, spender, value);
382: 382: 382: 382: 382: 		return true;
383: 383: 383: 383: 383: 	}
384: 384: 384: 384: 384: 
385: 385: 385: 385: 385: 	
386: 386: 386: 386: 386: 	function transferFrom(address payable from, address payable to, uint value) public returns(bool success) {
387: 387: 387: 387: 387: 		uint256 allowance = allowances[from][msg.sender];
388: 388: 388: 388: 388: 		require(allowance > 0, "Not approved");
389: 389: 389: 389: 389: 		require(allowance >= value, "Over spending limit");
390: 390: 390: 390: 390: 		allowances[from][msg.sender] = allowance.sub(value);
391: 391: 391: 391: 391: 		actualTransfer(from, to, value, "", "", false);
392: 392: 392: 392: 392: 		return true;
393: 393: 393: 393: 393: 	}
394: 394: 394: 394: 394: 
395: 395: 395: 395: 395: 	
396: 396: 396: 396: 396: 	function() payable external{
397: 397: 397: 397: 397: 		
398: 398: 398: 398: 398: 		if (msg.sender != address(hourglass) && msg.sender != address(refHandler)) {
399: 399: 399: 399: 399: 			
400: 400: 400: 400: 400: 			
401: 401: 401: 401: 401: 			if (msg.value > 0) {
402: 402: 402: 402: 402: 				lastTotalBalance += msg.value;
403: 403: 403: 403: 403: 				distributeDividends(0, NULL_ADDRESS);
404: 404: 404: 404: 404: 				lastTotalBalance -= msg.value;
405: 405: 405: 405: 405: 			}
406: 406: 406: 406: 406: 			createTokens(msg.sender, msg.value, NULL_ADDRESS, false);
407: 407: 407: 407: 407: 		}
408: 408: 408: 408: 408: 	}
409: 409: 409: 409: 409: 
410: 410: 410: 410: 410: 	
411: 411: 411: 411: 411: 	
412: 412: 412: 412: 412: 	function acquireGauntlet(uint256 amount, uint8 gType, uint256 end) public{
413: 413: 413: 413: 413: 		require(amount <= balances[msg.sender], "Insufficient balance");
414: 414: 414: 414: 414: 
415: 415: 415: 415: 415: 		
416: 416: 416: 416: 416: 		
417: 417: 417: 417: 417: 		uint256 oldGauntletType = gauntletType[msg.sender];
418: 418: 418: 418: 418: 		uint256 oldGauntletBalance = gauntletBalance[msg.sender];
419: 419: 419: 419: 419: 		uint256 oldGauntletEnd = gauntletEnd[msg.sender];
420: 420: 420: 420: 420: 
421: 421: 421: 421: 421: 		gauntletType[msg.sender] = gType;
422: 422: 422: 422: 422: 		gauntletEnd[msg.sender] = end;
423: 423: 423: 423: 423: 		gauntletBalance[msg.sender] = amount;
424: 424: 424: 424: 424: 
425: 425: 425: 425: 425: 		if (oldGauntletType == 0) {
426: 426: 426: 426: 426: 			if (gType == 1) {
427: 427: 427: 427: 427: 				require(end >= (block.timestamp + 97200), "Gauntlet time must be >= 4 weeks"); 
428: 428: 428: 428: 428: 				emit onGauntletAcquired(msg.sender, amount, gType, end);
429: 429: 429: 429: 429: 			} else if (gType == 2) {
430: 430: 430: 430: 430: 				uint256 P3DSupply = hourglass.totalSupply();
431: 431: 431: 431: 431: 				require(end >= (P3DSupply + (P3DSupply / 5)), "Gauntlet must make a profit"); 
432: 432: 432: 432: 432: 				emit onGauntletAcquired(msg.sender, amount, gType, end);
433: 433: 433: 433: 433: 			} else if (gType == 3) {
434: 434: 434: 434: 434: 				require(end <= 0x00ffffffffffffffffffffffffffffffffffffffff, "Invalid address");
435: 435: 435: 435: 435: 				require(ExternalGauntletInterface(address(end)).gauntletRequirement(msg.sender, 0, amount), "External gauntlet check failed");
436: 436: 436: 436: 436: 				emit onExternalGauntletAcquired(msg.sender, amount, address(end));
437: 437: 437: 437: 437: 			} else {
438: 438: 438: 438: 438: 				revert("Invalid gauntlet type");
439: 439: 439: 439: 439: 			}
440: 440: 440: 440: 440: 		} else if (oldGauntletType == 3) {
441: 441: 441: 441: 441: 			require(gType == 3, "New gauntlet must be same type");
442: 442: 442: 442: 442: 			require(end == gauntletEnd[msg.sender], "Must be same external gauntlet");
443: 443: 443: 443: 443: 			require(ExternalGauntletInterface(address(end)).gauntletRequirement(msg.sender, oldGauntletBalance, amount), "External gauntlet check failed");
444: 444: 444: 444: 444: 			emit onExternalGauntletAcquired(msg.sender, amount, address(end));
445: 445: 445: 445: 445: 		} else {
446: 446: 446: 446: 446: 			require(gType == oldGauntletType, "New gauntlet must be same type");
447: 447: 447: 447: 447: 			require(end > oldGauntletEnd, "Gauntlet must be an upgrade");
448: 448: 448: 448: 448: 			require(amount >= oldGauntletBalance, "New gauntlet must hold more tokens");
449: 449: 449: 449: 449: 			emit onGauntletAcquired(msg.sender, amount, gType, end);
450: 450: 450: 450: 450: 		}
451: 451: 451: 451: 451: 	}
452: 452: 452: 452: 452: 
453: 453: 453: 453: 453: 	function acquireExternalGauntlet(uint256 amount, address extGauntlet) public{
454: 454: 454: 454: 454: 		acquireGauntlet(amount, 3, uint256(extGauntlet));
455: 455: 455: 455: 455: 	}
456: 456: 456: 456: 456: 
457: 457: 457: 457: 457: 	
458: 458: 458: 458: 458: 	
459: 459: 459: 459: 459: 	function buy(address referrerAddress) payable public returns(uint256) {
460: 460: 460: 460: 460: 		
461: 461: 461: 461: 461: 		
462: 462: 462: 462: 462: 		if (msg.value > 0) {
463: 463: 463: 463: 463: 			lastTotalBalance += msg.value;
464: 464: 464: 464: 464: 			distributeDividends(0, NULL_ADDRESS);
465: 465: 465: 465: 465: 			lastTotalBalance -= msg.value;
466: 466: 466: 466: 466: 		}
467: 467: 467: 467: 467: 		return createTokens(msg.sender, msg.value, referrerAddress, false);
468: 468: 468: 468: 468: 	}
469: 469: 469: 469: 469: 
470: 470: 470: 470: 470: 	
471: 471: 471: 471: 471: 	
472: 472: 472: 472: 472: 	
473: 473: 473: 473: 473: 	function buy(string memory referrerName) payable public playerBookEnabled returns(uint256) {
474: 474: 474: 474: 474: 		address referrerAddress = getAddressFromReferralName(referrerName);
475: 475: 475: 475: 475: 		
476: 476: 476: 476: 476: 		if (msg.value > 0) {
477: 477: 477: 477: 477: 			lastTotalBalance += msg.value;
478: 478: 478: 478: 478: 			distributeDividends(0, NULL_ADDRESS);
479: 479: 479: 479: 479: 			lastTotalBalance -= msg.value;
480: 480: 480: 480: 480: 		}
481: 481: 481: 481: 481: 		return createTokens(msg.sender, msg.value, referrerAddress, false);
482: 482: 482: 482: 482: 	}
483: 483: 483: 483: 483: 
484: 484: 484: 484: 484: 	
485: 485: 485: 485: 485: 	
486: 486: 486: 486: 486: 	function reinvest() public returns(uint256) {
487: 487: 487: 487: 487: 		address accountHolder = msg.sender;
488: 488: 488: 488: 488: 		distributeDividends(0, NULL_ADDRESS); 
489: 489: 489: 489: 489: 		uint256 payout;
490: 490: 490: 490: 490: 		uint256 bonusPayout;
491: 491: 491: 491: 491: 		(payout, bonusPayout) = clearDividends(accountHolder);
492: 492: 492: 492: 492: 		emit onWithdraw(accountHolder, payout, bonusPayout, true);
493: 493: 493: 493: 493: 		return createTokens(accountHolder, payout + bonusPayout, NULL_ADDRESS, true);
494: 494: 494: 494: 494: 	}
495: 495: 495: 495: 495: 
496: 496: 496: 496: 496: 	
497: 497: 497: 497: 497: 	
498: 498: 498: 498: 498: 	
499: 499: 499: 499: 499: 	function reinvestPartial(uint256 ethToReinvest, bool withdrawAfter) public returns(uint256 tokensCreated) {
500: 500: 500: 500: 500: 		address payable accountHolder = msg.sender;
501: 501: 501: 501: 501: 		distributeDividends(0, NULL_ADDRESS); 
502: 502: 502: 502: 502: 
503: 503: 503: 503: 503: 		uint256 payout = dividendsOf(accountHolder, false);
504: 504: 504: 504: 504: 		uint256 bonusPayout = bonuses[accountHolder];
505: 505: 505: 505: 505: 
506: 506: 506: 506: 506: 		uint256 payoutReinvested = 0;
507: 507: 507: 507: 507: 		uint256 bonusReinvested;
508: 508: 508: 508: 508: 
509: 509: 509: 509: 509: 		require((payout + bonusPayout) >= ethToReinvest, "Insufficient balance for reinvestment");
510: 510: 510: 510: 510: 		
511: 511: 511: 511: 511: 		if (ethToReinvest > bonusPayout){
512: 512: 512: 512: 512: 			payoutReinvested = ethToReinvest - bonusPayout;
513: 513: 513: 513: 513: 			bonusReinvested = bonusPayout;
514: 514: 514: 514: 514: 			
515: 515: 515: 515: 515: 			payouts[accountHolder] += int256(payoutReinvested * ROUNDING_MAGNITUDE);
516: 516: 516: 516: 516: 		}else{
517: 517: 517: 517: 517: 			bonusReinvested = ethToReinvest;
518: 518: 518: 518: 518: 		}
519: 519: 519: 519: 519: 		
520: 520: 520: 520: 520: 		bonuses[accountHolder] -= bonusReinvested;
521: 521: 521: 521: 521: 
522: 522: 522: 522: 522: 		emit onWithdraw(accountHolder, payoutReinvested, bonusReinvested, true);
523: 523: 523: 523: 523: 		
524: 524: 524: 524: 524: 		tokensCreated = createTokens(accountHolder, ethToReinvest, NULL_ADDRESS, true);
525: 525: 525: 525: 525: 
526: 526: 526: 526: 526: 		if (withdrawAfter && dividendsOf(msg.sender, true) > 0) {
527: 527: 527: 527: 527: 			withdrawDividends(msg.sender);
528: 528: 528: 528: 528: 		}
529: 529: 529: 529: 529: 		return tokensCreated;
530: 530: 530: 530: 530: 	}
531: 531: 531: 531: 531: 
532: 532: 532: 532: 532: 	
533: 533: 533: 533: 533: 	function reinvestPartial(uint256 ethToReinvest) public returns(uint256) {
534: 534: 534: 534: 534: 		return reinvestPartial(ethToReinvest, true);
535: 535: 535: 535: 535: 	}
536: 536: 536: 536: 536: 
537: 537: 537: 537: 537: 	
538: 538: 538: 538: 538: 	function sell(uint256 amount, bool withdrawAfter) public returns(uint256) {
539: 539: 539: 539: 539: 		require(amount > 0, "You have to sell something");
540: 540: 540: 540: 540: 		uint256 sellAmount = destroyTokens(msg.sender, amount);
541: 541: 541: 541: 541: 		if (withdrawAfter && dividendsOf(msg.sender, true) > 0) {
542: 542: 542: 542: 542: 			withdrawDividends(msg.sender);
543: 543: 543: 543: 543: 		}
544: 544: 544: 544: 544: 		return sellAmount;
545: 545: 545: 545: 545: 	}
546: 546: 546: 546: 546: 
547: 547: 547: 547: 547: 	
548: 548: 548: 548: 548: 	function sell(uint256 amount) public returns(uint256) {
549: 549: 549: 549: 549: 		require(amount > 0, "You have to sell something");
550: 550: 550: 550: 550: 		return destroyTokens(msg.sender, amount);
551: 551: 551: 551: 551: 	}
552: 552: 552: 552: 552: 
553: 553: 553: 553: 553: 	
554: 554: 554: 554: 554: 	function withdraw() public{
555: 555: 555: 555: 555: 		require(dividendsOf(msg.sender, true) > 0, "No dividends to withdraw");
556: 556: 556: 556: 556: 		withdrawDividends(msg.sender);
557: 557: 557: 557: 557: 	}
558: 558: 558: 558: 558: 
559: 559: 559: 559: 559: 	
560: 560: 560: 560: 560: 	function exit() public{
561: 561: 561: 561: 561: 		address payable accountHolder = msg.sender;
562: 562: 562: 562: 562: 		uint256 balance = balances[accountHolder];
563: 563: 563: 563: 563: 		if (balance > 0) {
564: 564: 564: 564: 564: 			destroyTokens(accountHolder, balance);
565: 565: 565: 565: 565: 		}
566: 566: 566: 566: 566: 		if (dividendsOf(accountHolder, true) > 0) {
567: 567: 567: 567: 567: 			withdrawDividends(accountHolder);
568: 568: 568: 568: 568: 		}
569: 569: 569: 569: 569: 	}
570: 570: 570: 570: 570: 
571: 571: 571: 571: 571: 	
572: 572: 572: 572: 572: 	function setReferrer(address ref) public{
573: 573: 573: 573: 573: 		savedReferral[msg.sender] = ref;
574: 574: 574: 574: 574: 	}
575: 575: 575: 575: 575: 
576: 576: 576: 576: 576: 	
577: 577: 577: 577: 577: 	function setReferrer(string memory refName) public{
578: 578: 578: 578: 578: 		savedReferral[msg.sender] = getAddressFromReferralName(refName);
579: 579: 579: 579: 579: 	}
580: 580: 580: 580: 580: 
581: 581: 581: 581: 581: 	
582: 582: 582: 582: 582: 	function donateDividends() payable public{
583: 583: 583: 583: 583: 		distributeDividends(0, NULL_ADDRESS);
584: 584: 584: 584: 584: 		emit onDonatedDividends(msg.sender, msg.value);
585: 585: 585: 585: 585: 	}
586: 586: 586: 586: 586: 
587: 587: 587: 587: 587: 	
588: 588: 588: 588: 588: 
589: 589: 589: 589: 589: 	
590: 590: 590: 590: 590: 
591: 591: 591: 591: 591: 	
592: 592: 592: 592: 592: 	function baseHourglass() external view returns(address) {
593: 593: 593: 593: 593: 		return address(hourglass);
594: 594: 594: 594: 594: 	}
595: 595: 595: 595: 595: 
596: 596: 596: 596: 596: 	
597: 597: 597: 597: 597: 	function refHandlerAddress() external view returns(address) {
598: 598: 598: 598: 598: 		return address(refHandler);
599: 599: 599: 599: 599: 	}
600: 600: 600: 600: 600: 
601: 601: 601: 601: 601: 	
602: 602: 602: 602: 602: 	function getAddressFromReferralName(string memory refName) public view returns (address){
603: 603: 603: 603: 603: 		return playerBook.getPlayerAddr(playerBook.pIDxName_(stringToBytes32(refName)));
604: 604: 604: 604: 604: 	}
605: 605: 605: 605: 605: 
606: 606: 606: 606: 606: 	
607: 607: 607: 607: 607: 	function gauntletTypeOf(address accountHolder) public view returns(uint stakeAmount, uint gType, uint end) {
608: 608: 608: 608: 608: 		if (isGauntletExpired(accountHolder)) {
609: 609: 609: 609: 609: 			return (0, 0, gauntletEnd[accountHolder]);
610: 610: 610: 610: 610: 		} else {
611: 611: 611: 611: 611: 			return (gauntletBalance[accountHolder], gauntletType[accountHolder], gauntletEnd[accountHolder]);
612: 612: 612: 612: 612: 		}
613: 613: 613: 613: 613: 	}
614: 614: 614: 614: 614: 
615: 615: 615: 615: 615: 	
616: 616: 616: 616: 616: 	function myGauntletType() public view returns(uint stakeAmount, uint gType, uint end) {
617: 617: 617: 617: 617: 		return gauntletTypeOf(msg.sender);
618: 618: 618: 618: 618: 	}
619: 619: 619: 619: 619: 
620: 620: 620: 620: 620: 	
621: 621: 621: 621: 621: 	function usableBalanceOf(address accountHolder) public view returns(uint balance) {
622: 622: 622: 622: 622: 		if (isGauntletExpired(accountHolder)) {
623: 623: 623: 623: 623: 			return balances[accountHolder];
624: 624: 624: 624: 624: 		} else {
625: 625: 625: 625: 625: 			return balances[accountHolder].sub(gauntletBalance[accountHolder]);
626: 626: 626: 626: 626: 		}
627: 627: 627: 627: 627: 	}
628: 628: 628: 628: 628: 
629: 629: 629: 629: 629: 	
630: 630: 630: 630: 630: 	function myUsableBalance() public view returns(uint balance) {
631: 631: 631: 631: 631: 		return usableBalanceOf(msg.sender);
632: 632: 632: 632: 632: 	}
633: 633: 633: 633: 633: 
634: 634: 634: 634: 634: 	
635: 635: 635: 635: 635: 	function balanceOf(address accountHolder) external view returns(uint balance) {
636: 636: 636: 636: 636: 		return balances[accountHolder];
637: 637: 637: 637: 637: 	}
638: 638: 638: 638: 638: 
639: 639: 639: 639: 639: 	
640: 640: 640: 640: 640: 	function myBalance() public view returns(uint256) {
641: 641: 641: 641: 641: 		return balances[msg.sender];
642: 642: 642: 642: 642: 	}
643: 643: 643: 643: 643: 
644: 644: 644: 644: 644: 	
645: 645: 645: 645: 645: 	function allowance(address sugardaddy, address spender) external view returns(uint remaining) {
646: 646: 646: 646: 646: 		return allowances[sugardaddy][spender];
647: 647: 647: 647: 647: 	}
648: 648: 648: 648: 648: 
649: 649: 649: 649: 649: 	
650: 650: 650: 650: 650: 	function totalBalance() public view returns(uint256) {
651: 651: 651: 651: 651: 		return address(this).balance + hourglass.myDividends(true) + refHandler.totalBalance();
652: 652: 652: 652: 652: 	}
653: 653: 653: 653: 653: 
654: 654: 654: 654: 654: 	
655: 655: 655: 655: 655: 	function dividendsOf(address customerAddress, bool includeReferralBonus) public view returns(uint256) {
656: 656: 656: 656: 656: 		uint256 divs = uint256(int256(profitPerShare * balances[customerAddress]) - payouts[customerAddress]) / ROUNDING_MAGNITUDE;
657: 657: 657: 657: 657: 		if (includeReferralBonus) {
658: 658: 658: 658: 658: 			divs += bonuses[customerAddress];
659: 659: 659: 659: 659: 		}
660: 660: 660: 660: 660: 		return divs;
661: 661: 661: 661: 661: 	}
662: 662: 662: 662: 662: 
663: 663: 663: 663: 663: 	
664: 664: 664: 664: 664: 	function dividendsOf(address customerAddress) public view returns(uint256) {
665: 665: 665: 665: 665: 		return dividendsOf(customerAddress, true);
666: 666: 666: 666: 666: 	}
667: 667: 667: 667: 667: 
668: 668: 668: 668: 668: 	
669: 669: 669: 669: 669: 	function myDividends() public view returns(uint256) {
670: 670: 670: 670: 670: 		return dividendsOf(msg.sender, true);
671: 671: 671: 671: 671: 	}
672: 672: 672: 672: 672: 
673: 673: 673: 673: 673: 	
674: 674: 674: 674: 674: 	function myDividends(bool includeReferralBonus) public view returns(uint256) {
675: 675: 675: 675: 675: 		return dividendsOf(msg.sender, includeReferralBonus);
676: 676: 676: 676: 676: 	}
677: 677: 677: 677: 677: 
678: 678: 678: 678: 678: 	
679: 679: 679: 679: 679: 	function refBonusOf(address customerAddress) external view returns(uint256) {
680: 680: 680: 680: 680: 		return bonuses[customerAddress];
681: 681: 681: 681: 681: 	}
682: 682: 682: 682: 682: 
683: 683: 683: 683: 683: 	
684: 684: 684: 684: 684: 	function myRefBonus() external view returns(uint256) {
685: 685: 685: 685: 685: 		return bonuses[msg.sender];
686: 686: 686: 686: 686: 	}
687: 687: 687: 687: 687: 
688: 688: 688: 688: 688: 	
689: 689: 689: 689: 689: 	function stakingRequirement() external view returns(uint256) {
690: 690: 690: 690: 690: 		return referralRequirement;
691: 691: 691: 691: 691: 	}
692: 692: 692: 692: 692: 
693: 693: 693: 693: 693: 	
694: 694: 694: 694: 694: 	function calculateTokensReceived(uint256 ethereumToSpend) public view returns(uint256) {
695: 695: 695: 695: 695: 		return hourglass.calculateTokensReceived(ethereumToSpend);
696: 696: 696: 696: 696: 	}
697: 697: 697: 697: 697: 
698: 698: 698: 698: 698: 	
699: 699: 699: 699: 699: 	function calculateEthereumReceived(uint256 tokensToSell) public view returns(uint256) {
700: 700: 700: 700: 700: 		return hourglass.calculateEthereumReceived(tokensToSell);
701: 701: 701: 701: 701: 	}
702: 702: 702: 702: 702: 	
703: 703: 703: 703: 703: 
704: 704: 704: 704: 704: 	
705: 705: 705: 705: 705: 
706: 706: 706: 706: 706: 	
707: 707: 707: 707: 707: 	function isGauntletExpired(address holder) internal view returns(bool) {
708: 708: 708: 708: 708: 		if (gauntletType[holder] != 0) {
709: 709: 709: 709: 709: 			if (gauntletType[holder] == 1) {
710: 710: 710: 710: 710: 				return (block.timestamp >= gauntletEnd[holder]);
711: 711: 711: 711: 711: 			} else if (gauntletType[holder] == 2) {
712: 712: 712: 712: 712: 				return (hourglass.totalSupply() >= gauntletEnd[holder]);
713: 713: 713: 713: 713: 			} else if (gauntletType[holder] == 3) {
714: 714: 714: 714: 714: 				return ExternalGauntletInterface(gauntletEnd[holder]).gauntletRemovable(holder);
715: 715: 715: 715: 715: 			}
716: 716: 716: 716: 716: 		}
717: 717: 717: 717: 717: 		return false;
718: 718: 718: 718: 718: 	}
719: 719: 719: 719: 719: 
720: 720: 720: 720: 720: 	
721: 721: 721: 721: 721: 	function updateUsableBalanceOf(address holder) internal returns(uint256) {
722: 722: 722: 722: 722: 		
723: 723: 723: 723: 723: 		
724: 724: 724: 724: 724: 		if (isGauntletExpired(holder)) {
725: 725: 725: 725: 725: 			if (gauntletType[holder] == 3){
726: 726: 726: 726: 726: 				emit onExternalGauntletAcquired(holder, 0, NULL_ADDRESS);
727: 727: 727: 727: 727: 			}else{
728: 728: 728: 728: 728: 				emit onGauntletAcquired(holder, 0, 0, 0);
729: 729: 729: 729: 729: 			}
730: 730: 730: 730: 730: 			gauntletType[holder] = 0;
731: 731: 731: 731: 731: 			gauntletBalance[holder] = 0;
732: 732: 732: 732: 732: 
733: 733: 733: 733: 733: 			return balances[holder];
734: 734: 734: 734: 734: 		}
735: 735: 735: 735: 735: 		return balances[holder] - gauntletBalance[holder];
736: 736: 736: 736: 736: 	}
737: 737: 737: 737: 737: 
738: 738: 738: 738: 738: 	
739: 739: 739: 739: 739: 	function createTokens(address creator, uint256 eth, address referrer, bool reinvestment) internal returns(uint256) {
740: 740: 740: 740: 740: 		
741: 741: 741: 741: 741: 		uint256 parentReferralRequirement = hourglass.stakingRequirement();
742: 742: 742: 742: 742: 		
743: 743: 743: 743: 743: 		uint256 referralBonus = eth / HOURGLASS_FEE / HOURGLASS_BONUS;
744: 744: 744: 744: 744: 
745: 745: 745: 745: 745: 		bool usedHourglassMasternode = false;
746: 746: 746: 746: 746: 		bool invalidMasternode = false;
747: 747: 747: 747: 747: 		if (referrer == NULL_ADDRESS) {
748: 748: 748: 748: 748: 			referrer = savedReferral[creator];
749: 749: 749: 749: 749: 		}
750: 750: 750: 750: 750: 
751: 751: 751: 751: 751: 		
752: 752: 752: 752: 752: 		
753: 753: 753: 753: 753: 		uint256 tmp = hourglass.balanceOf(address(refHandler));
754: 754: 754: 754: 754: 
755: 755: 755: 755: 755: 		
756: 756: 756: 756: 756: 		if (creator == referrer) {
757: 757: 757: 757: 757: 			
758: 758: 758: 758: 758: 			invalidMasternode = true;
759: 759: 759: 759: 759: 		} else if (referrer == NULL_ADDRESS) {
760: 760: 760: 760: 760: 			usedHourglassMasternode = true;
761: 761: 761: 761: 761: 		
762: 762: 762: 762: 762: 		} else if (balances[referrer] >= referralRequirement && (tmp >= parentReferralRequirement || hourglass.balanceOf(address(this)) >= parentReferralRequirement)) {
763: 763: 763: 763: 763: 			
764: 764: 764: 764: 764: 		} else if (hourglass.balanceOf(referrer) >= parentReferralRequirement) {
765: 765: 765: 765: 765: 			usedHourglassMasternode = true;
766: 766: 766: 766: 766: 		} else {
767: 767: 767: 767: 767: 			
768: 768: 768: 768: 768: 			invalidMasternode = true;
769: 769: 769: 769: 769: 		}
770: 770: 770: 770: 770: 
771: 771: 771: 771: 771: 		
772: 772: 772: 772: 772: 		
773: 773: 773: 773: 773: 
774: 774: 774: 774: 774: 
775: 775: 775: 775: 775: 
776: 776: 776: 776: 776: 		uint256 createdTokens = hourglass.totalSupply();
777: 777: 777: 777: 777: 
778: 778: 778: 778: 778: 		
779: 779: 779: 779: 779: 		
780: 780: 780: 780: 780: 		
781: 781: 781: 781: 781: 
782: 782: 782: 782: 782: 		
783: 783: 783: 783: 783: 		if (tmp < parentReferralRequirement) {
784: 784: 784: 784: 784: 			if (reinvestment) {
785: 785: 785: 785: 785: 				
786: 786: 786: 786: 786: 				
787: 787: 787: 787: 787: 				tmp = refHandler.totalBalance();
788: 788: 788: 788: 788: 				if (tmp < eth) {
789: 789: 789: 789: 789: 					
790: 790: 790: 790: 790: 					tmp = eth - tmp; 
791: 791: 791: 791: 791: 					if (address(this).balance < tmp) {
792: 792: 792: 792: 792: 						
793: 793: 793: 793: 793: 						hourglass.withdraw();
794: 794: 794: 794: 794: 					}
795: 795: 795: 795: 795: 					address(refHandler).transfer(tmp);
796: 796: 796: 796: 796: 				}
797: 797: 797: 797: 797: 				tmp = hourglass.balanceOf(address(refHandler));
798: 798: 798: 798: 798: 
799: 799: 799: 799: 799: 				
800: 800: 800: 800: 800: 				refHandler.buyTokensFromBalance(NULL_ADDRESS, eth);
801: 801: 801: 801: 801: 			} else {
802: 802: 802: 802: 802: 				
803: 803: 803: 803: 803: 				
804: 804: 804: 804: 804: 				refHandler.buyTokens.value(eth)(invalidMasternode ? NULL_ADDRESS : (usedHourglassMasternode ? referrer : address(this)));
805: 805: 805: 805: 805: 			}
806: 806: 806: 806: 806: 		} else {
807: 807: 807: 807: 807: 			if (reinvestment) {
808: 808: 808: 808: 808: 				
809: 809: 809: 809: 809: 				if (address(this).balance < eth && hourglass.myDividends(true) > 0) {
810: 810: 810: 810: 810: 					hourglass.withdraw();
811: 811: 811: 811: 811: 				}
812: 812: 812: 812: 812: 				
813: 813: 813: 813: 813: 				if (address(this).balance < eth) {
814: 814: 814: 814: 814: 					refHandler.sendETH(address(this), eth - address(this).balance);
815: 815: 815: 815: 815: 				}
816: 816: 816: 816: 816: 			}
817: 817: 817: 817: 817: 			hourglass.buy.value(eth)(invalidMasternode ? NULL_ADDRESS : (usedHourglassMasternode ? referrer : address(refHandler)));
818: 818: 818: 818: 818: 		}
819: 819: 819: 819: 819: 
820: 820: 820: 820: 820: 		
821: 821: 821: 821: 821: 		createdTokens = hourglass.totalSupply() - createdTokens;
822: 822: 822: 822: 822: 		totalSupply += createdTokens;
823: 823: 823: 823: 823: 
824: 824: 824: 824: 824: 		
825: 825: 825: 825: 825: 		uint256 bonusTokens = hourglass.myTokens() + tmp - totalSupply;
826: 826: 826: 826: 826: 
827: 827: 827: 827: 827: 		
828: 828: 828: 828: 828: 		tmp = 0;
829: 829: 829: 829: 829: 		if (invalidMasternode)			{ tmp |= 1; }
830: 830: 830: 830: 830: 		if (usedHourglassMasternode)	{ tmp |= 2; }
831: 831: 831: 831: 831: 		if (reinvestment)				{ tmp |= 4; }
832: 832: 832: 832: 832: 
833: 833: 833: 833: 833: 		emit onTokenPurchase(creator, eth, createdTokens, bonusTokens, referrer, uint8(tmp));
834: 834: 834: 834: 834: 		createdTokens += bonusTokens;
835: 835: 835: 835: 835: 		
836: 836: 836: 836: 836: 		balances[creator] += createdTokens;
837: 837: 837: 837: 837: 		totalSupply += bonusTokens;
838: 838: 838: 838: 838: 
839: 839: 839: 839: 839: 		
840: 840: 840: 840: 840: 		emit Transfer(address(this), creator, createdTokens, "");
841: 841: 841: 841: 841: 		emit Transfer(address(this), creator, createdTokens);
842: 842: 842: 842: 842: 
843: 843: 843: 843: 843: 		
844: 844: 844: 844: 844: 		payouts[creator] += int256(profitPerShare * createdTokens); 
845: 845: 845: 845: 845: 
846: 846: 846: 846: 846: 		if (reinvestment) {
847: 847: 847: 847: 847: 			
848: 848: 848: 848: 848: 			
849: 849: 849: 849: 849: 			lastTotalBalance = lastTotalBalance.sub(eth);
850: 850: 850: 850: 850: 		}
851: 851: 851: 851: 851: 		distributeDividends((usedHourglassMasternode || invalidMasternode) ? 0 : referralBonus, referrer);
852: 852: 852: 852: 852: 		if (referrer != NULL_ADDRESS) {
853: 853: 853: 853: 853: 			
854: 854: 854: 854: 854: 			savedReferral[creator] = referrer;
855: 855: 855: 855: 855: 		}
856: 856: 856: 856: 856: 		return createdTokens;
857: 857: 857: 857: 857: 	}
858: 858: 858: 858: 858: 
859: 859: 859: 859: 859: 	
860: 860: 860: 860: 860: 	function destroyTokens(address weakHand, uint256 bags) internal returns(uint256) {
861: 861: 861: 861: 861: 		require(updateUsableBalanceOf(weakHand) >= bags, "Insufficient balance");
862: 862: 862: 862: 862: 
863: 863: 863: 863: 863: 		
864: 864: 864: 864: 864: 		
865: 865: 865: 865: 865: 		distributeDividends(0, NULL_ADDRESS);
866: 866: 866: 866: 866: 		uint256 tokenBalance = hourglass.myTokens();
867: 867: 867: 867: 867: 
868: 868: 868: 868: 868: 		
869: 869: 869: 869: 869: 		uint256 ethReceived = hourglass.calculateEthereumReceived(bags);
870: 870: 870: 870: 870: 		lastTotalBalance += ethReceived;
871: 871: 871: 871: 871: 		if (tokenBalance >= bags) {
872: 872: 872: 872: 872: 			hourglass.sell(bags);
873: 873: 873: 873: 873: 		} else {
874: 874: 874: 874: 874: 			
875: 875: 875: 875: 875: 			if (tokenBalance > 0) {
876: 876: 876: 876: 876: 				hourglass.sell(tokenBalance);
877: 877: 877: 877: 877: 			}
878: 878: 878: 878: 878: 			refHandler.sellTokens(bags - tokenBalance);
879: 879: 879: 879: 879: 		}
880: 880: 880: 880: 880: 
881: 881: 881: 881: 881: 		
882: 882: 882: 882: 882: 		int256 updatedPayouts = int256(profitPerShare * bags + (ethReceived * ROUNDING_MAGNITUDE));
883: 883: 883: 883: 883: 		payouts[weakHand] = payouts[weakHand].sub(updatedPayouts);
884: 884: 884: 884: 884: 
885: 885: 885: 885: 885: 		
886: 886: 886: 886: 886: 		balances[weakHand] -= bags;
887: 887: 887: 887: 887: 		totalSupply -= bags;
888: 888: 888: 888: 888: 
889: 889: 889: 889: 889: 		emit onTokenSell(weakHand, bags, ethReceived);
890: 890: 890: 890: 890: 
891: 891: 891: 891: 891: 		
892: 892: 892: 892: 892: 		emit Transfer(weakHand, address(this), bags, "");
893: 893: 893: 893: 893: 		emit Transfer(weakHand, address(this), bags);
894: 894: 894: 894: 894: 		return ethReceived;
895: 895: 895: 895: 895: 	}
896: 896: 896: 896: 896: 
897: 897: 897: 897: 897: 	
898: 898: 898: 898: 898: 	function sendETH(address payable to, uint256 amount) internal {
899: 899: 899: 899: 899: 		uint256 childTotalBalance = refHandler.totalBalance();
900: 900: 900: 900: 900: 		uint256 thisBalance = address(this).balance;
901: 901: 901: 901: 901: 		uint256 thisTotalBalance = thisBalance + hourglass.myDividends(true);
902: 902: 902: 902: 902: 		if (childTotalBalance >= amount) {
903: 903: 903: 903: 903: 			
904: 904: 904: 904: 904: 			refHandler.sendETH(to, amount);
905: 905: 905: 905: 905: 		} else if (thisTotalBalance >= amount) {
906: 906: 906: 906: 906: 			
907: 907: 907: 907: 907: 			if (thisBalance < amount) {
908: 908: 908: 908: 908: 				hourglass.withdraw();
909: 909: 909: 909: 909: 			}
910: 910: 910: 910: 910: 			to.transfer(amount);
911: 911: 911: 911: 911: 		} else {
912: 912: 912: 912: 912: 			
913: 913: 913: 913: 913: 			refHandler.sendETH(to, childTotalBalance);
914: 914: 914: 914: 914: 			if (hourglass.myDividends(true) > 0) {
915: 915: 915: 915: 915: 				hourglass.withdraw();
916: 916: 916: 916: 916: 			}
917: 917: 917: 917: 917: 			to.transfer(amount - childTotalBalance);
918: 918: 918: 918: 918: 		}
919: 919: 919: 919: 919: 		
920: 920: 920: 920: 920: 		lastTotalBalance = lastTotalBalance.sub(amount);
921: 921: 921: 921: 921: 	}
922: 922: 922: 922: 922: 
923: 923: 923: 923: 923: 	
924: 924: 924: 924: 924: 	function distributeDividends(uint256 bonus, address bonuser) internal{
925: 925: 925: 925: 925: 		
926: 926: 926: 926: 926: 		if (totalSupply > 0) {
927: 927: 927: 927: 927: 			uint256 tb = totalBalance();
928: 928: 928: 928: 928: 			uint256 delta = tb - lastTotalBalance;
929: 929: 929: 929: 929: 			if (delta > 0) {
930: 930: 930: 930: 930: 				
931: 931: 931: 931: 931: 				if (bonus != 0) {
932: 932: 932: 932: 932: 					bonuses[bonuser] += bonus;
933: 933: 933: 933: 933: 				}
934: 934: 934: 934: 934: 				profitPerShare = profitPerShare.add(((delta - bonus) * ROUNDING_MAGNITUDE) / totalSupply);
935: 935: 935: 935: 935: 				lastTotalBalance += delta;
936: 936: 936: 936: 936: 			}
937: 937: 937: 937: 937: 		}
938: 938: 938: 938: 938: 	}
939: 939: 939: 939: 939: 
940: 940: 940: 940: 940: 	
941: 941: 941: 941: 941: 	function clearDividends(address accountHolder) internal returns(uint256, uint256) {
942: 942: 942: 942: 942: 		uint256 payout = dividendsOf(accountHolder, false);
943: 943: 943: 943: 943: 		uint256 bonusPayout = bonuses[accountHolder];
944: 944: 944: 944: 944: 
945: 945: 945: 945: 945: 		payouts[accountHolder] += int256(payout * ROUNDING_MAGNITUDE);
946: 946: 946: 946: 946: 		bonuses[accountHolder] = 0;
947: 947: 947: 947: 947: 
948: 948: 948: 948: 948: 		
949: 949: 949: 949: 949: 		return (payout, bonusPayout);
950: 950: 950: 950: 950: 	}
951: 951: 951: 951: 951: 
952: 952: 952: 952: 952: 	
953: 953: 953: 953: 953: 	function withdrawDividends(address payable accountHolder) internal {
954: 954: 954: 954: 954: 		distributeDividends(0, NULL_ADDRESS); 
955: 955: 955: 955: 955: 		uint256 payout;
956: 956: 956: 956: 956: 		uint256 bonusPayout;
957: 957: 957: 957: 957: 		(payout, bonusPayout) = clearDividends(accountHolder);
958: 958: 958: 958: 958: 		emit onWithdraw(accountHolder, payout, bonusPayout, false);
959: 959: 959: 959: 959: 		sendETH(accountHolder, payout + bonusPayout);
960: 960: 960: 960: 960: 	}
961: 961: 961: 961: 961: 
962: 962: 962: 962: 962: 	
963: 963: 963: 963: 963: 	function actualTransfer (address payable from, address payable to, uint value, bytes memory data, string memory func, bool careAboutHumanity) internal{
964: 964: 964: 964: 964: 		require(updateUsableBalanceOf(from) >= value, "Insufficient balance");
965: 965: 965: 965: 965: 		require(to != address(refHandler), "My slave doesn't get paid"); 
966: 966: 966: 966: 966: 		require(to != address(hourglass), "P3D has no need for these"); 
967: 967: 967: 967: 967: 
968: 968: 968: 968: 968: 		if (to == address(this)) {
969: 969: 969: 969: 969: 			
970: 970: 970: 970: 970: 			if (value == 0) {
971: 971: 971: 971: 971: 				
972: 972: 972: 972: 972: 				emit Transfer(from, to, value, data);
973: 973: 973: 973: 973: 				emit Transfer(from, to, value);
974: 974: 974: 974: 974: 			} else {
975: 975: 975: 975: 975: 				destroyTokens(from, value);
976: 976: 976: 976: 976: 			}
977: 977: 977: 977: 977: 			withdrawDividends(from);
978: 978: 978: 978: 978: 		} else {
979: 979: 979: 979: 979: 			distributeDividends(0, NULL_ADDRESS); 
980: 980: 980: 980: 980: 			
981: 981: 981: 981: 981: 
982: 982: 982: 982: 982: 			
983: 983: 983: 983: 983: 			balances[from] = balances[from].sub(value);
984: 984: 984: 984: 984: 			balances[to] = balances[to].add(value);
985: 985: 985: 985: 985: 
986: 986: 986: 986: 986: 			
987: 987: 987: 987: 987: 			payouts[from] -= int256(profitPerShare * value);
988: 988: 988: 988: 988: 			
989: 989: 989: 989: 989: 			payouts[to] += int256(profitPerShare * value);
990: 990: 990: 990: 990: 
991: 991: 991: 991: 991: 			if (careAboutHumanity && isContract(to)) {
992: 992: 992: 992: 992: 				if (bytes(func).length == 0) {
993: 993: 993: 993: 993: 					ERC223Handler receiver = ERC223Handler(to);
994: 994: 994: 994: 994: 					receiver.tokenFallback(from, value, data);
995: 995: 995: 995: 995: 				} else {
996: 996: 996: 996: 996: 					bool success;
997: 997: 997: 997: 997: 					bytes memory returnData;
998: 998: 998: 998: 998: 					(success, returnData) = to.call.value(0)(abi.encodeWithSignature(func, from, value, data));
999: 999: 999: 999: 999: 					assert(success);
1000: 1000: 1000: 1000: 1000: 				}
1001: 1001: 1001: 1001: 1001: 			}
1002: 1002: 1002: 1002: 1002: 			emit Transfer(from, to, value, data);
1003: 1003: 1003: 1003: 1003: 			emit Transfer(from, to, value);
1004: 1004: 1004: 1004: 1004: 		}
1005: 1005: 1005: 1005: 1005: 	}
1006: 1006: 1006: 1006: 1006: 
1007: 1007: 1007: 1007: 1007: 	
1008: 1008: 1008: 1008: 1008: 	function bytesToBytes32(bytes memory data) internal pure returns(bytes32){
1009: 1009: 1009: 1009: 1009: 		uint256 result = 0;
1010: 1010: 1010: 1010: 1010: 		uint256 len = data.length;
1011: 1011: 1011: 1011: 1011: 		uint256 singleByte;
1012: 1012: 1012: 1012: 1012: 		for (uint256 i = 0; i<len; i+=1){
1013: 1013: 1013: 1013: 1013: 			singleByte = uint256(uint8(data[i])) << ( (31 - i) * 8);
1014: 1014: 1014: 1014: 1014: 			require(singleByte != 0, "bytes cannot contain a null byte");
1015: 1015: 1015: 1015: 1015: 			result |= singleByte;
1016: 1016: 1016: 1016: 1016: 		}
1017: 1017: 1017: 1017: 1017: 		return bytes32(result);
1018: 1018: 1018: 1018: 1018: 	}
1019: 1019: 1019: 1019: 1019: 
1020: 1020: 1020: 1020: 1020: 	
1021: 1021: 1021: 1021: 1021: 	function stringToBytes32(string memory data) internal pure returns(bytes32){
1022: 1022: 1022: 1022: 1022: 		return bytesToBytes32(bytes(data));
1023: 1023: 1023: 1023: 1023: 	}
1024: 1024: 1024: 1024: 1024: 
1025: 1025: 1025: 1025: 1025: 	
1026: 1026: 1026: 1026: 1026: 	function isContract(address _addr) internal view returns(bool) {
1027: 1027: 1027: 1027: 1027: 		uint length;
1028: 1028: 1028: 1028: 1028: 		assembly {
1029: 1029: 1029: 1029: 1029: 			
1030: 1030: 1030: 1030: 1030: 			length := extcodesize(_addr)
1031: 1031: 1031: 1031: 1031: 		}
1032: 1032: 1032: 1032: 1032: 		return (length>0);
1033: 1033: 1033: 1033: 1033: 	}
1034: 1034: 1034: 1034: 1034: 
1035: 1035: 1035: 1035: 1035: 	
1036: 1036: 1036: 1036: 1036: 	function tokenFallback(address from, uint value, bytes memory data) public pure{
1037: 1037: 1037: 1037: 1037: 		revert("I don't want your shitcoins!");
1038: 1038: 1038: 1038: 1038: 	}
1039: 1039: 1039: 1039: 1039: 
1040: 1040: 1040: 1040: 1040: 	
1041: 1041: 1041: 1041: 1041: 	function takeShitcoin(address shitCoin) public{
1042: 1042: 1042: 1042: 1042: 		
1043: 1043: 1043: 1043: 1043: 		require(shitCoin != address(hourglass), "P3D isn't a shitcoin");
1044: 1044: 1044: 1044: 1044: 		ERC20interface s = ERC20interface(shitCoin);
1045: 1045: 1045: 1045: 1045: 		s.transfer(msg.sender, s.balanceOf(address(this)));
1046: 1046: 1046: 1046: 1046: 	}
1047: 1047: 1047: 1047: 1047: }
1048: 1048: 1048: 1048: 1048: 
1049: 1049: 1049: 1049: 1049: 
1050: 1050: 1050: 1050: 1050: 
1051: 1051: 1051: 1051: 1051: 
1052: 1052: 1052: 1052: 1052: 
1053: 1053: 1053: 1053: 1053: 
1054: 1054: 1054: 1054: 1054: library SafeMath {
1055: 1055: 1055: 1055: 1055: 
1056: 1056: 1056: 1056: 1056: 	
1057: 1057: 1057: 1057: 1057: 
1058: 1058: 1058: 1058: 1058: 
1059: 1059: 1059: 1059: 1059: 	function mul(uint256 a, uint256 b) internal pure returns(uint256 c) {
1060: 1060: 1060: 1060: 1060: 		if (a == 0 || b == 0) {
1061: 1061: 1061: 1061: 1061: 		   return 0;
1062: 1062: 1062: 1062: 1062: 		}
1063: 1063: 1063: 1063: 1063: 		c = a * b;
1064: 1064: 1064: 1064: 1064: 		assert(c / a == b);
1065: 1065: 1065: 1065: 1065: 		return c;
1066: 1066: 1066: 1066: 1066: 	}
1067: 1067: 1067: 1067: 1067: 
1068: 1068: 1068: 1068: 1068: 	
1069: 1069: 1069: 1069: 1069: 
1070: 1070: 1070: 1070: 1070: 
1071: 1071: 1071: 1071: 1071: 	function div(uint256 a, uint256 b) internal pure returns(uint256) {
1072: 1072: 1072: 1072: 1072: 		
1073: 1073: 1073: 1073: 1073: 		
1074: 1074: 1074: 1074: 1074: 		
1075: 1075: 1075: 1075: 1075: 		return a / b;
1076: 1076: 1076: 1076: 1076: 	}
1077: 1077: 1077: 1077: 1077: 
1078: 1078: 1078: 1078: 1078: 	
1079: 1079: 1079: 1079: 1079: 
1080: 1080: 1080: 1080: 1080: 
1081: 1081: 1081: 1081: 1081: 	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
1082: 1082: 1082: 1082: 1082: 		assert(b <= a);
1083: 1083: 1083: 1083: 1083: 		return a - b;
1084: 1084: 1084: 1084: 1084: 	}
1085: 1085: 1085: 1085: 1085: 
1086: 1086: 1086: 1086: 1086: 	
1087: 1087: 1087: 1087: 1087: 
1088: 1088: 1088: 1088: 1088: 
1089: 1089: 1089: 1089: 1089: 	function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
1090: 1090: 1090: 1090: 1090: 		c = a + b;
1091: 1091: 1091: 1091: 1091: 		assert(c >= a);
1092: 1092: 1092: 1092: 1092: 		return c;
1093: 1093: 1093: 1093: 1093: 	}
1094: 1094: 1094: 1094: 1094: 
1095: 1095: 1095: 1095: 1095: 	
1096: 1096: 1096: 1096: 1096: 
1097: 1097: 1097: 1097: 1097: 
1098: 1098: 1098: 1098: 1098: 	function sub(int256 a, int256 b) internal pure returns(int256 c) {
1099: 1099: 1099: 1099: 1099: 		c = a - b;
1100: 1100: 1100: 1100: 1100: 		assert(c <= a);
1101: 1101: 1101: 1101: 1101: 		return c;
1102: 1102: 1102: 1102: 1102: 	}
1103: 1103: 1103: 1103: 1103: 
1104: 1104: 1104: 1104: 1104: 	
1105: 1105: 1105: 1105: 1105: 
1106: 1106: 1106: 1106: 1106: 
1107: 1107: 1107: 1107: 1107: 	function add(int256 a, int256 b) internal pure returns(int256 c) {
1108: 1108: 1108: 1108: 1108: 		c = a + b;
1109: 1109: 1109: 1109: 1109: 		assert(c >= a);
1110: 1110: 1110: 1110: 1110: 		return c;
1111: 1111: 1111: 1111: 1111: 	}
1112: 1112: 1112: 1112: 1112: }