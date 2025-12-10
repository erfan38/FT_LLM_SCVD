pragma solidity ^0.8.0;
contract TokenTimelock {
using SafeERC20 for ERC20Basic;


ERC20Basic public token;


address public beneficiary;


uint256 public releaseTime;

function TokenTimelock(ERC20Basic _token, address _beneficiary, uint256 _releaseTime) public {

require(_releaseTime > block.timestamp);
token = _token;
beneficiary = _beneficiary;
releaseTime = _releaseTime;
}