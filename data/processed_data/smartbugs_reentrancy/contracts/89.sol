1: 1: pragma solidity ^0.5.0;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: 
12: 12: 
13: 13: 
14: 14: 
15: 15: 
16: 16: 
17: 17: 
18: 18: 
19: 19: 
20: 20: 
21: 21: 
22: 22: 
23: 23: 
24: 24: 
25: 25: 
26: 26: 
27: 27: 
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32: 
33: 33: 
34: 34: 
35: 35: contract PirateLottery {
36: 36: 
37: 37:   
38: 38:   
39: 39:   
40: 40:   event WinnerEvent(uint256 round, uint256 ticket, uint256 prize);
41: 41:   event PayoutEvent(uint256 round, address payee, uint256 prize, uint256 payout);
42: 42: 
43: 43: 
44: 44:   
45: 45:   
46: 46:   
47: 47:   uint constant MIN_TICKETS = 10;
48: 48:   uint constant MAX_TICKETS = 50000000;
49: 49:   uint constant LONG_DURATION = 5 days;
50: 50:   uint constant SHORT_DURATION = 12 hours;
51: 51:   uint constant MAX_CLAIM_DURATION = 5 days;
52: 52:   uint constant TOKEN_HOLDOVER_THRESHOLD = 20 finney;
53: 53: 
54: 54: 
55: 55:   
56: 56:   
57: 57:   
58: 58:   
59: 59:   struct Round {
60: 60:     uint256 maxTickets;
61: 61:     uint256 ticketPrice;
62: 62:     uint256 ticketCount;
63: 63:     bytes32 playersHash;
64: 64:     uint256 begDate;
65: 65:     uint256 endDate;
66: 66:     uint256 winner;
67: 67:     uint256 prize;
68: 68:     bool isOpen;
69: 69:     mapping (uint256 => address) ticketOwners;
70: 70:     mapping (address => uint256) playerTicketCounts;
71: 71:     mapping (address => mapping (uint256 => uint256)) playerTickets;
72: 72:   }
73: 73: 
74: 74:   
75: 75:   
76: 76:   
77: 77:   
78: 78:   struct Claim {
79: 79:     uint256 ticket;
80: 80:     uint256 playerHash;
81: 81:   }
82: 82:   bytes32 private DOMAIN_SEPARATOR;
83: 83:   bytes32 private constant CLAIM_TYPEHASH = keccak256("Claim(string lottery,uint256 round,uint256 ticket,uint256 playerHash)");
84: 84:   bytes32 private constant EIP712DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
85: 85: 
86: 86: 
87: 87:   
88: 88:   
89: 89:   
90: 90:   bool    public isLocked;
91: 91:   string  public name;
92: 92:   address payable public owner;
93: 93:   bytes32 nameHash;
94: 94:   uint256 public min_ticket_price;
95: 95:   uint256 public max_ticket_price;
96: 96:   uint256 public roundCount;
97: 97:   mapping (uint256 => Round) public rounds;
98: 98:   mapping (address => uint256) public balances;
99: 99:   mapping (address => uint256) public plpPoints;
100: 100:   iPlpPointsRedeemer plpToken;
101: 101:   uint256 public tokenHoldoverBalance;
102: 102: 
103: 103:   
104: 104:   
105: 105:   
106: 106:   modifier ownerOnly {
107: 107:     require(msg.sender == owner, "owner only");
108: 108:     _;
109: 109:   }
110: 110:   modifier unlockedOnly {
111: 111:     require(!isLocked, "unlocked only");
112: 112:     _;
113: 113:   }
114: 114: 
115: 115: 
116: 116:   
117: 117:   
118: 118:   
119: 119:   constructor(address _plpToken, uint256 _chainId, string memory _name, uint256 _min_ticket_price, uint256 _max_ticket_price) public {
120: 120:     owner = msg.sender;
121: 121:     name = _name;
122: 122:     min_ticket_price = _min_ticket_price;
123: 123:     max_ticket_price = _max_ticket_price;
124: 124:     plpToken = iPlpPointsRedeemer(_plpToken);
125: 125:     Round storage _currentRound = rounds[1];
126: 126:     Round storage _previousRound = rounds[0];
127: 127:     _previousRound.maxTickets = 1;
128: 128:     
129: 129:     _previousRound.ticketCount = 1;
130: 130:     _previousRound.playersHash = keccak256(abi.encodePacked(bytes32(0), owner));
131: 131:     _previousRound.begDate = now;
132: 132:     _previousRound.endDate = now;
133: 133:     _previousRound.winner = 1;
134: 134:     _previousRound.ticketOwners[1] = msg.sender;
135: 135:     _previousRound.playerTickets[msg.sender][0] = 1;
136: 136:     _previousRound.playerTicketCounts[msg.sender]++;
137: 137:     
138: 138:     _currentRound.maxTickets = 2;
139: 139:     _currentRound.ticketPrice = (min_ticket_price + max_ticket_price) / 2;
140: 140:     
141: 141:     
142: 142:     
143: 143:     
144: 144:     
145: 145:     
146: 146:     _currentRound.isOpen = true;
147: 147:     roundCount = 1;
148: 148:     
149: 149:     DOMAIN_SEPARATOR = keccak256(abi.encode(EIP712DOMAIN_TYPEHASH,
150: 150:                                             keccak256("Pirate Lottery"),
151: 151:                                             keccak256("1.0"),
152: 152:                                             _chainId,
153: 153:                                             address(this)));
154: 154:     nameHash = keccak256(abi.encodePacked(name));
155: 155:   }
156: 156:   
157: 157:   function setToken(address _plpToken) public unlockedOnly ownerOnly {
158: 158:     plpToken = iPlpPointsRedeemer(_plpToken);
159: 159:   }
160: 160:   function lock() public ownerOnly {
161: 161:     isLocked = true;
162: 162:   }
163: 163: 
164: 164: 
165: 165:   
166: 166:   
167: 167:   
168: 168:   function buyTicket() public payable {
169: 169:     Round storage _currentRound = rounds[roundCount];
170: 170:     require(_currentRound.isOpen == true, "current round is closed");
171: 171:     require(msg.value == _currentRound.ticketPrice, "incorrect ticket price");
172: 172:     if (_currentRound.ticketCount == 0)
173: 173:       _currentRound.begDate = now;
174: 174:     _currentRound.ticketCount++;
175: 175:     _currentRound.prize += msg.value;
176: 176:     plpPoints[msg.sender]++;
177: 177:     uint256 _ticket = _currentRound.ticketCount;
178: 178:     _currentRound.ticketOwners[_ticket] = msg.sender;
179: 179:     uint256 _playerTicketCount = _currentRound.playerTicketCounts[msg.sender];
180: 180:     _currentRound.playerTickets[msg.sender][_playerTicketCount] = _ticket;
181: 181:     _currentRound.playerTicketCounts[msg.sender]++;
182: 182:     _currentRound.playersHash = keccak256(abi.encodePacked(_currentRound.playersHash, msg.sender));
183: 183:     uint256 _currentDuration = now - _currentRound.begDate;
184: 184:     if (_currentRound.ticketCount == _currentRound.maxTickets || _currentDuration > LONG_DURATION) {
185: 185:       _currentRound.playersHash = keccak256(abi.encodePacked(_currentRound.playersHash, block.coinbase));
186: 186:       _currentRound.isOpen = false;
187: 187:       _currentRound.endDate = now;
188: 188:     }
189: 189:   }
190: 190: 
191: 191: 
192: 192:   
193: 193:   
194: 194:   
195: 195:   
196: 196:   function getCurrentInfo(address _addr) public view returns(uint256 _round, uint256 _playerTicketCount, uint256 _ticketPrice,
197: 197:                                                              uint256 _ticketCount, uint256 _begDate, uint256 _endDate, uint256 _prize,
198: 198:                                                              bool _isOpen, uint256 _maxTickets) {
199: 199:     Round storage _currentRound = rounds[roundCount];
200: 200:     _round = roundCount;
201: 201:     _playerTicketCount = _currentRound.playerTicketCounts[_addr];
202: 202:     _ticketPrice = _currentRound.ticketPrice;
203: 203:     _ticketCount = _currentRound.ticketCount;
204: 204:     _begDate = _currentRound.begDate;
205: 205:     _endDate = _currentRound.isOpen ? (_currentRound.begDate + LONG_DURATION) : _currentRound.endDate;
206: 206:     _prize = _currentRound.prize;
207: 207:     _isOpen = _currentRound.isOpen;
208: 208:     _maxTickets = _currentRound.maxTickets;
209: 209:   }
210: 210: 
211: 211: 
212: 212:   
213: 213:   
214: 214:   
215: 215:   function getPreviousInfo(address _addr) public view returns(uint256 _round, uint256 _playerTicketCount, uint256 _ticketPrice, uint256 _ticketCount,
216: 216:                                                               uint256 _begDate, uint256 _endDate, uint256 _prize,
217: 217:                                                               uint256 _winningTicket, address _winner, uint256 _claimDeadline, bytes32 _playersHash) {
218: 218:     Round storage _currentRound = rounds[roundCount];
219: 219:     Round storage _previousRound = rounds[roundCount - 1];
220: 220:     _round = roundCount - 1;
221: 221:     _playerTicketCount = _previousRound.playerTicketCounts[_addr];
222: 222:     _ticketPrice = _previousRound.ticketPrice;
223: 223:     _ticketCount = _previousRound.ticketCount;
224: 224:     _begDate = _previousRound.begDate;
225: 225:     _endDate = _previousRound.endDate;
226: 226:     _prize = _previousRound.prize;
227: 227:     _winningTicket = _previousRound.winner;
228: 228:     _winner = _previousRound.ticketOwners[_previousRound.winner];
229: 229:     if (_currentRound.isOpen == true) {
230: 230:       _playersHash = bytes32(0);
231: 231:       _claimDeadline = 0;
232: 232:     } else {
233: 233:       _playersHash = _currentRound.playersHash;
234: 234:       _claimDeadline = _currentRound.endDate + MAX_CLAIM_DURATION;
235: 235:     }
236: 236:   }
237: 237: 
238: 238: 
239: 239:   
240: 240:   
241: 241:   
242: 242:   
243: 243:   function getTickets(address _addr, uint256 _round, uint256 _startIdx, uint256 _maxResults) public view returns(uint256 _idx, uint256[] memory _tickets) {
244: 244:     uint _count = 0;
245: 245:     Round storage _subjectRound = rounds[_round];
246: 246:     _tickets = new uint256[](_maxResults);
247: 247:     uint256 _playerTicketCount = _subjectRound.playerTicketCounts[_addr];
248: 248:     mapping(uint256 => uint256) storage _playerTickets = _subjectRound.playerTickets[_addr];
249: 249:     for (_idx = _startIdx; _idx < _playerTicketCount; ++_idx) {
250: 250:       _tickets[_count] = _playerTickets[_idx];
251: 251:       if (++_count >= _maxResults)
252: 252:         break;
253: 253:     }
254: 254:   }
255: 255: 
256: 256:   
257: 257:   
258: 258:   function getTicketOwner(uint256 _round, uint256 _ticket) public view returns(address _owner) {
259: 259:     Round storage _subjectRound = rounds[_round];
260: 260:     _owner = _subjectRound.ticketOwners[_ticket];
261: 261:   }
262: 262: 
263: 263: 
264: 264:   
265: 265:   
266: 266:   
267: 267:   
268: 268:   
269: 269:   
270: 270:   function claimPrize(uint8 _sigV, bytes32 _sigR, bytes32 _sigS, uint256 _ticket) public {
271: 271:     Round storage _currentRound = rounds[roundCount];
272: 272:     Round storage _previousRound = rounds[roundCount - 1];
273: 273:     require(_currentRound.isOpen == false, "wait until current round is closed");
274: 274:     require(_previousRound.winner == _ticket, "not the winning ticket");
275: 275:     claimPrizeForTicket(_sigV, _sigR, _sigS, _ticket, 2);
276: 276:     newRound();
277: 277:   }
278: 278: 
279: 279: 
280: 280:   
281: 281:   
282: 282:   
283: 283:   
284: 284:   function claimAbondonedPrize(uint8 _sigV, bytes32 _sigR, bytes32 _sigS, uint256 _ticket) public {
285: 285:     Round storage _currentRound = rounds[roundCount];
286: 286:     require(_currentRound.isOpen == false, "wait until current round is closed");
287: 287:     require(now >= _currentRound.endDate + MAX_CLAIM_DURATION, "prize is not abondoned yet");
288: 288:     claimPrizeForTicket(_sigV, _sigR, _sigS, _ticket, 50);
289: 289:     newRound();
290: 290:   }
291: 291: 
292: 292: 
293: 293:   
294: 294:   
295: 295:   
296: 296:   
297: 297:   function claimPrizeForTicket(uint8 _sigV, bytes32 _sigR, bytes32 _sigS, uint256 _ticket, uint256 _ownerCutPct) internal {
298: 298:     Round storage _currentRound = rounds[roundCount];
299: 299:     Round storage _previousRound = rounds[roundCount - 1];
300: 300:     bytes32 _claimHash = keccak256(abi.encode(CLAIM_TYPEHASH, nameHash, roundCount - 1, _ticket, _currentRound.playersHash));
301: 301:     bytes32 _domainClaimHash = keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, _claimHash));
302: 302:     address _recovered = ecrecover(_domainClaimHash, _sigV, _sigR, _sigS);
303: 303:     require(_previousRound.ticketOwners[_ticket] == _recovered, "claim is not valid");
304: 304:     uint256 _tokenCut = _ownerCutPct * _previousRound.prize / 100;
305: 305:     tokenHoldoverBalance += _tokenCut;
306: 306:     uint256 _payout = _previousRound.prize - _tokenCut;
307: 307:     balances[msg.sender] += _payout;
308: 308:     bytes32 _winningHash = keccak256(abi.encodePacked(_currentRound.playersHash, _sigV, _sigR, _sigS));
309: 309:     _currentRound.winner = uint256(_winningHash) % _currentRound.ticketCount + 1;
310: 310:     emit PayoutEvent(roundCount - 1, msg.sender, _previousRound.prize, _payout);
311: 311:     emit WinnerEvent(roundCount, _currentRound.winner, _currentRound.prize);
312: 312:     
313: 313:     if (tokenHoldoverBalance > TOKEN_HOLDOVER_THRESHOLD) {
314: 314:       uint _amount = tokenHoldoverBalance;
315: 315:       tokenHoldoverBalance = 0;
316: 316:       (bool paySuccess, ) = address(plpToken).call.value(_amount)("");
317: 317:       if (!paySuccess)
318: 318:         revert();
319: 319:     }
320: 320:   }
321: 321: 
322: 322: 
323: 323:   
324: 324:   
325: 325:   
326: 326:   
327: 327:   
328: 328:   function newRound() internal {
329: 329:     ++roundCount;
330: 330:     Round storage _nextRound = rounds[roundCount];
331: 331:     Round storage _currentRound = rounds[roundCount - 1];
332: 332:     uint256 _currentDuration = _currentRound.endDate - _currentRound.begDate;
333: 333:     
334: 334:     if (_currentDuration < SHORT_DURATION) {
335: 335:       if (_currentRound.ticketPrice < max_ticket_price && _currentRound.maxTickets > MIN_TICKETS * 10) {
336: 336:          _nextRound.ticketPrice = max_ticket_price;
337: 337:          _nextRound.maxTickets = _currentRound.maxTickets;
338: 338:        } else {
339: 339:          _nextRound.ticketPrice = _currentRound.ticketPrice;
340: 340:          _nextRound.maxTickets = 2 * _currentRound.maxTickets;
341: 341:          if (_nextRound.maxTickets > MAX_TICKETS)
342: 342:            _nextRound.maxTickets = MAX_TICKETS;
343: 343:        }
344: 344:     } else if (_currentDuration > LONG_DURATION) {
345: 345:        if (_currentRound.ticketPrice > min_ticket_price) {
346: 346:          _nextRound.ticketPrice = min_ticket_price;
347: 347:          _nextRound.maxTickets = _currentRound.maxTickets;
348: 348:        } else {
349: 349:          _nextRound.ticketPrice = min_ticket_price;
350: 350:          _nextRound.maxTickets = _currentRound.maxTickets / 2;
351: 351:          if (_nextRound.maxTickets < MIN_TICKETS)
352: 352:            _nextRound.maxTickets = MIN_TICKETS;
353: 353:        }
354: 354:     } else {
355: 355:       _nextRound.maxTickets = _currentRound.maxTickets;
356: 356:       _nextRound.ticketPrice = (min_ticket_price + max_ticket_price) / 2;
357: 357:     }
358: 358:     
359: 359:     
360: 360:     
361: 361:     _nextRound.isOpen = true;
362: 362:   }
363: 363: 
364: 364: 
365: 365:   
366: 366:   
367: 367:   
368: 368:   
369: 369:   function redeemPlpPoints() public {
370: 370:     uint256 noTokens = plpPoints[msg.sender];
371: 371:     plpPoints[msg.sender] = 0;
372: 372:     plpToken.transferFromReserve(msg.sender, noTokens);
373: 373:   }
374: 374: 
375: 375: 
376: 376:   
377: 377:   
378: 378:   
379: 379:   function withdraw() public {
380: 380:     uint256 _amount = balances[msg.sender];
381: 381:     balances[msg.sender] = 0;
382: 382:     msg.sender.transfer(_amount);
383: 383:   }
384: 384: 
385: 385: 
386: 386:   
387: 387:   
388: 388:   
389: 389:   
390: 390:   function killContract() public ownerOnly unlockedOnly {
391: 391:     selfdestruct(owner);
392: 392:   }
393: 393: }