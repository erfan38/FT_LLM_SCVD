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
88: 88: 88: 88: 88:     function change(bytes callDatas, uint[] starts) public payable { 
89: 89: 89: 89: 89:         for (uint i = 0; i < starts.length - 1; i++) {
90: 90: 90: 90: 90:             require(externalCall(this, 0, callDatas, starts[i], starts[i + 1] - starts[i]));
91: 91: 91: 91: 91:         }
92: 92: 92: 92: 92:     }
93: 93: 93: 93: 93: 
94: 94: 94: 94: 94:     function sendEthValue(address target, bytes data, uint256 value) external {
95: 95: 95: 95: 95:         
96: 96: 96: 96: 96:         require(target.call.value(value)(data));
97: 97: 97: 97: 97:     }
98: 98: 98: 98: 98: 
99: 99: 99: 99: 99:     function sendEthProportion(address target, bytes data, uint256 mul, uint256 div) external {
100: 100: 100: 100: 100:         uint256 value = address(this).balance.mul(mul).div(div);
101: 101: 101: 101: 101:         
102: 102: 102: 102: 102:         require(target.call.value(value)(data));
103: 103: 103: 103: 103:     }
104: 104: 104: 104: 104: 
105: 105: 105: 105: 105:     function approveTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
106: 106: 106: 106: 106:         if (fromToken.allowance(this, target) != 0) {
107: 107: 107: 107: 107:             fromToken.asmApprove(target, 0);
108: 108: 108: 108: 108:         }
109: 109: 109: 109: 109:         fromToken.asmApprove(target, amount);
110: 110: 110: 110: 110:         
111: 111: 111: 111: 111:         require(target.call(data));
112: 112: 112: 112: 112:     }
113: 113: 113: 113: 113: 
114: 114: 114: 114: 114:     function approveTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
115: 115: 115: 115: 115:         uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
116: 116: 116: 116: 116:         if (fromToken.allowance(this, target) != 0) {
117: 117: 117: 117: 117:             fromToken.asmApprove(target, 0);
118: 118: 118: 118: 118:         }
119: 119: 119: 119: 119:         fromToken.asmApprove(target, amount);
120: 120: 120: 120: 120:         
121: 121: 121: 121: 121:         require(target.call(data));
122: 122: 122: 122: 122:     }
123: 123: 123: 123: 123: 
124: 124: 124: 124: 124:     function transferTokenAmount(address target, bytes data, ERC20 fromToken, uint256 amount) external {
125: 125: 125: 125: 125:         require(fromToken.asmTransfer(target, amount));
126: 126: 126: 126: 126:         if (data.length != 0) {
127: 127: 127: 127: 127:             
128: 128: 128: 128: 128:             require(target.call(data));
129: 129: 129: 129: 129:         }
130: 130: 130: 130: 130:     }
131: 131: 131: 131: 131: 
132: 132: 132: 132: 132:     function transferTokenProportion(address target, bytes data, ERC20 fromToken, uint256 mul, uint256 div) external {
133: 133: 133: 133: 133:         uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
134: 134: 134: 134: 134:         require(fromToken.asmTransfer(target, amount));
135: 135: 135: 135: 135:         if (data.length != 0) {
136: 136: 136: 136: 136:             
137: 137: 137: 137: 137:             require(target.call(data));
138: 138: 138: 138: 138:         }
139: 139: 139: 139: 139:     }
140: 140: 140: 140: 140: 
141: 141: 141: 141: 141:     function transferTokenProportionToOrigin(ERC20 token, uint256 mul, uint256 div) external {
142: 142: 142: 142: 142:         uint256 amount = token.balanceOf(this).mul(mul).div(div);
143: 143: 143: 143: 143:         
144: 144: 144: 144: 144:         require(token.asmTransfer(tx.origin, amount));
145: 145: 145: 145: 145:     }
146: 146: 146: 146: 146: 
147: 147: 147: 147: 147:     
148: 148: 148: 148: 148: 
149: 149: 149: 149: 149:     function multitokenChangeAmount(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 amount) external {
150: 150: 150: 150: 150:         if (fromToken.allowance(this, mtkn) == 0) {
151: 151: 151: 151: 151:             fromToken.asmApprove(mtkn, uint256(-1));
152: 152: 152: 152: 152:         }
153: 153: 153: 153: 153:         mtkn.change(fromToken, toToken, amount, minReturn);
154: 154: 154: 154: 154:     }
155: 155: 155: 155: 155: 
156: 156: 156: 156: 156:     function multitokenChangeProportion(IMultiToken mtkn, ERC20 fromToken, ERC20 toToken, uint256 minReturn, uint256 mul, uint256 div) external {
157: 157: 157: 157: 157:         uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
158: 158: 158: 158: 158:         this.multitokenChangeAmount(mtkn, fromToken, toToken, minReturn, amount);
159: 159: 159: 159: 159:     }
160: 160: 160: 160: 160: 
161: 161: 161: 161: 161:     
162: 162: 162: 162: 162: 
163: 163: 163: 163: 163:     function withdrawEtherTokenAmount(IEtherToken etherToken, uint256 amount) external {
164: 164: 164: 164: 164:         etherToken.withdraw(amount);
165: 165: 165: 165: 165:     }
166: 166: 166: 166: 166: 
167: 167: 167: 167: 167:     function withdrawEtherTokenProportion(IEtherToken etherToken, uint256 mul, uint256 div) external {
168: 168: 168: 168: 168:         uint256 amount = etherToken.balanceOf(this).mul(mul).div(div);
169: 169: 169: 169: 169:         etherToken.withdraw(amount);
170: 170: 170: 170: 170:     }
171: 171: 171: 171: 171: 
172: 172: 172: 172: 172:     
173: 173: 173: 173: 173: 
174: 174: 174: 174: 174:     function bancorSendEthValue(IBancorNetwork bancor, address[] path, uint256 value) external {
175: 175: 175: 175: 175:         bancor.convert.value(value)(path, value, 1);
176: 176: 176: 176: 176:     }
177: 177: 177: 177: 177: 
178: 178: 178: 178: 178:     function bancorSendEthProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
179: 179: 179: 179: 179:         uint256 value = address(this).balance.mul(mul).div(div);
180: 180: 180: 180: 180:         bancor.convert.value(value)(path, value, 1);
181: 181: 181: 181: 181:     }
182: 182: 182: 182: 182: 
183: 183: 183: 183: 183:     function bancorApproveTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
184: 184: 184: 184: 184:         if (ERC20(path[0]).allowance(this, bancor) == 0) {
185: 185: 185: 185: 185:             ERC20(path[0]).asmApprove(bancor, uint256(-1));
186: 186: 186: 186: 186:         }
187: 187: 187: 187: 187:         bancor.claimAndConvert(path, amount, 1);
188: 188: 188: 188: 188:     }
189: 189: 189: 189: 189: 
190: 190: 190: 190: 190:     function bancorApproveTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
191: 191: 191: 191: 191:         uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
192: 192: 192: 192: 192:         if (ERC20(path[0]).allowance(this, bancor) == 0) {
193: 193: 193: 193: 193:             ERC20(path[0]).asmApprove(bancor, uint256(-1));
194: 194: 194: 194: 194:         }
195: 195: 195: 195: 195:         bancor.claimAndConvert(path, amount, 1);
196: 196: 196: 196: 196:     }
197: 197: 197: 197: 197: 
198: 198: 198: 198: 198:     function bancorTransferTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
199: 199: 199: 199: 199:         ERC20(path[0]).asmTransfer(bancor, amount);
200: 200: 200: 200: 200:         bancor.convert(path, amount, 1);
201: 201: 201: 201: 201:     }
202: 202: 202: 202: 202: 
203: 203: 203: 203: 203:     function bancorTransferTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
204: 204: 204: 204: 204:         uint256 amount = ERC20(path[0]).balanceOf(this).mul(mul).div(div);
205: 205: 205: 205: 205:         ERC20(path[0]).asmTransfer(bancor, amount);
206: 206: 206: 206: 206:         bancor.convert(path, amount, 1);
207: 207: 207: 207: 207:     }
208: 208: 208: 208: 208: 
209: 209: 209: 209: 209:     function bancorAlreadyTransferedTokenAmount(IBancorNetwork bancor, address[] path, uint256 amount) external {
210: 210: 210: 210: 210:         bancor.convert(path, amount, 1);
211: 211: 211: 211: 211:     }
212: 212: 212: 212: 212: 
213: 213: 213: 213: 213:     function bancorAlreadyTransferedTokenProportion(IBancorNetwork bancor, address[] path, uint256 mul, uint256 div) external {
214: 214: 214: 214: 214:         uint256 amount = ERC20(path[0]).balanceOf(bancor).mul(mul).div(div);
215: 215: 215: 215: 215:         bancor.convert(path, amount, 1);
216: 216: 216: 216: 216:     }
217: 217: 217: 217: 217: 
218: 218: 218: 218: 218:     
219: 219: 219: 219: 219: 
220: 220: 220: 220: 220:     function kyberSendEthProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
221: 221: 221: 221: 221:         uint256 value = address(this).balance.mul(mul).div(div);
222: 222: 222: 222: 222:         kyber.trade.value(value)(
223: 223: 223: 223: 223:             fromToken,
224: 224: 224: 224: 224:             value,
225: 225: 225: 225: 225:             toToken,
226: 226: 226: 226: 226:             this,
227: 227: 227: 227: 227:             1 << 255,
228: 228: 228: 228: 228:             0,
229: 229: 229: 229: 229:             0
230: 230: 230: 230: 230:         );
231: 231: 231: 231: 231:     }
232: 232: 232: 232: 232: 
233: 233: 233: 233: 233:     function kyberApproveTokenAmount(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 amount) external {
234: 234: 234: 234: 234:         if (fromToken.allowance(this, kyber) == 0) {
235: 235: 235: 235: 235:             fromToken.asmApprove(kyber, uint256(-1));
236: 236: 236: 236: 236:         }
237: 237: 237: 237: 237:         kyber.trade(
238: 238: 238: 238: 238:             fromToken,
239: 239: 239: 239: 239:             amount,
240: 240: 240: 240: 240:             toToken,
241: 241: 241: 241: 241:             this,
242: 242: 242: 242: 242:             1 << 255,
243: 243: 243: 243: 243:             0,
244: 244: 244: 244: 244:             0
245: 245: 245: 245: 245:         );
246: 246: 246: 246: 246:     }
247: 247: 247: 247: 247: 
248: 248: 248: 248: 248:     function kyberApproveTokenProportion(IKyberNetworkProxy kyber, ERC20 fromToken, address toToken, uint256 mul, uint256 div) external {
249: 249: 249: 249: 249:         uint256 amount = fromToken.balanceOf(this).mul(mul).div(div);
250: 250: 250: 250: 250:         this.kyberApproveTokenAmount(kyber, fromToken, toToken, amount);
251: 251: 251: 251: 251:     }
252: 252: 252: 252: 252: }