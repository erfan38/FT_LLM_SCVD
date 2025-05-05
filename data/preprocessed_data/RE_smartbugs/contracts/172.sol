1: 1: pragma solidity ^0.4.23;
2: 2: 
3: 3: 
4: 4: contract BasicCrowdsale is ICrowdsaleProcessor {
5: 5:   event CROWDSALE_START(uint256 startTimestamp, uint256 endTimestamp, address fundingAddress);
6: 6: 
7: 7:   
8: 8:   address public fundingAddress;
9: 9: 
10: 10:   
11: 11:   function BasicCrowdsale(
12: 12:     address _owner,
13: 13:     address _manager
14: 14:   )
15: 15:     public
16: 16:   {
17: 17:     owner = _owner;
18: 18:     manager = _manager;
19: 19:   }
20: 20: 
21: 21:   
22: 22:   
23: 23:   
24: 24:   
25: 25:   function mintETHRewards(
26: 26:     address _contract,  
27: 27:     uint256 _amount     
28: 28:   )
29: 29:     public
30: 30:     onlyManager() 
31: 31:   {
32: 32:     require(_contract.call.value(_amount)());
33: 33:   }
34: 34: 
35: 35:   
36: 36:   function stop() public onlyManager() hasntStopped()  {
37: 37:     
38: 38:     if (started) {
39: 39:       require(!isFailed());
40: 40:       require(!isSuccessful());
41: 41:     }
42: 42:     stopped = true;
43: 43:   }
44: 44: 
45: 45:   
46: 46:   
47: 47:   function start(
48: 48:     uint256 _startTimestamp,
49: 49:     uint256 _endTimestamp,
50: 50:     address _fundingAddress
51: 51:   )
52: 52:     public
53: 53:     onlyManager()   
54: 54:     hasntStarted()  
55: 55:     hasntStopped()  
56: 56:   {
57: 57:     require(_fundingAddress != address(0));
58: 58: 
59: 59:     
60: 60:     require(_startTimestamp >= block.timestamp);
61: 61: 
62: 62:     
63: 63:     require(_endTimestamp > _startTimestamp);
64: 64:     duration = _endTimestamp - _startTimestamp;
65: 65: 
66: 66:     
67: 67:     require(duration >= MIN_CROWDSALE_TIME && duration <= MAX_CROWDSALE_TIME);
68: 68: 
69: 69:     startTimestamp = _startTimestamp;
70: 70:     endTimestamp = _endTimestamp;
71: 71:     fundingAddress = _fundingAddress;
72: 72: 
73: 73:     
74: 74:     started = true;
75: 75: 
76: 76:     CROWDSALE_START(_startTimestamp, _endTimestamp, _fundingAddress);
77: 77:   }
78: 78: 
79: 79:   
80: 80:   function isFailed()
81: 81:     public
82: 82:     constant
83: 83:     returns(bool)
84: 84:   {
85: 85:     return (
86: 86:       
87: 87:       started &&
88: 88: 
89: 89:       
90: 90:       block.timestamp >= endTimestamp &&
91: 91: 
92: 92:       
93: 93:       totalCollected < minimalGoal
94: 94:     );
95: 95:   }
96: 96: 
97: 97:   
98: 98:   function isActive()
99: 99:     public
100: 100:     constant
101: 101:     returns(bool)
102: 102:   {
103: 103:     return (
104: 104:       
105: 105:       started &&
106: 106: 
107: 107:       
108: 108:       totalCollected < hardCap &&
109: 109: 
110: 110:       
111: 111:       block.timestamp >= startTimestamp &&
112: 112:       block.timestamp < endTimestamp
113: 113:     );
114: 114:   }
115: 115: 
116: 116:   
117: 117:   function isSuccessful()
118: 118:     public
119: 119:     constant
120: 120:     returns(bool)
121: 121:   {
122: 122:     return (
123: 123:       
124: 124:       totalCollected >= hardCap ||
125: 125: 
126: 126:       
127: 127:       (block.timestamp >= endTimestamp && totalCollected >= minimalGoal)
128: 128:     );
129: 129:   }
130: 130: }
131: 131: 
132: 132: 
133: 133: 
134: 134: 
135: 135: 