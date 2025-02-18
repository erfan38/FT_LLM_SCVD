1: 1: pragma solidity 0.5.0;
2: 2: 
3: 3: contract SolidifiedVault {
4: 4: 
5: 5:     
6: 6: 
7: 7: 
8: 8:     event Confirmation(address indexed sender, uint indexed transactionId);
9: 9:     event Revocation(address indexed sender, uint indexed transactionId);
10: 10:     event Submission(uint indexed transactionId);
11: 11:     event Execution(uint indexed transactionId);
12: 12:     event ExecutionFailure(uint indexed transactionId);
13: 13:     event Deposit(address indexed sender, uint value);
14: 14:     event OwnerAddition(address indexed owner);
15: 15:     event OwnerRemoval(address indexed owner);
16: 16:     event RequirementChange(uint required);
17: 17: 
18: 18:     
19: 19: 
20: 20: 
21: 21:     uint constant public MAX_OWNER_COUNT = 3;
22: 22: 
23: 23:     
24: 24: 
25: 25: 
26: 26:     mapping (uint => Transaction) public transactions;
27: 27:     mapping (uint => mapping (address => bool)) public confirmations;
28: 28:     mapping (address => bool) public isOwner;
29: 29:     address[] public owners;
30: 30:     uint public required;
31: 31:     uint public transactionCount;
32: 32: 
33: 33:     struct Transaction {
34: 34:         address destination;
35: 35:         uint value;
36: 36:         bool executed;
37: 37:     }
38: 38: 
39: 39:     
40: 40: 
41: 41: 
42: 42:     modifier onlyWallet() {
43: 43:         require(msg.sender == address(this), "Vault: sender should be wallet");
44: 44:         _;
45: 45:     }
46: 46: 
47: 47:     modifier ownerDoesNotExist(address owner) {
48: 48:         require(!isOwner[owner], "Vault:sender shouldn't be owner");
49: 49:         _;
50: 50:     }
51: 51: 
52: 52:     modifier ownerExists(address owner) {
53: 53:         require(isOwner[owner], "Vault:sender should be owner");
54: 54:         _;
55: 55:     }
56: 56: 
57: 57:     modifier transactionExists(uint transactionId) {
58: 58:         require(transactions[transactionId].destination != address(0),"Vault:transaction should exist");
59: 59:         _;
60: 60:     }
61: 61: 
62: 62:     modifier confirmed(uint transactionId, address owner) {
63: 63:         require(confirmations[transactionId][owner], "Vault:transaction should be confirmed");
64: 64:         _;
65: 65:     }
66: 66: 
67: 67:     modifier notConfirmed(uint transactionId, address owner) {
68: 68:         require(!confirmations[transactionId][owner], "Vault:transaction is already confirmed");
69: 69:         _;
70: 70:     }
71: 71: 
72: 72:     modifier notExecuted(uint transactionId) {
73: 73:         require(!transactions[transactionId].executed, "Vault:transaction has already executed");
74: 74:         _;
75: 75:     }
76: 76: 
77: 77:     modifier notNull(address _address) {
78: 78:         require(_address != address(0), "Vault:address shouldn't be null");
79: 79:         _;
80: 80:     }
81: 81: 
82: 82:     modifier validRequirement(uint ownerCount, uint _required) {
83: 83:         require(ownerCount <= MAX_OWNER_COUNT
84: 84:             && _required <= ownerCount
85: 85:             && _required != 0
86: 86:             && ownerCount != 0, "Vault:invalid requirement");
87: 87:         _;
88: 88:     }
89: 89: 
90: 90:     
91: 91: 
92: 92: 
93: 93:     function()
94: 94:         external
95: 95:         payable
96: 96:     {
97: 97:         if (msg.value > 0)
98: 98:             emit Deposit(msg.sender, msg.value);
99: 99:     }
100: 100: 
101: 101:     
102: 102: 
103: 103: 
104: 104:      
105: 105: 
106: 106: 
107: 107: 
108: 108: 
109: 109:     constructor(address[] memory _owners, uint _required)
110: 110:         public
111: 111:         validRequirement(_owners.length, _required)
112: 112:     {
113: 113:         for (uint i=0; i<_owners.length; i++) {
114: 114:             require(!isOwner[_owners[i]] && _owners[i] != address(0), "Vault:Invalid owner");
115: 115:             isOwner[_owners[i]] = true;
116: 116:         }
117: 117:         owners = _owners;
118: 118:         required = _required;
119: 119:     }
120: 120: 
121: 121: 
122: 122:     
123: 123:     
124: 124:     
125: 125:     
126: 126:     function submitTransaction(address destination, uint value)
127: 127:         public
128: 128:         returns (uint transactionId)
129: 129:     {
130: 130:         transactionId = addTransaction(destination, value);
131: 131:         confirmTransaction(transactionId);
132: 132:     }
133: 133: 
134: 134:     
135: 135:     
136: 136:     function confirmTransaction(uint transactionId)
137: 137:         public
138: 138:         ownerExists(msg.sender)
139: 139:         transactionExists(transactionId)
140: 140:         notConfirmed(transactionId, msg.sender)
141: 141:     {
142: 142:         confirmations[transactionId][msg.sender] = true;
143: 143:         emit Confirmation(msg.sender, transactionId);
144: 144:         executeTransaction(transactionId);
145: 145:     }
146: 146: 
147: 147:     
148: 148:     
149: 149:     function revokeConfirmation(uint transactionId)
150: 150:         public
151: 151:         ownerExists(msg.sender)
152: 152:         confirmed(transactionId, msg.sender)
153: 153:         notExecuted(transactionId)
154: 154:     {
155: 155:         confirmations[transactionId][msg.sender] = false;
156: 156:         emit Revocation(msg.sender, transactionId);
157: 157:     }
158: 158: 
159: 159:     
160: 160:     
161: 161:     function executeTransaction(uint transactionId)
162: 162:         public
163: 163:         ownerExists(msg.sender)
164: 164:         confirmed(transactionId, msg.sender)
165: 165:         notExecuted(transactionId)
166: 166:     {
167: 167:         if (isConfirmed(transactionId)) {
168: 168:             Transaction storage txn = transactions[transactionId];
169: 169:             txn.executed = true;
170: 170:             (bool exec, bytes memory _) = txn.destination.call.value(txn.value)("");
171: 171:             if (exec)
172: 172:                 emit Execution(transactionId);
173: 173:             else {
174: 174:                 emit ExecutionFailure(transactionId);
175: 175:                 txn.executed = false;
176: 176:             }
177: 177:         }
178: 178:     }
179: 179: 
180: 180:     
181: 181:     
182: 182:     
183: 183:     function isConfirmed(uint transactionId)
184: 184:         public
185: 185:         view
186: 186:         returns (bool)
187: 187:     {
188: 188:         uint count = 0;
189: 189:         for (uint i=0; i<owners.length; i++) {
190: 190:             if (confirmations[transactionId][owners[i]])
191: 191:                 count += 1;
192: 192:             if (count == required)
193: 193:                 return true;
194: 194:         }
195: 195:     }
196: 196: 
197: 197:     
198: 198: 
199: 199: 
200: 200:     
201: 201:     
202: 202:     
203: 203:     
204: 204:     function addTransaction(address destination, uint value)
205: 205:         internal
206: 206:         notNull(destination)
207: 207:         returns (uint transactionId)
208: 208:     {
209: 209:         transactionId = transactionCount;
210: 210:         transactions[transactionId] = Transaction({
211: 211:             destination: destination,
212: 212:             value: value,
213: 213:             executed: false
214: 214:         });
215: 215:         transactionCount += 1;
216: 216:         emit Submission(transactionId);
217: 217:     }
218: 218: 
219: 219:     
220: 220: 
221: 221: 
222: 222:     
223: 223:     
224: 224:     
225: 225:     function getConfirmationCount(uint transactionId)
226: 226:         public
227: 227:         view
228: 228:         returns (uint count)
229: 229:     {
230: 230:         for (uint i=0; i<owners.length; i++)
231: 231:             if (confirmations[transactionId][owners[i]])
232: 232:                 count += 1;
233: 233:     }
234: 234: 
235: 235:     
236: 236:     
237: 237:     
238: 238:     
239: 239:     function getTransactionCount(bool pending, bool executed)
240: 240:         public
241: 241:         view
242: 242:         returns (uint count)
243: 243:     {
244: 244:         for (uint i=0; i<transactionCount; i++)
245: 245:             if (   pending && !transactions[i].executed
246: 246:                 || executed && transactions[i].executed)
247: 247:                 count += 1;
248: 248:     }
249: 249: 
250: 250:     
251: 251:     
252: 252:     function getOwners()
253: 253:         public
254: 254:         view
255: 255:         returns (address[] memory)
256: 256:     {
257: 257:         return owners;
258: 258:     }
259: 259: 
260: 260:     
261: 261:     
262: 262:     
263: 263:     function getConfirmations(uint transactionId)
264: 264:         public
265: 265:         view
266: 266:         returns (address[] memory _confirmations)
267: 267:     {
268: 268:         address[] memory confirmationsTemp = new address[](owners.length);
269: 269:         uint count = 0;
270: 270:         uint i;
271: 271:         for (i=0; i<owners.length; i++)
272: 272:             if (confirmations[transactionId][owners[i]]) {
273: 273:                 confirmationsTemp[count] = owners[i];
274: 274:                 count += 1;
275: 275:             }
276: 276:         _confirmations = new address[](count);
277: 277:         for (i=0; i<count; i++)
278: 278:             _confirmations[i] = confirmationsTemp[i];
279: 279:     }
280: 280: 
281: 281:     
282: 282:     
283: 283:     
284: 284:     
285: 285:     
286: 286:     
287: 287:     function getTransactionIds(uint from, uint to, bool pending, bool executed)
288: 288:         public
289: 289:         view
290: 290:         returns (uint[] memory _transactionIds)
291: 291:     {
292: 292:         uint[] memory transactionIdsTemp = new uint[](transactionCount);
293: 293:         uint count = 0;
294: 294:         uint i;
295: 295:         for (i=0; i<transactionCount; i++)
296: 296:             if (   pending && !transactions[i].executed
297: 297:                 || executed && transactions[i].executed)
298: 298:             {
299: 299:                 transactionIdsTemp[count] = i;
300: 300:                 count += 1;
301: 301:             }
302: 302:         _transactionIds = new uint[](to - from);
303: 303:         for (i=from; i<to; i++)
304: 304:             _transactionIds[i - from] = transactionIdsTemp[i];
305: 305:     }
306: 306: }
307: 307: 
308: 308: 