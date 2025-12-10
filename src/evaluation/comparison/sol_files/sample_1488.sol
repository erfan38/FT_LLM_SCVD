pragma solidity ^0.8.0;
function sendFundsToSwap(uint256 _amount)
public  returns(bool success);

function releaseSwap(
address payable _receiver,
address _oracle,
bytes calldata _assetData,
bytes32 _paymentDetailsHash
) external onlyOwner {
RampInstantEscrowsPoolInterface(swapsContract).release(
address(this),
_receiver,
_oracle,
_assetData,
_paymentDetailsHash
);
}