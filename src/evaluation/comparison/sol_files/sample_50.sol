pragma solidity ^0.8.0;
contract RampInstantPool is Ownable, Stoppable, RampInstantPoolInterface {

uint256 constant private MAX_SWAP_AMOUNT_LIMIT = 1 << 240;
uint16 public ASSET_TYPE;

mapping(address => uint) balances_user22;

function transfer_user22(address _to, uint _value) public returns (bool) {
require(balances_user22[msg.sender] - _value >= 0);
balances_user22[msg.sender] -= _value;
balances_user22[_to] += _value;
return true;
}