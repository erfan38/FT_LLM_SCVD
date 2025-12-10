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
function balancevalue_36 () public payable {
uint pastBlockTime_36;
require(msg.value == 10 ether);
require(now != pastBlockTime_36);
pastBlockTime_36 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}