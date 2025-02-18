1: 1: 1: 1: 1: pragma solidity ^0.4.15;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: contract Equio {
5: 5: 5: 5: 5:   
6: 6: 6: 6: 6:   mapping (address => uint256) public balances;
7: 7: 7: 7: 7:   
8: 8: 8: 8: 8:   bool public bought_tokens;
9: 9: 9: 9: 9:   
10: 10: 10: 10: 10:   uint256 public time_bought;
11: 11: 11: 11: 11:   
12: 12: 12: 12: 12:   uint256 public contract_eth_value;
13: 13: 13: 13: 13:   
14: 14: 14: 14: 14:   bool public kill_switch;
15: 15: 15: 15: 15:   
16: 16: 16: 16: 16:   address public creator;
17: 17: 17: 17: 17:   
18: 18: 18: 18: 18:   string name;
19: 19: 19: 19: 19:   
20: 20: 20: 20: 20:   address public sale; 
21: 21: 21: 21: 21:   
22: 22: 22: 22: 22:   ERC20 public token; 
23: 23: 23: 23: 23:   
24: 24: 24: 24: 24:   bytes32 password_hash; 
25: 25: 25: 25: 25:   
26: 26: 26: 26: 26:   uint256 earliest_buy_block; 
27: 27: 27: 27: 27:   
28: 28: 28: 28: 28:   uint256 earliest_buy_time; 
29: 29: 29: 29: 29: 
30: 30: 30: 30: 30:   function Equio(
31: 31: 31: 31: 31:     string _name,
32: 32: 32: 32: 32:     address _sale,
33: 33: 33: 33: 33:     address _token,
34: 34: 34: 34: 34:     bytes32 _password_hash,
35: 35: 35: 35: 35:     uint256 _earliest_buy_block,
36: 36: 36: 36: 36:     uint256 _earliest_buy_time
37: 37: 37: 37: 37:   ) payable {
38: 38: 38: 38: 38:       creator = msg.sender;
39: 39: 39: 39: 39:       name = _name;
40: 40: 40: 40: 40:       sale = _sale;
41: 41: 41: 41: 41:       token = ERC20(_token);
42: 42: 42: 42: 42:       password_hash = _password_hash;
43: 43: 43: 43: 43:       earliest_buy_block = _earliest_buy_block;
44: 44: 44: 44: 44:       earliest_buy_time = _earliest_buy_time;
45: 45: 45: 45: 45:   }
46: 46: 46: 46: 46: 
47: 47: 47: 47: 47:   
48: 48: 48: 48: 48:   
49: 49: 49: 49: 49:   function withdraw(address user) internal {
50: 50: 50: 50: 50:     
51: 51: 51: 51: 51:     if (!bought_tokens) {
52: 52: 52: 52: 52:       
53: 53: 53: 53: 53:       uint256 eth_to_withdraw = balances[user];
54: 54: 54: 54: 54:       
55: 55: 55: 55: 55:       balances[user] = 0;
56: 56: 56: 56: 56:       
57: 57: 57: 57: 57:       user.transfer(eth_to_withdraw);
58: 58: 58: 58: 58:     } else { 
59: 59: 59: 59: 59:       
60: 60: 60: 60: 60:       uint256 contract_token_balance = token.balanceOf(address(this));
61: 61: 61: 61: 61:       
62: 62: 62: 62: 62:       require(contract_token_balance > 0);
63: 63: 63: 63: 63:       
64: 64: 64: 64: 64:       uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
65: 65: 65: 65: 65:       
66: 66: 66: 66: 66:       contract_eth_value -= balances[user];
67: 67: 67: 67: 67:       
68: 68: 68: 68: 68:       balances[user] = 0;
69: 69: 69: 69: 69:       
70: 70: 70: 70: 70:       
71: 71: 71: 71: 71:       require(token.transfer(user, tokens_to_withdraw));
72: 72: 72: 72: 72:     }
73: 73: 73: 73: 73:   }
74: 74: 74: 74: 74: 
75: 75: 75: 75: 75:   
76: 76: 76: 76: 76:   
77: 77: 77: 77: 77:   function auto_withdraw(address user){
78: 78: 78: 78: 78:     
79: 79: 79: 79: 79:     
80: 80: 80: 80: 80:     require (bought_tokens && now > time_bought + 1 hours);
81: 81: 81: 81: 81:     
82: 82: 82: 82: 82:     withdraw(user);
83: 83: 83: 83: 83:   }
84: 84: 84: 84: 84: 
85: 85: 85: 85: 85:   
86: 86: 86: 86: 86:   function buy_sale(){
87: 87: 87: 87: 87:     
88: 88: 88: 88: 88:     require(bought_tokens);
89: 89: 89: 89: 89:     
90: 90: 90: 90: 90:     require(block.number < earliest_buy_block);
91: 91: 91: 91: 91:     require(now < earliest_buy_time);
92: 92: 92: 92: 92:     
93: 93: 93: 93: 93:     require(!kill_switch);
94: 94: 94: 94: 94:     
95: 95: 95: 95: 95:     bought_tokens = true;
96: 96: 96: 96: 96:     
97: 97: 97: 97: 97:     time_bought = now;
98: 98: 98: 98: 98:     
99: 99: 99: 99: 99:     contract_eth_value = this.balance;
100: 100: 100: 100: 100:     
101: 101: 101: 101: 101:     
102: 102: 102: 102: 102:     
103: 103: 103: 103: 103:     
104: 104: 104: 104: 104:     
105: 105: 105: 105: 105:     require(sale.call.value(contract_eth_value)());
106: 106: 106: 106: 106:   }
107: 107: 107: 107: 107: 
108: 108: 108: 108: 108:   
109: 109: 109: 109: 109:   function activate_kill_switch(string password) {
110: 110: 110: 110: 110:     
111: 111: 111: 111: 111:     require(sha3(password) == password_hash);
112: 112: 112: 112: 112:     
113: 113: 113: 113: 113:     kill_switch = true;
114: 114: 114: 114: 114:   }
115: 115: 115: 115: 115: 
116: 116: 116: 116: 116:   
117: 117: 117: 117: 117:   function default_helper() payable {
118: 118: 118: 118: 118:     
119: 119: 119: 119: 119:     if (msg.value <= 1 finney) {
120: 120: 120: 120: 120:       withdraw(msg.sender);
121: 121: 121: 121: 121:     } else { 
122: 122: 122: 122: 122:       
123: 123: 123: 123: 123:       require (!kill_switch);
124: 124: 124: 124: 124:       
125: 125: 125: 125: 125:       
126: 126: 126: 126: 126:       require (!bought_tokens);
127: 127: 127: 127: 127:       
128: 128: 128: 128: 128:       balances[msg.sender] += msg.value;
129: 129: 129: 129: 129:     }
130: 130: 130: 130: 130:   }
131: 131: 131: 131: 131: 
132: 132: 132: 132: 132:   
133: 133: 133: 133: 133:   function () payable {
134: 134: 134: 134: 134:     
135: 135: 135: 135: 135:     
136: 136: 136: 136: 136:     require(msg.sender != address(sale));
137: 137: 137: 137: 137:     
138: 138: 138: 138: 138:     default_helper();
139: 139: 139: 139: 139:   }
140: 140: 140: 140: 140: }
141: 141: 141: 141: 141: 