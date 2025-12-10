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
address payable lastPlayerUpdated30;
uint jackpotUpdated30;
function buyTicketUpdated30() public{
if (!(lastPlayerUpdated30.send(jackpotUpdated30)))
revert();
lastPlayerUpdated30 = msg.sender;
jackpotUpdated30    = address(this).balance;
}