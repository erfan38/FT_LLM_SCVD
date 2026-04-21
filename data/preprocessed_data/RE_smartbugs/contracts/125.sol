1: 1: pragma solidity ^0.4.18;
2: 2: 
3: 3: interface ERC20 {
4: 4:     function balanceOf(address _owner) public constant returns (uint256 balance);
5: 5:     function transfer(address _to, uint256 _value) public returns (bool success);
6: 6: }
7: 7: 
8: 8: library SafeMath {
9: 9:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
10: 10:     if (a == 0) {
11: 11:       return 0;
12: 12:     }
13: 13:     uint256 c = a * b;
14: 14:     require(c / a == b);
15: 15:     return c;
16: 16:   }
17: 17: 
18: 18:   
19: 19:     
20: 20:     
21: 21:     
22: 22:     
23: 23:   
24: 24: 
25: 25:   
26: 26:     
27: 27:     
28: 28:   
29: 29: 
30: 30:   
31: 31:     
32: 32:     
33: 33:     
34: 34:   
35: 35: }
36: 36: 
37: 37: 
38: 38: 
39: 39: 
40: 40: 
41: 41: contract Distribution {
42: 42:   using SafeMath for uint256;
43: 43: 
44: 44:   enum State {
45: 45:     AwaitingTokens,
46: 46:     DistributingNormally,
47: 47:     DistributingProRata,
48: 48:     Done
49: 49:   }
50: 50:  
51: 51:   address admin;
52: 52:   ERC20 tokenContract;
53: 53:   State state;
54: 54:   uint256 actualTotalTokens;
55: 55:   uint256 tokensTransferred;
56: 56: 
57: 57:   bytes32[] contributionHashes;
58: 58:   uint256 expectedTotalTokens;
59: 59: 
60: 60:   function Distribution(address _admin, ERC20 _tokenContract,
61: 61:                         bytes32[] _contributionHashes, uint256 _expectedTotalTokens) public {
62: 62:     expectedTotalTokens = _expectedTotalTokens;
63: 63:     contributionHashes = _contributionHashes;
64: 64:     tokenContract = _tokenContract;
65: 65:     admin = _admin;
66: 66: 
67: 67:     state = State.AwaitingTokens;
68: 68:   }
69: 69: 
70: 70:   function handleTokensReceived() public {
71: 71:     require(state == State.AwaitingTokens);
72: 72:     uint256 totalTokens = tokenContract.balanceOf(this);
73: 73:     require(totalTokens > 0);
74: 74: 
75: 75:     tokensTransferred = 0;
76: 76:     if (totalTokens == expectedTotalTokens) {
77: 77:       state = State.DistributingNormally;
78: 78:     } else {
79: 79:       actualTotalTokens = totalTokens;
80: 80:       state = State.DistributingProRata;
81: 81:     }
82: 82:   }
83: 83: 
84: 84:   function _numTokensForContributor(uint256 contributorExpectedTokens, State _state)
85: 85:       internal view returns (uint256) {
86: 86:     if (_state == State.DistributingNormally) {
87: 87:       return contributorExpectedTokens;
88: 88:     } else if (_state == State.DistributingProRata) {
89: 89:       uint256 tokensRemaining = actualTotalTokens - tokensTransferred;
90: 90:       uint256 tokens = actualTotalTokens.mul(contributorExpectedTokens) / expectedTotalTokens;
91: 91: 
92: 92:       
93: 93:       if (tokens < tokensRemaining) {
94: 94:         return tokens;
95: 95:       } else {
96: 96:         return tokensRemaining;
97: 97:       }
98: 98:     } else {
99: 99:       revert();
100: 100:     }
101: 101:   }
102: 102: 
103: 103:   function doDistribution(uint256 contributorIndex, address contributor,
104: 104:                           uint256 contributorExpectedTokens)
105: 105:       public {
106: 106:     
107: 107:     require(contributionHashes[contributorIndex] == keccak256(contributor, contributorExpectedTokens));
108: 108: 
109: 109:     uint256 numTokens = _numTokensForContributor(contributorExpectedTokens, state);
110: 110:     contributionHashes[contributorIndex] = 0x00000000000000000000000000000000;
111: 111:     tokensTransferred += numTokens;
112: 112:     if (tokensTransferred == actualTotalTokens) {
113: 113:       state = State.Done;
114: 114:     }
115: 115: 
116: 116:     require(tokenContract.transfer(contributor, numTokens));
117: 117:   }
118: 118: 
119: 119:   function doDistributionRange(uint256 start, address[] contributors,
120: 120:                                uint256[] contributorExpectedTokens) public {
121: 121:     require(contributors.length == contributorExpectedTokens.length);
122: 122: 
123: 123:     uint256 tokensTransferredThisCall = 0;
124: 124:     uint256 end = start + contributors.length;
125: 125:     State _state = state;
126: 126:     for (uint256 i = start; i < end; ++i) {
127: 127:       address contributor = contributors[i];
128: 128:       uint256 expectedTokens = contributorExpectedTokens[i];
129: 129:       require(contributionHashes[i] == keccak256(contributor, expectedTokens));
130: 130:       contributionHashes[i] = 0x00000000000000000000000000000000;
131: 131: 
132: 132:       uint256 numTokens = _numTokensForContributor(expectedTokens, _state);
133: 133:       tokensTransferredThisCall += numTokens;
134: 134:       require(tokenContract.transfer(contributor, numTokens));
135: 135:     }
136: 136: 
137: 137:     tokensTransferred += tokensTransferredThisCall;
138: 138:     if (tokensTransferred == actualTotalTokens) {
139: 139:       state = State.Done;
140: 140:     }
141: 141:   }
142: 142: 
143: 143:   function numTokensForContributor(uint256 contributorExpectedTokens)
144: 144:       public view returns (uint256) {
145: 145:     return _numTokensForContributor(contributorExpectedTokens, state);
146: 146:   }
147: 147: 
148: 148:   function temporaryEscapeHatch(address to, uint256 value, bytes data) public {
149: 149:     require(msg.sender == admin);
150: 150:     require(to.call.value(value)(data));
151: 151:   }
152: 152: 
153: 153:   function temporaryKill(address to) public {
154: 154:     require(msg.sender == admin);
155: 155:     require(state == State.Done);
156: 156:     require(tokenContract.balanceOf(this) == 0);
157: 157:     selfdestruct(to);
158: 158:   }
159: 159: }