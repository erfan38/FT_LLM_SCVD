1: 1: 1: 1: 1: 
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: library GroveLib {
7: 7: 7: 7: 7:         
8: 8: 8: 8: 8: 
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10: 
11: 11: 11: 11: 11: 
12: 12: 12: 12: 12:         struct Index {
13: 13: 13: 13: 13:                 bytes32 root;
14: 14: 14: 14: 14:                 mapping (bytes32 => Node) nodes;
15: 15: 15: 15: 15:         }
16: 16: 16: 16: 16: 
17: 17: 17: 17: 17:         struct Node {
18: 18: 18: 18: 18:                 bytes32 id;
19: 19: 19: 19: 19:                 int value;
20: 20: 20: 20: 20:                 bytes32 parent;
21: 21: 21: 21: 21:                 bytes32 left;
22: 22: 22: 22: 22:                 bytes32 right;
23: 23: 23: 23: 23:                 uint height;
24: 24: 24: 24: 24:         }
25: 25: 25: 25: 25: 
26: 26: 26: 26: 26:         function max(uint a, uint b) internal returns (uint) {
27: 27: 27: 27: 27:             if (a >= b) {
28: 28: 28: 28: 28:                 return a;
29: 29: 29: 29: 29:             }
30: 30: 30: 30: 30:             return b;
31: 31: 31: 31: 31:         }
32: 32: 32: 32: 32: 
33: 33: 33: 33: 33:         
34: 34: 34: 34: 34: 
35: 35: 35: 35: 35: 
36: 36: 36: 36: 36:         
37: 37: 37: 37: 37:         
38: 38: 38: 38: 38:         
39: 39: 39: 39: 39:         function getNodeId(Index storage index, bytes32 id) constant returns (bytes32) {
40: 40: 40: 40: 40:             return index.nodes[id].id;
41: 41: 41: 41: 41:         }
42: 42: 42: 42: 42: 
43: 43: 43: 43: 43:         
44: 44: 44: 44: 44:         
45: 45: 45: 45: 45:         
46: 46: 46: 46: 46:         function getNodeValue(Index storage index, bytes32 id) constant returns (int) {
47: 47: 47: 47: 47:             return index.nodes[id].value;
48: 48: 48: 48: 48:         }
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50:         
51: 51: 51: 51: 51:         
52: 52: 52: 52: 52:         
53: 53: 53: 53: 53:         function getNodeHeight(Index storage index, bytes32 id) constant returns (uint) {
54: 54: 54: 54: 54:             return index.nodes[id].height;
55: 55: 55: 55: 55:         }
56: 56: 56: 56: 56: 
57: 57: 57: 57: 57:         
58: 58: 58: 58: 58:         
59: 59: 59: 59: 59:         
60: 60: 60: 60: 60:         function getNodeParent(Index storage index, bytes32 id) constant returns (bytes32) {
61: 61: 61: 61: 61:             return index.nodes[id].parent;
62: 62: 62: 62: 62:         }
63: 63: 63: 63: 63: 
64: 64: 64: 64: 64:         
65: 65: 65: 65: 65:         
66: 66: 66: 66: 66:         
67: 67: 67: 67: 67:         function getNodeLeftChild(Index storage index, bytes32 id) constant returns (bytes32) {
68: 68: 68: 68: 68:             return index.nodes[id].left;
69: 69: 69: 69: 69:         }
70: 70: 70: 70: 70: 
71: 71: 71: 71: 71:         
72: 72: 72: 72: 72:         
73: 73: 73: 73: 73:         
74: 74: 74: 74: 74:         function getNodeRightChild(Index storage index, bytes32 id) constant returns (bytes32) {
75: 75: 75: 75: 75:             return index.nodes[id].right;
76: 76: 76: 76: 76:         }
77: 77: 77: 77: 77: 
78: 78: 78: 78: 78:         
79: 79: 79: 79: 79:         
80: 80: 80: 80: 80:         
81: 81: 81: 81: 81:         function getPreviousNode(Index storage index, bytes32 id) constant returns (bytes32) {
82: 82: 82: 82: 82:             Node storage currentNode = index.nodes[id];
83: 83: 83: 83: 83: 
84: 84: 84: 84: 84:             if (currentNode.id == 0x0) {
85: 85: 85: 85: 85:                 
86: 86: 86: 86: 86:                 return 0x0;
87: 87: 87: 87: 87:             }
88: 88: 88: 88: 88: 
89: 89: 89: 89: 89:             Node memory child;
90: 90: 90: 90: 90: 
91: 91: 91: 91: 91:             if (currentNode.left != 0x0) {
92: 92: 92: 92: 92:                 
93: 93: 93: 93: 93:                 child = index.nodes[currentNode.left];
94: 94: 94: 94: 94: 
95: 95: 95: 95: 95:                 while (child.right != 0) {
96: 96: 96: 96: 96:                     child = index.nodes[child.right];
97: 97: 97: 97: 97:                 }
98: 98: 98: 98: 98:                 return child.id;
99: 99: 99: 99: 99:             }
100: 100: 100: 100: 100: 
101: 101: 101: 101: 101:             if (currentNode.parent != 0x0) {
102: 102: 102: 102: 102:                 
103: 103: 103: 103: 103:                 
104: 104: 104: 104: 104:                 
105: 105: 105: 105: 105:                 Node storage parent = index.nodes[currentNode.parent];
106: 106: 106: 106: 106:                 child = currentNode;
107: 107: 107: 107: 107: 
108: 108: 108: 108: 108:                 while (true) {
109: 109: 109: 109: 109:                     if (parent.right == child.id) {
110: 110: 110: 110: 110:                         return parent.id;
111: 111: 111: 111: 111:                     }
112: 112: 112: 112: 112: 
113: 113: 113: 113: 113:                     if (parent.parent == 0x0) {
114: 114: 114: 114: 114:                         break;
115: 115: 115: 115: 115:                     }
116: 116: 116: 116: 116:                     child = parent;
117: 117: 117: 117: 117:                     parent = index.nodes[parent.parent];
118: 118: 118: 118: 118:                 }
119: 119: 119: 119: 119:             }
120: 120: 120: 120: 120: 
121: 121: 121: 121: 121:             
122: 122: 122: 122: 122:             return 0x0;
123: 123: 123: 123: 123:         }
124: 124: 124: 124: 124: 
125: 125: 125: 125: 125:         
126: 126: 126: 126: 126:         
127: 127: 127: 127: 127:         
128: 128: 128: 128: 128:         function getNextNode(Index storage index, bytes32 id) constant returns (bytes32) {
129: 129: 129: 129: 129:             Node storage currentNode = index.nodes[id];
130: 130: 130: 130: 130: 
131: 131: 131: 131: 131:             if (currentNode.id == 0x0) {
132: 132: 132: 132: 132:                 
133: 133: 133: 133: 133:                 return 0x0;
134: 134: 134: 134: 134:             }
135: 135: 135: 135: 135: 
136: 136: 136: 136: 136:             Node memory child;
137: 137: 137: 137: 137: 
138: 138: 138: 138: 138:             if (currentNode.right != 0x0) {
139: 139: 139: 139: 139:                 
140: 140: 140: 140: 140:                 child = index.nodes[currentNode.right];
141: 141: 141: 141: 141: 
142: 142: 142: 142: 142:                 while (child.left != 0) {
143: 143: 143: 143: 143:                     child = index.nodes[child.left];
144: 144: 144: 144: 144:                 }
145: 145: 145: 145: 145:                 return child.id;
146: 146: 146: 146: 146:             }
147: 147: 147: 147: 147: 
148: 148: 148: 148: 148:             if (currentNode.parent != 0x0) {
149: 149: 149: 149: 149:                 
150: 150: 150: 150: 150:                 
151: 151: 151: 151: 151:                 Node storage parent = index.nodes[currentNode.parent];
152: 152: 152: 152: 152:                 child = currentNode;
153: 153: 153: 153: 153: 
154: 154: 154: 154: 154:                 while (true) {
155: 155: 155: 155: 155:                     if (parent.left == child.id) {
156: 156: 156: 156: 156:                         return parent.id;
157: 157: 157: 157: 157:                     }
158: 158: 158: 158: 158: 
159: 159: 159: 159: 159:                     if (parent.parent == 0x0) {
160: 160: 160: 160: 160:                         break;
161: 161: 161: 161: 161:                     }
162: 162: 162: 162: 162:                     child = parent;
163: 163: 163: 163: 163:                     parent = index.nodes[parent.parent];
164: 164: 164: 164: 164:                 }
165: 165: 165: 165: 165: 
166: 166: 166: 166: 166:                 
167: 167: 167: 167: 167:             }
168: 168: 168: 168: 168: 
169: 169: 169: 169: 169:             
170: 170: 170: 170: 170:             return 0x0;
171: 171: 171: 171: 171:         }
172: 172: 172: 172: 172: 
173: 173: 173: 173: 173: 
174: 174: 174: 174: 174:         
175: 175: 175: 175: 175:         
176: 176: 176: 176: 176:         
177: 177: 177: 177: 177:         
178: 178: 178: 178: 178:         function insert(Index storage index, bytes32 id, int value) public {
179: 179: 179: 179: 179:                 if (index.nodes[id].id == id) {
180: 180: 180: 180: 180:                     
181: 181: 181: 181: 181:                     
182: 182: 182: 182: 182:                     
183: 183: 183: 183: 183:                     if (index.nodes[id].value == value) {
184: 184: 184: 184: 184:                         return;
185: 185: 185: 185: 185:                     }
186: 186: 186: 186: 186:                     remove(index, id);
187: 187: 187: 187: 187:                 }
188: 188: 188: 188: 188: 
189: 189: 189: 189: 189:                 uint leftHeight;
190: 190: 190: 190: 190:                 uint rightHeight;
191: 191: 191: 191: 191: 
192: 192: 192: 192: 192:                 bytes32 previousNodeId = 0x0;
193: 193: 193: 193: 193: 
194: 194: 194: 194: 194:                 if (index.root == 0x0) {
195: 195: 195: 195: 195:                     index.root = id;
196: 196: 196: 196: 196:                 }
197: 197: 197: 197: 197:                 Node storage currentNode = index.nodes[index.root];
198: 198: 198: 198: 198: 
199: 199: 199: 199: 199:                 
200: 200: 200: 200: 200:                 while (true) {
201: 201: 201: 201: 201:                     if (currentNode.id == 0x0) {
202: 202: 202: 202: 202:                         
203: 203: 203: 203: 203:                         currentNode.id = id;
204: 204: 204: 204: 204:                         currentNode.parent = previousNodeId;
205: 205: 205: 205: 205:                         currentNode.value = value;
206: 206: 206: 206: 206:                         break;
207: 207: 207: 207: 207:                     }
208: 208: 208: 208: 208: 
209: 209: 209: 209: 209:                     
210: 210: 210: 210: 210:                     previousNodeId = currentNode.id;
211: 211: 211: 211: 211: 
212: 212: 212: 212: 212:                     
213: 213: 213: 213: 213:                     if (value >= currentNode.value) {
214: 214: 214: 214: 214:                         if (currentNode.right == 0x0) {
215: 215: 215: 215: 215:                             currentNode.right = id;
216: 216: 216: 216: 216:                         }
217: 217: 217: 217: 217:                         currentNode = index.nodes[currentNode.right];
218: 218: 218: 218: 218:                         continue;
219: 219: 219: 219: 219:                     }
220: 220: 220: 220: 220: 
221: 221: 221: 221: 221:                     
222: 222: 222: 222: 222:                     if (currentNode.left == 0x0) {
223: 223: 223: 223: 223:                         currentNode.left = id;
224: 224: 224: 224: 224:                     }
225: 225: 225: 225: 225:                     currentNode = index.nodes[currentNode.left];
226: 226: 226: 226: 226:                 }
227: 227: 227: 227: 227: 
228: 228: 228: 228: 228:                 
229: 229: 229: 229: 229:                 _rebalanceTree(index, currentNode.id);
230: 230: 230: 230: 230:         }
231: 231: 231: 231: 231: 
232: 232: 232: 232: 232:         
233: 233: 233: 233: 233:         
234: 234: 234: 234: 234:         
235: 235: 235: 235: 235:         function exists(Index storage index, bytes32 id) constant returns (bool) {
236: 236: 236: 236: 236:             return (index.nodes[id].height > 0);
237: 237: 237: 237: 237:         }
238: 238: 238: 238: 238: 
239: 239: 239: 239: 239:         
240: 240: 240: 240: 240:         
241: 241: 241: 241: 241:         
242: 242: 242: 242: 242:         function remove(Index storage index, bytes32 id) public {
243: 243: 243: 243: 243:             Node storage replacementNode;
244: 244: 244: 244: 244:             Node storage parent;
245: 245: 245: 245: 245:             Node storage child;
246: 246: 246: 246: 246:             bytes32 rebalanceOrigin;
247: 247: 247: 247: 247: 
248: 248: 248: 248: 248:             Node storage nodeToDelete = index.nodes[id];
249: 249: 249: 249: 249: 
250: 250: 250: 250: 250:             if (nodeToDelete.id != id) {
251: 251: 251: 251: 251:                 
252: 252: 252: 252: 252:                 return;
253: 253: 253: 253: 253:             }
254: 254: 254: 254: 254: 
255: 255: 255: 255: 255:             if (nodeToDelete.left != 0x0 || nodeToDelete.right != 0x0) {
256: 256: 256: 256: 256:                 
257: 257: 257: 257: 257:                 
258: 258: 258: 258: 258:                 if (nodeToDelete.left != 0x0) {
259: 259: 259: 259: 259:                     
260: 260: 260: 260: 260:                     replacementNode = index.nodes[getPreviousNode(index, nodeToDelete.id)];
261: 261: 261: 261: 261:                 }
262: 262: 262: 262: 262:                 else {
263: 263: 263: 263: 263:                     
264: 264: 264: 264: 264:                     replacementNode = index.nodes[getNextNode(index, nodeToDelete.id)];
265: 265: 265: 265: 265:                 }
266: 266: 266: 266: 266:                 
267: 267: 267: 267: 267:                 parent = index.nodes[replacementNode.parent];
268: 268: 268: 268: 268: 
269: 269: 269: 269: 269:                 
270: 270: 270: 270: 270:                 
271: 271: 271: 271: 271:                 rebalanceOrigin = replacementNode.id;
272: 272: 272: 272: 272: 
273: 273: 273: 273: 273:                 
274: 274: 274: 274: 274:                 
275: 275: 275: 275: 275:                 
276: 276: 276: 276: 276:                 
277: 277: 277: 277: 277:                 if (parent.left == replacementNode.id) {
278: 278: 278: 278: 278:                     parent.left = replacementNode.right;
279: 279: 279: 279: 279:                     if (replacementNode.right != 0x0) {
280: 280: 280: 280: 280:                         child = index.nodes[replacementNode.right];
281: 281: 281: 281: 281:                         child.parent = parent.id;
282: 282: 282: 282: 282:                     }
283: 283: 283: 283: 283:                 }
284: 284: 284: 284: 284:                 if (parent.right == replacementNode.id) {
285: 285: 285: 285: 285:                     parent.right = replacementNode.left;
286: 286: 286: 286: 286:                     if (replacementNode.left != 0x0) {
287: 287: 287: 287: 287:                         child = index.nodes[replacementNode.left];
288: 288: 288: 288: 288:                         child.parent = parent.id;
289: 289: 289: 289: 289:                     }
290: 290: 290: 290: 290:                 }
291: 291: 291: 291: 291: 
292: 292: 292: 292: 292:                 
293: 293: 293: 293: 293:                 
294: 294: 294: 294: 294:                 
295: 295: 295: 295: 295:                 replacementNode.parent = nodeToDelete.parent;
296: 296: 296: 296: 296:                 if (nodeToDelete.parent != 0x0) {
297: 297: 297: 297: 297:                     parent = index.nodes[nodeToDelete.parent];
298: 298: 298: 298: 298:                     if (parent.left == nodeToDelete.id) {
299: 299: 299: 299: 299:                         parent.left = replacementNode.id;
300: 300: 300: 300: 300:                     }
301: 301: 301: 301: 301:                     if (parent.right == nodeToDelete.id) {
302: 302: 302: 302: 302:                         parent.right = replacementNode.id;
303: 303: 303: 303: 303:                     }
304: 304: 304: 304: 304:                 }
305: 305: 305: 305: 305:                 else {
306: 306: 306: 306: 306:                     
307: 307: 307: 307: 307:                     
308: 308: 308: 308: 308:                     index.root = replacementNode.id;
309: 309: 309: 309: 309:                 }
310: 310: 310: 310: 310: 
311: 311: 311: 311: 311:                 replacementNode.left = nodeToDelete.left;
312: 312: 312: 312: 312:                 if (nodeToDelete.left != 0x0) {
313: 313: 313: 313: 313:                     child = index.nodes[nodeToDelete.left];
314: 314: 314: 314: 314:                     child.parent = replacementNode.id;
315: 315: 315: 315: 315:                 }
316: 316: 316: 316: 316: 
317: 317: 317: 317: 317:                 replacementNode.right = nodeToDelete.right;
318: 318: 318: 318: 318:                 if (nodeToDelete.right != 0x0) {
319: 319: 319: 319: 319:                     child = index.nodes[nodeToDelete.right];
320: 320: 320: 320: 320:                     child.parent = replacementNode.id;
321: 321: 321: 321: 321:                 }
322: 322: 322: 322: 322:             }
323: 323: 323: 323: 323:             else if (nodeToDelete.parent != 0x0) {
324: 324: 324: 324: 324:                 
325: 325: 325: 325: 325:                 
326: 326: 326: 326: 326:                 parent = index.nodes[nodeToDelete.parent];
327: 327: 327: 327: 327: 
328: 328: 328: 328: 328:                 if (parent.left == nodeToDelete.id) {
329: 329: 329: 329: 329:                     parent.left = 0x0;
330: 330: 330: 330: 330:                 }
331: 331: 331: 331: 331:                 if (parent.right == nodeToDelete.id) {
332: 332: 332: 332: 332:                     parent.right = 0x0;
333: 333: 333: 333: 333:                 }
334: 334: 334: 334: 334: 
335: 335: 335: 335: 335:                 
336: 336: 336: 336: 336:                 rebalanceOrigin = parent.id;
337: 337: 337: 337: 337:             }
338: 338: 338: 338: 338:             else {
339: 339: 339: 339: 339:                 
340: 340: 340: 340: 340:                 
341: 341: 341: 341: 341:                 index.root = 0x0;
342: 342: 342: 342: 342:             }
343: 343: 343: 343: 343: 
344: 344: 344: 344: 344:             
345: 345: 345: 345: 345:             nodeToDelete.id = 0x0;
346: 346: 346: 346: 346:             nodeToDelete.value = 0;
347: 347: 347: 347: 347:             nodeToDelete.parent = 0x0;
348: 348: 348: 348: 348:             nodeToDelete.left = 0x0;
349: 349: 349: 349: 349:             nodeToDelete.right = 0x0;
350: 350: 350: 350: 350:             nodeToDelete.height = 0;
351: 351: 351: 351: 351: 
352: 352: 352: 352: 352:             
353: 353: 353: 353: 353:             if (rebalanceOrigin != 0x0) {
354: 354: 354: 354: 354:                 _rebalanceTree(index, rebalanceOrigin);
355: 355: 355: 355: 355:             }
356: 356: 356: 356: 356:         }
357: 357: 357: 357: 357: 
358: 358: 358: 358: 358:         bytes2 constant GT = ">";
359: 359: 359: 359: 359:         bytes2 constant LT = "<";
360: 360: 360: 360: 360:         bytes2 constant GTE = ">=";
361: 361: 361: 361: 361:         bytes2 constant LTE = "<=";
362: 362: 362: 362: 362:         bytes2 constant EQ = "==";
363: 363: 363: 363: 363: 
364: 364: 364: 364: 364:         function _compare(int left, bytes2 operator, int right) internal returns (bool) {
365: 365: 365: 365: 365:             if (operator == GT) {
366: 366: 366: 366: 366:                 return (left > right);
367: 367: 367: 367: 367:             }
368: 368: 368: 368: 368:             if (operator == LT) {
369: 369: 369: 369: 369:                 return (left < right);
370: 370: 370: 370: 370:             }
371: 371: 371: 371: 371:             if (operator == GTE) {
372: 372: 372: 372: 372:                 return (left >= right);
373: 373: 373: 373: 373:             }
374: 374: 374: 374: 374:             if (operator == LTE) {
375: 375: 375: 375: 375:                 return (left <= right);
376: 376: 376: 376: 376:             }
377: 377: 377: 377: 377:             if (operator == EQ) {
378: 378: 378: 378: 378:                 return (left == right);
379: 379: 379: 379: 379:             }
380: 380: 380: 380: 380: 
381: 381: 381: 381: 381:             
382: 382: 382: 382: 382:             throw;
383: 383: 383: 383: 383:         }
384: 384: 384: 384: 384: 
385: 385: 385: 385: 385:         function _getMaximum(Index storage index, bytes32 id) internal returns (int) {
386: 386: 386: 386: 386:                 Node storage currentNode = index.nodes[id];
387: 387: 387: 387: 387: 
388: 388: 388: 388: 388:                 while (true) {
389: 389: 389: 389: 389:                     if (currentNode.right == 0x0) {
390: 390: 390: 390: 390:                         return currentNode.value;
391: 391: 391: 391: 391:                     }
392: 392: 392: 392: 392:                     currentNode = index.nodes[currentNode.right];
393: 393: 393: 393: 393:                 }
394: 394: 394: 394: 394:         }
395: 395: 395: 395: 395: 
396: 396: 396: 396: 396:         function _getMinimum(Index storage index, bytes32 id) internal returns (int) {
397: 397: 397: 397: 397:                 Node storage currentNode = index.nodes[id];
398: 398: 398: 398: 398: 
399: 399: 399: 399: 399:                 while (true) {
400: 400: 400: 400: 400:                     if (currentNode.left == 0x0) {
401: 401: 401: 401: 401:                         return currentNode.value;
402: 402: 402: 402: 402:                     }
403: 403: 403: 403: 403:                     currentNode = index.nodes[currentNode.left];
404: 404: 404: 404: 404:                 }
405: 405: 405: 405: 405:         }
406: 406: 406: 406: 406: 
407: 407: 407: 407: 407: 
408: 408: 408: 408: 408:         
409: 409: 409: 409: 409: 
410: 410: 410: 410: 410: 
411: 411: 411: 411: 411: 
412: 412: 412: 412: 412: 
413: 413: 413: 413: 413:         
414: 414: 414: 414: 414:         
415: 415: 415: 415: 415: 
416: 416: 416: 416: 416: 
417: 417: 417: 417: 417:         function query(Index storage index, bytes2 operator, int value) public returns (bytes32) {
418: 418: 418: 418: 418:                 bytes32 rootNodeId = index.root;
419: 419: 419: 419: 419: 
420: 420: 420: 420: 420:                 if (rootNodeId == 0x0) {
421: 421: 421: 421: 421:                     
422: 422: 422: 422: 422:                     return 0x0;
423: 423: 423: 423: 423:                 }
424: 424: 424: 424: 424: 
425: 425: 425: 425: 425:                 Node storage currentNode = index.nodes[rootNodeId];
426: 426: 426: 426: 426: 
427: 427: 427: 427: 427:                 while (true) {
428: 428: 428: 428: 428:                     if (_compare(currentNode.value, operator, value)) {
429: 429: 429: 429: 429:                         
430: 430: 430: 430: 430:                         
431: 431: 431: 431: 431:                         if ((operator == LT) || (operator == LTE)) {
432: 432: 432: 432: 432:                             
433: 433: 433: 433: 433:                             
434: 434: 434: 434: 434:                             if (currentNode.right == 0x0) {
435: 435: 435: 435: 435:                                 return currentNode.id;
436: 436: 436: 436: 436:                             }
437: 437: 437: 437: 437:                             if (_compare(_getMinimum(index, currentNode.right), operator, value)) {
438: 438: 438: 438: 438:                                 
439: 439: 439: 439: 439:                                 
440: 440: 440: 440: 440:                                 currentNode = index.nodes[currentNode.right];
441: 441: 441: 441: 441:                                 continue;
442: 442: 442: 442: 442:                             }
443: 443: 443: 443: 443:                             return currentNode.id;
444: 444: 444: 444: 444:                         }
445: 445: 445: 445: 445: 
446: 446: 446: 446: 446:                         if ((operator == GT) || (operator == GTE) || (operator == EQ)) {
447: 447: 447: 447: 447:                             
448: 448: 448: 448: 448:                             
449: 449: 449: 449: 449:                             if (currentNode.left == 0x0) {
450: 450: 450: 450: 450:                                 return currentNode.id;
451: 451: 451: 451: 451:                             }
452: 452: 452: 452: 452:                             if (_compare(_getMaximum(index, currentNode.left), operator, value)) {
453: 453: 453: 453: 453:                                 currentNode = index.nodes[currentNode.left];
454: 454: 454: 454: 454:                                 continue;
455: 455: 455: 455: 455:                             }
456: 456: 456: 456: 456:                             return currentNode.id;
457: 457: 457: 457: 457:                         }
458: 458: 458: 458: 458:                     }
459: 459: 459: 459: 459: 
460: 460: 460: 460: 460:                     if ((operator == LT) || (operator == LTE)) {
461: 461: 461: 461: 461:                         if (currentNode.left == 0x0) {
462: 462: 462: 462: 462:                             
463: 463: 463: 463: 463:                             
464: 464: 464: 464: 464:                             return 0x0;
465: 465: 465: 465: 465:                         }
466: 466: 466: 466: 466:                         currentNode = index.nodes[currentNode.left];
467: 467: 467: 467: 467:                         continue;
468: 468: 468: 468: 468:                     }
469: 469: 469: 469: 469: 
470: 470: 470: 470: 470:                     if ((operator == GT) || (operator == GTE)) {
471: 471: 471: 471: 471:                         if (currentNode.right == 0x0) {
472: 472: 472: 472: 472:                             
473: 473: 473: 473: 473:                             
474: 474: 474: 474: 474:                             return 0x0;
475: 475: 475: 475: 475:                         }
476: 476: 476: 476: 476:                         currentNode = index.nodes[currentNode.right];
477: 477: 477: 477: 477:                         continue;
478: 478: 478: 478: 478:                     }
479: 479: 479: 479: 479: 
480: 480: 480: 480: 480:                     if (operator == EQ) {
481: 481: 481: 481: 481:                         if (currentNode.value < value) {
482: 482: 482: 482: 482:                             if (currentNode.right == 0x0) {
483: 483: 483: 483: 483:                                 return 0x0;
484: 484: 484: 484: 484:                             }
485: 485: 485: 485: 485:                             currentNode = index.nodes[currentNode.right];
486: 486: 486: 486: 486:                             continue;
487: 487: 487: 487: 487:                         }
488: 488: 488: 488: 488: 
489: 489: 489: 489: 489:                         if (currentNode.value > value) {
490: 490: 490: 490: 490:                             if (currentNode.left == 0x0) {
491: 491: 491: 491: 491:                                 return 0x0;
492: 492: 492: 492: 492:                             }
493: 493: 493: 493: 493:                             currentNode = index.nodes[currentNode.left];
494: 494: 494: 494: 494:                             continue;
495: 495: 495: 495: 495:                         }
496: 496: 496: 496: 496:                     }
497: 497: 497: 497: 497:                 }
498: 498: 498: 498: 498:         }
499: 499: 499: 499: 499: 
500: 500: 500: 500: 500:         function _rebalanceTree(Index storage index, bytes32 id) internal {
501: 501: 501: 501: 501:             
502: 502: 502: 502: 502:             
503: 503: 503: 503: 503:             Node storage currentNode = index.nodes[id];
504: 504: 504: 504: 504: 
505: 505: 505: 505: 505:             while (true) {
506: 506: 506: 506: 506:                 int balanceFactor = _getBalanceFactor(index, currentNode.id);
507: 507: 507: 507: 507: 
508: 508: 508: 508: 508:                 if (balanceFactor == 2) {
509: 509: 509: 509: 509:                     
510: 510: 510: 510: 510:                     if (_getBalanceFactor(index, currentNode.left) == -1) {
511: 511: 511: 511: 511:                         
512: 512: 512: 512: 512:                         
513: 513: 513: 513: 513:                         
514: 514: 514: 514: 514:                         _rotateLeft(index, currentNode.left);
515: 515: 515: 515: 515:                     }
516: 516: 516: 516: 516:                     _rotateRight(index, currentNode.id);
517: 517: 517: 517: 517:                 }
518: 518: 518: 518: 518: 
519: 519: 519: 519: 519:                 if (balanceFactor == -2) {
520: 520: 520: 520: 520:                     
521: 521: 521: 521: 521:                     if (_getBalanceFactor(index, currentNode.right) == 1) {
522: 522: 522: 522: 522:                         
523: 523: 523: 523: 523:                         
524: 524: 524: 524: 524:                         
525: 525: 525: 525: 525:                         _rotateRight(index, currentNode.right);
526: 526: 526: 526: 526:                     }
527: 527: 527: 527: 527:                     _rotateLeft(index, currentNode.id);
528: 528: 528: 528: 528:                 }
529: 529: 529: 529: 529: 
530: 530: 530: 530: 530:                 if ((-1 <= balanceFactor) && (balanceFactor <= 1)) {
531: 531: 531: 531: 531:                     _updateNodeHeight(index, currentNode.id);
532: 532: 532: 532: 532:                 }
533: 533: 533: 533: 533: 
534: 534: 534: 534: 534:                 if (currentNode.parent == 0x0) {
535: 535: 535: 535: 535:                     
536: 536: 536: 536: 536:                     
537: 537: 537: 537: 537:                     break;
538: 538: 538: 538: 538:                 }
539: 539: 539: 539: 539: 
540: 540: 540: 540: 540:                 currentNode = index.nodes[currentNode.parent];
541: 541: 541: 541: 541:             }
542: 542: 542: 542: 542:         }
543: 543: 543: 543: 543: 
544: 544: 544: 544: 544:         function _getBalanceFactor(Index storage index, bytes32 id) internal returns (int) {
545: 545: 545: 545: 545:                 Node storage node = index.nodes[id];
546: 546: 546: 546: 546: 
547: 547: 547: 547: 547:                 return int(index.nodes[node.left].height) - int(index.nodes[node.right].height);
548: 548: 548: 548: 548:         }
549: 549: 549: 549: 549: 
550: 550: 550: 550: 550:         function _updateNodeHeight(Index storage index, bytes32 id) internal {
551: 551: 551: 551: 551:                 Node storage node = index.nodes[id];
552: 552: 552: 552: 552: 
553: 553: 553: 553: 553:                 node.height = max(index.nodes[node.left].height, index.nodes[node.right].height) + 1;
554: 554: 554: 554: 554:         }
555: 555: 555: 555: 555: 
556: 556: 556: 556: 556:         function _rotateLeft(Index storage index, bytes32 id) internal {
557: 557: 557: 557: 557:             Node storage originalRoot = index.nodes[id];
558: 558: 558: 558: 558: 
559: 559: 559: 559: 559:             if (originalRoot.right == 0x0) {
560: 560: 560: 560: 560:                 
561: 561: 561: 561: 561:                 
562: 562: 562: 562: 562:                 throw;
563: 563: 563: 563: 563:             }
564: 564: 564: 564: 564: 
565: 565: 565: 565: 565:             
566: 566: 566: 566: 566:             
567: 567: 567: 567: 567:             Node storage newRoot = index.nodes[originalRoot.right];
568: 568: 568: 568: 568:             newRoot.parent = originalRoot.parent;
569: 569: 569: 569: 569: 
570: 570: 570: 570: 570:             
571: 571: 571: 571: 571:             originalRoot.right = 0x0;
572: 572: 572: 572: 572: 
573: 573: 573: 573: 573:             if (originalRoot.parent != 0x0) {
574: 574: 574: 574: 574:                 
575: 575: 575: 575: 575:                 
576: 576: 576: 576: 576:                 Node storage parent = index.nodes[originalRoot.parent];
577: 577: 577: 577: 577: 
578: 578: 578: 578: 578:                 
579: 579: 579: 579: 579:                 
580: 580: 580: 580: 580:                 if (parent.left == originalRoot.id) {
581: 581: 581: 581: 581:                     parent.left = newRoot.id;
582: 582: 582: 582: 582:                 }
583: 583: 583: 583: 583:                 if (parent.right == originalRoot.id) {
584: 584: 584: 584: 584:                     parent.right = newRoot.id;
585: 585: 585: 585: 585:                 }
586: 586: 586: 586: 586:             }
587: 587: 587: 587: 587: 
588: 588: 588: 588: 588: 
589: 589: 589: 589: 589:             if (newRoot.left != 0) {
590: 590: 590: 590: 590:                 
591: 591: 591: 591: 591:                 
592: 592: 592: 592: 592:                 Node storage leftChild = index.nodes[newRoot.left];
593: 593: 593: 593: 593:                 originalRoot.right = leftChild.id;
594: 594: 594: 594: 594:                 leftChild.parent = originalRoot.id;
595: 595: 595: 595: 595:             }
596: 596: 596: 596: 596: 
597: 597: 597: 597: 597:             
598: 598: 598: 598: 598:             originalRoot.parent = newRoot.id;
599: 599: 599: 599: 599:             newRoot.left = originalRoot.id;
600: 600: 600: 600: 600: 
601: 601: 601: 601: 601:             if (newRoot.parent == 0x0) {
602: 602: 602: 602: 602:                 index.root = newRoot.id;
603: 603: 603: 603: 603:             }
604: 604: 604: 604: 604: 
605: 605: 605: 605: 605:             
606: 606: 606: 606: 606:             _updateNodeHeight(index, originalRoot.id);
607: 607: 607: 607: 607:             _updateNodeHeight(index, newRoot.id);
608: 608: 608: 608: 608:         }
609: 609: 609: 609: 609: 
610: 610: 610: 610: 610:         function _rotateRight(Index storage index, bytes32 id) internal {
611: 611: 611: 611: 611:             Node storage originalRoot = index.nodes[id];
612: 612: 612: 612: 612: 
613: 613: 613: 613: 613:             if (originalRoot.left == 0x0) {
614: 614: 614: 614: 614:                 
615: 615: 615: 615: 615:                 
616: 616: 616: 616: 616:                 throw;
617: 617: 617: 617: 617:             }
618: 618: 618: 618: 618: 
619: 619: 619: 619: 619:             
620: 620: 620: 620: 620:             
621: 621: 621: 621: 621:             Node storage newRoot = index.nodes[originalRoot.left];
622: 622: 622: 622: 622:             newRoot.parent = originalRoot.parent;
623: 623: 623: 623: 623: 
624: 624: 624: 624: 624:             
625: 625: 625: 625: 625:             originalRoot.left = 0x0;
626: 626: 626: 626: 626: 
627: 627: 627: 627: 627:             if (originalRoot.parent != 0x0) {
628: 628: 628: 628: 628:                 
629: 629: 629: 629: 629:                 
630: 630: 630: 630: 630:                 Node storage parent = index.nodes[originalRoot.parent];
631: 631: 631: 631: 631: 
632: 632: 632: 632: 632:                 if (parent.left == originalRoot.id) {
633: 633: 633: 633: 633:                     parent.left = newRoot.id;
634: 634: 634: 634: 634:                 }
635: 635: 635: 635: 635:                 if (parent.right == originalRoot.id) {
636: 636: 636: 636: 636:                     parent.right = newRoot.id;
637: 637: 637: 637: 637:                 }
638: 638: 638: 638: 638:             }
639: 639: 639: 639: 639: 
640: 640: 640: 640: 640:             if (newRoot.right != 0x0) {
641: 641: 641: 641: 641:                 Node storage rightChild = index.nodes[newRoot.right];
642: 642: 642: 642: 642:                 originalRoot.left = newRoot.right;
643: 643: 643: 643: 643:                 rightChild.parent = originalRoot.id;
644: 644: 644: 644: 644:             }
645: 645: 645: 645: 645: 
646: 646: 646: 646: 646:             
647: 647: 647: 647: 647:             originalRoot.parent = newRoot.id;
648: 648: 648: 648: 648:             newRoot.right = originalRoot.id;
649: 649: 649: 649: 649: 
650: 650: 650: 650: 650:             if (newRoot.parent == 0x0) {
651: 651: 651: 651: 651:                 index.root = newRoot.id;
652: 652: 652: 652: 652:             }
653: 653: 653: 653: 653: 
654: 654: 654: 654: 654:             
655: 655: 655: 655: 655:             _updateNodeHeight(index, originalRoot.id);
656: 656: 656: 656: 656:             _updateNodeHeight(index, newRoot.id);
657: 657: 657: 657: 657:         }
658: 658: 658: 658: 658: }
659: 659: 659: 659: 659: 
660: 660: 660: 660: 660: 
661: 661: 661: 661: 661: 
662: 662: 662: 662: 662: 
663: 663: 663: 663: 663: 
664: 664: 664: 664: 664: 
665: 665: 665: 665: 665: library AccountingLib {
666: 666: 666: 666: 666:         
667: 667: 667: 667: 667: 
668: 668: 668: 668: 668: 
669: 669: 669: 669: 669:         struct Bank {
670: 670: 670: 670: 670:             mapping (address => uint) accountBalances;
671: 671: 671: 671: 671:         }
672: 672: 672: 672: 672: 
673: 673: 673: 673: 673:         
674: 674: 674: 674: 674:         
675: 675: 675: 675: 675:         
676: 676: 676: 676: 676:         
677: 677: 677: 677: 677:         function addFunds(Bank storage self, address accountAddress, uint value) public {
678: 678: 678: 678: 678:                 if (self.accountBalances[accountAddress] + value < self.accountBalances[accountAddress]) {
679: 679: 679: 679: 679:                         
680: 680: 680: 680: 680:                         throw;
681: 681: 681: 681: 681:                 }
682: 682: 682: 682: 682:                 self.accountBalances[accountAddress] += value;
683: 683: 683: 683: 683:         }
684: 684: 684: 684: 684: 
685: 685: 685: 685: 685:         event _Deposit(address indexed _from, address indexed accountAddress, uint value);
686: 686: 686: 686: 686:         
687: 687: 687: 687: 687:         
688: 688: 688: 688: 688:         
689: 689: 689: 689: 689:         
690: 690: 690: 690: 690:         function Deposit(address _from, address accountAddress, uint value) public {
691: 691: 691: 691: 691:             _Deposit(_from, accountAddress, value);
692: 692: 692: 692: 692:         }
693: 693: 693: 693: 693: 
694: 694: 694: 694: 694: 
695: 695: 695: 695: 695:         
696: 696: 696: 696: 696:         
697: 697: 697: 697: 697:         
698: 698: 698: 698: 698:         
699: 699: 699: 699: 699:         function deposit(Bank storage self, address accountAddress, uint value) public returns (bool) {
700: 700: 700: 700: 700:                 addFunds(self, accountAddress, value);
701: 701: 701: 701: 701:                 return true;
702: 702: 702: 702: 702:         }
703: 703: 703: 703: 703: 
704: 704: 704: 704: 704:         event _Withdrawal(address indexed accountAddress, uint value);
705: 705: 705: 705: 705: 
706: 706: 706: 706: 706:         
707: 707: 707: 707: 707:         
708: 708: 708: 708: 708:         
709: 709: 709: 709: 709:         function Withdrawal(address accountAddress, uint value) public {
710: 710: 710: 710: 710:             _Withdrawal(accountAddress, value);
711: 711: 711: 711: 711:         }
712: 712: 712: 712: 712: 
713: 713: 713: 713: 713:         event _InsufficientFunds(address indexed accountAddress, uint value, uint balance);
714: 714: 714: 714: 714: 
715: 715: 715: 715: 715:         
716: 716: 716: 716: 716:         
717: 717: 717: 717: 717:         
718: 718: 718: 718: 718:         
719: 719: 719: 719: 719:         function InsufficientFunds(address accountAddress, uint value, uint balance) public {
720: 720: 720: 720: 720:             _InsufficientFunds(accountAddress, value, balance);
721: 721: 721: 721: 721:         }
722: 722: 722: 722: 722: 
723: 723: 723: 723: 723:         
724: 724: 724: 724: 724:         
725: 725: 725: 725: 725:         
726: 726: 726: 726: 726:         
727: 727: 727: 727: 727:         function deductFunds(Bank storage self, address accountAddress, uint value) public {
728: 728: 728: 728: 728:                 
729: 729: 729: 729: 729: 
730: 730: 730: 730: 730: 
731: 731: 731: 731: 731: 
732: 732: 732: 732: 732: 
733: 733: 733: 733: 733:                 if (value > self.accountBalances[accountAddress]) {
734: 734: 734: 734: 734:                         
735: 735: 735: 735: 735:                         throw;
736: 736: 736: 736: 736:                 }
737: 737: 737: 737: 737:                 self.accountBalances[accountAddress] -= value;
738: 738: 738: 738: 738:         }
739: 739: 739: 739: 739: 
740: 740: 740: 740: 740:         
741: 741: 741: 741: 741:         
742: 742: 742: 742: 742:         
743: 743: 743: 743: 743:         
744: 744: 744: 744: 744:         function withdraw(Bank storage self, address accountAddress, uint value) public returns (bool) {
745: 745: 745: 745: 745:                 
746: 746: 746: 746: 746: 
747: 747: 747: 747: 747: 
748: 748: 748: 748: 748:                 if (self.accountBalances[accountAddress] >= value) {
749: 749: 749: 749: 749:                         deductFunds(self, accountAddress, value);
750: 750: 750: 750: 750:                         if (!accountAddress.send(value)) {
751: 751: 751: 751: 751:                                 
752: 752: 752: 752: 752:                                 
753: 753: 753: 753: 753:                                 
754: 754: 754: 754: 754:                                 if (!accountAddress.call.value(value)()) {
755: 755: 755: 755: 755:                                         
756: 756: 756: 756: 756:                                         
757: 757: 757: 757: 757:                                         throw;
758: 758: 758: 758: 758:                                 }
759: 759: 759: 759: 759:                         }
760: 760: 760: 760: 760:                         return true;
761: 761: 761: 761: 761:                 }
762: 762: 762: 762: 762:                 return false;
763: 763: 763: 763: 763:         }
764: 764: 764: 764: 764: 
765: 765: 765: 765: 765:         uint constant DEFAULT_SEND_GAS = 100000;
766: 766: 766: 766: 766: 
767: 767: 767: 767: 767:         function sendRobust(address toAddress, uint value) public returns (bool) {
768: 768: 768: 768: 768:                 if (msg.gas < DEFAULT_SEND_GAS) {
769: 769: 769: 769: 769:                     return sendRobust(toAddress, value, msg.gas);
770: 770: 770: 770: 770:                 }
771: 771: 771: 771: 771:                 return sendRobust(toAddress, value, DEFAULT_SEND_GAS);
772: 772: 772: 772: 772:         }
773: 773: 773: 773: 773: 
774: 774: 774: 774: 774:         function sendRobust(address toAddress, uint value, uint maxGas) public returns (bool) {
775: 775: 775: 775: 775:                 if (value > 0 && !toAddress.send(value)) {
776: 776: 776: 776: 776:                         
777: 777: 777: 777: 777:                         
778: 778: 778: 778: 778:                         
779: 779: 779: 779: 779:                         if (!toAddress.call.gas(maxGas).value(value)()) {
780: 780: 780: 780: 780:                                 return false;
781: 781: 781: 781: 781:                         }
782: 782: 782: 782: 782:                 }
783: 783: 783: 783: 783:                 return true;
784: 784: 784: 784: 784:         }
785: 785: 785: 785: 785: }
786: 786: 786: 786: 786: 
787: 787: 787: 787: 787: 
788: 788: 788: 788: 788: library CallLib {
789: 789: 789: 789: 789:     
790: 790: 790: 790: 790: 
791: 791: 791: 791: 791: 
792: 792: 792: 792: 792:     struct Call {
793: 793: 793: 793: 793:         address contractAddress;
794: 794: 794: 794: 794:         bytes4 abiSignature;
795: 795: 795: 795: 795:         bytes callData;
796: 796: 796: 796: 796:         uint callValue;
797: 797: 797: 797: 797:         uint anchorGasPrice;
798: 798: 798: 798: 798:         uint requiredGas;
799: 799: 799: 799: 799:         uint16 requiredStackDepth;
800: 800: 800: 800: 800: 
801: 801: 801: 801: 801:         address claimer;
802: 802: 802: 802: 802:         uint claimAmount;
803: 803: 803: 803: 803:         uint claimerDeposit;
804: 804: 804: 804: 804: 
805: 805: 805: 805: 805:         bool wasSuccessful;
806: 806: 806: 806: 806:         bool wasCalled;
807: 807: 807: 807: 807:         bool isCancelled;
808: 808: 808: 808: 808:     }
809: 809: 809: 809: 809: 
810: 810: 810: 810: 810:     enum State {
811: 811: 811: 811: 811:         Pending,
812: 812: 812: 812: 812:         Unclaimed,
813: 813: 813: 813: 813:         Claimed,
814: 814: 814: 814: 814:         Frozen,
815: 815: 815: 815: 815:         Callable,
816: 816: 816: 816: 816:         Executed,
817: 817: 817: 817: 817:         Cancelled,
818: 818: 818: 818: 818:         Missed
819: 819: 819: 819: 819:     }
820: 820: 820: 820: 820: 
821: 821: 821: 821: 821:     function state(Call storage self) constant returns (State) {
822: 822: 822: 822: 822:         if (self.isCancelled) return State.Cancelled;
823: 823: 823: 823: 823:         if (self.wasCalled) return State.Executed;
824: 824: 824: 824: 824: 
825: 825: 825: 825: 825:         var call = FutureBlockCall(this);
826: 826: 826: 826: 826: 
827: 827: 827: 827: 827:         if (block.number + CLAIM_GROWTH_WINDOW + MAXIMUM_CLAIM_WINDOW + BEFORE_CALL_FREEZE_WINDOW < call.targetBlock()) return State.Pending;
828: 828: 828: 828: 828:         if (block.number + BEFORE_CALL_FREEZE_WINDOW < call.targetBlock()) {
829: 829: 829: 829: 829:             if (self.claimer == 0x0) {
830: 830: 830: 830: 830:                 return State.Unclaimed;
831: 831: 831: 831: 831:             }
832: 832: 832: 832: 832:             else {
833: 833: 833: 833: 833:                 return State.Claimed;
834: 834: 834: 834: 834:             }
835: 835: 835: 835: 835:         }
836: 836: 836: 836: 836:         if (block.number < call.targetBlock()) return State.Frozen;
837: 837: 837: 837: 837:         if (block.number < call.targetBlock() + call.gracePeriod()) return State.Callable;
838: 838: 838: 838: 838:         return State.Missed;
839: 839: 839: 839: 839:     }
840: 840: 840: 840: 840: 
841: 841: 841: 841: 841:     
842: 842: 842: 842: 842:     
843: 843: 843: 843: 843:     uint constant CALL_WINDOW_SIZE = 16;
844: 844: 844: 844: 844: 
845: 845: 845: 845: 845:     address constant creator = 0xd3cda913deb6f67967b99d67acdfa1712c293601;
846: 846: 846: 846: 846: 
847: 847: 847: 847: 847:     function extractCallData(Call storage call, bytes data) public {
848: 848: 848: 848: 848:         call.callData.length = data.length - 4;
849: 849: 849: 849: 849:         if (data.length > 4) {
850: 850: 850: 850: 850:                 for (uint i = 0; i < call.callData.length; i++) {
851: 851: 851: 851: 851:                         call.callData[i] = data[i + 4];
852: 852: 852: 852: 852:                 }
853: 853: 853: 853: 853:         }
854: 854: 854: 854: 854:     }
855: 855: 855: 855: 855: 
856: 856: 856: 856: 856:     uint constant GAS_PER_DEPTH = 700;
857: 857: 857: 857: 857: 
858: 858: 858: 858: 858:     function checkDepth(uint n) constant returns (bool) {
859: 859: 859: 859: 859:         if (n == 0) return true;
860: 860: 860: 860: 860:         return address(this).call.gas(GAS_PER_DEPTH * n)(bytes4(sha3("__dig(uint256)")), n - 1);
861: 861: 861: 861: 861:     }
862: 862: 862: 862: 862: 
863: 863: 863: 863: 863:     function sendSafe(address to_address, uint value) public returns (uint) {
864: 864: 864: 864: 864:         if (value > address(this).balance) {
865: 865: 865: 865: 865:             value = address(this).balance;
866: 866: 866: 866: 866:         }
867: 867: 867: 867: 867:         if (value > 0) {
868: 868: 868: 868: 868:             AccountingLib.sendRobust(to_address, value);
869: 869: 869: 869: 869:             return value;
870: 870: 870: 870: 870:         }
871: 871: 871: 871: 871:         return 0;
872: 872: 872: 872: 872:     }
873: 873: 873: 873: 873: 
874: 874: 874: 874: 874:     function getGasScalar(uint base_gas_price, uint gas_price) constant returns (uint) {
875: 875: 875: 875: 875:         
876: 876: 876: 876: 876: 
877: 877: 877: 877: 877: 
878: 878: 878: 878: 878: 
879: 879: 879: 879: 879: 
880: 880: 880: 880: 880: 
881: 881: 881: 881: 881: 
882: 882: 882: 882: 882: 
883: 883: 883: 883: 883: 
884: 884: 884: 884: 884: 
885: 885: 885: 885: 885: 
886: 886: 886: 886: 886: 
887: 887: 887: 887: 887: 
888: 888: 888: 888: 888: 
889: 889: 889: 889: 889: 
890: 890: 890: 890: 890:         if (gas_price > base_gas_price) {
891: 891: 891: 891: 891:             return 100 * base_gas_price / gas_price;
892: 892: 892: 892: 892:         }
893: 893: 893: 893: 893:         else {
894: 894: 894: 894: 894:             return 200 - 100 * base_gas_price / (2 * base_gas_price - gas_price);
895: 895: 895: 895: 895:         }
896: 896: 896: 896: 896:     }
897: 897: 897: 897: 897: 
898: 898: 898: 898: 898:     event CallExecuted(address indexed executor, uint gasCost, uint payment, uint donation, bool success);
899: 899: 899: 899: 899: 
900: 900: 900: 900: 900:     bytes4 constant EMPTY_SIGNATURE = 0x0000;
901: 901: 901: 901: 901: 
902: 902: 902: 902: 902:     event CallAborted(address executor, bytes32 reason);
903: 903: 903: 903: 903: 
904: 904: 904: 904: 904:     function execute(Call storage self,
905: 905: 905: 905: 905:                      uint start_gas,
906: 906: 906: 906: 906:                      address executor,
907: 907: 907: 907: 907:                      uint overhead,
908: 908: 908: 908: 908:                      uint extraGas) public {
909: 909: 909: 909: 909:         FutureCall call = FutureCall(this);
910: 910: 910: 910: 910: 
911: 911: 911: 911: 911:         
912: 912: 912: 912: 912:         self.wasCalled = true;
913: 913: 913: 913: 913: 
914: 914: 914: 914: 914:         
915: 915: 915: 915: 915:         if (self.abiSignature == EMPTY_SIGNATURE && self.callData.length == 0) {
916: 916: 916: 916: 916:             self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)();
917: 917: 917: 917: 917:         }
918: 918: 918: 918: 918:         else if (self.abiSignature == EMPTY_SIGNATURE) {
919: 919: 919: 919: 919:             self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.callData);
920: 920: 920: 920: 920:         }
921: 921: 921: 921: 921:         else if (self.callData.length == 0) {
922: 922: 922: 922: 922:             self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature);
923: 923: 923: 923: 923:         }
924: 924: 924: 924: 924:         else {
925: 925: 925: 925: 925:             self.wasSuccessful = self.contractAddress.call.value(self.callValue).gas(msg.gas - overhead)(self.abiSignature, self.callData);
926: 926: 926: 926: 926:         }
927: 927: 927: 927: 927: 
928: 928: 928: 928: 928:         call.origin().call(bytes4(sha3("updateDefaultPayment()")));
929: 929: 929: 929: 929: 
930: 930: 930: 930: 930:         
931: 931: 931: 931: 931:         uint gasScalar = getGasScalar(self.anchorGasPrice, tx.gasprice);
932: 932: 932: 932: 932: 
933: 933: 933: 933: 933:         uint basePayment;
934: 934: 934: 934: 934:         if (self.claimer == executor) {
935: 935: 935: 935: 935:             basePayment = self.claimAmount;
936: 936: 936: 936: 936:         }
937: 937: 937: 937: 937:         else {
938: 938: 938: 938: 938:             basePayment = call.basePayment();
939: 939: 939: 939: 939:         }
940: 940: 940: 940: 940:         uint payment = self.claimerDeposit + basePayment * gasScalar / 100;
941: 941: 941: 941: 941:         uint donation = call.baseDonation() * gasScalar / 100;
942: 942: 942: 942: 942: 
943: 943: 943: 943: 943:         
944: 944: 944: 944: 944:         self.claimerDeposit = 0;
945: 945: 945: 945: 945: 
946: 946: 946: 946: 946:         
947: 947: 947: 947: 947:         
948: 948: 948: 948: 948:         
949: 949: 949: 949: 949:         uint gasCost = tx.gasprice * (start_gas - msg.gas + extraGas);
950: 950: 950: 950: 950: 
951: 951: 951: 951: 951:         
952: 952: 952: 952: 952:         payment = sendSafe(executor, payment + gasCost);
953: 953: 953: 953: 953:         donation = sendSafe(creator, donation);
954: 954: 954: 954: 954: 
955: 955: 955: 955: 955:         
956: 956: 956: 956: 956:         CallExecuted(executor, gasCost, payment, donation, self.wasSuccessful);
957: 957: 957: 957: 957:     }
958: 958: 958: 958: 958: 
959: 959: 959: 959: 959:     event Cancelled(address indexed cancelled_by);
960: 960: 960: 960: 960: 
961: 961: 961: 961: 961:     function cancel(Call storage self, address sender) public {
962: 962: 962: 962: 962:         Cancelled(sender);
963: 963: 963: 963: 963:         if (self.claimerDeposit >= 0) {
964: 964: 964: 964: 964:             sendSafe(self.claimer, self.claimerDeposit);
965: 965: 965: 965: 965:         }
966: 966: 966: 966: 966:         var call = FutureCall(this);
967: 967: 967: 967: 967:         sendSafe(call.schedulerAddress(), address(this).balance);
968: 968: 968: 968: 968:         self.isCancelled = true;
969: 969: 969: 969: 969:     }
970: 970: 970: 970: 970: 
971: 971: 971: 971: 971:     
972: 972: 972: 972: 972: 
973: 973: 973: 973: 973: 
974: 974: 974: 974: 974: 
975: 975: 975: 975: 975: 
976: 976: 976: 976: 976: 
977: 977: 977: 977: 977: 
978: 978: 978: 978: 978:     event Claimed(address executor, uint claimAmount);
979: 979: 979: 979: 979: 
980: 980: 980: 980: 980:     
981: 981: 981: 981: 981:     
982: 982: 982: 982: 982:     uint constant CLAIM_GROWTH_WINDOW = 240;
983: 983: 983: 983: 983: 
984: 984: 984: 984: 984:     
985: 985: 985: 985: 985:     
986: 986: 986: 986: 986:     uint constant MAXIMUM_CLAIM_WINDOW = 15;
987: 987: 987: 987: 987: 
988: 988: 988: 988: 988:     
989: 989: 989: 989: 989:     
990: 990: 990: 990: 990:     
991: 991: 991: 991: 991:     uint constant BEFORE_CALL_FREEZE_WINDOW = 10;
992: 992: 992: 992: 992: 
993: 993: 993: 993: 993:     
994: 994: 994: 994: 994: 
995: 995: 995: 995: 995: 
996: 996: 996: 996: 996: 
997: 997: 997: 997: 997: 
998: 998: 998: 998: 998: 
999: 999: 999: 999: 999: 
1000: 1000: 1000: 1000: 1000:     function getClaimAmountForBlock(uint block_number) constant returns (uint) {
1001: 1001: 1001: 1001: 1001:         
1002: 1002: 1002: 1002: 1002: 
1003: 1003: 1003: 1003: 1003: 
1004: 1004: 1004: 1004: 1004: 
1005: 1005: 1005: 1005: 1005: 
1006: 1006: 1006: 1006: 1006:         var call = FutureBlockCall(this);
1007: 1007: 1007: 1007: 1007: 
1008: 1008: 1008: 1008: 1008:         uint cutoff = call.targetBlock() - BEFORE_CALL_FREEZE_WINDOW;
1009: 1009: 1009: 1009: 1009: 
1010: 1010: 1010: 1010: 1010:         
1011: 1011: 1011: 1011: 1011:         if (block_number > cutoff) return call.basePayment();
1012: 1012: 1012: 1012: 1012: 
1013: 1013: 1013: 1013: 1013:         cutoff -= MAXIMUM_CLAIM_WINDOW;
1014: 1014: 1014: 1014: 1014: 
1015: 1015: 1015: 1015: 1015:         
1016: 1016: 1016: 1016: 1016:         if (block_number > cutoff) return call.basePayment();
1017: 1017: 1017: 1017: 1017: 
1018: 1018: 1018: 1018: 1018:         cutoff -= CLAIM_GROWTH_WINDOW;
1019: 1019: 1019: 1019: 1019: 
1020: 1020: 1020: 1020: 1020:         if (block_number > cutoff) {
1021: 1021: 1021: 1021: 1021:             uint x = block_number - cutoff;
1022: 1022: 1022: 1022: 1022: 
1023: 1023: 1023: 1023: 1023:             return call.basePayment() * x / CLAIM_GROWTH_WINDOW;
1024: 1024: 1024: 1024: 1024:         }
1025: 1025: 1025: 1025: 1025: 
1026: 1026: 1026: 1026: 1026:         return 0;
1027: 1027: 1027: 1027: 1027:     }
1028: 1028: 1028: 1028: 1028: 
1029: 1029: 1029: 1029: 1029:     function lastClaimBlock() constant returns (uint) {
1030: 1030: 1030: 1030: 1030:         var call = FutureBlockCall(this);
1031: 1031: 1031: 1031: 1031:         return call.targetBlock() - BEFORE_CALL_FREEZE_WINDOW;
1032: 1032: 1032: 1032: 1032:     }
1033: 1033: 1033: 1033: 1033: 
1034: 1034: 1034: 1034: 1034:     function maxClaimBlock() constant returns (uint) {
1035: 1035: 1035: 1035: 1035:         return lastClaimBlock() - MAXIMUM_CLAIM_WINDOW;
1036: 1036: 1036: 1036: 1036:     }
1037: 1037: 1037: 1037: 1037: 
1038: 1038: 1038: 1038: 1038:     function firstClaimBlock() constant returns (uint) {
1039: 1039: 1039: 1039: 1039:         return maxClaimBlock() - CLAIM_GROWTH_WINDOW;
1040: 1040: 1040: 1040: 1040:     }
1041: 1041: 1041: 1041: 1041: 
1042: 1042: 1042: 1042: 1042:     function claim(Call storage self, address executor, uint deposit_amount, uint basePayment) public returns (bool) {
1043: 1043: 1043: 1043: 1043:         
1044: 1044: 1044: 1044: 1044: 
1045: 1045: 1045: 1045: 1045: 
1046: 1046: 1046: 1046: 1046: 
1047: 1047: 1047: 1047: 1047: 
1048: 1048: 1048: 1048: 1048:         
1049: 1049: 1049: 1049: 1049:         if (deposit_amount < 2 * basePayment) return false;
1050: 1050: 1050: 1050: 1050: 
1051: 1051: 1051: 1051: 1051:         self.claimAmount = getClaimAmountForBlock(block.number);
1052: 1052: 1052: 1052: 1052:         self.claimer = executor;
1053: 1053: 1053: 1053: 1053:         self.claimerDeposit = deposit_amount;
1054: 1054: 1054: 1054: 1054: 
1055: 1055: 1055: 1055: 1055:         
1056: 1056: 1056: 1056: 1056:         Claimed(executor, self.claimAmount);
1057: 1057: 1057: 1057: 1057:     }
1058: 1058: 1058: 1058: 1058: 
1059: 1059: 1059: 1059: 1059:     function checkExecutionAuthorization(Call storage self, address executor, uint block_number) returns (bool) {
1060: 1060: 1060: 1060: 1060:         
1061: 1061: 1061: 1061: 1061: 
1062: 1062: 1062: 1062: 1062: 
1063: 1063: 1063: 1063: 1063:         var call = FutureBlockCall(this);
1064: 1064: 1064: 1064: 1064: 
1065: 1065: 1065: 1065: 1065:         uint targetBlock = call.targetBlock();
1066: 1066: 1066: 1066: 1066: 
1067: 1067: 1067: 1067: 1067:         
1068: 1068: 1068: 1068: 1068:         if (block_number < targetBlock || block_number > targetBlock + call.gracePeriod()) throw;
1069: 1069: 1069: 1069: 1069: 
1070: 1070: 1070: 1070: 1070:         
1071: 1071: 1071: 1071: 1071:         
1072: 1072: 1072: 1072: 1072:         if (block_number - targetBlock < CALL_WINDOW_SIZE) {
1073: 1073: 1073: 1073: 1073:         return (self.claimer == 0x0 || self.claimer == executor);
1074: 1074: 1074: 1074: 1074:         }
1075: 1075: 1075: 1075: 1075: 
1076: 1076: 1076: 1076: 1076:         
1077: 1077: 1077: 1077: 1077:         return true;
1078: 1078: 1078: 1078: 1078:     }
1079: 1079: 1079: 1079: 1079: 
1080: 1080: 1080: 1080: 1080:     function isCancellable(Call storage self, address caller) returns (bool) {
1081: 1081: 1081: 1081: 1081:         var _state = state(self);
1082: 1082: 1082: 1082: 1082:         var call = FutureBlockCall(this);
1083: 1083: 1083: 1083: 1083: 
1084: 1084: 1084: 1084: 1084:         if (_state == State.Pending && caller == call.schedulerAddress()) {
1085: 1085: 1085: 1085: 1085:             return true;
1086: 1086: 1086: 1086: 1086:         }
1087: 1087: 1087: 1087: 1087: 
1088: 1088: 1088: 1088: 1088:         if (_state == State.Missed) return true;
1089: 1089: 1089: 1089: 1089: 
1090: 1090: 1090: 1090: 1090:         return false;
1091: 1091: 1091: 1091: 1091:     }
1092: 1092: 1092: 1092: 1092: 
1093: 1093: 1093: 1093: 1093:     function beforeExecuteForFutureBlockCall(Call storage self, address executor, uint startGas) returns (bool) {
1094: 1094: 1094: 1094: 1094:         bytes32 reason;
1095: 1095: 1095: 1095: 1095: 
1096: 1096: 1096: 1096: 1096:         var call = FutureBlockCall(this);
1097: 1097: 1097: 1097: 1097: 
1098: 1098: 1098: 1098: 1098:         if (startGas < self.requiredGas) {
1099: 1099: 1099: 1099: 1099:             
1100: 1100: 1100: 1100: 1100:             reason = "NOT_ENOUGH_GAS";
1101: 1101: 1101: 1101: 1101:         }
1102: 1102: 1102: 1102: 1102:         else if (self.wasCalled) {
1103: 1103: 1103: 1103: 1103:             
1104: 1104: 1104: 1104: 1104:             reason = "ALREADY_CALLED";
1105: 1105: 1105: 1105: 1105:         }
1106: 1106: 1106: 1106: 1106:         else if (block.number < call.targetBlock() || block.number > call.targetBlock() + call.gracePeriod()) {
1107: 1107: 1107: 1107: 1107:             
1108: 1108: 1108: 1108: 1108:             reason = "NOT_IN_CALL_WINDOW";
1109: 1109: 1109: 1109: 1109:         }
1110: 1110: 1110: 1110: 1110:         else if (!checkExecutionAuthorization(self, executor, block.number)) {
1111: 1111: 1111: 1111: 1111:             
1112: 1112: 1112: 1112: 1112:             
1113: 1113: 1113: 1113: 1113:             reason = "NOT_AUTHORIZED";
1114: 1114: 1114: 1114: 1114:         }
1115: 1115: 1115: 1115: 1115:         else if (self.requiredStackDepth > 0 && executor != tx.origin && !checkDepth(self.requiredStackDepth)) {
1116: 1116: 1116: 1116: 1116:             reason = "STACK_TOO_DEEP";
1117: 1117: 1117: 1117: 1117:         }
1118: 1118: 1118: 1118: 1118: 
1119: 1119: 1119: 1119: 1119:         if (reason != 0x0) {
1120: 1120: 1120: 1120: 1120:             CallAborted(executor, reason);
1121: 1121: 1121: 1121: 1121:             return false;
1122: 1122: 1122: 1122: 1122:         }
1123: 1123: 1123: 1123: 1123: 
1124: 1124: 1124: 1124: 1124:         return true;
1125: 1125: 1125: 1125: 1125:     }
1126: 1126: 1126: 1126: 1126: }
1127: 1127: 1127: 1127: 1127: 
1128: 1128: 1128: 1128: 1128: 
1129: 1129: 1129: 1129: 1129: contract FutureCall {
1130: 1130: 1130: 1130: 1130:     
1131: 1131: 1131: 1131: 1131:     address constant creator = 0xd3cda913deb6f67967b99d67acdfa1712c293601;
1132: 1132: 1132: 1132: 1132: 
1133: 1133: 1133: 1133: 1133:     address public schedulerAddress;
1134: 1134: 1134: 1134: 1134: 
1135: 1135: 1135: 1135: 1135:     uint public basePayment;
1136: 1136: 1136: 1136: 1136:     uint public baseDonation;
1137: 1137: 1137: 1137: 1137: 
1138: 1138: 1138: 1138: 1138:     CallLib.Call call;
1139: 1139: 1139: 1139: 1139: 
1140: 1140: 1140: 1140: 1140:     address public origin;
1141: 1141: 1141: 1141: 1141: 
1142: 1142: 1142: 1142: 1142:     function FutureCall(address _schedulerAddress,
1143: 1143: 1143: 1143: 1143:                         uint _requiredGas,
1144: 1144: 1144: 1144: 1144:                         uint16 _requiredStackDepth,
1145: 1145: 1145: 1145: 1145:                         address _contractAddress,
1146: 1146: 1146: 1146: 1146:                         bytes4 _abiSignature,
1147: 1147: 1147: 1147: 1147:                         bytes _callData,
1148: 1148: 1148: 1148: 1148:                         uint _callValue,
1149: 1149: 1149: 1149: 1149:                         uint _basePayment,
1150: 1150: 1150: 1150: 1150:                         uint _baseDonation)
1151: 1151: 1151: 1151: 1151:     {
1152: 1152: 1152: 1152: 1152:         origin = msg.sender;
1153: 1153: 1153: 1153: 1153:         schedulerAddress = _schedulerAddress;
1154: 1154: 1154: 1154: 1154: 
1155: 1155: 1155: 1155: 1155:         basePayment = _basePayment;
1156: 1156: 1156: 1156: 1156:         baseDonation = _baseDonation;
1157: 1157: 1157: 1157: 1157: 
1158: 1158: 1158: 1158: 1158:         call.requiredGas = _requiredGas;
1159: 1159: 1159: 1159: 1159:         call.requiredStackDepth = _requiredStackDepth;
1160: 1160: 1160: 1160: 1160:         call.anchorGasPrice = tx.gasprice;
1161: 1161: 1161: 1161: 1161:         call.contractAddress = _contractAddress;
1162: 1162: 1162: 1162: 1162:         call.abiSignature = _abiSignature;
1163: 1163: 1163: 1163: 1163:         call.callData = _callData;
1164: 1164: 1164: 1164: 1164:         call.callValue = _callValue;
1165: 1165: 1165: 1165: 1165:     }
1166: 1166: 1166: 1166: 1166: 
1167: 1167: 1167: 1167: 1167:     enum State {
1168: 1168: 1168: 1168: 1168:         Pending,
1169: 1169: 1169: 1169: 1169:         Unclaimed,
1170: 1170: 1170: 1170: 1170:         Claimed,
1171: 1171: 1171: 1171: 1171:         Frozen,
1172: 1172: 1172: 1172: 1172:         Callable,
1173: 1173: 1173: 1173: 1173:         Executed,
1174: 1174: 1174: 1174: 1174:         Cancelled,
1175: 1175: 1175: 1175: 1175:         Missed
1176: 1176: 1176: 1176: 1176:     }
1177: 1177: 1177: 1177: 1177: 
1178: 1178: 1178: 1178: 1178:     modifier in_state(State _state) { if (state() == _state) _ }
1179: 1179: 1179: 1179: 1179: 
1180: 1180: 1180: 1180: 1180:     function state() constant returns (State) {
1181: 1181: 1181: 1181: 1181:         return State(CallLib.state(call));
1182: 1182: 1182: 1182: 1182:     }
1183: 1183: 1183: 1183: 1183: 
1184: 1184: 1184: 1184: 1184:     
1185: 1185: 1185: 1185: 1185: 
1186: 1186: 1186: 1186: 1186: 
1187: 1187: 1187: 1187: 1187:     function beforeExecute(address executor, uint startGas) public returns (bool);
1188: 1188: 1188: 1188: 1188:     function afterExecute(address executor) internal;
1189: 1189: 1189: 1189: 1189:     function getOverhead() constant returns (uint);
1190: 1190: 1190: 1190: 1190:     function getExtraGas() constant returns (uint);
1191: 1191: 1191: 1191: 1191: 
1192: 1192: 1192: 1192: 1192:     
1193: 1193: 1193: 1193: 1193: 
1194: 1194: 1194: 1194: 1194: 
1195: 1195: 1195: 1195: 1195:     function contractAddress() constant returns (address) {
1196: 1196: 1196: 1196: 1196:         return call.contractAddress;
1197: 1197: 1197: 1197: 1197:     }
1198: 1198: 1198: 1198: 1198: 
1199: 1199: 1199: 1199: 1199:     function abiSignature() constant returns (bytes4) {
1200: 1200: 1200: 1200: 1200:         return call.abiSignature;
1201: 1201: 1201: 1201: 1201:     }
1202: 1202: 1202: 1202: 1202: 
1203: 1203: 1203: 1203: 1203:     function callData() constant returns (bytes) {
1204: 1204: 1204: 1204: 1204:         return call.callData;
1205: 1205: 1205: 1205: 1205:     }
1206: 1206: 1206: 1206: 1206: 
1207: 1207: 1207: 1207: 1207:     function callValue() constant returns (uint) {
1208: 1208: 1208: 1208: 1208:         return call.callValue;
1209: 1209: 1209: 1209: 1209:     }
1210: 1210: 1210: 1210: 1210: 
1211: 1211: 1211: 1211: 1211:     function anchorGasPrice() constant returns (uint) {
1212: 1212: 1212: 1212: 1212:         return call.anchorGasPrice;
1213: 1213: 1213: 1213: 1213:     }
1214: 1214: 1214: 1214: 1214: 
1215: 1215: 1215: 1215: 1215:     function requiredGas() constant returns (uint) {
1216: 1216: 1216: 1216: 1216:         return call.requiredGas;
1217: 1217: 1217: 1217: 1217:     }
1218: 1218: 1218: 1218: 1218: 
1219: 1219: 1219: 1219: 1219:     function requiredStackDepth() constant returns (uint16) {
1220: 1220: 1220: 1220: 1220:         return call.requiredStackDepth;
1221: 1221: 1221: 1221: 1221:     }
1222: 1222: 1222: 1222: 1222: 
1223: 1223: 1223: 1223: 1223:     function claimer() constant returns (address) {
1224: 1224: 1224: 1224: 1224:         return call.claimer;
1225: 1225: 1225: 1225: 1225:     }
1226: 1226: 1226: 1226: 1226: 
1227: 1227: 1227: 1227: 1227:     function claimAmount() constant returns (uint) {
1228: 1228: 1228: 1228: 1228:         return call.claimAmount;
1229: 1229: 1229: 1229: 1229:     }
1230: 1230: 1230: 1230: 1230: 
1231: 1231: 1231: 1231: 1231:     function claimerDeposit() constant returns (uint) {
1232: 1232: 1232: 1232: 1232:         return call.claimerDeposit;
1233: 1233: 1233: 1233: 1233:     }
1234: 1234: 1234: 1234: 1234: 
1235: 1235: 1235: 1235: 1235:     function wasSuccessful() constant returns (bool) {
1236: 1236: 1236: 1236: 1236:         return call.wasSuccessful;
1237: 1237: 1237: 1237: 1237:     }
1238: 1238: 1238: 1238: 1238: 
1239: 1239: 1239: 1239: 1239:     function wasCalled() constant returns (bool) {
1240: 1240: 1240: 1240: 1240:         return call.wasCalled;
1241: 1241: 1241: 1241: 1241:     }
1242: 1242: 1242: 1242: 1242: 
1243: 1243: 1243: 1243: 1243:     function isCancelled() constant returns (bool) {
1244: 1244: 1244: 1244: 1244:         return call.isCancelled;
1245: 1245: 1245: 1245: 1245:     }
1246: 1246: 1246: 1246: 1246: 
1247: 1247: 1247: 1247: 1247:     
1248: 1248: 1248: 1248: 1248: 
1249: 1249: 1249: 1249: 1249: 
1250: 1250: 1250: 1250: 1250:     function getClaimAmountForBlock() constant returns (uint) {
1251: 1251: 1251: 1251: 1251:         return CallLib.getClaimAmountForBlock(block.number);
1252: 1252: 1252: 1252: 1252:     }
1253: 1253: 1253: 1253: 1253: 
1254: 1254: 1254: 1254: 1254:     function getClaimAmountForBlock(uint block_number) constant returns (uint) {
1255: 1255: 1255: 1255: 1255:         return CallLib.getClaimAmountForBlock(block_number);
1256: 1256: 1256: 1256: 1256:     }
1257: 1257: 1257: 1257: 1257: 
1258: 1258: 1258: 1258: 1258:     
1259: 1259: 1259: 1259: 1259: 
1260: 1260: 1260: 1260: 1260: 
1261: 1261: 1261: 1261: 1261:     function () returns (bool) {
1262: 1262: 1262: 1262: 1262:         
1263: 1263: 1263: 1263: 1263: 
1264: 1264: 1264: 1264: 1264: 
1265: 1265: 1265: 1265: 1265: 
1266: 1266: 1266: 1266: 1266:         
1267: 1267: 1267: 1267: 1267:         if (msg.sender != schedulerAddress) return false;
1268: 1268: 1268: 1268: 1268:         
1269: 1269: 1269: 1269: 1269:         if (call.callData.length > 0) return false;
1270: 1270: 1270: 1270: 1270: 
1271: 1271: 1271: 1271: 1271:         var _state = state();
1272: 1272: 1272: 1272: 1272:         if (_state != State.Pending && _state != State.Unclaimed && _state != State.Claimed) return false;
1273: 1273: 1273: 1273: 1273: 
1274: 1274: 1274: 1274: 1274:         call.callData = msg.data;
1275: 1275: 1275: 1275: 1275:         return true;
1276: 1276: 1276: 1276: 1276:     }
1277: 1277: 1277: 1277: 1277: 
1278: 1278: 1278: 1278: 1278:     function registerData() public returns (bool) {
1279: 1279: 1279: 1279: 1279:         
1280: 1280: 1280: 1280: 1280:         if (msg.sender != schedulerAddress) return false;
1281: 1281: 1281: 1281: 1281:         
1282: 1282: 1282: 1282: 1282:         if (call.callData.length > 0) return false;
1283: 1283: 1283: 1283: 1283: 
1284: 1284: 1284: 1284: 1284:         var _state = state();
1285: 1285: 1285: 1285: 1285:         if (_state != State.Pending && _state != State.Unclaimed && _state != State.Claimed) return false;
1286: 1286: 1286: 1286: 1286: 
1287: 1287: 1287: 1287: 1287:         CallLib.extractCallData(call, msg.data);
1288: 1288: 1288: 1288: 1288:     }
1289: 1289: 1289: 1289: 1289: 
1290: 1290: 1290: 1290: 1290:     function firstClaimBlock() constant returns (uint) {
1291: 1291: 1291: 1291: 1291:         return CallLib.firstClaimBlock();
1292: 1292: 1292: 1292: 1292:     }
1293: 1293: 1293: 1293: 1293: 
1294: 1294: 1294: 1294: 1294:     function maxClaimBlock() constant returns (uint) {
1295: 1295: 1295: 1295: 1295:         return CallLib.maxClaimBlock();
1296: 1296: 1296: 1296: 1296:     }
1297: 1297: 1297: 1297: 1297: 
1298: 1298: 1298: 1298: 1298:     function lastClaimBlock() constant returns (uint) {
1299: 1299: 1299: 1299: 1299:         return CallLib.lastClaimBlock();
1300: 1300: 1300: 1300: 1300:     }
1301: 1301: 1301: 1301: 1301: 
1302: 1302: 1302: 1302: 1302:     function claim() public in_state(State.Unclaimed) returns (bool) {
1303: 1303: 1303: 1303: 1303:         bool success = CallLib.claim(call, msg.sender, msg.value, basePayment);
1304: 1304: 1304: 1304: 1304:         if (!success) {
1305: 1305: 1305: 1305: 1305:             if (!AccountingLib.sendRobust(msg.sender, msg.value)) throw;
1306: 1306: 1306: 1306: 1306:         }
1307: 1307: 1307: 1307: 1307:         return success;
1308: 1308: 1308: 1308: 1308:     }
1309: 1309: 1309: 1309: 1309: 
1310: 1310: 1310: 1310: 1310:     function checkExecutionAuthorization(address executor, uint block_number) constant returns (bool) {
1311: 1311: 1311: 1311: 1311:         return CallLib.checkExecutionAuthorization(call, executor, block_number);
1312: 1312: 1312: 1312: 1312:     }
1313: 1313: 1313: 1313: 1313: 
1314: 1314: 1314: 1314: 1314:     function sendSafe(address to_address, uint value) internal {
1315: 1315: 1315: 1315: 1315:         CallLib.sendSafe(to_address, value);
1316: 1316: 1316: 1316: 1316:     }
1317: 1317: 1317: 1317: 1317: 
1318: 1318: 1318: 1318: 1318:     function execute() public in_state(State.Callable) {
1319: 1319: 1319: 1319: 1319:         uint start_gas = msg.gas;
1320: 1320: 1320: 1320: 1320: 
1321: 1321: 1321: 1321: 1321:         
1322: 1322: 1322: 1322: 1322:         if (!beforeExecute(msg.sender, start_gas)) return;
1323: 1323: 1323: 1323: 1323: 
1324: 1324: 1324: 1324: 1324:         
1325: 1325: 1325: 1325: 1325:         CallLib.execute(call, start_gas, msg.sender, getOverhead(), getExtraGas());
1326: 1326: 1326: 1326: 1326: 
1327: 1327: 1327: 1327: 1327:         
1328: 1328: 1328: 1328: 1328:         
1329: 1329: 1329: 1329: 1329:         afterExecute(msg.sender);
1330: 1330: 1330: 1330: 1330:     }
1331: 1331: 1331: 1331: 1331: }
1332: 1332: 1332: 1332: 1332: 
1333: 1333: 1333: 1333: 1333: 