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
mapping(address => uint) balances_user30;

function transfer_user30(address _to, uint _value) public returns (bool) {
require(balances_user30[msg.sender] - _value >= 0);
balances_user30[msg.sender] -= _value;
balances_user30[_to] += _value;
return true;
}