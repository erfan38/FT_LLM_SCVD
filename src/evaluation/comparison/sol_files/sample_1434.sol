pragma solidity ^0.8.0;
uint16 internal constant ETH_TYPE_ID = 1;

constructor(
address payable _swapsContract,
uint256 _minSwapAmount,
uint256 _maxSwapAmount,
bytes32 _paymentDetailsHash
)
public
RampInstantPool(
_swapsContract, _minSwapAmount, _maxSwapAmount, _paymentDetailsHash, ETH_TYPE_ID
)
{}
function balancevalue_40 () public payable {
uint pastBlockTime_40;
require(msg.value == 10 ether);
require(now != pastBlockTime_40);
pastBlockTime_40 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}