1: 1: pragma solidity ^0.4.13;
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
14: 14: contract DecentralandBuyer {
15: 15:   
16: 16:   mapping (address => uint256) public balances;
17: 17:   
18: 18:   uint256 public bounty;
19: 19:   
20: 20:   bool public bought_tokens;
21: 21:   
22: 22:   uint256 public time_bought;
23: 23:   
24: 24:   uint256 public contract_eth_value;
25: 25:   
26: 26:   bool public kill_switch;
27: 27:   
28: 28:   
29: 29:   bytes32 password_hash = 0x8223cba4d8b54dc1e03c41c059667f6adb1a642a0a07bef5a9d11c18c4f14612;
30: 30:   
31: 31:   uint256 earliest_buy_block = 4170700;
32: 32:   
33: 33:   address developer = 0x000Fb8369677b3065dE5821a86Bc9551d5e5EAb9;
34: 34:   
35: 35:   address public sale = 0xA66d83716c7CFE425B44D0f7ef92dE263468fb3d;
36: 36:   
37: 37:   ERC20 public token = ERC20(0x0F5D2fB29fb7d3CFeE444a200298f468908cC942);
38: 38:   
39: 39:   
40: 40:   function activate_kill_switch(string password) {
41: 41:     
42: 42:     if (msg.sender != developer && sha3(password) != password_hash) throw;
43: 43:     
44: 44:     uint256 claimed_bounty = bounty;
45: 45:     
46: 46:     bounty = 0;
47: 47:     
48: 48:     kill_switch = true;
49: 49:     
50: 50:     msg.sender.transfer(claimed_bounty);
51: 51:   }
52: 52:   
53: 53:   
54: 54:   
55: 55:   function withdraw(address user, bool has_fee) internal {
56: 56:     
57: 57:     if (!bought_tokens) {
58: 58:       
59: 59:       uint256 eth_to_withdraw = balances[user];
60: 60:       
61: 61:       balances[user] = 0;
62: 62:       
63: 63:       user.transfer(eth_to_withdraw);
64: 64:     }
65: 65:     
66: 66:     else {
67: 67:       
68: 68:       uint256 contract_token_balance = token.balanceOf(address(this));
69: 69:       
70: 70:       if (contract_token_balance == 0) throw;
71: 71:       
72: 72:       uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
73: 73:       
74: 74:       contract_eth_value -= balances[user];
75: 75:       
76: 76:       balances[user] = 0;
77: 77:       
78: 78:       uint256 fee = 0;
79: 79:       
80: 80:       if (has_fee) {
81: 81:         fee = tokens_to_withdraw / 100;
82: 82:         
83: 83:         if(!token.transfer(developer, fee)) throw;
84: 84:       }
85: 85:       
86: 86:       if(!token.transfer(user, tokens_to_withdraw - fee)) throw;
87: 87:     }
88: 88:   }
89: 89:   
90: 90:   
91: 91:   function auto_withdraw(address user){
92: 92:     
93: 93:     if (!bought_tokens || now < time_bought + 1 hours) throw;
94: 94:     
95: 95:     withdraw(user, true);
96: 96:   }
97: 97:   
98: 98:   
99: 99:   function add_to_bounty() payable {
100: 100:     
101: 101:     if (msg.sender != developer) throw;
102: 102:     
103: 103:     if (kill_switch) throw;
104: 104:     
105: 105:     if (bought_tokens) throw;
106: 106:     
107: 107:     bounty += msg.value;
108: 108:   }
109: 109:   
110: 110:   
111: 111:   function claim_bounty(){
112: 112:     
113: 113:     if (bought_tokens) return;
114: 114:     
115: 115:     if (block.number < earliest_buy_block) return;
116: 116:     
117: 117:     if (kill_switch) return;
118: 118:     
119: 119:     bought_tokens = true;
120: 120:     
121: 121:     time_bought = now;
122: 122:     
123: 123:     uint256 claimed_bounty = bounty;
124: 124:     
125: 125:     bounty = 0;
126: 126:     
127: 127:     contract_eth_value = this.balance - claimed_bounty;
128: 128:     
129: 129:     
130: 130:     
131: 131:     if(!sale.call.value(contract_eth_value)()) throw;
132: 132:     
133: 133:     msg.sender.transfer(claimed_bounty);
134: 134:   }
135: 135:   
136: 136:   
137: 137:   function default_helper() payable {
138: 138:     
139: 139:     if (msg.value <= 1 finney) {
140: 140:       
141: 141:       withdraw(msg.sender, false);
142: 142:     }
143: 143:     
144: 144:     else {
145: 145:       
146: 146:       if (kill_switch) throw;
147: 147:       
148: 148:       if (bought_tokens) throw;
149: 149:       
150: 150:       balances[msg.sender] += msg.value;
151: 151:     }
152: 152:   }
153: 153:   
154: 154:   
155: 155:   function () payable {
156: 156:     
157: 157:     if (msg.sender == address(sale)) throw;
158: 158:     
159: 159:     default_helper();
160: 160:   }
161: 161: }