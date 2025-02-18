1: 1: pragma solidity ^0.4.19;
2: 2: 
3: 3: interface ERC20 {
4: 4:     function balanceOf(address _owner) public constant returns (uint256 balance);
5: 5:     function transfer(address _to, uint256 _value) public returns (bool success);
6: 6: }
7: 7: 
8: 8: interface ERC223ReceivingContract {
9: 9:     function tokenFallback(address _from, uint _value, bytes _data) public;
10: 10: }
11: 11: 
12: 12: library SafeMath {
13: 13:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
14: 14:     if (a == 0) {
15: 15:       return 0;
16: 16:     }
17: 17:     uint256 c = a * b;
18: 18:     require(c / a == b);
19: 19:     return c;
20: 20:   }
21: 21: }
22: 22: 
23: 23: contract Distribution {
24: 24:   using SafeMath for uint256;
25: 25: 
26: 26:   enum State {
27: 27:     AwaitingTokens,
28: 28:     DistributingNormally,
29: 29:     DistributingProRata,
30: 30:     Done
31: 31:   }
32: 32:  
33: 33:   address admin;
34: 34:   ERC20 tokenContract;
35: 35:   State public state;
36: 36:   uint256 actualTotalTokens;
37: 37:   uint256 tokensTransferred;
38: 38: 
39: 39:   bytes32[] contributionHashes;
40: 40:   uint256 expectedTotalTokens;
41: 41: 
42: 42:   function Distribution(address _admin, ERC20 _tokenContract,
43: 43:                         bytes32[] _contributionHashes, uint256 _expectedTotalTokens) public {
44: 44:     expectedTotalTokens = _expectedTotalTokens;
45: 45:     contributionHashes = _contributionHashes;
46: 46:     tokenContract = _tokenContract;
47: 47:     admin = _admin;
48: 48: 
49: 49:     state = State.AwaitingTokens;
50: 50:   }
51: 51: 
52: 52:   function _handleTokensReceived(uint256 totalTokens) internal {
53: 53:     require(state == State.AwaitingTokens);
54: 54:     require(totalTokens > 0);
55: 55: 
56: 56:     tokensTransferred = 0;
57: 57:     if (totalTokens == expectedTotalTokens) {
58: 58:       state = State.DistributingNormally;
59: 59:     } else {
60: 60:       actualTotalTokens = totalTokens;
61: 61:       state = State.DistributingProRata;
62: 62:     }
63: 63:   }
64: 64: 
65: 65:   function handleTokensReceived() public {
66: 66:     _handleTokensReceived(tokenContract.balanceOf(this));
67: 67:   }
68: 68: 
69: 69:   function tokenFallback(address , uint _value, bytes ) public {
70: 70:     require(msg.sender == address(tokenContract));
71: 71:     _handleTokensReceived(_value);
72: 72:   }
73: 73: 
74: 74:   function _numTokensForContributor(uint256 contributorExpectedTokens,
75: 75:                                     uint256 _tokensTransferred, State _state)
76: 76:       internal view returns (uint256) {
77: 77:     if (_state == State.DistributingNormally) {
78: 78:       return contributorExpectedTokens;
79: 79:     } else if (_state == State.DistributingProRata) {
80: 80:       uint256 tokens = actualTotalTokens.mul(contributorExpectedTokens) / expectedTotalTokens;
81: 81: 
82: 82:       
83: 83:       uint256 tokensRemaining = actualTotalTokens - _tokensTransferred;
84: 84:       if (tokens < tokensRemaining) {
85: 85:         return tokens;
86: 86:       } else {
87: 87:         return tokensRemaining;
88: 88:       }
89: 89:     } else {
90: 90:       revert();
91: 91:     }
92: 92:   }
93: 93: 
94: 94:   function doDistributionRange(uint256 start, address[] contributors,
95: 95:                                uint256[] contributorExpectedTokens) public {
96: 96:     require(contributors.length == contributorExpectedTokens.length);
97: 97: 
98: 98:     uint256 tokensTransferredSoFar = tokensTransferred;
99: 99:     uint256 end = start + contributors.length;
100: 100:     State _state = state;
101: 101:     for (uint256 i = start; i < end; ++i) {
102: 102:       address contributor = contributors[i];
103: 103:       uint256 expectedTokens = contributorExpectedTokens[i];
104: 104:       require(contributionHashes[i] == keccak256(contributor, expectedTokens));
105: 105:       contributionHashes[i] = 0x00000000000000000000000000000000;
106: 106: 
107: 107:       uint256 numTokens = _numTokensForContributor(expectedTokens, tokensTransferredSoFar, _state);
108: 108:       tokensTransferredSoFar += numTokens;
109: 109:       require(tokenContract.transfer(contributor, numTokens));
110: 110:     }
111: 111: 
112: 112:     tokensTransferred = tokensTransferredSoFar;
113: 113:     if (tokensTransferred == actualTotalTokens) {
114: 114:       state = State.Done;
115: 115:     }
116: 116:   }
117: 117: 
118: 118:   function numTokensForContributor(uint256 contributorExpectedTokens)
119: 119:       public view returns (uint256) {
120: 120:     return _numTokensForContributor(contributorExpectedTokens, tokensTransferred, state);
121: 121:   }
122: 122: 
123: 123:   function temporaryEscapeHatch(address to, uint256 value, bytes data) public {
124: 124:     require(msg.sender == admin);
125: 125:     require(to.call.value(value)(data));
126: 126:   }
127: 127: }