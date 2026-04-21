pragma solidity ^0.8.0;
function setSwapsContract(
address payable _swapsContract
) public onlyOwner validateSwapsContract(_swapsContract, ASSET_TYPE) {
address oldSwapsContract = swapsContract;
swapsContract = _swapsContract;
emit SwapsContractChanged(oldSwapsContract, _swapsContract);
}
function incrementBug4(uint8 incrementBugParam4) public{
uint8 overflowTest1=0;
overflowTest1 = overflowTest1 + incrementBugParam4;
}