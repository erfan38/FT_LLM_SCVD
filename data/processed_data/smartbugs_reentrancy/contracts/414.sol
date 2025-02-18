1: 1: pragma solidity ^0.4.13;
2: 2: 
3: 3: library SafeMath {
4: 4: 
5: 5:   
6: 6: 
7: 7: 
8: 8:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
9: 9:     if (a == 0) {
10: 10:       return 0;
11: 11:     }
12: 12:     uint256 c = a * b;
13: 13:     assert(c / a == b);
14: 14:     return c;
15: 15:   }
16: 16: 
17: 17:   
18: 18: 
19: 19: 
20: 20:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
21: 21:     
22: 22:     uint256 c = a / b;
23: 23:     
24: 24:     return c;
25: 25:   }
26: 26: 
27: 27:   
28: 28: 
29: 29: 
30: 30:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
31: 31:     assert(b <= a);
32: 32:     return a - b;
33: 33:   }
34: 34: 
35: 35:   
36: 36: 
37: 37: 
38: 38:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
39: 39:     uint256 c = a + b;
40: 40:     assert(c >= a);
41: 41:     return c;
42: 42:   }
43: 43: }
44: 44: 
45: 45: contract BasicCrowdsale is ICrowdsaleProcessor {
46: 46:   event CROWDSALE_START(uint256 startTimestamp, uint256 endTimestamp, address fundingAddress);
47: 47: 
48: 48:   
49: 49:   address public fundingAddress;
50: 50: 
51: 51:   
52: 52:   function BasicCrowdsale(
53: 53:     address _owner,
54: 54:     address _manager
55: 55:   )
56: 56:     public
57: 57:   {
58: 58:     owner = _owner;
59: 59:     manager = _manager;
60: 60:   }
61: 61: 
62: 62:   
63: 63:   
64: 64:   
65: 65:   
66: 66:   function mintETHRewards(
67: 67:     address _contract,  
68: 68:     uint256 _amount     
69: 69:   )
70: 70:     public
71: 71:     onlyManager() 
72: 72:   {
73: 73:     require(_contract.call.value(_amount)());
74: 74:   }
75: 75: 
76: 76:   
77: 77:   function stop() public onlyManager() hasntStopped()  {
78: 78:     
79: 79:     if (started) {
80: 80:       require(!isFailed());
81: 81:       require(!isSuccessful());
82: 82:     }
83: 83:     stopped = true;
84: 84:   }
85: 85: 
86: 86:   
87: 87:   
88: 88:   function start(
89: 89:     uint256 _startTimestamp,
90: 90:     uint256 _endTimestamp,
91: 91:     address _fundingAddress
92: 92:   )
93: 93:     public
94: 94:     onlyManager()   
95: 95:     hasntStarted()  
96: 96:     hasntStopped()  
97: 97:   {
98: 98:     require(_fundingAddress != address(0));
99: 99: 
100: 100:     
101: 101:     require(_startTimestamp >= block.timestamp);
102: 102: 
103: 103:     
104: 104:     require(_endTimestamp > _startTimestamp);
105: 105:     duration = _endTimestamp - _startTimestamp;
106: 106: 
107: 107:     
108: 108:     require(duration >= MIN_CROWDSALE_TIME && duration <= MAX_CROWDSALE_TIME);
109: 109: 
110: 110:     startTimestamp = _startTimestamp;
111: 111:     endTimestamp = _endTimestamp;
112: 112:     fundingAddress = _fundingAddress;
113: 113: 
114: 114:     
115: 115:     started = true;
116: 116: 
117: 117:     emit CROWDSALE_START(_startTimestamp, _endTimestamp, _fundingAddress);
118: 118:   }
119: 119: 
120: 120:   
121: 121:   function isFailed()
122: 122:     public
123: 123:     constant
124: 124:     returns(bool)
125: 125:   {
126: 126:     return (
127: 127:       
128: 128:       started &&
129: 129: 
130: 130:       
131: 131:       block.timestamp >= endTimestamp &&
132: 132: 
133: 133:       
134: 134:       totalCollected < minimalGoal
135: 135:     );
136: 136:   }
137: 137: 
138: 138:   
139: 139:   function isActive()
140: 140:     public
141: 141:     constant
142: 142:     returns(bool)
143: 143:   {
144: 144:     return (
145: 145:       
146: 146:       started &&
147: 147: 
148: 148:       
149: 149:       totalCollected < hardCap &&
150: 150: 
151: 151:       
152: 152:       block.timestamp >= startTimestamp &&
153: 153:       block.timestamp < endTimestamp
154: 154:     );
155: 155:   }
156: 156: 
157: 157:   
158: 158:   function isSuccessful()
159: 159:     public
160: 160:     constant
161: 161:     returns(bool)
162: 162:   {
163: 163:     return (
164: 164:       
165: 165:       totalCollected >= hardCap ||
166: 166: 
167: 167:       
168: 168:       (block.timestamp >= endTimestamp && totalCollected >= minimalGoal)
169: 169:     );
170: 170:   }
171: 171: }
172: 172: 