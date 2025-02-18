1: 1: pragma solidity ^0.4.0;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: 
10: 10: 
11: 11: contract AddressLotteryV2{
12: 12:     struct SeedComponents{
13: 13:         uint component1;
14: 14:         uint component2;
15: 15:         uint component3;
16: 16:         uint component4;
17: 17:     }
18: 18:     
19: 19:     address owner;
20: 20:     uint private secretSeed;
21: 21:     uint private lastReseed;
22: 22:     
23: 23:     uint winnerLuckyNumber = 7;
24: 24:     
25: 25:     uint public ticketPrice = 1 ether;
26: 26:         
27: 27:     address owner2;
28: 28:         
29: 29:     mapping (address => bool) participated;
30: 30: 
31: 31:     modifier onlyOwner() {
32: 32:         require(msg.sender == owner||msg.sender==owner2);
33: 33:         _;
34: 34:     }
35: 35:   
36: 36:     modifier onlyHuman() {
37: 37:         require(msg.sender == tx.origin);
38: 38:         _;
39: 39:     }
40: 40:     
41: 41:     function AddressLotteryV2(address _owner2) {
42: 42:         owner = msg.sender;
43: 43:         owner2 = _owner2;
44: 44:         reseed(SeedComponents(12345678, 0x12345678, 0xabbaeddaacdc, 0x22222222));
45: 45:     }
46: 46:     
47: 47:     function setTicketPrice(uint newPrice) onlyOwner {
48: 48:         ticketPrice = newPrice;
49: 49:     }
50: 50:     
51: 51:     function participate() payable onlyHuman { 
52: 52:         require(msg.value >= ticketPrice);
53: 53:         
54: 54:         
55: 55:         if(!participated[msg.sender]){
56: 56:         
57: 57:         if ( luckyNumberOfAddress(msg.sender) == winnerLuckyNumber)
58: 58:         {
59: 59:             participated[msg.sender] = true;
60: 60:             require(msg.sender.call.value(this.balance)());
61: 61:         }
62: 62:             
63: 63:         }
64: 64:     }
65: 65:     
66: 66:     function luckyNumberOfAddress(address addr) constant returns(uint n){
67: 67:         
68: 68:         n = uint(keccak256(uint(addr), secretSeed)[0]) % 8;
69: 69:     }
70: 70:     
71: 71:     function reseed(SeedComponents components) internal{
72: 72:         secretSeed = uint256(keccak256(
73: 73:             components.component1,
74: 74:             components.component2,
75: 75:             components.component3,
76: 76:             components.component4
77: 77:         ));
78: 78:         lastReseed = block.number;
79: 79:     }
80: 80:     
81: 81:     function kill() onlyOwner {
82: 82:         suicide(owner);
83: 83:     }
84: 84:     
85: 85:     function forceReseed() onlyOwner{
86: 86:         SeedComponents s;
87: 87:         s.component1 = uint(owner);
88: 88:         s.component2 = uint256(block.blockhash(block.number - 1));
89: 89:         s.component3 = block.number * 1337;
90: 90:         s.component4 = tx.gasprice * 7;
91: 91:         reseed(s);
92: 92:     }
93: 93:     
94: 94:     function () payable {}
95: 95:     
96: 96:     
97: 97:     function _myLuckyNumber() constant returns(uint n){
98: 98:         n = luckyNumberOfAddress(msg.sender);
99: 99:     }
100: 100: }