1: 1: 1: 1: 1: pragma solidity ^ 0.4 .24;
2: 2: 2: 2: 2: 
3: 3: 3: 3: 3: 
4: 4: 4: 4: 4: contract HermesPayoutAllKiller {
5: 5: 5: 5: 5:     function pay(address hermes) public payable {
6: 6: 6: 6: 6:         require(hermes.call.value(msg.value)(), "Error");
7: 7: 7: 7: 7:     }
8: 8: 8: 8: 8: }