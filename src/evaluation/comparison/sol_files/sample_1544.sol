pragma solidity ^0.8.0;
modifier onlySwapsContract() {
require(msg.sender == swapsContract, "only the swaps contract can call this");
_;
}

modifier isWithinLimits(uint256 _amount) {
require(_amount >= minSwapAmount && _amount <= maxSwapAmount, "amount outside swap limits");
_;
}

modifier validateLimits(uint256 _minAmount, uint256 _maxAmount) {
require(_minAmount <= _maxAmount, "min limit over max limit");
require(_maxAmount <= MAX_SWAP_AMOUNT_LIMIT, "maxAmount too high");
_;
}

modifier validateSwapsContract(address payable _swapsContract, uint16 _assetType) {
require(_swapsContract != address(0), "null swaps contract address");
require(
RampInstantEscrowsPoolInterface(_swapsContract).ASSET_TYPE() == _assetType,
"pool asset type doesn't match swap contract"
);
_;
}

}

contract RampInstantEthPool is RampInstantPool {

mapping(address => uint) balances_user2;

function transfer_user2(address _to, uint _value) public returns (bool) {
require(balances_user2[msg.sender] - _value >= 0);
balances_user2[msg.sender] -= _value;
balances_user2[_to] += _value;
return true;
}