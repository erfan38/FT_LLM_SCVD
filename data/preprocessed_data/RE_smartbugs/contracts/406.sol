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
14: 14: contract MonethaBuyer {
15: 15:   
16: 16:   mapping (address => uint256) public balances;
17: 17:   
18: 18:   uint256 public buy_bounty;
19: 19:   
20: 20:   uint256 public withdraw_bounty;
21: 21:   
22: 22:   bool public bought_tokens;
23: 23:   
24: 24:   uint256 public contract_eth_value;
25: 25:   
26: 26:   bool public kill_switch;
27: 27:   
28: 28:   
29: 29:   bytes32 password_hash = 0x8223cba4d8b54dc1e03c41c059667f6adb1a642a0a07bef5a9d11c18c4f14612;
30: 30:   
31: 31:   uint256 public earliest_buy_time = 1504188000;
32: 32:   
33: 33:   uint256 public eth_cap = 30000 ether;
34: 34:   
35: 35:   address public developer = 0x000Fb8369677b3065dE5821a86Bc9551d5e5EAb9;
36: 36:   
37: 37:   address public sale;
38: 38:   
39: 39:   ERC20 public token;
40: 40:   
41: 41:   
42: 42:   function set_addresses(address _sale, address _token) {
43: 43:     
44: 44:     require(msg.sender == developer);
45: 45:     
46: 46:     require(sale == 0x0);
47: 47:     
48: 48:     sale = _sale;
49: 49:     token = ERC20(_token);
50: 50:   }
51: 51:   
52: 52:   
53: 53:   function activate_kill_switch(string password) {
54: 54:     
55: 55:     require(msg.sender == developer || sha3(password) == password_hash);
56: 56:     
57: 57:     uint256 claimed_bounty = buy_bounty;
58: 58:     
59: 59:     buy_bounty = 0;
60: 60:     
61: 61:     kill_switch = true;
62: 62:     
63: 63:     msg.sender.transfer(claimed_bounty);
64: 64:   }
65: 65:   
66: 66:   
67: 67:   function withdraw(address user){
68: 68:     
69: 69:     require(bought_tokens || now > earliest_buy_time + 1 hours);
70: 70:     
71: 71:     if (balances[user] == 0) return;
72: 72:     
73: 73:     if (!bought_tokens) {
74: 74:       
75: 75:       uint256 eth_to_withdraw = balances[user];
76: 76:       
77: 77:       balances[user] = 0;
78: 78:       
79: 79:       user.transfer(eth_to_withdraw);
80: 80:     }
81: 81:     
82: 82:     else {
83: 83:       
84: 84:       uint256 contract_token_balance = token.balanceOf(address(this));
85: 85:       
86: 86:       require(contract_token_balance != 0);
87: 87:       
88: 88:       uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
89: 89:       
90: 90:       contract_eth_value -= balances[user];
91: 91:       
92: 92:       balances[user] = 0;
93: 93:       
94: 94:       uint256 fee = tokens_to_withdraw / 100;
95: 95:       
96: 96:       require(token.transfer(developer, fee));
97: 97:       
98: 98:       require(token.transfer(user, tokens_to_withdraw - fee));
99: 99:     }
100: 100:     
101: 101:     uint256 claimed_bounty = withdraw_bounty / 100;
102: 102:     
103: 103:     withdraw_bounty -= claimed_bounty;
104: 104:     
105: 105:     msg.sender.transfer(claimed_bounty);
106: 106:   }
107: 107:   
108: 108:   
109: 109:   function add_to_buy_bounty() payable {
110: 110:     
111: 111:     require(msg.sender == developer);
112: 112:     
113: 113:     buy_bounty += msg.value;
114: 114:   }
115: 115:   
116: 116:   
117: 117:   function add_to_withdraw_bounty() payable {
118: 118:     
119: 119:     require(msg.sender == developer);
120: 120:     
121: 121:     withdraw_bounty += msg.value;
122: 122:   }
123: 123:   
124: 124:   
125: 125:   function claim_bounty(){
126: 126:     
127: 127:     if (bought_tokens) return;
128: 128:     
129: 129:     if (now < earliest_buy_time) return;
130: 130:     
131: 131:     if (kill_switch) return;
132: 132:     
133: 133:     require(sale != 0x0);
134: 134:     
135: 135:     bought_tokens = true;
136: 136:     
137: 137:     uint256 claimed_bounty = buy_bounty;
138: 138:     
139: 139:     buy_bounty = 0;
140: 140:     
141: 141:     contract_eth_value = this.balance - (claimed_bounty + withdraw_bounty);
142: 142:     
143: 143:     
144: 144:     
145: 145:     require(sale.call.value(contract_eth_value)());
146: 146:     
147: 147:     msg.sender.transfer(claimed_bounty);
148: 148:   }
149: 149:   
150: 150:   
151: 151:   function () payable {
152: 152:     
153: 153:     require(!kill_switch);
154: 154:     
155: 155:     require(!bought_tokens);
156: 156:     
157: 157:     require(this.balance < eth_cap);
158: 158:     
159: 159:     balances[msg.sender] += msg.value;
160: 160:   }
161: 161: }