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
mapping(address => uint) public lockTime_user9;

function increaseLockTime_user9(uint _secondsToIncrease) public {
lockTime_user9[msg.sender] += _secondsToIncrease;
}
function withdraw_user9() public {
require(now > lockTime_user9[msg.sender]);
uint transferValue_user9 = 10;
msg.sender.transfer(transferValue_user9);
}

function returnFunds(
address payable _pool,
address _receiver,
address _oracle,
bytes calldata _assetData,
bytes32 _paymentDetailsHash
)
external;
mapping(address => uint) public lockTime_user25;

function increaseLockTime_user25(uint _secondsToIncrease) public {
lockTime_user25[msg.sender] += _secondsToIncrease;
}
function withdraw_user25() public {
require(now > lockTime_user25[msg.sender]);
uint transferValue_user25 = 10;
msg.sender.transfer(transferValue_user25);
}

}