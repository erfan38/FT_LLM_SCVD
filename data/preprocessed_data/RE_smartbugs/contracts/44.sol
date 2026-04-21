1: 1: pragma solidity ^0.4.13;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: contract EnjinBuyer {
8: 8:   mapping (address => uint256) public balances;
9: 9:   mapping (address => uint256) public balances_for_refund;
10: 10:   bool public bought_tokens;
11: 11:   bool public token_set;
12: 12:   uint256 public contract_eth_value;
13: 13:   uint256 public refund_contract_eth_value;
14: 14:   uint256 public refund_eth_value;
15: 15:   bool public kill_switch;
16: 16:   bytes32 password_hash = 0x8bf0720c6e610aace867eba51b03ab8ca908b665898b10faddc95a96e829539d;
17: 17:   address public developer = 0x0639C169D9265Ca4B4DEce693764CdA8ea5F3882;
18: 18:   address public sale = 0xc4740f71323129669424d1Ae06c42AEE99da30e2;
19: 19:   ERC20 public token;
20: 20:   uint256 public eth_minimum = 3235 ether;
21: 21: 
22: 22:   function set_token(address _token) {
23: 23:     require(msg.sender == developer);
24: 24:     token = ERC20(_token);
25: 25:     token_set = true;
26: 26:   }
27: 27:   
28: 28:   function activate_kill_switch(string password) {
29: 29:     require(msg.sender == developer || sha3(password) == password_hash);
30: 30:     kill_switch = true;
31: 31:   }
32: 32:   
33: 33:   function personal_withdraw(){
34: 34:     if (balances[msg.sender] == 0) return;
35: 35:     if (!bought_tokens) {
36: 36:       uint256 eth_to_withdraw = balances[msg.sender];
37: 37:       balances[msg.sender] = 0;
38: 38:       msg.sender.transfer(eth_to_withdraw);
39: 39:     }
40: 40:     else {
41: 41:       require(token_set);
42: 42:       uint256 contract_token_balance = token.balanceOf(address(this));
43: 43:       require(contract_token_balance != 0);
44: 44:       uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
45: 45:       contract_eth_value -= balances[msg.sender];
46: 46:       balances[msg.sender] = 0;
47: 47:       uint256 fee = tokens_to_withdraw / 100;
48: 48:       require(token.transfer(developer, fee));
49: 49:       require(token.transfer(msg.sender, tokens_to_withdraw - fee));
50: 50:     }
51: 51:   }
52: 52: 
53: 53: 
54: 54:   
55: 55:   
56: 56:   
57: 57:   function withdraw_token(address _token){
58: 58:     ERC20 myToken = ERC20(_token);
59: 59:     if (balances[msg.sender] == 0) return;
60: 60:     require(msg.sender != sale);
61: 61:     if (!bought_tokens) {
62: 62:       uint256 eth_to_withdraw = balances[msg.sender];
63: 63:       balances[msg.sender] = 0;
64: 64:       msg.sender.transfer(eth_to_withdraw);
65: 65:     }
66: 66:     else {
67: 67:       uint256 contract_token_balance = myToken.balanceOf(address(this));
68: 68:       require(contract_token_balance != 0);
69: 69:       uint256 tokens_to_withdraw = (balances[msg.sender] * contract_token_balance) / contract_eth_value;
70: 70:       contract_eth_value -= balances[msg.sender];
71: 71:       balances[msg.sender] = 0;
72: 72:       uint256 fee = tokens_to_withdraw / 100;
73: 73:       require(myToken.transfer(developer, fee));
74: 74:       require(myToken.transfer(msg.sender, tokens_to_withdraw - fee));
75: 75:     }
76: 76:   }
77: 77: 
78: 78:   
79: 79:   function withdraw_refund(){
80: 80:     require(refund_eth_value!=0);
81: 81:     require(balances_for_refund[msg.sender] != 0);
82: 82:     uint256 eth_to_withdraw = (balances_for_refund[msg.sender] * refund_eth_value) / refund_contract_eth_value;
83: 83:     refund_contract_eth_value -= balances_for_refund[msg.sender];
84: 84:     refund_eth_value -= eth_to_withdraw;
85: 85:     balances_for_refund[msg.sender] = 0;
86: 86:     msg.sender.transfer(eth_to_withdraw);
87: 87:   }
88: 88: 
89: 89:   function () payable {
90: 90:     if (!bought_tokens) {
91: 91:       balances[msg.sender] += msg.value;
92: 92:       balances_for_refund[msg.sender] += msg.value;
93: 93:       if (this.balance < eth_minimum) return;
94: 94:       if (kill_switch) return;
95: 95:       require(sale != 0x0);
96: 96:       bought_tokens = true;
97: 97:       contract_eth_value = this.balance;
98: 98:       refund_contract_eth_value = this.balance;
99: 99:       require(sale.call.value(contract_eth_value)());
100: 100:       require(this.balance==0);
101: 101:     } else {
102: 102:       
103: 103:       
104: 104:       
105: 105:       require(msg.sender == sale);
106: 106:       refund_eth_value += msg.value;
107: 107:     }
108: 108:   }
109: 109: }