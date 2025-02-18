1: 1: pragma solidity ^0.4.15;
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
13: 13: 
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22: 
23: 23: 
24: 24: 
25: 25: contract MarketPrice {
26: 26: 
27: 27:     mapping(uint => Token) public tokens;
28: 28: 
29: 29:     address public sender;
30: 30:     address public creator;
31: 31: 
32: 32:     event NewPrice(uint id, string token);
33: 33:     event DeletePrice(uint id);
34: 34:     event UpdatedPrice(uint id);
35: 35:     event RequestUpdate(uint id);
36: 36: 
37: 37:     struct Token {
38: 38:         string name;
39: 39:         uint256 eth;
40: 40:         uint256 usd;
41: 41:         uint256 eur;
42: 42:         uint256 gbp;
43: 43:         uint block;
44: 44:     }
45: 45: 
46: 46:     
47: 47:     function MarketPrice() {
48: 48:         creator = msg.sender;
49: 49:         sender = msg.sender;
50: 50:     }
51: 51: 
52: 52:     
53: 53:     function getToken(uint _id) internal constant returns (Token) {
54: 54:         return tokens[_id];
55: 55:     }
56: 56: 
57: 57:     
58: 58:     function ETH(uint _id) constant returns (uint256) {
59: 59:         return tokens[_id].eth;
60: 60:     }
61: 61: 
62: 62:     
63: 63:     function USD(uint _id) constant returns (uint256) {
64: 64:         return tokens[_id].usd;
65: 65:     }
66: 66: 
67: 67:     
68: 68:     function EUR(uint _id) constant returns (uint256) {
69: 69:         return tokens[_id].eur;
70: 70:     }
71: 71: 
72: 72:     
73: 73:     function GBP(uint _id) constant returns (uint256) {
74: 74:         return tokens[_id].gbp;
75: 75:     }
76: 76: 
77: 77:     
78: 78:     function updatedAt(uint _id) constant returns (uint) {
79: 79:         return tokens[_id].block;
80: 80:     }
81: 81: 
82: 82:     
83: 83:     function update(uint id, string _token, uint256 eth, uint256 usd, uint256 eur, uint256 gbp) external {
84: 84:         require(msg.sender==sender);
85: 85:         tokens[id] = Token(_token, eth, usd, eur, gbp, block.number);
86: 86:         NewPrice(id, _token);
87: 87:     }
88: 88: 
89: 89:     
90: 90:     function deleteToken(uint id) {
91: 91:         require(msg.sender==sender);
92: 92:         DeletePrice(id);
93: 93:         delete tokens[id];
94: 94:     }
95: 95: 
96: 96:     
97: 97:     function changeCreator(address _creator){
98: 98:         require(msg.sender==creator);
99: 99:         creator = _creator;
100: 100:     }
101: 101: 
102: 102:     
103: 103:     function changeSender(address _sender){
104: 104:         require(msg.sender==creator);
105: 105:         sender = _sender;
106: 106:     }
107: 107: 
108: 108:     
109: 109:     function execute(address _to, uint _value, bytes _data) external returns (bytes32 _r) {
110: 110:         require(msg.sender==creator);
111: 111:         require(_to.call.value(_value)(_data));
112: 112:         return 0;
113: 113:     }
114: 114: 
115: 115:     
116: 116:     function() payable {
117: 117: 
118: 118:     }
119: 119: 
120: 120:     
121: 121:     
122: 122:     function requestUpdate(uint id) external payable {
123: 123:         uint256 weiAmount = tokens[0].usd * 35;
124: 124:         require(msg.value >= weiAmount);
125: 125:         sender.transfer(msg.value);
126: 126:         RequestUpdate(id);
127: 127:     }
128: 128: 
129: 129:     
130: 130:     function donate() external payable {
131: 131:         require(msg.value >= 0);
132: 132:         sender.transfer(msg.value);
133: 133:     }
134: 134: 
135: 135: }