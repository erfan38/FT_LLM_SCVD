1: pragma solidity ^0.4.13;
2: 
3: library SafeMath {
4: 
5:   
6: 
7: 
8:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
9:     if (a == 0) {
10:       return 0;
11:     }
12:     uint256 c = a * b;
13:     assert(c / a == b);
14:     return c;
15:   }
16: 
17:   
18: 
19: 
20:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
21:     
22:     uint256 c = a / b;
23:     
24:     return c;
25:   }
26: 
27:   
28: 
29: 
30:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
31:     assert(b <= a);
32:     return a - b;
33:   }
34: 
35:   
36: 
37: 
38:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
39:     uint256 c = a + b;
40:     assert(c >= a);
41:     return c;
42:   }
43: }
44: 
45: contract BasicCrowdsale is ICrowdsaleProcessor {
46:   event CROWDSALE_START(uint256 startTimestamp, uint256 endTimestamp, address fundingAddress);
47: 
48:   
49:   address public fundingAddress;
50: 
51:   
52:   function BasicCrowdsale(
53:     address _owner,
54:     address _manager
55:   )
56:     public
57:   {
58:     owner = _owner;
59:     manager = _manager;
60:   }
61: 
62:   
63:   
64:   
65:   
66:   function mintETHRewards(
67:     address _contract,  
68:     uint256 _amount     
69:   )
70:     public
71:     onlyManager() 
72:   {
73:     require(_contract.call.value(_amount)());
74:   }
75: 
76:   
77:   function stop() public onlyManager() hasntStopped()  {
78:     
79:     if (started) {
80:       require(!isFailed());
81:       require(!isSuccessful());
82:     }
83:     stopped = true;
84:   }
85: 
86:   
87:   
88:   function start(
89:     uint256 _startTimestamp,
90:     uint256 _endTimestamp,
91:     address _fundingAddress
92:   )
93:     public
94:     onlyManager()   
95:     hasntStarted()  
96:     hasntStopped()  
97:   {
98:     require(_fundingAddress != address(0));
99: 
100:     
101:     require(_startTimestamp >= block.timestamp);
102: 
103:     
104:     require(_endTimestamp > _startTimestamp);
105:     duration = _endTimestamp - _startTimestamp;
106: 
107:     
108:     require(duration >= MIN_CROWDSALE_TIME && duration <= MAX_CROWDSALE_TIME);
109: 
110:     startTimestamp = _startTimestamp;
111:     endTimestamp = _endTimestamp;
112:     fundingAddress = _fundingAddress;
113: 
114:     
115:     started = true;
116: 
117:     emit CROWDSALE_START(_startTimestamp, _endTimestamp, _fundingAddress);
118:   }
119: 
120:   
121:   function isFailed()
122:     public
123:     constant
124:     returns(bool)
125:   {
126:     return (
127:       
128:       started &&
129: 
130:       
131:       block.timestamp >= endTimestamp &&
132: 
133:       
134:       totalCollected < minimalGoal
135:     );
136:   }
137: 
138:   
139:   function isActive()
140:     public
141:     constant
142:     returns(bool)
143:   {
144:     return (
145:       
146:       started &&
147: 
148:       
149:       totalCollected < hardCap &&
150: 
151:       
152:       block.timestamp >= startTimestamp &&
153:       block.timestamp < endTimestamp
154:     );
155:   }
156: 
157:   
158:   function isSuccessful()
159:     public
160:     constant
161:     returns(bool)
162:   {
163:     return (
164:       
165:       totalCollected >= hardCap ||
166: 
167:       
168:       (block.timestamp >= endTimestamp && totalCollected >= minimalGoal)
169:     );
170:   }
171: }
172: 