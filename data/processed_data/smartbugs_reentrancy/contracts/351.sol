1: pragma solidity ^0.4.13;
2: 
3: contract ATN is DSToken("ATN"), ERC223, Controlled {
4: 
5:     function ATN() {
6:         setName("AT Network Token");
7:     }
8: 
9:     
10:     
11:     
12:     
13:     
14:     
15:     function transferFrom(address _from, address _to, uint256 _amount
16:     ) public returns (bool success) {
17:         
18:         if (isContract(controller)) {
19:             if (!TokenController(controller).onTransfer(_from, _to, _amount))
20:                throw;
21:         }
22: 
23:         success = super.transferFrom(_from, _to, _amount);
24: 
25:         if (success && isContract(_to))
26:         {
27:             
28:             if(!_to.call(bytes4(keccak256("tokenFallback(address,uint256)")), _from, _amount)) {
29:                 
30:                 
31:                 
32: 
33:                 ReceivingContractTokenFallbackFailed(_from, _to, _amount);
34: 
35:                 
36:             }
37:         }
38:     }
39: 
40:     
41: 
42: 
43: 
44:     function transferFrom(address _from, address _to, uint256 _amount, bytes _data)
45:         public
46:         returns (bool success)
47:     {
48:         
49:         if (isContract(controller)) {
50:             if (!TokenController(controller).onTransfer(_from, _to, _amount))
51:                throw;
52:         }
53: 
54:         require(super.transferFrom(_from, _to, _amount));
55: 
56:         if (isContract(_to)) {
57:             ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
58:             receiver.tokenFallback(_from, _amount, _data);
59:         }
60: 
61:         ERC223Transfer(_from, _to, _amount, _data);
62: 
63:         return true;
64:     }
65: 
66:     
67: 
68: 
69: 
70: 
71: 
72:     
73:     
74:     
75:     
76:     
77:     
78:     
79:     function transfer(
80:         address _to,
81:         uint256 _amount,
82:         bytes _data)
83:         public
84:         returns (bool success)
85:     {
86:         return transferFrom(msg.sender, _to, _amount, _data);
87:     }
88: 
89:     
90: 
91: 
92: 
93:     function transferFrom(address _from, address _to, uint256 _amount, bytes _data, string _custom_fallback)
94:         public
95:         returns (bool success)
96:     {
97:         
98:         if (isContract(controller)) {
99:             if (!TokenController(controller).onTransfer(_from, _to, _amount))
100:                throw;
101:         }
102: 
103:         require(super.transferFrom(_from, _to, _amount));
104: 
105:         if (isContract(_to)) {
106:             ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
107:             receiver.call.value(0)(bytes4(keccak256(_custom_fallback)), _from, _amount, _data);
108:         }
109: 
110:         ERC223Transfer(_from, _to, _amount, _data);
111: 
112:         return true;
113:     }
114: 
115:     
116: 
117: 
118: 
119:     function transfer(
120:         address _to, 
121:         uint _amount, 
122:         bytes _data, 
123:         string _custom_fallback)
124:         public 
125:         returns (bool success)
126:     {
127:         return transferFrom(msg.sender, _to, _amount, _data, _custom_fallback);
128:     }
129: 
130:     
131:     
132:     
133:     
134:     
135:     
136:     function approve(address _spender, uint256 _amount) returns (bool success) {
137:         
138:         if (isContract(controller)) {
139:             if (!TokenController(controller).onApprove(msg.sender, _spender, _amount))
140:                 throw;
141:         }
142:         
143:         return super.approve(_spender, _amount);
144:     }
145: 
146:     function mint(address _guy, uint _wad) auth stoppable {
147:         super.mint(_guy, _wad);
148: 
149:         Transfer(0, _guy, _wad);
150:     }
151:     function burn(address _guy, uint _wad) auth stoppable {
152:         super.burn(_guy, _wad);
153: 
154:         Transfer(_guy, 0, _wad);
155:     }
156: 
157:     
158:     
159:     
160:     
161:     
162:     
163:     
164:     function approveAndCall(address _spender, uint256 _amount, bytes _extraData
165:     ) returns (bool success) {
166:         if (!approve(_spender, _amount)) throw;
167: 
168:         ApproveAndCallFallBack(_spender).receiveApproval(
169:             msg.sender,
170:             _amount,
171:             this,
172:             _extraData
173:         );
174: 
175:         return true;
176:     }
177: 
178:     
179:     
180:     
181:     function isContract(address _addr) constant internal returns(bool) {
182:         uint size;
183:         if (_addr == 0) return false;
184:         assembly {
185:             size := extcodesize(_addr)
186:         }
187:         return size>0;
188:     }
189: 
190:     
191:     
192:     
193:     function ()  payable {
194:         if (isContract(controller)) {
195:             if (! TokenController(controller).proxyPayment.value(msg.value)(msg.sender))
196:                 throw;
197:         } else {
198:             throw;
199:         }
200:     }
201: 
202: 
203: 
204: 
205: 
206:     
207:     
208:     
209:     
210:     function claimTokens(address _token) onlyController {
211:         if (_token == 0x0) {
212:             controller.transfer(this.balance);
213:             return;
214:         }
215: 
216:         ERC20 token = ERC20(_token);
217:         uint balance = token.balanceOf(this);
218:         token.transfer(controller, balance);
219:         ClaimedTokens(_token, controller, balance);
220:     }
221: 
222: 
223: 
224: 
225: 
226:     event ClaimedTokens(address indexed _token, address indexed _controller, uint _amount);
227: }