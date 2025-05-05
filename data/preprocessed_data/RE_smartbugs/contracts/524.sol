1: pragma solidity 0.5.0;
2: 
3: contract SolidifiedVault {
4: 
5:     
6: 
7: 
8:     event Confirmation(address indexed sender, uint indexed transactionId);
9:     event Revocation(address indexed sender, uint indexed transactionId);
10:     event Submission(uint indexed transactionId);
11:     event Execution(uint indexed transactionId);
12:     event ExecutionFailure(uint indexed transactionId);
13:     event Deposit(address indexed sender, uint value);
14:     event OwnerAddition(address indexed owner);
15:     event OwnerRemoval(address indexed owner);
16:     event RequirementChange(uint required);
17: 
18:     
19: 
20: 
21:     uint constant public MAX_OWNER_COUNT = 3;
22: 
23:     
24: 
25: 
26:     mapping (uint => Transaction) public transactions;
27:     mapping (uint => mapping (address => bool)) public confirmations;
28:     mapping (address => bool) public isOwner;
29:     address[] public owners;
30:     uint public required;
31:     uint public transactionCount;
32: 
33:     struct Transaction {
34:         address destination;
35:         uint value;
36:         bool executed;
37:     }
38: 
39:     
40: 
41: 
42:     modifier onlyWallet() {
43:         require(msg.sender == address(this), "Vault: sender should be wallet");
44:         _;
45:     }
46: 
47:     modifier ownerDoesNotExist(address owner) {
48:         require(!isOwner[owner], "Vault:sender shouldn't be owner");
49:         _;
50:     }
51: 
52:     modifier ownerExists(address owner) {
53:         require(isOwner[owner], "Vault:sender should be owner");
54:         _;
55:     }
56: 
57:     modifier transactionExists(uint transactionId) {
58:         require(transactions[transactionId].destination != address(0),"Vault:transaction should exist");
59:         _;
60:     }
61: 
62:     modifier confirmed(uint transactionId, address owner) {
63:         require(confirmations[transactionId][owner], "Vault:transaction should be confirmed");
64:         _;
65:     }
66: 
67:     modifier notConfirmed(uint transactionId, address owner) {
68:         require(!confirmations[transactionId][owner], "Vault:transaction is already confirmed");
69:         _;
70:     }
71: 
72:     modifier notExecuted(uint transactionId) {
73:         require(!transactions[transactionId].executed, "Vault:transaction has already executed");
74:         _;
75:     }
76: 
77:     modifier notNull(address _address) {
78:         require(_address != address(0), "Vault:address shouldn't be null");
79:         _;
80:     }
81: 
82:     modifier validRequirement(uint ownerCount, uint _required) {
83:         require(ownerCount <= MAX_OWNER_COUNT
84:             && _required <= ownerCount
85:             && _required != 0
86:             && ownerCount != 0, "Vault:invalid requirement");
87:         _;
88:     }
89: 
90:     
91: 
92: 
93:     function()
94:         external
95:         payable
96:     {
97:         if (msg.value > 0)
98:             emit Deposit(msg.sender, msg.value);
99:     }
100: 
101:     
102: 
103: 
104:      
105: 
106: 
107: 
108: 
109:     constructor(address[] memory _owners, uint _required)
110:         public
111:         validRequirement(_owners.length, _required)
112:     {
113:         for (uint i=0; i<_owners.length; i++) {
114:             require(!isOwner[_owners[i]] && _owners[i] != address(0), "Vault:Invalid owner");
115:             isOwner[_owners[i]] = true;
116:         }
117:         owners = _owners;
118:         required = _required;
119:     }
120: 
121: 
122:     
123:     
124:     
125:     
126:     function submitTransaction(address destination, uint value)
127:         public
128:         returns (uint transactionId)
129:     {
130:         transactionId = addTransaction(destination, value);
131:         confirmTransaction(transactionId);
132:     }
133: 
134:     
135:     
136:     function confirmTransaction(uint transactionId)
137:         public
138:         ownerExists(msg.sender)
139:         transactionExists(transactionId)
140:         notConfirmed(transactionId, msg.sender)
141:     {
142:         confirmations[transactionId][msg.sender] = true;
143:         emit Confirmation(msg.sender, transactionId);
144:         executeTransaction(transactionId);
145:     }
146: 
147:     
148:     
149:     function revokeConfirmation(uint transactionId)
150:         public
151:         ownerExists(msg.sender)
152:         confirmed(transactionId, msg.sender)
153:         notExecuted(transactionId)
154:     {
155:         confirmations[transactionId][msg.sender] = false;
156:         emit Revocation(msg.sender, transactionId);
157:     }
158: 
159:     
160:     
161:     function executeTransaction(uint transactionId)
162:         public
163:         ownerExists(msg.sender)
164:         confirmed(transactionId, msg.sender)
165:         notExecuted(transactionId)
166:     {
167:         if (isConfirmed(transactionId)) {
168:             Transaction storage txn = transactions[transactionId];
169:             txn.executed = true;
170:             (bool exec, bytes memory _) = txn.destination.call.value(txn.value)("");
171:             if (exec)
172:                 emit Execution(transactionId);
173:             else {
174:                 emit ExecutionFailure(transactionId);
175:                 txn.executed = false;
176:             }
177:         }
178:     }
179: 
180:     
181:     
182:     
183:     function isConfirmed(uint transactionId)
184:         public
185:         view
186:         returns (bool)
187:     {
188:         uint count = 0;
189:         for (uint i=0; i<owners.length; i++) {
190:             if (confirmations[transactionId][owners[i]])
191:                 count += 1;
192:             if (count == required)
193:                 return true;
194:         }
195:     }
196: 
197:     
198: 
199: 
200:     
201:     
202:     
203:     
204:     function addTransaction(address destination, uint value)
205:         internal
206:         notNull(destination)
207:         returns (uint transactionId)
208:     {
209:         transactionId = transactionCount;
210:         transactions[transactionId] = Transaction({
211:             destination: destination,
212:             value: value,
213:             executed: false
214:         });
215:         transactionCount += 1;
216:         emit Submission(transactionId);
217:     }
218: 
219:     
220: 
221: 
222:     
223:     
224:     
225:     function getConfirmationCount(uint transactionId)
226:         public
227:         view
228:         returns (uint count)
229:     {
230:         for (uint i=0; i<owners.length; i++)
231:             if (confirmations[transactionId][owners[i]])
232:                 count += 1;
233:     }
234: 
235:     
236:     
237:     
238:     
239:     function getTransactionCount(bool pending, bool executed)
240:         public
241:         view
242:         returns (uint count)
243:     {
244:         for (uint i=0; i<transactionCount; i++)
245:             if (   pending && !transactions[i].executed
246:                 || executed && transactions[i].executed)
247:                 count += 1;
248:     }
249: 
250:     
251:     
252:     function getOwners()
253:         public
254:         view
255:         returns (address[] memory)
256:     {
257:         return owners;
258:     }
259: 
260:     
261:     
262:     
263:     function getConfirmations(uint transactionId)
264:         public
265:         view
266:         returns (address[] memory _confirmations)
267:     {
268:         address[] memory confirmationsTemp = new address[](owners.length);
269:         uint count = 0;
270:         uint i;
271:         for (i=0; i<owners.length; i++)
272:             if (confirmations[transactionId][owners[i]]) {
273:                 confirmationsTemp[count] = owners[i];
274:                 count += 1;
275:             }
276:         _confirmations = new address[](count);
277:         for (i=0; i<count; i++)
278:             _confirmations[i] = confirmationsTemp[i];
279:     }
280: 
281:     
282:     
283:     
284:     
285:     
286:     
287:     function getTransactionIds(uint from, uint to, bool pending, bool executed)
288:         public
289:         view
290:         returns (uint[] memory _transactionIds)
291:     {
292:         uint[] memory transactionIdsTemp = new uint[](transactionCount);
293:         uint count = 0;
294:         uint i;
295:         for (i=0; i<transactionCount; i++)
296:             if (   pending && !transactions[i].executed
297:                 || executed && transactions[i].executed)
298:             {
299:                 transactionIdsTemp[count] = i;
300:                 count += 1;
301:             }
302:         _transactionIds = new uint[](to - from);
303:         for (i=from; i<to; i++)
304:             _transactionIds[i - from] = transactionIdsTemp[i];
305:     }
306: }