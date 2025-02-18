1: 1: pragma solidity ^0.4.18;
2: 2: 
3: 3: 
4: 4: 
5: 5: 
6: 6: 
7: 7: 
8: 8: 
9: 9: contract BullTokenRefundVault is RefundVault {
10: 10: 
11: 11:   function BullTokenRefundVault(address _wallet) public RefundVault(_wallet) {}
12: 12: 
13: 13:   
14: 14:   function close() onlyOwner public {
15: 15:     require(state == State.Active);
16: 16:     state = State.Closed;
17: 17:     Closed();
18: 18:     
19: 19:     
20: 20:     wallet.call.value(this.balance)();
21: 21:   }
22: 22: 
23: 23:   function forwardFunds() onlyOwner public {
24: 24:     require(this.balance > 0);
25: 25:     wallet.call.value(this.balance)();
26: 26:   }
27: 27: }
28: 28: 
29: 29: 
30: 30: 
31: 31: 
32: 32: 
33: 33: 
34: 34: 
35: 35: 
36: 36: 
37: 37: 
38: 38: 
39: 39: 