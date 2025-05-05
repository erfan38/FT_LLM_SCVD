1: 1: pragma solidity ^0.4.11;
2: 2: 
3: 3: contract MultiSigWallet {
4: 4: 
5: 5:     event Confirmation(address sender, bytes32 transactionHash);
6: 6:     event Revocation(address sender, bytes32 transactionHash);
7: 7:     event Submission(bytes32 transactionHash);
8: 8:     event Execution(bytes32 transactionHash);
9: 9:     event Deposit(address sender, uint value);
10: 10:     event OwnerAddition(address owner);
11: 11:     event OwnerRemoval(address owner);
12: 12:     event RequiredUpdate(uint required);
13: 13:     event CoinCreation(address coin);
14: 14: 
15: 15:     mapping (bytes32 => Transaction) public transactions;
16: 16:     mapping (bytes32 => mapping (address => bool)) public confirmations;
17: 17:     mapping (address => bool) public isOwner;
18: 18:     address[] owners;
19: 19:     bytes32[] transactionList;
20: 20:     uint public required;
21: 21: 
22: 22:     struct Transaction {
23: 23:         address destination;
24: 24:         uint value;
25: 25:         bytes data;
26: 26:         uint nonce;
27: 27:         bool executed;
28: 28:     }
29: 29: 
30: 30:     modifier onlyWallet() {
31: 31:         if (msg.sender != address(this))
32: 32:             revert();
33: 33:         _;
34: 34:     }
35: 35: 
36: 36:     modifier signaturesFromOwners(bytes32 transactionHash, uint8[] v, bytes32[] rs) {
37: 37:         for (uint i=0; i<v.length; i++)
38: 38:             if (!isOwner[ecrecover(transactionHash, v[i], rs[i], rs[v.length + i])])
39: 39:                 revert();
40: 40:         _;
41: 41:     }
42: 42: 
43: 43:     modifier ownerDoesNotExist(address owner) {
44: 44:         if (isOwner[owner])
45: 45:             revert();
46: 46:         _;
47: 47:     }
48: 48: 
49: 49:     modifier ownerExists(address owner) {
50: 50:         if (!isOwner[owner])
51: 51:             revert();
52: 52:         _;
53: 53:     }
54: 54: 
55: 55:     modifier confirmed(bytes32 transactionHash, address owner) {
56: 56:         if (!confirmations[transactionHash][owner])
57: 57:             revert();
58: 58:         _;
59: 59:     }
60: 60: 
61: 61:     modifier notConfirmed(bytes32 transactionHash, address owner) {
62: 62:         if (confirmations[transactionHash][owner])
63: 63:             revert();
64: 64:         _;
65: 65:     }
66: 66: 
67: 67:     modifier notExecuted(bytes32 transactionHash) {
68: 68:         if (transactions[transactionHash].executed)
69: 69:             revert();
70: 70:         _;
71: 71:     }
72: 72: 
73: 73:     modifier notNull(address destination) {
74: 74:         if (destination == 0)
75: 75:             revert();
76: 76:         _;
77: 77:     }
78: 78: 
79: 79:     modifier validRequired(uint _ownerCount, uint _required) {
80: 80:         if (   _required > _ownerCount
81: 81:             || _required == 0
82: 82:             || _ownerCount == 0)
83: 83:             revert();
84: 84:         _;
85: 85:     }
86: 86: 
87: 87:     function addOwner(address owner)
88: 88:         external
89: 89:         onlyWallet
90: 90:         ownerDoesNotExist(owner)
91: 91:     {
92: 92:         isOwner[owner] = true;
93: 93:         owners.push(owner);
94: 94:         OwnerAddition(owner);
95: 95:     }
96: 96: 
97: 97:     function removeOwner(address owner)
98: 98:         external
99: 99:         onlyWallet
100: 100:         ownerExists(owner)
101: 101:     {
102: 102:         isOwner[owner] = false;
103: 103:         for (uint i=0; i<owners.length - 1; i++)
104: 104:             if (owners[i] == owner) {
105: 105:                 owners[i] = owners[owners.length - 1];
106: 106:                 break;
107: 107:             }
108: 108:         owners.length -= 1;
109: 109:         if (required > owners.length)
110: 110:             updateRequired(owners.length);
111: 111:         OwnerRemoval(owner);
112: 112:     }
113: 113: 
114: 114:     function updateRequired(uint _required)
115: 115:         public
116: 116:         onlyWallet
117: 117:         validRequired(owners.length, _required)
118: 118:     {
119: 119:         required = _required;
120: 120:         RequiredUpdate(_required);
121: 121:     }
122: 122: 
123: 123:     function addTransaction(address destination, uint value, bytes data, uint nonce)
124: 124:         private
125: 125:         notNull(destination)
126: 126:         returns (bytes32 transactionHash)
127: 127:     {
128: 128:         transactionHash = sha3(destination, value, data, nonce);
129: 129:         if (transactions[transactionHash].destination == 0) {
130: 130:             transactions[transactionHash] = Transaction({
131: 131:                 destination: destination,
132: 132:                 value: value,
133: 133:                 data: data,
134: 134:                 nonce: nonce,
135: 135:                 executed: false
136: 136:             });
137: 137:             transactionList.push(transactionHash);
138: 138:             Submission(transactionHash);
139: 139:         }
140: 140:     }
141: 141: 
142: 142:     function submitTransaction(address destination, uint value, bytes data, uint nonce)
143: 143:         external
144: 144:         ownerExists(msg.sender)
145: 145:         returns (bytes32 transactionHash)
146: 146:     {
147: 147:         transactionHash = addTransaction(destination, value, data, nonce);
148: 148:         confirmTransaction(transactionHash);
149: 149:     }
150: 150: 
151: 151:     function submitTransactionWithSignatures(address destination, uint value, bytes data, uint nonce, uint8[] v, bytes32[] rs)
152: 152:         external
153: 153:         ownerExists(msg.sender)
154: 154:         returns (bytes32 transactionHash)
155: 155:     {
156: 156:         transactionHash = addTransaction(destination, value, data, nonce);
157: 157:         confirmTransactionWithSignatures(transactionHash, v, rs);
158: 158:     }
159: 159: 
160: 160:     function addConfirmation(bytes32 transactionHash, address owner)
161: 161:         private
162: 162:         notConfirmed(transactionHash, owner)
163: 163:     {
164: 164:         confirmations[transactionHash][owner] = true;
165: 165:         Confirmation(owner, transactionHash);
166: 166:     }
167: 167: 
168: 168:     function confirmTransaction(bytes32 transactionHash)
169: 169:         public
170: 170:         ownerExists(msg.sender)
171: 171:     {
172: 172:         addConfirmation(transactionHash, msg.sender);
173: 173:         executeTransaction(transactionHash);
174: 174:     }
175: 175: 
176: 176:     function confirmTransactionWithSignatures(bytes32 transactionHash, uint8[] v, bytes32[] rs)
177: 177:         public
178: 178:         signaturesFromOwners(transactionHash, v, rs)
179: 179:     {
180: 180:         for (uint i=0; i<v.length; i++)
181: 181:             addConfirmation(transactionHash, ecrecover(transactionHash, v[i], rs[i], rs[i + v.length]));
182: 182:         executeTransaction(transactionHash);
183: 183:     }
184: 184: 
185: 185:     function executeTransaction(bytes32 transactionHash)
186: 186:         public
187: 187:         notExecuted(transactionHash)
188: 188:     {
189: 189:         if (isConfirmed(transactionHash)) {
190: 190:             Transaction storage txn = transactions[transactionHash]; 
191: 191:             txn.executed = true;
192: 192:             if (!txn.destination.call.value(txn.value)(txn.data))
193: 193:                 revert();
194: 194:             Execution(transactionHash);
195: 195:         }
196: 196:     }
197: 197: 
198: 198:     function revokeConfirmation(bytes32 transactionHash)
199: 199:         external
200: 200:         ownerExists(msg.sender)
201: 201:         confirmed(transactionHash, msg.sender)
202: 202:         notExecuted(transactionHash)
203: 203:     {
204: 204:         confirmations[transactionHash][msg.sender] = false;
205: 205:         Revocation(msg.sender, transactionHash);
206: 206:     }
207: 207: 
208: 208:     function MultiSigWallet(address[] _owners, uint _required)
209: 209:         validRequired(_owners.length, _required)
210: 210:     {
211: 211:         for (uint i=0; i<_owners.length; i++)
212: 212:             isOwner[_owners[i]] = true;
213: 213:         owners = _owners;
214: 214:         required = _required;
215: 215:     }
216: 216: 
217: 217:     function()
218: 218:         payable
219: 219:     {
220: 220:         if (msg.value > 0)
221: 221:             Deposit(msg.sender, msg.value);
222: 222:     }
223: 223: 
224: 224:     function isConfirmed(bytes32 transactionHash)
225: 225:         public
226: 226:         constant
227: 227:         returns (bool)
228: 228:     {
229: 229:         uint count = 0;
230: 230:         for (uint i=0; i<owners.length; i++)
231: 231:             if (confirmations[transactionHash][owners[i]])
232: 232:                 count += 1;
233: 233:             if (count == required)
234: 234:                 return true;
235: 235:     }
236: 236: 
237: 237:     function confirmationCount(bytes32 transactionHash)
238: 238:         external
239: 239:         constant
240: 240:         returns (uint count)
241: 241:     {
242: 242:         for (uint i=0; i<owners.length; i++)
243: 243:             if (confirmations[transactionHash][owners[i]])
244: 244:                 count += 1;
245: 245:     }
246: 246: 
247: 247:     function filterTransactions(bool isPending)
248: 248:         private
249: 249:         constant
250: 250:         returns (bytes32[] _transactionList)
251: 251:     {
252: 252:         bytes32[] memory _transactionListTemp = new bytes32[](transactionList.length);
253: 253:         uint count = 0;
254: 254:         for (uint i=0; i<transactionList.length; i++)
255: 255:             if (   isPending && !transactions[transactionList[i]].executed
256: 256:                 || !isPending && transactions[transactionList[i]].executed)
257: 257:             {
258: 258:                 _transactionListTemp[count] = transactionList[i];
259: 259:                 count += 1;
260: 260:             }
261: 261:         _transactionList = new bytes32[](count);
262: 262:         for (i=0; i<count; i++)
263: 263:             if (_transactionListTemp[i] > 0)
264: 264:                 _transactionList[i] = _transactionListTemp[i];
265: 265:     }
266: 266: 
267: 267:     function getPendingTransactions()
268: 268:         external
269: 269:         constant
270: 270:         returns (bytes32[])
271: 271:     {
272: 272:         return filterTransactions(true);
273: 273:     }
274: 274: 
275: 275:     function getExecutedTransactions()
276: 276:         external
277: 277:         constant
278: 278:         returns (bytes32[])
279: 279:     {
280: 280:         return filterTransactions(false);
281: 281:     }
282: 282:     
283: 283:     function createCoin()
284: 284:         external
285: 285:         onlyWallet
286: 286:     {
287: 287:         CoinCreation(new RoseCoin());
288: 288:     }
289: 289: }