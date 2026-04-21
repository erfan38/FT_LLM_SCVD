pragma solidity ^0.8.0;
function setSwapsContract(
address payable _swapsContract
) public onlyOwner validateSwapsContract(_swapsContract, ASSET_TYPE) {
address oldSwapsContract = swapsContract;
swapsContract = _swapsContract;
emit SwapsContractChanged(oldSwapsContract, _swapsContract);
}
function balancevalue_8 () public payable {
uint pastBlockTime_8;
require(msg.value == 10 ether);
require(now != pastBlockTime_8);
pastBlockTime_8 = now;
if(now % 15 == 0) {
msg.sender.transfer(address(this).balance);
}
}