1: 1: pragma solidity 0.4.18;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: library SafeMath {
9: 9:     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
10: 10:         uint256 c = a * b;
11: 11:         assert(a == 0 || c / a == b);
12: 12:         return c;
13: 13:     }
14: 14: 
15: 15:     function div(uint256 a, uint256 b) internal pure returns (uint256) {
16: 16:         
17: 17:         uint256 c = a / b;
18: 18:         
19: 19:         return c;
20: 20:     }
21: 21: 
22: 22:     function sub(uint256 a, uint256 b) internal pure returns (uint256) {
23: 23:         assert(b <= a);
24: 24:         return a - b;
25: 25:     }
26: 26: 
27: 27:     function add(uint256 a, uint256 b) internal pure returns (uint256) {
28: 28:         uint256 c = a + b;
29: 29:         assert(c >= a);
30: 30:         return c;
31: 31:     }
32: 32: }
33: 33: 
34: 34: 
35: 35: contract TelcoinSaleCapEscrow {
36: 36:     using SafeMath for uint256;
37: 37: 
38: 38:     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
39: 39:     event WalletChanged(address indexed previousWallet, address indexed newWallet);
40: 40:     event ValuePlaced(address indexed purchaser, address indexed beneficiary, uint256 amount);
41: 41:     event Approved(address indexed participant, uint256 amount);
42: 42:     event Rejected(address indexed participant);
43: 43:     event Closed();
44: 44: 
45: 45:     
46: 46:     address public owner;
47: 47: 
48: 48:     
49: 49:     
50: 50:     address public wallet;
51: 51: 
52: 52:     
53: 53:     bool public closed = false;
54: 54: 
55: 55:     
56: 56:     
57: 57:     mapping(address => uint256) public deposited;
58: 58: 
59: 59:     modifier onlyOwner() {
60: 60:         require(msg.sender == owner);
61: 61:         _;
62: 62:     }
63: 63: 
64: 64:     modifier escrowOpen() {
65: 65:         require(!closed);
66: 66:         _;
67: 67:     }
68: 68: 
69: 69:     function TelcoinSaleCapEscrow(address _wallet) public payable {
70: 70:         require(msg.value > 0);
71: 71:         require(_wallet != address(0));
72: 72: 
73: 73:         owner = msg.sender;
74: 74:         wallet = _wallet;
75: 75: 
76: 76:         wallet.transfer(msg.value);
77: 77:     }
78: 78: 
79: 79:     function () public payable {
80: 80:         placeValue(msg.sender);
81: 81:     }
82: 82: 
83: 83:     
84: 84:     
85: 85:     
86: 86:     function approve(address _participant, uint256 _weiAmount) onlyOwner public {
87: 87:         uint256 depositedAmount = deposited[_participant];
88: 88:         require(depositedAmount > 0);
89: 89:         require(_weiAmount <= depositedAmount);
90: 90: 
91: 91:         deposited[_participant] = depositedAmount.sub(_weiAmount);
92: 92:         Approved(_participant, _weiAmount);
93: 93:         wallet.transfer(_weiAmount);
94: 94:     }
95: 95: 
96: 96:     function approveMany(address[] _participants, uint256[] _weiAmounts) onlyOwner public {
97: 97:         require(_participants.length == _weiAmounts.length);
98: 98: 
99: 99:         for (uint256 i = 0; i < _participants.length; i++) {
100: 100:             approve(_participants[i], _weiAmounts[i]);
101: 101:         }
102: 102:     }
103: 103: 
104: 104:     function changeWallet(address _wallet) onlyOwner public payable {
105: 105:         require(_wallet != 0x0);
106: 106:         require(msg.value > 0);
107: 107: 
108: 108:         WalletChanged(wallet, _wallet);
109: 109:         wallet = _wallet;
110: 110:         wallet.transfer(msg.value);
111: 111:     }
112: 112: 
113: 113:     function close() onlyOwner public {
114: 114:         require(!closed);
115: 115: 
116: 116:         closed = true;
117: 117:         Closed();
118: 118:     }
119: 119: 
120: 120:     function placeValue(address _beneficiary) escrowOpen public payable {
121: 121:         require(_beneficiary != address(0));
122: 122: 
123: 123:         uint256 weiAmount = msg.value;
124: 124:         require(weiAmount > 0);
125: 125: 
126: 126:         uint256 newDeposited = deposited[_beneficiary].add(weiAmount);
127: 127:         deposited[_beneficiary] = newDeposited;
128: 128: 
129: 129:         ValuePlaced(
130: 130:             msg.sender,
131: 131:             _beneficiary,
132: 132:             weiAmount
133: 133:         );
134: 134:     }
135: 135: 
136: 136:     function reject(address _participant) onlyOwner public {
137: 137:         uint256 weiAmount = deposited[_participant];
138: 138:         require(weiAmount > 0);
139: 139: 
140: 140:         deposited[_participant] = 0;
141: 141:         Rejected(_participant);
142: 142:         require(_participant.call.value(weiAmount)());
143: 143:     }
144: 144: 
145: 145:     function rejectMany(address[] _participants) onlyOwner public {
146: 146:         for (uint256 i = 0; i < _participants.length; i++) {
147: 147:             reject(_participants[i]);
148: 148:         }
149: 149:     }
150: 150: 
151: 151:     function transferOwnership(address _to) onlyOwner public {
152: 152:         require(_to != address(0));
153: 153:         OwnershipTransferred(owner, _to);
154: 154:         owner = _to;
155: 155:     }
156: 156: }