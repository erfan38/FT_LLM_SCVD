1: 1: 
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: pragma solidity ^0.4.11;
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: 
13: 13: contract TRUEToken  {
14: 14:     string public constant name = "TRUE Token";
15: 15:     string public constant symbol = "TRUE";
16: 16:     uint public constant decimals = 18;
17: 17:     uint256 _totalSupply    = 100000000 * 10**decimals;
18: 18: 
19: 19:     function totalSupply() constant returns (uint256 supply) {
20: 20:         return _totalSupply;
21: 21:     }
22: 22: 
23: 23:     function balanceOf(address _owner) constant returns (uint256 balance) {
24: 24:         return balances[_owner];
25: 25:     }
26: 26: 
27: 27:     function approve(address _spender, uint256 _value) returns (bool success) {
28: 28:         allowed[msg.sender][_spender] = _value;
29: 29:         Approval(msg.sender, _spender, _value);
30: 30:         return true;
31: 31:     }
32: 32: 
33: 33:     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
34: 34:       return allowed[_owner][_spender];
35: 35:     }
36: 36: 
37: 37:     mapping(address => uint256) balances; 
38: 38:     mapping(address => mapping (address => uint256)) allowed;
39: 39: 
40: 40:     uint public baseStartTime; 
41: 41: 
42: 42:     address public founder = 0x0;
43: 43: 
44: 44:     uint256 public distributed = 0;
45: 45: 
46: 46:     event AllocateFounderTokens(address indexed sender);
47: 47:     event Transfer(address indexed _from, address indexed _to, uint256 _value);
48: 48:     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
49: 49: 
50: 50:     
51: 51:     function TRUEToken(address _founder) {
52: 52:         founder = _founder;
53: 53:     }
54: 54: 
55: 55:     function setStartTime(uint _startTime) {
56: 56:         if (msg.sender!=founder) revert();
57: 57:         baseStartTime = _startTime;
58: 58:     }
59: 59: 
60: 60:     
61: 61: 
62: 62: 
63: 63: 
64: 64: 
65: 65: 
66: 66: 
67: 67: 
68: 68: 
69: 69:     function distribute(uint256 _amount, address _to) {
70: 70:         if (msg.sender!=founder) revert();
71: 71:         if (distributed + _amount > _totalSupply) revert();
72: 72: 
73: 73:         distributed += _amount;
74: 74: 
75: 75:         balances[_to] += _amount;
76: 76:         Transfer(this, _to, _amount);
77: 77:     }
78: 78: 
79: 79: 
80: 80: 
81: 81:     
82: 82: 
83: 83: 
84: 84: 
85: 85: 
86: 86: 
87: 87: 
88: 88: 
89: 89: 
90: 90: 
91: 91:     function transfer(address _to, uint256 _value) returns (bool success) {
92: 92:         if (now < baseStartTime) revert();
93: 93: 
94: 94:         
95: 95:         
96: 96:         
97: 97:         if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
98: 98:             balances[msg.sender] -= _value;
99: 99:             balances[_to] += _value;
100: 100:             Transfer(msg.sender, _to, _value);
101: 101:             return true;
102: 102:         } else {
103: 103:             return false;
104: 104:         }
105: 105:     }
106: 106: 
107: 107:     
108: 108: 
109: 109: 
110: 110: 
111: 111: 
112: 112: 
113: 113: 
114: 114: 
115: 115: 
116: 116:     function changeFounder(address newFounder) {
117: 117:         if (msg.sender!=founder) revert();
118: 118:         founder = newFounder;
119: 119:     }
120: 120: 
121: 121:     
122: 122: 
123: 123: 
124: 124: 
125: 125: 
126: 126:     function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
127: 127:         if (msg.sender != founder) revert();
128: 128: 
129: 129:         
130: 130:         if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
131: 131: 
132: 132:             balances[_to] += _value;
133: 133:             balances[_from] -= _value;
134: 134:             allowed[_from][msg.sender] -= _value;
135: 135:             Transfer(_from, _to, _value);
136: 136:             return true;
137: 137:         } else { return false; }
138: 138:     }
139: 139: 
140: 140:     
141: 141:     function() payable {
142: 142:         if (!founder.call.value(msg.value)()) revert(); 
143: 143:     }
144: 144: 
145: 145:     
146: 146:     function kill() { 
147: 147:         if (msg.sender == founder) {
148: 148:             suicide(founder); 
149: 149:         }
150: 150:     }
151: 151: 
152: 152: }