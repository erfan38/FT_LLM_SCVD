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
35: 35: contract TelcoinSaleKYCEscrow {
36: 36:     using SafeMath for uint256;
37: 37: 
38: 38:     event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
39: 39:     event ValuePlaced(address indexed purchaser, address indexed beneficiary, uint256 amount);
40: 40:     event Approved(address indexed participant);
41: 41:     event Rejected(address indexed participant);
42: 42:     event Closed();
43: 43: 
44: 44:     
45: 45:     address public owner;
46: 46: 
47: 47:     
48: 48:     TelcoinSale public sale;
49: 49: 
50: 50:     
51: 51:     bool public closed = false;
52: 52: 
53: 53:     
54: 54:     mapping(address => uint256) public deposited;
55: 55: 
56: 56:     modifier onlyOwner() {
57: 57:         require(msg.sender == owner);
58: 58:         _;
59: 59:     }
60: 60: 
61: 61:     modifier escrowOpen() {
62: 62:         require(!closed);
63: 63:         _;
64: 64:     }
65: 65: 
66: 66:     function TelcoinSaleKYCEscrow(TelcoinSale _sale) public {
67: 67:         require(_sale != address(0));
68: 68: 
69: 69:         owner = msg.sender;
70: 70:         sale = _sale;
71: 71:     }
72: 72: 
73: 73:     function () public payable {
74: 74:         placeValue(msg.sender);
75: 75:     }
76: 76: 
77: 77:     function approve(address _participant) onlyOwner public {
78: 78:         uint256 weiAmount = deposited[_participant];
79: 79:         require(weiAmount > 0);
80: 80: 
81: 81:         deposited[_participant] = 0;
82: 82:         Approved(_participant);
83: 83:         sale.buyTokens.value(weiAmount)(_participant);
84: 84:     }
85: 85: 
86: 86:     function approveMany(address[] _participants) onlyOwner public {
87: 87:         for (uint256 i = 0; i < _participants.length; i++) {
88: 88:             approve(_participants[i]);
89: 89:         }
90: 90:     }
91: 91: 
92: 92:     function close() onlyOwner public {
93: 93:         require(!closed);
94: 94: 
95: 95:         closed = true;
96: 96:         Closed();
97: 97:     }
98: 98: 
99: 99:     function placeValue(address _beneficiary) escrowOpen public payable {
100: 100:         require(_beneficiary != address(0));
101: 101: 
102: 102:         uint256 weiAmount = msg.value;
103: 103:         require(weiAmount > 0);
104: 104: 
105: 105:         uint256 newDeposited = deposited[_beneficiary].add(weiAmount);
106: 106:         deposited[_beneficiary] = newDeposited;
107: 107: 
108: 108:         ValuePlaced(
109: 109:             msg.sender,
110: 110:             _beneficiary,
111: 111:             weiAmount
112: 112:         );
113: 113:     }
114: 114: 
115: 115:     function reject(address _participant) onlyOwner public {
116: 116:         uint256 weiAmount = deposited[_participant];
117: 117:         require(weiAmount > 0);
118: 118: 
119: 119:         deposited[_participant] = 0;
120: 120:         Rejected(_participant);
121: 121:         require(_participant.call.value(weiAmount)());
122: 122:     }
123: 123: 
124: 124:     function rejectMany(address[] _participants) onlyOwner public {
125: 125:         for (uint256 i = 0; i < _participants.length; i++) {
126: 126:             reject(_participants[i]);
127: 127:         }
128: 128:     }
129: 129: 
130: 130:     function transferOwnership(address _to) onlyOwner public {
131: 131:         require(_to != address(0));
132: 132:         OwnershipTransferred(owner, _to);
133: 133:         owner = _to;
134: 134:     }
135: 135: }