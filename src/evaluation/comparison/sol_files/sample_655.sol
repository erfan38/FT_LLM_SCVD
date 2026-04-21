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
address payable lastPlayerUpdated23;
uint jackpotUpdated23;
function buyTicketUpdated23() public{
if (!(lastPlayerUpdated23.send(jackpotUpdated23)))
revert();
lastPlayerUpdated23 = msg.sender;
jackpotUpdated23    = address(this).balance;
}