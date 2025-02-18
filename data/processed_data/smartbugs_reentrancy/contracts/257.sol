1: 1: 1: 1: 1: pragma solidity ^0.4.24;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: 
8: 8: 8: 8: 8: 
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10: contract MultiBuyer is CanReclaimToken {
11: 11: 11: 11: 11:     using SafeMath for uint256;
12: 12: 12: 12: 12: 
13: 13: 13: 13: 13:     function buyOnApprove(
14: 14: 14: 14: 14:         IMultiToken _mtkn,
15: 15: 15: 15: 15:         uint256 _minimumReturn,
16: 16: 16: 16: 16:         ERC20 _throughToken,
17: 17: 17: 17: 17:         address[] _exchanges,
18: 18: 18: 18: 18:         bytes _datas,
19: 19: 19: 19: 19:         uint[] _datasIndexes, 
20: 20: 20: 20: 20:         uint256[] _values
21: 21: 21: 21: 21:     )
22: 22: 22: 22: 22:         public
23: 23: 23: 23: 23:         payable
24: 24: 24: 24: 24:     {
25: 25: 25: 25: 25:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
26: 26: 26: 26: 26:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28:         for (uint i = 0; i < _exchanges.length; i++) {
29: 29: 29: 29: 29:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
30: 30: 30: 30: 30:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
31: 31: 31: 31: 31:                 data[j - _datasIndexes[i]] = _datas[j];
32: 32: 32: 32: 32:             }
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34:             if (_throughToken != address(0) && _values[i] == 0) {
35: 35: 35: 35: 35:                 if (_throughToken.allowance(this, _exchanges[i]) == 0) {
36: 36: 36: 36: 36:                     _throughToken.approve(_exchanges[i], uint256(-1));
37: 37: 37: 37: 37:                 }
38: 38: 38: 38: 38:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
39: 39: 39: 39: 39:             } else {
40: 40: 40: 40: 40:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
41: 41: 41: 41: 41:             }
42: 42: 42: 42: 42:         }
43: 43: 43: 43: 43: 
44: 44: 44: 44: 44:         j = _mtkn.totalSupply(); 
45: 45: 45: 45: 45:         uint256 bestAmount = uint256(-1);
46: 46: 46: 46: 46:         for (i = _mtkn.tokensCount(); i > 0; i--) {
47: 47: 47: 47: 47:             ERC20 token = _mtkn.tokens(i - 1);
48: 48: 48: 48: 48:             if (token.allowance(this, _mtkn) == 0) {
49: 49: 49: 49: 49:                 token.approve(_mtkn, uint256(-1));
50: 50: 50: 50: 50:             }
51: 51: 51: 51: 51: 
52: 52: 52: 52: 52:             uint256 amount = j.mul(token.balanceOf(this)).div(token.balanceOf(_mtkn));
53: 53: 53: 53: 53:             if (amount < bestAmount) {
54: 54: 54: 54: 54:                 bestAmount = amount;
55: 55: 55: 55: 55:             }
56: 56: 56: 56: 56:         }
57: 57: 57: 57: 57: 
58: 58: 58: 58: 58:         require(bestAmount >= _minimumReturn, "buy: return value is too low");
59: 59: 59: 59: 59:         _mtkn.bundle(msg.sender, bestAmount);
60: 60: 60: 60: 60:         if (address(this).balance > 0) {
61: 61: 61: 61: 61:             msg.sender.transfer(address(this).balance);
62: 62: 62: 62: 62:         }
63: 63: 63: 63: 63:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
64: 64: 64: 64: 64:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
65: 65: 65: 65: 65:         }
66: 66: 66: 66: 66:     }
67: 67: 67: 67: 67: 
68: 68: 68: 68: 68:     function buyFirstTokensOnApprove(
69: 69: 69: 69: 69:         IMultiToken _mtkn,
70: 70: 70: 70: 70:         ERC20 _throughToken,
71: 71: 71: 71: 71:         address[] _exchanges,
72: 72: 72: 72: 72:         bytes _datas,
73: 73: 73: 73: 73:         uint[] _datasIndexes, 
74: 74: 74: 74: 74:         uint256[] _values
75: 75: 75: 75: 75:     )
76: 76: 76: 76: 76:         public
77: 77: 77: 77: 77:         payable
78: 78: 78: 78: 78:     {
79: 79: 79: 79: 79:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
80: 80: 80: 80: 80:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
81: 81: 81: 81: 81: 
82: 82: 82: 82: 82:         for (uint i = 0; i < _exchanges.length; i++) {
83: 83: 83: 83: 83:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
84: 84: 84: 84: 84:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
85: 85: 85: 85: 85:                 data[j - _datasIndexes[i]] = _datas[j];
86: 86: 86: 86: 86:             }
87: 87: 87: 87: 87: 
88: 88: 88: 88: 88:             if (_throughToken != address(0) && _values[i] == 0) {
89: 89: 89: 89: 89:                 if (_throughToken.allowance(this, _exchanges[i]) == 0) {
90: 90: 90: 90: 90:                     _throughToken.approve(_exchanges[i], uint256(-1));
91: 91: 91: 91: 91:                 }
92: 92: 92: 92: 92:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
93: 93: 93: 93: 93:             } else {
94: 94: 94: 94: 94:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
95: 95: 95: 95: 95:             }
96: 96: 96: 96: 96:         }
97: 97: 97: 97: 97: 
98: 98: 98: 98: 98:         uint tokensCount = _mtkn.tokensCount();
99: 99: 99: 99: 99:         uint256[] memory amounts = new uint256[](tokensCount);
100: 100: 100: 100: 100:         for (i = 0; i < tokensCount; i++) {
101: 101: 101: 101: 101:             ERC20 token = _mtkn.tokens(i);
102: 102: 102: 102: 102:             amounts[i] = token.balanceOf(this);
103: 103: 103: 103: 103:             if (token.allowance(this, _mtkn) == 0) {
104: 104: 104: 104: 104:                 token.approve(_mtkn, uint256(-1));
105: 105: 105: 105: 105:             }
106: 106: 106: 106: 106:         }
107: 107: 107: 107: 107: 
108: 108: 108: 108: 108:         _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
109: 109: 109: 109: 109:         if (address(this).balance > 0) {
110: 110: 110: 110: 110:             msg.sender.transfer(address(this).balance);
111: 111: 111: 111: 111:         }
112: 112: 112: 112: 112:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
113: 113: 113: 113: 113:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
114: 114: 114: 114: 114:         }
115: 115: 115: 115: 115:     }
116: 116: 116: 116: 116: }