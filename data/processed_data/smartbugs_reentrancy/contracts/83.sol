1: 1: pragma solidity ^0.4.13;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: contract EnjinBuyer {
8: 8:   mapping (address => uint256) public balances;
9: 9:   mapping (address => uint256) public balances_after_buy;
10: 10:   bool public bought_tokens;
11: 11:   bool public token_set;
12: 12:   bool public refunded;
13: 13:   uint256 public contract_eth_value;
14: 14:   bool public kill_switch;
15: 15:   bytes32 password_hash = 0x8bf0720c6e610aace867eba51b03ab8ca908b665898b10faddc95a96e829539d;
16: 16:   address public developer = 0x0639C169D9265Ca4B4DEce693764CdA8ea5F3882;
17: 17:   address public sale = 0xc4740f71323129669424d1Ae06c42AEE99da30e2;
18: 18:   ERC20 public token;
19: 19:   uint256 public eth_minimum = 3235 ether;
20: 20: 
21: 21:   function set_token(address _token) {
22: 22:     require(msg.sender == developer);
23: 23:     token = ERC20(_token);
24: 24:     token_set = true;
25: 25:   }
26: 26: 
27: 27:   
28: 28:   function set_refunded(bool _refunded) {
29: 29:     require(msg.sender == developer);
30: 30:     refunded = _refunded;
31: 31:   }
32: 32:   
33: 33:   function activate_kill_switch(string password) {
34: 34:     require(msg.sender == developer || sha3(password) == password_hash);
35: 35:     kill_switch = true;
36: 36:   }
37: 37:   
38: 38:   function personal_withdraw(){
39: 39:     if (balances_after_buy[msg.sender]>0 && msg.sender != sale) {
40: 40:         uint256 eth_to_withdraw_after_buy = balances_after_buy[msg.sender];
41: 41:         balances_after_buy[msg.sender] = 0;
42: 42:         msg.sender.transfer(eth_to_withdraw_after_buy);
43: 43:     }
44: 44:     if (balances[msg.sender] == 0) return;
45: 45:     require(msg.sender != sale);
46: 46:     if (!bought_tokens || refunded) {
47: 47:       uint256 eth_to_withdraw = balances[msg.sender];
48: 48:       balances[msg.sender] = 0;
49: 49:       msg.sender.transfer(eth_to_withdraw);
50: 50:     }
51: 51:     else {
52: 52:       require(token_set);
53: 53:       uint256 contract_token_balance = token.balanceOf(address(this));
54: 54:       require(contract_token_balance != 0);
55: 55:       uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
56: 56:       contract_eth_value -= balances[msg.sender];
57: 57:       balances[msg.sender] = 0;
58: 58:       uint256 fee = tokens_to_withdraw / 100;
59: 59:       require(token.transfer(developer, fee));
60: 60:       require(token.transfer(msg.sender, tokens_to_withdraw - fee));
61: 61:     }
62: 62:   }
63: 63: 
64: 64:   function withdraw(address user){
65: 65:     require(bought_tokens || kill_switch);
66: 66:     
67: 67:     require(user != sale);
68: 68:     if (balances_after_buy[user]>0 && user != sale) {
69: 69:         uint256 eth_to_withdraw_after_buy = balances_after_buy[user];
70: 70:         balances_after_buy[user] = 0;
71: 71:         user.transfer(eth_to_withdraw_after_buy);
72: 72:     }
73: 73:     if (balances[user] == 0) return;
74: 74:     if (!bought_tokens || refunded) {
75: 75:       uint256 eth_to_withdraw = balances[user];
76: 76:       balances[user] = 0;
77: 77:       user.transfer(eth_to_withdraw);
78: 78:     }
79: 79:     else {
80: 80:       require(token_set);
81: 81:       uint256 contract_token_balance = token.balanceOf(address(this));
82: 82:       require(contract_token_balance != 0);
83: 83:       uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
84: 84:       contract_eth_value -= balances[user];
85: 85:       balances[user] = 0;
86: 86:       uint256 fee = tokens_to_withdraw / 100;
87: 87:       require(token.transfer(developer, fee));
88: 88:       require(token.transfer(user, tokens_to_withdraw - fee));
89: 89:     }
90: 90:   }
91: 91: 
92: 92:   function purchase_tokens() {
93: 93:     require(msg.sender == developer);
94: 94:     if (this.balance < eth_minimum) return;
95: 95:     if (kill_switch) return;
96: 96:     require(sale != 0x0);
97: 97:     bought_tokens = true;
98: 98:     contract_eth_value = this.balance;
99: 99:     require(sale.call.value(contract_eth_value)());
100: 100:     require(this.balance==0);
101: 101:   }
102: 102:   
103: 103:   function () payable {
104: 104:     if (!bought_tokens) {
105: 105:       balances[msg.sender] += msg.value;
106: 106:     } else {
107: 107:       
108: 108:       
109: 109:       
110: 110:       
111: 111:       
112: 112:       balances_after_buy[msg.sender] += msg.value;
113: 113:       if (msg.sender == sale && this.balance >= contract_eth_value) {
114: 114:         refunded = true;
115: 115:       }
116: 116:     }
117: 117:   }
118: 118: }