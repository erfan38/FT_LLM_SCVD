1: 1: 1: 1: 1: pragma solidity ^0.4.24;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: contract TwoCoinsOneMoonGame {
4: 4: 4: 4: 4:     struct Bettor {
5: 5: 5: 5: 5:         address account;
6: 6: 6: 6: 6:         uint256 amount;
7: 7: 7: 7: 7:         uint256 amountEth;
8: 8: 8: 8: 8:     }
9: 9: 9: 9: 9: 
10: 10: 10: 10: 10:     struct Event {
11: 11: 11: 11: 11:         uint256 winner; 
12: 12: 12: 12: 12:         uint256 newMoonLevel;
13: 13: 13: 13: 13:         uint256 block;
14: 14: 14: 14: 14:         uint256 blueCap;
15: 15: 15: 15: 15:         uint256 redCap;
16: 16: 16: 16: 16:     }
17: 17: 17: 17: 17: 
18: 18: 18: 18: 18:     uint256 public lastLevelChangeBlock;
19: 19: 19: 19: 19:     uint256 public lastEventId;
20: 20: 20: 20: 20:     uint256 public lastActionBlock;
21: 21: 21: 21: 21:     uint256 public moonLevel;
22: 22: 22: 22: 22: 
23: 23: 23: 23: 23:     uint256 public marketCapBlue;
24: 24: 24: 24: 24:     uint256 public marketCapRed;
25: 25: 25: 25: 25: 
26: 26: 26: 26: 26:     uint256 public jackpotBlue;
27: 27: 27: 27: 27:     uint256 public jackpotRed;
28: 28: 28: 28: 28:     
29: 29: 29: 29: 29:     uint256 public startBetBlue;
30: 30: 30: 30: 30:     uint256 public endBetBlue;
31: 31: 31: 31: 31:     uint256 public startBetRed;
32: 32: 32: 32: 32:     uint256 public endBetRed;
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34:     Bettor[] public bettorsBlue;
35: 35: 35: 35: 35:     Bettor[] public bettorsRed;
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37:     Event[] public history;
38: 38: 38: 38: 38: 
39: 39: 39: 39: 39:     mapping (address => uint) public balance;
40: 40: 40: 40: 40: 
41: 41: 41: 41: 41:     address private feeCollector;
42: 42: 42: 42: 42: 
43: 43: 43: 43: 43:     DiscountToken discountToken;
44: 44: 44: 44: 44: 
45: 45: 45: 45: 45:     string public publisherMessage;
46: 46: 46: 46: 46:     address publisher;
47: 47: 47: 47: 47: 
48: 48: 48: 48: 48:     bool isPaused;
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50:     constructor() public {
51: 51: 51: 51: 51:         marketCapBlue = 0;
52: 52: 52: 52: 52:         marketCapRed = 0;
53: 53: 53: 53: 53: 
54: 54: 54: 54: 54:         jackpotBlue = 0;
55: 55: 55: 55: 55:         jackpotRed = 0;
56: 56: 56: 56: 56:         
57: 57: 57: 57: 57:         startBetBlue = 0;
58: 58: 58: 58: 58:         startBetRed = 0;
59: 59: 59: 59: 59: 
60: 60: 60: 60: 60:         endBetBlue = 0;
61: 61: 61: 61: 61:         endBetRed = 0;
62: 62: 62: 62: 62: 
63: 63: 63: 63: 63:         publisher = msg.sender;
64: 64: 64: 64: 64:         feeCollector = 0xfD4e7B9F4F97330356F7d1b5DDB9843F2C3e9d87;
65: 65: 65: 65: 65:         discountToken = DiscountToken(0x25a803EC5d9a14D41F1Af5274d3f2C77eec80CE9);
66: 66: 66: 66: 66:         lastLevelChangeBlock = block.number;
67: 67: 67: 67: 67: 
68: 68: 68: 68: 68:         lastActionBlock = block.number;
69: 69: 69: 69: 69:         moonLevel = 5 * (uint256(10) ** 17);
70: 70: 70: 70: 70:         isPaused = false;
71: 71: 71: 71: 71:     }
72: 72: 72: 72: 72: 
73: 73: 73: 73: 73:     function getBetAmountGNC(uint256 marketCap, uint256 tokenCount, uint256 betAmount) private view returns (uint256) {
74: 74: 74: 74: 74:         require (msg.value >= 100 finney);
75: 75: 75: 75: 75: 
76: 76: 76: 76: 76:         uint256 betAmountGNC = 0;
77: 77: 77: 77: 77:         if (marketCap < 1 * moonLevel / 100) {
78: 78: 78: 78: 78:             betAmountGNC += 10 * betAmount;
79: 79: 79: 79: 79:         }
80: 80: 80: 80: 80:         else if (marketCap < 2 * moonLevel / 100) {
81: 81: 81: 81: 81:             betAmountGNC += 8 * betAmount;
82: 82: 82: 82: 82:         }
83: 83: 83: 83: 83:         else if (marketCap < 5 * moonLevel / 100) {
84: 84: 84: 84: 84:             betAmountGNC += 5 * betAmount;
85: 85: 85: 85: 85:         }
86: 86: 86: 86: 86:         else if (marketCap < 10 * moonLevel / 100) {
87: 87: 87: 87: 87:             betAmountGNC += 4 * betAmount;
88: 88: 88: 88: 88:         }
89: 89: 89: 89: 89:         else if (marketCap < 20 * moonLevel / 100) {
90: 90: 90: 90: 90:             betAmountGNC += 3 * betAmount;
91: 91: 91: 91: 91:         }
92: 92: 92: 92: 92:         else if (marketCap < 33 * moonLevel / 100) {
93: 93: 93: 93: 93:             betAmountGNC += 2 * betAmount;
94: 94: 94: 94: 94:         }
95: 95: 95: 95: 95:         else {
96: 96: 96: 96: 96:             betAmountGNC += betAmount;
97: 97: 97: 97: 97:         }
98: 98: 98: 98: 98: 
99: 99: 99: 99: 99:         if (tokenCount != 0) {
100: 100: 100: 100: 100:             if (tokenCount >= 2 && tokenCount <= 4) {
101: 101: 101: 101: 101:                 betAmountGNC = betAmountGNC *  105 / 100;
102: 102: 102: 102: 102:             }
103: 103: 103: 103: 103:             if (tokenCount >= 5 && tokenCount <= 9) {
104: 104: 104: 104: 104:                 betAmountGNC = betAmountGNC *  115 / 100;
105: 105: 105: 105: 105:             }
106: 106: 106: 106: 106:             if (tokenCount >= 10 && tokenCount <= 20) {
107: 107: 107: 107: 107:                 betAmountGNC = betAmountGNC *  135 / 100;
108: 108: 108: 108: 108:             }
109: 109: 109: 109: 109:             if (tokenCount >= 21 && tokenCount <= 41) {
110: 110: 110: 110: 110:                 betAmountGNC = betAmountGNC *  170 / 100;
111: 111: 111: 111: 111:             }
112: 112: 112: 112: 112:             if (tokenCount >= 42) {
113: 113: 113: 113: 113:                 betAmountGNC = betAmountGNC *  200 / 100;
114: 114: 114: 114: 114:             }
115: 115: 115: 115: 115:         }
116: 116: 116: 116: 116:         return betAmountGNC;
117: 117: 117: 117: 117:     }
118: 118: 118: 118: 118: 
119: 119: 119: 119: 119:     function putMessage(string message) public {
120: 120: 120: 120: 120:         if (msg.sender == publisher) {
121: 121: 121: 121: 121:             publisherMessage = message;
122: 122: 122: 122: 122:         }
123: 123: 123: 123: 123:     }
124: 124: 124: 124: 124: 
125: 125: 125: 125: 125:     function togglePause(bool paused) public {
126: 126: 126: 126: 126:         if (msg.sender == publisher) {
127: 127: 127: 127: 127:             isPaused = paused;
128: 128: 128: 128: 128:         }
129: 129: 129: 129: 129:     }
130: 130: 130: 130: 130: 
131: 131: 131: 131: 131:     function getBetAmountETH(uint256 tokenCount) private returns (uint256) {
132: 132: 132: 132: 132:         uint256 betAmount = msg.value;
133: 133: 133: 133: 133:         if (tokenCount == 0) {
134: 134: 134: 134: 134:             uint256 comission = betAmount * 38 / 1000;
135: 135: 135: 135: 135:             betAmount -= comission;
136: 136: 136: 136: 136:             balance[feeCollector] += comission;
137: 137: 137: 137: 137:         }
138: 138: 138: 138: 138:         return betAmount;
139: 139: 139: 139: 139:     }
140: 140: 140: 140: 140: 
141: 141: 141: 141: 141:     function betBlueCoin(uint256 actionBlock) public payable {
142: 142: 142: 142: 142:         require (!isPaused || marketCapBlue > 0 || actionBlock == lastActionBlock);
143: 143: 143: 143: 143: 
144: 144: 144: 144: 144:         uint256 tokenCount = discountToken.balanceOf(msg.sender);
145: 145: 145: 145: 145:         uint256 betAmountETH = getBetAmountETH(tokenCount);
146: 146: 146: 146: 146:         uint256 betAmountGNC = getBetAmountGNC(marketCapBlue, tokenCount, betAmountETH);
147: 147: 147: 147: 147: 
148: 148: 148: 148: 148:         jackpotBlue += betAmountETH;
149: 149: 149: 149: 149:         marketCapBlue += betAmountGNC;
150: 150: 150: 150: 150:         bettorsBlue.push(Bettor({account:msg.sender, amount:betAmountGNC, amountEth:betAmountETH}));
151: 151: 151: 151: 151:         endBetBlue = bettorsBlue.length;
152: 152: 152: 152: 152:         lastActionBlock = block.number;
153: 153: 153: 153: 153: 
154: 154: 154: 154: 154:         checkMoon();
155: 155: 155: 155: 155:     }
156: 156: 156: 156: 156: 
157: 157: 157: 157: 157:     function betRedCoin(uint256 actionBlock) public payable {
158: 158: 158: 158: 158:         require (!isPaused || marketCapRed > 0 || actionBlock == lastActionBlock);
159: 159: 159: 159: 159: 
160: 160: 160: 160: 160:         uint256 tokenCount = discountToken.balanceOf(msg.sender);
161: 161: 161: 161: 161:         uint256 betAmountETH = getBetAmountETH(tokenCount);
162: 162: 162: 162: 162:         uint256 betAmountGNC = getBetAmountGNC(marketCapBlue, tokenCount, betAmountETH);
163: 163: 163: 163: 163: 
164: 164: 164: 164: 164:         jackpotRed += betAmountETH;
165: 165: 165: 165: 165:         marketCapRed += betAmountGNC;
166: 166: 166: 166: 166:         bettorsRed.push(Bettor({account:msg.sender, amount:betAmountGNC, amountEth: betAmountETH}));
167: 167: 167: 167: 167:         endBetRed = bettorsRed.length;
168: 168: 168: 168: 168:         lastActionBlock = block.number;
169: 169: 169: 169: 169: 
170: 170: 170: 170: 170:         checkMoon();
171: 171: 171: 171: 171:     }
172: 172: 172: 172: 172: 
173: 173: 173: 173: 173:     function withdraw() public {
174: 174: 174: 174: 174:         if (balance[feeCollector] != 0) {
175: 175: 175: 175: 175:             uint256 fee = balance[feeCollector];
176: 176: 176: 176: 176:             balance[feeCollector] = 0;
177: 177: 177: 177: 177:             feeCollector.call.value(fee)();
178: 178: 178: 178: 178:         }
179: 179: 179: 179: 179: 
180: 180: 180: 180: 180:         uint256 amount = balance[msg.sender];
181: 181: 181: 181: 181:         balance[msg.sender] = 0;
182: 182: 182: 182: 182:         msg.sender.transfer(amount);
183: 183: 183: 183: 183:     }
184: 184: 184: 184: 184: 
185: 185: 185: 185: 185:     function depositBalance(uint256 winner) private {
186: 186: 186: 186: 186:         uint256 i;
187: 187: 187: 187: 187:         if (winner == 0) {
188: 188: 188: 188: 188:             for (i = startBetBlue; i < bettorsBlue.length; i++) {
189: 189: 189: 189: 189:                 balance[bettorsBlue[i].account] += bettorsBlue[i].amountEth;
190: 190: 190: 190: 190:                 balance[bettorsBlue[i].account] += 10**18 * bettorsBlue[i].amount / marketCapBlue * jackpotRed / 10**18;
191: 191: 191: 191: 191:             }
192: 192: 192: 192: 192:         }
193: 193: 193: 193: 193:         else {
194: 194: 194: 194: 194:             for (i = startBetRed; i < bettorsRed.length; i++) {
195: 195: 195: 195: 195:                 balance[bettorsRed[i].account] += bettorsRed[i].amountEth;
196: 196: 196: 196: 196:                 balance[bettorsRed[i].account] += 10**18 * bettorsRed[i].amount / marketCapRed * jackpotBlue / 10**18;
197: 197: 197: 197: 197:             }
198: 198: 198: 198: 198:         }
199: 199: 199: 199: 199:     }
200: 200: 200: 200: 200: 
201: 201: 201: 201: 201:     function addEvent(uint256 winner) private {
202: 202: 202: 202: 202:         history.push(Event({winner: winner, newMoonLevel: moonLevel, block: block.number, blueCap: marketCapBlue, redCap: marketCapRed}));
203: 203: 203: 203: 203:         lastEventId = history.length - 1;
204: 204: 204: 204: 204:         lastLevelChangeBlock = block.number;
205: 205: 205: 205: 205:     }
206: 206: 206: 206: 206: 
207: 207: 207: 207: 207:     function burstBubble() private {
208: 208: 208: 208: 208:         uint256 winner;
209: 209: 209: 209: 209:         if (marketCapBlue == marketCapRed) {
210: 210: 210: 210: 210:             winner = block.number % 2;
211: 211: 211: 211: 211:         }
212: 212: 212: 212: 212:         else if (marketCapBlue > marketCapRed) {
213: 213: 213: 213: 213:             winner = 0;
214: 214: 214: 214: 214:         }
215: 215: 215: 215: 215:         else {
216: 216: 216: 216: 216:             winner = 1;
217: 217: 217: 217: 217:         }
218: 218: 218: 218: 218:         depositBalance(winner);
219: 219: 219: 219: 219:         moonLevel = moonLevel * 2;
220: 220: 220: 220: 220:         addEvent(winner);
221: 221: 221: 221: 221: 
222: 222: 222: 222: 222:         marketCapBlue = 0;
223: 223: 223: 223: 223:         marketCapRed = 0;
224: 224: 224: 224: 224: 
225: 225: 225: 225: 225:         jackpotBlue = 0;
226: 226: 226: 226: 226:         jackpotRed = 0;
227: 227: 227: 227: 227:         
228: 228: 228: 228: 228:         startBetBlue = bettorsBlue.length;
229: 229: 229: 229: 229:         startBetRed = bettorsRed.length;
230: 230: 230: 230: 230:     }
231: 231: 231: 231: 231: 
232: 232: 232: 232: 232:     function checkMoon() private {
233: 233: 233: 233: 233:         if (block.number - lastLevelChangeBlock > 2880) {
234: 234: 234: 234: 234:            moonLevel = moonLevel / 2;
235: 235: 235: 235: 235:            addEvent(2);
236: 236: 236: 236: 236:         }
237: 237: 237: 237: 237:         if (marketCapBlue >= moonLevel || marketCapRed >= moonLevel) {
238: 238: 238: 238: 238:             burstBubble();
239: 239: 239: 239: 239:         }
240: 240: 240: 240: 240:     }
241: 241: 241: 241: 241: }