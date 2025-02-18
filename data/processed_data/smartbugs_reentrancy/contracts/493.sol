1: 1: pragma solidity 0.5.6;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: contract MessageTransport is SafeMath, Ownable {
11: 11: 
12: 12:   
13: 13:   
14: 14:   
15: 15:   
16: 16:   
17: 17:   
18: 18:   event InviteEvent(address indexed _toAddr, address indexed _fromAddr);
19: 19:   event MessageEvent(uint indexed _id1, uint indexed _id2, uint indexed _id3,
20: 20:                      address _fromAddr, address _toAddr, address _via, uint _txCount, uint _rxCount, uint _attachmentIdx, uint _ref, bytes message);
21: 21:   event MessageTxEvent(address indexed _fromAddr, uint indexed _txCount, uint _id);
22: 22:   event MessageRxEvent(address indexed _toAddr, uint indexed _rxCount, uint _id);
23: 23: 
24: 24: 
25: 25:   
26: 26:   
27: 27:   
28: 28:   
29: 29:   struct Account {
30: 30:     bool isValid;
31: 31:     uint messageFee;           
32: 32:     uint spamFee;              
33: 33:     uint feeBalance;           
34: 34:     uint recvMessageCount;     
35: 35:     uint sentMessageCount;     
36: 36:     bytes publicKey;           
37: 37:     bytes encryptedPrivateKey; 
38: 38:     mapping (address => uint256) peerRecvMessageCount;
39: 39:     mapping (uint256 => uint256) recvIds;
40: 40:     mapping (uint256 => uint256) sentIds;
41: 41:   }
42: 42: 
43: 43: 
44: 44:   
45: 45:   
46: 46:   
47: 47:   bool public isLocked;
48: 48:   address public tokenAddr;
49: 49:   uint public messageCount;
50: 50:   uint public retainedFeesBalance;
51: 51:   mapping (address => bool) public trusted;
52: 52:   mapping (address => Account) public accounts;
53: 53: 
54: 54: 
55: 55:   
56: 56:   
57: 57:   
58: 58:   modifier trustedOnly {
59: 59:     require(trusted[msg.sender] == true, "trusted only");
60: 60:     _;
61: 61:   }
62: 62: 
63: 63: 
64: 64:   
65: 65:   
66: 66:   
67: 67:   constructor(address _tokenAddr) public {
68: 68:     tokenAddr = _tokenAddr;
69: 69:   }
70: 70:   function setTrust(address _trustedAddr, bool _trust) public onlyOwner {
71: 71:     trusted[_trustedAddr] = _trust;
72: 72:   }
73: 73: 
74: 74: 
75: 75:   
76: 76:   
77: 77:   
78: 78:   
79: 79:   
80: 80:   
81: 81:   
82: 82:   function register(uint256 _messageFee, uint256 _spamFee, bytes memory _publicKey, bytes memory _encryptedPrivateKey) public {
83: 83:     Account storage _account = accounts[msg.sender];
84: 84:     require(_account.isValid == false, "account already registered");
85: 85:     _account.publicKey = _publicKey;
86: 86:     _account.encryptedPrivateKey = _encryptedPrivateKey;
87: 87:     _account.isValid = true;
88: 88:     _modifyAccount(_account, _messageFee, _spamFee);
89: 89:   }
90: 90:   function modifyAccount(uint256 _messageFee, uint256 _spamFee) public {
91: 91:     Account storage _account = accounts[msg.sender];
92: 92:     require(_account.isValid == true, "not registered");
93: 93:     _modifyAccount(_account, _messageFee, _spamFee);
94: 94:   }
95: 95:   function _modifyAccount(Account storage _account, uint256 _messageFee, uint256 _spamFee) internal {
96: 96:     _account.messageFee = _messageFee;
97: 97:     _account.spamFee = _spamFee;
98: 98:   }
99: 99: 
100: 100: 
101: 101:   
102: 102:   
103: 103:   
104: 104:   function getPeerMessageCount(address _from, address _to) public view returns(uint256 _messageCount) {
105: 105:     Account storage _account = accounts[_to];
106: 106:     _messageCount = _account.peerRecvMessageCount[_from];
107: 107:   }
108: 108: 
109: 109: 
110: 110: 
111: 111:   
112: 112:   
113: 113:   
114: 114:   
115: 115:   function getRecvMsgs(address _to, uint256 _startIdx, uint256 _maxResults) public view returns(uint256 _idx, uint256[] memory _messageIds) {
116: 116:     uint _count = 0;
117: 117:     Account storage _recvAccount = accounts[_to];
118: 118:     uint256 _recvMessageCount = _recvAccount.recvMessageCount;
119: 119:     _messageIds = new uint256[](_maxResults);
120: 120:     mapping(uint256 => uint256) storage _recvIds = _recvAccount.recvIds;
121: 121:     
122: 122:     for (_idx = _startIdx; _idx < _recvMessageCount; ++_idx) {
123: 123:       _messageIds[_count] = _recvIds[_idx];
124: 124:       if (++_count >= _maxResults)
125: 125:         break;
126: 126:     }
127: 127:   }
128: 128: 
129: 129:   
130: 130:   
131: 131:   
132: 132:   
133: 133:   function getSentMsgs(address _from, uint256 _startIdx, uint256 _maxResults) public view returns(uint256 _idx, uint256[] memory _messageIds) {
134: 134:     uint _count = 0;
135: 135:     Account storage _sentAccount = accounts[_from];
136: 136:     uint256 _sentMessageCount = _sentAccount.sentMessageCount;
137: 137:     _messageIds = new uint256[](_maxResults);
138: 138:     mapping(uint256 => uint256) storage _sentIds = _sentAccount.sentIds;
139: 139:     
140: 140:     for (_idx = _startIdx; _idx < _sentMessageCount; ++_idx) {
141: 141:       _messageIds[_count] = _sentIds[_idx];
142: 142:       if (++_count >= _maxResults)
143: 143:         break;
144: 144:     }
145: 145:   }
146: 146: 
147: 147: 
148: 148:   
149: 149:   
150: 150:   
151: 151:   
152: 152:   function getFee(address _toAddr) public view returns(uint256 _fee) {
153: 153:     Account storage _sendAccount = accounts[msg.sender];
154: 154:     Account storage _recvAccount = accounts[_toAddr];
155: 155:     if (_sendAccount.peerRecvMessageCount[_toAddr] == 0)
156: 156:       _fee = _recvAccount.spamFee;
157: 157:     else
158: 158:       _fee = _recvAccount.messageFee;
159: 159:   }
160: 160:   function getFee(address _fromAddr, address _toAddr) public view trustedOnly returns(uint256 _fee) {
161: 161:     Account storage _sendAccount = accounts[_fromAddr];
162: 162:     Account storage _recvAccount = accounts[_toAddr];
163: 163:     if (_sendAccount.peerRecvMessageCount[_toAddr] == 0)
164: 164:       _fee = _recvAccount.spamFee;
165: 165:     else
166: 166:       _fee = _recvAccount.messageFee;
167: 167:   }
168: 168: 
169: 169: 
170: 170:   
171: 171:   
172: 172:   
173: 173:   
174: 174:   
175: 175:   
176: 176:   
177: 177:   function sendMessage(address _toAddr, uint attachmentIdx, uint _ref, bytes memory _message) public payable returns (uint _messageId) {
178: 178:     uint256 _noDataLength = 4 + 32 + 32 + 32 + 64;
179: 179:     _messageId = doSendMessage(_noDataLength, msg.sender, _toAddr, address(0), attachmentIdx, _ref, _message);
180: 180:   }
181: 181:   function sendMessage(address _fromAddr, address _toAddr, uint attachmentIdx, uint _ref, bytes memory _message) public payable trustedOnly returns (uint _messageId) {
182: 182:     uint256 _noDataLength = 4 + 32 + 32 + 32 + 32 + 64;
183: 183:     _messageId = doSendMessage(_noDataLength, _fromAddr, _toAddr, msg.sender, attachmentIdx, _ref, _message);
184: 184:   }
185: 185: 
186: 186: 
187: 187:   function doSendMessage(uint256 _noDataLength, address _fromAddr, address _toAddr, address _via, uint attachmentIdx, uint _ref, bytes memory _message) internal returns (uint _messageId) {
188: 188:     Account storage _sendAccount = accounts[_fromAddr];
189: 189:     Account storage _recvAccount = accounts[_toAddr];
190: 190:     require(_sendAccount.isValid == true, "sender not registered");
191: 191:     require(_recvAccount.isValid == true, "recipient not registered");
192: 192:     
193: 193:     
194: 194:     
195: 195:     if (msg.data.length > _noDataLength) {
196: 196:       if (_sendAccount.peerRecvMessageCount[_toAddr] == 0)
197: 197:         require(msg.value >= _recvAccount.spamFee, "spam fee is insufficient");
198: 198:       else
199: 199:         require(msg.value >= _recvAccount.messageFee, "fee is insufficient");
200: 200:       messageCount = safeAdd(messageCount, 1);
201: 201:       _recvAccount.recvIds[_recvAccount.recvMessageCount] = messageCount;
202: 202:       _sendAccount.sentIds[_sendAccount.sentMessageCount] = messageCount;
203: 203:       _recvAccount.recvMessageCount = safeAdd(_recvAccount.recvMessageCount, 1);
204: 204:       _sendAccount.sentMessageCount = safeAdd(_sendAccount.sentMessageCount, 1);
205: 205:       emit MessageEvent(messageCount, messageCount, messageCount, _fromAddr, _toAddr, _via, _sendAccount.sentMessageCount, _recvAccount.recvMessageCount, attachmentIdx, _ref, _message);
206: 206:       emit MessageTxEvent(_fromAddr, _sendAccount.sentMessageCount, messageCount);
207: 207:       emit MessageRxEvent(_toAddr, _recvAccount.recvMessageCount, messageCount);
208: 208:       
209: 209:       _messageId = messageCount;
210: 210:     } else {
211: 211:       emit InviteEvent(_toAddr, _fromAddr);
212: 212:       _messageId = 0;
213: 213:     }
214: 214:     uint _retainAmount = safeMul(msg.value, 30) / 100;
215: 215:     retainedFeesBalance = safeAdd(retainedFeesBalance, _retainAmount);
216: 216:     _recvAccount.feeBalance = safeAdd(_recvAccount.feeBalance, safeSub(msg.value, _retainAmount));
217: 217:     _recvAccount.peerRecvMessageCount[_fromAddr] = safeAdd(_recvAccount.peerRecvMessageCount[_fromAddr], 1);
218: 218:   }
219: 219: 
220: 220: 
221: 221:   
222: 222:   
223: 223:   
224: 224:   function withdraw() public {
225: 225:     Account storage _account = accounts[msg.sender];
226: 226:     uint _amount = _account.feeBalance;
227: 227:     _account.feeBalance = 0;
228: 228:     msg.sender.transfer(_amount);
229: 229:   }
230: 230: 
231: 231: 
232: 232:   
233: 233:   
234: 234:   
235: 235:   function withdrawRetainedFees() public {
236: 236:     uint _amount = retainedFeesBalance / 2;
237: 237:     address(0).transfer(_amount);
238: 238:     _amount = safeSub(retainedFeesBalance, _amount);
239: 239:     retainedFeesBalance = 0;
240: 240:     (bool paySuccess, ) = tokenAddr.call.value(_amount)("");
241: 241:     require(paySuccess, "failed to transfer fees");
242: 242:   }
243: 243: 
244: 244: }