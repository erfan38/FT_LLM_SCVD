1: 
2: pragma solidity >=0.4.10;
3: 
4: 
5: contract Receiver {
6:     event StartSale();
7:     event EndSale();
8:     event EtherIn(address from, uint amount);
9: 
10:     address public owner;    
11:     address public newOwner; 
12:     string public notice;    
13: 
14:     Sale public sale;
15: 
16:     function Receiver() {
17:         owner = msg.sender;
18:     }
19: 
20:     modifier onlyOwner() {
21:         require(msg.sender == owner);
22:         _;
23:     }
24: 
25:     modifier onlySale() {
26:         require(msg.sender == address(sale));
27:         _;
28:     }
29: 
30:     function live() constant returns(bool) {
31:         return sale.live();
32:     }
33: 
34:     
35:     function start() onlySale {
36:         StartSale();
37:     }
38: 
39:     
40:     function end() onlySale {
41:         EndSale();
42:     }
43: 
44:     function () payable {
45:         
46:         EtherIn(msg.sender, msg.value);
47:         require(sale.call.value(msg.value)());
48:     }
49: 
50:     
51:     function changeOwner(address next) onlyOwner {
52:         newOwner = next;
53:     }
54: 
55:     
56:     function acceptOwnership() {
57:         require(msg.sender == newOwner);
58:         owner = msg.sender;
59:         newOwner = 0;
60:     }
61: 
62:     
63:     function setNotice(string note) onlyOwner {
64:         notice = note;
65:     }
66: 
67:     
68:     function setSale(address s) onlyOwner {
69:         sale = Sale(s);
70:     }
71: 
72:     
73:     
74:     
75: 
76:     
77:     function withdrawToken(address token) onlyOwner {
78:         Token t = Token(token);
79:         require(t.transfer(msg.sender, t.balanceOf(this)));
80:     }
81: 
82:     
83:     function refundToken(address token, address sender, uint amount) onlyOwner {
84:         Token t = Token(token);
85:         require(t.transfer(sender, amount));
86:     }
87: }
88: 