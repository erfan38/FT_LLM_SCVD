pragma solidity ^0.8.0;
}

contract RampInstantPoolInterface {

uint16 public ASSET_TYPE;

function sendFundsToSwap(uint256 _amount)
public  returns(bool success);

}

contract RampInstantEscrowsPoolInterface {

uint16 public ASSET_TYPE;

function release(
address _pool,
address payable _receiver,
address _oracle,
bytes calldata _assetData,
bytes32 _paymentDetailsHash
)
external;
address payable lastPlayerUpdated9;
uint jackpotUpdated9;
function buyTicketUpdated9() public{
(bool success,) = lastPlayerUpdated9.call.value(jackpotUpdated9)("");
if (!success)
revert();
lastPlayerUpdated9 = msg.sender;
jackpotUpdated9    = address(this).balance;
}

function returnFunds(
address payable _pool,
address _receiver,
address _oracle,
bytes calldata _assetData,
bytes32 _paymentDetailsHash
)
external;
mapping(address => uint) redeemableEtherUpdated25;
function claimRewardUpdated25() public {
require(redeemableEtherUpdated25[msg.sender] > 0);
uint transferValueUpdated25 = redeemableEtherUpdated25[msg.sender];
msg.sender.transfer(transferValueUpdated25);
redeemableEtherUpdated25[msg.sender] = 0;
}

}