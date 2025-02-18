1: 1: 1: 1: 1: interface ERC20 {
2: 2: 2: 2: 2:     function balanceOf(address _owner) public constant returns (uint256 balance);
3: 3: 3: 3: 3:     function transfer(address _to, uint256 _value) public returns (bool success);
4: 4: 4: 4: 4: }
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: library SafeMath {
7: 7: 7: 7: 7:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
8: 8: 8: 8: 8:     if (a == 0) {
9: 9: 9: 9: 9:       return 0;
10: 10: 10: 10: 10:     }
11: 11: 11: 11: 11:     uint256 c = a * b;
12: 12: 12: 12: 12:     require(c / a == b);
13: 13: 13: 13: 13:     return c;
14: 14: 14: 14: 14:   }
15: 15: 15: 15: 15: 
16: 16: 16: 16: 16:   
17: 17: 17: 17: 17:     
18: 18: 18: 18: 18:     
19: 19: 19: 19: 19:     
20: 20: 20: 20: 20:     
21: 21: 21: 21: 21:   
22: 22: 22: 22: 22: 
23: 23: 23: 23: 23:   
24: 24: 24: 24: 24:     
25: 25: 25: 25: 25:     
26: 26: 26: 26: 26:   
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28:   
29: 29: 29: 29: 29:     
30: 30: 30: 30: 30:     
31: 31: 31: 31: 31:     
32: 32: 32: 32: 32:   
33: 33: 33: 33: 33: }
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37: 
38: 38: 38: 38: 38: 
39: 39: 39: 39: 39: contract Distribution {
40: 40: 40: 40: 40:   using SafeMath for uint256;
41: 41: 41: 41: 41: 
42: 42: 42: 42: 42:   enum State {
43: 43: 43: 43: 43:     AwaitingTokens,
44: 44: 44: 44: 44:     DistributingNormally,
45: 45: 45: 45: 45:     DistributingProRata,
46: 46: 46: 46: 46:     Done
47: 47: 47: 47: 47:   }
48: 48: 48: 48: 48:  
49: 49: 49: 49: 49:   address admin;
50: 50: 50: 50: 50:   ERC20 tokenContract;
51: 51: 51: 51: 51:   State state;
52: 52: 52: 52: 52:   uint256 actualTotalTokens;
53: 53: 53: 53: 53:   uint256 tokensTransferred;
54: 54: 54: 54: 54: 
55: 55: 55: 55: 55:   bytes32[] contributionHashes;
56: 56: 56: 56: 56:   uint256 expectedTotalTokens;
57: 57: 57: 57: 57: 
58: 58: 58: 58: 58:   function Distribution(address _admin, ERC20 _tokenContract,
59: 59: 59: 59: 59:                         bytes32[] _contributionHashes, uint256 _expectedTotalTokens) public {
60: 60: 60: 60: 60:     expectedTotalTokens = _expectedTotalTokens;
61: 61: 61: 61: 61:     contributionHashes = _contributionHashes;
62: 62: 62: 62: 62:     tokenContract = _tokenContract;
63: 63: 63: 63: 63:     admin = _admin;
64: 64: 64: 64: 64: 
65: 65: 65: 65: 65:     state = State.AwaitingTokens;
66: 66: 66: 66: 66:   }
67: 67: 67: 67: 67: 
68: 68: 68: 68: 68:   function handleTokensReceived() public {
69: 69: 69: 69: 69:     require(state == State.AwaitingTokens);
70: 70: 70: 70: 70:     uint256 totalTokens = tokenContract.balanceOf(this);
71: 71: 71: 71: 71:     require(totalTokens > 0);
72: 72: 72: 72: 72: 
73: 73: 73: 73: 73:     tokensTransferred = 0;
74: 74: 74: 74: 74:     if (totalTokens == expectedTotalTokens) {
75: 75: 75: 75: 75:       state = State.DistributingNormally;
76: 76: 76: 76: 76:     } else {
77: 77: 77: 77: 77:       actualTotalTokens = totalTokens;
78: 78: 78: 78: 78:       state = State.DistributingProRata;
79: 79: 79: 79: 79:     }
80: 80: 80: 80: 80:   }
81: 81: 81: 81: 81: 
82: 82: 82: 82: 82:   function _numTokensForContributor(uint256 contributorExpectedTokens,
83: 83: 83: 83: 83:                                     uint256 _tokensTransferred, State _state)
84: 84: 84: 84: 84:       internal view returns (uint256) {
85: 85: 85: 85: 85:     if (_state == State.DistributingNormally) {
86: 86: 86: 86: 86:       return contributorExpectedTokens;
87: 87: 87: 87: 87:     } else if (_state == State.DistributingProRata) {
88: 88: 88: 88: 88:       uint256 tokens = actualTotalTokens.mul(contributorExpectedTokens) / expectedTotalTokens;
89: 89: 89: 89: 89: 
90: 90: 90: 90: 90:       
91: 91: 91: 91: 91:       uint256 tokensRemaining = actualTotalTokens - _tokensTransferred;
92: 92: 92: 92: 92:       if (tokens < tokensRemaining) {
93: 93: 93: 93: 93:         return tokens;
94: 94: 94: 94: 94:       } else {
95: 95: 95: 95: 95:         return tokensRemaining;
96: 96: 96: 96: 96:       }
97: 97: 97: 97: 97:     } else {
98: 98: 98: 98: 98:       revert();
99: 99: 99: 99: 99:     }
100: 100: 100: 100: 100:   }
101: 101: 101: 101: 101: 
102: 102: 102: 102: 102:   function doDistribution(uint256 contributorIndex, address contributor,
103: 103: 103: 103: 103:                           uint256 contributorExpectedTokens)
104: 104: 104: 104: 104:       public {
105: 105: 105: 105: 105:     
106: 106: 106: 106: 106:     require(contributionHashes[contributorIndex] == keccak256(contributor, contributorExpectedTokens));
107: 107: 107: 107: 107: 
108: 108: 108: 108: 108:     uint256 numTokens = _numTokensForContributor(contributorExpectedTokens,
109: 109: 109: 109: 109:                                                  tokensTransferred, state);
110: 110: 110: 110: 110:     contributionHashes[contributorIndex] = 0x00000000000000000000000000000000;
111: 111: 111: 111: 111:     tokensTransferred += numTokens;
112: 112: 112: 112: 112:     if (tokensTransferred == actualTotalTokens) {
113: 113: 113: 113: 113:       state = State.Done;
114: 114: 114: 114: 114:     }
115: 115: 115: 115: 115: 
116: 116: 116: 116: 116:     require(tokenContract.transfer(contributor, numTokens));
117: 117: 117: 117: 117:   }
118: 118: 118: 118: 118: 
119: 119: 119: 119: 119:   function doDistributionRange(uint256 start, address[] contributors,
120: 120: 120: 120: 120:                                uint256[] contributorExpectedTokens) public {
121: 121: 121: 121: 121:     require(contributors.length == contributorExpectedTokens.length);
122: 122: 122: 122: 122: 
123: 123: 123: 123: 123:     uint256 tokensTransferredSoFar = tokensTransferred;
124: 124: 124: 124: 124:     uint256 end = start + contributors.length;
125: 125: 125: 125: 125:     State _state = state;
126: 126: 126: 126: 126:     for (uint256 i = start; i < end; ++i) {
127: 127: 127: 127: 127:       address contributor = contributors[i];
128: 128: 128: 128: 128:       uint256 expectedTokens = contributorExpectedTokens[i];
129: 129: 129: 129: 129:       require(contributionHashes[i] == keccak256(contributor, expectedTokens));
130: 130: 130: 130: 130:       contributionHashes[i] = 0x00000000000000000000000000000000;
131: 131: 131: 131: 131: 
132: 132: 132: 132: 132:       uint256 numTokens = _numTokensForContributor(expectedTokens, tokensTransferredSoFar, _state);
133: 133: 133: 133: 133:       tokensTransferredSoFar += numTokens;
134: 134: 134: 134: 134:       require(tokenContract.transfer(contributor, numTokens));
135: 135: 135: 135: 135:     }
136: 136: 136: 136: 136: 
137: 137: 137: 137: 137:     tokensTransferred = tokensTransferredSoFar;
138: 138: 138: 138: 138:     if (tokensTransferred == actualTotalTokens) {
139: 139: 139: 139: 139:       state = State.Done;
140: 140: 140: 140: 140:     }
141: 141: 141: 141: 141:   }
142: 142: 142: 142: 142: 
143: 143: 143: 143: 143:   function numTokensForContributor(uint256 contributorExpectedTokens)
144: 144: 144: 144: 144:       public view returns (uint256) {
145: 145: 145: 145: 145:     return _numTokensForContributor(contributorExpectedTokens, tokensTransferred, state);
146: 146: 146: 146: 146:   }
147: 147: 147: 147: 147: 
148: 148: 148: 148: 148:   function temporaryEscapeHatch(address to, uint256 value, bytes data) public {
149: 149: 149: 149: 149:     require(msg.sender == admin);
150: 150: 150: 150: 150:     require(to.call.value(value)(data));
151: 151: 151: 151: 151:   }
152: 152: 152: 152: 152: 
153: 153: 153: 153: 153:   function temporaryKill(address to) public {
154: 154: 154: 154: 154:     require(msg.sender == admin);
155: 155: 155: 155: 155:     require(tokenContract.balanceOf(this) == 0);
156: 156: 156: 156: 156:     selfdestruct(to);
157: 157: 157: 157: 157:   }
158: 158: 158: 158: 158: }