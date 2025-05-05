1: 1: pragma solidity ^0.4.17;
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
14: 14: contract ICOSyndicate {
15: 15:     
16: 16:     mapping (address => uint256) public balances;
17: 17:     
18: 18:     bool public bought_tokens;
19: 19:     
20: 20:     uint256 public contract_eth_value;
21: 21:     
22: 22:     bool public kill_switch;
23: 23: 
24: 24:     
25: 25:     uint256 public eth_cap = 30000 ether;
26: 26:     
27: 27:     address public developer = 0x91d97da49d3cD71B475F46d719241BD8bb6Af18f;
28: 28:     
29: 29:     address public sale;
30: 30:     
31: 31:     ERC20 public token;
32: 32: 
33: 33:     
34: 34:     function set_addresses(address _sale, address _token) public {
35: 35:         
36: 36:         require(msg.sender == developer);
37: 37:         
38: 38:         require(sale == 0x0);
39: 39:         
40: 40:         sale = _sale;
41: 41:         token = ERC20(_token);
42: 42:     }
43: 43: 
44: 44:     
45: 45:     function activate_kill_switch() public {
46: 46:         
47: 47:         require(msg.sender == developer);
48: 48:         
49: 49:         kill_switch = true;
50: 50:     }
51: 51: 
52: 52:     
53: 53:     function withdraw(address user) public {
54: 54:         
55: 55:         require(bought_tokens);
56: 56:         
57: 57:         if (balances[user] == 0) return;
58: 58:         
59: 59:         if (!bought_tokens) {
60: 60:             
61: 61:             uint256 eth_to_withdraw = balances[user];
62: 62:             
63: 63:             balances[user] = 0;
64: 64:             
65: 65:             user.transfer(eth_to_withdraw);
66: 66:         }
67: 67:         
68: 68:         else {
69: 69:             
70: 70:             uint256 contract_token_balance = token.balanceOf(address(this));
71: 71:             
72: 72:             require(contract_token_balance != 0);
73: 73:             
74: 74:             uint256 tokens_to_withdraw = (balances[user] * contract_token_balance) / contract_eth_value;
75: 75:             
76: 76:             contract_eth_value -= balances[user];
77: 77:             
78: 78:             balances[user] = 0;
79: 79:             
80: 80:             require(token.transfer(user, tokens_to_withdraw));
81: 81: 
82: 82:         }
83: 83: 
84: 84:     }
85: 85: 
86: 86:     
87: 87:     function buy() public {
88: 88:         
89: 89:         if (bought_tokens) return;
90: 90:         
91: 91:         if (kill_switch) return;
92: 92:         
93: 93:         require(sale != 0x0);
94: 94:         
95: 95:         bought_tokens = true;
96: 96:         
97: 97:         contract_eth_value = this.balance;
98: 98:         
99: 99:         
100: 100:         require(sale.call.value(contract_eth_value)());
101: 101:     }
102: 102: 
103: 103:     
104: 104:     function () public payable {
105: 105:         
106: 106:         require(!kill_switch);
107: 107:         
108: 108:         require(!bought_tokens);
109: 109:         
110: 110:         require(this.balance < eth_cap);
111: 111:         
112: 112:         balances[msg.sender] += msg.value;
113: 113:     }
114: 114: }