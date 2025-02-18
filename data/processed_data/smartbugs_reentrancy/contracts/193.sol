1: 1: 1: 1: 1: pragma solidity ^0.4.24;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: 
8: 8: 8: 8: 8: 
9: 9: 9: 9: 9: library SafeMath {
10: 10: 10: 10: 10: 
11: 11: 11: 11: 11:   
12: 12: 12: 12: 12: 
13: 13: 13: 13: 13: 
14: 14: 14: 14: 14:   function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
15: 15: 15: 15: 15:     
16: 16: 16: 16: 16:     
17: 17: 17: 17: 17:     
18: 18: 18: 18: 18:     if (_a == 0) {
19: 19: 19: 19: 19:       return 0;
20: 20: 20: 20: 20:     }
21: 21: 21: 21: 21: 
22: 22: 22: 22: 22:     c = _a * _b;
23: 23: 23: 23: 23:     assert(c / _a == _b);
24: 24: 24: 24: 24:     return c;
25: 25: 25: 25: 25:   }
26: 26: 26: 26: 26: 
27: 27: 27: 27: 27:   
28: 28: 28: 28: 28: 
29: 29: 29: 29: 29: 
30: 30: 30: 30: 30:   function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
31: 31: 31: 31: 31:     
32: 32: 32: 32: 32:     
33: 33: 33: 33: 33:     
34: 34: 34: 34: 34:     return _a / _b;
35: 35: 35: 35: 35:   }
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37:   
38: 38: 38: 38: 38: 
39: 39: 39: 39: 39: 
40: 40: 40: 40: 40:   function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
41: 41: 41: 41: 41:     assert(_b <= _a);
42: 42: 42: 42: 42:     return _a - _b;
43: 43: 43: 43: 43:   }
44: 44: 44: 44: 44: 
45: 45: 45: 45: 45:   
46: 46: 46: 46: 46: 
47: 47: 47: 47: 47: 
48: 48: 48: 48: 48:   function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
49: 49: 49: 49: 49:     c = _a + _b;
50: 50: 50: 50: 50:     assert(c >= _a);
51: 51: 51: 51: 51:     return c;
52: 52: 52: 52: 52:   }
53: 53: 53: 53: 53: }
54: 54: 54: 54: 54: 
55: 55: 55: 55: 55: 
56: 56: 56: 56: 56: 
57: 57: 57: 57: 57: 
58: 58: 58: 58: 58: 
59: 59: 59: 59: 59: 
60: 60: 60: 60: 60: 
61: 61: 61: 61: 61: 
62: 62: 62: 62: 62: contract MultiChanger is CanReclaimToken {
63: 63: 63: 63: 63:     using SafeMath for uint256;
64: 64: 64: 64: 64:     using CheckedERC20 for ERC20;
65: 65: 65: 65: 65: 
66: 66: 66: 66: 66:     
67: 67: 67: 67: 67:     
68: 68: 68: 68: 68:     
69: 69: 69: 69: 69:     function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns (bool result) {
70: 70: 70: 70: 70:         
71: 71: 71: 71: 71:         assembly {
72: 72: 72: 72: 72:             let x := mload(0x40)   
73: 73: 73: 73: 73:             let d := add(data, 32) 
74: 74: 74: 74: 74:             result := call(
75: 75: 75: 75: 75:                 sub(gas, 34710),   
76: 76: 76: 76: 76:                                    
77: 77: 77: 77: 77:                                    
78: 78: 78: 78: 78:                 destination,
79: 79: 79: 79: 79:                 value,
80: 80: 80: 80: 80:                 add(d, dataOffset),
81: 81: 81: 81: 81:                 dataLength,        
82: 82: 82: 82: 82:                 x,
83: 83: 83: 83: 83:                 0                  
84: 84: 84: 84: 84:             )
85: 85: 85: 85: 85:         }
86: 86: 86: 86: 86:     }
87: 87: 87: 87: 87: 
88: 88: 88: 88: 88:     function change(bytes _callDatas, uint[] _starts) public payable { 
89: 89: 89: 89: 89:         for (uint i = 0; i < _starts.length - 1; i++) {
90: 90: 90: 90: 90:             require(externalCall(this, 0, _callDatas, _starts[i], _starts[i + 1] - _starts[i]));
91: 91: 91: 91: 91:         }
92: 92: 92: 92: 92:     }
93: 93: 93: 93: 93: 
94: 94: 94: 94: 94:     function sendEthValue(address _target, bytes _data, uint256 _value) external {
95: 95: 95: 95: 95:         
96: 96: 96: 96: 96:         require(_target.call.value(_value)(_data));
97: 97: 97: 97: 97:     }
98: 98: 98: 98: 98: 
99: 99: 99: 99: 99:     function sendEthProportion(address _target, bytes _data, uint256 _mul, uint256 _div) external {
100: 100: 100: 100: 100:         uint256 value = address(this).balance.mul(_mul).div(_div);
101: 101: 101: 101: 101:         
102: 102: 102: 102: 102:         require(_target.call.value(value)(_data));
103: 103: 103: 103: 103:     }
104: 104: 104: 104: 104: 
105: 105: 105: 105: 105:     function approveTokenAmount(address _target, bytes _data, ERC20 _fromToken, uint256 _amount) external {
106: 106: 106: 106: 106:         if (_fromToken.allowance(this, _target) != 0) {
107: 107: 107: 107: 107:             _fromToken.asmApprove(_target, 0);
108: 108: 108: 108: 108:         }
109: 109: 109: 109: 109:         _fromToken.asmApprove(_target, _amount);
110: 110: 110: 110: 110:         
111: 111: 111: 111: 111:         require(_target.call(_data));
112: 112: 112: 112: 112:     }
113: 113: 113: 113: 113: 
114: 114: 114: 114: 114:     function approveTokenProportion(address _target, bytes _data, ERC20 _fromToken, uint256 _mul, uint256 _div) external {
115: 115: 115: 115: 115:         uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);
116: 116: 116: 116: 116:         if (_fromToken.allowance(this, _target) != 0) {
117: 117: 117: 117: 117:             _fromToken.asmApprove(_target, 0);
118: 118: 118: 118: 118:         }
119: 119: 119: 119: 119:         _fromToken.asmApprove(_target, amount);
120: 120: 120: 120: 120:         
121: 121: 121: 121: 121:         require(_target.call(_data));
122: 122: 122: 122: 122:     }
123: 123: 123: 123: 123: 
124: 124: 124: 124: 124:     function transferTokenAmount(address _target, bytes _data, ERC20 _fromToken, uint256 _amount) external {
125: 125: 125: 125: 125:         _fromToken.asmTransfer(_target, _amount);
126: 126: 126: 126: 126:         if (_target != address(0)) {
127: 127: 127: 127: 127:             
128: 128: 128: 128: 128:             require(_target.call(_data));
129: 129: 129: 129: 129:         }
130: 130: 130: 130: 130:     }
131: 131: 131: 131: 131: 
132: 132: 132: 132: 132:     function transferTokenProportion(address _target, bytes _data, ERC20 _fromToken, uint256 _mul, uint256 _div) external {
133: 133: 133: 133: 133:         uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);
134: 134: 134: 134: 134:         _fromToken.asmTransfer(_target, amount);
135: 135: 135: 135: 135:         if (_target != address(0)) {
136: 136: 136: 136: 136:             
137: 137: 137: 137: 137:             require(_target.call(_data));
138: 138: 138: 138: 138:         }
139: 139: 139: 139: 139:     }
140: 140: 140: 140: 140: 
141: 141: 141: 141: 141:     
142: 142: 142: 142: 142: 
143: 143: 143: 143: 143:     function multitokenChangeAmount(IMultiToken _mtkn, ERC20 _fromToken, ERC20 _toToken, uint256 _minReturn, uint256 _amount) external {
144: 144: 144: 144: 144:         if (_fromToken.allowance(this, _mtkn) == 0) {
145: 145: 145: 145: 145:             _fromToken.asmApprove(_mtkn, uint256(-1));
146: 146: 146: 146: 146:         }
147: 147: 147: 147: 147:         _mtkn.change(_fromToken, _toToken, _amount, _minReturn);
148: 148: 148: 148: 148:     }
149: 149: 149: 149: 149: 
150: 150: 150: 150: 150:     function multitokenChangeProportion(IMultiToken _mtkn, ERC20 _fromToken, ERC20 _toToken, uint256 _minReturn, uint256 _mul, uint256 _div) external {
151: 151: 151: 151: 151:         uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);
152: 152: 152: 152: 152:         this.multitokenChangeAmount(_mtkn, _fromToken, _toToken, _minReturn, amount);
153: 153: 153: 153: 153:     }
154: 154: 154: 154: 154: 
155: 155: 155: 155: 155:     
156: 156: 156: 156: 156: 
157: 157: 157: 157: 157:     function withdrawEtherTokenAmount(IEtherToken _etherToken, uint256 _amount) external {
158: 158: 158: 158: 158:         _etherToken.withdraw(_amount);
159: 159: 159: 159: 159:     }
160: 160: 160: 160: 160: 
161: 161: 161: 161: 161:     function withdrawEtherTokenProportion(IEtherToken _etherToken, uint256 _mul, uint256 _div) external {
162: 162: 162: 162: 162:         uint256 amount = _etherToken.balanceOf(this).mul(_mul).div(_div);
163: 163: 163: 163: 163:         _etherToken.withdraw(amount);
164: 164: 164: 164: 164:     }
165: 165: 165: 165: 165: 
166: 166: 166: 166: 166:     
167: 167: 167: 167: 167: 
168: 168: 168: 168: 168:     function bancorSendEthValue(IBancorNetwork _bancor, address[] _path, uint256 _value) external {
169: 169: 169: 169: 169:         _bancor.convert.value(_value)(_path, _value, 1);
170: 170: 170: 170: 170:     }
171: 171: 171: 171: 171: 
172: 172: 172: 172: 172:     function bancorSendEthProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
173: 173: 173: 173: 173:         uint256 value = address(this).balance.mul(_mul).div(_div);
174: 174: 174: 174: 174:         _bancor.convert.value(value)(_path, value, 1);
175: 175: 175: 175: 175:     }
176: 176: 176: 176: 176: 
177: 177: 177: 177: 177:     function bancorApproveTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {
178: 178: 178: 178: 178:         if (ERC20(_path[0]).allowance(this, _bancor) == 0) {
179: 179: 179: 179: 179:             ERC20(_path[0]).asmApprove(_bancor, uint256(-1));
180: 180: 180: 180: 180:         }
181: 181: 181: 181: 181:         _bancor.claimAndConvert(_path, _amount, 1);
182: 182: 182: 182: 182:     }
183: 183: 183: 183: 183: 
184: 184: 184: 184: 184:     function bancorApproveTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
185: 185: 185: 185: 185:         uint256 amount = ERC20(_path[0]).balanceOf(this).mul(_mul).div(_div);
186: 186: 186: 186: 186:         if (ERC20(_path[0]).allowance(this, _bancor) == 0) {
187: 187: 187: 187: 187:             ERC20(_path[0]).asmApprove(_bancor, uint256(-1));
188: 188: 188: 188: 188:         }
189: 189: 189: 189: 189:         _bancor.claimAndConvert(_path, amount, 1);
190: 190: 190: 190: 190:     }
191: 191: 191: 191: 191: 
192: 192: 192: 192: 192:     function bancorTransferTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {
193: 193: 193: 193: 193:         ERC20(_path[0]).asmTransfer(_bancor, _amount);
194: 194: 194: 194: 194:         _bancor.convert(_path, _amount, 1);
195: 195: 195: 195: 195:     }
196: 196: 196: 196: 196: 
197: 197: 197: 197: 197:     function bancorTransferTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
198: 198: 198: 198: 198:         uint256 amount = ERC20(_path[0]).balanceOf(this).mul(_mul).div(_div);
199: 199: 199: 199: 199:         ERC20(_path[0]).asmTransfer(_bancor, amount);
200: 200: 200: 200: 200:         _bancor.convert(_path, amount, 1);
201: 201: 201: 201: 201:     }
202: 202: 202: 202: 202: 
203: 203: 203: 203: 203:     function bancorAlreadyTransferedTokenAmount(IBancorNetwork _bancor, address[] _path, uint256 _amount) external {
204: 204: 204: 204: 204:         _bancor.convert(_path, _amount, 1);
205: 205: 205: 205: 205:     }
206: 206: 206: 206: 206: 
207: 207: 207: 207: 207:     function bancorAlreadyTransferedTokenProportion(IBancorNetwork _bancor, address[] _path, uint256 _mul, uint256 _div) external {
208: 208: 208: 208: 208:         uint256 amount = ERC20(_path[0]).balanceOf(_bancor).mul(_mul).div(_div);
209: 209: 209: 209: 209:         _bancor.convert(_path, amount, 1);
210: 210: 210: 210: 210:     }
211: 211: 211: 211: 211: 
212: 212: 212: 212: 212:     
213: 213: 213: 213: 213: 
214: 214: 214: 214: 214:     function kyberSendEthProportion(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _mul, uint256 _div) external {
215: 215: 215: 215: 215:         uint256 value = address(this).balance.mul(_mul).div(_div);
216: 216: 216: 216: 216:         _kyber.trade.value(value)(
217: 217: 217: 217: 217:             _fromToken,
218: 218: 218: 218: 218:             value,
219: 219: 219: 219: 219:             _toToken,
220: 220: 220: 220: 220:             this,
221: 221: 221: 221: 221:             1 << 255,
222: 222: 222: 222: 222:             0,
223: 223: 223: 223: 223:             0
224: 224: 224: 224: 224:         );
225: 225: 225: 225: 225:     }
226: 226: 226: 226: 226: 
227: 227: 227: 227: 227:     function kyberApproveTokenAmount(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _amount) external {
228: 228: 228: 228: 228:         if (_fromToken.allowance(this, _kyber) == 0) {
229: 229: 229: 229: 229:             _fromToken.asmApprove(_kyber, uint256(-1));
230: 230: 230: 230: 230:         }
231: 231: 231: 231: 231:         _kyber.trade(
232: 232: 232: 232: 232:             _fromToken,
233: 233: 233: 233: 233:             _amount,
234: 234: 234: 234: 234:             _toToken,
235: 235: 235: 235: 235:             this,
236: 236: 236: 236: 236:             1 << 255,
237: 237: 237: 237: 237:             0,
238: 238: 238: 238: 238:             0
239: 239: 239: 239: 239:         );
240: 240: 240: 240: 240:     }
241: 241: 241: 241: 241: 
242: 242: 242: 242: 242:     function kyberApproveTokenProportion(IKyberNetworkProxy _kyber, ERC20 _fromToken, address _toToken, uint256 _mul, uint256 _div) external {
243: 243: 243: 243: 243:         uint256 amount = _fromToken.balanceOf(this).mul(_mul).div(_div);
244: 244: 244: 244: 244:         this.kyberApproveTokenAmount(_kyber, _fromToken, _toToken, amount);
245: 245: 245: 245: 245:     }
246: 246: 246: 246: 246: }
247: 247: 247: 247: 247: 
248: 248: 248: 248: 248: 
249: 249: 249: 249: 249: 