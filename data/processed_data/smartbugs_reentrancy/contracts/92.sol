1: 1: 1: 1: 1: pragma solidity ^0.4.23;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: contract ShareStore is IRoleModel, IShareStore, IStateModel {
6: 6: 6: 6: 6:   
7: 7: 7: 7: 7:   using SafeMath for uint;
8: 8: 8: 8: 8:   
9: 9: 9: 9: 9:   
10: 10: 10: 10: 10: 
11: 11: 11: 11: 11: 
12: 12: 12: 12: 12:   uint public minimalDeposit;
13: 13: 13: 13: 13:   
14: 14: 14: 14: 14:   
15: 15: 15: 15: 15: 
16: 16: 16: 16: 16: 
17: 17: 17: 17: 17:   address public tokenAddress;
18: 18: 18: 18: 18:   
19: 19: 19: 19: 19:   
20: 20: 20: 20: 20: 
21: 21: 21: 21: 21: 
22: 22: 22: 22: 22:   mapping (address=>uint) public share;
23: 23: 23: 23: 23:   
24: 24: 24: 24: 24:   
25: 25: 25: 25: 25: 
26: 26: 26: 26: 26: 
27: 27: 27: 27: 27:   uint public totalShare;
28: 28: 28: 28: 28:   
29: 29: 29: 29: 29:   
30: 30: 30: 30: 30: 
31: 31: 31: 31: 31: 
32: 32: 32: 32: 32:   uint public totalToken;
33: 33: 33: 33: 33:   
34: 34: 34: 34: 34:   
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37:   mapping (uint8=>uint) public stakeholderShare;
38: 38: 38: 38: 38:   mapping (address=>uint) internal etherReleased_;
39: 39: 39: 39: 39:   mapping (address=>uint) internal tokenReleased_;
40: 40: 40: 40: 40:   mapping (uint8=>uint) internal stakeholderEtherReleased_;
41: 41: 41: 41: 41:   uint constant DECIMAL_MULTIPLIER = 1e18;
42: 42: 42: 42: 42: 
43: 43: 43: 43: 43:   
44: 44: 44: 44: 44: 
45: 45: 45: 45: 45: 
46: 46: 46: 46: 46:   uint public tokenPrice;
47: 47: 47: 47: 47:   
48: 48: 48: 48: 48:   
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50: 
51: 51: 51: 51: 51: 
52: 52: 52: 52: 52: 
53: 53: 53: 53: 53: 
54: 54: 54: 54: 54: 
55: 55: 55: 55: 55:   function () public payable {
56: 56: 56: 56: 56:     uint8 _state = getState_();
57: 57: 57: 57: 57:     if (_state == ST_RAISING){
58: 58: 58: 58: 58:       buyShare_(_state);
59: 59: 59: 59: 59:       return;
60: 60: 60: 60: 60:     }
61: 61: 61: 61: 61:     
62: 62: 62: 62: 62:     if (_state == ST_MONEY_BACK) {
63: 63: 63: 63: 63:       refundShare_(msg.sender, share[msg.sender]);
64: 64: 64: 64: 64:       if(msg.value > 0)
65: 65: 65: 65: 65:         msg.sender.transfer(msg.value);
66: 66: 66: 66: 66:       return;
67: 67: 67: 67: 67:     }
68: 68: 68: 68: 68:     
69: 69: 69: 69: 69:     if (_state == ST_TOKEN_DISTRIBUTION) {
70: 70: 70: 70: 70:       releaseEther_(msg.sender, getBalanceEtherOf_(msg.sender));
71: 71: 71: 71: 71:       releaseToken_(msg.sender, getBalanceTokenOf_(msg.sender));
72: 72: 72: 72: 72:       if(msg.value > 0)
73: 73: 73: 73: 73:         msg.sender.transfer(msg.value);
74: 74: 74: 74: 74:       return;
75: 75: 75: 75: 75:     }
76: 76: 76: 76: 76:     revert();
77: 77: 77: 77: 77:   }
78: 78: 78: 78: 78:   
79: 79: 79: 79: 79:   
80: 80: 80: 80: 80:   
81: 81: 81: 81: 81: 
82: 82: 82: 82: 82: 
83: 83: 83: 83: 83: 
84: 84: 84: 84: 84:   function buyShare() external payable returns(bool) {
85: 85: 85: 85: 85:     return buyShare_(getState_());
86: 86: 86: 86: 86:   }
87: 87: 87: 87: 87:   
88: 88: 88: 88: 88:   
89: 89: 89: 89: 89: 
90: 90: 90: 90: 90: 
91: 91: 91: 91: 91: 
92: 92: 92: 92: 92: 
93: 93: 93: 93: 93:   function acceptTokenFromICO(uint _value) external returns(bool) {
94: 94: 94: 94: 94:     return acceptTokenFromICO_(_value);
95: 95: 95: 95: 95:   }
96: 96: 96: 96: 96:   
97: 97: 97: 97: 97:   
98: 98: 98: 98: 98: 
99: 99: 99: 99: 99: 
100: 100: 100: 100: 100: 
101: 101: 101: 101: 101: 
102: 102: 102: 102: 102:   function getStakeholderBalanceOf(uint8 _for) external view returns(uint) {
103: 103: 103: 103: 103:     return getStakeholderBalanceOf_(_for);
104: 104: 104: 104: 104:   }
105: 105: 105: 105: 105:   
106: 106: 106: 106: 106:   
107: 107: 107: 107: 107: 
108: 108: 108: 108: 108: 
109: 109: 109: 109: 109: 
110: 110: 110: 110: 110: 
111: 111: 111: 111: 111:   function getBalanceEtherOf(address _for) external view returns(uint) {
112: 112: 112: 112: 112:     return getBalanceEtherOf_(_for);
113: 113: 113: 113: 113:   }
114: 114: 114: 114: 114:   
115: 115: 115: 115: 115:   
116: 116: 116: 116: 116: 
117: 117: 117: 117: 117: 
118: 118: 118: 118: 118: 
119: 119: 119: 119: 119: 
120: 120: 120: 120: 120:   function getBalanceTokenOf(address _for) external view returns(uint) {
121: 121: 121: 121: 121:     return getBalanceTokenOf_(_for);
122: 122: 122: 122: 122:   }
123: 123: 123: 123: 123:   
124: 124: 124: 124: 124:   
125: 125: 125: 125: 125: 
126: 126: 126: 126: 126: 
127: 127: 127: 127: 127: 
128: 128: 128: 128: 128: 
129: 129: 129: 129: 129:   function releaseEtherToStakeholder(uint _value) external returns(bool) {
130: 130: 130: 130: 130:     uint8 _state = getState_();
131: 131: 131: 131: 131:     uint8 _for = getRole_();
132: 132: 132: 132: 132:     require(!((_for == RL_ICO_MANAGER) && ((_state != ST_WAIT_FOR_ICO) || (tokenPrice > 0))));
133: 133: 133: 133: 133:     return releaseEtherToStakeholder_(_state, _for, _value);
134: 134: 134: 134: 134:   }
135: 135: 135: 135: 135:   
136: 136: 136: 136: 136:   
137: 137: 137: 137: 137: 
138: 138: 138: 138: 138: 
139: 139: 139: 139: 139: 
140: 140: 140: 140: 140: 
141: 141: 141: 141: 141: 
142: 142: 142: 142: 142:   function releaseEtherToStakeholderForce(uint8 _for, uint _value) external returns(bool) {
143: 143: 143: 143: 143:     uint8 _role = getRole_();
144: 144: 144: 144: 144:     require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
145: 145: 145: 145: 145:     uint8 _state = getState_();
146: 146: 146: 146: 146:     require(!((_for == RL_ICO_MANAGER) && ((_state != ST_WAIT_FOR_ICO) || (tokenPrice > 0))));
147: 147: 147: 147: 147:     return releaseEtherToStakeholder_(_state, _for, _value);
148: 148: 148: 148: 148:   }
149: 149: 149: 149: 149:   
150: 150: 150: 150: 150:   
151: 151: 151: 151: 151: 
152: 152: 152: 152: 152: 
153: 153: 153: 153: 153: 
154: 154: 154: 154: 154: 
155: 155: 155: 155: 155:   function releaseEther(uint _value) external returns(bool) {
156: 156: 156: 156: 156:     uint8 _state = getState_();
157: 157: 157: 157: 157:     require(_state == ST_TOKEN_DISTRIBUTION);
158: 158: 158: 158: 158:     return releaseEther_(msg.sender, _value);
159: 159: 159: 159: 159:   }
160: 160: 160: 160: 160:   
161: 161: 161: 161: 161:   
162: 162: 162: 162: 162: 
163: 163: 163: 163: 163: 
164: 164: 164: 164: 164: 
165: 165: 165: 165: 165: 
166: 166: 166: 166: 166: 
167: 167: 167: 167: 167:   function releaseEtherForce(address _for, uint _value) external returns(bool) {
168: 168: 168: 168: 168:     uint8 _role = getRole_();
169: 169: 169: 169: 169:     uint8 _state = getState_();
170: 170: 170: 170: 170:     require(_state == ST_TOKEN_DISTRIBUTION);
171: 171: 171: 171: 171:     require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
172: 172: 172: 172: 172:     return releaseEther_(_for, _value);
173: 173: 173: 173: 173:   }
174: 174: 174: 174: 174: 
175: 175: 175: 175: 175:   
176: 176: 176: 176: 176: 
177: 177: 177: 177: 177: 
178: 178: 178: 178: 178: 
179: 179: 179: 179: 179: 
180: 180: 180: 180: 180: 
181: 181: 181: 181: 181:   function releaseEtherForceMulti(address[] _for, uint[] _value) external returns(bool) {
182: 182: 182: 182: 182:     uint _sz = _for.length;
183: 183: 183: 183: 183:     require(_value.length == _sz);
184: 184: 184: 184: 184:     uint8 _role = getRole_();
185: 185: 185: 185: 185:     uint8 _state = getState_();
186: 186: 186: 186: 186:     require(_state == ST_TOKEN_DISTRIBUTION);
187: 187: 187: 187: 187:     require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
188: 188: 188: 188: 188:     for (uint i = 0; i < _sz; i++){
189: 189: 189: 189: 189:       require(releaseEther_(_for[i], _value[i]));
190: 190: 190: 190: 190:     }
191: 191: 191: 191: 191:     return true;
192: 192: 192: 192: 192:   }
193: 193: 193: 193: 193:   
194: 194: 194: 194: 194:   
195: 195: 195: 195: 195: 
196: 196: 196: 196: 196: 
197: 197: 197: 197: 197: 
198: 198: 198: 198: 198: 
199: 199: 199: 199: 199:   function releaseToken(uint _value) external returns(bool) {
200: 200: 200: 200: 200:     uint8 _state = getState_();
201: 201: 201: 201: 201:     require(_state == ST_TOKEN_DISTRIBUTION);
202: 202: 202: 202: 202:     return releaseToken_(msg.sender, _value);
203: 203: 203: 203: 203:   }
204: 204: 204: 204: 204:   
205: 205: 205: 205: 205:   
206: 206: 206: 206: 206: 
207: 207: 207: 207: 207: 
208: 208: 208: 208: 208: 
209: 209: 209: 209: 209: 
210: 210: 210: 210: 210: 
211: 211: 211: 211: 211:   function releaseTokenForce(address _for, uint _value) external returns(bool) {
212: 212: 212: 212: 212:     uint8 _role = getRole_();
213: 213: 213: 213: 213:     uint8 _state = getState_();
214: 214: 214: 214: 214:     require(_state == ST_TOKEN_DISTRIBUTION);
215: 215: 215: 215: 215:     require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
216: 216: 216: 216: 216:     return releaseToken_(_for, _value);
217: 217: 217: 217: 217:   }
218: 218: 218: 218: 218: 
219: 219: 219: 219: 219: 
220: 220: 220: 220: 220:   
221: 221: 221: 221: 221: 
222: 222: 222: 222: 222: 
223: 223: 223: 223: 223: 
224: 224: 224: 224: 224: 
225: 225: 225: 225: 225: 
226: 226: 226: 226: 226:   function releaseTokenForceMulti(address[] _for, uint[] _value) external returns(bool) {
227: 227: 227: 227: 227:     uint _sz = _for.length;
228: 228: 228: 228: 228:     require(_value.length == _sz);
229: 229: 229: 229: 229:     uint8 _role = getRole_();
230: 230: 230: 230: 230:     uint8 _state = getState_();
231: 231: 231: 231: 231:     require(_state == ST_TOKEN_DISTRIBUTION);
232: 232: 232: 232: 232:     require((_role==RL_ADMIN) || (_role==RL_PAYBOT));
233: 233: 233: 233: 233:     for(uint i = 0; i < _sz; i++){
234: 234: 234: 234: 234:       require(releaseToken_(_for[i], _value[i]));
235: 235: 235: 235: 235:     }
236: 236: 236: 236: 236:     return true;
237: 237: 237: 237: 237:   }
238: 238: 238: 238: 238:   
239: 239: 239: 239: 239:   
240: 240: 240: 240: 240: 
241: 241: 241: 241: 241: 
242: 242: 242: 242: 242: 
243: 243: 243: 243: 243: 
244: 244: 244: 244: 244:   function refundShare(uint _value) external returns(bool) {
245: 245: 245: 245: 245:     uint8 _state = getState_();
246: 246: 246: 246: 246:     require (_state == ST_MONEY_BACK);
247: 247: 247: 247: 247:     return refundShare_(msg.sender, _value);
248: 248: 248: 248: 248:   }
249: 249: 249: 249: 249:   
250: 250: 250: 250: 250:   
251: 251: 251: 251: 251: 
252: 252: 252: 252: 252: 
253: 253: 253: 253: 253: 
254: 254: 254: 254: 254: 
255: 255: 255: 255: 255: 
256: 256: 256: 256: 256:   function refundShareForce(address _for, uint _value) external returns(bool) {
257: 257: 257: 257: 257:     uint8 _state = getState_();
258: 258: 258: 258: 258:     uint8 _role = getRole_();
259: 259: 259: 259: 259:     require(_role == RL_ADMIN || _role == RL_PAYBOT);
260: 260: 260: 260: 260:     require (_state == ST_MONEY_BACK || _state == ST_RAISING);
261: 261: 261: 261: 261:     return refundShare_(_for, _value);
262: 262: 262: 262: 262:   }
263: 263: 263: 263: 263:   
264: 264: 264: 264: 264:   
265: 265: 265: 265: 265: 
266: 266: 266: 266: 266: 
267: 267: 267: 267: 267: 
268: 268: 268: 268: 268: 
269: 269: 269: 269: 269: 
270: 270: 270: 270: 270: 
271: 271: 271: 271: 271:   function execute(address _to, uint _value, bytes _data) external returns (bool) {
272: 272: 272: 272: 272:     require (getRole_()==RL_ADMIN);
273: 273: 273: 273: 273:     require (getState_()==ST_FUND_DEPRECATED);
274: 274: 274: 274: 274:     
275: 275: 275: 275: 275:     return _to.call.value(_value)(_data);
276: 276: 276: 276: 276:   }
277: 277: 277: 277: 277:   
278: 278: 278: 278: 278:   function getTotalShare_() internal view returns(uint){
279: 279: 279: 279: 279:     return totalShare;
280: 280: 280: 280: 280:   }
281: 281: 281: 281: 281: 
282: 282: 282: 282: 282:   function getEtherCollected_() internal view returns(uint){
283: 283: 283: 283: 283:     return totalShare;
284: 284: 284: 284: 284:   }
285: 285: 285: 285: 285: 
286: 286: 286: 286: 286:   function buyShare_(uint8 _state) internal returns(bool) {
287: 287: 287: 287: 287:     require(_state == ST_RAISING);
288: 288: 288: 288: 288:     require(msg.value >= minimalDeposit);
289: 289: 289: 289: 289:     uint _shareRemaining = getShareRemaining_();
290: 290: 290: 290: 290:     uint _shareAccept = (msg.value <= _shareRemaining) ? msg.value : _shareRemaining;
291: 291: 291: 291: 291: 
292: 292: 292: 292: 292:     share[msg.sender] = share[msg.sender].add(_shareAccept);
293: 293: 293: 293: 293:     totalShare = totalShare.add(_shareAccept);
294: 294: 294: 294: 294:     emit BuyShare(msg.sender, _shareAccept);
295: 295: 295: 295: 295:     if (msg.value!=_shareAccept) {
296: 296: 296: 296: 296:       msg.sender.transfer(msg.value.sub(_shareAccept));
297: 297: 297: 297: 297:     }
298: 298: 298: 298: 298:     return true;
299: 299: 299: 299: 299:   }
300: 300: 300: 300: 300: 
301: 301: 301: 301: 301:   function acceptTokenFromICO_(uint _value) internal returns(bool) {
302: 302: 302: 302: 302:     uint8 _state = getState_();
303: 303: 303: 303: 303:     uint8 _for = getRole_();
304: 304: 304: 304: 304:     require(_state == ST_WAIT_FOR_ICO);
305: 305: 305: 305: 305:     require(_for == RL_ICO_MANAGER);
306: 306: 306: 306: 306:     
307: 307: 307: 307: 307:     totalToken = totalToken.add(_value);
308: 308: 308: 308: 308:     emit AcceptTokenFromICO(msg.sender, _value);
309: 309: 309: 309: 309:     require(IERC20(tokenAddress).transferFrom(msg.sender, this, _value));
310: 310: 310: 310: 310:     if (tokenPrice > 0) {
311: 311: 311: 311: 311:       releaseEtherToStakeholder_(_state, _for, _value.mul(tokenPrice).div(DECIMAL_MULTIPLIER));
312: 312: 312: 312: 312:     }
313: 313: 313: 313: 313:     return true;
314: 314: 314: 314: 314:   }
315: 315: 315: 315: 315: 
316: 316: 316: 316: 316:   function getStakeholderBalanceOf_(uint8 _for) internal view returns (uint) {
317: 317: 317: 317: 317:     if (_for == RL_ICO_MANAGER) {
318: 318: 318: 318: 318:       return getEtherCollected_().mul(stakeholderShare[_for]).div(DECIMAL_MULTIPLIER).sub(stakeholderEtherReleased_[_for]);
319: 319: 319: 319: 319:     }
320: 320: 320: 320: 320: 
321: 321: 321: 321: 321:     if ((_for == RL_POOL_MANAGER) || (_for == RL_ADMIN)) {
322: 322: 322: 322: 322:       return stakeholderEtherReleased_[RL_ICO_MANAGER].mul(stakeholderShare[_for]).div(stakeholderShare[RL_ICO_MANAGER]);
323: 323: 323: 323: 323:     }
324: 324: 324: 324: 324:     return 0;
325: 325: 325: 325: 325:   }
326: 326: 326: 326: 326: 
327: 327: 327: 327: 327:   function releaseEtherToStakeholder_(uint8 _state, uint8 _for, uint _value) internal returns (bool) {
328: 328: 328: 328: 328:     require(_for != RL_DEFAULT);
329: 329: 329: 329: 329:     require(_for != RL_PAYBOT);
330: 330: 330: 330: 330:     require(!((_for == RL_ICO_MANAGER) && (_state != ST_WAIT_FOR_ICO)));
331: 331: 331: 331: 331:     uint _balance = getStakeholderBalanceOf_(_for);
332: 332: 332: 332: 332:     address _afor = getRoleAddress_(_for);
333: 333: 333: 333: 333:     require(_balance >= _value);
334: 334: 334: 334: 334:     stakeholderEtherReleased_[_for] = stakeholderEtherReleased_[_for].add(_value);
335: 335: 335: 335: 335:     emit ReleaseEtherToStakeholder(_for, _afor, _value);
336: 336: 336: 336: 336:     _afor.transfer(_value);
337: 337: 337: 337: 337:     return true;
338: 338: 338: 338: 338:   }
339: 339: 339: 339: 339: 
340: 340: 340: 340: 340:   function getBalanceEtherOf_(address _for) internal view returns (uint) {
341: 341: 341: 341: 341:     uint _stakeholderTotalEtherReserved = stakeholderEtherReleased_[RL_ICO_MANAGER]
342: 342: 342: 342: 342:     .mul(DECIMAL_MULTIPLIER).div(stakeholderShare[RL_ICO_MANAGER]);
343: 343: 343: 343: 343:     uint _restEther = getEtherCollected_().sub(_stakeholderTotalEtherReserved);
344: 344: 344: 344: 344:     return _restEther.mul(share[_for]).div(totalShare).sub(etherReleased_[_for]);
345: 345: 345: 345: 345:   }
346: 346: 346: 346: 346: 
347: 347: 347: 347: 347:   function getBalanceTokenOf_(address _for) internal view returns (uint) {
348: 348: 348: 348: 348:     return totalToken.mul(share[_for]).div(totalShare).sub(tokenReleased_[_for]);
349: 349: 349: 349: 349:   }
350: 350: 350: 350: 350: 
351: 351: 351: 351: 351:   function releaseEther_(address _for, uint _value) internal returns (bool) {
352: 352: 352: 352: 352:     uint _balance = getBalanceEtherOf_(_for);
353: 353: 353: 353: 353:     require(_balance >= _value);
354: 354: 354: 354: 354:     etherReleased_[_for] = etherReleased_[_for].add(_value);
355: 355: 355: 355: 355:     emit ReleaseEther(_for, _value);
356: 356: 356: 356: 356:     _for.transfer(_value);
357: 357: 357: 357: 357:     return true;
358: 358: 358: 358: 358:   }
359: 359: 359: 359: 359: 
360: 360: 360: 360: 360:   function releaseToken_( address _for, uint _value) internal returns (bool) {
361: 361: 361: 361: 361:     uint _balance = getBalanceTokenOf_(_for);
362: 362: 362: 362: 362:     require(_balance >= _value);
363: 363: 363: 363: 363:     tokenReleased_[_for] = tokenReleased_[_for].add(_value);
364: 364: 364: 364: 364:     emit ReleaseToken(_for, _value);
365: 365: 365: 365: 365:     require(IERC20(tokenAddress).transfer(_for, _value));
366: 366: 366: 366: 366:     return true;
367: 367: 367: 367: 367:   }
368: 368: 368: 368: 368: 
369: 369: 369: 369: 369:   function refundShare_(address _for, uint _value) internal returns(bool) {
370: 370: 370: 370: 370:     uint _balance = share[_for];
371: 371: 371: 371: 371:     require(_balance >= _value);
372: 372: 372: 372: 372:     share[_for] = _balance.sub(_value);
373: 373: 373: 373: 373:     totalShare = totalShare.sub(_value);
374: 374: 374: 374: 374:     emit RefundShare(_for, _value);
375: 375: 375: 375: 375:     _for.transfer(_value);
376: 376: 376: 376: 376:     return true;
377: 377: 377: 377: 377:   }
378: 378: 378: 378: 378:   
379: 379: 379: 379: 379: }
380: 380: 380: 380: 380: 
381: 381: 381: 381: 381: 
382: 382: 382: 382: 382: 