1: pragma solidity ^0.4.13;
2: 
3: 
4: 
5: 
6: 
7: 
8: 
9: 
10: 
11: 
12: 
13: 
14: contract MonethaBuyer {
15:   
16:   mapping (address => uint256) public balances;
17:   
18:   uint256 public buy_bounty;
19:   
20:   uint256 public withdraw_bounty;
21:   
22:   bool public bought_tokens;
23:   
24:   uint256 public contract_eth_value;
25:   
26:   bool public kill_switch;
27:   
28:   
29:   bytes32 password_hash = 0x8223cba4d8b54dc1e03c41c059667f6adb1a642a0a07bef5a9d11c18c4f14612;
30:   
31:   uint256 public earliest_buy_time = 1504188000;
32:   
33:   uint256 public eth_cap = 30000 ether;
34:   
35:   address public developer = 0x000Fb8369677b3065dE5821a86Bc9551d5e5EAb9;
36:   
37:   address public sale;
38:   
39:   ERC20 public token;
40:   
41:   
42:   function set_addresses(address _sale, address _token) {
43:     
44:     require(msg.sender == developer);
45:     
46:     require(sale == 0x0);
47:     
48:     sale = _sale;
49:     token = ERC20(_token);
50:   }
51:   
52:   
53:   function activate_kill_switch(string password) {
54:     
55:     require(msg.sender == developer || sha3(password) == password_hash);
56:     
57:     uint256 claimed_bounty = buy_bounty;
58:     
59:     buy_bounty = 0;
60:     
61:     kill_switch = true;
62:     
63:     msg.sender.transfer(claimed_bounty);
64:   }
65:   
66:   
67:   function withdraw(address user){
68:     
69:     require(bought_tokens || now > earliest_buy_time + 1 hours);
70:     
71:     if (balances[user] == 0) return;
72:     
73:     if (!bought_tokens) {
74:       
75:       uint256 eth_to_withdraw = balances[user];
76:       
77:       balances[user] = 0;
78:       
79:       user.transfer(eth_to_withdraw);
80:     }
81:     
82:     else {
83:       
84:       uint256 contract_token_balance = token.balanceOf(address(this));
85:       
86:       require(contract_token_balance != 0);
87:       
88:       uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
89:       
90:       contract_eth_value -= balances[user];
91:       
92:       balances[user] = 0;
93:       
94:       uint256 fee = tokens_to_withdraw / 100;
95:       
96:       require(token.transfer(developer, fee));
97:       
98:       require(token.transfer(user, tokens_to_withdraw - fee));
99:     }
100:     
101:     uint256 claimed_bounty = withdraw_bounty / 100;
102:     
103:     withdraw_bounty -= claimed_bounty;
104:     
105:     msg.sender.transfer(claimed_bounty);
106:   }
107:   
108:   
109:   function add_to_buy_bounty() payable {
110:     
111:     require(msg.sender == developer);
112:     
113:     buy_bounty += msg.value;
114:   }
115:   
116:   
117:   function add_to_withdraw_bounty() payable {
118:     
119:     require(msg.sender == developer);
120:     
121:     withdraw_bounty += msg.value;
122:   }
123:   
124:   
125:   function claim_bounty(){
126:     
127:     if (bought_tokens) return;
128:     
129:     if (now < earliest_buy_time) return;
130:     
131:     if (kill_switch) return;
132:     
133:     require(sale != 0x0);
134:     
135:     bought_tokens = true;
136:     
137:     uint256 claimed_bounty = buy_bounty;
138:     
139:     buy_bounty = 0;
140:     
141:     contract_eth_value = this.balance - (claimed_bounty + withdraw_bounty);
142:     
143:     
144:     
145:     require(sale.call.value(contract_eth_value)());
146:     
147:     msg.sender.transfer(claimed_bounty);
148:   }
149:   
150:   
151:   function () payable {
152:     
153:     require(!kill_switch);
154:     
155:     require(!bought_tokens);
156:     
157:     require(this.balance < eth_cap);
158:     
159:     balances[msg.sender] += msg.value;
160:   }
161: }