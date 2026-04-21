1: pragma solidity ^0.4.24;
2: 
3: 
4: 
5: 
6: contract ERC223Token is ERC223, SafeMathERC223 {
7:   mapping(address => uint) public balances;
8: 
9:   string public name;
10:   string public symbol;
11:   uint8 public decimals;
12:   uint256 public totalSupply;
13: 
14:   
15:   constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
16:         symbol = _symbol;
17:         name = _name;
18:         decimals = _decimals;
19:         totalSupply = _totalSupply;
20:         balances[msg.sender] = _totalSupply;
21:   }
22: 
23:   
24:   function name() public view returns (string _name) {
25:     return name;
26:   }
27: 
28:   
29:   function symbol() public view returns (string _symbol) {
30:     return symbol;
31:   }
32: 
33:   
34:   function decimals() public view returns (uint8 _decimals) {
35:     return decimals;
36:   }
37: 
38:   
39:   function totalSupply() public view returns (uint256 _totalSupply) {
40:     return totalSupply;
41:   }
42: 
43:   
44:   function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
45:     if (isContract(_to)) {
46:       return transferToContractCustom(msg.sender, _to, _value, _data, _custom_fallback);
47:     } else {
48:       return transferToAddress(msg.sender, _to, _value, _data);
49:     }
50:   }
51: 
52:   
53:   function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
54:     if (isContract(_to)) {
55:       return transferToContract(msg.sender, _to, _value, _data);
56:     } else {
57:       return transferToAddress(msg.sender, _to, _value, _data);
58:     }
59:   }
60: 
61:   
62:   
63:   function transfer(address _to, uint _value) public returns (bool success) {
64:     
65:     
66:     bytes memory empty;
67:     if (isContract(_to)) {
68:       return transferToContract(msg.sender, _to, _value, empty);
69:     } else {
70:       return transferToAddress(msg.sender, _to, _value, empty);
71:     }
72:   }
73: 
74:   function balanceOf(address _owner) public view returns (uint balance) {
75:     return balances[_owner];
76:   }
77: 
78:   
79:   function isContract(address _addr) internal view returns (bool is_contract) {
80:     uint length;
81:     assembly { 
82:           
83:           length := extcodesize(_addr)
84:     }
85:     return (length > 0);
86:   }
87: 
88:   
89:   function transferToAddress(address _from, address _to, uint _value, bytes _data) internal returns (bool success) {
90:     if (balanceOf(_from) < _value) revert();
91:     balances[_from] = safeSub(balanceOf(_from), _value);
92:     balances[_to] = safeAdd(balanceOf(_to), _value);
93:     emit Transfer(_from, _to, _value, _data);
94:     return true;
95:   }
96: 
97:   
98:   function transferToContract(address _from, address _to, uint _value, bytes _data) internal returns (bool success) {
99:     if (balanceOf(_from) < _value) revert();
100:     balances[_from] = safeSub(balanceOf(_from), _value);
101:     balances[_to] = safeAdd(balanceOf(_to), _value);
102:     ContractReceiver receiver = ContractReceiver(_to);
103:     receiver.tokenFallback(_from, _value, _data);
104:     emit Transfer(_from, _to, _value, _data);
105:     return true;
106:   }
107: 
108:   
109:   function transferToContractCustom(address _from, address _to, uint _value, bytes _data, string _custom_fallback) internal returns (bool success) {
110:     if (balanceOf(_from) < _value) revert();
111:     balances[_from] = safeSub(balanceOf(_from), _value);
112:     balances[_to] = safeAdd(balanceOf(_to), _value);
113:     
114:     assert(_to.call.value(0)(abi.encodeWithSignature(_custom_fallback, _from, _value, _data)));
115:     emit Transfer(_from, _to, _value, _data);
116:     return true;
117:   }
118: }