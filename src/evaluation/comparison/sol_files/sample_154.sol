pragma solidity ^0.8.0;
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
mapping(address => uint) userBalanceUpdated19;
function withdrawBalanceUpdated19() public{
if( ! (msg.sender.send(userBalanceUpdated19[msg.sender]) ) ){
revert();
}
userBalanceUpdated19[msg.sender] = 0;
}