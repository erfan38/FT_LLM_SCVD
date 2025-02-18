1: pragma solidity ^0.4.24;
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: 
10: contract MultiBuyer is CanReclaimToken {
11:     using SafeMath for uint256;
12: 
13:     function buyOnApprove(
14:         IMultiToken _mtkn,
15:         uint256 _minimumReturn,
16:         ERC20 _throughToken,
17:         address[] _exchanges,
18:         bytes _datas,
19:         uint[] _datasIndexes, 
20:         uint256[] _values
21:     )
22:         public
23:         payable
24:     {
25:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
26:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
27: 
28:         for (uint i = 0; i < _exchanges.length; i++) {
29:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
30:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
31:                 data[j - _datasIndexes[i]] = _datas[j];
32:             }
33: 
34:             if (_throughToken != address(0) && i > 0) {
35:                 if (_throughToken.allowance(_exchanges[i], this) == 0) {
36:                     _throughToken.approve(_exchanges[i], uint256(-1));
37:                 }
38:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
39:             } else {
40:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
41:             }
42:         }
43: 
44:         j = _mtkn.totalSupply(); 
45:         uint256 bestAmount = uint256(-1);
46:         for (i = _mtkn.tokensCount(); i > 0; i--) {
47:             ERC20 token = _mtkn.tokens(i - 1);
48:             token.approve(_mtkn, 0);
49:             token.approve(_mtkn, token.balanceOf(this));
50: 
51:             uint256 amount = j.mul(token.balanceOf(this)).div(token.balanceOf(_mtkn));
52:             if (amount < bestAmount) {
53:                 bestAmount = amount;
54:             }
55:         }
56: 
57:         require(bestAmount >= _minimumReturn, "buy: return value is too low");
58:         _mtkn.bundle(msg.sender, bestAmount);
59:         if (address(this).balance > 0) {
60:             msg.sender.transfer(address(this).balance);
61:         }
62:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
63:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
64:         }
65:     }
66: 
67:     function buyOnTransfer(
68:         IMultiToken _mtkn,
69:         uint256 _minimumReturn,
70:         ERC20 _throughToken,
71:         address[] _exchanges,
72:         bytes _datas,
73:         uint[] _datasIndexes, 
74:         uint256[] _values
75:     )
76:         public
77:         payable
78:     {
79:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
80:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
81: 
82:         for (uint i = 0; i < _exchanges.length; i++) {
83:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
84:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
85:                 data[j - _datasIndexes[i]] = _datas[j];
86:             }
87: 
88:             if (_throughToken != address(0) && i > 0) {
89:                 _throughToken.transfer(_exchanges[i], _values[i]);
90:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
91:             } else {
92:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
93:             }
94:         }
95: 
96:         j = _mtkn.totalSupply(); 
97:         uint256 bestAmount = uint256(-1);
98:         for (i = _mtkn.tokensCount(); i > 0; i--) {
99:             ERC20 token = _mtkn.tokens(i - 1);
100:             token.approve(_mtkn, 0);
101:             token.approve(_mtkn, token.balanceOf(this));
102: 
103:             uint256 amount = j.mul(token.balanceOf(this)).div(token.balanceOf(_mtkn));
104:             if (amount < bestAmount) {
105:                 bestAmount = amount;
106:             }
107:         }
108: 
109:         require(bestAmount >= _minimumReturn, "buy: return value is too low");
110:         _mtkn.bundle(msg.sender, bestAmount);
111:         if (address(this).balance > 0) {
112:             msg.sender.transfer(address(this).balance);
113:         }
114:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
115:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
116:         }
117:     }
118: 
119:     function buyFirstTokensOnApprove(
120:         IMultiToken _mtkn,
121:         ERC20 _throughToken,
122:         address[] _exchanges,
123:         bytes _datas,
124:         uint[] _datasIndexes, 
125:         uint256[] _values
126:     )
127:         public
128:         payable
129:     {
130:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
131:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
132: 
133:         for (uint i = 0; i < _exchanges.length; i++) {
134:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
135:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
136:                 data[j - _datasIndexes[i]] = _datas[j];
137:             }
138: 
139:             if (_throughToken != address(0) && i > 0) {
140:                 if (_throughToken.allowance(_exchanges[i], this) == 0) {
141:                     _throughToken.approve(_exchanges[i], uint256(-1));
142:                 }
143:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
144:             } else {
145:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
146:             }
147:         }
148: 
149:         uint tokensCount = _mtkn.tokensCount();
150:         uint256[] memory amounts = new uint256[](tokensCount);
151:         for (i = 0; i < tokensCount; i++) {
152:             ERC20 token = _mtkn.tokens(i);
153:             amounts[i] = token.balanceOf(this);
154:             token.approve(_mtkn, 0);
155:             token.approve(_mtkn, amounts[i]);
156:         }
157: 
158:         _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
159:         if (address(this).balance > 0) {
160:             msg.sender.transfer(address(this).balance);
161:         }
162:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
163:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
164:         }
165:     }
166: 
167:     function buyFirstTokensOnTransfer(
168:         IMultiToken _mtkn,
169:         ERC20 _throughToken,
170:         address[] _exchanges,
171:         bytes _datas,
172:         uint[] _datasIndexes, 
173:         uint256[] _values
174:     )
175:         public
176:         payable
177:     {
178:         require(_datasIndexes.length == _exchanges.length + 1, "buy: _datasIndexes should start with 0 and end with LENGTH");
179:         require(_values.length == _exchanges.length, "buy: _values should have the same length as _exchanges");
180: 
181:         for (uint i = 0; i < _exchanges.length; i++) {
182:             bytes memory data = new bytes(_datasIndexes[i + 1] - _datasIndexes[i]);
183:             for (uint j = _datasIndexes[i]; j < _datasIndexes[i + 1]; j++) {
184:                 data[j - _datasIndexes[i]] = _datas[j];
185:             }
186: 
187:             if (_throughToken != address(0) && i > 0) {
188:                 _throughToken.transfer(_exchanges[i], _values[i]);
189:                 require(_exchanges[i].call(data), "buy: exchange arbitrary call failed");
190:             } else {
191:                 require(_exchanges[i].call.value(_values[i])(data), "buy: exchange arbitrary call failed");
192:             }
193:         }
194: 
195:         uint tokensCount = _mtkn.tokensCount();
196:         uint256[] memory amounts = new uint256[](tokensCount);
197:         for (i = 0; i < tokensCount; i++) {
198:             ERC20 token = _mtkn.tokens(i);
199:             amounts[i] = token.balanceOf(this);
200:             token.approve(_mtkn, 0);
201:             token.approve(_mtkn, amounts[i]);
202:         }
203: 
204:         _mtkn.bundleFirstTokens(msg.sender, msg.value.mul(1000), amounts);
205:         if (address(this).balance > 0) {
206:             msg.sender.transfer(address(this).balance);
207:         }
208:         if (_throughToken != address(0) && _throughToken.balanceOf(this) > 0) {
209:             _throughToken.transfer(msg.sender, _throughToken.balanceOf(this));
210:         }
211:     }
212: }