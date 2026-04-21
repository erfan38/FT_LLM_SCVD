1: 1: pragma solidity^0.4.11;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: library SafeMath {
7: 7:   function mul(uint a, uint b) internal returns (uint) {
8: 8:     uint c = a * b;
9: 9:     assert(a == 0 || c / a == b);
10: 10:     return c;
11: 11:   }
12: 12: 
13: 13:   function div(uint a, uint b) internal returns (uint) {
14: 14:     
15: 15:     uint c = a / b;
16: 16:     
17: 17:     return c;
18: 18:   }
19: 19: 
20: 20:   function sub(uint a, uint b) internal returns (uint) {
21: 21:     assert(b <= a);
22: 22:     return a - b;
23: 23:   }
24: 24: 
25: 25:   function add(uint a, uint b) internal returns (uint) {
26: 26:     uint c = a + b;
27: 27:     assert(c >= a);
28: 28:     return c;
29: 29:   }
30: 30: 
31: 31:   function max64(uint64 a, uint64 b) internal constant returns (uint64) {
32: 32:     return a >= b ? a : b;
33: 33:   }
34: 34: 
35: 35:   function min64(uint64 a, uint64 b) internal constant returns (uint64) {
36: 36:     return a < b ? a : b;
37: 37:   }
38: 38: 
39: 39:   function max256(uint256 a, uint256 b) internal constant returns (uint256) {
40: 40:     return a >= b ? a : b;
41: 41:   }
42: 42: 
43: 43:   function min256(uint256 a, uint256 b) internal constant returns (uint256) {
44: 44:     return a < b ? a : b;
45: 45:   }
46: 46: 
47: 47:   function assert(bool assertion) internal {
48: 48:     if (!assertion) {
49: 49:       throw;
50: 50:     }
51: 51:   }
52: 52: }
53: 53: 
54: 54: 
55: 55: 
56: 56: 
57: 57: 
58: 58: 
59: 59: contract CATToken is StandardToken {
60: 60: 	using SafeMath for uint256;
61: 61: 	
62: 62: 	
63: 63: 	string public constant HIDDEN_CAP = "0xd22f19d54193ff5e08e7ba88c8e52ec1b9fc8d4e0cf177e1be8a764fa5b375fa";
64: 64: 	
65: 65: 	
66: 66: 	event CreatedCAT(address indexed _creator, uint256 _amountOfCAT);
67: 67: 	event CATRefundedForWei(address indexed _refunder, uint256 _amountOfWei);
68: 68: 	
69: 69: 	
70: 70: 	string public constant name = "BlockCAT Token";
71: 71: 	string public constant symbol = "CAT";
72: 72: 	uint256 public constant decimals = 18;  
73: 73: 	string public version = "1.0";
74: 74: 	
75: 75: 	
76: 76: 	address public executor;
77: 77: 	address public devETHDestination;
78: 78: 	address public devCATDestination;
79: 79: 	address public reserveCATDestination;
80: 80: 	
81: 81: 	
82: 82: 	bool public saleHasEnded;
83: 83: 	bool public minCapReached;
84: 84: 	bool public allowRefund;
85: 85: 	mapping (address => uint256) public ETHContributed;
86: 86: 	uint256 public totalETHRaised;
87: 87: 	uint256 public saleStartBlock;
88: 88: 	uint256 public saleEndBlock;
89: 89: 	uint256 public saleFirstEarlyBirdEndBlock;
90: 90: 	uint256 public saleSecondEarlyBirdEndBlock;
91: 91: 	uint256 public constant DEV_PORTION = 20;  
92: 92: 	uint256 public constant RESERVE_PORTION = 1;  
93: 93: 	uint256 public constant ADDITIONAL_PORTION = DEV_PORTION + RESERVE_PORTION;
94: 94: 	uint256 public constant SECURITY_ETHER_CAP = 1000000 ether;
95: 95: 	uint256 public constant CAT_PER_ETH_BASE_RATE = 300;  
96: 96: 	uint256 public constant CAT_PER_ETH_FIRST_EARLY_BIRD_RATE = 330;
97: 97: 	uint256 public constant CAT_PER_ETH_SECOND_EARLY_BIRD_RATE = 315;
98: 98: 	
99: 99: 	function CATToken(
100: 100: 		address _devETHDestination,
101: 101: 		address _devCATDestination,
102: 102: 		address _reserveCATDestination,
103: 103: 		uint256 _saleStartBlock,
104: 104: 		uint256 _saleEndBlock
105: 105: 	) {
106: 106: 		
107: 107: 		if (_devETHDestination == address(0x0)) throw;
108: 108: 		if (_devCATDestination == address(0x0)) throw;
109: 109: 		if (_reserveCATDestination == address(0x0)) throw;
110: 110: 		
111: 111: 		if (_saleEndBlock <= block.number) throw;
112: 112: 		
113: 113: 		if (_saleEndBlock <= _saleStartBlock) throw;
114: 114: 
115: 115: 		executor = msg.sender;
116: 116: 		saleHasEnded = false;
117: 117: 		minCapReached = false;
118: 118: 		allowRefund = false;
119: 119: 		devETHDestination = _devETHDestination;
120: 120: 		devCATDestination = _devCATDestination;
121: 121: 		reserveCATDestination = _reserveCATDestination;
122: 122: 		totalETHRaised = 0;
123: 123: 		saleStartBlock = _saleStartBlock;
124: 124: 		saleEndBlock = _saleEndBlock;
125: 125: 		saleFirstEarlyBirdEndBlock = saleStartBlock + 6171;  
126: 126: 		saleSecondEarlyBirdEndBlock = saleFirstEarlyBirdEndBlock + 12342;  
127: 127: 
128: 128: 		totalSupply = 0;
129: 129: 	}
130: 130: 	
131: 131: 	function createTokens() payable external {
132: 132: 		
133: 133: 		if (saleHasEnded) throw;
134: 134: 		if (block.number < saleStartBlock) throw;
135: 135: 		if (block.number > saleEndBlock) throw;
136: 136: 		
137: 137: 		uint256 newEtherBalance = totalETHRaised.add(msg.value);
138: 138: 		if (newEtherBalance > SECURITY_ETHER_CAP) throw; 
139: 139: 		
140: 140: 		if (0 == msg.value) throw;
141: 141: 		
142: 142: 		
143: 143: 		uint256 curTokenRate = CAT_PER_ETH_BASE_RATE;
144: 144: 		if (block.number < saleFirstEarlyBirdEndBlock) {
145: 145: 			curTokenRate = CAT_PER_ETH_FIRST_EARLY_BIRD_RATE;
146: 146: 		}
147: 147: 		else if (block.number < saleSecondEarlyBirdEndBlock) {
148: 148: 			curTokenRate = CAT_PER_ETH_SECOND_EARLY_BIRD_RATE;
149: 149: 		}
150: 150: 		
151: 151: 		
152: 152: 		uint256 amountOfCAT = msg.value.mul(curTokenRate);
153: 153: 		
154: 154: 		
155: 155: 		uint256 totalSupplySafe = totalSupply.add(amountOfCAT);
156: 156: 		uint256 balanceSafe = balances[msg.sender].add(amountOfCAT);
157: 157: 		uint256 contributedSafe = ETHContributed[msg.sender].add(msg.value);
158: 158: 
159: 159: 		
160: 160: 		totalSupply = totalSupplySafe;
161: 161: 		balances[msg.sender] = balanceSafe;
162: 162: 
163: 163: 		totalETHRaised = newEtherBalance;
164: 164: 		ETHContributed[msg.sender] = contributedSafe;
165: 165: 
166: 166: 		CreatedCAT(msg.sender, amountOfCAT);
167: 167: 	}
168: 168: 	
169: 169: 	function endSale() {
170: 170: 		
171: 171: 		if (saleHasEnded) throw;
172: 172: 		
173: 173: 		if (!minCapReached) throw;
174: 174: 		
175: 175: 		if (msg.sender != executor) throw;
176: 176: 		
177: 177: 		saleHasEnded = true;
178: 178: 
179: 179: 		
180: 180: 		uint256 additionalCAT = (totalSupply.mul(ADDITIONAL_PORTION)).div(100 - ADDITIONAL_PORTION);
181: 181: 		uint256 totalSupplySafe = totalSupply.add(additionalCAT);
182: 182: 
183: 183: 		uint256 reserveShare = (additionalCAT.mul(RESERVE_PORTION)).div(ADDITIONAL_PORTION);
184: 184: 		uint256 devShare = additionalCAT.sub(reserveShare);
185: 185: 
186: 186: 		totalSupply = totalSupplySafe;
187: 187: 		balances[devCATDestination] = devShare;
188: 188: 		balances[reserveCATDestination] = reserveShare;
189: 189: 		
190: 190: 		CreatedCAT(devCATDestination, devShare);
191: 191: 		CreatedCAT(reserveCATDestination, reserveShare);
192: 192: 
193: 193: 		if (this.balance > 0) {
194: 194: 			if (!devETHDestination.call.value(this.balance)()) throw;
195: 195: 		}
196: 196: 	}
197: 197: 
198: 198: 	
199: 199: 	function withdrawFunds() {
200: 200: 		
201: 201: 		if (!minCapReached) throw;
202: 202: 		if (0 == this.balance) throw;
203: 203: 
204: 204: 		if (!devETHDestination.call.value(this.balance)()) throw;
205: 205: 	}
206: 206: 	
207: 207: 	
208: 208: 	function triggerMinCap() {
209: 209: 		if (msg.sender != executor) throw;
210: 210: 
211: 211: 		minCapReached = true;
212: 212: 	}
213: 213: 
214: 214: 	
215: 215: 	function triggerRefund() {
216: 216: 		
217: 217: 		if (saleHasEnded) throw;
218: 218: 		
219: 219: 		if (minCapReached) throw;
220: 220: 		
221: 221: 		if (block.number < saleEndBlock) throw;
222: 222: 		if (msg.sender != executor) throw;
223: 223: 
224: 224: 		allowRefund = true;
225: 225: 	}
226: 226: 
227: 227: 	function refund() external {
228: 228: 		
229: 229: 		if (!allowRefund) throw;
230: 230: 		
231: 231: 		if (0 == ETHContributed[msg.sender]) throw;
232: 232: 
233: 233: 		
234: 234: 		uint256 etherAmount = ETHContributed[msg.sender];
235: 235: 		ETHContributed[msg.sender] = 0;
236: 236: 
237: 237: 		CATRefundedForWei(msg.sender, etherAmount);
238: 238: 		if (!msg.sender.send(etherAmount)) throw;
239: 239: 	}
240: 240: 
241: 241: 	function changeDeveloperETHDestinationAddress(address _newAddress) {
242: 242: 		if (msg.sender != executor) throw;
243: 243: 		devETHDestination = _newAddress;
244: 244: 	}
245: 245: 	
246: 246: 	function changeDeveloperCATDestinationAddress(address _newAddress) {
247: 247: 		if (msg.sender != executor) throw;
248: 248: 		devCATDestination = _newAddress;
249: 249: 	}
250: 250: 	
251: 251: 	function changeReserveCATDestinationAddress(address _newAddress) {
252: 252: 		if (msg.sender != executor) throw;
253: 253: 		reserveCATDestination = _newAddress;
254: 254: 	}
255: 255: 	
256: 256: 	function transfer(address _to, uint _value) {
257: 257: 		
258: 258: 		if (!minCapReached) throw;
259: 259: 		
260: 260: 		super.transfer(_to, _value);
261: 261: 	}
262: 262: 	
263: 263: 	function transferFrom(address _from, address _to, uint _value) {
264: 264: 		
265: 265: 		if (!minCapReached) throw;
266: 266: 		
267: 267: 		super.transferFrom(_from, _to, _value);
268: 268: 	}
269: 269: }