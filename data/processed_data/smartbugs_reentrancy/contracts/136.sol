1: 1: pragma solidity 0.4.25;
2: 2: pragma experimental ABIEncoderV2;
3: 3: pragma experimental "v0.5.0";
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: library SafeMath {
11: 11: 
12: 12: 	
13: 13: 
14: 14: 
15: 15: 	function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
16: 16: 		
17: 17: 		
18: 18: 		
19: 19: 		if (a == 0) {
20: 20: 			return 0;
21: 21: 		}
22: 22: 		c = a * b;
23: 23: 		assert(c / a == b);
24: 24: 		return c;
25: 25: 	}
26: 26: 
27: 27: 	
28: 28: 
29: 29: 
30: 30: 	function div(uint256 a, uint256 b) internal pure returns (uint256) {
31: 31: 		
32: 32: 		
33: 33: 		
34: 34: 		return a / b;
35: 35: 	}
36: 36: 
37: 37: 	
38: 38: 
39: 39: 
40: 40: 	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
41: 41: 		assert(b <= a);
42: 42: 		return a - b;
43: 43: 	}
44: 44: 
45: 45: 	
46: 46: 
47: 47: 
48: 48: 	function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
49: 49: 		c = a + b;
50: 50: 		assert(c >= a);
51: 51: 		return c;
52: 52: 	}
53: 53: 
54: 54: }
55: 55: 
56: 56: 
57: 57: 
58: 58: 
59: 59: 
60: 60: 
61: 61: library SafeMathFixedPoint {
62: 62: 	using SafeMath for uint256;
63: 63: 
64: 64: 	function mul27(uint256 x, uint256 y) internal pure returns (uint256 z) {
65: 65: 		z = x.mul(y).add(5 * 10**26).div(10**27);
66: 66: 	}
67: 67: 	function mul18(uint256 x, uint256 y) internal pure returns (uint256 z) {
68: 68: 		z = x.mul(y).add(5 * 10**17).div(10**18);
69: 69: 	}
70: 70: 
71: 71: 	function div18(uint256 x, uint256 y) internal pure returns (uint256 z) {
72: 72: 		z = x.mul(10**18).add(y.div(2)).div(y);
73: 73: 	}
74: 74: 	function div27(uint256 x, uint256 y) internal pure returns (uint256 z) {
75: 75: 		z = x.mul(10**27).add(y.div(2)).div(y);
76: 76: 	}
77: 77: }
78: 78: 
79: 79: 
80: 80: 
81: 81: 
82: 82: 
83: 83: 
84: 84: 
85: 85: contract LiquidLong is Ownable, Claimable, Pausable, PullPayment {
86: 86: 	using SafeMath for uint256;
87: 87: 	using SafeMathFixedPoint for uint256;
88: 88: 
89: 89: 	uint256 public providerFeePerEth;
90: 90: 
91: 91: 	Oasis public oasis;
92: 92: 	Maker public maker;
93: 93: 	Dai public dai;
94: 94: 	Weth public weth;
95: 95: 	Peth public peth;
96: 96: 	Mkr public mkr;
97: 97: 
98: 98: 	ProxyRegistry public proxyRegistry;
99: 99: 
100: 100: 	event NewCup(address user, bytes32 cup);
101: 101: 
102: 102: 	constructor(Oasis _oasis, Maker _maker, ProxyRegistry _proxyRegistry) public payable {
103: 103: 		providerFeePerEth = 0.01 ether;
104: 104: 
105: 105: 		oasis = _oasis;
106: 106: 		maker = _maker;
107: 107: 		dai = maker.sai();
108: 108: 		weth = maker.gem();
109: 109: 		peth = maker.skr();
110: 110: 		mkr = maker.gov();
111: 111: 
112: 112: 		
113: 113: 		dai.approve(address(_oasis), uint256(-1));
114: 114: 		
115: 115: 		dai.approve(address(_maker), uint256(-1));
116: 116: 		mkr.approve(address(_maker), uint256(-1));
117: 117: 		
118: 118: 		weth.approve(address(_maker), uint256(-1));
119: 119: 		
120: 120: 		peth.approve(address(_maker), uint256(-1));
121: 121: 
122: 122: 		proxyRegistry = _proxyRegistry;
123: 123: 
124: 124: 		if (msg.value > 0) {
125: 125: 			weth.deposit.value(msg.value)();
126: 126: 		}
127: 127: 	}
128: 128: 
129: 129: 	
130: 130: 	function () external payable {
131: 131: 	}
132: 132: 
133: 133: 	function wethDeposit() public payable {
134: 134: 		weth.deposit.value(msg.value)();
135: 135: 	}
136: 136: 
137: 137: 	function wethWithdraw(uint256 _amount) public onlyOwner {
138: 138: 		weth.withdraw(_amount);
139: 139: 		owner.transfer(_amount);
140: 140: 	}
141: 141: 
142: 142: 	function ethWithdraw() public onlyOwner {
143: 143: 		
144: 144: 		uint256 _amount = address(this).balance.sub(totalPayments);
145: 145: 		owner.transfer(_amount);
146: 146: 	}
147: 147: 
148: 148: 	
149: 149: 	function transferTokens(ERC20 _token) public onlyOwner {
150: 150: 		_token.transfer(owner, _token.balanceOf(this));
151: 151: 	}
152: 152: 
153: 153: 	function ethPriceInUsd() public view returns (uint256 _attousd) {
154: 154: 		return uint256(maker.pip().read());
155: 155: 	}
156: 156: 
157: 157: 	function estimateDaiSaleProceeds(uint256 _attodaiToSell) public view returns (uint256 _daiPaid, uint256 _wethBought) {
158: 158: 		return getPayPriceAndAmount(dai, weth, _attodaiToSell);
159: 159: 	}
160: 160: 
161: 161: 	
162: 162: 	function getPayPriceAndAmount(ERC20 _payGem, ERC20 _buyGem, uint256 _payDesiredAmount) public view returns (uint256 _paidAmount, uint256 _boughtAmount) {
163: 163: 		uint256 _offerId = oasis.getBestOffer(_buyGem, _payGem);
164: 164: 		while (_offerId != 0) {
165: 165: 			uint256 _payRemaining = _payDesiredAmount.sub(_paidAmount);
166: 166: 			(uint256 _buyAvailableInOffer, , uint256 _payAvailableInOffer,) = oasis.getOffer(_offerId);
167: 167: 			if (_payRemaining <= _payAvailableInOffer) {
168: 168: 				uint256 _buyRemaining = _payRemaining.mul(_buyAvailableInOffer).div(_payAvailableInOffer);
169: 169: 				_paidAmount = _paidAmount.add(_payRemaining);
170: 170: 				_boughtAmount = _boughtAmount.add(_buyRemaining);
171: 171: 				break;
172: 172: 			}
173: 173: 			_paidAmount = _paidAmount.add(_payAvailableInOffer);
174: 174: 			_boughtAmount = _boughtAmount.add(_buyAvailableInOffer);
175: 175: 			_offerId = oasis.getWorseOffer(_offerId);
176: 176: 		}
177: 177: 		return (_paidAmount, _boughtAmount);
178: 178: 	}
179: 179: 
180: 180: 	modifier wethBalanceUnchanged() {
181: 181: 		uint256 _startingAttowethBalance = weth.balanceOf(this);
182: 182: 		_;
183: 183: 		require(weth.balanceOf(this) >= _startingAttowethBalance);
184: 184: 	}
185: 185: 
186: 186: 	
187: 187: 	function openCdp(uint256 _leverage, uint256 _leverageSizeInAttoeth, uint256 _allowedFeeInAttoeth, address _affiliateAddress) public payable wethBalanceUnchanged returns (bytes32 _cdpId) {
188: 188: 		require(_leverage >= 100 && _leverage <= 300);
189: 189: 		uint256 _lockedInCdpInAttoeth = _leverageSizeInAttoeth.mul(_leverage).div(100);
190: 190: 		uint256 _loanInAttoeth = _lockedInCdpInAttoeth.sub(_leverageSizeInAttoeth);
191: 191: 		uint256 _feeInAttoeth = _loanInAttoeth.mul18(providerFeePerEth);
192: 192: 		require(_feeInAttoeth <= _allowedFeeInAttoeth);
193: 193: 		uint256 _drawInAttodai = _loanInAttoeth.mul18(uint256(maker.pip().read()));
194: 194: 		uint256 _attopethLockedInCdp = _lockedInCdpInAttoeth.div27(maker.per());
195: 195: 
196: 196: 		
197: 197: 		weth.deposit.value(_leverageSizeInAttoeth)();
198: 198: 		
199: 199: 		_cdpId = maker.open();
200: 200: 		
201: 201: 		maker.join(_attopethLockedInCdp);
202: 202: 		
203: 203: 		maker.lock(_cdpId, _attopethLockedInCdp);
204: 204: 		
205: 205: 		maker.draw(_cdpId, _drawInAttodai);
206: 206: 		
207: 207: 		sellDai(_drawInAttodai, _lockedInCdpInAttoeth, _feeInAttoeth, _loanInAttoeth);
208: 208: 		
209: 209: 		if (_feeInAttoeth != 0) {
210: 210: 			
211: 211: 			if (_affiliateAddress == 0x0) {
212: 212: 				asyncSend(owner, _feeInAttoeth);
213: 213: 			} else {
214: 214: 				asyncSend(owner, _feeInAttoeth.div(2));
215: 215: 				asyncSend(_affiliateAddress, _feeInAttoeth.div(2));
216: 216: 			}
217: 217: 		}
218: 218: 
219: 219: 		emit NewCup(msg.sender, _cdpId);
220: 220: 
221: 221: 		giveCdpToProxy(msg.sender, _cdpId);
222: 222: 	}
223: 223: 
224: 224: 	function giveCdpToProxy(address _ownerOfProxy, bytes32 _cdpId) private {
225: 225: 		DSProxy _proxy = proxyRegistry.proxies(_ownerOfProxy);
226: 226: 		if (_proxy == DSProxy(0) || _proxy.owner() != _ownerOfProxy) {
227: 227: 			_proxy = proxyRegistry.build(_ownerOfProxy);
228: 228: 		}
229: 229: 		
230: 230: 		maker.give(_cdpId, proxyRegistry);
231: 231: 	}
232: 232: 
233: 233: 	
234: 234: 	function sellDai(uint256 _drawInAttodai, uint256 _lockedInCdpInAttoeth, uint256 _feeInAttoeth, uint256 _loanInAttoeth) private {
235: 235: 		uint256 _wethBoughtInAttoweth = oasis.sellAllAmount(dai, _drawInAttodai, weth, 0);
236: 236: 		
237: 237: 		uint256 _refundDue = msg.value.add(_wethBoughtInAttoweth).sub(_lockedInCdpInAttoeth).sub(_feeInAttoeth);
238: 238: 		if (_refundDue > 0) {
239: 239: 			require(msg.sender.call.value(_refundDue)());
240: 240: 		}
241: 241: 
242: 242: 		if (_loanInAttoeth > _wethBoughtInAttoweth) {
243: 243: 			weth.deposit.value(_loanInAttoeth - _wethBoughtInAttoweth)();
244: 244: 		}
245: 245: 	}
246: 246: }