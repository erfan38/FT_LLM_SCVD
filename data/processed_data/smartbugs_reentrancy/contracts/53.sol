1: 1: 1: 1: 1: contract MultiAsset {
2: 2: 2: 2: 2:     function isCreated(bytes32 _symbol) constant returns(bool);
3: 3: 3: 3: 3:     function owner(bytes32 _symbol) constant returns(address);
4: 4: 4: 4: 4:     function totalSupply(bytes32 _symbol) constant returns(uint);
5: 5: 5: 5: 5:     function balanceOf(address _holder, bytes32 _symbol) constant returns(uint);
6: 6: 6: 6: 6:     function transfer(address _to, uint _value, bytes32 _symbol) returns(bool);
7: 7: 7: 7: 7:     function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
8: 8: 8: 8: 8:     function proxyTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool);
9: 9: 9: 9: 9:     function proxyApprove(address _spender, uint _value, bytes32 _symbol) returns(bool);
10: 10: 10: 10: 10:     function allowance(address _from, address _spender, bytes32 _symbol) constant returns(uint);
11: 11: 11: 11: 11:     function transferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
12: 12: 12: 12: 12:     function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
13: 13: 13: 13: 13:     function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
14: 14: 14: 14: 14:     function proxyTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
15: 15: 15: 15: 15:     function proxySetCosignerAddress(address _address, bytes32 _symbol) returns(bool);
16: 16: 16: 16: 16: }
17: 17: 17: 17: 17: 
18: 18: 18: 18: 18: contract OpenDollar is Asset {
19: 19: 19: 19: 19:     uint public txGasPriceLimit = 21000000000;
20: 20: 20: 20: 20:     uint public refundGas = 40000;
21: 21: 21: 21: 21:     uint public transferCallGas = 21000;
22: 22: 22: 22: 22:     uint public transferWithReferenceCallGas = 21000;
23: 23: 23: 23: 23:     uint public transferFromCallGas = 21000;
24: 24: 24: 24: 24:     uint public transferFromWithReferenceCallGas = 21000;
25: 25: 25: 25: 25:     uint public transferToICAPCallGas = 21000;
26: 26: 26: 26: 26:     uint public transferToICAPWithReferenceCallGas = 21000;
27: 27: 27: 27: 27:     uint public transferFromToICAPCallGas = 21000;
28: 28: 28: 28: 28:     uint public transferFromToICAPWithReferenceCallGas = 21000;
29: 29: 29: 29: 29:     uint public approveCallGas = 21000;
30: 30: 30: 30: 30:     uint public forwardCallGas = 21000;
31: 31: 31: 31: 31:     uint public setCosignerCallGas = 21000;
32: 32: 32: 32: 32:     EtherTreasuryInterface public treasury;
33: 33: 33: 33: 33:     mapping(bytes32 => address) public allowedForwards;
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35:     function updateRefundGas() noValue() checkAccess("setup") returns(uint) {
36: 36: 36: 36: 36:         uint startGas = msg.gas;
37: 37: 37: 37: 37:         
38: 38: 38: 38: 38:         uint refund = (startGas - msg.gas + refundGas) * tx.gasprice;
39: 39: 39: 39: 39:         if (tx.gasprice > txGasPriceLimit) {
40: 40: 40: 40: 40:             return 0;
41: 41: 41: 41: 41:         }
42: 42: 42: 42: 42:         
43: 43: 43: 43: 43:         if (!_refund(1)) {
44: 44: 44: 44: 44:             return 0;
45: 45: 45: 45: 45:         }
46: 46: 46: 46: 46:         refundGas = startGas - msg.gas;
47: 47: 47: 47: 47:         return refundGas;
48: 48: 48: 48: 48:     }
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50:     function setOperationsCallGas
51: 51: 51: 51: 51:         (
52: 52: 52: 52: 52:             uint _transfer,
53: 53: 53: 53: 53:             uint _transferFrom,
54: 54: 54: 54: 54:             uint _transferToICAP,
55: 55: 55: 55: 55:             uint _transferFromToICAP,
56: 56: 56: 56: 56:             uint _transferWithReference,
57: 57: 57: 57: 57:             uint _transferFromWithReference,
58: 58: 58: 58: 58:             uint _transferToICAPWithReference,
59: 59: 59: 59: 59:             uint _transferFromToICAPWithReference,
60: 60: 60: 60: 60:             uint _approve,
61: 61: 61: 61: 61:             uint _forward,
62: 62: 62: 62: 62:             uint _setCosigner
63: 63: 63: 63: 63:         ) noValue() checkAccess("setup") returns(bool)
64: 64: 64: 64: 64:     {
65: 65: 65: 65: 65:         transferCallGas = _transfer;
66: 66: 66: 66: 66:         transferFromCallGas = _transferFrom;
67: 67: 67: 67: 67:         transferToICAPCallGas = _transferToICAP;
68: 68: 68: 68: 68:         transferFromToICAPCallGas = _transferFromToICAP;
69: 69: 69: 69: 69:         transferWithReferenceCallGas = _transferWithReference;
70: 70: 70: 70: 70:         transferFromWithReferenceCallGas = _transferFromWithReference;
71: 71: 71: 71: 71:         transferToICAPWithReferenceCallGas = _transferToICAPWithReference;
72: 72: 72: 72: 72:         transferFromToICAPWithReferenceCallGas = _transferFromToICAPWithReference;
73: 73: 73: 73: 73:         approveCallGas = _approve;
74: 74: 74: 74: 74:         forwardCallGas = _forward;
75: 75: 75: 75: 75:         setCosignerCallGas = _setCosigner;
76: 76: 76: 76: 76:         return true;
77: 77: 77: 77: 77:     }
78: 78: 78: 78: 78: 
79: 79: 79: 79: 79:     function setupTreasury(address _treasury, uint _txGasPriceLimit) checkAccess("admin") returns(bool) {
80: 80: 80: 80: 80:         if (_txGasPriceLimit == 0) {
81: 81: 81: 81: 81:             return false;
82: 82: 82: 82: 82:         }
83: 83: 83: 83: 83:         treasury = EtherTreasuryInterface(_treasury);
84: 84: 84: 84: 84:         txGasPriceLimit = _txGasPriceLimit;
85: 85: 85: 85: 85:         if (msg.value > 0) {
86: 86: 86: 86: 86:             _safeSend(_treasury, msg.value);
87: 87: 87: 87: 87:         }
88: 88: 88: 88: 88:         return true;
89: 89: 89: 89: 89:     }
90: 90: 90: 90: 90: 
91: 91: 91: 91: 91:     function setForward(bytes4 _msgSig, address _forward) noValue() checkAccess("admin") returns(bool) {
92: 92: 92: 92: 92:         allowedForwards[sha3(_msgSig)] = _forward;
93: 93: 93: 93: 93:         return true;
94: 94: 94: 94: 94:     }
95: 95: 95: 95: 95: 
96: 96: 96: 96: 96:     function _stringGas(string _string) constant internal returns(uint) {
97: 97: 97: 97: 97:         return bytes(_string).length * 75; 
98: 98: 98: 98: 98:     }
99: 99: 99: 99: 99: 
100: 100: 100: 100: 100:     function _applyRefund(uint _startGas) internal returns(bool) {
101: 101: 101: 101: 101:         if (tx.gasprice > txGasPriceLimit) {
102: 102: 102: 102: 102:             return false;
103: 103: 103: 103: 103:         }
104: 104: 104: 104: 104:         uint refund = (_startGas - msg.gas + refundGas) * tx.gasprice;
105: 105: 105: 105: 105:         return _refund(refund);
106: 106: 106: 106: 106:     }
107: 107: 107: 107: 107: 
108: 108: 108: 108: 108:     function _refund(uint _value) internal returns(bool) {
109: 109: 109: 109: 109:         return treasury.withdraw(tx.origin, _value);
110: 110: 110: 110: 110:     }
111: 111: 111: 111: 111: 
112: 112: 112: 112: 112:     function _transfer(address _to, uint _value) internal returns(bool, bool) {
113: 113: 113: 113: 113:         uint startGas = msg.gas + transferCallGas;
114: 114: 114: 114: 114:         if (!super.transfer(_to, _value)) {
115: 115: 115: 115: 115:             return (false, false);
116: 116: 116: 116: 116:         }
117: 117: 117: 117: 117:         return (true, _applyRefund(startGas));
118: 118: 118: 118: 118:     }
119: 119: 119: 119: 119: 
120: 120: 120: 120: 120:     function _transferFrom(address _from, address _to, uint _value) internal returns(bool, bool) {
121: 121: 121: 121: 121:         uint startGas = msg.gas + transferFromCallGas;
122: 122: 122: 122: 122:         if (!super.transferFrom(_from, _to, _value)) {
123: 123: 123: 123: 123:             return (false, false);
124: 124: 124: 124: 124:         }
125: 125: 125: 125: 125:         return (true, _applyRefund(startGas));
126: 126: 126: 126: 126:     }
127: 127: 127: 127: 127: 
128: 128: 128: 128: 128:     function _transferToICAP(bytes32 _icap, uint _value) internal returns(bool, bool) {
129: 129: 129: 129: 129:         uint startGas = msg.gas + transferToICAPCallGas;
130: 130: 130: 130: 130:         if (!super.transferToICAP(_icap, _value)) {
131: 131: 131: 131: 131:             return (false, false);
132: 132: 132: 132: 132:         }
133: 133: 133: 133: 133:         return (true, _applyRefund(startGas));
134: 134: 134: 134: 134:     }
135: 135: 135: 135: 135: 
136: 136: 136: 136: 136:     function _transferFromToICAP(address _from, bytes32 _icap, uint _value) internal returns(bool, bool) {
137: 137: 137: 137: 137:         uint startGas = msg.gas + transferFromToICAPCallGas;
138: 138: 138: 138: 138:         if (!super.transferFromToICAP(_from, _icap, _value)) {
139: 139: 139: 139: 139:             return (false, false);
140: 140: 140: 140: 140:         }
141: 141: 141: 141: 141:         return (true, _applyRefund(startGas));
142: 142: 142: 142: 142:     }
143: 143: 143: 143: 143: 
144: 144: 144: 144: 144:     function _transferWithReference(address _to, uint _value, string _reference) internal returns(bool, bool) {
145: 145: 145: 145: 145:         uint startGas = msg.gas + transferWithReferenceCallGas + _stringGas(_reference);
146: 146: 146: 146: 146:         if (!super.transferWithReference(_to, _value, _reference)) {
147: 147: 147: 147: 147:             return (false, false);
148: 148: 148: 148: 148:         }
149: 149: 149: 149: 149:         return (true, _applyRefund(startGas));
150: 150: 150: 150: 150:     }
151: 151: 151: 151: 151: 
152: 152: 152: 152: 152:     function _transferFromWithReference(address _from, address _to, uint _value, string _reference) internal returns(bool, bool) {
153: 153: 153: 153: 153:         uint startGas = msg.gas + transferFromWithReferenceCallGas + _stringGas(_reference);
154: 154: 154: 154: 154:         if (!super.transferFromWithReference(_from, _to, _value, _reference)) {
155: 155: 155: 155: 155:             return (false, false);
156: 156: 156: 156: 156:         }
157: 157: 157: 157: 157:         return (true, _applyRefund(startGas));
158: 158: 158: 158: 158:     }
159: 159: 159: 159: 159: 
160: 160: 160: 160: 160:     function _transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) internal returns(bool, bool) {
161: 161: 161: 161: 161:         uint startGas = msg.gas + transferToICAPWithReferenceCallGas + _stringGas(_reference);
162: 162: 162: 162: 162:         if (!super.transferToICAPWithReference(_icap, _value, _reference)) {
163: 163: 163: 163: 163:             return (false, false);
164: 164: 164: 164: 164:         }
165: 165: 165: 165: 165:         return (true, _applyRefund(startGas));
166: 166: 166: 166: 166:     }
167: 167: 167: 167: 167: 
168: 168: 168: 168: 168:     function _transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) internal returns(bool, bool) {
169: 169: 169: 169: 169:         uint startGas = msg.gas + transferFromToICAPWithReferenceCallGas + _stringGas(_reference);
170: 170: 170: 170: 170:         if (!super.transferFromToICAPWithReference(_from, _icap, _value, _reference)) {
171: 171: 171: 171: 171:             return (false, false);
172: 172: 172: 172: 172:         }
173: 173: 173: 173: 173:         return (true, _applyRefund(startGas));
174: 174: 174: 174: 174:     }
175: 175: 175: 175: 175: 
176: 176: 176: 176: 176:     function _approve(address _spender, uint _value) internal returns(bool, bool) {
177: 177: 177: 177: 177:         uint startGas = msg.gas + approveCallGas;
178: 178: 178: 178: 178:         if (!super.approve(_spender, _value)) {
179: 179: 179: 179: 179:             return (false, false);
180: 180: 180: 180: 180:         }
181: 181: 181: 181: 181:         return (true, _applyRefund(startGas));
182: 182: 182: 182: 182:     }
183: 183: 183: 183: 183: 
184: 184: 184: 184: 184:     function _setCosignerAddress(address _cosigner) internal returns(bool, bool) {
185: 185: 185: 185: 185:         uint startGas = msg.gas + setCosignerCallGas;
186: 186: 186: 186: 186:         if (!super.setCosignerAddress(_cosigner)) {
187: 187: 187: 187: 187:             return (false, false);
188: 188: 188: 188: 188:         }
189: 189: 189: 189: 189:         return (true, _applyRefund(startGas));
190: 190: 190: 190: 190:     }
191: 191: 191: 191: 191: 
192: 192: 192: 192: 192:     function transfer(address _to, uint _value) returns(bool) {
193: 193: 193: 193: 193:         bool success;
194: 194: 194: 194: 194:         (success,) = _transfer(_to, _value);
195: 195: 195: 195: 195:         return success;
196: 196: 196: 196: 196:     }
197: 197: 197: 197: 197: 
198: 198: 198: 198: 198:     function transferFrom(address _from, address _to, uint _value) returns(bool) {
199: 199: 199: 199: 199:         bool success;
200: 200: 200: 200: 200:         (success,) = _transferFrom(_from, _to, _value);
201: 201: 201: 201: 201:         return success;
202: 202: 202: 202: 202:     }
203: 203: 203: 203: 203: 
204: 204: 204: 204: 204:     function transferToICAP(bytes32 _icap, uint _value) returns(bool) {
205: 205: 205: 205: 205:         bool success;
206: 206: 206: 206: 206:         (success,) = _transferToICAP(_icap, _value);
207: 207: 207: 207: 207:         return success;
208: 208: 208: 208: 208:     }
209: 209: 209: 209: 209: 
210: 210: 210: 210: 210:     function transferFromToICAP(address _from, bytes32 _icap, uint _value) returns(bool) {
211: 211: 211: 211: 211:         bool success;
212: 212: 212: 212: 212:         (success,) = _transferFromToICAP(_from, _icap, _value);
213: 213: 213: 213: 213:         return success;
214: 214: 214: 214: 214:     }
215: 215: 215: 215: 215: 
216: 216: 216: 216: 216:     function transferWithReference(address _to, uint _value, string _reference) returns(bool) {
217: 217: 217: 217: 217:         bool success;
218: 218: 218: 218: 218:         (success,) = _transferWithReference(_to, _value, _reference);
219: 219: 219: 219: 219:         return success;
220: 220: 220: 220: 220:     }
221: 221: 221: 221: 221: 
222: 222: 222: 222: 222:     function transferFromWithReference(address _from, address _to, uint _value, string _reference) returns(bool) {
223: 223: 223: 223: 223:         bool success;
224: 224: 224: 224: 224:         (success,) = _transferFromWithReference(_from, _to, _value, _reference);
225: 225: 225: 225: 225:         return success;
226: 226: 226: 226: 226:     }
227: 227: 227: 227: 227: 
228: 228: 228: 228: 228:     function transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool) {
229: 229: 229: 229: 229:         bool success;
230: 230: 230: 230: 230:         (success,) = _transferToICAPWithReference(_icap, _value, _reference);
231: 231: 231: 231: 231:         return success;
232: 232: 232: 232: 232:     }
233: 233: 233: 233: 233: 
234: 234: 234: 234: 234:     function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool) {
235: 235: 235: 235: 235:         bool success;
236: 236: 236: 236: 236:         (success,) = _transferFromToICAPWithReference(_from, _icap, _value, _reference);
237: 237: 237: 237: 237:         return success;
238: 238: 238: 238: 238:     }
239: 239: 239: 239: 239: 
240: 240: 240: 240: 240:     function approve(address _spender, uint _value) returns(bool) {
241: 241: 241: 241: 241:         bool success;
242: 242: 242: 242: 242:         (success,) = _approve(_spender, _value);
243: 243: 243: 243: 243:         return success;
244: 244: 244: 244: 244:     }
245: 245: 245: 245: 245: 
246: 246: 246: 246: 246:     function setCosignerAddress(address _cosigner) returns(bool) {
247: 247: 247: 247: 247:         bool success;
248: 248: 248: 248: 248:         (success,) = _setCosignerAddress(_cosigner);
249: 249: 249: 249: 249:         return success;
250: 250: 250: 250: 250:     }
251: 251: 251: 251: 251: 
252: 252: 252: 252: 252:     function checkTransfer(address _to, uint _value) constant returns(bool, bool) {
253: 253: 253: 253: 253:         return _transfer(_to, _value);
254: 254: 254: 254: 254:     }
255: 255: 255: 255: 255: 
256: 256: 256: 256: 256:     function checkTransferFrom(address _from, address _to, uint _value) constant returns(bool, bool) {
257: 257: 257: 257: 257:         return _transferFrom(_from, _to, _value);
258: 258: 258: 258: 258:     }
259: 259: 259: 259: 259: 
260: 260: 260: 260: 260:     function checkTransferToICAP(bytes32 _icap, uint _value) constant returns(bool, bool) {
261: 261: 261: 261: 261:         return _transferToICAP(_icap, _value);
262: 262: 262: 262: 262:     }
263: 263: 263: 263: 263: 
264: 264: 264: 264: 264:     function checkTransferFromToICAP(address _from, bytes32 _icap, uint _value) constant returns(bool, bool) {
265: 265: 265: 265: 265:         return _transferFromToICAP(_from, _icap, _value);
266: 266: 266: 266: 266:     }
267: 267: 267: 267: 267: 
268: 268: 268: 268: 268:     function checkTransferWithReference(address _to, uint _value, string _reference) constant returns(bool, bool) {
269: 269: 269: 269: 269:         return _transferWithReference(_to, _value, _reference);
270: 270: 270: 270: 270:     }
271: 271: 271: 271: 271: 
272: 272: 272: 272: 272:     function checkTransferFromWithReference(address _from, address _to, uint _value, string _reference) constant returns(bool, bool) {
273: 273: 273: 273: 273:         return _transferFromWithReference(_from, _to, _value, _reference);
274: 274: 274: 274: 274:     }
275: 275: 275: 275: 275: 
276: 276: 276: 276: 276:     function checkTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) constant returns(bool, bool) {
277: 277: 277: 277: 277:         return _transferToICAPWithReference(_icap, _value, _reference);
278: 278: 278: 278: 278:     }
279: 279: 279: 279: 279: 
280: 280: 280: 280: 280:     function checkTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) constant returns(bool, bool) {
281: 281: 281: 281: 281:         return _transferFromToICAPWithReference(_from, _icap, _value, _reference);
282: 282: 282: 282: 282:     }
283: 283: 283: 283: 283: 
284: 284: 284: 284: 284:     function checkApprove(address _spender, uint _value) constant returns(bool, bool) {
285: 285: 285: 285: 285:         return _approve(_spender, _value);
286: 286: 286: 286: 286:     }
287: 287: 287: 287: 287: 
288: 288: 288: 288: 288:     function checkSetCosignerAddress(address _cosigner) constant returns(bool, bool) {
289: 289: 289: 289: 289:         return _setCosignerAddress(_cosigner);
290: 290: 290: 290: 290:     }
291: 291: 291: 291: 291: 
292: 292: 292: 292: 292:     function checkForward(bytes _data) constant returns(bool, bool) {
293: 293: 293: 293: 293:         bytes memory sig = new bytes(4);
294: 294: 294: 294: 294:         sig[0] = _data[0];
295: 295: 295: 295: 295:         sig[1] = _data[1];
296: 296: 296: 296: 296:         sig[2] = _data[2];
297: 297: 297: 297: 297:         sig[3] = _data[3];
298: 298: 298: 298: 298:         return _forward(allowedForwards[sha3(sig)], _data);
299: 299: 299: 299: 299:     }
300: 300: 300: 300: 300: 
301: 301: 301: 301: 301:     function _forward(address _to, bytes _data) internal returns(bool, bool) {
302: 302: 302: 302: 302:         uint startGas = msg.gas + forwardCallGas + (_data.length * 50); 
303: 303: 303: 303: 303:         if (_to == 0x0) {
304: 304: 304: 304: 304:             return (false, _safeFalse());
305: 305: 305: 305: 305:         }
306: 306: 306: 306: 306:         if (!_to.call.value(msg.value)(_data)) {
307: 307: 307: 307: 307:             return (false, _safeFalse());
308: 308: 308: 308: 308:         }
309: 309: 309: 309: 309:         return (true, _applyRefund(startGas));
310: 310: 310: 310: 310:     }
311: 311: 311: 311: 311: 
312: 312: 312: 312: 312:     function () returns(bool) {
313: 313: 313: 313: 313:         bool success;
314: 314: 314: 314: 314:         (success,) = _forward(allowedForwards[sha3(msg.sig)], msg.data);
315: 315: 315: 315: 315:         return success;
316: 316: 316: 316: 316:     }
317: 317: 317: 317: 317: }