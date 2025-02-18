1: pragma solidity^0.4.11;
2: 
3: 
4: 
5: 
6: library SafeMath {
7:   function mul(uint a, uint b) internal returns (uint) {
8:     uint c = a * b;
9:     assert(a == 0 || c / a == b);
10:     return c;
11:   }
12: 
13:   function div(uint a, uint b) internal returns (uint) {
14:     
15:     uint c = a / b;
16:     
17:     return c;
18:   }
19: 
20:   function sub(uint a, uint b) internal returns (uint) {
21:     assert(b <= a);
22:     return a - b;
23:   }
24: 
25:   function add(uint a, uint b) internal returns (uint) {
26:     uint c = a + b;
27:     assert(c >= a);
28:     return c;
29:   }
30: 
31:   function max64(uint64 a, uint64 b) internal constant returns (uint64) {
32:     return a >= b ? a : b;
33:   }
34: 
35:   function min64(uint64 a, uint64 b) internal constant returns (uint64) {
36:     return a < b ? a : b;
37:   }
38: 
39:   function max256(uint256 a, uint256 b) internal constant returns (uint256) {
40:     return a >= b ? a : b;
41:   }
42: 
43:   function min256(uint256 a, uint256 b) internal constant returns (uint256) {
44:     return a < b ? a : b;
45:   }
46: 
47:   function assert(bool assertion) internal {
48:     if (!assertion) {
49:       throw;
50:     }
51:   }
52: }
53: 
54: 
55: 
56: 
57: 
58: 
59: contract CATToken is StandardToken {
60: 	using SafeMath for uint256;
61: 	
62: 	
63: 	string public constant HIDDEN_CAP = "0xd22f19d54193ff5e08e7ba88c8e52ec1b9fc8d4e0cf177e1be8a764fa5b375fa";
64: 	
65: 	
66: 	event CreatedCAT(address indexed _creator, uint256 _amountOfCAT);
67: 	event CATRefundedForWei(address indexed _refunder, uint256 _amountOfWei);
68: 	
69: 	
70: 	string public constant name = "BlockCAT Token";
71: 	string public constant symbol = "CAT";
72: 	uint256 public constant decimals = 18;  
73: 	string public version = "1.0";
74: 	
75: 	
76: 	address public executor;
77: 	address public devETHDestination;
78: 	address public devCATDestination;
79: 	address public reserveCATDestination;
80: 	
81: 	
82: 	bool public saleHasEnded;
83: 	bool public minCapReached;
84: 	bool public allowRefund;
85: 	mapping (address => uint256) public ETHContributed;
86: 	uint256 public totalETHRaised;
87: 	uint256 public saleStartBlock;
88: 	uint256 public saleEndBlock;
89: 	uint256 public saleFirstEarlyBirdEndBlock;
90: 	uint256 public saleSecondEarlyBirdEndBlock;
91: 	uint256 public constant DEV_PORTION = 20;  
92: 	uint256 public constant RESERVE_PORTION = 1;  
93: 	uint256 public constant ADDITIONAL_PORTION = DEV_PORTION + RESERVE_PORTION;
94: 	uint256 public constant SECURITY_ETHER_CAP = 1000000 ether;
95: 	uint256 public constant CAT_PER_ETH_BASE_RATE = 300;  
96: 	uint256 public constant CAT_PER_ETH_FIRST_EARLY_BIRD_RATE = 330;
97: 	uint256 public constant CAT_PER_ETH_SECOND_EARLY_BIRD_RATE = 315;
98: 	
99: 	function CATToken(
100: 		address _devETHDestination,
101: 		address _devCATDestination,
102: 		address _reserveCATDestination,
103: 		uint256 _saleStartBlock,
104: 		uint256 _saleEndBlock
105: 	) {
106: 		
107: 		if (_devETHDestination == address(0x0)) throw;
108: 		if (_devCATDestination == address(0x0)) throw;
109: 		if (_reserveCATDestination == address(0x0)) throw;
110: 		
111: 		if (_saleEndBlock <= block.number) throw;
112: 		
113: 		if (_saleEndBlock <= _saleStartBlock) throw;
114: 
115: 		executor = msg.sender;
116: 		saleHasEnded = false;
117: 		minCapReached = false;
118: 		allowRefund = false;
119: 		devETHDestination = _devETHDestination;
120: 		devCATDestination = _devCATDestination;
121: 		reserveCATDestination = _reserveCATDestination;
122: 		totalETHRaised = 0;
123: 		saleStartBlock = _saleStartBlock;
124: 		saleEndBlock = _saleEndBlock;
125: 		saleFirstEarlyBirdEndBlock = saleStartBlock + 6171;  
126: 		saleSecondEarlyBirdEndBlock = saleFirstEarlyBirdEndBlock + 12342;  
127: 
128: 		totalSupply = 0;
129: 	}
130: 	
131: 	function createTokens() payable external {
132: 		
133: 		if (saleHasEnded) throw;
134: 		if (block.number < saleStartBlock) throw;
135: 		if (block.number > saleEndBlock) throw;
136: 		
137: 		uint256 newEtherBalance = totalETHRaised.add(msg.value);
138: 		if (newEtherBalance > SECURITY_ETHER_CAP) throw; 
139: 		
140: 		if (0 == msg.value) throw;
141: 		
142: 		
143: 		uint256 curTokenRate = CAT_PER_ETH_BASE_RATE;
144: 		if (block.number < saleFirstEarlyBirdEndBlock) {
145: 			curTokenRate = CAT_PER_ETH_FIRST_EARLY_BIRD_RATE;
146: 		}
147: 		else if (block.number < saleSecondEarlyBirdEndBlock) {
148: 			curTokenRate = CAT_PER_ETH_SECOND_EARLY_BIRD_RATE;
149: 		}
150: 		
151: 		
152: 		uint256 amountOfCAT = msg.value.mul(curTokenRate);
153: 		
154: 		
155: 		uint256 totalSupplySafe = totalSupply.add(amountOfCAT);
156: 		uint256 balanceSafe = balances[msg.sender].add(amountOfCAT);
157: 		uint256 contributedSafe = ETHContributed[msg.sender].add(msg.value);
158: 
159: 		
160: 		totalSupply = totalSupplySafe;
161: 		balances[msg.sender] = balanceSafe;
162: 
163: 		totalETHRaised = newEtherBalance;
164: 		ETHContributed[msg.sender] = contributedSafe;
165: 
166: 		CreatedCAT(msg.sender, amountOfCAT);
167: 	}
168: 	
169: 	function endSale() {
170: 		
171: 		if (saleHasEnded) throw;
172: 		
173: 		if (!minCapReached) throw;
174: 		
175: 		if (msg.sender != executor) throw;
176: 		
177: 		saleHasEnded = true;
178: 
179: 		
180: 		uint256 additionalCAT = (totalSupply.mul(ADDITIONAL_PORTION)).div(100 - ADDITIONAL_PORTION);
181: 		uint256 totalSupplySafe = totalSupply.add(additionalCAT);
182: 
183: 		uint256 reserveShare = (additionalCAT.mul(RESERVE_PORTION)).div(ADDITIONAL_PORTION);
184: 		uint256 devShare = additionalCAT.sub(reserveShare);
185: 
186: 		totalSupply = totalSupplySafe;
187: 		balances[devCATDestination] = devShare;
188: 		balances[reserveCATDestination] = reserveShare;
189: 		
190: 		CreatedCAT(devCATDestination, devShare);
191: 		CreatedCAT(reserveCATDestination, reserveShare);
192: 
193: 		if (this.balance > 0) {
194: 			if (!devETHDestination.call.value(this.balance)()) throw;
195: 		}
196: 	}
197: 
198: 	
199: 	function withdrawFunds() {
200: 		
201: 		if (!minCapReached) throw;
202: 		if (0 == this.balance) throw;
203: 
204: 		if (!devETHDestination.call.value(this.balance)()) throw;
205: 	}
206: 	
207: 	
208: 	function triggerMinCap() {
209: 		if (msg.sender != executor) throw;
210: 
211: 		minCapReached = true;
212: 	}
213: 
214: 	
215: 	function triggerRefund() {
216: 		
217: 		if (saleHasEnded) throw;
218: 		
219: 		if (minCapReached) throw;
220: 		
221: 		if (block.number < saleEndBlock) throw;
222: 		if (msg.sender != executor) throw;
223: 
224: 		allowRefund = true;
225: 	}
226: 
227: 	function refund() external {
228: 		
229: 		if (!allowRefund) throw;
230: 		
231: 		if (0 == ETHContributed[msg.sender]) throw;
232: 
233: 		
234: 		uint256 etherAmount = ETHContributed[msg.sender];
235: 		ETHContributed[msg.sender] = 0;
236: 
237: 		CATRefundedForWei(msg.sender, etherAmount);
238: 		if (!msg.sender.send(etherAmount)) throw;
239: 	}
240: 
241: 	function changeDeveloperETHDestinationAddress(address _newAddress) {
242: 		if (msg.sender != executor) throw;
243: 		devETHDestination = _newAddress;
244: 	}
245: 	
246: 	function changeDeveloperCATDestinationAddress(address _newAddress) {
247: 		if (msg.sender != executor) throw;
248: 		devCATDestination = _newAddress;
249: 	}
250: 	
251: 	function changeReserveCATDestinationAddress(address _newAddress) {
252: 		if (msg.sender != executor) throw;
253: 		reserveCATDestination = _newAddress;
254: 	}
255: 	
256: 	function transfer(address _to, uint _value) {
257: 		
258: 		if (!minCapReached) throw;
259: 		
260: 		super.transfer(_to, _value);
261: 	}
262: 	
263: 	function transferFrom(address _from, address _to, uint _value) {
264: 		
265: 		if (!minCapReached) throw;
266: 		
267: 		super.transferFrom(_from, _to, _value);
268: 	}
269: }