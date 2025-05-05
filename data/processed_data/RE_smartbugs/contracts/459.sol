1: 1: 
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
12: 12: pragma solidity ^0.4.13;
13: 13: 
14: 14: contract Wallet is multisig, multiowned, daylimit, creator {
15: 15: 
16: 16: 	
17: 17: 
18: 18: 	
19: 19: 	struct Transaction {
20: 20: 		address to;
21: 21: 		uint value;
22: 22: 		bytes data;
23: 23: 	}
24: 24: 
25: 25: 	
26: 26: 
27: 27: 	
28: 28: 	
29: 29: 	function Wallet(address[] _owners, uint _required, uint _daylimit)
30: 30: 			multiowned(_owners, _required) daylimit(_daylimit) {
31: 31: 	}
32: 32: 
33: 33: 	
34: 34: 	function kill(address _to) onlymanyowners(sha3(msg.data)) external {
35: 35: 		suicide(_to);
36: 36: 	}
37: 37: 
38: 38: 	
39: 39: 	function() payable {
40: 40: 		
41: 41: 		if (msg.value > 0)
42: 42: 			Deposit(msg.sender, msg.value);
43: 43: 	}
44: 44: 
45: 45: 	
46: 46: 	
47: 47: 	
48: 48: 	
49: 49: 	function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 o_hash) {
50: 50: 		
51: 51: 		if ((_data.length == 0 && underLimit(_value)) || m_required == 1) {
52: 52: 			
53: 53: 			address created;
54: 54: 			if (_to == 0) {
55: 55: 				created = create(_value, _data);
56: 56: 			} else {
57: 57: 				require(_to.call.value(_value)(_data));
58: 58: 			}
59: 59: 			SingleTransact(msg.sender, _value, _to, _data, created);
60: 60: 		} else {
61: 61: 			
62: 62: 			o_hash = sha3(msg.data, block.number);
63: 63: 			
64: 64: 			if (m_txs[o_hash].to == 0 && m_txs[o_hash].value == 0 && m_txs[o_hash].data.length == 0) {
65: 65: 				m_txs[o_hash].to = _to;
66: 66: 				m_txs[o_hash].value = _value;
67: 67: 				m_txs[o_hash].data = _data;
68: 68: 			}
69: 69: 			if (!confirm(o_hash)) {
70: 70: 				ConfirmationNeeded(o_hash, msg.sender, _value, _to, _data);
71: 71: 			}
72: 72: 		}
73: 73: 	}
74: 74: 
75: 75: 	function create(uint _value, bytes _code) internal returns (address o_addr) {
76: 76: 		return doCreate(_value, _code);
77: 77: 	}
78: 78: 
79: 79: 	
80: 80: 	
81: 81: 	function confirm(bytes32 _h) onlymanyowners(_h) returns (bool o_success) {
82: 82: 		if (m_txs[_h].to != 0 || m_txs[_h].value != 0 || m_txs[_h].data.length != 0) {
83: 83: 			address created;
84: 84: 			if (m_txs[_h].to == 0) {
85: 85: 				created = create(m_txs[_h].value, m_txs[_h].data);
86: 86: 			} else {
87: 87: 				require(m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data));
88: 88: 			}
89: 89: 
90: 90: 			MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data, created);
91: 91: 			delete m_txs[_h];
92: 92: 			return true;
93: 93: 		}
94: 94: 	}
95: 95: 
96: 96: 	
97: 97: 
98: 98: 	function clearPending() internal {
99: 99: 		uint length = m_pendingIndex.length;
100: 100: 		for (uint i = 0; i < length; ++i)
101: 101: 			delete m_txs[m_pendingIndex[i]];
102: 102: 		super.clearPending();
103: 103: 	}
104: 104: 
105: 105: 	
106: 106: 
107: 107: 	
108: 108: 	mapping (bytes32 => Transaction) m_txs;
109: 109: }