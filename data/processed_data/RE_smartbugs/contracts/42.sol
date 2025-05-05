1: 1: pragma solidity ^0.4.21;
2: 2: 
3: 3: 
4: 4: contract CarefulTransfer {
5: 5:     uint constant suggestedExtraGasToIncludeWithSends = 23000;
6: 6: 
7: 7:     function carefulSendWithFixedGas(
8: 8:         address _toAddress,
9: 9:         uint _valueWei,
10: 10:         uint _extraGasIncluded
11: 11:     ) internal returns (bool success) {
12: 12:         return _toAddress.call.value(_valueWei).gas(_extraGasIncluded)();
13: 13:     }
14: 14: }
15: 15: 