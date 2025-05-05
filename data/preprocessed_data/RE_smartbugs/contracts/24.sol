1: 1: pragma solidity ^0.4.21;
2: 2: 
3: 3: 
4: 4: library SafeMath {
5: 5: 	function add(uint256 a, uint256 b) internal pure returns (uint256) {
6: 6: 		uint256 c = a + b;
7: 7: 		assert(a <= c);
8: 8: 		return c;
9: 9: 	}
10: 10: 
11: 11: 	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
12: 12: 		assert(a >= b);
13: 13: 		return a - b;
14: 14: 	}
15: 15: 
16: 16: 	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
17: 17: 		uint256 c = a * b;
18: 18: 		assert(a == 0 || c / a == b);
19: 19: 		return c;
20: 20: 	}
21: 21: 
22: 22: 	function div(uint256 a, uint256 b) internal pure returns (uint256) {
23: 23: 		return a / b;
24: 24: 	}
25: 25: }
26: 26: 
27: 27: 
28: 28: contract AuctusTokenSale is ContractReceiver {
29: 29: 	using SafeMath for uint256;
30: 30: 
31: 31: 	address public auctusTokenAddress = 0xc12d099be31567add4e4e4d0D45691C3F58f5663;
32: 32: 	address public auctusWhiteListAddress = 0xA6e728E524c1D7A65fE5193cA1636265DE9Bc982;
33: 33: 
34: 34: 	uint256 public startTime = 1522159200; 
35: 35: 	uint256 public endTime; 
36: 36: 
37: 37: 	uint256 public basicPricePerEth = 2000;
38: 38: 
39: 39: 	address public owner;
40: 40: 	uint256 public softCap;
41: 41: 	uint256 public remainingTokens;
42: 42: 	uint256 public weiRaised;
43: 43: 	mapping(address => uint256) public invested;
44: 44: 
45: 45: 	bool public saleWasSet;
46: 46: 	bool public tokenSaleHalted;
47: 47: 
48: 48: 	event Buy(address indexed buyer, uint256 tokenAmount);
49: 49: 	event Revoke(address indexed buyer, uint256 investedAmount);
50: 50: 
51: 51: 	function AuctusTokenSale(uint256 minimumCap, uint256 endSaleTime) public {
52: 52: 		owner = msg.sender;
53: 53: 		softCap = minimumCap;
54: 54: 		endTime = endSaleTime;
55: 55: 		saleWasSet = false;
56: 56: 		tokenSaleHalted = false;
57: 57: 	}
58: 58: 
59: 59: 	modifier onlyOwner() {
60: 60: 		require(owner == msg.sender);
61: 61: 		_;
62: 62: 	}
63: 63: 
64: 64: 	modifier openSale() {
65: 65: 		require(saleWasSet && !tokenSaleHalted && now >= startTime && now <= endTime && remainingTokens > 0);
66: 66: 		_;
67: 67: 	}
68: 68: 
69: 69: 	modifier saleCompletedSuccessfully() {
70: 70: 		require(weiRaised >= softCap && (now > endTime || remainingTokens == 0));
71: 71: 		_;
72: 72: 	}
73: 73: 
74: 74: 	modifier saleFailed() {
75: 75: 		require(weiRaised < softCap && now > endTime);
76: 76: 		_;
77: 77: 	}
78: 78: 
79: 79: 	function transferOwnership(address newOwner) onlyOwner public {
80: 80: 		require(newOwner != address(0));
81: 81: 		owner = newOwner;
82: 82: 	}
83: 83: 
84: 84: 	function setTokenSaleHalt(bool halted) onlyOwner public {
85: 85: 		tokenSaleHalted = halted;
86: 86: 	}
87: 87: 
88: 88: 	function setSoftCap(uint256 minimumCap) onlyOwner public {
89: 89: 		require(now < startTime);
90: 90: 		softCap = minimumCap;
91: 91: 	}
92: 92: 
93: 93: 	function setEndSaleTime(uint256 endSaleTime) onlyOwner public {
94: 94: 		require(now < endTime);
95: 95: 		endTime = endSaleTime;
96: 96: 	}
97: 97: 
98: 98: 	function tokenFallback(address, uint256 value, bytes) public {
99: 99: 		require(msg.sender == auctusTokenAddress);
100: 100: 		require(!saleWasSet);
101: 101: 		setTokenSaleDistribution(value);
102: 102: 	}
103: 103: 
104: 104: 	function()
105: 105: 		payable
106: 106: 		openSale
107: 107: 		public
108: 108: 	{
109: 109: 		uint256 weiToInvest;
110: 110: 		uint256 weiRemaining;
111: 111: 		(weiToInvest, weiRemaining) = getValueToInvest();
112: 112: 
113: 113: 		require(weiToInvest > 0);
114: 114: 
115: 115: 		uint256 tokensToReceive = weiToInvest.mul(basicPricePerEth);
116: 116: 		remainingTokens = remainingTokens.sub(tokensToReceive);
117: 117: 		weiRaised = weiRaised.add(weiToInvest);
118: 118: 		invested[msg.sender] = invested[msg.sender].add(weiToInvest);
119: 119: 
120: 120: 		if (weiRemaining > 0) {
121: 121: 			msg.sender.transfer(weiRemaining);
122: 122: 		}
123: 123: 		assert(AuctusToken(auctusTokenAddress).transfer(msg.sender, tokensToReceive));
124: 124: 
125: 125: 		emit Buy(msg.sender, tokensToReceive);
126: 126: 	}
127: 127: 
128: 128: 	function revoke() saleFailed public {
129: 129: 		uint256 investedValue = invested[msg.sender];
130: 130: 		require(investedValue > 0);
131: 131: 
132: 132: 		invested[msg.sender] = 0;
133: 133: 		msg.sender.transfer(investedValue);
134: 134: 
135: 135: 		emit Revoke(msg.sender, investedValue);
136: 136: 	}
137: 137: 
138: 138: 	function finish() 
139: 139: 		onlyOwner
140: 140: 		saleCompletedSuccessfully 
141: 141: 		public 
142: 142: 	{
143: 143: 		
144: 144: 		uint256 freeEthers = address(this).balance * 40 / 100;
145: 145: 		uint256 vestedEthers = address(this).balance - freeEthers;
146: 146: 
147: 147: 		address(0xd1B10607921C78D9a00529294C4b99f1bd250E1c).transfer(freeEthers); 
148: 148: 		assert(address(0xb3cc085B5a56Fdd47545A66EBd3DBd2a903D4565).call.value(vestedEthers)()); 
149: 149: 
150: 150: 		AuctusToken token = AuctusToken(auctusTokenAddress);
151: 151: 		token.setTokenSaleFinished();
152: 152: 		if (remainingTokens > 0) {
153: 153: 			token.burn(remainingTokens);
154: 154: 			remainingTokens = 0;
155: 155: 		}
156: 156: 	}
157: 157: 
158: 158: 	function getValueToInvest() view private returns (uint256, uint256) {
159: 159: 		uint256 allowedValue = AuctusWhitelist(auctusWhiteListAddress).getAllowedAmountToContribute(msg.sender);
160: 160: 
161: 161: 		uint256 weiToInvest;
162: 162: 		if (allowedValue == 0) {
163: 163: 			weiToInvest = 0;
164: 164: 		} else if (allowedValue >= invested[msg.sender].add(msg.value)) {
165: 165: 			weiToInvest = getAllowedAmount(msg.value);
166: 166: 		} else {
167: 167: 			weiToInvest = getAllowedAmount(allowedValue.sub(invested[msg.sender]));
168: 168: 		}
169: 169: 		return (weiToInvest, msg.value.sub(weiToInvest));
170: 170: 	}
171: 171: 
172: 172: 	function getAllowedAmount(uint256 value) view private returns (uint256) {
173: 173: 		uint256 maximumValue = remainingTokens / basicPricePerEth;
174: 174: 		if (value > maximumValue) {
175: 175: 			return maximumValue;
176: 176: 		} else {
177: 177: 			return value;
178: 178: 		}
179: 179: 	}
180: 180: 
181: 181: 	function setTokenSaleDistribution(uint256 totalAmount) private {
182: 182: 		
183: 183: 		uint256 auctusCoreTeam = totalAmount * 20 / 100;
184: 184: 		
185: 185: 		uint256 bounty = totalAmount * 2 / 100;
186: 186: 		
187: 187: 		uint256 reserveForFuture = totalAmount * 18 / 100;
188: 188: 		
189: 189: 		uint256 partnershipsAdvisoryFree = totalAmount * 18 / 1000;
190: 190: 		
191: 191: 		uint256 partnershipsAdvisoryVested = totalAmount * 72 / 1000;
192: 192: 
193: 193: 		uint256 privateSales = 6836048000000000000000000;
194: 194: 		uint256 preSale = 2397307557007329968290000;
195: 195: 
196: 196: 		transferTokens(auctusCoreTeam, bounty, reserveForFuture, preSale, partnershipsAdvisoryVested, partnershipsAdvisoryFree, privateSales);
197: 197: 		
198: 198: 		remainingTokens = totalAmount - auctusCoreTeam - bounty - reserveForFuture - preSale - partnershipsAdvisoryVested - partnershipsAdvisoryFree - privateSales;
199: 199: 		saleWasSet = true;
200: 200: 	}
201: 201: 	
202: 202: 	function transferTokens(
203: 203: 		uint256 auctusCoreTeam,
204: 204: 		uint256 bounty,
205: 205: 		uint256 reserveForFuture,
206: 206: 		uint256 preSale,
207: 207: 		uint256 partnershipsAdvisoryVested,
208: 208: 		uint256 partnershipsAdvisoryFree,
209: 209: 		uint256 privateSales
210: 210: 	) private {
211: 211: 		AuctusToken token = AuctusToken(auctusTokenAddress);
212: 212: 		bytes memory empty;
213: 213: 		assert(token.transfer(0x8592Ec038ACBA05BC467C6bC17aA855880d490E4, auctusCoreTeam, empty)); 
214: 214: 		assert(token.transfer(0x389E93aC36Dd8c8E04FB1952B37c4aa4b320b6FF, bounty, empty)); 
215: 215: 		assert(token.transfer(0xc83847FCbd217FB8Ec4bc79DbA7DB672d3aB2602, reserveForFuture, empty)); 
216: 216: 		assert(token.transfer(0xA39cA2768A7B76Aa3bCab68c4d4DEBF9A32c5434, preSale, empty)); 
217: 217: 		assert(token.transfer(0x8Cb9626BBc5Ec60c386eeEde50ac74f173FBD8a8, partnershipsAdvisoryVested, empty)); 
218: 218: 		assert(token.transfer(0x6c89Cc03036193d52e9b8386413b545184BDAb99, partnershipsAdvisoryFree));
219: 219: 		assert(token.transfer(0xd1B10607921C78D9a00529294C4b99f1bd250E1c, privateSales));
220: 220: 	}
221: 221: }