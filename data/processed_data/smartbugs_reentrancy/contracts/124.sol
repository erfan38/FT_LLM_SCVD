1: 1: 1: 1: 1: pragma solidity ^0.4.24;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: 
5: 5: 5: 5: 5: 
6: 6: 6: 6: 6: 
7: 7: 7: 7: 7: library SafeMath {
8: 8: 8: 8: 8: 
9: 9: 9: 9: 9:   
10: 10: 10: 10: 10: 
11: 11: 11: 11: 11: 
12: 12: 12: 12: 12:   function mul(uint256 a, uint256 b) internal pure returns (uint256) {
13: 13: 13: 13: 13:     
14: 14: 14: 14: 14:     
15: 15: 15: 15: 15:     
16: 16: 16: 16: 16:     if (a == 0) {
17: 17: 17: 17: 17:       return 0;
18: 18: 18: 18: 18:     }
19: 19: 19: 19: 19: 
20: 20: 20: 20: 20:     uint256 c = a * b;
21: 21: 21: 21: 21:     require(c / a == b);
22: 22: 22: 22: 22: 
23: 23: 23: 23: 23:     return c;
24: 24: 24: 24: 24:   }
25: 25: 25: 25: 25: 
26: 26: 26: 26: 26:   
27: 27: 27: 27: 27: 
28: 28: 28: 28: 28: 
29: 29: 29: 29: 29:   function div(uint256 a, uint256 b) internal pure returns (uint256) {
30: 30: 30: 30: 30:     require(b > 0); 
31: 31: 31: 31: 31:     uint256 c = a / b;
32: 32: 32: 32: 32:     
33: 33: 33: 33: 33: 
34: 34: 34: 34: 34:     return c;
35: 35: 35: 35: 35:   }
36: 36: 36: 36: 36: 
37: 37: 37: 37: 37:   
38: 38: 38: 38: 38: 
39: 39: 39: 39: 39: 
40: 40: 40: 40: 40:   function sub(uint256 a, uint256 b) internal pure returns (uint256) {
41: 41: 41: 41: 41:     require(b <= a);
42: 42: 42: 42: 42:     uint256 c = a - b;
43: 43: 43: 43: 43: 
44: 44: 44: 44: 44:     return c;
45: 45: 45: 45: 45:   }
46: 46: 46: 46: 46: 
47: 47: 47: 47: 47:   
48: 48: 48: 48: 48: 
49: 49: 49: 49: 49: 
50: 50: 50: 50: 50:   function add(uint256 a, uint256 b) internal pure returns (uint256) {
51: 51: 51: 51: 51:     uint256 c = a + b;
52: 52: 52: 52: 52:     require(c >= a);
53: 53: 53: 53: 53: 
54: 54: 54: 54: 54:     return c;
55: 55: 55: 55: 55:   }
56: 56: 56: 56: 56: 
57: 57: 57: 57: 57:   
58: 58: 58: 58: 58: 
59: 59: 59: 59: 59: 
60: 60: 60: 60: 60: 
61: 61: 61: 61: 61:   function mod(uint256 a, uint256 b) internal pure returns (uint256) {
62: 62: 62: 62: 62:     require(b != 0);
63: 63: 63: 63: 63:     return a % b;
64: 64: 64: 64: 64:   }
65: 65: 65: 65: 65: }
66: 66: 66: 66: 66: 
67: 67: 67: 67: 67: 
68: 68: 68: 68: 68: 
69: 69: 69: 69: 69: 
70: 70: 70: 70: 70: 
71: 71: 71: 71: 71: 
72: 72: 72: 72: 72: 
73: 73: 73: 73: 73: contract DividendTokenERC667 is ERC667, Ownable
74: 74: 74: 74: 74: {
75: 75: 75: 75: 75:     using SafeMath for uint256;
76: 76: 76: 76: 76: 
77: 77: 77: 77: 77:     
78: 78: 78: 78: 78:     
79: 79: 79: 79: 79:     
80: 80: 80: 80: 80:     
81: 81: 81: 81: 81:     
82: 82: 82: 82: 82:     
83: 83: 83: 83: 83:     
84: 84: 84: 84: 84:     
85: 85: 85: 85: 85:     
86: 86: 86: 86: 86:     
87: 87: 87: 87: 87:     
88: 88: 88: 88: 88:     
89: 89: 89: 89: 89:     
90: 90: 90: 90: 90:     
91: 91: 91: 91: 91:     
92: 92: 92: 92: 92:     
93: 93: 93: 93: 93:     
94: 94: 94: 94: 94:     
95: 95: 95: 95: 95:     
96: 96: 96: 96: 96:     
97: 97: 97: 97: 97:     
98: 98: 98: 98: 98:     
99: 99: 99: 99: 99:     
100: 100: 100: 100: 100:     uint constant POINTS_PER_WEI = 1e32;
101: 101: 101: 101: 101:     uint public dividendsTotal;
102: 102: 102: 102: 102:     uint public dividendsCollected;
103: 103: 103: 103: 103:     uint public totalPointsPerToken;
104: 104: 104: 104: 104:     mapping (address => uint) public creditedPoints;
105: 105: 105: 105: 105:     mapping (address => uint) public lastPointsPerToken;
106: 106: 106: 106: 106: 
107: 107: 107: 107: 107:     
108: 108: 108: 108: 108:     event CollectedDividends(uint time, address indexed account, uint amount);
109: 109: 109: 109: 109:     event DividendReceived(uint time, address indexed sender, uint amount);
110: 110: 110: 110: 110: 
111: 111: 111: 111: 111:     constructor(uint256 _totalSupply, address _custom_owner)
112: 112: 112: 112: 112:     public
113: 113: 113: 113: 113:     ERC667("Noteshares Token", "NST")
114: 114: 114: 114: 114:     Ownable(_custom_owner)
115: 115: 115: 115: 115:     {
116: 116: 116: 116: 116:         totalSupply = _totalSupply;
117: 117: 117: 117: 117:     }
118: 118: 118: 118: 118: 
119: 119: 119: 119: 119:     
120: 120: 120: 120: 120:     function receivePayment()
121: 121: 121: 121: 121:     internal
122: 122: 122: 122: 122:     {
123: 123: 123: 123: 123:         if (msg.value == 0) return;
124: 124: 124: 124: 124:         
125: 125: 125: 125: 125:         
126: 126: 126: 126: 126:         totalPointsPerToken = totalPointsPerToken.add((msg.value.mul(POINTS_PER_WEI)).div(totalSupply));
127: 127: 127: 127: 127:         dividendsTotal = dividendsTotal.add(msg.value);
128: 128: 128: 128: 128:         emit DividendReceived(now, msg.sender, msg.value);
129: 129: 129: 129: 129:     }
130: 130: 130: 130: 130:     
131: 131: 131: 131: 131:     
132: 132: 132: 132: 132:     
133: 133: 133: 133: 133: 
134: 134: 134: 134: 134:     
135: 135: 135: 135: 135:     
136: 136: 136: 136: 136:     function transfer(address _to, uint _value)
137: 137: 137: 137: 137:     public
138: 138: 138: 138: 138:     returns (bool success)
139: 139: 139: 139: 139:     {
140: 140: 140: 140: 140:         
141: 141: 141: 141: 141:         _updateCreditedPoints(msg.sender);
142: 142: 142: 142: 142:         _updateCreditedPoints(_to);
143: 143: 143: 143: 143:         return ERC20.transfer(_to, _value);
144: 144: 144: 144: 144:     }
145: 145: 145: 145: 145: 
146: 146: 146: 146: 146:     
147: 147: 147: 147: 147:     
148: 148: 148: 148: 148:     function transferFrom(address _from, address _to, uint256 _value)
149: 149: 149: 149: 149:     public
150: 150: 150: 150: 150:     returns (bool success)
151: 151: 151: 151: 151:     {
152: 152: 152: 152: 152:         _updateCreditedPoints(_from);
153: 153: 153: 153: 153:         _updateCreditedPoints(_to);
154: 154: 154: 154: 154:         return ERC20.transferFrom(_from, _to, _value);
155: 155: 155: 155: 155:     }
156: 156: 156: 156: 156: 
157: 157: 157: 157: 157:     
158: 158: 158: 158: 158:     
159: 159: 159: 159: 159:     function transferAndCall(address _to, uint _value, bytes _data)
160: 160: 160: 160: 160:     public
161: 161: 161: 161: 161:     returns (bool success)
162: 162: 162: 162: 162:     {
163: 163: 163: 163: 163:         _updateCreditedPoints(msg.sender);
164: 164: 164: 164: 164:         _updateCreditedPoints(_to);
165: 165: 165: 165: 165:         return ERC667.transferAndCall(_to, _value, _data);
166: 166: 166: 166: 166:     }
167: 167: 167: 167: 167: 
168: 168: 168: 168: 168:     
169: 169: 169: 169: 169:     function collectOwedDividends()
170: 170: 170: 170: 170:     internal
171: 171: 171: 171: 171:     returns (uint _amount)
172: 172: 172: 172: 172:     {
173: 173: 173: 173: 173:         
174: 174: 174: 174: 174:         _updateCreditedPoints(msg.sender);
175: 175: 175: 175: 175:         _amount = creditedPoints[msg.sender].div(POINTS_PER_WEI);
176: 176: 176: 176: 176:         creditedPoints[msg.sender] = 0;
177: 177: 177: 177: 177:         dividendsCollected = dividendsCollected.add(_amount);
178: 178: 178: 178: 178:         emit CollectedDividends(now, msg.sender, _amount);
179: 179: 179: 179: 179:         require(msg.sender.call.value(_amount)());
180: 180: 180: 180: 180:     }
181: 181: 181: 181: 181: 
182: 182: 182: 182: 182: 
183: 183: 183: 183: 183:     
184: 184: 184: 184: 184:     
185: 185: 185: 185: 185:     
186: 186: 186: 186: 186:     
187: 187: 187: 187: 187:     
188: 188: 188: 188: 188:     
189: 189: 189: 189: 189:     function _updateCreditedPoints(address _account)
190: 190: 190: 190: 190:     private
191: 191: 191: 191: 191:     {
192: 192: 192: 192: 192:         creditedPoints[_account] = creditedPoints[_account].add(_getUncreditedPoints(_account));
193: 193: 193: 193: 193:         lastPointsPerToken[_account] = totalPointsPerToken;
194: 194: 194: 194: 194:     }
195: 195: 195: 195: 195: 
196: 196: 196: 196: 196:     
197: 197: 197: 197: 197:     function _getUncreditedPoints(address _account)
198: 198: 198: 198: 198:     private
199: 199: 199: 199: 199:     view
200: 200: 200: 200: 200:     returns (uint _amount)
201: 201: 201: 201: 201:     {
202: 202: 202: 202: 202:         uint _pointsPerToken = totalPointsPerToken.sub(lastPointsPerToken[_account]);
203: 203: 203: 203: 203:         
204: 204: 204: 204: 204:         
205: 205: 205: 205: 205:         
206: 206: 206: 206: 206:         
207: 207: 207: 207: 207:         return _pointsPerToken.mul(balanceOf[_account]);
208: 208: 208: 208: 208:     }
209: 209: 209: 209: 209: 
210: 210: 210: 210: 210: 
211: 211: 211: 211: 211:     
212: 212: 212: 212: 212:     
213: 213: 213: 213: 213:     
214: 214: 214: 214: 214:     
215: 215: 215: 215: 215:     function getOwedDividends(address _account)
216: 216: 216: 216: 216:     public
217: 217: 217: 217: 217:     constant
218: 218: 218: 218: 218:     returns (uint _amount)
219: 219: 219: 219: 219:     {
220: 220: 220: 220: 220:         return (_getUncreditedPoints(_account).add(creditedPoints[_account])).div(POINTS_PER_WEI);
221: 221: 221: 221: 221:     }
222: 222: 222: 222: 222: }
223: 223: 223: 223: 223: 