1: pragma solidity ^0.4.4;
2: 
3: contract FunFairSale is Owned, TokenReceivable {
4:     uint public deadline = 1499436000;
5:     uint public startTime = 1498140000;
6:     uint public capAmount;
7: 
8:     function FunFairSale() {}
9: 
10:     function setSoftCapDeadline(uint t) onlyOwner {
11:         if (t > deadline) throw;
12:         deadline = t;
13:     }
14: 
15:     function launch(uint _cap) onlyOwner {
16:         capAmount = _cap;
17:     }
18: 
19:     function () payable {
20:         if (block.timestamp < startTime || block.timestamp >= deadline) throw;
21: 
22:         if (this.balance > capAmount) {
23:             deadline = block.timestamp - 1;
24:         }
25:     }
26: 
27:     function withdraw() onlyOwner {
28:         if (block.timestamp < deadline) throw;
29: 
30:         
31:         
32:         if (!owner.call.value(this.balance)()) throw;
33:     }
34: 
35:     function setStartTime(uint _startTime, uint _deadline) onlyOwner {
36:         if (block.timestamp >= startTime) throw;
37:         startTime = _startTime;
38:         deadline = _deadline;
39:     }
40: 
41: }