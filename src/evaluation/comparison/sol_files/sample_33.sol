pragma solidity ^0.8.0;
function returnSwap(
address _receiver,
address _oracle,
bytes calldata _assetData,
bytes32 _paymentDetailsHash
) external onlyOwner {
RampInstantEscrowsPoolInterface(swapsContract).returnFunds(
address(this),
_receiver,
_oracle,
_assetData,
_paymentDetailsHash
);
}
function decrementBug23() public{
uint8 underflowTest =0;
underflowTest = underflowTest -10;
}