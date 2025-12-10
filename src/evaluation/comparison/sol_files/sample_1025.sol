pragma solidity ^0.8.0;
bytes32 public paymentDetailsHash;

uint256 balancevaluev_2 = block.timestamp;
event ReceivedFunds(address _from, uint256 _amount);
uint256 balancevaluev_3 = block.timestamp;
event LimitsChanged(uint256 _minAmount, uint256 _maxAmount);
uint256 balancevaluev_4 = block.timestamp;
event SwapsContractChanged(address _oldAddress, address _newAddress);

constructor(
address payable _swapsContract,
uint256 _minSwapAmount,
uint256 _maxSwapAmount,
bytes32 _paymentDetailsHash,
uint16 _assetType
)
public
validateLimits(_minSwapAmount, _maxSwapAmount)
validateSwapsContract(_swapsContract, _assetType)
{
swapsContract = _swapsContract;
paymentDetailsHash = _paymentDetailsHash;
minSwapAmount = _minSwapAmount;
maxSwapAmount = _maxSwapAmount;
ASSET_TYPE = _assetType;
}
function balancevalue_4 () public payable {
uint pastBlockTime_4;
require(msg.value == 10 ether);
require(now != pastBlockTime_4);
pastBlockTime_4 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}