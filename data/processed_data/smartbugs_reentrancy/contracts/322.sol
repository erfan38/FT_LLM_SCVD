1: 1: pragma solidity ^0.4.24;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: contract MultiBuyer is CanReclaimToken {
11: 11:     using SafeMath for uint256;
12: 12: 
13: 13:     function buyOnApprove(
14: 14:         IMultiToken _mtkn,
15: 15:         uint256 _minimumReturn,
16: 16:         ERC20 _throughToken,
17: 17:         address[] _exchanges,
18: 18:         bytes _datas,
19: 19:         uint[] _datasIndexes, 
20: 20:         uint256[] _values
21: 21:     )
22: 22:         public
23: 23:         payable
24: 24:     {
25: 25:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
26: 26:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
27: 27: 
28: 28:         for (uint i = 0; i < _exchanges.length; i++) {
29: 29:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
30: 30:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
31: 31:                 data[j - _datasIndexes[i]] = _datas[j];
32: 32:             }
33: 33: 
34: 34:             if (_throughToken != address(0) && i > 0) {
35: 35:                 if (_throughToken.allowance(_exchanges[i], this) == 0) {
36: 36:                     _throughToken.approve(_exchanges[i], uint256(-1));
37: 37:                 }
38: 38:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
39: 39:             } else {
40: 40:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
41: 41:             }
42: 42:         }
43: 43: 
44: 44:         j = _mtkn.totalSupply(); 
45: 45:         uint256 bestAmount = uint256(-1);
46: 46:         for (i = _mtkn.tokensCount(); i > 0; i--) {
47: 47:             ERC20 token = _mtkn.tokens(i - 1);
48: 48:             token.approve(_mtkn, 0);
49: 49:             token.approve(_mtkn, token.balanceOf(this));
50: 50: 
51: 51:             uint256 amount = j.mul(token.balanceOf(this)).div(token.balanceOf(_mtkn));
52: 52:             if (amount < bestAmount) {
53: 53:                 bestAmount = amount;
54: 54:             }
55: 55:         }
56: 56: 
57: 57:         require(bestAmount >= _minimumReturn, "buy: return value is too low");
58: 58:         _mtkn.bundle(msg.sender, bestAmount);
59: 59:         if (address(this).balance > 0) {
60: 60:             msg.sender.transfer(address(this).balance);
61: 61:         }
62: 62:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
63: 63:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
64: 64:         }
65: 65:     }
66: 66: 
67: 67:     function buyOnTransfer(
68: 68:         IMultiToken _mtkn,
69: 69:         uint256 _minimumReturn,
70: 70:         ERC20 _throughToken,
71: 71:         address[] _exchanges,
72: 72:         bytes _datas,
73: 73:         uint[] _datasIndexes, 
74: 74:         uint256[] _values
75: 75:     )
76: 76:         public
77: 77:         payable
78: 78:     {
79: 79:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
80: 80:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
81: 81: 
82: 82:         for (uint i = 0; i < _exchanges.length; i++) {
83: 83:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
84: 84:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
85: 85:                 data[j - _datasIndexes[i]] = _datas[j];
86: 86:             }
87: 87: 
88: 88:             if (_throughToken != address(0) && i > 0) {
89: 89:                 _throughToken.transfer(_exchanges[i], _values[i]);
90: 90:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
91: 91:             } else {
92: 92:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
93: 93:             }
94: 94:         }
95: 95: 
96: 96:         j = _mtkn.totalSupply(); 
97: 97:         uint256 bestAmount = uint256(-1);
98: 98:         for (i = _mtkn.tokensCount(); i > 0; i--) {
99: 99:             ERC20 token = _mtkn.tokens(i - 1);
100: 100:             token.approve(_mtkn, 0);
101: 101:             token.approve(_mtkn, token.balanceOf(this));
102: 102: 
103: 103:             uint256 amount = j.mul(token.balanceOf(this)).div(token.balanceOf(_mtkn));
104: 104:             if (amount < bestAmount) {
105: 105:                 bestAmount = amount;
106: 106:             }
107: 107:         }
108: 108: 
109: 109:         require(bestAmount >= _minimumReturn, "buy: return value is too low");
110: 110:         _mtkn.bundle(msg.sender, bestAmount);
111: 111:         if (address(this).balance > 0) {
112: 112:             msg.sender.transfer(address(this).balance);
113: 113:         }
114: 114:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
115: 115:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
116: 116:         }
117: 117:     }
118: 118: 
119: 119:     function buyFirstTokensOnApprove(
120: 120:         IMultiToken _mtkn,
121: 121:         ERC20 _throughToken,
122: 122:         address[] _exchanges,
123: 123:         bytes _datas,
124: 124:         uint[] _datasIndexes, 
125: 125:         uint256[] _values
126: 126:     )
127: 127:         public
128: 128:         payable
129: 129:     {
130: 130:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
131: 131:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
132: 132: 
133: 133:         for (uint i = 0; i < _exchanges.length; i++) {
134: 134:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
135: 135:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
136: 136:                 data[j - _datasIndexes[i]] = _datas[j];
137: 137:             }
138: 138: 
139: 139:             if (_throughToken != address(0) && i > 0) {
140: 140:                 if (_throughToken.allowance(_exchanges[i], this) == 0) {
141: 141:                     _throughToken.approve(_exchanges[i], uint256(-1));
142: 142:                 }
143: 143:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
144: 144:             } else {
145: 145:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
146: 146:             }
147: 147:         }
148: 148: 
149: 149:         uint tokensCount = _mtkn.tokensCount();
150: 150:         uint256[] memory amounts = new uint256[](tokensCount);
151: 151:         for (i = 0; i < tokensCount; i++) {
152: 152:             ERC20 token = _mtkn.tokens(i);
153: 153:             amounts[i] = token.balanceOf(this);
154: 154:             token.approve(_mtkn, 0);
155: 155:             token.approve(_mtkn, amounts[i]);
156: 156:         }
157: 157: 
158: 158:         _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
159: 159:         if (address(this).balance > 0) {
160: 160:             msg.sender.transfer(address(this).balance);
161: 161:         }
162: 162:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
163: 163:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
164: 164:         }
165: 165:     }
166: 166: 
167: 167:     function buyFirstTokensOnTransfer(
168: 168:         IMultiToken _mtkn,
169: 169:         ERC20 _throughToken,
170: 170:         address[] _exchanges,
171: 171:         bytes _datas,
172: 172:         uint[] _datasIndexes, 
173: 173:         uint256[] _values
174: 174:     )
175: 175:         public
176: 176:         payable
177: 177:     {
178: 178:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
179: 179:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
180: 180: 
181: 181:         for (uint i = 0; i < _exchanges.length; i++) {
182: 182:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
183: 183:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
184: 184:                 data[j - _datasIndexes[i]] = _datas[j];
185: 185:             }
186: 186: 
187: 187:             if (_throughToken != address(0) && i > 0) {
188: 188:                 _throughToken.transfer(_exchanges[i], _values[i]);
189: 189:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
190: 190:             } else {
191: 191:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
192: 192:             }
193: 193:         }
194: 194: 
195: 195:         uint tokensCount = _mtkn.tokensCount();
196: 196:         uint256[] memory amounts = new uint256[](tokensCount);
197: 197:         for (i = 0; i < tokensCount; i++) {
198: 198:             ERC20 token = _mtkn.tokens(i);
199: 199:             amounts[i] = token.balanceOf(this);
200: 200:             token.approve(_mtkn, 0);
201: 201:             token.approve(_mtkn, amounts[i]);
202: 202:         }
203: 203: 
204: 204:         _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
205: 205:         if (address(this).balance > 0) {
206: 206:             msg.sender.transfer(address(this).balance);
207: 207:         }
208: 208:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
209: 209:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
210: 210:         }
211: 211:     }
212: 212: }