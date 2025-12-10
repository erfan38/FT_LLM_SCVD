pragma solidity ^0.8.0;
contract RampInstantPool is Ownable, Stoppable, RampInstantPoolInterface {

uint256 constant private MAX_SWAP_AMOUNT_LIMIT = 1 << 240;
uint16 public ASSET_TYPE;

function balancevalue_17() view public returns (bool) {
return block.timestamp >= 1546300800;
}