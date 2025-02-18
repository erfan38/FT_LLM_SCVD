1: 1: pragma solidity ^0.4.13;
2: 2: 
3: 3: contract ATN is DSToken("ATN"), ERC223, Controlled {
4: 4: 
5: 5:     function ATN() {
6: 6:         setName("AT Network Token");
7: 7:     }
8: 8: 
9: 9:     
10: 10:     
11: 11:     
12: 12:     
13: 13:     
14: 14:     
15: 15:     function transferFrom(address _from, address _to, uint256 _amount
16: 16:     ) public returns (bool success) {
17: 17:         
18: 18:         if (isContract(controller)) {
19: 19:             if (!TokenController(controller).onTransfer(_from, _to, _amount))
20: 20:                throw;
21: 21:         }
22: 22: 
23: 23:         success = super.transferFrom(_from, _to, _amount);
24: 24: 
25: 25:         if (success && isContract(_to))
26: 26:         {
27: 27:             
28: 28:             if(!_to.call(bytes4(keccak256("tokenFallback(address,uint256)")), _from, _amount)) {
29: 29:                 
30: 30:                 
31: 31:                 
32: 32: 
33: 33:                 ReceivingContractTokenFallbackFailed(_from, _to, _amount);
34: 34: 
35: 35:                 
36: 36:             }
37: 37:         }
38: 38:     }
39: 39: 
40: 40:     
41: 41: 
42: 42: 
43: 43: 
44: 44:     function transferFrom(address _from, address _to, uint256 _amount, bytes _data)
45: 45:         public
46: 46:         returns (bool success)
47: 47:     {
48: 48:         
49: 49:         if (isContract(controller)) {
50: 50:             if (!TokenController(controller).onTransfer(_from, _to, _amount))
51: 51:                throw;
52: 52:         }
53: 53: 
54: 54:         require(super.transferFrom(_from, _to, _amount));
55: 55: 
56: 56:         if (isContract(_to)) {
57: 57:             ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
58: 58:             receiver.tokenFallback(_from, _amount, _data);
59: 59:         }
60: 60: 
61: 61:         ERC223Transfer(_from, _to, _amount, _data);
62: 62: 
63: 63:         return true;
64: 64:     }
65: 65: 
66: 66:     
67: 67: 
68: 68: 
69: 69: 
70: 70: 
71: 71: 
72: 72:     
73: 73:     
74: 74:     
75: 75:     
76: 76:     
77: 77:     
78: 78:     
79: 79:     function transfer(
80: 80:         address _to,
81: 81:         uint256 _amount,
82: 82:         bytes _data)
83: 83:         public
84: 84:         returns (bool success)
85: 85:     {
86: 86:         return transferFrom(msg.sender, _to, _amount, _data);
87: 87:     }
88: 88: 
89: 89:     
90: 90: 
91: 91: 
92: 92: 
93: 93:     function transferFrom(address _from, address _to, uint256 _amount, bytes _data, string _custom_fallback)
94: 94:         public
95: 95:         returns (bool success)
96: 96:     {
97: 97:         
98: 98:         if (isContract(controller)) {
99: 99:             if (!TokenController(controller).onTransfer(_from, _to, _amount))
100: 100:                throw;
101: 101:         }
102: 102: 
103: 103:         require(super.transferFrom(_from, _to, _amount));
104: 104: 
105: 105:         if (isContract(_to)) {
106: 106:             ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
107: 107:             receiver.call.value(0)(bytes4(keccak256(_custom_fallback)), _from, _amount, _data);
108: 108:         }
109: 109: 
110: 110:         ERC223Transfer(_from, _to, _amount, _data);
111: 111: 
112: 112:         return true;
113: 113:     }
114: 114: 
115: 115:     
116: 116: 
117: 117: 
118: 118: 
119: 119:     function transfer(
120: 120:         address _to, 
121: 121:         uint _amount, 
122: 122:         bytes _data, 
123: 123:         string _custom_fallback)
124: 124:         public 
125: 125:         returns (bool success)
126: 126:     {
127: 127:         return transferFrom(msg.sender, _to, _amount, _data, _custom_fallback);
128: 128:     }
129: 129: 
130: 130:     
131: 131:     
132: 132:     
133: 133:     
134: 134:     
135: 135:     
136: 136:     function approve(address _spender, uint256 _amount) returns (bool success) {
137: 137:         
138: 138:         if (isContract(controller)) {
139: 139:             if (!TokenController(controller).onApprove(msg.sender, _spender, _amount))
140: 140:                 throw;
141: 141:         }
142: 142:         
143: 143:         return super.approve(_spender, _amount);
144: 144:     }
145: 145: 
146: 146:     function mint(address _guy, uint _wad) auth stoppable {
147: 147:         super.mint(_guy, _wad);
148: 148: 
149: 149:         Transfer(0, _guy, _wad);
150: 150:     }
151: 151:     function burn(address _guy, uint _wad) auth stoppable {
152: 152:         super.burn(_guy, _wad);
153: 153: 
154: 154:         Transfer(_guy, 0, _wad);
155: 155:     }
156: 156: 
157: 157:     
158: 158:     
159: 159:     
160: 160:     
161: 161:     
162: 162:     
163: 163:     
164: 164:     function approveAndCall(address _spender, uint256 _amount, bytes _extraData
165: 165:     ) returns (bool success) {
166: 166:         if (!approve(_spender, _amount)) throw;
167: 167: 
168: 168:         ApproveAndCallFallBack(_spender).receiveApproval(
169: 169:             msg.sender,
170: 170:             _amount,
171: 171:             this,
172: 172:             _extraData
173: 173:         );
174: 174: 
175: 175:         return true;
176: 176:     }
177: 177: 
178: 178:     
179: 179:     
180: 180:     
181: 181:     function isContract(address _addr) constant internal returns(bool) {
182: 182:         uint size;
183: 183:         if (_addr == 0) return false;
184: 184:         assembly {
185: 185:             size := extcodesize(_addr)
186: 186:         }
187: 187:         return size>0;
188: 188:     }
189: 189: 
190: 190:     
191: 191:     
192: 192:     
193: 193:     function ()  payable {
194: 194:         if (isContract(controller)) {
195: 195:             if (! TokenController(controller).proxyPayment.value(msg.value)(msg.sender))
196: 196:                 throw;
197: 197:         } else {
198: 198:             throw;
199: 199:         }
200: 200:     }
201: 201: 
202: 202: 
203: 203: 
204: 204: 
205: 205: 
206: 206:     
207: 207:     
208: 208:     
209: 209:     
210: 210:     function claimTokens(address _token) onlyController {
211: 211:         if (_token == 0x0) {
212: 212:             controller.transfer(this.balance);
213: 213:             return;
214: 214:         }
215: 215: 
216: 216:         ERC20 token = ERC20(_token);
217: 217:         uint balance = token.balanceOf(this);
218: 218:         token.transfer(controller, balance);
219: 219:         ClaimedTokens(_token, controller, balance);
220: 220:     }
221: 221: 
222: 222: 
223: 223: 
224: 224: 
225: 225: 
226: 226:     event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
227: 227: }