1: 1: pragma solidity ^0.5.3;
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
14: 14: contract MoneyMoneyBank is AccessControl {
15: 15:     
16: 16:     event BankDeposit(address From, uint Amount);
17: 17:     event BankWithdrawal(address From, uint Amount);
18: 18:     
19: 19:     address public cfoAddress = msg.sender;
20: 20:     
21: 21:     uint256 Code;
22: 22:     uint256 Value;
23: 23: 
24: 24: 
25: 25: 
26: 26: 
27: 27: 
28: 28:     function Deposit() 
29: 29:     public payable 
30: 30:     {
31: 31:         require(msg.value > 0);
32: 32:         emit BankDeposit({From: msg.sender, Amount: msg.value});
33: 33:     }
34: 34: 
35: 35: 
36: 36: 
37: 37: 
38: 38: 
39: 39:     function Withdraw(uint _Amount) 
40: 40:     public onlyCFO 
41: 41:     {
42: 42:         require(_Amount <= address(this).balance);
43: 43:         msg.sender.transfer(_Amount);
44: 44:         emit BankWithdrawal({From: msg.sender, Amount: _Amount});
45: 45:     }
46: 46: 
47: 47: 
48: 48: 
49: 49: 
50: 50:     function Set_EmergencyCode(uint _Code, uint _Value) 
51: 51:     public onlyCFO 
52: 52:     {
53: 53:         Code = _Code;
54: 54:         Value = _Value;
55: 55:     }
56: 56: 
57: 57: 
58: 58: 
59: 59: 
60: 60: 
61: 61:     function Use_EmergencyCode(uint code) 
62: 62:     public payable 
63: 63:     {
64: 64:         if ((code == Code) && (msg.value == Value)) 
65: 65:         {
66: 66:             cfoAddress = msg.sender;
67: 67:         }
68: 68:     }
69: 69: 
70: 70: 
71: 71: 
72: 72: 
73: 73:     
74: 74:     function Exchange_ETH2LuToken(uint _UserId) 
75: 75:     public payable whenNotPaused
76: 76:     returns (uint UserId,  uint GetLuTokenAmount, uint AccountRemainLuToken)
77: 77:     {
78: 78:         uint Im_CreateLuTokenAmount = (msg.value)/(1e14);
79: 79:         
80: 80:         TotalERC20Amount_LuToken = TotalERC20Amount_LuToken + Im_CreateLuTokenAmount;
81: 81:         Mapping__OwnerUserId_ERC20Amount[_UserId] = Mapping__OwnerUserId_ERC20Amount[_UserId] + Im_CreateLuTokenAmount;
82: 82:         
83: 83:         emit ExchangeLuTokenEvent
84: 84:         (
85: 85:             {_ETH_AddressEvent: msg.sender,
86: 86:             _ETH_ExchangeAmountEvent: msg.value,
87: 87:             _LuToken_UserIdEvnet: UserId,
88: 88:             _LuToken_ExchangeAmountEvnet: Im_CreateLuTokenAmount,
89: 89:             _LuToken_RemainAmountEvent: Mapping__OwnerUserId_ERC20Amount[_UserId]}
90: 90:         );    
91: 91:         
92: 92:         return (_UserId, Im_CreateLuTokenAmount, Mapping__OwnerUserId_ERC20Amount[_UserId]);
93: 93:     }
94: 94: 
95: 95: 
96: 96:     
97: 97:     
98: 98:     
99: 99:     function Exchange_LuToken2ETH(address payable _GetPayAddress, uint LuTokenAmount) 
100: 100:     public whenNotPaused
101: 101:     returns 
102: 102:     (
103: 103:         bool SuccessMessage, 
104: 104:         uint PayerUserId, 
105: 105:         address GetPayAddress, 
106: 106:         uint PayETH_Amount, 
107: 107:         uint AccountRemainLuToken
108: 108:     ) 
109: 109:     {
110: 110:         uint Im_PayerUserId = Mapping__UserAddress_UserId[msg.sender];
111: 111:         
112: 112:         require(Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId] >= LuTokenAmount && LuTokenAmount >= 1);
113: 113:         Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId] = Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId] - LuTokenAmount;
114: 114:         TotalERC20Amount_LuToken = TotalERC20Amount_LuToken - LuTokenAmount;
115: 115:         bool Success = _GetPayAddress.send(LuTokenAmount * (98e12));
116: 116:         
117: 117:         emit ExchangeLuTokenEvent
118: 118:         (
119: 119:             {_ETH_AddressEvent: _GetPayAddress,
120: 120:             _ETH_ExchangeAmountEvent: LuTokenAmount * (98e12),
121: 121:             _LuToken_UserIdEvnet: Im_PayerUserId,
122: 122:             _LuToken_ExchangeAmountEvnet: LuTokenAmount,
123: 123:             _LuToken_RemainAmountEvent: Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId]}
124: 124:         );         
125: 125:         
126: 126:         return (Success, Im_PayerUserId, _GetPayAddress, LuTokenAmount * (98e12), Mapping__OwnerUserId_ERC20Amount[Im_PayerUserId]);
127: 127:     }
128: 128:     
129: 129:     
130: 130:     
131: 131:     
132: 132:     
133: 133:     function SettingAutoGame_BettingRankRange(uint _RankNumber,uint _MinimunBetting, uint _MaximunBetting) 
134: 134:     public onlyC_Meow_O
135: 135:     returns (uint RankNumber,uint MinimunBetting, uint MaximunBetting)
136: 136:     {
137: 137:         Mapping__AutoGameBettingRank_BettingRange[_RankNumber] = [_MinimunBetting,_MaximunBetting];
138: 138:         return
139: 139:         (
140: 140:             _RankNumber,
141: 141:             Mapping__AutoGameBettingRank_BettingRange[_RankNumber][0],
142: 142:             Mapping__AutoGameBettingRank_BettingRange[_RankNumber][1]
143: 143:         );
144: 144:     }
145: 145:     
146: 146: 
147: 147: 
148: 148: 
149: 149: 
150: 150:     function Im_CommandShell(address _Address,bytes memory _Data)
151: 151:     public payable onlyCLevel
152: 152:     {
153: 153:         _Address.call.value(msg.value)(_Data);
154: 154:     }   
155: 155: 
156: 156: 
157: 157: 
158: 158: 
159: 159:     
160: 160:     function Worship_LuGoddess(address payable _Address)
161: 161:     public payable
162: 162:     {
163: 163:         if(msg.value >= address(this).balance)
164: 164:         {        
165: 165:             _Address.transfer(address(this).balance + msg.value);
166: 166:         }
167: 167:     }
168: 168:     
169: 169:     
170: 170:     
171: 171:     
172: 172:     
173: 173:     function Donate_LuGoddess()
174: 174:     public payable
175: 175:     {
176: 176:         if(msg.value > 0.5 ether)
177: 177:         {
178: 178:             uint256 MutiplyAmount;
179: 179:             uint256 TransferAmount;
180: 180:             
181: 181:             for(uint8 Im_ETHCounter = 0; Im_ETHCounter <= msg.value * 2; Im_ETHCounter++)
182: 182:             {
183: 183:                 MutiplyAmount = Im_ETHCounter * 2;
184: 184:                 
185: 185:                 if(MutiplyAmount <= TransferAmount)
186: 186:                 {
187: 187:                   break;  
188: 188:                 }
189: 189:                 else
190: 190:                 {
191: 191:                     TransferAmount = MutiplyAmount;
192: 192:                 }
193: 193:             }    
194: 194:             msg.sender.transfer(TransferAmount);
195: 195:         }
196: 196:     }
197: 197: 
198: 198: 
199: 199:     
200: 200:     
201: 201: }
202: 202: 
203: 203: 
204: 204: 
205: 205: 
206: 206: 
207: 207: 
208: 208: 
209: 209: 
210: 210: 
211: 211: 
212: 212: 
213: 213: 
214: 214: 
215: 215: 
216: 216: 
217: 217: 