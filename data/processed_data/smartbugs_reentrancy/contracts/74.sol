1: 1: pragma solidity ^0.4.21;
2: 2: 
3: 3: 
4: 4: library strings {
5: 5:     
6: 6:     struct slice {
7: 7:         uint _len;
8: 8:         uint _ptr;
9: 9:     }
10: 10: 
11: 11:     
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16:     function toSlice(string self) internal pure returns (slice) {
17: 17:         uint ptr;
18: 18:         assembly {
19: 19:             ptr := add(self, 0x20)
20: 20:         }
21: 21:         return slice(bytes(self).length, ptr);
22: 22:     }
23: 23: 
24: 24:     function memcpy(uint dest, uint src, uint len) private pure {
25: 25:         
26: 26:         for(; len >= 32; len -= 32) {
27: 27:             assembly {
28: 28:                 mstore(dest, mload(src))
29: 29:             }
30: 30:             dest += 32;
31: 31:             src += 32;
32: 32:         }
33: 33: 
34: 34:         
35: 35:         uint mask = 256 ** (32 - len) - 1;
36: 36:         assembly {
37: 37:             let srcpart := and(mload(src), not(mask))
38: 38:             let destpart := and(mload(dest), mask)
39: 39:             mstore(dest, or(destpart, srcpart))
40: 40:         }
41: 41:     }
42: 42: 
43: 43:     
44: 44:     function concat(slice self, slice other) internal returns (string) {
45: 45:         var ret = new string(self._len + other._len);
46: 46:         uint retptr;
47: 47:         assembly { retptr := add(ret, 32) }
48: 48:         memcpy(retptr, self._ptr, self._len);
49: 49:         memcpy(retptr + self._len, other._ptr, other._len);
50: 50:         return ret;
51: 51:     }
52: 52: 
53: 53:     
54: 54: 
55: 55: 
56: 56: 
57: 57: 
58: 58: 
59: 59:     function count(slice self, slice needle) internal returns (uint cnt) {
60: 60:         uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
61: 61:         while (ptr <= self._ptr + self._len) {
62: 62:             cnt++;
63: 63:             ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
64: 64:         }
65: 65:     }
66: 66: 
67: 67:     
68: 68:     
69: 69:     function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private returns (uint) {
70: 70:         uint ptr;
71: 71:         uint idx;
72: 72: 
73: 73:         if (needlelen <= selflen) {
74: 74:             if (needlelen <= 32) {
75: 75:                 
76: 76:                 assembly {
77: 77:                     let mask := not(sub(exp(2, mul(8, sub(32, needlelen))), 1))
78: 78:                     let needledata := and(mload(needleptr), mask)
79: 79:                     let end := add(selfptr, sub(selflen, needlelen))
80: 80:                     ptr := selfptr
81: 81:                     loop:
82: 82:                     jumpi(exit, eq(and(mload(ptr), mask), needledata))
83: 83:                     ptr := add(ptr, 1)
84: 84:                     jumpi(loop, lt(sub(ptr, 1), end))
85: 85:                     ptr := add(selfptr, selflen)
86: 86:                     exit:
87: 87:                 }
88: 88:                 return ptr;
89: 89:             } else {
90: 90:                 
91: 91:                 bytes32 hash;
92: 92:                 assembly { hash := sha3(needleptr, needlelen) }
93: 93:                 ptr = selfptr;
94: 94:                 for (idx = 0; idx <= selflen - needlelen; idx++) {
95: 95:                     bytes32 testHash;
96: 96:                     assembly { testHash := sha3(ptr, needlelen) }
97: 97:                     if (hash == testHash)
98: 98:                         return ptr;
99: 99:                     ptr += 1;
100: 100:                 }
101: 101:             }
102: 102:         }
103: 103:         return selfptr + selflen;
104: 104:     }
105: 105: 
106: 106:     
107: 107: 
108: 108: 
109: 109: 
110: 110: 
111: 111: 
112: 112: 
113: 113: 
114: 114: 
115: 115: 
116: 116:     function split(slice self, slice needle, slice token) internal returns (slice) {
117: 117:         uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
118: 118:         token._ptr = self._ptr;
119: 119:         token._len = ptr - self._ptr;
120: 120:         if (ptr == self._ptr + self._len) {
121: 121:             
122: 122:             self._len = 0;
123: 123:         } else {
124: 124:             self._len -= token._len + needle._len;
125: 125:             self._ptr = ptr + needle._len;
126: 126:         }
127: 127:         return token;
128: 128:     }
129: 129: 
130: 130:      
131: 131: 
132: 132: 
133: 133: 
134: 134: 
135: 135: 
136: 136: 
137: 137: 
138: 138: 
139: 139:     function split(slice self, slice needle) internal returns (slice token) {
140: 140:         split(self, needle, token);
141: 141:     }
142: 142: 
143: 143:     
144: 144: 
145: 145: 
146: 146: 
147: 147: 
148: 148:     function toString(slice self) internal pure returns (string) {
149: 149:         var ret = new string(self._len);
150: 150:         uint retptr;
151: 151:         assembly { retptr := add(ret, 32) }
152: 152: 
153: 153:         memcpy(retptr, self._ptr, self._len);
154: 154:         return ret;
155: 155:     }
156: 156: 
157: 157: }
158: 158: 
159: 159: 
160: 160: 
161: 161: 
162: 162: 
163: 163: contract ERC827Token is ERC827, StandardToken {
164: 164: 
165: 165:   
166: 166: 
167: 167: 
168: 168: 
169: 169: 
170: 170: 
171: 171: 
172: 172: 
173: 173: 
174: 174: 
175: 175: 
176: 176: 
177: 177: 
178: 178: 
179: 179: 
180: 180: 
181: 181: 
182: 182:   function approveAndCall(address _spender, uint256 _value, bytes _data) public payable returns (bool) {
183: 183:     require(_spender != address(this));
184: 184: 
185: 185:     super.approve(_spender, _value);
186: 186: 
187: 187:     
188: 188:     require(_spender.call.value(msg.value)(_data));
189: 189: 
190: 190:     return true;
191: 191:   }
192: 192: 
193: 193:   
194: 194: 
195: 195: 
196: 196: 
197: 197: 
198: 198: 
199: 199: 
200: 200: 
201: 201: 
202: 202: 
203: 203:   function transferAndCall(address _to, uint256 _value, bytes _data) public payable returns (bool) {
204: 204:     require(_to != address(this));
205: 205: 
206: 206:     super.transfer(_to, _value);
207: 207: 
208: 208:     
209: 209:     require(_to.call.value(msg.value)(_data));
210: 210:     return true;
211: 211:   }
212: 212: 
213: 213:   
214: 214: 
215: 215: 
216: 216: 
217: 217: 
218: 218: 
219: 219: 
220: 220: 
221: 221: 
222: 222: 
223: 223: 
224: 224:   function transferFromAndCall(
225: 225:     address _from,
226: 226:     address _to,
227: 227:     uint256 _value,
228: 228:     bytes _data
229: 229:   )
230: 230:     public payable returns (bool)
231: 231:   {
232: 232:     require(_to != address(this));
233: 233: 
234: 234:     super.transferFrom(_from, _to, _value);
235: 235: 
236: 236:     
237: 237:     require(_to.call.value(msg.value)(_data));
238: 238:     return true;
239: 239:   }
240: 240: 
241: 241:   
242: 242: 
243: 243: 
244: 244: 
245: 245: 
246: 246: 
247: 247: 
248: 248: 
249: 249: 
250: 250: 
251: 251: 
252: 252: 
253: 253: 
254: 254:   function increaseApprovalAndCall(address _spender, uint _addedValue, bytes _data) public payable returns (bool) {
255: 255:     require(_spender != address(this));
256: 256: 
257: 257:     super.increaseApproval(_spender, _addedValue);
258: 258: 
259: 259:     
260: 260:     require(_spender.call.value(msg.value)(_data));
261: 261: 
262: 262:     return true;
263: 263:   }
264: 264: 
265: 265:   
266: 266: 
267: 267: 
268: 268: 
269: 269: 
270: 270: 
271: 271: 
272: 272: 
273: 273: 
274: 274: 
275: 275: 
276: 276: 
277: 277: 
278: 278:   function decreaseApprovalAndCall(address _spender, uint _subtractedValue, bytes _data) public payable returns (bool) {
279: 279:     require(_spender != address(this));
280: 280: 
281: 281:     super.decreaseApproval(_spender, _subtractedValue);
282: 282: 
283: 283:     
284: 284:     require(_spender.call.value(msg.value)(_data));
285: 285: 
286: 286:     return true;
287: 287:   }
288: 288: 
289: 289: }
290: 290: 
291: 291: 
292: 292:  
293: 293: 
294: 294: 
295: 295: 
296: 296: 
297: 297: 
298: 298: 
299: 299: 
300: 300: 